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
@property (strong, nonatomic) IBOutlet UIButton *purchaseMonthButton;
@property (strong, nonatomic) IBOutlet UIButton *purchaseYearButton;
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
        [ANALYTICS trackEvent:kEventShowUpgradeViewByLimit sender:self];
    }
    else
    {
        [ANALYTICS trackEvent:kEventShowUpgradeViewByButton sender:self];
    }
    
    [self setPurchaseButtons];
    
    self.explanationLabel.text = NSLocalizedString(@"UpgradeAccountView_Explanation", nil);
    [self.explanationLabel sizeToFit];
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

- (void)setPurchaseButtons
{
    NSDictionary *prices = [[MKStoreManager sharedManager] pricesDictionary];
    
    //Month
    NSString *titleForMonth;
    if ([[MKStoreManager sharedManager] isSubscriptionActive:kProductIdSubscriptionMonth])
    {
        titleForMonth = NSLocalizedString(@"UpgradeAccountView_Button_Purchased", nil);
    }
    else
    {
        titleForMonth = [NSString stringWithFormat: NSLocalizedString(@"UpgradeAccountView_Unit_Month_%@", nil),
                         [prices objectForKey:kProductIdSubscriptionMonth]];
    }
    
    [self.purchaseMonthButton setTitle:titleForMonth forState:UIControlStateNormal];
    [self.purchaseMonthButton addTarget:self action:@selector(didPushPurchaseMonthButton) forControlEvents:UIControlEventTouchUpInside];
    
    
    //Year
    NSString *titleForYear;
    if ([[MKStoreManager sharedManager] isSubscriptionActive:kProductIdSubscriptionYear])
    {
        titleForYear = NSLocalizedString(@"UpgradeAccountView_Button_Purchased", nil);
    }
    else
    {
        titleForYear = [NSString stringWithFormat: NSLocalizedString(@"UpgradeAccountView_Unit_Year_%@", nil),
                        [prices objectForKey:kProductIdSubscriptionYear]];
    }
    
    [self.purchaseYearButton setTitle:titleForYear forState:UIControlStateNormal];
    [self.purchaseYearButton addTarget:self action:@selector(didPushPurchaseYearButton) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Purchase

- (void)didPushPurchaseMonthButton
{
    [self showHUD];
    
    [self purchaseItemWithProductId:kProductIdSubscriptionMonth];
}

- (void)didPushPurchaseYearButton
{
    [self showHUD];
    
    [self purchaseItemWithProductId:kProductIdSubscriptionYear];
}

- (void)purchaseItemWithProductId:(NSString *)productId
{
    [[MKStoreManager sharedManager] buyFeature:productId
                                    onComplete:^(NSString *purchasedFeature, NSData *purchasedReceipt, NSArray *availableDownloads)
     {
         NSLog(@"Purchased: %@", purchasedFeature);
         
         [self hideHUDWithCompleted:YES];
         
         [self setPurchaseButtons];
         
         if ([purchasedFeature isEqualToString:kProductIdSubscriptionMonth])
         {
             [ANALYTICS trackEvent:kEventPurchasePremiumMonth sender:self];
             [ANALYTICS registerSuperProperties:@{kPropertyKeyAccountType: kPropertyValueAccountTypePremiumMonth}];
         }
         else
         {
             [ANALYTICS trackEvent:kEventPurchasePremiumYear sender:self];
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
