//
//  SectionHeaderView.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 2013/07/14.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "SectionHeaderView.h"

@implementation SectionHeaderView

- (id)initWithStyle:(UITableViewStyle)style title:(NSString *)title
{
    self = [super init];
    if (self)
    {
        if (style == UITableViewStyleGrouped)
        {
            self.frame = CGRectMake(0, 0, 320, kHeightForSectionHeaderGrouped);
            
            UILabel *label = [[UILabel alloc] initWithFrame:kFrameForSectionHeaderLabelGrouped];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor colorWithHexString:kColorHexSectionHeaderTitle];
            label.shadowColor = [UIColor whiteColor];
            label.shadowOffset = CGSizeMake(0, 1);
            label.font = [UIFont boldSystemFontOfSize:17.0];
            label.text = title;
            
            [self addSubview:label];
        }
        else
        {
            self.frame = CGRectMake(0, 0, 320, kHeightForSectionHeaderPlain);
            
            UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sectionHeader.png"]];
            [backgroundImage setFrame:CGRectMake(0, -1, backgroundImage.frame.size.width, backgroundImage.frame.size.height)];
            [self addSubview: backgroundImage];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, 300, kHeightForSectionHeaderPlain - 1)];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor darkGrayColor];
            label.shadowColor = [UIColor whiteColor];
            label.shadowOffset = CGSizeMake(0, 1);
            label.font = [UIFont boldSystemFontOfSize:16.0];
            label.text = title;
            
            //label.backgroundColor = [UIColor redColor];
            
            [self addSubview:label];
        }
    }
    return self;
}

@end
