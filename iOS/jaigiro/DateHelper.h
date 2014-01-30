//
//  DateHelper.h
//  jaigiro
//
//  Created by Sergio Garcia on 25/11/13.
//  Copyright (c) 2013 Irontec S.L. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateHelper : NSObject

+ (NSInteger)getActualColorMonth;
+ (void)setActualColorMonth:(NSInteger)month;

+ (NSArray *)getDaysArray;
+ (NSArray *)getMonthsArray;

+ (NSString *)pretyDate:(NSDate *)start end:(NSDate *)end;
+ (NSString *)integerToHilabeteaEuskaraz:(NSInteger)month;
@end
