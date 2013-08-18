//
//  NavigationBarTitleWithSubtitleView.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/04/28.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "NavigationBarTitleWithSubtitleView.h"

@implementation NavigationBarTitleWithSubtitleView

@synthesize titleLabel;
@synthesize detailTitleLabel;

- (id) init
{
    self = [super initWithFrame:CGRectMake(0, 0, 200, 44)];
    if (self) {
        [self setBackgroundColor: [UIColor clearColor]];
        [self setAutoresizesSubviews:YES];
        
        CGRect titleFrame = CGRectMake(0, 2, 200, 24);
        titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont boldSystemFontOfSize:20];
        titleLabel.textColor = [UIColor colorWithHexString:kColorHexNavigationBarTitle];
        titleLabel.shadowColor = [UIColor whiteColor];
        titleLabel.shadowOffset = CGSizeMake(0, 1);
        titleLabel.text = @"";
        titleLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:titleLabel];
        
        CGRect detailFrame = CGRectMake(0, 24, 200, 44-24);
        detailTitleLabel = [[UILabel alloc] initWithFrame:detailFrame];
        detailTitleLabel.backgroundColor = [UIColor clearColor];
        detailTitleLabel.textAlignment = NSTextAlignmentCenter;
        detailTitleLabel.font = [UIFont boldSystemFontOfSize:13];
        detailTitleLabel.textColor = [UIColor colorWithHexString:kColorHexNavigationBarSubTitle];
        detailTitleLabel.shadowColor = [UIColor whiteColor];
        detailTitleLabel.shadowOffset = CGSizeMake(0, 1);
        detailTitleLabel.text = @"";
        detailTitleLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:detailTitleLabel];
        
        [self setAutoresizingMask : (UIViewAutoresizingFlexibleLeftMargin |
                                     UIViewAutoresizingFlexibleRightMargin |
                                     UIViewAutoresizingFlexibleTopMargin |
                                     UIViewAutoresizingFlexibleBottomMargin)];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    [self.titleLabel setText:title];
}

- (void)setDetailTitle:(NSString *)detailTitle
{  
    [self.detailTitleLabel setText:detailTitle];  
}

@end
