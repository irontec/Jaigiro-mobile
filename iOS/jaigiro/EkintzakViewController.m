//
//  EkintzakViewController.m
//  jaigiro
//
//  Created by Sergio Garcia on 10/01/14.
//  Copyright (c) 2014 Irontec S.L. All rights reserved.
//

#import "EkintzakViewController.h"
#import "EkintzaCell.h"
#import "Login.h"
#import "JaigiroAPIClient.h"
#import "Ekintza.h"
#import "NewEkintzaViewController.h"
#import "UIColor+Jaigiro.h"

#define DEFAULT_CELL_SIZE 80
#define DEFAULT_LABEL_DESC 19

@interface EkintzakViewController (){
    NSArray *nombresMeses;
    BOOL isShowingView;
    NSMutableArray *ekintzakArray;
}

@end

@implementation EkintzakViewController

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
    nombresMeses = [[NSArray alloc] initWithObjects:@"Urtarrila", @"Otsaila", @"Martxoa", @"Apirila", @"maiatza", @"Ekaina", @"Uztaila", @"Abuztua", @"Iraila", @"Urria", @"Azaroa", @"Abendua", nil];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"EkintzaCell" bundle:nil] forCellReuseIdentifier:@"EkintzaCell"];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    UIImage *new = [UIImage imageNamed:@"plus.png"];
    UIBarButtonItem *newEkintza = [[UIBarButtonItem alloc]initWithImage:new style:UIBarButtonItemStylePlain target:self action:@selector(newEkintzaClick:)];
    self.navigationItem.rightBarButtonItem = newEkintza;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Atzera" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    ekintzakArray = [[NSMutableArray alloc]init];
}

- (void)viewWillAppear:(BOOL)animated
{
    isShowingView = YES;
    [self loadEkintzak];
}

- (void)viewWillDisappear:(BOOL)animated
{
    isShowingView = NO;
}

- (void)newEkintzaClick:(id)sender
{
    NewEkintzaViewController *vc = [[NewEkintzaViewController alloc]init];
    vc.jaia = _jaia;
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark Load data

-(void) loadEkintzak
{
    NSMutableDictionary *params = [Login getLoginParams];
    [params setValue:[NSString stringWithFormat:@"%d", _jaia.id_jaia] forKey:@"idJai"];
    
    [[JaigiroAPIClient sharedClient] postPath:@"get-ekintzak-by-jaiak" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [ekintzakArray removeAllObjects];//borrar el contenido
        NSMutableArray *eki = [responseObject objectForKey:@"ekintzak"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //2014-01-31 21:32:00
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSInteger tam;
        @try {
            tam = eki.count;
        }
        @catch (NSException * e) {
            NSLog(@"Exception: %@", e);
            tam = 0;
        }
        for(int x=0;x<tam;x++){
            Ekintza *e = [[Ekintza alloc]init];
            e.id_ekintza = [[[eki objectAtIndex:x]objectForKey:@"id"] integerValue];
            e.izena = [[eki objectAtIndex:x]objectForKey:@"izena"];
            e.deskribapena = [[eki objectAtIndex:x]objectForKey:@"deskribapena"];
            NSString *dateString = [[eki objectAtIndex:x]objectForKey:@"noiz"];
            e.noiz = [dateFormatter dateFromString:dateString];
            [ekintzakArray addObject:e];
        }
        [_tableView reloadData];
        
        if(ekintzakArray.count == 0){
            _emptyView.hidden = NO;
            _tableView.hidden = YES;
        }else{
            _emptyView.hidden = YES;
            _tableView.hidden = NO;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(isShowingView){
            [self loadEkintzak];
        }
//        NSLog(@"TIMEOUT");
    }];
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EkintzaCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EkintzaCell"];
    
    Ekintza *e=[ekintzakArray objectAtIndex:indexPath.row];
    cell.lblTitulo.text = e.izena;
    cell.lblDescripcion.text = e.deskribapena;
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:e.noiz];
    
    cell.lblDia.text = [NSString stringWithFormat:@"%d", [components day]];
    cell.lblMes.text = [nombresMeses objectAtIndex:[components month]-1];
    NSString *min = [NSString stringWithFormat:@"%d", [components minute]];
    if (min.length == 1){
        min = [@"0" stringByAppendingString:min];
    }
    cell.lblHora.text = [NSString stringWithFormat:@"%d:%@",[components hour], min];
    
    [cell.separatorView setBackgroundColor:[UIColor_Jaigiro getColor:_jaia.colorSelector]];
    return cell;
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ekintzakArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EkintzaCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EkintzaCell"];
    
    Ekintza *e=[ekintzakArray objectAtIndex:indexPath.row];
    //Configuramos la celda, el unico valor importante es describapena porque es el unico que es multiline, el esto rellenamos con datos comodin
    cell.lblTitulo.text = e.izena;
    cell.lblDescripcion.text = e.deskribapena;
    cell.lblDia.text = @"01";
    cell.lblMes.text = @"Enero";
    cell.lblHora.text = @"23:32";

    CGSize theSize = [e.deskribapena sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14.0f] constrainedToSize:CGSizeMake(cell.lblDescripcion.frame.size.width, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat hCell = DEFAULT_CELL_SIZE;//cell estandar size
    if(theSize.height > DEFAULT_CELL_SIZE){//if size > label estandar size -> incremente the different size
        hCell = hCell + (theSize.height - DEFAULT_CELL_SIZE);//Sumamos el extra del label
    }

    return hCell;
}

@end
