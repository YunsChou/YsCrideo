//
//  HomeListItemCell.h
//  Crideo
//
//  Created by weiying on 16/9/21.
//  Copyright © 2016年 yunschou. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HomeListModel;

@interface HomeListItemCell : UITableViewCell

@property (nonatomic, strong) HomeListModel *homeListM;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

- (CGFloat)cellOffset;
@end
