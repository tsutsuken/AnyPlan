//
//  ManageProjectViewController.h
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/05/11.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ManageProjectViewController : UIViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) IBOutlet UIToolbar *myToolbar;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end
