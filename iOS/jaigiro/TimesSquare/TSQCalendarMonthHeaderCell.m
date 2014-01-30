//
//  TSQCalendarMonthHeaderCell.m
//  TimesSquare
//
//  Created by Jim Puls on 11/14/12.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import "TSQCalendarMonthHeaderCell.h"
#import "UIColor+Jaigiro.h"

static const CGFloat TSQCalendarMonthHeaderCellMonthsHeight = 20.f;


@interface TSQCalendarMonthHeaderCell ()

@property (nonatomic, strong) NSDateFormatter *monthDateFormatter;

@end


@implementation TSQCalendarMonthHeaderCell

- (id)initWithCalendar:(NSCalendar *)calendar reuseIdentifier:(NSString *)reuseIdentifier;
{
    self = [super initWithCalendar:calendar reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    [self createHeaderLabels];
    
    return self;
}


+ (CGFloat)cellHeight;
{
    return 65.0f;
}

- (NSDateFormatter *)monthDateFormatter;
{
    if (!_monthDateFormatter) {
        _monthDateFormatter = [NSDateFormatter new];
        _monthDateFormatter.calendar = self.calendar;
        
        NSString *dateComponents = @"yyyyLLLL";
        //NSLocale *usLoc = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        _monthDateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:dateComponents options:0 locale:[NSLocale currentLocale]];
        //_monthDateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:dateComponents options:0 locale:usLoc];//locale para el formato del mes
        
    }
    return _monthDateFormatter;
}

- (void)createHeaderLabels;
{
    NSDate *referenceDate = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
    NSDateComponents *offset = [NSDateComponents new];
    offset.day = 1;
    NSMutableArray *headerLabels = [NSMutableArray arrayWithCapacity:self.daysInWeek];
    
    NSDateFormatter *dayFormatter = [NSDateFormatter new];
    dayFormatter.calendar = self.calendar;
    dayFormatter.dateFormat = @"cccccc";
    
    for (NSUInteger index = 0; index < self.daysInWeek; index++) {
        [headerLabels addObject:@""];
    }
    
    for (NSUInteger index = 0; index < self.daysInWeek; index++) {
        NSInteger ordinality = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSWeekCalendarUnit forDate:referenceDate];
        UILabel *label = [[UILabel alloc] initWithFrame:self.frame];
        label.textAlignment = NSTextAlignmentCenter;
        //label.text = [dayFormatter stringFromDate:referenceDate];
        
        //NSCalendarUnit unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        NSCalendarUnit unitFlags = NSDayCalendarUnit;
        NSDateComponents *dateComponents = [self.calendar components:unitFlags fromDate:referenceDate];
        NSInteger day = [dateComponents day];//1-7 Dia de la semana
        NSString *name;
        
        switch (day) {
            case 1:
                name = @"al";
                break;
            case 2:
                name = @"as";
                break;
            case 3:
                name = @"az";
                break;
            case 4:
                name = @"og";
                break;
            case 5:
                name = @"or";
                break;
            case 6:
                name = @"lr";
                break;
            case 7:
                name = @"ig";
                break;
        }
        label.text = name;
        label.font = [UIFont boldSystemFontOfSize:12.f];
        //label.backgroundColor = self.backgroundColor;
        //[label setBackgroundColor:[UIColor greenColor]];
        //label.textColor = self.textColor;
        //[label setTextColor:[UIColor whiteColor]];
        
        //label.shadowColor = [UIColor whiteColor];
        
        //label.shadowOffset = self.shadowOffset;
        [label sizeToFit];
        headerLabels[ordinality - 1] = label;
        [self.contentView addSubview:label];
        [label setBackgroundColor:[UIColor whiteColor]];//Fondo nombres dia de la semana
        [label setTextColor:[UIColor_Jaigiro getColor:0]];//Color letra dias del mes
        referenceDate = [self.calendar dateByAddingComponents:offset toDate:referenceDate options:0];
    }
    
    
    self.headerLabels = headerLabels;
    
}

- (void)layoutSubviews;
{
    [super layoutSubviews];
    
    CGRect bounds = self.contentView.bounds;
    bounds.size.height -= TSQCalendarMonthHeaderCellMonthsHeight;
    self.textLabel.frame = CGRectOffset(bounds, 0.0f, 5.0f);
    
    
    [self.textLabel setBackgroundColor:[UIColor whiteColor]];//Fondo nombre mes
    [self.textLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:22]];//TIpo letra nombre de mes
    [self.textLabel sizeToFit];//Ajustar nombre del mes
    [self.textLabel setCenter:self.contentView.center];//Centrar nombre del mes
    CGRect frame = self.textLabel.frame;
    frame.origin.y = frame.origin.y - 10;
    frame.size.width = frame.size.width + 6;
    [self.textLabel setFrame:frame];//Ajustamos el nombre del mes para dejar espacio
    
    //TITULOS DE MES
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    //self.textLabel.textColor = self.textColor;
    [self.textLabel setTextColor:[UIColor whiteColor]];//Color nombre del mes
    [self.textLabel setBackgroundColor:[UIColor_Jaigiro getColor:1]];//Color fondo nombre del mes
    //self.textLabel.shadowColor = [UIColor clearColor];
    //[self.textLabel setShadowColor:[UIColor clearColor]];//Sombreado nombre del mes
    //self.textLabel.shadowOffset = self.shadowOffset;
}

- (void)layoutViewsForColumnAtIndex:(NSUInteger)index inRect:(CGRect)rect;
{
    UILabel *label = self.headerLabels[index];
    CGRect labelFrame = rect;
    labelFrame.size.height = TSQCalendarMonthHeaderCellMonthsHeight;
    labelFrame.origin.y = self.bounds.size.height - TSQCalendarMonthHeaderCellMonthsHeight;
    label.frame = labelFrame;
    
}

- (void)setFirstOfMonth:(NSDate *)firstOfMonth;
{
    [super setFirstOfMonth:firstOfMonth];
    self.textLabel.text = [self.monthDateFormatter stringFromDate:firstOfMonth];//sin traducir
    self.accessibilityLabel = self.textLabel.text;
    
    //NSCalendarUnit unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSCalendarUnit unitFlags = NSMonthCalendarUnit | NSYearCalendarUnit;
    NSDateComponents *dateComponents = [self.calendar components:unitFlags fromDate:firstOfMonth];
    NSInteger month = [dateComponents month];//1-12 Mes del año
    NSInteger year = [dateComponents year];//Año
    //self.textLabel.text = [NSString stringWithFormat:@"%d", month];
    NSString *name;
    switch (month) {
        case 1:
            name = @"urtarrila";
            break;
        case 2:
            name = @"otsaila";
            break;
        case 3:
            name = @"martxoa";
            break;
        case 4:
            name = @"apirila";
            break;
        case 5:
            name = @"maiatza";
            break;
        case 6:
            name = @"ekaina";
            break;
        case 7:
            name = @"uztaila";
            break;
        case 8:
            name = @"abuztua";
            break;
        case 9:
            name = @"iraila";
            break;
        case 10:
            name = @"urria";
            break;
        case 11:
            name = @"azaroa";
            break;
        case 12:
            name = @"abendua";
            break;
    }
    name = [[name stringByAppendingString:@" "] stringByAppendingString:[NSString stringWithFormat:@"%d",year]];
    self.textLabel.text = name;
    //Cambiar nombre del mes aqui
}

- (void)setBackgroundColor:(UIColor *)backgroundColor;
{
    [super setBackgroundColor:backgroundColor];
    for (UILabel *label in self.headerLabels) {
        label.backgroundColor = backgroundColor;
        
        
    }
}

@end
