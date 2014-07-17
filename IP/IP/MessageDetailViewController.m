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
@synthesize logoImageView;
@synthesize senderLabel;
@synthesize channelLabel;
@synthesize contentLabel;

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
    
    self.senderLabel.text=message.sender.nickname;
    self.channelLabel.text=message.channel.channelName;
    
    NSString *detailString=message.content;
    
    [contentLabel setNumberOfLines:0];
    contentLabel.font=[UIFont systemFontOfSize:17];
    contentLabel.lineBreakMode=NSLineBreakByWordWrapping;
    contentLabel.text=detailString;
    
    CGSize constraint=CGSizeMake(self.view.frame.size.width-40, 20000);
    NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:contentLabel.font, NSFontAttributeName, nil];
    
    CGSize actualSize=[detailString boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
    
    contentLabel.frame=CGRectMake(20, 150, self.view.frame.size.width-40, actualSize.height);
    
    scrollView.contentSize=CGSizeMake(self.view.frame.size.width, actualSize.height+170);
    [scrollView addSubview:contentLabel];
    
    appDelegate=[[UIApplication sharedApplication]delegate];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    appDelegate.refreshPostsList=false;
}

@end
