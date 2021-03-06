//
//  Channel.m
//  SparkHere
//
//  Created by Tianyu An on 14-6-16.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "Channel.h"

@implementation Channel

@synthesize channelID;
@synthesize channelName;
@synthesize description;
@synthesize logo;
@synthesize followersNumber;
@synthesize defaultPrivilege;
@synthesize category;

- (id)init
{
    if(self=[super init])
    {
        channelID=[[NSString alloc]init];
        channelName=[[NSString alloc]init];
        description=[[NSString alloc]init];
        followersNumber=0;
        defaultPrivilege=0;
        category=0;
        logo=nil;
    }
    return self;
}

- (id)initWithPFObject:(PFObject *)object
{
    if(self=[super init])
    {
        channelID=object.objectId;
        channelName=object[@"channelName"];
        description=object[@"description"];
        followersNumber=[object[@"followersNumber"] intValue];
        defaultPrivilege=[object[@"defaultPrivilege"] intValue];
        category=[object[@"category"] intValue];
        
        // construct file of image and attach it to PFObject
        PFFile *imageFile=object[@"logo"];
        logo=[UIImage imageWithData:[imageFile getData]];
    }
    return self;
}

@end
