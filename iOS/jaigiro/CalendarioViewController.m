//
//  CalendarioViewController.m
//  jaigiro
//
//  Created by Sergio Garcia on 04/11/13.
//  Copyright (c) 2013 Irontec S.L. All rights reserved.
//

#import "CalendarioViewController.h"
#import "TSQTACalendarRowCell.h"
#import "InguruViewController.h"
#import "TimesSquare.h"


@interface CalendarioViewController () <TSQCalendarViewDelegate>

@end


@interface TSQCalendarView (AccessingPrivateStuff)

@property (nonatomic, readonly) UITableView *tableView;

@end


@implementation CalendarioViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Atzera" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
}

- (void)viewDidLayoutSubviews;
{
    [(TSQCalendarView *)self.view scrollToDate:[NSDate date] animated:YES];
}

#pragma mark Calendar datasource, delegate and customize

- (void)loadView;
{
    TSQCalendarView *calendarView = [[TSQCalendarView alloc] init];
    calendarView.delegate = self;
    calendarView.calendar = self.calendar;
    [calendarView.calendar setFirstWeekday:2];
    calendarView.rowCellClass = [TSQTACalendarRowCell class];
    calendarView.firstDate = [NSDate dateWithTimeIntervalSinceNow:0];
    calendarView.lastDate = [NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24 * 365 * 1];
    [calendarView setBackgroundColor:[UIColor whiteColor]];
    calendarView.pagingEnabled = YES;
    CGFloat onePixel = 1.0f / [UIScreen mainScreen].scale;
    calendarView.contentInset = UIEdgeInsetsMake(0.0f, onePixel, 0.0f, onePixel);
    
    self.view = calendarView;
}

- (void)setCalendar:(NSCalendar *)calendar;
{
    _calendar = calendar;
    self.navigationItem.title = calendar.calendarIdentifier;
    self.tabBarItem.title = calendar.calendarIdentifier;
}

- (void)calendarView:(TSQCalendarView *)calendarView didSelectDate:(NSDate *)date
{
    NSCalendarUnit unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *dateComponents = [calendarView.calendar components:unitFlags fromDate:date];
    NSInteger selectedYear = [dateComponents year];
    NSInteger selectedMonth = [dateComponents month];
    NSInteger selectdDay = [dateComponents day];
    NSLog(@"Selected: %d:%d:%d", selectdDay, selectedMonth, selectedYear);
    
    NSDate *todayDate = [NSDate dateWithTimeIntervalSinceNow:0];
    dateComponents = [calendarView.calendar components:unitFlags fromDate:todayDate];
    NSInteger todayYear = [dateComponents year];
    NSInteger todayMonth = [dateComponents month];
    NSInteger todayDay = [dateComponents day];
    NSLog(@"Today   : %d:%d:%d", todayDay, todayMonth, todayYear);
    
    if ([date compare:todayDate] == NSOrderedDescending) {
        NSLog(@"date is later than todayDate");
        //correcto
        InguruViewController *vc = [[InguruViewController alloc]init];
        vc.dateLimit = [NSString stringWithFormat:@"%d-%d-%d", selectedYear, selectedMonth, selectdDay];
        vc.isCalendar = YES;
        [self.navigationController pushViewController:vc animated:YES];
        
    } else {
        if(selectdDay == todayDay){
            NSLog(@"dates are the same");
            //mismo dia
            InguruViewController *vc = [[InguruViewController alloc]init];
            vc.dateLimit = [NSString stringWithFormat:@"%d-%d-%d", selectedYear, selectedMonth, selectdDay];
            vc.isCalendar = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            NSLog(@"date is earlier than todayDate");

            NSInteger daysToAdd = 1;
            
            // set up date components
            NSDateComponents *components = [[NSDateComponents alloc] init];
            [components setDay:daysToAdd];
            
            
            NSDate *tomorrowDate = [calendarView.calendar dateByAddingComponents:components toDate:todayDate options:0];
            calendarView.selectedDate = tomorrowDate;
            NSLog(@"Tomorrow date: %@", tomorrowDate);
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops!"
                                                            message:@"Ezin dau egun hori aukeratu, biharko eguna aukeratzen da."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            //error
        }
    }
}

@end
