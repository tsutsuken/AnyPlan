//
//  MenuViewController.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/04/22.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "MenuViewController.h"

#define kSectionForSeparator 3

@interface MenuViewController ()

@end

@implementation MenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    self.navigationController.navigationBarHidden = YES;
    
    self.tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
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
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1)
    {
        return [[self.fetchedResultsController fetchedObjects] count];
    }
    else
    {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == kSectionForSeparator)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == kSectionForSeparator)
    {
        UIView *headerView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
        UIImageView *separator = [[UIImageView alloc] initWithFrame:CGRectMake(13, 0, 250, 1)];
        separator.image = [UIImage imageNamed:@"separator_dark"];
        
        [headerView addSubview:separator];
        
        return headerView;
    }
    else
    {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.selectedBackgroundView = [self highlightView];
    cell.titleLabel.textColor = kColorPaleWhite;
    cell.iconView.highlightedImage = nil;//highlightedImageが使い回されるのを防ぐため
    
    if (indexPath.section == 0)
    {
        UIColor *highlightedColor = [UIColor colorWithHexString:kColorHexDefaultProject];
        cell.titleLabel.highlightedTextColor = highlightedColor;
        
        cell.titleLabel.text = NSLocalizedString(@"Common_Project_Category_All", nil);
        cell.iconView.image = [[UIImage imageNamed:@"infinity"] imageTintedWithColor:highlightedColor];
    }
    else if (indexPath.section == 1)
    {
        Project *project = [self.fetchedResultsController objectAtIndexPath:[self projectIndexPathWithMenuIndexPath:indexPath]];
        
        cell.titleLabel.highlightedTextColor = [UIColor colorWithHexString:project.colorHex];
        
        cell.titleLabel.text = project.title;
        cell.iconView.image = project.iconWithColor;
    }
    else if (indexPath.section == 2)
    {
        cell.titleLabel.textColor = kColorMiddleGray;
        cell.titleLabel.highlightedTextColor = kColorPaleWhite;
        
        cell.titleLabel.text = NSLocalizedString(@"MenuView_Cell_AddProject", nil);
        cell.iconView.image = [[UIImage imageNamed:@"add"] imageTintedWithColor:kColorMiddleGray];
        cell.iconView.highlightedImage = [[UIImage imageNamed:@"add"] imageTintedWithColor:kColorPaleWhite];
    }
    else
    {
        cell.titleLabel.textColor = kColorMiddleGray;
        cell.titleLabel.highlightedTextColor = kColorPaleWhite;
        
        cell.titleLabel.text = NSLocalizedString(@"MenuView_Cell_Settings", nil);
        cell.iconView.image = [[UIImage imageNamed:@"gear"] imageTintedWithColor:kColorMiddleGray];
        cell.iconView.highlightedImage = [[UIImage imageNamed:@"gear"] imageTintedWithColor:kColorPaleWhite];
    }
    
    return cell;
}

- (UIView *)highlightView
{
    UIView *highlightView = [[UIView alloc] init];
    highlightView.backgroundColor = [UIColor colorWithHexString:@"1B1B1B"];
    
    return highlightView;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2)
    {
        if ([APPDELEGATE canAddNewProject])
        {
            [self showEditProjectView];
        }
        else
        {
            [self showUpgradeAccountView];
        }
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else
    {
        [self.viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller)
         {
             UIViewController *centerController;
             
             if (indexPath.section == 3)
             {
                 centerController = [self settingViewNavigationController];
             }
             else
             {
                 centerController = [self tabBarControllerWithMenuIndexPath:indexPath];
             }
             
             self.viewDeckController.centerController = centerController;
             
             [NSThread sleepForTimeInterval:(300+arc4random()%700)/1000000.0]; // mimic delay... not really necessary
         }];
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
        controller.isNew = YES;
        
        Project *newProject = (Project *)[NSEntityDescription insertNewObjectForEntityForName:@"Project" inManagedObjectContext:self.managedObjectContext];
        newProject.displayOrder = [NSNumber numberWithInt:[[self.fetchedResultsController fetchedObjects] count]];
        controller.project = newProject;
    }
}

#pragma mark EditProjectView

- (void)showEditProjectView
{
    [self performSegueWithIdentifier:@"showEditProjectView" sender:self];
}

#pragma mark UpgradeAccountView

- (void)showUpgradeAccountView
{
    [self performSegueWithIdentifier:@"showUpgradeAccountView" sender:self];
}

#pragma mark SettingView

- (void)showSettingView
{
    [self performSegueWithIdentifier:@"showSettingView" sender:self];
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
    
    /*
     CustomTabBarController *existingTabBarController = (CustomTabBarController *)self.viewDeckController.centerController;
     tabBarController.selectedIndex = existingTabBarController.selectedIndex;
     */
    
    return tabBarController;
}

- (UINavigationController *)settingViewNavigationController
{
    UIStoryboard* mainStoryBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    
    UINavigationController *navigationController = (UINavigationController*) [mainStoryBoard instantiateViewControllerWithIdentifier:@"SettingViewNavigationController"];
    
    SettingViewController *controller = (SettingViewController *)navigationController.topViewController;
    controller.managedObjectContext = self.managedObjectContext;
    
    return navigationController;
}

@end






