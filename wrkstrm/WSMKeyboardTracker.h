//
//  WSMKeyboardTracker4.h
//  wrkstrm_mac
//
//  Created by Cristian Monterroza on 1/17/14.
//
//

extern NSString *const kWSMDatabaseKeystrokeData;
extern NSString *const kWSMDatabaseKeystrokeStats;

@interface WSMKeyboardTracker : NSObject

+ (instancetype)sharedInstance;

- (RACSignal *)keystrokeSignal;

- (CBLQuery *)dailyKeystrokesQuery;

@end
