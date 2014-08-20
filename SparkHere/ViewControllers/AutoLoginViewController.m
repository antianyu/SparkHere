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
@synthesize logoImageViewContainer;
@synthesize nicknameLabel;

#pragma mark View
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:appDelegate.backgroundImage]];
    
    [appDelegate setImageViewStyle:logoImageView container:logoImageViewContainer borderWidth:3 shadowOffset:3];
    
    logoImageView.image=appDelegate.settings.defaultLogo;
    nicknameLabel.text=appDelegate.settings.defaultNickname;
    nicknameLabel.textColor=appDelegate.majorColor;
    
    appDelegate.refreshMessageList=YES;
    appDelegate.refreshMyChannelList=YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [NSThread sleepForTimeInterval:1];
    
    MainViewController *controller=[[MainViewController alloc]init];
    [controller setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [self presentViewController:controller animated:YES completion:nil];    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}
@end
