//
//  XFZVideoRefreshView.m
//  xfz
//
//  Created by 黄勇 on 16/1/27.
//  Copyright © 2016年 xfz. All rights reserved.
//

#import "XFZVideoRefreshView.h"
#import <QuartzCore/QuartzCore.h>
#import "Masonry.h"

@interface XFZVideoRefreshView ()

@property(nonatomic,strong) UIImageView *imageView;

@end

@implementation XFZVideoRefreshView

-(void)startAnimation
{
    self.hidden = NO;
    CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    basicAnimation.duration = 0.5f;
    basicAnimation.repeatCount = CGFLOAT_MAX;
    basicAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    basicAnimation.toValue = [NSNumber numberWithFloat:M_PI*2];
    [self.imageView.layer addAnimation:basicAnimation forKey:@"rotate-layer"];
}

-(void)stopAnimation
{
    [self.imageView.layer removeAnimationForKey:@"rotate-layer"];
    self.hidden = YES;
}

#pragma mark - get方法
#pragma mark _imageView
-(UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [UIImageView new];
        _imageView.image = [UIImage imageNamed:@"video_refresh_icon"];
        [self addSubview:_imageView];
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(18, 18));
        }];
    }
    return _imageView;
}

@end
