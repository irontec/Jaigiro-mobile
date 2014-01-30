//
//  SearchViewController.m
//  jaigiro
//
//  Created by Sergio Garcia on 19/11/13.
//  Copyright (c) 2013 Irontec S.L. All rights reserved.
//

#import "SearchViewController.h"
#import "JaiakViewCell.h"
#import "Jaia.h"
#import "UIColor+Jaigiro.h"
#import "JaiaFitxaViewController.h"
#import "Login.h"
#import "JaigiroAPIClient.h"
#import "UIImageView+AFNetworking.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

#define moveMargin 5
#define showTime 0.65f
#define hideTime 1.0f

@interface SearchViewController (){
    NSMutableArray *jaiakArray;
    NSInteger page, totalPages;
    UILabel *help, *empty;
    CGPoint scrollPos;
    BOOL searchShowed;
}

@end

@implementation SearchViewController

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
    
    CGRect posFrame = _txtSearch.frame;
    posFrame.origin.y = posFrame.origin.y - (posFrame.size.height + posFrame.origin.y);
    _txtSearch.frame = posFrame;
    _topTxtConstraint.constant = posFrame.origin.y;
    
    posFrame = _tableView.frame;
    posFrame.origin.y = 0;
    _tableView.frame = posFrame;
    
    posFrame = _emptyView.frame;
    posFrame.origin.y = 0;
    _emptyView.frame = posFrame;
    searchShowed = NO;
    
    UIColor *col = [UIColor colorWithRed:255/255.0 green:0/255.0 blue:153/255.0 alpha:0.75];
    [self.txtSearch setValue:col forKeyPath:@"_placeholderLabel.textColor"];
    [self.txtSearch setTextColor:[UIColor_Jaigiro getColor:1]];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Atzera" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"JaiakViewCell" bundle:nil] forCellReuseIdentifier:@"JaiaCell"];
}

-(void) viewWillAppear:(BOOL)animated
{
    if(!searchShowed){
        [self showSearchBar:YES];
    }
    
    
}
-(void) viewDidAppear:(BOOL)animated
{
    
    self.tableView.contentOffset = scrollPos;
}

-(void) viewWillDisappear:(BOOL)animated
{
    NSIndexPath *selection = [self.tableView indexPathForSelectedRow];
    if (selection) {
        [self.tableView deselectRowAtIndexPath:selection animated:YES];
    }
    scrollPos = self.tableView.contentOffset;
    [empty removeFromSuperview];
    [help removeFromSuperview];
}

#pragma mark Keyboard return action

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if(_txtSearch.text.length>0){
        [help removeFromSuperview];
        [empty removeFromSuperview];
        
        page = 1;
        jaiakArray = [[NSMutableArray alloc]init];
        [jaiakArray removeAllObjects];
        scrollPos.y = 0;
        [self searchJaiak];
    }else{
        [self textAnim];
    }
    [textField resignFirstResponder];
    return YES;
}

#pragma mark Error text anim

