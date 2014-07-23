//
//  ChooseCategoryViewController.m
//  IP
//
//  Created by Tianyu An on 14-7-23.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "ChooseCategoryViewController.h"
#import "ChannelDetailViewController.h"
#import "Settings.h"

@interface ChooseCategoryViewController ()

@end

@implementation ChooseCategoryViewController
{
    Settings *settings;
    NSArray *categoryList;    
}

@synthesize categoryTableView;
@synthesize category;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"Category";
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
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
    
    [self.categoryTableView setBackgroundColor:[UIColor clearColor]];
    [self.categoryTableView setSeparatorInset:UIEdgeInsetsZero];
    [self.searchDisplayController.searchResultsTableView setSeparatorInset:UIEdgeInsetsZero];
    
    NSString *plistPath=[[NSBundle mainBundle] pathForResource:@"Category" ofType:@"plist"];
    categoryList=[[NSArray alloc]initWithContentsOfFile:plistPath];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return categoryList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *categoryCellIdentifier = @"CategoryCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:categoryCellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:categoryCellIdentifier];
    }
    
    cell.textLabel.text=[categoryList objectAtIndex:indexPath.row];
    cell.textLabel.font=[UIFont systemFontOfSize:settings.fontSize];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setTintColor:[UIColor whiteColor]];
    
    if (indexPath.row==category)
    {
        cell.accessoryType=UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate passIntDelegate:indexPath.row];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
