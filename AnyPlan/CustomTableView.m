//
//  CustomTableView.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 2013/07/13.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "CustomTableView.h"

@implementation CustomTableView

- (void)awakeFromNib
{
    if (self.style == UITableViewStyleGrouped)
    {
        self.backgroundView = nil;
        self.backgroundColor = [UIColor colorWithHexString:@"E3E3E3"];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
