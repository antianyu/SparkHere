//
//  MyProfileViewController.m
//  SparkHere
//
//  Created by Tianyu An on 14-6-19.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "MyProfileViewController.h"
#import "LoginViewController.h"
#import "MyPostsViewController.h"
#import "EditProfileViewController.h"
#import "SettingsViewController.h"
#import "HelpViewController.h"
#import "AboutViewController.h"
#import "AppDelegate.h"

@interface MyProfileViewController ()

@end

@implementation MyProfileViewController
{
    AppDelegate *appDelegate;
}

@synthesize logoutButton;
@synthesize myPostsButton;
@synthesize editProfileButton;
@synthesize settingsButton;
@synthesize helpButton;
@synthesize aboutButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"My Profile";
    
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:appDelegate.backgroundImage]];
    
    [logoutButton setBackgroundColor:[UIColor colorWithRed:156/255.0 green:222/255.0 blue:0/255.0 alpha:1]];
    [logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [myPostsButton setBackgroundColor:[UIColor colorWithRed:146/255.0 green:43/255.0 blue:236/255.0 alpha:1]];
    [myPostsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    editProfileButton.titleLabel.lineBreakMode=YES;
    [editProfileButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [editProfileButton setBackgroundColor:[UIColor colorWithRed:53/255.0 green:174/255.0 blue:238/255.0 alpha:1]];
    [editProfileButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    settingsButton.titleLabel.lineBreakMode=YES;
    [settingsButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [settingsButton setBackgroundColor:[UIColor colorWithRed:194/255.0 green:19/255.0 blue:70/255.0 alpha:1]];
    [settingsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [helpButton setBackgroundColor:[UIColor colorWithRed:233/255.0 green:170/255.0 blue:5/255.0 alpha:1]];
    [helpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [aboutButton setBackgroundColor:[UIColor colorWithRed:239/255.0 green:68/255.0 blue:158/255.0 alpha:1]];
    [aboutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    if (!appDelegate.is4Inch)
    {
        logoutButton.frame=CGRectMake(40, 17, 100, 100);
        myPostsButton.frame=CGRectMake(180, 17, 100, 100);
        editProfileButton.frame=CGRectMake(40, 134, 100, 100);
        settingsButton.frame=CGRectMake(180, 134, 100, 100);
        helpButton.frame=CGRectMake(40, 251, 100, 100);
        aboutButton.frame=CGRectMake(180, 251, 100, 100);
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tabBarItem setTitle:@"My Profile"];
    [self.tabBarItem setImage:[[UIImage imageNamed:@"MyProfile_unselected.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [self.tabBarItem setSelectedImage:[UIImage imageNamed:@"MyProfile_selected.png"]];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.hidesBottomBarWhenPushed=NO;
}

- (IBAction)logoutButtonClicked:(id)sender
{
    appDelegate.user=nil;
    appDelegate.settings.autoLogin=NO;
    [appDelegate.settings saveSettings];
    LoginViewController *controller=[[LoginViewController alloc]init];
    UINavigationController *navController=[[UINavigationController alloc]initWithRootViewController:controller];
    [navController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [self presentViewController:navController animated:YES completion:^{nil;}];
}

- (IBAction)myPostsButtonClicked:(id)sender
{
    appDelegate.refreshPostsList=YES;
    MyPostsViewController *controller=[[MyPostsViewController alloc]init];
    self.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)editProfileButtonClicked:(id)sender
{
    EditProfileViewController *controller=[[EditProfileViewController alloc]init];
    
    UIBarButtonItem *backButton=[[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem=backButton;
    
    self.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)settingsButtonClicked:(id)sender
{
    SettingsViewController *controller=[[SettingsViewController alloc]init];
    self.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)helpButtonClicked:(id)sender
{
    HelpViewController *controller=[[HelpViewController alloc]init];
    self.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:controller animated:YES];
    
}

- (IBAction)aboutButtonClicked:(id)sender
{
    AboutViewController *controller=[[AboutViewController alloc]init];
    self.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
