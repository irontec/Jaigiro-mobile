//
//  MenuViewController.h
//  Banda Beat
//
//  Created by Iker Mendilibar Fernandez on 24/09/13.
//  Copyright (c) 2013 Irontec S.L. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MenuViewControllerDelegate <NSObject>
@required
- (void)loadControllerWithIndex:(NSInteger)index;
@end

@interface MenuViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign) id<MenuViewControllerDelegate> delegate;
@end
