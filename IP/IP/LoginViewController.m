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
#import "Settings.h"
#import "User.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import <Parse/Parse.h>

@interface LoginViewController ()

@end

@implementation LoginViewController
{
    Settings *settings;
    AppDelegate *appDelegate;
    MBProgressHUD *progressHUD;
}

@synthesize usernameTextField;
@synthesize passwordTextField;
@synthesize loginButton;
@synthesize registerButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    settings=[[Settings alloc]init];
    
    if (settings.is4Inch)
    {
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Background_4.png"]]];
    }
    else
    {
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Background_3.5.png"]]];
    }
    
    self.title=@"SparkHere";
    
    NSDictionary *attributes=[NSDictionary dictionaryWithObjectsAndKeys:
                               [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavigationBar.png"] forBarMetrics:UIBarMetricsDefault];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    appDelegate=[[UIApplication sharedApplication]delegate];
    progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    
    [usernameTextField becomeFirstResponder];
    
    [appDelegate setDefaultViewStyle:usernameTextField];
    [appDelegate setDefaultViewStyle:passwordTextField];
    [appDelegate setDefaultViewStyle:loginButton];
    [appDelegate setDefaultViewStyle:registerButton];
    
    usernameTextField.text=@"user2";
    passwordTextField.text=@"222";
}

- (IBAction)loginButtonClicked:(id)sender
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    [self constructUser];
    if (appDelegate.user!=nil)
    {
        [self showLoginWaitingView];
    }
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
        [self constructUser];
        if (appDelegate.user!=nil)
        {
            [self showLoginWaitingView];
        }
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

- (void)showLoginWaitingView
{
    [[UIApplication sharedApplication].keyWindow addSubview:progressHUD];
    progressHUD.dimBackground = YES;
    progressHUD.labelText = @"Loading...";
    [progressHUD showAnimated:YES whileExecutingBlock:^
     {
         [self loginRequest];
     }];
}

@end
