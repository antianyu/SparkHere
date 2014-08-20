//
//  MyProfileTableViewCell.m
//  SparkHere
//
//  Created by Tianyu An on 14-8-18.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "MyProfileTableViewCell.h"
#import "AppDelegate.h"

@implementation MyProfileTableViewCell
{
    UILabel *contentLabel;
    AppDelegate *appDelegate;
}

@synthesize logoImageView;
@synthesize logoImageViewContainer;
@synthesize nicknameLabel;
@synthesize locationLabel;

- (void)awakeFromNib
{
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self setBackgroundColor:[UIColor whiteColor]];
    
    [appDelegate setImageViewStyle:logoImageView container:logoImageViewContainer borderWidth:3 shadowOffset:3];
    
    nicknameLabel.text=appDelegate.user.nickname;
    nicknameLabel.textColor=appDelegate.majorColor;
    
    if (appDelegate.currentLocation==nil)
    {
        locationLabel.text=@"Somewhere";
    }
    else
    {
        CLLocation *newLocation=[[CLLocation alloc]initWithLatitude:appDelegate.currentLocation.latitude
                                                          longitude:appDelegate.currentLocation.longitude];
        CLGeocoder *geoCoder=[[CLGeocoder alloc]init];
        [geoCoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error)
         {
             if (placemarks.count>0)
             {
                 CLPlacemark *placemark=[placemarks firstObject];
                 NSString *city=placemark.locality;
                 NSString *region=placemark.subLocality;
                 if (region!=nil && city!=nil)
                 {
                     locationLabel.text=[region stringByAppendingString:[NSString stringWithFormat:@", %@", city]];
                 }
                 else if (region!=nil)
                 {
                     locationLabel.text=region;
                 }
                 else if (city!=nil)
                 {
                     locationLabel.text=city;
                 }
                 else
                 {
                     locationLabel.text=@"Somewhere";
                 }
             }
         }];
    }
    locationLabel.textColor=appDelegate.detailColor;
    
    if (appDelegate.user.logo==nil)
    {
        logoImageView.image=[UIImage imageNamed:@"Default_Logo.png"];
    }
    else
    {
        logoImageView.image=appDelegate.user.logo;
    }
}

@end
