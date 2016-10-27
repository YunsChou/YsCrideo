//
//  HomeListGroupHeader.h
//  Crideo
//
//  Created by weiying on 16/9/21.
//  Copyright © 2016年 yunschou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeListGroupHeader : UIView

+ (instancetype)groupNormalHeader;

- (void)firstHeaderWithGroupTime:(NSString *)time;

- (void)normalHeaderWithGroupTime:(NSString *)time;

@end
