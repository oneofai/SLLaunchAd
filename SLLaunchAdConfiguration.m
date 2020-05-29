//
//  SLLaunchAdConfiguration.m
//  YiBanClient
//
//  Created by Sun on 2020/05/29.
//  Copyright © 2019 Qing Class. All rights reserved.
//

#import "SLLaunchAdConfiguration.h"

#pragma mark - 公共
@implementation SLLaunchAdConfiguration

@end

#pragma mark - 图片广告
@implementation SLLaunchImageAdConfiguration

+ (SLLaunchImageAdConfiguration *)defaultConfiguration{
    //配置广告数据
    SLLaunchImageAdConfiguration *configuration = [SLLaunchImageAdConfiguration new];
    //广告停留时间
    configuration.duration = 5.0;
    //广告frame
    configuration.frame = [UIScreen mainScreen].bounds;
    //设置GIF动图是否只循环播放一次(仅对动图设置有效)
    configuration.gifImageLoopOnce = NO;
    //缓存机制
    configuration.imageOptions = SLLaunchAdImageDefault;
    //图片填充模式
    configuration.contentMode = UIViewContentModeScaleToFill;
    //广告显示完成动画
    configuration.animationType =SLLaunchAdCompletionAnimationTypeFadeIn;
     //显示完成动画时间
    configuration.animationDuration = SLLaunchAdCompletionAnimationDefaultDuration;
    //跳过按钮类型
    configuration.skipButtonType = SLLaunchAdSkipTypeRoundedRectangleTimeText;
    //后台返回时,是否显示广告
    configuration.showEnterForeground = NO;
    return configuration;
}

@end

#pragma mark - 视频广告

@implementation SLLaunchVideoAdConfiguration
+ (SLLaunchVideoAdConfiguration *)defaultConfiguration{
    //配置广告数据
    SLLaunchVideoAdConfiguration *configuration = [SLLaunchVideoAdConfiguration new];
    //广告停留时间
    configuration.duration = 5.0;
    //广告frame
    configuration.frame = [UIScreen mainScreen].bounds;
    //视频填充模式
    configuration.videoGravity = AVLayerVideoGravityResizeAspectFill;
    //是否只循环播放一次
    configuration.videoLoopOnce = NO;
    //广告显示完成动画
    configuration.animationType =SLLaunchAdCompletionAnimationTypeFadeIn;
    //显示完成动画时间
    configuration.animationDuration = SLLaunchAdCompletionAnimationDefaultDuration;
    //跳过按钮类型
    configuration.skipButtonType = SLLaunchAdSkipTypeRoundedRectangleTimeText;
    //后台返回时,是否显示广告
    configuration.showEnterForeground = NO;
    //是否静音播放
    configuration.muted = NO;
    return configuration;
}

@end
