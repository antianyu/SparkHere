//
//  MainViewController.m
//  SparkHere
//
//  Created by Tianyu An on 14-6-11.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <Parse/Parse.h>
#import "MainViewController.h"
#import "MessagesViewController.h"
#import "MyChannelsViewController.h"
#import "DiscoverChannelsViewController.h"
#import "MyProfileViewController.h"
#import "AppDelegate.h"

@interface MainViewController ()

@end

@implementation MainViewController
{
    MessagesViewController *messageViewController;
    MyChannelsViewController *myChannelsViewController;
    DiscoverChannelsViewController *discoverChannelsViewController;
    MyProfileViewController *myProfileViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITabBarItem *msgItem=[[UITabBarItem alloc]init];
    msgItem.title=@"Messages";
    msgItem.image=[[UIImage imageNamed:@"Messages_unselected.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    msgItem.selectedImage=[UIImage imageNamed:@"Messages_selected.png"];
    
    UITabBarItem *myChannelItem=[[UITabBarItem alloc]init];
    [myChannelItem setTitle:@"My Channels"];
    [myChannelItem setImage:[[UIImage imageNamed:@"Channel_unselected.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [myChannelItem setSelectedImage:[UIImage imageNamed:@"Channel_selected.png"]];
    
    UITabBarItem *discoverChannelItem=[[UITabBarItem alloc]init];
    [discoverChannelItem setTitle:@"Discover"];
    [discoverChannelItem setImage:[[UIImage imageNamed:@"Discover_unselected.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [discoverChannelItem setSelectedImage:[UIImage imageNamed:@"Discover_selected.png"]];
    
    UITabBarItem *moreItem=[[UITabBarItem alloc]init];
    [moreItem setTitle:@"My Profile"];
    [moreItem setImage:[[UIImage imageNamed:@"MyProfile_unselected.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [moreItem setSelectedImage:[UIImage imageNamed:@"MyProfile_selected.png"]];
    
    messageViewController=[[MessagesViewController alloc]init];
    messageViewController.tabBarItem=msgItem;
    UINavigationController *messageNavController=[[UINavigationController alloc]initWithRootViewController:messageViewController];
    
    myChannelsViewController=[[MyChannelsViewController alloc]init];
    myChannelsViewController.tabBarItem=myChannelItem;
    UINavigationController *myChannelNavController=[[UINavigationController alloc]initWithRootViewController:myChannelsViewController];
    
    discoverChannelsViewController=[[DiscoverChannelsViewController alloc]init];
    discoverChannelsViewController.tabBarItem=discoverChannelItem;
    UINavigationController *findChannelNavController=[[UINavigationController alloc]initWithRootViewController:discoverChannelsViewController];
    
    myProfileViewController=[[MyProfileViewController alloc]init];
    myProfileViewController.tabBarItem=moreItem;
    UINavigationController *moreNavController=[[UINavigationController alloc]initWithRootViewController:myProfileViewController];
    
    NSMutableArray *items=[[NSMutableArray alloc]init];
    [items addObject:messageNavController];
    [items addObject:myChannelNavController];
    [items addObject:findChannelNavController];
    [items addObject:moreNavController];
    [self setViewControllers:items animated:YES];
    
    self.selectedIndex=0;
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.hidesBottomBarWhenPushed=NO;
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (item.tag==0)
    {
        [[self.tabBar.items objectAtIndex:0] setBadgeValue:nil];
    }
}
@end
