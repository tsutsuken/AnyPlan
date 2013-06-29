//
//  MySignUpViewController.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 2013/06/27.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "MySignUpViewController.h"

#define kTagForFooterButton 1
#define kFontSizeForFooterButton 12

@interface MySignUpViewController ()

@end

@implementation MySignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addFooter];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGRect signUpButtonFrame = self.signUpView.signUpButton.frame;
    
    UIButton *footerButton = (UIButton *)[self.view viewWithTag:kTagForFooterButton];
    CGRect frame = footerButton.frame;
    frame.origin.y = signUpButtonFrame.origin.y + signUpButtonFrame.size.height + 15;
    footerButton.frame = frame;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addFooter
{
    UIButton *footerButton = [[UIButton alloc] initWithFrame:CGRectMake(45, 0, 230, 50)];
    footerButton.tag = kTagForFooterButton;
    footerButton.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    [footerButton addTarget:self action:@selector(didPushFooterButton) forControlEvents:UIControlEventTouchUpInside];
    [footerButton setAttributedTitle:[self attributedTitleForFooter] forState:UIControlStateNormal];
    
    footerButton.titleLabel.numberOfLines = 0;
    footerButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    footerButton.titleLabel.font = [UIFont systemFontOfSize:kFontSizeForFooterButton];
    footerButton.titleLabel.textColor = [UIColor whiteColor];
    footerButton.titleLabel.shadowColor = [UIColor darkGrayColor];
    footerButton.titleLabel.shadowOffset = CGSizeMake(0, -1);

    [self.view addSubview:footerButton];
}

- (void)didPushFooterButton
{
#warning 本番URLを挿入
    [self showWebBrowserWithURL:[NSURL URLWithString:@"http://lvupp.com"]];
}

- (void)showWebBrowserWithURL:(NSURL *)url
{
    TSMiniWebBrowser *webBrowser = [[TSMiniWebBrowser alloc] initWithUrl:url];
    webBrowser.showPageTitleOnTitleBar = NO;
    webBrowser.showActionButton = NO;
    webBrowser.showReloadButton = NO;
    webBrowser.mode = TSMiniWebBrowserModeModal;
    [self presentViewController:webBrowser animated:YES completion:nil];
}

- (NSAttributedString *)attributedTitleForFooter
{
    NSAttributedString *attributedTitleForFooter;
    
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] init];
    
    NSAttributedString *string1 = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"MySignUpView_Footer_Title_1", nil)
                                                                  attributes:nil];
    [mutableAttributedString appendAttributedString:string1];
    
    NSDictionary *attributes2 = @{ NSFontAttributeName : [UIFont boldSystemFontOfSize:kFontSizeForFooterButton] };
    NSAttributedString *string2 = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"MySignUpView_Footer_Title_2", nil)
                                                                  attributes:attributes2];
    [mutableAttributedString appendAttributedString:string2];
    
    NSAttributedString *string3 = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"MySignUpView_Footer_Title_3", nil)
                                                                  attributes:nil];
    [mutableAttributedString appendAttributedString:string3];
    
    NSDictionary *attributes4 = @{ NSFontAttributeName : [UIFont boldSystemFontOfSize:kFontSizeForFooterButton] };
    NSAttributedString *string4 = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"MySignUpView_Footer_Title_4", nil)
                                                                  attributes:attributes4];
    [mutableAttributedString appendAttributedString:string4];
    
    NSAttributedString *string5 = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"MySignUpView_Footer_Title_5", nil)
                                                                  attributes:nil];
    [mutableAttributedString appendAttributedString:string5];
    
    
    attributedTitleForFooter = [mutableAttributedString copy];
    
    return attributedTitleForFooter;
}

@end
