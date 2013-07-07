//
//  ManageProjectViewController.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/05/11.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "ManageProjectViewController.h"

@interface ManageProjectViewController ()

@end

@implementation ManageProjectViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"ManageProjectView_Title", nil);
    self.myToolbar.items = [NSArray arrayWithObjects:self.self.editButtonItem, nil];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                           target:self
                                                                                           action:@selector(didPushAddButton)];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (![[self.navigationController viewControllers] containsObject:self])//前のViewに戻った時
    {
        [self saveContext];//Editボタン押し忘れのため(追加、編集については対応済み)
    }
    else//次のViewに行った時
    {
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //UITableViewControllerではないため、手動でやる必要がある
    NSIndexPath *indexPath = self.myTableView.indexPathForSelectedRow;
    if (indexPath)
    {
        [self.myTableView deselectRowAtIndexPath:indexPath animated:animated];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveContext
{
    NSError *error = nil;
    if (![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    else{
        NSLog(@"Saved Context");
    }
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
    ProjectCell *cell = (ProjectCell *)[tableView dequeueReusableCellWithIdentifier:@"ProjectCell"];
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(ProjectCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Project *project = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.titleLabel.text = project.title;
    cell.iconView.image = project.icon;
}

- (BOOL)tableView:(UITableView*)tableView canMoveRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.row == 0)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (NSIndexPath*)tableView:(UITableView*)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath*)sourceIndexPath toProposedIndexPath:(NSIndexPath*)proposedDestinationIndexPath
{
    if (proposedDestinationIndexPath.row == 0)
    {
        return sourceIndexPath;
    }
    else
    {
        return proposedDestinationIndexPath;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showEditProjectView" sender:self.myTableView];
}

#pragma mark - Edit

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    [self.myTableView setEditing:editing animated:animated];
    
    if (editing)
    {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else
    {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [self saveContext];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        Project *deletingProject = [self.fetchedResultsController objectAtIndexPath:indexPath];
		[self.managedObjectContext deleteObject:deletingProject];
        [deletingProject saveContext];
        
        [self refreshDisplayOrder];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    //http://stackoverflow.com/questions/1648223/how-can-i-maintain-display-order-in-uitableview-using-core-data
    
    NSUInteger fromRow = fromIndexPath.row;
    NSUInteger toRow = toIndexPath.row;
    
    Project *movingProject = [self.fetchedResultsController.fetchedObjects objectAtIndex:fromRow];
    movingProject.displayOrder =  [[NSNumber alloc] initWithInteger:toRow];
    
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
    NSLog(@"Change Displey Order from cellAtIndex:%i to cellAtIndex:%i", start, end);
    
    for (NSUInteger i = start; i <= end; i++)
    {
        Project *aProject = [self.fetchedResultsController.fetchedObjects objectAtIndex:i];
        NSLog(@"「%@」 Displey Order changed from %i to %i",aProject.title, [aProject.displayOrder intValue], [aProject.displayOrder intValue]+delta);
        
        int newDisplayOrderInt = [aProject.displayOrder intValue] + delta;
        aProject.displayOrder =  [[NSNumber alloc] initWithInt:newDisplayOrderInt];
    }
}

- (void)refreshDisplayOrder
{
    //プロジェクトの削除で、displayOrderに空白が出来ないようにする
    NSUInteger index = 0;
    
    Project * aProject;
    for (aProject in self.fetchedResultsController.fetchedObjects)
    {
        aProject.displayOrder = [NSNumber numberWithInt:index];
        index++;
    }
}

#pragma mark - Show Other View

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    LOG(@"%@", [segue identifier]);
    
    if([[segue identifier] isEqualToString:@"showEditProjectView"])
    {
        EditProjectViewController *controller = (EditProjectViewController *)segue.destinationViewController;

        if (sender == self.myTableView)//Existing Project
        {
            controller.isNewProject = NO;
            controller.project = [[self fetchedResultsController] objectAtIndexPath:[self.myTableView indexPathForSelectedRow]];
        }
        else//New Project
        {
            controller.isNewProject = YES;
            
            Project *newProject = (Project *)[NSEntityDescription insertNewObjectForEntityForName:@"Project" inManagedObjectContext:self.managedObjectContext];
            newProject.displayOrder = [NSNumber numberWithInt:[[self.fetchedResultsController fetchedObjects] count]];
            controller.project = newProject;
        }
    }
}

- (void)didPushAddButton
{
    if ([APPDELEGATE canAddNewProject])
    {
        [self showEditProjectViewWithNewProject];
    }
    else
    {
        [self showUpgradeAccountView];
    }
}

#pragma mark EditProjectView

- (void)showEditProjectViewWithNewProject
{
    [self performSegueWithIdentifier:@"showEditProjectView" sender:self.navigationItem.rightBarButtonItem];
}

#pragma mark UpgradeAccountView

- (void)showUpgradeAccountView
{
    [self performSegueWithIdentifier:@"showUpgradeAccountView" sender:self];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchedResultsController *aFetchedResultsController = [APPDELEGATE fetchedResultsControllerForProjectWithContext:self.managedObjectContext];
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

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.myTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.myTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.myTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.myTableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(ProjectCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.myTableView endUpdates];
}

@end
