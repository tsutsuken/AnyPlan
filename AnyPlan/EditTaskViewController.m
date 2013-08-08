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
#define kHeightForCustomActionSheet 500
#define kTagForActionSheetDueDatePicker 1
#define kTagForActionSheetRepeatPicker 2
#define kIndexPathForCellDueDate [NSIndexPath indexPathForRow:2 inSection:0]
#define kIndexPathForCellRepeat [NSIndexPath indexPathForRow:3 inSection:0]


@interface EditTaskViewController ()

@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) NSString *tempTitle;//画面遷移時にも、値を保持するため
@property (assign, nonatomic) BOOL shouldDeleteTask;
@property (strong, nonatomic) UIActionSheet *myActionSheet;
@property (strong, nonatomic) NSArray *unitNameArray;

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
    
    [self setToolbar];
}

- (void)setToolbar
{
    UIButton *customView = [[UIButton alloc] initWithFrame:kFrameForBarButtonItem];
    [customView setImage:[UIImage imageNamed:@"trash.png"] forState:UIControlStateNormal];
    [customView addTarget:self action:@selector(didPushDeleteButton) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* buttonItem = [[UIBarButtonItem alloc] initWithCustomView:customView];
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.toolbar.items = @[space, buttonItem, space];
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
                
                if (self.isNewTask)
                {
                    [ANALYTICS trackEvent:kEventAddTask sender:self];
                    [ANALYTICS trackPropertyWithTask:self.task sender:self];
                }
            }
        }
        
        [self.task saveContext];
    }
    else//次のViewに行った時
    {
        [self hideKeyBoard];
    }
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
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
        cell.detailTextLabel.text = self.task.dueDateStringLong;
        
        return cell;
    }
    else if (indexPath.row == 3)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        cell.textLabel.text = NSLocalizedString(@"EditTaskView_Cell_Repeat", nil);
        cell.detailTextLabel.text = self.task.repeat.title;
        
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
    
    if (indexPath.row == 4)
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
    else if (indexPath.row == 3)
    {
        [self showRepeatPicker];
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

#pragma mark - Picker
#pragma mark Common

- (UIActionSheet *)actionSheetForPicker
{
    //アクションシートの作成
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
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
                                                                                action:@selector(didPushDoneButtonForPicker)];
    [doneButton setTitleColorForButtonStyle:UIBarButtonItemStyleDone];
    
    //Deleteボタンの作成
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"EditTaskView_Picker_Button_Delete", nil)
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(didPushDeleteButtonForPicker)];
    toolBar.items = [NSArray arrayWithObjects:deleteButton, spacer, doneButton, nil];
	[actionSheet addSubview:toolBar];
    
    return actionSheet;
}

