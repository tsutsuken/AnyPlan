//
//  EditNoteViewController.h
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/04/28.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoteInfoViewController.h"

@protocol EditNoteViewControllerDelegate;

@interface EditNoteViewController : UIViewController <UIActionSheetDelegate, UITextViewDelegate>

@property (assign, nonatomic) id <EditNoteViewControllerDelegate> delegate;
@property (strong, nonatomic) Note *note;
@property (weak  , nonatomic) IBOutlet UITextView *noteTextView;
@property (assign, nonatomic) BOOL isNewNote;

- (IBAction)didPushDeleteButton;


@end

@protocol EditNoteViewControllerDelegate
- (void)editNoteViewController:(EditNoteViewController *)controller didFinishWithSave:(BOOL)save;
@end
