//
//  AppDelegate.h
//  IP
//
//  Created by Tianyu An on 14-6-11.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navController;

@property (strong, nonatomic) User *user;

@property (strong, nonatomic) NSMutableArray *messageList;
@property (strong, nonatomic) NSMutableArray *myChannelList;

@property (nonatomic) BOOL refreshMessageList;
@property (nonatomic) BOOL refreshMyChannelList;
@property (nonatomic) BOOL refreshChannelDetail;
@property (nonatomic) BOOL refreshPostsList;

- (void)constructMessageList;
- (void)constructMyChannelList;
- (void)setDefaultViewStyle:(UIView *)view;

@end
