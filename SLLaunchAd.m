//
//  SLLaunchAd.m
//  YiBanClient
//
//  Created by Sun on 2020/05/29.
//  Copyright © 2019 Qing Class. All rights reserved.
//

#import "SLLaunchAd.h"
#import "SLLaunchAdView.h"
#import "SLLaunchAdImageView+SLLaunchAdCache.h"
#import "SLLaunchAdDownloader.h"
#import "SLLaunchAdCache.h"
#import "SLLaunchAdController.h"

#if __has_include(<FLAnimatedImage/FLAnimatedImage.h>)
    #import <FLAnimatedImage/FLAnimatedImage.h>
#else
    #import "FLAnimatedImage.h"
#endif

typedef NS_ENUM(NSInteger, SLLaunchAdType) {
    SLLaunchAdTypeImage,
    SLLaunchAdTypeVideo
};

static NSInteger defaultWaitDataDuration = 3;
static  SLLaunchSourceType _sourceType = SLLaunchSourceTypeStoryboard;

@interface SLLaunchAd()

@property (nonatomic, assign) SLLaunchAdType launchAdType;
@property (nonatomic, assign) NSInteger waitDataDuration;
@property (nonatomic, strong) SLLaunchImageAdConfiguration *imageAdConfiguration;
@property (nonatomic, strong) SLLaunchVideoAdConfiguration *videoAdConfiguration;

@property (nonatomic, strong) SLLaunchAdButton *skipButton;
@property (nonatomic, strong) SLLaunchAdVideoView *adVideoView;
@property (nonatomic, strong) UIWindow * window;
@property (nonatomic, copy)   dispatch_source_t waitDataTimer;
@property (nonatomic, copy)   dispatch_source_t skipTimer;
@property (nonatomic, assign) BOOL detailPageShowing;
@property (nonatomic, assign) CGPoint clickPoint;
@end

@implementation SLLaunchAd

+ (void)setLaunchSourceType:(SLLaunchSourceType)sourceType {
    _sourceType = sourceType;
}

+ (void)setWaitDataDuration:(NSInteger )waitDataDuration {
    SLLaunchAd *launchAd = [SLLaunchAd shareLaunchAd];
    launchAd.waitDataDuration = waitDataDuration;
}

+ (SLLaunchAd *)imageAdWithImageAdConfiguration:(SLLaunchImageAdConfiguration *)imageAdconfiguration {
    return [SLLaunchAd imageAdWithImageAdConfiguration:imageAdconfiguration delegate:nil];
}

+ (SLLaunchAd *)imageAdWithImageAdConfiguration:(SLLaunchImageAdConfiguration *)imageAdconfiguration delegate:(nullable id<SLLaunchAdDelegate>)delegate {
    SLLaunchAd *launchAd = [SLLaunchAd shareLaunchAd];
    if(delegate) launchAd.delegate = delegate;
    launchAd.imageAdConfiguration = imageAdconfiguration;
    return launchAd;
}

+ (SLLaunchAd *)videoAdWithVideoAdConfiguration:(SLLaunchVideoAdConfiguration *)videoAdconfiguration {
    return [SLLaunchAd videoAdWithVideoAdConfiguration:videoAdconfiguration delegate:nil];
}

+ (SLLaunchAd *)videoAdWithVideoAdConfiguration:(SLLaunchVideoAdConfiguration *)videoAdconfiguration delegate:(nullable id<SLLaunchAdDelegate>)delegate {
    SLLaunchAd *launchAd = [SLLaunchAd shareLaunchAd];
    if(delegate) launchAd.delegate = delegate;
    launchAd.videoAdConfiguration = videoAdconfiguration;
    return launchAd;
}

+ (void)downLoadImageAndCacheWithURLArray:(NSArray<NSURL *> * )urlArray {
    [self downLoadImageAndCacheWithURLArray:urlArray completed:nil];
}

+ (void)downLoadImageAndCacheWithURLArray:(NSArray<NSURL *> * )urlArray completed:(nullable SLLaunchAdBatchDownLoadAndCacheCompletedBlock)completedBlock {
    if(urlArray.count==0) return;
    [[SLLaunchAdDownloader sharedDownloader] downLoadImageAndCacheWithURLArray:urlArray completed:completedBlock];
}

