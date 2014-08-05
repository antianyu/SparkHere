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
#import "Constants.h"
#import "User.h"
#import "Message.h"
#import "PassBoolDelegate.h"

@implementation CLLocationManager (TemporaryHack)

- (void)hackLocationFix
{
    CLLocation *location=[[CLLocation alloc]initWithLatitude:51.47435 longitude:-0.184062];
    [[self delegate] locationManager:self didUpdateLocations:[NSArray arrayWithObject:location]];
}

- (void)startUpdatingLocation
{
    [self performSelector:@selector(hackLocationFix) withObject:nil afterDelay:0.1];
}

@end


@interface MessagesViewController ()

@end

@implementation MessagesViewController
{
    AppDelegate *appDelegate;
    MBProgressHUD *progressHUD;
    NSMutableArray *messageList;
    CLLocationManager *locationManager;
    BOOL initMessageList;
}

@synthesize messagesTableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"Messages";
    
    appDelegate=[[UIApplication sharedApplication] delegate];
    progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:appDelegate.backgroundImage]];
    
    [self.messagesTableView setBackgroundColor:[UIColor clearColor]];
    [self.messagesTableView setSeparatorInset:UIEdgeInsetsZero];
    [self.messagesTableView addHeaderWithTarget:self action:@selector(headerRefreshing)];
    
    messageList=[[NSMutableArray alloc]init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (appDelegate.refreshMessageList||appDelegate.loadMoreMessages)
    {
        [self.messagesTableView headerBeginRefreshing];
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
    controller.message=[messageList objectAtIndex:indexPath.row];
    self.hidesBottomBarWhenPushed=YES;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)headerRefreshing
{
    // refresh tableView UI
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if (appDelegate.refreshMessageList)
        {
            if (appDelegate.refreshMyChannelList)
            {
                [appDelegate constructMyChannelList];
                appDelegate.refreshMyChannelList=false;
            }
            [self constructMessageListWithInit:true];
            appDelegate.refreshMessageList=false;
        }
        else
        {
            [self constructMessageListWithInit:false];
            appDelegate.loadMoreMessages=false;
        }
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

- (void)constructMessageListWithInit:(BOOL)initialisation
{
    initMessageList=initialisation;
    if ([CLLocationManager locationServicesEnabled])
    {
        if (locationManager==nil)
        {
            locationManager=[[CLLocationManager alloc]init];
            locationManager.delegate=self;
            locationManager.desiredAccuracy=kCLLocationAccuracyNearestTenMeters;
        }
        [locationManager startUpdatingLocation];
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                     message:@"Location service is not available. Please turn it on."
                                                    delegate:self
                                           cancelButtonTitle:@"Confirm"
                                           otherButtonTitles:nil];
        [alert show];
        return;
    }
}

- (void)constructMessageListWithLocation:(PFGeoPoint *)currentLocation
{
    if (initMessageList)
    {
        [messageList removeAllObjects];
        
        NSMutableArray *subQueries=[[NSMutableArray alloc]init];
        
        // if the user is in the range of channel, add query constraint of the channel
        for (Channel *channel in appDelegate.myChannelList)
        {
            PFQuery *query=[PFQuery queryWithClassName:@"Message"];
            [query whereKey:@"channelID" equalTo:channel.channelID];
            [subQueries addObject:query];
        }
        
        if (subQueries.count>0)
        {
            PFQuery *query=[PFQuery orQueryWithSubqueries:subQueries];
            [query whereKey:@"location" nearGeoPoint:currentLocation withinKilometers:messageRange];
            [query orderByDescending:@"updatedAt"];
            query.limit=20;
            NSArray *messages=[query findObjects];
            
            for (PFObject *object in messages)
            {
                query=[PFQuery queryWithClassName:@"User"];
                User *sender=[[User alloc]initWithPFObject:[query getObjectWithId:object[@"senderID"]]];
                
                Message *message=[[Message alloc]initWithPFObject:object
                                                          sender:sender
                                                         channel:[self findChannelFromMyChannelList:object[@"channelID"]]];
                [messageList addObject:message];
            }
        }
    }
    else
    {
        NSMutableArray *subQueries=[[NSMutableArray alloc]init];
        
        // if the user is in the range of channel, add query constraint of the channel
        for (Channel *channel in appDelegate.myChannelList)
        {
            PFQuery *query=[PFQuery queryWithClassName:@"Message"];
            [query whereKey:@"channelID" equalTo:channel.channelID];
            [subQueries addObject:query];
        }   
        
        if (subQueries.count>0)
        {
            PFQuery *query=[PFQuery orQueryWithSubqueries:subQueries];
            [query whereKey:@"updatedAt" greaterThan:appDelegate.lastUpdateTime];
            [query whereKey:@"location" nearGeoPoint:currentLocation withinKilometers:messageRange];
            [query orderByAscending:@"updatedAt"];
            
            NSArray *messages=[query findObjects];
            
            for (PFObject *object in messages)
            {
                query=[PFQuery queryWithClassName:@"User"];
                User *sender=[[User alloc]initWithPFObject:[query getObjectWithId:object[@"senderID"]]];
                
                Message *message=[[Message alloc]initWithPFObject:object
                                                           sender:sender
                                                          channel:[self findChannelFromMyChannelList:object[@"channelID"]]];
                [messageList insertObject:message atIndex:0];
            }
        }
    }
    appDelegate.lastUpdateTime=[NSDate date];
    
    [self.messagesTableView reloadData];
    
    [self.messagesTableView headerEndRefreshing];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                 message:@"Location failed. Please try again."
                                                delegate:self
                                       cancelButtonTitle:@"Confirm"
                                       otherButtonTitles:nil];
    [alert show];
    
    [self.messagesTableView headerEndRefreshing];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self constructMessageListWithLocation:[PFGeoPoint geoPointWithLocation:[locations lastObject]]];
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
