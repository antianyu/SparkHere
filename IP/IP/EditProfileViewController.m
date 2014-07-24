//
//  EditProfileViewController.m
//  IP
//
//  Created by Tianyu An on 14-7-24.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "EditProfileViewController.h"
#import "Settings.h"
#import "User.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import <Parse/Parse.h>
#import "TextInputError.h"

@interface EditProfileViewController ()

@end

@implementation EditProfileViewController
{
    Settings *settings;
    AppDelegate *appDelegate;
    MBProgressHUD *progressHUD;
    TextInputError inputError;
}

@synthesize nicknameTextField;
@synthesize theOriginalPwdTextField;
@synthesize theNewPwdTextField;
@synthesize theConfirmPwdTextField;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"Edit Profile";
    
    UIBarButtonItem *saveButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonClicked)];
    self.navigationItem.rightBarButtonItem=saveButtonItem;
    
    settings=[[Settings alloc]init];
    
    if (settings.is4Inch)
    {
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Background_4.png"]]];
    }
    else
    {
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Background_3.5.png"]]];
    }
    
    appDelegate=[[UIApplication sharedApplication]delegate];
    progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    
    [nicknameTextField becomeFirstResponder];
    
    [appDelegate setDefaultViewStyle:nicknameTextField];
    [appDelegate setDefaultViewStyle:theOriginalPwdTextField];
    [appDelegate setDefaultViewStyle:theNewPwdTextField];
    [appDelegate setDefaultViewStyle:theConfirmPwdTextField];
    
    nicknameTextField.text=appDelegate.user.nickname;
}

- (void)saveButtonClicked
{
    [self editProfileRequest];
}

- (IBAction)viewTouchDown:(id)sender
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (theOriginalPwdTextField.text.length>0 && theNewPwdTextField.text.length>0 &&
        theConfirmPwdTextField.text.length>0)
    {
        [self editProfileRequest];
    }
    else if (textField==nicknameTextField)
    {
        [theOriginalPwdTextField becomeFirstResponder];
    }
    else if (textField==theOriginalPwdTextField)
    {
        [theNewPwdTextField becomeFirstResponder];
    }
    else if (textField==theNewPwdTextField)
    {
        [theConfirmPwdTextField becomeFirstResponder];
    }
    else // textField==confirmPwdTextField
    {
        [theOriginalPwdTextField becomeFirstResponder];
    }
    return NO;
}

- (void)editProfileRequest
{
    if (nicknameTextField.text.length==0)
    {
        inputError=TextInputErrorNickname;
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                     message:@"Nickname can't be empty!"
                                                    delegate:self
                                           cancelButtonTitle:@"Confirm"
                                           otherButtonTitles:nil];
        [alert show];
    }
    else if (![appDelegate.user.nickname isEqualToString:nicknameTextField.text] &&
             theOriginalPwdTextField.text.length==0 && theNewPwdTextField.text.length==0 &&
             theConfirmPwdTextField.text.length==0)
    {
        [self showEditProfileWaitingView];
    }
    else if ([appDelegate.user.nickname isEqualToString:nicknameTextField.text] &&
             theOriginalPwdTextField.text.length==0 && theNewPwdTextField.text.length==0 &&
             theConfirmPwdTextField.text.length==0)
    {
        inputError=TextInputErrorNickname;
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                     message:@"Nothing changed!"
                                                    delegate:self
                                           cancelButtonTitle:@"Confirm"
                                           otherButtonTitles:nil];
        [alert show];
    }
    else if (theOriginalPwdTextField.text.length==0)
    {
        inputError=TextInputErrorOriginalPassword;
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                     message:@"Original password can't be empty!"
                                                    delegate:self
                                           cancelButtonTitle:@"Confirm"
                                           otherButtonTitles:nil];
        [alert show];
    }
    else if (theNewPwdTextField.text.length==0)
    {
        inputError=TextInputErrorNewPassword;
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                     message:@"New password can't be empty!"
                                                    delegate:self
                                           cancelButtonTitle:@"Confirm"
                                           otherButtonTitles:nil];
        [alert show];
    }
    else if (theConfirmPwdTextField.text.length==0)
    {
        inputError=TextInputErrorConfirmPassword;
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                     message:@"Please confirm password!"
                                                    delegate:self
                                           cancelButtonTitle:@"Confirm"
                                           otherButtonTitles:nil];
        [alert show];
    }
    else if (![theNewPwdTextField.text isEqual:theConfirmPwdTextField.text])
    {
        inputError=TextInputErrorConfirmPassword;
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                     message:@"The passwords you typed do not match!"
                                                    delegate:self
                                           cancelButtonTitle:@"Confirm"
                                           otherButtonTitles:nil];
        [alert show];
    }
    else if (![appDelegate.user.userPassword isEqualToString:theOriginalPwdTextField.text])
    {
        inputError=TextInputErrorOriginalPassword;
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                     message:@"Invalid original password!"
                                                    delegate:self
                                           cancelButtonTitle:@"Confirm"
                                           otherButtonTitles:nil];
        [alert show];
    }
}

- (void)showEditProfileWaitingView
{
    [[UIApplication sharedApplication].keyWindow addSubview:progressHUD];
    progressHUD.dimBackground = YES;
    progressHUD.labelText = @"Please wait...";
    [progressHUD showAnimated:YES whileExecutingBlock:^
     {
         PFObject *object=[PFObject objectWithClassName:@"User"];
         object.objectId=appDelegate.user.userID;
         object[@"username"]=appDelegate.user.username;
         object[@"nickname"]=nicknameTextField.text;
         if (theNewPwdTextField.text.length==0)
         {
             object[@"password"]=appDelegate.user.userPassword;
         }
         else
         {
             object[@"password"]=theNewPwdTextField.text;
         }
//         object[@"logoURL"]=user.logoURL;
         [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
          {
              PFQuery *query=[PFQuery queryWithClassName:@"User"];
              appDelegate.user=[[User alloc]initWithPFObject:[query getObjectWithId:appDelegate.user.userID]];
              [progressHUD removeFromSuperview];
              UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Congratulations"
                                                           message:@"Profile is updated!"
                                                          delegate:self
                                                 cancelButtonTitle:nil
                                                 otherButtonTitles:@"Confirm", nil];
              [alert show];
          }];
     }];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex!=alertView.cancelButtonIndex)
    {
        appDelegate.refreshMessageList=true;
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(inputError==TextInputErrorNickname)
    {
        [nicknameTextField becomeFirstResponder];
    }
    else if(inputError==TextInputErrorOriginalPassword)
    {
        [theOriginalPwdTextField becomeFirstResponder];
    }
    else if(inputError==TextInputErrorNewPassword)
    {
        [theNewPwdTextField becomeFirstResponder];
    }
    else if(inputError==TextInputErrorConfirmPassword)
    {
        [theConfirmPwdTextField becomeFirstResponder];
    }
}

@end
