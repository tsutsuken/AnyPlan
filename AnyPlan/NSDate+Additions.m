//
//  NSDate+Additions.m
//  Anyplan
//
//  Created by Ken Tsutsumi on 2013/10/22.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "NSDate+Additions.h"

@implementation NSDate (Additions)

- (NSDate *)dateWithoutHour
{
    NSDate *dateWithoutHour;
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *dateComp = [cal components:unitFlags fromDate:self];
    
    dateWithoutHour = [cal dateFromComponents:dateComp];
    
    NSLog(@"dateWithoutHour_%@", [dateWithoutHour description]);
    return dateWithoutHour;
}

@end
