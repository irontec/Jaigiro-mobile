//
//  MapaViewController.m
//  jaigiro
//
//  Created by Sergio Garcia on 04/11/13.
//  Copyright (c) 2013 Irontec S.L. All rights reserved.
//
#import "MapaViewController.h"
#import "JaigiroAPIClient.h"
#import "JaiakViewCell.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "Jaia.h"
#import "Herria.h"
#import "UIColor+Jaigiro.h"
#import "JaiaFitxaViewController.h"
#import "HerriJaiakViewController.h"
#import "JaigiroAnnotation.h"
#import "CenterViewController.h"
#import "Login.h"

//animation
#define SLIDE_INITIAL_POSITION 130


@interface MapaViewController () <UIGestureRecognizerDelegate>{
    CLLocation *actualPosition;
    NSInteger capturedUserLocations;
    NSMutableArray *jaiakArray;
    NSMutableArray *herriakArray;
    NSInteger page, totalPages;
    CGPoint scrollPos;
    BOOL firstLaunch, dataJaiakLoad, dataHerriakLoad;
    BOOL canLoadJaiak, canLoadHerriaK;
    BOOL listShowed, isShowingView;
    //Touch control
    BOOL slidingView, moveUPDir;
    float beforePost;
}

@end

@implementation MapaViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    //touch control
    slidingView = NO;
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(handleGesture:)];
    panGestureRecognizer.delegate = self;
    panGestureRecognizer.minimumNumberOfTouches = 1;
    panGestureRecognizer.maximumNumberOfTouches = 1;
    [self.view addGestureRecognizer:panGestureRecognizer];
    
    //iniciamos la localizacion
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Atzera" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    jaiakArray = [[NSMutableArray alloc]init];
    herriakArray = [[NSMutableArray alloc]init];
    [self.tableView registerNib:[UINib nibWithNibName:@"JaiakViewCell" bundle:nil] forCellReuseIdentifier:@"JaiaCell"];
    
    self.tableView.dataSource = self;
    self.mapView.delegate = self;
    
    self.mapView.showsUserLocation = YES;
    self.mapView.mapType = MKMapTypeStandard;
    firstLaunch = YES;
    listShowed = YES;
    dataJaiakLoad = NO;
    dataHerriakLoad = NO;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    isShowingView = YES;
    canLoadJaiak = YES;
    canLoadHerriaK = YES;
    
    _bottomHeighConstraint.constant = self.view.frame.size.height - SLIDE_INITIAL_POSITION - self.touchView.frame.size.height;
    _bottomHeighConstraintForEmpty.constant = _bottomHeighConstraint.constant;
    locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    capturedUserLocations = 0;
    
    if(listShowed){
        _topDistanceConstraint.constant = SLIDE_INITIAL_POSITION;
        _lblZerrendaMsg.text = @"Hemen zapaldu zerrenda ixteko";
    }else{
        _topDistanceConstraint.constant = self.view.frame.size.height - self.touchView.frame.size.height;
        _lblZerrendaMsg.text = @"Hemen zapaldu zerrenda ikusteko";
    }
    //Actualizar cada vez que se carga la vista
    dataJaiakLoad = NO;
    dataHerriakLoad = NO;
}


- (void)viewWillDisappear:(BOOL)animated
{
    //quitar seleccion de la tabla
    NSIndexPath *selection = [self.tableView indexPathForSelectedRow];
    if (selection) {
        [self.tableView deselectRowAtIndexPath:selection animated:YES];
    }
    
    [locationManager stopUpdatingLocation];
    isShowingView = NO;
    scrollPos = self.tableView.contentOffset;
}

#pragma mark Location delegate

- (void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    capturedUserLocations++;
    if(firstLaunch){
        firstLaunch = NO;
        NSLog(@"update loc");
        CLLocationCoordinate2D centerCoordinate;
        CGPoint userPoint;
        
        MKCoordinateRegion userRegion = MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(.005, .300));
        userPoint = [self.mapView convertCoordinate:userLocation.coordinate toPointToView:self.mapView];
        
        NSInteger screenSize = self.mapView.frame.size.height - self.touchView.frame.origin.y;        userPoint.y += screenSize/2;
        centerCoordinate = [self.mapView convertPoint:userPoint toCoordinateFromView:self.mapView];
        userRegion = MKCoordinateRegionMake(centerCoordinate, MKCoordinateSpanMake(.005, .300));
        [self.mapView setRegion:userRegion animated:NO];
        [self centerMapInUserLocation];
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
    if(!dataHerriakLoad){
        if(canLoadHerriaK){
            canLoadHerriaK = NO;
            [self loadDataHerriak];
        }
    }
    
    if(!dataJaiakLoad){
        if(canLoadJaiak){
            canLoadJaiak = NO;
            page = 1;
            self.emptyView.hidden = NO;
            self.extraView.hidden = YES;
            [self firstLoadDataJaiak];
        }
    }
}



