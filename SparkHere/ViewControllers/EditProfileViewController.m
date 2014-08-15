//
//  EditProfileViewController.m
//  SparkHere
//
//  Created by Tianyu An on 14-7-24.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <Parse/Parse.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "EditProfileViewController.h"
#import "ImagePickerViewController.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "User.h"
#import "TextInputError.h"
#import "UIAlertViewOperation.h"

@interface EditProfileViewController ()

@end

@implementation EditProfileViewController
{
    AppDelegate *appDelegate;
    MBProgressHUD *progressHUD;
    UIAlertViewOperation operation;
    TextInputError inputError;
}

@synthesize nicknameTextField;
@synthesize theOriginalPwdTextField;
@synthesize theNewPwdTextField;
@synthesize theConfirmPwdTextField;
@synthesize chooseLogoButton;
@synthesize logoImageView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"Edit Profile";
    
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    progressHUD=[[MBProgressHUD alloc] initWithView:self.view];
    progressHUD.dimBackground = NO;
    progressHUD.userInteractionEnabled=NO;
    progressHUD.labelText = @"Please wait...";
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:appDelegate.backgroundImage]];
    
    UIBarButtonItem *saveButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonClicked)];
    self.navigationItem.rightBarButtonItem=saveButtonItem;
    
    [nicknameTextField becomeFirstResponder];
    
    [appDelegate setDefaultViewStyle:nicknameTextField];
    [appDelegate setDefaultViewStyle:theOriginalPwdTextField];
    [appDelegate setDefaultViewStyle:theNewPwdTextField];
    [appDelegate setDefaultViewStyle:theConfirmPwdTextField];
    [appDelegate setDefaultViewStyle:chooseLogoButton];
    
    nicknameTextField.text=appDelegate.user.nickname;
    if (appDelegate.user.logo!=nil)
    {
        logoImageView.image=appDelegate.user.logo;
    }
    else
    {
        logoImageView.image=[UIImage imageNamed:@"Default_Logo.png"];        
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [progressHUD removeFromSuperview];
}

- (IBAction)viewTouchDown:(id)sender
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (void)saveButtonClicked
{
    [self editProfileRequest];
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
        [appDelegate showUIAlertViewWithTitle:@"Error" message:@"Nickname can't be empty!" delegate:self];
    }
    else if ([appDelegate.user.nickname isEqualToString:nicknameTextField.text] && [self isPasswordPartEmpty]
             && [logoImageView.image isEqual:appDelegate.user.logo])
    {
        inputError=TextInputErrorNickname;
        [appDelegate showUIAlertViewWithTitle:@"Error" message:@"Nothing changed!" delegate:self];
    }
    else if ((![appDelegate.user.nickname isEqualToString:nicknameTextField.text] ||
             ![logoImageView.image isEqual:appDelegate.user.logo])
             && ([self isPasswordPartEmpty] || [self isPasswordPartValid]))
    {
        [self showEditProfileWaitingView];
    }
}

- (void)showEditProfileWaitingView
{
    [[UIApplication sharedApplication].keyWindow addSubview:progressHUD];
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
         NSData *logoData=UIImageJPEGRepresentation(logoImageView.image, 1);
         PFFile *logo=[PFFile fileWithName:@"logo.jpg" data:logoData];
         object[@"logo"]=logo;
         
         [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
          {
              PFQuery *query=[PFQuery queryWithClassName:@"User"];
              [appDelegate setCurrentUser:[query getObjectWithId:appDelegate.user.userID]];
              [progressHUD removeFromSuperview];
              appDelegate.refreshMessageList=YES;
              [appDelegate showUIAlertViewWithTitle:@"Congratulations" message:@"Profile is updated!" delegate:nil];
          }];
     }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex!=alertView.cancelButtonIndex)
    {
        if (operation==UIAlertViewOperationChooseImage)
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

- (BOOL)isPasswordPartEmpty
{
    if (theOriginalPwdTextField.text.length==0 && theNewPwdTextField.text.length==0 &&
        theConfirmPwdTextField.text.length==0)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)isPasswordPartValid
{
    BOOL result=NO;
    
    if (theOriginalPwdTextField.text.length==0)
    {
        inputError=TextInputErrorOriginalPassword;
        [appDelegate showUIAlertViewWithTitle:@"Error" message:@"Original password can't be empty!" delegate:self];
    }
    else if (theNewPwdTextField.text.length==0)
    {
        inputError=TextInputErrorNewPassword;
        [appDelegate showUIAlertViewWithTitle:@"Error" message:@"New password can't be empty!" delegate:self];
    }
    else if (theConfirmPwdTextField.text.length==0)
    {
        inputError=TextInputErrorConfirmPassword;
        [appDelegate showUIAlertViewWithTitle:@"Error" message:@"Please confirm password!" delegate:self];
    }
    else if (![theNewPwdTextField.text isEqual:theConfirmPwdTextField.text])
    {
        inputError=TextInputErrorConfirmPassword;
        [appDelegate showUIAlertViewWithTitle:@"Error" message:@"The passwords you typed do not match!" delegate:self];
    }
    else if (![appDelegate.user.userPassword isEqualToString:theOriginalPwdTextField.text])
    {
        inputError=TextInputErrorOriginalPassword;
        [appDelegate showUIAlertViewWithTitle:@"Error" message:@"Invalid original password!" delegate:self];
    }
    else
    {
        result=YES;
    }
    return result;
}

@end
