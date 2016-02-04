//
//  XFZVideoPlayerController.m
//  xfz
//
//  Created by 黄勇 on 16/1/25.
//  Copyright © 2016年 xfz. All rights reserved.
//

#import "XFZVideoPlayerController.h"
#import "ReactiveCocoa.h"
#import "RACEXTScope.h"

//事件监听间隔
static CGFloat const REFRESH_INTERVAL = 0.5f;

static NSString * const STATUS_KEYPATH = @"status";

static NSString * const PLAYBACKLIKELYTOKEEPUP_KEYPATH = @"playbackLikelyToKeepUp";

static NSString * const PLAYBACKBUFFERFULL_KEYPATH = @"playbackBufferFull";

static NSString * const PLAYBACKBUFFEREMPTY_KEYPATH = @"playbackBufferEmpty";

static const NSString *PlaybackLikelyToKeeyUPContext;

static const NSString *PlaybackBufferFullContext;

static const NSString *PlayerItemStatusContext;

static const NSString *PlaybackBufferEmptyContext;

@interface XFZVideoPlayerController ()

@property(nonatomic,strong) AVAsset *asset;

@property(nonatomic,strong) AVPlayerItem *playerItem;

@property(nonatomic,assign,readwrite) XFZVideoPlayerStatus status;

@property(nonatomic,strong) AVPlayer *player;

@property(nonatomic,strong) id itemEndObserver;

@property(nonatomic,strong) id timeObserver;

@property(nonatomic,assign) XFZVideoPlayerStatus lastStatus;

@end

@implementation XFZVideoPlayerController

#pragma mark - init方法
-(instancetype)init{
    if ([self class] == [XFZVideoPlayerController class]) {
        NSAssert(false, @"禁止调用init方法");
    }else{
        self = [super init];
    }
    return nil;
}

-(instancetype)initWithVideoURL:(NSURL *)videoURL
{
    self = [super init];
    if (self) {
        _lastStatus = XFZVideoPlayerStatusUnknow;
        _status = XFZVideoPlayerStatusUnknow;
        
        _videoURL = videoURL;
        _asset = [AVAsset assetWithURL:videoURL];
        _playerItem = [AVPlayerItem playerItemWithAsset:self.asset automaticallyLoadedAssetKeys:@[@"tracks",@"duration",@"commonMetadata"]];
        _player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
        
        //添加时间监听的行为
        [self addPlayerTimeObserver];
        
        [self addPlayerItemStatusObserver];
        
        //添加视频播放结束的通知
        [self addItemEndObserverForPlayerItem];
        
        //添加是否可以播放的监听（包括网络到达、本地视频I/O读取）
        [self addItemPlaybackLoadingObserver];
        
    }
    return self;
}

#pragma mark - dealloc方法
-(void)dealloc
{
    if (self.itemEndObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.itemEndObserver name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
        self.itemEndObserver = nil;
    }
    
    if (self.playerItem) {
        [self removeItemPlackLoadingObserver];
    }
    
    self.player = nil;
    self.playerItem = nil;
    self.asset = nil;
}


-(void)addPlayerTimeObserver
{
    CMTime interval = CMTimeMakeWithSeconds(REFRESH_INTERVAL, NSEC_PER_SEC);
    @weakify(self)
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        @strongify(self)
        NSTimeInterval currentTime = CMTimeGetSeconds(time);
        NSTimeInterval duration = CMTimeGetSeconds(self.playerItem.duration);
        if (isnan(duration)) {
            duration = 0.0f;
        }
        if (self.currentTimeChangedBlock) {
            self.currentTimeChangedBlock(currentTime,duration);
        }
    }];
}

-(void)addPlayerItemStatusObserver
{
    [self.playerItem addObserver:self forKeyPath:STATUS_KEYPATH options:NSKeyValueObservingOptionNew context:&PlayerItemStatusContext];
}

-(void)addItemEndObserverForPlayerItem
{
    @weakify(self)
    self.itemEndObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        @strongify(self)
        [self stop];
    }];
}

