//
//  SelectIconViewController.h
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/06/08.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectIconViewController : UIViewController

@property (strong, nonatomic) Project *project;
@property (strong, nonatomic) NSArray *dataArray;
@property (weak  , nonatomic) IBOutlet UIScrollView *scrollView;

- (void)setScrollView;

@end
