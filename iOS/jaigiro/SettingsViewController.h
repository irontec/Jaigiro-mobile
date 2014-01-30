//
//  SettingsViewController.h
//  jaigiro
//
//  Created by Sergio Garcia on 18/11/13.
//  Copyright (c) 2013 Irontec S.L. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMCalendar.h"

@interface SettingsViewController : UIViewController <PMCalendarControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblDist;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;

@property (weak, nonatomic) IBOutlet UISlider *spinnerDist;
- (IBAction)spinnerChange:(id)sender;

- (IBAction)buttonCalendar:(id)sender;

@end
