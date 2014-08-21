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
#import "CustomisedTableViewCell.h"
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

@synthesize logoImageView;
@synthesize editImageView;
@synthesize logoImageViewContainer;
@synthesize channelNameLabel;
@synthesize channelNameTextField;
@synthesize categoryTableView;
@synthesize privilegeSegmentedControl;
@synthesize descriptionLabel;
@synthesize descriptionTextView;
@synthesize backgroundImageView;
@synthesize channel;
@synthesize editChannel;

#pragma mark View
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (editChannel)
    {
        self.title=@"Edit Channel";
    }
    else
    {
        self.title=@"New Channel";
    }
    
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    progressHUD=[[MBProgressHUD alloc] initWithView:self.view];
    progressHUD.dimBackground = NO;
    progressHUD.userInteractionEnabled=NO;
    progressHUD.labelText = @"Please wait...";
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:appDelegate.backgroundImage]];
    
    UIBarButtonItem *establishButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonClicked)];
    self.navigationItem.rightBarButtonItem=establishButtonItem;
    
    NSString *plistPath=[[NSBundle mainBundle] pathForResource:@"Category" ofType:@"plist"];
    categoryList=[[NSArray alloc]initWithContentsOfFile:plistPath];
    
    [appDelegate setTextFieldStyle:channelNameTextField];
    [appDelegate setTextViewStyle:descriptionTextView];
    
    categoryTableView.separatorStyle=NO;
    categoryTableView.scrollEnabled=NO;
    
    privilegeSegmentedControl.tintColor=appDelegate.majorColor;
    
    [appDelegate setImageViewStyle:logoImageView container:logoImageViewContainer borderWidth:2.5 shadowOffset:3];
    
    logoImageView.userInteractionEnabled=YES;
    UITapGestureRecognizer *singleTap=[[UITapGestureRecognizer alloc]initWithTarget:self
                                                                             action:@selector(chooseLogo)];
    [logoImageView addGestureRecognizer:singleTap];
    
    editImageView.userInteractionEnabled=YES;
    UITapGestureRecognizer *editTap=[[UITapGestureRecognizer alloc]initWithTarget:self
                                                                           action:@selector(chooseLogo)];
    [editImageView addGestureRecognizer:editTap];
    
    logoImageView.image=[UIImage imageNamed:@"Default_Logo.png"];
    
    if (appDelegate.is4Inch)
    {
        backgroundImageView.image=[UIImage imageNamed:@"Channel_TextView_4.png"];
    }
    else
    {
        backgroundImageView.image=[UIImage imageNamed:@"Channel_TextView_3.5.png"];
    }
    
    channelNameLabel.textColor=[UIColor lightGrayColor];
    descriptionLabel.textColor=[UIColor lightGrayColor];
    
    if (editChannel)
    {
        channelNameLabel.hidden=YES;
        channelNameTextField.text=channel.channelName;
        privilegeSegmentedControl.selectedSegmentIndex=channel.defaultPrivilege-1;
        descriptionLabel.hidden=YES;
        descriptionTextView.text=channel.description;
        if (channel.logo!=nil)
        {
            logoImageView.image=channel.logo;
        }
    }
    inputError=TextInputErrorNone;
    operation=UIAlertViewOperationNone;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [progressHUD removeFromSuperview];
}

- (IBAction)viewTouchDown:(id)sender
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    [self resumeView];
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
        [appDelegate showUIAlertViewWithTitle:@"Tips!" message:tip delegate:self];
    }
    else if([sender selectedSegmentIndex]==1)
    {
        NSString *tip= @"New users are allowed to:\n1. Receive messages\n2. Send messages";
        [appDelegate showUIAlertViewWithTitle:@"Tips!" message:tip delegate:self];
    }
    else
    {
        NSString *tip= @"New users are allowed to:\n1. Receive messages\n2. Send messages\n3. Administrate channel";
        [appDelegate showUIAlertViewWithTitle:@"Tips!" message:tip delegate:self];
    }
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
    
    cell.logoImageView.image=[UIImage imageNamed:@"Category.png"];
    cell.titleLabel.text=@"Category";
    if (channel!=nil)
    {
        cell.detailLabel.text=[categoryList objectAtIndex:channel.category];
    }
    else
    {
        cell.detailLabel.text=[categoryList objectAtIndex:0];
    }
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
    
    ChooseCategoryViewController *controller=[[ChooseCategoryViewController alloc]init];
    controller.category=channel.category;
    controller.delegate=self;
    
    self.hidesBottomBarWhenPushed=YES;
    
    UIBarButtonItem *backButton=[[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem=backButton;
    
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark UITextField
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField==channelNameTextField)
    {
        channelNameLabel.hidden=YES;
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField==channelNameTextField && textField.text.length==0)
    {
        channelNameLabel.hidden=NO;
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
    
    return NO;
}

#pragma mark UITextView
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    descriptionLabel.hidden=YES;
    
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

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (textView.text.length==0)
    {
        descriptionLabel.hidden=NO;
    }
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView.text.length>499 && text.length>0)
    {
        return NO;
    }
    
    return YES;
}

