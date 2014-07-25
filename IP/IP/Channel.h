//
//  Channel.h
//  IP
//
//  Created by Tianyu An on 14-6-16.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Channel : NSObject

@property (strong, nonatomic) NSString *channelID;
@property (strong, nonatomic) NSString *channelName;
@property (strong, nonatomic) NSString *description;
@property (strong, nonatomic) UIImage *logo;
@property (strong, nonatomic) PFGeoPoint *location;
@property (nonatomic) double range;
@property (nonatomic) int followersNumber;
@property (nonatomic) int defaultPrivilege;
@property (nonatomic) int category;

- (id)init;
- (id)initWithPFObject:(PFObject *)object;

@end
