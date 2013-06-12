//
//  SelectIconShapeViewController.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/06/06.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "SelectIconShapeViewController.h"
#import "SelectIconColorViewController.h"

@interface SelectIconShapeViewController ()

@end

@implementation SelectIconShapeViewController
{
    int selectedItemIndex;
}

- (void)viewDidLoad
{
    self.title = NSLocalizedString(@"SelectIconShapeView_Title", nil);
    
    self.dataArray = [self imageNameArray];
    
    [self setScrollView];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self action:@selector(didPushCancelButton)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CloseView

- (void)didPushCancelButton
{
    [self dismissModalViewControllerAnimated:YES];
}

- (NSString *)iconImageNameForItemIndex:(int)itemIndex
{
    return [self.dataArray objectAtIndex:itemIndex];
}

- (UIColor *)iconColorForItemIndex:(int)itemIndex
{
    return [UIColor colorWithHexString:kColorHexForDefaultProjectIcon];
}

- (void)didPushIconButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    selectedItemIndex = button.tag;
    
    [self showSelectIconColorView];
    
    LOG(@"selectedItemIndex_%i",selectedItemIndex);
}

- (NSArray *)imageNameArray
{
    NSString *path = [[NSBundle mainBundle] pathForResource:
                      @"IconShapes" ofType:@"plist"];
    NSArray *imageNameArray = [[NSArray alloc] initWithContentsOfFile:path];
    
    return imageNameArray;
}

#pragma mark - Show Other View

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    LOG(@"%@", [segue identifier]);
    
    if([[segue identifier] isEqualToString:@"showSelectIconColorView"])
    {
        SelectIconColorViewController *controller = (SelectIconColorViewController *)segue.destinationViewController;
        controller.project = self.project;
        controller.iconImageName = [self.dataArray objectAtIndex:selectedItemIndex];
    }
}

#pragma mark SelectIconShapeView

- (void)showSelectIconColorView
{
    LOG_METHOD;
    [self performSegueWithIdentifier:@"showSelectIconColorView" sender:self];
}

@end
