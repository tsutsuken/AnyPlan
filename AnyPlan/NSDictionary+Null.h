//
//  NSDictionary+Null.h
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/05/20.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (NSDictionary_Null)
- (void)setObjectNull:(id)anObject forKey:(id)aKey;
@end

@interface NSDictionary (NSDictionary_Null)
- (id)objectForKeyNull:(id)aKey;
@end