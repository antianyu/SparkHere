//
//  EditChannelViewController.m
//  SparkHere
//
//  Created by Tianyu An on 14-7-14.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <Parse/Parse.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "EditChannelViewController.h"
#import "ChooseCategoryViewController.h"
#import "ImagePickerViewController.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "TextInputError.h"
#import "UIAlertViewOperation.h"

@interface EditChannelViewController ()

@end

@implementation EditChannelViewController
{
    AppDelegate *appDelegate;
    MBProgressHUD *progressHUD;
    UIAlertViewOperation operation;
    TextInputError inputError;
    PFObject *newChannel;
    NSArray *categoryList;
}

@synthesize channelNameTextField;
@synthesize privilegeSegmentedControl;
@synthesize categoryButton;
@synthesize chooseLogoButton;
@synthesize logoImageView;
@synthesize descriptionTextView;
@synthesize channel;
@synthesize editChannel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"Establish new channel";
    
    appDelegate=[[UIApplication sharedApplication] delegate];
    progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:appDelegate.backgroundImage]];
    
    UIBarButtonItem *establishButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonClicked)];
    self.navigationItem.rightBarButtonItem=establishButtonItem;
    
    NSString *detailString=@"Lorem ipsum dolor sit er elit lametm";
    
    descriptionTextView.text=detailString;
    
    NSString *plistPath=[[NSBundle mainBundle] pathForResource:@"Category" ofType:@"plist"];
    categoryList=[[NSArray alloc]initWithContentsOfFile:plistPath];
    
    [channelNameTextField becomeFirstResponder];
    
    [appDelegate setDefaultViewStyle:channelNameTextField];
    [appDelegate setDefaultViewStyle:descriptionTextView];
    [appDelegate setDefaultViewStyle:categoryButton];
    [appDelegate setDefaultViewStyle:chooseLogoButton];
    
    categoryButton.titleLabel.textAlignment=NSTextAlignmentCenter;
    [categoryButton setTitle:[categoryList objectAtIndex:0] forState:UIControlStateNormal];
    
    logoImageView.image=[UIImage imageNamed:@"Default_Logo.png"];
    
    if (editChannel)
    {
        channelNameTextField.text=channel.channelName;
        privilegeSegmentedControl.selectedSegmentIndex=channel.defaultPrivilege-1;
        [categoryButton setTitle:[categoryList objectAtIndex:channel.category] forState:UIControlStateNormal];
        descriptionTextView.text=channel.description;
        if (channel.logo!=nil)
        {
            logoImageView.image=channel.logo;
        }
    }
}

- (IBAction)viewTouchDown:(id)sender
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (void)doneButtonClicked
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    [self constructChannel];
    if (newChannel!=nil)
    {
        if (editChannel)
        {
            [self showEditWaitingView];
        }
        else
        {
            [self showEstablishWaitingView];
        }
    }
}

