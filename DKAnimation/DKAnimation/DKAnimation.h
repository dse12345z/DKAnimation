//
//  DKAnimation.h
//  DKAnimation
//
//  Created by daisuke on 2017/3/21.
//  Copyright © 2017年 dse12345z. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface DKAnimation : NSObject

@property (strong, nonatomic) NSMutableDictionary *backAnimationInfo;

+ (instancetype)shared;

@end
