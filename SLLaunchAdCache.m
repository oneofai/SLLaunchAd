//
//  SLLaunchAdCache.m
//  YiBanClient
//
//  Created by Sun on 2020/05/29.
//  Copyright © 2019 Qing Class. All rights reserved.
//

#import "SLLaunchAdCache.h"
#import <CommonCrypto/CommonDigest.h>
#import "SLLaunchAdUtilities.h"

@implementation SLLaunchAdCache

+ (UIImage *)getCacheImageWithURL:(NSURL *)url {
    if (url==nil) return nil;
    NSData *data = [NSData dataWithContentsOfFile:[self imagePathWithURL:url]];
    return [UIImage imageWithData:data];
}

+ (NSData *)getCacheImageDataWithURL:(NSURL *)url {
    if (url==nil) return nil;
    return [NSData dataWithContentsOfFile:[self imagePathWithURL:url]];
}

+ (BOOL)saveImageData:(NSData *)data imageURL:(NSURL *)url {
    NSString *path = [NSString stringWithFormat:@"%@/%@",[self launchAdCachePath],[self keyWithURL:url]];
    if (data) {
        BOOL result = [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
        if (!result) SL_LAUNCH_AD_LOG(@"cache file error for URL: %@", url);
        return result;
    }
    return NO;
}

+ (void)asyncSaveImageData:(NSData *)data imageURL:(NSURL *)url completed:(nullable SLLaunchAdCacheSavedCompletion)completedBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL result = [self saveImageData:data imageURL:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completedBlock) completedBlock(result , url);
        });
    });
}

+ (BOOL)saveVideoToPath:(NSURL *)location URL:(NSURL *)url {
    NSString *savePath = [[self launchAdCachePath] stringByAppendingPathComponent:[self videoNameWithURL:url]];
    NSURL *savePathUrl = [NSURL fileURLWithPath:savePath];
    BOOL result =[[NSFileManager defaultManager] moveItemAtURL:location toURL:savePathUrl error:nil];
    if (!result) SL_LAUNCH_AD_LOG(@"cache file error for URL: %@", url);
    return  result;
}

+ (void)asyncSaveVideoToPath:(NSURL *)location URL:(NSURL *)url completed:(nullable SLLaunchAdCacheSavedCompletion)completedBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       BOOL result = [self saveVideoToPath:location URL:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completedBlock) completedBlock(result , url);
        });
    });
}

+ (nullable NSURL *)getCacheVideoWithURL:(NSURL *)url {
    NSString *savePath = [[self launchAdCachePath] stringByAppendingPathComponent:[self videoNameWithURL:url]];
    //如果存在
    if ([[NSFileManager defaultManager] fileExistsAtPath:savePath]) {
        return [NSURL fileURLWithPath:savePath];
    }
    return nil;
}

+ (NSString *)launchAdCachePath {
    NSString *path =[NSHomeDirectory() stringByAppendingPathComponent:@"Library/SLLaunchAdCache"];
    [self checkDirectory:path];
    return path;
}

+ (NSString *)imagePathWithURL:(NSURL *)url {
    if (url==nil) return nil;
    return [[self launchAdCachePath] stringByAppendingPathComponent:[self keyWithURL:url]];
}

+ (NSString *)videoPathWithURL:(NSURL *)url {
    if (url==nil) return nil;
    return [[self launchAdCachePath] stringByAppendingPathComponent:[self videoNameWithURL:url]];
}

+ (NSString *)videoPathWithFileName:(NSString *)videoFileName {
    if (videoFileName.length == 0) return nil;
    return [[self launchAdCachePath] stringByAppendingPathComponent:[self videoNameWithURL:[NSURL URLWithString:videoFileName]]];
}


+ (BOOL)checkImageInCacheWithURL:(NSURL *)url {
    return [[NSFileManager defaultManager] fileExistsAtPath:[self imagePathWithURL:url]];
}

+ (BOOL)checkVideoInCacheWithURL:(NSURL *)url {
    return [[NSFileManager defaultManager] fileExistsAtPath:[self videoPathWithURL:url]];
}

+ (BOOL)checkVideoInCacheWithFileName:(NSString *)videoFileName {
    return [[NSFileManager defaultManager] fileExistsAtPath:[self videoPathWithFileName:videoFileName]];
}

+ (void)checkDirectory:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        [self createBaseDirectoryAtPath:path];
    } else {
        if (!isDir) {
            NSError *error = nil;
            [fileManager removeItemAtPath:path error:&error];
            [self createBaseDirectoryAtPath:path];
        }
    }
}

#pragma mark - url缓存
+ (void)asyncSaveImageUrl:(NSString *)url {
    if (url == nil) return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSUserDefaults standardUserDefaults] setObject:url forKey:SLCacheImageURLStringKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    });
}

+ (NSString *)getCacheImageUrl {
   return [[NSUserDefaults standardUserDefaults] objectForKey:SLCacheImageURLStringKey];
}

+ (void)asyncSaveVideoUrl:(NSString *)url {
    if (url == nil) return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSUserDefaults standardUserDefaults] setObject:url forKey:SLCacheVideoURLStringKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    });
}

+ (NSString *)getCacheVideoUrl {
  return [[NSUserDefaults standardUserDefaults] objectForKey:SLCacheVideoURLStringKey];
}

