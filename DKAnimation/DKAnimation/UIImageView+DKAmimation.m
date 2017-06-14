//
//  UIImageView+DKAmimation.m
//  DKAnimation
//
//  Created by daisuke on 2017/3/20.
//  Copyright © 2017年 dse12345z. All rights reserved.
//

#import "UIImageView+DKAmimation.h"
#import <objc/runtime.h>

typedef NS_OPTIONS (NSInteger, SnapShotType) {
    SnapShotTypeUp = 1 << 1, // 剪裁上半部分
    SnapShotTypeDown = 1 << 2, // 剪裁下半部分
};

@implementation UIImageView (DKAmimation)
@dynamic delegate;

#pragma mark - properties

- (void)setDelegate:(id<UIImageViewDKAmimationDelegate>)delegate {
    objc_setAssociatedObject(self, @selector(delegate), delegate, OBJC_ASSOCIATION_ASSIGN);
}

- (id<UIImageViewDKAmimationDelegate>)delegate {
    return objc_getAssociatedObject(self, _cmd);
}

- (NSMutableDictionary *)component {
    if (!objc_getAssociatedObject(self, _cmd)) {
        objc_setAssociatedObject(self, _cmd, [[NSMutableDictionary alloc] init], OBJC_ASSOCIATION_RETAIN);
    }
    return objc_getAssociatedObject(self, _cmd);
}

#pragma mark - method

- (void)addGestureWithClass:(id)aClass {
    self.delegate = aClass;
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushViewController)];
    [self addGestureRecognizer:tapGestureRecognizer];
}

- (void)dk_backAnimation:(id)aClass {
    UINavigationController *naviDetailViewController = aClass;
    UIImageView *topImageView = self.component[@"topImageView"][@"imageView"];
    [naviDetailViewController.view addSubview:topImageView];
    
    UIImageView *downImageView = self.component[@"downImageView"][@"imageView"];
    [naviDetailViewController.view addSubview:downImageView];
    
    for (NSInteger index = 0; index < [self.delegate dk_centerViews].count; index++) {
        NSString *keyString = [NSString stringWithFormat:@"center%td", index];
        UIImageView *imageView = self.component[keyString][@"imageView"];
        [naviDetailViewController.view addSubview:imageView];
    }
    
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations: ^{
        NSValue *topStartFrame = self.component[@"topImageView"][@"startFrame"];
        topImageView.frame = topStartFrame.CGRectValue;
        
        NSValue *downStartFrame = self.component[@"downImageView"][@"startFrame"];
        downImageView.frame = downStartFrame.CGRectValue;

        for (NSInteger index = 0; index < [self.delegate dk_centerViews].count; index++) {
            NSString *keyString = [NSString stringWithFormat:@"center%td", index];
            UIImageView *imageView = self.component[keyString][@"imageView"];
            NSValue *val = self.component[keyString][@"startFrame"];
            imageView.frame = val.CGRectValue;
            [naviDetailViewController.view addSubview:imageView];
        }
        
    } completion: ^(BOOL finished) {
        [topImageView removeFromSuperview];
        [downImageView removeFromSuperview];
        for (NSInteger index = 0; index < [self.delegate dk_centerViews].count; index++) {
            NSString *keyString = [NSString stringWithFormat:@"center%td", index];
            UIImageView *imageView = self.component[keyString][@"imageView"];
            [imageView removeFromSuperview];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"dkAnimationPop" object:nil];
        [self.component removeAllObjects];
        [[DKAnimation shared].backAnimationInfo removeAllObjects];
    }];
}

#pragma mark - private instance method

#pragma mark * push

