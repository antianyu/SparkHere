//
//  MyChannelsViewController.m
//  IP
//
//  Created by Tianyu An on 14-6-12.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "MyChannelsViewController.h"
#import "ChannelDetailViewController.h"
#import "EditChannelViewController.h"
#import "Settings.h"
#import "User.h"
#import "Channel.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"

@interface MyChannelsViewController ()

@end

@implementation MyChannelsViewController
{
    Settings *settings;
    AppDelegate *appDelegate;
    MBProgressHUD *progressHUD;
    NSMutableArray *searchResults;
}

@synthesize channelTableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"My Channels";
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    UIBarButtonItem *establishButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(establishButtonClicked)];
    self.navigationItem.rightBarButtonItem=establishButtonItem;
    
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
    
    searchResults=[[NSMutableArray alloc]init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    settings=[[Settings alloc]init];
    
    [self.tabBarItem setTitle:@"My Channels"];
    [self.tabBarItem setImage:[[UIImage imageNamed:@"Channel_unselected.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [self.tabBarItem setSelectedImage:[UIImage imageNamed:@"Channel_selected.png"]];
    
    if (appDelegate.refreshMyChannelList)
    {
        [self showRefreshMyChannelListWaitingView];
        appDelegate.refreshMyChannelList=false;
    }
    else
    {
        [self.channelTableView reloadData];
    }
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
        return appDelegate.myChannelList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *channelCellIdentifier = @"ChannelCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:channelCellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:channelCellIdentifier];
    }
    
    NSInteger row=indexPath.row;
    if (tableView==self.searchDisplayController.searchResultsTableView)
    {
        Channel *channel=[searchResults objectAtIndex:row];
        cell.textLabel.text = channel.channelName;
    }
    else
    {
        Channel *channel=[appDelegate.myChannelList objectAtIndex:row];
        cell.textLabel.text = channel.channelName;
    }
    cell.textLabel.font=[UIFont systemFontOfSize:settings.fontSize];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
//    [cell setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ChannelCell.png"]]];
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
        controller.channel=[appDelegate.myChannelList objectAtIndex:indexPath.row];
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

- (void)establishButtonClicked
{
    EditChannelViewController *controller=[[EditChannelViewController alloc]init];
    controller.editChannel=false;
    self.hidesBottomBarWhenPushed=YES;
    
    UIBarButtonItem *backButton=[[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem=backButton;
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)showRefreshMyChannelListWaitingView
{
    [[UIApplication sharedApplication].keyWindow addSubview:progressHUD];
    progressHUD.dimBackground = YES;
    progressHUD.labelText = @"Loading...";
    [progressHUD showAnimated:YES whileExecutingBlock:^
     {
         [appDelegate constructMyChannelList];
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
