//
//  MenuViewController.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/04/22.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "MenuViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"MenuView_SectionHeader_Project", nil);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return tableView.sectionHeaderHeight;
    }else
    {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int numberOfRows;
    
    if (section == 0)
    {
        numberOfRows = 1;
    }
    else if (section == 1)
    {
        numberOfRows = [[self.fetchedResultsController fetchedObjects] count];
    }
    else
    {
        numberOfRows = 1;
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        ProjectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProjectCell"];
        cell.titleLabel.text = NSLocalizedString(@"Common_Project_Category_All", nil);
        cell.iconView.image = [UIImage imageNamed:@"eye_opened"];
        
        return cell;
    }
    else if (indexPath.section == 1)
    {
        ProjectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProjectCell"];
        Project *project = [self.fetchedResultsController objectAtIndexPath:[self projectIndexPathWithMenuIndexPath:indexPath]];
        cell.titleLabel.text = project.title;
        cell.iconView.image = project.icon;
        
        return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddProjectCell"];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:38];
        cell.textLabel.text = @"　　　+";
        
        return cell;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 ||indexPath.section == 1)
    {
        [self.viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller)
         {
             self.viewDeckController.centerController = [self tabBarControllerWithMenuIndexPath:indexPath];
             
             [NSThread sleepForTimeInterval:(300+arc4random()%700)/1000000.0]; // mimic delay... not really necessary
         }];
    }
    else
    {
        [self showEditProjectView];
    }
}

#pragma mark - Show Other View

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    LOG(@"%@", [segue identifier]);
    
    if([[segue identifier] isEqualToString:@"showEditProjectView"])
    {
        UINavigationController *navigationController = (UINavigationController*)segue.destinationViewController;
        EditProjectViewController *controller = (EditProjectViewController *)navigationController.topViewController;
        controller.isNewProject = YES;
        
        Project *newProject = (Project *)[NSEntityDescription insertNewObjectForEntityForName:@"Project" inManagedObjectContext:self.managedObjectContext];
        newProject.displayOrder = [NSNumber numberWithInt:[[self.fetchedResultsController fetchedObjects] count]];
        controller.project = newProject;
    
    }
    if([[segue identifier] isEqualToString:@"showSettingView"])
    {
        UINavigationController *navigationController = (UINavigationController*)segue.destinationViewController;
        SettingViewController *controller = (SettingViewController *)navigationController.topViewController;
        controller.managedObjectContext = self.managedObjectContext;
    }
}

#pragma mark EditProjectView

- (void)showEditProjectView
{
    [self performSegueWithIdentifier:@"showEditProjectView" sender:self];
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

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    [self.tableView reloadData];
}

- (NSIndexPath *)projectIndexPathWithMenuIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *indexPathForProjectWith = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
    
    return indexPathForProjectWith;
}

- (UITabBarController *)tabBarControllerWithMenuIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard* mainStoryBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    
    CustomTabBarController *tabBarController = (CustomTabBarController*) [mainStoryBoard instantiateViewControllerWithIdentifier:@"CenterTabBarController"];
    tabBarController.managedObjectContext = self.managedObjectContext;
    
    if (indexPath.section == 0)
    {
        //すべて
        tabBarController.shouldDisplayAllProject = YES;
    }
    else
    {
        tabBarController.project = [self.fetchedResultsController objectAtIndexPath:[self projectIndexPathWithMenuIndexPath:indexPath]];
    }
    
    CustomTabBarController *existingTabBarController = (CustomTabBarController *)self.viewDeckController.centerController;
    tabBarController.selectedIndex = existingTabBarController.selectedIndex;
    
    return tabBarController;
}

@end
