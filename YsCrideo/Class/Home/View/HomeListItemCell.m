//
//  HomeListItemCell.m
//  Crideo
//
//  Created by weiying on 16/9/21.
//  Copyright © 2016年 yunschou. All rights reserved.
//

#import "HomeListItemCell.h"
#import "LeanCloudTool.h"
#import "HomeListViewModel.h"
#import "UIImageView+WebCache.h"
#import "HomeListModel.h"

@interface HomeListItemCell ()
@property (weak, nonatomic) IBOutlet UIImageView *itemImageView;
@property (weak, nonatomic) IBOutlet UIView *itemCoverView;
@property (weak, nonatomic) IBOutlet UILabel *itemTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemSourceLabel;
@property (weak, nonatomic) IBOutlet UIButton *itemShareButton;

@end

@implementation HomeListItemCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"HomeListItemCell";
    HomeListItemCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:ID owner:nil options:nil] firstObject];
    }
    return cell;
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.itemSourceLabel.font = [UIFont systemFontOfSize:14 * SCREEN_SCALE];
    self.itemTitleLabel.font = [UIFont fontWithName:@"SFCompactDisplay-Heavy" size:30 * SCREEN_SCALE];
    self.itemTimeLabel.font = [UIFont systemFontOfSize:16 * SCREEN_SCALE];
    
    self.itemCoverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    //创建长按手势监听
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tapCellLongPressed:)];
    longPress.minimumPressDuration = 0.5;
    //将长按手势添加到需要实现长按操作的视图里
    [self.itemCoverView addGestureRecognizer:longPress];
}

- (void)tapCellLongPressed:(UILongPressGestureRecognizer *)gesture
{
    if ([gesture state] == UIGestureRecognizerStateBegan) {
        DLog(@"触发长按 -- ");
        [UIView animateWithDuration:0.1 animations:^{
            self.itemCoverView.alpha = 0.0;
        }];
    }else if ([gesture state] == UIGestureRecognizerStateEnded) {
        DLog(@"触发结束 -- ");
        [UIView animateWithDuration:0.2 animations:^{
            self.itemCoverView.alpha = 1.0;
            self.itemCoverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
        }];
    }
}

- (void)setHomeListM:(HomeListModel *)homeListM
{
    _homeListM = homeListM;

    //标题
    self.itemTitleLabel.text = homeListM.localData.title;
    // 图片
    [self.itemImageView sd_setImageWithURL:[NSURL URLWithString:homeListM.localData.coverURL]];
    //
    self.itemSourceLabel.text = homeListM.localData.category;

    //视频时长
    NSInteger videoTime = [homeListM.localData.duration integerValue];
    NSString *timeString = [NSString stringWithFormat:@"%02ld' %02ld''",videoTime / 60, videoTime % 60];
    self.itemTimeLabel.text = timeString;
}

- (IBAction)shareBtnClick:(id)sender {
    DLog(@"点击分享按钮-- ");
}

- (CGFloat)cellOffset
{
    CGRect centerToWindow = [self convertRect:self.bounds toView:self.window];
    CGFloat centerY = CGRectGetMidY(centerToWindow);
    CGPoint windowCenter = self.superview.center;
    
    CGFloat cellOffsetY = centerY - windowCenter.y;
    
    CGFloat offsetDig =  cellOffsetY / self.superview.frame.size.height *2;
    CGFloat offset =  -offsetDig * (SCREEN_HEIGHT/2 - 250)/2;
    
    CGAffineTransform transY = CGAffineTransformMakeTranslation(0,offset);
    
    self.itemTitleLabel.transform = transY;
    self.itemTimeLabel.transform = transY;

    self.itemImageView.transform = transY;
    
    return offset;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
