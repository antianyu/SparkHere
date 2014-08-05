//
//  MapViewAnnotation.h
//  IP
//
//  Created by Tianyu An on 14-8-5.
//  Copyright (c) 2014年 Tianyu An. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapViewAnnotation : NSObject <MKAnnotation>

@property (nonatomic,copy) NSString *title;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

-(id) initWithTitle:(NSString *)Title coordinate:(CLLocationCoordinate2D)Coordinate;

@end
