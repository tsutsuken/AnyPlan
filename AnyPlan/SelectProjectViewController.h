//
//  SelectProjectViewController.h
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/05/20.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectProjectViewController : UITableViewController

@property (strong, nonatomic) Task *task;
@property (strong, nonatomic) NSArray *projectDataArray;

@end
