//
//  SLLaunchAdDownloader.m
//  YiBanClient
//
//  Created by Sun on 2020/05/29.
//  Copyright © 2019 Qing Class. All rights reserved.
//


#import "SLLaunchAdDownloader.h"
#import "SLLaunchAdCache.h"
#import "SLLaunchAdUtilities.h"

#if __has_include(<FLAnimatedImage/FLAnimatedImage.h>)
    #import <FLAnimatedImage/FLAnimatedImage.h>
#else
    #import "FLAnimatedImage.h"
#endif

#pragma mark - SLLaunchAdDownload

@interface SLLaunchAdDownload()

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, assign) unsigned long long totalLength;
@property (nonatomic, assign) unsigned long long currentLength;
@property (nonatomic, copy)   SLLaunchAdDownloadProgressBlock progressBlock;
@property (nonatomic, strong) NSURL *url;

@end

@implementation SLLaunchAdDownload

@end

#pragma mark -  SLLaunchAdImageDownload
@interface SLLaunchAdImageDownload() <NSURLSessionDownloadDelegate, NSURLSessionTaskDelegate>

@property (nonatomic, copy ) SLLaunchAdDownloadImageCompletedBlock completedBlock;

@end

@implementation SLLaunchAdImageDownload

- (instancetype)initWithURL:(nonnull NSURL *)url delegateQueue:(nonnull NSOperationQueue *)queue progress:(nullable SLLaunchAdDownloadProgressBlock)progressBlock completed:(nullable SLLaunchAdDownloadImageCompletedBlock)completedBlock {
    self = [super init];
    if (self) {
        self.url = url;
        self.progressBlock = progressBlock;
        self.completedBlock = completedBlock;
        NSURLSessionConfiguration * sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfiguration.timeoutIntervalForRequest = 15.0;
        self.session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                     delegate:self
                                                delegateQueue:queue];
        self.downloadTask =  [self.session downloadTaskWithRequest:[NSURLRequest requestWithURL:url]];
        [self.downloadTask resume];
    }
    return self;
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
                              didFinishDownloadingToURL:(NSURL *)location {
    
    NSData *data = [NSData dataWithContentsOfURL:location];
    UIImage *image = [UIImage imageWithData:data];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.completedBlock) {
            self.completedBlock(image,data, nil);
            // 防止重复调用
            self.completedBlock = nil;
        }
        //下载完成回调
        if ([self.delegate respondsToSelector:@selector(downloadFinishWithURL:)]) {
            [self.delegate downloadFinishWithURL:self.url];
        }
    });
    //销毁
    [self.session invalidateAndCancel];
    self.session = nil;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    self.currentLength = totalBytesWritten;
    self.totalLength = totalBytesExpectedToWrite;
    if (self.progressBlock) {
        self.progressBlock(self.totalLength, self.currentLength);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error){
        SL_LAUNCH_AD_LOG(@"error = %@",error);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.completedBlock) {
                self.completedBlock(nil,nil, error);
            }
            self.completedBlock = nil;
        });
    }
}

// 处理 HTTPS 请求
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {
    NSURLProtectionSpace *protectionSpace = challenge.protectionSpace;
    if ([protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        SecTrustRef serverTrust = protectionSpace.serverTrust;
        completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:serverTrust]);
    } else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

@end

#pragma makr - SLLaunchAdVideoDownload

@interface SLLaunchAdVideoDownload() <NSURLSessionDownloadDelegate, NSURLSessionTaskDelegate>

@property (nonatomic, copy) SLLaunchAdDownloadVideoCompletedBlock completedBlock;

@end

@implementation SLLaunchAdVideoDownload

