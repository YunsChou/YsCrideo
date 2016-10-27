//
//  XLVideoPlayer.m
//  XLVideoPlayer
//
//  Created by Shelin on 16/3/23.
//  Copyright © 2016年 GreatGate. All rights reserved.
//  https://github.com/ShelinShelin
//  博客：http://www.jianshu.com/users/edad244257e2/latest_articles

#import "XLVideoPlayer.h"
#import "XLSlider.h"
#import <AVFoundation/AVFoundation.h>

//以iPhone6屏幕宽度为基准，定义比例
#define PlayBtnSizeWH (40 * SCREEN_SCALE)

static CGFloat const barAnimateSpeed = 0.5f;
static CGFloat const barShowDuration = 2.0f;
static CGFloat const opacity = 0.7f;
static CGFloat const bottomBaHeight = 40.0f;

@interface XLVideoPlayer ()

/**videoPlayer superView*/
@property (nonatomic, strong) UIView *playSuprView;
@property (nonatomic, strong) UIView *topBar;
@property (nonatomic, strong) UIView *fullBottomBar;
@property (nonatomic, strong) XLSlider *fullSlider;

@property (nonatomic, strong) UILabel *fullTitleLabel;
@property (nonatomic, strong) UIButton *fullShareBtn;
@property (nonatomic, strong) UIButton *fullScreenBtn;
@property (nonatomic, strong) UILabel *totalTimeLabel;
@property (nonatomic, strong) UILabel *playTimeLabel;

@property (nonatomic, strong) UIButton *playOrPauseBtn;
@property (nonatomic, strong) UIWindow *keyWindow;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, assign) CGRect playerOriginalFrame;

@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
/**video player*/
@property (nonatomic,strong) AVPlayer *player;
/**video total duration*/
@property (nonatomic, assign) CGFloat totalDuration;
@property (nonatomic, assign) CGFloat current;

@property (nonatomic, strong) UITableView *bindTableView;
@property (nonatomic, assign) CGRect currentPlayCellRect;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;

@property (nonatomic, assign) BOOL isOriginalFrame;
@property (nonatomic, assign) BOOL barHiden;
@property (nonatomic, assign) BOOL inOperation;
@property (nonatomic, assign) BOOL smallWinPlaying;

@property (nonatomic, assign) BOOL isDragSliderPlay;
@end

@implementation XLVideoPlayer

#pragma mark - public method

- (instancetype)init {
    if (self = [super init]) {
        
        self.backgroundColor = [UIColor blackColor];
        
        self.keyWindow = [UIApplication sharedApplication].keyWindow;

        //screen orientation change
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
        
        //show or hiden gestureRecognizer
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showOrHidenBar)];
        [self addGestureRecognizer:tap];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appwillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        self.barHiden = YES;
    }
    return self;
}

- (void)setVideoUrl:(NSString *)videoUrl {
    _videoUrl = videoUrl;
    
    [self.layer addSublayer:self.playerLayer];
    [self insertSubview:self.activityIndicatorView belowSubview:self.playOrPauseBtn];
    [self.activityIndicatorView startAnimating];
    //play from start
    [self playOrPause:self.playOrPauseBtn];
//    [self addSubview:self.smallBottomBar];
    [self addSubview:self.fullBottomBar];
    [self addSubview:self.topBar];
    [self insertSubview:self.playOrPauseBtn aboveSubview:self.activityIndicatorView];
    
}

- (void)setSeekTime:(double)seekTime
{
    _seekTime = seekTime;
}

- (void)playerPlay
{
    self.playOrPauseBtn.selected = YES;
    [self.player play];
    [self hiden];
}

- (void)playerPause
{
    [self.player pause];
    self.playOrPauseBtn.selected = NO;
}

- (void)playPause {
    [self playOrPause:self.playOrPauseBtn];
}

- (void)destroyPlayer {
    [self.player pause];
    [self.player.currentItem cancelPendingSeeks];
    [self.player.currentItem.asset cancelLoading];
    [self.fullSlider removeFromSuperview];
    self.fullSlider = nil;
    [self removeFromSuperview];
}

- (void)playerBindTableView:(UITableView *)bindTableView currentIndexPath:(NSIndexPath *)currentIndexPath {
    self.bindTableView = bindTableView;
    self.currentIndexPath = currentIndexPath;
}

