//
//  UIImage+Additions.m
//  Anyplan
//
//  Created by Ken Tsutsumi on 13/06/10.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "UIImage+Additions.h"

@implementation UIImage (Additions)

+ (UIImage *)generateImageWithSourceImage:(UIImage *)sourceImage composeImage:(UIImage *)composeImage rect:(CGRect)rect
{
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);//scaleに0を指定することで、機種に応じて自動的に調整してくれる
    
    [sourceImage drawInRect:rect];
    [composeImage drawInRect:rect blendMode:kCGBlendModeNormal alpha:1.0f];
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //http://d.akiroom.com/2012-03/cgcontext-uiimage-blur/
    
    return resultingImage;
}

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
