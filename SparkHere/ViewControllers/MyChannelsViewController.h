//
//  MyChannelsViewController.h
//  SparkHere
//
//  Created by Tianyu An on 14-7-2.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyChannelsViewController : UIViewController <UISearchBarDelegate, UISearchDisplayDelegate>

@property (strong, nonatomic) IBOutlet UITableView *channelTableView;

@end
