//
//  NSStatusItem+WSMKeystrokeTracker.h
//  wrkstrm_mac
//
//  Created by Cristian Monterroza on 12/14/13.
//
//

#import <Cocoa/Cocoa.h>

@interface NSStatusItem (WSMKeystrokeTracker)

@property (nonatomic) NSUInteger keystrokes;

- (void)bindTitleToKeystrokes;

@end
