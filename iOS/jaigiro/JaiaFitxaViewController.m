//
//  JaiaFitxaViewController.m
//  jaigiro
//
//  Created by Sergio Garcia on 06/11/13.
//  Copyright (c) 2013 Irontec S.L. All rights reserved.
//

#import "UIColor+Jaigiro.h"
#import "JaiaFitxaViewController.h"
#import "JaigiroAPIClient.h"
#import "Login.h"
#import "DateHelper.h"
#import "EkintzakViewController.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"

static NSString * const shareText = @"! Bazatoz? Jaitsi #jaigiro aplikazioa dohainik: www.jaigiro.net";


//share
#define BLUR_TIME 0.2f
#define SLIDE_TIME 0.5f

@interface JaiaFitxaViewController () <UIGestureRecognizerDelegate> {
    UILabel *help, *empty;
    //Touch control
    BOOL slidingView, moveUPDir;
    float beforePost;
    NSInteger SLIDE_INITIAL_POSITION;
}

@end

@implementation JaiaFitxaViewController

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
    slidingView = NO;
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(handleGesture:)];
    panGestureRecognizer.delegate = self;
    panGestureRecognizer.minimumNumberOfTouches = 1;
    panGestureRecognizer.maximumNumberOfTouches = 1;
    [self.view addGestureRecognizer:panGestureRecognizer];
    
    UIBarButtonItem *ekintzak = [[UIBarButtonItem alloc]initWithTitle:@"Ekintzak" style:UIBarButtonItemStyleBordered target:self action:@selector(ekintzakIkusi:)];
    self.navigationItem.rightBarButtonItem = ekintzak;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Atzera" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    if(!self.backImg.image){
        NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:_jaia.url_kartela]cachePolicy:NSURLCacheStorageAllowed timeoutInterval:5];
        [self.backImg setImageWithURLRequest:req placeholderImage:[UIImage imageNamed:@"placeholder_jaia"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            self.backImg.image = image;
            [self.backImg setContentMode:UIViewContentModeScaleAspectFill];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            
        }];
    }
    
    [_lblPueblo sizeToFit];
    _lblPueblo.text = [@" "stringByAppendingString:[_jaia.herria stringByAppendingString:@" "]];
    [_lblPueblo sizeToFit];
    _lblFecha.text = [DateHelper pretyDate:_jaia.hasiera end:_jaia.bukaera];
    
    [_lblNombreFiesta sizeToFit];
    _lblNombreFiesta.text = _jaia.izena;
    
    _txtDescripcion.text = _jaia.deskribapena;
    [_txtDescripcion setTextColor:[UIColor whiteColor]];
    [_txtDescripcion  setFont: [UIFont fontWithName:@"Helvetica" size:15]];
    _txtDescripcion.textAlignment = NSTextAlignmentJustified;
    
    
    [self setColors];
    
    _fbView.layer.borderColor = [UIColor blackColor].CGColor;
    _fbView.layer.borderWidth = 1.0f;
    
    _twView.layer.borderColor = [UIColor blackColor].CGColor;
    _twView.layer.borderWidth = 1.0f;
    
    _waView.layer.borderColor = [UIColor blackColor].CGColor;
    _waView.layer.borderWidth = 1.0f;
    
    _emView.layer.borderColor = [UIColor blackColor].CGColor;
    _emView.layer.borderWidth = 1.0f;
    
    _cpView.layer.borderColor = [UIColor blackColor].CGColor;
    _cpView.layer.borderWidth = 1.0f;
    
    NSInteger col = _jaia.colorSelector;
    UIImage *back;
    switch (col) {
        case 0:
            back = [UIImage imageNamed:@"green_px.png"];
            break;
        case 1:
            back = [UIImage imageNamed:@"pink_px.png"];
            break;
        case 2:
            back = [UIImage imageNamed:@"blue_px.png"];
            break;
            
    }
    [_fbButton setBackgroundImage:back forState:UIControlStateHighlighted];
    [_twButton setBackgroundImage:back forState:UIControlStateHighlighted];
    [_waButton setBackgroundImage:back forState:UIControlStateHighlighted];
    [_emButton setBackgroundImage:back forState:UIControlStateHighlighted];
    [_cpButton setBackgroundImage:back forState:UIControlStateHighlighted];
}

