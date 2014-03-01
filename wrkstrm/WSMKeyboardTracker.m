//
//  WSMKeyboardTracker4.m
//  wrkstrm_mac
//
//  Created by Cristian Monterroza on 1/17/14.
//
//

#import "WSMKeyboardTracker.h"
#import "CBLDocument+WSMActivityModel.h"
#import "WSMActivityModel.h"
#import "WSMKeyboardTrackerViews.h"

NSString *const kWSMDatabaseKeystrokeData = @"keystroke_data";
NSString *const kWSMDatabaseKeystrokeStats = @"keystroke_stats";

@interface WSMKeyboardTracker ()

@property (nonatomic, strong) id globalMonitor, localMonitor;
@property (nonatomic, strong) RACSubject *rawKeystrokeSubject, *savedKeystrokeSubject;

@property (nonatomic, strong) CBLManager *keystrokeDBManager;
@property (nonatomic, strong) CBLDatabase *keystrokeDatabase;

@property (nonatomic, strong) NSTimer *dailyTimer;

@property (nonatomic, strong) NSMutableSet *delayedDictionaryKeys;
@property (nonatomic, strong) NSMutableDictionary *currentlyPressedKeys;
@property (nonatomic, strong) NSMutableDictionary *keysWaitingForSave, *keysReadyToSave;

@end

@implementation WSMKeyboardTracker

#pragma mark - Public Class methods

WSM_SINGLETON_WITH_NAME(sharedInstance);

- (RACSignal *)keystrokeSignal {
    return self.savedKeystrokeSubject;
}

- (CBLQuery *)dailyKeystrokesQuery {
    return [self.keystrokeDatabase viewNamed:kWSMViewDailyKeystrokeCount].createQuery;
}

- (void)keystrokeCount:(void (^)(NSUInteger keystrokeCount))onComplete {
    [[self.keystrokeDatabase viewNamed:kWSMViewTotalKeystrokeCount].createQuery
     runAsync:^(CBLQueryEnumerator *enumerator, NSError *error) {
         NSUInteger keystrokes = enumerator.count;
         dispatch_async(dispatch_get_main_queue(), ^{
             onComplete(keystrokes);
         });
     }];
}

- (instancetype)init {
    if ((self = [super init])) {
        NSUInteger documentCount = self.keystrokeDatabase.documentCount;

        [self keystrokeCount:^(NSUInteger keystrokeCount) {
            NSLog(@"<%lu Keystrokes, %f KPS>",
                  (unsigned long)keystrokeCount, (CGFloat)keystrokeCount / (CGFloat)documentCount);
        }];

        [self logDownEvents];
        [self logUpEvents];
    }
    return self;
}

#pragma mark - RACSubject setup

/**
 Subscribe to and log all future keyDown events as long as they are not repeats.
 */
#define WSM_EXACT_TIMESTAMP(event) (NSDate.date.timeIntervalSinceReferenceDate - \
NSProcessInfo.processInfo.systemUptime + event.timestamp)

- (void)logDownEvents {
    [[self.keystrokeSubject filter:^BOOL(NSEvent *rawEvent) {
        return (rawEvent.type == NSKeyDown) && !rawEvent.isARepeat;
    }] subscribeNext: ^(NSEvent *filteredEvent) {
        NSTimeInterval exactTimeStamp = WSM_EXACT_TIMESTAMP(filteredEvent);
        NSTimeInterval integerKey, decimalKey;
        decimalKey = modf(exactTimeStamp, &integerKey);
        //The parts are split in case rounding errors stop us from finding the objects again.
        self.currentlyPressedKeys[@(filteredEvent.keyCode)] =
        @[filteredEvent, @(integerKey), @(decimalKey), @(exactTimeStamp)];

        NSMutableDictionary *timeDictionary = WSM_LAZY(self.keysWaitingForSave[@(integerKey)],
                                                       @{}.mutableCopy);
        timeDictionary[@(decimalKey)] = filteredEvent;
        //WSMLog(self.currentlyPressedKeys, @"%@", [NSString stringWithFormat:@"WHAT %@", self.currentlyPressedKeys]);
    }];
}

/**
 Subscribe to and log all future keyUp events as long as they are not repeats.
 */
#define integerKey 1
#define decimalKey 2
#define saveDelay 1.0

