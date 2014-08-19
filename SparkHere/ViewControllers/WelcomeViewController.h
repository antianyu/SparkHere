//
//  WelcomeViewController.h
//  SparkHere
//
//  Created by Tianyu An on 14-8-19.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WelcomeViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) IBOutlet UILabel *photoLabel;
@property (strong, nonatomic) IBOutlet UIButton *signUpButton;
@property (strong, nonatomic) IBOutlet UIButton *signInButton;

- (IBAction)signUpButtonClicked:(id)sender;
- (IBAction)signInButtonClicked:(id)sender;

@end
