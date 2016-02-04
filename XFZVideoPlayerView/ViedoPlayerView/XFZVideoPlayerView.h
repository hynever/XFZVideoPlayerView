//
//  XFZVideoPlayerView.h
//  xfz
//
//  Created by 黄勇 on 16/1/25.
//  Copyright © 2016年 xfz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XFZVideoPlayerViewDelegate;
@interface XFZVideoPlayerView : UIView

/**
 *  视频的url
 */
@property(nonatomic,copy) NSURL *videoURL;

@property(nonatomic,weak) id<XFZVideoPlayerViewDelegate> delegate;

@end


@protocol XFZVideoPlayerViewDelegate <NSObject>

/**
 *  将要进入全屏
 */
-(void)videoPlayerViewWillFullScreen;

/**
 *  将要退出全屏
 */
-(void)videoPlayerViewWillExitFullScreen;

@end