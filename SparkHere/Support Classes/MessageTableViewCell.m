//
//  MessageTableViewCell.m
//  SparkHere
//
//  Created by Tianyu An on 14-7-2.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "MessageTableViewCell.h"
#import "AppDelegate.h"

@implementation MessageTableViewCell
{
    UILabel *contentLabel;
    AppDelegate *appDelegate;
}

@synthesize senderLabel;
@synthesize channelLabel;
@synthesize updateLabel;
@synthesize locationLabel;
@synthesize senderLogoImageView;
@synthesize logoImageViewContainer;

- (void)awakeFromNib
{
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self setBackgroundColor:[UIColor clearColor]];
    [senderLabel setTextColor:appDelegate.majorColor];
    [channelLabel setTextColor:appDelegate.detailColor];
    [updateLabel setTextColor:appDelegate.detailColor];
    [locationLabel setTextColor:appDelegate.majorColor];
    [appDelegate setImageViewStyle:senderLogoImageView container:logoImageViewContainer borderWidth:1.5 shadowOffset:2];
}

- (void)setMessage:(Message *)message fontSize:(int)fontSize
{    
    senderLabel.font=[UIFont systemFontOfSize:fontSize-6];
    senderLogoImageView.image=message.sender.logo;
    senderLabel.text=message.sender.nickname;
    
    channelLabel.font=[UIFont systemFontOfSize:fontSize-8];
    channelLabel.text=[@"via: " stringByAppendingString:message.channel.channelName];
    
    locationLabel.font=[UIFont systemFontOfSize:fontSize-6];
    locationLabel.text=message.area;
    
    updateLabel.font=[UIFont systemFontOfSize:fontSize-8];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit |NSHourCalendarUnit |NSMinuteCalendarUnit;
    NSDateComponents *cmp1 = [calendar components:unitFlags fromDate:message.updateAt];
    NSDateComponents *cmp2 = [calendar components:unitFlags fromDate:[NSDate date]];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if ([cmp1 day] == [cmp2 day])
    {
        [formatter setDateFormat:@"HH:mm a"];
        NSString *time = [formatter stringFromDate:message.updateAt];
        updateLabel.text = [NSString stringWithFormat:@"Today %@", time];
    }
    else
    {
        formatter.dateFormat = @"dd/MM/yyyy HH:mm a";
        NSString *time = [formatter stringFromDate:message.updateAt];
        updateLabel.text = [NSString stringWithFormat:@"%@", time];
    }
    
    if (message.content.length>0)
    {
        contentLabel=[[UILabel alloc]init];
        contentLabel.font=[UIFont systemFontOfSize:fontSize];
        contentLabel.text=message.content;
        contentLabel.numberOfLines=0;
        contentLabel.lineBreakMode=NSLineBreakByWordWrapping;
        contentLabel.textColor=appDelegate.descriptionColor;
        
        CGSize constraint=CGSizeMake(LABEL_WIDTH, MAXIMUM_HEIGHT);
        NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:contentLabel.font, NSFontAttributeName, nil];
        
        CGSize actualSize=[message.content boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
        
        contentLabel.frame=CGRectMake(LABEL_ORIGIN_X, self.frame.size.height+INTERVAL, LABEL_WIDTH, actualSize.height);
        [self addSubview:contentLabel];
       
        CGRect frame=self.frame;
        frame.size.height+=actualSize.height+INTERVAL;
        self.frame=frame;
    }
    
    if(message.image!=nil)
    {
        CGRect frame;
        double imageHeight=IMAGE_WIDTH*message.image.size.height/message.image.size.width;
        frame=CGRectMake(IMAGE_ORIGIN_X, self.frame.size.height+INTERVAL, IMAGE_WIDTH, imageHeight);
        
        UIImageView *imageView=[[UIImageView alloc]initWithFrame:frame];
        imageView.image=message.image;
        [self addSubview:imageView];
        
        frame=self.frame;
        frame.size.height+=imageHeight+INTERVAL;
        self.frame=frame;
    }
    
    CGRect frame=self.frame;
    frame.size.height+=PADDING;
    self.frame=frame;
}

@end
