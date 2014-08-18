//
//  EditChannelViewController.h
//  SparkHere
//
//  Created by Tianyu An on 14-7-14.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Channel.h"
#import "PassIntDelegate.h"

@interface EditChannelViewController : UIViewController <UITextFieldDelegate, UINavigationControllerDelegate,  UIImagePickerControllerDelegate, PassIntDelegate>

@property (strong, nonatomic) IBOutlet UILabel *channelNameLabel;
@property (strong, nonatomic) IBOutlet UITextField *channelNameTextField;
@property (strong, nonatomic) IBOutlet UILabel *privilegeLabel;
@property (strong, nonatomic) IBOutlet UISegmentedControl *privilegeSegmentedControl;
@property (strong, nonatomic) IBOutlet UILabel *categoryLabel;
@property (strong, nonatomic) IBOutlet UIButton *categoryButton;
@property (strong, nonatomic) IBOutlet UILabel *logoLabel;
@property (strong, nonatomic) IBOutlet UIImageView *logoImageView;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;

- (IBAction)categoryButtonClicked:(id)sender;

@property (strong, nonatomic) Channel *channel;
@property BOOL editChannel;

@end
