//
//  SettingViewController.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/05/11.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"SettingView_Title", nil);

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self action:@selector(didPushDoneButton)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CloseView

- (void)didPushDoneButton
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"SettingView_SectionHeader_Settings", nil);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (indexPath.row == 0)
    {
        cell.textLabel.text = NSLocalizedString(@"SettingView_Cell_ManageProject", nil);
    }
    else
    {
        cell.textLabel.text = NSLocalizedString(@"SettingView_Cell_Account", nil);
        cell.detailTextLabel.text = [[PFUser currentUser] username];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        [self showManageProjectView];
    }
    else
    {
        [self showUserAccountView];
    }
}

#pragma mark - Show Other View

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    LOG(@"%@", [segue identifier]);
    
    if([[segue identifier] isEqualToString:@"showManageProjectView"])
    {
        ManageProjectViewController *controller = (ManageProjectViewController *)segue.destinationViewController;
        controller.managedObjectContext = self.managedObjectContext;
    }
}

#pragma mark ManageProjectView

- (void)showManageProjectView
{
    [self performSegueWithIdentifier:@"showManageProjectView" sender:self];
}

#pragma mark UserAccountView

- (void)showUserAccountView
{
    [self performSegueWithIdentifier:@"showUserAccountView" sender:self];
}


@end
