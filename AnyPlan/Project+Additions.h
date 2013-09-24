//
//  Project+Additions.h
//  Anyplan
//
//  Created by Ken Tsutsumi on 13/04/23.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "Project.h"

@interface Project (Additions)

- (void)saveContext;
- (UIImage *)iconWithColor;
- (void)refreshDisplayOrderOfTasks;
- (int)numberOfUncompletedTask;
- (void)deleteWithRefreshDisplayOrder:(BOOL)shouldRefresh;



@end


@interface ImageToDataTransformer : NSValueTransformer {
}
@end