//
//  AboutViewController.m
//  SparkHere
//
//  Created by Tianyu An on 14-6-12.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "AboutViewController.h"
#import "AppDelegate.h"

@interface AboutViewController ()

@end

@implementation AboutViewController
{
     AppDelegate *appDelegate;
}

@synthesize scrollView;
@synthesize aboutLabel;

#pragma mark View
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"About";
    
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:appDelegate.backgroundImage]];
    
    NSString *aboutString=@"SparkHere Version 1.0\n\n"
    
    "Many thanks to Dr. Chao Wu, Wuyang Xu and Minghao Fan.\n\n"
    
    "Any furthur questions please send email to aty_3361@sina.com";
    
    [aboutLabel setNumberOfLines:0];
    aboutLabel.font=[UIFont systemFontOfSize:17];
    aboutLabel.lineBreakMode=NSLineBreakByWordWrapping;
    aboutLabel.text=aboutString;
    aboutLabel.textColor=appDelegate.majorColor;
    
    
    CGSize constraint=CGSizeMake(self.view.frame.size.width-40, 20000);
    NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:aboutLabel.font, NSFontAttributeName, nil];
    
    CGSize actualSize=[aboutString boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
    
    aboutLabel.frame=CGRectMake(20, 20, self.view.frame.size.width-40, actualSize.height);
    
    scrollView.contentSize=CGSizeMake(self.view.frame.size.width, actualSize.height+20);
    [scrollView addSubview:aboutLabel];
}

@end