- (void)playerScrollIsSupportSmallWindowPlay:(BOOL)support {
    
    NSAssert(self.bindTableView != nil, @"必须绑定对应的tableview！！！");
    
    self.currentPlayCellRect = [self.bindTableView rectForRowAtIndexPath:self.currentIndexPath];
    self.currentIndexPath = self.currentIndexPath;
    
    CGFloat cellBottom = self.currentPlayCellRect.origin.y + self.currentPlayCellRect.size.height;
    CGFloat cellUp = self.currentPlayCellRect.origin.y;
    
    if (self.bindTableView.contentOffset.y > cellBottom) {
        if (!support) {
            if (self.playerScrollDestoryBlock) {
                self.playerScrollDestoryBlock();
            }
            [self destroyPlayer];
            return;
        }
        [self smallWindowPlay];
        return;
    }
    
    if (cellUp > self.bindTableView.contentOffset.y + self.bindTableView.frame.size.height) {
        if (!support) {
            if (self.playerScrollDestoryBlock) {
                self.playerScrollDestoryBlock();
            }
            [self destroyPlayer];
            return;
        }
        [self smallWindowPlay];
        return;
    }
    
    if (self.bindTableView.contentOffset.y < cellBottom){
        if (!support) return;
        [self returnToOriginView];
        return;
    }
    
    if (cellUp < self.bindTableView.contentOffset.y + self.bindTableView.frame.size.height){
        if (!support) return;
        [self returnToOriginView];
        return;
    }
}

#pragma mark - layoutSubviews

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.playerLayer.frame = self.bounds;
    
    if (!self.isOriginalFrame) {
        self.playerOriginalFrame = self.frame;
        self.playSuprView = self.superview;
        self.topBar.frame = CGRectMake(0, 0, self.playerOriginalFrame.size.width, bottomBaHeight);

        self.fullBottomBar.frame = CGRectMake(0, self.playerOriginalFrame.size.height - bottomBaHeight, self.playerOriginalFrame.size.width, bottomBaHeight);
        self.playOrPauseBtn.frame = CGRectMake((self.playerOriginalFrame.size.width - PlayBtnSizeWH) / 2, (self.playerOriginalFrame.size.height - PlayBtnSizeWH) / 2, PlayBtnSizeWH, PlayBtnSizeWH);
        self.activityIndicatorView.center = CGPointMake(self.playerOriginalFrame.size.width / 2, self.playerOriginalFrame.size.height / 2);
        self.isOriginalFrame = YES;
    }
}

#pragma mark - status hiden

- (void)setStatusBarHidden:(BOOL)hidden {
//    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
//    statusBar.hidden = hidden;
}

#pragma mark - Screen Orientation

- (void)statusBarOrientationChange:(NSNotification *)notification {
    if (self.smallWinPlaying) return;
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (orientation == UIDeviceOrientationLandscapeLeft) {
        [self orientationLeftFullScreen];
    }else if (orientation == UIDeviceOrientationLandscapeRight) {
        [self orientationRightFullScreen];
    }else if (orientation == UIDeviceOrientationPortrait) {
        [self smallScreen];
    }
}

- (void)actionFullScreen {
    //全屏/小屏切换回调
    if (_playerScreenBlock) {
        _playerScreenBlock(_isFullScreen);
    }
    //全屏/小屏切换
    if (!self.isFullScreen) {
        [self orientationLeftFullScreen];
    }else {
        [self smallScreen];
    }
}

- (void)orientationLeftFullScreen {
    
    self.isFullScreen = YES;
    [self changeOrientationHideUI];
    self.fullScreenBtn.selected = YES;
    [self.keyWindow addSubview:self];
    
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];
    [self updateConstraintsIfNeeded];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformMakeRotation(M_PI / 2);
        self.frame = self.keyWindow.bounds;
        self.topBar.frame = CGRectMake(0, 0, self.keyWindow.bounds.size.height, bottomBaHeight);
        self.fullBottomBar.frame = CGRectMake(0, self.keyWindow.bounds.size.width - bottomBaHeight, self.keyWindow.bounds.size.height, bottomBaHeight);
        self.playOrPauseBtn.frame = CGRectMake((self.keyWindow.bounds.size.height - PlayBtnSizeWH) / 2, (self.keyWindow.bounds.size.width - PlayBtnSizeWH) / 2, PlayBtnSizeWH, PlayBtnSizeWH);
        self.activityIndicatorView.center = CGPointMake(self.keyWindow.bounds.size.height / 2, self.keyWindow.bounds.size.width / 2);
    }];
    
    [self setStatusBarHidden:YES];
}

