//
//  ChooseCategoryViewController.h
//  IP
//
//  Created by Tianyu An on 14-7-23.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PassIntDelegate.h"

@interface ChooseCategoryViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *categoryTableView;

@property int category;

@property (nonatomic) NSObject<PassIntDelegate> *delegate;

@end
