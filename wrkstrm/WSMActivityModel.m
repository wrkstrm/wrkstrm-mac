//
//  WSMActivityModel.m
//  wrkstrm_mac
//
//  Created by Cristian Monterroza on 1/18/14.
//
//

#import "WSMActivityModel.h"
#import "WSMKeyEventModel.h"

@interface WSMActivityModel ()

//Dynamic
@property (nonatomic, strong) NSArray *k;

@end

@implementation WSMActivityModel

@dynamic k;

@synthesize keystrokes = _keystrokes;

- (NSArray *)keystrokes {
    if (!_keystrokes) {
        _keystrokes = [self.k.rac_sequence map:^id(NSArray *keystroke) {
            return [[WSMKeyEventModel alloc] initWithParent:self Keystroke:keystroke];
        }].array;
    }
    return _keystrokes;
}

@end
