//
//  CBLDatabase+WSMUtilities.h
//  wrkstrm_mac
//
//  Created by Cristian Monterroza on 1/20/14.
//
//

@protocol WSMViewRegistry <NSObject>

+ (NSDictionary *)instanceVariablesForViewNamed:(NSString *)name;

+ (void)setMapBlockForView:(CBLView *)view instanceVariables:(NSDictionary *)variables;

+ (NSTimeInterval)nextVersionForView:(NSString *)name;

@end

extern NSString *const kWSMViewRefreshNotification;

@interface CBLDatabase (WSMUtilities)

- (void)addRegistry:(Class <WSMViewRegistry>)registry forViews:(NSArray *)views;

@end
