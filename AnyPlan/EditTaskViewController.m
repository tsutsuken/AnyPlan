//
//  EditTaskViewController.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/04/25.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "EditTaskViewController.h"

@interface EditTaskViewController ()

@end

@implementation EditTaskViewController
{
    BOOL shouldDeleteTask;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];//Task編集後のデータを反映させるため
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (self.isNewTask)
    {
        self.title = NSLocalizedString(@"EditTaskView_Title_NewTask", nil);
    }
    else
    {
        self.title = NSLocalizedString(@"EditTaskView_Title_ExistingTask", nil);
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                                           target:self
                                                                                           action:@selector(showActionSheetForDeletingTask)];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (!self.task.title)
    {
        [self showKeyBoard];
    }
}
- (void)showKeyBoard
{
    EditableCell *editableCell = (EditableCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [editableCell.textField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - CloseView

- (void)viewWillDisappear:(BOOL)animated
{
    if (![[self.navigationController viewControllers] containsObject:self])//前のViewに戻った時
    {
        if (shouldDeleteTask)
        {
            [self.task.managedObjectContext deleteObject:self.task];
        }
        else//BackButton Pushed
        {
            NSString *textInTextField = [self textInTextField];
            
            if(!textInTextField||[textInTextField isEqualToString:@""])
            {
                if (self.isNewTask)
                {
                    [self.task.managedObjectContext deleteObject:self.task];
                }
                else
                {
                    self.task.title = NSLocalizedString(@"Common_Untitled", nil);
                }
            }
            else
            {
                self.task.title = textInTextField;
            }
        }
        
        [self.delegate editTaskViewController:self didFinishWithSave:YES];
    }
    else//次のViewに行った時
    {
        //[self hideKeyBoard];
    }
}

- (NSString *)textInTextField
{
    NSString *textInTextField;
    
    EditableCell *editableCell = (EditableCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    textInTextField = editableCell.textField.text;
    
    return textInTextField;
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
    if (indexPath.row == 0)
    {
        EditableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EditableCell"];
        
        cell.textField.delegate = self;
        cell.textField.placeholder = NSLocalizedString(@"EditTaskView_Cell_Title_Placeholder", nil);
        cell.textField.text = self.task.title;
        
        return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        cell.textLabel.text = NSLocalizedString(@"EditTaskView_Cell_Project", nil);
        cell.detailTextLabel.text = self.task.projectTitle;
        
        return cell;
    }
}

#pragma mark - Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    if (indexPath.row == 0)
    {
        return nil;
    }
    else
    {
        return indexPath;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
    }
    else if (indexPath.row == 1)
    {
        [self showSelectProjectView];
    }
}

#pragma mark - Show Other Views

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    LOG(@"%@", [segue identifier]);
    
    if([[segue identifier] isEqualToString:@"showSelectProjectView"])
    {
        SelectProjectViewController *controller = (SelectProjectViewController *)segue.destinationViewController;
        controller.task = self.task;
    }
}

#pragma mark SelectProjectView

- (void)showSelectProjectView
{
    [self performSegueWithIdentifier:@"showSelectProjectView" sender:self.navigationItem.rightBarButtonItem];
}

#pragma mark - TextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Delete Task

- (void)didPushDeleteButton
{
    [self showActionSheetForDeletingTask];
}

- (void)showActionSheetForDeletingTask
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"EditTaskView_ActionSheet_Button_Delete", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"EditTaskView_ActionSheet_Button_Cancel", nil)];
    actionSheet.destructiveButtonIndex = 0;
    actionSheet.cancelButtonIndex = 1;
    
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{    
    switch (buttonIndex) {
        case 0:
            [self closeViewWithDeletingTask];
            break;
        case 1:
            //Do Nothing
            break;
    }
}

- (void)closeViewWithDeletingTask
{
    shouldDeleteTask = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

@end
