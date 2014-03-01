//
//  WSMAppDelegate.h
//  wrkstrm
//
//  Created by Cristian Monterroza on 2/24/14.
//
//

#import <Cocoa/Cocoa.h>

@class WSMMenuController;

@interface WSMNSAppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, strong) NSStatusItem  *statusItem;

@property (nonatomic, strong) IBOutlet NSMenu *statusMenu;

+ (NSString *)defaultDatabaseDirectory;

@end
