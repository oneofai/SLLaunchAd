//
//  SLLaunchAdImageView+SLLaunchAdCache.h
//  YiBanClient
//
//  Created by Sun on 2020/05/29.
//  Copyright © 2019 Qing Class. All rights reserved.
//


#import "SLLaunchAdView.h"
#import "SLLaunchAdImageManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface SLLaunchAdImageView (SLLaunchAdCache)

/**
 设置url图片

 @param url 图片url
 */
- (void)sl_setImageWithURL:(NSURL *)url;

/**
 设置url图片

 @param url 图片url
 @param placeholder 占位图
 */
- (void)sl_setImageWithURL:(NSURL *)url placeholderImage:(nullable UIImage *)placeholder;

/**
 设置url图片

 @param url 图片url
 @param placeholder 占位图
 @param options SLLaunchAdImageOptions
 */
- (void)sl_setImageWithURL:(NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(SLLaunchAdImageOptions)options;

/**
 设置url图片

 @param url 图片url
 @param placeholder 占位图
 @param completedBlock SLExternalCompletionBlock
 */
- (void)sl_setImageWithURL:(NSURL *)url placeholderImage:(nullable UIImage *)placeholder completed:(nullable SLExternalCompletionBlock)completedBlock;

/**
 设置url图片

 @param url 图片url
 @param completedBlock SLExternalCompletionBlock
 */
- (void)sl_setImageWithURL:(NSURL *)url completed:(nullable SLExternalCompletionBlock)completedBlock;


/**
 设置url图片

 @param url 图片url
 @param placeholder 占位图
 @param options SLLaunchAdImageOptions
 @param completedBlock SLExternalCompletionBlock
 */
- (void)sl_setImageWithURL:(NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(SLLaunchAdImageOptions)options completed:(nullable SLExternalCompletionBlock)completedBlock;

/**
 设置url图片

 @param url 图片url
 @param placeholder 占位图
 @param gifImageLoopOnce gif是否只循环播放一次
 @param options SLLaunchAdImageOptions
 @param gifImageLoopOnceFinished gif播放完回调(gifImageLoopOnce = YES 有效)
 @param completedBlock SLExternalCompletionBlock
 */
- (void)sl_setImageWithURL:(NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
          gifImageLoopOnce:(BOOL)gifImageLoopOnce
                   options:(SLLaunchAdImageOptions)options
  gifImageLoopOnceFinished:(void(^_Nullable)(void))finishedBlock
                 completed:(nullable SLExternalCompletionBlock)completedBlock ;

@end

NS_ASSUME_NONNULL_END
