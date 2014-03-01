//
//  WSMAccessibilityUtilities.m
//  test2
//
//  Created by Cristian Monterroza on 1/15/14.
//  Copyright (c) 2014 wrkstrm. All rights reserved.
//

#import "WSMAccessibilityUtilities.h"
#import <Foundation/NSObjCRuntime.h>

@implementation WSMAccessibilityUtilities

+ (WSMTrustState) trustState {
    WSMTrustState result = WSMTrustStateTrue;

    NSDictionary *options = @{(__bridge id)kAXTrustedCheckOptionPrompt: @YES};
    BOOL accessibilityEnabled = AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)options);
    DDLogError(@"Accessibility is enabled and trusted? %@, %@",
               accessibilityEnabled ? @"YES" : @"NO",
               AXIsProcessTrusted() ? @"YES" : @"NO");
    
    if ((AXIsProcessTrustedWithOptions != NULL) && !AXIsProcessTrustedWithOptions(NULL)) {
        result = WSMTrustStateFalseOnOrAfterMavericks;
    } else if (!AXAPIEnabled()) {
        result = WSMTrustStateFalseBeforeMavericks;
    }
    
    return result;
}

+ (void)displayAccessibilityAPIAlert {
    NSAlert *alert = [NSAlert new];
    NSURL *preferencePaneURL = [NSURL fileURLWithPath: [WSMAccessibilityUtilities pathForPreferencePaneNamed: WSMSecurityPreferencePaneName]];
    
    alert.alertStyle = NSWarningAlertStyle;
    alert.messageText = WSMLocalizedString(@"wrkstrm requires that the Accessibility API be enabled");
    alert.informativeText = WSMLocalizedString(@"Would you like to open the Universal Access preferences so that you can turn on \"Enable access for assistive devices\"?");
    
    [alert addButtonWithTitle: WSMLocalizedString(@"Open Universal Access Preferences")];
    [alert addButtonWithTitle: WSMLocalizedString(@"Stop Spectacle")];
    
    switch ([alert runModal]) {
        case NSAlertFirstButtonReturn: {
            [NSWorkspace.sharedWorkspace openURL: preferencePaneURL];
            
        } break;
        case NSAlertSecondButtonReturn: {
            [NSApplication.sharedApplication terminate: self];
            
        } break;
        default: break;
    }
}

#pragma mark -

+ (NSString *)pathForPreferencePaneNamed: (NSString *)preferencePaneName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSPreferencePanesDirectory, NSAllDomainsMask, YES);
    NSFileManager *fileManager = NSFileManager.defaultManager;
    NSString *preferencePanePath = nil;
    
    if (preferencePaneName) {
        preferencePaneName = [preferencePaneName stringByAppendingFormat: @".%@", WSMPreferencePaneExtension];
        
        for (__strong NSString *path in paths) {
            path = [path stringByAppendingPathComponent: preferencePaneName];
            
            if (path && [fileManager fileExistsAtPath: path isDirectory: nil]) {
                preferencePanePath = path;
                
                break;
            }
        }
        
        if (!preferencePanePath) {
            NSLog(@"There was a problem obtaining the path for the specified preference pane: %@", preferencePaneName);
        }
    }
    
    return preferencePanePath;
}

@end
