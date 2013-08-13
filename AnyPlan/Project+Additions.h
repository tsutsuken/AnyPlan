//
//  Project+Additions.h
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/04/23.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "Project.h"

@interface Project (Additions)

- (void)saveContext;
- (void)deleteWithRefreshDisplayOrder:(BOOL)shouldRefresh;
- (UIImage *)iconWithColor;

@end


@interface ImageToDataTransformer : NSValueTransformer {
}
@end