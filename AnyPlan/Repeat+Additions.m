//
//  Repeat+Additions.m
//  Anyplan
//
//  Created by Ken Tsutsumi on 2013/06/19.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "Repeat+Additions.h"

@implementation Repeat (Additions)

- (NSString *)title
{
    NSString *unitName = [[self unitNameArray] objectAtIndex:[self.unitId intValue]];
    
    if ([self.number intValue] == 1)
    {
        return [NSString stringWithFormat:NSLocalizedString(@"Repeat_Title_Base_Type_1_%@", nil), unitName];
    }
    else
    {
        NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
        if ([self.unitId intValue] == 2 && [language isEqualToString:@"ja"])
        {
            unitName = @"ヶ月";
        }
        
        return [NSString stringWithFormat:NSLocalizedString(@"Repeat_Title_Base_Type_2_%@_%@", nil), self.number, unitName];
    }
}

- (NSArray *)unitNameArray
{
    NSArray *unitNameArray = @[NSLocalizedString(@"Repeat_UnitName_Day", nil),
                               NSLocalizedString(@"Repeat_UnitName_Week", nil),
                               NSLocalizedString(@"Repeat_UnitName_Month", nil),
                               NSLocalizedString(@"Repeat_UnitName_Year", nil)];
    
    return unitNameArray;
}

- (int)maxNumber
{
    int unitId = [self.unitId intValue];
    
    if (unitId == 0)//日
    {
        return 30;
    }
    else if (unitId == 1)//週
    {
        return 12;
    }
    else if (unitId == 2)//月
    {
        return 12;
    }
    else//年
    {
        return 10;
    }
}

@end
