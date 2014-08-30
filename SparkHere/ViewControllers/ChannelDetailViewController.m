//
//  ChannelDetailViewController.m
//  SparkHere
//
//  Created by Tianyu An on 14-6-12.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "ChannelDetailViewController.h"
#import "PublishMessageViewController.h"
#import "EditChannelViewController.h"
#import "ManagePrivilegeViewController.h"
#import "ChooseNewSuperAdminViewController.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "User.h"
#import "UIAlertViewOperation.h"

@interface ChannelDetailViewController ()

@end

@implementation ChannelDetailViewController
{
    AppDelegate *appDelegate;
    MBProgressHUD *progressHUD;
    UIAlertViewOperation operation;
    BOOL unfollowWithCancel;
    int privilege;
    int buttonClickTimes;
    UIBarButtonItem *composeButtonItem;
    UIBarButtonItem *editButtonItem;
    UIToolbar *composeToolBar;
}

@synthesize scrollView;
@synthesize logoImageView;
@synthesize logoImageViewContainer;
@synthesize titleLabel;
@synthesize descriptionLabel;
@synthesize followersLabel;
@synthesize followButton;
@synthesize separateLine;
@synthesize channel;
@synthesize isFollowing;

#pragma mark View
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"Channel Detail";
    
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    progressHUD=[[MBProgressHUD alloc] initWithView:self.view];
    progressHUD.dimBackground = NO;
    progressHUD.userInteractionEnabled=NO;
    progressHUD.labelText = @"Please wait...";
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:appDelegate.backgroundImage]];
    
    logoImageViewContainer.hidden=YES;
    
    // add editButton
    editButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonClicked)];
    
    titleLabel.textColor=[UIColor whiteColor];
    followersLabel.textColor=[UIColor whiteColor];
    
    [descriptionLabel setNumberOfLines:0];
    descriptionLabel.font=[UIFont systemFontOfSize:17];
    descriptionLabel.lineBreakMode=NSLineBreakByWordWrapping;
    descriptionLabel.textColor=appDelegate.descriptionColor;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (appDelegate.refreshChannelDetail)
    {
        appDelegate.refreshChannelDetail=NO;
        [self initialise];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [progressHUD removeFromSuperview];
    if (buttonClickTimes%2==1)
    {
        appDelegate.refreshMessageList=YES;
        appDelegate.refreshMyChannelList=YES;
    }
}

