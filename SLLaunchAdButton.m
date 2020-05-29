//
//  SLLaunchAdButton.m
//  YiBanClient
//
//  Created by Sun on 2020/05/29.
//  Copyright © 2019 Qing Class. All rights reserved.
//

#import "SLLaunchAdButton.h"
#import "SLLaunchAdUtilities.h"

/** Progress颜色 */
#define SLLaunchAdRoundProgressColor  [UIColor whiteColor]
/** 背景色 */
#define SLLaunchAdBackgroundColor     [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]
/** 字体颜色 */
#define SLLaunchAdFontColor           [UIColor whiteColor]

#define SLLaunchAdSkipTitle           @"跳过"
/** 倒计时单位 */
#define SLLaunchAdSkipDurationUnit    @"s"

@interface SLLaunchAdButton()

@property (nonatomic, assign) SLLaunchAdSkipType skipType;
@property (nonatomic, assign) CGFloat leftRightSpace;
@property (nonatomic, assign) CGFloat topBottomSpace;
@property (nonatomic, strong) UILabel *timeLab;
@property (nonatomic, strong) CAShapeLayer *roundLayer;
@property (nonatomic, copy)   dispatch_source_t roundTimer;
@end

@implementation SLLaunchAdButton

- (instancetype)initWithSkipType:(SLLaunchAdSkipType)skipType{
    self = [super init];
    if (self) {
        
        _skipType = skipType;
        CGFloat y = SL_IS_NOTCHED_SCREEN ? 44 : 20;
        self.frame = CGRectMake(SL_DEVICE_WIDTH - 80, y, 70, 35);//方形
        switch (skipType) {
            case SLLaunchAdSkipTypeRoundedTimeText:
            case SLLaunchAdSkipTypeRoundedTime:
            case SLLaunchAdSkipTypeRoundedProgressTime:
            case SLLaunchAdSkipTypeRoundedProgressText: { //环形
                self.frame = CGRectMake(SL_DEVICE_WIDTH - 55, y, 42, 42);
            }
                break;
            default:
                break;
        }
        
        switch (skipType) {
            case SLLaunchAdSkipNone:{
                self.hidden = YES;
            }
                break;
            case SLLaunchAdSkipTypeRoundedRectangleTime:{
                [self addSubview:self.timeLab];
                self.leftRightSpace = 5;
                self.topBottomSpace = 2.5;
            }
                break;
            case SLLaunchAdSkipTypeRoundedRectangleText:{
                [self addSubview:self.timeLab];
                self.leftRightSpace = 5;
                self.topBottomSpace = 2.5;
            }
                break;
            case SLLaunchAdSkipTypeRoundedRectangleTimeText:{
                [self addSubview:self.timeLab];
                self.leftRightSpace = 5;
                self.topBottomSpace = 2.5;
            }
                break;
            case SLLaunchAdSkipTypeRoundedTimeText:{
                [self addSubview:self.timeLab];
            }
                break;
            case SLLaunchAdSkipTypeRoundedTime:{
                [self addSubview:self.timeLab];
            }
                break;
            case SLLaunchAdSkipTypeRoundedProgressTime:{
                [self addSubview:self.timeLab];
                [self.timeLab.layer addSublayer:self.roundLayer];
            }
                break;
            case SLLaunchAdSkipTypeRoundedProgressText:{
                [self addSubview:self.timeLab];
                [self.timeLab.layer addSublayer:self.roundLayer];
            }
                break;
            default:
                break;
        }
    }
    return self;
}

- (UILabel *)timeLab {
    if (_timeLab ==  nil) {
        _timeLab = [[UILabel alloc] initWithFrame:self.bounds];
        _timeLab.textColor = SLLaunchAdFontColor;
        _timeLab.backgroundColor = SLLaunchAdBackgroundColor;
        _timeLab.layer.masksToBounds = YES;
        _timeLab.textAlignment = NSTextAlignmentCenter;
        _timeLab.font = [UIFont systemFontOfSize:13.5];
        [self cornerRadiusWithView:_timeLab];
    }
    return _timeLab;
}

