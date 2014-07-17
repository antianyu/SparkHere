//
//  User.m
//  IP
//
//  Created by Tianyu An on 14-6-16.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "User.h"

@implementation User

@synthesize username;
@synthesize userPassword;
@synthesize nickname;
@synthesize userID;
@synthesize logoURL;

-(id)init
{
    if(self=[super init])
    {
        username=[[NSString alloc]init];
        userPassword=[[NSString alloc]init];
        userID=[[NSString alloc]init];
    }
    return self;
}

-(id)init:(NSString *)name userPassword:(NSString *)password;
{
    if(self=[super init])
    {
        username=name;
        userPassword=password;
    }
    return self;
}

-(id)init:(NSString *)name userPassword:(NSString *)password nickname:(NSString *)nickName;
{
    if(self=[super init])
    {
        username=name;
        userPassword=password;
        nickname=nickName;
    }
    return self;
}

-(id)init:(NSString *)name userPassword:(NSString *)password nickname:(NSString *)nickName userID:(NSString *)userid;
{
    if(self=[super init])
    {
        username=name;
        userPassword=password;
        nickname=nickName;
        userID=userid;
    }
    return self;
}

-(id)init:(NSString *)name userPassword:(NSString *)password nickname:(NSString *)nickName userID:(NSString *)userid logoURL:(NSString *)url;
{
    if(self=[super init])
    {        
        username=name;
        userPassword=password;
        nickname=nickName;
        userID=userid;
        logoURL=url;
    }
    return self;
}

-(id)initWithPFObject:(PFObject *)object
{
    if(self=[super init])
    {
        username=object[@"username"];
        userPassword=object[@"password"];
        nickname=object[@"nickname"];
        userID=object.objectId;
        logoURL=object[@"logoURL"];
    }
    return self;
}

@end
