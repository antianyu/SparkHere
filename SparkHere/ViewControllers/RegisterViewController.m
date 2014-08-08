//
//  RegisterViewController.m
//  SparkHere
//
//  Created by Tianyu An on 14-6-20.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <Parse/Parse.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "RegisterViewController.h"
#import "MainViewController.h"
#import "ImagePickerViewController.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "User.h"
#import "UIAlertViewOperation.h"
#import "TextInputError.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController
{
    AppDelegate *appDelegate;
    MBProgressHUD *progressHUD;
    UIAlertViewOperation operation;
    User *user;
    TextInputError inputError;
}

@synthesize usernameTextField;
@synthesize passwordTextField;
@synthesize confirmPwdTextField;
@synthesize nicknameTextField;
@synthesize chooseLogoButton;
@synthesize logoImageView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"Register";
    
    appDelegate=[[UIApplication sharedApplication] delegate];
    progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:appDelegate.backgroundImage]];
    
    UIBarButtonItem *doneButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonClicked)];
    self.navigationItem.rightBarButtonItem=doneButtonItem;
    
    [appDelegate setDefaultViewStyle:usernameTextField];
    [appDelegate setDefaultViewStyle:passwordTextField];
    [appDelegate setDefaultViewStyle:confirmPwdTextField];
    [appDelegate setDefaultViewStyle:nicknameTextField];
    [appDelegate setDefaultViewStyle:chooseLogoButton];
    
    [usernameTextField becomeFirstResponder];
    
    user=nil;
}

- (void)doneButtonClicked
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

- (IBAction)chooseLogoButtonClicked:(id)sender
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    operation=UIAlertViewOperationChooseImage;
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Choose Logo"
                                                 message:@"Please select a way to choose logo"
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                       otherButtonTitles:@"From albums", @"From camera", nil];
    [alert show];
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
        inputError=TextInputErrorUserName;
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                     message:@"Username can't be empty!"
                                                    delegate:self
                                           cancelButtonTitle:@"Confirm"
                                           otherButtonTitles:nil];
        [alert show];
    }
    else if (passwordTextField.text.length==0)
    {
        inputError=TextInputErrorPassword;
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                     message:@"Password can't be empty!"
                                                    delegate:self
                                           cancelButtonTitle:@"Confirm"
                                           otherButtonTitles:nil];
        [alert show];
    }
    else if (confirmPwdTextField.text.length==0)
    {
        inputError=TextInputErrorConfirmPassword;
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                     message:@"Please confirm password!"
                                                    delegate:self
                                           cancelButtonTitle:@"Confirm"
                                           otherButtonTitles:nil];
        [alert show];
    }
    else if (nicknameTextField.text.length==0)
    {
        inputError=TextInputErrorNickname;
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                     message:@"Nickname can't be empty!"
                                                    delegate:self
                                           cancelButtonTitle:@"Confirm"
                                           otherButtonTitles:nil];
        [alert show];
    }
    else if (![passwordTextField.text isEqual:confirmPwdTextField.text])
    {
        inputError=TextInputErrorConfirmPassword;
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                     message:@"The passwords you typed do not match!"
                                                    delegate:self
                                           cancelButtonTitle:@"Confirm"
                                           otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        user=[[User alloc]init:usernameTextField.text
                  userPassword:passwordTextField.text
                      nickname:nicknameTextField.text
                        userID:nil
                          logo:logoImageView.image];
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
                      NSData *logoData=UIImageJPEGRepresentation(user.logo, 1);
                      PFFile *logo=[PFFile fileWithName:@"logo.jpg" data:logoData];
                      newUser[@"logo"]=logo;
                      [newUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                       {
                           if (!error)
                           {
                               PFQuery *userQuery=[PFQuery queryWithClassName:@"User"];
                               [userQuery whereKey:@"username" equalTo:user.username];
                               [userQuery whereKey:@"password" equalTo:user.userPassword];
                               [appDelegate setCurrentUser:[query getFirstObject]];
                               [progressHUD removeFromSuperview];
                               operation=UIAlertViewOperationChooseRegister;
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex!=alertView.cancelButtonIndex)
    {
        if (operation==UIAlertViewOperationChooseRegister)
        {
            appDelegate.refreshMessageList=false;
            appDelegate.refreshMyChannelList=false;
            MainViewController *controller=[[MainViewController alloc]init];
            controller.selectedIndex=2;
            [controller setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
            [self presentViewController:controller animated:YES completion:^{nil;}];
        }
        else
        {
            if (buttonIndex==1)
            {
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
                {
                    ImagePickerViewController *controller=[[ImagePickerViewController alloc]init];
                    controller.delegate=self;
                    controller.allowsEditing=YES;
                    controller.mediaTypes=[[NSArray alloc]initWithObjects:(NSString *)kUTTypeImage, nil];
                    [self.navigationController presentViewController:controller animated:YES completion:nil];
                }
                else
                {
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                                 message:@"Image picker is not supported on your phone!"
                                                                delegate:self
                                                       cancelButtonTitle:@"Confirm"
                                                       otherButtonTitles:nil];
                    [alert show];
                }
            }
            else
            {
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                {
                    ImagePickerViewController *controller=[[ImagePickerViewController alloc]init];
                    controller.delegate=self;
                    controller.allowsEditing=YES;
                    controller.mediaTypes=[[NSArray alloc]initWithObjects:(NSString *)kUTTypeImage, nil];
                    [self.navigationController presentViewController:controller animated:YES completion:nil];
                }
                else
                {
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                                 message:@"Camera is not supported on your phone!"
                                                                delegate:self
                                                       cancelButtonTitle:@"Confirm"
                                                       otherButtonTitles:nil];
                    [alert show];
                }
            }
        }
    }
    else if(inputError==TextInputErrorUserName)
    {
        [usernameTextField becomeFirstResponder];
    }
    else if(inputError==TextInputErrorPassword)
    {
        [passwordTextField becomeFirstResponder];
    }
    else if(inputError==TextInputErrorConfirmPassword)
    {
        [confirmPwdTextField becomeFirstResponder];
    }
    else if(inputError==TextInputErrorNickname)
    {
        [nicknameTextField becomeFirstResponder];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image=[info objectForKey:@"UIImagePickerControllerEditedImage"];
    image=[self scaleToSize:image size:CGSizeMake(100, 100)];
    logoImageView.image=image;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage *)scaleToSize:(UIImage *)image size:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

@end
