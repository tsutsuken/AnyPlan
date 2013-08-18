//
//  UIBarButtonItem+Additions.h
//  AnyPlan
//
//  Created by Ken Tsutsumi on 2013/07/12.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
typedef enum UIBarButtonItemStyle : NSUInteger {
    UIBarButtonSystemItemNormal,
    UIBarButtonSystemItemDone,
} UIBarButtonItemStyle;
 */

@interface UIBarButtonItem (Additions)

- (void)setTitleColorForButtonStyle:(UIBarButtonItemStyle)style;

@end
