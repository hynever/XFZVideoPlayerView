//
//  XFZVideoOverlayView.m
//  xfz
//
//  Created by 黄勇 on 16/1/25.
//  Copyright © 2016年 xfz. All rights reserved.
//

#import "XFZVideoOverlayView.h"
#import "XFZVideoPlayerController.h"
#import "XFZVolumeController.h"
#import "XFZVideoTimeSlider.h"
#import "XFZVideoRefreshView.h"
#import <ReactiveCocoa.h>
#import "Masonry.h"
#import "UIColor+XFZColor.h"


static CGFloat const kBottomViewHeight = 50;

#define kWinWidth [UIScreen mainScreen].bounds.size.width
#define kWinHeight [UIScreen mainScreen].bounds.size.height

@interface XFZVideoOverlayView ()

@property(nonatomic,strong) UIView *bottomView;

@property(nonatomic,strong) UIButton *playbackBtn;

@property(nonatomic,strong) UILabel *currentTimeLabel;

@property(nonatomic,strong) UILabel *separatorLabel;

@property(nonatomic,strong) UILabel *durationTimeLabel;

@property(nonatomic,strong) XFZVideoTimeSlider *timeSlider;

@property(nonatomic,strong) UIButton *scaleBtn;

@property(nonatomic,strong) XFZVideoRefreshView *refreshView;

@property(nonatomic,copy) XFZVideoCurrentTimeChangedBlock currentTimeChangedBlock;

@property(nonatomic,copy) XFZVideoPlayLoadingStatusChangedBlock loadingStatusChangedBlock;

@property(nonatomic,copy) XFZVideoReadyToPlayBlock readyToPlayBlock;

@property(nonatomic,assign) BOOL bottomViewHidden;

@property(nonatomic,assign) BOOL isFullScreen;

@property(nonatomic,assign) CGRect oldFrame;

@end

@implementation XFZVideoOverlayView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _bottomViewHidden = NO;
        _isFullScreen = NO;
        _oldFrame = CGRectZero;
        self.clipsToBounds = YES;
        self.currentTimeLabel.text = @"00:00:00";
        self.durationTimeLabel.text = @"00:00:00";
        [self setupEvent];
    }
    return self;
}

