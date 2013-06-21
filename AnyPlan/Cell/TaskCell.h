//
//  TaskCell.h
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/04/30.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaskCell : UITableViewCell

@property Task *task;
@property IBOutlet UIButton *checkBox;
@property IBOutlet UILabel *titleLabel;
@property IBOutlet UILabel *detailLabel;

@end
