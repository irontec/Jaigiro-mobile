//
//  NewEkintzaViewController.h
//  jaigiro
//
//  Created by Sergio Garcia on 10/01/14.
//  Copyright (c) 2014 Irontec S.L. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Jaia.h"

@interface NewEkintzaViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewHeighConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollBottomConstraint;
@property (weak, nonatomic) IBOutlet UITextField *txtTitulo;
@property (weak, nonatomic) IBOutlet UITextView *textDescr;
@property (weak, nonatomic) IBOutlet UITextField *txtFecha;
@property (weak, nonatomic) IBOutlet UITextField *txtHora;

@property (weak, nonatomic) IBOutlet UIView *separatorView;

@property (weak, nonatomic) Jaia *jaia;
@property (weak, nonatomic) IBOutlet UILabel *lblIzena;
@property (weak, nonatomic) IBOutlet UILabel *lblDesc;
@property (weak, nonatomic) IBOutlet UILabel *lblOrdua;
@property (weak, nonatomic) IBOutlet UILabel *lblEguna;
@property (weak, nonatomic) IBOutlet UILabel *lblMes;
- (IBAction)btnDataClick:(id)sender;
- (IBAction)btnOrduaClick:(id)sender;

@end
