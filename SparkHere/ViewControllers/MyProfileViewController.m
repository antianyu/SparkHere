//
//  MyProfileViewController.m
//  SparkHere
//
//  Created by Tianyu An on 14-6-19.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "MyProfileViewController.h"
#import "WelcomeViewController.h"
#import "EditProfileViewController.h"
#import "SettingsViewController.h"
#import "HelpViewController.h"
#import "AboutViewController.h"
#import "MessageDetailViewController.h"
#import "MessageTableViewCell.h"
#import "MyProfileTableViewCell.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"

@interface MyProfileViewController ()

@end

@implementation MyProfileViewController
{
    AppDelegate *appDelegate;
    MBProgressHUD *progressHUD;
    Message *tempMessage;
    PFGeoPoint *oldLocation;
    BOOL isSettingsAction;
    BOOL isMessageTable;
    BOOL modificationInSearchTableView;
    NSMutableArray *postsList;
    NSMutableArray *searchResults;
    NSIndexPath *tempIndexPath;
}

@synthesize postsTableView;

#pragma mark View
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"My Profile";
    
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    progressHUD=[[MBProgressHUD alloc] initWithView:self.view];
    progressHUD.dimBackground = NO;
    progressHUD.userInteractionEnabled=NO;
    progressHUD.labelText = @"Please wait...";
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:appDelegate.backgroundImage]];
    
    UIBarButtonItem *settingsButtonItem=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Settings.png"]
                                                                        style:UIBarButtonItemStyleBordered
                                                                       target:self
                                                                       action:@selector(settingsButtonClicked)];
    
    UIBarButtonItem *moreButtonItem=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"More.png"]
                                                                    style:UIBarButtonItemStyleBordered
                                                                   target:self
                                                                   action:@selector(moreButtonClicked)];
        
    self.navigationItem.leftBarButtonItem=settingsButtonItem;
    self.navigationItem.rightBarButtonItem=moreButtonItem;
    
    [postsTableView setBackgroundColor:[UIColor clearColor]];
    [postsTableView setSeparatorInset:UIEdgeInsetsZero];
    
    [self.searchDisplayController.searchResultsTableView setBackgroundColor:[UIColor colorWithPatternImage:appDelegate.backgroundImage]];
    [self.searchDisplayController.searchResultsTableView setSeparatorInset:UIEdgeInsetsZero];
    
    searchResults=[[NSMutableArray alloc]init];
    oldLocation=appDelegate.currentLocation;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tabBarItem setTitle:@"My Profile"];
    [self.tabBarItem setImage:[[UIImage imageNamed:@"MyProfile_unselected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [self.tabBarItem setSelectedImage:[UIImage imageNamed:@"MyProfile_selected.png"]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (appDelegate.refreshPostsList)
    {
        [self constructPostsList];
    }
    else if (oldLocation!=appDelegate.currentLocation)
    {
        [postsTableView reloadData];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [progressHUD removeFromSuperview];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.hidesBottomBarWhenPushed=NO;
}

- (void)moreButtonClicked
{
    isSettingsAction=NO;
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Help", @"About", nil];
    [actionSheet showInView:self.view.superview];
}

- (void)settingsButtonClicked
{
    isSettingsAction=YES;
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:@"Sign out"
                                  otherButtonTitles:@"Edit Profile", @"Application Settings", nil];
    [actionSheet showInView:self.view.superview];
}

#pragma mark Action Sheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (isSettingsAction)
    {
        if (buttonIndex==actionSheet.destructiveButtonIndex)
        {
            [[UIApplication sharedApplication].keyWindow addSubview:progressHUD];
            [progressHUD showAnimated:YES whileExecutingBlock:^
             {
                 // wipe out user information in server
                 PFInstallation *currentInstallation=[PFInstallation currentInstallation];
                 [currentInstallation setObject:@"" forKey:@"currentUserID"];
                 [currentInstallation saveInBackground];
                 
                 // update local settings
                 appDelegate.user=nil;
                 appDelegate.settings.autoLogin=NO;
                 [appDelegate.settings saveSettings];
                 
                 // jump to welcome page
                 [progressHUD removeFromSuperview];
                 WelcomeViewController *controller=[[WelcomeViewController alloc]init];
                 UINavigationController *navController=[[UINavigationController alloc] initWithRootViewController:controller];
                 [navController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
                 [self presentViewController:navController animated:YES completion:nil];
             }];
        }
        else if (buttonIndex==1)
        {
            EditProfileViewController *controller=[[EditProfileViewController alloc]init];
            
            UIBarButtonItem *backButton=[[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:nil];
            self.navigationItem.backBarButtonItem=backButton;
            
            self.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:controller animated:YES];
        }
        else if (buttonIndex==2)
        {
            SettingsViewController *controller=[[SettingsViewController alloc]init];
            self.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
    else
    {
        if (buttonIndex==0)
        {
            HelpViewController *controller=[[HelpViewController alloc]init];
            self.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:controller animated:YES];
        }
        else if (buttonIndex==1)
        {
            AboutViewController *controller=[[AboutViewController alloc]init];
            self.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

#pragma mark UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView==self.searchDisplayController.searchResultsTableView)
    {
        return 1;
    }
    else
    {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView==self.searchDisplayController.searchResultsTableView)
    {
        return searchResults.count;
    }
    else
    {
        if (section==0)
        {
            return 1;
        }
        else
        {
            return postsList.count;
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView==postsTableView)
    {
        if (section==0)
        {
            return @"My Profile";
        }
        else
        {
            return @"My Posts";
        }
    }
    else
    {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *messageCellIdentifier = @"MessageCellIdentifier";
    
    static BOOL messageNibsRegistered=NO;
    if (!messageNibsRegistered)
    {
        UINib *nib=[UINib nibWithNibName:@"MessageTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:messageCellIdentifier];
        messageNibsRegistered=YES;
    }
    
    static NSString *myProfileCellIdentifier = @"MyProfileCellIdentifier";
    
    static BOOL myProfileNibsRegistered=NO;
    if (!myProfileNibsRegistered)
    {
        UINib *nib=[UINib nibWithNibName:@"MyProfileTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:myProfileCellIdentifier];
        myProfileNibsRegistered=YES;
    }
    
    if (tableView==postsTableView && indexPath.section==0)
    {
        MyProfileTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:myProfileCellIdentifier];
        if (cell==nil)
        {
            cell=[[[NSBundle mainBundle]loadNibNamed:@"MyProfileTableViewCell" owner:nil options:nil] lastObject];
        }
        return cell;
    }
    else
    {
        
        Message *message;
        if (tableView==self.searchDisplayController.searchResultsTableView)
        {
            message=[searchResults objectAtIndex:indexPath.row];
        }
        else
        {
            message=[postsList objectAtIndex:indexPath.row];
        }
        
        MessageTableViewCell *cell;
        if (message.image==nil)
        {
            static NSString *messageWithoutImageCellIdentifier = @"MessageWithoutImageCellIdentifier";
            cell = [tableView dequeueReusableCellWithIdentifier:messageWithoutImageCellIdentifier];
            if (cell==nil)
            {
                cell=[[[NSBundle mainBundle]loadNibNamed:@"MessageTableViewCell" owner:nil options:nil] lastObject];
            }
        }
        else
        {
            static NSString *messageWithImageCellIdentifier = @"MessageWithImageCellIdentifier";
            cell = [tableView dequeueReusableCellWithIdentifier:messageWithImageCellIdentifier];
            if (cell==nil)
            {
                cell=[[[NSBundle mainBundle]loadNibNamed:@"MessageTableViewCell" owner:nil options:nil] lastObject];
            }
        }
        
        [cell setMessage:message fontSize:appDelegate.settings.fontSize];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageTableViewCell *cell=(MessageTableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section==0)
    {
        EditProfileViewController *controller=[[EditProfileViewController alloc]init];
        
        UIBarButtonItem *backButton=[[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:nil];
        self.navigationItem.backBarButtonItem=backButton;
        
        self.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:controller animated:YES];        
    }
    else
    {
        MessageDetailViewController *controller=[[MessageDetailViewController alloc]init];
        controller.message=[postsList objectAtIndex:indexPath.row];
        self.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // swipe to delete
    if(editingStyle==UITableViewCellEditingStyleDelete)
    {
        tempIndexPath=indexPath;
        if (tableView==self.searchDisplayController.searchResultsTableView)
        {
            isMessageTable=NO;
            tempMessage=[searchResults objectAtIndex:indexPath.row];
        }
        else
        {
            isMessageTable=YES;
            tempMessage=[postsList objectAtIndex:indexPath.row];
        }
        [self deleteMessage];
    }
}

#pragma mark SearchDisplayController
- (void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope
{
    NSPredicate *resultPredicate=[NSPredicate predicateWithFormat:@"(SELF.content contains[cd] %@) or (SELF.channel.channelName contains[cd] %@)", searchText, searchText];
    searchResults = [[postsList filteredArrayUsingPredicate:resultPredicate] mutableCopy];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                                         objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    if (modificationInSearchTableView)
    {
        [self constructPostsList];
        modificationInSearchTableView=NO;
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self constructSearchResultLists:searchBar.text];
}

#pragma mark Auxiliaries
- (void)constructPostsList
{
    [[UIApplication sharedApplication].keyWindow addSubview:progressHUD];
    [progressHUD showAnimated:YES whileExecutingBlock:^
     {
         postsList=[[NSMutableArray alloc]init];
         
         PFQuery *query=[PFQuery queryWithClassName:@"Message"];
         [query whereKey:@"senderID" equalTo:appDelegate.user.userID];
         [query orderByDescending:@"updatedAt"];
         NSArray *messages=[query findObjects];
         
         for (PFObject *object in messages)
         {
             query=[PFQuery queryWithClassName:@"Channel"];
             Channel *channel=[[Channel alloc]initWithPFObject:[query getObjectWithId:object[@"channelID"]]];
             
             query=[PFQuery queryWithClassName:@"User"];
             User *sender=[[User alloc]initWithPFObject:[query getObjectWithId:object[@"senderID"]]];
             
             Message *message=[[Message alloc]initWithPFObject:object
                                                        sender:sender
                                                       channel:channel];
             [postsList addObject:message];
         }
     }
              completionBlock:^
     {
         appDelegate.refreshPostsList=NO;
         [progressHUD removeFromSuperview];
         [postsTableView reloadData];
     }];
}

- (void)constructSearchResultLists:(NSString *)searchString
{
    [[UIApplication sharedApplication].keyWindow addSubview:progressHUD];
    [progressHUD showAnimated:YES whileExecutingBlock:^
     {
         [searchResults removeAllObjects];
         PFQuery *query=[PFQuery queryWithClassName:@"Channel"];
         [query whereKey:@"channelName" containsString:searchString];
         NSArray *channels=[query findObjects];
         
         NSMutableArray *channelNames=[[NSMutableArray alloc]init];
         for (PFObject *object in channels)
         {
             [channelNames addObject:object.objectId];
         }
         
         PFQuery *channelQuery=[PFQuery queryWithClassName:@"Message"];
         [channelQuery whereKey:@"channelID" containedIn:channelNames];
         PFQuery *contentQuery=[PFQuery queryWithClassName:@"Message"];
         [contentQuery whereKey:@"content" containsString:searchString];
         query=[PFQuery orQueryWithSubqueries:@[channelQuery, contentQuery]];
         NSArray *messages=[query findObjects];
         
         // get members from subscriptions
         for (PFObject *object in messages)
         {
             query=[PFQuery queryWithClassName:@"User"];
             User *sender=[[User alloc]initWithPFObject:[query getObjectWithId:object[@"senderID"]]];
             
             query=[PFQuery queryWithClassName:@"Channel"];
             Channel *channel=[[Channel alloc]initWithPFObject:[query getObjectWithId:object[@"channelID"]]];
             
             Message *message=[[Message alloc]initWithPFObject:object
                                                        sender:sender
                                                       channel:channel];
             [searchResults addObject:message];
         }
     }
              completionBlock:^
     {
         [progressHUD removeFromSuperview];
         [self.searchDisplayController.searchResultsTableView reloadData];
     }];
}

- (void)deleteMessage
{
    [appDelegate.window.rootViewController.view addSubview:progressHUD];
    [progressHUD showAnimated:YES whileExecutingBlock:^
     {
         PFQuery *query=[PFQuery queryWithClassName:@"Message"];
         PFObject *object=[query getObjectWithId:tempMessage.messageID];
         [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
          {
              [progressHUD removeFromSuperview];
              appDelegate.refreshMessageList=YES;
              
              if (isMessageTable)
              {
                  [postsTableView reloadData];
                  [postsList removeObjectAtIndex:tempIndexPath.row];
                  
                  [postsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:tempIndexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
              }
              else
              {
                  modificationInSearchTableView=YES;
                  [self.searchDisplayController.searchResultsTableView reloadData];
                  [searchResults removeObjectAtIndex:tempIndexPath.row];
                  
                  [self.searchDisplayController.searchResultsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:tempIndexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
              }
          }];
     }];
}

@end
