//
//  WSMModel.m
//  wrkstrm_mac
//
//  Created by Cristian Monterroza on 12/15/13.
//
//

#import "WSMModel.h"

@class CBLModel;

@implementation WSMModel : CBLModel

- (NSString *)docID {
    return self.document.documentID;
}

@end
