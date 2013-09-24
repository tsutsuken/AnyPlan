//
//  CustomNavigationBarTitleView.m
//  Anyplan
//
//  Created by Ken Tsutsumi on 2013/09/12.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "CustomNavigationBarTitleView.h"

@implementation CustomNavigationBarTitleView

@synthesize titleLabel;
@synthesize detailTitleLabel;

- (id) init
{
    int titleViewWIdth = 200;
    
    self = [super initWithFrame:CGRectMake(0, 0, titleViewWIdth, 44)];
    if (self) {
        
        [self setBackgroundColor: [UIColor clearColor]];
        [self setAutoresizingMask : (UIViewAutoresizingFlexibleWidth)];
        
        CGRect titleFrame = CGRectMake(0, 2, titleViewWIdth, 24);
        titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont boldSystemFontOfSize:20];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.text = @"";
        titleLabel.adjustsFontSizeToFitWidth = YES;
        [titleLabel setAutoresizingMask : (UIViewAutoresizingFlexibleWidth)];
        [self addSubview:titleLabel];
        
        CGRect detailFrame = CGRectMake(0, 24, titleViewWIdth, 44-24);
        detailTitleLabel = [[UILabel alloc] initWithFrame:detailFrame];
        detailTitleLabel.backgroundColor = [UIColor clearColor];
        detailTitleLabel.textAlignment = NSTextAlignmentCenter;
        detailTitleLabel.font = [UIFont boldSystemFontOfSize:13];
        detailTitleLabel.textColor = [UIColor colorWithHexString:kColorHexNavigationBarSubTitle];
        detailTitleLabel.text = @"";
        detailTitleLabel.adjustsFontSizeToFitWidth = YES;
        [detailTitleLabel setAutoresizingMask : (UIViewAutoresizingFlexibleWidth)];
        [self addSubview:detailTitleLabel];
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
