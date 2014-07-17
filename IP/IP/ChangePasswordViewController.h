//
//  ChangePasswordViewController.h
//  IP
//
//  Created by Tianyu An on 14-6-21.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangePasswordViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *theOriginalPwdTextField;
@property (strong, nonatomic) IBOutlet UITextField *theNewPwdTextField;
@property (strong, nonatomic) IBOutlet UITextField *theConfirmPwdTextField;

@end
