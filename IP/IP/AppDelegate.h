//
//  AppDelegate.h
//  IP
//
//  Created by Tianyu An on 14-6-11.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "Settings.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navController;

@property (strong, nonatomic) User *user;

@property (strong, nonatomic) NSMutableArray *myChannelList;

@property (strong, nonatomic) NSDate *lastUpdateTime;

@property (strong, nonatomic) UIImage *backgroundImage;

@property (strong, nonatomic) Settings *settings;

@property (nonatomic) BOOL is4Inch;
@property (nonatomic) BOOL refreshMessageList;
@property (nonatomic) BOOL loadMoreMessages;
@property (nonatomic) BOOL refreshMyChannelList;
@property (nonatomic) BOOL refreshChannelDetail;
@property (nonatomic) BOOL refreshPostsList;

- (void)constructMyChannelList;
- (void)setDefaultViewStyle:(UIView *)view;

@end
