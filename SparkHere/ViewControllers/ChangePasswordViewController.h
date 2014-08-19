//
//  ChangePasswordViewController.h
//  SparkHere
//
//  Created by Tianyu An on 14-8-19.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangePasswordViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *theOldPwdLabel;
@property (strong, nonatomic) IBOutlet UITextField *theOldPwdTextField;
@property (strong, nonatomic) IBOutlet UILabel *theNewPwdLabel;
@property (strong, nonatomic) IBOutlet UITextField *theNewPwdTextField;
@property (strong, nonatomic) IBOutlet UILabel *theConfirmPwdLabel;
@property (strong, nonatomic) IBOutlet UITextField *theConfirmPwdTextField;

@end
