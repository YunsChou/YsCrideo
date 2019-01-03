//
//  DetailImageDescView.m
//  Crideo
//
//  Created by weiying on 16/9/20.
//  Copyright © 2016年 yunschou. All rights reserved.
//

#import "DetailImageDescView.h"
#import "UIImageView+WebCache.h"
//Model
#import "HomeListModel.h"
//Tool
#import "LeanCloudTool.h"

@interface DetailImageDescView ()
@property (weak, nonatomic) IBOutlet UIImageView *ImgDescBlureImageView;
@property (weak, nonatomic) IBOutlet UILabel *ImgDescTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *ImgDescTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *ImgDescContentLabel;
@property (weak, nonatomic) IBOutlet UIButton *ImgDescLikeButton;
@property (weak, nonatomic) IBOutlet UIButton *ImgDescShareButton;


@end

@implementation DetailImageDescView

+ (instancetype)imageDescView
{
    return [[[NSBundle mainBundle] loadNibNamed:@"DetailImageDescView" owner:nil options:nil] firstObject];
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.ImgDescTitleLabel.font = [UIFont systemFontOfSize:24 * SCREEN_SCALE];
    self.ImgDescTimeLabel.font = [UIFont systemFontOfSize:14 * SCREEN_SCALE];
    self.ImgDescContentLabel.font = [UIFont systemFontOfSize:14 * SCREEN_SCALE];
    self.ImgDescShareButton.titleLabel.font = [UIFont systemFontOfSize:13 * SCREEN_SCALE];
    self.ImgDescLikeButton.titleLabel.font = [UIFont systemFontOfSize:13 * SCREEN_SCALE];
    //添加高斯模糊
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    effectView.frame = self.ImgDescBlureImageView.bounds;
    [self.ImgDescBlureImageView addSubview:effectView];
}

- (void)setHomeListM:(HomeListModel *)homeListM
{
    _homeListM = homeListM;
    
    self.ImgDescTitleLabel.text = homeListM.localData.title;
    self.ImgDescContentLabel.text = homeListM.localData.desc;
    NSInteger videoTime = [homeListM.localData.duration integerValue];
    NSString *timeString = [NSString stringWithFormat:@"%02ld' %02ld''",videoTime / 60, videoTime % 60];
    self.ImgDescTimeLabel.text = [NSString stringWithFormat:@"#%@  |  %@", homeListM.localData.category, timeString];
    
    __weak typeof(self) weakSelf = self;
    [[[SDWebImageManager sharedManager] imageDownloader] downloadImageWithURL:[NSURL URLWithString:homeListM.localData.coverURL] options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        if (image) {
            CABasicAnimation *contentsAnimation = [CABasicAnimation animationWithKeyPath:@"contents"];
            contentsAnimation.duration = 0.5f;
            contentsAnimation.fromValue = self.ImgDescBlureImageView.image ;
            contentsAnimation.toValue = image;
            contentsAnimation.removedOnCompletion = YES;
            contentsAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [weakSelf.ImgDescBlureImageView.layer addAnimation:contentsAnimation forKey:nil];
            
            weakSelf.ImgDescBlureImageView.image = image;
        }
    }];
}

- (IBAction)likeButtonClick:(id)sender {
    DLog(@"点击喜欢按钮 -- ");

}

- (IBAction)shareButtonClick:(id)sender {
    DLog(@"点击分享按钮 -- ");
}


@end
