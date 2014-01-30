//
//  JaiaFitxaViewController.h
//  jaigiro
//
//  Created by Sergio Garcia on 06/11/13.
//  Copyright (c) 2013 Irontec S.L. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Jaia.h"

@interface JaiaFitxaViewController : UIViewController

@property (nonatomic, strong) Jaia *jaia;
@property (strong, nonatomic) IBOutlet UIView *view;

@property (weak, nonatomic) IBOutlet UIImageView *backImg;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIView *datosView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topDatosConstraint;


@property (weak, nonatomic) IBOutlet UILabel *lblPueblo;
@property (weak, nonatomic) IBOutlet UILabel *lblFecha;
@property (weak, nonatomic) IBOutlet UILabel *lblNombreFiesta;
@property (weak, nonatomic) IBOutlet UITextView *txtDescripcion;
@property (weak, nonatomic) IBOutlet UIButton *btnShare;
@property (weak, nonatomic) IBOutlet UIButton *btnBanator;


- (IBAction)btnShare:(id)sender;
- (IBAction)btnBanator:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *translucentView;
@property (weak, nonatomic) IBOutlet UIView *shareView;
@property (weak, nonatomic) IBOutlet UIView *buttonsView;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

- (IBAction)closeShareAction:(id)sender;

- (IBAction)postToFacebook:(id)sender;
- (IBAction)postToTwitter:(id)sender;
- (IBAction)postToWhatsApp:(id)sender;
- (IBAction)postToEmail:(id)sender;
- (IBAction)postToClipboard:(id)sender;


@property (weak, nonatomic) IBOutlet UIView *fbView;
@property (weak, nonatomic) IBOutlet UIView *twView;
@property (weak, nonatomic) IBOutlet UIView *waView;
@property (weak, nonatomic) IBOutlet UIView *emView;
@property (weak, nonatomic) IBOutlet UIView *cpView;

@property (weak, nonatomic) IBOutlet UIButton *fbButton;
@property (weak, nonatomic) IBOutlet UIButton *twButton;
@property (weak, nonatomic) IBOutlet UIButton *waButton;
@property (weak, nonatomic) IBOutlet UIButton *emButton;
@property (weak, nonatomic) IBOutlet UIButton *cpButton;






@end
