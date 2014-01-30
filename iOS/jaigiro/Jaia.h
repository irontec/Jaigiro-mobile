//
//  Jaia.h
//  jaigiro
//
//  Created by Sergio Garcia on 05/11/13.
//  Copyright (c) 2013 Irontec S.L. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Jaia : NSObject

@property (nonatomic) NSInteger id_jaia;
@property (nonatomic) NSInteger pisua;
@property (nonatomic) NSInteger colorSelector;
@property (nonatomic, strong) NSString *izena;
@property (nonatomic, strong) NSString *herria;
@property (nonatomic) NSInteger banator;
@property (nonatomic, strong) NSDate *hasiera;
@property (nonatomic, strong) NSDate *bukaera;
@property (nonatomic, strong) NSString *deskribapena;
@property (nonatomic) CGFloat lat;
@property (nonatomic) CGFloat lng;
@property (nonatomic, strong) NSString *url_kartela;
@property (nonatomic, strong) NSString *url_thum;


@end
