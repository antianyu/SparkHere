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
    NSMutableArray *buttons;
    UIBarButtonItem *composeButtonItem;
    UIBarButtonItem *editButtonItem;
}

@synthesize scrollView;
@synthesize logoImageView;
@synthesize titleLabel;
@synthesize descriptionLabel;
@synthesize followersLabel;
@synthesize followButton;
@synthesize separateLine;
@synthesize channel;
@synthesize isFollowing;

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
    
    // add composeButton
    composeButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeButtonClicked)];
    
    // add editButton
    editButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonClicked)];
    
    buttons=[[NSMutableArray alloc]init];
    
    [descriptionLabel setNumberOfLines:0];
    descriptionLabel.font=[UIFont systemFontOfSize:17];
    descriptionLabel.lineBreakMode=NSLineBreakByWordWrapping;
    descriptionLabel.textColor=[UIColor whiteColor];
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
         
         followersLabel.text=[NSString stringWithFormat:@"Followers: %d", channel.followersNumber];
         
         [buttons removeAllObjects];
         if (privilege>=3)
         {
             [buttons addObject:editButtonItem];
         }
         if (privilege>=2)
         {
             [buttons addObject:composeButtonItem];
         }
         self.navigationItem.rightBarButtonItems=buttons;
         
         NSString *description=channel.description;
         
         descriptionLabel.text=description;
         
         CGSize constraint=CGSizeMake(self.view.frame.size.width-40, 20000);
         NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:descriptionLabel.font, NSFontAttributeName, nil];
         
         CGSize actualSize=[description boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
         
         descriptionLabel.frame=CGRectMake(20, 150, self.view.frame.size.width-40, actualSize.height);
         
         scrollView.contentSize=CGSizeMake(self.view.frame.size.width, actualSize.height+170);
         [scrollView addSubview:descriptionLabel];
         
         [appDelegate setDefaultViewStyle:followButton];
         if (isFollowing)
         {
             [followButton setTitle:@"Following" forState:UIControlStateNormal];
         }
         else
         {
             [followButton setTitle:@"Follow" forState:UIControlStateNormal];
         }
         
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
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Prompt"
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

- (void)followCurrentChannel
{
    [[UIApplication sharedApplication].keyWindow addSubview:progressHUD];
    [progressHUD showAnimated:YES whileExecutingBlock:^
     {
         PFQuery *query=[PFQuery queryWithClassName:@"Channel"];
         PFObject *channelObj=[query getObjectWithId:channel.channelID];
         int followersNumber=[channelObj[@"followersNumber"] intValue];
         channelObj[@"followersNumber"]=[NSNumber numberWithInt:followersNumber+1];
         [channelObj saveInBackground];
         
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
              followersLabel.text=[NSString stringWithFormat:@"%d", [channelObj[@"followersNumber"] intValue]];
              privilege=[channelObj[@"defaultPrivilege"] intValue];
              [buttons removeAllObjects];
              if (privilege>=3)
              {
                  [buttons addObject:editButtonItem];
              }
              if (privilege>=2)
              {
                  [buttons addObject:composeButtonItem];
              }
              self.navigationItem.rightBarButtonItems=buttons;
              [progressHUD removeFromSuperview];
          }];
     }];
}

- (void)unfollowCurrentChannel
{
    [[UIApplication sharedApplication].keyWindow addSubview:progressHUD];
    [progressHUD showAnimated:YES whileExecutingBlock:^
     {
         PFQuery *query=[PFQuery queryWithClassName:@"Channel"];
         PFObject *channelObj=[query getObjectWithId:channel.channelID];
         channelObj[@"followersNumber"]=[NSNumber numberWithInt:[channelObj[@"followersNumber"] intValue]-1];
         [channelObj saveInBackground];
         
         query=[PFQuery queryWithClassName:@"Subscription"];
         [query whereKey:@"channelID" equalTo:channel.channelID];
         [query whereKey:@"userID" equalTo:appDelegate.user.userID];
         PFObject *object=[query getFirstObject];
         [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
          {
              followersLabel.text=[NSString stringWithFormat:@"%d", [channelObj[@"followersNumber"] intValue]];
              privilege=0;
              self.navigationItem.rightBarButtonItems=nil;
              [followButton setTitle:@"Follow" forState:UIControlStateNormal];
              [progressHUD removeFromSuperview];
          }];
     }];
}

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
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Delete"
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

- (void)showDeleteChannelWaitingView
{
    [[UIApplication sharedApplication].keyWindow addSubview:progressHUD];
    [progressHUD showAnimated:YES whileExecutingBlock:^
     {
         PFQuery *query=[PFQuery queryWithClassName:@"Subscription"];
         [query whereKey:@"channelID" equalTo:channel.channelID];
         NSArray *subscriptions=[query findObjects];
         
         // get channels from subscriptions
         for (PFObject *object in subscriptions)
         {
             [object deleteInBackground];
         }
         
         query=[PFQuery queryWithClassName:@"Message"];
         [query whereKey:@"channelID" equalTo:channel.channelID];
         NSArray *messages=[query findObjects];
         
         // get channels from subscriptions
         for (PFObject *object in messages)
         {
             [object deleteInBackground];
         }
         
         query=[PFQuery queryWithClassName:@"Channel"];
         
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

@end
