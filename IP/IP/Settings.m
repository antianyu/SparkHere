//
//  Settings.m
//  IP
//
//  Created by Tianyu An on 14-6-17.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "Settings.h"

@implementation Settings

@synthesize fontSize;
@synthesize receiveMessage;
@synthesize autoLogin;
@synthesize defaultUsername;
@synthesize defaultPassword;

- (id)init
{
    return [Settings sharedInstance];
}

- (id)initSharedInstance
{
    if(self=[super init])
    {
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        fontSize=[[defaults objectForKey:@"fontSize"] intValue];
        receiveMessage=[[defaults objectForKey:@"receiveMessage"] boolValue];
        autoLogin=[[defaults objectForKey:@"autoLogin"] boolValue];
        defaultUsername=[defaults objectForKey:@"defaultUsername"];
        defaultPassword=[defaults objectForKey:@"defaultPassword"];
    }
    
    return self;
}

+ (Settings *)sharedInstance
{
    static Settings *settings;
    static dispatch_once_t token;
    dispatch_once(&token, ^
    {
        settings=[[Settings alloc]initSharedInstance];
    });
    return settings;
}

- (void)saveSettings
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setInteger:fontSize forKey:@"fontSize"];
    [defaults setBool:receiveMessage forKey:@"receiveMessage"];
    [defaults setBool:autoLogin forKey:@"autoLogin"];
    [defaults setObject:defaultUsername forKey:@"defaultUsername"];
    [defaults setObject:defaultPassword forKey:@"defaultPassword"];
}

@end
