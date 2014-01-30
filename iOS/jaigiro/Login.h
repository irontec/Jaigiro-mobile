//
//  Login.h
//  jaigiro
//
//  Created by Sergio Garcia on 13/11/13.
//  Copyright (c) 2013 Irontec S.L. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Login : NSObject 

+ (NSString *)getBasePath;

+ (NSMutableDictionary *) getLoginParams;
+ (void) logout;

+ (NSString *)getID;
+ (void)setID:(NSString *)userID;
+ (NSString *)getUsermane;
+ (void) setUsername:(NSString *)username;
//+ (NSString *)getFbID;
+ (void) setFbID:(NSString *)FbID;
//+ (NSString *)getTwID;
+ (void) setTwID:(NSString *)TwID;

+ (NSString *)getProfilePhotoUrl;
+ (void) setProfilePhotoUrl:(NSString *)url;

+ (NSInteger)getMaxDistance;
+ (void)setMaxDistance:(NSInteger)Distance;
+ (NSDate *)getMaxDateDate;
+ (NSString *)getMaxDateForAPI;
+ (void)setMaxtDate:(NSDate *)Date;
+ (NSString *)getMaxDateString;

+ (NSInteger) getColorForMonth:(NSInteger)month;

+ (void) setMobHawkBlockState:(BOOL)state;
+ (BOOL) forceUpdate:(BOOL)actualState;

@end