- (CAShapeLayer *)roundLayer {
    if (_roundLayer == nil) {
        _roundLayer = [CAShapeLayer layer];
        _roundLayer.fillColor = SLLaunchAdBackgroundColor.CGColor;
        _roundLayer.strokeColor = SLLaunchAdRoundProgressColor.CGColor;
        _roundLayer.lineCap = kCALineCapRound;
        _roundLayer.lineJoin = kCALineJoinRound;
        _roundLayer.lineWidth = 2;
        _roundLayer.frame = self.bounds;
        _roundLayer.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.timeLab.bounds.size.width/2.0, self.timeLab.bounds.size.width/2.0) radius:self.timeLab.bounds.size.width/2.0-1.0 startAngle:-0.5*M_PI endAngle:1.5*M_PI clockwise:YES].CGPath;
        _roundLayer.strokeStart = 0;
    }
    return _roundLayer;
}

- (void)setTitleWithSkipType:(SLLaunchAdSkipType)skipType duration:(NSTimeInterval)duration{
    
    switch (skipType) {
        case SLLaunchAdSkipNone:{
            self.hidden = YES;
        }
            break;
        case SLLaunchAdSkipTypeRoundedRectangleTime:{
            self.hidden = NO;
            self.timeLab.text = [NSString stringWithFormat:@"%.0lf %@", duration, SLLaunchAdSkipDurationUnit];
        }
            break;
        case SLLaunchAdSkipTypeRoundedRectangleText:{
            self.hidden = NO;
            self.timeLab.text = SLLaunchAdSkipTitle;
        }
            break;
        case SLLaunchAdSkipTypeRoundedRectangleTimeText:{
            self.hidden = NO;
            self.timeLab.text = [NSString stringWithFormat:@"%.0lf %@", duration, SLLaunchAdSkipTitle];
        }
            break;
        case SLLaunchAdSkipTypeRoundedTimeText:{
            self.hidden = NO;
            self.timeLab.text = [NSString stringWithFormat:@"%.0lf %@", duration, SLLaunchAdSkipDurationUnit];
        }
            break;
        case SLLaunchAdSkipTypeRoundedTime:{
            self.hidden = NO;
            self.timeLab.text = SLLaunchAdSkipTitle;
        }
            break;
        case SLLaunchAdSkipTypeRoundedProgressTime:{
            self.hidden = NO;
            self.timeLab.text = [NSString stringWithFormat:@"%.0lf %@", duration, SLLaunchAdSkipDurationUnit];
        }
            break;
        case SLLaunchAdSkipTypeRoundedProgressText:{
            self.hidden = NO;
            self.timeLab.text = SLLaunchAdSkipTitle;
        }
            break;
        default:
            break;
    }
}

- (void)startRoundDispathTimerWithDuration:(NSTimeInterval)duration {
    NSTimeInterval period = 0.05;
    __block CGFloat roundDuration = duration;
    _roundTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    dispatch_source_set_timer(_roundTimer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_roundTimer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (roundDuration <= 0) {
                self.roundLayer.strokeStart = 1;
                SL_DISPATCH_SOURCE_CANCEL_SAFE(self.roundTimer);
            }
            self.roundLayer.strokeStart += 1/(duration/period);
            roundDuration -= period;
        });
    });
    dispatch_resume(_roundTimer);
}

- (void)setLeftRightSpace:(CGFloat)leftRightSpace {
    _leftRightSpace = leftRightSpace;
    CGRect frame = self.timeLab.frame;
    CGFloat width = frame.size.width;
    if (leftRightSpace<=0 || leftRightSpace*2>= width) return;
    frame = CGRectMake(leftRightSpace, frame.origin.y, width-2*leftRightSpace, frame.size.height);
    self.timeLab.frame = frame;
    [self cornerRadiusWithView:self.timeLab];
}

- (void)setTopBottomSpace:(CGFloat)topBottomSpace {
    _topBottomSpace = topBottomSpace;
    CGRect frame = self.timeLab.frame;
    CGFloat height = frame.size.height;
    if (topBottomSpace<=0 || topBottomSpace*2>= height) return;
    frame = CGRectMake(frame.origin.x, topBottomSpace, frame.size.width, height-2*topBottomSpace);
    self.timeLab.frame = frame;
    [self cornerRadiusWithView:self.timeLab];
}

- (void)cornerRadiusWithView:(UIView *)view {
    CGFloat min = view.frame.size.height;
    if (view.frame.size.height > view.frame.size.width) {
        min = view.frame.size.width;
    }
    view.layer.cornerRadius = min/2.0;
    view.layer.masksToBounds = YES;
}

@end
