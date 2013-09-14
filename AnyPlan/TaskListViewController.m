//
//  TaskListViewController.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/04/24.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "TaskListViewController.h"

#define kTagTextField 2

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
    
    [self setNavBarButtonsWithEditingTextField:NO];
    
    self.tableView.tableHeaderView = [self textFieldView];
    
    CustomNavigationBarTitleView *titleView = [[CustomNavigationBarTitleView alloc] init];
    [titleView setTitle:[APPDELEGATE mainTitleForTabBarWithProject:self.project shouldDisplayAllProject:self.shouldDisplayAllProject]];
    [titleView setDetailTitle:self.title];
    self.navigationItem.titleView = titleView;
}

- (void)setNavBarButtonsWithEditingTextField:(BOOL)editingTextField
{
    UIBarButtonItem *leftBarButtonItem;
    UIBarButtonItem *rightBarButtonItem;
    
    if (editingTextField)
    {
        leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                          target:self
                                                                          action:@selector(didPushCancelButton)];
        
        rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                           target:self
                                                                           action:@selector(didPushDoneButton)];
    }
    else
    {
        leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"list.png"]
                                                             style:UIBarButtonItemStyleBordered
                                                            target:self.viewDeckController
                                                            action:@selector(toggleLeftView)];
        
        rightBarButtonItem = self.editButtonItem;
    }
    
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

- (void)didPushCancelButton
{
    [self didFinishTextFieldWithSave:NO hideKeyBoard:YES];
}

- (void)didPushDoneButton
{
    [self didFinishTextFieldWithSave:YES hideKeyBoard:YES];
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
    [self performSegueWithIdentifier:@"showEditTaskView" sender:self];
}

#pragma mark - Table view edit

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    if (editing)
    {
        self.tabBarController.viewDeckController.panningMode = IIViewDeckNoPanning;
        self.navigationItem.leftBarButtonItem = nil;
        
        [UIView beginAnimations:nil context:nil];
        self.tableView.tableHeaderView = nil;
        self.tabBarController.tabBar.hidden = YES;
        [UIView commitAnimations];
    }
    else
    {
        self.tabBarController.viewDeckController.panningMode = IIViewDeckFullViewPanning;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"list.png"]
                                                                                 style:UIBarButtonItemStyleBordered
                                                                                target:self.viewDeckController
                                                                                action:@selector(toggleLeftView)];
        
        [UIView beginAnimations:nil context:nil];
        self.tableView.tableHeaderView = [self textFieldView];
        self.tabBarController.tabBar.hidden = NO;
        [UIView commitAnimations];
    }
}

#pragma mark Delete

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        Task *deletingTask = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [deletingTask delete];
    }
}

#pragma mark Move

