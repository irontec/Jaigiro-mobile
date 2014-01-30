//
//  AppDelegate.h
//  jaigiro
//
//  Created by Asier Fernandez on 02/10/13.
//  Copyright (c) 2013 Irontec S.L. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void) setFirstLaunch:(BOOL)state;
- (void) loadFirstController;
- (void)loadLoginController;
- (void)loadMainController;

@end
