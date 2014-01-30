//
//  Login.m
//  jaigiro
//
//  Created by Sergio Garcia on 13/11/13.
//  Copyright (c) 2013 Irontec S.L. All rights reserved.
//

#import "Login.h"
#import "DateHelper.h"
#import "LoginViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <FacebookSDK/FacebookSDK.h>

//#import "IIIUtil.h"

@implementation Login


+ (NSString *)getBasePath
{
    return [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"jaiak_kartelak"];
}

+ (NSMutableDictionary *)getLoginParams
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *UUID = [prefs stringForKey:@"uuid"];
    
    NSString *idFb = [prefs stringForKey:@"idFb"];
    NSString *idTw = [prefs stringForKey:@"idTw"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:UUID forKey:@"uuid"];
    [params setValue:@"ios" forKey:@"device"];
    
    if(idFb.length > 0){
        [params setValue:idFb forKey:@"idFb"];
    }
    
    if(idTw.length > 0){
        [params setValue:idTw forKey:@"idTw"];
    }
    return params;
}

+ (void) logout
{
    [[FBSession activeSession] close];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setValue:nil forKey:@"firstBoot"];
    [prefs setValue:nil forKey:@"idFb"];
    [prefs setValue:nil forKey:@"idTw"];
    [prefs setValue:nil forKey:@"username"];
    [prefs setValue:nil  forKey:@"profile_photo_url"];
    [prefs setValue:nil forKey:@"distancia"];
    [prefs setValue:nil forKey:@"date"];
    [prefs synchronize];

    
//    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
//    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
//    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
//    NSDictionary * dict = [defs dictionaryRepresentation];
//    for (id key in dict) {
//        [defs removeObjectForKey:key];
//    }
//    [defs synchronize];
    
    
}

+ (NSString *)getID
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    return [prefs stringForKey:@"uuid"];
}

+ (void)setID:(NSString *)userID
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setValue:userID forKey:@"uuid"];
    [prefs synchronize];
    
}

+ (NSString *)getUsermane
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    

    NSString *user = [prefs stringForKey:@"username"];

    if(user.length <= 0){
        user = @"Kaixo!";
    }
    
    return user;
}

+ (void) setUsername:(NSString *)username
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setValue:username forKey:@"username"];
    [prefs synchronize];
    
}
/*
+ (NSString *)getFbID
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    return [prefs stringForKey:@"idFb"];
}
*/
+ (void) setFbID:(NSString *)FbID
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setValue:FbID  forKey:@"idFb"];
    [prefs synchronize];
}
/*
+ (NSString *)getTwID
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    return [prefs stringForKey:@"idTw"];
}
*/
+ (void) setTwID:(NSString *)TwID
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setValue:TwID  forKey:@"idTw"];
    [prefs synchronize];
}

+ (NSString *)getProfilePhotoUrl
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *url = [prefs stringForKey:@"profile_photo_url"];
    if(url.length <= 0){
        if([Login getSocialState] == 1){
            [self forceTwPicUpdate];
            url = [prefs stringForKey:@"profile_photo_url"];
        }
    }
    return url;
    
}

+ (void) setProfilePhotoUrl:(NSString *)url
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setValue:url  forKey:@"profile_photo_url"];
    [prefs synchronize];
    /*
    if(url.length > 0){
        IIIUtil *util = [[IIIUtil alloc] init];
        [util createImagesIfNotExists:[Login getBasePath] url:[Login getProfilePhotoUrl] idJ:@"perfila"];
    }
    */
}

+ (void) forceTwPicUpdate
{
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if(granted) {
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
            
            if ([accountsArray count] > 0) {
                ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
                NSLog(@"%@",twitterAccount.identifier);
                NSLog(@"%@",twitterAccount.username);
                NSLog(@"%@",twitterAccount.accountType);
                
                [Login setTwID:twitterAccount.identifier];
                [Login setUsername:twitterAccount.username];
                
                [LoginViewController getTwUserInfo:twitterAccount];
            }
        }
    }];
}

//0-FB 1-Twitter 2-Nothing
+ (NSInteger)getSocialState
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *idFb = [prefs stringForKey:@"idFb"];
    NSString *idTw = [prefs stringForKey:@"idTw"];
    
    if(idFb.length > 0){
        return 0;
    }else  if(idTw.length > 0){
        return 1;
    }else{
        return 2;
    }
}


+ (NSInteger)getMaxDistance
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSInteger dist = [prefs integerForKey:@"distancia"];
    if(!dist || dist < 50){
        dist = 50;
        [prefs setInteger:dist forKey:@"distancia"];//guardamos porque habia un valor incorrecto
    }
    return dist;
}

+ (void)setMaxDistance:(NSInteger)Distance
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:Distance forKey:@"distancia"];
    [prefs synchronize];
}


+ (NSDate *)getMaxDateDate
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSDate *fecha = [prefs objectForKey:@"date"];
    NSDate *todayDate = [NSDate dateWithTimeIntervalSinceNow:0];
    
    
    
    if (!fecha || [fecha compare:todayDate] == NSOrderedAscending) {
        NSInteger daysToAdd = 730;//añadimos dos años a la fecha actual
        
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setDay:daysToAdd];
        
        fecha = [gregorian dateByAddingComponents:components toDate:todayDate options:0];
//        [prefs setObject:fecha forKey:@"date"];//guardamos porque habia un dato incorrecto
        //no guardamos hasta que el usuario no entre en preferenciass
    }
    return fecha;
}

+ (NSString *)getMaxDateForAPI
{
    NSDate *fecha = [self getMaxDateDate];
    NSCalendarUnit unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [gregorian components:unitFlags fromDate:fecha];
    NSInteger selectedYear = [dateComponents year];
    NSInteger selectedMonth = [dateComponents month];
    NSInteger selectdDay = [dateComponents day];
    return [NSString stringWithFormat:@"%d-%d-%d", selectedYear, selectedMonth, selectdDay];
}

+ (void)setMaxtDate:(NSDate *)Date
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:Date forKey:@"date"];
    [prefs synchronize];
}

+ (NSString *)getMaxDateString
{
    NSDate *fecha = [self getMaxDateDate];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSCalendarUnit unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components = [gregorian components:unitFlags fromDate:fecha];
    
    NSInteger selectedYear = [components year];
    NSInteger selectedMonth = [components month];
    NSInteger selectdDay = [components day];
    
    return [NSString stringWithFormat:@"%dko %@%d", selectedYear, [DateHelper integerToHilabeteaEuskaraz:selectedMonth], selectdDay];
}

+ (NSInteger) getColorForMonth:(NSInteger)month
{
    NSInteger res;
    switch (month) {
        case 1:
        case 4:
        case 7:
        case 10:
            res = 0;
            break;
        case 2:
        case 5:
        case 8:
        case 11:
            res = 1;
            break;
        case 3:
        case 6:
        case 9:
        case 12:
            res = 2;
            break;
    }
    return res;
}





+ (void) setMobHawkBlockState:(BOOL)state
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setBool:state  forKey:@"mobhawkBlockState"];
    [prefs synchronize];
}

+ (BOOL) forceUpdate:(BOOL)actualState
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    BOOL prevState = [prefs boolForKey:@"mobhawkBlockState"];
    if(prevState != actualState){
        [prefs setBool:actualState  forKey:@"mobhawkBlockState"];
        [prefs synchronize];
        return YES;
    } else {
        return NO;
    }

}


@end
