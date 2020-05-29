//
//  SLLaunchAdImageView.h
//  YiBanClient
//
//  Created by Sun on 2020/05/29.
//  Copyright © 2019 Qing Class. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

#if __has_include(<FLAnimatedImage/FLAnimatedImage.h>)
    #import <FLAnimatedImage/FLAnimatedImage.h>
#else
    #import "FLAnimatedImage.h"
#endif

#if __has_include(<FLAnimatedImage/FLAnimatedImageView.h>)
    #import <FLAnimatedImage/FLAnimatedImageView.h>
#else
    #import "FLAnimatedImageView.h"
#endif


#pragma mark - image
@interface SLLaunchAdImageView : FLAnimatedImageView

@property (nonatomic, copy) void(^click)(CGPoint point);

@end

#pragma mark - video
@interface SLLaunchAdVideoView : UIView

@property (nonatomic, copy) void(^click)(CGPoint point);
@property (nonatomic, strong) AVPlayerViewController *videoPlayer;
@property (nonatomic, copy)   AVLayerVideoGravity videoGravity;
@property (nonatomic, assign) BOOL videoLoopOnce;
@property (nonatomic, assign) BOOL muted;
@property (nonatomic, strong) NSURL *contentURL;

- (void)stopVideoPlayer;

@end

