//
//  HomeListDelegate.h
//  Crideo
//
//  Created by weiying on 16/9/23.
//  Copyright © 2016年 yunschou. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^HomeListDelegateSelectedBlock)(NSIndexPath *indexPath);

@interface HomeListDelegate : NSObject <UITableViewDelegate>

@property (nonatomic, strong) NSArray *listModelArr;

- (instancetype)initWithListDelegateSelectedBlock:(HomeListDelegateSelectedBlock)selectedBlock;

@end
