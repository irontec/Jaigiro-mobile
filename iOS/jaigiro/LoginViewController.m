//
//  LoginViewController.m
//  jaigiro
//
//  Created by Sergio Garcia on 12/11/13.
//  Copyright (c) 2013 Irontec S.L. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "JaigiroAPIClient.h"
#import "MBProgressHUD.h"
#import "UIColor+Jaigiro.h"
#import <FacebookSDK/FacebookSDK.h>
#import "Login.h"
#import "MainViewController.h"

//#import <Accounts/Accounts.h>
//#import <Social/Social.h>
#import <QuartzCore/QuartzCore.h>




@interface LoginViewController () <FBLoginViewDelegate>{
    MBProgressHUD *hud;
    NSInteger twState;
    ACAccount *twitterAccount;
}


@end

@implementation LoginViewController

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(twFinished) name:@"twLoadFinishSergio" object:nil];
    
    UIImage *loginImage = [UIImage imageNamed:@"twitter_login.png"];
    [_loginTwitter setBackgroundImage:loginImage forState:UIControlStateNormal];
    
    loginImage = [UIImage imageNamed:@"gonbidatu.png"];
    [_loginInvitado setBackgroundImage:loginImage forState:UIControlStateNormal];
    _loginFB.readPermissions = @[@"basic_info"];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"twLoadFinishSergio" object:nil];
}

-(void) viewDidAppear:(BOOL)animated
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    UIColor *topColor = [UIColor colorWithRed:0/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
    UIColor *bottomColor = [UIColor colorWithRed:0/255.0f green:192/255.0f blue:192/255.0f alpha:1.0f];
    gradient.colors = [NSArray arrayWithObjects:(id)topColor.CGColor, (id)bottomColor.CGColor, nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    UIView *v = [[UIView alloc]initWithFrame:self.bottomView.bounds];
    v.hidden = YES;
    [self.view addSubview:v];
    
    [UIView animateWithDuration:2.0f animations:^{
        v.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        [v removeFromSuperview];
        [UIView animateWithDuration:1.0f animations:^{
            _nameView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            _nameView.hidden = YES;
            _bottomView.hidden = NO;
            [UIView animateWithDuration:1.0f animations:^{
                _bottomView.alpha = 1.0f;
            }];
        }];
    }];
}


#pragma mark Button actions

- (IBAction)btnInvitadoAction:(id)sender {
    [self saveUUIDAndLoadMainController];
}

- (IBAction)loginTwitterAction:(id)sender {
    [self loginWithTwitter];
}

- (void)twFinished {
    UIAlertView *alert;
    switch (twState) {
        case 0:
            [Login setTwID:twitterAccount.identifier];
            [Login setUsername:twitterAccount.username];
            
            double delayInSeconds = 0.1;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
                [appDelegate loadMainController];
            });
            
            break;
        case 1:
            alert = [[UIAlertView alloc] initWithTitle:@"Ooops!"
                                               message:@"Twitter kontua berrezkuratzeko bahimena eta kontu bat sartuta egon behar da."
                                              delegate:nil
                                     cancelButtonTitle:@"OK"
                                     otherButtonTitles:nil];
            [alert show];
            alert = nil;
            break;
        case 2:
            alert = [[UIAlertView alloc] initWithTitle:@"Ooops!"
                                               message:@"Twitter kontua berrezkuratzeko bahimena eta kontu bat sartuta egon behar da."
                                              delegate:nil
                                     cancelButtonTitle:@"OK"
                                     otherButtonTitles:nil];
            [alert show];
            alert = nil;
            break;
        default:
            alert = [[UIAlertView alloc] initWithTitle:@"Ooops!"
                                               message:@"Errore bat sortu da. Saiatu berriro."
                                              delegate:nil
                                     cancelButtonTitle:@"OK"
                                     otherButtonTitles:nil];
            [alert show];
            alert = nil;
            break;
    }
}


- (void) saveUUIDAndLoadMainController
{
    
    if(hud){
        hud.hidden = YES;
        hud = nil;
    }
    
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    [appDelegate loadMainController];
    
}

