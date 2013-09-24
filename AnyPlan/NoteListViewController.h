//
//  NoteListViewController.h
//  Anyplan
//
//  Created by Ken Tsutsumi on 13/04/28.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditNoteViewController.h"

@interface NoteListViewController : UITableViewController <NSFetchedResultsControllerDelegate,EditNoteViewControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Project *project;
@property (assign, nonatomic) BOOL shouldDisplayAllProject;

@end
