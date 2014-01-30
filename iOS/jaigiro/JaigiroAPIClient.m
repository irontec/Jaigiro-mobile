//
//  JaigiroAPIClient.m
//  jaigiro
//
//  Created by Asier Fernandez on 03/10/13.
//  Copyright (c) 2013 Irontec S.L. All rights reserved.
//

#import "JaigiroAPIClient.h"
#import "AFNetworking.h"

static NSString * const url = @"http://jaigiro.net/kontrola/api/";

@implementation JaigiroAPIClient




+ (instancetype)sharedClient {
    static JaigiroAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[JaigiroAPIClient alloc] initWithBaseURL:[NSURL URLWithString:url]];
        [_sharedClient setSecurityPolicy:[AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey]];
    });
    
    return _sharedClient;
}

- (NSInteger)error:(id)json
{
    NSInteger error = [[json objectForKey:@"error"] intValue];
    return error;
}

- (NSString*)handleErrorWithCode:(NSInteger)errorCode
{
    NSString *errorString = @"Errore bat egon da";
    return errorString;
}

- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[NSString stringWithFormat:@"%@%@", url, path] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger errorCode = [self error:responseObject];
        if(errorCode != 0) {
            NSError *error = [NSError errorWithDomain:@"JaigiroAPI" code:errorCode userInfo:nil];
            if(failure != nil){
                failure(operation, error);
            }
        } else {
            if (success != nil) {
                success(operation, responseObject);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure != nil) {
            failure(operation, error);
        }
    }];
}


@end
