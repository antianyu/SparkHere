//
//  MessageTableViewCell.m
//  IP
//
//  Created by Tianyu An on 14-7-2.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "MessageTableViewCell.h"

@implementation MessageTableViewCell
{
    UILabel *contentLabel;
}

@synthesize senderLabel;
@synthesize channelLabel;
@synthesize senderLogoImageView;
@synthesize channelLogoImageView;

- (void)awakeFromNib
{
//    [self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"MessageCell.png"]]];
    [self setBackgroundColor:[UIColor clearColor]];
    [senderLabel setTextColor:[UIColor lightGrayColor]];
    [channelLabel setTextColor:[UIColor lightGrayColor]];
}

- (void)setMessage:(Message *)message fontSize:(int)fontSize
{
    senderLabel.font=[UIFont systemFontOfSize:fontSize-6];
    senderLogoImageView.image=message.sender.logo;
    senderLabel.text=message.sender.nickname;
    
    channelLabel.font=[UIFont systemFontOfSize:fontSize-6];
    channelLogoImageView.image=message.channel.logo;
    channelLabel.text=message.channel.channelName;
    
    if (message.content.length>0)
    {
        contentLabel=[[UILabel alloc]init];
        contentLabel.font=[UIFont systemFontOfSize:fontSize];
        [contentLabel setTextColor:[UIColor whiteColor]];
        contentLabel.text=message.content;
        contentLabel.numberOfLines=0;
        contentLabel.lineBreakMode=NSLineBreakByWordWrapping;
        
        CGSize constraint=CGSizeMake(280, 1000);
        NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:contentLabel.font, NSFontAttributeName, nil];
        
        CGSize actualSize=[message.content boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
        
        contentLabel.frame=CGRectMake(20, 32, 280, actualSize.height);
        [self addSubview:contentLabel];
       
        CGRect frame=self.frame;
        frame.size.height=actualSize.height+73;
        self.frame=frame;
    }
    
    if(message.image!=nil)
    {
        CGRect frame;
        double imageHeight=240*message.image.size.height/message.image.size.width;
        if(message.content.length==0)
        {
            frame=CGRectMake(40, 36, 240, imageHeight);
        }
        else
        {
            frame=CGRectMake(40, 40+contentLabel.frame.size.height, 240, imageHeight);
        }
        UIImageView *imageView=[[UIImageView alloc]initWithFrame:frame];
        imageView.image=message.image;
        [self addSubview:imageView];
        frame=self.frame;
        frame.size.height+=imageHeight+8;
        self.frame=frame;
    }
}

@end
