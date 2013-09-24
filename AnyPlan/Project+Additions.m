//
//  Project+Additions.m
//  Anyplan
//
//  Created by Ken Tsutsumi on 13/04/23.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "Project+Additions.h"

@implementation Project (Additions)

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
    }
}

- (void)deleteWithRefreshDisplayOrder:(BOOL)shouldRefresh
{
    [self.managedObjectContext deleteObject:self];
    
    if (shouldRefresh)
    {
        [self refreshDisplayOrderOfProjects];
    }
}

#pragma mark - Icon

- (UIImage *)iconWithColor
{
    UIImage *iconWithColor;
    
    UIImage *iconNormal = self.icon;
    UIColor *color = [UIColor colorWithHexString:self.colorHex];
    iconWithColor = [iconNormal imageTintedWithColor:color];
    
    return iconWithColor;
}

#pragma mark - DisplayOrder of Tasks

- (void)refreshDisplayOrderOfTasks
{
    //displayOrderに空白が出来ないようにする
    NSArray *sortedTasks = [self sortedTasks];
    int index = 0;
    
    for (Task * task in sortedTasks)
    {
        task.displayOrder = @(index);
        index++;
        
        LOG(@"%@ %@", task.displayOrder, task.title);
    }
}

- (NSArray *)sortedTasks
{
    //未完了のタスクのみ取得
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:self.managedObjectContext];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(project == %@) AND (isDone == NO)", self];
    
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"displayOrder" ascending:YES]];
    
    NSArray* sortedTasks = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    return sortedTasks;
}

- (int)numberOfUncompletedTask
{
    int uncompletedTaskCount;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    request.entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:self.managedObjectContext];
    request.predicate = [NSPredicate predicateWithFormat:@"(project == %@) AND (isDone == NO)", self];
    request.includesSubentities = NO;
    
    uncompletedTaskCount = [self.managedObjectContext countForFetchRequest:request error:nil];
    
    LOG(@"uncompletedTaskCount_%i", uncompletedTaskCount);
    
    return uncompletedTaskCount;
}

#pragma mark - DisplayOrder of Projects

- (void)refreshDisplayOrderOfProjects
{
    //displayOrderに空白が出来ないようにする
    NSArray *sortedLists = [self sortedProjects];
    int index = 0;
    
    for (Project * project in sortedLists)
    {
        project.displayOrder = @(index);
        index++;
    }
}

- (NSArray *)sortedProjects
{
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.entity = [NSEntityDescription entityForName:@"Project" inManagedObjectContext:self.managedObjectContext];
    
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"displayOrder" ascending:YES]];
    
    NSArray* sortedLists = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    return sortedLists;
}

@end

@implementation ImageToDataTransformer

//http://blog.natsuapps.com/2010/02/core-data-9.htmlを参照

+ (BOOL)allowsReverseTransformation
{
	return YES;
}

+ (Class)transformedValueClass
{
	return [NSData class];
}

- (id)transformedValue:(id)value
{
    //UIImageからNSDataへ変換
	NSData *data = UIImagePNGRepresentation(value);
	return data;
}

- (id)reverseTransformedValue:(id)value
{
    //NSDataからUIImageへ変換
	UIImage *uiImage = [[UIImage alloc] initWithData:value];
	return uiImage;
}

@end
