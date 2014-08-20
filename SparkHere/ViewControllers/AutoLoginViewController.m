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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:appDelegate.backgroundImage]];
    
    CALayer *layer=logoImageView.layer;
    layer.masksToBounds=YES;
    layer.cornerRadius=50;
    layer.borderColor=[UIColor whiteColor].CGColor;
    layer.borderWidth=3;
    
    logoImageViewContainer.backgroundColor=[UIColor clearColor];
    CALayer *containerLayer=logoImageViewContainer.layer;
    containerLayer.shadowColor=[UIColor darkGrayColor].CGColor;
    containerLayer.shadowOpacity=0.8;
    containerLayer.shadowOffset=CGSizeMake(3, 3);
    containerLayer.shadowRadius=3;
    containerLayer.shadowPath=[UIBezierPath bezierPathWithRoundedRect:logoImageView.bounds cornerRadius:50].CGPath;
    
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
