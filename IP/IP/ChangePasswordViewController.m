//
//  ChangePasswordViewController.m
//  IP
//
//  Created by Tianyu An on 14-6-21.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "Settings.h"
#import "User.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import <Parse/Parse.h>

@interface ChangePasswordViewController ()

@end

@implementation ChangePasswordViewController
{
    Settings *settings;
    AppDelegate *appDelegate;
    MBProgressHUD *progressHUD;
    int inputError;
}

@synthesize theOriginalPwdTextField;
@synthesize theNewPwdTextField;
@synthesize theConfirmPwdTextField;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"Change Password";
    
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
    
    [theOriginalPwdTextField becomeFirstResponder];
    
    theOriginalPwdTextField.backgroundColor=[UIColor clearColor];
    theOriginalPwdTextField.layer.borderColor=[[UIColor whiteColor]CGColor];
    theOriginalPwdTextField.layer.borderWidth=1.5;
    theOriginalPwdTextField.layer.cornerRadius=5;
    
    theNewPwdTextField.backgroundColor=[UIColor clearColor];
    theNewPwdTextField.layer.borderColor=[[UIColor whiteColor]CGColor];
    theNewPwdTextField.layer.borderWidth=1.5;
    theNewPwdTextField.layer.cornerRadius=5;
    
    theConfirmPwdTextField.backgroundColor=[UIColor clearColor];
    theConfirmPwdTextField.layer.borderColor=[[UIColor whiteColor]CGColor];
    theConfirmPwdTextField.layer.borderWidth=1.5;
    theConfirmPwdTextField.layer.cornerRadius=5;
    
    appDelegate=[[UIApplication sharedApplication]delegate];
    progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
}

- (void)saveButtonClicked
{
    [self changePasswordRequest];
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
        [self changePasswordRequest];
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

- (void)changePasswordRequest
{
    if (theOriginalPwdTextField.text.length==0)
    {
        inputError=0;
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                     message:@"Original password can't be empty!"
                                                    delegate:self
                                           cancelButtonTitle:@"Confirm"
                                           otherButtonTitles:nil];
        [alert show];
    }
    else if (theNewPwdTextField.text.length==0)
    {
        inputError=1;
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                     message:@"New password can't be empty!"
                                                    delegate:self
                                           cancelButtonTitle:@"Confirm"
                                           otherButtonTitles:nil];
        [alert show];
    }
    else if (theConfirmPwdTextField.text.length==0)
    {
        inputError=2;
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                     message:@"Please confirm password!"
                                                    delegate:self
                                           cancelButtonTitle:@"Confirm"
                                           otherButtonTitles:nil];
        [alert show];
    }
    else if (![theNewPwdTextField.text isEqual:theConfirmPwdTextField.text])
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
        if (![appDelegate.user.userPassword isEqualToString:theOriginalPwdTextField.text])
        {
            inputError=0;
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                         message:@"Invalid original password!"
                                                        delegate:self
                                               cancelButtonTitle:@"Confirm"
                                               otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            [self showChangePwdWaitingView];
        }
    }
}

- (void)showChangePwdWaitingView
{
    [[UIApplication sharedApplication].keyWindow addSubview:progressHUD];
    progressHUD.dimBackground = YES;
    progressHUD.labelText = @"Please wait...";
    [progressHUD showAnimated:YES whileExecutingBlock:^
     {
         PFObject *object=[PFObject objectWithClassName:@"User"];
         object.objectId=appDelegate.user.userID;
         object[@"username"]=appDelegate.user.username;
         object[@"password"]=theNewPwdTextField.text;
         object[@"nickname"]=appDelegate.user.nickname;
//            object[@"logoURL"]=user.logoURL;
         [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
          {
              PFQuery *query=[PFQuery queryWithClassName:@"User"];
              appDelegate.user=[[User alloc]initWithPFObject:[query getObjectWithId:appDelegate.user.userID]];
              [progressHUD removeFromSuperview];
              UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Congratulations"
                                                           message:@"The password has been changed!"
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
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(inputError==0)
    {
        [theOriginalPwdTextField becomeFirstResponder];
    }
    else if(inputError==1)
    {
        [theNewPwdTextField becomeFirstResponder];
    }
    else if(inputError==2)
    {
        [theConfirmPwdTextField becomeFirstResponder];
    }

}

@end