+ (void)downLoadVideoAndCacheWithURLArray:(NSArray<NSURL *> * )urlArray {
    [self downLoadVideoAndCacheWithURLArray:urlArray completed:nil];
}

+ (void)downLoadVideoAndCacheWithURLArray:(NSArray<NSURL *> * )urlArray completed:(nullable SLLaunchAdBatchDownLoadAndCacheCompletedBlock)completedBlock {
    if(urlArray.count==0) return;
    [[SLLaunchAdDownloader sharedDownloader] downLoadVideoAndCacheWithURLArray:urlArray completed:completedBlock];
}

+ (void)removeAndAnimated:(BOOL)animated {
    [[SLLaunchAd shareLaunchAd] removeAndAnimated:animated];
}

+ (BOOL)checkImageInCacheWithURL:(NSURL *)url {
    return [SLLaunchAdCache checkImageInCacheWithURL:url];
}

+ (BOOL)checkVideoInCacheWithURL:(NSURL *)url {
    return [SLLaunchAdCache checkVideoInCacheWithURL:url];
}

+ (void)clearDiskCache {
    [SLLaunchAdCache clearDiskCache];
}

+ (void)clearDiskCacheWithImageUrlArray:(NSArray<NSURL *> *)imageUrlArray {
    [SLLaunchAdCache clearDiskCacheWithImageUrlArray:imageUrlArray];
}

+ (void)clearDiskCacheExceptImageUrlArray:(NSArray<NSURL *> *)exceptImageUrlArray {
    [SLLaunchAdCache clearDiskCacheExceptImageUrlArray:exceptImageUrlArray];
}

+ (void)clearDiskCacheWithVideoUrlArray:(NSArray<NSURL *> *)videoUrlArray {
    [SLLaunchAdCache clearDiskCacheWithVideoUrlArray:videoUrlArray];
}

+ (void)clearDiskCacheExceptVideoUrlArray:(NSArray<NSURL *> *)exceptVideoUrlArray {
    [SLLaunchAdCache clearDiskCacheExceptVideoUrlArray:exceptVideoUrlArray];
}

+ (float)diskCacheSize {
    return [SLLaunchAdCache diskCacheSize];
}

+ (NSString *)launchAdCachePath {
    return [SLLaunchAdCache launchAdCachePath];
}

+ (NSString *)cacheImageURLString {
    return [SLLaunchAdCache getCacheImageUrl];
}

+ (NSString *)cacheVideoURLString {
    return [SLLaunchAdCache getCacheVideoUrl];
}


#pragma mark - private
+ (SLLaunchAd *)shareLaunchAd {
    static SLLaunchAd *instance = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken,^{
        instance = [[SLLaunchAd alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
         __weak typeof(self) weakSelf = self;
        [self setupLaunchAd];
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            [weakSelf setupLaunchAdEnterForeground];
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            [weakSelf removeOnly];
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:SLLaunchAdDetailPageWillShowNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            weakSelf.detailPageShowing = YES;
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:SLLaunchAdDetailPageShowFinishNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            weakSelf.detailPageShowing = NO;
        }];
    }
    return self;
}

- (void)setupLaunchAdEnterForeground {
    switch (_launchAdType) {
        case SLLaunchAdTypeImage:{
            if (!_imageAdConfiguration.showEnterForeground || _detailPageShowing) return;
            [self setupLaunchAd];
            [self setupImageAdForConfiguration:_imageAdConfiguration];
        }
            break;
        case SLLaunchAdTypeVideo:{
            if (!_videoAdConfiguration.showEnterForeground || _detailPageShowing) return;
            [self setupLaunchAd];
            [self setupVideoAdForConfiguration:_videoAdConfiguration];
        }
            break;
        default:
            break;
    }
}

- (void)setupLaunchAd {
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.rootViewController = [SLLaunchAdController new];
    window.rootViewController.view.backgroundColor = [UIColor clearColor];
    window.rootViewController.view.userInteractionEnabled = NO;
    window.windowLevel = UIWindowLevelStatusBar + 1;
    window.hidden = NO;
    window.alpha = 1;
    _window = window;
    /** 添加launchImageView */
    [_window addSubview:[[SLLaunchImageView alloc] initWithSourceType:_sourceType]];
}