-(void)addItemPlaybackLoadingObserver{
    [self.playerItem addObserver:self forKeyPath:PLAYBACKLIKELYTOKEEPUP_KEYPATH options:NSKeyValueObservingOptionNew context:&PlaybackLikelyToKeeyUPContext];
    [self.playerItem addObserver:self forKeyPath:PLAYBACKBUFFERFULL_KEYPATH options:NSKeyValueObservingOptionNew context:&PlaybackBufferFullContext];
    [self.playerItem addObserver:self forKeyPath:PLAYBACKBUFFEREMPTY_KEYPATH options:NSKeyValueObservingOptionNew context:&PlaybackBufferEmptyContext];
}

-(void)removePlayerTimeObserver
{
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
}

-(void)removeItemPlackLoadingObserver
{
    [self.playerItem removeObserver:self forKeyPath:PLAYBACKLIKELYTOKEEPUP_KEYPATH];
    [self.playerItem removeObserver:self forKeyPath:PLAYBACKBUFFERFULL_KEYPATH];
    [self.playerItem removeObserver:self forKeyPath:PLAYBACKBUFFEREMPTY_KEYPATH];
}

#pragma mark - set方法
-(void)setVolume:(CGFloat)volume
{
    _volume = volume;
    [self.player setVolume:volume];
}

-(void)setCurrentTimeChangedBlock:(XFZVideoCurrentTimeChangedBlock)currentTimeChangedBlock
{
    _currentTimeChangedBlock = [currentTimeChangedBlock copy];
    if (currentTimeChangedBlock) {
        currentTimeChangedBlock(0.0f,CMTimeGetSeconds(self.playerItem.duration));
    }
}

#pragma mark - kvo方法
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (context == &PlaybackLikelyToKeeyUPContext) {
        [self updateLoadingStatus];
    }else if (context == &PlaybackBufferFullContext){
        [self updateLoadingStatus];
    }else if (context == &PlaybackBufferEmptyContext){
        [self updateLoadingStatus];
    }else if (context == &PlayerItemStatusContext){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
                if (self.readyToPlayBlock) {
                    self.readyToPlayBlock();
                }
            }
        });
    }
}

#pragma mark - 辅助方法（私有方法）
#pragma mark 更新loading状态
-(void)updateLoadingStatus
{
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL isLoading = YES;
        if (self.playerItem.playbackLikelyToKeepUp || self.playerItem.playbackBufferFull || !self.playerItem.playbackBufferEmpty) {
            isLoading = NO;
        }
        
        if (!isLoading) {
            if ((self.lastStatus == XFZVideoPlayerStatusToPlay || self.lastStatus == XFZVideoPlayerStatusPlaying) && self.status != XFZVideoPlayerStatusStoped && self.status != XFZVideoPlayerStatusPause) {
                [self play];
            }
        }
        
        if (self.loadingStatusChangedBlock) {
            self.loadingStatusChangedBlock(isLoading);
        }
    });
}

#pragma mark - vide的行为方法
-(void)play
{
    if (self.lastStatus == XFZVideoPlayerStatusUnknow) {
        self.lastStatus = XFZVideoPlayerStatusToPlay;
    }
    [self.player play];
    self.status = XFZVideoPlayerStatusPlaying;
}

-(void)pause
{
    self.lastStatus = self.status;
    [self.player pause];
    self.status = XFZVideoPlayerStatusPause;
}

-(void)stop
{
    self.lastStatus = self.status;
    [self.player seekToTime:kCMTimeZero];
    [self.player pause];
    self.status = XFZVideoPlayerStatusStoped;
}

-(void)scrubbingDidStart
{
    self.lastStatus = self.status;
    [self pause];
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
        [self.playerItem removeObserver:self forKeyPath:PLAYBACKLIKELYTOKEEPUP_KEYPATH];
    }
}

-(void)scrubbingToTime:(NSTimeInterval)time
{
    [self.playerItem cancelPendingSeeks];
    @weakify(self)
    [self.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
        @strongify(self)
        if (finished) {            
            if (!self.timeObserver) {
                [self addPlayerTimeObserver];
                [self addItemPlaybackLoadingObserver];
            }
            if (self.lastStatus == XFZVideoPlayerStatusPlaying || self.lastStatus == XFZVideoPlayerStatusToPlay) {
                [self play];
            }
        }
    }];
}

-(void)seekToTime:(NSTimeInterval)time
{
    [self.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)];
}

@end
