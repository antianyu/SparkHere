//
//  PublishMessageViewController.m
//  SparkHere
//
//  Created by Tianyu An on 14-7-25.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <Parse/Parse.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "PublishMessageViewController.h"
#import "ImagePickerViewController.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "TextInputError.h"

@implementation CLLocationManager (TemporaryHack)

- (void)hackLocationFix
{
    CLLocation *location=[[CLLocation alloc]initWithLatitude:51.47431 longitude:-0.184063];
    [[self delegate] locationManager:self didUpdateLocations:[NSArray arrayWithObject:location]];
}

- (void)startUpdatingLocation
{
    [self performSelector:@selector(hackLocationFix) withObject:nil afterDelay:0.1];
}

@end

@interface PublishMessageViewController ()

@end

@implementation PublishMessageViewController
{
    AppDelegate *appDelegate;
    MBProgressHUD *progressHUD;
    TextInputError inputError;
    CAShapeLayer *shapeLayer;
    CLLocationManager *locationManager;
}

@synthesize contentTextView;
@synthesize contentImageView;
@synthesize scrollView;
@synthesize toolbar;
@synthesize channel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"New Message";
    
    appDelegate=[[UIApplication sharedApplication] delegate];
    progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:appDelegate.backgroundImage]];
    
    UIBarButtonItem *pubishButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pubishButtonClicked)];
    self.navigationItem.rightBarButtonItem=pubishButtonItem;
    
    [contentTextView becomeFirstResponder];
    
    [appDelegate setDefaultViewStyle:contentTextView];
    
    contentImageView.userInteractionEnabled=YES;
    UITapGestureRecognizer *singleTap=[[UITapGestureRecognizer alloc]initWithTarget:self
                                                                             action:@selector(imageViewTapped)];
    [contentImageView addGestureRecognizer:singleTap];
    [self drawBorderOfImageView];
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
        if ([CLLocationManager locationServicesEnabled])
        {
            if (locationManager==nil)
            {
                locationManager=[[CLLocationManager alloc]init];
                locationManager.delegate=self;
                locationManager.desiredAccuracy=kCLLocationAccuracyNearestTenMeters;
            }
            [locationManager startUpdatingLocation];
        }
        else
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                         message:@"Location service is not available. Please turn it on."
                                                        delegate:self
                                               cancelButtonTitle:@"Confirm"
                                               otherButtonTitles:nil];
            [alert show];
            return;
        }
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
    
    scrollView.contentSize=CGSizeMake(contentImageView.frame.size.width, contentImageView.frame.size.height+145);
    [shapeLayer removeFromSuperlayer];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex!=alertView.cancelButtonIndex)
    {
        appDelegate.loadMoreMessages=true;
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(inputError==TextInputErrorMessageContent)
    {
        [contentTextView becomeFirstResponder];
    }
}

- (void)imageViewTapped
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (void)drawBorderOfImageView
{
    CGRect frame=contentImageView.frame;
    frame.origin.y=72.5;
    if (appDelegate.is4Inch)
    {
        frame.size.height=275;
    }
    else
    {
        frame.size.height=187;
    }
    
    shapeLayer=[CAShapeLayer layer];
    
    CGMutablePathRef path=CGPathCreateMutable();
    
    CGPathMoveToPoint(path, nil, CGRectGetMinX(frame), CGRectGetMaxY(frame));
    CGPathAddLineToPoint(path, nil, CGRectGetMaxX(frame), CGRectGetMaxY(frame));
    CGPathAddLineToPoint(path, nil, CGRectGetMaxX(frame), CGRectGetMinY(frame));
    CGPathAddLineToPoint(path, nil, CGRectGetMinX(frame), CGRectGetMinY(frame));
    CGPathAddLineToPoint(path, nil, CGRectGetMinX(frame), CGRectGetMaxY(frame));
    
    shapeLayer.path=path;
    CGPathRelease(path);
    
    shapeLayer.frame=frame;
    shapeLayer.masksToBounds=NO;
    shapeLayer.backgroundColor=[UIColor clearColor].CGColor;
    shapeLayer.fillColor=[UIColor clearColor].CGColor;
    shapeLayer.strokeColor=[UIColor whiteColor].CGColor;
    shapeLayer.lineWidth=2;
    shapeLayer.lineCap=kCALineCapSquare;
    shapeLayer.lineDashPattern=[NSArray arrayWithObjects:[NSNumber numberWithInt:5], [NSNumber numberWithInt:5],nil];
    
    [scrollView.layer addSublayer:shapeLayer];
}

- (void)publishMessageWithLocation:(PFGeoPoint *)currentLocation
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
         newMessage[@"location"]=currentLocation;
         if (contentImageView.image!=nil)
         {
             NSData *imageData=UIImageJPEGRepresentation(contentImageView.image, 1);
             PFFile *image=[PFFile fileWithName:@"image.jpg" data:imageData];
             newMessage[@"image"]=image;
         }
         
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

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                 message:@"Location failed. Please try again."
                                                delegate:self
                                       cancelButtonTitle:@"Confirm"
                                       otherButtonTitles:nil];
    [alert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self publishMessageWithLocation:[PFGeoPoint geoPointWithLocation:[locations lastObject]]];
}

@end
