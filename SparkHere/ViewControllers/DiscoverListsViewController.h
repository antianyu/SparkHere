//
//  DiscoverListsViewController.h
//  SparkHere
//
//  Created by Tianyu An on 14-7-23.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DiscoverListsViewController : UIViewController <UISearchBarDelegate, UISearchDisplayDelegate>

@property (strong, nonatomic) IBOutlet UITableView *channelTableView;

@property int category;

@end