/**图片*/
- (void)setupImageAdForConfiguration:(SLLaunchImageAdConfiguration *)configuration {
    if (_window == nil) return;
    [self removeSubViewsExceptLaunchAdImageView];
    SLLaunchAdImageView *adImageView = [[SLLaunchAdImageView alloc] init];
    [_window addSubview:adImageView];
    /** frame */
    if (configuration.frame.size.width>0 && configuration.frame.size.height>0) adImageView.frame = configuration.frame;
    if (configuration.contentMode) adImageView.contentMode = configuration.contentMode;
    /** webImage */
    if (configuration.imageNameOrURLString.length && SL_VALIDED_URL_STRING(configuration.imageNameOrURLString)){
        [SLLaunchAdCache asyncSaveImageUrl:configuration.imageNameOrURLString];
        /** 自设图片 */
        if ([self.delegate respondsToSelector:@selector(launchAd:launchAdImageView:URL:)]) {
            [self.delegate launchAd:self launchAdImageView:adImageView URL:[NSURL URLWithString:configuration.imageNameOrURLString]];
        } else {
            if (!configuration.imageOptions) configuration.imageOptions = SLLaunchAdImageDefault;
            __weak typeof(self) weakSelf = self;
            [adImageView sl_setImageWithURL:[NSURL URLWithString:configuration.imageNameOrURLString] placeholderImage:nil gifImageLoopOnce:configuration.gifImageLoopOnce options:configuration.imageOptions gifImageLoopOnceFinished:^{
                //GIF不循环,播放完成
                [[NSNotificationCenter defaultCenter] postNotificationName:SLLaunchAdGIFImageCycleOnceFinishNotification object:nil userInfo:@{@"imageNameOrURLString":configuration.imageNameOrURLString}];
                
            } completed:^(UIImage *image,NSData *imageData,NSError *error,NSURL *url){
                if (!error) {
                    if ([weakSelf.delegate respondsToSelector:@selector(launchAd:imageDownLoadFinish:imageData:)]) {
                        [weakSelf.delegate launchAd:weakSelf imageDownLoadFinish:image imageData:imageData];
                    }
                }
            }];
            if (configuration.imageOptions == SLLaunchAdImageCacheInBackground) {
                /** 缓存中未有 */
                if (![SLLaunchAdCache checkImageInCacheWithURL:[NSURL URLWithString:configuration.imageNameOrURLString]]) {
                    [self removeAndAnimateDefault]; return; /** 完成显示 */
                }
            }
        }
    } else {
        if(configuration.imageNameOrURLString.length){
            NSData *data = SL_FETCH_DATA_USE_FILENAME(configuration.imageNameOrURLString);
            if (SL_IS_GIF_DATA(data)) {
                FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:data];
                adImageView.animatedImage = image;
                adImageView.image = nil;
                __weak typeof(adImageView) w_adImageView = adImageView;
                adImageView.loopCompletionBlock = ^(NSUInteger loopCountRemaining) {
                    if(configuration.gifImageLoopOnce){
                        [w_adImageView stopAnimating];
                        SL_LAUNCH_AD_LOG(@"GIF不循环,播放完成");
                        [[NSNotificationCenter defaultCenter] postNotificationName:SLLaunchAdGIFImageCycleOnceFinishNotification object:@{@"imageNameOrURLString":configuration.imageNameOrURLString}];
                    }
                };
            } else {
                adImageView.animatedImage = nil;
                adImageView.image = [UIImage imageWithData:data];
            }
        } else {
            SL_LAUNCH_AD_LOG(@"未设置广告图片");
        }
    }
    /** skipButton */
    [self addSkipButtonForConfiguration:configuration];
    [self startSkipDispathTimer];
    /** customView */
    if (configuration.subViews.count > 0)  [self addSubViews:configuration.subViews];
    __weak typeof(self) weakSelf = self;
    adImageView.click = ^(CGPoint point) {
        [weakSelf clickAndPoint:point];
    };
}

