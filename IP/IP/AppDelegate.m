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
@synthesize messageList;
@synthesize myChannelList;
@synthesize refreshMessageList;
@synthesize refreshMyChannelList;
@synthesize refreshChannelDetail;
@synthesize refreshPostsList;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Parse setApplicationId:@"VPfKCfiTgyg2daoUkVCmXLWWrYzUOkUmUEB2aqwk"
                  clientKey:@"YncBrS1TJ486X8cIGAmc8WMFOVyWfzgtyqCfcy1j"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    LoginViewController *loginViewController=[[LoginViewController alloc]init];
    self.navController=[[UINavigationController alloc]initWithRootViewController:loginViewController];
    self.window.rootViewController=navController;
    
    [self.window makeKeyAndVisible];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    user=nil;
    messageList=[[NSMutableArray alloc]init];
    myChannelList=[[NSMutableArray alloc]init];
    refreshMessageList=true;
    refreshMyChannelList=true;
    refreshChannelDetail=false;
    refreshPostsList=false;
    
    [[UITextField appearance] setTintColor:[UIColor whiteColor]];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor whiteColor]];
    
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

- (void)constructMessageList
{
    [messageList removeAllObjects];
    PFGeoPoint *currentLocation=[self getCurrentLocation];
    
    NSMutableArray *subQueries=[[NSMutableArray alloc]init];
    
    // if the user is in the range of channel, add query constraint of the channel
    for (Channel *channel in myChannelList)
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
            
            Message *message=[[Message alloc]initWithContent:object[@"content"]
                                                   messageID:object.objectId
                                                      sender:sender
                                                     channel:[self findChannelFromMyChannelList:object[@"channelID"]]];
            [messageList addObject:message];
        }
    }
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

- (PFGeoPoint *)getCurrentLocation
{
    PFGeoPoint *currentLocation=[PFGeoPoint geoPointWithLatitude:4 longitude:4];
    return currentLocation;
}

- (Channel *)findChannelFromMyChannelList:(NSString *)channelID
{
    for (Channel *channel in myChannelList)
    {
        if ([channel.channelID isEqualToString:channelID])
        {
            return channel;
        }
    }
    return nil;
}

@end
