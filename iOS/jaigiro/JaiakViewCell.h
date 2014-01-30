//
//  JaiakViewCell.h
//  jaigiro
//
//  Created by Sergio Garcia on 05/11/13.
//  Copyright (c) 2013 Irontec S.L. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JaiakViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *dataView;
@property (weak, nonatomic) IBOutlet UIImageView *imgKartela;
@property (weak, nonatomic) IBOutlet UILabel *lblPueblo;
@property (weak, nonatomic) IBOutlet UILabel *lblFecha;
@property (weak, nonatomic) IBOutlet UILabel *lblNombreFiesta;

@end