- (void) addSkipButtonForConfiguration:(SLLaunchAdConfiguration *)configuration{
    if (!configuration.duration) configuration.duration = 5;
    if (!configuration.skipButtonType) configuration.skipButtonType = SLLaunchAdSkipTypeRoundedRectangleTimeText;
    if (configuration.customSkipView) {
        [_window addSubview:configuration.customSkipView];
    } else {
        if (_skipButton == nil) {
            _skipButton = [[SLLaunchAdButton alloc] initWithSkipType:configuration.skipButtonType];
            _skipButton.hidden = YES;
            [_skipButton addTarget:self action:@selector(skipButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        }
        [_window addSubview:_skipButton];
        [_skipButton setTitleWithSkipType:configuration.skipButtonType duration:configuration.duration];
    }
}

/**视频*/
- (void)setupVideoAdForConfiguration:(SLLaunchVideoAdConfiguration *)configuration{
    if (_window ==nil) return;
    [self removeSubViewsExceptLaunchAdImageView];
    if (!_adVideoView) {
        _adVideoView = [[SLLaunchAdVideoView alloc] init];
    }
    [_window addSubview:_adVideoView];
    /** frame */
    if (configuration.frame.size.width>0&&configuration.frame.size.height>0) _adVideoView.frame = configuration.frame;
    if (configuration.videoGravity) _adVideoView.videoGravity = configuration.videoGravity;
    _adVideoView.videoLoopOnce = configuration.videoLoopOnce;
    if (configuration.videoLoopOnce) {
        [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            SL_LAUNCH_AD_LOG(@"video不循环,播放完成");
            [[NSNotificationCenter defaultCenter] postNotificationName:SLLaunchAdVideoCycleOnceFinishNotification object:nil userInfo:@{@"videoNameOrURLString":configuration.videoNameOrURLString}];
        }];
    }
    /** video 数据源 */
    if (configuration.videoNameOrURLString.length && SL_VALIDED_URL_STRING(configuration.videoNameOrURLString)) {
        [SLLaunchAdCache asyncSaveVideoUrl:configuration.videoNameOrURLString];
        NSURL *pathURL = [SLLaunchAdCache getCacheVideoWithURL:[NSURL URLWithString:configuration.videoNameOrURLString]];
        if (pathURL) {
            if ([self.delegate respondsToSelector:@selector(launchAd:videoDownLoadFinish:)]) {
                [self.delegate launchAd:self videoDownLoadFinish:pathURL];
            }
            _adVideoView.contentURL = pathURL;
            _adVideoView.muted = configuration.muted;
            [_adVideoView.videoPlayer.player play];
        } else {
            __weak typeof(self) weakSelf = self;
            [[SLLaunchAdDownloader sharedDownloader] downloadVideoWithURL:[NSURL URLWithString:configuration.videoNameOrURLString] progress:^(unsigned long long total, unsigned long long current) {
                if ([weakSelf.delegate respondsToSelector:@selector(launchAd:videoDownLoadProgress:total:current:)]) {
                    [weakSelf.delegate launchAd:weakSelf videoDownLoadProgress:current/(float)total total:total current:current];
                }
            }  completed:^(NSURL * _Nullable location, NSError * _Nullable error){
                if(!error){
                    if ([weakSelf.delegate respondsToSelector:@selector(launchAd:videoDownLoadFinish:)]){
                        [weakSelf.delegate launchAd:weakSelf videoDownLoadFinish:location];
                    }
                }
            }];
            /***视频缓存,提前显示完成 */
            [self removeAndAnimateDefault]; return;
        }
    } else {
        if (configuration.videoNameOrURLString.length) {
            NSURL *pathURL = nil;
            NSURL *cachePathURL = [[NSURL alloc] initFileURLWithPath:[SLLaunchAdCache videoPathWithFileName:configuration.videoNameOrURLString]];
            //若本地视频未在沙盒缓存文件夹中
            if (![SLLaunchAdCache checkVideoInCacheWithFileName:configuration.videoNameOrURLString]) {
                /***如果不在沙盒文件夹中则将其复制一份到沙盒缓存文件夹中/下次直接取缓存文件夹文件,加快文件查找速度 */
                NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:configuration.videoNameOrURLString withExtension:nil];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [[NSFileManager defaultManager] copyItemAtURL:bundleURL toURL:cachePathURL error:nil];
                });
                pathURL = bundleURL;
            } else {
                pathURL = cachePathURL;
            }
            
            if (pathURL) {
                if ([self.delegate respondsToSelector:@selector(launchAd:videoDownLoadFinish:)]) {
                    [self.delegate launchAd:self videoDownLoadFinish:pathURL];
                }
                _adVideoView.contentURL = pathURL;
                _adVideoView.muted = configuration.muted;
                [_adVideoView.videoPlayer.player play];
                
            }else{
                SL_LAUNCH_AD_LOG(@"Error:广告视频未找到,请检查名称是否有误!");
            }
        }else{
            SL_LAUNCH_AD_LOG(@"未设置广告视频");
        }
    }
    /** skipButton */
    [self addSkipButtonForConfiguration:configuration];
    [self startSkipDispathTimer];
    /** customView */
    if (configuration.subViews.count > 0) [self addSubViews:configuration.subViews];
    __weak typeof(self) weakSelf = self;
    _adVideoView.click = ^(CGPoint point) {
        [weakSelf clickAndPoint:point];
    };
}

