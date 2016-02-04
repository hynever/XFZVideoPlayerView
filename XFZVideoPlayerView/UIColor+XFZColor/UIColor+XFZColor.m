//
//  UIColor+XFZColor.m
//  xfz
//
//  Created by 黄勇 on 15/8/14.
//  Copyright (c) 2015年 xfz. All rights reserved.
//

#import "UIColor+XFZColor.h"

@implementation UIColor (XFZColor)

/**
 *  主体字体颜色
 */
+(UIColor *)mainTextColor
{
    return [self c1Color];
}

/**
 *  辅助性的文字颜色
 */
+(UIColor *)assistTextColor
{
    return [self colorWithRGBHex:0xbcbcbc];
}

/**
 *  主体颜色
 */
+(UIColor *)themeColor
{
    return [self c10Color];
}

/**
 *  不可用状态的颜色
 */
+(UIColor *)disableColor
{
    return [self c5Color];
}

/**
 *  背景颜色
 */
+(UIColor *)backgroundColor
{
    return [self c7Color];
}

/**
 *  线的颜色
 */
+(UIColor *)lineColor
{
    return [self c6Color];
}

/**
 *  导航栏背景颜色
 */
+(UIColor *)navigationBarBackgroundColor
{
    return [UIColor colorWithRed:0.17f green:0.16f blue:0.18f alpha:1.00f];
}

/**
 *  C1颜色
 */
+(UIColor *)c1Color
{
    return [self colorWithRGBHex:0x2a2c2f];
}

/**
 *  C2颜色
 */
+(UIColor *)c2Color
{
    return [self colorWithRGBHex:0x565656];
}

/**
 *  C3颜色
 */
+(UIColor *)c3Color
{
    return [self colorWithRGBHex:0x696969];
}

/**
 *  C4颜色
 */
+(UIColor *)c4Color
{
    return [self colorWithRGBHex:0x989898];
}

/**
 *  C5颜色
 */
+(UIColor *)c5Color
{
    return [self colorWithRGBHex:0xc9c9c9];
}

/**
 *  C6颜色
 */
+(UIColor *)c6Color
{
    return [self colorWithRGBHex:0xe1e1e1];
}

/**
 *  C7颜色
 */
+(UIColor *)c7Color
{
    return [self colorWithRGBHex:0xf2f2f2];
}

/**
 *  C8颜色
 */
+(UIColor *)c8Color
{
    return [self colorWithRGBHex:0xf8f8f8];
}

/**
 *  C9颜色
 */
+(UIColor *)c9Color
{
    return [self colorWithRGBHex:0xfafafa];
}

/**
 *  C10颜色
 */
+(UIColor *)c10Color
{
    return [self colorWithRGBHex:0x00caa9];
}

/**
 *  C11颜色
 */
+(UIColor *)c11Color
{
    return [self colorWithRGBHex:0x5ed3cd];
}

/**
 *  C12颜色
 */
+(UIColor *)c12Color
{
    return [self colorWithRGBHex:0xff4c7c];
}

/**
 *  C13颜色
 */
+(UIColor *)c13Color
{
    return [self colorWithRGBHex:0xff76a0];
}

/**
 *  C14颜色
 */
+(UIColor *)c14Color
{
    return [self colorWithRGBHex:0xffbe16];
}

/**
 *  C15颜色
 */
+(UIColor *)c15Color
{
    return [self colorWithRGBHex:0xffd961];
}

/**
 *  C16颜色
 */
+(UIColor *)c16Color
{
    return [self blackColor];
}

/**
 *  C17颜色
 */
+(UIColor *)c17Color
{
    return [self whiteColor];
}

/**
 *  C18颜色
 */
+(UIColor *)c18Color
{
    return [self colorWithRGBHex:0xf9f9f9];
}

/**
 *  C19颜色
 */
+(UIColor *)c19Color
{
    return [self colorWithRGBHex:0xe9eaeb];
}

/**
 *  C20颜色
 */
+(UIColor *)c20Color
{
    return [self colorWithRGBHex:0x6d85a3];
}

/**
 *  C21颜色
 */
+(UIColor *)c21Color
{
    return [self colorWithRGBHex:0xf4e7af];
}

/**
 *  C22颜色
 */
+(UIColor *)c22Color
{
    return [self colorWithRGBHex:273748];
}

/**
 *  C23的颜色
 */
+(UIColor *)c23Color
{
    return [self colorWithRGBHex:0x34495e];
}

/**
 *  C24的颜色
 */
+(UIColor *)c24Color
{
    return [self colorWithRGBHex:0xb1d52f];
}

/*
 *  C25的颜色
 */
+(UIColor *)c25Color
{
    return [self colorWithRGBHex:0x5F87DC];
}

+ (UIColor *)randomColor {
    return [UIColor colorWithRed:(CGFloat)RAND_MAX / random()
                           green:(CGFloat)RAND_MAX / random()
                            blue:(CGFloat)RAND_MAX / random()
                           alpha:1.0f];
}

+ (UIColor *)colorWithRGBHex:(UInt32)hex {
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:1.0f];
}

@end
