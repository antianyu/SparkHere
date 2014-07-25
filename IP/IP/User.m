//
//  User.m
//  IP
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

- (id)init:(NSString *)name userPassword:(NSString *)password nickname:(NSString *)nickName logo:(UIImage *)image
{
    if(self=[super init])
    {
        userID=[[NSString alloc]init];
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

@end
