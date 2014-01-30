//
//  MapaViewController.h
//  jaigiro
//
//  Created by Sergio Garcia on 04/11/13.
//  Copyright (c) 2013 Irontec S.L. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

extern NSInteger const mapHeight;
extern NSInteger const imgHeight;

@interface MapaViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource>{
    CLLocationManager *locationManager;
}
@property (nonatomic,retain) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *extraView;
@property (weak, nonatomic) IBOutlet UIView *touchView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lblZerrendaMsg;
@property (weak, nonatomic) IBOutlet UIView *emptyView;
@property (weak, nonatomic) IBOutlet UILabel *emptyMessage;

@property (weak, nonatomic) IBOutlet UIButton *btnCenterMap;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topDistanceConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomHeighConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomHeighConstraintForEmpty;

- (IBAction)centerMap:(id)sender;

@end

