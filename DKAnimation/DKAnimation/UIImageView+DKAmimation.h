//
//  UIImageView+DKAmimation.h
//  DKAnimation
//
//  Created by daisuke on 2017/3/20.
//  Copyright © 2017年 dse12345z. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DKAnimation.h"

@protocol UIImageViewDKAmimationDelegate <NSObject>
@required
- (UIViewController *)dk_pushToViewController;
- (UIView *)dk_selectedArea;
- (CGRect)dk_selectedImageViewMovewToFrame;
- (CGFloat)dk_animateDuration;
- (NSArray *)dk_centerViews;

@end

@interface UIImageView (DKAmimation)

@property (weak, nonatomic) id <UIImageViewDKAmimationDelegate>delegate;

- (void)addGestureWithClass:(id)aClass;
- (void)dk_backAnimation:(id)aClass;

@end
