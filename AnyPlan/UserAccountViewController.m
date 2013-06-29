//
//  UserAccountViewController.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 2013/06/28.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "UserAccountViewController.h"

@interface UserAccountViewController ()

@end

@implementation UserAccountViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"UserAccountView_Title", nil);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];//Account情報変更後のデータを反映させるため
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        cell.textLabel.text = NSLocalizedString(@"UserAccountView_Cell_Email", nil);
        cell.detailTextLabel.text = [[PFUser currentUser] email];
        
        return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LogOutCell" forIndexPath:indexPath];
        cell.textLabel.text = @"ログアウト";
        
        return cell;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        [self showChangeEmailView];
    }
    else
    {
        [PFUser logOut];
    }
}

#pragma mark - Show Other View
#pragma mark ChangeEmailView

- (void)showChangeEmailView
{
    [self performSegueWithIdentifier:@"showChangeEmailView" sender:self];
}

@end
