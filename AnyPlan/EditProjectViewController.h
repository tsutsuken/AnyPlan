//
//  EditProjectViewController.h
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/04/23.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditProjectViewController : UITableViewController <UITextFieldDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) Project *project;
@property (assign, nonatomic) BOOL isNewProject;

@end
