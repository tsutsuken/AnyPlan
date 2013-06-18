//
//  EditTaskViewController.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/04/25.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "EditTaskViewController.h"

#define kMaxSizeForMemoLabel CGSizeMake(194, 2000)
#define kDefaultOriginForMemoLabel CGPointMake(83, 12)


@interface EditTaskViewController ()

@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) NSString *tempTitle;//画面遷移時にも、値を保持するため
@property (assign, nonatomic) BOOL shouldDeleteTask;
@property (strong, nonatomic) UIActionSheet *actionSheetForPicker;

@end

@implementation EditTaskViewController

- (void)viewWillAppear:(BOOL)animated
{
    [self.myTableView reloadData];//Task編集後のデータを反映させるため
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tempTitle = self.task.title;
    
    self.tabBarController.viewDeckController.enabled = NO;

    if (self.isNewTask)
    {
        self.title = NSLocalizedString(@"EditTaskView_Title_NewTask", nil);
    }
    else
    {
        self.title = NSLocalizedString(@"EditTaskView_Title_ExistingTask", nil);
    }
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

- (void)showKeyBoard
{
    EditableCell *editableCell = (EditableCell *)[self.myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [editableCell.textField becomeFirstResponder];
}

- (void)hideKeyBoard
{
    EditableCell *editableCell = (EditableCell *)[self.myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [editableCell.textField resignFirstResponder];
}

#pragma mark - CloseView

- (void)viewWillDisappear:(BOOL)animated
{
    if (![[self.navigationController viewControllers] containsObject:self])//前のViewに戻った時
    {
        self.tabBarController.viewDeckController.enabled = YES;
        
        if (self.shouldDeleteTask)
        {
            [self.task.managedObjectContext deleteObject:self.task];
        }
        else//BackButton Pushed
        {
            if(!self.tempTitle||[self.tempTitle isEqualToString:@""])
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
                self.task.title = self.tempTitle;
            }
        }
        
        [self.task saveContext];
    }
    else//次のViewに行った時
    {
        [self hideKeyBoard];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        EditableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EditableCell"];
        
        cell.textField.delegate = self;
        cell.textField.placeholder = NSLocalizedString(@"EditTaskView_Cell_Title_Placeholder", nil);
        cell.textField.text = self.tempTitle;
        
        return cell;
    }
    else if (indexPath.row == 1)
    {
        ProjectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProjectCell"];
        cell.titleLabel.text = NSLocalizedString(@"EditTaskView_Cell_Project", nil);
        cell.detailLabel.text = self.task.project.title;
        cell.iconView.image = self.task.project.icon;
        
        return cell;
    }
    else if (indexPath.row == 2)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        cell.textLabel.text = NSLocalizedString(@"EditTaskView_Cell_DueDate", nil);
        cell.detailTextLabel.text = [self.task.dueDate dateStringWithStyle:NSDateFormatterFullStyle];
        
        return cell;
    }
    else
    {
        MemoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MemoCell"];
        cell.titleLabel.text = NSLocalizedString(@"EditTaskView_Cell_Memo", nil);
        cell.detailLabel.text = self.task.memo;
        
        //ラベルのサイズを設定
        CGSize labelSize = [self.task.memo sizeWithFont:cell.detailLabel.font
                                      constrainedToSize:kMaxSizeForMemoLabel
                                          lineBreakMode:cell.detailLabel.lineBreakMode];
        cell.detailLabel.frame = CGRectMake(kDefaultOriginForMemoLabel.x, kDefaultOriginForMemoLabel.y, labelSize.width, labelSize.height);
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 3)
    {
        float heightForMemoCell;
        
        MemoCell *memoCell = (MemoCell *)[self tableView:self.myTableView cellForRowAtIndexPath:indexPath];
        float memoLabelHeight = memoCell.detailLabel.frame.size.height;
        heightForMemoCell = MAX(memoLabelHeight + 20, self.myTableView.rowHeight);
        
        return heightForMemoCell;
    }
    else
    {
        return self.myTableView.rowHeight;
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
    else if (indexPath.row == 2)
    {
        [self showDueDatePicker];
    }
    else
    {
        [self showEditMemoView];
    }
}

#pragma mark - Show Other Views

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    LOG(@"%@", [segue identifier]);
    
    if([[segue identifier] isEqualToString:@"showSelectProjectView"])
    {
        SelectProjectViewController *controller = (SelectProjectViewController *)segue.destinationViewController;
        controller.editedObject = self.task;
    }
    else if([[segue identifier] isEqualToString:@"showEditMemoView"])
    {
        EditMemoViewController *controller = (EditMemoViewController *)segue.destinationViewController;
        controller.task = self.task;
    }
}

#pragma mark SelectProjectView

- (void)showSelectProjectView
{
    [self performSegueWithIdentifier:@"showSelectProjectView" sender:self];
}

#pragma mark EditMemoView

- (void)showEditMemoView
{
    [self performSegueWithIdentifier:@"showEditMemoView" sender:self];
}

#pragma mark - PickerView

- (void)showDueDatePicker
{
    //アクションシートの作成
     UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                              delegate:self
                                     cancelButtonTitle:nil
                                destructiveButtonTitle:nil
                                     otherButtonTitles:nil];
    
	//ピッカーの作成
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 44, 0, 0)];
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.minimumDate = [[NSDate date] initWithTimeIntervalSinceNow:-1*365*24*60*60];
    [datePicker addTarget:self action:@selector(didChangeValueOnDatePicker:) forControlEvents:UIControlEventValueChanged];
    if (!self.task.dueDate)
    {
        self.task.dueDate = [NSDate date];
        [self.myTableView reloadData];
    }
    datePicker.date = self.task.dueDate;
    
    
    //ツールバーの作成
    UIToolbar *toolBar = [[UIToolbar alloc] init];
    toolBar.barStyle = UIBarStyleBlackTranslucent;
	[toolBar sizeToFit];
    
	 //スペースの作成
	UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                            target:self
                                                                            action:nil];
    
	 //Doneボタンの作成
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                          target:self
                                                                          action:@selector(didPushDoneButtonForDatePicker)];
    
     //Deleteボタンの作成
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"EditTaskView_Picker_Button_Delete", nil)
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(didPushDeleteButtonForDatePicker)];
    toolBar.items = [NSArray arrayWithObjects:deleteButton, spacer, doneButton, nil];
	
    
	[actionSheet addSubview:toolBar];
	[actionSheet addSubview:datePicker];
    self.actionSheetForPicker = actionSheet;
    
    [self.actionSheetForPicker showInView:self.view];
	[self.actionSheetForPicker setBounds:CGRectMake(0, 0, 320, 500)];//高さは、手動で調整
}

-(void)didChangeValueOnDatePicker:(UIDatePicker*)datePicker
{
    self.task.dueDate = datePicker.date;
    
    [self.myTableView reloadData];
}

- (void)didPushDoneButtonForDatePicker
{
    [self.actionSheetForPicker dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)didPushDeleteButtonForDatePicker
{
    self.task.dueDate = nil;
    [self.myTableView reloadData];
    
    [self.actionSheetForPicker dismissWithClickedButtonIndex:0 animated:YES];
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

#pragma mark - Delete Task

- (IBAction)didPushDeleteButton
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
    self.shouldDeleteTask = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

@end
