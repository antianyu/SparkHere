//
//  MessagesViewController.m
//  IP
//
//  Created by Tianyu An on 14-6-11.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "MessagesViewController.h"
#import "MessageDetailViewController.h"
#import "Message.h"
#import "User.h"
#import "MessageTableViewCell.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "PassBoolDelegate.h"
#import <Parse/Parse.h>
#import "MJRefresh/MJRefresh.h"
#import "MJRefresh/MJRefreshHeaderView.h"


@interface MessagesViewController ()

@end

@implementation MessagesViewController
{
    AppDelegate *appDelegate;
    MBProgressHUD *progressHUD;
    NSMutableArray *messageList;
}

@synthesize messagesTableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"Messages";
    
    appDelegate=[[UIApplication sharedApplication] delegate];
    progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:appDelegate.backgroundImage]];
    
    NSDictionary *attributes=[NSDictionary dictionaryWithObjectsAndKeys:
                              [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavigationBar.png"] forBarMetrics:UIBarMetricsDefault];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self.messagesTableView setBackgroundColor:[UIColor clearColor]];
    [self.messagesTableView setSeparatorInset:UIEdgeInsetsZero];
//    [self.messagesTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    messageList=[[NSMutableArray alloc]init];
    
    [self.messagesTableView addHeaderWithTarget:self action:@selector(headerRefreshing)];
    
//    [self.messagesTableView addFooterWithTarget:self action:@selector(footerRefreshing)];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (appDelegate.refreshMessageList||appDelegate.loadMoreMessages)
    {
        [self.messagesTableView headerBeginRefreshing];
        appDelegate.refreshMessageList=false;
        appDelegate.loadMoreMessages=false;
    }
    else
    {
        [self.messagesTableView reloadData];
    }
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.hidesBottomBarWhenPushed=NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return messageList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *messageCellIdentifier = @"MessageCellIdentifier";
    static BOOL nibsRegistered=NO;
    if (!nibsRegistered)
    {
        UINib *nib=[UINib nibWithNibName:@"MessageTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:messageCellIdentifier];
        nibsRegistered=YES;
    }
    
    Message *message=[messageList objectAtIndex:indexPath.row];
    MessageTableViewCell *cell;
    if (message.image==nil)
    {
        static NSString *messageWithoutImageCellIdentifier = @"MessageWithoutImageCellIdentifier";
        cell = [tableView dequeueReusableCellWithIdentifier:messageWithoutImageCellIdentifier];
        if (cell==nil)
        {
            cell=[[[NSBundle mainBundle]loadNibNamed:@"MessageTableViewCell" owner:nil options:nil]lastObject];
        }
    }
    else
    {
        static NSString *messageWithImageCellIdentifier = @"MessageWithImageCellIdentifier";
        cell = [tableView dequeueReusableCellWithIdentifier:messageWithImageCellIdentifier];
        if (cell==nil)
        {
            cell=[[[NSBundle mainBundle]loadNibNamed:@"MessageTableViewCell" owner:nil options:nil]lastObject];
        }
    }
    
    [cell setMessage:message fontSize:appDelegate.settings.fontSize];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageTableViewCell *cell=(MessageTableViewCell*)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageDetailViewController *controller=[[MessageDetailViewController alloc]init];
    controller.message=[messageList objectAtIndex:indexPath.row];
    self.hidesBottomBarWhenPushed=YES;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)headerRefreshing
{
    // refresh tableView UI
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if (messageList.count==0)
        {
            if (appDelegate.refreshMyChannelList)
            {
                [appDelegate constructMyChannelList];
                appDelegate.refreshMyChannelList=false;
            }
            [self constructMessageList];
        }
        else
        {
            [self loadMoreMessages];
        }
        
        [self.messagesTableView reloadData];
        
        [self.messagesTableView headerEndRefreshing];
    });
}

