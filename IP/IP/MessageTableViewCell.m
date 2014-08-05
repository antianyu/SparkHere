//
//  MessageTableViewCell.m
//  IP
//
//  Created by Tianyu An on 14-7-2.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "MessageTableViewCell.h"

const int MAXIMUM_HEIGHT=1000;
const int LABEL_WIDTH=280;
const int IMAGE_WIDTH=240;
const int LABEL_ORIGIN_X=20;
const int LABEL_ORIGIN_Y=49;
const int IMAGE_ORIGIN_X=40;
const int IMAGE_ORIGIN_Y=53;
const int INTERVAL=8;

@implementation MessageTableViewCell
{
    UILabel *contentLabel;
}

@synthesize senderLabel;
@synthesize channelLabel;
@synthesize updateLabel;
@synthesize senderLogoImageView;
@synthesize channelLogoImageView;

- (void)awakeFromNib
{
    [self setBackgroundColor:[UIColor clearColor]];
}

- (void)setMessage:(Message *)message fontSize:(int)fontSize
{
    senderLabel.font=[UIFont systemFontOfSize:fontSize-6];
    senderLogoImageView.image=message.sender.logo;
    senderLabel.text=message.sender.nickname;
    [senderLabel setTextColor:[UIColor whiteColor]];
    
    channelLabel.font=[UIFont systemFontOfSize:fontSize-6];
    channelLogoImageView.image=message.channel.logo;
    channelLabel.text=message.channel.channelName;
    [channelLabel setTextColor:[UIColor lightGrayColor]];
    
    updateLabel.font=[UIFont systemFontOfSize:fontSize-8];
    [updateLabel setTextColor:[UIColor lightGrayColor]];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit |NSHourCalendarUnit |NSMinuteCalendarUnit;
    NSDateComponents *cmp1 = [calendar components:unitFlags fromDate:message.updateAt];
    NSDateComponents *cmp2 = [calendar components:unitFlags fromDate:[NSDate date]];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if ([cmp1 day] == [cmp2 day])
    {
        [formatter setDateFormat:@"HH:mm a"];
        NSString *time = [formatter stringFromDate:message.updateAt];
        updateLabel.text = [NSString stringWithFormat:@"Published at：Today %@", time];
    }
    else
    {
        formatter.dateFormat = @"dd/MM/yyyy HH:mm a";
        NSString *time = [formatter stringFromDate:message.updateAt];
        updateLabel.text = [NSString stringWithFormat:@"Published at：%@", time];
    }
    
    if (message.content.length>0)
    {
        contentLabel=[[UILabel alloc]init];
        contentLabel.font=[UIFont systemFontOfSize:fontSize];
        [contentLabel setTextColor:[UIColor whiteColor]];
        contentLabel.text=message.content;
        contentLabel.numberOfLines=0;
        contentLabel.lineBreakMode=NSLineBreakByWordWrapping;
        
        CGSize constraint=CGSizeMake(LABEL_WIDTH, MAXIMUM_HEIGHT);
        NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:contentLabel.font, NSFontAttributeName, nil];
        
        CGSize actualSize=[message.content boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
        
        contentLabel.frame=CGRectMake(LABEL_ORIGIN_X, LABEL_ORIGIN_Y, LABEL_WIDTH, actualSize.height);
        [self addSubview:contentLabel];
       
        CGRect frame=self.frame;
        frame.size.height+=actualSize.height+INTERVAL;
        self.frame=frame;
    }
    
    if(message.image!=nil)
    {
        CGRect frame;
        double imageHeight=IMAGE_WIDTH*message.image.size.height/message.image.size.width;
        if(message.content.length==0)
        {
            frame=CGRectMake(IMAGE_ORIGIN_X, IMAGE_ORIGIN_Y, IMAGE_WIDTH, imageHeight);
        }
        else
        {
            frame=CGRectMake(IMAGE_ORIGIN_X, LABEL_ORIGIN_Y+contentLabel.frame.size.height+INTERVAL, IMAGE_WIDTH, imageHeight);
        }
        UIImageView *imageView=[[UIImageView alloc]initWithFrame:frame];
        imageView.image=message.image;
        [self addSubview:imageView];
        frame=self.frame;
        frame.size.height+=imageHeight+INTERVAL;
        self.frame=frame;
    }
}

@end
