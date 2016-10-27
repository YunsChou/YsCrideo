//
//  YsMacro.h
//  YsCrideo
//
//  Created by weiying on 16/10/26.
//  Copyright © 2016年 yunschou. All rights reserved.
//

#ifndef YsMacro_h
#define YsMacro_h

//设备系统版本
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

//设备屏幕尺寸
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width

//以iPhone6屏幕宽度为基准，定义比例
#define SCREEN_SCALE (SCREEN_WIDTH / 375)

/**
 *  调试模式下的打印输出
 */
#ifdef DEBUG
#define DLog(...) NSLog(__VA_ARGS__)
#else
#define DLog(...)
#endif


#endif /* YsMacro_h */
