//
//  EkintzaCell.h
//  jaigiro
//
//  Created by Sergio Garcia on 10/01/14.
//  Copyright (c) 2014 Irontec S.L. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EkintzaCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *dataView;
@property (weak, nonatomic) IBOutlet UILabel *lblDia;
@property (weak, nonatomic) IBOutlet UILabel *lblMes;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet UILabel *lblTitulo;
@property (weak, nonatomic) IBOutlet UILabel *lblDescripcion;
@property (weak, nonatomic) IBOutlet UILabel *lblHora;

@end
