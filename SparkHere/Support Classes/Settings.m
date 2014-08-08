//
//  Settings.m
//  SparkHere
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
@synthesize defaultNickname;
@synthesize defaultID;
@synthesize defaultLogo;

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
        defaultNickname=[defaults objectForKey:@"defaultNickname"];
        defaultID=[defaults objectForKey:@"defaultID"];
        defaultLogo=[UIImage imageWithData:[defaults objectForKey:@"defaultLogo"]];
        
        if (fontSize==0)
        {
            fontSize=18;
            receiveMessage=true;
        }
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
}

- (void)saveDefaultUser:(User *)user
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:user.username forKey:@"defaultUsername"];
    [defaults setObject:user.userPassword forKey:@"defaultPassword"];
    [defaults setObject:user.nickname forKey:@"defaultNickname"];
    [defaults setObject:user.userID forKey:@"defaultID"];
    [defaults setObject:UIImagePNGRepresentation(user.logo) forKey:@"defaultLogo"];
}

@end
