//
//  MemoCell.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 2013/06/16.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "MemoCell.h"

@implementation MemoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
