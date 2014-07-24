//
//  RegisterViewController.h
//  IP
//
//  Created by Tianyu An on 14-6-20.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterViewController : UIViewController <UITextFieldDelegate, UINavigationControllerDelegate,  UIImagePickerControllerDelegate>

@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *confirmPwdTextField;
@property (strong, nonatomic) IBOutlet UITextField *nicknameTextField;
@property (strong, nonatomic) IBOutlet UIButton *chooseLogoButton;
@property (strong, nonatomic) IBOutlet UIImageView *logoImageView;

- (IBAction)viewTouchDown:(id)sender;
- (IBAction)chooseLogoButtonClicked:(id)sender;

@end
