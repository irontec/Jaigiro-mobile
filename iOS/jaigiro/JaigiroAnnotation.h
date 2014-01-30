//
//  JaigiroAnnotation.h
//  jaigiro
//
//  Created by Sergio Garcia on 11/11/13.
//  Copyright (c) 2013 Irontec S.L. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MapKit/MapKit.h>

@class Herria;

@interface JaigiroAnnotation : NSObject <MKAnnotation>
@property (nonatomic) Herria *herria;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *imgUrl;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
- (id)initWithTitle:(NSString *)aTitle subtitle:(NSString*)aSubtitle imageURL:(NSString*)imageUrl andCoordinate:(CLLocationCoordinate2D)coord;
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;
@end
