//
//  EditTaskViewController.h
//  Anyplan
//
//  Created by Ken Tsutsumi on 13/04/25.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectProjectViewController.h"
#import "EditMemoViewController.h"
#import "MemoCell.h"

@interface EditTaskViewController : UIViewController <UITextFieldDelegate, UIActionSheetDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) Task *task;

@end
