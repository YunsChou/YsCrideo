//
//  LeanCloudTool.h
//  YsCrideo
//
//  Created by weiying on 16/10/26.
//  Copyright © 2016年 yunschou. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^LeanCloudQueryFinish) (NSArray *objects, NSError *error);

@interface LeanCloudTool : NSObject

+ (instancetype)shareInstance;

- (void)setupLeanCloudWithOptions:(NSDictionary *)launchOptions;

- (void)queryLeanCloudWithSkipNum:(NSInteger)skipNum limitNum:(NSInteger)limitNum finishBlock:(LeanCloudQueryFinish)finishBlock;

@end
