//
//  Repeat.h
//  Anyplan
//
//  Created by Ken Tsutsumi on 2013/06/19.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Task;

@interface Repeat : NSManagedObject

@property (nonatomic, retain) NSNumber * unitId;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) Task *task;

@end