#pragma mark - 初始化方法
-(void)setupEvent
{
    @weakify(self)
    //底部播放按钮的点击事件
    [[self.playbackBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)
        if (self.playerController.status == XFZVideoPlayerStatusPlaying) {
            [self.playerController pause];
        }else{
            [self.playerController play];
        }
    }];
    
    //timeSlider的拖拽事件
    [[self.timeSlider rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(id x) {
        @strongify(self)
        self.currentTimeLabel.text = [self formatedStringWithTime:self.timeSlider.value];
    }];
    [[self.timeSlider rac_signalForControlEvents:UIControlEventTouchDown] subscribeNext:^(id x) {
        @strongify(self)
        [self.playerController scrubbingDidStart];
    }];
    [[self.timeSlider rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)
        [self.playerController scrubbingToTime:self.timeSlider.value];
    }];
    
    //当前时间改变执行的block
    self.currentTimeChangedBlock = ^(NSTimeInterval currentTime,NSTimeInterval duration){
        @strongify(self)
        //更新时间
        self.currentTimeLabel.text = [self formatedStringWithTime:currentTime];
        self.durationTimeLabel.text = [self formatedStringWithTime:duration];
        self.timeSlider.minimumValue = 0.0f;
        if (isnan(duration)) {
            duration = 0.0f;
        }
        self.timeSlider.maximumValue = duration;
        //更新进度条
        self.timeSlider.value = currentTime;
    };
    
    //缩放按钮点击的执行事件
    [[self.scaleBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)
        [UIView animateWithDuration:0.5f animations:^{
            if (self.isFullScreen) {
                if (self.willExitFullScreenBlock) {
                    self.willExitFullScreenBlock();
                }
                self.superview.transform = CGAffineTransformIdentity;
                [self.superview mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(self.superview.superview).offset(self.oldFrame.origin.x);
                    make.top.equalTo(self.superview.superview).offset(self.oldFrame.origin.y);
                    make.width.equalTo(@(self.oldFrame.size.width));
                    make.height.equalTo(@(self.oldFrame.size.height));
                }];
                self.isFullScreen = NO;
            }else{
                //记录原来的frame
                self.oldFrame = self.superview.frame;
                if (self.willFullScreenBlock) {
                    self.willFullScreenBlock();
                }
                //旋转父view
                self.superview.transform = CGAffineTransformMakeRotation(M_PI_2);
                //重新设置autolayout
                [self.superview mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.center.equalTo(self.superview.superview);
                    make.width.equalTo(@(kWinHeight));
                    make.height.equalTo(@(kWinWidth));
                }];
                self.isFullScreen = YES;
            }
            [self.superview layoutIfNeeded];
        }];
    }];
    
    //手势上下滑动的执行事件（修改音量）
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] init];
    [self addGestureRecognizer:panGesture];
    __block CGPoint oldPoint = CGPointZero;
    [[panGesture rac_gestureSignal] subscribeNext:^(id x) {
        @strongify(self)
        UIPanGestureRecognizer *gesture = (UIPanGestureRecognizer *)x;
        CGPoint locationPoint = [gesture locationInView:self];
        if (locationPoint.y < self.frame.size.height - kBottomViewHeight - 20) {
            switch (gesture.state) {
                case UIGestureRecognizerStateBegan:
                {
                    CGPoint locationPoint = [gesture locationInView:self];
                    oldPoint = locationPoint;
                }
                    break;
                case UIGestureRecognizerStateChanged:
                {
                    CGPoint locationPoint = [gesture locationInView:self];
                    if (!CGPointEqualToPoint(oldPoint, locationPoint)) {
                        CGFloat diffVolume = -(locationPoint.y - oldPoint.y)/50;
                        CGFloat oldVolume = [XFZVolumeController sharedVolumeController].volume;
                        CGFloat newVolume = oldVolume + diffVolume;
                        [XFZVolumeController sharedVolumeController].volume = newVolume;
                    }
                }
                    break;
                default:
                    break;
            }
        }
    }];
    
    //点击手势执行事件（隐藏和显示bottomView）
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    [self addGestureRecognizer:tapGesture];
    [[tapGesture rac_gestureSignal] subscribeNext:^(id x) {
        @strongify(self)
        UITapGestureRecognizer *tempGesture = (UITapGestureRecognizer *)x;
        CGPoint point = [tempGesture locationInView:self];
        if (point.y < self.frame.size.height-self.bottomView.frame.size.height) {
            if (self.bottomViewHidden) {
                [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.right.bottom.equalTo(self);
                    make.height.equalTo(@(kBottomViewHeight));
                }];
                self.bottomViewHidden = NO;
            }else{
                [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.right.equalTo(self);
                    make.top.equalTo(self.mas_bottom).offset(10);
                    make.height.equalTo(@(kBottomViewHeight));
                }];
                self.bottomViewHidden = YES;
            }
            [UIView animateWithDuration:0.5f animations:^{
                [self.bottomView layoutIfNeeded];
            }];
        }
    }];
    
    //更新播放按钮状态事件
    [RACObserve(self, playerController) subscribeNext:^(id x) {
        XFZVideoPlayerController *controller = (XFZVideoPlayerController *)x;
        if (controller) {
            [RACObserve(controller, status) subscribeNext:^(id x) {
                XFZVideoPlayerStatus status = [x integerValue];
                self.playbackBtn.selected = status==XFZVideoPlayerStatusPlaying;
            }];
        }
    }];
    
    //是否loading状态监听
    self.loadingStatusChangedBlock = ^(BOOL loading){
        @strongify(self)
        if (loading) {
            [self.refreshView startAnimation];
        }else{
            [self.refreshView stopAnimation];
        }
    };
    
    self.readyToPlayBlock = ^(){
        //加一个loading
        [self.refreshView stopAnimation];
    };
}

#pragma mark - set方法
-(void)setPlayerController:(XFZVideoPlayerController *)playerController
{
    _playerController = playerController;
    playerController.currentTimeChangedBlock = self.currentTimeChangedBlock;
    playerController.loadingStatusChangedBlock = self.loadingStatusChangedBlock;
    playerController.readyToPlayBlock = self.readyToPlayBlock;
}

#pragma mark - 系统方法
-(void)didMoveToSuperview
{
    [super didMoveToSuperview];
    [self.refreshView startAnimation];
}

#pragma mark - 辅助方法
-(NSString *)formatedStringWithTime:(NSInteger)value{
    //小时
    NSInteger hours = value / 3600;
    NSInteger minutes = (value - hours*3600) / 60;
    NSInteger seconds = (value - minutes*60) % 60;
    if (hours > 0) {
        return [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)hours,(long)minutes,(long)seconds];
    }else{
        return [NSString stringWithFormat:@"%02ld:%02ld",(long)minutes,(long)seconds];
    }
}


