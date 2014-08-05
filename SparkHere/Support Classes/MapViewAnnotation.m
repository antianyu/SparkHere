//
//  MapViewAnnotation.m
//  SparkHere
//
//  Created by Tianyu An on 14-8-5.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "MapViewAnnotation.h"

@implementation MapViewAnnotation

@synthesize title;
@synthesize coordinate;

-(id) initWithTitle:(NSString *)aTitle coordinate:(CLLocationCoordinate2D)aCoordinate
{
    if(self = [super init])
    {
        title=aTitle;
        coordinate=aCoordinate;
    }
    
    return self;
}

@end
