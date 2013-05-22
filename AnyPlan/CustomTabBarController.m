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
    
    [self switchTaskListView];
    
    for (UINavigationController *nvc in self.viewControllers)
    {
        id viewController = nvc.topViewController;
        [viewController setManagedObjectContext:self.managedObjectContext];
        [viewController setProject:self.project];
        [viewController setShouldDisplayAllProject:self.shouldDisplayAllProject];
    }
}

- (void)switchTaskListView
{
    LOG_METHOD;
    
    NSMutableArray *newViewControllers =  [NSMutableArray arrayWithArray:self.viewControllers];
    
    if (self.shouldDisplayAllProject)
    {
        [newViewControllers removeObjectAtIndex:1];
    }
    else
    {
        [newViewControllers removeObjectAtIndex:0];
    }
    
    [self setViewControllers:newViewControllers animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
