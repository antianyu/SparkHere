//
//  Settings.h
//  IP
//
//  Created by Tianyu An on 14-6-17.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Settings : NSObject

@property (nonatomic) int fontSize;

@property (nonatomic) BOOL receiveMessage;

@property (nonatomic) BOOL is4Inch;

- (id)init;

- (void)saveSettings;

@end
