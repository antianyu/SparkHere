//
//  MyProfileTableViewCell.h
//  SparkHere
//
//  Created by Tianyu An on 14-8-18.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyProfileTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *logoImageView;
@property (strong, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;

@end
