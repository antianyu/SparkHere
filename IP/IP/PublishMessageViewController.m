//
//  PublishMessageViewController.m
//  IP
//
//  Created by Tianyu An on 14-7-25.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "PublishMessageViewController.h"
#import "ImagePickerViewController.h"
#import "Settings.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import <Parse/Parse.h>
#import "TextInputError.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface PublishMessageViewController ()

@end

@implementation PublishMessageViewController
{
    Settings *settings;
    AppDelegate *appDelegate;
    MBProgressHUD *progressHUD;
    TextInputError inputError;
}

@synthesize contentTextView;
@synthesize contentImageView;
@synthesize scrollView;
@synthesize toolbar;
@synthesize channel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"Edit Profile";
    
    UIBarButtonItem *pubishButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pubishButtonClicked)];
    self.navigationItem.rightBarButtonItem=pubishButtonItem;
    
    settings=[[Settings alloc]init];
    
    if (settings.is4Inch)
    {
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Background_4.png"]]];
    }
    else
    {
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Background_3.5.png"]]];
    }
    
    [toolbar setBackgroundImage:[UIImage imageNamed:@"Toolbar.png"]
             forToolbarPosition:UIBarPositionAny
                     barMetrics:UIBarMetricsDefault];
    
    appDelegate=[[UIApplication sharedApplication]delegate];
    progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    
    [contentTextView becomeFirstResponder];
    
    [appDelegate setDefaultViewStyle:contentTextView];
    
    [scrollView setHidden:YES];
}

- (IBAction)viewTouchDown:(id)sender
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (void)pubishButtonClicked
{
    if (contentTextView.text.length==0 && contentImageView.image==nil)
    {
        inputError=TextInputErrorMessageContent;
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error!"
                                                     message:@"Please write something or choose a picture!"
                                                    delegate:self
                                           cancelButtonTitle:@"Confirm"
                                           otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        [[UIApplication sharedApplication].keyWindow addSubview:progressHUD];
        progressHUD.dimBackground = YES;
        progressHUD.labelText = @"Please wait...";
        [progressHUD showAnimated:YES whileExecutingBlock:^
         {
             PFObject *newMessage=[PFObject objectWithClassName:@"Message"];
             newMessage[@"channelID"]=channel.channelID;
             newMessage[@"senderID"]=appDelegate.user.userID;
             newMessage[@"content"]=contentTextView.text;
             NSData *imageData=UIImageJPEGRepresentation(contentImageView.image, 1);
             PFFile *image=[PFFile fileWithName:@"image.jpg" data:imageData];
             newMessage[@"image"]=image;

             [newMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
              {
                  if (!error)
                  {
                      [progressHUD removeFromSuperview];
                      UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Congratulations!"
                                                                   message:@"Publish message succeed!"
                                                                  delegate:self
                                                         cancelButtonTitle:nil
                                                         otherButtonTitles:@"Confirm", nil];
                      [alert show];
                      appDelegate.refreshMessageList=true;
                  }
                  else
                  {
                      [progressHUD removeFromSuperview];
                      inputError=TextInputErrorNone;
                      UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Woops!"
                                                                   message:@"Publish message failed! Something wrong with server!"
                                                                  delegate:self
                                                         cancelButtonTitle:@"Confirm"
                                                         otherButtonTitles:nil];
                      [alert show];
                  }
              }];
         }];
    }
}

- (IBAction)albumButtonClicked:(id)sender
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
        inputError=TextInputErrorNone;
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                     message:@"Image picker is not supported on your phone!"
                                                    delegate:self
                                           cancelButtonTitle:@"Confirm"
                                           otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)cameraButtonClicked:(id)sender
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
        inputError=TextInputErrorNone;
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                     message:@"Camera is not supported on your phone!"
                                                    delegate:self
                                           cancelButtonTitle:@"Confirm"
                                           otherButtonTitles:nil];
        [alert show];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image=[info objectForKey:@"UIImagePickerControllerEditedImage"];
    CGRect rect=contentImageView.frame;
    rect.size.height=280*image.size.height/image.size.width;
    contentImageView.frame=rect;
    contentImageView.image=image;
    
    scrollView.contentSize=CGSizeMake(contentImageView.frame.size.width, contentImageView.frame.size.height);
    scrollView.hidden=NO;
    if (contentImageView.frame.size.height<=scrollView.frame.size.height)
    {
        [scrollView setScrollEnabled:NO];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex!=alertView.cancelButtonIndex)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(inputError==TextInputErrorMessageContent)
    {
        [contentTextView becomeFirstResponder];
    }
}

@end
