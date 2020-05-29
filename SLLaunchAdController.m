//
//  SLLaunchAdController.m
//  YiBanClient
//
//  Created by Sun on 2020/05/29.
//  Copyright © 2019 Qing Class. All rights reserved.
//

#import "SLLaunchAdController.h"
#import "SLLaunchAdUtilities.h"

@interface SLLaunchAdController ()

@end

@implementation SLLaunchAdController

- (BOOL)shouldAutorotate {
    return NO;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return SLLaunchAdPrefersHomeIndicatorAutoHidden;
}

@end
