//
//  AnalyticsManager.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 2013/07/11.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "AnalyticsManager.h"

@implementation AnalyticsManager

#define GA_TRACKER  [GAI sharedInstance].defaultTracker
#define MP_TRACKER  [Mixpanel sharedInstance]

#pragma mark - Singleton

+ (AnalyticsManager *)sharedInstance
{
    static AnalyticsManager* sharedSingleton;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSingleton = [[AnalyticsManager alloc] initSharedInstance];
    });
    return sharedSingleton;
}

- (id)initSharedInstance
{
    self = [super init];
    if (self)
    {
        // 初期化処理
    }
    return self;
}

//initされることを防ぐ
- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Methods For Other Class

- (void)trackView:(id)sender
{
    [GA_TRACKER sendView:NSStringFromClass([sender class])];
}

- (void)trackEvent:(NSString *)event sender:(id)sender
{
    [GA_TRACKER sendEventWithCategory:NSStringFromClass([sender class])
                           withAction:event
                            withLabel:@""
                            withValue:@-1];
    
    [MP_TRACKER track:event];
}

- (void)trackPropertyWithKey:(NSString *)key value:(NSString *)value sender:(id)sender
{
    [GA_TRACKER sendEventWithCategory:NSStringFromClass([sender class])
                           withAction:key
                            withLabel:value
                            withValue:@-1];
}

- (void)trackPropertyWithTask:(Task *)task sender:(id)sender
{
    //処理時間:0.002秒
    NSString *isDueDateOn = [NSString stringWithFormat:@"%@",(task.dueDate ? @"YES":@"NO")];
    
    [self trackPropertyWithKey:kPropertyKeyTaskTitle value:task.title sender:sender];
    [self trackPropertyWithKey:kPropertyKeyTaskRepeat value:task.repeat.title sender:sender];
    [self trackPropertyWithKey:kPropertyKeyTaskMemo value:task.memo sender:sender];
    [self trackPropertyWithKey:kPropertyKeyTaskDueDateIsOn value:isDueDateOn sender:sender];
}

- (void)registerSuperProperties:(NSDictionary *)properties
{
    [MP_TRACKER registerSuperProperties:properties];
}

@end
