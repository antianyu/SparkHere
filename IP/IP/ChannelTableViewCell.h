//
//  ChannelTableViewCell.h
//  IP
//
//  Created by Tianyu An on 14-7-26.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Channel.h"

@interface ChannelTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *logoImageView;
@property (strong, nonatomic) IBOutlet UILabel *channelNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *followersLabel;

- (void)setChannel:(Channel *)channel fontSize:(int)fontSize;

@end
