//
//  MainViewController.m
//  IP
//
//  Created by Tianyu An on 14-6-11.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "MainViewController.h"
#import "MessagesViewController.h"
#import "MyChannelsViewController.h"
#import "DiscoverChannelsViewController.h"
#import "MyProfileViewController.h"
#import "User.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>

@interface MainViewController ()

@end

@implementation MainViewController
{
    MessagesViewController *messageViewController;
    MyChannelsViewController *myChannelsViewController;
    DiscoverChannelsViewController *discoverChannelsViewController;
    MyProfileViewController *myProfileViewController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        UIColor *colorSelected=[UIColor colorWithRed:228/255.0 green:0/255.0 blue:127/255.0 alpha:1];
        UIColor *colorUnselected=[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
        
        [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:colorUnselected, NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
        [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:colorSelected, NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
        
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
        
        [self.tabBar setBackgroundImage:[UIImage imageNamed:@"TabBar.png"]];
        [self.tabBar setSelectedImageTintColor:colorSelected];
        self.selectedIndex=0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    PFQuery *query=[PFQuery queryWithClassName:@"User"];
    [query whereKey:@"username" equalTo:appDelegate.user.username];
    PFObject *object=[query getFirstObject];
    appDelegate.user=[[User alloc]initWithPFObject:object];
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
