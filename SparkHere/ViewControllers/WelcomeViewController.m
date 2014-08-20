//
//  WelcomeViewController.m
//  SparkHere
//
//  Created by Tianyu An on 14-8-19.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "WelcomeViewController.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "AppDelegate.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController
{
    AppDelegate *appDelegate;    
}

@synthesize titleLabel;
@synthesize backgroundImageView;
@synthesize photoLabel;
@synthesize signUpButton;
@synthesize signInButton;

#pragma mark View
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (appDelegate.is4Inch)
    {
        backgroundImageView.image=[UIImage imageNamed:@"Welcome_4.png"];
    }
    else
    {
        backgroundImageView.image=[UIImage imageNamed:@"Welcome_3.5.png"];
        CGRect frame=titleLabel.frame;
        frame.origin.y=128;
        titleLabel.frame=frame;
    }
    
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.text=@"SparkHere";
    titleLabel.font=[UIFont fontWithName:@"Snell Roundhand" size:40];
    
    UIFontDescriptor *descriptor=[titleLabel.font.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    titleLabel.font=[UIFont fontWithDescriptor:descriptor size:0];
    
    [appDelegate setButtonStyle:signUpButton color:appDelegate.buttonColor];
    [appDelegate setButtonStyle:signInButton color:[UIColor lightGrayColor]];
    
    photoLabel.textColor=[UIColor darkGrayColor];
    photoLabel.text=@"Photo by Cityscapes";
    photoLabel.font=[UIFont fontWithName:@"Georgia" size:12];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden=YES;
}

- (IBAction)signUpButtonClicked:(id)sender
{
    self.navigationController.navigationBar.hidden=NO;
    RegisterViewController *controller=[[RegisterViewController alloc]init];
    
    UIBarButtonItem *backButton=[[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem=backButton;
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)signInButtonClicked:(id)sender
{
    self.navigationController.navigationBar.hidden=NO;
    LoginViewController *controller=[[LoginViewController alloc]init];
    
    UIBarButtonItem *backButton=[[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem=backButton;
    
    [self.navigationController pushViewController:controller animated:YES];
}
@end
