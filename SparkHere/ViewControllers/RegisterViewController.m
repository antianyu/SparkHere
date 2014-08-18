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

@synthesize usernameLabel;
@synthesize usernameTextField;
@synthesize passwordLabel;
@synthesize passwordTextField;
@synthesize confirmPwdLabel;
@synthesize confirmPwdTextField;
@synthesize nicknameLabel;
@synthesize nicknameTextField;
@synthesize logoImageView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"Register";
    
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    progressHUD=[[MBProgressHUD alloc] initWithView:self.view];
    progressHUD.dimBackground = NO;
    progressHUD.userInteractionEnabled=NO;
    progressHUD.labelText = @"Please wait...";
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:appDelegate.backgroundImage]];
    
    UIBarButtonItem *doneButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonClicked)];
    self.navigationItem.rightBarButtonItem=doneButtonItem;
    
    usernameLabel.textColor=appDelegate.majorColor;
    passwordLabel.textColor=appDelegate.majorColor;
    confirmPwdLabel.textColor=appDelegate.majorColor;
    nicknameLabel.textColor=appDelegate.majorColor;
    
    [appDelegate setDefaultViewStyle:usernameTextField];
    [appDelegate setDefaultViewStyle:passwordTextField];
    [appDelegate setDefaultViewStyle:confirmPwdTextField];
    [appDelegate setDefaultViewStyle:nicknameTextField];
    
    logoImageView.userInteractionEnabled=YES;
    UITapGestureRecognizer *singleTap=[[UITapGestureRecognizer alloc]initWithTarget:self
                                                                             action:@selector(chooseLogo)];
    [logoImageView addGestureRecognizer:singleTap];
    
    [usernameTextField becomeFirstResponder];
    
    user=nil;
    
    inputError=TextInputErrorNone;
    operation=UIAlertViewOperationNone;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [progressHUD removeFromSuperview];
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
    [self resumeView];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length>15 && ![string isEqualToString:@""])
    {
        return NO;
    }
    
    return YES;
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSTimeInterval animationDuration=0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    float width=self.view.frame.size.width;
    float height=self.view.frame.size.height;
    
    if (textField==passwordTextField)
    {
        CGRect rect=CGRectMake(0, -18, width, height);
        self.view.frame=rect;
    }
    else if (textField==confirmPwdTextField)
    {
        CGRect rect=CGRectMake(0, -85, width, height);
        self.view.frame=rect;
    }
    else if (textField==nicknameTextField)
    {
        CGRect rect=CGRectMake(0, -152, width, height);
        self.view.frame=rect;
    }
    
    [UIView commitAnimations];
    
    return YES;
}

- (void)resumeView
{
    NSTimeInterval animationDuration=0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    float width=self.view.frame.size.width;
    float height=self.view.frame.size.height;
    
    CGRect rect=CGRectMake(0, 64, width, height);
    self.view.frame=rect;
    [UIView commitAnimations];
}

- (void)chooseLogo
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    [self resumeView];
    operation=UIAlertViewOperationChooseImage;
    inputError=TextInputErrorNone;
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Choose Logo"
                                                 message:@"Please select a way to choose logo"
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                       otherButtonTitles:@"From albums", @"From camera", nil];
    [alert show];
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
    else if (confirmPwdTextField.text.length==0)
    {
        inputError=TextInputErrorConfirmPassword;
        [appDelegate showUIAlertViewWithTitle:@"Error" message:@"Please confirm password!" delegate:self];
    }
    else if (nicknameTextField.text.length==0)
    {
        inputError=TextInputErrorNickname;
        [appDelegate showUIAlertViewWithTitle:@"Error" message:@"Nickname can't be empty!" delegate:self];
    }
    else if (![passwordTextField.text isEqual:confirmPwdTextField.text])
    {
        inputError=TextInputErrorConfirmPassword;
        [appDelegate showUIAlertViewWithTitle:@"Error" message:@"The passwords you typed do not match!" delegate:self];
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
             [appDelegate showUIAlertViewWithTitle:@"Error" message:@"Username already exists!" delegate:self];
         }
         else if(!error && objects.count==0)
         {
             [query whereKey:@"nickname" equalTo:user.nickname];
             [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
              {
                  if (!error && objects.count>0)
                  {
                      [progressHUD removeFromSuperview];
                      [appDelegate showUIAlertViewWithTitle:@"Error" message:@"Nickname already exists!" delegate:self];
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
                               operation=UIAlertViewOperationRegister;
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
                               [appDelegate showUIAlertViewWithTitle:@"Woops!" message:@"Register failed! Something wrong with server!" delegate:self];
                           }
                       }];
                  }
                  else
                  {
                      [progressHUD removeFromSuperview];
                      [appDelegate showUIAlertViewWithTitle:@"Error" message:@"Query error!" delegate:self];                  }
              }];
         }
         else
         {
             [progressHUD removeFromSuperview];
             [appDelegate showUIAlertViewWithTitle:@"Error" message:@"Query error!" delegate:self];
         }
     }];
}

- (void)showRegisterWaitingView
{
    [[UIApplication sharedApplication].keyWindow addSubview:progressHUD];
    [progressHUD showAnimated:YES whileExecutingBlock:^
     {
         [self registerRequest];
     }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex!=alertView.cancelButtonIndex)
    {
        if (operation==UIAlertViewOperationRegister)
        {
            appDelegate.refreshMessageList=NO;
            appDelegate.refreshMyChannelList=NO;
            MainViewController *controller=[[MainViewController alloc]init];
            controller.selectedIndex=2;
            [controller setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
            [self presentViewController:controller animated:YES completion:nil];
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
                    [appDelegate showUIAlertViewWithTitle:@"Error" message:@"Image picker is not supported on your phone!" delegate:self];
                }
            }
            else
            {
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                {
                    ImagePickerViewController *controller=[[ImagePickerViewController alloc]init];
                    controller.delegate=self;
                    controller.allowsEditing=YES;
                    controller.sourceType=UIImagePickerControllerSourceTypeCamera;
                    controller.mediaTypes=[[NSArray alloc]initWithObjects:(NSString *)kUTTypeImage, nil];
                    [self.navigationController presentViewController:controller animated:YES completion:nil];
                }
                else
                {
                    [appDelegate showUIAlertViewWithTitle:@"Error" message:@"Camera is not supported on your phone!" delegate:self];
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
