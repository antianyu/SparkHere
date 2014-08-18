//
//  Message.m
//  SparkHere
//
//  Created by Tianyu An on 14-6-16.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "Message.h"

@implementation Message

@synthesize sender;
@synthesize channel;
@synthesize location;
@synthesize area;
@synthesize messageID;
@synthesize updateAt;
@synthesize content;
@synthesize image;

- (id)init
{
    if(self=[super init])
    {
        sender=[[User alloc]init];
        channel=[[Channel alloc]init];
        messageID=[[NSString alloc]init];
        content=[[NSString alloc]init];
        location=[[PFGeoPoint alloc]init];
    }    
    return self;
}

- (id)initWithPFObject:(PFObject *)object sender:(User *)msgSender channel:(Channel *)msgChannel
{
    if(self=[super init])
    {
        sender=msgSender;
        channel=msgChannel;
        messageID=object.objectId;
        updateAt=object.updatedAt;
        content=object[@"content"];
        PFFile *imageFile=object[@"image"];
        image=[UIImage imageWithData:[imageFile getData]];
        location=object[@"location"];
        
        CLLocation *newLocation=[[CLLocation alloc]initWithLatitude:location.latitude longitude:location.longitude];
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
                    area=[region stringByAppendingString:[NSString stringWithFormat:@", %@", city]];
                }
                else if (region!=nil)
                {
                    area=region;
                }
                else if (city!=nil)
                {
                    area=city;
                }
                else
                {
                    area=@"Somewhere";
                }
            }
        }];
    }
    return self;
}

@end
