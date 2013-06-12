//
//  UIImage+Additions.h
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/06/10.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Additions)

+ (UIImage *)generateImageWithSourceImage:(UIImage *)sourceImage composeImage:(UIImage *)composeImage rect:(CGRect)rect;
+ (UIImage *)imageWithColor:(UIColor *)color;

@end