- (void)didPushDoneButtonForPicker
{
    if (self.myActionSheet.tag == kTagForActionSheetDueDatePicker)
    {
        [self.myTableView deselectRowAtIndexPath:kIndexPathForCellDueDate animated:YES];
    }
    else
    {
        self.myTableView.contentInset = UIEdgeInsetsZero;
        [self.myTableView deselectRowAtIndexPath:kIndexPathForCellRepeat animated:YES];
    }
    
    [self.myActionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)didPushDeleteButtonForPicker
{
    if (self.myActionSheet.tag == kTagForActionSheetDueDatePicker)
    {
        self.task.dueDate = nil;
        [self reloadRowAtIndexPath:kIndexPathForCellDueDate withSelected:NO];
    }
    else
    {
        self.myTableView.contentInset = UIEdgeInsetsZero;
        
        [self.task.managedObjectContext deleteObject:self.task.repeat];
        self.task.repeat = nil;
        [self reloadRowAtIndexPath:kIndexPathForCellRepeat withSelected:NO];
    }
    
    [self.myActionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)reloadRowAtIndexPath:(NSIndexPath *)indexPath withSelected:(BOOL)selected
{
    [self.myTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    if (selected)
    {
        [self.myTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

#pragma mark RepeatPicker

- (void)showRepeatPicker
{
    //必要データの取得
    if (!self.task.repeat)
    {
        Repeat *repeat = (Repeat *)[NSEntityDescription insertNewObjectForEntityForName:@"Repeat"
                                                                 inManagedObjectContext:self.task.managedObjectContext];
        self.task.repeat = repeat;
        [self reloadRowAtIndexPath:kIndexPathForCellRepeat withSelected:YES];
    }
    self.unitNameArray = self.task.repeat.unitNameArray;
    
    
    //アクションシートの作成
    UIActionSheet *actionSheet = [self actionSheetForPicker];
    actionSheet.tag = kTagForActionSheetRepeatPicker;
    
    
	//ピッカーの作成
    UIPickerView *repeatPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, 0, 0)];
    repeatPicker.delegate = self;
    repeatPicker.dataSource = self;
    repeatPicker.showsSelectionIndicator = YES;
    [repeatPicker selectRow:([self.task.repeat.number intValue] - 1) inComponent:0 animated:YES];
    [repeatPicker selectRow:[self.task.repeat.unitId intValue] inComponent:1 animated:YES];
    [actionSheet addSubview:repeatPicker];
    
    
    //アクションシートのセット
    self.myActionSheet = actionSheet;
    [self.myActionSheet showInView:self.view];
	[self.myActionSheet setBounds:CGRectMake(0, 0, self.view.frame.size.width, kHeightForCustomActionSheet)];//高さは、手動で調整
    
    //TableViewの表示位置を調整
    self.myTableView.contentInset = UIEdgeInsetsMake(0, 0, 216, 0);//216 = Picker+Toolbar-BottomToolbar(myActionSheetのframeは当てにならない)
    [self.myTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]
                            atScrollPosition:UITableViewScrollPositionMiddle
                                    animated:YES];
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    if(component == 0)
    {
        return self.task.repeat.maxNumber;
    }else
    {
        return [self.unitNameArray count];
    }
}

// 表示する内容を返す例
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(component == 0)
    {
        return [NSString stringWithFormat:@"%d", row + 1];
    }else
    {
        return [self.unitNameArray objectAtIndex:row];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0)
    {
        self.task.repeat.number = @(row + 1);
    }
    else
    {
        self.task.repeat.unitId = @(row);
        [pickerView reloadComponent:0];
    }
    
    [self reloadRowAtIndexPath:kIndexPathForCellRepeat withSelected:YES];
}

#pragma mark DueDatePicker

- (void)showDueDatePicker
{
    //アクションシートの作成
    UIActionSheet *actionSheet = [self actionSheetForPicker];
    actionSheet.tag = kTagForActionSheetDueDatePicker;
    
	//ピッカーの作成
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 44, 0, 0)];
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.minimumDate = [[NSDate date] initWithTimeIntervalSinceNow:-1*365*24*60*60];
    [datePicker addTarget:self action:@selector(didChangeValueOnDatePicker:) forControlEvents:UIControlEventValueChanged];
    if (!self.task.dueDate)
    {
        self.task.dueDate = [NSDate date];
        [self reloadRowAtIndexPath:kIndexPathForCellDueDate withSelected:YES];
    }
    datePicker.date = self.task.dueDate;
    [actionSheet addSubview:datePicker];
    
    self.myActionSheet = actionSheet;
    [self.myActionSheet showInView:self.view];
	[self.myActionSheet setBounds:CGRectMake(0, 0, self.view.frame.size.width, kHeightForCustomActionSheet)];//高さは、手動で調整
}

-(void)didChangeValueOnDatePicker:(UIDatePicker*)datePicker
{
    self.task.dueDate = datePicker.date;
    [self reloadRowAtIndexPath:kIndexPathForCellDueDate withSelected:YES];
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
    self.shouldDeleteTask = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

@end
