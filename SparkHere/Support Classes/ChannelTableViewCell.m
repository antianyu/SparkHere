//
//  ChannelTableViewCell.m
//  SparkHere
//
//  Created by Tianyu An on 14-7-26.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "ChannelTableViewCell.h"

@implementation ChannelTableViewCell

@synthesize channelNameLabel;
@synthesize followersLabel;
@synthesize logoImageView;

- (void)awakeFromNib
{
    [self setBackgroundColor:[UIColor clearColor]];
    [channelNameLabel setTextColor:[UIColor whiteColor]];
    [followersLabel setTextColor:[UIColor lightGrayColor]];
}

- (void)setChannel:(Channel *)channel fontSize:(int)fontSize
{
    channelNameLabel.font=[UIFont systemFontOfSize:fontSize];
    channelNameLabel.text=channel.channelName;
    
    followersLabel.font=[UIFont systemFontOfSize:fontSize-6];
    followersLabel.text=[NSString stringWithFormat:@"Followers: %d", channel.followersNumber];
    
    if (channel.logo!=nil)
    {
        logoImageView.image=channel.logo;
    }
    else
    {
        logoImageView.image=[UIImage imageNamed:@"Default_Logo.png"];
    }
}

@end
