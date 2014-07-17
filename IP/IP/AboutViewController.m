//
//  AboutViewController.m
//  IP
//
//  Created by Tianyu An on 14-6-12.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "AboutViewController.h"
#import "Settings.h"

@interface AboutViewController ()

@end

@implementation AboutViewController
{
    Settings *settings;
}

@synthesize scrollView;
@synthesize aboutLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *aboutString=@"About\n\n"
    
    "This is about page!\n\n"
    
    "This is about page!\n\n"
    
    "This is about page!\n\n"
    
    "This is about page!\n\n"
    
    "This is about page!\n\n"
    
    "This is about page!\n\n"
    
    "This is about page!\n\n"
    
    "This is about page!\n\n"
    
    "This is about page!\n\n"
    
    "This is about page!\n\n"
    
    "This is about page!\n\n"
    
    "This is about page!\n\n"
    
    "This is about page!\n\n"
    
    "This is about page!\n\n"
    
    "This is about page!\n\n"
    
    "This is about page!\n\n"
    
    "This is about page!\n\n"
    
    "This is about page!\n\n"
    
    "This is about page!\n\n"
    
    "This is about page!\n\n"
    
    "This is about page!\n\n";
    
    [aboutLabel setNumberOfLines:0];
    aboutLabel.font=[UIFont systemFontOfSize:17];
    aboutLabel.lineBreakMode=NSLineBreakByWordWrapping;
    aboutLabel.text=aboutString;
    
    
    CGSize constraint=CGSizeMake(self.view.frame.size.width-40, 20000);
    NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:aboutLabel.font, NSFontAttributeName, nil];
    
    CGSize actualSize=[aboutString boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
    
    aboutLabel.frame=CGRectMake(20, 20, self.view.frame.size.width-40, actualSize.height);
    
    scrollView.contentSize=CGSizeMake(self.view.frame.size.width, actualSize.height+20);
    [scrollView addSubview:aboutLabel];
    
    self.title=@"About";
    
    settings=[[Settings alloc]init];
    
    if (settings.is4Inch)
    {
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Background_4.png"]]];
    }
    else
    {
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Background_3.5.png"]]];
    }
}

@end
