//
//  UINavigationController+QQEffectiveNavigation.m
//  QQEffectiveNavigation
//
//  Created by qiongqiong on 2020/6/5.
//  Copyright © 2020 qiongqiong. All rights reserved.
//

#import <objc/runtime.h>
#import "UINavigationController+QQEffectiveNavigation.h"

typedef void (^_QQViewControllerViewAppearLifeCycleBlock)(UIViewController *viewController, BOOL animated);
typedef union _QQEffectiveNavigationProperties _QQEffectiveNavigationProperties;
///QQEffectiveNavigation bool属性共用体
union _QQEffectiveNavigationProperties {
    char bits;
    struct {
        BOOL effectiveNavigatonDisabled : 1;
        BOOL navigationBarHidden : 1;
        BOOL navigationBarTranslucent : 1;
        BOOL interactivePopDisabled : 1;
        BOOL screenAlwaysBrightEnabled : 1;
    };
};

/// 方法实现交换
/// @param cls 方法所在类
/// @param originalSelector 原始方法的方法实现
/// @param swizzledSelector 需要交换的方法实现
static inline void _QQ_SwizzleMethods(Class cls, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(cls, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);
    if (originalMethod && swizzledMethod) {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

static inline CGFloat _QQ_ScreenWidth() {
    return UIScreen.mainScreen.bounds.size.width;
}

static inline CGFloat _QQ_StatusBarHeight() {
    return UIApplication.sharedApplication.statusBarFrame.size.height;
}

static inline CGFloat _QQ_NavigationHeight() {
    return (_QQ_StatusBarHeight() + 44);
}

/// 通过比例计算当前区间值
/// @param begin 起始值
/// @param end 终值
/// @param ratio 比例
static inline CGFloat _QQ_ValueWith(CGFloat begin, CGFloat end, CGFloat ratio) {
    return (begin + (end - begin) * ratio);
}

/// 通过比例计算当前区间颜色值
/// @param begin 起始值
/// @param end 终值
/// @param ratio 比例
static inline UIColor *_QQ_ColorWith(UIColor *begin, UIColor *end, CGFloat ratio) {
    CGFloat beginRed, beginGreen, beginBlue, beginAlpha;
    [begin getRed:&beginRed green:&beginGreen blue:&beginBlue alpha:&beginAlpha];

    CGFloat endRed, endGreen, endBlue, endAlpha;
    [end getRed:&endRed green:&endGreen blue:&endBlue alpha:&endAlpha];

    UIColor *newColor = [UIColor colorWithRed:_QQ_ValueWith(beginRed, endRed, ratio)
                                        green:_QQ_ValueWith(beginGreen, endGreen, ratio)
                                         blue:_QQ_ValueWith(beginBlue, endBlue, ratio)
                                        alpha:_QQ_ValueWith(beginAlpha, endAlpha, ratio)];
    return newColor;
}

#pragma mark - NSArray (QQEffectiveNavigationPrivate)
@interface NSArray <__covariant ObjectType> (QQEffectiveNavigationPrivate)

- (ObjectType)_qq_objectAtIndex:(NSInteger)index;

@end

@interface _QQInteractivePopGestureRecognizerDelegate : NSObject <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UINavigationController *navigationController;
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL action;

@end

@interface UIVisualEffectView (QQEffectiveNavigationPrivate)

- (void)setHiddens:(BOOL)hidden UI_APPEARANCE_SELECTOR;

@end

@implementation UIVisualEffectView (QQEffectiveNavigationPrivate)

- (void)setHiddens:(BOOL)hidden {
    self.hidden = true;
}

@end

@interface UIImageView (QQEffectiveNavigationPrivate)

- (void)setHiddens:(BOOL)hidden UI_APPEARANCE_SELECTOR;

@end

@implementation UIImageView (QQEffectiveNavigationPrivate)

- (void)setHiddens:(BOOL)hidden {
    self.hidden = true;
}

@end

@interface UINavigationBar (QQEffectiveNavigationPrivate)

/** 添加一个固定的背景View */
@property (nonatomic, strong) UIView *qq_backgroundView;
- (void)qq_setBackgroundAlpha:(CGFloat)alpha;
- (void)qq_setBackgroundColor:(UIColor *)color;

@end

@implementation UINavigationBar (QQEffectiveNavigationPrivate)

- (UIView *)qq_backgroundView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setQq_backgroundView:(UIView *)colorView {
    objc_setAssociatedObject(self, @selector(qq_backgroundView), colorView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)qq_setBackgroundAlpha:(CGFloat)alpha {
    UIView *backgroundView = self.subviews.firstObject;
    self.qq_backgroundView.alpha = alpha;
    
    UIView *shadowView = object_getIvar(backgroundView, class_getInstanceVariable(backgroundView.class, "_shadowView"));
    shadowView.alpha = alpha;
    shadowView.hidden = alpha == 0;
        
    backgroundView.alpha = alpha;
}

- (void)qq_setBackgroundColor:(UIColor *)color {
    self.barTintColor = color;
    self.subviews.firstObject.backgroundColor = color;
    if (self.qq_backgroundView == nil) {
        self.qq_backgroundView = [[UIView alloc] initWithFrame:self.subviews.firstObject.bounds];
        [self.subviews.firstObject addSubview:self.qq_backgroundView];
    }
    self.qq_backgroundView.backgroundColor = color;
}

- (void)subviewsFroView:(UIView *)view class:(Class)cls array:(NSMutableArray *)array {
    if ([view isKindOfClass:cls]) {
        [array addObject:view];
    }
    if (view.subviews.count == 0) {
        return;
    }
    for (UIView *subview in view.subviews) {
        [self subviewsFroView:subview class:cls array:array];
    }
}

@end

@interface UIViewController (QQEffectiveNavigationPrivate)

/** 属性集合 */
@property (nonatomic, assign) _QQEffectiveNavigationProperties qq_properties;
/** 执行系统的 viewWillAppear 后调用 */
@property (nonatomic, copy) _QQViewControllerViewAppearLifeCycleBlock qq_viewWillAppearBlock;
/** 执行系统的 viewDidAppear 后调用 */
@property (nonatomic, copy) _QQViewControllerViewAppearLifeCycleBlock qq_viewDidAppearBlock;
/** 执行系统的 viewWillDisappear 后调用 */
@property (nonatomic, copy) _QQViewControllerViewAppearLifeCycleBlock qq_viewWillDisappearBlock;

@end

@implementation UIViewController (QQEffectiveNavigationPrivate)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _QQ_SwizzleMethods(self, @selector(viewWillAppear:), @selector(qq_viewWillAppear:));
        _QQ_SwizzleMethods(self, @selector(viewDidAppear:), @selector(qq_viewDidAppear:));
        _QQ_SwizzleMethods(self, @selector(viewWillDisappear:), @selector(qq_viewWillDisappear:));
        _QQ_SwizzleMethods(self, @selector(viewDidDisappear:), @selector(qq_viewDidDisappear:));
        [[UIVisualEffectView appearanceWhenContainedInInstancesOfClasses:@[NSClassFromString(@"_UIBarBackground")]] setHiddens:true];
        [[UIImageView appearanceWhenContainedInInstancesOfClasses:@[NSClassFromString(@"_UIBarBackground")]] setHiddens:true];
    });
}

