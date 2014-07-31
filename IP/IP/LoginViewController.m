//
//  LoginViewController.m
//  IP
//
//  Created by Tianyu An on 14-6-19.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "MainViewController.h"
#import "User.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import <Parse/Parse.h>

@interface LoginViewController ()

@end

@implementation LoginViewController
{
    AppDelegate *appDelegate;
    MBProgressHUD *progressHUD;
}

@synthesize usernameTextField;
@synthesize passwordTextField;
@synthesize loginButton;
@synthesize registerButton;
@synthesize autoLoginSegmentedControl;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"SparkHere";
    
    appDelegate=[[UIApplication sharedApplication] delegate];
    progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:appDelegate.backgroundImage]];
    
    NSDictionary *attributes=[NSDictionary dictionaryWithObjectsAndKeys:
                               [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavigationBar.png"] forBarMetrics:UIBarMetricsDefault];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [usernameTextField becomeFirstResponder];
    
    [appDelegate setDefaultViewStyle:usernameTextField];
    [appDelegate setDefaultViewStyle:passwordTextField];
    [appDelegate setDefaultViewStyle:loginButton];
    [appDelegate setDefaultViewStyle:registerButton];
    
    if (appDelegate.settings.autoLogin)
    {
        autoLoginSegmentedControl.on=true;
        usernameTextField.text=appDelegate.settings.defaultUsername;
        passwordTextField.text=appDelegate.settings.defaultPassword;
        [self login];
    }
    else
    {
        autoLoginSegmentedControl.on=false;
    }
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

- (void)constructUser
{
    if (usernameTextField.text.length==0)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                     message:@"Username can't be empty!"
                                                    delegate:self
                                           cancelButtonTitle:@"Confirm"
                                           otherButtonTitles:nil];
        [alert show];
    }
    else if (passwordTextField.text.length==0)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                     message:@"Password can't be empty!"
                                                    delegate:self
                                           cancelButtonTitle:@"Confirm"
                                           otherButtonTitles:nil];
        [alert show];
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
                      appDelegate.refreshMessageList=true;
                      appDelegate.refreshMyChannelList=true;
                      if (autoLoginSegmentedControl.on)
                      {
                          appDelegate.settings.autoLogin=true;
                          appDelegate.settings.defaultUsername=appDelegate.user.username;
                          appDelegate.settings.defaultPassword=appDelegate.user.userPassword;
                          [appDelegate.settings saveSettings];
                      }
                      else
                      {
                          appDelegate.settings.autoLogin=false;
                          [appDelegate.settings saveSettings];
                      }
                      [progressHUD removeFromSuperview];
                      MainViewController *controller=[[MainViewController alloc]init];
                      [controller setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
                      [self presentViewController:controller animated:YES completion:^{nil;}];
                  }
                  else if(!error && objects.count==0)
                  {
                      [progressHUD removeFromSuperview];
                      UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                                   message:@"Username and password do not match!"
                                                                  delegate:self
                                                         cancelButtonTitle:@"Confirm"
                                                         otherButtonTitles:nil];
                      [alert show];
                  }
                  else
                  {
                      [progressHUD removeFromSuperview];
                      UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                                   message:@"Query error!"
                                                                  delegate:self
                                                         cancelButtonTitle:@"Confirm"
                                                         otherButtonTitles:nil];
                      [alert show];
                  }
              }];
         }
         else if(!error && objects.count==0)
         {
             [progressHUD removeFromSuperview];
             UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                          message:@"Invalid username!"
                                                         delegate:self
                                                cancelButtonTitle:@"Confirm"
                                                otherButtonTitles:nil];
             [alert show];
         }
         else
         {
             [progressHUD removeFromSuperview];
             UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                          message:@"Query error!"
                                                         delegate:self
                                                cancelButtonTitle:@"Confirm"
                                                otherButtonTitles:nil];
             [alert show];
         }
     }];
}

- (void)login
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    [self constructUser];
    if (appDelegate.user!=nil)
    {
        [[UIApplication sharedApplication].keyWindow addSubview:progressHUD];
        progressHUD.dimBackground = YES;
        progressHUD.labelText = @"Loading...";
        [progressHUD showAnimated:YES whileExecutingBlock:^
         {
             [self loginRequest];
         }];
    }
}

@end
