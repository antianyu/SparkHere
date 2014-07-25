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

@synthesize is4Inch;

- (id)init
{
    if(self=[super init])
    {
        NSFileManager *fileManager=[NSFileManager defaultManager];
        NSArray *paths=NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *settingsFilePath=[[paths objectAtIndex:0] stringByAppendingPathComponent:@"AppSettings.plist"];
        
        if(![fileManager fileExistsAtPath:settingsFilePath])
        {
            NSString *resourceFolderPath=[[NSBundle mainBundle]pathForResource:@"AppSettings" ofType:@"plist"];
            NSData *mainBundleFile=[NSData dataWithContentsOfFile:resourceFolderPath];
            [fileManager createFileAtPath:settingsFilePath contents:mainBundleFile attributes:nil];
        }
        
        NSMutableDictionary *dict=[[NSMutableDictionary alloc]initWithContentsOfFile:settingsFilePath];
        fontSize=[[dict objectForKey:@"fontSize"]intValue];
        receiveMessage=[[dict objectForKey:@"receiveMessage"]boolValue];
        
        float width=[UIScreen mainScreen].currentMode.size.width;
        float height=[UIScreen mainScreen].currentMode.size.height;
        if (height/width==1.5)
        {
            is4Inch=false;
        }
        else
        {
            is4Inch=true;
        }
    }
    
    return self;
}

- (void)saveSettings
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *settingsFilePath=[[paths objectAtIndex:0] stringByAppendingPathComponent:@"AppSettings.plist"];
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setValue:[NSNumber numberWithInt:fontSize] forKey:@"fontSize"];
    [dict setValue:[NSNumber numberWithBool:receiveMessage] forKey:@"receiveMessage"];
    [dict writeToFile:settingsFilePath atomically:NO];
}

@end
