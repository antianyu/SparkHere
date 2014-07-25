//
//  DiscoverListsViewController.m
//  IP
//
//  Created by Tianyu An on 14-7-23.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "DiscoverListsViewController.h"
#import "ChannelDetailViewController.h"
#import "Settings.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"

@interface DiscoverListsViewController ()

@end

@implementation DiscoverListsViewController
{
    Settings *settings;
    AppDelegate *appDelegate;
    MBProgressHUD *progressHUD;
    NSMutableArray *hotChannelList;
    NSMutableArray *searchResults;
}

@synthesize channelTableView;
@synthesize category;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    self.navigationController.navigationBar.translucent=NO;
    
    NSString *plistPath=[[NSBundle mainBundle] pathForResource:@"Category" ofType:@"plist"];
    self.title=[[[NSArray alloc]initWithContentsOfFile:plistPath] objectAtIndex:category];
    
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
    [super viewDidDisappear:animated];
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
    NSInteger row=indexPath.row;
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
    [cell setBackgroundColor:[UIColor clearColor]];
    
    return cell;
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
    [query whereKey:@"category" equalTo:[NSNumber numberWithInt:category]];
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
         [query whereKey:@"category" equalTo:[NSNumber numberWithInt:category]];
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
