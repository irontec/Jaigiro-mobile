//
//  JaigiroAPIClient.h
//  jaigiro
//
//  Created by Asier Fernandez on 03/10/13.
//  Copyright (c) 2013 Irontec S.L. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"
#import "AFNetworking.h"


@interface JaigiroAPIClient : AFHTTPSessionManager

+ (instancetype)sharedClient;
- (void)postPath:(NSString *)path
parameters:(NSDictionary *)parameters
success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
@end