-(void) textAnim
{
    [help removeFromSuperview];
    [empty removeFromSuperview];
    NSInteger lblHeight = 20;
    CGRect frame = self.view.frame;
    frame.size.height = lblHeight;
    frame.origin.y = -lblHeight;
    help = [[UILabel alloc]initWithFrame:frame];//sdsR:51 G:181 B:229
    help.backgroundColor = [UIColor colorWithRed:51/255.0 green:(181/255.0) blue:229/255.0 alpha:1];
    help.textAlignment = NSTextAlignmentCenter;
    help.tag = 123123;
    [help setFont:[UIFont fontWithName:@"Helvetica" size:13]];
    [help setNumberOfLines:2];
    
    
    help.text = @"Gutxienez izki bat sartu.";
    [self.view addSubview:help];
    [UIView animateWithDuration:1.5 animations:^{
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
                    [UIView animateWithDuration:2.5 animations:^{
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

#pragma mark Search bar animation

- (void) showSearchBar:(BOOL)show
{
    if(show){
        CGRect posTableViewFrame = _tableView.frame;
        posTableViewFrame.size.height = posTableViewFrame.size.height + 45;
        _tableView.frame = posTableViewFrame;
        
        [UIView animateWithDuration:showTime animations:^{
            CGRect posTxtFrame = _txtSearch.frame;
            posTxtFrame.origin.y = 0;
            _txtSearch.frame = posTxtFrame;
            _topTxtConstraint.constant = posTxtFrame.origin.y;
        } completion:^(BOOL finished) {
//            NSLog(@"Search show");
            searchShowed = YES;
        }];
    }else{
        //ocultamos
        [UIView animateWithDuration:hideTime animations:^{
            CGRect posTxtFrame = _txtSearch.frame;
            posTxtFrame.origin.y = posTxtFrame.origin.y - (posTxtFrame.size.height + moveMargin);
            _txtSearch.frame = posTxtFrame;
            _topTxtConstraint.constant = posTxtFrame.origin.y;
            
            CGRect posTableViewFrame = _tableView.frame;
            posTableViewFrame.origin.y = 0;
            _tableView.frame = posTableViewFrame;
            
            CGRect posEmptyViewFrame = _emptyView.frame;
            posEmptyViewFrame.origin.y = 0;
            _emptyView.frame = posEmptyViewFrame;
            
        } completion:^(BOOL finished) {
//            NSLog(@"Search hide");
            searchShowed = NO;
        }];
    }
}


#pragma mark Load data

-(void) searchJaiak
{
    NSMutableDictionary *params = [Login getLoginParams];
    [params setValue:_txtSearch.text forKey:@"search"];
    [params setValue:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    [params setValue:@"21" forKey:@"items"];
    
    [[JaigiroAPIClient sharedClient] postPath:@"search-jaiak" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        totalPages = [[responseObject objectForKey:@"orriKop"]integerValue];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        
        NSMutableArray *jai = [[NSMutableArray alloc]init];
        jai = [responseObject objectForKey:@"jaiak"];
        
        NSInteger tam;
        @try {
            tam = jai.count;
        }
        @catch (NSException * e) {
            //NSLog(@"Exception: %@", e);
            tam = 0;
        }
        
        NSInteger colSel=0;
        for(NSInteger x=0;x<tam;x++){
            Jaia *j = [[Jaia alloc]init];
            j.banator = [[[jai objectAtIndex:x]objectForKey:@"banator"] integerValue];
            NSString *dateString = [[jai objectAtIndex:x]objectForKey:@"bukaera"];
            j.bukaera = [dateFormatter dateFromString:dateString];
            j.deskribapena = [[jai objectAtIndex:x]objectForKey:@"deskribapena"];
            dateString = [[jai objectAtIndex:x]objectForKey:@"hasiera"];
            j.hasiera = [dateFormatter dateFromString:dateString];
            j.herria = [[jai objectAtIndex:x]objectForKey:@"herria"];
            j.id_jaia = [[[jai objectAtIndex:x]objectForKey:@"id"] integerValue];
            j.izena = [[jai objectAtIndex:x]objectForKey:@"izena"];
            j.url_kartela = [[jai objectAtIndex:x]objectForKey:@"kartela"];
            j.lat = [[[jai objectAtIndex:x]objectForKey:@"lat"] floatValue];
            j.lng = [[[jai objectAtIndex:x]objectForKey:@"lng"] floatValue];
            j.pisua = [[[jai objectAtIndex:x]objectForKey:@"pisua"] integerValue];
            j.url_thum = [[jai objectAtIndex:x]objectForKey:@"thumb"];
            
            j.colorSelector = colSel;
            colSel++;
            if(colSel == 3){
                colSel = 0;
            }
            [jaiakArray addObject:j];
        }
        [self.tableView reloadData];
        
        
        if(jaiakArray.count == 0){
            _emptyView.hidden = NO;
            _tableView.hidden = YES;
        }else{
            _emptyView.hidden = YES;
            _tableView.hidden = NO;
        }
        page++;
        self.tableView.contentOffset = scrollPos;
    } failure:nil];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return jaiakArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JaiakViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JaiaCell"];
    
    Jaia *j=[jaiakArray objectAtIndex:indexPath.row];
    
    cell.lblNombreFiesta.text = [[@" " stringByAppendingString:j.izena] stringByAppendingString:@" "];
    cell.lblPueblo.text = [j.herria uppercaseString];
    [cell.lblPueblo sizeToFit];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *stringFromDate = [[dateFormatter stringFromDate:j.hasiera] stringByAppendingString:@" - "];
    stringFromDate = [stringFromDate stringByAppendingString:[dateFormatter stringFromDate:j.bukaera]];
    cell.lblFecha.text = stringFromDate;
    
    
    [cell.imgKartela setImageWithURL:[NSURL URLWithString:j.url_thum]];
    [self setColors:indexPath.row cell:cell jaia:j];
    return cell;
    
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger actualRow = [indexPath row];
    NSInteger lastRow=[jaiakArray count]-1;
    if(actualRow == 1){
        if(!searchShowed){
            [self showSearchBar:YES];
        }
    }else if(actualRow == 10){
        if(searchShowed){
            [self showSearchBar:NO];
        }
    }
    if(actualRow == (lastRow - 3) && page <= totalPages)
    {
        [self searchJaiak];
    }
}

-(void)setColors:(NSInteger)index cell:(JaiakViewCell *)cell jaia:(Jaia *)jaia
{
    UIColor *c = [UIColor_Jaigiro getColor:jaia.colorSelector];
    if(index%2 == 0){
        //normal
        //fondo color
        cell.dataView.backgroundColor = c;
        cell.lblPueblo.textColor = c;
        cell.lblPueblo.backgroundColor = [UIColor whiteColor];
        cell.lblFecha.textColor = [UIColor whiteColor];
        cell.lblFecha.backgroundColor = c;
        cell.lblNombreFiesta.textColor = [UIColor whiteColor];
        cell.lblNombreFiesta.backgroundColor = c;
    }else{
        //inverso
        //fondo blanco
        cell.dataView.backgroundColor = [UIColor whiteColor];
        cell.lblPueblo.textColor = [UIColor whiteColor];
        cell.lblPueblo.backgroundColor = c;
        cell.lblFecha.textColor = c;
        cell.lblFecha.backgroundColor = [UIColor whiteColor];
        cell.lblNombreFiesta.textColor = c;
        cell.lblNombreFiesta.backgroundColor = [UIColor whiteColor];
    }
}


#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 73;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Jaia *j = [jaiakArray objectAtIndex:indexPath.row];
    
    JaiaFitxaViewController *vc = [[JaiaFitxaViewController alloc]init];
    vc.jaia = j;
    [self.navigationController pushViewController:vc animated:YES];
    scrollPos = self.tableView.contentOffset;
}



@end
