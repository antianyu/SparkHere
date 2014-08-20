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
#import "ChangePasswordViewController.h"
#import "ImagePickerViewController.h"
#import "CustomisedTableViewCell.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "TextInputError.h"

@interface EditProfileViewController ()

@end

@implementation EditProfileViewController
{
    AppDelegate *appDelegate;
    MBProgressHUD *progressHUD;
    TextInputError inputError;
}

@synthesize logoImageView;
@synthesize editImageView;
@synthesize logoImageViewContainer;
@synthesize nicknameLabel;
@synthesize nicknameTextField;
@synthesize changePwdTableView;

#pragma mark View
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
    
    // init logoImageView
    [appDelegate setImageViewStyle:logoImageView container:logoImageViewContainer borderWidth:3 shadowOffset:3];
    
    logoImageView.userInteractionEnabled=YES;
    UITapGestureRecognizer *singleTap=[[UITapGestureRecognizer alloc]initWithTarget:self
                                                                             action:@selector(chooseLogo)];
    [logoImageView addGestureRecognizer:singleTap];
    
    editImageView.userInteractionEnabled=YES;
    UITapGestureRecognizer *editTap=[[UITapGestureRecognizer alloc]initWithTarget:self
                                                                           action:@selector(chooseLogo)];
    [editImageView addGestureRecognizer:editTap];
    
    if (appDelegate.user.logo!=nil)
    {
        logoImageView.image=appDelegate.user.logo;
    }
    else
    {
        logoImageView.image=[UIImage imageNamed:@"Default_Logo.png"];
    }
    
    // init nicknameTextField
    nicknameLabel.textColor=[UIColor lightGrayColor];
    nicknameLabel.hidden=YES;
    
    [appDelegate setTextFieldStyle:nicknameTextField];
    nicknameTextField.text=appDelegate.user.nickname;
    
    // init changePwdTableView
    [changePwdTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
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
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    [self editProfileRequest];
}

#pragma mark UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *customisedCellIdentifier = @"CustomisedCellIdentifier";
    static BOOL nibsRegistered=NO;
    if (!nibsRegistered)
    {
        UINib *nib=[UINib nibWithNibName:@"CustomisedTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:customisedCellIdentifier];
        nibsRegistered=YES;
    }
    
    CustomisedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:customisedCellIdentifier];
    if (cell == nil)
    {
        cell=[[[NSBundle mainBundle]loadNibNamed:@"CustomisedTableViewCell" owner:nil options:nil] lastObject];
    }
    
    cell.logoImageView.image=[UIImage imageNamed:@"Password.png"];
    cell.titleLabel.text=@"Change My Password";
    cell.detailLabel.text=nil;
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ChangePasswordViewController *controller=[[ChangePasswordViewController alloc]init];
    
    self.hidesBottomBarWhenPushed=YES;
    
    UIBarButtonItem *backButton=[[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem=backButton;
    
    [self.navigationController pushViewController:controller animated:YES];
}

# pragma mark UITextField
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField==nicknameTextField)
    {
        nicknameLabel.hidden=YES;
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField==nicknameTextField && textField.text.length==0)
    {
        nicknameLabel.hidden=NO;
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
    if (nicknameTextField.text.length>0)
    {
        [self editProfileRequest];
    }
    
    return NO;
}

#pragma mark Other Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex!=alertView.cancelButtonIndex)
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
                [appDelegate showUIAlertViewWithTitle:@"Error!" message:@"Image picker is not supported on your phone!" delegate:self];
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
                [appDelegate showUIAlertViewWithTitle:@"Error!" message:@"Camera is not supported on your phone!" delegate:self];
            }
        }
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

#pragma mark Auxiliaries
- (void)chooseLogo
{
    
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil
                                                 message:@"Please select a way to choose logo"
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                       otherButtonTitles:@"From albums", @"From camera", nil];
    [alert show];
}

- (void)editProfileRequest
{
    if (nicknameTextField.text.length==0)
    {
        inputError=TextInputErrorNickname;
        [appDelegate showUIAlertViewWithTitle:@"Error!" message:@"Nickname can't be empty!" delegate:self];
    }
    else if ([appDelegate.user.nickname isEqualToString:nicknameTextField.text]
             && [logoImageView.image isEqual:appDelegate.user.logo])
    {
        inputError=TextInputErrorNone;
        [appDelegate showUIAlertViewWithTitle:@"Woops" message:@"Nothing changed!" delegate:self];
    }
    else
    {
        [self showEditProfileWaitingView];
    }
}

- (void)showEditProfileWaitingView
{
    [[UIApplication sharedApplication].keyWindow addSubview:progressHUD];
    [progressHUD showAnimated:YES whileExecutingBlock:^
     {
         PFObject *object=[appDelegate.user getPFObject];
         object[@"nickname"]=nicknameTextField.text;
         if (logoImageView.image!=appDelegate.user.logo)
         {
             NSData *logoData=UIImageJPEGRepresentation(logoImageView.image, 1);
             PFFile *logo=[PFFile fileWithName:@"logo.jpg" data:logoData];
             object[@"logo"]=logo;
         }
         
         [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
          {
              PFQuery *query=[PFQuery queryWithClassName:@"User"];
              [appDelegate setCurrentUser:[query getObjectWithId:appDelegate.user.userID]];
              [progressHUD removeFromSuperview];
              appDelegate.refreshMessageList=YES;
              appDelegate.refreshPostsList=YES;
              [appDelegate showUIAlertViewWithTitle:@"Congratulations" message:@"Profile is updated!" delegate:nil];
          }];
     }];
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
