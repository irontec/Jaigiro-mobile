//
//  JaiakViewController.m
//  jaigiro
//
//  Created by Sergio Garcia on 04/11/13.
//  Copyright (c) 2013 Irontec S.L. All rights reserved.
//


#import "JaiakViewController.h"
#import "JaigiroAPIClient.h"
#import "Jaia.h"
#import "JaiaFitxaViewController.h"
#import "Login.h"
#import "JaiaCell.h"
#import "JaiaHeaderCell.h"
#import "UIColor+Jaigiro.h"
#import "UIImageView+AFNetworking.h"
#import "AFNetworking.h"


@interface JaiakViewController ()<UIScrollViewDelegate>{
    NSString *_basePath;
    UIImage *pic;
    CGPoint scrollPos;
    NSMutableArray *jaiakArray;
    NSInteger page, totalPages;;
    BOOL load, isShowingView;
}

@property (strong, nonatomic)NSMutableArray *imageSource;

@end

@implementation JaiakViewController

-(void) viewDidLoad
{
    _basePath = [Login getBasePath];
    [self.tableView registerNib:[UINib nibWithNibName:@"JaiaHeaderCell" bundle:nil] forCellReuseIdentifier:@"JaiaHeaderCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"JaiaCell" bundle:nil] forCellReuseIdentifier:@"JaiaCell"];
}

-(void) viewWillAppear:(BOOL)animated
{
    load = true;
    page = 1;
    isShowingView = YES;
    [self firstLoadData];
}


-(void) viewWillDisappear:(BOOL)animated
{
    scrollPos = self.tableView.contentOffset;
    isShowingView = NO;
}


#pragma mark Load data


- (void)firstLoadData
{
    NSMutableDictionary *params = [Login getLoginParams];
    [params setValue:@"21" forKey:@"items"];
    [params setValue:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    [params setValue:[Login getMaxDateForAPI] forKey:@"dateLimit"];
    
    [[JaigiroAPIClient sharedClient] postPath:@"get-jaiak" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        jaiakArray = [[NSMutableArray alloc]init];
        
        totalPages = [[responseObject objectForKey:@"orriKop"] integerValue];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        
        NSMutableArray *jai = [responseObject objectForKey:@"jaiak"];
        NSInteger tam;
        @try {
            tam = jai.count;
        }
        @catch (NSException * e) {
            NSLog(@"Exception: %@", e);
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
            
            //[jaiak addObject:j];
        }
        
        page++;
        load = true;
        [self.tableView reloadData];
        self.tableView.contentOffset = scrollPos;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(isShowingView){
            [self firstLoadData];
        }
        //        NSLog(@"TIMEOUT");
    }];
}


- (void)loadData
{
    NSMutableDictionary *params = [Login getLoginParams];
    [params setValue:@"21" forKey:@"items"];
    [params setValue:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    [params setValue:[Login getMaxDateForAPI] forKey:@"dateLimit"];
    
    [[JaigiroAPIClient sharedClient] postPath:@"get-jaiak" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        if(page == 1){
            jaiakArray = [[NSMutableArray alloc]init];
        }
        totalPages = [[responseObject objectForKey:@"orriKop"] integerValue];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        
        NSMutableArray *jai = [responseObject objectForKey:@"jaiak"];
        NSInteger tam;
        @try {
            tam = jai.count;
        }
        @catch (NSException * e) {
            NSLog(@"Exception: %@", e);
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
        page++;
        load = true;
        [self.tableView reloadData];
        //[self createAndLoadLocalImages];
        self.tableView.contentOffset = scrollPos;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self loadData];
        //        NSLog(@"TIMEOUT");
    }];
}

#pragma mark Click action

- (void)bAction:(id)sender
{
    UIButton *b = sender;
    NSInteger pos = b.tag;
    Jaia *j = [jaiakArray objectAtIndex:pos];
    
    JaiaFitxaViewController *vc = [[JaiaFitxaViewController alloc]init];
    vc.jaia = j;
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = jaiakArray.count;
    //Con esto evitamos que añada una fila en blanco de cabecera
    /*
     if(count == 0){
     return count;
     }
     */
    count++;//sumamos uno por tener la cabecera y ostrar algo mientras carga
    NSInteger tamI = (int)count/2;
    float tamF = count/2.0f;
    if(tamF > tamI){
        return tamI+1;
    }
    return tamI;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger jaiaIndex = (indexPath.row * 2) - 1;
    Jaia *j;
    if(indexPath.row == 0){
        JaiaHeaderCell *hCell = [tableView dequeueReusableCellWithIdentifier:@"JaiaHeaderCell"];
        @try {
            j=[jaiakArray objectAtIndex:0];
        }
        @catch (NSException * e) {
            NSLog(@"Exception: %@", e);
            j = nil;
        }
        if(!j){
            hCell.hImgKartela.image = [UIImage imageNamed:@"placeholder_jaia"];
        } else {
            hCell.hImgKartela.image = nil;
        }
        if(j){
            hCell.hButton.tag = 0;
            
            NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:j.url_thum]];
            [hCell.hImgKartela setImageWithURLRequest:req placeholderImage:[UIImage imageNamed:@"placeholder_jaia"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                hCell.hImgKartela.image = image;
                [hCell.hImgKartela setContentMode:UIViewContentModeScaleAspectFill];
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                [hCell.hImgKartela setContentMode:UIViewContentModeScaleAspectFit];
            }];
            
            
            [hCell.hButton addTarget:self action:@selector(bAction:) forControlEvents:UIControlEventTouchUpInside];
            hCell.hLblJaia.text = [j.izena uppercaseString];
            [hCell.hViewInfo setBackgroundColor:[UIColor_Jaigiro getColor:j.colorSelector]];
            if(j.banator == 0){
                //no va
                hCell.hImgCheck.hidden = YES;
            }else{
                //si va
                hCell.hImgCheck.hidden = NO;
            }
        }else{
            [hCell.hButton removeTarget:self action:@selector(bAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        return hCell;
    }else{
        JaiaCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JaiaCell"];
        
        //Left item
        @try {
            j=[jaiakArray objectAtIndex:jaiaIndex];
        }
        @catch (NSException * e) {
            NSLog(@"Exception: %@", e);
            j = nil;
        }
        if(j){
            cell.lButton.tag = jaiaIndex;
            NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:j.url_thum]cachePolicy:NSURLCacheStorageAllowed timeoutInterval:5];
            [cell.lImgKartela setImageWithURLRequest:req placeholderImage:[UIImage imageNamed:@"placeholder_jaia"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                cell.lImgKartela.image = image;
                [cell.lImgKartela setContentMode:UIViewContentModeScaleAspectFill];
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                [cell.lImgKartela setContentMode:UIViewContentModeScaleAspectFit];
            }];
            [cell.lButton addTarget:self action:@selector(bAction:) forControlEvents:UIControlEventTouchUpInside];
            cell.lLblJaia.text = [j.izena uppercaseString];
            
            [cell.lViewInfo setBackgroundColor:[UIColor_Jaigiro getColor:j.colorSelector]];
            if(j.banator == 0){
                //no va
                cell.lImgCheck.hidden = YES;
            }else{
                //si va
                cell.lImgCheck.hidden = NO;
            }
        }else{
            [cell.lButton removeTarget:self action:@selector(bAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        //Right item
        jaiaIndex++;
        @try {
            j=[jaiakArray objectAtIndex:jaiaIndex];
        }
        @catch (NSException * e) {
            NSLog(@"Exception: %@", e);
            j = nil;
        }
        
        if(j){
            cell.rButton.tag = jaiaIndex;
            NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:j.url_thum]cachePolicy:NSURLCacheStorageAllowed timeoutInterval:5];
            [cell.rImgKartela setImageWithURLRequest:req placeholderImage:[UIImage imageNamed:@"placeholder_jaia"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                cell.rImgKartela.image = image;
                [cell.rImgKartela setContentMode:UIViewContentModeScaleAspectFill];
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                [cell.rImgKartela setContentMode:UIViewContentModeScaleAspectFit];
            }];
            [cell.rButton addTarget:self action:@selector(bAction:) forControlEvents:UIControlEventTouchUpInside];
            cell.rLblJaia.text = [j.izena uppercaseString];
            
            [cell.rViewInfo setBackgroundColor:[UIColor_Jaigiro getColor:j.colorSelector]];
            
            [cell.rInfoImg setImage:[UIImage imageNamed:@"info.png"]];
            if(j.banator == 0){
                //no va
                cell.rImgCheck.hidden = YES;
            }else{
                //si va
                cell.rImgCheck.hidden = NO;
            }
        }else{
            [cell.rButton removeTarget:self action:@selector(bAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.rImgKartela setImage:[UIImage imageNamed:@"black_px.png"]];
            [cell.rLblJaia setText:@""];
            [cell.rInfoImg setImage:[UIImage imageNamed:@"black_px.png"]];
            cell.rImgCheck.hidden = YES;
            [cell.rViewInfo setBackgroundColor:[UIColor blackColor]];
        }
        return cell;
    }
    
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger lastRow=[jaiakArray count]-1;
    if([indexPath row] == (lastRow - 3) && page <= totalPages && load)
    {
        load = false;
        scrollPos = self.tableView.contentOffset;
        [self loadData];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 140;
}

@end
