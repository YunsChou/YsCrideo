//
//  DetailTopImageView.h
//  Crideo
//
//  Created by weiying on 16/9/20.
//  Copyright © 2016年 yunschou. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HomeListModel;

@interface DetailTopImageView : UIView

@property (nonatomic, strong) HomeListModel *homeListM;

/**
 顶部图片左右滑动视差效果
 */
- (void)topImageOffset;


/**
 切换内容，销毁上一个视屏播放器
 */
- (void)destroyVideoPlayer;
@end
