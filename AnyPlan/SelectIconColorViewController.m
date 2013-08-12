//
//  SelectIconColorViewController.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/06/07.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "SelectIconColorViewController.h"

@interface SelectIconColorViewController ()

@property (strong, nonatomic) NSArray *colorHexArray;

@end

@implementation SelectIconColorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"SelectIconColorView_Title", nil);
    
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
    return [self.colorHexArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    IconCell *cell = (IconCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"IconCell" forIndexPath:indexPath];
    
    UIColor *color = [UIColor colorWithHexString:[self.colorHexArray objectAtIndex:indexPath.item]];
    cell.imageView.image = [self.project.icon imageTintedWithColor:color];
    cell.imageView.highlightedImage = [self.project.icon imageTintedWithColor:[UIColor whiteColor]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.project.colorHex = [self.colorHexArray objectAtIndex:indexPath.item];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSArray *)colorHexArray
{
    if (_colorHexArray != nil) {
        return _colorHexArray;
    }
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"IconColors" ofType:@"plist"];
    self.colorHexArray = [[NSArray alloc] initWithContentsOfFile:filePath];
    
    return _colorHexArray;
}

@end
