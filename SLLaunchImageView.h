//
//  SLLaunchImageView.h
//  YiBanClient
//
//  Created by Sun on 2020/05/29.
//  Copyright © 2019 Qing Class. All rights reserved.
//


#import <UIKit/UIKit.h>

/** 启动图来源 */
typedef NS_ENUM(NSInteger, SLLaunchSourceType) {
    /** LaunchImage */
    SLLaunchSourceTypeImage = 1,
    /** LaunchScreen.storyboard (default) */
    SLLaunchSourceTypeStoryboard = 2,
};


@interface SLLaunchImageView : UIImageView

- (instancetype)initWithSourceType:(SLLaunchSourceType)sourceType;

@end
