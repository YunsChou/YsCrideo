//
//  DetailTopScrollView.m
//  Crideo
//
//  Created by weiying on 16/9/20.
//  Copyright © 2016年 yunschou. All rights reserved.
//

#import "DetailTopScrollView.h"
#import "DetailTopImageView.h"

@implementation DetailTopScrollView

- (instancetype)initWithFrame:(CGRect)frame imageArr:(NSArray *)imgArr index:(NSInteger)index
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.bounces = NO;
        self.pagingEnabled = YES;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.contentSize = CGSizeMake(imgArr.count * SCREEN_WIDTH, 0);
        self.contentOffset = CGPointMake(index * SCREEN_WIDTH, 0);
 
        [self setupTopImageViewWithImageArr:imgArr];
    }
    return self;
}

- (void)setupTopImageViewWithImageArr:(NSArray *)imgArr
{
    for (NSInteger i = 0; i < imgArr.count; i ++) {
        DetailTopImageView *topImageView = [[DetailTopImageView alloc] initWithFrame:CGRectMake(i * SCREEN_WIDTH, 0, SCREEN_WIDTH, kDetailTopImageHeight)];
        topImageView.homeListM = imgArr[i];
        [self addSubview:topImageView];
    }
}

@end
