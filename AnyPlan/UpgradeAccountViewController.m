//
//  UpgradeAccountViewController.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 2013/06/30.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "UpgradeAccountViewController.h"

@interface UpgradeAccountViewController ()

@property (strong, nonatomic) MBProgressHUD *HUD;
@property (strong, nonatomic) IBOutlet UILabel *explanationLabel;

@end

@implementation UpgradeAccountViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.title = NSLocalizedString(@"UpgradeAccountView_Title", nil);
    
    if (self.navigationController.isBeingPresented)//Modalによって表示された場合
    {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                              target:self action:@selector(didPushCancelButton)];
        [ANALYTICS trackEvent:kEventShowUpgradeViewByLimit isImportant:YES sender:self];
    }
    else
    {
        [ANALYTICS trackEvent:kEventShowUpgradeViewByButton isImportant:YES sender:self];
    }
    
    self.explanationLabel.attributedText = [self attributedTextForHeader];
    //[self.explanationLabel sizeToFit];
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

- (void)didPushCancelButton
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (indexPath.section == 0)
    {
        cell.textLabel.text = [self labelTitleForMonthCell];
    }
    else
    {
        cell.textLabel.text = [self labelTitleForYearCell];
    }
    
    return cell;
}

- (NSString *)labelTitleForMonthCell
{
    NSDictionary *prices = [[MKStoreManager sharedManager] pricesDictionary];
    
    NSString *title;
    
    if ([[MKStoreManager sharedManager] isSubscriptionActive:kProductIdSubscriptionMonth])
    {
        title = NSLocalizedString(@"UpgradeAccountView_Button_Purchased", nil);
    }
    else
    {
        title = [NSString stringWithFormat: NSLocalizedString(@"UpgradeAccountView_Unit_Month_%@", nil),
                         [prices objectForKey:kProductIdSubscriptionMonth]];
    }
    
    return title;
}

- (NSString *)labelTitleForYearCell
{
    NSDictionary *prices = [[MKStoreManager sharedManager] pricesDictionary];
    
    NSString *title;
    
    if ([[MKStoreManager sharedManager] isSubscriptionActive:kProductIdSubscriptionYear])
    {
        title = NSLocalizedString(@"UpgradeAccountView_Button_Purchased", nil);
    }
    else
    {
        title = [NSString stringWithFormat: NSLocalizedString(@"UpgradeAccountView_Unit_Year_%@", nil),
                 [prices objectForKey:kProductIdSubscriptionYear]];
    }
    
    return title;
}

#pragma mark HeaderView

- (NSAttributedString *)attributedTextForHeader
{
    NSAttributedString *attributedTextForHeader;
    
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] init];
    
    NSAttributedString *string1 = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"UpgradeAccountView_Header_Part_1", nil)
                                                                  attributes:nil];
    [mutableAttributedString appendAttributedString:string1];
    
    NSDictionary *attributes2 = @{ NSFontAttributeName : [UIFont boldSystemFontOfSize:17] };
    NSAttributedString *string2 = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"UpgradeAccountView_Header_Part_2", nil)
                                                                  attributes:attributes2];
    [mutableAttributedString appendAttributedString:string2];
    
    NSAttributedString *string3 = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"UpgradeAccountView_Header_Part_3", nil)
                                                                  attributes:nil];
    [mutableAttributedString appendAttributedString:string3];
    
    
    attributedTextForHeader = [mutableAttributedString copy];
    
    return attributedTextForHeader;
}

#pragma mark Section Footer

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    NSString *title;
    
    if (section == 0)
    {
        title = NSLocalizedString(@"UpgradeAccountView_SectionFooter_Month", nil);
    }
    else
    {
        title = NSLocalizedString(@"UpgradeAccountView_SectionFooter_Year", nil);
    }
    
    return [self footerViewWithTitle:title];
}

- (UIView *)footerViewWithTitle:(NSString *)title
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(19, 0, 282, 20)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithHexString:kColorHexSectionHeaderTitle];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0, 1);
    label.font = [UIFont boldSystemFontOfSize:15.0];
    label.text = title;
    
    /*
    footerView.backgroundColor = [UIColor blackColor];
    label.backgroundColor = [UIColor redColor];
    */
    
    [footerView addSubview:label];
    
    return footerView;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self showHUD];
    
    if (indexPath.section == 0)
    {
        [self purchaseItemWithProductId:kProductIdSubscriptionMonth];
    }
    else
    {
        [self purchaseItemWithProductId:kProductIdSubscriptionYear];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Purchase

- (void)purchaseItemWithProductId:(NSString *)productId
{
    [[MKStoreManager sharedManager] buyFeature:productId
                                    onComplete:^(NSString *purchasedFeature, NSData *purchasedReceipt, NSArray *availableDownloads)
     {
         NSLog(@"Purchased: %@", purchasedFeature);
         
         [self hideHUDWithCompleted:YES];
         
         if ([purchasedFeature isEqualToString:kProductIdSubscriptionMonth])
         {
             [ANALYTICS trackEvent:kEventPurchasePremiumMonth isImportant:YES sender:self];
             [ANALYTICS registerSuperProperties:@{kPropertyKeyAccountType: kPropertyValueAccountTypePremiumMonth}];
         }
         else
         {
             [ANALYTICS trackEvent:kEventPurchasePremiumYear isImportant:YES sender:self];
             [ANALYTICS registerSuperProperties:@{kPropertyKeyAccountType: kPropertyValueAccountTypePremiumYear}];
         }
         
        [self closeView];
     }
                                   onCancelled:^
     {
         // User cancels the transaction, you can log this using any analytics software like Flurry.
         LOG(@"cancel");
         
         [self hideHUDWithCompleted:NO];
     }];
}

- (void)closeView
{
    int childViewCount = [self.navigationController.childViewControllers count];
    
    if (childViewCount == 1)//NVCのトップ画面=Modalで表示された
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else//NVCの２画面目以降
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)showHUD
{
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
	[self.view.window addSubview:self.HUD];
    
	self.HUD.delegate = self;
	self.HUD.labelText = NSLocalizedString(@"UpgradeAccountView_HUD_Accessing", nil);
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
        labelText = NSLocalizedString(@"UpgradeAccountView_HUD_Completed", nil);
    }
    else
    {
        imageName = @"cross_HUD.png";
        labelText = NSLocalizedString(@"UpgradeAccountView_HUD_Canceled", nil);;
    }
    
    self.HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    self.HUD.mode = MBProgressHUDModeCustomView;
    self.HUD.labelText = labelText;
    [self.HUD hide:YES afterDelay:1];
}

@end
