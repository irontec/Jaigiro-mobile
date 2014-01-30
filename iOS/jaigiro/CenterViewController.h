//
//  CenterViewController.h
//  Banda Beat
//
//  Created by Iker Mendilibar Fernandez on 24/09/13.
//  Copyright (c) 2013 Irontec S.L. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MenuViewController.h"

@protocol CenterViewControllerDelegate <NSObject>

@optional
- (void)movePanelLeft;
- (void)movePanelRight;

@required
- (void)movePanelToOriginalPosition;

@end

@interface CenterViewController : UIViewController <MenuViewControllerDelegate>
@property (nonatomic, assign) id<CenterViewControllerDelegate> delegate;
@property (nonatomic, strong) UIBarButtonItem *menuButton;
- (void)loadControllerWithIndex:(NSInteger)index;
@end
