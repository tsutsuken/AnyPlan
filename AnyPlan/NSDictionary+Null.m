//
//  NSDictionary+Null.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/05/20.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "NSDictionary+Null.h"

@implementation NSMutableDictionary (NSDictionary_Null)

- (void)setObjectNull:(id)anObject forKey:(id)aKey
{
    if (anObject) {
        [self setObject:anObject forKey:aKey];
    } else {
        [self setObject:[NSNull null] forKey:aKey];
    }
}

@end

@implementation NSDictionary (NSDictionary_Null)

- (id)objectForKeyNull:(id)aKey
{
    id anObject = [self objectForKey:aKey];
    if (anObject == [NSNull null]) {
        return nil;
    } else {
        return anObject;
    }
}

@end