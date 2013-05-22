//
//  SelectProjectViewController.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/05/20.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "SelectProjectViewController.h"

@interface SelectProjectViewController ()

@end

@implementation SelectProjectViewController

#define kObjectKeyForProjectData @"kObjectKeyForProjectData"
#define kTitleKeyForProjectData @"kTitleKeyForProjectData"

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"SelectProjectView_Title", nil);
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
    return [self.projectDataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    cell.textLabel.text = [[self.projectDataArray objectAtIndex:indexPath.row] objectForKey:kTitleKeyForProjectData];
    
    Project *project = [[self.projectDataArray objectAtIndex:indexPath.row] objectForKeyNull:kObjectKeyForProjectData];
    if (self.task.project == project)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (NSArray *)projectDataArray
{
    if (_projectDataArray != nil) {
        return _projectDataArray;
    }
    
    NSMutableArray *projectDataArray = [NSMutableArray array];
    
    //未分類プロジェクトデータを挿入
    [projectDataArray addObject:[self dataForInboxProject]];
    
    //その他のプロジェクトデータを挿入
    NSArray *userAddedProjectArray = [self userAddedProjectArray];
    for (Project *aProject in userAddedProjectArray)
    {
        NSDictionary * projectData = [NSDictionary dictionaryWithObjectsAndKeys:
                              aProject, kObjectKeyForProjectData,
                              aProject.title, kTitleKeyForProjectData,
                              nil];
        
        [projectDataArray addObject:projectData];
    }
    
    _projectDataArray = [projectDataArray copy];
    
    return _projectDataArray;
}

- (NSDictionary *)dataForInboxProject
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObjectNull:[NSNull null] forKey:kObjectKeyForProjectData];
    [dic setObject:NSLocalizedString(@"Common_Project_Category_Inbox", nil) forKey:kTitleKeyForProjectData];
    
    NSDictionary *dictionaryForInboxProject = [dic copy];
    
    return dictionaryForInboxProject;
}

- (NSArray *)userAddedProjectArray
{
    NSManagedObjectContext *context = self.task.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Project" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSArray *userAddedProjectArray = [context executeFetchRequest:fetchRequest error:&error];
    
    return userAddedProjectArray;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.task.project = [[self.projectDataArray objectAtIndex:indexPath.row] objectForKeyNull:kObjectKeyForProjectData];
    
    [self.tableView reloadData];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
