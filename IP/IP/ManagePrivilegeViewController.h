//
//  ManagePrivilegeViewController.h
//  IP
//
//  Created by Tianyu An on 14-7-15.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Channel.h"

@interface ManagePrivilegeViewController : UIViewController <UISearchBarDelegate, UISearchDisplayDelegate>

@property (strong, nonatomic) IBOutlet UITableView *memberTableView;

@property Channel *channel;
@property int privilege;

@end
