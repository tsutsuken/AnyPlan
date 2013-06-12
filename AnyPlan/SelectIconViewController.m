//
//  SelectIconViewController.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/06/08.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "SelectIconViewController.h"

@interface SelectIconViewController ()

@end

@implementation SelectIconViewController
{
    int selectedItemIndex;
}

#define kNumberOfColumns 4

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setScrollView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setScrollView
{
    self.scrollView.userInteractionEnabled = YES;
    self.scrollView.alwaysBounceVertical = YES;
    
    int space = 16;
    int iconWidth = 60;
    int iconHeight = iconWidth;
    
    int row, column, xPosition, yPosition;
    
    for (int itemIndex = 0; itemIndex < [self.dataArray count]; itemIndex++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        row = [self rowForItemIndex:itemIndex];
        column = [self columnForItemIndex:itemIndex];
        xPosition = (space + iconWidth)*column + space;
        yPosition = (space + iconHeight)*row + space;
        button.frame = CGRectMake(xPosition, yPosition, iconWidth, iconHeight);
        
        
        NSString *imageName = [self iconImageNameForItemIndex:itemIndex];
        [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        
        [button setBackgroundColor:[self iconColorForItemIndex:itemIndex]];
        
        button.tag = itemIndex;
        [button addTarget:self action:@selector(didPushIconButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.scrollView addSubview:button];
    }
    
    CGSize contentSize = self.scrollView.contentSize;
    contentSize.height = yPosition + iconHeight + space;
    self.scrollView.contentSize = contentSize;
}

- (NSString *)iconImageNameForItemIndex:(int)itemIndex
{
    return @"star";
}

- (UIColor *)iconColorForItemIndex:(int)itemIndex
{
    return [UIColor grayColor];
}

//上から何行目かを返す
- (int)rowForItemIndex:(int)itemIndex
{
    //列の数(=4)で割った時の商
    return itemIndex / kNumberOfColumns;
}

//左から何列目かを返す
- (int)columnForItemIndex:(int)itemIndex
{
    //列の数(=4)で割った時の余り
    return itemIndex % kNumberOfColumns;
}

- (void)didPushIconButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    selectedItemIndex = button.tag;

    LOG(@"selectedItemIndex_%i",selectedItemIndex);
}

@end
