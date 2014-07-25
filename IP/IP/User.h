//
//  User.h
//  IP
//
//  Created by Tianyu An on 14-6-16.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface User : NSObject

@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *userPassword;
@property (strong, nonatomic) NSString *nickname;
@property (strong, nonatomic) UIImage *logo;

- (id)init;
- (id)init:(NSString *)userName userPassword:(NSString *)userPassword;
- (id)init:(NSString *)userName userPassword:(NSString *)userPassword nickname:(NSString *)nickName
      logo:(UIImage *)image;
- (id)initWithPFObject:(PFObject *)object;

@end
