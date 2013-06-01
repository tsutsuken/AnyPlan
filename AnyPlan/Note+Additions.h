//
//  Note+Additions.h
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/04/28.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "Note.h"

@interface Note (Additions)

- (void)saveContext;
- (NSString *)title;
- (NSString *)body;
- (NSString *)editedMonthString;

@end
