//
//  MyChannelsViewController.m
//  SparkHere
//
//  Created by Tianyu An on 14-6-12.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "MyChannelsViewController.h"
#import "ChannelDetailViewController.h"
#import "EditChannelViewController.h"
#import "ChannelTableViewCell.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "User.h"
#import "Channel.h"

@interface MyChannelsViewController ()

@end

@implementation MyChannelsViewController
{
    AppDelegate *appDelegate;
    MBProgressHUD *progressHUD;
    NSMutableArray *searchResults;
}

@synthesize channelTableView;

#pragma mark View
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"My Channels";
    
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    progressHUD=[[MBProgressHUD alloc] initWithView:self.view];
    progressHUD.dimBackground = NO;
    progressHUD.userInteractionEnabled=NO;
    progressHUD.labelText = @"Please wait...";
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:appDelegate.backgroundImage]];
    
    UIBarButtonItem *establishButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(establishButtonClicked)];
    self.navigationItem.rightBarButtonItem=establishButtonItem;
    
    [channelTableView setBackgroundColor:[UIColor clearColor]];
    [channelTableView setSeparatorInset:UIEdgeInsetsZero];
    
    [self.searchDisplayController.searchResultsTableView setBackgroundColor:[UIColor colorWithPatternImage:appDelegate.backgroundImage]];
    [self.searchDisplayController.searchResultsTableView setSeparatorInset:UIEdgeInsetsZero];
    
    searchResults=[[NSMutableArray alloc]init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tabBarItem setTitle:@"My Channels"];
    [self.tabBarItem setImage:[[UIImage imageNamed:@"Channel_unselected.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [self.tabBarItem setSelectedImage:[UIImage imageNamed:@"Channel_selected.png"]];

    if (appDelegate.refreshMyChannelList)
    {
        [appDelegate constructListsFromMessageVC:NO tableView:channelTableView tabBarItem:nil];
    }
    else
    {
        [channelTableView reloadData];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.hidesBottomBarWhenPushed=NO;
    [progressHUD removeFromSuperview];
}

- (IBAction)viewTouchDown:(id)sender
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (void)establishButtonClicked
{
    EditChannelViewController *controller=[[EditChannelViewController alloc]init];
    controller.editChannel=NO;
    self.hidesBottomBarWhenPushed=YES;
    
    UIBarButtonItem *backButton=[[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem=backButton;
    
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView==self.searchDisplayController.searchResultsTableView)
    {
        return searchResults.count;
    }
    else
    {
        return appDelegate.myChannelList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *channelCellIdentifier = @"ChannelCellIdentifier";
    static BOOL nibsRegistered=NO;
    if (!nibsRegistered)
    {
        UINib *nib=[UINib nibWithNibName:@"ChannelTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:channelCellIdentifier];
        nibsRegistered=YES;
    }
    
    ChannelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:channelCellIdentifier];
    if (cell == nil)
    {
        cell=[[[NSBundle mainBundle]loadNibNamed:@"ChannelTableViewCell" owner:nil options:nil] lastObject];
    }
    
    Channel *channel;
    if (tableView==self.searchDisplayController.searchResultsTableView)
    {
        channel=[searchResults objectAtIndex:indexPath.row];
    }
    else
    {
        channel=[appDelegate.myChannelList objectAtIndex:indexPath.row];
    }
    [cell setChannel:channel fontSize:appDelegate.settings.fontSize];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChannelTableViewCell *cell=(ChannelTableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ChannelDetailViewController *controller=[[ChannelDetailViewController alloc]init];
    controller.hidesBottomBarWhenPushed=YES;

    
    if (tableView==self.searchDisplayController.searchResultsTableView)
    {
        controller.channel=[searchResults objectAtIndex:indexPath.row];
    }
    else
    {
        controller.channel=[appDelegate.myChannelList objectAtIndex:indexPath.row];
    }
    appDelegate.refreshChannelDetail=YES;
    
    self.hidesBottomBarWhenPushed=YES;
    
    UIBarButtonItem *backButton=[[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem=backButton;
    
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark SearchDisplayController
- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope
{
    NSPredicate *resultPredicate=[NSPredicate predicateWithFormat:@"SELF.channelName contains[cd] %@", searchText];
    searchResults = [[appDelegate.myChannelList filteredArrayUsingPredicate:resultPredicate] mutableCopy];
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

#pragma mark Auxiliaries
- (void)constructSearchResultLists:(NSString *)searchString
{
    [[UIApplication sharedApplication].keyWindow addSubview:progressHUD];
    [progressHUD showAnimated:YES whileExecutingBlock:^
     {
         [searchResults removeAllObjects];
         PFQuery *query=[PFQuery queryWithClassName:@"Subscription"];
         [query whereKey:@"userID" equalTo:appDelegate.user.userID];
         NSArray *subscriptions=[query findObjects];
         
         // get members from subscriptions
         for (PFObject *object in subscriptions)
         {
             PFQuery *channelQuery=[PFQuery queryWithClassName:@"Channel"];
             Channel *channel=[[Channel alloc]initWithPFObject:[channelQuery getObjectWithId:object[@"channelID"]]];
             if ([channel.channelName rangeOfString:searchString].location!=NSNotFound)
             {
                 [searchResults addObject:channel];
             }
         }
     }
    completionBlock:^
     {
         [progressHUD removeFromSuperview];
         [self.searchDisplayController.searchResultsTableView reloadData];
     }];
}

@end
