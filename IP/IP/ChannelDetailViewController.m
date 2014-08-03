//
//  ChannelDetailViewController.m
//  IP
//
//  Created by Tianyu An on 14-6-12.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "ChannelDetailViewController.h"
#import "EditChannelViewController.h"
#import "ManagePrivilegeViewController.h"
#import "ChooseNewSuperAdminViewController.h"
#import "PublishMessageViewController.h"
#import "User.h"
#import "UIAlertViewOperation.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"

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
@synthesize channel;
@synthesize isFollowing;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"Channel Detail";
    
    appDelegate=[[UIApplication sharedApplication] delegate];
    progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:appDelegate.backgroundImage]];
    
    // add composeButton
    composeButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeButtonClicked)];
    
    // add editButton
    editButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonClicked)];
    
    buttons=[[NSMutableArray alloc]init];
    
    [appDelegate setDefaultViewStyle:followButton];
    
    [descriptionLabel setNumberOfLines:0];
    descriptionLabel.font=[UIFont systemFontOfSize:17];
    descriptionLabel.lineBreakMode=NSLineBreakByWordWrapping;
    descriptionLabel.textColor=[UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (appDelegate.refreshChannelDetail)
    {
        [self initialise];
        appDelegate.refreshChannelDetail=false;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (buttonClickTimes%2==1)
    {
        appDelegate.refreshMessageList=true;
        appDelegate.refreshMyChannelList=true;
    }
}

- (void)initialise
{
    [[UIApplication sharedApplication].keyWindow addSubview:progressHUD];
    progressHUD.dimBackground = YES;
    progressHUD.labelText = @"Please wait...";
    [progressHUD showAnimated:YES whileExecutingBlock:^
     {
         PFQuery *query=[PFQuery queryWithClassName:@"Channel"];
         channel=[[Channel alloc]initWithPFObject:[query getObjectWithId:channel.channelID]];
         
         query=[PFQuery queryWithClassName:@"Subscription"];
         [query whereKey:@"userID" equalTo:appDelegate.user.userID];
         [query whereKey:@"channelID" equalTo:channel.channelID];
         PFObject *result=[query getFirstObject];
         if (result)
         {
             privilege=[result[@"privilege"] intValue];
             isFollowing=true;
         }
         else
         {
             privilege=0;
             isFollowing=false;
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
         
         buttonClickTimes=0;
         unfollowWithCancel=false;
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
            unfollowWithCancel=true;
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
    progressHUD.dimBackground = YES;
    progressHUD.labelText = @"Please wait...";
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
    progressHUD.dimBackground = YES;
    progressHUD.labelText = @"Please wait...";
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
            case UIAlertViewOperationGoBack:
            {
                appDelegate.refreshMessageList=true;
                appDelegate.refreshMyChannelList=true;
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }                
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
        unfollowWithCancel=false;
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
        controller.editChannel=true;
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
    progressHUD.dimBackground = YES;
    progressHUD.labelText = @"Loading...";
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
              operation=UIAlertViewOperationGoBack;
              UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Wow!"
                                                           message:@"Channel is deleted!"
                                                          delegate:self
                                                 cancelButtonTitle:nil
                                                 otherButtonTitles:@"Confirm", nil];
              [alert show];
          }];
         
     }];
}

@end
