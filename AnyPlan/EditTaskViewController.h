//
//  EditTaskViewController.h
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/04/25.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectProjectViewController.h"

@protocol EditTaskViewControllerDelegate;

@interface EditTaskViewController : UITableViewController <UITextFieldDelegate, UIActionSheetDelegate>

@property (assign, nonatomic) id <EditTaskViewControllerDelegate> delegate;
@property (strong, nonatomic) Task *task;
@property (assign, nonatomic) BOOL isNewTask;

@end


@protocol EditTaskViewControllerDelegate
- (void)editTaskViewController:(EditTaskViewController *)controller didFinishWithSave:(BOOL)save;
@end