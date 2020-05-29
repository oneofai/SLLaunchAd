//
//  SLLaunchAdImageManager.m
//  YiBanClient
//
//  Created by Sun on 2020/05/29.
//  Copyright © 2019 Qing Class. All rights reserved.
//

#import "SLLaunchAdImageManager.h"
#import "SLLaunchAdCache.h"

@interface SLLaunchAdImageManager()

@property(nonatomic,strong) SLLaunchAdDownloader *downloader;
@end

@implementation SLLaunchAdImageManager

+ (instancetype)sharedManager{
    static SLLaunchAdImageManager *instance = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken,^{
        instance = [[SLLaunchAdImageManager alloc] init];
        
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _downloader = [SLLaunchAdDownloader sharedDownloader];
    }
    return self;
}

- (void)loadImageWithURL:(nullable NSURL *)url options:(SLLaunchAdImageOptions)options progress:(nullable SLLaunchAdDownloadProgressBlock)progressBlock completed:(nullable SLExternalCompletionBlock)completedBlock {
    if (!options) options = SLLaunchAdImageDefault;
    if (options & SLLaunchAdImageOnlyLoad){
        [_downloader downloadImageWithURL:url progress:progressBlock completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error) {
            if (completedBlock) completedBlock(image,data,error,url);
        }];
    } else if (options & SLLaunchAdImageRefreshCached){
        NSData *imageData = [SLLaunchAdCache getCacheImageDataWithURL:url];
        UIImage *image =  [UIImage imageWithData:imageData];
        if (image && completedBlock) completedBlock(image,imageData,nil,url);
        [_downloader downloadImageWithURL:url progress:progressBlock completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error) {
            if(completedBlock) completedBlock(image,data,error,url);
            [SLLaunchAdCache asyncSaveImageData:data imageURL:url completed:nil];
        }];
    } else if (options & SLLaunchAdImageCacheInBackground){
        NSData *imageData = [SLLaunchAdCache getCacheImageDataWithURL:url];
        UIImage *image =  [UIImage imageWithData:imageData];
        if (image && completedBlock){
            completedBlock(image,imageData,nil,url);
        } else {
            [_downloader downloadImageWithURL:url progress:progressBlock completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error) {
                [SLLaunchAdCache asyncSaveImageData:data imageURL:url completed:nil];
            }];
        }
    } else {//default
        NSData *imageData = [SLLaunchAdCache getCacheImageDataWithURL:url];
        UIImage *image =  [UIImage imageWithData:imageData];
        if (image && completedBlock){
            completedBlock(image,imageData,nil,url);
        } else {
            [_downloader downloadImageWithURL:url progress:progressBlock completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error) {
                if(completedBlock) completedBlock(image,data,error,url);
                [SLLaunchAdCache asyncSaveImageData:data imageURL:url completed:nil];
            }];
        }
    }
}

@end
