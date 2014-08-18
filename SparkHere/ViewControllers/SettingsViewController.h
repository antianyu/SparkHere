//
//  SettingsViewController.h
//  SparkHere
//
//  Created by Tianyu An on 14-6-12.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *receivePromptLabel;
@property (strong, nonatomic) IBOutlet UILabel *receiveMessagesLabel;
@property (strong, nonatomic) IBOutlet UISwitch *receiveMessageSwitch;
@property (strong, nonatomic) IBOutlet UILabel *fontSizeLabel;
@property (strong, nonatomic) IBOutlet UISegmentedControl *fontSizeSegmentedControl;

@end
