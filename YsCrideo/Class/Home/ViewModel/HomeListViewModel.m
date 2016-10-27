//
//  HomeListViewModel.m
//  Crideo
//
//  Created by weiying on 16/9/19.
//  Copyright © 2016年 yunschou. All rights reserved.
//

#import "HomeListViewModel.h"
#import "MJExtension.h"
#import "LeanCloudTool.h"
#import "HomeListModel.h"

NSInteger const limitNum = 10;

@implementation HomeListViewModel

+ (void)requetListModelWithSkipNum:(NSInteger)skipNum finishBlock:(RequestFinishBlock)finishBlock
{
    [[LeanCloudTool shareInstance] queryLeanCloudWithSkipNum:skipNum limitNum:limitNum finishBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *homeListArr = [HomeListModel mj_objectArrayWithKeyValuesArray:objects];
        //回调请求数据
        if (finishBlock) {
            finishBlock(homeListArr, error);
        }
    }];
}

+ (NSArray *)listModelPacketAccordingToDateWithListArr:(NSArray *)listArr
{
    //1、获取不同城市首字符，和首字符不相同时下标
    //用来保存所有不同日期字符
    NSMutableArray *headWordMArr = [NSMutableArray array];
    //用来保存出现首字符不相同时的下标
    NSMutableArray *headIndexMArr = [NSMutableArray array];
    NSString *headWords = @"";
    for (NSInteger i = 0; i < listArr.count; i ++) {
        HomeListModel *homeListM = listArr[i];
        NSString *headWord = [[homeListM.localData.date description] substringToIndex:10];
        if (![headWords isEqualToString:headWord]) {
            [headWordMArr addObject:headWord];
            [headIndexMArr addObject:@(i)];
            headWords = headWord;
        }
    }
    //追加最后一个地区的下标
    [headIndexMArr addObject:@(listArr.count)];
    
    //2、根据首字符不相同时的下标，对城市进行分组
    //用来保存同组的城市
    NSMutableArray *listGroups = [NSMutableArray array];
    NSInteger headIndex = 0;
    for (NSInteger i = 0; i < headWordMArr.count; i ++) {
        NSMutableDictionary *groupDict = [NSMutableDictionary dictionary];
        NSString *headWord = headWordMArr[i];
        groupDict[@"title"] = headWord;
        //将地区放到对应的数组中
        NSInteger nextIndex = [headIndexMArr[i + 1] integerValue];
        NSMutableArray *headNameMArr = [NSMutableArray array];
        for (NSInteger j = headIndex; j < nextIndex; j ++) {
            HomeListModel *homeListM = listArr[j];
            [headNameMArr addObject:homeListM];
        }
        groupDict[@"items"] = headNameMArr;
        headIndex = nextIndex;
        [listGroups addObject:groupDict];
    }
    
    return listGroups;
}

@end
