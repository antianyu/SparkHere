//
//  ChooseCategoryViewController.m
//  SparkHere
//
//  Created by Tianyu An on 14-7-23.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "ChooseCategoryViewController.h"
#import "ChannelDetailViewController.h"
#import "AppDelegate.h"

@interface ChooseCategoryViewController ()

@end

@implementation ChooseCategoryViewController
{
    AppDelegate *appDelegate;
    NSArray *categoryList;    
}

@synthesize categoryTableView;
@synthesize category;

#pragma mark View
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"Category";
    
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:appDelegate.backgroundImage]];
    
    [self.categoryTableView setBackgroundColor:[UIColor clearColor]];
    [self.categoryTableView setSeparatorInset:UIEdgeInsetsZero];
    
    [self.searchDisplayController.searchResultsTableView setBackgroundColor:[UIColor colorWithPatternImage:appDelegate.backgroundImage]];
    [self.searchDisplayController.searchResultsTableView setSeparatorInset:UIEdgeInsetsZero];
    
    NSString *plistPath=[[NSBundle mainBundle] pathForResource:@"Category" ofType:@"plist"];
    categoryList=[[NSArray alloc]initWithContentsOfFile:plistPath];
}

#pragma mark UITableView
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
    cell.textLabel.font=[UIFont systemFontOfSize:appDelegate.settings.fontSize];
    [cell.textLabel setTextColor:appDelegate.majorColor];
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setTintColor:appDelegate.majorColor];
    
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
