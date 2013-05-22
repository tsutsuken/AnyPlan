//
//  Task+Additions.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/04/24.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "Task+Additions.h"

@implementation Task (Additions)

- (void)saveContext
{
    LOG_METHOD;
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    else {
        LOG(@"Saved Context");
    }
}

- (NSString *)projectTitle
{
    NSString *projectTitle;
    
    if (self.project)
    {
        projectTitle = self.project.title;
    }
    else
    {
        projectTitle = NSLocalizedString(@"Common_Project_Category_Inbox", nil);
    }
    
    return projectTitle;
}

@end
