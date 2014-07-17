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
#import "MessageTableViewCell.h"
#import "User.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "PassBoolDelegate.h"
#import <Parse/Parse.h>

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    settings=[[Settings alloc]init];
    
    if (appDelegate.refreshMessageList)
    {
        [self showRefreshMessageListWaitingView];
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
    
    MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:messageCellIdentifier];
    if (cell==nil)
    {
        cell=[[[NSBundle mainBundle]loadNibNamed:@"MessageTableViewCell" owner:nil options:nil]lastObject];
    }
    
    [cell setFontSize:settings.fontSize];
    NSInteger row = [indexPath row];
    Message *message=[appDelegate.messageList objectAtIndex:row];
    cell.senderLabel.text = message.sender.nickname;
    cell.contentLabel.text = message.content;
    cell.channelLabel.text = message.channel.channelName;
    
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

- (void)showRefreshMessageListWaitingView
{
    [[UIApplication sharedApplication].keyWindow addSubview:progressHUD];
    progressHUD.dimBackground = YES;
    progressHUD.labelText = @"Loading...";
    [progressHUD showAnimated:YES whileExecutingBlock:^
     {
         if (appDelegate.refreshMyChannelList)
         {
             [appDelegate constructMyChannelList];
             appDelegate.refreshMyChannelList=false;
         }
         [appDelegate constructMessageList];
         appDelegate.refreshMessageList=false;
     }
    completionBlock:^
     {
         [progressHUD removeFromSuperview];
         self.tabBarItem.badgeValue=[NSString stringWithFormat:@"%d", appDelegate.messageList.count];
         [self.messagesTableView reloadData];
     }];
}

@end
