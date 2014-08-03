//
//  ChooseNewSuperAdminViewController.m
//  IP
//
//  Created by Tianyu An on 14-7-16.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "ChooseNewSuperAdminViewController.h"
#import "User.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import <Parse/Parse.h>
#import "UIAlertViewOperation.h"

@interface ChooseNewSuperAdminViewController ()

@end

@implementation ChooseNewSuperAdminViewController
{
    AppDelegate *appDelegate;
    MBProgressHUD *progressHUD;
    UIAlertViewOperation operation;
    User *tempUser;
    int index;
    NSMutableArray *memberList;
    NSMutableArray *privilegeList;
    NSMutableArray *searchResults;
    NSMutableArray *searchPrivilegeList;
}

@synthesize memberTableView;
@synthesize channel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"Choose New Admin";
    
    appDelegate=[[UIApplication sharedApplication] delegate];
    progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:appDelegate.backgroundImage]];
    
    [self.memberTableView setBackgroundColor:[UIColor clearColor]];
    [self.memberTableView setSeparatorInset:UIEdgeInsetsZero];
    
    [self.searchDisplayController.searchResultsTableView setBackgroundColor:[UIColor colorWithPatternImage:appDelegate.backgroundImage]];
    [self.searchDisplayController.searchResultsTableView setSeparatorInset:UIEdgeInsetsZero];
    
    memberList=[[NSMutableArray alloc]init];
    privilegeList=[[NSMutableArray alloc]init];
    searchResults=[[NSMutableArray alloc]init];
    searchPrivilegeList=[[NSMutableArray alloc]init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self constructLists];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView==self.searchDisplayController.searchResultsTableView)
    {
        return searchResults.count;
    }
    else
    {
        return memberList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    User *user;
    NSInteger row=indexPath.row;
    int userPrivilege;
    
    if (tableView==self.searchDisplayController.searchResultsTableView)
    {
        static NSString *searchTableIdentifier=@"searchTableIdentifier";
        cell=[tableView dequeueReusableCellWithIdentifier:searchTableIdentifier];
        if(cell==nil)
        {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:searchTableIdentifier];
        }
        user=[searchResults objectAtIndex:row];
        userPrivilege=[[searchPrivilegeList objectAtIndex:row] intValue];
    }
    else
    {
        static NSString *memberTableIdentifier=@"memberTableIdentifier";
        cell=[tableView dequeueReusableCellWithIdentifier:memberTableIdentifier];
        if(cell==nil)
        {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:memberTableIdentifier];
        }
        user=[memberList objectAtIndex:row];
        userPrivilege=[[privilegeList objectAtIndex:row] intValue];
    }
    
    cell.textLabel.text=user.nickname;
    cell.textLabel.font=[UIFont systemFontOfSize:appDelegate.settings.fontSize];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    
    NSString *privilegeString;
    if (userPrivilege==1)
    {
        privilegeString=@"Privilege:1--Receive";
    }
    else if (userPrivilege==2)
    {
        privilegeString=@"Privilege:2--Receive/Send";
    }
    else if (userPrivilege==3)
    {
        privilegeString=@"Privilege:3--Receive/Send/Admin";
    }
    else
    {
        privilegeString=@"Privilege:4--Super Admin";
    }
    cell.detailTextLabel.text = privilegeString;
    cell.detailTextLabel.font=[UIFont systemFontOfSize:appDelegate.settings.fontSize-6];
    [cell.detailTextLabel setTextColor:[UIColor lightGrayColor]];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    return  cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    index=indexPath.row;
    if (tableView==self.searchDisplayController.searchResultsTableView)
    {
        tempUser=[searchResults objectAtIndex:index];
    }
    else
    {
        tempUser=[memberList objectAtIndex:index];
    }
    
    if ([tempUser.userID isEqualToString:appDelegate.user.userID])
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Hey!"
                                                     message:@"You should choose someone else to be new super administrator!"
                                                    delegate:self
                                           cancelButtonTitle:@"Confirm"
                                           otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        operation=UIAlertViewOperationChooseNewSuperAdmin;
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Hey!"
                                                     message:@"You really want this guy to be new super administrator? This operation can't be undone."
                                                    delegate:self
                                           cancelButtonTitle:@"No"
                                           otherButtonTitles:@"Yes", nil];
        [alert show];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope
{
    NSPredicate *resultPredicate=[NSPredicate predicateWithFormat:@"SELF.nickname contains[cd] %@", searchText];
    searchResults = [[memberList filteredArrayUsingPredicate:resultPredicate] mutableCopy];
    [searchPrivilegeList removeAllObjects];
    for (User *user in searchResults)
    {
        [searchPrivilegeList addObject:[privilegeList objectAtIndex:[memberList indexOfObject:user]]];
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                                         objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self constructSearchResultLists:searchBar.text];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex!=alertView.cancelButtonIndex)
    {
        switch (operation)
        {
            case UIAlertViewOperationChooseNewSuperAdmin:
                [self changeSuperAdministrator];
                break;
                
            case UIAlertViewOperationGoBack:
                appDelegate.refreshChannelDetail=true;
                [self.navigationController popViewControllerAnimated:YES];
                break;
                
            default:
                break;
        }
    }
}

