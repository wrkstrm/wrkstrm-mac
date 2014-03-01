//
//  CBLDocument+WSMKeyEvent4.m
//  wrkstrm_mac
//
//  Created by Cristian Monterroza on 1/17/14.
//
//

#import "CBLDocument+WSMActivityModel.h"
#import "WSMActivityModel.h"

#define down 0
#define docID 1

#define time 2
#define exact 3
#define up 4

#define obj 1

@implementation CBLDocument (WSMActivityModel)

+ (void)db:(CBLDatabase *)db strokes:(NSDictionary *)keystrokes
  document:(void (^)(WSMActivityModel *))block {
    __block NSString *documentID;
    NSArray *keystrokeArray = [keystrokes.rac_sequence map:^id(RACTuple *pair) {
        NSArray *keystroke = pair[obj];
        WSM_LAZY(documentID, [keystroke[docID] stringValue]);
        NSEvent *downEvent = keystroke[down];
        NSTimeInterval elapsedTime = [keystroke[up] timestamp] - downEvent.timestamp;
        NSString *characters = [CBLDocument eventCharacters:downEvent];

        //Fraction of a second, keycode, characters, modifierFlags, length
        return @[keystroke[exact], characters,
                 [NSNumber numberWithUnsignedShort: downEvent.keyCode],
                 @(downEvent.modifierFlags), @(elapsedTime)];
    }].array;

    [db.manager backgroundTellDatabaseNamed:db.name to:^(CBLDatabase *keysDB) {
        CBLUnsavedRevision *rev = [keysDB documentWithID:documentID].newRevision;

        rev[@"k"] = [[WSM_LAZY(rev[@"k"], @[].mutableCopy)
                      arrayByAddingObjectsFromArray:keystrokeArray]
                     sortedArrayWithOptions:NSSortConcurrent
                     usingComparator:^NSComparisonResult(id obj1, id obj2) {
                         WSM_COMPARATOR([obj1[0] doubleValue] <
                                        [obj2[0] doubleValue]);
                   }];

        [rev save:nil];

        dispatch_async(dispatch_get_main_queue(), ^{
            block([WSMActivityModel modelForDocument: [db documentWithID: documentID]]);
        });
    }];
}

+ (NSString *)eventCharacters:(NSEvent *)event {
    switch (event.keyCode) {
        case 36: return @"↩";
        case 48: return @"⇥";
        case 49: return @" ";
        case 51: return @"⌫";
        case 53: return @"␛";
        case 123: return @"←";
        case 124: return @"→";
        case 125: return @"↓";
        case 126: return @"↑";
        default: return event.characters;
    }
}

@end