- (IBAction)segmentControlValueChanged:(id)sender
{
    inputError=TextInputErrorNone;
    if([sender selectedSegmentIndex]==0)
    {
        NSString *tip= @"New users are allowed to:\n1. Receive messages";
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tips"
                                                     message:tip
                                                    delegate:self
                                           cancelButtonTitle:@"Confirm"
                                           otherButtonTitles:nil];
        [alert show];
    }
    else if([sender selectedSegmentIndex]==1)
    {
        NSString *tip= @"New users are allowed to:\n1. Receive messages\n2. Send messages";
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tips"
                                                     message:tip
                                                    delegate:self
                                           cancelButtonTitle:@"Confirm"
                                           otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        NSString *tip= @"New users are allowed to:\n1. Receive messages\n2. Send messages\n3. Administrate channel";
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Tips"
                                                     message:tip
                                                    delegate:self
                                           cancelButtonTitle:@"Confirm"
                                           otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)categoryButtonClicked:(id)sender
{
    ChooseCategoryViewController *controller=[[ChooseCategoryViewController alloc]init];
    controller.category=channel.category;
    controller.delegate=self;
    
    self.hidesBottomBarWhenPushed=YES;
    
    UIBarButtonItem *backButton=[[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem=backButton;
    
    [self.navigationController pushViewController:controller animated:YES];    
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
    if (channelNameTextField.text.length>0 && descriptionTextView.text.length>0)
    {
        [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
        [self constructChannel];
        if (newChannel!=nil)
        {
            if (editChannel)
            {
                [self showEditWaitingView];
            }
            else
            {
                [self showEstablishWaitingView];
            }
        }
    }
    else if (textField==channelNameTextField)
    {
        [descriptionTextView becomeFirstResponder];
    }
    else // textField==descriptionTextView
    {
        [channelNameTextField becomeFirstResponder];
    }
    return NO;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    NSTimeInterval animationDuration=0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    float width=self.view.frame.size.width;
    float height=self.view.frame.size.height;
    
    CGRect rect=CGRectMake(0, -150, width, height);
    self.view.frame=rect;
    [UIView commitAnimations];
    
    return YES;
}

- (IBAction)textViewDidEndEditing:(UITextView *)textView
{
    [self.descriptionTextView resignFirstResponder];
    [self resumeView];
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex!=alertView.cancelButtonIndex)
    {
        if (operation==UIAlertViewOperationDone)
        {
            if (!editChannel)
            {
                appDelegate.refreshMyChannelList=true;
            }
            else if (editChannel && ![channel.channelName isEqualToString:newChannel[@"channelName"]])
            {
                appDelegate.refreshMessageList=true;
                appDelegate.refreshMyChannelList=true;
            }
            appDelegate.refreshChannelDetail=true;
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
    else if(inputError==TextInputErrorChannelName)
    {
        [channelNameTextField becomeFirstResponder];
    }
    else if(inputError==TextInputErrorDescription)
    {
        [descriptionTextView becomeFirstResponder];
    }
}

- (void)constructChannel
{
    if (channelNameTextField.text.length==0)
    {
        inputError=TextInputErrorChannelName;
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                     message:@"The name of channel can't be empty!"
                                                    delegate:self
                                           cancelButtonTitle:@"Confirm"
                                           otherButtonTitles:nil];
        [alert show];
    }
    else if (descriptionTextView.text.length==0)
    {
        inputError=TextInputErrorDescription;
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                     message:@"Description can't be empty!"
                                                    delegate:self
                                           cancelButtonTitle:@"Confirm"
                                           otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        newChannel=[PFObject objectWithClassName:@"Channel"];
        newChannel[@"channelName"]=channelNameTextField.text;
        newChannel[@"description"]=descriptionTextView.text;
        if (!editChannel)
        {
            newChannel[@"followersNumber"]=[NSNumber numberWithInt:1];
        }
        else
        {
            newChannel[@"followersNumber"]=[NSNumber numberWithInt:channel.followersNumber];
        }
        newChannel[@"defaultPrivilege"]=[NSNumber numberWithInt:privilegeSegmentedControl.selectedSegmentIndex+1];
        newChannel[@"category"]=[NSNumber numberWithInt:channel.category];
        NSData *logoData=UIImageJPEGRepresentation(logoImageView.image, 1);
        PFFile *logo=[PFFile fileWithName:@"logo.jpg" data:logoData];
        newChannel[@"logo"]=logo;
    }
}

- (void)editRequest
{
    if ([newChannel[@"channelName"] isEqualToString:channel.channelName])
    {
        newChannel.objectId=channel.channelID;
        [newChannel saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (!error)
             {
                 [progressHUD removeFromSuperview];
                 operation=UIAlertViewOperationDone;
                 UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Congratulations"
                                                              message:@"Channel is updated!"
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                                    otherButtonTitles:@"Confirm", nil];
                 [alert show];
             }
             else
             {
                 [progressHUD removeFromSuperview];
                 UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Woops!"
                                                              message:@"Update failed! Something wrong with server!"
                                                             delegate:self
                                                    cancelButtonTitle:@"Confirm"
                                                    otherButtonTitles:nil];
                 [alert show];
             }
         }];
    }
    else
    {
        PFQuery *query=[PFQuery queryWithClassName:@"Channel"];
        [query whereKey:@"channelName" equalTo:newChannel[@"channelName"]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (objects.count>0)
             {
                 [progressHUD removeFromSuperview];
                 UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                              message:@"Channel already exists!"
                                                             delegate:self
                                                    cancelButtonTitle:@"Confirm"
                                                    otherButtonTitles:nil];
                 [alert show];
             }
             else
             {
                 newChannel.objectId=channel.channelID;
                 [newChannel saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                  {
                      if (!error)
                      {
                          [progressHUD removeFromSuperview];
                          appDelegate.refreshChannelDetail=true;
                          operation=UIAlertViewOperationDone;
                          UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Congratulations"
                                                                       message:@"Channel is updated!"
                                                                      delegate:self
                                                             cancelButtonTitle:nil
                                                             otherButtonTitles:@"Confirm", nil];
                          [alert show];
                      }
                      else
                      {
                          [progressHUD removeFromSuperview];
                          UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Woops!"
                                                                       message:@"Update failed! Something wrong with server!"
                                                                      delegate:self
                                                             cancelButtonTitle:@"Confirm"
                                                             otherButtonTitles:nil];
                          [alert show];
                      }
                  }];
             }
         }];
    }
}