- (void)constructLists
{
    [[UIApplication sharedApplication].keyWindow addSubview:progressHUD];
    progressHUD.dimBackground = YES;
    progressHUD.labelText = @"Please wait...";
    [progressHUD showAnimated:YES whileExecutingBlock:^
     {
         [memberList removeAllObjects];
         [privilegeList removeAllObjects];
         PFQuery *query=[PFQuery queryWithClassName:@"Subscription"];
         [query whereKey:@"channelID" equalTo:channel.channelID];
         query.limit=10;
         NSArray *subscriptions=[query findObjects];
         
         // get members from subscriptions
         for (PFObject *object in subscriptions)
         {
             PFQuery *userQuery=[PFQuery queryWithClassName:@"User"];
             User *subscriber=[[User alloc]initWithPFObject:[userQuery getObjectWithId:object[@"userID"]]];
             [memberList addObject:subscriber];
             [privilegeList addObject:object[@"privilege"]];
         }
     }
              completionBlock:^
     {
         [progressHUD removeFromSuperview];
         [self.memberTableView reloadData];
     }];
}

- (void)constructSearchResultLists:(NSString *)searchString
{
    [[UIApplication sharedApplication].keyWindow addSubview:progressHUD];
    progressHUD.dimBackground = YES;
    progressHUD.labelText = @"Please wait...";
    [progressHUD showAnimated:YES whileExecutingBlock:^
     {
         [searchResults removeAllObjects];
         [searchPrivilegeList removeAllObjects];
         PFQuery *query=[PFQuery queryWithClassName:@"Subscription"];
         [query whereKey:@"channelID" equalTo:channel.channelID];
         NSArray *subscriptions=[query findObjects];
         
         // get members from subscriptions
         for (PFObject *object in subscriptions)
         {
             PFQuery *userQuery=[PFQuery queryWithClassName:@"User"];
             User *user=[[User alloc]initWithPFObject:[userQuery getObjectWithId:object[@"userID"]]];
             if ([user.nickname rangeOfString:searchString].location!=NSNotFound)
             {
                 [searchResults addObject:user];
                 [searchPrivilegeList addObject:object[@"privilege"]];
             }
         }
     }
              completionBlock:^
     {
         [progressHUD removeFromSuperview];
         [self.searchDisplayController.searchResultsTableView reloadData];
     }];
}

- (void)changeSuperAdministrator
{
    [[UIApplication sharedApplication].keyWindow addSubview:progressHUD];
    progressHUD.dimBackground = YES;
    progressHUD.labelText = @"Please wait...";
    [progressHUD showAnimated:YES whileExecutingBlock:^
     {
         // change privilege of new admin
         PFQuery *query=[PFQuery queryWithClassName:@"Subscription"];
         [query whereKey:@"channelID" equalTo:channel.channelID];
         [query whereKey:@"userID" equalTo:tempUser.userID];
         PFObject *subscription=[query getFirstObject];
         subscription[@"privilege"]=[NSNumber numberWithInt:4];
         [subscription saveInBackground];
         
         // unfollow channel for original admin
         [query whereKey:@"userID" equalTo:appDelegate.user.userID];
         subscription=[query getFirstObject];
         [subscription deleteInBackground];
         
         // decrement followersNumber of channel
         query=[PFQuery queryWithClassName:@"Channel"];
         PFObject *channelObj=[query getObjectWithId:channel.channelID];
         channelObj[@"followersNumber"]=[NSNumber numberWithInt:[channelObj[@"followersNumber"] intValue]-1];
         [channelObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
           {
               if (!error)
               {
                   [progressHUD removeFromSuperview];
                   operation=UIAlertViewOperationGoBack;
                   NSString *prompt=[NSString stringWithFormat:@"You have choose %@ to be new super adminstrator!", tempUser.nickname];
                   UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Congratulations!"
                                                                message:prompt
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"Confirm", nil];
                   [alert show];
               }
               else
               {
                   [progressHUD removeFromSuperview];
                   UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Woops!"
                                                                message:@"Unsubscribe failed! Something wrong with server!"
                                                               delegate:self
                                                      cancelButtonTitle:@"Confirm"
                                                      otherButtonTitles:nil];
                   [alert show];
               }
           }];
     }];
}

@end
