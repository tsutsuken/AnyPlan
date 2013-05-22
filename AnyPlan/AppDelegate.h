//
//  AppDelegate.h
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/04/20.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IIViewDeckController.h"
#import "MenuViewController.h"
#import "TaskListViewController.h"
#import "NoteListViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (NSFetchedResultsController *)fetchedResultsControllerForProjectWithContext:(NSManagedObjectContext *)context;
- (NSString *)mainTitleForTabBarWithProject:(Project *)project shouldDisplayAllProject:(BOOL)shouldDisplayAllProject;
- (Project *)inboxProjectInManagedObjectContext:(NSManagedObjectContext *)context;

@end