- (instancetype)initWithURL:(nonnull NSURL *)url delegateQueue:(nonnull NSOperationQueue *)queue progress:(nullable SLLaunchAdDownloadProgressBlock)progressBlock completed:(nullable SLLaunchAdDownloadVideoCompletedBlock)completedBlock {
    self = [super init];
    if (self) {
        self.url = url;
        self.progressBlock = progressBlock;
        _completedBlock = completedBlock;
        NSURLSessionConfiguration * sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfiguration.timeoutIntervalForRequest = 15.0;
        self.session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                     delegate:self
                                                delegateQueue:queue];
        self.downloadTask =  [self.session downloadTaskWithRequest:[NSURLRequest requestWithURL:url]];
        [self.downloadTask resume];
    }
    return self;
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    NSError *error=nil;
    NSURL *toURL = [NSURL fileURLWithPath:[SLLaunchAdCache videoPathWithURL:self.url]];

    [[NSFileManager defaultManager] copyItemAtURL:location toURL:toURL error:&error];//复制到缓存目录

    if(error)  SL_LAUNCH_AD_LOG(@"error = %@",error);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.completedBlock) {
            if(!error){
                self.completedBlock(toURL,nil);
            }else{
                self.completedBlock(nil,error);
            }
            // 防止重复调用
            self.completedBlock = nil;
        }
        //下载完成回调
        if ([self.delegate respondsToSelector:@selector(downloadFinishWithURL:)]) {
            [self.delegate downloadFinishWithURL:self.url];
        }
    });
    [self.session invalidateAndCancel];
    self.session = nil;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    self.currentLength = totalBytesWritten;
    self.totalLength = totalBytesExpectedToWrite;
    if (self.progressBlock) {
        self.progressBlock(self.totalLength, self.currentLength);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error){
        SL_LAUNCH_AD_LOG(@"error = %@",error);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.completedBlock) {
                self.completedBlock(nil, error);
            }
            self.completedBlock = nil;
        });
    }
}
@end

#pragma mark - SLLaunchAdDownloader

@interface SLLaunchAdDownloader() <SLLaunchAdDownloadDelegate>

@property (nonatomic, strong, nonnull) NSOperationQueue *downloadImageQueue;

@property (nonatomic, strong, nonnull) NSOperationQueue *downloadVideoQueue;

@property (nonatomic, strong) NSMutableDictionary *allDownloadDict;

@end

@implementation SLLaunchAdDownloader

