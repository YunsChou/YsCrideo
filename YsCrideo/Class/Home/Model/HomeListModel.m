//
//  HomeListModel.m
//  Crideo
//
//  Created by weiying on 16/9/19.
//  Copyright © 2016年 yunschou. All rights reserved.
//

#import "HomeListModel.h"
#import "MJExtension.h"

@implementation HomeListModel

@end

@implementation LocalDataModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"desc" : @"description"};
}

@end
