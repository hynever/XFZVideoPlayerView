//
//  XFZVolumeController.h
//  xfz
//
//  Created by 黄勇 on 16/1/26.
//  Copyright © 2016年 xfz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XFZSinglenMacro.h"

/**
 *  音量控制，不是viewController
 */
@interface XFZVolumeController : NSObject

singleton_h(VolumeController);

@property(nonatomic,assign) float volume;

@end
