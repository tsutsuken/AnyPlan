//
//  NoteInfoViewController.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/05/26.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "NoteInfoViewController.h"

@interface NoteInfoViewController ()

@end

@implementation NoteInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"NoteInfoView_Title", nil);
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];//Note編集後のデータを反映させるため
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    cell.textLabel.text = NSLocalizedString(@"NoteInfoView_Cell_Project", nil);
    cell.detailTextLabel.text = self.note.project.title;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self showSelectProjectView];
}

#pragma mark - Show Other View

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    LOG(@"%@", [segue identifier]);
    
    if([[segue identifier] isEqualToString:@"showSelectProjectView"])
    {
        SelectProjectViewController *controller = (SelectProjectViewController *)segue.destinationViewController;
        controller.editedObject = self.note;
    }
}

- (void)showSelectProjectView
{
    LOG_METHOD;
    [self performSegueWithIdentifier:@"showSelectProjectView" sender:self];
}

@end