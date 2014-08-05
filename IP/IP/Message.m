//
//  Message.m
//  IP
//
//  Created by Tianyu An on 14-6-16.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "Message.h"

@implementation Message

@synthesize sender;
@synthesize channel;
@synthesize messageID;
@synthesize updateAt;
@synthesize content;
@synthesize image;

- (id)init
{
    if(self=[super init])
    {
        sender=[[User alloc]init];
        channel=[[Channel alloc]init];
        messageID=[[NSString alloc]init];
        content=[[NSString alloc]init];
    }    
    return self;
}

- (id)initWithContent:(NSString *)msgContent image:(UIImage *)contentImage updateAt:(NSDate *)msgUpdateAt messageID:(NSString *)msgID sender:(User *)msgSender channel:(Channel *)msgChannel;
{
    if(self=[super init])
    {
        sender=msgSender;
        channel=msgChannel;
        messageID=msgID;
        content=msgContent;
        image=contentImage;
        updateAt=msgUpdateAt;
    }
    return self;
}

@end