#pragma mark - 其他
+ (void)clearDiskCache {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *path = [self launchAdCachePath];
        [fileManager removeItemAtPath:path error:nil];
        [self checkDirectory:[self launchAdCachePath]];
    });
}

+ (void)clearDiskCacheWithImageUrlArray:(NSArray<NSURL *> *)imageUrlArray {
    if(imageUrlArray.count==0) return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [imageUrlArray enumerateObjectsUsingBlock:^(NSURL * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([self checkImageInCacheWithURL:obj]) {
                [[NSFileManager defaultManager] removeItemAtPath:[self imagePathWithURL:obj] error:nil];
            }
        }];
    });
}

+ (void)clearDiskCacheExceptImageUrlArray:(NSArray<NSURL *> *)exceptImageUrlArray {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *allFilePaths = [self allFilePathWithDirectoryPath:[self launchAdCachePath]];
        NSArray *exceptImagePaths = [self filePathsWithFileUrlArray:exceptImageUrlArray videoType:NO];
        [allFilePaths enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![exceptImagePaths containsObject:obj] && !SL_IS_VIDEO_PATH(obj)) {
                [[NSFileManager defaultManager] removeItemAtPath:obj error:nil];
            }
        }];
        SL_LAUNCH_AD_LOG(@"allFilePath = %@",allFilePaths);
    });
}

+ (void)clearDiskCacheWithVideoUrlArray:(NSArray<NSURL *> *)videoUrlArray {
    if(videoUrlArray.count==0) return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [videoUrlArray enumerateObjectsUsingBlock:^(NSURL * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([self checkVideoInCacheWithURL:obj]){
                [[NSFileManager defaultManager] removeItemAtPath:[self videoPathWithURL:obj] error:nil];
            }
        }];
    });
}

+ (void)clearDiskCacheExceptVideoUrlArray:(NSArray<NSURL *> *)exceptVideoUrlArray {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *allFilePaths = [self allFilePathWithDirectoryPath:[self launchAdCachePath]];
        NSArray *exceptVideoPaths = [self filePathsWithFileUrlArray:exceptVideoUrlArray videoType:YES];
        [allFilePaths enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![exceptVideoPaths containsObject:obj] && SL_IS_VIDEO_PATH(obj)) {
                [[NSFileManager defaultManager] removeItemAtPath:obj error:nil];
            }
        }];
        SL_LAUNCH_AD_LOG(@"allFilePath = %@",allFilePaths);
    });
}

+ (float)diskCacheSize {
    NSString *directoryPath = [self launchAdCachePath];
    BOOL isDir = NO;
    unsigned long long total = 0;
    if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:&isDir]) {
        if (isDir) {
            NSError *error = nil;
            NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:&error];
            if (error == nil) {
                for (NSString *subpath in array) {
                    NSString *path = [directoryPath stringByAppendingPathComponent:subpath];
                    NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
                    if (!error) {
                        total += [dict[NSFileSize] unsignedIntegerValue];
                    }
                }
            }
        }
    }
    return total/(1024.0*1024.0);
}

+ (NSArray *)filePathsWithFileUrlArray:(NSArray <NSURL *> *)fileUrlArray videoType:(BOOL)videoType {
    NSMutableArray *filePaths = [[NSMutableArray alloc] init];
    [fileUrlArray enumerateObjectsUsingBlock:^(NSURL * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *path;
        if (videoType) {
            path = [self videoPathWithURL:obj];
        } else {
            path = [self imagePathWithURL:obj];
        }
        [filePaths addObject:path];
    }];
    return filePaths;
}

+ (NSArray*)allFilePathWithDirectoryPath:(NSString*)directoryPath {
    NSMutableArray* array = [[NSMutableArray alloc] init];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSArray* tempArray = [fileManager contentsOfDirectoryAtPath:directoryPath error:nil];
    for (NSString* fileName in tempArray) {
        BOOL flag = YES;
        NSString* fullPath = [directoryPath stringByAppendingPathComponent:fileName];
        if ([fileManager fileExistsAtPath:fullPath isDirectory:&flag]) {
            if (!flag) {
                [array addObject:fullPath];
            }
        }
    }
    return array;
}

+ (void)createBaseDirectoryAtPath:(NSString *)path {
    __autoreleasing NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
        SL_LAUNCH_AD_LOG(@"create cache directory failed, error = %@", error);
    } else {
        [self addDoNotBackupAttribute:path];
    }
    SL_LAUNCH_AD_LOG(@"XHLaunchAdCachePath = %@",path);
}

+ (void)addDoNotBackupAttribute:(NSString *)path {
    NSURL *url = [NSURL fileURLWithPath:path];
    NSError *error = nil;
    [url setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
    if (error) {
        SL_LAUNCH_AD_LOG(@"error to set do not backup attribute, error = %@", error);
    }
}

+ (NSString *)md5String:(NSString *)string {
    const char *value = [string UTF8String];
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++) {
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    return outputString;
}

+ (NSString *)videoNameWithURL:(NSURL *)url {
     return [[self md5String:url.absoluteString] stringByAppendingString:@".mp4"];
}

+ (NSString *)keyWithURL:(NSURL *)url {
    return [self md5String:url.absoluteString];
}

@end