#pragma mark - add subViews
- (void)addSubViews:(NSArray *)subViews {
    [subViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        [_window addSubview:view];
    }];
}

#pragma mark - set
- (void)setImageAdConfiguration:(SLLaunchImageAdConfiguration *)imageAdConfiguration {
    _imageAdConfiguration = imageAdConfiguration;
    _launchAdType = SLLaunchAdTypeImage;
    [self setupImageAdForConfiguration:imageAdConfiguration];
}

- (void)setVideoAdConfiguration:(SLLaunchVideoAdConfiguration *)videoAdConfiguration {
    _videoAdConfiguration = videoAdConfiguration;
    _launchAdType = SLLaunchAdTypeVideo;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(CGFLOAT_MIN * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setupVideoAdForConfiguration:videoAdConfiguration];
    });
}

- (void)setWaitDataDuration:(NSInteger)waitDataDuration {
    _waitDataDuration = waitDataDuration;
    /** 数据等待 */
    [self startWaitDataDispathTiemr];
}

#pragma mark - Action
- (void)skipButtonClick:(SLLaunchAdButton *)button {
    if ([self.delegate respondsToSelector:@selector(launchAd:clickSkipButton:)]) {
        [self.delegate launchAd:self clickSkipButton:button];
    }
    [self removeAndAnimated:YES];
}

- (void)removeAndAnimated:(BOOL)animated{
    if (animated) {
        [self removeAndAnimate];
    } else {
        [self remove];
    }
}

- (void)clickAndPoint:(CGPoint)point {
    self.clickPoint = point;
    SLLaunchAdConfiguration * configuration = [self commonConfiguration];
    if ([self.delegate respondsToSelector:@selector(launchAd:clickAtOpenModel:clickPoint:)]) {
        BOOL status =  [self.delegate launchAd:self clickAtOpenModel:configuration.openModel clickPoint:point];
        if(status) [self removeAndAnimateDefault];
    }
}

- (SLLaunchAdConfiguration *)commonConfiguration {
    SLLaunchAdConfiguration *configuration = nil;
    switch (_launchAdType) {
        case SLLaunchAdTypeVideo:
            configuration = _videoAdConfiguration;
            break;
        case SLLaunchAdTypeImage:
            configuration = _imageAdConfiguration;
            break;
        default:
            break;
    }
    return configuration;
}

- (void)startWaitDataDispathTiemr {
    __block NSInteger duration = defaultWaitDataDuration;
    if (_waitDataDuration) duration = _waitDataDuration;
    _waitDataTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    NSTimeInterval period = 1.0;
    __weak __typeof(self)weakSelf = self;
    dispatch_source_set_timer(_waitDataTimer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_waitDataTimer, ^{
        if (duration==0) {
            SL_DISPATCH_SOURCE_CANCEL_SAFE(weakSelf.waitDataTimer);
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:SLLaunchAdWaitDataDurationArriveNotification object:nil];
                [self remove];
                return ;
            });
        }
        duration--;
    });
    dispatch_resume(_waitDataTimer);
}

