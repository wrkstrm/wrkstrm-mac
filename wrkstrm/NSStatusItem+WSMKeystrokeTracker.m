//
//  NSStatusItem+WSMKeystrokeTracker.m
//  wrkstrm_mac
//
//  Created by Cristian Monterroza on 12/14/13.
//
//

#import "NSStatusItem+WSMKeystrokeTracker.h"
#import "WSMKeyboardTracker.h"
#import "WSMKeyboardTrackerViews.h"
#import <objc/runtime.h>

@implementation NSStatusItem (WSMKeystrokeTracker)

static const char *const keystrokeKey = "keystrokeKey";

#define viewName @"viewName"

- (void)bindTitleToKeystrokes {
    [WSMKeyboardTracker.sharedInstance.keystrokeSignal subscribeNext:^(NSArray *savedKeystrokes) {
        self.title = [NSString stringWithFormat:@"%lu", savedKeystrokes.count + self.title.integerValue];
    }];
}

- (void)setKeystrokes:(NSUInteger)keystrokes {
    [self willChangeValueForKey:@"keystrokes"];
    objc_setAssociatedObject(self, &keystrokeKey, @(keystrokes), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"keystrokes"];
}

- (NSUInteger)keystrokes {
    return [objc_getAssociatedObject(self, &keystrokeKey) unsignedIntegerValue];
}

@end