- (void)orientationRightFullScreen {
    
    self.isFullScreen = YES;
    [self changeOrientationHideUI];
    self.fullScreenBtn.selected = YES;
    [self.keyWindow addSubview:self];
    
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeRight] forKey:@"orientation"];
    
    [self updateConstraintsIfNeeded];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformMakeRotation(-M_PI / 2);
        self.frame = self.keyWindow.bounds;
        self.topBar.frame = CGRectMake(0, 0, self.keyWindow.bounds.size.height, bottomBaHeight);
        self.fullBottomBar.frame = CGRectMake(0, self.keyWindow.bounds.size.width - bottomBaHeight, self.keyWindow.bounds.size.height, bottomBaHeight);
        self.playOrPauseBtn.frame = CGRectMake((self.keyWindow.bounds.size.height - PlayBtnSizeWH) / 2, (self.keyWindow.bounds.size.width - PlayBtnSizeWH) / 2, PlayBtnSizeWH, PlayBtnSizeWH);
        self.activityIndicatorView.center = CGPointMake(self.keyWindow.bounds.size.height / 2, self.keyWindow.bounds.size.width / 2);
    }];
    [self setStatusBarHidden:YES];
}

- (void)smallScreen {
    
    self.isFullScreen = NO;
    [self changeOrientationHideUI];
    self.fullScreenBtn.selected = NO;
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
   
    if (self.bindTableView) {
        UITableViewCell *cell = [self.bindTableView cellForRowAtIndexPath:self.currentIndexPath];
        [cell.contentView addSubview:self];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformMakeRotation(0);
        self.frame = self.playerOriginalFrame;
        self.topBar.frame = CGRectMake(0, 0, self.playerOriginalFrame.size.width, bottomBaHeight);
        self.fullBottomBar.frame = CGRectMake(0, self.playerOriginalFrame.size.height - bottomBaHeight, self.playerOriginalFrame.size.width, bottomBaHeight);
        self.playOrPauseBtn.frame = CGRectMake((self.playerOriginalFrame.size.width - PlayBtnSizeWH) / 2, (self.playerOriginalFrame.size.height - PlayBtnSizeWH) / 2, PlayBtnSizeWH, PlayBtnSizeWH);
        self.activityIndicatorView.center = CGPointMake(self.playerOriginalFrame.size.width / 2, self.playerOriginalFrame.size.height / 2);
        [self updateConstraintsIfNeeded];
    }];
    [self setStatusBarHidden:NO];
}

- (void)actionShareFacebook
{
    //如果最大化就变成最小
    if (self.isFullScreen) {
        [self smallScreen];
    }
    
    if (self.playerShareBlock) {
        self.playerShareBlock();
    }
}

#pragma mark - app notif

- (void)appDidEnterBackground:(NSNotification*)note {
    
    NSLog(@"appDidEnterBackground");
}

- (void)appWillEnterForeground:(NSNotification*)note {
    NSLog(@"appWillEnterForeground");
}

- (void)appwillResignActive:(NSNotification *)note {
    NSLog(@"appwillResignActive");
//    [self playOrPause:self.playOrPauseBtn];
    [self.player pause];
    self.playOrPauseBtn.selected = NO;
    [self show];
}

- (void)appBecomeActive:(NSNotification *)note {
    NSLog(@"appBecomeActive");
//    [self playOrPause:self.playOrPauseBtn];
//    [self.player pause];
}

#pragma mark - button action

- (void)playOrPause:(UIButton *)btn {
    if(self.player.rate == 0.0){      //pause
        btn.selected = YES;
        [self.player play];
        [self hiden];
        //播放回调
        if (self.playStartBlock) {
            self.playStartBlock();
        }
    }else if(self.player.rate == 1.0f){    //playing
        [self.player pause];
        btn.selected = NO;
        //暂停回调
        if (self.playPauseBlock) {
            self.playPauseBlock();
        }
    }
}

