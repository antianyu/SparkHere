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
    
    if (!appDelegate.is4Inch)
    {
        CGRect frame=logoImageViewContainer.frame;
        frame.origin.y-=40;
        logoImageViewContainer.frame=frame;
        
        frame=nicknameLabel.frame;
        frame.origin.y-=40;
        nicknameLabel.frame=frame;
    }
    
    [appDelegate setImageViewStyle:logoImageView container:logoImageViewContainer borderWidth:2.5 shadowOffset:3];
    
    logoImageView.image=appDelegate.settings.defaultLogo;
    
    nicknameLabel.text=[@"Welcome back,\n" stringByAppendingString:appDelegate.settings.defaultNickname];
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