+ (instancetype)sharedDownloader {
    static SLLaunchAdDownloader *instance = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken,^{
        instance = [[SLLaunchAdDownloader alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _downloadImageQueue = [NSOperationQueue new];
        _downloadImageQueue.maxConcurrentOperationCount = 6;
        _downloadImageQueue.name = @"com.it7090.XHLaunchAdDownloadImageQueue";
        _downloadVideoQueue = [NSOperationQueue new];
        _downloadVideoQueue.maxConcurrentOperationCount = 3;
        _downloadVideoQueue.name = @"com.it7090.XHLaunchAdDownloadVideoQueue";
        SL_LAUNCH_AD_LOG(@"XHLaunchAdCachePath:%@",[SLLaunchAdCache launchAdCachePath]);
    }
    return self;
}

- (void)downloadImageWithURL:(nonnull NSURL *)url progress:(nullable SLLaunchAdDownloadProgressBlock)progressBlock completed:(nullable SLLaunchAdDownloadImageCompletedBlock)completedBlock {
    NSString *key = [self keyWithURL:url];
    if (self.allDownloadDict[key]) return;
    SLLaunchAdImageDownload * download = [[SLLaunchAdImageDownload alloc] initWithURL:url delegateQueue:_downloadImageQueue progress:progressBlock completed:completedBlock];
    download.delegate = self;
    [self.allDownloadDict setObject:download forKey:key];
}

- (void)downloadImageAndCacheWithURL:(nonnull NSURL *)url completed:(void(^)(BOOL result))completedBlock {
    if (url == nil) {
         if (completedBlock) completedBlock(NO);
         return;
    }
    [self downloadImageWithURL:url progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error) {
        if (error) {
            if (completedBlock) completedBlock(NO);
        } else {
            [SLLaunchAdCache asyncSaveImageData:data imageURL:url completed:^(BOOL result, NSURL * _Nonnull URL) {
                if (completedBlock) completedBlock(result);
            }];
        }
    }];
}

- (void)downLoadImageAndCacheWithURLArray:(NSArray<NSURL *> *)urlArray {
    [self downLoadImageAndCacheWithURLArray:urlArray completed:nil];
}

- (void)downLoadImageAndCacheWithURLArray:(nonnull NSArray <NSURL *> * )urlArray completed:(nullable SLLaunchAdBatchDownLoadAndCacheCompletedBlock)completedBlock {
    if(urlArray.count==0) return;
    __block NSMutableArray * resultArray = [[NSMutableArray alloc] init];
    dispatch_group_t downLoadGroup = dispatch_group_create();
    [urlArray enumerateObjectsUsingBlock:^(NSURL *url, NSUInteger idx, BOOL *stop) {
        if (![SLLaunchAdCache checkImageInCacheWithURL:url]) {
            dispatch_group_enter(downLoadGroup);
            [self downloadImageAndCacheWithURL:url completed:^(BOOL result) {
                dispatch_group_leave(downLoadGroup);
                [resultArray addObject:@{@"url":url.absoluteString,@"result":@(result)}];
            }];
        } else {
          [resultArray addObject:@{@"url":url.absoluteString,@"result":@(YES)}];
        }
    }];
    dispatch_group_notify(downLoadGroup, dispatch_get_main_queue(), ^{
        if(completedBlock) completedBlock(resultArray);
    });
}

- (void)downloadVideoWithURL:(nonnull NSURL *)url progress:(nullable SLLaunchAdDownloadProgressBlock)progressBlock completed:(nullable SLLaunchAdDownloadVideoCompletedBlock)completedBlock {
    NSString *key = [self keyWithURL:url];
    if (self.allDownloadDict[key]) return;
    SLLaunchAdVideoDownload * download = [[SLLaunchAdVideoDownload alloc] initWithURL:url delegateQueue:_downloadVideoQueue progress:progressBlock completed:completedBlock];
    download.delegate = self;
    [self.allDownloadDict setObject:download forKey:key];
}

- (void)downloadVideoAndCacheWithURL:(nonnull NSURL *)url completed:(void(^)(BOOL result))completedBlock {
    if (url == nil) {
        if(completedBlock) completedBlock(NO);
        return;
    }
    [self downloadVideoWithURL:url progress:nil completed:^(NSURL * _Nullable location, NSError * _Nullable error) {
        if (error) {
            if(completedBlock) completedBlock(NO);
        } else {
            if (completedBlock) completedBlock(YES);
        }
    }];
}

- (void)downLoadVideoAndCacheWithURLArray:(nonnull NSArray <NSURL *> * )urlArray{
    [self downLoadVideoAndCacheWithURLArray:urlArray completed:nil];
}

- (void)downLoadVideoAndCacheWithURLArray:(nonnull NSArray <NSURL *> * )urlArray completed:(nullable SLLaunchAdBatchDownLoadAndCacheCompletedBlock)completedBlock {
    if (urlArray.count == 0) return;
    __block NSMutableArray * resultArray = [[NSMutableArray alloc] init];
    dispatch_group_t downLoadGroup = dispatch_group_create();
    [urlArray enumerateObjectsUsingBlock:^(NSURL *url, NSUInteger idx, BOOL *stop) {
        if (![SLLaunchAdCache checkVideoInCacheWithURL:url]) {
             dispatch_group_enter(downLoadGroup);
            [self downloadVideoAndCacheWithURL:url completed:^(BOOL result) {
               dispatch_group_leave(downLoadGroup);
                [resultArray addObject:@{@"url":url.absoluteString,@"result":@(result)}];
            }];
        } else {
           [resultArray addObject:@{@"url":url.absoluteString,@"result":@(YES)}];
        }
    }];
    dispatch_group_notify(downLoadGroup, dispatch_get_main_queue(), ^{
        if (completedBlock) completedBlock(resultArray);
    });
}

- (NSMutableDictionary *)allDownloadDict {
    if (!_allDownloadDict) {
        _allDownloadDict = [[NSMutableDictionary alloc] init];
    }
    return _allDownloadDict;
}

- (void)downloadFinishWithURL:(NSURL *)url {
    [self.allDownloadDict removeObjectForKey:[self keyWithURL:url]];
}

- (NSString *)keyWithURL:(NSURL *)url {
    return [SLLaunchAdCache md5String:url.absoluteString];
}

@end

