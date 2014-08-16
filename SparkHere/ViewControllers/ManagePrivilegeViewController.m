//
//  ManagePrivilegeViewController.m
//  SparkHere
//
//  Created by Tianyu An on 14-7-15.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <Parse/Parse.h>
#import "ManagePrivilegeViewController.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "User.h"

@interface ManagePrivilegeViewController ()

@end

@implementation ManagePrivilegeViewController
{
    AppDelegate *appDelegate;
    MBProgressHUD *progressHUD;
    User *tempUser;
    int originalPrivilege;
    int index;
    BOOL isMemberTableView;
    BOOL modificationInSearchTableView;
    BOOL deleteSucceed;
    NSMutableArray *memberList;
    NSMutableArray *privilegeList;
    NSMutableArray *searchResults;
    NSMutableArray *searchPrivilegeList;
    NSIndexPath *tempIndexPath;
}

@synthesize memberTableView;
@synthesize channel;
@synthesize privilege;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"Manage Privilege";
    
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    progressHUD=[[MBProgressHUD alloc] initWithView:self.view];
    progressHUD.dimBackground = NO;
    progressHUD.userInteractionEnabled=NO;
    progressHUD.labelText = @"Please wait...";
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:appDelegate.backgroundImage]];
    
    [self.memberTableView setBackgroundColor:[UIColor clearColor]];
    [self.memberTableView setSeparatorInset:UIEdgeInsetsZero];
    
    [self.searchDisplayController.searchResultsTableView setBackgroundColor:[UIColor colorWithPatternImage:appDelegate.backgroundImage]];
    [self.searchDisplayController.searchResultsTableView setSeparatorInset:UIEdgeInsetsZero];
    
    memberList=[[NSMutableArray alloc]init];
    privilegeList=[[NSMutableArray alloc]init];
    searchResults=[[NSMutableArray alloc]init];
    searchPrivilegeList=[[NSMutableArray alloc]init];
    
    deleteSucceed=NO;
    modificationInSearchTableView=NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self constructLists];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [progressHUD removeFromSuperview];
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
        isMemberTableView=NO;
        originalPrivilege=[[searchPrivilegeList objectAtIndex:index] intValue];
        tempUser=[searchResults objectAtIndex:index];
    }
    else
    {
        isMemberTableView=YES;
        originalPrivilege=[[privilegeList objectAtIndex:index] intValue];
        tempUser=[memberList objectAtIndex:index];
    }
    
    if ([appDelegate.user.userID isEqualToString:tempUser.userID] && privilege==3)
    {
        [appDelegate showUIAlertViewWithTitle:@"Hey!" message:@"Your privilege should be modified by your administrator!" delegate:self];
    }
    else if ([appDelegate.user.userID isEqualToString:tempUser.userID] && privilege==4)
    {
        [appDelegate showUIAlertViewWithTitle:@"Hey!" message:@"You are the king of the channel! What else do you want to do?" delegate:self];
    }
    else if (privilege<=originalPrivilege)
    {
        [appDelegate showUIAlertViewWithTitle:@"Hey!" message:@"You can't change the privilege of those who has higher one!" delegate:self];
    }
    else
    {
        if (privilege==3)
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Modify Privilege"
                                                         message:@"Please select the privilege"
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles:@"1--Only Receive", @"2--Receive/Send", nil];
            [alert show];
        }
        else
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Modify Privilege"
                                                         message:@"Please select the privilege"
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles:@"1--Only Receive", @"2--Receive/Send",
                                @"3--Receive/Send/Admin", nil];
            [alert show];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    index=indexPath.row;
    int targetPrivilege;
    
    // swipe to delete
    if(editingStyle==UITableViewCellEditingStyleDelete)
    {
        if (tableView==self.searchDisplayController.searchResultsTableView)
        {
            isMemberTableView=NO;
            tempUser=[searchResults objectAtIndex:index];
            targetPrivilege=[[searchPrivilegeList objectAtIndex:index] intValue];
        }
        else
        {
            isMemberTableView=YES;
            tempUser=[memberList objectAtIndex:index];
            targetPrivilege=[[privilegeList objectAtIndex:index] intValue];
        }
        
        if ([appDelegate.user.userID isEqualToString:tempUser.userID])
        {
            [appDelegate showUIAlertViewWithTitle:@"Hey!" message:@"You can't delete yourself!" delegate:self];
        }
        else if (privilege<=targetPrivilege)
        {
            [appDelegate showUIAlertViewWithTitle:@"Hey!" message:@"You can't delete those who has higher privilege!" delegate:self];
        }
        else
        {
            tempIndexPath=indexPath;
            [self deleteSubsciption];
        }
    }
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

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    if (modificationInSearchTableView)
    {
        [self constructLists];
        modificationInSearchTableView=NO;
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self constructSearchResultLists:searchBar.text];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex!=alertView.cancelButtonIndex && buttonIndex!=originalPrivilege)
    {
        [self saveNewPrivilege:buttonIndex];
    }
    else if (deleteSucceed)
    {
        deleteSucceed=NO;
        if (isMemberTableView)
        {
            [memberList removeObjectAtIndex:index];
            [privilegeList removeObjectAtIndex:index];
            [self.memberTableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:tempIndexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
        }
        else
        {
            [searchResults removeObjectAtIndex:index];
            [searchPrivilegeList removeObjectAtIndex:index];
            [self.searchDisplayController.searchResultsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:tempIndexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

- (void)constructLists
{
    [[UIApplication sharedApplication].keyWindow addSubview:progressHUD];
    [progressHUD showAnimated:YES whileExecutingBlock:^
     {
         [memberList removeAllObjects];
         [privilegeList removeAllObjects];
         PFQuery *query=[PFQuery queryWithClassName:@"Subscription"];
         [query whereKey:@"channelID" equalTo:channel.channelID];
         query.limit=ITEMS_PER_REQUEST;
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

- (void)saveNewPrivilege:(int)newPrivilege
{
    [[UIApplication sharedApplication].keyWindow addSubview:progressHUD];
    [progressHUD showAnimated:YES whileExecutingBlock:^
     {
         PFQuery *query=[PFQuery queryWithClassName:@"Subscription"];
         [query whereKey:@"channelID" equalTo:channel.channelID];
         [query whereKey:@"userID" equalTo:tempUser.userID];
         PFObject *subscription=[query getFirstObject];
         subscription[@"privilege"]=[NSNumber numberWithInt:newPrivilege];
         [subscription saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
          {
              if (!error)
              {
                  [progressHUD removeFromSuperview];
                  [appDelegate showUIAlertViewWithTitle:@"Congratulations!" message:@"Privilege is modified!" delegate:self];
                  
                  if (isMemberTableView)
                  {
                      [privilegeList replaceObjectAtIndex:index withObject:[NSNumber numberWithInt:newPrivilege]];
                      [memberTableView reloadData];
                  }
                  else
                  {
                      modificationInSearchTableView=YES;
                      [searchPrivilegeList replaceObjectAtIndex:index
                                                     withObject:[NSNumber numberWithInt:newPrivilege]];
                      [self.searchDisplayController.searchResultsTableView reloadData];
                  }
              }
              else
              {
                  [progressHUD removeFromSuperview];
                  [appDelegate showUIAlertViewWithTitle:@"Woops!" message:@"Modify failed! Something wrong with server!" delegate:self];
              }
          }];
     }];
}

- (void)deleteSubsciption
{
    [[UIApplication sharedApplication].keyWindow addSubview:progressHUD];
    [progressHUD showAnimated:YES whileExecutingBlock:^
     {
         PFQuery *query=[PFQuery queryWithClassName:@"Subscription"];
         [query whereKey:@"channelID" equalTo:channel.channelID];
         [query whereKey:@"userID" equalTo:tempUser.userID];
         PFObject *subscription=[query getFirstObject];
         [subscription deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
          {
              if (!error)
              {
                  [progressHUD removeFromSuperview];
                  deleteSucceed=YES;
                  NSString *prompt=[NSString stringWithFormat:@"You have moved %@", tempUser.nickname];
                  [appDelegate showUIAlertViewWithTitle:@"Congratulations!" message:prompt delegate:self];
              }
              else
              {
                  [progressHUD removeFromSuperview];
                  [appDelegate showUIAlertViewWithTitle:@"Woops!" message:@"Delete failed! Something wrong with server!" delegate:self];
              }
          }];
     }];
}

@end
