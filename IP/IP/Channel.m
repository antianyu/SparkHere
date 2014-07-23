//
//  Channel.m
//  IP
//
//  Created by Tianyu An on 14-6-16.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "Channel.h"

@implementation Channel

@synthesize channelName;
@synthesize description;
@synthesize channelID;
@synthesize location;
@synthesize range;
@synthesize followersNumber;
@synthesize defaultPrivilege;
@synthesize category;

-(id)init
{
    if(self=[super init])
    {
        channelName=[[NSString alloc]init];
        description=[[NSString alloc]init];
        channelID=[[NSString alloc]init];
        location=[[PFGeoPoint alloc]init];
        range=0;
        followersNumber=0;
        defaultPrivilege=0;
        category=0;
    }
    return self;
}

-(id)initWithPFObject:(PFObject *)object
{
    if(self=[super init])
    {
        channelName=object[@"channelName"];
        description=object[@"description"];
        channelID=object.objectId;
        location=object[@"location"];
        range=[object[@"range"] doubleValue];
        followersNumber=[object[@"followersNumber"] intValue];
        defaultPrivilege=[object[@"defaultPrivilege"] intValue];
        category=[object[@"category"] intValue];
    }
    return self;
}

@end
