//
//  TaskListViewController.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/04/24.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "TaskListViewController.h"

@interface TaskListViewController ()

@end

@implementation TaskListViewController

- (void)awakeFromNib
{
    self.title = NSLocalizedString(@"TaskListView_Title", nil);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NavigationBarTitleWithSubtitleView *titleView = [[NavigationBarTitleWithSubtitleView alloc] init];
    [titleView setTitle:[APPDELEGATE mainTitleForTabBarWithProject:self.project shouldDisplayAllProject:self.shouldDisplayAllProject]];
    [titleView setDetailTitle:self.title];
    self.navigationItem.titleView = titleView;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"list.png"]
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self.viewDeckController
                                                                            action:@selector(toggleLeftView)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                           target:self
                                                                                           action:@selector(showEditTaskViewWithNewTask)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
#warning test
    LOG_METHOD;
    LOG_BOOL([APPDELEGATE isPremiumUser], @"isPremiumUser");
    
    [ANALYTICS trackView:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TaskCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TaskCell"];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(TaskCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Task *task = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.checkBox.selected = [task.isDone boolValue];
    cell.titleLabel.text = task.title;
    cell.detailLabel.text = [NSString stringWithFormat:@"%@ %@", task.repeatIconString, task.dueDateStringShort];
}

#pragma mark Section Header

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.shouldDisplayAllProject)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
        Task *task = [[sectionInfo objects] objectAtIndex:0];
        
        return task.project.title;
    }
    else
    {
        return nil;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showEditTaskView" sender:self.tableView];
}

#pragma mark - Check Box

- (IBAction)didTouchCheckBox:(id)sender event:(UIEvent*)event
{
    NSIndexPath* indexPath = [self indexPathForTaskWithEvent:event];
    Task *selectedTask = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    BOOL isDoneOld = [selectedTask.isDone boolValue];
    BOOL isDoneNew = !isDoneOld;
    
    //Cellを更新
    TaskCell *selectedCell =  (TaskCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    selectedCell.checkBox.selected = isDoneNew;
    
    //Taskを更新
    [self updateTaskWithDelayWithObjectID:selectedTask.objectID isDone:isDoneNew];
}

- (void)updateTaskWithDelayWithObjectID:(NSManagedObjectID *)objectID isDone:(BOOL)isDone
{
    //GCD x CoreDataの注意事項
    //http://www.cimgf.com/2011/05/04/core-data-and-threads-without-the-headache/
    
    // グローバル(非同期)キューとメイン(同期)キューの準備
    dispatch_queue_t q_global, q_main;
    q_global = dispatch_get_global_queue(0, 0);
    q_main = dispatch_get_main_queue();
    
    //非同期キューでsleep
    dispatch_async(q_global, ^{
        
        [NSThread sleepForTimeInterval:0.4];
        
        //メインキューでタスクを保存
        dispatch_async(q_main, ^{
            
            Task *selectedTask = (Task *)[self.managedObjectContext objectWithID:objectID];
            selectedTask.isDone = [[NSNumber alloc] initWithBool:isDone];
            
            if (isDone)
            {
                selectedTask.completedDate = [NSDate date];
                selectedTask.addedDate = nil;
                
                [selectedTask repeatTaskIfNeeded];
                
                [ANALYTICS trackEvent:kEventExecuteTask isImportant:YES sender:self];
            }
            else
            {
                selectedTask.completedDate = nil;
                selectedTask.addedDate = [NSDate date];
            }
            
            [selectedTask saveContext];
        });
    });
}

- (NSIndexPath *)indexPathForTaskWithEvent:(UIEvent *)event
{
    NSIndexPath* indexPath;
    UITouch* touch = [[event allTouches] anyObject];
    CGPoint p = [touch locationInView:self.tableView];
    indexPath = [self.tableView indexPathForRowAtPoint:p];
    
    return indexPath;
}

#pragma mark - Show Other View

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    LOG(@"%@", [segue identifier]);
    
    if([[segue identifier] isEqualToString:@"showEditTaskView"])
    {
        EditTaskViewController *controller = (EditTaskViewController *)segue.destinationViewController;
        
        BOOL isNewTask;
        Task *editingTask;
        
        if (sender == self.tableView)//Existing Task
        {
            isNewTask = NO;
            
            Task *selectedTask = [[self fetchedResultsController] objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
            editingTask = selectedTask;
        }
        else//New Task
        {
            isNewTask = YES;
            
            Task *newTask = (Task *)[NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:self.managedObjectContext];
            newTask.addedDate = [NSDate date];
        
            if (self.shouldDisplayAllProject)
            {
                newTask.project = [APPDELEGATE inboxProjectInManagedObjectContext:self.managedObjectContext];
            }
            else
            {
                newTask.project = self.project;
            }
            
            editingTask = newTask;
        }
        
        controller.isNewTask = isNewTask;
        controller.task = editingTask;
    }
}

#pragma mark EditTaskView

- (void)showEditTaskViewWithNewTask
{
    [self performSegueWithIdentifier:@"showEditTaskView" sender:self.navigationItem.rightBarButtonItem];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    [fetchRequest setPredicate:[self predicate]];
    
    // Edit the sort key as appropriate.    
    [fetchRequest setSortDescriptors:[self sortDescriptors]];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]
                                                             initWithFetchRequest:fetchRequest
                                                             managedObjectContext:self.managedObjectContext
                                                             sectionNameKeyPath:[self sectionNameKeyPath]
                                                             cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

- (NSPredicate *)predicate
{
    NSPredicate *predicate;
    
    if (self.shouldDisplayAllProject)
    {
        predicate = [NSPredicate predicateWithFormat:@"isDone == NO"];
    }
    else
    {
        predicate = [NSPredicate predicateWithFormat:@"project == %@", self.project];
    }
    
    return predicate;
}

- (NSArray *)sortDescriptors
{
    NSSortDescriptor *mainSortDescriptor;
    
    if (self.shouldDisplayAllProject)
    {
        mainSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"project.displayOrder" ascending:YES];
    }
    else
    {
        mainSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"isDone" ascending:YES];
    }
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects:
                   mainSortDescriptor,
                   [[NSSortDescriptor alloc] initWithKey:@"addedDate" ascending:YES],
                   [[NSSortDescriptor alloc] initWithKey:@"completedDate" ascending:NO],
                   nil];
    
    return sortDescriptors;
}

- (NSString *)sectionNameKeyPath
{
    NSString *sectionNameKeyPath;
    
    if (self.shouldDisplayAllProject)
    {
        sectionNameKeyPath = @"project.displayOrder";
    }
    else
    {
        sectionNameKeyPath = @"isDone";
    }
    
    return sectionNameKeyPath;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(TaskCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

@end