//
//  MessageTableViewCell.m
//  IP
//
//  Created by Tianyu An on 14-7-2.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "MessageTableViewCell.h"

@implementation MessageTableViewCell

@synthesize senderLabel;
@synthesize contentLabel;
@synthesize channelLabel;

- (void)awakeFromNib
{
//    [self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"MessageCell.png"]]];
    [self setBackgroundColor:[UIColor clearColor]];
    [senderLabel setTextColor:[UIColor lightGrayColor]];
    [contentLabel setTextColor:[UIColor whiteColor]];
    [channelLabel setTextColor:[UIColor grayColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setFontSize:(int)fontSize
{
    senderLabel.font=[UIFont systemFontOfSize:fontSize-6];
    contentLabel.font=[UIFont systemFontOfSize:fontSize];
    channelLabel.font=[UIFont systemFontOfSize:fontSize-6];
}

@end
