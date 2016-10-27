//
//  DetailPreviewView.h
//  Crideo
//
//  Created by weiying on 16/9/20.
//  Copyright © 2016年 yunschou. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^PreviewScrollEndDeceleratBlock) (NSInteger index);
typedef void (^PreviewDismissCompleteBlock) ();

@interface DetailPreviewView : UIView

@property (nonatomic, assign) CGFloat animationOffsetY;

- (instancetype)initWithFrame:(CGRect)frame imageArr:(NSArray *)imgArr index:(NSInteger)index;

- (void)previewTopScrollEndDeceleratBlock:(PreviewScrollEndDeceleratBlock)endDeceleratBlock;

- (void)previewShowAnimation;

- (void)previewDismissAnimationCompleteBlock:(PreviewDismissCompleteBlock)completeBlock;
@end
