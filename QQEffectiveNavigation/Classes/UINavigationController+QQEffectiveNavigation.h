//
//  UINavigationController+QQEffectiveNavigation.h
//  QQEffectiveNavigation
//
//  Created by qiongqiong on 2020/6/5.
//  Copyright © 2020 qiongqiong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (QQEffectiveNavigation)

/**
 单独持有一个导航栏背景
 */
@property (nonatomic, strong, readonly) UIImageView *qq_navigationBarBackgroundImageView;
/** 禁用掉当前控制器的effectiveNavigaton特性，右滑返回不受影响，默认false */
@property (nonatomic, assign) BOOL qq_effectiveNavigatonDisabled;
/** 隐藏系统的 UINavigationBar */
@property (nonatomic, assign) BOOL qq_navigationBarHidden;
/** 开启navigationBar的translucent属性，默认true开启 */
@property (nonatomic, assign) BOOL qq_navigationBarTranslucent;
/** 禁用掉右滑返回手势 */
@property (nonatomic, assign) BOOL qq_fullScreenPopDisabled;
/** 是否开启屏幕常亮 */
@property (nonatomic, assign) BOOL qq_screenAlwaysBrightEnabled;

/** 导航栏背景色 */
@property (nonatomic, strong) UIColor *qq_barTintColor;
/** 导航栏item的文字颜色 */
@property (nonatomic, strong) UIColor *qq_tintColor;

/** 默认1 */
@property (nonatomic, assign) CGFloat qq_navigationBarBackgroundAlpha;
/**
 滑动返回时允许最大的距离，右滑返回距离左侧，左滑返回距离右侧
 */
@property (nonatomic, assign) CGFloat qq_fullScreenPopMaxAllowedDistance;

@end

@interface UINavigationController (QQEffectiveNavigation)

/** 全屏返回手势 */
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *qq_fullScreenPopGestureRecognizer;

@end


NS_ASSUME_NONNULL_END
