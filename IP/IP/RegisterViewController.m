//
//  RegisterViewController.m
//  IP
//
//  Created by Tianyu An on 14-6-20.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "RegisterViewController.h"
#import "MainViewController.h"
#import "Settings.h"
#import "User.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import <Parse/Parse.h>

@interface RegisterViewController ()

@end

@implementation RegisterViewController
{
    Settings *settings;
    AppDelegate *appDelegate;
    MBProgressHUD *progressHUD;
    User *user;
    int inputError;
}

@synthesize usernameTextField;
@synthesize passwordTextField;
@synthesize confirmPwdTextField;
@synthesize nicknameTextField;

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
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    self.title=@"Register";
    
    [usernameTextField becomeFirstResponder];
    
    usernameTextField.textColor=[UIColor whiteColor];
    usernameTextField.backgroundColor=[UIColor clearColor];
    usernameTextField.layer.borderColor=[[UIColor whiteColor]CGColor];
    usernameTextField.layer.borderWidth=1.5;
    usernameTextField.layer.cornerRadius=5;
    
    passwordTextField.textColor=[UIColor whiteColor];
    passwordTextField.backgroundColor=[UIColor clearColor];
    passwordTextField.layer.borderColor=[[UIColor whiteColor]CGColor];
    passwordTextField.layer.borderWidth=1.5;
    passwordTextField.layer.cornerRadius=5;
    
    confirmPwdTextField.textColor=[UIColor whiteColor];
    confirmPwdTextField.backgroundColor=[UIColor clearColor];
    confirmPwdTextField.layer.borderColor=[[UIColor whiteColor]CGColor];
    confirmPwdTextField.layer.borderWidth=1.5;
    confirmPwdTextField.layer.cornerRadius=5;
    
    nicknameTextField.textColor=[UIColor whiteColor];
    nicknameTextField.backgroundColor=[UIColor clearColor];
    nicknameTextField.layer.borderColor=[[UIColor whiteColor]CGColor];
    nicknameTextField.layer.borderWidth=1.5;
    nicknameTextField.layer.cornerRadius=5;
    
    user=nil;
    
    appDelegate=[[UIApplication sharedApplication]delegate];
    progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)registerButtonClicked:(id)sender
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    [self constructUser];
    if (user!=nil)
    {
        [self showRegisterWaitingView];
    }
}

- (IBAction)viewTouchDown:(id)sender
{    
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    if (usernameTextField.text.length>0 && passwordTextField.text.length>0 &&
        confirmPwdTextField.text.length>0 && nicknameTextField.text.length>0)
    {
        [self constructUser];
        if (user!=nil)
        {
            [self showRegisterWaitingView];
        }
    }
    else if (textField==usernameTextField)
    {
        [passwordTextField becomeFirstResponder];
    }
    else if (textField==passwordTextField)
    {
        [confirmPwdTextField becomeFirstResponder];
    }
    else if (textField==confirmPwdTextField)
    {
        [nicknameTextField becomeFirstResponder];
    }
    else // textField==nicknameTextField
    {
        [usernameTextField becomeFirstResponder];
    }
    return NO;
}

- (void)constructUser
{
    if (usernameTextField.text.length==0)
    {
        inputError=0;
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                     message:@"Username can't be empty!"
                                                    delegate:self
                                           cancelButtonTitle:@"Confirm"
                                           otherButtonTitles:nil];
        [alert show];
    }
    else if (passwordTextField.text.length==0)
    {
        inputError=1;
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                     message:@"Password can't be empty!"
                                                    delegate:self
                                           cancelButtonTitle:@"Confirm"
                                           otherButtonTitles:nil];
        [alert show];
    }
    else if (confirmPwdTextField.text.length==0)
    {
        inputError=2;
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                     message:@"Please confirm password!"
                                                    delegate:self
                                           cancelButtonTitle:@"Confirm"
                                           otherButtonTitles:nil];
        [alert show];
    }
    else if (nicknameTextField.text.length==0)
    {
        inputError=3;
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                     message:@"Nickname can't be empty!"
                                                    delegate:self
                                           cancelButtonTitle:@"Confirm"
                                           otherButtonTitles:nil];
        [alert show];
    }
    else if (![passwordTextField.text isEqual:confirmPwdTextField.text])
    {
        inputError=2;
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                     message:@"The passwords you typed do not match!"
                                                    delegate:self
                                           cancelButtonTitle:@"Confirm"
                                           otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        user=[[User alloc]init:usernameTextField.text userPassword:passwordTextField.text
                            nickname:nicknameTextField.text];
    }
}

- (void)registerRequest
{
    PFQuery *query=[PFQuery queryWithClassName:@"User"];
    [query whereKey:@"username" equalTo:user.username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error && objects.count>0)
         {
             [progressHUD removeFromSuperview];
             UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                          message:@"Username already exists!"
                                                         delegate:self
                                                cancelButtonTitle:@"Confirm"
                                                otherButtonTitles:nil];
             [alert show];
         }
         else if(!error && objects.count==0)
         {
             [query whereKey:@"nickname" equalTo:user.nickname];
             [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
              {
                  if (!error && objects.count>0)
                  {
                      [progressHUD removeFromSuperview];
                      UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                                   message:@"Nickname already exists!"
                                                                  delegate:self
                                                         cancelButtonTitle:@"Confirm"
                                                         otherButtonTitles:nil];
                      [alert show];
                  }
                  else if(!error && objects.count==0)
                  {
                      PFObject *newUser=[PFObject objectWithClassName:@"User"];
                      newUser[@"username"]=user.username;
                      newUser[@"password"]=user.userPassword;
                      newUser[@"nickname"]=user.nickname;
                      [newUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                       {
                           if (!error)
                           {                               
                               [progressHUD removeFromSuperview];
                               UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Congratulations"
                                                                            message:@"Register succeed!"
                                                                           delegate:self
                                                                  cancelButtonTitle:nil
                                                                  otherButtonTitles:@"Confirm", nil];
                               [alert show];
                           }
                           else
                           {
                               [progressHUD removeFromSuperview];
                               UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Woops!"
                                                                            message:@"Register failed! Something wrong with server!"
                                                                           delegate:self
                                                                  cancelButtonTitle:@"Confirm"
                                                                  otherButtonTitles:nil];
                               [alert show];
                           }
                       }];
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

- (void)showRegisterWaitingView
{
    [[UIApplication sharedApplication].keyWindow addSubview:progressHUD];
    progressHUD.dimBackground = YES;
    progressHUD.labelText = @"Please wait...";
    [progressHUD showAnimated:YES whileExecutingBlock:^
     {
         [self registerRequest];
     }];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex!=alertView.cancelButtonIndex)
    {
        appDelegate.user=user;
        appDelegate.refreshMessageList=false;
        appDelegate.refreshMyChannelList=false;
        MainViewController *controller=[[MainViewController alloc]init];
        controller.selectedIndex=2;
        [controller setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
        [self presentViewController:controller animated:YES completion:^{nil;}];
    }
    else if(inputError==0)
    {
        [usernameTextField becomeFirstResponder];
    }
    else if(inputError==1)
    {
        [passwordTextField becomeFirstResponder];
    }
    else if(inputError==2)
    {
        [confirmPwdTextField becomeFirstResponder];
    }
    else if(inputError==3)
    {
        [nicknameTextField becomeFirstResponder];
    }
}

@end