#pragma mark - get方法
#pragma mark _bottomView
-(UIView *)bottomView
{
    if (!_bottomView) {
        _bottomView = [UIView new];
        _bottomView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        [self addSubview:_bottomView];
        [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.height.equalTo(@(kBottomViewHeight));
        }];
    }
    return _bottomView;
}

#pragma mark _playbackBtn
-(UIButton *)playbackBtn
{
    if (!_playbackBtn) {
        _playbackBtn = [UIButton new];
        [_playbackBtn setImage:[UIImage imageNamed:@"video_playback_icon"] forState:UIControlStateNormal];
        [_playbackBtn setImage:[UIImage imageNamed:@"video_pause_icon"] forState:UIControlStateSelected];
        [self.bottomView addSubview:_playbackBtn];
        [_playbackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.bottomView).offset(10);
            make.bottom.equalTo(self.bottomView).offset(-5);
            make.size.mas_equalTo(CGSizeMake(40, 40));
        }];
    }
    return _playbackBtn;
}

#pragma mark _currentTimeLabel
-(UILabel *)currentTimeLabel
{
    if (!_currentTimeLabel) {
        _currentTimeLabel = [UILabel new];
        _currentTimeLabel.text = @"00:00:00";
        _currentTimeLabel.font = [UIFont systemFontOfSize:9];
        _currentTimeLabel.textColor = [UIColor c4Color];
        [self.bottomView addSubview:_currentTimeLabel];
        [_currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.playbackBtn.mas_right).offset(0);
            make.centerY.equalTo(self.playbackBtn);
        }];
    }
    return _currentTimeLabel;
}

#pragma mark _durationTimeLabel
-(UILabel *)durationTimeLabel
{
    if (!_durationTimeLabel) {
        _durationTimeLabel = [UILabel new];
        _durationTimeLabel.text = @"00:00:00";
        _durationTimeLabel.font = self.currentTimeLabel.font;
        _durationTimeLabel.textColor = self.currentTimeLabel.textColor;
        [self.bottomView addSubview:_durationTimeLabel];
        
        _separatorLabel = [[UILabel alloc] init];
        _separatorLabel.font = _durationTimeLabel.font;
        _separatorLabel.textColor = _durationTimeLabel.textColor;
        _separatorLabel.text = @"/";
        [self.bottomView addSubview:_separatorLabel];
        [_separatorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.currentTimeLabel.mas_right).offset(0);
            make.centerY.equalTo(self.currentTimeLabel);
        }];
        [_durationTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_separatorLabel.mas_right);
            make.centerY.equalTo(self.currentTimeLabel);
        }];
    }
    return _durationTimeLabel;
}

#pragma mark _scaleBtn
-(UIButton *)scaleBtn
{
    if (!_scaleBtn) {
        _scaleBtn = [UIButton new];
        [_scaleBtn setImage:[UIImage imageNamed:@"video_scale_icon"] forState:UIControlStateNormal];
        [self.bottomView addSubview:_scaleBtn];
        [_scaleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.bottomView).offset(-15);
            make.centerY.equalTo(self.playbackBtn);
            make.size.mas_equalTo(CGSizeMake(30, 30));
        }];
    }
    return _scaleBtn;
}

#pragma mark _timeSlider
-(XFZVideoTimeSlider *)timeSlider
{
    if (!_timeSlider) {
        _timeSlider = [XFZVideoTimeSlider new];
        [_timeSlider setThumbImage:[UIImage imageNamed:@"video_slider_btn_icon"] forState:UIControlStateNormal];
        _timeSlider.minimumTrackTintColor = [UIColor c10Color];
        _timeSlider.maximumTrackTintColor = [UIColor c3Color];
        _timeSlider.minimumValue = 0.0f;
        [self.bottomView addSubview:_timeSlider];
        [_timeSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.bottomView);
            make.centerY.equalTo(self.bottomView.mas_top);
            make.height.equalTo(@3);
        }];
    }
    return _timeSlider;
}

#pragma mark _refreshView
-(XFZVideoRefreshView *)refreshView
{
    if (!_refreshView) {
        _refreshView = [XFZVideoRefreshView new];
        [self.superview addSubview:_refreshView];
        [_refreshView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.superview);
            make.size.mas_equalTo(CGSizeMake(30, 30));
        }];
    }
    return _refreshView;
}

@end