#pragma mark Load data

-(void) firstLoadDataJaiak
{
    
    MKUserLocation *userLocation = self.mapView.userLocation;
    MKCoordinateRegion userRegion = MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(.005, .005));
    
    NSMutableDictionary *params = [Login getLoginParams];
    
    [params setValue:[NSString stringWithFormat:@"%f", userRegion.center.latitude] forKey:@"lat"];
    [params setValue:[NSString stringWithFormat:@"%f", userRegion.center.longitude] forKey:@"lng"];
    [params setValue:[NSString stringWithFormat:@"%d", [Login getMaxDistance]] forKey:@"maxDistance"];
    [params setValue:[Login getMaxDateForAPI] forKey:@"dateLimit"];
    
    [params setValue:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    [params setValue:@"21" forKey:@"items"];//21 items para guardar el orden de colores (multiplo de 3)
    
    [[JaigiroAPIClient sharedClient] postPath:@"get-jaiak-by-coords" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        
        totalPages = [[responseObject objectForKey:@"orriKop"]integerValue];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        NSMutableArray *jai = [responseObject objectForKey:@"jaiak"];
        NSMutableArray *temp = [[NSMutableArray alloc]init];
        NSInteger tam;
        @try {
            tam = jai.count;
        }
        @catch (NSException * e) {
            NSLog(@"Exception: %@", e);
            if(isShowingView){
                [self firstLoadDataJaiak];
            }
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
            [temp addObject:j];
            //            [jaiakArray removeAllObjects];
            jaiakArray = temp;
        }
        [self.tableView reloadData];
        if(tam == 0){
            self.emptyView.hidden = NO;
            self.extraView.hidden = YES;
            self.emptyMessage.text = @"Ez dira jaiak aurkitu..";
        }else{
            self.emptyView.hidden = YES;
            self.extraView.hidden = NO;
            //self.emptyMessage.text = @"Oraindik ez da zure posizioa zehaztatu...";
        }
        
        
        if(tam != 0){
            page++;
            dataJaiakLoad = YES;
        }
        
        self.tableView.contentOffset = scrollPos;
        scrollPos = self.tableView.contentOffset;
        
        canLoadJaiak = YES;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(isShowingView){
            [self firstLoadDataJaiak];
        }
        //        NSLog(@"TIMEOUT");
    }];
}


-(void) loadDataJaiak
{
    
    MKUserLocation *userLocation = self.mapView.userLocation;
    MKCoordinateRegion userRegion = MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(.005, .005));
    
    NSMutableDictionary *params = [Login getLoginParams];
    
    [params setValue:[NSString stringWithFormat:@"%f", userRegion.center.latitude] forKey:@"lat"];
    [params setValue:[NSString stringWithFormat:@"%f", userRegion.center.longitude] forKey:@"lng"];
    [params setValue:[NSString stringWithFormat:@"%d", [Login getMaxDistance]] forKey:@"maxDistance"];
    [params setValue:[Login getMaxDateForAPI] forKey:@"dateLimit"];
    [params setValue:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    [params setValue:@"21" forKey:@"items"];
    
    [[JaigiroAPIClient sharedClient] postPath:@"get-jaiak-by-coords" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        totalPages = [[responseObject objectForKey:@"orriKop"]integerValue];
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
        if(tam == 0){
            self.emptyView.hidden = NO;
            self.extraView.hidden = YES;
            self.emptyMessage.text = @"Ez dira jaiak aurkitu..";
        }else{
            self.emptyView.hidden = YES;
            self.extraView.hidden = NO;
        }
        
        [self.tableView reloadData];
        page++;
        self.tableView.contentOffset = scrollPos;
        scrollPos = self.tableView.contentOffset;
        dataJaiakLoad = YES;
        canLoadJaiak = YES;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (isShowingView){
            [self loadDataJaiak];
        }
        //        NSLog(@"TIMEOUT");
    }];
}



