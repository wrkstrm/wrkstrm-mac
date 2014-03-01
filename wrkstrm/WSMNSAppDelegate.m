//
//  WSMAppDelegate.m
//  wrkstrm
//
//  Created by Cristian Monterroza on 2/24/14.
//
//

#import "NSStatusItem+WSMKeystrokeTracker.h"
#import "WSMKeyboardTracker.h"
#import "WSMAccessibilityUtilities.h"

@interface WSMNSAppDelegate ()

@property (nonatomic) NSTimeInterval runningtime;
@property (nonatomic, weak) IBOutlet NSWindow *accessiblityAccessDialogWindow;

@end

@implementation WSMNSAppDelegate

+ (void)load {
    WSMLogger *logger = WSMLogger.sharedInstance;
    [DDLog addLogger:logger];

    // Customize the WSLogger
    logger.formatStyle = kWSMLogFormatStyleQueue;
    logger[kWSMLogFormatKeyFile] = @7;
    logger[kWSMLogFormatKeyFunction] = @30;

    // Color the WSlogger. By default DDLog does not color VERBOSE or warn flags.
    [logger setColorsEnabled:YES];
    [logger setForegroundColor:SKColor.orangeColor
               backgroundColor:SKColor.blackColor
                       forFlag:LOG_FLAG_WARN];

    [logger setForegroundColor:SKColor.yellowColor
               backgroundColor:SKColor.blackColor
                       forFlag:LOG_FLAG_VERBOSE];

    DDLogWarn(@"Welcome to %@", WSMNSAppDelegate.ver);
}

#pragma mark - Application lifecycle

- (void)awakeFromNib {
    switch (WSMAccessibilityUtilities.trustState) {
        case WSMTrustStateFalseBeforeMavericks:{
            [WSMAccessibilityUtilities displayAccessibilityAPIAlert];
        } break;

        case WSMTrustStateFalseOnOrAfterMavericks: {
            [[NSApplication sharedApplication] runModalForWindow: self.accessiblityAccessDialogWindow];

        } break;

        default: {
            [self.statusItem setMenu:self.statusMenu];
        } break;
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return NO;
}

+ (WSMNSAppDelegate *)sharedInstance {
    return (WSMNSAppDelegate *) NSApplication.sharedApplication.delegate;
}

+ (NSString *)ver {
    NSDictionary *info = NSBundle.mainBundle.infoDictionary;
    return [NSString stringWithFormat:@"%@ (Version: %@ Build: %@)",
            info[@"CFBundleName"],
            info[@"CFBundleShortVersionString"],
            info[@"CFBundleVersion"]];
}

+ (NSString *)defaultDatabaseDirectory {
    return  [[[NSBundle mainBundle] bundlePath] stringByAppendingString: @"/Contents/Databases"];
}

#pragma mark - Property Lazy instantiation
//This status item is the equivalent of the NSWindow for now - so it stays in the App Delegate.

- (NSStatusItem *)statusItem {
    if (!_statusItem) {
        _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];

        NSImage *menuIcon= [NSImage imageNamed:NSImageNameApplicationIcon];
        [menuIcon setSize:NSMakeSize(22, 22)];
        [_statusItem setImage: menuIcon];

        [_statusItem bindTitleToKeystrokes];
        [_statusItem setHighlightMode:YES];
        [_statusItem setEnabled:YES];
        [_statusItem setToolTip:@"Today's keystrokes."];
        [_statusItem setTarget:self];

        [_statusItem setImage: menuIcon];

    }
    return _statusItem;
}

@end
