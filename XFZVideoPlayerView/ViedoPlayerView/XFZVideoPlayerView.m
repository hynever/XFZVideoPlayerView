//
//  XFZVideoPlayerView.m
//  xfz
//
//  Created by 黄勇 on 16/1/25.
//  Copyright © 2016年 xfz. All rights reserved.
//

#import "XFZVideoPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import "XFZVideoOverlayView.h"
#import "XFZVideoPlayerController.h"
#import <ReactiveCocoa.h>
#import "Masonry.h"

@interface XFZVideoPlayerView ()

@property(nonatomic,strong) XFZVideoPlayerController *playerController;

@property(nonatomic,strong) XFZVideoOverlayView *overlayView;

@end

@implementation XFZVideoPlayerView


-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

#pragma mark - set方法
#pragma mark 设置VideoURL
-(void)setVideoURL:(NSURL *)videoURL
{
    _videoURL = videoURL;
    XFZVideoPlayerController *playerController = [[XFZVideoPlayerController alloc] initWithVideoURL:videoURL];
    self.overlayView.playerController = playerController;
    [((AVPlayerLayer *)self.layer) setPlayer:playerController.player];
    
    @weakify(self)
    self.overlayView.willFullScreenBlock = ^(){
        @strongify(self)
        if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayerViewWillFullScreen)]) {
            [self.delegate videoPlayerViewWillFullScreen];
        }
    };
    
    self.overlayView.willExitFullScreenBlock = ^(){
        @strongify(self)
        if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayerViewWillExitFullScreen)]) {
            [self.delegate videoPlayerViewWillExitFullScreen];
        }
    };
}

-(void)layoutSubviews
{
    [super layoutSubviews];
}

#pragma mark - get方法
#pragma mark _overlayView
-(XFZVideoOverlayView *)overlayView
{
    if (!_overlayView) {
        _overlayView = [XFZVideoOverlayView new];
        [self addSubview:_overlayView];
        [_overlayView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return _overlayView;
}

#pragma mark - 重写方法
#pragma mark layer定义成AVPlayerLayer
+(Class)layerClass
{
    return [AVPlayerLayer class];
}

-(void)dealloc
{
    [self.overlayView.playerController stop];
    [((AVPlayerLayer *)self.layer) setPlayer:nil];
}

@end