- (void)establishRequest
{
    PFQuery *query=[PFQuery queryWithClassName:@"Channel"];
    [query whereKey:@"channelName" equalTo:newChannel[@"channelName"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (objects.count>0)
         {
             [progressHUD removeFromSuperview];
             UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                          message:@"Channel already exists!"
                                                         delegate:self
                                                cancelButtonTitle:@"Confirm"
                                                otherButtonTitles:nil];
             [alert show];
         }
         else
         {
             [newChannel saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
              {
                  if (!error)
                  {
                      PFQuery *query=[PFQuery queryWithClassName:@"Channel"];
                      [query whereKey:@"channelName" equalTo:newChannel[@"channelName"]];
                      PFObject *result=[query getFirstObject];
                      PFObject *newSubscription=[PFObject objectWithClassName:@"Subscription"];
                      newSubscription[@"channelID"]=result.objectId;
                      newSubscription[@"userID"]=appDelegate.user.userID;
                      newSubscription[@"privilege"]=[NSNumber numberWithInt:4];
                      [newSubscription saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                       {
                           if (!error)
                           {
                               [progressHUD removeFromSuperview];
                               UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Congratulations"
                                                                            message:@"Establish succeed!"
                                                                           delegate:self
                                                                  cancelButtonTitle:nil
                                                                  otherButtonTitles:@"Confirm", nil];
                               [alert show];
                           }
                           else
                           {
                               [progressHUD removeFromSuperview];
                               UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Woops!"
                                                                            message:@"Subscribe failed! Something wrong with server!"
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
                      UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Woops!"
                                                                   message:@"Establish failed! Something wrong with server!"
                                                                  delegate:self
                                                         cancelButtonTitle:@"Confirm"
                                                         otherButtonTitles:nil];
                      [alert show];
                  }
              }];
         }
     }];
}

- (void)showEditWaitingView
{
    [[UIApplication sharedApplication].keyWindow addSubview:progressHUD];
    progressHUD.dimBackground = YES;
    progressHUD.labelText = @"Please wait...";
    [progressHUD showAnimated:YES whileExecutingBlock:^
     {
         [self editRequest];
     }];
}

- (void)showEstablishWaitingView
{
    [[UIApplication sharedApplication].keyWindow addSubview:progressHUD];
    progressHUD.dimBackground = YES;
    progressHUD.labelText = @"Please wait...";
    [progressHUD showAnimated:YES whileExecutingBlock:^
     {
         [self establishRequest];
     }];
}

- (void)passIntDelegate:(int)value
{
    [categoryButton setTitle:[categoryList objectAtIndex:value] forState:UIControlStateNormal];
    channel.category=value;
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
