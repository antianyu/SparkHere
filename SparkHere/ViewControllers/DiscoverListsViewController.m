//
//  DiscoverListsViewController.m
//  SparkHere
//
//  Created by Tianyu An on 14-7-23.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "DiscoverListsViewController.h"
#import "ChannelDetailViewController.h"
#import "ChannelTableViewCell.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"

@interface DiscoverListsViewController ()

@end

@implementation DiscoverListsViewController
{
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
    
    NSString *plistPath=[[NSBundle mainBundle] pathForResource:@"Category" ofType:@"plist"];
    self.title=[[[NSArray alloc]initWithContentsOfFile:plistPath] objectAtIndex:category];
    
    appDelegate=[[UIApplication sharedApplication] delegate];
    progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:appDelegate.backgroundImage]];
    
    [self.channelTableView setBackgroundColor:[UIColor clearColor]];
    [self.channelTableView setSeparatorInset:UIEdgeInsetsZero];
    
    [self.searchDisplayController.searchResultsTableView setBackgroundColor:[UIColor colorWithPatternImage:appDelegate.backgroundImage]];
    [self.searchDisplayController.searchResultsTableView setSeparatorInset:UIEdgeInsetsZero];
    
    hotChannelList=[[NSMutableArray alloc]init];
    searchResults=[[NSMutableArray alloc]init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self showRefreshHotListWaitingView];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.hidesBottomBarWhenPushed=YES;
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
        channel=[hotChannelList objectAtIndex:indexPath.row];
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
        controller.channel=[hotChannelList objectAtIndex:indexPath.row];
    }
    appDelegate.refreshChannelDetail=true;
    
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
