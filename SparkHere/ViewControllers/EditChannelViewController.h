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

@interface EditChannelViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, UINavigationControllerDelegate,  UIImagePickerControllerDelegate, PassIntDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *logoImageView;
@property (strong, nonatomic) IBOutlet UIImageView *editImageView;
@property (strong, nonatomic) IBOutlet UIView *logoImageViewContainer;
@property (strong, nonatomic) IBOutlet UILabel *channelNameLabel;
@property (strong, nonatomic) IBOutlet UITextField *channelNameTextField;
@property (strong, nonatomic) IBOutlet UITableView *categoryTableView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *privilegeSegmentedControl;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (strong, nonatomic) Channel *channel;
@property BOOL editChannel;

@end