- (void)initialise
{
    [[UIApplication sharedApplication].keyWindow addSubview:progressHUD];
    [progressHUD showAnimated:YES whileExecutingBlock:^
     {
         PFQuery *query=[PFQuery queryWithClassName:@"Channel"];
         channel=[[Channel alloc]initWithPFObject:[query getObjectWithId:channel.channelID]];
         
         query=[PFQuery queryWithClassName:@"Subscription"];
         [query whereKey:@"userID" equalTo:appDelegate.user.userID];
         [query whereKey:@"channelID" equalTo:channel.channelID];
         PFObject *result=[query getFirstObject];
         if (result!=nil)
         {
             privilege=[result[@"privilege"] intValue];
             isFollowing=YES;
         }
         else
         {
             privilege=0;
             isFollowing=NO;
         }
     }
    completionBlock:^
     {
         [progressHUD removeFromSuperview];
         
         titleLabel.text=channel.channelName;
         
         followersLabel.text=[self constructFollowersString:channel.followersNumber];
         
         if (privilege>=3)
         {
             self.navigationItem.rightBarButtonItem=editButtonItem;
         }
         if (privilege>=2)
         {
             CGRect scrollViewFrame=scrollView.frame;
             CGRect frame;
             if (appDelegate.is4Inch)
             {
                 frame=CGRectMake(0, 460, 320, 44);
                 scrollViewFrame.size.height=460;
             }
             else
             {
                 frame=CGRectMake(0, 372, 320, 44);
                 scrollViewFrame.size.height=372;
             }
             scrollView.frame=scrollViewFrame;
             
             composeToolBar=[[UIToolbar alloc]initWithFrame:frame];
             
             composeButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                            target:self
                                                                            action:@selector(composeButtonClicked)];
             
             UIBarButtonItem *spaceButtonItem1=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                           target:nil
                                                                                           action:nil];
             
             UIBarButtonItem *spaceButtonItem2=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                           target:nil
                                                                                           action:nil];
             
             [composeToolBar setItems:[NSArray arrayWithObjects:spaceButtonItem1, composeButtonItem, spaceButtonItem2, nil]];
             [self.view addSubview:composeToolBar];
         }
         
         NSString *description=channel.description;
         
         descriptionLabel.text=description;
         
         CGSize constraint=CGSizeMake(self.view.frame.size.width-40, 20000);
         NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:descriptionLabel.font, NSFontAttributeName, nil];
         
         CGSize actualSize=[description boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
         
         descriptionLabel.frame=CGRectMake(20, 210, self.view.frame.size.width-40, actualSize.height);
         
         scrollView.contentSize=CGSizeMake(self.view.frame.size.width, actualSize.height+170);
         [scrollView addSubview:descriptionLabel];
         
         UIColor *buttonColor=[UIColor colorWithRed:30/255.0 green:187/255.0 blue:166/255.0 alpha:1];
         [appDelegate setButtonStyle:followButton color:buttonColor];
         if (isFollowing)
         {
             [followButton setTitle:@"Following" forState:UIControlStateNormal];
         }
         else
         {
             [followButton setTitle:@"Follow" forState:UIControlStateNormal];
         }
         
         logoImageViewContainer.hidden=NO;
         [appDelegate setImageViewStyle:logoImageView container:logoImageViewContainer borderWidth:2.5 shadowOffset:3];
         if (channel.logo!=nil)
         {
             logoImageView.image=channel.logo;
         }
         else
         {
             logoImageView.image=[UIImage imageNamed:@"Default_Logo.png"];
         }
         
         [separateLine setHidden:NO];
         
         buttonClickTimes=0;
         unfollowWithCancel=NO;
     }];
}

- (IBAction)followButtonClicked:(id)sender
{
    UIButton *button=(UIButton *)sender;
    if ([button.currentTitle isEqual:@"Follow"])
    {
        [self followCurrentChannel];
        [button setTitle:@"Following" forState:UIControlStateNormal];
    }
    else
    {
        if (privilege==4)
        {
            operation=UIAlertViewOperationChooseNewSuperAdmin;
            unfollowWithCancel=YES;
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Hey!"
                                                         message:@"Would you like to choose someone to be new super administrator?"
                                                        delegate:self
                                               cancelButtonTitle:@"No"
                                               otherButtonTitles:@"Yes", nil];
            [alert show];
        }
        else
        {
            [self unfollowCurrentChannel];
        }
    }
    buttonClickTimes++;
}

- (void)composeButtonClicked
{
    PublishMessageViewController *controller=[[PublishMessageViewController alloc]init];
    controller.channel=channel;
    controller.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)editButtonClicked
{
    if (privilege==4)
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:@"Delete"
                                      otherButtonTitles:@"Edit Detail", @"Manage Privilege", nil];
        [actionSheet showInView:self.view];
    }
    else
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"Edit Detail", @"Manage Privilege", nil];
        [actionSheet showInView:self.view];
    }
}

