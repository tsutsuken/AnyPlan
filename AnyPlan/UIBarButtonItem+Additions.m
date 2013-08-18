//
//  UIBarButtonItem+Additions.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 2013/07/12.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "UIBarButtonItem+Additions.h"

@implementation UIBarButtonItem (Additions)

- (void)setTitleColorForButtonStyle:(UIBarButtonItemStyle)style
{
    [self setTitleTextAttributes:[self textAttributesForStyle:style] forState:UIControlStateNormal];
}

- (NSDictionary *)textAttributesForStyle:(UIBarButtonItemStyle)style
{
    if (style == UIBarButtonItemStyleDone)
    {
        NSDictionary *dictionaryForDoneButton = @{UITextAttributeTextColor:[UIColor whiteColor],
                                                   UITextAttributeTextShadowColor:[UIColor colorWithHexString:@"2B64A6"],
                                                   UITextAttributeTextShadowOffset:[NSValue valueWithUIOffset:UIOffsetMake(0, -1)]
                                                   };
        
        return dictionaryForDoneButton;
    }
    else
    {
        NSDictionary *dictionaryForPlainButton = @{UITextAttributeTextColor:[UIColor colorWithHexString:kColorHexNavigationBarTitle],
                                                   UITextAttributeTextShadowColor:[UIColor whiteColor],
                                                   UITextAttributeTextShadowOffset:[NSValue valueWithUIOffset:UIOffsetMake(0, 1)]
                                                   };
        
        return dictionaryForPlainButton;
    }
}

@end
