//
//  DateHelper.m
//  jaigiro
//
//  Created by Sergio Garcia on 25/11/13.
//  Copyright (c) 2013 Irontec S.L. All rights reserved.
//

#import "DateHelper.h"
#import "Login.h"

@implementation DateHelper


+ (NSInteger)getActualColorMonth
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    return [prefs integerForKey:@"actualMonthColor"];
}

+ (void)setActualColorMonth:(NSInteger)month
{
    NSInteger col = [Login getColorForMonth:month];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    return [prefs setInteger:col forKey:@"actualMonthColor"];
}

+ (NSArray *)getDaysArray
{
    NSArray *names;
    names = [[NSArray alloc] initWithObjects:@"al", @"as", @"az", @"og", @"or", @"lr", @"ig", nil];
    return names;
}

+ (NSArray *)getMonthsArray
{
    NSArray *names;
    names = [[NSArray alloc] initWithObjects:@"urtarrila", @"otsaila", @"martxoa", @"apirila", @"maiatza", @"ekaina", @"uztaila", @"abuztua", @"iraila", @"urria", @"azaroa", @"abendua", nil];
    return names;
}



+ (NSString *)pretyDate:(NSDate *)startDate end:(NSDate *)endDate
{
    NSString *result = @"";
    /*
    //Formatter for the date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyy-MM-dd"];
    
    //Declare dates
    NSDate *startDate = [[NSDate alloc] init];
    NSDate *endDate = [[NSDate alloc]init];
    
    //Create dates
    startDate = [dateFormatter dateFromString:start];
    endDate = [dateFormatter dateFromString:end];
    */
    //Create dates components
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSCalendarUnit components = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit;
    NSDateComponents* startComponents = [calendar components:components fromDate:startDate];
    NSDateComponents* endComponents = [calendar components:components fromDate:endDate];
    
    //Get componentes from the dates
    NSInteger startDay = [startComponents day];
    NSInteger startMonth = [startComponents month];
    NSInteger startYear = [startComponents year];
    
    NSInteger endDay = [endComponents day];
    NSInteger endMonth = [endComponents month];
    NSInteger endYear = [endComponents year];
    
    
    result = [result stringByAppendingString:[self integerToHilabeteaEuskaraz:startMonth]];
    result = [result stringByAppendingString:[NSString stringWithFormat:@"%d-(e)tik ", startDay]];
    if(startYear != endYear){
        result = [result stringByAppendingString:[NSString stringWithFormat:@"%dko ",endYear]];
        result = [result stringByAppendingString:[self integerToHilabeteaEuskaraz:endMonth]];
        result = [result stringByAppendingString:[NSString stringWithFormat:@"%d-(e)ra",endDay]];
    }else{
        if(startMonth != endMonth){
            result = [result stringByAppendingString:[self integerToHilabeteaEuskaraz:endMonth]];
        }
        result = [result stringByAppendingString:[NSString stringWithFormat:@"%d-(e)ra",endDay]];
    }

    return result;
}

+ (NSString *)integerToHilabeteaEuskaraz:(NSInteger)month
{
    switch (month) {
        case 1:
            return @"Urtarrilaren ";
        case 2:
            return @"Otsailaren ";
        case 3:
            return @"Martxoaren ";
        case 4:
            return @"Apirilaren ";
        case 5:
            return @"Maiatzaren ";
        case 6:
            return @"Ekainaren ";
        case 7:
            return @"Uztailaren ";
        case 8:
            return @"Abuztuaren ";
        case 9:
            return @"Irailaren ";
        case 10:
            return @"Urriaren ";
        case 11:
            return @"Azaroaren ";
        case 12:
            return @"Abenduaren ";
        default:
            return nil;
    }
}


@end
