//
//  CenterViewController.m
//  Banda Beat
//
//  Created by Iker Mendilibar Fernandez on 24/09/13.
//  Copyright (c) 2013 Irontec S.L. All rights reserved.
//

#import "CenterViewController.h"
#import "JaiakViewController.h"
#import "MapaViewController.h"
#import "CalendarioViewController.h"
#import "InguruViewController.h"
#import "SettingsViewController.h"
#import "SearchViewController.h"
#import "NewJaiaViewController.h"
#import "AboutViewController.h"



@interface CenterViewController ()
{
    NSArray *_controllers;
    NSInteger _currentIndex;
    CGRect _frame;
    
}
@property (nonatomic) NSInteger controllerIndex;
@end

@implementation CenterViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //back button for the next view
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Atzera" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    JaiakViewController *jaiakViewController = [[JaiakViewController alloc]initWithNibName:@"JaiakViewController" bundle:nil];
    MapaViewController *mapaViewConrtoller = [[MapaViewController alloc]initWithNibName:@"MapaViewController" bundle:nil];
    CalendarioViewController *calendarioViewController = [[CalendarioViewController alloc]initWithNibName:@"CalendarioViewcontroller" bundle:nil];
    InguruViewController *inguruViewController = [[InguruViewController alloc]initWithNibName:@"InguruViewController" bundle:nil];
    AboutViewController *aboutViewController = [[AboutViewController alloc]initWithNibName:@"AboutViewController" bundle:nil];
    aboutViewController.fileName = @"about";
    _controllers = @[jaiakViewController, mapaViewConrtoller, inguruViewController, calendarioViewController, aboutViewController];
    
    
    
    UIViewController *toController = [_controllers objectAtIndex:0];
    
    toController.view.frame = self.view.bounds;
    
    [self.view addSubview:toController.view];
    [toController didMoveToParentViewController:self];
    [self addChildViewController:toController];


    UIImage *menuImage = [UIImage imageNamed:@"menu.png"];
    _menuButton = [[UIBarButtonItem alloc] initWithImage:menuImage style:UIBarButtonItemStyleBordered target:self action:@selector(movePanelRight:)];
    _menuButton.tag = 1;
    self.navigationItem.leftBarButtonItem = _menuButton;
    
    UIImage *settingsImage = [UIImage imageNamed:@"config.png"];
    UIBarButtonItem *settings = [[UIBarButtonItem alloc]initWithImage:settingsImage style:UIBarButtonItemStylePlain target:self action:@selector(settingsClick:)];
    
    UIImage *searchImage = [UIImage imageNamed:@"search.png"];
    UIBarButtonItem *search = [[UIBarButtonItem alloc]initWithImage:searchImage style:UIBarButtonItemStylePlain target:self action:@selector(searchClick:)];
    
    UIImage *new = [UIImage imageNamed:@"plus.png"];
    UIBarButtonItem *newJaia = [[UIBarButtonItem alloc]initWithImage:new style:UIBarButtonItemStylePlain target:self action:@selector(newJaiaClick:)];

    NSArray *buttonArray = [NSArray arrayWithObjects:settings, search, newJaia, nil];
    self.navigationItem.rightBarButtonItems = buttonArray;

    
    /*
    //titulo blanco
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    label.textColor = [UIColor whiteColor];
    label.text = @"Prueba";
    label.textAlignment = NSTextAlignmentCenter;
    [label setBackgroundColor:[UIColor clearColor]];
    self.navigationItem.titleView = label;
    */
    

}

- (UIViewController*)getCurrentController
{
    return [_controllers objectAtIndex:_currentIndex];
}

