//
//  Task.h
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/05/23.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Project;

@interface Task : NSManagedObject

@property (nonatomic, retain) NSDate * completedDate;
@property (nonatomic, retain) NSNumber * isDone;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * addedDate;
@property (nonatomic, retain) Project *project;

@end
