//
//  IconCell.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 2013/06/13.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "IconCell.h"

@implementation IconCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
    backgroundView.backgroundColor = [UIColor darkGrayColor];
    self.selectedBackgroundView = backgroundView;
}

@end
