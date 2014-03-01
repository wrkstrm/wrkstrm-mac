//
//  CBLDocument+WSMKeyEvent4.h
//  wrkstrm_mac
//
//  Created by Cristian Monterroza on 1/17/14.
//
//

#import <CouchbaseLite/CouchbaseLite.h>

@class WSMActivityModel;

@interface CBLDocument (WSMActivityModel)

/**
 This method saves all keystrokes that were initiated during the same second in one document.
 The document ID is the second since January 1, 2001 that it occured. 
 The WSMActivityModel has 1 property: An array of keystrokes that took place that second.
 The properties need to be unfolded on demand.
 
 @param db  The database where the document will be saved to
 @param keystrokes  A Dictionary of all the keystrokes that took place that second.
 @param block to be executed on the main thread with the saved WSMActivityModel.
 */

+ (void)db:(CBLDatabase *)db strokes:(NSDictionary *)keystrokes document:(void (^)(WSMActivityModel *))block;

/**
 * http://blog.elliottcable.name/posts/useful_unicode.xhtml
 */

+ (NSString *)eventCharacters:(NSEvent *)event;

@end
