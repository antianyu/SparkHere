//
//  ChangePasswordViewController.m
//  SparkHere
//
//  Created by Tianyu An on 14-8-19.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "TextInputError.h"

@interface ChangePasswordViewController ()

@end

@implementation ChangePasswordViewController
{
    AppDelegate *appDelegate;
    MBProgressHUD *progressHUD;
    TextInputError inputError;
}

@synthesize theOldPwdLabel;
@synthesize theOldPwdTextField;
@synthesize theNewPwdLabel;
@synthesize theNewPwdTextField;
@synthesize theConfirmPwdLabel;
@synthesize theConfirmPwdTextField;

#pragma mark View
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"Change Password";
    
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    progressHUD=[[MBProgressHUD alloc] initWithView:self.view];
    progressHUD.dimBackground = NO;
    progressHUD.userInteractionEnabled=NO;
    progressHUD.labelText = @"Please wait...";
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:appDelegate.backgroundImage]];
    
    UIBarButtonItem *saveButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonClicked)];
    self.navigationItem.rightBarButtonItem=saveButtonItem;
    
    [appDelegate setTextFieldStyle:theOldPwdTextField];
    [appDelegate setTextFieldStyle:theNewPwdTextField];
    [appDelegate setTextFieldStyle:theConfirmPwdTextField];    
}

- (void)saveButtonClicked
{
    [self savePasswordRequest];
}

#pragma mark UITextField
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField==theOldPwdTextField)
    {
        theOldPwdLabel.hidden=YES;
    }
    else if (textField==theNewPwdTextField)
    {
        theNewPwdLabel.hidden=YES;
    }
    else if (textField==theConfirmPwdTextField)
    {
        theConfirmPwdLabel.hidden=YES;
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField==theOldPwdTextField && textField.text.length==0)
    {
        theOldPwdLabel.hidden=NO;
    }
    else if (textField==theNewPwdTextField && textField.text.length==0)
    {
        theNewPwdLabel.hidden=NO;
    }
    else if (textField==theConfirmPwdTextField && textField.text.length==0)
    {
        theConfirmPwdLabel.hidden=NO;
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
    if (theOldPwdTextField.text.length>0 && theNewPwdTextField.text.length>0 && theConfirmPwdTextField.text.length>0)
    {
        [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
        [self savePasswordRequest];
    }
    else if (textField==theOldPwdTextField)
    {
        [theNewPwdTextField becomeFirstResponder];
    }
    else if (textField==theNewPwdTextField)
    {
        [theConfirmPwdTextField becomeFirstResponder];
    }
    else // textField==theConfirmPwdTextField
    {
        [theOldPwdTextField becomeFirstResponder];
    }
    
    return NO;
}

#pragma mark Other Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex!=alertView.cancelButtonIndex)
    {

    }
    else if(inputError==TextInputErrorOldPassword)
    {
        [theOldPwdTextField becomeFirstResponder];
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

#pragma mark Auxiliaries
- (void)savePasswordRequest
{
    if ([self isPasswordPartValid])
    {
        [[UIApplication sharedApplication].keyWindow addSubview:progressHUD];
        [progressHUD showAnimated:YES whileExecutingBlock:^
         {
             // construct new object of user
             PFObject *object=[appDelegate.user getPFObject];
             object[@"password"]=theNewPwdTextField.text;
             
             // save to table
             [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
              {
                  if (!error)
                  {
                      [progressHUD removeFromSuperview];
                      [appDelegate setCurrentUser:object];
                      [appDelegate showUIAlertViewWithTitle:@"Congratulations" message:@"Password has been changed!" delegate:nil];
                  }
                  else
                  {
                      [progressHUD removeFromSuperview];
                      [appDelegate showUIAlertViewWithTitle:@"Woops!" message:@"Change failed! Something wrong with server!" delegate:nil];
                  }
              }];
         }];
    }
}

- (BOOL)isPasswordPartValid
{
    BOOL result=NO;
    
    if (theOldPwdTextField.text.length==0)
    {
        inputError=TextInputErrorOldPassword;
        [appDelegate showUIAlertViewWithTitle:@"Error!" message:@"Old password can't be empty!" delegate:self];
    }
    else if (theNewPwdTextField.text.length==0)
    {
        inputError=TextInputErrorNewPassword;
        [appDelegate showUIAlertViewWithTitle:@"Error!" message:@"New password can't be empty!" delegate:self];
    }
    else if (theConfirmPwdTextField.text.length==0)
    {
        inputError=TextInputErrorConfirmPassword;
        [appDelegate showUIAlertViewWithTitle:@"Error!" message:@"Please confirm password!" delegate:self];
    }
    else if (![theNewPwdTextField.text isEqual:theConfirmPwdTextField.text])
    {
        inputError=TextInputErrorConfirmPassword;
        [appDelegate showUIAlertViewWithTitle:@"Error!" message:@"The passwords you typed do not match!" delegate:self];
    }
    else if (![appDelegate.user.userPassword isEqualToString:theOldPwdTextField.text])
    {
        inputError=TextInputErrorOldPassword;
        [appDelegate showUIAlertViewWithTitle:@"Error!" message:@"Invalid old password!" delegate:self];
    }
    else
    {
        result=YES;
    }
    
    return result;
}

@end