- (void)startSkipDispathTimer {
    SLLaunchAdConfiguration *configuration = [self commonConfiguration];
    SL_DISPATCH_SOURCE_CANCEL_SAFE(_waitDataTimer);
    if (!configuration.skipButtonType) configuration.skipButtonType = SLLaunchAdSkipTypeRoundedRectangleTimeText;//默认
    __block NSTimeInterval duration = 5;//默认
    if (configuration.duration) duration = configuration.duration;
    if (configuration.skipButtonType == SLLaunchAdSkipTypeRoundedProgressTime || configuration.skipButtonType == SLLaunchAdSkipTypeRoundedProgressText){
        [_skipButton startRoundDispathTimerWithDuration:duration];
    }
    
    __weak __typeof(self)weakSelf = self;
    NSTimeInterval period = 1.0;
    _skipTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    dispatch_source_set_timer(_skipTimer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_skipTimer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakSelf.delegate respondsToSelector:@selector(launchAd:customSkipView:duration:)]) {
                [weakSelf.delegate launchAd:weakSelf customSkipView:configuration.customSkipView duration:duration];
            }
            if (!configuration.customSkipView){
                [weakSelf.skipButton setTitleWithSkipType:configuration.skipButtonType duration:duration];
            }
            if (duration == 0) {
                SL_DISPATCH_SOURCE_CANCEL_SAFE(weakSelf.skipTimer);
                [self removeAndAnimate]; return ;
            }
            duration--;
        });
    });
    dispatch_resume(_skipTimer);
}

- (void)removeAndAnimate {
    
    SLLaunchAdConfiguration * configuration = [self commonConfiguration];
    CGFloat duration = SLLaunchAdCompletionAnimationDefaultDuration;
    if(configuration.animationDuration>0) duration = configuration.animationDuration;
    switch (configuration.animationType) {
        case SLLaunchAdCompletionAnimationTypeNone:{
            [self remove];
        }
            break;
        case SLLaunchAdCompletionAnimationTypeFadeIn:{
            [self removeAndAnimateDefault];
        }
            break;
        case SLLaunchAdCompletionAnimationTypeZoomInFade:{
            [UIView transitionWithView:_window duration:duration options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.window.transform = CGAffineTransformMakeScale(1.5, 1.5);
                self.window.alpha = 0;
            } completion:^(BOOL finished) {
                [self remove];
            }];
        }
            break;
        case SLLaunchAdCompletionAnimationTypeFlipLeftToRight:{
            [UIView transitionWithView:_window duration:duration options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                self.window.alpha = 0;
            } completion:^(BOOL finished) {
                [self remove];
            }];
        }
            break;
        case SLLaunchAdCompletionAnimationTypeFlipTopToBottom:{
            [UIView transitionWithView:_window duration:duration options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
                self.window.alpha = 0;
            } completion:^(BOOL finished) {
                [self remove];
            }];
        }
            break;
        case SLLaunchAdCompletionAnimationTypeFlipOver:{
            [UIView transitionWithView:_window duration:duration options:UIViewAnimationOptionTransitionCurlUp animations:^{
                self.window.alpha = 0;
            } completion:^(BOOL finished) {
                [self remove];
            }];
        }
            break;
        default:{
            [self removeAndAnimateDefault];
        }
            break;
    }
}

- (void)removeAndAnimateDefault {
    SLLaunchAdConfiguration * configuration = [self commonConfiguration];
    CGFloat duration = SLLaunchAdCompletionAnimationDefaultDuration;
    if (configuration.animationDuration>0) duration = configuration.animationDuration;
    [UIView transitionWithView:_window duration:duration options:UIViewAnimationOptionTransitionNone animations:^{
        self.window.alpha = 0;
    } completion:^(BOOL finished) {
        [self remove];
    }];
}

- (void)removeOnly {
    SL_DISPATCH_SOURCE_CANCEL_SAFE(_waitDataTimer)
    SL_DISPATCH_SOURCE_CANCEL_SAFE(_skipTimer)
    SL_REMOVE_FROM_SUPERVIEW_SAFE(_skipButton)
    if (_launchAdType==SLLaunchAdTypeVideo){
        if(_adVideoView){
            [_adVideoView stopVideoPlayer];
            SL_REMOVE_FROM_SUPERVIEW_SAFE(_adVideoView)
        }
    }
    if (_window) {
        [_window.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            SL_REMOVE_FROM_SUPERVIEW_SAFE(obj)
        }];
        _window.hidden = YES;
        _window = nil;
    }
}

- (void) remove {
    [self removeOnly];
    if ([self.delegate respondsToSelector:@selector(launchAdShowFinish:)]) {
        [self.delegate launchAdShowFinish:self];
    }
}

- (void)removeSubViewsExceptLaunchAdImageView {
    [_window.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(![obj isKindOfClass:[SLLaunchImageView class]]){
            SL_REMOVE_FROM_SUPERVIEW_SAFE(obj)
        }
    }];
}

@end
