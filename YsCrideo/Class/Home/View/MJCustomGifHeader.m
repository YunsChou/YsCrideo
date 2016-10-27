//
//  MJCustomGifHeader.m
//  Crideo
//
//  Created by weiying on 16/9/19.
//  Copyright © 2016年 yunschou. All rights reserved.
//

#import "MJCustomGifHeader.h"

@implementation MJCustomGifHeader

- (void)prepare
{
    [super prepare];
    
    //隐藏下拉刷新label
    self.stateLabel.hidden = YES;
    self.lastUpdatedTimeLabel.hidden = YES;
    
    NSMutableArray *refreshImgArr = [NSMutableArray array];
    for (NSInteger i = 0; i <= 63; i ++) {
        NSString *imgName = [NSString stringWithFormat:@"refresh_load_%02ld",i];
        [refreshImgArr addObject:[UIImage imageNamed:imgName]];
    }
    
    // 设置普通状态的动画图片
    [self setImages:refreshImgArr forState:MJRefreshStateIdle];
    
    // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
    [self setImages:refreshImgArr forState:MJRefreshStatePulling];
    
    // 设置正在刷新状态的动画图片
    [self setImages:refreshImgArr forState:MJRefreshStateRefreshing];
}

@end