- (void)loadControllerWithIndex:(NSInteger)index
{
    
    if(index == 0){
        //linea nombre -> Cargamos el controlador en la posicion 0
        [self movePanelRight:nil];
        return;
    }else{
        //corregir el index por la linea del nombre, porque el array de controller va de 0 a X.
        index = index - 1;
    }
    
    UIImage *menuImage = [UIImage imageNamed:@"menu.png"];
    _menuButton = [[UIBarButtonItem alloc] initWithImage:menuImage style:UIBarButtonItemStyleBordered target:self action:@selector(movePanelRight:)];
    _menuButton.tag = 1;
    self.navigationItem.leftBarButtonItem = _menuButton;
    
    UIImage *settingsImage = [UIImage imageNamed:@"config.png"];
    UIBarButtonItem *settings = [[UIBarButtonItem alloc]initWithImage:settingsImage style:UIBarButtonItemStylePlain target:self action:@selector(settingsClick:)];
    
    UIImage *searchImage = [UIImage imageNamed:@"search.png"];
    UIBarButtonItem *search = [[UIBarButtonItem alloc]initWithImage:searchImage style:UIBarButtonItemStylePlain target:self action:@selector(searchClick:)];
    
    UIImage *new = [UIImage imageNamed:@"plus.png"];
    UIBarButtonItem *newJaia = [[UIBarButtonItem alloc]initWithImage:new style:UIBarButtonItemStylePlain target:self action:@selector(newJaiaClick:)];
    
    UIImage *centerImage = [UIImage imageNamed:@"map.png"];
    UIBarButtonItem *center = [[UIBarButtonItem alloc]initWithImage:centerImage style:UIBarButtonItemStylePlain target:self action:@selector(centerMap:)];
    
    
    //La posicion 0 es HASIERA -> Lo quitamos en EGUTEGIA
    if(index == 0){
        NSArray *buttonArray = [NSArray arrayWithObjects:settings, search, newJaia,  nil];
        self.navigationItem.rightBarButtonItems = buttonArray;
    } else if(index == 1){
        NSArray *buttonArray = [NSArray arrayWithObjects:settings, search, center, nil];
        self.navigationItem.rightBarButtonItems = buttonArray;
    }else if (index == 3){
        NSArray *buttonArray = [NSArray arrayWithObjects:search, nil];
        self.navigationItem.rightBarButtonItems = buttonArray;
    }else{
        NSArray *buttonArray = [NSArray arrayWithObjects:settings, search, nil];
        self.navigationItem.rightBarButtonItems = buttonArray;
    }
    

    UIViewController *toViewController = [_controllers objectAtIndex:index];
    UIViewController *currentController = [self getCurrentController];
    
    [self transitionFromViewController:currentController toViewController:toViewController completion:^{
        _currentIndex = index;
        [_delegate movePanelToOriginalPosition];
    }];

}


- (void)transitionFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController completion:(void (^)())completion;
{
	if (fromViewController == toViewController)	{
		[_delegate movePanelToOriginalPosition];
        return;
	}
    
	// animation setup
	toViewController.view.frame = self.view.bounds;
	toViewController.view.autoresizingMask = self.view.autoresizingMask;
    
	// notify
	[fromViewController willMoveToParentViewController:nil];
	[self addChildViewController:toViewController];
    
	// transition
	[self transitionFromViewController:fromViewController
					  toViewController:toViewController
							  duration:0.2
							   options:UIViewAnimationOptionTransitionCrossDissolve
							animations:^{
							}
							completion:^(BOOL finished) {
								[toViewController didMoveToParentViewController:self];
								[fromViewController removeFromParentViewController];
                                if (completion != nil) {
                                    completion();
                                }
							}];
}


-(void)movePanelRight:(id)sender {
	UIButton *button = sender;
	switch (button.tag) {
		case 0: {
			[_delegate movePanelToOriginalPosition];
			break;
		}
		case 1: {
			[_delegate movePanelRight];
			break;
		}
	}
}


-(void) settingsClick:(id)sender
{
    if(self.navigationItem.leftBarButtonItem.tag == 0){
        //cerramos el menu si esta abierto
        [_delegate movePanelToOriginalPosition];
    }else{
        SettingsViewController *vc = [[SettingsViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

-(void) searchClick:(id)sender
{
    if(self.navigationItem.leftBarButtonItem.tag == 0){
        //cerramos el menu si esta abierto
        [_delegate movePanelToOriginalPosition];
    }else{
        SearchViewController *vc = [[SearchViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

-(void) newJaiaClick:(id)sender
{
    if(self.navigationItem.leftBarButtonItem.tag == 0){
        //cerramos el menu si esta abierto
        [_delegate movePanelToOriginalPosition];
    }else{
        NewJaiaViewController *vc = [[NewJaiaViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

-(void) centerMap:(id)sender
{
    if(self.navigationItem.leftBarButtonItem.tag == 0){
        //cerramos el menu si esta abierto
        [_delegate movePanelToOriginalPosition];
    }else{
        if(_currentIndex == 1){
            MapaViewController *map = (MapaViewController *)[self getCurrentController];
            [map centerMap:nil];
        }
    }
    
}

@end
