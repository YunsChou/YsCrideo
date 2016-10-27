//
//  HomeListModel.h
//  Crideo
//
//  Created by weiying on 16/9/19.
//  Copyright © 2016年 yunschou. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LocalDataModel;

@interface HomeListModel : NSObject

@property (nonatomic, copy) NSString *objectId;

@property (nonatomic, strong) LocalDataModel *localData;

@end

@interface LocalDataModel : NSObject

@property (nonatomic, copy) NSString *category;

@property (nonatomic, copy) NSString *coverURL;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *duration;

@property (nonatomic, copy) NSString *desc;

@property (nonatomic, copy) NSString *source;

@property (nonatomic, copy) NSString *playURL;

@property (nonatomic, strong) NSDate *date;


@end
