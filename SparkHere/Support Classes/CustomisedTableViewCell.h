//
//  CustomisedTableViewCell.h
//  SparkHere
//
//  Created by Tianyu An on 14-8-19.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomisedTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *logoImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailLabel;

@end
