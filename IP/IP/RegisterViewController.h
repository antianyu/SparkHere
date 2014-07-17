//
//  RegisterViewController.h
//  IP
//
//  Created by Tianyu An on 14-6-20.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *confirmPwdTextField;
@property (strong, nonatomic) IBOutlet UITextField *nicknameTextField;

- (IBAction)viewTouchDown:(id)sender;

@end
