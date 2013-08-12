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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tempTitle = self.project.title;
    
    //アイコン
    if (self.isNew)
    {
        [self setDefaultIcon];
    }
    
    //タイトル
    if (self.isNew)
    {
        self.title = NSLocalizedString(@"EditProjectView_Title_NewProject", nil);
    }
    else
    {
        self.title = NSLocalizedString(@"EditProjectView_Title_ExistingProject", nil);
    }
    
    //ナビゲーションボタン
    if (self.navigationController.isBeingPresented)//Modalによって表示された場合
    {
        [self setNavigationButtons];
    }

    //削除ボタン
    if (!self.navigationController.isBeingPresented && ![self isDefaultProject])//Modalではない & デフォルトプロジェクトではない場合
    {
        [self setDeleteButton];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];//アイコン編集後のデータを反映させるため
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [ANALYTICS trackView:self];
    
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

#pragma mark - Initialize

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

- (void)setDefaultIcon
{
    self.project.colorHex = kColorHexDefaultProject;
    self.project.icon = [UIImage imageNamed:kImageDefaultProjectIcon];
}

- (BOOL)isDefaultProject
{
    if ([self.project.displayOrder intValue] == 0)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark - CloseView

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
                if (self.isNew)
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
                
                if (self.isNew)
                {
                    [ANALYTICS trackEvent:kEventAddProject sender:self];
                    [ANALYTICS trackPropertyWithKey:kPropertyKeyProjectTitle value:self.project.title sender:self];
                    [ANALYTICS registerSuperProperties:@{kPropertyKeyProjectCount:@([APPDELEGATE numberOfProject])}];
                }
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
        
        if ([self isDefaultProject])
        {
            cell.textField.enabled = NO;
            cell.textField.textColor = [UIColor lightGrayColor];
        }
        
        return cell;
    }
    else
    {
        ProjectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProjectCell"];
        cell.titleLabel.text = NSLocalizedString(@"EditProjectView_Cell_Icon", nil);
        cell.iconView.image = self.project.iconWithColor;
        
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
        [self showSelectIconShapeView];
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
    switch (buttonIndex) {
        case 0:
            [self closeViewWithDeletingTask];
            break;
        case 1:
            //Do Nothing
            break;
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

@end
