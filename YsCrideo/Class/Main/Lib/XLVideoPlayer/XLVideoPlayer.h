//
//  XLVideoPlayer.h
//  XLVideoPlayer
//
//  Created by Shelin on 16/3/23.
//  Copyright © 2016年 GreatGate. All rights reserved.
//  https://github.com/ShelinShelin
//  博客：http://www.jianshu.com/users/edad244257e2/latest_articles

#import <UIKit/UIKit.h>

@class XLVideoPlayer;
@class XLSlider;
typedef void (^VideoCompletedPlayingBlock) (XLVideoPlayer *videoPlayer);
typedef void (^VideoPlayStartBlock) ();
typedef void (^VideoPlayPauseBlock) ();
typedef void (^VideoPlayerDraggingBlock) (NSInteger startTime);
typedef void (^VideoPlayerEndDragBlock) (NSInteger endTime);
typedef void (^VideoPlayerScrollDestoryBlock) ();
typedef void (^VideoCompletedNotDestoryBlock)();
typedef void (^VideoPlayerShareBlock) ();
typedef void (^VideoPlayerScreenBlock) (BOOL isFull);

@interface XLVideoPlayer : UIView

@property (nonatomic, copy) VideoCompletedPlayingBlock completedPlayingBlock;
@property (nonatomic, copy) VideoCompletedNotDestoryBlock completedNotDestoryBlock;
@property (nonatomic, copy) VideoPlayStartBlock playStartBlock;
@property (nonatomic, copy) VideoPlayPauseBlock playPauseBlock;
@property (nonatomic, copy) VideoPlayerScrollDestoryBlock playerScrollDestoryBlock;
@property (nonatomic, copy) VideoPlayerDraggingBlock playerDraggingBlock;
@property (nonatomic, copy) VideoPlayerEndDragBlock playerEndDragBlock;
@property (nonatomic, copy) VideoPlayerShareBlock playerShareBlock;
@property (nonatomic, copy) VideoPlayerScreenBlock playerScreenBlock;
/**
 *  video url 视频路径
 */
@property (nonatomic, strong) NSString *videoUrl;
/**
 *  跳到time处播放
 */
@property (nonatomic, assign) double seekTime;
/**
 *  全屏时的标题
 */
@property (nonatomic, copy) NSString *titleText;
/**
 *  小屏时的时间
 */
@property (nonatomic, copy) NSString *timeText;
/**是否全屏
 *
 */
@property (nonatomic, assign) BOOL isFullScreen;

- (void)smallScreen;

/**
 *  play or pause
 */
- (void)playPause;

- (void)playerPlay;

- (void)playerPause;

/**
 *  dealloc 销毁
 */
- (void)destroyPlayer;


/**
 *  获取正在播放的时间点
 */
- (double)currentTime;

/**
 *  在cell上播放必须绑定TableView、当前播放cell的IndexPath
 */
- (void)playerBindTableView:(UITableView *)bindTableView currentIndexPath:(NSIndexPath *)currentIndexPath;

/**
 *  在scrollview的scrollViewDidScroll代理中调用
 *
 *  @param support        是否支持右下角小窗悬停播放
 */
- (void)playerScrollIsSupportSmallWindowPlay:(BOOL)support;

@end
