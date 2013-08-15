//
//  SettingViewController.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/05/11.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "SettingViewController.h"

#define kHeightForFooter 53

@interface SettingViewController ()

@property (assign, nonatomic) BOOL isPremiumUser;
@property (strong, nonatomic)  MBProgressHUD *HUD;

@end

@implementation SettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"SettingView_Title", nil);

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self action:@selector(didPushDoneButton)];;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //購入完了後に、購入ボタンが表示されるのを防ぐため
    self.isPremiumUser = [APPDELEGATE isPremiumUser];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [ANALYTICS trackView:self];
}

- (NSString *)currentPlan
{
    NSString *currentPlan;
    
    if ([[MKStoreManager sharedManager] isSubscriptionActive:kProductIdSubscriptionMonth])
    {
        currentPlan = NSLocalizedString(@"SettingView_PlanType_Premium_Month", nil);
    }
    else if ([[MKStoreManager sharedManager] isSubscriptionActive:kProductIdSubscriptionYear])
    {
        currentPlan = NSLocalizedString(@"SettingView_PlanType_Premium_Year", nil);
    }
    else
    {
        currentPlan = NSLocalizedString(@"SettingView_PlanType_Free", nil);
    }
    
    return currentPlan;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CloseView

- (void)didPushDoneButton
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 2;
    }
    else
    {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        
        if (indexPath.row == 0)
        {
            cell.textLabel.text = NSLocalizedString(@"SettingView_Cell_Plan", nil);
            cell.detailTextLabel.text = [self currentPlan];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else
        {
            cell.textLabel.text = NSLocalizedString(@"SettingView_Cell_Account", nil);
        }
        
        return cell;
    }
    else if (indexPath.section == 1)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        cell.textLabel.text = NSLocalizedString(@"SettingView_Cell_ManageProject", nil);
        
        return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedbackCell" forIndexPath:indexPath];
        cell.textLabel.text = NSLocalizedString(@"SettingView_Cell_Feedback", nil);
        
        return cell;
    }
}

#pragma mark Section Header

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title;
    
    switch (section) {
        case 0:
            title = NSLocalizedString(@"SettingView_SectionHeader_Account", nil);
            break;
        case 1:
            title = NSLocalizedString(@"SettingView_SectionHeader_Settings", nil);
            break;
        case 2:
            title = @"";
            break;
            
        default:
            title = @"";
            break;
    }
    
    return title;
}

#pragma mark Section Footer

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0 && !self.isPremiumUser)
    {
        return kHeightForFooter;
    }
    else
    {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0 && !self.isPremiumUser)
    {
        return [self viewForFooter];
    }
    else
    {
        return nil;
    }
}

- (UIView *)viewForFooter
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, kHeightForFooter)];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self action:@selector(didPushFooterButton) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:NSLocalizedString(@"SettingView_SectionFooter_BecomePremium", nil) forState:UIControlStateNormal];
    button.frame = CGRectMake(10, 5, 300, kHeightForFooter - 10);
    [view addSubview:button];
                      
    return view;
}

- (void)didPushFooterButton
{
    [self showUpgradeAccountView];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 1)
        {
            [self showUserAccountView];
        }
    }
    else if (indexPath.section == 1)
    {
        [self showManageProjectView];
    }
    else
    {
        [self showActionSheetSelectTopic];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - Show Other View

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    LOG(@"%@", [segue identifier]);
    
    if([[segue identifier] isEqualToString:@"showManageProjectView"])
    {
        ManageProjectViewController *controller = (ManageProjectViewController *)segue.destinationViewController;
        controller.managedObjectContext = self.managedObjectContext;
    }
}

#pragma mark ManageProjectView

- (void)showManageProjectView
{
    [self performSegueWithIdentifier:@"showManageProjectView" sender:self];
}

#pragma mark UserAccountView

- (void)showUserAccountView
{
    [self performSegueWithIdentifier:@"showUserAccountView" sender:self];
}

#pragma mark UpgradeAccountView

- (void)showUpgradeAccountView
{
    [self performSegueWithIdentifier:@"showUpgradeAccountView" sender:self];
}

#pragma mark - Send Feedback

- (void)showActionSheetSelectTopic
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    actionSheet.title = NSLocalizedString(@"SettingView_ActionSheet_Title", nil);
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"SettingView_ActionSheet_Button_Topic_Like", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"SettingView_ActionSheet_Button_Topic_Dislike", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"SettingView_ActionSheet_Button_Topic_Request", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"SettingView_ActionSheet_Button_Topic_Other", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"SettingView_ActionSheet_Button_Cancel", nil)];
    actionSheet.cancelButtonIndex = 4;
    
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 4)
    {
        NSString *subject = [self subjectWithTopicIndex:buttonIndex];
        [self showMailComposeViewWithSubject:subject];
    }
}

- (void)showMailComposeViewWithSubject:(NSString *)subject
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setSubject:subject];
        [controller setToRecipients:@[kMailAddressSupport]];
        
        [self presentViewController:controller animated:YES completion:NULL];
    }
    else
    {
        [self showAlertWithTitle:NSLocalizedString(@"SettingView_Alert_Title_EmailError", nil)];
    }
}

- (NSString *)subjectWithTopicIndex:(int)topicIndex
{
    NSString *subject;
    
    NSString *topic;
    switch (topicIndex)
	{
		case 0:
            topic = NSLocalizedString(@"SettingView_Topic_Like", nil);
			break;
		case 1:
            topic = NSLocalizedString(@"SettingView_Topic_Dislike", nil);
			break;
		case 2:
            topic = NSLocalizedString(@"SettingView_Topic_Request", nil);
			break;
		case 3:
            topic = NSLocalizedString(@"SettingView_Topic_Other", nil);//
			break;
		default:
            topic = @"";
			break;
	}
    
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    subject = [NSString stringWithFormat:@"%@:%@", topic, appName];
    
    return subject;
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	switch (result)
	{
		case MFMailComposeResultCancelled:
			break;
		case MFMailComposeResultSaved:
			break;
		case MFMailComposeResultSent:
            [self showSuccessHUD];
			break;
		case MFMailComposeResultFailed:
			break;
		default:
			break;
	}
    
	[self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)showSuccessHUD
{
	self.HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:self.HUD];
	self.HUD.delegate = self;
	self.HUD.minSize = CGSizeMake(135.f, 135.f);
	self.HUD.mode = MBProgressHUDModeCustomView;
    self.HUD.labelText = NSLocalizedString(@"SettingView_HUD_Mail_Completed", nil);
    self.HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check_HUD"]];
	
	[self.HUD showWhileExecuting:@selector(wait) onTarget:self withObject:nil animated:YES];
}

- (void)wait
{
	sleep(1);
}

- (void)showAlertWithTitle:(NSString *)title
{
    UIAlertView *alertForInvalidEmail = [[UIAlertView alloc] initWithTitle:title
                                                                   message:nil
                                                                  delegate:nil
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil];
    
    [alertForInvalidEmail show];
}

@end
