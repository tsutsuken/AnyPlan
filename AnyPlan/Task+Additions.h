//
//  Task+Additions.h
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/04/24.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "Task.h"

@interface Task (Additions)

- (void)saveContext;
- (void)delete;
- (void)execute;
- (void)cancel;
- (void)setDisplayOrderInCurrentProject;
- (void)switchToProject:(Project *)newProject;
- (NSString *)dueDateStringShort;
- (NSString *)dueDateStringLong;
- (NSString *)repeatIconString;
- (void)repeatTaskIfNeeded;

@end
