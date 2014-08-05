//
//  DiscoverChannelsViewController.m
//  SparkHere
//
//  Created by Tianyu An on 14-6-12.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "DiscoverChannelsViewController.h"
#import "DiscoverListsViewController.h"
#import "ChannelDetailViewController.h"
#import "ChannelTableViewCell.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "User.h"

@interface DiscoverChannelsViewController ()

@end

@implementation DiscoverChannelsViewController
{
    AppDelegate *appDelegate;
    MBProgressHUD *progressHUD;
    NSArray *categoryList;
    NSMutableArray *searchResults;
}

@synthesize categoryTableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"Discover Channels";
    
    appDelegate=[[UIApplication sharedApplication] delegate];
    progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:appDelegate.backgroundImage]];
    
    self.tabBarItem.title=@"Discover";
    
    [self.categoryTableView setBackgroundColor:[UIColor clearColor]];
    [self.categoryTableView setSeparatorInset:UIEdgeInsetsZero];
    
    [self.searchDisplayController.searchResultsTableView setBackgroundColor:[UIColor colorWithPatternImage:appDelegate.backgroundImage]];
    [self.searchDisplayController.searchResultsTableView setSeparatorInset:UIEdgeInsetsZero];
    
    NSString *plistPath=[[NSBundle mainBundle] pathForResource:@"Category" ofType:@"plist"];
    categoryList=[[NSArray alloc]initWithContentsOfFile:plistPath];
    
    searchResults=[[NSMutableArray alloc]init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.categoryTableView reloadData];
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
        return categoryList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==self.searchDisplayController.searchResultsTableView)
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
        
        Channel *channel=[searchResults objectAtIndex:indexPath.row];
        [cell setChannel:channel fontSize:appDelegate.settings.fontSize];
        return cell;
    }
    else
    {
        static NSString *categoryCellIdentifier = @"CategoryCellIdentifier";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:categoryCellIdentifier];
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
                                         reuseIdentifier:categoryCellIdentifier];
        }
        
        cell.textLabel.text=[categoryList objectAtIndex:indexPath.row];
        cell.textLabel.font=[UIFont systemFontOfSize:appDelegate.settings.fontSize];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        [cell setBackgroundColor:[UIColor clearColor]];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView==self.searchDisplayController.searchResultsTableView)
    {
        ChannelDetailViewController *controller=[[ChannelDetailViewController alloc]init];
        controller.channel=[searchResults objectAtIndex:indexPath.row];
        controller.hidesBottomBarWhenPushed=YES;
        
        appDelegate.refreshChannelDetail=true;
        
        self.hidesBottomBarWhenPushed=YES;
        
        UIBarButtonItem *backButton=[[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:nil];
        self.navigationItem.backBarButtonItem=backButton;
        
        [self.navigationController pushViewController:controller animated:YES];
    }
    else
    {
        DiscoverListsViewController *controller=[[DiscoverListsViewController alloc]init];
        controller.category=indexPath.row;
        
        self.hidesBottomBarWhenPushed=YES;
        
        UIBarButtonItem *backButton=[[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:nil];
        self.navigationItem.backBarButtonItem=backButton;
        
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self constructSearchResultLists:searchBar.text];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [searchResults removeAllObjects];
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
