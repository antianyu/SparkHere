//
//  MessagesViewController.m
//  SparkHere
//
//  Created by Tianyu An on 14-6-11.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <Parse/Parse.h>
#import "MessagesViewController.h"
#import "MessageDetailViewController.h"
#import "MessageTableViewCell.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "MJRefresh.h"
#import "User.h"
#import "Message.h"
#import "PassBoolDelegate.h"

@interface MessagesViewController ()

@end

@implementation MessagesViewController
{
    AppDelegate *appDelegate;
    MBProgressHUD *progressHUD;
    BOOL initMessageList;
}

@synthesize messagesTableView;

#pragma mark View
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"Messages";
    
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    progressHUD=[[MBProgressHUD alloc] initWithView:self.view];
    progressHUD.dimBackground = NO;
    progressHUD.userInteractionEnabled=NO;
    progressHUD.labelText = @"Please wait...";
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:appDelegate.backgroundImage]];
    
    [messagesTableView setBackgroundColor:[UIColor clearColor]];
    [messagesTableView setSeparatorInset:UIEdgeInsetsZero];
    [messagesTableView addHeaderWithTarget:self action:@selector(headerRefreshing)];
    [messagesTableView addFooterWithTarget:self action:@selector(footerRefreshing)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    PFInstallation *currentInstallation=[PFInstallation currentInstallation];
    if (currentInstallation.badge!=0)
    {
        self.tabBarItem.badgeValue=[NSString stringWithFormat:@"%ld", (long)currentInstallation.badge];
    }
    else
    {
        self.tabBarItem.badgeValue=nil;
    }
    
    if (appDelegate.refreshMessageList || appDelegate.loadMoreMessages)
    {
        [messagesTableView headerBeginRefreshing];
    }
    else
    {
        [messagesTableView reloadData];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.hidesBottomBarWhenPushed=NO;
    [progressHUD removeFromSuperview];
    [messagesTableView headerEndRefreshing];
}

#pragma mark UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return appDelegate.messageList.count;
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
    
    Message *message=[appDelegate.messageList objectAtIndex:indexPath.row];
    MessageTableViewCell *cell;
    if (message.image==nil)
    {
        static NSString *messageWithoutImageCellIdentifier = @"MessageWithoutImageCellIdentifier";
        cell = [tableView dequeueReusableCellWithIdentifier:messageWithoutImageCellIdentifier];
        if (cell==nil)
        {
            cell=[[[NSBundle mainBundle]loadNibNamed:@"MessageTableViewCell" owner:nil options:nil] lastObject];
        }
    }
    else
    {
        static NSString *messageWithImageCellIdentifier = @"MessageWithImageCellIdentifier";
        cell = [tableView dequeueReusableCellWithIdentifier:messageWithImageCellIdentifier];
        if (cell==nil)
        {
            cell=[[[NSBundle mainBundle]loadNibNamed:@"MessageTableViewCell" owner:nil options:nil] lastObject];
        }
    }
    
    [cell setMessage:message fontSize:appDelegate.settings.fontSize];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageTableViewCell *cell=(MessageTableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageDetailViewController *controller=[[MessageDetailViewController alloc]init];
    controller.message=[appDelegate.messageList objectAtIndex:indexPath.row];
    self.hidesBottomBarWhenPushed=YES;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)headerRefreshing
{
    // refresh tableView UI
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        appDelegate.loadMoreMessages=YES;
        if (appDelegate.lastUpdateTime==nil)
        {
            appDelegate.refreshMyChannelList=YES;
            appDelegate.refreshMessageList=YES;
        }
        [appDelegate constructListsFromMessageVC:YES tableView:messagesTableView tabBarItem:self.tabBarItem];
    });
}

- (void)footerRefreshing
{
    // refresh tableView UI
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if (appDelegate.firstUpdateTime!=nil)
        {
            [self loadMoreMessagesFromFooter];
        }
        else
        {
            [messagesTableView footerEndRefreshing];
        }
    });
}

#pragma mark Auxilaries
- (void)loadMoreMessagesFromFooter
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableArray *subQueries=[[NSMutableArray alloc]init];
        
        // add query constraint of the channel
        for (Channel *channel in appDelegate.myChannelList)
        {
            PFQuery *query=[PFQuery queryWithClassName:@"Message"];
            [query whereKey:@"channelID" equalTo:channel.channelID];
            [subQueries addObject:query];
        }
        
        if (subQueries.count>0)
        {
            PFQuery *query=[PFQuery orQueryWithSubqueries:subQueries];
            [query whereKey:@"updatedAt" lessThan:appDelegate.firstUpdateTime];
            [query whereKey:@"location" nearGeoPoint:appDelegate.currentLocation withinKilometers:MESSAGE_RANGE];
            [query orderByDescending:@"updatedAt"];
            query.limit=MESSAGES_PER_REQUEST;
            
            NSArray *messages=[query findObjects];
            
            for (PFObject *object in messages)
            {
                query=[PFQuery queryWithClassName:@"User"];
                User *sender=[[User alloc]initWithPFObject:[query getObjectWithId:object[@"senderID"]]];
                
                Message *message=[[Message alloc]initWithPFObject:object
                                                           sender:sender
                                                          channel:[appDelegate findChannelFromMyChannelList:object[@"channelID"]]];
                [appDelegate.messageList addObject:message];
            }
            
            if (messages.count>0)
            {
                PFObject *object=[messages lastObject];
                appDelegate.firstUpdateTime=object.updatedAt;
            }
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [messagesTableView reloadData];
            [messagesTableView footerEndRefreshing];
        });
    });
}

@end
