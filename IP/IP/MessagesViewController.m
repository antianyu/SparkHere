//
//  MessagesViewController.m
//  IP
//
//  Created by Tianyu An on 14-6-11.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "MessagesViewController.h"
#import "MessageDetailViewController.h"
#import "Settings.h"
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
    Settings *settings;
    AppDelegate *appDelegate;
    MBProgressHUD *progressHUD;
}

@synthesize messagesTableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"Messages";
    
    settings=[[Settings alloc]init];
    
    if (settings.is4Inch)
    {
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Background_4.png"]]];
    }
    else
    {
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Background_3.5.png"]]];
    }
    
    NSDictionary *attributes=[NSDictionary dictionaryWithObjectsAndKeys:
                              [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavigationBar.png"] forBarMetrics:UIBarMetricsDefault];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self.messagesTableView setBackgroundColor:[UIColor clearColor]];
    [self.messagesTableView setSeparatorInset:UIEdgeInsetsZero];
//    [self.messagesTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    appDelegate=[[UIApplication sharedApplication]delegate];
    progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    
    [self.messagesTableView addHeaderWithTarget:self action:@selector(headerRefreshing)];
    
//    [self.messagesTableView addFooterWithTarget:self action:@selector(footerRefreshing)];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    settings=[[Settings alloc]init];
    
    if (appDelegate.refreshMessageList||appDelegate.loadMessages)
    {
        [self.messagesTableView headerBeginRefreshing];
        appDelegate.refreshMessageList=false;
        appDelegate.loadMessages=false;
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
    
    [cell setMessage:message fontSize:settings.fontSize];
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
    controller.message=[appDelegate.messageList objectAtIndex:indexPath.row];
    self.hidesBottomBarWhenPushed=YES;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)headerRefreshing
{
    // refresh tableView UI
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if (appDelegate.messageList.count==0)
        {
            if (appDelegate.refreshMyChannelList)
            {
                [appDelegate constructMyChannelList];
                appDelegate.refreshMyChannelList=false;
            }
            [appDelegate constructMessageList];
        }
        else
        {
            [appDelegate loadMoreMessages];
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

@end
