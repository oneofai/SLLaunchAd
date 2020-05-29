//
//  SLLaunchAdUtilities.h
//  YiBanClient
//
//  Created by Sun on 2020/05/29.
//  Copyright © 2019 Qing Class. All rights reserved.
//

#import <UIKit/UIKit.h>


// 屏幕的宽
#ifndef SL_DEVICE_WIDTH
    #define SL_DEVICE_WIDTH MIN([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)
#endif

// 屏幕的高
#ifndef SL_DEVICE_HEIGHT
    #define SL_DEVICE_HEIGHT MAX([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)
#endif

// 是否全面屏
#define SL_IS_NOTCHED_SCREEN [SLLaunchAdUtilities isNotchedScreen]


#define SL_VALIDED_URL_STRING(string)  ([string hasPrefix:@"https://"] || [string hasPrefix:@"http://"]) ? YES:NO


#ifdef DEBUG
#define SL_LAUNCH_AD_LOG(FORMAT, ...) fprintf(stderr,"%s:%d\t%s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define SL_LAUNCH_AD_LOG(...)
#endif

#define SL_IS_GIF_DATA(data)\
({\
BOOL result = NO;\
if(!data) result = NO;\
uint8_t c;\
[data getBytes:&c length:1];\
if(c == 0x47) result = YES;\
(result);\
})

#define SL_IS_VIDEO_PATH(path)\
({\
BOOL result = NO;\
if([path hasSuffix:@".mp4"])  result =  YES;\
(result);\
})

#define SL_FETCH_DATA_USE_FILENAME(name)\
({\
NSData *data = nil;\
NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:nil];\
if([[NSFileManager defaultManager] fileExistsAtPath:path]){\
    data = [NSData dataWithContentsOfFile:path];\
}\
(data);\
})

#define SL_DISPATCH_SOURCE_CANCEL_SAFE(time) if(time)\
{\
dispatch_source_cancel(time);\
time = nil;\
}

#define SL_REMOVE_FROM_SUPERVIEW_SAFE(view) if(view)\
{\
[view removeFromSuperview];\
view = nil;\
}

UIKIT_EXTERN NSString *const SLCacheImageURLStringKey;
UIKIT_EXTERN NSString *const SLCacheVideoURLStringKey;

UIKIT_EXTERN NSString *const SLLaunchAdWaitDataDurationArriveNotification;
UIKIT_EXTERN NSString *const SLLaunchAdDetailPageWillShowNotification;
UIKIT_EXTERN NSString *const SLLaunchAdDetailPageShowFinishNotification;
/** gifImageLoopOnce = YES(GIF不循环)时, GIF动图播放完成通知 */
UIKIT_EXTERN NSString *const SLLaunchAdGIFImageCycleOnceFinishNotification;
/** videoLoopOnce = YES(视频不循环时) ,video播放完成通知 */
UIKIT_EXTERN NSString *const SLLaunchAdVideoCycleOnceFinishNotification;
/** 视频播放失败通知 */
UIKIT_EXTERN NSString *const SLLaunchAdVideoPlayFailedNotification;

UIKIT_EXTERN BOOL SLLaunchAdPrefersHomeIndicatorAutoHidden;


@interface SLLaunchAdUtilities : NSObject


+ (UIEdgeInsets)safeAreaInsetsForDeviceScreen;

+ (BOOL)isNotchedScreen;

+ (CGSize)screenSizeFor58Inch;

+ (BOOL)is58InchScreen;

+ (BOOL)isiPad;


@end


