//
//  NoteListViewController.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/04/28.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "NoteListViewController.h"

@interface NoteListViewController ()

@end

@implementation NoteListViewController

- (void)awakeFromNib
{
    self.title = NSLocalizedString(@"NoteListView_Title", nil);
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
                                                                                           action:@selector(showEditNoteView)];
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
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NoteCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoteCell"];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(NoteCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Note *note = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.titleLabel.text = note.title;
    cell.projectLabel.text = note.project.title;
    cell.bodyLabel.text = note.body;
    
    //Labelのサイズを調整
    [cell.bodyLabel sizeToFit];
    CGRect frame = cell.bodyLabel.frame;
    frame.size.width = 300;//セル再利用時の不具合を防ぐため
    [cell.bodyLabel setFrame:frame];
}

#pragma mark Section Header

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    Note *note = [[sectionInfo objects] objectAtIndex:0];
    
    return note.editedMonthString;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     [self performSegueWithIdentifier:@"showEditNoteView" sender:self.tableView];
}

#pragma mark - Show Other View

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    LOG(@"%@", [segue identifier]);
    
    if([[segue identifier] isEqualToString:@"showEditNoteView"])
    {
        EditNoteViewController *controller = (EditNoteViewController *)segue.destinationViewController;
        controller.delegate = self;
        
        BOOL isNewNote;
        Note *editingNote;
        
        if (sender == self.tableView)//Existing Task
        {
            isNewNote = NO;
            
            Note *selectedNote = [[self fetchedResultsController] objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
            editingNote = selectedNote;
        }
        else//New Note
        {
            isNewNote = YES;
            
            Note *newNote = (Note *)[NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:self.managedObjectContext];
            
            if (self.shouldDisplayAllProject)
            {
                newNote.project = [APPDELEGATE inboxProjectInManagedObjectContext:self.managedObjectContext];
            }
            else
            {
                newNote.project = self.project;
            }
            
            editingNote = newNote;
        }
        
        controller.isNewNote = isNewNote;
        controller.note = editingNote;
    }
}

#pragma mark EditTaskView

- (void)showEditNoteView
{
    [self performSegueWithIdentifier:@"showEditNoteView" sender:self.navigationItem.rightBarButtonItem];
}

- (void)editNoteViewController:(EditNoteViewController *)controller didFinishWithSave:(BOOL)save
{
    if (save)
    {
        controller.note.editedDate = [NSDate date];
        
        [controller.note saveContext];
        
        if (controller.isNewNote)
        {
            [self.tableView reloadData];//Tableviewに反映されないのを防ぐため。どうにかしたい
        }
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    [fetchRequest setPredicate:[self predicate]];
    
    // Edit the sort key as appropriate.
    NSArray *sortDescriptors = [NSArray arrayWithObjects:
                                [[NSSortDescriptor alloc] initWithKey:@"editedDate" ascending:NO],
                                nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"editedMonthString" cacheName:nil];
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
        predicate = nil;
    }
    else
    {
        predicate = [NSPredicate predicateWithFormat:@"project == %@", self.project];
    }
    
    return predicate;
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
            [self configureCell:(NoteCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
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
