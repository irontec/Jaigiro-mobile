//
//  JaigiroAnnotation.m
//  jaigiro
//
//  Created by Sergio Garcia on 11/11/13.
//  Copyright (c) 2013 Irontec S.L. All rights reserved.
//

#import "JaigiroAnnotation.h"

@implementation JaigiroAnnotation

- (id)initWithTitle:(NSString *)aTitle subtitle:(NSString*)aSubtitle imageURL:(NSString*)imageUrl andCoordinate:(CLLocationCoordinate2D)coord;
{
	self = [super init];
    if (self) {
        _title = aTitle;
        _subtitle = aSubtitle;
        _coordinate = coord;
        _imgUrl = imageUrl;
    }
	return self;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    _coordinate = newCoordinate;
}

@end