-(void) loadDataHerriak
{
    
    NSMutableDictionary *params = [Login getLoginParams];
    
    MKUserLocation *userLocation = self.mapView.userLocation;
    MKCoordinateRegion userRegion = MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(.005, .005));
    
    [params setValue:[NSString stringWithFormat:@"%f", userRegion.center.latitude] forKey:@"lat"];
    [params setValue:[NSString stringWithFormat:@"%f", userRegion.center.longitude] forKey:@"lng"];
    
    [params setValue:[NSString stringWithFormat:@"%d", [Login getMaxDistance]] forKey:@"maxDistance"];
    
    [[JaigiroAPIClient sharedClient] postPath:@"get-jaien-herriak-by-coords" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //Limpiamos el mapa y el array de fiestas
        //deselect
        NSArray *selectedAnnotations = _mapView.selectedAnnotations;
        for(id annotation in selectedAnnotations) {
            [_mapView deselectAnnotation:annotation animated:YES];
        }
        //remove
        NSMutableArray *toRemove = [[NSMutableArray alloc]init];
        for (id annotation in _mapView.annotations)
            if (annotation != _mapView.userLocation)
                [toRemove addObject:annotation];
        [_mapView removeAnnotations:toRemove];
        
        //Cargamos los nuevos datos del mapa
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        NSMutableArray *herri = [responseObject objectForKey:@"herriak"];
        NSMutableArray *temp = [[NSMutableArray alloc]init];
        NSInteger tam;
        @try {
            tam = herri.count;
        }
        @catch (NSException * e) {
            NSLog(@"Exception: %@", e);
            if(isShowingView){
                [self loadDataHerriak];
            }
            tam = 0;
        }
        
        NSInteger colSel=0;
        for(NSInteger x=0;x<tam;x++){
            Herria *h = [[Herria alloc]init];
            h.id_herria = [[[herri objectAtIndex:x]objectForKey:@"id"] integerValue];
            h.izena = [[herri objectAtIndex:x]objectForKey:@"izena"];
            h.lat = [[[herri objectAtIndex:x]objectForKey:@"lat"] floatValue];
            h.lng = [[[herri objectAtIndex:x]objectForKey:@"lng"] floatValue];
            h.colorSelector = colSel;
            colSel++;
            if(colSel == 3){
                colSel = 0;
            }
            
            [temp addObject:h];
            
            herriakArray = temp;
            [self addAnnotationsWithHerria:h];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(isShowingView){
            [self loadDataHerriak];
        }
        //        NSLog(@"TIMEOUT");
    }];
    
}

- (void)addAnnotationsWithHerria:(Herria*)herria
{
    NSString *imgPath;
    switch (herria.colorSelector) {
        case 0:
            imgPath = @"dot_green.png";
            break;
        case 1:
            imgPath = @"dot_pink.png";
            break;
        case 2:
            imgPath = @"dot_blue.png";
            break;
    }
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(herria.lat, herria.lng);
    JaigiroAnnotation *annotation = [[JaigiroAnnotation alloc] initWithTitle:herria.izena subtitle:@"" imageURL:imgPath andCoordinate:coordinate];
    annotation.herria = herria;
    [self.mapView addAnnotation:annotation];
}


#pragma mark MapView

- (IBAction)centerMap:(id)sender {
    [self centerMapInUserLocation];
}


- (void)centerMapInUserLocation
{
    NSLog(@"EXECUTED CENTER MAP");
    NSLog(@"LOCATION: %f  %f", self.mapView.userLocation.coordinate.latitude, self.mapView.userLocation.coordinate.longitude);
    MKUserLocation *userLocation = self.mapView.userLocation;
    
    CLLocationCoordinate2D centerCoordinate;
    CGPoint userPoint;
    
    MKCoordinateRegion userRegion = MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(.005, .300));
    
    userPoint = [self.mapView convertCoordinate:userLocation.coordinate toPointToView:self.mapView];
    
    NSInteger screenSize = self.mapView.frame.size.height - self.touchView.frame.origin.y;
    userPoint.y += screenSize/2;
    centerCoordinate = [self.mapView convertPoint:userPoint toCoordinateFromView:self.mapView];
    userRegion = MKCoordinateRegionMake(centerCoordinate, MKCoordinateSpanMake(.005, .300));
    
    [self.mapView setRegion:userRegion animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id)annotation
{
    MKAnnotationView *aView = nil;
    if ([annotation isKindOfClass:[JaigiroAnnotation class]]) {
        JaigiroAnnotation *jaigiroAnnotation = (JaigiroAnnotation*)annotation;
        
        aView = [[MKAnnotationView alloc] initWithAnnotation:jaigiroAnnotation reuseIdentifier:@"pinView"];
        aView.canShowCallout = YES;
        aView.enabled = YES;
        aView.centerOffset = CGPointMake(0, 0);
        aView.draggable = NO;
        aView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        aView.annotation = jaigiroAnnotation;
        [aView setImage:[UIImage imageNamed:jaigiroAnnotation.imgUrl]];
    }
    return aView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    JaigiroAnnotation *an = [[JaigiroAnnotation alloc]init];
    an = view.annotation;
    
    HerriJaiakViewController *vc = [[HerriJaiakViewController alloc]init];
    vc.idHerria = [NSString stringWithFormat:@"%d", an.herria.id_herria];
    [self.navigationController pushViewController:vc animated:YES];
}

