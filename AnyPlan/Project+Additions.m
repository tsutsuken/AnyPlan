//
//  Project+Additions.m
//  AnyPlan
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
