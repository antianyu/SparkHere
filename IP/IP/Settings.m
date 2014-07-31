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
    if(self=[super init])
    {
        [self readSettings];
    }
    
    return self;
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

- (void)readSettings
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    fontSize=[[defaults objectForKey:@"fontSize"] intValue];
    receiveMessage=[[defaults objectForKey:@"receiveMessage"] boolValue];
    autoLogin=[[defaults objectForKey:@"autoLogin"] boolValue];
    defaultUsername=[defaults objectForKey:@"defaultUsername"];
    defaultPassword=[defaults objectForKey:@"defaultPassword"];
}

@end