- (BOOL)tableView:(UITableView *)tableview canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.shouldDisplayAllProject)
    {
        return YES;
    }
    else
    {
        Task *task = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        if ([task.isDone boolValue])
        {
            return NO;
        }
        else
        {
            return YES;
        }
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if( sourceIndexPath.section != proposedDestinationIndexPath.section )
    {
        return sourceIndexPath;
    }
    else
    {
        return proposedDestinationIndexPath;
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    //http://stackoverflow.com/questions/1648223/how-can-i-maintain-display-order-in-uitableview-using-core-data
    
    NSUInteger fromRow = fromIndexPath.row;
    NSUInteger toRow = toIndexPath.row;
    
    Task *movingTask = [self.fetchedResultsController.fetchedObjects objectAtIndex:fromRow];
    movingTask.displayOrder =  [[NSNumber alloc] initWithInteger:toRow];
    
    //並べ替えの影響を受ける範囲（start,end）を求める
    NSInteger start,end;
    int delta;
    
    if (fromRow == toRow) {//セルを移動させなかった場合
        return;
    }
    else if (fromRow < toRow){//セルを下に移動させた場合
        delta = -1;
        start = fromRow + 1;
        end = toRow;
    }
    else {//セルを上に移動させた場合
        delta = 1;
        start = toRow;
        end = fromRow - 1;
    }
    
    for (NSUInteger i = start; i <= end; i++)
    {
        Task *task = [self.fetchedResultsController.fetchedObjects objectAtIndex:i];
        NSNumber *newDisplayOrder = @([task.displayOrder intValue] + delta);
        task.displayOrder =  newDisplayOrder;
    }
    
    [movingTask saveContext];
    
    [self.tableView reloadData];
}

#pragma mark - Check Box

- (IBAction)didTouchCheckBox:(id)sender event:(UIEvent*)event
{
    NSIndexPath* indexPath = [self indexPathForTaskWithEvent:event];
    Task *selectedTask = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    BOOL isDoneNew = ![selectedTask.isDone boolValue];
    
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
            
            if (isDone)
            {
                [selectedTask execute];
            }
            else
            {
                [selectedTask cancel];
            }
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

#pragma mark - TextField

- (UIView *)textFieldView
{
    int textFieldHeight = 50;
    int topMargin = 15;
    
    int bottomMargin;
    if (self.shouldDisplayAllProject)
    {
        bottomMargin = 0;//SectionHeaderの分、余白が大きく見るため、調整
    }
    else
    {
        bottomMargin = topMargin;
    }
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, textFieldHeight + topMargin + bottomMargin)];
    
    UITextField *textField =  [[UITextField alloc] initWithFrame:CGRectMake(8, topMargin, 304, textFieldHeight)];
    textField.delegate = self;
    textField.tag = kTagTextField;
    textField.placeholder = NSLocalizedString(@"TaskListView_TextField_PlaceHolder", nil);
    
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.returnKeyType = UIReturnKeyNext;
    textField.font = [UIFont boldSystemFontOfSize:20];
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [headerView addSubview:textField];
    
    return headerView;
}

- (void)didFinishTextFieldWithSave:(BOOL)save hideKeyBoard:(BOOL)hide
{
    UITextField *textField = (UITextField *)[self.view viewWithTag:kTagTextField];
    
    if (save)
    {
        if (textField.text.length != 0)
        {
            [self addTaskWithTitle:textField.text];
        }
    }
    
    if (hide)
    {
        [textField resignFirstResponder];
    }
    
    textField.text = nil;
}

- (void)addTaskWithTitle:(NSString *)title
{
    [ANALYTICS trackEvent:kEventAddTask isImportant:YES sender:self];
    [ANALYTICS trackPropertyWithKey:kPropertyKeyTaskTitle value:title sender:self];

    Task *newTask = (Task *)[NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:self.managedObjectContext];

    newTask.title = title;
    newTask.project = [self projectForNewTask];
    [newTask setDisplayOrderInCurrentProject];
    
    [newTask saveContext];
}

- (Project *)projectForNewTask
{
    if (self.shouldDisplayAllProject)
    {
        return [APPDELEGATE inboxProjectInManagedObjectContext:self.managedObjectContext];
    }
    else
    {
        return self.project;
    }
}

/*
- (void)testDisplayOrder
{
    for (Task *task in [self.fetchedResultsController fetchedObjects])
    {
        LOG(@"%@ %@", task.displayOrder, task.title);
    }
}
*/

#pragma mark TextField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self setNavBarButtonsWithEditingTextField:YES];
    
    self.tabBarController.viewDeckController.enabled = NO;
    
    return YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [self setNavBarButtonsWithEditingTextField:NO];
    
    self.tabBarController.viewDeckController.enabled = YES;
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length == 0)
    {
        [self didFinishTextFieldWithSave:NO hideKeyBoard:YES];
    }
    else
    {
        [self didFinishTextFieldWithSave:YES hideKeyBoard:NO];
    }
    
    return YES;
}

#pragma mark - Show Other View

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    LOG(@"%@", [segue identifier]);
    
    if([[segue identifier] isEqualToString:@"showEditTaskView"])
    {
        EditTaskViewController *controller = (EditTaskViewController *)segue.destinationViewController;
        
        Task *selectedTask = [[self fetchedResultsController] objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
        controller.task = selectedTask;
    }
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
                   [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES],
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