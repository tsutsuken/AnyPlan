//
//  EditMemoViewController.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 2013/06/15.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "EditMemoViewController.h"

@interface EditMemoViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation EditMemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"EditMemoView_Title", nil);
    
	self.textView.text = self.task.memo;
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
    [super viewDidAppear:animated];
    
    [ANALYTICS trackView:self];
    
    if (!self.textView.text||[self.textView.text isEqualToString:@""])
    {
        [self.textView becomeFirstResponder];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (self.isMovingFromParentViewController)//前のViewに戻った時
    {
        self.task.memo = self.textView.text;
    }
    else//次のViewに行った時
    {
        
    }
}

////textViewがキーボードで隠れないようにする。下記を参考
//http://hitoshiohtubo.blog.fc2.com/blog-entry-18.html
- (void)keyboardDidShow:(NSNotification *)anotification
{
    NSDictionary *info = [anotification userInfo];
    
    //表示開始時のキーボードのRect
    CGRect beginRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect cBeginRect = [[self.textView superview] convertRect:beginRect toView:nil];
    
    //表示完了時のキーボードのRect
    CGRect endRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect cEndRect = [[self.textView superview] convertRect:endRect toView:nil];
    
    CGRect frame = [self.textView frame];
    if (cBeginRect.size.height == cEndRect.size.height)//新しいキーボードが表示された時（開始時と完了時で、キーボードのサイズが同じ）
    {
        frame.size.height -= cBeginRect.size.height;
    }
    else//キーボードが変更された時（開始時と完了時で、キーボードのサイズが違う）
    {
        frame.size.height -= (cEndRect.size.height - cBeginRect.size.height);
    }
    [self.textView setFrame:frame];

}

@end