- (void)footerRefreshing
{
    // refresh tableView UI
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self.messagesTableView reloadData];
        
        [self.messagesTableView footerEndRefreshing];
    });
}

- (void)constructMessageList
{
    PFGeoPoint *currentLocation=[self getCurrentLocation];
    appDelegate.lastUpdateTime=[NSDate date];
    
    NSMutableArray *subQueries=[[NSMutableArray alloc]init];
    
    // if the user is in the range of channel, add query constraint of the channel
    for (Channel *channel in appDelegate.myChannelList)
    {
        if (pow(currentLocation.latitude-channel.location.latitude, 2)+
            pow(currentLocation.longitude-channel.location.longitude, 2)<=
            pow(channel.range, 2))
        {
            PFQuery *query=[PFQuery queryWithClassName:@"Message"];
            [query whereKey:@"channelID" equalTo:channel.channelID];
            [subQueries addObject:query];
        }
    }
    
    if (subQueries.count>0)
    {
        PFQuery *query=[PFQuery orQueryWithSubqueries:subQueries];
        [query orderByDescending:@"updatedAt"];
        query.limit=20;
        NSArray *messages=[query findObjects];
        
        for (PFObject *object in messages)
        {
            query=[PFQuery queryWithClassName:@"User"];
            User *sender=[[User alloc]initWithPFObject:[query getObjectWithId:object[@"senderID"]]];
            
            PFFile *imageFile=object[@"image"];
            UIImage *image=[UIImage imageWithData:[imageFile getData]];
            
            Message *message=[[Message alloc]initWithContent:object[@"content"]
                                                   messageID:object.objectId
                                                      sender:sender
                                                     channel:[self findChannelFromMyChannelList:object[@"channelID"]]
                                                       image:image];
            [messageList addObject:message];
        }
    }
}

- (void)loadMoreMessages
{
    PFGeoPoint *currentLocation=[self getCurrentLocation];
    
    NSMutableArray *subQueries=[[NSMutableArray alloc]init];
    
    // if the user is in the range of channel, add query constraint of the channel
    for (Channel *channel in appDelegate.myChannelList)
    {
        if (pow(currentLocation.latitude-channel.location.latitude, 2)+
            pow(currentLocation.longitude-channel.location.longitude, 2)<=
            pow(channel.range, 2))
        {
            PFQuery *query=[PFQuery queryWithClassName:@"Message"];
            [query whereKey:@"channelID" equalTo:channel.channelID];
            [subQueries addObject:query];
        }
    }
    
    if (subQueries.count>0)
    {
        PFQuery *query=[PFQuery orQueryWithSubqueries:subQueries];
        [query whereKey:@"updatedAt" greaterThan:appDelegate.lastUpdateTime];
        [query orderByAscending:@"updatedAt"];
        appDelegate.lastUpdateTime=[NSDate date];
        
        NSArray *messages=[query findObjects];
        
        for (PFObject *object in messages)
        {
            query=[PFQuery queryWithClassName:@"User"];
            User *sender=[[User alloc]initWithPFObject:[query getObjectWithId:object[@"senderID"]]];
            
            PFFile *imageFile=object[@"image"];
            UIImage *image=[UIImage imageWithData:[imageFile getData]];
            
            Message *message=[[Message alloc]initWithContent:object[@"content"]
                                                   messageID:object.objectId
                                                      sender:sender
                                                     channel:[self findChannelFromMyChannelList:object[@"channelID"]]
                                                       image:image];
            [messageList insertObject:message atIndex:0];
        }
    }
}

- (PFGeoPoint *)getCurrentLocation
{
    PFGeoPoint *currentLocation=[PFGeoPoint geoPointWithLatitude:4 longitude:4];
    return currentLocation;
}

- (Channel *)findChannelFromMyChannelList:(NSString *)channelID
{
    for (Channel *channel in appDelegate.myChannelList)
    {
        if ([channel.channelID isEqualToString:channelID])
        {
            return channel;
        }
    }
    return nil;
}

@end
