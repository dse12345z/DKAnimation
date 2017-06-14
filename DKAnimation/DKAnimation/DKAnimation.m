//
//  DKAnimation.m
//  DKAnimation
//
//  Created by daisuke on 2017/3/21.
//  Copyright © 2017年 dse12345z. All rights reserved.
//

#import "DKAnimation.h"
#import <objc/runtime.h>

@implementation DKAnimation
@synthesize backAnimationInfo = _backAnimationInfo;

+ (instancetype)shared {
    if (!objc_getAssociatedObject(self, _cmd)) {
        objc_setAssociatedObject(self, _cmd, [[DKAnimation alloc] init], OBJC_ASSOCIATION_RETAIN);
    }
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setBackAnimationInfo:(NSMutableDictionary *)backAnimationInfo {
    _backAnimationInfo = backAnimationInfo;
}

- (NSMutableDictionary *)backAnimationInfo {
    if (_backAnimationInfo == nil) {
        _backAnimationInfo = [[NSMutableDictionary alloc] init];
    }
    return _backAnimationInfo;
}

@end
