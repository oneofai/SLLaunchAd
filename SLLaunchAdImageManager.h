//
//  SLLaunchAdImageManager.h
//  YiBanClient
//
//  Created by Sun on 2020/05/29.
//  Copyright © 2019 Qing Class. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLLaunchAdDownloader.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, SLLaunchAdImageOptions) {
    /** 有缓存,读取缓存,不重新下载,没缓存先下载,并缓存 */
    SLLaunchAdImageDefault = 1 << 0,
    /** 只下载,不缓存 */
    SLLaunchAdImageOnlyLoad = 1 << 1,
    /** 先读缓存,再下载刷新图片和缓存 */
    SLLaunchAdImageRefreshCached = 1 << 2 ,
    /** 后台缓存本次不显示,缓存OK后下次再显示(建议使用这种方式)*/
    SLLaunchAdImageCacheInBackground = 1 << 3
};

typedef void(^SLExternalCompletionBlock)(UIImage * _Nullable image,NSData * _Nullable imageData, NSError * _Nullable error, NSURL * _Nullable imageURL);

@interface SLLaunchAdImageManager : NSObject

+ (instancetype )sharedManager;
- (void)loadImageWithURL:(nullable NSURL *)url options:(SLLaunchAdImageOptions)options progress:(nullable SLLaunchAdDownloadProgressBlock)progressBlock completed:(nullable SLExternalCompletionBlock)completedBlock;

@end

NS_ASSUME_NONNULL_END
