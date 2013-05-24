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
    IBOutlet UITextView *noteTextView;
    BOOL shouldDeleteNote;
    BOOL isEdited;
    NSString *tempNoteText;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    tempNoteText = self.note.text;
    
    noteTextView.text = tempNoteText;
    
    if (self.isNewNote)
    {
        self.title = NSLocalizedString(@"EditNoteView_Title_NewNote", nil);
    }
    else
    {
        self.title = NSLocalizedString(@"EditNoteView_Title_ExistingNote", nil);
    }
    
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
    if (!tempNoteText||[tempNoteText isEqualToString:@""])
    {
        [noteTextView becomeFirstResponder];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    
    if (shouldDeleteNote)
    {
        [self.note.managedObjectContext deleteObject:self.note];
        [self.delegate editNoteViewController:self didFinishWithSave:YES];
    }
    else
    {
        if (isEdited)
        {
            if(!tempNoteText||[tempNoteText isEqualToString:@""])
            {
                if (self.isNewNote)
                {
                    [self.note.managedObjectContext deleteObject:self.note];
                }
                else
                {
                    self.note.text = NSLocalizedString(@"Common_Untitled", nil);
                }
            }
            else
            {
                self.note.text = tempNoteText;
            }
            
            [self.delegate editNoteViewController:self didFinishWithSave:YES];
        }
        else
        {
           [self.delegate editNoteViewController:self didFinishWithSave:NO];
        }
    }
}

////textViewがキーボードで隠れないようにする。下記を参考
//http://hitoshiohtubo.blog.fc2.com/blog-entry-18.html
- (void)keyboardDidShow:(NSNotification *)anotification
{
    isEdited = YES;
    
    NSDictionary *info = [anotification userInfo];
    
    //表示開始時のキーボードのRect
    CGRect beginRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    
    //表示完了時のキーボードのRect
    CGRect endRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect cBeginRect = [[noteTextView superview] convertRect:beginRect toView:nil];
    CGRect cEndRect = [[noteTextView superview] convertRect:endRect toView:nil];
    
    CGRect frame = [noteTextView frame];
    if (cBeginRect.size.height == cEndRect.size.height)//新しいキーボードが表示された時（開始時と完了時で、キーボードのサイズが同じ）
    {
        frame.size.height -= cBeginRect.size.height;
    }
    else//キーボードが変更された時（開始時と完了時で、キーボードのサイズが違う）
    {
        frame.size.height -= (cEndRect.size.height - cBeginRect.size.height);
    }
    [noteTextView setFrame:frame];
}

#pragma mark - TextView Delegate

- (void)textViewDidChange:(UITextView*)textView
{
    tempNoteText = textView.text;
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
