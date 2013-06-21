//
//  Task+Additions.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/04/24.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "Task+Additions.h"

@implementation Task (Additions)

#pragma mark - Common

- (void)saveContext
{
    LOG_METHOD;
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    else {
    }
}

#pragma mark - DueDate

- (NSString *)dueDateStringShort
{
    NSString *dueDateStringShort;
    
    if (self.dueDate)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:NSLocalizedString(@"Task_DueDateString_Format", nil)];
        dueDateStringShort = [formatter stringFromDate:self.dueDate];
    }
    else {
        dueDateStringShort = @"";//stringWithFormatで、nullという表示を防ぐため
    }
        
    return dueDateStringShort;
}

- (NSString *)dueDateStringLong
{
    NSString *dueDateStringLong;
    
    if (self.dueDate)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterFullStyle];
        dueDateStringLong = [formatter stringFromDate:self.dueDate];
    }
    else
    {
        dueDateStringLong = @"";//stringWithFormatで、nullという表示を防ぐため
    }
    
    return dueDateStringLong;
}

#pragma mark - Repeat

- (NSString *)repeatIconString
{
    if (self.repeat)
    {
        return @"↺";
    }
    else
    {
        return @"";//stringWithFormatで、nullという表示を防ぐため
    }
}

- (void)repeatTaskIfNeeded
{
    if (self.repeat)
    {
        Task *newTask = (Task *)[NSEntityDescription insertNewObjectForEntityForName:@"Task"
                                                              inManagedObjectContext:self.managedObjectContext];
        
        newTask.title = self.title;
        newTask.project = self.project;
        newTask.repeat = [self newRepeat];
        newTask.memo = self.memo;
        
        newTask.addedDate = [NSDate date];
        newTask.dueDate = [self newDueDate];
        
        //下記は設定不要
        //newTask.completedDate = nil;
        //newTask.isDone = NO;
        
        [newTask saveContext];
    }
}

- (Repeat *)newRepeat
{
    Repeat *newRepeat = (Repeat *)[NSEntityDescription insertNewObjectForEntityForName:@"Repeat"
                                                                inManagedObjectContext:self.managedObjectContext];
    newRepeat.number = self.repeat.number;
    newRepeat.unitId = self.repeat.unitId;
    
    return newRepeat;
}

-(NSDate *)newDueDate
{
    NSDate *newDueDate;
    
    NSDate *today = [NSDate date];
    NSDate *originDate = [self originDateForRepeat];
    NSDateComponents *repeatIntervalComponents = [self repeatIntervalComponents];
    
    do
    {
        LOG(@"do");
        newDueDate = [[NSCalendar currentCalendar] dateByAddingComponents:repeatIntervalComponents toDate:originDate options:0];
        
        originDate = newDueDate;
    }
    while ([today timeIntervalSinceDate:newDueDate] > 0);

    return newDueDate;
}

- (NSDateComponents *)repeatIntervalComponents
{
    NSDateComponents* repeatIntervalComponents = [[NSDateComponents alloc] init];
    
    int repeatNumberInt = [self.repeat.number intValue];
    
    switch ([self.repeat.unitId intValue]) {
        case 0:
            [repeatIntervalComponents setDay:repeatNumberInt];
            break;
        case 1:
            [repeatIntervalComponents setWeek:repeatNumberInt];
            break;
        case 2:
            [repeatIntervalComponents setMonth:repeatNumberInt];
            break;
        case 3:
            [repeatIntervalComponents setYear:repeatNumberInt];
            break;
            
        default:
            break;
    }
    
    return repeatIntervalComponents;
}

-(NSDate *)originDateForRepeat
{
    NSDate *originDate;

    if (self.dueDate)
    {
        originDate = self.dueDate;
    }
    else{
        originDate = [NSDate date];//=タスクの実行日
    }
    
    return originDate;
}

@end
