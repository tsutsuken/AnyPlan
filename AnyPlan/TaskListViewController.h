//
//  TaskListViewController.h
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/04/24.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditTaskViewController.h"
#import "TaskCell.h"

@interface TaskListViewController : UITableViewController <NSFetchedResultsControllerDelegate, EditTaskViewControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Project *project;
@property (assign, nonatomic) BOOL shouldDisplayAllProject;

- (IBAction)didTouchCheckBox:(id)sender event:(UIEvent*)event;

@end
