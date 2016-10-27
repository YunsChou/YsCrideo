//
//  DetailPreviewView.m
//  Crideo
//
//  Created by weiying on 16/9/20.
//  Copyright © 2016年 yunschou. All rights reserved.
//

#import "DetailPreviewView.h"
//Model
#import "HomeListModel.h"
//View
#import "DetailTopScrollView.h" //滚动视图
#import "DetailTopImageView.h"  //顶部图片
#import "DetailImageDescView.h" //底部描述

@interface DetailPreviewView ()<UIScrollViewDelegate>
@property (nonatomic, copy) PreviewScrollEndDeceleratBlock endDeceleratBlock;
@property (nonatomic, copy) PreviewDismissCompleteBlock completeBlock;
@property (nonatomic, strong) DetailTopScrollView *topScrollView;
@property (nonatomic, strong) DetailImageDescView *imageDescView;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) NSArray *imgArr;
@property (nonatomic, assign) NSInteger lastScrollIndex;
@end

@implementation DetailPreviewView

- (instancetype)initWithFrame:(CGRect)frame imageArr:(NSArray *)imgArr index:(NSInteger)index
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        
        self.imgArr = imgArr;
        self.lastScrollIndex = index;
        
        [self setupPreviewSubViewsWithIndex:index];
        
        [self previewAddSwipeGesture];
    }
    return self;
}

- (void)setupPreviewSubViewsWithIndex:(NSInteger)index
{
    DetailImageDescView *imageDescView = [DetailImageDescView imageDescView];
    imageDescView.frame = CGRectMake(0, SCREEN_HEIGHT - kDetailBottomImageHeight, SCREEN_WIDTH, kDetailBottomImageHeight);
    imageDescView.homeListM = [self.imgArr objectAtIndex:index];
    [self addSubview:imageDescView];
    self.imageDescView = imageDescView;
    
    DetailTopScrollView *topScrollView = [[DetailTopScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) imageArr:self.imgArr index:index];
    topScrollView.delegate = self;
    [self addSubview:topScrollView];
    self.topScrollView = topScrollView;
    
    UIButton *backBtn = [[UIButton alloc] init];
    backBtn.alpha = 0;
    [backBtn setImage:[UIImage imageNamed:@"icon_back_btn"] forState:UIControlStateNormal];
    backBtn.frame = CGRectMake(0, 0, 60, 40);
    [backBtn addTarget:self action:@selector(backHomeListViewClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:backBtn];
    self.backButton = backBtn;
}

- (void)backHomeListViewClick
{
    DLog(@"点击返回按钮-- ");
    [self previewAnimationCompletion:^{
        if (self.completeBlock) {
            self.completeBlock();
        }
    }];
}

- (void)previewAddSwipeGesture
{
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(previewSwipeGesture:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown;
    [self.topScrollView addGestureRecognizer:swipeGesture];
}

#pragma mark - 手势事件
- (void)previewSwipeGesture:(UISwipeGestureRecognizer *)swipeGesture
{
    self.topScrollView.scrollEnabled = NO;
    [self previewAnimationCompletion:^{
        if (self.completeBlock) {
            self.completeBlock();
        }
    }];
}

- (void)previewTopScrollEndDeceleratBlock:(PreviewScrollEndDeceleratBlock)endDeceleratBlock
{
    self.endDeceleratBlock = endDeceleratBlock;
}

- (void)previewDismissAnimationCompleteBlock:(PreviewDismissCompleteBlock)completeBlock
{
    self.completeBlock = completeBlock;
}

#pragma mark - scroll delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    for (DetailTopImageView *topImageView in scrollView.subviews) {
        if ([topImageView respondsToSelector:@selector(topImageOffset)] ) {
            [topImageView topImageOffset];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = scrollView.contentOffset.x / scrollView.frame.size.width;
    //销毁上一个视频播放
    if (self.lastScrollIndex != index) {
        [self stopAndDestoryVideoPlayer];
        self.lastScrollIndex = index;
        
        //给View赋值
        self.imageDescView.homeListM = self.imgArr[index];
    }
    //滚动完成后回调
    if (self.endDeceleratBlock) {
        self.endDeceleratBlock(index);
    }
}

- (void)stopAndDestoryVideoPlayer
{
    DetailTopImageView *topImageView = self.topScrollView.subviews[self.lastScrollIndex];
    if ([topImageView respondsToSelector:@selector(destroyVideoPlayer)] ) {
        [topImageView destroyVideoPlayer];
    }
}

#pragma mark - 显示和消失动画
- (void)previewShowAnimation
{
    self.imageDescView.frame = CGRectMake(0, self.animationOffsetY, SCREEN_WIDTH, kDetailBottomImageHeight);
    self.topScrollView.frame = CGRectMake(0, self.animationOffsetY, SCREEN_WIDTH, kListTableViewCellHeight);
    [UIView animateWithDuration:0.5 animations:^{
        self.topScrollView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 50);
        self.imageDescView.frame = CGRectMake(0, SCREEN_HEIGHT - kDetailBottomImageHeight, SCREEN_WIDTH, kDetailBottomImageHeight);
    } completion:^(BOOL finished) {
        self.backButton.alpha = 1.0f;
    }];
}

- (void)previewAnimationCompletion:(void (^)(void))completion
{
    self.backButton.alpha = 0.0;
    [self stopAndDestoryVideoPlayer];
    [UIView animateWithDuration:0.5 animations:^{
        self.imageDescView.frame = CGRectMake(0, self.animationOffsetY, SCREEN_WIDTH, kDetailBottomImageHeight);
        self.topScrollView.frame = CGRectMake(0, self.animationOffsetY, SCREEN_WIDTH, kListTableViewCellHeight);
    } completion:^(BOOL finished) {
        [self.imageDescView removeFromSuperview];
        [self.topScrollView removeFromSuperview];
        if (completion) {
            completion();
        }
    }];
}

@end