-(NSInteger)searchColSelHerria:(NSString *)name
{
    for(NSInteger x=0;x<herriakArray.count;x++){
        Herria *h = [herriakArray objectAtIndex:x];
        if([name compare:h.izena]==0){
            return h.colorSelector;
        }
    }
    return -1;
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
    if([indexPath row] == (lastRow - 0) && page <= totalPages && canLoadJaiak)
    {
        canLoadJaiak = NO;
        [self loadDataJaiak];
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
}

#pragma mark Touch Control


- (void)handleGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint velocity = [gestureRecognizer velocityInView:self.view];
    if(velocity.y < 0){
        moveUPDir = YES;
    }else{
        moveUPDir = NO;
    }
    
    CGPoint point = [gestureRecognizer locationInView:self.view];
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        // handle start of gesture
        [self touchesBegan:point];
    } else if ([gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        // handle updated position
        [self touchesMoved:point];
    } else if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
        [self touchesEnded:point];
    }
    
}

- (void)touchesBegan:(CGPoint)point {
    CGRect rect = self.touchView.frame;
    BOOL xRange = point.x >= rect.origin.x && point.x <= rect.origin.x+rect.size.width;
    BOOL yRange = point.y >= rect.origin.y && point.y <= rect.origin.y+rect.size.height;
    if(xRange && yRange) {
        //[self changeVisibility];
        beforePost = point.y;
        slidingView = YES;
    }
}

- (void)touchesMoved:(CGPoint)point {
    if(slidingView) {
        CGRect rect = self.touchView.frame;
        CGRect newRect = CGRectMake(rect.origin.x, self.touchView.frame.origin.y - (beforePost - point.y)  , rect.size.width, rect.size.height);
        beforePost = point.y;
        if(newRect.origin.y >= SLIDE_INITIAL_POSITION && newRect.origin.y <= self.view.frame.size.height - self.touchView.frame.size.height){
            self.touchView.frame=newRect;
            _topDistanceConstraint.constant = newRect.origin.y;
            
            newRect = self.extraView.frame;
            newRect.origin.y = self.touchView.frame.origin.y + self.touchView.frame.size.height;
            self.extraView.frame = newRect;
            self.emptyView.frame = newRect;
            
        }
    }
}

- (void)touchesEnded:(CGPoint)point {
    if(slidingView) {
        slidingView=NO;
        if (moveUPDir){
            [self hideData:NO time:0.65f];
        }else{
            [self hideData:YES time:0.65f];
        }
    }
}


#pragma mark Move Data View

-(void) hideData:(BOOL)hideData time:(float)time
{
    if(hideData){
        [UIView animateWithDuration:time animations:^{
            CGRect frameTouch = self.touchView.frame;
            CGRect frameTable = self.extraView.frame;
            CGRect frameEmpty = self.emptyView.frame;
            
            frameTouch.origin.y = self.view.frame.size.height - frameTouch.size.height;
            frameTable.origin.y = frameTouch.origin.y + frameTouch.size.height;
            frameEmpty.origin.y = frameTable.origin.y;
            
            self.touchView.frame = frameTouch;
            self.extraView.frame = frameTable;
            self.emptyView.frame = frameEmpty;
        } completion:^(BOOL finished) {
            _topDistanceConstraint.constant = self.view.frame.size.height - self.touchView.frame.size.height;
            [self centerMapInUserLocation];
            _lblZerrendaMsg.text = @"Hemen zapaldu zerrenda ikusteko";
            listShowed = NO;
        }];
    }else{
        [UIView animateWithDuration:time animations:^{
            CGRect frameTouch = self.touchView.frame;
            CGRect frameTable = self.extraView.frame;
            CGRect frameEmpty = self.emptyView.frame;
            
            frameTouch.origin.y = SLIDE_INITIAL_POSITION;
            frameTable.origin.y = frameTouch.origin.y + frameTouch.size.height;
            frameEmpty.origin.y = frameTable.origin.y;
            
            self.touchView.frame = frameTouch;
            self.extraView.frame = frameTable;
            self.emptyView.frame = frameEmpty;
        } completion:^(BOOL finished) {
            _topDistanceConstraint.constant = SLIDE_INITIAL_POSITION;
            [self centerMapInUserLocation];
            _lblZerrendaMsg.text = @"Hemen zapaldu zerrenda ixteko";
            listShowed = YES;
        }];
    }
}
@end
