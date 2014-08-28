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

@interface MessageDetailViewController ()

@end

@implementation MessageDetailViewController
{
    AppDelegate *appDelegate;
    MKMapView *mapView;
}

@synthesize scrollView;
@synthesize senderLabel;
@synthesize senderLogoImageView;
@synthesize logoImageViewContainer;
@synthesize channelLabel;
@synthesize updateLabel;

@synthesize message;

#pragma mark View
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"Detail";
    
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:appDelegate.backgroundImage]];
    
    senderLabel.text=message.sender.nickname;
    senderLabel.textColor=appDelegate.majorColor;
    channelLabel.text=[@"via:" stringByAppendingString:message.channel.channelName];
    channelLabel.textColor=appDelegate.detailColor;
    
    // init senderLogoImageView
    [appDelegate setImageViewStyle:senderLogoImageView container:logoImageViewContainer borderWidth:1.5 shadowOffset:2];
    senderLogoImageView.image=message.sender.logo;
    
    // init updateLabel
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit |NSHourCalendarUnit |NSMinuteCalendarUnit;
    NSDateComponents *cmp1 = [calendar components:unitFlags fromDate:message.updatedAt];
    NSDateComponents *cmp2 = [calendar components:unitFlags fromDate:[NSDate date]];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if ([cmp1 day] == [cmp2 day])
    {
        [formatter setDateFormat:@"HH:mm a"];
        NSString *time = [formatter stringFromDate:message.updatedAt];
        updateLabel.text = [NSString stringWithFormat:@"Today %@", time];
    }
    else
    {
        formatter.dateFormat = @"dd/MM/yyyy HH:mm a";
        NSString *time = [formatter stringFromDate:message.updatedAt];
        updateLabel.text = [NSString stringWithFormat:@"%@", time];
    }
    updateLabel.textColor=appDelegate.detailColor;
    
    scrollView.contentSize=CGSizeMake(VIEW_WIDTH, TITLE_HEIGHT);
    
    // init contentLabel
    UILabel *contentLabel=[[UILabel alloc]init];
    if (message.content.length>0)
    {
        contentLabel.font=[UIFont systemFontOfSize:appDelegate.settings.fontSize];
        contentLabel.textColor=[UIColor blackColor];
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
    
    // init image
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
    
    // init locationImageView
    UIImageView *locationImageView=[[UIImageView alloc]initWithFrame:CGRectMake(15, scrollView.contentSize.height+INTERVAL+4, 20, 20)];
    locationImageView.image=[UIImage imageNamed:@"Location.png"];
    [scrollView addSubview:locationImageView];
    
    // init locationLabel
    UILabel *locationLabel=[[UILabel alloc]init];
    locationLabel.font=[UIFont systemFontOfSize:appDelegate.settings.fontSize-4];
    locationLabel.textColor=appDelegate.detailColor;
    locationLabel.text=message.area;
    locationLabel.frame=CGRectMake(LABEL_ORIGIN_X+20, scrollView.contentSize.height+INTERVAL, LABEL_WIDTH-20, LABEL_HEIGHT);
    scrollView.contentSize=CGSizeMake(VIEW_WIDTH, scrollView.contentSize.height+INTERVAL+LABEL_HEIGHT);
    [scrollView addSubview:locationLabel];
    
    // add Message Annotation
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
    
    [self drawYourPosition];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    appDelegate.refreshPostsList=NO;
}

#pragma mark Other Delegate
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

#pragma mark Auxiliaries
- (void)drawYourPosition
{
    [appDelegate getLocation];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        int count=0;
        while (appDelegate.currentLocation==nil && count<30)
        {
            [NSThread sleepForTimeInterval:1];
            count++;
            NSLog(@"count:%d",count);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (count==REQUEST_TIMEOUT)
            {
                [appDelegate showUIAlertViewWithTitle:@"Woops!" message:@"Can't locate your position!" delegate:nil];

            }
            else
            {
                CLLocationCoordinate2D coordinate=CLLocationCoordinate2DMake(appDelegate.currentLocation.latitude, appDelegate.currentLocation.longitude);
                MapViewAnnotation *annotation=[[MapViewAnnotation alloc]initWithTitle:@"You"
                                                                           coordinate:coordinate];
                [mapView addAnnotation:annotation];
            }
        });
    });
}

@end
