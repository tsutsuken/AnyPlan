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

- (NSString *)editedMonthString
{
    NSString *editedMonthString;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:NSLocalizedString(@"Note_EditedMonthString_Format", nil)];
    editedMonthString = [formatter stringFromDate:self.editedDate];
    
    return editedMonthString;
}

@end
