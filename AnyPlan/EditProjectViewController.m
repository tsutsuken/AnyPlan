//
//  EditProjectViewController.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/04/23.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "EditProjectViewController.h"

@interface EditProjectViewController ()

@end

@implementation EditProjectViewController
{
    BOOL shouldDeleteProject;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.isNewProject)
    {
        self.title = NSLocalizedString(@"EditProjectView_Title_NewProject", nil);
        [self setNavigationButtons];
    }
    else
    {
        self.title = NSLocalizedString(@"EditProjectView_Title_ExistingProject", nil);
        [self setDeleteButton];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if (!self.project.title)
    {
        [self showKeyBoard];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNavigationButtons
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self action:@selector(didPushCancelButton)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self action:@selector(didPushDoneButton)];
}

- (void)setDeleteButton
{
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [deleteButton addTarget:self action:@selector(didPushDeleteButton) forControlEvents:UIControlEventTouchUpInside];

    [deleteButton setTitle:NSLocalizedString(@"EditProjectView_DeleteButton_Title", nil) forState:UIControlStateNormal];
    
    [deleteButton setBackgroundImage:[[UIImage imageNamed:@"delete_button.png"]
                                      stretchableImageWithLeftCapWidth:8.0f
                                      topCapHeight:0.0f]
                            forState:UIControlStateNormal];
    
    [deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    deleteButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    deleteButton.titleLabel.shadowColor = [UIColor lightGrayColor];
    deleteButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
    
    deleteButton.frame = CGRectMake(10, 0, 300, 44);
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    [footerView addSubview:deleteButton];
    
    self.tableView.tableFooterView = footerView;
}

- (void)showKeyBoard
{
    EditableCell *editableCell = (EditableCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [editableCell.textField becomeFirstResponder];
}

#pragma mark - CloseView

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.isNewProject)
    {
        
    }
    else
    {
        if (![[self.navigationController viewControllers] containsObject:self])//前のViewに戻った時
        {
            if (shouldDeleteProject)
            {
                [self.project.managedObjectContext deleteObject:self.project];
            }
            else
            {
                self.project.title = [self projectTitle];
            }
            
            [self.project saveContext];
        }
        else//次のViewに行った時
        {
            //[self hideKeyBoard];
        }
    }
}

- (NSString *)projectTitle
{
    NSString *projectTitle;
    
    EditableCell *editableCell = (EditableCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    NSString *textInTextField = editableCell.textField.text;
    
    if(!textInTextField||[textInTextField isEqualToString:@""])
    {
        projectTitle = NSLocalizedString(@"Common_Untitled", nil);
    }
    else
    {
        projectTitle = textInTextField;
    }
    
    return projectTitle;
}

#pragma mark New Project

- (void)didPushCancelButton
{
    [self.project.managedObjectContext deleteObject:self.project];
    [self.project saveContext];
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didPushDoneButton
{
    self.project.title = [self projectTitle];
    [self.project saveContext];
    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EditableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EditableCell"];
    
    cell.textField.delegate = self;
    cell.textField.placeholder = NSLocalizedString(@"EditProjectView_TextField_PlaceHolder", nil);
    cell.textField.text = self.project.title;
    
    return cell;
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
}

#pragma mark - TextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Delete Project

- (void)didPushDeleteButton
{
    [self showActionSheetForDeletingTask];
}

- (void)showActionSheetForDeletingTask
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"EditProjectView_ActionSheet_Button_Delete", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"EditProjectView_ActionSheet_Button_Cancel", nil)];
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
    shouldDeleteProject = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

@end
