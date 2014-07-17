//
//  DiscoverChannelsViewController.m
//  IP
//
//  Created by Tianyu An on 14-6-12.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "DiscoverChannelsViewController.h"
#import "ChannelDetailViewController.h"
#import "Settings.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"

@interface DiscoverChannelsViewController ()

@end

@implementation DiscoverChannelsViewController
{
    Settings *settings;
    AppDelegate *appDelegate;
    MBProgressHUD *progressHUD;
    NSMutableArray *hotChannelList;
    NSMutableArray *searchResults;
}

@synthesize channelTableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent=NO;
    
    self.title=@"Discover Channels";
    
    self.tabBarItem.title=@"Discover";
    
    settings=[[Settings alloc]init];
    
    if (settings.is4Inch)
    {
        UIColor *background=[UIColor colorWithPatternImage:[UIImage imageNamed:@"Background_4.png"]];
        [self.view setBackgroundColor:background];
        [self.searchDisplayController.searchResultsTableView setBackgroundColor:background];
    }
    else
    {
        UIColor *background=[UIColor colorWithPatternImage:[UIImage imageNamed:@"Background_3.5.png"]];
        [self.view setBackgroundColor:background];
        [self.searchDisplayController.searchResultsTableView setBackgroundColor:background];
    }
    
    NSDictionary *attributes=[NSDictionary dictionaryWithObjectsAndKeys:
                              [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavigationBar.png"] forBarMetrics:UIBarMetricsDefault];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self.channelTableView setBackgroundColor:[UIColor clearColor]];
    [self.channelTableView setSeparatorInset:UIEdgeInsetsZero];
    [self.searchDisplayController.searchResultsTableView setSeparatorInset:UIEdgeInsetsZero];
//    [self.channelTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
//    [self.searchDisplayController.searchResultsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    appDelegate=[[UIApplication sharedApplication]delegate];
    progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    
    hotChannelList=[[NSMutableArray alloc]init];
    searchResults=[[NSMutableArray alloc]init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    settings=[[Settings alloc]init];
    [self showRefreshHotListWaitingView];
}

- (void) viewDidDisappear:(BOOL)animated
{
    self.hidesBottomBarWhenPushed=NO;
}

- (IBAction)viewTouchDown:(id)sender
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView==self.searchDisplayController.searchResultsTableView)
    {
        return searchResults.count;
    }
    else
    {
        return hotChannelList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *channelCellIdentifier = @"ChannelCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:channelCellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle
                                     reuseIdentifier:channelCellIdentifier];
    }
    
    Channel *channel=[[Channel alloc]init];
    NSInteger row = [indexPath row];
    if (tableView==self.searchDisplayController.searchResultsTableView)
    {
        channel=[searchResults objectAtIndex:row];
    }
    else
    {
        channel=[hotChannelList objectAtIndex:row];
    }
    cell.textLabel.text = channel.channelName;
    cell.textLabel.font=[UIFont systemFontOfSize:settings.fontSize];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Number of followers: %d", channel.followersNumber];
    cell.detailTextLabel.font=[UIFont systemFontOfSize:settings.fontSize-6];
    [cell.detailTextLabel setTextColor:[UIColor lightGrayColor]];
//    [cell setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ChannelCell.png"]]];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ChannelDetailViewController *controller=[[ChannelDetailViewController alloc]init];
    
    if (tableView==self.searchDisplayController.searchResultsTableView)
    {
        controller.channel=[searchResults objectAtIndex:indexPath.row];
    }
    else
    {
        controller.channel=[hotChannelList objectAtIndex:indexPath.row];
    }
    appDelegate.refreshChannelDetail=true;
    
    self.hidesBottomBarWhenPushed=YES;
    
    UIBarButtonItem *backButton=[[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem=backButton;
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope
{
    NSPredicate *resultPredicate=[NSPredicate predicateWithFormat:@"SELF.channelName contains[cd] %@", searchText];
    searchResults = [[hotChannelList filteredArrayUsingPredicate:resultPredicate] mutableCopy];
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

- (void)constructList
{
    [hotChannelList removeAllObjects];
    PFQuery *query=[PFQuery queryWithClassName:@"Channel"];
    [query orderByDescending:@"followersNumber"];
    query.limit=10;
    NSArray *channels=[query findObjects];
    
    // get channels from subscriptions
    for (PFObject *object in channels)
    {
        Channel *channel=[[Channel alloc]initWithPFObject:object];
        [hotChannelList addObject:channel];
    }
}

- (void)showRefreshHotListWaitingView
{
    [[UIApplication sharedApplication].keyWindow addSubview:progressHUD];
    progressHUD.dimBackground = YES;
    progressHUD.labelText = @"Loading...";
    [progressHUD showAnimated:YES whileExecutingBlock:^
     {
         [self constructList];
     }
    completionBlock:^
     {
         [progressHUD removeFromSuperview];
         [self.channelTableView reloadData];
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
         
         for (PFObject *object in channels)
         {
             Channel *channel=[[Channel alloc]initWithPFObject:object];
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
