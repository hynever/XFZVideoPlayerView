//
//  XFZSinglenMacro.h
//  xfz
//
//  Created by 黄勇 on 15/7/22.
//  Copyright (c) 2015年 xfz. All rights reserved.
//

#ifndef xfz_XFZSinglenMacro_h
#define xfz_XFZSinglenMacro_h

/************************使用单例的宏************************/
#define singleton_h(name) + (instancetype)shared##name;
#define singleton_m(name) \
static id _instance; \
+ (id)allocWithZone:(struct _NSZone *)zone \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken,^{ \
_instance = [super allocWithZone:zone]; \
}); \
return _instance; \
} \
\
+ (instancetype)shared##name \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken,^{ \
_instance = [[self alloc] init]; \
}); \
return _instance; \
} \
\
+ (id)copyWithZone:(struct _NSZone *)zone \
{ \
return _instance; \
}


#endif
