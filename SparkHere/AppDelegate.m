//
//  AppDelegate.m
//  SparkHere
//
//  Created by Tianyu An on 14-8-5.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "WelcomeViewController.h"
#import "AutoLoginViewController.h"
#import "MJRefresh.h"
#import "Constants.h"
#import "Message.h"

@implementation AppDelegate
{
    CLLocationManager *locationManager;
}

@synthesize navController;
@synthesize user;
@synthesize messageList;
@synthesize myChannelList;
@synthesize lastUpdateTime;
@synthesize firstUpdateTime;
@synthesize backgroundImage;
@synthesize settings;
@synthesize currentLocation;
@synthesize majorColor;
@synthesize detailColor;
@synthesize descriptionColor;
@synthesize buttonColor;

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
    [self initView];
    
    if (settings.receiveMessage && !settings.registeredForNotification)
    {
        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
                                                        UIRemoteNotificationTypeAlert|
                                                        UIRemoteNotificationTypeSound];
    }
    
    [self updateLocationWithInterval];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    WelcomeViewController *welcomeViewController=[[WelcomeViewController alloc]init];
    self.navController=[[UINavigationController alloc]initWithRootViewController:welcomeViewController];
    if (settings.autoLogin)
    {
        AutoLoginViewController *autoLoginViewController=[[AutoLoginViewController alloc]init];
        self.window.rootViewController=autoLoginViewController;
    }
    else
    {
        self.window.rootViewController=navController;
    }
    
    [self.window makeKeyAndVisible];
    
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

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    PFInstallation *currentInstallation=[PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels=@[@"global"];
    currentInstallation[@"receiveMessage"]=[NSNumber numberWithBool:YES];
    [currentInstallation saveInBackground];
    
    settings.registeredForNotification=YES;
    settings.deviceToken=deviceToken;
    [settings saveSettings];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    PFInstallation *currentInstallation=[PFInstallation currentInstallation];
    application.applicationIconBadgeNumber=currentInstallation.badge;
    [PFPush handlePush:userInfo];
}

- (void)initData
{
    settings=[Settings sharedInstance];
    
    if (settings.autoLogin)
    {
        user=[[User alloc]init:settings.defaultUsername
                  userPassword:settings.defaultPassword
                      nickname:settings.defaultNickname
                        userID:settings.defaultID
                          logo:settings.defaultLogo];
        
        PFInstallation *currentInstallation=[PFInstallation currentInstallation];
        [currentInstallation setObject:user.userID forKey:@"currentUserID"];
        [currentInstallation saveInBackground];
    }
    messageList=[[NSMutableArray alloc]init];
    myChannelList=[[NSMutableArray alloc]init];
    
    refreshMessageList=NO;
    loadMoreMessages=NO;
    refreshMyChannelList=NO;
    refreshChannelDetail=NO;
    refreshPostsList=YES;
    
    float width=[UIScreen mainScreen].currentMode.size.width;
    float height=[UIScreen mainScreen].currentMode.size.height;
    if (height/width==1.5)
    {
        is4Inch=NO;
        backgroundImage=[UIImage imageNamed:@"Background_3.5.png"];
    }
    else
    {
        is4Inch=YES;
        backgroundImage=[UIImage imageNamed:@"Background_4.png"];
    }
}

