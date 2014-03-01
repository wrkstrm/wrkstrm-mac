//
//  WSMKeyEventModel6.m
//  wrkstrm_mac
//
//  Created by Cristian Monterroza on 1/18/14.
//
//

#import "WSMKeyEventModel.h"
#import "WSMActivityModel.h"

@interface WSMKeyEventModel ()

@property (nonatomic, strong) NSArray *keystroke;

@property (nonatomic, readwrite, weak) WSMActivityModel *parent;

@end

@implementation WSMKeyEventModel

- (instancetype)initWithParent:(WSMActivityModel *)parent Keystroke:(NSArray *)keystroke {
    if ((self = [super init])) {
        self.parent = parent;
        self.keystroke = keystroke;
    }
    return self;
}

- (NSTimeInterval)timestamp {
    return [self.keystroke[0] doubleValue];
}

- (NSString *)characters {
    return self.keystroke[1];
}

- (unsigned short)keyCode {
    return [self.keystroke[2] unsignedShortValue];
}

- (NSUInteger)modifierFlags {
    return [self.keystroke[3] unsignedIntegerValue];
}

- (NSTimeInterval)length {
    return [self.keystroke[4] doubleValue];
}

- (NSUInteger)hash {
    return self.keystroke.hash;
}

@end
