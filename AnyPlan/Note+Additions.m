//
//  Note+Additions.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/04/28.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "Note+Additions.h"

@implementation Note (Additions)

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

- (NSString *)title
{
    NSString *title;
    
    NSRange rangeForFirstLine = [self.text lineRangeForRange:NSMakeRange(0, 0)];
    NSString *firstLine = [self.text substringWithRange:rangeForFirstLine];
    
    title = firstLine;
    
    return title;
}

- (NSString *)body
{
    NSString *body;

    NSRange rangeForFirstLine = [self.text lineRangeForRange:NSMakeRange(0, 0)];
    
    NSRange rangeForBody;
    int location = NSMaxRange(rangeForFirstLine);
    int length = [self.text length] - rangeForFirstLine.length;
    rangeForBody = NSMakeRange(location, length);
    
    body = [self.text substringWithRange:rangeForBody];
    
    return body;
}

- (NSString *)editedDateString
{
    NSString *editedDateString;
    
    NSDate *editedDay = [self dateWithOutTime:self.editedDate];
    NSDate *today = [self dateWithOutTime:[NSDate date]];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    if ([editedDay isEqualToDate:today])
    {
        [formatter setDateFormat:@"HH:mm"];
        
        editedDateString = [formatter stringFromDate:self.editedDate];
    }
    else
    {
        NSDate *yesterday = [NSDate dateWithTimeInterval:-24*60*60 sinceDate:today];
        
        if ([editedDay isEqualToDate:yesterday])
        {
            editedDateString = NSLocalizedString(@"Note_EditedDateString_Yesterday", nil);
        }
        else
        {
            [formatter setDateStyle:NSDateFormatterMediumStyle];
            editedDateString = [formatter stringFromDate:self.editedDate];
        }
    }
    
    return editedDateString;
}

- (NSString *)editedMonthString
{
    NSString *editedMonthString;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:NSLocalizedString(@"Note_EditedMonthString_Format", nil)];
    editedMonthString = [formatter stringFromDate:self.editedDate];
    
    return editedMonthString;
}

-(NSDate *)dateWithOutTime:(NSDate *)date
{
    if(date == nil)
    {
        date = [NSDate date];
    }
    
    NSDateComponents* comps = [[NSCalendar currentCalendar]
                               components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                               fromDate:date];
    
    return [[NSCalendar currentCalendar] dateFromComponents:comps];
}

@end
