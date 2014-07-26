//
//  MessageDetailViewController.m
//  IP
//
//  Created by Tianyu An on 14-6-12.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "MessageDetailViewController.h"
#import "Settings.h"
#import "AppDelegate.h"

@interface MessageDetailViewController ()

@end

@implementation MessageDetailViewController
{
    Settings *settings;
    AppDelegate *appDelegate;
}

@synthesize scrollView;
@synthesize senderLabel;
@synthesize senderLogoImageView;
@synthesize channelLabel;
@synthesize channelLogoImageView;

@synthesize message;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    settings=[[Settings alloc]init];
    
    if (settings.is4Inch)
    {
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Background_4.png"]]];
    }
    else
    {
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Background_3.5.png"]]];
    }
    
    senderLabel.text=message.sender.nickname;
    channelLabel.text=message.channel.channelName;
    
    senderLogoImageView.image=message.sender.logo;
    channelLogoImageView.image=message.channel.logo;
    
    UILabel *contentLabel=[[UILabel alloc]init];
    if (message.content.length>0)
    {
        contentLabel.font=[UIFont systemFontOfSize:18];
        contentLabel.textColor=[UIColor whiteColor];
        contentLabel.numberOfLines=0;
        contentLabel.lineBreakMode=NSLineBreakByWordWrapping;
        contentLabel.text=message.content;
        
        CGSize constraint=CGSizeMake(self.view.frame.size.width-40, 10000);
        NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:contentLabel.font, NSFontAttributeName, nil];
        
        CGSize actualSize=[message.content boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
        
        contentLabel.frame=CGRectMake(20, 108, self.view.frame.size.width-40, actualSize.height);
        
        scrollView.contentSize=CGSizeMake(self.view.frame.size.width, actualSize.height+20);
        [scrollView addSubview:contentLabel];
    }
    
    if(message.image!=nil)
    {
        CGRect frame;
        double imageHeight=240*message.image.size.height/message.image.size.width;
        if(message.content.length==0)
        {
            frame=CGRectMake(40, 116, self.view.frame.size.width-80, imageHeight);
        }
        else
        {
            frame=CGRectMake(40, 116+contentLabel.frame.size.height, self.view.frame.size.width-80, imageHeight);
        }
        UIImageView *imageView=[[UIImageView alloc]initWithFrame:frame];
        imageView.image=message.image;
        
        scrollView.contentSize=CGSizeMake(self.view.frame.size.width, scrollView.contentSize.height+imageHeight+8);
        [scrollView addSubview:imageView];
    }
    
    appDelegate=[[UIApplication sharedApplication]delegate];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    appDelegate.refreshPostsList=false;
}

@end