#pragma mark Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex!=alertView.cancelButtonIndex)
    {
        switch (operation)
        {
            case UIAlertViewOperationDeleteChannel:
            {
                [self showDeleteChannelWaitingView];
                break;
            }
            case UIAlertViewOperationChooseNewSuperAdmin:
            {
                ChooseNewSuperAdminViewController *controller=[[ChooseNewSuperAdminViewController alloc]init];
                controller.channel=channel;
                self.hidesBottomBarWhenPushed=YES;
                [self.navigationController pushViewController:controller animated:YES];
                break;
            }
            default:
                break;
        }
    }
    else if(unfollowWithCancel)
    {
        unfollowWithCancel=NO;
        [self unfollowCurrentChannel];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==actionSheet.destructiveButtonIndex)
    {
        NSString *prompt=[NSString stringWithFormat:@"Are you sure you really want to delete channel %@?",channel.channelName];
        operation=UIAlertViewOperationDeleteChannel;
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil
                                                     message:prompt
                                                    delegate:self
                                           cancelButtonTitle:@"No"
                                           otherButtonTitles:@"Yes", nil];
        [alert show];
    }
    else if (buttonIndex==actionSheet.cancelButtonIndex-2)
    {
        EditChannelViewController *controller=[[EditChannelViewController alloc]init];
        controller.editChannel=YES;
        controller.channel=channel;
        self.hidesBottomBarWhenPushed=YES;
        
        UIBarButtonItem *backButton=[[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:nil];
        self.navigationItem.backBarButtonItem=backButton;
        
        [self.navigationController pushViewController:controller animated:YES];
    }
    else if (buttonIndex==actionSheet.cancelButtonIndex-1)
    {
        ManagePrivilegeViewController *controller=[[ManagePrivilegeViewController alloc]init];
        controller.channel=channel;
        controller.privilege=privilege;
        
        UIBarButtonItem *backButton=[[UIBarButtonItem alloc]initWithTitle:@"Back"
                                                                    style:UIBarButtonItemStyleBordered
                                                                   target:self
                                                                   action:nil];
        self.navigationItem.backBarButtonItem=backButton;
        
        self.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark Auxiliaries
- (void)followCurrentChannel
{
    [[UIApplication sharedApplication].keyWindow addSubview:progressHUD];
    [progressHUD showAnimated:YES whileExecutingBlock:^
     {
         // increment followersNumber
         PFQuery *query=[PFQuery queryWithClassName:@"Channel"];
         PFObject *channelObj=[query getObjectWithId:channel.channelID];
         int followersNumber=[channelObj[@"followersNumber"] intValue];
         [channelObj incrementKey:@"followersNumber"];
         [channelObj saveInBackground];
         
         // save subscription object
         PFObject *subscription=[PFObject objectWithClassName:@"Subscription"];
         subscription[@"channelID"]=channel.channelID;
         subscription[@"userID"]=appDelegate.user.userID;
         if (followersNumber==0)
         {
             subscription[@"privilege"]=[NSNumber numberWithInt:4];
         }
         else
         {
             subscription[@"privilege"]=[NSNumber numberWithInt:channel.defaultPrivilege];
         }
         [subscription saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
          {
              // refresh view
              followersLabel.text=[self constructFollowersString:[channelObj[@"followersNumber"] intValue]];
              privilege=[channelObj[@"defaultPrivilege"] intValue];
              if (privilege>=3)
              {
                  self.navigationItem.rightBarButtonItem=editButtonItem;
              }
              if (privilege>=2)
              {
                  CGRect scrollViewFrame=scrollView.frame;
                  CGRect frame;
                  if (appDelegate.is4Inch)
                  {
                      frame=CGRectMake(0, 460, 320, 44);
                      scrollViewFrame.size.height=460;
                  }
                  else
                  {
                      frame=CGRectMake(0, 372, 320, 44);
                      scrollViewFrame.size.height=372;
                  }
                  scrollView.frame=scrollViewFrame;
                  
                  composeToolBar=[[UIToolbar alloc]initWithFrame:frame];
                  
                  composeButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                 target:self
                                                                                 action:@selector(composeButtonClicked)];
                  
                  UIBarButtonItem *spaceButtonItem1=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                                 target:nil
                                                                                                 action:nil];
                  
                  UIBarButtonItem *spaceButtonItem2=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                                 target:nil
                                                                                                 action:nil];
                  
                  [composeToolBar setItems:[NSArray arrayWithObjects:spaceButtonItem1, composeButtonItem, spaceButtonItem2, nil]];
                  [self.view addSubview:composeToolBar];
              }
              [progressHUD removeFromSuperview];
          }];
     }];
}

