//
//  MessageDetailViewController.h
//  SparkHere
//
//  Created by Tianyu An on 14-6-12.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "Message.h"
#import "PassBoolDelegate.h"

@interface MessageDetailViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UILabel *senderLabel;
@property (strong, nonatomic) IBOutlet UIImageView *senderLogoImageView;
@property (strong, nonatomic) IBOutlet UILabel *channelLabel;
@property (strong, nonatomic) IBOutlet UIImageView *channelLogoImageView;
@property (strong, nonatomic) IBOutlet UILabel *updateLabel;

@property (nonatomic) NSObject<PassBoolDelegate> *delegate;

@property Message* message;

@end
