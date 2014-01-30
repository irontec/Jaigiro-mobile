//
//  InguruViewController.h
//  jaigiro
//
//  Created by Sergio Garcia on 12/11/13.
//  Copyright (c) 2013 Irontec S.L. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface InguruViewController : UITableViewController <CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
}
@property (nonatomic, strong) NSString *dateLimit;
@property (strong, nonatomic) IBOutlet UIView *emptyView;
@property (weak, nonatomic) IBOutlet UILabel *emptyText;
@property (nonatomic) BOOL isCalendar;

@end
