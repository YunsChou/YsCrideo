//
//  HomeListDelegate.m
//  Crideo
//
//  Created by weiying on 16/9/23.
//  Copyright © 2016年 yunschou. All rights reserved.
//

#import "HomeListDelegate.h"
#import "HomeListItemCell.h"
#import "HomeListGroupHeader.h"

@interface HomeListDelegate ()
@property (nonatomic, copy) HomeListDelegateSelectedBlock selectedBlock;
@end

@implementation HomeListDelegate

- (instancetype)initWithListDelegateSelectedBlock:(HomeListDelegateSelectedBlock)selectedBlock
{
    self = [super init];
    if (self) {
        self.selectedBlock = selectedBlock;
    }
    return self;
}

- (void)setListModelArr:(NSArray *)listModelArr
{
    _listModelArr = listModelArr;
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return kListTopHeaderHeight;
    }else{
        return kListNormalHeaderHeight;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kListTableViewCellHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *groupTime = self.listModelArr[section][@"title"];
    HomeListGroupHeader *groupHeader = [HomeListGroupHeader groupNormalHeader];
    if (section == 0) {
        [groupHeader firstHeaderWithGroupTime:groupTime];
    }else{
        [groupHeader normalHeaderWithGroupTime:groupTime];
    }
    return groupHeader;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectedBlock) {
        self.selectedBlock(indexPath);
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomeListItemCell *listCell = (HomeListItemCell *)cell;
    NSArray *items = self.listModelArr[indexPath.section][@"items"];
    listCell.homeListM = items[indexPath.row];
}
@end
