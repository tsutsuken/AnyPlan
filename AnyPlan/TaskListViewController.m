//
//  TaskListViewController.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/04/24.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "TaskListViewController.h"

#define kTagForLabelInSectionHeaderView 1
#define kTagForButtonInSectionHeaderView 2
#define kErrorValueForSection -1
#define kSectionNameForCompletedTask @"1"
#define kShouldHideCompletedTask @"ShouldHideCompletedTask"

@interface TaskListViewController ()

@end

@implementation TaskListViewController
{
    BOOL shouldHideCompletedTask;
}

- (void)awakeFromNib
{
    self.title = NSLocalizedString(@"TaskListView_Title", nil);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[self.tableView setBackgroundViewForGroupedStyle];

    shouldHideCompletedTask = [[NSUserDefaults standardUserDefaults] boolForKey:kShouldHideCompletedTask];
    
    NavigationBarTitleWithSubtitleView *titleView = [[NavigationBarTitleWithSubtitleView alloc] init];
    [titleView setTitle:[APPDELEGATE mainTitleForTabBarWithProject:self.project shouldDisplayAllProject:self.shouldDisplayAllProject]];
    [titleView setDetailTitle:self.title];
    self.navigationItem.titleView = titleView;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"list.png"]
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self.viewDeckController
                                                                            action:@selector(toggleLeftView)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add.png"]
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(showEditTaskViewWithNewTask)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
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
    
    if (self.shouldDisplayAllProject)
    {
        return [sectionInfo numberOfObjects];
    }
    else
    {
        if (section == [self sectionForCompletedTask])
        {
            if (shouldHideCompletedTask)
            {
                return 0;
            }
            else
            {
                return [sectionInfo numberOfObjects];
            }
        }
        else
        {
            return [sectionInfo numberOfObjects];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.tableView.rowHeight;
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (!self.shouldDisplayAllProject && section != [self sectionForCompletedTask])
    {
        return 0;
    }
    else
    {
        return kHeightForSectionHeaderGrouped;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.shouldDisplayAllProject)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
        Task *task = [[sectionInfo objects] objectAtIndex:0];
        
        return [[SectionHeaderView alloc] initWithStyle:UITableViewStyleGrouped title:task.project.title];
    }
    else
    {
        if (section == [self sectionForCompletedTask])
        {
            return [self headerViewForCompletedTaskWithTitle:[self sectionTitleForCompletedTask]];
        }
        else
        {
            return nil;
        }
    }
}

- (int)sectionForCompletedTask
{
    int sectionForCompletedTask;
    
    int numberOfSections = [[self.fetchedResultsController sections] count];
    
    if (numberOfSections == 0)
    {
        sectionForCompletedTask = kErrorValueForSection;
    }
    else if (numberOfSections == 1)//完了or未完了
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
        if ([[sectionInfo name] isEqualToString:kSectionNameForCompletedTask])
        {
            sectionForCompletedTask = 0;
        }
        else
        {
            sectionForCompletedTask = kErrorValueForSection;
        }
    }
    else//完了＋未完了
    {
        sectionForCompletedTask = 1;
    }
    
    return sectionForCompletedTask;
}

- (UIControl *)headerViewForCompletedTaskWithTitle:(NSString *)title
{
    UIControl *headerView = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, kHeightForSectionHeaderGrouped)];
    [headerView addTarget:self action:@selector(didTouchSectionHeader) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *label = [[UILabel alloc] initWithFrame:kFrameForSectionHeaderLabelGrouped];
    label.tag = kTagForLabelInSectionHeaderView;
    label.text              = title;
    label.textColor         = [UIColor colorWithHexString:kColorHexSectionHeaderTitle];
    label.font              = [UIFont boldSystemFontOfSize:17.0];
    label.backgroundColor   = [UIColor clearColor];
    label.shadowColor       = [UIColor whiteColor];
    label.shadowOffset      = CGSizeMake(0, 1);
    label.textAlignment     = NSTextAlignmentLeft;
    label.numberOfLines     = 2;
    [headerView addSubview:label];
    
    UIButton *eyeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    eyeButton.tag = kTagForButtonInSectionHeaderView;
    eyeButton.userInteractionEnabled = NO;
    
    UIImage *eyeOpen = [UIImage imageNamed:@"eye_open.png"];
    UIImage *eyeClosed = [UIImage imageNamed:@"eye_closed.png"];
    [eyeButton setImage:eyeOpen forState:UIControlStateNormal];
    [eyeButton setImage:eyeClosed forState:UIControlStateSelected];
    
    LOG_SIZE(eyeOpen.size, nil);
    
    eyeButton.frame = CGRectMake(276, 20, eyeOpen.size.width, eyeOpen.size.height);
    
    eyeButton.selected = [[NSUserDefaults standardUserDefaults] boolForKey:kShouldHideCompletedTask];
    [headerView addSubview:eyeButton];
    
    return headerView;
}

- (void)didTouchSectionHeader
{
    [self.tableView beginUpdates];
    
    UIButton *eyeButton = (UIButton *)[self.view viewWithTag:kTagForButtonInSectionHeaderView];
    
    if (shouldHideCompletedTask)//Old Value
    {
        shouldHideCompletedTask = NO;
        eyeButton.selected = NO;
        [self.tableView insertRowsAtIndexPaths:[self indexPathsForCompletedTask] withRowAnimation:UITableViewRowAnimationFade];
    }
    else
    {
        shouldHideCompletedTask = YES;
        eyeButton.selected = YES;
        [self.tableView deleteRowsAtIndexPaths:[self indexPathsForCompletedTask] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:shouldHideCompletedTask forKey:kShouldHideCompletedTask];
    [ud synchronize];
    
    [self.tableView endUpdates];
}

- (NSString *)sectionTitleForCompletedTask
{
    return [NSString stringWithFormat: NSLocalizedString(@"TaskListView_SectionHeader_CompletedTask_%i", nil),[self countOfCompletedTask]];
}

- (NSArray *)indexPathsForCompletedTask
{
    int sectionForCompletedTask = [self sectionForCompletedTask];
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:sectionForCompletedTask];
    
    NSMutableArray *indexPathsForCompletedTask = [NSMutableArray array];
    
    for (int i = 0;i < [sectionInfo numberOfObjects]; i++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:sectionForCompletedTask];
        [indexPathsForCompletedTask addObject:indexPath];
    }
    
    return [indexPathsForCompletedTask copy];
}

- (void)updateLabelInSectionHeaderView
{
    UILabel *label = (UILabel*)[self.view viewWithTag:kTagForLabelInSectionHeaderView];
    label.text = [self sectionTitleForCompletedTask];;
}

- (int)countOfCompletedTask
{
    int countOfCompletedTask;
    
    int sectionForCompletedTask = [self sectionForCompletedTask];
    
    if (sectionForCompletedTask == kErrorValueForSection)
    {
        countOfCompletedTask = 0;
    }
    else
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:sectionForCompletedTask];
        countOfCompletedTask = [sectionInfo numberOfObjects];
    }
    
    return countOfCompletedTask;
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
                
                [ANALYTICS trackEvent:kEventExecuteTask sender:self];
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
            
            if (newIndexPath.section == [self sectionForCompletedTask] && shouldHideCompletedTask)
            {
                //Do nothing
            }
            else
            {
                [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
            break;
    }
    
    [self updateLabelInSectionHeaderView];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

@end