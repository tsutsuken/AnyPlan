//
//  EditableCell.m
//  LevelUp
//
//  Created by 堤 健 on 12/03/29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "EditableCell.h"

@implementation EditableCell

@synthesize textField;

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