-(void) viewWillAppear:(BOOL)animated
{
    [self deleteMessageView];
    _topDatosConstraint.constant = self.view.frame.size.height - self.datosView.frame.size.height -self.bottomView.frame.size.height;
    SLIDE_INITIAL_POSITION = _topDatosConstraint.constant;
}

-(void) viewWillDisappear:(BOOL)animated
{
    [help removeFromSuperview];
    [empty removeFromSuperview];
}

- (void)ekintzakIkusi:(id)sender
{
    EkintzakViewController *vc = [[EkintzakViewController alloc]init];
    vc.jaia = _jaia;
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark Customize Views

-(void)setColors
{
    [_datosView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7f]];
    
    NSInteger colSel = _jaia.colorSelector;
    NSInteger ant;
    
    if (colSel == 0) {
        ant = 2;
    }else{
        ant = colSel-1;
    }
    UIColor *pres = [UIColor_Jaigiro getColor:ant];
    UIColor *c = [UIColor_Jaigiro getColor:colSel] ;
    _bottomView.backgroundColor = [c colorWithAlphaComponent:0.75f];
    
    _lblPueblo.backgroundColor = c;
    _lblFecha.textColor = c;
    _lblNombreFiesta.textColor = c;
    
    [self setBanatorColor];
    [_btnShare setTitleColor:c forState:UIControlStateNormal];
    [_btnShare setTitleColor:pres forState:UIControlStateHighlighted];
}

-(void)setBanatorColor
{
    NSInteger colSel = _jaia.colorSelector;
    NSInteger ant;
    if (colSel == 0) {
        ant = 2;
    }else{
        ant = colSel-1;
    }
    UIColor *pres = [UIColor_Jaigiro getColor:ant];
    UIColor *c = [UIColor_Jaigiro getColor:colSel];
    
    [_btnBanator setTitleColor:c forState:UIControlStateNormal];
    [_btnBanator setTitleColor:pres forState:UIControlStateHighlighted];
    if(_jaia.banator == 0){
        //no va
        [_btnBanator setBackgroundColor:[UIColor whiteColor]];
    }else{
        //si va
        [_btnBanator setBackgroundColor:[UIColor_Jaigiro getBackgroundBanator]];
        self.btnBanator.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"fondo_banator.png"]];
    }
}

#pragma mark Banator Action

- (IBAction)btnBanator:(id)sender {
    self.btnBanator.enabled = NO;
    NSMutableDictionary *params = [Login getLoginParams];
    [params setValue:[NSString stringWithFormat:@"%d",_jaia.id_jaia] forKey:@"idJai"];
    [[JaigiroAPIClient sharedClient] postPath:@"banator" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger error = [[responseObject objectForKey:@"error"] integerValue];
        NSInteger message = [[responseObject objectForKey:@"message"] integerValue];
        
        if(error == 0){
            _jaia.banator = message;
            [self setBanatorColor];
            self.btnBanator.enabled = YES;
        }else{
            //ERROR
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self btnBanator:nil];
        //        NSLog(@"TIMEOUT");
    }];
    
}



#pragma mark Share Actions

