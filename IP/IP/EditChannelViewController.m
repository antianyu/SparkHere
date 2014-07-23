//
//  EditChannelViewController.m
//  IP
//
//  Created by Tianyu An on 14-7-14.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "EditChannelViewController.h"
#import "ChooseCategoryViewController.h"
#import "Settings.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import <Parse/Parse.h>

@interface EditChannelViewController ()

@end

@implementation EditChannelViewController
{
    Settings *settings;
    PFObject *newChannel;
    AppDelegate *appDelegate;
    MBProgressHUD *progressHUD;
    int inputError;
    NSArray *categoryList;
}

@synthesize channelNameTextField;
@synthesize privilegeSegmentedControl;
@synthesize longitudeTextField;
@synthesize latitudeTextField;
@synthesize rangeTextField;
@synthesize categoryButton;
@synthesize descriptionTextView;
@synthesize channel;
@synthesize editChannel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    settings=[[Settings alloc]init];
    
    if (settings.is4Inch)
    {
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Background_4.png"]]];
    }
    else
    {
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Background_3.5.png"]]];
    }
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    self.title=@"Establish new channel";
    self.navigationController.navigationBar.translucent=NO;
    
    UIBarButtonItem *establishButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonClicked)];
    self.navigationItem.rightBarButtonItem=establishButtonItem;
    
    NSString *detailString=@"Lorem ipsum dolor sit er elit lametm";
    
    descriptionTextView.text=detailString;
    
    [channelNameTextField becomeFirstResponder];
    
    channelNameTextField.backgroundColor=[UIColor clearColor];
    channelNameTextField.layer.borderColor=[[UIColor whiteColor]CGColor];
    channelNameTextField.layer.borderWidth=1.5;
    channelNameTextField.layer.cornerRadius=5;
    
    latitudeTextField.backgroundColor=[UIColor clearColor];
    latitudeTextField.layer.borderColor=[[UIColor whiteColor]CGColor];
    latitudeTextField.layer.borderWidth=1.5;
    latitudeTextField.layer.cornerRadius=5;
    
    longitudeTextField.backgroundColor=[UIColor clearColor];
    longitudeTextField.layer.borderColor=[[UIColor whiteColor]CGColor];
    longitudeTextField.layer.borderWidth=1.5;
    longitudeTextField.layer.cornerRadius=5;
    
    rangeTextField.backgroundColor=[UIColor clearColor];
    rangeTextField.layer.borderColor=[[UIColor whiteColor]CGColor];
    rangeTextField.layer.borderWidth=1.5;
    rangeTextField.layer.cornerRadius=5;
    
    descriptionTextView.backgroundColor=[UIColor clearColor];
    descriptionTextView.layer.borderColor=[[UIColor whiteColor]CGColor];
    descriptionTextView.layer.borderWidth=1.5;
    descriptionTextView.layer.cornerRadius=5;
    descriptionTextView.tintColor=[UIColor whiteColor];
    
    categoryButton.titleLabel.textAlignment=NSTextAlignmentCenter;
    categoryButton.titleLabel.text=[categoryList objectAtIndex:0];
    
    appDelegate=[[UIApplication sharedApplication]delegate];
    progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    
    NSString *plistPath=[[NSBundle mainBundle] pathForResource:@"Category" ofType:@"plist"];
    categoryList=[[NSArray alloc]initWithContentsOfFile:plistPath];
    
    if (editChannel)
    {
        channelNameTextField.text=channel.channelName;
        privilegeSegmentedControl.selectedSegmentIndex=channel.defaultPrivilege-1;
        latitudeTextField.text=[NSString stringWithFormat:@"%f", channel.location.latitude];
        longitudeTextField.text=[NSString stringWithFormat:@"%f", channel.location.longitude];
        rangeTextField.text=[NSString stringWithFormat:@"%f", channel.range];
        categoryButton.titleLabel.text=[categoryList objectAtIndex:channel.category];
        descriptionTextView.text=channel.description;
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
    inputError=-1;
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField==longitudeTextField || textField==latitudeTextField || textField==rangeTextField)
    {
        NSCharacterSet *characterSet=[[NSCharacterSet characterSetWithCharactersInString:@"-.1234567890"]invertedSet];
        NSString *filteredResult=[[string componentsSeparatedByCharactersInSet:characterSet] componentsJoinedByString:@""];
        if (![string isEqualToString:filteredResult])
        {
            return NO;
        }
        
        static BOOL containsDecPoint;
        if ([textField.text rangeOfString:@"."].location==NSNotFound)
        {
            containsDecPoint=NO;
        }
        if (string.length>0)
        {
            unichar single=[string characterAtIndex:0];
            if(textField.text.length==0)
            {
                if (single=='.')
                {
                    return NO;
                }
            }
            else
            {
                if(single=='.')
                {
                    if (!containsDecPoint)
                    {
                        containsDecPoint=YES;
                    }
                    else
                    {
                        return NO;
                    }
                }
                if(single=='-')
                {
                    return NO;
                }
            }
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (channelNameTextField.text.length>0 && longitudeTextField.text.length>0 &&
        latitudeTextField.text.length>0 && rangeTextField.text.length>0 && descriptionTextView.text.length>0)
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
        [latitudeTextField becomeFirstResponder];
    }
    else if (textField==latitudeTextField)
    {
        [longitudeTextField becomeFirstResponder];
    }
    else if (textField==longitudeTextField)
    {
        [rangeTextField becomeFirstResponder];
    }
    else if (textField==rangeTextField)
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

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex!=alertView.cancelButtonIndex)
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
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(inputError==0)
    {
        [channelNameTextField becomeFirstResponder];
    }
    else if(inputError==1)
    {
        [latitudeTextField becomeFirstResponder];
    }
    else if(inputError==2)
    {
        [longitudeTextField becomeFirstResponder];
    }
    else if(inputError==3)
    {
        [rangeTextField becomeFirstResponder];
    }
    else if(inputError==4)
    {
        [descriptionTextView becomeFirstResponder];
    }
}

