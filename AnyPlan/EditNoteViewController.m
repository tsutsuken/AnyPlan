//
//  EditNoteViewController.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/04/28.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "EditNoteViewController.h"

@interface EditNoteViewController ()

@end

@implementation EditNoteViewController
{
    IBOutlet UITextView *textView;
    BOOL shouldDeleteNote;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.isNewNote)
    {
        self.title = NSLocalizedString(@"EditNoteView_Title_NewNote", nil);
    }
    else
    {
        self.title = NSLocalizedString(@"EditNoteView_Title_ExistingNote", nil);
    }
    
    textView.text = self.note.text;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                                           target:self
                                                                                           action:@selector(showActionSheetForDeletingNote)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (!self.note.text||[self.note.text isEqualToString:@""])
    {
        [textView becomeFirstResponder];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (shouldDeleteNote)
    {
        [self.note.managedObjectContext deleteObject:self.note];
    }
    else
    {
        self.note.text = textView.text;
    }

    [self.delegate editNoteViewController:self didFinishWithSave:YES];
}

////textViewがキーボードで隠れないようにする。下記を参考
//http://hitoshiohtubo.blog.fc2.com/blog-entry-18.html
- (void)keyboardDidShow:(NSNotification *)anotification
{
    NSDictionary *info = [anotification userInfo];
    
    //表示開始時のキーボードのRect
    CGRect beginRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    
    //表示完了時のキーボードのRect
    CGRect endRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect cBeginRect = [[textView superview] convertRect:beginRect toView:nil];
    CGRect cEndRect = [[textView superview] convertRect:endRect toView:nil];
    
    CGRect frame = [textView frame];
    if (cBeginRect.size.height == cEndRect.size.height)//新しいキーボードが表示された時（開始時と完了時で、キーボードのサイズが同じ）
    {
        frame.size.height -= cBeginRect.size.height;
    }
    else//キーボードが変更された時（開始時と完了時で、キーボードのサイズが違う）
    {
        frame.size.height -= (cEndRect.size.height - cBeginRect.size.height);
    }
    [textView setFrame:frame];
}

#pragma mark - Delete Task

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
    shouldDeleteNote = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

@end
