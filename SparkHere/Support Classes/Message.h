//
//  Message.h
//  SparkHere
//
//  Created by Tianyu An on 14-6-16.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Channel.h"

@interface Message : NSObject

@property (strong, nonatomic) NSString *messageID;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSDate *updatedAt;
@property (strong, nonatomic) NSString *area;
@property (strong, nonatomic) PFGeoPoint *location;
@property (strong, nonatomic) User *sender;
@property (strong, nonatomic) Channel *channel;

- (id)init;
- (id)initWithPFObject:(PFObject *)object sender:(User *)msgSender channel:(Channel *)msgChannel;

@end