- (IBAction)btnShare:(id)sender {
    _translucentView.hidden = NO;
    
    //separacion entre 1er botom y titulo inicial 16.
    CGRect frame = _shareView.frame;
    frame.origin.y = _translucentView.frame.size.height;
    [_shareView setFrame:frame];
    _shareView.hidden = NO;
    
    CGFloat borderWidth = 1.5f;
    UIColor *col = [[UIColor_Jaigiro getColor:_jaia.colorSelector]colorWithAlphaComponent:0.6f];
    _buttonsView.frame = CGRectInset(_buttonsView.frame, -borderWidth, -borderWidth);
    _buttonsView.layer.borderColor = col.CGColor;
    _buttonsView.layer.borderWidth = borderWidth;
    _separatorView.backgroundColor = col;
    
    [UIView animateWithDuration:BLUR_TIME animations:^{
        [_translucentView setBackgroundColor:[[UIColor whiteColor]colorWithAlphaComponent:0.9]];
    } completion:^(BOOL finished) {
        //meter botones
        [UIView animateWithDuration:SLIDE_TIME animations:^{
            CGRect shareFrame = _shareView.frame;
            shareFrame.origin.y = 0;
            shareFrame.size.height = _translucentView.frame.size.height;
            shareFrame.size.width = _translucentView.frame.size.width;
            [_shareView setFrame:shareFrame];
        } completion:^(BOOL finished) {
            
        }];
    }];
}

- (IBAction)closeShareAction:(id)sender {
    [self deleteMessageView];
    [UIView animateWithDuration:BLUR_TIME animations:^{
        CGRect shareFrame = _shareView.frame;
        shareFrame.origin.y = _translucentView.frame.size.height;
        [_shareView setFrame:shareFrame];
    } completion:^(BOOL finished) {
        _shareView.hidden = YES;
        [UIView animateWithDuration:SLIDE_TIME animations:^{
            [_translucentView setBackgroundColor:[[UIColor whiteColor]colorWithAlphaComponent:0]];
        } completion:^(BOOL finished) {
            _translucentView.hidden = YES;
        }];
    }];
    
}

- (IBAction)postToTwitter:(id)sender
{
    [self deleteMessageView];
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [tweetSheet setInitialText:[NSString stringWithFormat:@"%@%@",_jaia.izena, shareText]];
        [tweetSheet addImage:self.backImg.image];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }else{
        NSLog(@"Twitter not found");
        [self textAnim];
    }
}

- (IBAction)postToFacebook:(id)sender
{
    [self deleteMessageView];
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [controller setInitialText:[NSString stringWithFormat:@"%@%@",_jaia.izena, shareText]];
        [controller addImage:self.backImg.image];
        [self presentViewController:controller animated:YES completion:Nil];
    }else{
        NSLog(@"Facebook not found");
        [self textAnim];
    }
}

- (IBAction)postToEmail:(id)sender {
    [self deleteMessageView];
    NSString *subject = @"Jaigiro";
    NSString *message = [NSString stringWithFormat:@"%@%@",_jaia.izena, shareText];
    NSURL *emailURL = [NSURL URLWithString:[NSString stringWithFormat:@"mailto:?subject=%@&body=%@", subject, message]];
    if ([[UIApplication sharedApplication] canOpenURL: emailURL]) {
        [[UIApplication sharedApplication] openURL: emailURL];
    }else{
        NSLog(@"Email not found");
        [self textAnim];
    }
}

- (IBAction)postToClipboard:(id)sender {
    [self deleteMessageView];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [NSString stringWithFormat:@"%@%@",_jaia.izena, shareText];
    [self closeShareAction:nil];
}

- (IBAction)postToWhatsApp:(id)sender {
    NSString *message = [NSString stringWithFormat:@"%@%@",_jaia.izena, shareText];
    NSURL *whatsappURL = [NSURL URLWithString:[NSString stringWithFormat:@"whatsapp://send?text=%@",message]];
    if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
        [[UIApplication sharedApplication] openURL: whatsappURL];
    }else{
        NSLog(@"WhatApp not found");
        [self textAnim];
    }
}

-(void) deleteMessageView
{
    [help removeFromSuperview];
    [empty removeFromSuperview];
}

