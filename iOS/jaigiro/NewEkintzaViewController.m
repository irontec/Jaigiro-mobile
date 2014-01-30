//
//  NewEkintzaViewController.m
//  jaigiro
//
//  Created by Sergio Garcia on 10/01/14.
//  Copyright (c) 2014 Irontec S.L. All rights reserved.
//

#import "NewEkintzaViewController.h"
#import "Toast+UIView.h"
#import "Login.h"
#import "JaigiroAPIClient.h"
#import "PMCalendar.h"
#import "UIColor+Jaigiro.h"
#import "FlatDatePicker.h"

@interface NewEkintzaViewController () <UITextFieldDelegate, UITextViewDelegate, FlatDatePickerDelegate>
{
    NSArray *nombresMeses;
    UITextField *activeTextField;
    FlatDatePicker *flatDatePicker;
}

@end

@implementation NewEkintzaViewController


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
    
    nombresMeses = [[NSArray alloc] initWithObjects:@"Urtarrila", @"Otsaila", @"Martxoa", @"Apirila", @"Maiatza", @"Ekaina", @"Uztaila", @"Abuztua", @"Iraila", @"Urria", @"Azaroa", @"Abendua", nil];
    _separatorView.backgroundColor = [UIColor_Jaigiro getColor:_jaia.colorSelector];
    
    UIImage *confirm = [UIImage imageNamed:@"confirm.png"];
    UIBarButtonItem *gordeEkintza = [[UIBarButtonItem alloc]initWithImage:confirm style:UIBarButtonItemStylePlain target:self action:@selector(gordeEkintza:)];
    self.navigationItem.rightBarButtonItem = gordeEkintza;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Atzera" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHidden:) name:UIKeyboardDidHideNotification object:nil];
    
    [_txtTitulo addTarget:self action:@selector(izenaValueChanged) forControlEvents:UIControlEventEditingChanged];
    [_txtFecha addTarget:self action:@selector(dataValueChangeFinish) forControlEvents:UIControlEventEditingDidEnd];
    [_txtHora addTarget:self action:@selector(orduaValueChangeFinish) forControlEvents:UIControlEventEditingDidEnd];
    
    //picker
    flatDatePicker = [[FlatDatePicker alloc] initWithParentView:self.view];
    flatDatePicker.delegate = self;
    flatDatePicker.title = @"Aukeratu";
    flatDatePicker.datePickerMode = FlatDatePickerModeDate;
    
    _textDescr.clipsToBounds = YES;
    _textDescr.layer.cornerRadius = 5.0f;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)gordeEkintza:(id)sender
{
    NSString *izena = _txtTitulo.text;
    NSString *desk = _textDescr.text;
    NSString *fecha = _txtFecha.text;
    NSString *hora = _txtHora.text;
    
    if(activeTextField){
        [activeTextField resignFirstResponder];
    }
    [_textDescr resignFirstResponder];
    
    if([self chechData]){
        [self.view makeToast:@"Ekintzan bidaltzen.."];
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
        NSMutableDictionary *params = [Login getLoginParams];
        [params setValue:[NSString stringWithFormat:@"%d", _jaia.id_jaia] forKey:@"idJai"];
        [params setValue:izena forKey:@"izena"];
        [params setValue:desk forKey:@"deskribapena"];
        [params setValue:[NSString stringWithFormat:@"%@ %@", fecha, hora] forKey:@"noiz"];
        
        [[JaigiroAPIClient sharedClient] postPath:@"new-ekintza-sugerentzia" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self.parentViewController.view makeToast:@"Zure ekintza bidali da. Eskerrik asko."];
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self.navigationItem.rightBarButtonItem setEnabled:YES];
            [self.view makeToast:@"Errore bat egon da. Saiatu berriro."];
        }];
    }else{
        [self.parentViewController.view makeToast:@"Ekintzaren informazio gustia ondo sartu lehenengoz."];
    }
    

}

- (NSInteger)chechData
{
    NSString *izena = _txtTitulo.text;
    NSString *desk = _textDescr.text;
    
    if (izena.length == 0 ){
        return NO;
    }
    if(desk.length == 0){
        return NO;
    }
    if (![self checkFecha]){
        return NO;
    }
    if (![self checkOrdua]){
        return NO;
    }
    return YES;
}

- (bool)checkFecha
{
    NSString *fecha = _txtFecha.text;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    
    NSDate *date = [dateFormatter dateFromString:fecha];
    if(!date){
        return NO;
    }
    return YES;
}

- (bool)checkOrdua
{
    NSString *hora = _txtHora.text;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    
    NSDate *date = [dateFormatter dateFromString:hora];
    if(!date){
        return NO;
    }
    return YES;
}



#pragma mark Calendar delegate

- (void)calendarController:(PMCalendarController *)calendarController didChangePeriod:(PMPeriod *)newPeriod
{
    
}

