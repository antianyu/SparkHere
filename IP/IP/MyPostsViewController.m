//
//  MyPostsViewController.m
//  IP
//
//  Created by Tianyu An on 14-6-19.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "MyPostsViewController.h"
#import "MessageDetailViewController.h"
#import "User.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "MessageTableViewCell.h"
#import <Parse/Parse.h>

@interface MyPostsViewController ()

@end

@implementation MyPostsViewController
{
    AppDelegate *appDelegate;
    MBProgressHUD *progressHUD;
    Message *tempMessage;
    BOOL isMessageTable;
    BOOL modificationInSearchTableView;
    NSMutableArray *postsList;
    NSMutableArray *searchResults;
    NSIndexPath *tempIndexPath;
}

@synthesize postsTableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"My Posts";
    
    appDelegate=[[UIApplication sharedApplication] delegate];
    progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:appDelegate.backgroundImage]];
    
    [self.postsTableView setBackgroundColor:[UIColor clearColor]];
    [self.postsTableView setSeparatorInset:UIEdgeInsetsZero];
    
    [self.searchDisplayController.searchResultsTableView setBackgroundColor:[UIColor colorWithPatternImage:appDelegate.backgroundImage]];
    [self.searchDisplayController.searchResultsTableView setSeparatorInset:UIEdgeInsetsZero];
    
    searchResults=[[NSMutableArray alloc]init];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (appDelegate.refreshPostsList)
    {
        [self constructPostsList];
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
        return postsList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *messageCellIdentifier = @"MessageCellIdentifier";
    
    static BOOL nibsRegistered=NO;
    if (!nibsRegistered)
    {
        UINib *nib=[UINib nibWithNibName:@"MessageTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:messageCellIdentifier];
        nibsRegistered=YES;
    }
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageTableViewCell *cell=(MessageTableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageDetailViewController *controller=[[MessageDetailViewController alloc]init];
    controller.message=[postsList objectAtIndex:indexPath.row];
    self.hidesBottomBarWhenPushed=YES;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // swipe to delete
    if(editingStyle==UITableViewCellEditingStyleDelete)
    {
        tempIndexPath=indexPath;
        if (tableView==self.searchDisplayController.searchResultsTableView)
        {
            isMessageTable=false;
            tempMessage=[searchResults objectAtIndex:indexPath.row];
        }
        else
        {
            isMessageTable=true;
            tempMessage=[postsList objectAtIndex:indexPath.row];
        }
        [self deleteMessage];
    }
}

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

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    if (modificationInSearchTableView)
    {
        [self constructPostsList];
        modificationInSearchTableView=false;
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self constructSearchResultLists:searchBar.text];
}

- (void)constructPostsList
{
    [[UIApplication sharedApplication].keyWindow addSubview:progressHUD];
    progressHUD.dimBackground = YES;
    progressHUD.labelText = @"Loading...";
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
             
             PFFile *imageFile=object[@"image"];
             UIImage *image=[UIImage imageWithData:[imageFile getData]];
             
             Message *message=[[Message alloc]initWithContent:object[@"content"]
                                                        image:image
                                                     updateAt:object.updatedAt
                                                    messageID:object.objectId
                                                       sender:sender
                                                      channel:channel];
             [postsList addObject:message];
         }
     }
              completionBlock:^
     {
         [progressHUD removeFromSuperview];
         [self.postsTableView reloadData];
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
             
             PFFile *imageFile=object[@"image"];
             UIImage *image=[UIImage imageWithData:[imageFile getData]];
             
             Message *message=[[Message alloc]initWithContent:object[@"content"]
                                                        image:image
                                                     updateAt:object.updatedAt
                                                    messageID:object.objectId
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
    [[UIApplication sharedApplication].keyWindow addSubview:progressHUD];
    progressHUD.dimBackground = YES;
    progressHUD.labelText = @"Please wait...";
    [progressHUD showAnimated:YES whileExecutingBlock:^
     {
         PFQuery *query=[PFQuery queryWithClassName:@"Message"];
         PFObject *object=[query getObjectWithId:tempMessage.messageID];
         [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             [progressHUD removeFromSuperview];
             appDelegate.refreshMessageList=true;
             
             if (isMessageTable)
             {
                 [self.postsTableView reloadData];
                 [postsList removeObjectAtIndex:tempIndexPath.row];
                 
                 [self.postsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:tempIndexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
             }
             else
             {
                 modificationInSearchTableView=true;
                 [self.searchDisplayController.searchResultsTableView reloadData];
                 [searchResults removeObjectAtIndex:tempIndexPath.row];
                 
                 [self.searchDisplayController.searchResultsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:tempIndexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
             }
         }];
     }];
}
@end