- (void)initView
{
    majorColor=[UIColor colorWithRed:0/255.0 green:117/255.0 blue:169/255.0 alpha:1];
    detailColor=[UIColor darkGrayColor];
    descriptionColor=[UIColor colorWithRed:43/255.0 green:43/255.0 blue:43/255.0 alpha:1];
    buttonColor=[UIColor colorWithRed:146/255.0 green:208/255.0 blue:80/255.0 alpha:1];
    
    // Status Bar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // Navigation Bar
    NSDictionary *attributes=[NSDictionary dictionaryWithObjectsAndKeys:
                              [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    [[UINavigationBar appearance] setTitleTextAttributes:attributes];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"NavigationBar.png"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    // Tab Bar
    UIColor *colorSelected=[UIColor colorWithRed:228/255.0 green:0/255.0 blue:127/255.0 alpha:1];
    UIColor *colorUnselected=[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:colorUnselected, NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:colorSelected, NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    
    [[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:@"TabBar.png"]];
    [[UITabBar appearance] setSelectedImageTintColor:colorSelected];
    
    // Tool Bar
    [[UIToolbar appearance] setBackgroundImage:[UIImage imageNamed:@"Toolbar.png"]
                            forToolbarPosition:UIBarPositionAny
                                    barMetrics:UIBarMetricsDefault];
    [[UIToolbar appearance] setTintColor:[UIColor whiteColor]];
    
    // Search Bar
    [[UISearchBar appearance] setTintColor:majorColor];
    
    // UITextField
    [[UITextField appearance] setTextColor:majorColor];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:majorColor];
    
    // UITextView
    [[UITextView appearance] setTextColor:majorColor];
}

- (void)setTextFieldStyle:(UITextField *)textField
{
    textField.tintColor=detailColor;
    textField.textColor=detailColor;
    textField.backgroundColor=[UIColor clearColor];
    textField.borderStyle=UITextBorderStyleNone;
}

- (void)setTextViewStyle:(UITextView *)textView
{
    textView.tintColor=detailColor;
    textView.textColor=detailColor;
    textView.backgroundColor=[UIColor clearColor];
}

- (void)setButtonStyle:(UIButton *)button color:(UIColor *)color
{
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.backgroundColor=color;
    button.layer.borderColor=color.CGColor;
    button.layer.borderWidth=1.5;
}

- (void)setImageViewStyle:(UIImageView *)imageView container:(UIView *)container borderWidth:(float)borderWidth shadowOffset:(float)offset
{
    float radius=imageView.frame.size.height/2;
    
    CALayer *layer=imageView.layer;
    layer.masksToBounds=YES;
    layer.cornerRadius=radius;
    layer.borderColor=[UIColor whiteColor].CGColor;
    layer.borderWidth=borderWidth;
    
    container.backgroundColor=[UIColor clearColor];
    CALayer *containerLayer=container.layer;
    containerLayer.shadowColor=[UIColor darkGrayColor].CGColor;
    containerLayer.shadowOpacity=0.8;
    containerLayer.shadowOffset=CGSizeMake(offset, offset);
    containerLayer.shadowRadius=3;
    containerLayer.shadowPath=[UIBezierPath bezierPathWithRoundedRect:imageView.bounds cornerRadius:radius].CGPath;
}

- (void)setCurrentUser:(PFObject *)object
{
    if (user==nil)
    {
        user=[[User alloc]initWithPFObject:object];
    }
    else
    {
        [user setWithPFObject:object];
    }
    
    if (settings.autoLogin)
    {
        [settings saveDefaultUser:user];
    }
}

- (void)constructListsFromMessageVC:(BOOL)fromMessageVC tableView:(UITableView *)tableView tabBarItem:(UITabBarItem *)tabBarItem
{
    BOOL tempRefreshMessageList=refreshMessageList;
    BOOL tempLoadMoreMessages=loadMoreMessages;
    BOOL tempRefreshMyChannelList=refreshMyChannelList;
    refreshMessageList=NO;
    loadMoreMessages=NO;
    refreshMyChannelList=NO;
    
    if (tempRefreshMessageList || tempLoadMoreMessages)
    {
        [self getLocation];
    }
    
    if (tempRefreshMessageList && tempLoadMoreMessages)
    {
        tempLoadMoreMessages=NO;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if (tempRefreshMyChannelList)
        {
            [myChannelList removeAllObjects];
            
            PFQuery *query=[PFQuery queryWithClassName:@"Subscription"];
            [query whereKey:@"userID" equalTo:user.userID];
            [query orderByDescending:@"updatedAt"];
            query.limit=ITEMS_PER_REQUEST;
            NSArray *subscriptions=[query findObjects];
            
            // get channels from subscriptions
            for (PFObject *object in subscriptions)
            {
                PFQuery *channelQuery=[PFQuery queryWithClassName:@"Channel"];
                Channel *channel=[[Channel alloc]initWithPFObject:[channelQuery getObjectWithId:object[@"channelID"]]];
                [myChannelList addObject:channel];
            }
            NSLog(@"%lu objects in channel list", (unsigned long)myChannelList.count);
        }
        
        if (!tempRefreshMessageList && !tempLoadMoreMessages)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [tableView reloadData];
                
                if (fromMessageVC)
                {
                    [tableView headerEndRefreshing];
                }
            });
            return;
        }
        
        int count=0;
        while (currentLocation==nil && count<30)
        {
            [NSThread sleepForTimeInterval:1];
            count++;
        }
        if (count==REQUEST_TIMEOUT)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [tableView reloadData];
                
                if (fromMessageVC)
                {
                    [tableView headerEndRefreshing];
                }
            });
            return;
        }
        
        if (tempRefreshMessageList)
        {
            [messageList removeAllObjects];
            
            NSMutableArray *subQueries=[[NSMutableArray alloc]init];
            
            // if the user is in the range of channel, add query constraint of the channel
            for (Channel *channel in myChannelList)
            {
                PFQuery *query=[PFQuery queryWithClassName:@"Message"];
                [query whereKey:@"channelID" equalTo:channel.channelID];
                [subQueries addObject:query];
            }
            
            if (subQueries.count>0)
            {
                PFQuery *query=[PFQuery orQueryWithSubqueries:subQueries];
                [query whereKey:@"location" nearGeoPoint:currentLocation withinKilometers:MESSAGE_RANGE];
                [query orderByDescending:@"updatedAt"];
                query.limit=MESSAGES_PER_REQUEST;
                
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
                
                if (messages.count>0)
                {                    
                    PFObject *object=[messages lastObject];
                    firstUpdateTime=object.updatedAt;
                    lastUpdateTime=[NSDate date];
                }
            }
            NSLog(@"%lu objects in message list", (unsigned long)messageList.count);
        }
        
        else if (tempLoadMoreMessages)
        {
            NSMutableArray *subQueries=[[NSMutableArray alloc]init];
            
            // if the user is in the range of channel, add query constraint of the channel
            for (Channel *channel in myChannelList)
            {
                PFQuery *query=[PFQuery queryWithClassName:@"Message"];
                [query whereKey:@"channelID" equalTo:channel.channelID];
                [subQueries addObject:query];
            }
            
            if (subQueries.count>0)
            {
                PFQuery *query=[PFQuery orQueryWithSubqueries:subQueries];
                if (lastUpdateTime!=nil)
                {
                    [query whereKey:@"updatedAt" greaterThan:lastUpdateTime];
                }
                [query whereKey:@"location" nearGeoPoint:currentLocation withinKilometers:MESSAGE_RANGE];
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
                lastUpdateTime=[NSDate date];
            }
            NSLog(@"%lu objects in load list", (unsigned long)messageList.count);
        }
        
        // remove badge
        PFInstallation *currentInstallation=[PFInstallation currentInstallation];
        currentInstallation.badge=0;
        [currentInstallation saveInBackground];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [tableView reloadData];
            
            if (fromMessageVC)
            {
                tabBarItem.badgeValue=nil;
                [tableView headerEndRefreshing];
            }
        });
    });
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

