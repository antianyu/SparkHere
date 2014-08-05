//
//  MessagesViewController.h
//  SparkHere
//
//  Created by Tianyu An on 14-7-2.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MessagesViewController : UIViewController <CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *messagesTableView;

@end
