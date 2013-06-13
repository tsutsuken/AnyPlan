//
//  SelectIconColorViewController.h
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/06/07.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "SelectIconShapeViewController.h"
#import "IconCell.h"

@interface SelectIconColorViewController : UICollectionViewController

@property (strong, nonatomic) Project *project;
@property (strong, nonatomic) NSString *iconImageName;

@end