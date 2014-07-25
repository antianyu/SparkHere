//
//  Message.h
//  IP
//
//  Created by Tianyu An on 14-6-16.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Channel.h"


@interface Message : NSObject

@property (strong, nonatomic) User *sender;
@property (strong, nonatomic) Channel *channel;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *messageID;

- (id)init;
- (id)initWithContent:(NSString *)content messageID:(NSString *)msgID sender:(User *)msgSender channel:(Channel *)msgChannel image:(UIImage *)image;

@end
