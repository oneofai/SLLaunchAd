//
//  SLLaunchAdUtilities.m
//  YiBanClient
//
//  Created by Sun on 2020/05/29.
//  Copyright © 2019 Qing Class. All rights reserved.
//


#import "SLLaunchAdUtilities.h"

NSString *const SLCacheImageURLStringKey = @"SLCacheImageURLStringKey";
NSString *const SLCacheVideoURLStringKey = @"SLCacheVideoURLStringKey";

NSString *const SLLaunchAdWaitDataDurationArriveNotification = @"SLLaunchAdWaitDataDurationArriveNotification";
NSString *const SLLaunchAdDetailPageWillShowNotification = @"SLLaunchAdDetailPageWillShowNotification";
NSString *const SLLaunchAdDetailPageShowFinishNotification = @"SLLaunchAdDetailPageShowFinishNotification";
NSString *const SLLaunchAdGIFImageCycleOnceFinishNotification = @"SLLaunchAdGIFImageCycleOnceFinishNotification";
NSString *const SLLaunchAdVideoCycleOnceFinishNotification = @"SLLaunchAdVideoCycleOnceFinishNotification";
NSString *const SLLaunchAdVideoPlayFailedNotification = @"SLLaunchAdVideoPlayFailedNotification";

BOOL SLLaunchAdPrefersHomeIndicatorAutoHidden = NO;




@interface NSObject (SLLaunchAd)

- (void)sl_performSelector:(SEL)selector withPrimitiveReturnValue:(void *)returnValue;

- (void)sl_performSelector:(SEL)selector withPrimitiveReturnValue:(void *)returnValue arguments:(void *)firstArgument, ...;

@end

@implementation NSObject (SLLaunchAd)

- (void)sl_performSelector:(SEL)selector withPrimitiveReturnValue:(void *)returnValue {
    [self sl_performSelector:selector withPrimitiveReturnValue:returnValue arguments:nil];
}

- (void)sl_performSelector:(SEL)selector withPrimitiveReturnValue:(void *)returnValue arguments:(void *)firstArgument, ... {
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:selector]];
    [invocation setTarget:self];
    [invocation setSelector:selector];
    
    if (firstArgument) {
        va_list valist;
        va_start(valist, firstArgument);
        [invocation setArgument:firstArgument atIndex:2];// 0->self, 1->_cmd
        
        void *currentArgument;
        NSInteger index = 3;
        while ((currentArgument = va_arg(valist, void *))) {
            [invocation setArgument:currentArgument atIndex:index];
            index++;
        }
        va_end(valist);
    }
    
    [invocation invoke];
    
    if (returnValue) {
        [invocation getReturnValue:returnValue];
    }
}

@end




@implementation SLLaunchAdUtilities


static NSInteger isNotchedScreen = -1;
+ (BOOL)isNotchedScreen {
    if (@available(iOS 11, *)) {
        if (isNotchedScreen < 0) {
            if (@available(iOS 12.0, *)) {
                SEL peripheryInsetsSelector = NSSelectorFromString([NSString stringWithFormat:@"_%@%@", @"periphery", @"Insets"]);
                UIEdgeInsets peripheryInsets = UIEdgeInsetsZero;
                [[UIScreen mainScreen] sl_performSelector:peripheryInsetsSelector withPrimitiveReturnValue:&peripheryInsets];
                if (peripheryInsets.bottom <= 0) {
                    UIWindow *window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
                    peripheryInsets = window.safeAreaInsets;
                    if (peripheryInsets.bottom <= 0) {
                        UIViewController *viewController = [UIViewController new];
                        window.rootViewController = viewController;
                        if (CGRectGetMinY(viewController.view.frame) > 20) {
                            peripheryInsets.bottom = 1;
                        }
                    }
                }
                isNotchedScreen = peripheryInsets.bottom > 0 ? 1 : 0;
            } else {
                isNotchedScreen = [self is58InchScreen] ? 1 : 0;
            }
        }
    } else {
        isNotchedScreen = 0;
    }
    
    return isNotchedScreen > 0;
}


static NSInteger is58InchScreen = -1;
+ (BOOL)is58InchScreen {
    if (is58InchScreen < 0) {
        // Both iPhone XS and iPhone X share the same actual screen sizes, so no need to compare identifiers
        // iPhone XS 和 iPhone X 的物理尺寸是一致的，因此无需比较机器 Identifier
        is58InchScreen = (SL_DEVICE_WIDTH == self.screenSizeFor58Inch.width && SL_DEVICE_HEIGHT == self.screenSizeFor58Inch.height) ? 1 : 0;
    }
    return is58InchScreen > 0;
}


+ (CGSize)screenSizeFor58Inch {
    return CGSizeMake(375, 812);
}

static NSInteger isiPad = -1;
+ (BOOL)isiPad {
    if (isiPad < 0) {
        // [[[UIDevice currentDevice] model] isEqualToString:@"iPad"] 无法判断模拟器 iPad，所以改为以下方式
        isiPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 1 : 0;
    }
    return isiPad > 0;
}


+ (UIEdgeInsets)safeAreaInsetsForDeviceScreen {
    if (![self isNotchedScreen]) {
        return UIEdgeInsetsZero;
    }
    
    if ([self isiPad]) {
        return UIEdgeInsetsMake(0, 0, 20, 0);
    }
    
    UIInterfaceOrientation orientation = UIInterfaceOrientationUnknown;
    if (@available(iOS 13.0, *)) {
        UIWindow *keyWindow = nil;
        for (UIWindow *key in UIApplication.sharedApplication.windows) {
            if (key.isKeyWindow) {
                keyWindow = key;
                break;
            }
        }
        if (keyWindow) {
            orientation = keyWindow.windowScene.interfaceOrientation;
        }
    } else {
        orientation = UIApplication.sharedApplication.statusBarOrientation;
    }
    
    
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            return UIEdgeInsetsMake(44, 0, 34, 0);
            
        case UIInterfaceOrientationPortraitUpsideDown:
            return UIEdgeInsetsMake(34, 0, 44, 0);
            
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            return UIEdgeInsetsMake(0, 44, 21, 44);
            
        case UIInterfaceOrientationUnknown:
        default:
            return UIEdgeInsetsMake(44, 0, 34, 0);
    }
}

@end
