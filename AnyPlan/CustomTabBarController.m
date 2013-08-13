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
    
    //[self setNotificationCenter];
    
    for (UINavigationController *nvc in self.viewControllers)
    {
        id viewController = nvc.topViewController;
        [viewController setManagedObjectContext:self.managedObjectContext];
        [viewController setProject:self.project];
        [viewController setShouldDisplayAllProject:self.shouldDisplayAllProject];
    }
}

- (void)setNotificationCenter
{
    //どうやっても重複しなかった。対応されたのかも。
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didCloseManageProjectView)
                                                 name:kNotificationDidCloseManageProjectView object:nil];
}

- (void)didCloseManageProjectView
{
    //projectのdisplayorder変更を反映
      //手動でデータを反映させるため、fetchし直す
    for (UINavigationController *nvc in self.viewControllers)
    {
        id viewController = nvc.topViewController;
        [viewController setFetchedResultsController:nil];
        [[viewController tableView] reloadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