#pragma mark Twitter login

- (void)loginWithTwitter
{
    twState = 0;
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if(granted) {
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
            
            if ([accountsArray count] > 0) {
                twState = 0;
                twitterAccount = [accountsArray objectAtIndex:0];
                NSLog(@"%@",twitterAccount.identifier);
                NSLog(@"%@",twitterAccount.username);
                NSLog(@"%@",twitterAccount.accountType);
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"twLoadFinishSergio" object:nil];
            }else{
                twState = -1;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"twLoadFinishSergio" object:nil];
                
            }
        }else{
            //error de acceso a las cuentas , permisos
            twState = -2;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"twLoadFinishSergio" object:nil];
        }
    }];
    
    
}


+ (void) getTwUserInfo:(ACAccount *)twitterAccount
{
    
    
    // Creating a request to get the info about a user on Twitter
    SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"] parameters:[NSDictionary dictionaryWithObject:twitterAccount.username forKey:@"screen_name"]];
    [twitterInfoRequest setAccount:twitterAccount];
    // Making the request
    [twitterInfoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // Check if we reached the reate limit
            if ([urlResponse statusCode] == 429) {
                NSLog(@"Rate limit reached");
                return;
            }
            // Check if there was an error
            if (error) {
                NSLog(@"Error: %@", error.localizedDescription);
                return;
            }
            // Check if there is some response data
            if (responseData) {
                NSError *error = nil;
                NSArray *TWData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                
                NSString *profileImageStringURL = [(NSDictionary *)TWData objectForKey:@"profile_image_url_https"];
                
                profileImageStringURL = [profileImageStringURL stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
                [Login setProfilePhotoUrl:profileImageStringURL];
                
            }
        });
    }];
    
}


#pragma mark Facebook loginview delegate


- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    
    //guardamos los datos necesarios del usuario
    [Login setFbID:[user objectForKey:@"id"]];
    [Login setUsername:user.name];
    NSString * strPictureURL = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", [user objectForKey:@"id"]];
    [Login setProfilePhotoUrl:strPictureURL];
    //[prefs setValue:user.first_name forKey:@"firstName"];
    //[prefs setValue:user.link forKey:@"profilePhoto"];
    [self saveUUIDAndLoadMainController];
}

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    for (id obj in _loginFB.subviews)
    {
        if ([obj isKindOfClass:[UILabel class]])
        {
            UILabel * loginLabel =  obj;
            [loginLabel setText:@"Facebook itxi"];
            [loginLabel setTextColor:[UIColor whiteColor]];
        }
    }
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    for (id obj in _loginFB.subviews)
    {
        if ([obj isKindOfClass:[UIButton class]])
        {
            UIButton * loginButton =  obj;
            UIImage *loginImage = [UIImage imageNamed:@"facebook_login.png"];
            [loginButton setImage:loginImage forState:UIControlStateNormal];
        }
        if ([obj isKindOfClass:[UILabel class]])
        {
            UILabel * loginLabel =  obj;
            [loginLabel setText:@""];
            [loginLabel setTextColor:[UIColor clearColor]];
        }
    }
}

- (void)loginView:(FBLoginView *)loginView
      handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    NSLog(@"Error -> %@",error);
    if (error.fberrorShouldNotifyUser) {
        alertTitle = @"Ooops!";
        alertMessage = @"Internet behar da Facebookekin sartzeko.";
    } else if (error.fberrorCategory == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Ooops!";
        alertMessage = @"Facebookren sesioa bukatu egin da. Sartu berriro.";
    } else if (error.fberrorCategory == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        alertTitle = @"Ooops!";
        alertMessage = @"Facebookekin sartzeko zure kontua berrezkuratzeko bahimena behar dugu.";
    } else {
        NSLog(@"Unexpected error:%@", error);
        alertTitle = @"Ooops!";
        alertMessage = @"Errore bat egon da. Sartu berriro mesedez.";
        
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

@end
