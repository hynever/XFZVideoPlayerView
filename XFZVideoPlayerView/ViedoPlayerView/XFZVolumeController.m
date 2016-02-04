//
//  XFZVolumeController.m
//  xfz
//
//  Created by 黄勇 on 16/1/26.
//  Copyright © 2016年 xfz. All rights reserved.
//

#import "XFZVolumeController.h"
#import <MediaPlayer/MPVolumeView.h>

@interface XFZVolumeController ()

@property(nonatomic,strong) MPVolumeView *volumeView;

@property(nonatomic,strong) UISlider *volumeSlider;

@end

@implementation XFZVolumeController

singleton_m(VolumeController);

-(instancetype)init
{
    self = [super init];
    if (self) {
        _volumeView = [[MPVolumeView alloc] init];
        for (UIView *view in _volumeView.subviews) {
            if ([view.class.description isEqualToString:@"MPVolumeSlider"]) {
                _volumeSlider = (UISlider *)view;
                break;
            }
        }
        
        _volume = _volumeSlider.value;
    }
    return self;
}

-(void)setVolume:(float)volume
{
    if (volume > 1.0f) {
        volume = 1.0f;
    }
    if (volume < 0.0f) {
        volume = 0.0f;
    }
    [self.volumeSlider setValue:volume animated:YES];
    [self.volumeSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
}

@end