- (void)constructChannel
{
    if (channelNameTextField.text.length==0)
    {
        inputError=0;
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                     message:@"The name of channel can't be empty!"
                                                    delegate:self
                                           cancelButtonTitle:@"Confirm"
                                           otherButtonTitles:nil];
        [alert show];
    }
    else if (latitudeTextField.text.length==0)
    {
        inputError=1;
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                     message:@"Latitude can't be empty!"
                                                    delegate:self
                                           cancelButtonTitle:@"Confirm"
                                           otherButtonTitles:nil];
        [alert show];
    }
    else if (longitudeTextField.text.length==0)
    {
        inputError=2;
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                     message:@"Longitude can't be empty!"
                                                    delegate:self
                                           cancelButtonTitle:@"Confirm"
                                           otherButtonTitles:nil];
        [alert show];
    }
    else if (rangeTextField.text.length==0)
    {
        inputError=3;
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                     message:@"Range can't be empty!"
                                                    delegate:self
                                           cancelButtonTitle:@"Confirm"
                                           otherButtonTitles:nil];
        [alert show];
    }
    else if (descriptionTextView.text.length==0)
    {
        inputError=4;
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                     message:@"Description can't be empty!"
                                                    delegate:self
                                           cancelButtonTitle:@"Confirm"
                                           otherButtonTitles:nil];
        [alert show];
    }
    else if (latitudeTextField.text.doubleValue<-90 || latitudeTextField.text.doubleValue>=90)
    {
        inputError=1;
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                     message:@"Latitude is out of range!"
                                                    delegate:self
                                           cancelButtonTitle:@"Confirm"
                                           otherButtonTitles:nil];
        [alert show];
    }
    else if (longitudeTextField.text.doubleValue<-180 || longitudeTextField.text.doubleValue>=180)
    {
        inputError=2;
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                     message:@"Longitude is out of range!"
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
        double latitude=latitudeTextField.text.doubleValue;
        double longitude=longitudeTextField.text.doubleValue;
        PFGeoPoint *location=[PFGeoPoint geoPointWithLatitude:latitude longitude:longitude];
        newChannel[@"location"]=location;
        newChannel[@"range"]=[NSNumber numberWithDouble:rangeTextField.text.doubleValue];
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
                 appDelegate.refreshChannelDetail=true;
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
    {PFQuery *query=[PFQuery queryWithClassName:@"Channel"];
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
    categoryButton.titleLabel.text=[categoryList objectAtIndex:value];
    channel.category=value;
}

@end

