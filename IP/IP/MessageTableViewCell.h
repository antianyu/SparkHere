//
//  MessageTableViewCell.h
//  IP
//
//  Created by Tianyu An on 14-7-2.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"

@interface MessageTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *senderLabel;
@property (strong, nonatomic) IBOutlet UILabel *channelLabel;
@property (strong, nonatomic) IBOutlet UIImageView *senderLogoImageView;
@property (strong, nonatomic) IBOutlet UIImageView *channelLogoImageView;

- (void)setMessage:(Message *)message fontSize:(int)fontSize;
@end