- (void)logUpEvents {
    [[self.keystrokeSubject filter:^BOOL(NSEvent *rawEvent) {
        return (rawEvent.type == NSKeyUp) && !rawEvent.isARepeat;
    }] subscribeNext: ^(NSEvent *up) {
        NSArray *downEvent = self.currentlyPressedKeys[@(up.keyCode)];

        if (downEvent) {
            [self.currentlyPressedKeys removeObjectForKey:@(up.keyCode)];

            NSMutableDictionary *timeDictionary =
            WSM_LAZY(self.keysReadyToSave[downEvent[integerKey]],
                     @{}.mutableCopy);
            timeDictionary[downEvent[decimalKey]] = [downEvent arrayByAddingObject: up];

            BOOL isDelayed = [self.delayedDictionaryKeys containsObject:downEvent[integerKey]];
            NSTimeInterval delay = isDelayed ? 0.0f : NSDate.timeIntervalUntilNextSecond;

            if (!isDelayed) {
                [self.delayedDictionaryKeys addObject:downEvent[integerKey]];
            }


            WSM_DISPATCH_AFTER(delay, {
                [self.keysWaitingForSave[downEvent[integerKey]] removeObjectForKey:
                 downEvent[decimalKey]];

                if (![self.keysWaitingForSave[downEvent[integerKey]] count]) {
                    [CBLDocument db:self.keystrokeDatabase
                            strokes:self.keysReadyToSave[downEvent[integerKey]]
                           document:^(WSMActivityModel *model) {
                               [self.savedKeystrokeSubject sendNext:model.keystrokes];
                           }];

                    [self.delayedDictionaryKeys removeObject:downEvent[integerKey]];
                    [self.keysReadyToSave removeObjectForKey:downEvent[integerKey]];
                }
            });
        }
    }];
}

#pragma mark - Lazy Property instantiation

- (RACSubject *)keystrokeSubject {
    if (!_rawKeystrokeSubject) {
        _rawKeystrokeSubject = RACSubject.subject;

        NSUInteger logMask = (NSKeyDownMask|NSKeyUpMask|NSFlagsChangedMask);
        self.globalMonitor =
        [NSEvent addGlobalMonitorForEventsMatchingMask:logMask
                                               handler:^(NSEvent *event) {
                                                   [self->_rawKeystrokeSubject sendNext:event];
                                               }];

        self.localMonitor =
        [NSEvent addLocalMonitorForEventsMatchingMask:logMask
                                              handler:^NSEvent *(NSEvent *event) {
                                                  [self->_rawKeystrokeSubject sendNext:event];
                                                  return event;
                                              }];
    }
    return _rawKeystrokeSubject;
}

- (CBLManager *)keystrokeDBManager { return WSM_LAZY(_keystrokeDBManager, CBLManager.new); }

- (CBLDatabase *)keystrokeDatabase {
    if (!_keystrokeDatabase) {
        NSError *error;
        _keystrokeDatabase = [self.keystrokeDBManager databaseNamed:kWSMDatabaseKeystrokeData
                                                              error:&error];
        _keystrokeDatabase.maxRevTreeDepth = 1;
        [_keystrokeDatabase compact:&error];
        [_keystrokeDatabase addRegistry:WSMKeyboardTrackerViews.class
                               forViews:@[kWSMViewDailyKeystrokeCount,
                                          kWSMViewTotalKeystrokeCount]];
        //There should be a register views call here.
    }
    return _keystrokeDatabase;
}

- (RACSubject *)savedKeystrokeSubject {
    return WSM_LAZY(_savedKeystrokeSubject, RACSubject.subject);
}

- (NSMutableSet *)delayedDictionaryKeys {
    return WSM_LAZY(_delayedDictionaryKeys, NSMutableSet.new);
}

- (NSMutableDictionary *)currentlyPressedKeys {
    return WSM_LAZY(_currentlyPressedKeys, @{}.mutableCopy);
}

- (NSMutableDictionary *)keysWaitingForSave {
    return WSM_LAZY(_keysWaitingForSave, @{}.mutableCopy);
}

- (NSMutableDictionary *)keysReadyToSave {
    return WSM_LAZY(_keysReadyToSave, @{}.mutableCopy);
}

@end
