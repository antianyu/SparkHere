//
//  LoginViewController.m
//  SparkHere
//
//  Created by Tianyu An on 14-6-19.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <Parse/Parse.h>
#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "MainViewController.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "User.h"
#import "TextInputError.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
{
    AppDelegate *appDelegate;
    MBProgressHUD *progressHUD;
    TextInputError inputError;
}

@synthesize usernameTextField;
@synthesize passwordTextField;
@synthesize loginButton;
@synthesize registerButton;
@synthesize autoLoginSwitch;
@synthesize autoLoginLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"SparkHere";
    
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    progressHUD=[[MBProgressHUD alloc] initWithView:self.view];
    progressHUD.dimBackground = NO;
    progressHUD.userInteractionEnabled=NO;
    progressHUD.labelText = @"Please wait...";
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:appDelegate.backgroundImage]];
    
    [usernameTextField becomeFirstResponder];
    
    [appDelegate setDefaultViewStyle:usernameTextField];
    [appDelegate setDefaultViewStyle:passwordTextField];
    [appDelegate setDefaultViewStyle:loginButton];
    [appDelegate setDefaultViewStyle:registerButton];
    
    autoLoginSwitch.on=NO;
    autoLoginLabel.text=@"NO";
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [progressHUD removeFromSuperview];
}

- (IBAction)loginButtonClicked:(id)sender
{
    [self login];
}

- (IBAction)registerButtonClicked:(id)sender
{
    RegisterViewController *controller=[[RegisterViewController alloc]init];
    
    UIBarButtonItem *backButton=[[UIBarButtonItem alloc]initWithTitle:@"Login" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem=backButton;
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)switchValueChanged:(id)sender
{
    UISwitch *senderSwitch=(UISwitch *)sender;
    if(senderSwitch.on)
    {
        autoLoginLabel.text=@"YES";
    }
    else
    {
        autoLoginLabel.text=@"NO";
    }
}

- (IBAction)viewTouchDown:(id)sender
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (usernameTextField.text.length>0 && passwordTextField.text.length>0)
    {
        [self login];
    }
    else if(textField==usernameTextField)
    {
        [passwordTextField becomeFirstResponder];
    }
    else
    {
        [usernameTextField becomeFirstResponder];
    }
    return NO;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(inputError==TextInputErrorUserName)
    {
        [usernameTextField becomeFirstResponder];
    }
    else if(inputError==TextInputErrorPassword)
    {
        [passwordTextField becomeFirstResponder];
    }
}

- (void)constructUser
{
    if (usernameTextField.text.length==0)
    {
        inputError=TextInputErrorUserName;
        [appDelegate showUIAlertViewWithTitle:@"Error" message:@"Username can't be empty!" delegate:self];
    }
    else if (passwordTextField.text.length==0)
    {
        inputError=TextInputErrorPassword;
        [appDelegate showUIAlertViewWithTitle:@"Error" message:@"Password can't be empty!" delegate:self];
    }
    else
    {
        appDelegate.user=[[User alloc]init:usernameTextField.text userPassword:passwordTextField.text];
    }
}

- (void)loginRequest
{
    PFQuery *query=[PFQuery queryWithClassName:@"User"];
    [query whereKey:@"username" equalTo:appDelegate.user.username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error && objects.count>0)
         {
             [query whereKey:@"password" equalTo:appDelegate.user.userPassword];
             [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
              {
                  if (!error && objects.count>0)
                  {
                      if (autoLoginSwitch.on)
                      {
                          appDelegate.settings.autoLogin=YES;
                          [appDelegate setCurrentUser:[objects firstObject]];
                          
                          PFInstallation *currentInstallation=[PFInstallation currentInstallation];
                          [currentInstallation setObject:appDelegate.user.userID forKey:@"currentUserID"];
                          [currentInstallation saveInBackground];
                      }
                      else
                      {
                          appDelegate.settings.autoLogin=NO;
                          [appDelegate.settings saveSettings];
                      }
                      [progressHUD removeFromSuperview];
                      
                      appDelegate.refreshMessageList=YES;
                      appDelegate.refreshMyChannelList=YES;
                      [appDelegate.messageList removeAllObjects];
                      [appDelegate.myChannelList removeAllObjects];
                      
                      MainViewController *controller=[[MainViewController alloc]init];
                      [controller setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
                      [self presentViewController:controller animated:YES completion:nil];
                  }
                  else if(!error && objects.count==0)
                  {
                      [progressHUD removeFromSuperview];
                      inputError=TextInputErrorPassword;
                      [appDelegate showUIAlertViewWithTitle:@"Error" message:@"Username and password do not match!"  delegate:self];
                  }
                  else
                  {
                      [progressHUD removeFromSuperview];
                      inputError=TextInputErrorNone;
                      [appDelegate showUIAlertViewWithTitle:@"Error" message:@"Query error!" delegate:self];
                  }
              }];
         }
         else if(!error && objects.count==0)
         {
             [progressHUD removeFromSuperview];
             inputError=TextInputErrorUserName;
             [appDelegate showUIAlertViewWithTitle:@"Error" message:@"Invalid username!" delegate:self];
         }
         else
         {
             [progressHUD removeFromSuperview];
             inputError=TextInputErrorNone;
             [appDelegate showUIAlertViewWithTitle:@"Error" message:@"Query error!" delegate:self];
         }
     }];
}

- (void)login
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    appDelegate.user=nil;
    [self constructUser];
    if (appDelegate.user!=nil)
    {
        [[UIApplication sharedApplication].keyWindow addSubview:progressHUD];
        [progressHUD showAnimated:YES whileExecutingBlock:^
         {
             [self loginRequest];
         }];
    }
}

@end
