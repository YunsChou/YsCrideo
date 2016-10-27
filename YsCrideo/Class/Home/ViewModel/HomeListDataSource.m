//
//  HomeListDataSource.m
//  Crideo
//
//  Created by weiying on 16/9/23.
//  Copyright © 2016年 yunschou. All rights reserved.
//

#import "HomeListDataSource.h"
#import "HomeListItemCell.h"

@interface HomeListDataSource ()

@end

@implementation HomeListDataSource

- (void)setListModelArr:(NSArray *)listModelArr
{
    _listModelArr = listModelArr;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.listModelArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *items = self.listModelArr[section][@"items"];
    return items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomeListItemCell *cell = [HomeListItemCell cellWithTableView:tableView];
    return cell;
}

@end
