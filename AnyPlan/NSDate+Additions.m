//
//  NSDate+Additions.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 2013/06/17.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "NSDate+Additions.h"

@implementation NSDate (Additions)

- (NSString *)dateStringWithStyle:(NSDateFormatterStyle)style;
{
    NSString *string;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:style];
    string = [formatter stringFromDate:self];
    
    return string;
}

@end
