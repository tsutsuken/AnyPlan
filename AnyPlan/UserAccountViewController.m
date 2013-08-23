//
//  UserAccountViewController.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 2013/06/28.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "UserAccountViewController.h"

@interface UserAccountViewController ()

@property (strong, nonatomic) MBProgressHUD *HUD;

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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([APPDELEGATE isPremiumUser])
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (indexPath.row == 0)
    {
        cell.textLabel.text = NSLocalizedString(@"UserAccountView_Cell_Restore", nil);
    }
    else
    {
        cell.textLabel.text = NSLocalizedString(@"UserAccountView_Cell_ManageSubscription", nil);
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        [self restorePurchase];
    }
    else
    {
        [self showManageSubscriptionView];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Restore

- (void)restorePurchase
{
    [self showHUD];
    
    [[MKStoreManager sharedManager] restorePreviousTransactionsOnComplete:^()
    {
        LOG(@"Restored");
        [self hideHUDWithCompleted:YES];
    }
                                                                  onError:^(NSError* error)
    {
        LOG(@"Canceled");
        [self hideHUDWithCompleted:NO];
    }];
}

#pragma mark - Manage Subscription

- (void)showManageSubscriptionView
{
    NSURL *url = [NSURL URLWithString:@"https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions"];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)showHUD
{
	self.HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:self.HUD];
	
	self.HUD.delegate = self;
	self.HUD.labelText = NSLocalizedString(@"UserAccountView_HUD_Restore", nil);
	self.HUD.minSize = CGSizeMake(135.f, 135.f);
	
	[self.HUD show:YES];
}

- (void)hideHUDWithCompleted:(BOOL)isCompleted
{
    NSString *imageName;
    NSString *labelText;
    
    if (isCompleted)
    {
        imageName = @"check_HUD.png";
        labelText = NSLocalizedString(@"UserAccountView_HUD_Completed", nil);
    }
    else
    {
        imageName = @"cross_HUD.png";
        labelText = NSLocalizedString(@"UserAccountView_HUD_Canceled", nil);;
    }
    
    self.HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    self.HUD.mode = MBProgressHUDModeCustomView;
    self.HUD.labelText = labelText;
    [self.HUD hide:YES afterDelay:1];
}

@end
