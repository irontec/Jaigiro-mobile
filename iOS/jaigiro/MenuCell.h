//
//  MenuCell.h
//  jaigiro
//
//  Created by Sergio Garcia on 13/11/13.
//  Copyright (c) 2013 Irontec S.L. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgCat;
@property (weak, nonatomic) IBOutlet UILabel *lblOption;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@end
