//
//  AnalyticsManager.h
//  AnyPlan
//
//  Created by Ken Tsutsumi on 2013/07/11.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnalyticsManager : NSObject

+ (AnalyticsManager *)sharedInstance;
- (void)trackView:(id)sender;
- (void)trackEvent:(NSString *)event isImportant:(BOOL)isImportant sender:(id)sender;
- (void)trackPropertyWithKey:(NSString *)key value:(NSString *)value sender:(id)sender;
- (void)trackPropertyWithTask:(Task *)task sender:(id)sender;
- (void)registerSuperProperties:(NSDictionary *)properties;

@end
