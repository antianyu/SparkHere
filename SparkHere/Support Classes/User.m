//
//  User.m
//  SparkHere
//
//  Created by Tianyu An on 14-6-16.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "User.h"

@implementation User

@synthesize userID;
@synthesize username;
@synthesize userPassword;
@synthesize nickname;
@synthesize logo;

- (id)init
{
    if(self=[super init])
    {
        username=[[NSString alloc]init];
        userPassword=[[NSString alloc]init];
        nickname=[[NSString alloc]init];
        userID=[[NSString alloc]init];
        logo=nil;
    }
    return self;
}

- (id)init:(NSString *)name userPassword:(NSString *)password
{
    if(self=[super init])
    {
        username=name;
        userPassword=password;
        nickname=[[NSString alloc]init];
        userID=[[NSString alloc]init];
        logo=nil;
    }
    return self;
}

- (id)init:(NSString *)name userPassword:(NSString *)password nickname:(NSString *)nickName userID:(NSString *)userId logo:(UIImage *)image
{
    if(self=[super init])
    {
        userID=userId;
        username=name;
        userPassword=password;
        nickname=nickName;
        logo=image;
    }
    return self;
}

- (id)initWithPFObject:(PFObject *)object
{
    if(self=[super init])
    {
        username=object[@"username"];
        userPassword=object[@"password"];
        nickname=object[@"nickname"];
        userID=object.objectId;
        PFFile *imageFile=object[@"logo"];
        logo=[UIImage imageWithData:[imageFile getData]];
    }
    return self;
}

- (void)setWithPFObject:(PFObject *)object
{
    username=object[@"username"];
    userPassword=object[@"password"];
    nickname=object[@"nickname"];
    userID=object.objectId;
    PFFile *imageFile=object[@"logo"];
    logo=[UIImage imageWithData:[imageFile getData]];
}

- (PFObject *)getPFObject
{
    PFObject *object=[PFObject objectWithClassName:@"User"];
    object.objectId=userID;
    object[@"username"]=username;
    object[@"password"]=userPassword;
    object[@"nickname"]=nickname;
    
    NSData *logoData=UIImageJPEGRepresentation(logo, 1);
    PFFile *logoFile=[PFFile fileWithName:@"logo.jpg" data:logoData];
    object[@"logo"]=logoFile;
    
    return object;
}

@end
