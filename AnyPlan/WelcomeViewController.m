//
//  WelcomeViewController.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 2013/06/26.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "WelcomeViewController.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addButtons];
}

- (void)addButtons
{
    CGSize buttonSize = CGSizeMake(140, 42);
    CGSize spacer = CGSizeMake(15, 15);
    
    int yPosition = self.view.frame.size.height - (buttonSize.height + spacer.height);
    
    UIButton *signUpButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    signUpButton.frame = CGRectMake(spacer.width, yPosition, buttonSize.width, buttonSize.height);
    [signUpButton setTitle:NSLocalizedString(@"WelcomeView_Button_SignUp", nil) forState:UIControlStateNormal];
    [signUpButton addTarget:self action:@selector(showSignUpView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:signUpButton];
    
    int xPosition = self.view.frame.size.width - (buttonSize.width + spacer.width);
    
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    loginButton.frame = CGRectMake(xPosition, yPosition, buttonSize.width, buttonSize.height);
    [loginButton setTitle:NSLocalizedString(@"WelcomeView_Button_LogIn", nil) forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(showLogInView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Show Other View

- (void)showSignUpView
{
    MySignUpViewController *signUpViewController = [[MySignUpViewController alloc] init];
    [signUpViewController setDelegate:self];
    signUpViewController.fields = PFSignUpFieldsUsernameAndPassword | PFSignUpFieldsEmail | PFSignUpFieldsSignUpButton | PFSignUpFieldsDismissButton ;
    //signUpViewController.signUpView.usernameField.placeholder = @"Email";
    [signUpViewController.signUpView setLogo:nil];
    
    [self presentViewController:signUpViewController animated:YES completion:NULL];
}

- (void)showLogInView
{
    PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
    [logInViewController setDelegate:self];
    logInViewController.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsLogInButton | PFLogInFieldsPasswordForgotten | PFLogInFieldsDismissButton ;
    [logInViewController.logInView setLogo:nil];
    
    [self presentViewController:logInViewController animated:YES completion:NULL];
}

#pragma mark - Delegates

- (UIAlertView *)alertWithTitle:(NSString *)title
{
    UIAlertView *alertForInvalidEmail = [[UIAlertView alloc] initWithTitle:title
                                                                   message:nil
                                                                  delegate:nil
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil];
    
    return alertForInvalidEmail;
}

#pragma mark PFSignUpViewControllerDelegate

- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info
{
    BOOL informationComplete = YES;
    
    for (id key in info)
    {
        NSString *field = [info objectForKey:key];
        if (!field || !field.length)
        {
            informationComplete = NO;
            break;
        }
    }
    
    if (!informationComplete)
    {
        [[self alertWithTitle:NSLocalizedString(@"WelcomeView_Alert_Title", nil)] show];
    }
    
    return informationComplete;
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user
{
    //大元のWelcomeViewを閉じる
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark PFLogInViewControllerDelegate

- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password
{
    if (username && password && username.length != 0 && password.length != 0) {
        return YES;
    }

    [[self alertWithTitle:NSLocalizedString(@"WelcomeView_Alert_Title", nil)] show];
    
    return NO;
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    //大元のWelcomeViewを閉じる
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
