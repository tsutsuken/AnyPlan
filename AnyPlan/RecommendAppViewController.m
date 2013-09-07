//
//  RecommendAppViewController.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 2013/08/26.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "RecommendAppViewController.h"

#define kAppIdLvUP @"523946175"
#define kAppIdWannaDo @"668425656"

@interface RecommendAppViewController ()

@end

@implementation RecommendAppViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"RecommendAppView_Title", nil);
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    CALayer * layer = [cell.iconView layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:5];
    
    if (indexPath.row == 0)
    {
        cell.iconView.image = [UIImage imageNamed:@"appIcon_lvup"];
        cell.titleLabel.text = NSLocalizedString(@"RecommendAppView_Cell_LvUP", nil);
    }
    else
    {
        cell.iconView.image = [UIImage imageNamed:@"appIcon_wannaDo"];
        cell.titleLabel.text = NSLocalizedString(@"RecommendAppView_Cell_WannaDo", nil);
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *appId;
    
    switch (indexPath.row)
    {
        case 0:
            appId = kAppIdLvUP;
            [ANALYTICS trackEvent:kEventOpenAppStoreLvUP isImportant:YES sender:self];
            break;
            
        case 1:
            appId = kAppIdWannaDo;
            [ANALYTICS trackEvent:kEventOpenAppStoreWannaDo isImportant:YES sender:self];
            break;
            
        default:
            break;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@", appId]];
    [[UIApplication sharedApplication] openURL:url];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end


