//
//  AutoLoginViewController.m
//  SparkHere
//
//  Created by Tianyu An on 14-8-5.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "AutoLoginViewController.h"
#import "MainViewController.h"
#import "AppDelegate.h"

@interface AutoLoginViewController ()

@end

@implementation AutoLoginViewController
{
    AppDelegate *appDelegate;
}

@synthesize logoImageView;
@synthesize nicknameLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate=[[UIApplication sharedApplication] delegate];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:appDelegate.backgroundImage]];
    
    logoImageView.image=appDelegate.settings.defaultLogo;
    nicknameLabel.text=appDelegate.settings.defaultNickname;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [NSThread sleepForTimeInterval:1];
    
    MainViewController *controller=[[MainViewController alloc]init];
    [controller setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [self presentViewController:controller animated:YES completion:^{nil;}];    
}

@end
