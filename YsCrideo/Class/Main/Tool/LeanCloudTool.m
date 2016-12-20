//
//  LeanCloudTool.m
//  YsCrideo
//
//  Created by weiying on 16/10/26.
//  Copyright © 2016年 yunschou. All rights reserved.
//

#import "LeanCloudTool.h"
#import <AVOSCloud/AVOSCloud.h>

static NSString *appID = @"fk4AUJ7OlHYbidD4LxalEalR-gzGzoHsz";
static NSString *appKey = @"rinLEHC3cazLFkttM1XWiilF";

static NSString *dataTable = @"VideoTable";

@implementation LeanCloudTool

+ (instancetype)shareInstance
{
    static LeanCloudTool *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (void)setupLeanCloudWithOptions:(NSDictionary *)launchOptions
{
    // 如果使用美国站点，请加上下面这行代码：
//    [AVOSCloud setServiceRegion:AVServiceRegionUS];
    [AVOSCloud setApplicationId:appID clientKey:appKey];
    [AVAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
}

- (void)queryLeanCloudWithSkipNum:(NSInteger)skipNum limitNum:(NSInteger)limitNum finishBlock:(LeanCloudQueryFinish)finishBlock
{
    //1、创建查询对象，并添加查询条件
    AVQuery *query = [AVQuery queryWithClassName:dataTable];
    query.skip = skipNum;
    query.limit = limitNum;
    [query orderByDescending:@"date"];
    //2、进行查询
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (finishBlock) {
            finishBlock(objects, error);
        }
    }];
}

@end
