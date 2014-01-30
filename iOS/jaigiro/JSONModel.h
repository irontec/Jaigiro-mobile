//
//  JSONModel.h
//  jaigiro
//
//  Created by Asier Fernandez on 02/10/13.
//  Copyright (c) 2013 Irontec S.L. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONModel : NSObject <NSCopying, NSMutableCopying>
- (id)initWithDictionary:(NSDictionary*)jsonDictionary;
@end
