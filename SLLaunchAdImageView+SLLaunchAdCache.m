//
//  SLLaunchAdImageView+SLLaunchAdCache.h
//  YiBanClient
//
//  Created by Sun on 2020/05/29.
//  Copyright © 2019 Qing Class. All rights reserved.
//


#import "SLLaunchAdImageView+SLLaunchAdCache.h"
#import "SLLaunchAdUtilities.h"

#if __has_include(<FLAnimatedImage/FLAnimatedImage.h>)
    #import <FLAnimatedImage/FLAnimatedImage.h>
#else
    #import "FLAnimatedImage.h"
#endif

@implementation SLLaunchAdImageView (SLLaunchAdCache)

- (void)sl_setImageWithURL:(NSURL *)url {
    [self sl_setImageWithURL:url placeholderImage:nil];
}

- (void)sl_setImageWithURL:(NSURL *)url placeholderImage:(nullable UIImage *)placeholder {
    [self sl_setImageWithURL:url placeholderImage:placeholder options:SLLaunchAdImageDefault];
}

-(void)sl_setImageWithURL:(NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(SLLaunchAdImageOptions)options{
    [self sl_setImageWithURL:url placeholderImage:placeholder options:options completed:NULL];
}

- (void)sl_setImageWithURL:(NSURL *)url completed:(nullable SLExternalCompletionBlock)completedBlock {
    [self sl_setImageWithURL:url placeholderImage:nil completed:completedBlock];
}

- (void)sl_setImageWithURL:(NSURL *)url placeholderImage:(nullable UIImage *)placeholder completed:(nullable SLExternalCompletionBlock)completedBlock {
    [self sl_setImageWithURL:url placeholderImage:placeholder options:SLLaunchAdImageDefault completed:completedBlock];
}

-(void)sl_setImageWithURL:(NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(SLLaunchAdImageOptions)options completed:(nullable SLExternalCompletionBlock)completedBlock {
    [self sl_setImageWithURL:url placeholderImage:placeholder gifImageLoopOnce:NO options:options gifImageLoopOnceFinished:nil completed:completedBlock];
}

- (void)sl_setImageWithURL:(NSURL *)url placeholderImage:(nullable UIImage *)placeholder gifImageLoopOnce:(BOOL)gifImageLoopOnce options:(SLLaunchAdImageOptions)options gifImageLoopOnceFinished:(void(^_Nullable)(void))finishedBlock completed:(nullable SLExternalCompletionBlock)completedBlock {
    if (placeholder) self.image = placeholder;
    if (!url) return;
    __weak typeof(self) weakSelf = self;
    [[SLLaunchAdImageManager sharedManager] loadImageWithURL:url options:options progress:nil completed:^(UIImage * _Nullable image,  NSData *_Nullable imageData, NSError * _Nullable error, NSURL * _Nullable imageURL) {
        if(!error){
            if (SL_IS_GIF_DATA(imageData)) {
                weakSelf.image = nil;
                weakSelf.animatedImage = [FLAnimatedImage animatedImageWithGIFData:imageData];
                weakSelf.loopCompletionBlock = ^(NSUInteger loopCountRemaining) {
                    if (gifImageLoopOnce) {
                       [weakSelf stopAnimating];
                        SL_LAUNCH_AD_LOG(@"GIF不循环,播放完成");
                        if (finishedBlock) finishedBlock();
                    }
                };
            } else {
                weakSelf.image = image;
                weakSelf.animatedImage = nil;
            }
        }
        if(completedBlock) completedBlock(image,imageData,error,imageURL);
    }];
}

@end