- (void)showOrHidenBar {
    if (self.barHiden) {
        [self show];
    }else {
        [self hiden];
    }
}

- (void)show {
    [UIView animateWithDuration:barAnimateSpeed animations:^{
        self.topBar.layer.opacity = opacity;
        self.fullBottomBar.layer.opacity = opacity;
        self.playOrPauseBtn.layer.opacity = opacity;
        [self changeOrientationHideUI];
    } completion:^(BOOL finished) {
        if (finished) {
//            self.barHiden = !self.barHiden;
            self.barHiden = NO;
            [self performBlock:^{
                if (!self.barHiden && !self.inOperation && self.playOrPauseBtn.selected) {
                    [self hiden];
                }
            } afterDelay:barShowDuration];
        }
    }];
}


/**
 显示或隐藏控件
 */
- (void)changeOrientationHideUI
{
    if (_isFullScreen) {
        self.fullTitleLabel.hidden = NO;
        self.fullShareBtn.hidden = NO;
    }else{
        self.fullTitleLabel.hidden = YES;
        self.fullShareBtn.hidden = YES;
    }
}

- (void)hiden {
    self.inOperation = NO;
    [UIView animateWithDuration:barAnimateSpeed animations:^{
        self.topBar.layer.opacity = 0.0f;
        self.fullBottomBar.layer.opacity = 0.0f;
        self.playOrPauseBtn.layer.opacity = 0.0f;
    } completion:^(BOOL finished){
        if (finished) {
            self.barHiden = YES;
        }
    }];
}

#pragma mark - call back

- (void)sliderValueChange:(XLSlider *)slider {
    self.playTimeLabel.text = [self timeFormatted:slider.value * self.totalDuration];
}

- (void)finishChange {
    self.inOperation = NO;
    [self performBlock:^{
        if (!self.barHiden && !self.inOperation) {
            [self hiden];
        }
    } afterDelay:barShowDuration];
    
//    [self.player pause];
    CMTime currentCMTime = CMTimeMake(self.fullSlider.value * self.totalDuration, 1);
    DLog(@"currentCMTime -- %f", self.fullSlider.value);
    if (self.fullSlider.middleValue) {
        [self.player seekToTime:currentCMTime completionHandler:^(BOOL finished) {
            if (_isDragSliderPlay) {
                [self.player play];
                self.playOrPauseBtn.selected = YES;
            }
        }];
    }
}

//Dragging the thumb to suspend video playback

- (void)dragSlider {
    
    _isDragSliderPlay = self.playOrPauseBtn.isSelected;
    self.inOperation = YES;
    [self.player pause];
}

- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay {
    [self performSelector:@selector(callBlockAfterDelay:) withObject:block afterDelay:delay];
}

- (void)callBlockAfterDelay:(void (^)(void))block {
    block();
}

#pragma mark - monitor video playing course

-(void)addProgressObserver{
    
    //get current playerItem object
    AVPlayerItem *playerItem = self.player.currentItem;
    __weak typeof(self) weakSelf = self;
    
    //Set once per second
    [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.1f, NSEC_PER_SEC)  queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        float current = CMTimeGetSeconds(time);
        weakSelf.current = current;
        float total = CMTimeGetSeconds([playerItem duration]);
        weakSelf.playTimeLabel.text = [weakSelf timeFormatted:current];
        
        if (current) {
//            NSLog(@"current --- %f", current );
//            weakSelf.smallTimeLabel.text = [weakSelf timeFormatted:(total - current)];
            
            if (!weakSelf.inOperation) {
                weakSelf.fullSlider.value = current / total;
            }
            if (weakSelf.fullSlider.value == 1.0f) {      //complete block
                if (weakSelf.isFullScreen) {
                    [weakSelf smallScreen];
                }
                //播放完成
                if (weakSelf.completedPlayingBlock) {
                    [weakSelf setStatusBarHidden:NO];
                    if ( weakSelf.completedPlayingBlock) {
                        weakSelf.completedPlayingBlock(weakSelf);
                    }
                    weakSelf.completedPlayingBlock = nil;
                }else {       //finish and loop playback
                    if (weakSelf.completedNotDestoryBlock) {
                        weakSelf.completedNotDestoryBlock();
                    }
                    
                    weakSelf.playOrPauseBtn.selected = NO;
                    [weakSelf showOrHidenBar];
                    CMTime currentCMTime = CMTimeMake(0, 1);
                    [weakSelf.player seekToTime:currentCMTime completionHandler:^(BOOL finished) {
                        weakSelf.fullSlider.value = 0.0f;
                    }];
                }
            }
        }
    }];
}

