//
//  EditProjectViewController.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/04/23.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "EditProjectViewController.h"

@interface EditProjectViewController ()

@property (strong, nonatomic) NSString *tempTitle;//画面遷移時にも、値を保持するため
@property (assign, nonatomic) BOOL shouldDeleteProject;

@end

@implementation EditProjectViewController

#define kTagForActionSheetDeleteProject 1
#define kTagForActionSheetSelectIconStyle 2

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tempTitle = self.project.title;
    
    if (self.isNewProject)
    {
        self.title = NSLocalizedString(@"EditProjectView_Title_NewProject", nil);
        self.project.icon = [self defaultIcon];
        
        if (self.navigationController.isBeingPresented)//Modalによって表示された場合
        {
            [self setNavigationButtons];
        }
        else
        {
            [self setDeleteButton];
        }
    }
    else
    {
        self.title = NSLocalizedString(@"EditProjectView_Title_ExistingProject", nil);
        [self setDeleteButton];
    }
    
    LOG(@"%@",[NSNumber numberWithBool:self.navigationController.isBeingPresented]);
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];//アイコン編集後のデータを反映させるため
}

- (void)viewDidAppear:(BOOL)animated
{
    if (!self.tempTitle)
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

- (UIImage *)defaultIcon
{
    UIImage *defaultIconForProject;
    
    UIImage *backGroundImage = [UIImage imageWithColor:[UIColor colorWithHexString:kColorHexForDefaultProjectIcon]];
    UIImage *iconImage = [UIImage imageNamed:kImageNameForDefaultProjectIcon];
    CGRect rect = CGRectMake(0, 0, kLengthForDefaultProjectIcon, kLengthForDefaultProjectIcon);
    defaultIconForProject = [UIImage generateImageWithSourceImage:backGroundImage composeImage:iconImage rect:rect];
    
    return defaultIconForProject;
}

#pragma mark - CloseView
/*
- (NSString *)projectTitle
{
    NSString *projectTitle;
    
    if(!self.tempTitle||[self.tempTitle isEqualToString:@""])
    {
        projectTitle = NSLocalizedString(@"Common_Untitled", nil);
    }
    else
    {
        projectTitle = self.tempTitle;
    }
    
    return projectTitle;
}
*/
#pragma mark Existing Project

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.isMovingFromParentViewController || self.navigationController.isBeingDismissed)//NavBarで前に戻った、もしくはModalを閉じた場合
    {
        if (self.shouldDeleteProject)
        {
            [self.project.managedObjectContext deleteObject:self.project];
        }
        else
        {
            if(!self.tempTitle||[self.tempTitle isEqualToString:@""])
            {
                if (self.isNewProject)
                {
                    [self.project.managedObjectContext deleteObject:self.project];
                }
                else
                {
                    self.project.title = NSLocalizedString(@"Common_Untitled", nil);
                }
            }
            else
            {
                self.project.title = self.tempTitle;
            }
        }
        
        [self.project saveContext];
    }
    else//次のViewに行った時
    {
        //[self hideKeyBoard];
    }
}

#pragma mark New Project

- (void)didPushCancelButton
{
    self.shouldDeleteProject = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didPushDoneButton
{
    [self dismissViewControllerAnimated:YES completion:nil];
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        return tableView.rowHeight;//storyboardで設定
    }
    else
    {
        return 76;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        EditableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EditableCell"];
        cell.textField.delegate = self;
        cell.textField.placeholder = NSLocalizedString(@"EditProjectView_TextField_PlaceHolder", nil);
        cell.textField.text = self.tempTitle;
        
        return cell;
    }
    else
    {
        ProjectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProjectCell"];
        cell.titleLabel.text = NSLocalizedString(@"EditProjectView_Cell_Icon", nil);
        cell.iconView.image = self.project.icon;
        
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
    if (indexPath.row == 1)
    {
        [self showActionSheetForSelectIconStyle];
    }
}

#pragma mark - Show Other View

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    LOG(@"%@", [segue identifier]);
    
    if([[segue identifier] isEqualToString:@"showSelectIconShapeView"])
    {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        SelectIconShapeViewController *controller = (SelectIconShapeViewController *)navigationController.topViewController;
        controller.project = self.project;
    }
}

#pragma mark SelectIconShapeView

- (void)showSelectIconShapeView
{
    [self performSegueWithIdentifier:@"showSelectIconShapeView" sender:self];
}

#pragma mark - TextField delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.tempTitle = [textField.text stringByReplacingCharactersInRange:range withString:string];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - ActionSheet delegate

-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == kTagForActionSheetDeleteProject)
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
    else
    {
        switch (buttonIndex) {
            case 0:
                [self showSelectIconShapeView];
                break;
            case 1:
                [self pickImageWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                break;
            case 2:
                [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] animated:YES];
                break;
        }
    }
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
    actionSheet.tag = kTagForActionSheetDeleteProject;
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"EditProjectView_ActionSheet_Button_Delete", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"EditProjectView_ActionSheet_Button_Cancel", nil)];
    actionSheet.destructiveButtonIndex = 0;
    actionSheet.cancelButtonIndex = 1;
    
    [actionSheet showInView:self.view];
}

- (void)closeViewWithDeletingTask
{
    self.shouldDeleteProject = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Select Icon

- (void)showActionSheetForSelectIconStyle
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    actionSheet.tag = kTagForActionSheetSelectIconStyle;

    [actionSheet addButtonWithTitle:NSLocalizedString(@"EditProjectView_ActionSheet_Button_SelectFromDefaultIcon", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"EditProjectView_ActionSheet_Button_SelectFromLibrary", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"EditProjectView_ActionSheet_Button_Cancel", nil)];
    actionSheet.cancelButtonIndex = 2;
    
    [actionSheet showInView:self.view];
}

-(void)pickImageWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
    if([UIImagePickerController isSourceTypeAvailable:sourceType])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = sourceType;
        imagePicker.allowsEditing = YES;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

#pragma mark ImagePicker delegate

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingImage:(UIImage*)image editingInfo:(NSDictionary*)editingInfo
{
    self.project.icon = image;
    
    [self dismissModalViewControllerAnimated:YES];
    [self.tableView reloadData];//セル内の画像を更新するため
}

@end
