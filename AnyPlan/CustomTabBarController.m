//
//  CustomTabBarController.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/04/28.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "CustomTabBarController.h"

@interface CustomTabBarController ()

@end

@implementation CustomTabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    for (UINavigationController *nvc in self.viewControllers)
    {
        id viewController = nvc.topViewController;
        [viewController setManagedObjectContext:self.managedObjectContext];
        [viewController setProject:self.project];
        [viewController setShouldDisplayAllProject:self.shouldDisplayAllProject];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![PFUser currentUser])// No user logged in
    {
        [self showWelcomeView];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Show Other View
#pragma mark WelcomeView

- (void)showWelcomeView
{
    [self performSegueWithIdentifier:@"showWelcomeView" sender:self];
}

@end
