//
//  AppDelegate.h
//  SparkHere
//
//  Created by Tianyu An on 14-8-5.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "User.h"
#import "Channel.h"
#import "Settings.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navController;

@property (strong, nonatomic) User *user;

@property (strong, atomic) NSMutableArray *messageList;

@property (strong, atomic) NSMutableArray *myChannelList;

@property (strong, nonatomic) NSDate *lastUpdateTime;
@property (strong, nonatomic) NSDate *firstUpdateTime;

@property (strong, nonatomic) UIImage *backgroundImage;

@property (strong, nonatomic) Settings *settings;

@property (strong, nonatomic) PFGeoPoint *currentLocation;

@property (strong, nonatomic) UIColor *majorColor;
@property (strong, nonatomic) UIColor *detailColor;
@property (strong, nonatomic) UIColor *descriptionColor;
@property (strong, nonatomic) UIColor *buttonColor;

@property (nonatomic) BOOL is4Inch;
@property (atomic) BOOL refreshMessageList;
@property (atomic) BOOL loadMoreMessages;
@property (atomic) BOOL refreshMyChannelList;
@property (nonatomic) BOOL refreshChannelDetail;
@property (nonatomic) BOOL refreshPostsList;

- (void)setTextFieldStyle:(UITextField *)textField;
- (void)setTextViewStyle:(UITextView *)textView;
- (void)setButtonStyle:(UIButton *)button color:(UIColor *)color;
- (void)setCurrentUser:(PFObject *)object;
- (void)constructListsFromMessageVC:(BOOL)fromMessageVC tableView:(UITableView *)tableView tabBarItem:(UITabBarItem *)tabBarItem;
- (Channel *)findChannelFromMyChannelList:(NSString *)channelID;
- (void)getLocation;
- (void)showUIAlertViewWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate;

@end