- (void)pushViewController {
    CGFloat screenWidth =  [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    UINavigationController *currentNavigationController = [self currentViewController].navigationController;
    UIViewController *nextViewController = [self.delegate dk_pushToViewController];
    
    // full screen image
    /*
     CGRect frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
     UIImageView *screenImageView = [[UIImageView alloc] initWithFrame:frame];
     screenImageView.image = [self snapShotToImage:currentNavigationController.view];
     */
    UIImage *fullScreenImage = [self snapShotToImage:currentNavigationController.view];
    
    CGRect selectedImageViewFrame = [self.superview convertRect:self.frame toView:nil];
    
    // 上方的圖片
    UIImage *topImage = [self separationImage:fullScreenImage snapShotType:SnapShotTypeUp];
    CGFloat topHeight = CGRectGetMinY(selectedImageViewFrame);
    CGRect topStartFrame = CGRectMake(0, 0, screenWidth, topHeight);
    CGRect topEndFrame = CGRectMake(0, (-topHeight) + 64, screenWidth, topHeight);
    
    UIImageView *topImageView = [[UIImageView alloc] initWithFrame:topStartFrame];
    
    topImageView.image = topImage;
    [nextViewController.view addSubview:topImageView];
    
    [self addToComponent:@"topImageView" imageView:topImageView starFrame:topStartFrame endFrame:topEndFrame];
    
    // 下方的圖片
    UIImage *downImage = [self separationImage:fullScreenImage snapShotType:SnapShotTypeDown];
    CGFloat downHeight = CGRectGetMaxY(selectedImageViewFrame);
    CGRect downStartFrame = CGRectMake(0, downHeight, screenWidth, screenHeight - downHeight);
    CGRect downEndFrame = CGRectMake(0, screenHeight, screenWidth, screenHeight - downHeight);
    
    UIImageView *downImageView = [[UIImageView alloc] initWithFrame:downStartFrame];
    downImageView.image = downImage;
    [nextViewController.view addSubview:downImageView];
    
    [self addToComponent:@"downImageView" imageView:downImageView starFrame:downStartFrame endFrame:downEndFrame];
    
    
    // 中間的圖片
    [self addCenterImageViews:nextViewController];
    
    //    UIImageView *selectedImageView = [[UIImageView alloc] initWithFrame:selectedImageViewFrame];
    //    selectedImageView.image = self.image;
    //    [nextViewController.view addSubview:selectedImageView];
    //    self.component[@"selectedImageView"] = selectedImageView;
    
    // push viewController
    currentNavigationController.navigationBar.hidden = YES;
    [currentNavigationController pushViewController:nextViewController animated:NO];
    
    // 進場動畫
    /*
     CGFloat duration = [self.delegate dk_animateDuration];
     [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations: ^{
     selectedImageView.frame = [self.delegate dk_selectedImageViewMovewToFrame];
     } completion:^(BOOL finished) {
     }];*/
    
    [DKAnimation shared].backAnimationInfo[[NSValue valueWithNonretainedObject:nextViewController]] = self;
    CGFloat duration = [self.delegate dk_animateDuration];
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations: ^{
        topImageView.frame = topEndFrame;
        downImageView.frame = downEndFrame;
        
        for (NSInteger index = 0; index < [self.delegate dk_centerViews].count; index++) {
            NSString *keyString = [NSString stringWithFormat:@"center%td", index];
            UIImageView *imageView = self.component[keyString][@"imageView"];
            NSValue *val = self.component[keyString][@"endFrame"];
            imageView.frame = val.CGRectValue;
        }
    } completion: ^(BOOL finished) {
        [topImageView removeFromSuperview];
        [downImageView removeFromSuperview];
        for (NSInteger index = 0; index < [self.delegate dk_centerViews].count; index++) {
            NSString *keyString = [NSString stringWithFormat:@"center%td", index];
            UIImageView *imageView = self.component[keyString][@"imageView"];
            [imageView removeFromSuperview];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"dkAnimationComplete" object:nil];
    }];
}

#pragma mark * image

