//
//  Task+Additions.m
//  Anyplan
//
//  Created by Ken Tsutsumi on 13/04/24.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "Task+Additions.h"

#define kKeyLocalNotificationID @"kKeyLocalNotificationID"

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
    
    [self refreshAlert];
}

#pragma mark - Delete

- (void)delete
{
    [self.managedObjectContext deleteObject:self];
    
    [self.project refreshDisplayOrderOfTasks];
    
    [self saveContext];
}

#pragma mark - isDone

#pragma mark Execute

- (void)execute
{
    [ANALYTICS trackEvent:kEventExecuteTask isImportant:YES sender:self];
    
    self.isDone = [[NSNumber alloc] initWithBool:YES];
    [self.project refreshDisplayOrderOfTasks];
    
    self.completedDate = [NSDate date];
    self.displayOrder = nil;
    
    [self repeatTaskIfNeeded];
    
    [self saveContext];
}

#pragma mark Cancel

- (void)cancel
{
    self.isDone = [[NSNumber alloc] initWithBool:NO];
    [self setDisplayOrderInCurrentProject];//isDoneを設定した後に実行する
    
    self.completedDate = nil;
    
    [self saveContext];
}

#pragma mark - DisplayOrder

- (void)setDisplayOrderInCurrentProject
{
    int displayOrder = [self.project numberOfUncompletedTask] - 1;//自タスクの分を引く
    self.displayOrder = @(displayOrder);
}

#pragma mark - Project

- (void)switchToProject:(Project *)newProject
{
    if ([self.isDone boolValue])
    {
        self.project = newProject;
    }
    else
    {
        //以前のProjectを取得
        Project *oldProject = self.project;
        
        //新しいProjectをセット
        self.project = newProject;
        
        //新しいProjectでのdisplayOrderをセット
        [self setDisplayOrderInCurrentProject];
        
        //古いProject内で、displayOrderをリフレッシュ
        [oldProject refreshDisplayOrderOfTasks];
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
        newTask.dueDate = [self newDueDate];
        newTask.alertDate = [self newAlertDate];
        
        [newTask setDisplayOrderInCurrentProject];
        
        //下記は設定不要
        //completedDate,isDone
        
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
        newDueDate = [[NSCalendar currentCalendar] dateByAddingComponents:repeatIntervalComponents toDate:originDate options:0];
        
        originDate = newDueDate;
    }
    while ([today timeIntervalSinceDate:newDueDate] > 0);

    return newDueDate;
}

- (NSDate *)newAlertDate
{
    NSDate *newAlertDate;
    
    if (!self.alertDate)
    {
        return nil;
    }
    
    ////古い期日と、新しい期日の差分を求める
    NSTimeInterval intervalOfDueDate;
    
    //古い期日
    NSDate *oldDueDate;
    if (self.dueDate) {
        oldDueDate = [self.dueDate dateWithoutHour];
    }
    else {
        oldDueDate = [[NSDate date] dateWithoutHour];
    }
    //新しい期日
    NSDate *newDueDate = [[self newDueDate] dateWithoutHour];
    
    //差分
    intervalOfDueDate = [newDueDate timeIntervalSinceDate:oldDueDate];//A-B
    
    ////差分から新しい通知日を求める
    newAlertDate = [self.alertDate initWithTimeInterval:intervalOfDueDate sinceDate:self.alertDate];
    
    return newAlertDate;
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

#pragma mark - AlertDate

- (NSString *)alertDateStringLong
{
    NSString *alertDateStringLong;
    
    if (self.alertDate)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterLongStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        alertDateStringLong = [formatter stringFromDate:self.alertDate];
    }
    else
    {
        alertDateStringLong = @"";//stringWithFormatで、nullという表示を防ぐため
    }
    
    return alertDateStringLong;
}

- (void)refreshAlert
{
    NSLog(@"%s",__FUNCTION__);
    
    [self cancelAlert];
    
    if ([self shouldSetAlert])
    {
        [self setAlert];
    }
}

- (void)cancelAlert
{
    NSLog(@"%s",__FUNCTION__);
    
    NSString *objectURIString = [[self.objectID URIRepresentation] absoluteString];
    
    for(UILocalNotification *aNotif in [[UIApplication sharedApplication] scheduledLocalNotifications])
    {
        if([[aNotif.userInfo objectForKey:kKeyLocalNotificationID] isEqualToString:objectURIString])
        {
            [[UIApplication sharedApplication] cancelLocalNotification:aNotif];
            NSLog(@"DidCancelOldAlert");
            break;
        }
    }
}

- (BOOL)shouldSetAlert
{
    //ObjectIDがtemporayならエラーを出す?
    NSLog(@"%s",__FUNCTION__);
    
    if (self.managedObjectContext == nil)
    {
        NSLog(@"NO:Task is deleted");
        return NO;
    }
    else if (!self.alertDate)
    {
        NSLog(@"NO:AlertDate is nil");
        return NO;
    }
    else if ([self.isDone boolValue])
    {
        NSLog(@"NO:Task is done");
        return NO;
    }
    else
    {
        NSLog(@"YES:Should Set Alert");
        return YES;
    }
}

- (void)setAlert
{
    NSLog(@"%s",__FUNCTION__);
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    notification.fireDate = self.alertDate;
    NSLog(@"fireDate_%@",notification.fireDate);
    
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.alertBody = self.title;
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    NSString *objectURIString = [[self.objectID URIRepresentation] absoluteString];
    
    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:objectURIString forKey:kKeyLocalNotificationID];
    notification.userInfo = infoDict;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

@end
