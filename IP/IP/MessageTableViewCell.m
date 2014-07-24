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

- (void)setFontSize:(int)fontSize
{
    senderLabel.font=[UIFont systemFontOfSize:fontSize-6];
    contentLabel.font=[UIFont systemFontOfSize:fontSize];
    channelLabel.font=[UIFont systemFontOfSize:fontSize-6];
}

- (void)setContent:(NSString *)content
{
    contentLabel.text=content;
    
    CGSize constraint=CGSizeMake(280, 1000);
    NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:contentLabel.font, NSFontAttributeName, nil];
    
    CGSize actualSize=[content boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
    
    contentLabel.frame=CGRectMake(20, 27, 280, actualSize.height);
    
    CGRect frame=self.frame;
    frame.size.height=actualSize.height+63;
    self.frame=frame;
}

@end
