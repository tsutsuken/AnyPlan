//
//  TaskCell.m
//  Anyplan
//
//  Created by Ken Tsutsumi on 13/04/30.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "TaskCell.h"
#define kFrameCheckBox CGRectMake(0, 0, 50, 50)
#define kFrameTitleLabel CGRectMake(50, 14, 260, 21)
#define kFrameDetailLabel CGRectMake(50, 35, 260, 14)
#define kDeleteButtonSpaceWidth 38

@implementation TaskCell

- (void)layoutSubviews
{
    if (self.editing)
    {
        self.checkBox.hidden = YES;
        
        CGRect frameForCheckBox = kFrameCheckBox;
        frameForCheckBox.origin.x -= kDeleteButtonSpaceWidth;
        self.checkBox.frame = frameForCheckBox;
        
        CGRect frameForTitleLabel = kFrameTitleLabel;
        frameForTitleLabel.origin.x -= kDeleteButtonSpaceWidth;
        self.titleLabel.frame = frameForTitleLabel;
        
        CGRect frameForDetailLabel = kFrameDetailLabel;
        frameForDetailLabel.origin.x -= kDeleteButtonSpaceWidth;
        self.detailLabel.frame = frameForDetailLabel;
    }
    else
    {
        self.checkBox.hidden = NO;
        
        self.checkBox.frame = kFrameCheckBox;
        self.titleLabel.frame = kFrameTitleLabel;
        self.detailLabel.frame = kFrameDetailLabel;
    }
    
    [super layoutSubviews];
}

@end
