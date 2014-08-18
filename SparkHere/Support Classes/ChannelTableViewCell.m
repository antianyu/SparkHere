//
//  ChannelTableViewCell.m
//  SparkHere
//
//  Created by Tianyu An on 14-7-26.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "ChannelTableViewCell.h"
#import "AppDelegate.h"

@implementation ChannelTableViewCell
{
    AppDelegate *appDelegate;
}

@synthesize channelNameLabel;
@synthesize followersLabel;
@synthesize logoImageView;

- (void)awakeFromNib
{
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self setBackgroundColor:[UIColor clearColor]];
    [channelNameLabel setTextColor:appDelegate.majorColor];
    [followersLabel setTextColor:appDelegate.detailColor];
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
