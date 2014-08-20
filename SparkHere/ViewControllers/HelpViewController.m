//
//  HelpViewController.m
//  SparkHere
//
//  Created by Tianyu An on 14-6-12.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "HelpViewController.h"
#import "AppDelegate.h"

@interface HelpViewController ()

@end

@implementation HelpViewController
{
    AppDelegate *appDelegate;
}

@synthesize scrollView;
@synthesize helpLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"Help";
    
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:appDelegate.backgroundImage]];
    
    NSString *helpString=@"FAQ:\n\n"
    
    "1. What is Channel?\n"
    
    "Answer: Channel is a carrier, like frequecy in radio. When you subscribe a channel (just like switch to FM XX.X on your radio), "
    "then you can receive messages via this channel.\n\n"
    
    "2. How to subscribe a channel?\n"
    
    "Answer: Choose a category of channels, or search key words in search bar, then select a channel, click \"Follow\" button.\n\n"
    
    "3. Now I have subscribed a channel, how to send a message?\n"
    
    "Answer: Click the button at bottom. It will lead you to new message page. Write your message there.\n\n"
    
    "4. Why can't I see the button at bottom?\n"
    
    "Answer: Have you subscribed the channel? If you do, the reason is that you don't have enough privilege to send a message.\n\n"
    
    "5. Privilege? What is privilege?\n"
    
    "Answer: When you subscribe a channel, there will a privilege that controls what you can do to that channel. \n\n"
    "There are 4 levels:\n"
    "Level 1: Just receive message via that channel.\n"
    "Level 2: Receive and send message via that channel.\n"
    "Level 3: Adminstrator, you can modify the privilege of those whose privilege is level 1 or 2 apart from receiving and sending message.\n"
    "Level 4: Super Adminstrator, you can do whatever you want! Delete that channel, remove other subscribers...\n\n";
    
    [helpLabel setNumberOfLines:0];
    helpLabel.font=[UIFont systemFontOfSize:17];
    helpLabel.lineBreakMode=NSLineBreakByWordWrapping;
    helpLabel.text=helpString;
    helpLabel.textColor=appDelegate.majorColor;
    
    CGSize constraint=CGSizeMake(self.view.frame.size.width-40, 20000);
    NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:helpLabel.font, NSFontAttributeName, nil];
    
    CGSize actualSize=[helpString boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
    
    helpLabel.frame=CGRectMake(20, 20, self.view.frame.size.width-40, actualSize.height);
    
    scrollView.contentSize=CGSizeMake(self.view.frame.size.width, actualSize.height+20);
    [scrollView addSubview:helpLabel];
}

@end
