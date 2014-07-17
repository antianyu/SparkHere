//
//  EditChannelViewController.h
//  IP
//
//  Created by Tianyu An on 14-7-14.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Channel.h"

@interface EditChannelViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *channelNameTextField;
@property (strong, nonatomic) IBOutlet UISegmentedControl *privilegeSegmentedControl;
@property (strong, nonatomic) IBOutlet UITextField *latitudeTextField;
@property (strong, nonatomic) IBOutlet UITextField *longitudeTextField;
@property (strong, nonatomic) IBOutlet UITextField *rangeTextField;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;

@property (strong, nonatomic) Channel *channel;
@property BOOL editChannel;

@end