-(void) textAnim
{
    [self deleteMessageView];
    NSInteger lblHeight = 20;
    
    CGRect frame = self.view.frame;
    frame = [[UIScreen mainScreen] bounds];
    frame.size.height = lblHeight;
    frame.origin.y = -lblHeight;
    help = [[UILabel alloc]initWithFrame:frame];
    help.backgroundColor = [[UIColor colorWithRed:51/255.0 green:(181/255.0) blue:229/255.0 alpha:1] colorWithAlphaComponent:0.8f];;
    help.textAlignment = NSTextAlignmentCenter;
    help.tag = 123123;
    [help setFont:[UIFont fontWithName:@"Helvetica" size:13]];
    [help setNumberOfLines:2];
    help.textColor = [UIColor whiteColor];
    
    
    help.text = @"Lehenengoz aplikazioa ipini behar duzu.";
    [self.view addSubview:help];
    [UIView animateWithDuration:1.0f animations:^{
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
                    [UIView animateWithDuration:1.0f animations:^{
                        CGRect fram = help.frame;
                        fram.origin.y = -lblHeight;
                        help.frame = fram;
                    } completion:^(BOOL finished) {
                        [help removeFromSuperview];
                    }];
                }
            }];
        }
    }];
}

#pragma mark Touch Control

- (void)handleGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint velocity = [gestureRecognizer velocityInView:self.view];
    if(velocity.y < 0){
        moveUPDir = YES;
    }else{
        moveUPDir = NO;
    }
    
    CGPoint point = [gestureRecognizer locationInView:self.view];
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        // handle start of gesture
        [self touchesBegan:point];
    } else if ([gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        // handle updated position
        [self touchesMoved:point];
    } else if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
        [self touchesEnded:point];
    }
}

- (void)touchesBegan:(CGPoint)point {
    CGRect rect = self.datosView.frame;
    BOOL xRange = point.x >= rect.origin.x && point.x <= rect.origin.x+rect.size.width;
    BOOL yRange = point.y >= rect.origin.y && point.y <= rect.origin.y+rect.size.height;
    if(xRange && yRange) {
        beforePost = point.y;
        slidingView = YES;
    }
}

- (void)touchesMoved:(CGPoint)point {
    if(slidingView) {
        CGRect rect = self.datosView.frame;
        CGRect newRect = CGRectMake(rect.origin.x, self.datosView.frame.origin.y - (beforePost - point.y)  , rect.size.width, rect.size.height);
        beforePost = point.y;
        if(newRect.origin.y >= SLIDE_INITIAL_POSITION && newRect.origin.y <= self.view.frame.size.height - self.datosView.frame.size.height){
            self.datosView.frame=newRect;
            _topDatosConstraint.constant = self.datosView.frame.origin.y;
        }
    }
}

- (void)touchesEnded:(CGPoint)point {
    if(slidingView) {
        slidingView=NO;
        if (moveUPDir){
            [self hideData:NO time:0.65f];
        }else{
            [self hideData:YES time:0.65f];
        }
    }
}


#pragma mark Move Data View

-(void) hideData:(BOOL)hideData time:(float)time
{
    if(hideData){
        [UIView animateWithDuration:time animations:^{
            CGRect frameData = self.datosView.frame;
            CGRect frameBottom = self.bottomView.frame;
            
            frameData.origin.y = self.view.frame.size.height - frameData.size.height;
            frameBottom.origin.y = self.view.frame.size.height;
            
            self.datosView.frame = frameData;
            self.bottomView.frame = frameBottom;
            
        } completion:^(BOOL finished) {
            _topDatosConstraint.constant = self.datosView.frame.origin.y;
        }];
    }else{
        [UIView animateWithDuration:time animations:^{
            CGRect frameData = self.datosView.frame;
            CGRect frameBottom = self.bottomView.frame;
            
            frameData.origin.y = SLIDE_INITIAL_POSITION;
            frameBottom.origin.y = frameData.origin.y + frameData.size.height;
            
            self.bottomView.frame = frameBottom;
            self.datosView.frame = frameData;
        } completion:^(BOOL finished) {
            _topDatosConstraint.constant = SLIDE_INITIAL_POSITION;
        }];
    }
}


@end
