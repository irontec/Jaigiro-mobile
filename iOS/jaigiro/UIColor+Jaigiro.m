//
//  UIColor+Jaigiro.m
//  jaigiro
//
//  Created by Sergio Garcia on 08/11/13.
//  Copyright (c) 2013 Irontec S.L. All rights reserved.
//

#import "UIColor+Jaigiro.h"

@implementation UIColor_Jaigiro

+(UIColor *)getColor:(NSInteger)selector
{
    UIColor *c;
    switch (selector) {
        case 0:
            //verde
            c = [[UIColor alloc]initWithRed:68/255.0 green:221/255.0 blue:0/255.0 alpha:1];
            break;
        case 1:
            //rosa
            c = [UIColor colorWithRed:255/255.0 green:0/255.0 blue:153/255.0 alpha:1];
            break;
        case 2:
            //blue
            //HEX: #00e0e0
            //RGB: 0,254,254 alpha:1
            c = [UIColor colorWithRed:0/255.0 green:224/255.0 blue:224/255.0 alpha:1];
            break;
       default:
            c=[UIColor greenColor];
            break;
    }
    return c;
}

+(UIColor *)getBackgroundBanator
{
    //verde oscuro
    return [UIColor colorWithRed:49/255.0 green:214/255.0 blue:7/255.0 alpha:1];
}

@end