- (void)showUIAlertViewWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate
{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:title
                                                 message:message
                                                delegate:delegate
                                       cancelButtonTitle:@"Confirm"
                                       otherButtonTitles:nil];
    [alert show];
}

- (void)getLocation
{
    if ([CLLocationManager locationServicesEnabled])
    {
        if (locationManager==nil)
        {
            locationManager=[[CLLocationManager alloc]init];
            locationManager.delegate=self;
            locationManager.desiredAccuracy=kCLLocationAccuracyNearestTenMeters;
            locationManager.distanceFilter=200;
        }
        currentLocation=nil;
        [locationManager startUpdatingLocation];
    }
    else
    {
        [self showUIAlertViewWithTitle:@"Error!" message:@"Location service is not available. Please turn it on." delegate:nil];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{    
    [self showUIAlertViewWithTitle:@"Error!" message:@"Location failed. Please try again." delegate:nil];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    currentLocation=[PFGeoPoint geoPointWithLocation:[locations lastObject]];
    [locationManager stopUpdatingLocation];
    
    PFInstallation *currentInstallation=[PFInstallation currentInstallation];
    [currentInstallation setObject:currentLocation forKey:@"currentLocation"];
    [currentInstallation saveInBackground];
}

- (void)updateLocationWithInterval
{
    NSTimer *timer=[NSTimer timerWithTimeInterval:LOCATION_UPDATE_INTERVAL
                                           target:self
                                         selector:@selector(getLocation)
                                         userInfo:nil
                                          repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

@end
