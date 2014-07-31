//
//  AppDelegate.m
//  IP
//
//  Created by Tianyu An on 14-6-11.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "AppDelegate.h"
#import "Channel.h"
#import "Message.h"
#import <Parse/Parse.h>
#import "LoginViewController.h"

@implementation AppDelegate

@synthesize navController;
@synthesize user;
@synthesize myChannelList;
@synthesize lastUpdateTime;
@synthesize backgroundImage;
@synthesize settings;

@synthesize is4Inch;
@synthesize refreshMessageList;
@synthesize loadMoreMessages;
@synthesize refreshMyChannelList;
@synthesize refreshChannelDetail;
@synthesize refreshPostsList;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Parse setApplicationId:@"VPfKCfiTgyg2daoUkVCmXLWWrYzUOkUmUEB2aqwk"
                  clientKey:@"YncBrS1TJ486X8cIGAmc8WMFOVyWfzgtyqCfcy1j"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [self initData];
    
    LoginViewController *loginViewController=[[LoginViewController alloc]init];
    self.navController=[[UINavigationController alloc]initWithRootViewController:loginViewController];
    self.window.rootViewController=navController;
    
    [self.window makeKeyAndVisible];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)initData
{
    user=nil;
    myChannelList=[[NSMutableArray alloc]init];
    
    settings=[Settings sharedInstance];
    
    refreshMessageList=true;
    loadMoreMessages=false;
    refreshMyChannelList=true;
    refreshChannelDetail=false;
    refreshPostsList=false;
    
    float width=[UIScreen mainScreen].currentMode.size.width;
    float height=[UIScreen mainScreen].currentMode.size.height;
    if (height/width==1.5)
    {
        is4Inch=false;
        backgroundImage=[UIImage imageNamed:@"Background_3.5.png"];
    }
    else
    {
        is4Inch=true;
        backgroundImage=[UIImage imageNamed:@"Background_4.png"];
    }
    
    [[UITextField appearance] setTintColor:[UIColor whiteColor]];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor whiteColor]];
}

- (void)setDefaultViewStyle:(UIView *)view
{
    if ([view isKindOfClass:[UITextField class]])
    {
        UITextField *textField=(UITextField *)view;
        textField.textColor=[UIColor whiteColor];
    }
    else if ([view isKindOfClass:[UITextView class]])
    {
        UITextView *textView=(UITextView *)view;
        textView.textColor=[UIColor whiteColor];
    }
    
    view.tintColor=[UIColor whiteColor];
    view.backgroundColor=[UIColor clearColor];
    view.layer.borderColor=[[UIColor whiteColor]CGColor];
    view.layer.borderWidth=1.5;
    view.layer.cornerRadius=5;
}

- (void)constructMyChannelList
{
    [myChannelList removeAllObjects];
    
    PFQuery *query=[PFQuery queryWithClassName:@"Subscription"];
    [query whereKey:@"userID" equalTo:user.userID];
    [query orderByDescending:@"updatedAt"];
    NSArray *subscriptions=[query findObjects];
    
    // get channels from subscriptions
    for (PFObject *object in subscriptions)
    {
        PFQuery *channelQuery=[PFQuery queryWithClassName:@"Channel"];
        Channel *channel=[[Channel alloc]initWithPFObject:[channelQuery getObjectWithId:object[@"channelID"]]];
        [myChannelList addObject:channel];
    }
}

@end
