//
//  CustomNavigationBarTitleView.h
//  Anyplan
//
//  Created by Ken Tsutsumi on 2013/09/12.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomNavigationBarTitleView : UIView

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *detailTitleLabel;

- (void)setTitle:(NSString *)title;
- (void)setDetailTitle:(NSString *)detailTitle;

@end
