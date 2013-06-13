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
    self.title = NSLocalizedString(@"SelectIconColorView_Title", nil);
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
    
    cell.backgroundColor = [UIColor colorWithHexString:[self.colorHexArray objectAtIndex:indexPath.item]];
    cell.imageView.image = [UIImage imageNamed:self.iconImageName];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIColor *selectedColor = [UIColor colorWithHexString:[self.colorHexArray objectAtIndex:indexPath.item]];
    UIImage *backGroundImage = [UIImage imageWithColor:selectedColor];
    
    UIImage *iconImage = [UIImage imageNamed:self.iconImageName];
    
    CGRect rect = CGRectMake(0, 0, kLengthForDefaultProjectIcon, kLengthForDefaultProjectIcon);
    
    self.project.icon = [UIImage generateImageWithSourceImage:backGroundImage composeImage:iconImage rect:rect];
    //saveはしない
    
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
