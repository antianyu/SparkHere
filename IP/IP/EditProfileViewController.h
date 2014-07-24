//
//  EditProfileViewController.h
//  IP
//
//  Created by Tianyu An on 14-7-24.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditProfileViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *nicknameTextField;
@property (strong, nonatomic) IBOutlet UITextField *theOriginalPwdTextField;
@property (strong, nonatomic) IBOutlet UITextField *theNewPwdTextField;
@property (strong, nonatomic) IBOutlet UITextField *theConfirmPwdTextField;

@end
