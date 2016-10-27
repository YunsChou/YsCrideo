//
//  HomeListViewModel.h
//  Crideo
//
//  Created by weiying on 16/9/19.
//  Copyright © 2016年 yunschou. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HomeListModel;

extern NSInteger const limitNum;

typedef void (^RequestFinishBlock) (NSArray *homeListArr, NSError *error);

@interface HomeListViewModel : NSObject

+ (void)requetListModelWithSkipNum:(NSInteger)skipNum finishBlock:(RequestFinishBlock)finishBlock;

+ (NSArray *)listModelPacketAccordingToDateWithListArr:(NSArray *)listArr;

@end
