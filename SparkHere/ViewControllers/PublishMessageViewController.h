//
//  PublishMessageViewController.h
//  SparkHere
//
//  Created by Tianyu An on 14-7-25.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Channel.h"

@interface PublishMessageViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) IBOutlet UITextView *contentTextView;
@property (strong, nonatomic) IBOutlet UIImageView *contentImageView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;

- (IBAction)viewTouchDown:(id)sender;
- (IBAction)albumButtonClicked:(id)sender;
- (IBAction)cameraButtonClicked:(id)sender;

@property Channel *channel;

@end