#pragma mark - PlayerItem （status，loadedTimeRanges）

-(void)addObserverToPlayerItem:(AVPlayerItem *)playerItem{
    
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //network loading progress
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}

/**
 *  通过KVO监控播放器状态
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *playerItem = object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue];
        if(status == AVPlayerStatusReadyToPlay){
            // 跳到xx秒播放视频
            if (self.seekTime) {
                [self seekToTimeToPlay:self.seekTime];
            }
            
            self.totalDuration = CMTimeGetSeconds(playerItem.duration);
            self.totalTimeLabel.text = [self timeFormatted:self.totalDuration];
        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray *array = playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度

        self.fullSlider.middleValue = totalBuffer / CMTimeGetSeconds(playerItem.duration);
        
        //loading animation
        if (self.fullSlider.middleValue <= self.fullSlider.value || (totalBuffer - 1.0) < self.current) {
            DLog(@"正在缓冲...");
            self.activityIndicatorView.hidden = NO;
            [self.activityIndicatorView startAnimating];
        }else {
            self.activityIndicatorView.hidden = YES;
            if (self.playOrPauseBtn.selected) {
                [self.player play];
            }
        }
    }
}

/**
 *  跳到time处播放
 */
- (void)seekToTimeToPlay:(double)time{
    if (self.player&&self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        if (time>[self duration]) {
            time = [self duration];
        }
        if (time<=0) {
            time=0.0;
        }

        [self.player seekToTime:CMTimeMakeWithSeconds(time, self.playerItem.currentTime.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            
        }];

    }
}

///获取视频长度
- (double)duration{
    AVPlayerItem *playerItem = self.player.currentItem;
    if (playerItem.status == AVPlayerItemStatusReadyToPlay){
        return CMTimeGetSeconds([[playerItem asset] duration]);
    }
    else{
        return 0.f;
    }
}

///获取视频当前播放的时间
- (double)currentTime{
    if (self.player) {
        return CMTimeGetSeconds([self.player currentTime]);
    }else{
        return 0.0;
    }
}


#pragma mark - timeFormat

- (NSString *)timeFormatted:(int)totalSeconds {

    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    NSString *showtimeNew = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    return showtimeNew;
}

#pragma mark - animation smallWindowPlay

- (void)smallWindowPlay {
    if ([self.superview isKindOfClass:[UIWindow class]]) return;
    self.smallWinPlaying = YES;
    self.playOrPauseBtn.hidden = YES;
    self.fullBottomBar.hidden = YES;
    CGRect tableViewframe = [self.bindTableView convertRect:self.bindTableView.bounds toView:self.keyWindow];
    self.frame = [self convertRect:self.frame toView:self.keyWindow];
    [self.keyWindow addSubview:self];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        CGFloat w = self.playerOriginalFrame.size.width * 0.5;
        CGFloat h = self.playerOriginalFrame.size.height * 0.5;
        CGRect smallFrame = CGRectMake(tableViewframe.origin.x + tableViewframe.size.width - w, tableViewframe.origin.y + tableViewframe.size.height - h, w, h);
        self.frame = smallFrame;
        self.playerLayer.frame = self.bounds;
        self.activityIndicatorView.center = CGPointMake(w / 2.0, h / 2.0);
    }];
}

- (void)returnToOriginView {
    if (![self.superview isKindOfClass:[UIWindow class]]) return;
    self.smallWinPlaying = NO;
    self.playOrPauseBtn.hidden = NO;
    self.fullBottomBar.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        
        self.frame = CGRectMake(self.currentPlayCellRect.origin.x, self.currentPlayCellRect.origin.y, self.playerOriginalFrame.size.width, self.playerOriginalFrame.size.height);
        self.playerLayer.frame = self.bounds;
        self.activityIndicatorView.center = CGPointMake(self.playerOriginalFrame.size.width / 2, self.playerOriginalFrame.size.height / 2);
    } completion:^(BOOL finished) {
        self.frame = self.playerOriginalFrame;
        UITableViewCell *cell = [self.bindTableView cellForRowAtIndexPath:self.currentIndexPath];
        [cell.contentView addSubview:self];
    }];
}

