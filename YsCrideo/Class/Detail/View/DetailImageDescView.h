//
//  DetailImageDescView.h
//  Crideo
//
//  Created by weiying on 16/9/20.
//  Copyright © 2016年 yunschou. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HomeListModel;

@interface DetailImageDescView : UIView

@property (nonatomic, strong) HomeListModel *homeListM;

+ (instancetype)imageDescView;


@end
