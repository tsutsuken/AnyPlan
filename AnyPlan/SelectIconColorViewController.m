//
//  SelectIconColorViewController.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/06/07.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "SelectIconColorViewController.h"

@interface SelectIconColorViewController ()

@end

@implementation SelectIconColorViewController

- (void)viewDidLoad
{
    self.title = NSLocalizedString(@"SelectIconColorView_Title", nil);
    
    self.dataArray = [self colorHexArray];
    
    [self setScrollView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didPushIconButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    int selectedItemIndex = button.tag;
    NSString *hexString = [self.dataArray objectAtIndex:selectedItemIndex];
    UIColor *selectedColor = [UIColor colorWithHexString:hexString];
    
    UIImage *backGroundImage = [UIImage imageWithColor:selectedColor];
    UIImage *iconImage = [UIImage imageNamed:self.iconImageName];
    CGRect rect = CGRectMake(0, 0, kLengthForDefaultProjectIcon, kLengthForDefaultProjectIcon);
    self.project.icon = [UIImage generateImageWithSourceImage:backGroundImage composeImage:iconImage rect:rect];
    //saveはしない
    
    [self dismissModalViewControllerAnimated:YES];
}

- (NSString *)iconImageNameForItemIndex:(int)itemIndex
{
    return self.iconImageName;
}

- (UIColor *)iconColorForItemIndex:(int)itemIndex
{
    NSString *hexString = [self.dataArray objectAtIndex:itemIndex];
    return [UIColor colorWithHexString:hexString];
}

- (NSArray *)colorHexArray
{
    NSString *path = [[NSBundle mainBundle] pathForResource:
                      @"IconColors" ofType:@"plist"];
    NSArray *colorHexArray = [[NSArray alloc] initWithContentsOfFile:path];
    
    return colorHexArray;
}

@end
