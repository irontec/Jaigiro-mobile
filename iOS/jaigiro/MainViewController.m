//
//  MainViewController.m
//  Banden Lehia
//
//  Created by Iker Mendilibar on 22/10/12.
//  Copyright (c) 2012 Irontec S.L. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MainViewController.h"
#import "CenterViewController.h"
#import "MenuViewController.h"
#import "AppDelegate.h"

#define CENTER_TAG 1
#define MENU_PANEL_TAG 2

#define CORNER_RADIUS 4

#define SLIDE_TIMING .25
#define PANEL_WIDTH 220
#define PANEL_ORIGIN_Y 64.0f


@interface MainViewController () <CenterViewControllerDelegate, MenuViewControllerDelegate, UIGestureRecognizerDelegate>
{
    BOOL isMenuOpen;
    CenterViewController *_centerViewController;
    MenuViewController *_menuViewController;
    UINavigationController *_navController;
    __weak IBOutlet UIView *_containerView;
    //UIView *napa;//ñapa
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerTopSpaceConstraint;
@end

@implementation MainViewController


-(void)viewDidLoad
{
    
    [super viewDidLoad];
    [self setupView];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
    [tapRecognizer setDelegate:self];
    [tapRecognizer setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapRecognizer];

    
}

//Cerrar el menu tocando la vista central, no solo con el boton Menu
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint point = [touch locationInView:self.view];
    if(isMenuOpen){//is menu opened -> close
        CGRect rect = _centerViewController.view.frame;
        rect.origin.x = _menuViewController.view.frame.size.width;
        rect.size.width = rect.size.width - _menuViewController.view.frame.size.width;
        BOOL xRange = point.x >= rect.origin.x && point.x <= rect.origin.x+rect.size.width;
        BOOL yRange = point.y >= rect.origin.y && point.y <= rect.origin.y+rect.size.height;
        //close menu
        if(xRange && yRange) {
            [self movePanelToOriginalPosition];
            return YES;//Indicamos que hemos usado el touch
        }
    }
    return NO;//Indicamos que no hemos usado el touch, que siga la ejecucion el padre
}

- (void)dealloc
{
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark  Menu delegate

- (void)loadControllerWithIndex:(NSInteger)index
{
    [_centerViewController loadControllerWithIndex:index];
}

#pragma mark Setup View

-(void)setupView
{
    [_containerView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    
	_centerViewController = [[CenterViewController alloc] initWithNibName:@"CenterViewController" bundle:nil];
	_centerViewController.view.tag = CENTER_TAG;
	_centerViewController.delegate = self;
    _menuViewController.delegate = self;
    
    _navController = [[UINavigationController alloc] initWithRootViewController:_centerViewController];
    _navController.navigationBar.translucent = NO;
    
    
    
    _navController.view.frame = _containerView.frame;
	[_containerView addSubview:_navController.view];
	[self addChildViewController:_navController];
	[_navController didMoveToParentViewController:self];
    
    
        
}





-(void)resetMainView
{
	if (_menuViewController != nil) {

        
        [UIView animateWithDuration:SLIDE_TIMING animations:^{
            CGRect fram = _menuViewController.view.frame;
            fram.origin.x = 0 - fram.size.width;
            [_menuViewController.view setFrame:fram];
        } completion:^(BOOL finished) {
            if(finished){
                [_menuViewController.view removeFromSuperview];
            }
        }];
		_menuViewController = nil;
		_centerViewController.menuButton.tag = 1;
        isMenuOpen = NO;
	}
}

-(UIView *)getLeftView
{
	if (_menuViewController == nil)	{
		_menuViewController = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
		_menuViewController.view.tag = MENU_PANEL_TAG;
		_menuViewController.delegate = _centerViewController;
        
        CGRect frame = _menuViewController.view.frame;
        frame = CGRectMake(0, PANEL_ORIGIN_Y, PANEL_WIDTH, self.view.frame.size.height);
        frame.origin.x = 0 - PANEL_WIDTH;
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
            frame.origin.y = frame.origin.y - 20;
        }
        [_menuViewController.view setFrame:frame];
        [self addChildViewController:_menuViewController];
        [self.view addSubview:_menuViewController.view];
        [UIView animateWithDuration:SLIDE_TIMING animations:^{
            CGRect fram = _menuViewController.view.frame;
            fram.origin.x = 0 + PANEL_WIDTH;
            if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
                fram.origin.y = frame.origin.y - 20;
            }
            [_menuViewController.view setFrame:fram];
        }];
		
        
		
		[_menuViewController didMoveToParentViewController:self];
        
        //-20 para corregir la posicion en ios 6.1 o menos
        float origin = PANEL_ORIGIN_Y;
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
            origin = origin - 20;
        }
        //x-y-widh/heig
		_menuViewController.view.frame = CGRectMake(0, origin, PANEL_WIDTH, self.view.frame.size.height);
	}
    
	UIView *view = _menuViewController.view;
	return view;
}


#pragma mark Delegate

-(void)movePanelRight
{
    
    /*
    //ñapa para que el status bar siempre se mantenga negro con letra blanca
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        
    } else {
        CGRect frame = [UIScreen mainScreen].applicationFrame;
        frame.origin.y = 0;
        frame.size.height = 20;
        napa = [[UIView alloc] initWithFrame:frame];
        napa.backgroundColor = [UIColor blackColor];
        [self.view addSubview:napa];
    }
    */
	UIView *childView = [self getLeftView];
    
    //[self.view sendSubviewToBack:childView];
    
    _navController.visibleViewController.view.userInteractionEnabled = NO;
    _centerViewController.menuButton.tag = 0;
    isMenuOpen = YES;
    /*
	[self.view sendSubviewToBack:childView];
    
    [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        _containerView.frame = CGRectMake(_containerView.frame.size.width - PANEL_WIDTH, 0, _containerView.frame.size.width, _containerView.frame.size.height);
    }
	 completion:^(BOOL finished) {
		 if (finished) {
             _navController.visibleViewController.view.userInteractionEnabled = NO;
			 _centerViewController.menuButton.tag = 0;
             
             
		 }
	 }];
     */
}

-(void)movePanelToOriginalPosition
{
    
    
    
	[UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        _containerView.frame = CGRectMake(0, 0, _containerView.frame.size.width, _containerView.frame.size.height);
	 }
	 completion:^(BOOL finished) {
		 if (finished) {
             _navController.visibleViewController.view.userInteractionEnabled = YES;
			 [self resetMainView];
             
             /*
             //ñapa para que el status bar siempre se mantenga negor con letra blanca
             if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
                 
             } else {
                 [napa removeFromSuperview];
             }
              */
		 }
	 }];
}

@end
