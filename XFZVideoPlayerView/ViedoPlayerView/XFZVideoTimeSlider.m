//
//  XFZVideoTimeSlider.m
//  xfz
//
//  Created by 黄勇 on 16/1/26.
//  Copyright © 2016年 xfz. All rights reserved.
//

#import "XFZVideoTimeSlider.h"

@implementation XFZVideoTimeSlider

-(CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value
{
    if (self.maximumValue > 0.0f) {
        CGFloat width = 30;
        CGFloat height = 30;
        CGFloat x = value/(self.maximumValue - self.minimumValue)*rect.size.width-5;
        CGFloat y = [super thumbRectForBounds:bounds trackRect:rect value:value].origin.y-5;
        return CGRectMake(x, y, width, height);
    }else{
        return [super thumbRectForBounds:bounds trackRect:rect value:value];
    }
}


-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect bounds = self.bounds;
    bounds = CGRectInset(bounds, -20, -10);
    return CGRectContainsPoint(bounds, point);
}

@end
