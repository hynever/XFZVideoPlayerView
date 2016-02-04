//
//  XFZVideoOverlayView.h
//  xfz
//
//  Created by 黄勇 on 16/1/25.
//  Copyright © 2016年 xfz. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^XFZVideoPlayerViewWillFullScreenBlock)();
typedef void(^XFZVideoPlayerViewWillExitFullScreenBlock)();

@class XFZVideoPlayerController;
@interface XFZVideoOverlayView : UIView
@property(nonatomic,strong) XFZVideoPlayerController *playerController;
@property(nonatomic,copy) XFZVideoPlayerViewWillFullScreenBlock willFullScreenBlock;
@property(nonatomic,copy) XFZVideoPlayerViewWillExitFullScreenBlock willExitFullScreenBlock;
@end
