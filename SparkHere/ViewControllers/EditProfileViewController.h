//
//  EditProfileViewController.h
//  SparkHere
//
//  Created by Tianyu An on 14-7-24.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditProfileViewController : UIViewController <UITextFieldDelegate, UINavigationControllerDelegate,  UIImagePickerControllerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (strong, nonatomic) IBOutlet UITextField *nicknameTextField;
@property (strong, nonatomic) IBOutlet UILabel *theOriginalPwdLabel;
@property (strong, nonatomic) IBOutlet UITextField *theOriginalPwdTextField;
@property (strong, nonatomic) IBOutlet UILabel *theNewPwdLabel;
@property (strong, nonatomic) IBOutlet UITextField *theNewPwdTextField;
@property (strong, nonatomic) IBOutlet UILabel *theConfirmPwdLabel;
@property (strong, nonatomic) IBOutlet UITextField *theConfirmPwdTextField;
@property (strong, nonatomic) IBOutlet UIImageView *logoImageView;

@end
