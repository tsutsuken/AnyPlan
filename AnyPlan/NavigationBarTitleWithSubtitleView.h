//
//  NavigationBarTitleWithSubtitleView.h
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/04/28.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavigationBarTitleWithSubtitleView : UIView

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *detailTitleLabel;

- (void)setTitle:(NSString *)title;
- (void)setDetailTitle:(NSString *)detailTitle;

@end
