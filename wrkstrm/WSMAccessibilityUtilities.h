//
//  WSMAccessibilityUtilities.h
//  test2
//
//  Created by Cristian Monterroza on 1/15/14.
//  Copyright (c) 2014 wrkstrm. All rights reserved.
//

#define WSMUniversalAccessPreferencePaneName    @"UniversalAccessPref"
#define WSMPreferencePaneExtension              @"prefPane"
#define WSMSecurityPreferencePaneName           @"Security"

#ifdef __OBJC__

#define WSMLOCALIZE NO

#if WSMLOCALIZE

#define WSMLocalizedString(string) NSLocalizedString(string, string)

#else

#define WSMLocalizedString(string) string

#endif

#endif

typedef NS_ENUM(NSInteger, WSMTrustState) {
    WSMTrustStateTrue = 0,
    WSMTrustStateFalseOnOrAfterMavericks,
    WSMTrustStateFalseBeforeMavericks
};

@interface WSMAccessibilityUtilities : NSObject

+ (WSMTrustState) trustState;

+ (void)displayAccessibilityAPIAlert;

+ (NSString *)pathForPreferencePaneNamed: (NSString *)preferencePaneName;

@end