- (void)keyboardShown:(NSNotification*)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    _scrollBottomConstraint.constant = keyboardFrameBeginRect.size.height;
}

- (void)keyboardHidden:(NSNotification*)notification
{
    _scrollBottomConstraint.constant = 0;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }else{
        [self descValueChanged];
    }
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    activeTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    activeTextField = nil;
}

- (void)izenaValueChanged
{
    NSString *cad = _txtTitulo.text;
    if (cad.length == 0){
        _lblIzena.text = @"Su artifizialak";
    }else{
        _lblIzena.text = cad;
    }
}

- (void)descValueChanged
{
    NSString *cad = _textDescr.text;
    
    if (cad.length == 0){
        _lblDesc.text = @"Valentziako suetxearen su artifizialak";
    }else{
        _lblDesc.text = cad;
    }
    
    CGSize theSize = [_lblDesc.text sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14.0f] constrainedToSize:CGSizeMake(_lblDesc.frame.size.width, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    if(theSize.height > 32){//32 es el tamaño del label minimo que queremos mostrar
        _previewHeighConstraint.constant = 80 - 32 + theSize.height;
    } else {
        _previewHeighConstraint.constant = 80;
    }

    
}
- (IBAction)btnDataClick:(id)sender
{
    if(activeTextField){
        [activeTextField resignFirstResponder];
    }
    [_textDescr resignFirstResponder];
    [flatDatePicker setDatePickerMode:FlatDatePickerModeDate];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd ss:mm:HH"];
    NSDate *date = [dateFormatter dateFromString:@"2014-01-30 45:30:22"];
    [flatDatePicker setLocale:nil];
    if (flatDatePicker.isOpen) {
        [flatDatePicker setDate:date animated:YES];
    } else {
        [flatDatePicker setDate:date animated:NO];
    }
    flatDatePicker.title = @"Aukeratu eguna";
    flatDatePicker.maximumDate = _jaia.bukaera;
    [flatDatePicker show];
}

- (IBAction)btnOrduaClick:(id)sender
{
    if(activeTextField){
        [activeTextField resignFirstResponder];
    }
    [_textDescr resignFirstResponder];
    [flatDatePicker setDatePickerMode:FlatDatePickerModeTime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:@"22:30:45"];
    [flatDatePicker setLocale:nil];
    if (flatDatePicker.isOpen) {
        [flatDatePicker setDate:date animated:YES];
    } else {
        [flatDatePicker setDate:date animated:NO];
    }
    flatDatePicker.title = @"Aukeratu ordua";
    [flatDatePicker show];
}


#pragma mark - FlatDatePicker Delegate

- (void)flatDatePicker:(FlatDatePicker*)datePicker dateDidChange:(NSDate*)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if (datePicker.datePickerMode == FlatDatePickerModeDate) {
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    } else if (datePicker.datePickerMode == FlatDatePickerModeTime) {
        [dateFormatter setDateFormat:@"HH:mm:ss"];
    } else {
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
}

- (void)flatDatePicker:(FlatDatePicker*)datePicker didCancel:(UIButton*)sender
{

}

- (void)flatDatePicker:(FlatDatePicker*)datePicker didValid:(UIButton*)sender date:(NSDate*)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if (datePicker.datePickerMode == FlatDatePickerModeDate) {
        [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm"];
        NSString *dia, *mes, *ano;
        NSDateComponents *components = [dateFormatter.calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date]; // Get necessary date components
        ano = [NSString stringWithFormat:@"%d",[components year]];
        mes = [NSString stringWithFormat:@"%d", [components month]];
        dia = [NSString stringWithFormat:@"%d",[components day]];
        
        if(mes.length == 1){
            mes = [@"0" stringByAppendingString:mes];
        }
        if(dia.length == 1){
            dia = [@"0" stringByAppendingString:dia];
        }
        _txtFecha.text = [NSString stringWithFormat:@"%@/%@/%@", ano, mes, dia];
        _lblEguna.text = dia;
        _lblMes.text = [nombresMeses objectAtIndex:[components month]-1];
    } else if (datePicker.datePickerMode == FlatDatePickerModeTime) {
        [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm"];
        
        NSDateComponents *components = [dateFormatter.calendar components:NSMinuteCalendarUnit|NSHourCalendarUnit fromDate:date];
        NSString *h, *m;
        h = [NSString stringWithFormat:@"%d",[components hour]];
        m = [NSString stringWithFormat:@"%d", [components minute]];
        
        if(m.length == 1){
            m = [@"0" stringByAppendingString:m];
        }
        _txtHora.text = [NSString stringWithFormat:@"%@:%@", h, m];
        _lblOrdua.text = _txtHora.text;
    } else {
        [dateFormatter setDateFormat:@"dd MMMM yyyy HH:mm:ss"];
    }
}
@end