#pragma mark - lazy loading

- (AVPlayerLayer *)playerLayer {
    if (!_playerLayer) {
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        _playerLayer.backgroundColor = [UIColor blackColor].CGColor;
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;//视频填充模式
    }
    return _playerLayer;
}

- (AVPlayer *)player{
    if (!_player) {
        AVPlayerItem *playerItem = [self getAVPlayItem];
        self.playerItem = playerItem;
        _player = [AVPlayer playerWithPlayerItem:playerItem];
        
        [self addProgressObserver];
        
        [self addObserverToPlayerItem:playerItem];
        
        // 解决8.1系统播放无声音问题，8.0、9.0以上未发现此问题
        AVAudioSession * session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
        [session setActive:YES error:nil];
    }
    return _player;
}

//initialize AVPlayerItem
- (AVPlayerItem *)getAVPlayItem{
    
    NSAssert(self.videoUrl != nil, @"必须先传入视频url！！！");
    
    if ([self.videoUrl rangeOfString:@"http"].location != NSNotFound) {
        AVPlayerItem *playerItem=[AVPlayerItem playerItemWithURL:[NSURL URLWithString:[self.videoUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        return playerItem;
    }else{
        AVAsset *movieAsset  = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:self.videoUrl] options:nil];
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
        return playerItem;
    }
}

- (UIActivityIndicatorView *)activityIndicatorView {
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [self insertSubview:_activityIndicatorView aboveSubview:self.playOrPauseBtn];

    }
    return _activityIndicatorView;
}

- (void)setTitleText:(NSString *)titleText
{
    _titleText = titleText;
    self.fullTitleLabel.text = titleText;
}

- (void)setTimeText:(NSString *)timeText
{
    _timeText = timeText;
}

- (UIView *)topBar
{
    if (!_topBar) {
        UIView *topBar = [[UIView alloc] init];
        topBar.backgroundColor = [UIColor clearColor];
        topBar.layer.opacity = 0.0f;
        self.topBar = topBar;
        //返回按钮
        UIButton *backBtn = [[UIButton alloc] init];
        [backBtn setImage:[UIImage imageNamed:@"icon_back_btn"] forState:UIControlStateNormal];
        backBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [backBtn addTarget:self action:@selector(actionFullScreen) forControlEvents:UIControlEventTouchUpInside];
        [topBar addSubview:backBtn];
        
        NSLayoutConstraint *btnLeft = [NSLayoutConstraint constraintWithItem:backBtn attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:topBar attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0];
        NSLayoutConstraint *btnCenterY = [NSLayoutConstraint constraintWithItem:backBtn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:topBar attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0];
        NSLayoutConstraint *btnWidth = [NSLayoutConstraint constraintWithItem:backBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0f constant:60.0];
        NSLayoutConstraint *btnHeight = [NSLayoutConstraint constraintWithItem:backBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0f constant:40.0];
        [topBar addConstraints:@[btnLeft, btnCenterY, btnWidth, btnHeight]];
        //分享按钮
        UIButton *shareBtn = [[UIButton alloc] init];
        [shareBtn setImage:[UIImage imageNamed:@"icon_share_facebook"] forState:UIControlStateNormal];
        shareBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [shareBtn addTarget:self action:@selector(actionShareFacebook) forControlEvents:UIControlEventTouchUpInside];
        [topBar addSubview:shareBtn];
        
        NSLayoutConstraint *shareBtnRight = [NSLayoutConstraint constraintWithItem:shareBtn attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:topBar attribute:NSLayoutAttributeRight multiplier:1.0f constant:0];
        NSLayoutConstraint *sharebtnCenterY = [NSLayoutConstraint constraintWithItem:shareBtn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:topBar attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0];
        NSLayoutConstraint *shareBtnWidth = [NSLayoutConstraint constraintWithItem:shareBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0f constant:60.0];
        NSLayoutConstraint *shareBtnHeight = [NSLayoutConstraint constraintWithItem:shareBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0f constant:40.0];
        [topBar addConstraints:@[shareBtnRight, sharebtnCenterY, shareBtnWidth, shareBtnHeight]];
        self.fullShareBtn = shareBtn;
        //标题
        UILabel *titileLabel = [[UILabel alloc] init];
        titileLabel.translatesAutoresizingMaskIntoConstraints = NO;
        titileLabel.textAlignment = NSTextAlignmentLeft;
        titileLabel.font = [UIFont systemFontOfSize:16.0f];
        titileLabel.textColor = [UIColor whiteColor];
        [topBar addSubview:titileLabel];
        NSLayoutConstraint *titleLeft = [NSLayoutConstraint constraintWithItem:titileLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:backBtn attribute:NSLayoutAttributeRight multiplier:1.0f constant:0];
        NSLayoutConstraint *titleRight = [NSLayoutConstraint constraintWithItem:titileLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:shareBtn attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0];
        titleRight.priority = UILayoutPriorityDefaultLow;
        NSLayoutConstraint *titleCenterY = [NSLayoutConstraint constraintWithItem:titileLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:topBar attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0];
        NSLayoutConstraint *titleHeight = [NSLayoutConstraint constraintWithItem:titileLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:topBar attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0];
        [topBar addConstraints:@[titleLeft, titleRight, titleCenterY, titleHeight]];
        self.fullTitleLabel = titileLabel;
        
        titileLabel.hidden = YES;
        shareBtn.hidden = YES;
        
        [self updateConstraintsIfNeeded];
    }
    return _topBar;
}