- (void)unfollowCurrentChannel
{
    [[UIApplication sharedApplication].keyWindow addSubview:progressHUD];
    [progressHUD showAnimated:YES whileExecutingBlock:^
     {
         // decrement followersNumber
         PFQuery *query=[PFQuery queryWithClassName:@"Channel"];
         PFObject *channelObj=[query getObjectWithId:channel.channelID];
         [channelObj incrementKey:@"followersNumber" byAmount:[NSNumber numberWithInt:-1]];
         [channelObj saveInBackground];
         
         // delete subscription object
         query=[PFQuery queryWithClassName:@"Subscription"];
         [query whereKey:@"channelID" equalTo:channel.channelID];
         [query whereKey:@"userID" equalTo:appDelegate.user.userID];
         PFObject *object=[query getFirstObject];
         [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
          {
              // refresh view
              followersLabel.text=[self constructFollowersString:[channelObj[@"followersNumber"] intValue]];
              privilege=0;
              self.navigationItem.rightBarButtonItem=nil;
              [composeToolBar removeFromSuperview];
              [followButton setTitle:@"Follow" forState:UIControlStateNormal];
              [progressHUD removeFromSuperview];
          }];
     }];
}

- (void)showDeleteChannelWaitingView
{
    [[UIApplication sharedApplication].keyWindow addSubview:progressHUD];
    [progressHUD showAnimated:YES whileExecutingBlock:^
     {
         // get and delete subscriptions associated to the channel
         PFQuery *query=[PFQuery queryWithClassName:@"Subscription"];
         [query whereKey:@"channelID" equalTo:channel.channelID];
         NSArray *subscriptions=[query findObjects];
         
         for (PFObject *object in subscriptions)
         {
             [object deleteInBackground];
         }
         
         // get and delete messages associated to the channel
         query=[PFQuery queryWithClassName:@"Message"];
         [query whereKey:@"channelID" equalTo:channel.channelID];
         NSArray *messages=[query findObjects];
         
         // get channels from subscriptions
         for (PFObject *object in messages)
         {
             [object deleteInBackground];
         }
         
         query=[PFQuery queryWithClassName:@"Channel"];
         
         // delete channel
         PFObject *object=[query getObjectWithId:channel.channelID];
         [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
          {
              [progressHUD removeFromSuperview];
              UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Wow!"
                                                           message:@"Channel is deleted!"
                                                          delegate:self
                                                 cancelButtonTitle:nil
                                                 otherButtonTitles:@"Confirm", nil];
              [alert show];
              appDelegate.refreshMessageList=YES;
              appDelegate.refreshMyChannelList=YES;
              [self.navigationController popViewControllerAnimated:YES];
          }];
     }];
}

- (NSString *)constructFollowersString:(long long)followersNumber
{
    NSString *result;
    if (followersNumber<1000)
    {
        result=[NSString stringWithFormat:@"%lld followers", followersNumber];
    }
    else if (followersNumber<10000)
    {
        int magnitude=10000;
        long long quotient=followersNumber/(magnitude/10);
        long long remainder=followersNumber%(magnitude/10);
        remainder/=(magnitude/100);
        if (remainder==0)
        {
            result=[NSString stringWithFormat:@"%lldK followers", quotient];
        }
        else
        {
            result=[NSString stringWithFormat:@"%lld.%lldK followers", quotient, remainder];
        }
    }
    else if (followersNumber<1000000)
    {
        result=[NSString stringWithFormat:@"%lldK followers", followersNumber/1000];
    }
    else if (followersNumber<10000000)
    {
        int magnitude=10000000;
        long long quotient=followersNumber/(magnitude/10);
        long long remainder=followersNumber%(magnitude/10);
        remainder/=(magnitude/100);
        if (remainder==0)
        {
            result=[NSString stringWithFormat:@"%lldM followers", quotient];
        }
        else
        {
            result=[NSString stringWithFormat:@"%lld.%lldM followers", quotient, remainder];
        }
    }
    else if (followersNumber<1000000000)
    {
        result=[NSString stringWithFormat:@"%lldM followers", followersNumber/1000000];
    }
    else
    {
        int magnitude=1000000000;
        long long quotient=followersNumber/magnitude;
        long long remainder=followersNumber%magnitude;
        remainder/=(magnitude/10);
        if (remainder==0)
        {
            result=[NSString stringWithFormat:@"%lldB followers", quotient];
        }
        else
        {
            result=[NSString stringWithFormat:@"%lld.%lldB followers", quotient, remainder];
        }
    }
    return result;
}

@end
