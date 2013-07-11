//
//  SettingViewController.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/05/11.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()

@property (assign, nonatomic) BOOL isPremiumUser;

@end

@implementation SettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"SettingView_Title", nil);

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self action:@selector(didPushDoneButton)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //購入完了後に、購入ボタンが表示されるのを防ぐため
    self.isPremiumUser = [APPDELEGATE isPremiumUser];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [ANALYTICS trackView:self];
}

- (NSString *)currentPlan
{
    NSString *currentPlan;
    
    if ([[MKStoreManager sharedManager] isSubscriptionActive:kProductIdSubscriptionMonth])
    {
        currentPlan = NSLocalizedString(@"SettingView_PlanType_Premium_Month", nil);
    }
    else if ([[MKStoreManager sharedManager] isSubscriptionActive:kProductIdSubscriptionMonth])
    {
        currentPlan = NSLocalizedString(@"SettingView_PlanType_Premium_Year", nil);
    }
    else
    {
        currentPlan = NSLocalizedString(@"SettingView_PlanType_Free", nil);
    }
    
    return currentPlan;
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
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return NSLocalizedString(@"SettingView_SectionHeader_Account", nil);
    }
    else
    {
        return NSLocalizedString(@"SettingView_SectionHeader_Settings", nil);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0)
    {
        if (self.isPremiumUser)
        {
            return 0;
        }
        else
        {
            return 53;
        }
    }
    else
    {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0)
    {
        if (self.isPremiumUser)
        {
            return nil;
        }
        else
        {
            return [self viewForFooter];
        }
    }
    else
    {
        return nil;
    }
}

#pragma mark Section Header

- (UIView *)viewForFooter
{
    int heightForHeader = 53;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, heightForHeader)];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self action:@selector(didPushFooterButton) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:NSLocalizedString(@"SettingView_SectionFooter_BecomePremium", nil) forState:UIControlStateNormal];
    button.frame = CGRectMake(10, 5, 300, heightForHeader - 10);
    [headerView addSubview:button];
                      
    return headerView;
}

- (void)didPushFooterButton
{
    LOG_METHOD;
    
    [self showUpgradeAccountView];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 2;
    }
    else
    {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            cell.textLabel.text = NSLocalizedString(@"SettingView_Cell_Plan", nil);
            cell.detailTextLabel.text = [self currentPlan];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else
        {
            cell.textLabel.text = NSLocalizedString(@"SettingView_Cell_Account", nil);
            //cell.detailTextLabel.text = [[PFUser currentUser] username];
        }
    }
    else
    {
        cell.textLabel.text = NSLocalizedString(@"SettingView_Cell_ManageProject", nil);
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 1)
        {
            [self showUserAccountView];
        }
    }
    else
    {
        [self showManageProjectView];
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

#pragma mark UpgradeAccountView

- (void)showUpgradeAccountView
{
    [self performSegueWithIdentifier:@"showUpgradeAccountView" sender:self];
}


@end
