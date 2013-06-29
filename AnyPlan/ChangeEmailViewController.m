//
//  ChangeEmailViewController.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 2013/06/28.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "ChangeEmailViewController.h"

@interface ChangeEmailViewController ()

@property (strong, nonatomic)  MBProgressHUD *HUD;
@property (strong, nonatomic)  NSString *tempNewEmail;
@property (strong, nonatomic)  NSString *oldEmail;

@end

@implementation ChangeEmailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"ChangeEmailView_Title", nil);
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                           target:self action:@selector(didPushCancelButton)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self action:@selector(didPushDoneButton)];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.oldEmail = [PFUser currentUser].email;
    self.tempNewEmail = [PFUser currentUser].email;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CloseView
- (void)didPushCancelButton
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didPushDoneButton
{
    if ([self isValidEmail:self.tempNewEmail])
    {
        [self hideKeyboard];
        [self updateAccountWithHUD];
    }
    else
    {
        [[self alertWithTitle:NSLocalizedString(@"ChangeEmailView_Alert_Title_InvalidEmail", nil)] show];
    }
}

- (void)updateAccountWithHUD
{
    [self showHUD];
    
    PFUser *currentUser = [PFUser currentUser];
    currentUser.email = self.tempNewEmail;
    
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        if (succeeded)
        {
            self.HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check_HUD.png"]];
            self.HUD.mode = MBProgressHUDModeCustomView;
            self.HUD.labelText = NSLocalizedString(@"ChangeEmailView_HUD_Title_Completed", nil);
            [self.HUD hide:YES afterDelay:1];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [self.HUD hide:YES];
            [[self alertWithTitle:[error localizedDescription]] show];
        }
    }];
}

- (void)showHUD
{
	self.HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:self.HUD];
	
	self.HUD.delegate = self;
	self.HUD.labelText = NSLocalizedString(@"ChangeEmailView_HUD_Title_Updating", nil);
	self.HUD.minSize = CGSizeMake(135.f, 135.f);
	
	[self.HUD show:YES];
}

- (UIAlertView *)alertWithTitle:(NSString *)title
{
    UIAlertView *alertForInvalidEmail = [[UIAlertView alloc] initWithTitle:title
                                                                   message:nil
                                                                  delegate:nil
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil];
    
    return alertForInvalidEmail;
}

//下記を参照
//http://stackoverflow.com/questions/5428304/email-validation-on-textfield-in-iphone-sdk
- (BOOL)isValidEmail:(NSString *)emailString
{
    BOOL isValidEmail;
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    isValidEmail = [emailTest evaluateWithObject:emailString];
    
    return isValidEmail;
}

- (void)hideKeyboard
{
    EditableCell *emailCell = (EditableCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [emailCell.textField resignFirstResponder];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"ChangeEmailView_SectionHeader_ChangeEmail", nil);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EditableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textField.delegate = self;
    cell.textField.text = self.tempNewEmail;
    cell.textField.placeholder =NSLocalizedString(@"ChangeEmailView_PlaceHolder_Email", nil);
    
    return cell;
}

#pragma mark - TextField delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.tempNewEmail = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (!self.tempNewEmail || self.tempNewEmail.length == 0 || [self.tempNewEmail isEqualToString:self.oldEmail])
    {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else
    {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