- (UIImage *)snapShotToImage:(UIView *)view {
    // 將目前的畫面製作成圖片
    UIGraphicsBeginImageContextWithOptions(view.window.bounds.size, view.window.opaque, 0);
    [view.window.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *aImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return aImage;
}

- (UIImage *)separationImage:(UIImage *)image snapShotType:(SnapShotType)snapShotType {
    // 將圖片剪裁
    // 因為是取得點擊圖片的最小的 y 值，所以會有兩種情況必須要做判斷
    // 第一種：tapImageViewTopY 必須要大於 0 ，如果小於 0 的話代表點擊的圖片上半部份超出螢幕外面，所以就不做剪裁動作。
    // 第二種：tapImageViewTopY 必須要小於 imageSize.height，如果大於 imageSize.height 的話代表點擊的圖片下半部份超出螢幕外面，所以就不做剪裁動作。
    
    CGSize imageSize = image.size;
    CGRect selectedImageViewFrame = [self.superview convertRect:self.frame toView:nil];
    CGFloat y = (snapShotType == SnapShotTypeUp) ? CGRectGetMinY(selectedImageViewFrame) : CGRectGetMaxY(selectedImageViewFrame);
    
    BOOL isOverTopScreen = (y < 0);
    BOOL isOverDownScreen = (y > imageSize.height);
    
    if (isOverTopScreen && snapShotType == SnapShotTypeUp) {
        return nil;
    }
    else if (isOverDownScreen && snapShotType == SnapShotTypeDown) {
        return nil;
    }
    
    CGRect rect = CGRectNull;
    CGFloat scale = [UIScreen mainScreen].scale;
    switch (snapShotType) {
        case SnapShotTypeUp:
            rect = CGRectMake(0, 0, imageSize.width * scale, y * scale);
            break;
            
        case SnapShotTypeDown:
            rect = CGRectMake(0, y * scale, imageSize.width * scale, (imageSize.height - y) * scale);
            break;
    }
    
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    return CGRectIsNull(rect) ? nil : newImage;
}

#pragma mark * misc

- (UIViewController *)currentViewController {
    id viewController = [self nextResponder];
    
    while (![viewController isKindOfClass:[UIViewController class]] && viewController != nil)
        viewController = [viewController nextResponder];
    return viewController;
}

- (void)addToComponent:(NSString *)keyName imageView:(UIImageView *)imageView starFrame:(CGRect)startFrame endFrame:(CGRect)endFrame {
    self.component[keyName] = @{ @"imageView":imageView, @"startFrame":[NSValue valueWithCGRect:startFrame], @"endFrame":[NSValue valueWithCGRect:endFrame] };
}

- (void)addCenterImageViews:(UIViewController *)viewController {
    CGRect selectedStartFrame = [self.superview convertRect:self.frame toView:nil];
    CGRect selectedEndFrame = [self.delegate dk_selectedImageViewMovewToFrame];
    
    for (NSInteger index = 0; index < [self.delegate dk_centerViews].count; index++) {
        UIImageView *centerView = [self.delegate dk_centerViews][index];
        CGRect startFrame = [centerView.superview convertRect:centerView.frame toView:nil];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:startFrame];
        imageView.image = centerView.image;
        
        NSString *keyString = [NSString stringWithFormat:@"center%td", index];
        if (CGRectContainsRect(selectedStartFrame, startFrame)) {
            [self addToComponent:keyString imageView:imageView starFrame:startFrame endFrame:selectedEndFrame];
        }
        else {
            BOOL isLeft = CGRectGetMinX(startFrame) < CGRectGetMinX(selectedStartFrame);
            if (isLeft) {
                CGFloat x = CGRectGetWidth(selectedEndFrame) + (CGRectGetMinX(selectedStartFrame) - CGRectGetMaxX(startFrame));
                CGRect endFrame = CGRectMake(-x, CGRectGetMinY(selectedEndFrame), CGRectGetWidth(selectedEndFrame), CGRectGetHeight(selectedEndFrame));
                [self addToComponent:keyString imageView:imageView starFrame:startFrame endFrame:endFrame];
            }
            else {
                CGFloat x = CGRectGetWidth(selectedEndFrame) + (CGRectGetMinX(startFrame) - CGRectGetMaxX(selectedStartFrame));
                CGRect endFrame = CGRectMake(x, CGRectGetMinY(selectedEndFrame), CGRectGetWidth(selectedEndFrame), CGRectGetHeight(selectedEndFrame));
                [self addToComponent:keyString imageView:imageView starFrame:startFrame endFrame:endFrame];
            }
        }
        [viewController.view addSubview:imageView];
    }
}

@end
