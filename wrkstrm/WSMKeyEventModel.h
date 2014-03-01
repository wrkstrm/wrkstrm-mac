//
//  WSMKeyEventModel6.h
//  wrkstrm_mac
//
//  Created by Cristian Monterroza on 1/18/14.
//
//

@class WSMActivityModel;

@interface WSMKeyEventModel : NSObject

@property (nonatomic, readonly) NSTimeInterval timestamp;

@property (nonatomic, readonly, copy) NSString *characters;

@property (nonatomic, readonly) unsigned short keyCode;

@property (nonatomic, readonly) NSUInteger modifierFlags;

@property (nonatomic, readonly) NSTimeInterval length;

@property (nonatomic, readonly, weak) WSMActivityModel *parent;

- (instancetype)initWithParent:(WSMActivityModel *)parent Keystroke:(NSArray *)keystroke;

@end
