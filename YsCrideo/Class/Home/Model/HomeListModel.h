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
/**类别*/
@property (nonatomic, copy) NSString *category;
/**列表图片*/
@property (nonatomic, copy) NSString *coverURL;
/**标题*/
@property (nonatomic, copy) NSString *title;
/**播放时长*/
@property (nonatomic, copy) NSString *duration;
/**内容描述*/
@property (nonatomic, copy) NSString *desc;
/**来源*/
@property (nonatomic, copy) NSString *source;
/**视屏播放链接*/
@property (nonatomic, copy) NSString *playURL;
/**后台数据添加时间*/
@property (nonatomic, strong) NSDate *date;


@end