#pragma mark UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex!=alertView.cancelButtonIndex)
    {
        if (operation==UIAlertViewOperationChooseImage)
        {
            operation=UIAlertViewOperationNone;
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

#pragma mark Auxiliaries
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
    operation=UIAlertViewOperationChooseImage;
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil
                                                 message:@"Please select a way to choose logo"
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                       otherButtonTitles:@"From albums", @"From camera", nil];
    [alert show];
}

- (void)constructChannel
{
    if (channelNameTextField.text.length==0)
    {
        inputError=TextInputErrorChannelName;
        [appDelegate showUIAlertViewWithTitle:@"Error!" message:@"The name of channel can't be empty!" delegate:self];
    }
    else if (descriptionTextView.text.length==0)
    {
        inputError=TextInputErrorDescription;
        [appDelegate showUIAlertViewWithTitle:@"Error!" message:@"Description can't be empty!" delegate:self];
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
                 [appDelegate showUIAlertViewWithTitle:@"Congratulations"
                                               message:@"Channel is updated!"
                                              delegate:nil];
                 [self requestSucceed];
             }
             else
             {
                 [progressHUD removeFromSuperview];
                 [appDelegate showUIAlertViewWithTitle:@"Woops!" message:@"Update failed! Something wrong with server!" delegate:self];
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
                 [appDelegate showUIAlertViewWithTitle:@"Error!" message:@"Channel already exists!" delegate:self];
             }
             else
             {
                 newChannel.objectId=channel.channelID;
                 [newChannel saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                  {
                      if (!error)
                      {
                          [progressHUD removeFromSuperview];
                          [appDelegate showUIAlertViewWithTitle:@"Congratulations!"
                                                        message:@"Channel is updated!"
                                                       delegate:nil];
                          [self requestSucceed];
                      }
                      else
                      {
                          [progressHUD removeFromSuperview];
                          [appDelegate showUIAlertViewWithTitle:@"Woops!"
                                                        message:@"Update failed! Something wrong with server!"
                                                       delegate:self];
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
             [appDelegate showUIAlertViewWithTitle:@"Error!" message:@"Channel already exists!" delegate:self];
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
                               [appDelegate showUIAlertViewWithTitle:@"Congratulations"
                                                             message:@"Establish succeed!"
                                                            delegate:nil];
                               [self requestSucceed];
                           }
                           else
                           {
                               [progressHUD removeFromSuperview];
                               [appDelegate showUIAlertViewWithTitle:@"Woops!" message:@"Subscribe failed! Something wrong with server!" delegate:self];
                           }
                       }];
                  }
                  else
                  {
                      [progressHUD removeFromSuperview];
                      [appDelegate showUIAlertViewWithTitle:@"Woops!" message:@"Establish failed! Something wrong with server!" delegate:self];
                  }
              }];
         }
     }];
}

- (void)showEditWaitingView
{
    [[UIApplication sharedApplication].keyWindow addSubview:progressHUD];
    [progressHUD showAnimated:YES whileExecutingBlock:^
     {
         [self editRequest];
     }];
}

- (void)showEstablishWaitingView
{
    [[UIApplication sharedApplication].keyWindow addSubview:progressHUD];
    [progressHUD showAnimated:YES whileExecutingBlock:^
     {
         [self establishRequest];
     }];
}

- (void)passIntDelegate:(int)value
{
    channel.category=value;
    [categoryTableView reloadData];
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

- (void)requestSucceed
{
    if (!editChannel)
    {
        appDelegate.refreshMyChannelList=YES;
    }
    else if (editChannel && ![channel.channelName isEqualToString:newChannel[@"channelName"]])
    {
        appDelegate.refreshMessageList=YES;
        appDelegate.refreshMyChannelList=YES;
    }
    appDelegate.refreshChannelDetail=YES;
    [self.navigationController popViewControllerAnimated:YES];
}

@end

