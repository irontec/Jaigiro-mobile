//
//  LoginViewController.h
//  jaigiro
//
//  Created by Sergio Garcia on 12/11/13.
//  Copyright (c) 2013 Irontec S.L. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface LoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIView *nameView;

@property (weak, nonatomic) IBOutlet FBLoginView *loginFB;
@property (weak, nonatomic) IBOutlet UIButton *loginTwitter;
@property (weak, nonatomic) IBOutlet UIButton *loginInvitado;

- (IBAction)loginTwitterAction:(id)sender;
- (IBAction)btnInvitadoAction:(id)sender;

+ (void) getTwUserInfo:(ACAccount *)twitterAccount;

@end
