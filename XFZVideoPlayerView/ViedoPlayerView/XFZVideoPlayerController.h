//
//  XFZVideoPlayerController.h
//  xfz
//
//  Created by 黄勇 on 16/1/25.
//  Copyright © 2016年 xfz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef enum : NSUInteger {
    XFZVideoPlayerStatusUnknow, //未知
    XFZVideoPlayerStatusToPlay, //将要播放
    XFZVideoPlayerStatusPlaying,//播放中
    XFZVideoPlayerStatusPause,  //暂停
    XFZVideoPlayerStatusStoped, //停止
    XFZVideoPlayerStatusLoading,//loading中
} XFZVideoPlayerStatus;

typedef void(^XFZVideoCurrentTimeChangedBlock)(NSTimeInterval currentTime,NSTimeInterval totalTime);

typedef void(^XFZVideoPlayLoadingStatusChangedBlock)(BOOL loading);

typedef void(^XFZVideoReadyToPlayBlock)();

/**
 *  这只是一个控制视频播放的控制器，不是ViewController
 */
@interface XFZVideoPlayerController : NSObject

/**
 *  根据VideoURL初始化，只能通过这个方法初始化，不能通过init方法初始化
 */
-(instancetype)initWithVideoURL:(NSURL *)videoURL;

/**
 *  只读的videoURL
 */
@property(nonatomic,strong,readonly) NSURL *videoURL;

/**
 *  AVPlayer
 */
@property(nonatomic,strong,readonly) AVPlayer *player;

/**
 *  当前时间改变的block
 */
@property(nonatomic,copy) XFZVideoCurrentTimeChangedBlock currentTimeChangedBlock;

/**
 *  播放是否是被缓冲了
 */
@property(nonatomic,copy) XFZVideoPlayLoadingStatusChangedBlock loadingStatusChangedBlock;

/**
 *  已经准备播放的block
 */
@property(nonatomic,copy) XFZVideoReadyToPlayBlock readyToPlayBlock;

/**
 *  音量(值从0-1)
 */
@property(nonatomic,assign) CGFloat volume;

/**
 *  播放器的状态
 */
@property(nonatomic,assign,readonly) XFZVideoPlayerStatus status;

/**
 *  播放(如果还未开始，就从头开始播放，如果之前播放了，就从当前时间播放)
 */
-(void)play;

/**
 *  暂停播放
 */
-(void)pause;

/**
 *  停止播放
 */
-(void)stop;

/**
 *  跳到某个时间
 */
-(void)seekToTime:(NSTimeInterval)time;

/**
 *  slide已经开始
 */
-(void)scrubbingDidStart;

/**
 *  slide到某个时间
 */
-(void)scrubbingToTime:(NSTimeInterval)time;


@end
