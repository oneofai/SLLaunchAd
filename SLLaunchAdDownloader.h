//
//  SLLaunchAdDownloader.h
//  YiBanClient
//
//  Created by Sun on 2020/05/29.
//  Copyright © 2019 Qing Class. All rights reserved.
//


#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark - SLLaunchAdDownload

typedef void(^SLLaunchAdDownloadProgressBlock)(unsigned long long total, unsigned long long current);

typedef void(^SLLaunchAdDownloadImageCompletedBlock)(UIImage *_Nullable image, NSData * _Nullable data, NSError * _Nullable error);

typedef void(^SLLaunchAdDownloadVideoCompletedBlock)(NSURL * _Nullable location, NSError * _Nullable error);

typedef void(^SLLaunchAdBatchDownLoadAndCacheCompletedBlock) (NSArray * _Nonnull completedArray);

@protocol SLLaunchAdDownloadDelegate <NSObject>

- (void)downloadFinishWithURL:(nonnull NSURL *)url;

@end

@interface SLLaunchAdDownload : NSObject

@property (nonatomic, weak, nullable) id<SLLaunchAdDownloadDelegate> delegate;

@end

@interface SLLaunchAdImageDownload : SLLaunchAdDownload

@end

@interface SLLaunchAdVideoDownload : SLLaunchAdDownload

@end

#pragma mark - SLLaunchAdDownloader
@interface SLLaunchAdDownloader : NSObject

+ (instancetype )sharedDownloader;

- (void)downloadImageWithURL:(nonnull NSURL *)url progress:(nullable SLLaunchAdDownloadProgressBlock)progressBlock completed:(nullable SLLaunchAdDownloadImageCompletedBlock)completedBlock;

- (void)downLoadImageAndCacheWithURLArray:(nonnull NSArray <NSURL *> * )urlArray;
- (void)downLoadImageAndCacheWithURLArray:(nonnull NSArray <NSURL *> * )urlArray completed:(nullable SLLaunchAdBatchDownLoadAndCacheCompletedBlock)completedBlock;

- (void)downloadVideoWithURL:(nonnull NSURL *)url progress:(nullable SLLaunchAdDownloadProgressBlock)progressBlock completed:(nullable SLLaunchAdDownloadVideoCompletedBlock)completedBlock;

- (void)downLoadVideoAndCacheWithURLArray:(nonnull NSArray <NSURL *> * )urlArray;
- (void)downLoadVideoAndCacheWithURLArray:(nonnull NSArray <NSURL *> * )urlArray completed:(nullable SLLaunchAdBatchDownLoadAndCacheCompletedBlock)completedBlock;

@end

NS_ASSUME_NONNULL_END
