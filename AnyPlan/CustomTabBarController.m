//
//  CustomTabBarController.m
//  Anyplan
//
//  Created by Ken Tsutsumi on 13/04/28.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "CustomTabBarController.h"

#define kKeyLastSelectedIndex @"kKeyLastSelectedIndex"

@interface CustomTabBarController ()

@end

@implementation CustomTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.delegate = self;
    
    self.selectedIndex = [[NSUserDefaults standardUserDefaults] integerForKey:kKeyLastSelectedIndex];
    
    for (UINavigationController *nvc in self.viewControllers)
    {
        id viewController = nvc.topViewController;
        [viewController setManagedObjectContext:self.managedObjectContext];
        [viewController setProject:self.project];
        [viewController setShouldDisplayAllProject:self.shouldDisplayAllProject];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITabBarController delegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    int selectedIndex = tabBarController.selectedIndex;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults] ;
    [userDefaults setInteger:selectedIndex forKey:kKeyLastSelectedIndex];
    [userDefaults synchronize];
}

@end