- (UIView *)fullBottomBar
{
    if (!_fullBottomBar) {
        UIView * fullBottomBar = [[UIView alloc] init];
        fullBottomBar.backgroundColor = [UIColor blackColor];
        fullBottomBar.layer.opacity = 0.0f;
        self.fullBottomBar = fullBottomBar;
        
        UILabel *label1 = [[UILabel alloc] init];
        label1.translatesAutoresizingMaskIntoConstraints = NO;
        label1.textAlignment = NSTextAlignmentCenter;
        label1.text = @"00:00";
        label1.font = [UIFont systemFontOfSize:12.0f];
        label1.textColor = [UIColor whiteColor];
        [fullBottomBar addSubview:label1];
        self.playTimeLabel = label1;
        
        NSLayoutConstraint *label1Left = [NSLayoutConstraint constraintWithItem:label1 attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:fullBottomBar attribute:NSLayoutAttributeLeft multiplier:1.0f constant:15];
        NSLayoutConstraint *label1Top = [NSLayoutConstraint constraintWithItem:label1 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:fullBottomBar attribute:NSLayoutAttributeTop multiplier:1.0f constant:0];
        NSLayoutConstraint *label1Bottom = [NSLayoutConstraint constraintWithItem:label1 attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:fullBottomBar attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0];
        NSLayoutConstraint *label1Width = [NSLayoutConstraint constraintWithItem:label1 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0f constant:45.0f];
        [fullBottomBar addConstraints:@[label1Left, label1Top, label1Bottom, label1Width]];
        
        
        UIButton *fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        fullScreenBtn.translatesAutoresizingMaskIntoConstraints = NO;
        fullScreenBtn.contentMode = UIViewContentModeCenter;
        [fullScreenBtn setImage:[UIImage imageNamed:@"icon_video_full"] forState:UIControlStateNormal];
        [fullScreenBtn setImage:[UIImage imageNamed:@"icon_video_small"] forState:UIControlStateSelected];
        [fullScreenBtn addTarget:self action:@selector(actionFullScreen) forControlEvents:UIControlEventTouchUpInside];
        [fullBottomBar addSubview:fullScreenBtn];
        self.fullScreenBtn = fullScreenBtn;
        
        
        NSLayoutConstraint *btnWidth = [NSLayoutConstraint constraintWithItem:fullScreenBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0f constant:40.0f];
        NSLayoutConstraint *btnHeight = [NSLayoutConstraint constraintWithItem:fullScreenBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0f constant:40.0f];
        NSLayoutConstraint *btnRight = [NSLayoutConstraint constraintWithItem:fullScreenBtn attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:fullBottomBar attribute:NSLayoutAttributeRight multiplier:1.0f constant:-10];
        NSLayoutConstraint *btnCenterY = [NSLayoutConstraint constraintWithItem:fullScreenBtn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:fullBottomBar attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0];
        [fullBottomBar addConstraints:@[btnWidth, btnHeight, btnRight, btnCenterY]];
        
        
        UILabel *label2 = [[UILabel alloc] init];
        label2.translatesAutoresizingMaskIntoConstraints = NO;
        label2.textAlignment = NSTextAlignmentCenter;
        label2.text = @"00:00";
        label2.font = [UIFont systemFontOfSize:12.0f];
        label2.textColor = [UIColor whiteColor];
        [fullBottomBar addSubview:label2];
        self.totalTimeLabel = label2;
        
        NSLayoutConstraint *label2Right = [NSLayoutConstraint constraintWithItem:label2 attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:fullScreenBtn attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0];
        NSLayoutConstraint *label2Top = [NSLayoutConstraint constraintWithItem:label2 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:fullBottomBar attribute:NSLayoutAttributeTop multiplier:1.0f constant:0];
        NSLayoutConstraint *label2Bottom = [NSLayoutConstraint constraintWithItem:label2 attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:fullBottomBar attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0];
        NSLayoutConstraint *label2Width = [NSLayoutConstraint constraintWithItem:label2 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0f constant:45.0f];
        [fullBottomBar addConstraints:@[label2Right, label2Top, label2Bottom, label2Width]];
        
        XLSlider *slider = [[XLSlider alloc] init];
        slider.value = 0.0f;
        slider.middleValue = 0.0f;
        slider.minColor = [UIColor whiteColor];
        slider.translatesAutoresizingMaskIntoConstraints = NO;
        [fullBottomBar addSubview:slider];
        __weak typeof(self) weakSelf = self;
        slider.valueChangeBlock = ^(XLSlider *slider){
            [weakSelf sliderValueChange:slider];
        };
        slider.finishChangeBlock = ^(XLSlider *slider){
            [weakSelf finishChange];
            if (self.playerEndDragBlock) {
                self.playerEndDragBlock((NSInteger)(slider.value * self.totalDuration));
            }
        };
        slider.draggingSliderBlock = ^(XLSlider *slider){
            [weakSelf dragSlider];
            if (self.playerDraggingBlock) {
                self.playerDraggingBlock((NSInteger)weakSelf.currentTime);
            }
        };
        
        NSLayoutConstraint *sliderLeft = [NSLayoutConstraint constraintWithItem:slider attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:label1 attribute:NSLayoutAttributeRight multiplier:1.0f constant:0];
        sliderLeft.priority = UILayoutPriorityDefaultLow;
        NSLayoutConstraint *sliderRight = [NSLayoutConstraint constraintWithItem:slider attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:label2 attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0];
        sliderRight.priority = UILayoutPriorityDefaultLow;
        NSLayoutConstraint *sliderTop = [NSLayoutConstraint constraintWithItem:slider attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:fullBottomBar attribute:NSLayoutAttributeTop multiplier:1.0f constant:0];
        NSLayoutConstraint *sliderBottom = [NSLayoutConstraint constraintWithItem:slider attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:fullBottomBar attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0];
        [fullBottomBar addConstraints:@[sliderLeft, sliderRight, sliderTop, sliderBottom]];
        self.fullSlider = slider;
        
        [self updateConstraintsIfNeeded];
    }
    return _fullBottomBar;
}


- (UIButton *)playOrPauseBtn {
    if (!_playOrPauseBtn) {
        _playOrPauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _playOrPauseBtn.layer.opacity = 0.0f;
//        _playOrPauseBtn.imageView.contentMode = UIViewContentModeCenter;
        [_playOrPauseBtn setBackgroundImage:[UIImage imageNamed:@"icon_video_play"] forState:UIControlStateNormal];
        [_playOrPauseBtn setBackgroundImage:[UIImage imageNamed:@"icon_video_pause"] forState:UIControlStateSelected];
        [_playOrPauseBtn addTarget:self action:@selector(playOrPause:) forControlEvents:UIControlEventTouchDown];
    }
    return _playOrPauseBtn;
}

#pragma mark - dealloc

- (void)dealloc {
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    NSLog(@"video player - dealloc");
}

@end
