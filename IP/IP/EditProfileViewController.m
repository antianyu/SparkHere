//
//  EditProfileViewController.m
//  IP
//
//  Created by Tianyu An on 14-7-24.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "EditProfileViewController.h"
#import "ImagePickerViewController.h"
#import "User.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import <Parse/Parse.h>
#import "UIAlertViewOperation.h"
#import "TextInputError.h"
#import <MobileCoreServices/UTCoreTypes.h>

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
    
    appDelegate=[[UIApplication sharedApplication] delegate];
    progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    
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
    else if ([appDelegate.user.nickname isEqualToString:nicknameTextField.text] && [self isPasswordPartEmpty]
             && [logoImageView.image isEqual:appDelegate.user.logo])
    {
        inputError=TextInputErrorNickname;
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                     message:@"Nothing changed!"
                                                    delegate:self
                                           cancelButtonTitle:@"Confirm"
                                           otherButtonTitles:nil];
        [alert show];
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
         NSData *logoData=UIImageJPEGRepresentation(logoImageView.image, 1);
         PFFile *logo=[PFFile fileWithName:@"logo.jpg" data:logoData];
         object[@"logo"]=logo;
         
         [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
          {
              PFQuery *query=[PFQuery queryWithClassName:@"User"];
              appDelegate.user=[[User alloc]initWithPFObject:[query getObjectWithId:appDelegate.user.userID]];
              [appDelegate.settings saveDefaultUser:appDelegate.user];
              [progressHUD removeFromSuperview];
              operation=UIAlertViewOperationDone;
              UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Congratulations"
                                                           message:@"Profile is updated!"
                                                          delegate:self
                                                 cancelButtonTitle:nil
                                                 otherButtonTitles:@"Confirm", nil];
              [alert show];
          }];
     }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex!=alertView.cancelButtonIndex)
    {
        if (operation==UIAlertViewOperationDone)
        {
            appDelegate.refreshMessageList=true;
            [self.navigationController popViewControllerAnimated:YES];
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
        return true;
    }
    else
    {
        return false;
    }
}

- (BOOL)isPasswordPartValid
{
    BOOL result=false;
    
    if (theOriginalPwdTextField.text.length==0)
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
    else
    {
        result=true;
    }
    return result;
}

@end
