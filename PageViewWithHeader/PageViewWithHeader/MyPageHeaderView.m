//
//  MyPageHeaderView.m
//  PageViewWithHeader
//
//  Created by PudgeMa on 2020/2/18.
//  Copyright © 2020 PudgeMa. All rights reserved.
//

#import "MyPageHeaderView.h"

#import <objc/runtime.h>
#import <objc/message.h>
#import <CoreFoundation/CFDictionary.h>

/* ------------------- iOS 13.x ------------------------ */

static UIView* (*originalActingParentViewIMP)(id, SEL);

static UIView* swizzledActingParentViewIMP(id self, SEL _cmd) {
    if ([self isMemberOfClass:[MyPageHeaderView class]]) {
        return ((MyPageHeaderView *)self).actingParentView;
    }
    return originalActingParentViewIMP(self, _cmd);
}

static void setupCustomMethod13() {
    SEL selector = NSSelectorFromString(@"_actingParentViewForGestureRecognizers");
    Class clazz = [MyPageHeaderView class];
    Method method = class_getInstanceMethod(clazz, selector);
    if (method) {
        const void *originalIMP = method_getImplementation(method);
        originalActingParentViewIMP = originalIMP;
        const char *encoding = method_getTypeEncoding(method);
        class_replaceMethod(clazz, selector, (IMP)swizzledActingParentViewIMP, encoding);
    }
}

/* ------------ iOS 12.x and below versions -------------- */

static SEL sel_shouldReceiveTouch;
static SEL sel_deliverTouch2Super;
static SEL sel_addGestureRecognizer;
static SEL sel_touchesForKey;
static SEL sel_exclusiveView;

static ptrdiff_t offset_recgonizersByWindow;

static void (*origin_addGestureRecognizersIMP)(id self, SEL _cmd, UIView *view, UITouch *touch);

static void custom_addGestureRecognizers(id self, SEL _cmd, UIView *view, UITouch *touch) {
    void(^AddGestureRecognizer2Touch)(UIGestureRecognizer *, UIView *, BOOL) = ^(UIGestureRecognizer *targetRecognizer, UIView *targetView, BOOL isActingParent){
        if (targetRecognizer.isEnabled && targetRecognizer.state <= UIGestureRecognizerStateChanged) {
            UIView *recognizerView = targetRecognizer.view;
            UIView *touchView = recognizerView;
            if (!isActingParent) {
                touchView = touch.view;
            }
            if ((BOOL)objc_msgSend(targetRecognizer, sel_shouldReceiveTouch, touch, recognizerView, touchView)) {
                (void)objc_msgSend(touch, sel_addGestureRecognizer, targetRecognizer);
                NSMutableSet *touches = objc_msgSend(self, sel_touchesForKey, targetRecognizer);
                [touches addObject:touch];
            }
        } else {
            UIWindow *window = view.window;
            CFMutableDictionaryRef ref = *((CFMutableDictionaryRef *)((__bridge void *)self + offset_recgonizersByWindow));
            __unused id recognizers = CFDictionaryGetValue(ref, (__bridge const void *)(window));
            CFDictionaryRemoveValue(ref, (__bridge const void *)(window));
        }
    };
    if (!view) {
        return;
    }
    UIView *exclusiveTouchView = (UIView *)objc_msgSend(view.window, sel_exclusiveView);
    UIView *currentView = view;
    NSMutableSet<UIView *> *findedViews = [NSMutableSet new];
    UIView *findedActingParentView = nil;
    while (currentView) {
        [findedViews addObject:currentView];
        NSArray<UIGestureRecognizer *> *recognizers = [currentView gestureRecognizers];
        if (recognizers) {
            if (!exclusiveTouchView || [exclusiveTouchView isDescendantOfView:currentView]) {
                for (UIGestureRecognizer *recognizer in recognizers) {
                    AddGestureRecognizer2Touch(recognizer, currentView, NO);
                }
            }
        }
        if ([currentView isMemberOfClass:[MyPageHeaderView class]]) {
            UIView *actingParentView = ((MyPageHeaderView *)currentView).actingParentView;
            if (actingParentView) {
                NSAssert(!findedActingParentView, @"DO NOT SUPPORT MULTI ACTINGPARENTVIEW!");
                findedActingParentView = actingParentView;
            }
        }
        if (!(BOOL)objc_msgSend(currentView, sel_deliverTouch2Super)) {
            break;
        }
        currentView = currentView.superview;
    }
    currentView = findedActingParentView;
    while (currentView) {
        if ([findedViews containsObject:currentView]) {
            break;
        }
        NSArray<UIGestureRecognizer *> *recognizers = [currentView gestureRecognizers];
        if (recognizers) {
            if (!exclusiveTouchView || [exclusiveTouchView isDescendantOfView:currentView]) {
                for (UIGestureRecognizer *recognizer in recognizers) {
                    AddGestureRecognizer2Touch(recognizer, currentView, YES);
                }
            }
        }
        if (!(BOOL)objc_msgSend(currentView, sel_deliverTouch2Super)) {
            break;
        }
        currentView = currentView.superview;
    }
}

static void setupCustomMethod() {
    Class clazz_TouchesEvent = NSClassFromString(@"UITouchesEvent");
    SEL sel_addGestureRecognizers = NSSelectorFromString(@"_addGestureRecognizersForView:toTouch:");
    Method method_addGestureRecognizers = class_getInstanceMethod(clazz_TouchesEvent, sel_addGestureRecognizers);
    void *IMP_addGestureRecognizers = method_getImplementation(method_addGestureRecognizers);
    origin_addGestureRecognizersIMP = IMP_addGestureRecognizers;
    const char * encoding_addGestureRecognizers = method_getTypeEncoding(method_addGestureRecognizers);
    class_replaceMethod(clazz_TouchesEvent, sel_addGestureRecognizers, (IMP)custom_addGestureRecognizers, encoding_addGestureRecognizers);
    
    sel_shouldReceiveTouch = NSSelectorFromString(@"_shouldReceiveTouch:recognizerView:touchView:");
    sel_deliverTouch2Super = NSSelectorFromString(@"deliversTouchesForGesturesToSuperview");
    sel_addGestureRecognizer = NSSelectorFromString(@"_addGestureRecognizer:");
    sel_touchesForKey = NSSelectorFromString(@"_touchesForKey:");
    sel_exclusiveView = NSSelectorFromString(@"_exclusiveTouchView");
    
    Ivar ivar_recgonizersByWindow = class_getInstanceVariable(NSClassFromString(@"UITouchesEvent"), "_gestureRecognizersByWindow");
    offset_recgonizersByWindow = ivar_getOffset(ivar_recgonizersByWindow);
}

@implementation MyPageHeaderView

+ (void)initialize {
    if (self == [MyPageHeaderView class]) {
        if (@available(iOS 13, *)) {
            setupCustomMethod13();
        } else if (@available(iOS 10, *)) {
            setupCustomMethod();
        }
    }
}

@end
