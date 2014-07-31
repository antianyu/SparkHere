//
//  Settings.h
//  IP
//
//  Created by Tianyu An on 14-6-17.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Settings : NSObject

@property (nonatomic) int fontSize;
@property (nonatomic) BOOL receiveMessage;
@property (nonatomic) BOOL autoLogin;
@property (strong, nonatomic) NSString *defaultUsername;
@property (strong, nonatomic) NSString *defaultPassword;

+ (Settings *)sharedInstance;

- (void)saveSettings;

@end
