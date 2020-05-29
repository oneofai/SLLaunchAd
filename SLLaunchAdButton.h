//
//  SLLaunchAdButton.h
//  YiBanClient
//
//  Created by Sun on 2020/05/29.
//  Copyright © 2019 Qing Class. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/**
 *  倒计时类型
 */
typedef NS_ENUM(NSInteger,SLLaunchAdSkipType) {
    SLLaunchAdSkipNone                           = 1, //无
    /** 方形 */
    SLLaunchAdSkipTypeRoundedRectangleTime       = 2, // 方形圆角:倒计时
    SLLaunchAdSkipTypeRoundedRectangleText       = 3, // 方形圆角:跳过
    SLLaunchAdSkipTypeRoundedRectangleTimeText   = 4, // 方形圆角:倒计时+跳过 (default)
    /** 圆形 */
    SLLaunchAdSkipTypeRoundedTimeText            = 5, // 圆形: 倒计时
    SLLaunchAdSkipTypeRoundedTime                = 6, // 圆形: 跳过
    SLLaunchAdSkipTypeRoundedProgressTime        = 7, // 圆形: 进度圈+倒计时
    SLLaunchAdSkipTypeRoundedProgressText        = 8, // 圆形: 进度圈+跳过
};

@interface SLLaunchAdButton : UIButton

- (instancetype)initWithSkipType:(SLLaunchAdSkipType)skipType;

- (void)startRoundDispathTimerWithDuration:(NSTimeInterval)duration;

- (void)setTitleWithSkipType:(SLLaunchAdSkipType)skipType duration:(NSTimeInterval)duration;

@end

NS_ASSUME_NONNULL_END
