//
//  CBLDatabase+WSMUtilities.m
//  wrkstrm_mac
//
//  Created by Cristian Monterroza on 1/20/14.
//
//

#import "CBLDatabase+WSMUtilities.h"
#import <objc/runtime.h>

@interface CBLDatabase ()

@property (nonatomic, strong) NSMutableDictionary *registries;
@property (nonatomic, strong) NSMutableDictionary *variables;
@property (nonatomic, strong) NSMutableDictionary *timers;

@end

@implementation CBLDatabase (WSMUtilities)

static const NSString *const kWSMViewRegistries = @"registries";
static const NSString *const kWSMViewVariables = @"variables";
static const NSString *const kWSMViewTimers = @"timers";
NSString *const kWSMViewRefreshNotification = @"kWSMViewRefreshNotification";

- (void)addRegistry:(Class <WSMViewRegistry>)registry forViews:(NSArray *)views {
    for (NSString *name in views) {
        self.registries[name] = NSStringFromClass(registry);
        [self mapBlockForViewNamed:name];
    }
}

#define viewName @"viewName"
- (void)mapBlockForViewNamed:(NSString *)name {
    if (name) {
        Class <WSMViewRegistry> registry = NSClassFromString(self.registries[name]);

        //Although views should be pure funtions,
        //there are some instance variables which are too expensive to create every time a view updates
        NSDictionary *viewInstanceVariables = [registry instanceVariablesForViewNamed:name];
        self.variables[name] = viewInstanceVariables ?: @{};

        //The registry passes the expensive instance variables to the registry class
        //Which in turn adds a mapblock and a version.
        [registry setMapBlockForView:[self viewNamed:name]
                   instanceVariables:self.variables[name]];

        //Finally. the view should then try to refresh its version if it wants to.
        NSTimeInterval refreshDelay = [registry nextVersionForView:name];

        if (refreshDelay != 0) {
            self.timers[name] = [NSTimer scheduledTimerWithTimeInterval:refreshDelay target:self
                                                               selector:@selector(refreshViewVersion:)
                                                               userInfo:@{viewName: name }
                                                                repeats:NO];
        }
    }
}

- (void)refreshViewVersion:(NSTimer *)timer {
    [self mapBlockForViewNamed:timer.userInfo[viewName]];

    [NSNotificationCenter.defaultCenter postNotificationName:kWSMViewRefreshNotification
                                                      object:nil
                                                    userInfo:@{viewName:timer.userInfo[viewName]}];
}

#pragma mark - Lazy Instantiaion of Assocaiated references

- (void)setRegistries:(NSMutableDictionary *)registries {
    [self willChangeValueForKey:[kWSMViewRegistries copy]];
    objc_setAssociatedObject(self, &kWSMViewRegistries, registries, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:[kWSMViewRegistries copy]];
}

- (NSMutableDictionary *)registries {
    if (!objc_getAssociatedObject(self, &kWSMViewRegistries)) {
        objc_setAssociatedObject(self, &kWSMViewRegistries, @{}.mutableCopy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return objc_getAssociatedObject(self, &kWSMViewRegistries);
}

- (void)setVariables:(NSMutableDictionary *)variables {
    [self willChangeValueForKey:[kWSMViewVariables copy]];
    objc_setAssociatedObject(self, &kWSMViewVariables, variables, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:[kWSMViewVariables copy]];
}

- (NSMutableDictionary *)variables {
    if (!objc_getAssociatedObject(self, &kWSMViewVariables)) {
        objc_setAssociatedObject(self, &kWSMViewVariables, @{}.mutableCopy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return objc_getAssociatedObject(self, &kWSMViewVariables);
}

- (void)setTimers:(NSMutableDictionary *)timers {
    [self willChangeValueForKey:[kWSMViewTimers copy]];
    objc_setAssociatedObject(self, &kWSMViewTimers, timers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:[kWSMViewTimers copy]];
}

- (NSMutableDictionary *)timers {
    if (!objc_getAssociatedObject(self, &kWSMViewTimers)) {
        objc_setAssociatedObject(self, &kWSMViewTimers, @{}.mutableCopy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return objc_getAssociatedObject(self, &kWSMViewTimers);
}

@end
