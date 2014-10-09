//
//  WSMKeyboardViews.m
//  wrkstrm_mac
//
//  Created by Cristian Monterroza on 1/20/14.
//
//

#import "WSMKeyboardTrackerViews.h"

NSString *const kWSMViewDailyKeystrokeCount = @"dailyKeystrokeCountView";
NSString *const kWSMViewTotalKeystrokeCount = @"totalKeystrokeCountView";

@implementation WSMKeyboardTrackerViews

#define startOfDay 0
#define todayKey @"today"

+ (NSDictionary *)instanceVariablesForViewNamed:(NSString *)name {
    if (name == kWSMViewDailyKeystrokeCount) {
        return @{todayKey:[NSDate now:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)]};
    }
    return nil;
}

+ (void)setMapBlockForView:(CBLView *)view instanceVariables:(NSDictionary *)variables {
    if (view.name == kWSMViewDailyKeystrokeCount) {
        NSDate *today = variables[todayKey];
        [view setMapBlock:^(NSDictionary *doc, CBLMapEmitBlock emit) {
            for (NSArray *obj in doc[@"k"]) {
                NSTimeInterval timeSinceStartOfDay =
                [obj[0] doubleValue] - today.timeIntervalSinceReferenceDate;
                BOOL afterBeginningOfDay = startOfDay <= timeSinceStartOfDay;
                BOOL beforeEndOfDay = timeSinceStartOfDay < WSM_SECONDS_PER_DAY;
                
                if (afterBeginningOfDay && beforeEndOfDay) {
                    emit(@(timeSinceStartOfDay), obj[1]);
                }
            }
        } version:@(today.timeIntervalSinceReferenceDate).stringValue];
    }
    
    if (view.name == kWSMViewTotalKeystrokeCount) {
        [view setMapBlock:^(NSDictionary *doc, CBLMapEmitBlock emit) {
            for (NSArray *obj in doc[@"k"]) {
                emit(@([obj[0] doubleValue]), obj[1]);
            }
        } version:@"total"];
    }
}

+ (NSTimeInterval)nextVersionForView:(NSString *)name {
    if (name == kWSMViewDailyKeystrokeCount) {
        return NSDate.timeIntervalUntilNextMidNight;
    }
    return 0;
}

@end
