//
//  MenuViewController.m
//  Banda Beat
//
//  Created by Iker Mendilibar Fernandez on 24/09/13.
//  Copyright (c) 2013 Irontec S.L. All rights reserved.
//

#import "MenuViewController.h"
#import "UIColor+Jaigiro.h"
#import "Login.h"
#import "MenuCell.h"
#import "MenuUserCell.h"
#import <QuartzCore/QuartzCore.h>
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
//#import "IIIUtil.h"
//#import "SDImageCache+IIIThumb.h"

@interface MenuViewController () <UITableViewDataSource, UITableViewDelegate>
{
    __weak IBOutlet UITableView *_tableView;
    NSArray *_menuItems;
}
@end

@implementation MenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _menuItems = @[[[Login getUsermane] uppercaseString], @"Hasiera", @"Mapa", @"Ingurua", @"Egutegia", @"Zer da Jaigiro", @"Saioa amaitu"];
        
            }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_tableView registerNib:[UINib nibWithNibName:@"MenuCell" bundle:nil] forCellReuseIdentifier:@"MenuCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"MenuUserCell" bundle:nil] forCellReuseIdentifier:@"MenuUserCell"];

    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        CGRect frame = _tableView.frame;
        frame.origin.y = 20;
        _tableView.frame = frame;
    }

}

- (void) viewDidAppear:(BOOL)animated
{
    [self.view setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7f]];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    

    NSInteger row = indexPath.row;
    if(row == 0){
        MenuUserCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"MenuUserCell"];
        
        UIImage *image = [UIImage imageNamed:@"placeholder_user.png"];
        [cell.imageProfile setImage:image];
        NSString *url = [Login getProfilePhotoUrl];
        
        
        if(url.length >0){
            [cell.imageProfile setImageWithURL:[NSURL URLWithString:url] placeholderImage:image];
        }
        
        cell.imageProfile.layer.cornerRadius = 32;
        cell.imageProfile.layer.masksToBounds = YES;
        cell.imageProfile.layer.borderWidth = 3;
        cell.imageProfile.layer.borderColor = [UIColor whiteColor].CGColor;
        
        cell.lblUsername.text = [_menuItems objectAtIndex:row];
        //cell.lblUsername.textColor = [UIColor_Jaigiro getColor:1];
        cell.lblUsername.textColor = [UIColor whiteColor];
        
        //cell.contentView.backgroundColor = [UIColor whiteColor];
        [cell.contentView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3f]];
        return cell;
    }else{
        MenuCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"MenuCell"];
        cell.lblOption.text = [_menuItems objectAtIndex:row];
        //cell.backgroundColor = [UIColor blueColor];

        switch (row) {
            case 1:
                [cell.imgCat setImage:[UIImage imageNamed:@"rounded.png"]];
//                [cell.lblOption setTextColor:[UIColor_Jaigiro getColor:1]];
                break;
            case 4:
                [cell.imgCat setImage:[UIImage imageNamed:@"calendarMenu.png"]];
//                [cell.lblOption setTextColor:[UIColor_Jaigiro getColor:1]];
                break;
                
                
            case 2:
                [cell.imgCat setImage:[UIImage imageNamed:@"flag.png"]];
//                [cell.lblOption setTextColor:[UIColor_Jaigiro getColor:2]];
                break;
            case 5:
                [cell.imgCat setImage:[UIImage imageNamed:@"personal.png"]];
//                [cell.lblOption setTextColor:[UIColor_Jaigiro getColor:2]];
                break;
                
            case 3:
                [cell.imgCat setImage:[UIImage imageNamed:@"sphere.png"]];
//                [cell.lblOption setTextColor:[UIColor_Jaigiro getColor:0]];
                break;

            case 6:
                [cell.imgCat setImage:[UIImage imageNamed:@"power.png"]];
//                [cell.lblOption setTextColor:[UIColor_Jaigiro getColor:0]];
                break;
        }

        //Hacer menos transparente la celda de usuario
        //[cell setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2f]];
        return cell;
        
    }
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 6){
        //logout
        [self logout];
    }else{
        [_delegate loadControllerWithIndex:indexPath.row];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
        return 115;
    return 50;
}

- (void)logout
{
//    [[FBSession activeSession] close];
    [[FBSession activeSession]closeAndClearTokenInformation];
    [Login logout];
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    [appDelegate setFirstLaunch:YES];
    [appDelegate loadFirstController];
    
}

@end
