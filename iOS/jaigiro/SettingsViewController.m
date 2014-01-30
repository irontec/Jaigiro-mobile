//
//  SettingsViewController.m
//  jaigiro
//
//  Created by Sergio Garcia on 18/11/13.
//  Copyright (c) 2013 Irontec S.L. All rights reserved.
//

#import "SettingsViewController.h"
#import "Login.h"
#import "PMCalendar.h"

@interface SettingsViewController (){
    UILabel *help, *empty;
    NSDate *userDate;
    NSInteger userDist;
}
@property (nonatomic, strong) PMCalendarController *pmCC;
@end

@implementation SettingsViewController

@synthesize pmCC;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setOutletParams];
    [self customizeOutlets];
    _spinnerDist.minimumValue = 0;
    _spinnerDist.maximumValue = 500;
    _spinnerDist.value = 50;

}

-(void) viewDidAppear:(BOOL)animated
{
    userDist = [Login getMaxDistance];
    userDate = [Login getMaxDateDate];
    [self setOutletParams];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [help removeFromSuperview];
    [empty removeFromSuperview];
}

#pragma mark Customize views

-(void) setOutletParams
{
    _spinnerDist.value = userDist;
    _lblDist.text = [NSString stringWithFormat:@"%d km",userDist];
    
    _lblDate.text = [Login getMaxDateString];
}

-(void) customizeOutlets
{
    _spinnerDist.backgroundColor = [UIColor clearColor];
    
    UIColor *col;
    col = [UIColor colorWithRed:255/255.0 green:0/255.0 blue:153/255.0 alpha:0.90];
    [_spinnerDist setMinimumTrackTintColor:col];
    col = [UIColor colorWithRed:255/255.0 green:0/255.0 blue:153/255.0 alpha:0.6];
    [_spinnerDist setMaximumTrackTintColor:col];
    col = [UIColor colorWithRed:255/255.0 green:0/255.0 blue:153/255.0 alpha:1.0];
    col = [UIColor whiteColor];
    [_spinnerDist setThumbTintColor:col];
}

#pragma mark Outlets actions

- (IBAction)spinnerChange:(id)sender {
    UISlider *slid = sender;
    NSInteger dist = (int) slid.value;
    if(dist <= 50){
        dist = 50;
    }
    userDist = (int)dist;
    [Login setMaxDistance:userDist];
    _spinnerDist.value = userDist;
    _lblDist.text = [[NSString stringWithFormat:@"%d", userDist] stringByAppendingString:@" km"];
}

- (IBAction)buttonCalendar:(id)sender {
    self.pmCC = [[PMCalendarController alloc] init];
    pmCC.delegate = self;
    pmCC.mondayFirstDayOfWeek = YES;
    pmCC.allowsPeriodSelection = NO;
    
    [pmCC presentCalendarFromView:sender
         permittedArrowDirections:PMCalendarArrowDirectionAny
                         animated:YES];
}


#pragma mark Calendar delegate

- (void)calendarController:(PMCalendarController *)calendarController didChangePeriod:(PMPeriod *)newPeriod
{
    NSDate *fecha = newPeriod.endDate;
    NSLog(@"Click: %@", fecha);//devuelve el dia anterior escogido

    NSDate *todayDate = [NSDate dateWithTimeIntervalSinceNow:0];
    
    if ([fecha compare:todayDate] == NSOrderedAscending) {
        
        [self textAnim];
        fecha = todayDate;
        
    }else{
        [calendarController dismissCalendarAnimated:YES];
    }
    userDate = fecha;
    [Login setMaxtDate:userDate];
    _lblDate.text = [Login getMaxDateString];
}

#pragma mark Error text anim

-(void) textAnim
{
    [help removeFromSuperview];
    [empty removeFromSuperview];
    NSInteger lblHeig = 20;
    CGRect frame = self.view.frame;
    frame.size.height = lblHeig;
    frame.origin.y = -lblHeig;
    help = [[UILabel alloc]initWithFrame:frame];//sdsR:51 G:181 B:229
    help.backgroundColor = [UIColor colorWithRed:51/255.0 green:(181/255.0) blue:229/255.0 alpha:1];
    help.textAlignment = NSTextAlignmentCenter;
    help.tag = 123123;
    [help setFont:[UIFont fontWithName:@"Helvetica" size:13]];
    [help setNumberOfLines:2];
    
    
    help.text = @"Ezin da egun hori aukeratu, gaurko eguna jartzen da.";
    [self.view addSubview:help];
    [UIView animateWithDuration:1.0 animations:^{
        CGRect fram = help.frame;
        fram.origin.y = 0;
        help.frame = fram;
    } completion:^(BOOL finished) {
        if(finished){
            empty = [[UILabel alloc]init];
            empty.backgroundColor = [UIColor clearColor];
            empty.tag = 123123;
            CGRect fr = help.frame;
            fr.size.height = 0;
            fr.origin.y = 0;
            empty.frame = fr;
            [UIView animateWithDuration:3.0 animations:^{
                //perder tiempo
                [self.view addSubview:empty];
                CGRect fr = help.frame;
                fr.origin.y = -60;
                empty.frame=fr;
            } completion:^(BOOL finished) {
                if(finished){
                    [empty removeFromSuperview];
                    [UIView animateWithDuration:1.5 animations:^{
                        CGRect fram = help.frame;
                        fram.origin.y = -lblHeig;
                        help.frame = fram;
                    } completion:^(BOOL finished) {
                        [help removeFromSuperview];
                    }];
                }
            }];
        }
    }];
}

@end
