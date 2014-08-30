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

@synthesize usernameLabel;
@synthesize usernameTextField;
@synthesize passwordLabel;
@synthesize passwordTextField;
@synthesize loginButton;

#pragma mark View
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"Sign In";
    
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    progressHUD=[[MBProgressHUD alloc] initWithView:self.view];
    progressHUD.dimBackground = NO;
    progressHUD.userInteractionEnabled=NO;
    progressHUD.labelText = @"Please wait...";
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:appDelegate.backgroundImage]];
    
    [appDelegate setTextFieldStyle:usernameTextField];
    [appDelegate setTextFieldStyle:passwordTextField];
    
    [appDelegate setButtonStyle:loginButton color:appDelegate.buttonColor];
    
    usernameLabel.textColor=[UIColor lightGrayColor];
    passwordLabel.textColor=[UIColor lightGrayColor];
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

- (IBAction)viewTouchDown:(id)sender
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

#pragma mark UITextField
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField==usernameTextField)
    {
        usernameLabel.hidden=YES;
    }
    else if (textField==passwordTextField)
    {
        passwordLabel.hidden=YES;
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField==usernameTextField &&  textField.text.length==0)
    {
        usernameLabel.hidden=NO;
    }
    else if (textField==passwordTextField &&  textField.text.length==0)
    {
        passwordLabel.hidden=NO;
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length>15 && string.length>0)
    {
        return NO;
    }
    
    return YES;
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

#pragma mark Other Delegate
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

#pragma mark Auxiliaries
- (void)constructUser
{
    if (usernameTextField.text.length==0)
    {
        inputError=TextInputErrorUserName;
        [appDelegate showUIAlertViewWithTitle:@"Error!" message:@"Username can't be empty!" delegate:self];
    }
    else if (passwordTextField.text.length==0)
    {
        inputError=TextInputErrorPassword;
        [appDelegate showUIAlertViewWithTitle:@"Error!" message:@"Password can't be empty!" delegate:self];
    }
    else
    {
        appDelegate.user=[[User alloc]init:usernameTextField.text userPassword:passwordTextField.text];
    }
}

- (void)loginRequest
{
    // query username in table of user
    PFQuery *query=[PFQuery queryWithClassName:@"User"];
    [query whereKey:@"username" equalTo:appDelegate.user.username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error && objects.count>0) // username exists
         {
             // query password in table of user
             [query whereKey:@"password" equalTo:appDelegate.user.userPassword];
             [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
              {
                  if (!error && objects.count>0) // username and password are matched
                  {
                      // update global user with information obtained from server and save it to local storage
                      appDelegate.settings.autoLogin=YES;
                      [appDelegate setCurrentUser:[objects firstObject]];
                      
                      // update user in installation object
                      PFInstallation *currentInstallation=[PFInstallation currentInstallation];
                      [currentInstallation setObject:appDelegate.user.userID forKey:@"currentUserID"];
                      [currentInstallation saveInBackground];
                      
                      // set local flags and variables
                      appDelegate.refreshMessageList=YES;
                      appDelegate.refreshMyChannelList=YES;
                      [appDelegate.messageList removeAllObjects];
                      [appDelegate.myChannelList removeAllObjects];
                      
                      [progressHUD removeFromSuperview];
                      
                      // jump to main page
                      MainViewController *controller=[[MainViewController alloc]init];
                      [controller setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
                      [self presentViewController:controller animated:YES completion:nil];
                  }
                  else if(!error && objects.count==0) // password is not matched
                  {
                      [progressHUD removeFromSuperview];
                      inputError=TextInputErrorPassword;
                      [appDelegate showUIAlertViewWithTitle:@"Error!" message:@"Username and password do not match!"  delegate:self];
                  }
                  else // query error
                  {
                      // prompt user
                      [progressHUD removeFromSuperview];
                      inputError=TextInputErrorNone;
                      [appDelegate showUIAlertViewWithTitle:@"Error!" message:@"Query error!" delegate:self];
                  }
              }];
         }
         else if(!error && objects.count==0) // username doesn't exist
         {
             [progressHUD removeFromSuperview];
             inputError=TextInputErrorUserName;
             [appDelegate showUIAlertViewWithTitle:@"Error!" message:@"Invalid username!" delegate:self];
         }
         else // query error
         {
             [progressHUD removeFromSuperview];
             inputError=TextInputErrorNone;
             [appDelegate showUIAlertViewWithTitle:@"Error!" message:@"Query error!" delegate:self];
         }
     }];
}

- (void)login
{
    // Hide keyboard
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    // construct user
    appDelegate.user=nil;
    [self constructUser];
    
    // send login request
    if (appDelegate.user!=nil)
    {
        // show waiting view
        [[UIApplication sharedApplication].keyWindow addSubview:progressHUD];
        [progressHUD showAnimated:YES whileExecutingBlock:^
         {
             [self loginRequest];
         }];
    }
}

@end
