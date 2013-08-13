//
//  EditNoteViewController.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/04/28.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "EditNoteViewController.h"

@interface EditNoteViewController ()

@property (weak  , nonatomic) IBOutlet UITextView *noteTextView;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (assign, nonatomic) CGRect defaultFrameForTextView;

@end

@implementation EditNoteViewController

#define kHeightForToolbar 44

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tabBarController.viewDeckController.enabled = NO;
    
    self.noteTextView.text = self.note.text;
    
    [self setTitle];
    [self setToolbar];
    [self setRightBarButtonWithDoneButton:NO];
}

- (void)setTitle
{
    if (self.isNewNote)
    {
        self.title = NSLocalizedString(@"EditNoteView_Title_NewNote", nil);
    }
    else
    {
        self.title = NSLocalizedString(@"EditNoteView_Title_ExistingNote", nil);
    }
}

- (void)setToolbar
{
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                                  target:self action:@selector(didPushDeleteButton)];
    
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                  target:self action:@selector(didPushShareButton)];
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.toolbar.items = @[space, deleteButton, space, shareButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];//UIActivityViewの後の呼び出しで、余分に追加するのを防ぐため
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    if (CGRectIsEmpty(self.defaultFrameForTextView))
    {
        self.defaultFrameForTextView = self.noteTextView.frame;//viewDidLoadだと、frameが初期化されていない。
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [ANALYTICS trackView:self];
    
    NSString *textInTextView = self.noteTextView.text;
    
    if (!textInTextView||[textInTextView isEqualToString:@""])
    {
        [self.noteTextView becomeFirstResponder];
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
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (![[self.navigationController viewControllers] containsObject:self])//前のViewに戻った時
    {
        self.tabBarController.viewDeckController.enabled = YES;
        
        [self setTextToManagedObjectIfNeeded];
        
        if (self.note.isDeleted)
        {
            [self.delegate editNoteViewController:self didFinishWithSave:YES];
        }
        else
        {
            if (self.note.hasChanges)//編集された場合
            {
                if(!self.note.text||[self.note.text isEqualToString:@""])
                {
                    [self.note.managedObjectContext deleteObject:self.note];
                }
                else
                {
                    //Do nothing
                }
                
                if (self.isNewNote){
                    [ANALYTICS trackEvent:kEventAddNote sender:self];
                    [ANALYTICS trackPropertyWithKey:kPropertyKeyNoteText value:self.note.text sender:self];
                }
                
                [self.delegate editNoteViewController:self didFinishWithSave:YES];
            }
            else
            {
                [self.delegate editNoteViewController:self didFinishWithSave:NO];
            }
        }
    }
    else//次のViewに行った時
    {
        
    }
}

- (void)setTextToManagedObjectIfNeeded
{
    if (![self.note.text isEqualToString:self.noteTextView.text])
    {
        self.note.text = self.noteTextView.text;
    }
}

////textViewがキーボードで隠れないようにする。下記を参考
//http://hitoshiohtubo.blog.fc2.com/blog-entry-18.html
- (void)keyboardDidShow:(NSNotification *)anotification
{
    NSDictionary *info = [anotification userInfo];
    
    //表示開始時のキーボードのRect
    CGRect beginRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect cBeginRect = [[self.noteTextView superview] convertRect:beginRect toView:nil];//すべてをnoteTextViewに合わせるため
    
    //表示完了時のキーボードのRect
    CGRect endRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect cEndRect = [[self.noteTextView superview] convertRect:endRect toView:nil];
    
    CGRect frame = [self.noteTextView frame];
    
    if (cBeginRect.size.height == cEndRect.size.height)//新しいキーボードが表示された時（開始時と完了時で、キーボードのサイズが同じ）
    {
        [self setRightBarButtonWithDoneButton:YES];
        
        frame.size.height -= (cBeginRect.size.height - kHeightForToolbar);//Toolbarの分だけ、textViewの縮小サイズを減らす
    }
    else//キーボードが変更された時（開始時と完了時で、キーボードのサイズが違う）
    {
        frame.size.height -= (cEndRect.size.height - cBeginRect.size.height);
    }
    
    [self.noteTextView setFrame:frame];
}

- (void)keyboardDidHide:(NSNotification *)anotification
{
    [self setRightBarButtonWithDoneButton:NO];
    
    [self.noteTextView setFrame:self.defaultFrameForTextView];
}

- (void)setRightBarButtonWithDoneButton:(BOOL)isDoneButton
{
    NSMutableArray *rightBarButtonItems = [NSMutableArray array];
                                        
    if (isDoneButton)
    {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                               target:self
                                                                                               action:@selector(didPushDoneButton)];
        
        [rightBarButtonItems addObject:doneButton];
    }
    else
    {
        UIButton *button = [[UIButton alloc] initWithFrame:kFrameForBarButtonItem];
        [button setImage:[UIImage imageNamed:@"info.png"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(didPushInfoButton) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithCustomView:button];
        
        [rightBarButtonItems addObject:infoButton];
    }

    self.navigationItem.rightBarButtonItems = [rightBarButtonItems copy];
}

- (void)didPushDoneButton
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

#pragma mark - Delete Note

- (void)didPushDeleteButton
{
    [self showActionSheetForDeletingNote];
}

- (void)showActionSheetForDeletingNote
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"EditNoteView_ActionSheet_Button_Delete", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"EditNoteView_ActionSheet_Button_Cancel", nil)];
    actionSheet.destructiveButtonIndex = 0;
    actionSheet.cancelButtonIndex = 1;
    
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self closeViewWithDeletingNote];
            break;
        case 1:
            //Do Nothing
            break;
    }
}

- (void)closeViewWithDeletingNote
{
    [self.note.managedObjectContext deleteObject:self.note];
    //contextのsaveはしない。isDeleteにするため
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Export Note

- (void)didPushShareButton
{
    NSString *exportingText = self.noteTextView.text;
    NSArray* actItems = @[exportingText];
    
    UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:actItems applicationActivities:nil];
    activityView.excludedActivityTypes = @[UIActivityTypePostToFacebook, UIActivityTypePostToTwitter];
    
    [self presentViewController:activityView animated:YES completion:nil];
}

#pragma mark - Show Other View

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    LOG(@"%@", [segue identifier]);
    
    if([[segue identifier] isEqualToString:@"showNoteInfoView"])
    {
        NoteInfoViewController *controller = (NoteInfoViewController *)segue.destinationViewController;
        controller.note = self.note;
    }
}

#pragma mark EditTaskView

- (void)didPushInfoButton
{
    [self performSegueWithIdentifier:@"showNoteInfoView" sender:self];
}

@end
