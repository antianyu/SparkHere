//
//  LoginViewController.h
//  SparkHere
//
//  Created by Tianyu An on 14-6-19.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIButton *registerButton;
@property (strong, nonatomic) IBOutlet UISwitch *autoLoginSwitch;
@property (strong, nonatomic) IBOutlet UILabel *autoLoginLabel;

- (IBAction)loginButtonClicked:(id)sender;
- (IBAction)registerButtonClicked:(id)sender;
- (IBAction)switchValueChanged:(id)sender;
- (IBAction)viewTouchDown:(id)sender;

@end