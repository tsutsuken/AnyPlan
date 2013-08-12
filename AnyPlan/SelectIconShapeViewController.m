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

@property (strong, nonatomic) NSArray *imageNameArray;

@end

@implementation SelectIconShapeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"SelectIconShapeView_Title", nil);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self action:@selector(didPushCancelButton)];
    
    self.collectionView.backgroundColor = kColorBackGroundDark;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [ANALYTICS trackView:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CollectionView delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.imageNameArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    IconCell *cell = (IconCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"IconCell" forIndexPath:indexPath];

    UIImage *imageNormal = [UIImage imageNamed:[self.imageNameArray objectAtIndex:indexPath.item]];
    cell.imageView.image = [imageNormal imageTintedWithColor:kColorPaleWhite];
    cell.imageView.highlightedImage = [imageNormal imageTintedWithColor:[UIColor lightGrayColor]];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *selectedImageName = [self.imageNameArray objectAtIndex:indexPath.item];
    self.project.icon = [UIImage imageNamed:selectedImageName];

    [self showSelectIconColorView];
}

#pragma mark - CloseView

- (void)didPushCancelButton
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Show Other View

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    LOG(@"%@", [segue identifier]);
    
    if([[segue identifier] isEqualToString:@"showSelectIconColorView"])
    {
        SelectIconColorViewController *controller = (SelectIconColorViewController *)segue.destinationViewController;
        controller.project = self.project;
    }
}

#pragma mark SelectIconShapeView

- (void)showSelectIconColorView
{
    [self performSegueWithIdentifier:@"showSelectIconColorView" sender:self];
}

- (NSArray *)imageNameArray
{
    if (_imageNameArray != nil) {
        return _imageNameArray;
    }
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"IconShapes" ofType:@"plist"];
    self.imageNameArray = [[NSArray alloc] initWithContentsOfFile:filePath];
    
    return _imageNameArray;
}

@end
