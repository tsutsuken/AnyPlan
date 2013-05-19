//
//  MenuViewController.h
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/04/22.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditProjectViewController.h"
#import "SettingViewController.h"

@interface MenuViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
