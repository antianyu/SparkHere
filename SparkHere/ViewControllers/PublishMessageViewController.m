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

@interface PublishMessageViewController ()

@end

@implementation PublishMessageViewController
{
    AppDelegate *appDelegate;
    MBProgressHUD *progressHUD;
    TextInputError inputError;
    CAShapeLayer *shapeLayer;
}

@synthesize contentLabel;
@synthesize contentTextView;
@synthesize contentImageView;
@synthesize scrollView;
@synthesize toolbar;
@synthesize channel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"New Message";
    
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    progressHUD=[[MBProgressHUD alloc] initWithView:self.view];
    progressHUD.dimBackground = NO;
    progressHUD.userInteractionEnabled=NO;
    progressHUD.labelText = @"Please wait...";
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:appDelegate.backgroundImage]];
    
    UIBarButtonItem *pubishButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Send"
                                                                       style:UIBarButtonItemStyleDone
                                                                      target:self
                                                                      action:@selector(pubishButtonClicked)];
    self.navigationItem.rightBarButtonItem=pubishButtonItem;
    
    UIToolbar *keyBoardToolBar=[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    
    UIBarButtonItem *albumButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"Album"
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(albumButtonClicked:)];
    
    UIBarButtonItem *cameraButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                                                   target:self
                                                                                   action:@selector(cameraButtonClicked:)];
    
    UIBarButtonItem *spaceButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                  target:nil
                                                                                  action:nil];
    
    UIBarButtonItem *hideButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"Hide Keyboard"
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(viewTouchDown:)];
    
    [keyBoardToolBar setItems:[NSArray arrayWithObjects:albumButtonItem, cameraButtonItem, spaceButtonItem, hideButtonItem, nil]];
    
    contentTextView.tintColor=appDelegate.majorColor;
    contentTextView.textColor=appDelegate.majorColor;
    contentTextView.backgroundColor=[UIColor clearColor];
    contentTextView.inputAccessoryView=keyBoardToolBar;
    
    contentImageView.userInteractionEnabled=YES;
    UITapGestureRecognizer *singleTap=[[UITapGestureRecognizer alloc]initWithTarget:self
                                                                             action:@selector(imageViewTapped)];
    [contentImageView addGestureRecognizer:singleTap];
    [self drawBorderOfImageView];
    
    inputError=TextInputErrorNone;
    
    [contentTextView becomeFirstResponder];
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

- (void)pubishButtonClicked
{
    if (contentTextView.text.length==0 && contentImageView.image==nil)
    {
        inputError=TextInputErrorMessageContent;
        [appDelegate showUIAlertViewWithTitle:@"Error!" message:@"Please write something or choose a picture!" delegate:self];
    }
    else
    {
        [appDelegate getLocation];
        [self publishMessage];
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
        [appDelegate showUIAlertViewWithTitle:@"Error!" message:@"Image picker is not supported on your phone!" delegate:nil];
    }
}

- (IBAction)cameraButtonClicked:(id)sender
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
        [appDelegate showUIAlertViewWithTitle:@"Error!" message:@"Camera is not supported on your phone!" delegate:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image=[info objectForKey:@"UIImagePickerControllerEditedImage"];
    CGRect rect=contentImageView.frame;
    rect.size.height=IMAGE_WIDTH*image.size.height/image.size.width;
    contentImageView.frame=rect;
    contentImageView.image=image;
    
    scrollView.contentSize=CGSizeMake(contentImageView.frame.size.width, contentImageView.frame.size.height+145);
    [shapeLayer removeFromSuperlayer];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(inputError==TextInputErrorMessageContent)
    {
        inputError=TextInputErrorNone;
        [contentTextView becomeFirstResponder];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    contentLabel.hidden=YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView.text.length==0)
    {
        contentLabel.hidden=NO;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView.text.length>499 && text.length>0)
    {
        return NO;
    }
    
    return YES;
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
    shapeLayer.strokeColor=appDelegate.majorColor.CGColor;
    shapeLayer.lineWidth=2;
    shapeLayer.lineCap=kCALineCapSquare;
    shapeLayer.lineDashPattern=[NSArray arrayWithObjects:[NSNumber numberWithInt:5], [NSNumber numberWithInt:5],nil];
    
    [scrollView.layer addSublayer:shapeLayer];
}

- (void)publishMessage
{
    [[UIApplication sharedApplication].keyWindow addSubview:progressHUD];
    [progressHUD showAnimated:YES whileExecutingBlock:^
     {
         int count=0;
         while (appDelegate.currentLocation==nil && count<30)
         {
             [NSThread sleepForTimeInterval:1];
             count++;
             NSLog(@"count:%d",count);
         }
         if (count==REQUEST_TIMEOUT)
         {
             [progressHUD removeFromSuperview];
             [appDelegate showUIAlertViewWithTitle:@"Woops!" message:@"Publish message failed! Can't locate your position!" delegate:nil];
             return;
         }

         PFObject *newMessage=[PFObject objectWithClassName:@"Message"];
         newMessage[@"channelID"]=channel.channelID;
         newMessage[@"senderID"]=appDelegate.user.userID;
         newMessage[@"content"]=contentTextView.text;
         newMessage[@"location"]=appDelegate.currentLocation;
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
                  [self pushMessage];
                  [progressHUD removeFromSuperview];
                  [appDelegate showUIAlertViewWithTitle:@"Congratulations!" message:@"Publish message succeed!" delegate:nil];
                  appDelegate.loadMoreMessages=YES;
                  appDelegate.refreshPostsList=YES;
                  [self.navigationController popViewControllerAnimated:YES];
              }
              else
              {
                  [progressHUD removeFromSuperview];
                  inputError=TextInputErrorNone;
                  [appDelegate showUIAlertViewWithTitle:@"Woops!" message:@"Publish message failed! Something wrong with server!" delegate:nil];
              }
          }];
     }];
}

- (void)pushMessage
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // construct push content
        NSString *pushContent=contentTextView.text;
        if (pushContent==nil)
        {
            pushContent=@"You have received an image. ";
        }
        pushContent=[pushContent stringByAppendingString:[NSString stringWithFormat:@"(via %@)", channel.channelName]];
        
        // get every subscriber
        PFQuery *subscriptionQuery=[PFQuery queryWithClassName:@"Subscription"];
        [subscriptionQuery whereKey:@"channelID" equalTo:channel.channelID];
        NSArray *result=[subscriptionQuery findObjects];
        
        // check if every subscriber is valid for push
        NSMutableArray *subQueries=[[NSMutableArray alloc]init];
        for (PFObject *object in result)
        {
            PFQuery *query=[PFInstallation query];
            [query whereKey:@"currentUserID" equalTo:object[@"userID"]];
            [subQueries addObject:query];
        }
        
        PFQuery *pushQuery=[PFQuery orQueryWithSubqueries:subQueries];
        [pushQuery whereKey:@"currentUserID" notEqualTo:appDelegate.user.userID];
        [pushQuery whereKey:@"currentLocation" nearGeoPoint:appDelegate.currentLocation withinKilometers:MESSAGE_RANGE];
        [pushQuery whereKey:@"receiveMessage" equalTo:[NSNumber numberWithBool:YES]];
        
        // set alert and badge
        NSDictionary *data=[NSDictionary dictionaryWithObjectsAndKeys:
                            pushContent, @"alert",
                            @"Increment", @"badge", nil];
        
        // send push
        PFPush *push=[[PFPush alloc]init];
        [push setQuery:pushQuery];
        [push setData:data];
        [push sendPushInBackground];
    });
}

@end
