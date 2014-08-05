//
//  MapViewAnnotation.m
//  IP
//
//  Created by Tianyu An on 14-8-5.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import "MapViewAnnotation.h"

@implementation MapViewAnnotation

@synthesize title;
@synthesize coordinate;

-(id) initWithTitle:(NSString *)Title coordinate:(CLLocationCoordinate2D)Coordinate
{
    if(self = [super init])
    {
        title=Title;
        coordinate=Coordinate;
    }
    
    return self;
}

@end
