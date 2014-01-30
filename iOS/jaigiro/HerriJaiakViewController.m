//
//  HerriJaiakViewController.m
//  jaigiro
//
//  Created by Sergio Garcia on 08/11/13.
//  Copyright (c) 2013 Irontec S.L. All rights reserved.
//

#import "HerriJaiakViewController.h"
#import "JaigiroAPIClient.h"
#import "Jaia.h"
#import "JaiakViewCell.h"
#import "AFNetworking.h"
#import "UIColor+Jaigiro.h"
#import "JaiaFitxaViewController.h"
#import "Login.h"
#import "UIImageView+AFNetworking.h"


@interface HerriJaiakViewController (){
    NSMutableArray *jaiakArray;
    NSInteger page, totalPages;
}


@end

@implementation HerriJaiakViewController

@synthesize  idHerria = _idHerria;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"JaiakViewCell" bundle:nil] forCellReuseIdentifier:@"JaiaCell"];
    self.tableView.backgroundColor = [UIColor blackColor];
    page = 1;
    jaiakArray = [[NSMutableArray alloc]init];
    [jaiakArray removeAllObjects];
    [self loadData];
}

#pragma mark Load data

-(void) loadData
{
    NSMutableDictionary *params = [Login getLoginParams];
    
    [params setValue:_idHerria forKey:@"idHerri"];
    [params setValue:[NSString stringWithFormat:@"%d", [Login getMaxDistance]] forKey:@"maxDistance"];
    [params setValue:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    [params setValue:@"21" forKey:@"items"];//21 items para guardar el orden de colores (multiplo de 3)
    
    [[JaigiroAPIClient sharedClient] postPath:@"get-herriko-jaiak" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
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
        [self.tableView reloadData];
        page++;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self loadData];
//        NSLog(@"TIMEOUT");
    }];
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
    NSInteger lastRow=[jaiakArray count]-1;
    if([indexPath row] == (lastRow - 3) && page <= totalPages)
    {
        [self loadData];
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

}

@end
