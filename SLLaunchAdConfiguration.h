//
//  SLLaunchAdConfiguration.h
//  YiBanClient
//
//  Created by Sun on 2020/05/29.
//  Copyright © 2019 Qing Class. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "SLLaunchAdButton.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "SLLaunchAdImageManager.h"
#import "SLLaunchAdUtilities.h"

NS_ASSUME_NONNULL_BEGIN

/** 显示完成动画时间默认时间 */
static CGFloat const SLLaunchAdCompletionAnimationDefaultDuration = 0.8;

/** 显示完成动画类型 */
typedef NS_ENUM(NSInteger, SLLaunchAdCompletionAnimationType) {
    /** 无动画 */
    SLLaunchAdCompletionAnimationTypeNone = 1,
    /** 普通淡入(default) */
    SLLaunchAdCompletionAnimationTypeFadeIn = 2,
    /** 放大淡入 */
    SLLaunchAdCompletionAnimationTypeZoomInFade = 3,
    /** 左右翻转(类似网易云音乐) */
    SLLaunchAdCompletionAnimationTypeFlipLeftToRight = 4,
    /** 下上翻转 */
    SLLaunchAdCompletionAnimationTypeFlipTopToBottom = 5,
    /** 向上翻页 */
    SLLaunchAdCompletionAnimationTypeFlipOver = 6,
};

#pragma mark - 公共属性
@interface SLLaunchAdConfiguration : NSObject

/** 停留时间(default 5.0 ,单位:秒) */
@property (nonatomic, assign) NSTimeInterval duration;

/** 跳过按钮类型(default SLLaunchAdSkipTypeRoundedRectangleTimeText) */
@property (nonatomic, assign) SLLaunchAdSkipType skipButtonType;

/** 显示完成动画(default SLLaunchAdCompletionAnimationTypeFadeIn) */
@property (nonatomic, assign) SLLaunchAdCompletionAnimationType animationType;

/** 显示完成动画时间(default 0.8 , 单位:秒) */
@property (nonatomic, assign) CGFloat animationDuration;

/** 设置开屏广告的frame(default [UIScreen mainScreen].bounds) */
@property (nonatomic, assign) CGRect frame;

/** 程序从后台恢复时,是否需要展示广告(defailt NO) */
@property (nonatomic, assign) BOOL showEnterForeground;

/** 点击打开页面参数 */
@property (nonatomic, strong) id openModel;

/** 自定义跳过按钮(若定义此视图,将会自定替换系统跳过按钮) */
@property (nonatomic, strong) UIView *customSkipView;

/** 子视图(若定义此属性,这些视图将会被自动添加在广告视图上,frame相对于window) */
@property (nonatomic, copy, nullable) NSArray<UIView *> *subViews;

@end

#pragma mark - 图片广告相关
@interface SLLaunchImageAdConfiguration : SLLaunchAdConfiguration

/** image本地图片名(jpg/gif图片请带上扩展名)或网络图片URL string */
@property (nonatomic, copy) NSString *imageNameOrURLString;

/** 图片广告缩放模式(default UIViewContentModeScaleToFill) */
@property (nonatomic, assign) UIViewContentMode contentMode;

/** 缓存机制(default XHLaunchImageDefault) */
@property (nonatomic, assign) SLLaunchAdImageOptions imageOptions;

/** 设置GIF动图是否只循环播放一次(YES:只播放一次,NO:循环播放,default NO,仅对动图设置有效) */
@property (nonatomic, assign) BOOL gifImageLoopOnce;

+ (SLLaunchImageAdConfiguration *)defaultConfiguration;

@end

#pragma mark - 视频广告相关
@interface SLLaunchVideoAdConfiguration : SLLaunchAdConfiguration

/** video本地名或网络链接URL string */
@property (nonatomic, copy) NSString *videoNameOrURLString;

/** 视频缩放模式(default AVLayerVideoGravityResizeAspectFill) */
@property (nonatomic, copy) AVLayerVideoGravity videoGravity;

/** 设置视频是否只循环播放一次(YES:只播放一次,NO循环播放,default NO) */
@property (nonatomic, assign) BOOL videoLoopOnce;

/** 是否关闭音频(default NO) */
@property (nonatomic, assign) BOOL muted;

+ (SLLaunchVideoAdConfiguration *)defaultConfiguration;

@end

NS_ASSUME_NONNULL_END
