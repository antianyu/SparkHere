//
//  MessageDetailViewController.h
//  IP
//
//  Created by Tianyu An on 14-6-12.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"
#import "PassBoolDelegate.h"

@interface MessageDetailViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *logoImageView;
@property (strong, nonatomic) IBOutlet UILabel *senderLabel;
@property (strong, nonatomic) IBOutlet UILabel *channelLabel;
@property (strong, nonatomic) IBOutlet UILabel *contentLabel;

@property (nonatomic) NSObject<PassBoolDelegate> *delegate;

@property Message* message;

@end
