//
//  DetailTopImageView.m
//  Crideo
//
//  Created by weiying on 16/9/20.
//  Copyright © 2016年 yunschou. All rights reserved.
//

#import "DetailTopImageView.h"
#import "UIImageView+WebCache.h"
//Model
#import "HomeListModel.h"
//View
#import "XLVideoPlayer.h"

@interface DetailTopImageView ()
@property (nonatomic, strong) UIImageView *topImgView;
@property (nonatomic, strong) UIButton *playBtn;

@property (nonatomic, strong) XLVideoPlayer *player;
@property (nonatomic, assign) NSInteger slideDragTime;
@end

@implementation DetailTopImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor blackColor];
        
        UIImageView *topImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        topImageView.contentMode = UIViewContentModeScaleAspectFill;
        topImageView.userInteractionEnabled = YES;
        [self addSubview:topImageView];
        self.topImgView = topImageView;
        //创建播放按钮
        [self setupPlayBtn];
        //添加通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detailStatusBarOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    }
    return self;
}


- (void)setupPlayBtn
{
    CGFloat palyBtnWH = 60 * SCREEN_SCALE;
    UIButton *playBtn = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - palyBtnWH) / 2, (kDetailTopImageHeight - palyBtnWH) / 2, palyBtnWH, palyBtnWH)];
    [playBtn setImage:[UIImage imageNamed:@"icon_video_play"] forState:UIControlStateNormal];
    [playBtn addTarget:self action:@selector(playBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:playBtn];
    self.playBtn = playBtn;
}

- (void)setHomeListM:(HomeListModel *)homeListM
{
    _homeListM = homeListM;
    [self.topImgView sd_setImageWithURL:[NSURL URLWithString:homeListM.localData.coverURL]];
}

/**
 顶部图片左右滑动视差效果
 */
- (void)topImageOffset
{
    CGRect centerToWindow = [self convertRect:self.bounds toView:nil];
    CGFloat centerX = CGRectGetMidX(centerToWindow);
    CGPoint windowCenter = self.window.center;
    CGFloat cellOffsetX = centerX - windowCenter.x;
    CGFloat offsetDig =  cellOffsetX / self.window.frame.size.height *2;
    CGAffineTransform transX = CGAffineTransformMakeTranslation(- offsetDig * SCREEN_WIDTH * 0.7, 0);
    self.topImgView.transform = transX;
}

#pragma mark - 播放按钮点击
- (void)playBtnClick
{
    //添加视屏播放
    XLVideoPlayer *player = [[XLVideoPlayer alloc] init];
    player.frame = self.bounds;
    __weak typeof(self) weakSelf = self;
    //播放完成
    player.completedPlayingBlock = ^(XLVideoPlayer *videoPlayer){
        [weakSelf destroyVideoPlayer];
    };
    //分享
    player.playerShareBlock = ^(){
        [weakSelf.player playerPause];
        [weakSelf shareVideoWithFacebook];
    };
        //播放时长统计
    __block NSInteger thisDragTime = 0;
    _player.playerDraggingBlock = ^(NSInteger startTime){
        thisDragTime = startTime;
    };
    _player.playerEndDragBlock = ^(NSInteger endTime){
        thisDragTime = endTime - thisDragTime;
        weakSelf.slideDragTime += thisDragTime;
    };

    player.videoUrl = _homeListM.localData.playURL;
    player.titleText = _homeListM.localData.title;
    [self addSubview:player];
    self.player = player;

}

#pragma mark - 分享按钮点击
- (void)shareVideoWithFacebook
{
    DLog(@"分享视频到Facebook-- ");

}

#pragma mark - 结束视屏播放及上报播放时长
- (void)destroyVideoPlayer
{
    if (_player) {
        //销毁动画
        [UIView animateWithDuration:0.2 animations:^{
            self.player.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.player destroyPlayer];
            self.player = nil;
        }];
    }
}

#pragma mark - 接收通知
- (void)detailStatusBarOrientationChange:(NSNotification *)notification {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (orientation == UIDeviceOrientationPortrait) {//如果切换到竖屏的话，将player，放到当前view上
        if (self.player) {
            [self addSubview:_player];
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];;
}

@end