- (void)qq_viewWillAppear:(BOOL)animated {
    [self qq_viewWillAppear:animated];
    if (self.qq_viewWillAppearBlock) {
        self.qq_viewWillAppearBlock(self, animated);
    }
}

- (void)qq_viewDidAppear:(BOOL)animated {
    [self qq_viewDidAppear:animated];
    if (self.qq_viewDidAppearBlock) {
        self.qq_viewDidAppearBlock(self, animated);
    }
}

- (void)qq_viewWillDisappear:(BOOL)animated {
    [self qq_viewWillDisappear:animated];
    if (self.qq_viewWillDisappearBlock) {
        self.qq_viewWillDisappearBlock(self, animated);
    }
}

- (void)qq_viewDidDisappear:(BOOL)animated {
    [self qq_viewDidDisappear:animated];
    
}

- (_QQViewControllerViewAppearLifeCycleBlock)qq_viewWillAppearBlock {
    _QQViewControllerViewAppearLifeCycleBlock viewWillAppearBlock = objc_getAssociatedObject(self, _cmd);
    if (viewWillAppearBlock == nil && self.qq_effectiveNavigatonDisabled == false) {
        viewWillAppearBlock = ^(UIViewController *controller, BOOL animated) {
            ///禁掉滑动返回手势在 qq_fullScreenPopGestureRecognizer 的代理里配置的。
            if ([controller isKindOfClass:UINavigationController.class]) {
                
                ((UINavigationController *)controller).navigationBar.barTintColor = ((UINavigationController *)controller).topViewController.qq_barTintColor;
            } else {
                [controller.navigationController setNavigationBarHidden:controller.qq_navigationBarHidden animated:animated];
                controller.navigationController.navigationBar.translucent = controller.qq_navigationBarTranslucent;
                UIApplication.sharedApplication.idleTimerDisabled = controller.qq_screenAlwaysBrightEnabled;
                if (controller.qq_navigationBarTranslucent == false) {
                    [controller.view addSubview:controller.qq_navigationBarBackgroundImageView];
                } else {
                    [controller.qq_navigationBarBackgroundImageView removeFromSuperview];
                }
            }
        };
        objc_setAssociatedObject(self, _cmd, viewWillAppearBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    return viewWillAppearBlock;
}

- (void)setQq_viewWillAppearBlock:(_QQViewControllerViewAppearLifeCycleBlock)qq_viewWillAppearBlock {
    objc_setAssociatedObject(self, @selector(qq_viewWillAppearBlock), qq_viewWillAppearBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (_QQViewControllerViewAppearLifeCycleBlock)qq_viewDidAppearBlock {
    _QQViewControllerViewAppearLifeCycleBlock viewDidAppearBlock = objc_getAssociatedObject(self, _cmd);
    if (viewDidAppearBlock == nil && self.qq_effectiveNavigatonDisabled == false) {
        viewDidAppearBlock = ^(UIViewController *controller, BOOL animated) {
            controller.navigationController.navigationBar.tintColor = controller.qq_tintColor;
            [controller.navigationController.navigationBar qq_setBackgroundColor:controller.qq_barTintColor];
            [controller.navigationController.navigationBar qq_setBackgroundAlpha:controller.qq_navigationBarBackgroundAlpha];
            
        };
        objc_setAssociatedObject(self, _cmd, viewDidAppearBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    return viewDidAppearBlock;
}

- (void)setQq_viewDidAppearBlock:(_QQViewControllerViewAppearLifeCycleBlock)qq_viewDidAppearBlock {
    objc_setAssociatedObject(self, @selector(qq_viewDidAppearBlock), qq_viewDidAppearBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (_QQViewControllerViewAppearLifeCycleBlock)qq_viewWillDisappearBlock {
    _QQViewControllerViewAppearLifeCycleBlock viewWillDisappearBlock = objc_getAssociatedObject(self, _cmd);
    if (viewWillDisappearBlock == nil && self.qq_effectiveNavigatonDisabled == false) {
        viewWillDisappearBlock = ^(UIViewController *controller, BOOL animated){};
        objc_setAssociatedObject(self, _cmd, viewWillDisappearBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    return viewWillDisappearBlock;
}

- (void)setQq_viewWillDisappearBlock:(_QQViewControllerViewAppearLifeCycleBlock)qq_viewWillDisappearBlock {
    objc_setAssociatedObject(self, @selector(qq_viewWillDisappearBlock), qq_viewWillDisappearBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (_QQEffectiveNavigationProperties)qq_properties {
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    union _QQEffectiveNavigationProperties properties = {number.charValue};
    if (number == nil) {
        properties.navigationBarTranslucent = true;
    }
    return properties;
}

- (void)setQq_properties:(_QQEffectiveNavigationProperties)qq_properties {
    objc_setAssociatedObject(self, @selector(qq_properties), [NSNumber numberWithChar:qq_properties.bits], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end

@interface UINavigationController (QQEffectiveNavigationPrivate)

/** 记录是否处于手动滑动结束后，后面的缓冲动画 */
@property (nonatomic, assign) BOOL qq_animating;

@end

@implementation UINavigationController (QQEffectiveNavigationPrivate)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{    ///一般情况，load方法只会加载一次，本人确实遇见过加载了两次的。
        _QQ_SwizzleMethods(self, @selector(pushViewController:animated:),     @selector(_qq_pushViewController:animated:));
        _QQ_SwizzleMethods(self, @selector(navigationBar:shouldPushItem:), @selector(_qq_navigationBar:shouldPushItem:));
        _QQ_SwizzleMethods(self, @selector(navigationBar:shouldPopItem:), @selector(_qq_navigationBar:shouldPopItem:));
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
        _QQ_SwizzleMethods(self, @selector(_updateInteractiveTransition:),    @selector(_qq__updateInteractiveTransition:));
    #pragma clang diagnostic pop
    });
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPushItem:(UINavigationItem *)item {
    return true;
}

- (BOOL)_qq_navigationBar:(UINavigationBar *)navigationBar shouldPushItem:(UINavigationItem *)item {
    BOOL result = [self _qq_navigationBar:navigationBar shouldPushItem:item];
    if (result) {
        [self _qq_updateNavigationBarWithViewController:self.topViewController];
    }
    return result;
}

- (BOOL)_qq_navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    
    BOOL result = [self _qq_navigationBar:navigationBar shouldPopItem:item];
    if (result) {
        id <UIViewControllerTransitionCoordinator> coordinator = self.topViewController.transitionCoordinator;
        if (coordinator && coordinator.initiallyInteractive) {
            [self _qq_notifyWhenInteractionChangesWithCoordinator:coordinator];
        } else {
            [self _qq_updateNavigationBarWithViewController:[self.viewControllers _qq_objectAtIndex:-2]];
        }
    }
    return result;
}

- (void)_qq_notifyWhenInteractionChangesWithCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    if (@available(iOS 10.0, *)) {
        [coordinator notifyWhenInteractionChangesUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            [self _qq_handleInteraction:context];
        }];
    } else {
        [coordinator notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            [self _qq_handleInteraction:context];
        }];
    }
}

- (void)_qq_handleInteraction:(nonnull id<UIViewControllerTransitionCoordinatorContext>)context {
    if (self.qq_animating == false) {
        self.qq_animating = true;
        if (context.isCancelled) {
            [self _qq_animateWithDuration:context.transitionDuration * context.percentComplete controller:[context viewControllerForKey:UITransitionContextFromViewControllerKey]];
        } else {
            [self _qq_animateWithDuration:context.transitionDuration * (1 - context.percentComplete) controller:[context viewControllerForKey:UITransitionContextToViewControllerKey]];
        }
    }
}

/// 滑动手势，剩余部分时间，执行动画，貌似不起作用
/// @param duration 时长
/// @param controller 最终出现的控制器
- (void)_qq_animateWithDuration:(NSTimeInterval)duration controller:(UIViewController *)controller {
    [UIView animateWithDuration:duration animations:^{
        [controller.navigationController _qq_updateNavigationBarWithViewController:controller];
    } completion:^(BOOL finished) {
        self.qq_animating = false;
    }];
}

/// 更新转场过渡的百分比
/// @param percentComplete 百分比
- (void)_qq__updateInteractiveTransition:(CGFloat)percentComplete {
    id <UIViewControllerTransitionCoordinator> coordinator = self.topViewController.transitionCoordinator;
    if (coordinator == nil) {
        return [self _qq__updateInteractiveTransition:percentComplete];
    }
    
    [self _qq_notifyWhenInteractionChangesWithCoordinator:coordinator];
    
    UIViewController *fromController = [coordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toController = [coordinator viewControllerForKey:UITransitionContextToViewControllerKey];
    CGFloat fromAlpha = fromController.qq_navigationBarBackgroundAlpha;
    CGFloat toAlpha = toController.qq_navigationBarBackgroundAlpha;
    ///这是导航栏透明度
    [self.navigationBar qq_setBackgroundAlpha:_QQ_ValueWith(fromAlpha, toAlpha, percentComplete * 1.2)];
    ///设置导航栏item的颜色
    self.navigationBar.tintColor = _QQ_ColorWith(fromController.qq_tintColor, toController.qq_tintColor, percentComplete * 1.2);
    ///设置导航栏背景色
    [self.navigationBar qq_setBackgroundColor:_QQ_ColorWith(fromController.qq_barTintColor, toController.qq_barTintColor, percentComplete * 1.2)];
    
    [self _qq__updateInteractiveTransition:percentComplete];
}

/// 更新导航栏的透明度以及tintColor
- (void)_qq_updateNavigationBarWithViewController:(UIViewController *)controller {
    if (controller.qq_tintColor != nil) {
        self.navigationBar.tintColor = controller.qq_tintColor;
    }
        
    [self.navigationBar qq_setBackgroundAlpha:controller.qq_navigationBarBackgroundAlpha];
    [self.navigationBar qq_setBackgroundColor:controller.qq_barTintColor];
}

- (void)_qq_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if ([self.viewControllers containsObject:viewController]) {
        return;
    }
    
    if ([self.interactivePopGestureRecognizer.view.gestureRecognizers containsObject:self.qq_fullScreenPopGestureRecognizer] == false) {
        [self.interactivePopGestureRecognizer.view addGestureRecognizer:self.qq_fullScreenPopGestureRecognizer];
        
        NSArray *internalTargets = [self.interactivePopGestureRecognizer valueForKey:@"targets"];
        id internalTarget = [internalTargets.firstObject valueForKey:@"target"];
        SEL internalAction = NSSelectorFromString(@"handleNavigationTransition:");
        self.qq_fullScreenPopGestureRecognizer.delegate = [self _qq_popGestureRecognizerDelegate];
        [self.qq_fullScreenPopGestureRecognizer addTarget:internalTarget action:internalAction];
        ///禁掉系统的滑动返回事件
        self.interactivePopGestureRecognizer.enabled = false;
    }
        
    if (self.viewControllers.count >= 1 && [self.viewControllers containsObject:viewController] == false) {
        viewController.hidesBottomBarWhenPushed = true;
        CGFloat alpha = 0;
        [viewController.view.backgroundColor getWhite:nil alpha:&alpha];
        if (alpha == 0) {   ///alpha 通道等于0时，没有其他非透明view的区域右滑手势失效
            viewController.view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.001];
        }
    }

    ///调用系统的实现，不需判断self.viewControllers是否包含viewController
    [self _qq_pushViewController:viewController animated:animated];
}

- (_QQInteractivePopGestureRecognizerDelegate *)_qq_popGestureRecognizerDelegate {
    _QQInteractivePopGestureRecognizerDelegate *delegate = objc_getAssociatedObject(self, _cmd);
    if (delegate == nil) {
        delegate = [[_QQInteractivePopGestureRecognizerDelegate alloc] init];
        delegate.navigationController = self;
        objc_setAssociatedObject(self, _cmd, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return delegate;
}

- (BOOL)qq_effectiveNavigationDisabled {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setQq_effectiveNavigationDisabled:(BOOL)qq_effectiveNavigationDisabled {
    objc_setAssociatedObject(self, @selector(qq_effectiveNavigationDisabled), @(qq_effectiveNavigationDisabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)qq_animating {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setQq_animating:(BOOL)qq_animating {
    objc_setAssociatedObject(self, @selector(qq_animating), @(qq_animating), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end


#pragma mark - UIViewController (QQEffectiveNavigation)
@implementation UIViewController (QQEffectiveNavigation)

#pragma mark - setter & getter

- (BOOL)qq_effectiveNavigatonDisabled {
    return self.qq_properties.effectiveNavigatonDisabled;
}

- (void)setQq_effectiveNavigatonDisabled:(BOOL)qq_effectiveNavigatonDisabled {
    _QQEffectiveNavigationProperties properties = self.qq_properties;
    properties.effectiveNavigatonDisabled = qq_effectiveNavigatonDisabled;
    self.qq_properties = properties;
}

- (BOOL)qq_navigationBarHidden {
    return self.qq_properties.navigationBarHidden;
}

- (void)setQq_navigationBarHidden:(BOOL)qq_navigationBarHidden {
    _QQEffectiveNavigationProperties properties = self.qq_properties;
    properties.navigationBarHidden = qq_navigationBarHidden;
    self.qq_properties = properties;
}

- (BOOL)qq_navigationBarTranslucent {
    return self.qq_properties.navigationBarTranslucent;
}

- (void)setQq_navigationBarTranslucent:(BOOL)qq_navigationBarTranslucent {
    _QQEffectiveNavigationProperties properties = self.qq_properties;
    properties.navigationBarTranslucent = qq_navigationBarTranslucent;
    self.qq_properties = properties;
}

- (BOOL)qq_fullScreenPopDisabled {
    return self.qq_properties.interactivePopDisabled;
}

- (void)setQq_fullScreenPopDisabled:(BOOL)qq_interactivePopDisabled {
    _QQEffectiveNavigationProperties properties = self.qq_properties;
    properties.interactivePopDisabled = qq_interactivePopDisabled;
    self.qq_properties = properties;
}

- (BOOL)qq_screenAlwaysBrightEnabled {
    return self.qq_properties.screenAlwaysBrightEnabled;
}

- (void)setQq_screenAlwaysBrightEnabled:(BOOL)qq_screenAlwaysBrightEnabled {
    _QQEffectiveNavigationProperties properties = self.qq_properties;
    properties.screenAlwaysBrightEnabled = qq_screenAlwaysBrightEnabled;
    self.qq_properties = properties;
}

- (CGFloat)qq_navigationBarBackgroundAlpha {

    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number == nil) {
        number = @1;
    }
#if CGFLOAT_IS_DOUBLE
    return [number doubleValue];
#else
    return [number floatValue];
#endif
}

- (void)setQq_navigationBarBackgroundAlpha:(CGFloat)qq_navigationBarBackgroundAlpha {
    objc_setAssociatedObject(self, @selector(qq_navigationBarBackgroundAlpha), @(MIN(1, MAX(0, qq_navigationBarBackgroundAlpha))), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)qq_fullScreenPopMaxAllowedDistance {
#if CGFLOAT_IS_DOUBLE
    return [objc_getAssociatedObject(self, _cmd) doubleValue];
#else
    return [objc_getAssociatedObject(self, _cmd) floatValue];
#endif
}

- (void)setQq_fullScreenPopMaxAllowedDistance:(CGFloat)distance {
    objc_setAssociatedObject(self, @selector(qq_fullScreenPopMaxAllowedDistance), @(MAX(0, distance)), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)qq_tintColor {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setQq_tintColor:(UIColor *)qq_tintColor {
    objc_setAssociatedObject(self, @selector(qq_tintColor), qq_tintColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)qq_barTintColor {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setQq_barTintColor:(UIColor *)qq_barTintColor {
    objc_setAssociatedObject(self, @selector(qq_barTintColor), qq_barTintColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImageView *)qq_navigationBarBackgroundImageView {
    UIImageView *imageView = objc_getAssociatedObject(self, _cmd);
    if (imageView == nil) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -_QQ_NavigationHeight(), _QQ_ScreenWidth(), _QQ_NavigationHeight())];
        imageView.backgroundColor = self.view.backgroundColor;
    }
    objc_setAssociatedObject(self, _cmd, imageView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return imageView;
}

@end

#pragma mark - UINavigationController (QQEffectiveNavigation)
@implementation UINavigationController (QQEffectiveNavigation)

- (UIPanGestureRecognizer *)qq_fullScreenPopGestureRecognizer {
    UIPanGestureRecognizer *recognizer = objc_getAssociatedObject(self, _cmd);
    if (recognizer == nil) {
        recognizer = [[UIPanGestureRecognizer alloc] init];
        recognizer.maximumNumberOfTouches = 1;
        objc_setAssociatedObject(self, _cmd, recognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return recognizer;
}

@end


@implementation NSArray (QQEffectiveNavigationPrivate)

- (id)_qq_objectAtIndex:(NSInteger)index {
    if (index>=0 || self.count == 0) {
        return [self objectAtIndex:index];
    } else {    ///负数
        if (self.count == 1) {
            return self.firstObject;
        } else {
            return [self objectAtIndex:self.count - (-(index + 1) % self.count)];;
        }
    }
}

@end

@implementation _QQInteractivePopGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
        
    if (self.navigationController.viewControllers.count <= 1 ||
      [[self.navigationController valueForKey:@"_isTransitioning"] boolValue] ||
        self.navigationController.topViewController.qq_fullScreenPopDisabled) {
        return false;   ///当只有一个控制器或者处于过渡状态状态又或者该控制器返回手势被用户禁用了
    }
    
    if ([self __effectiveBeginningDistanceWithGestureRecongnizer:gestureRecognizer] &&
        [self __effectiveScrollDirectionWithGestureRecognizer:gestureRecognizer]) {
        return true;
    }
    return false;
}

///有效的触控范围
- (BOOL)__effectiveBeginningDistanceWithGestureRecongnizer:(UIPanGestureRecognizer *)gestureRecognizer {
    UIViewController *controller = self.navigationController.topViewController;
    CGPoint beginningPoint = [gestureRecognizer locationInView:gestureRecognizer.view];
    return controller.qq_fullScreenPopMaxAllowedDistance <= beginningPoint.x;    ///小于有效区域就行，无需判断是否设置为0
}

///有效的滚动方向
- (BOOL)__effectiveScrollDirectionWithGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
    BOOL isLeftToRight = UIApplication.sharedApplication.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionLeftToRight;
    CGFloat multiplier = isLeftToRight ? 1 : - 1;
    return (translation.x * multiplier) > 0;
}

@end

