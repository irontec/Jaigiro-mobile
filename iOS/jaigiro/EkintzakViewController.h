//
//  EkintzakViewController.h
//  jaigiro
//
//  Created by Sergio Garcia on 10/01/14.
//  Copyright (c) 2014 Irontec S.L. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Jaia.h"

@interface EkintzakViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *emptyView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) Jaia *jaia;

@end
