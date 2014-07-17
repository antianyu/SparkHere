//
//  MyProfileViewController.h
//  IP
//
//  Created by Tianyu An on 14-6-19.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface MyProfileViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *logoutButton;
@property (strong, nonatomic) IBOutlet UIButton *myPostsButton;
@property (strong, nonatomic) IBOutlet UIButton *changePwdButton;
@property (strong, nonatomic) IBOutlet UIButton *settingsButton;
@property (strong, nonatomic) IBOutlet UIButton *helpButton;
@property (strong, nonatomic) IBOutlet UIButton *aboutButton;

- (IBAction)logoutButtonClicked:(id)sender;
- (IBAction)myPostsButtonClicked:(id)sender;
- (IBAction)changePwdButtonClicked:(id)sender;
- (IBAction)settingsButtonClicked:(id)sender;
- (IBAction)helpButtonClicked:(id)sender;
- (IBAction)aboutButtonClicked:(id)sender;

@end
