//
//  MessageDetailViewController.m
//  SparkHere
//
//  Created by Tianyu An on 14-6-12.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "MessageDetailViewController.h"
#import "AppDelegate.h"
#import "MapViewAnnotation.h"
#import "Constants.h"

@implementation CLLocationManager (TemporaryHack)

- (void)hackLocationFix
{
    CLLocation *location=[[CLLocation alloc]initWithLatitude:51.474 longitude:-0.184];
    [[self delegate] locationManager:self didUpdateLocations:[NSArray arrayWithObject:location]];
}

- (void)startUpdatingLocation
{
    [self performSelector:@selector(hackLocationFix) withObject:nil afterDelay:0.1];
}

@end

@interface MessageDetailViewController ()

@end

@implementation MessageDetailViewController
{
    AppDelegate *appDelegate;
    CLLocationManager *locationManager;
    MKMapView *mapView;
}

@synthesize scrollView;
@synthesize senderLabel;
@synthesize senderLogoImageView;
@synthesize channelLabel;
@synthesize channelLogoImageView;
@synthesize updateLabel;

@synthesize message;

- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate=[[UIApplication sharedApplication] delegate];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:appDelegate.backgroundImage]];
    
    senderLabel.text=message.sender.nickname;
    channelLabel.text=message.channel.channelName;
    
    senderLogoImageView.image=message.sender.logo;
    channelLogoImageView.image=message.channel.logo;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit |NSHourCalendarUnit |NSMinuteCalendarUnit;
    NSDateComponents *cmp1 = [calendar components:unitFlags fromDate:message.updateAt];
    NSDateComponents *cmp2 = [calendar components:unitFlags fromDate:[NSDate date]];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if ([cmp1 day] == [cmp2 day])
    {
        [formatter setDateFormat:@"HH:mm a"];
        NSString *time = [formatter stringFromDate:message.updateAt];
        updateLabel.text = [NSString stringWithFormat:@"Published at：Today %@", time];
    }
    else
    {
        formatter.dateFormat = @"dd/MM/yyyy HH:mm a";
        NSString *time = [formatter stringFromDate:message.updateAt];
        updateLabel.text = [NSString stringWithFormat:@"Published at：%@", time];
    }
    
    scrollView.contentSize=CGSizeMake(VIEW_WIDTH, TITLE_HEIGHT);
    
    UILabel *contentLabel=[[UILabel alloc]init];
    if (message.content.length>0)
    {
        contentLabel.font=[UIFont systemFontOfSize:appDelegate.settings.fontSize];
        contentLabel.textColor=[UIColor whiteColor];
        contentLabel.numberOfLines=0;
        contentLabel.lineBreakMode=NSLineBreakByWordWrapping;
        contentLabel.text=message.content;
        
        CGSize constraint=CGSizeMake(LABEL_WIDTH, MAXIMUM_HEIGHT);
        NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:contentLabel.font, NSFontAttributeName, nil];
        
        CGSize actualSize=[message.content boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
        
        contentLabel.frame=CGRectMake(LABEL_ORIGIN_X, scrollView.contentSize.height+INTERVAL, LABEL_WIDTH, actualSize.height);
        
        scrollView.contentSize=CGSizeMake(VIEW_WIDTH, scrollView.contentSize.height+INTERVAL+actualSize.height);
        [scrollView addSubview:contentLabel];
    }
    
    if(message.image!=nil)
    {
        CGRect frame;
        double imageHeight=IMAGE_WIDTH*message.image.size.height/message.image.size.width;
        frame=CGRectMake(IMAGE_ORIGIN_X, scrollView.contentSize.height+INTERVAL, IMAGE_WIDTH, imageHeight);
        
        UIImageView *imageView=[[UIImageView alloc]initWithFrame:frame];
        imageView.image=message.image;
        
        scrollView.contentSize=CGSizeMake(VIEW_WIDTH, scrollView.contentSize.height+INTERVAL+imageHeight);
        [scrollView addSubview:imageView];
    }
    
    UILabel *locationLabel=[[UILabel alloc]init];
    locationLabel.font=[UIFont systemFontOfSize:appDelegate.settings.fontSize-4];
    locationLabel.textColor=[UIColor lightGrayColor];
    locationLabel.text=@"Message location:";
    locationLabel.frame=CGRectMake(LABEL_ORIGIN_X, scrollView.contentSize.height+INTERVAL, LABEL_WIDTH, LABEL_HEIGHT);
    scrollView.contentSize=CGSizeMake(VIEW_WIDTH, scrollView.contentSize.height+INTERVAL+LABEL_HEIGHT);
    [scrollView addSubview:locationLabel];
    
    CGRect frame=CGRectMake(MAP_ORIGIN_X, scrollView.contentSize.height+INTERVAL, MAP_WIDTH, MAP_HEIGHT);
    mapView=[[MKMapView alloc]initWithFrame:frame];
    mapView.delegate=self;
    scrollView.contentSize=CGSizeMake(VIEW_WIDTH, scrollView.contentSize.height+INTERVAL+MAP_HEIGHT+PADDING);
    [scrollView addSubview:mapView];
    
    MapViewAnnotation *annotation=[[MapViewAnnotation alloc]initWithTitle:@"Message"
                                                               coordinate:CLLocationCoordinate2DMake(message.location.latitude, message.location.longitude)];
    [mapView addAnnotation:annotation];
    
    MKCoordinateRegion viewRegion=MKCoordinateRegionMakeWithDistance(annotation.coordinate, MAP_RANGE, MAP_RANGE);
    [mapView setRegion:viewRegion animated:YES];
    
    if ([CLLocationManager locationServicesEnabled])
    {
        if (locationManager==nil)
        {
            locationManager=[[CLLocationManager alloc]init];
            locationManager.delegate=self;
            locationManager.desiredAccuracy=kCLLocationAccuracyNearestTenMeters;
        }
        [locationManager startUpdatingLocation];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    appDelegate.refreshPostsList=false;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *currentLocation=[locations lastObject];
    MapViewAnnotation *annotation=[[MapViewAnnotation alloc]initWithTitle:@"You"
                                                               coordinate:CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude)];
    [mapView addAnnotation:annotation];
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    for (MKPinAnnotationView *mkView in views)
    {
        if ([mkView.annotation.title isEqualToString:@"You"])
        {
            mkView.pinColor=MKPinAnnotationColorGreen;
        }
    }
}

@end
