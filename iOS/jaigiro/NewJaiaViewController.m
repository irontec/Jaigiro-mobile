//
//  NewJaiaViewController.m
//  jaigiro
//
//  Created by Sergio Garcia on 09/01/14.
//  Copyright (c) 2014 Irontec S.L. All rights reserved.
//

#import "NewJaiaViewController.h"
#import "Login.h"
#import "JaigiroAPIClient.h"
#import "AFNetworking.h"
#import "Toast+UIView.h"

#define KEYBOARD_SLIDE_TIME 0.25
#define KEYBOARD_OFFSET 10
@interface NewJaiaViewController () <UITextFieldDelegate>

@end

@implementation NewJaiaViewController{
    UITextField *activeField;
    CGRect initialActiveFrame;
}

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
    
    UIImage *confirm = [UIImage imageNamed:@"confirm.png"];
    UIBarButtonItem *gordeJaia = [[UIBarButtonItem alloc]initWithImage:confirm style:UIBarButtonItemStylePlain target:self action:@selector(gordeJaiaClick:)];
    self.navigationItem.rightBarButtonItem = gordeJaia;
    
    _textSugerencia.clipsToBounds = YES;
    _textSugerencia.layer.cornerRadius = 5.0f;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self registerForKeyboardNotifications];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self unregisterForKeyboardNotifications];
}

- (void)gordeJaiaClick:(id)sender
{
    NSString *text = _textSugerencia.text;
    [_textSugerencia resignFirstResponder];
    if(text.length > 0){
        [self.view makeToast:@"Ekintzan bidaltzen.."];
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
        
        NSMutableDictionary *params = [Login getLoginParams];
        [params setValue:text forKey:@"sugerentzia"];
        
        [[JaigiroAPIClient sharedClient] postPath:@"new-sugerentzia" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self.parentViewController.view makeToast:@"Zure proposamena bidali egin da. Eskerrik asko."];
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self.navigationItem.rightBarButtonItem setEnabled:YES];
            [self.view makeToast:@"Errore bat egon da. Saiatu berriro."];
        }];
        
    }else{
        [self.view makeToast:@"Proposamena idatzi lehenengoz."];
    }
    
    
    
    
    
    
    
}


#pragma mark Keyboard Manage

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)unregisterForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect screenFrame = self.view.frame;
    CGRect activeFrame = activeField.frame;
    initialActiveFrame = activeFrame;
    if((activeFrame.origin.y + activeFrame.size.height) > (screenFrame.size.height - kbSize.height)){
        activeFrame.origin.y = screenFrame.size.height - kbSize.height - activeFrame.size.height - KEYBOARD_OFFSET;
        [UIView animateWithDuration:KEYBOARD_SLIDE_TIME animations:^{
            [activeField setFrame:activeFrame];
        }];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    if(initialActiveFrame.origin.y != activeField.frame.origin.y){
        [UIView animateWithDuration:KEYBOARD_SLIDE_TIME animations:^{
            [activeField setFrame:initialActiveFrame];
        }];
        initialActiveFrame = activeField.frame;
    }
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
}
@end
