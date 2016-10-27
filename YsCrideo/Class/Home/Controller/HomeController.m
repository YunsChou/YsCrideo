//
//  HomeController.m
//  Crideo
//
//  Created by weiying on 16/10/9.
//  Copyright © 2016年 yunschou. All rights reserved.
//

#import "HomeController.h"
//Model
#import "HomeListModel.h"
//View
#import "MJCustomGifHeader.h"
#import "MJCustomGifFooter.h"
#import "HomeListItemCell.h"
//ViewModel
#import "HomeListViewModel.h"
#import "HomeListDelegate.h"
#import "HomeListDataSource.h"
//详情页
#import "DetailPreviewView.h"

@interface HomeController ()
//列表页
@property (nonatomic, strong) NSMutableArray *listOriginMArr;
@property (nonatomic, strong) NSMutableArray *listHandleMArr;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) HomeListDelegate *homeDelegate;
@property (nonatomic, strong) HomeListDataSource *homeDataSource;
//详情页
@property (nonatomic, strong) DetailPreviewView *previewView;

@end

@implementation HomeController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    [self setupTableView];
    [self setupRefresh];
}

#pragma mark - 添加tableview及上下拉刷新
- (void)setupTableView
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor blackColor];
    self.homeDelegate = [[HomeListDelegate alloc] initWithListDelegateSelectedBlock:^(NSIndexPath *indexPath) {
        [self showImageAtIndexPath:indexPath];

    }];
    self.homeDataSource = [[HomeListDataSource alloc] init];
    tableView.delegate = self.homeDelegate;
    tableView.dataSource = self.homeDataSource;
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

- (void)setupRefresh
{
    //下拉刷新
    self.tableView.mj_header = [MJCustomGifHeader headerWithRefreshingBlock:^{
        [self loadLatestData];
    }];
    [self.tableView.mj_header beginRefreshing];
    
    //上拉加载
    self.tableView.mj_footer = [MJCustomGifFooter footerWithRefreshingBlock:^{
        [self loadMoreData];
    }];
}

#pragma mark - 获取leancloud数据
- (void)loadLatestData
{
    [self loadHomeListDataWithSkipNum:0];
}

- (void)loadMoreData
{
    [self loadHomeListDataWithSkipNum:self.listOriginMArr.count];
}

- (void)loadHomeListDataWithSkipNum:(NSInteger)skipNum
{
    [HomeListViewModel requetListModelWithSkipNum:skipNum finishBlock:^(NSArray *homeListArr, NSError *error) {
        if (!error) {
            //判断下拉刷新
            if (homeListArr.count > 0 && skipNum == 0) {
                [self.listOriginMArr removeAllObjects];
            }
            //添加数据
            [self.listOriginMArr addObjectsFromArray:homeListArr];
            self.listHandleMArr = [[HomeListViewModel listModelPacketAccordingToDateWithListArr:self.listOriginMArr] mutableCopy];
            
            //判断是否请求完所有数据
            if (homeListArr.count < limitNum) {
                self.tableView.mj_footer.hidden = YES;
            }else{
                self.tableView.mj_footer.hidden = NO;
            }
        }
        //结束刷新
        [self tableViewEndRefresh];
    }];
}

- (void)tableViewEndRefresh
{
    //结束刷新
    self.homeDelegate.listModelArr = self.listHandleMArr;
    self.homeDataSource.listModelArr = self.listHandleMArr;
    [self.tableView reloadData];
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
}


#pragma mark - 显示详情界面
- (void)showImageAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellToWinY = [self cellToWinYWithIndexPath:indexPath];
    
    DetailPreviewView *previewView = [[DetailPreviewView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) imageArr:self.listHandleMArr[indexPath.section][@"items"] index:indexPath.row];
    previewView.animationOffsetY = cellToWinY;
    
    [previewView previewTopScrollEndDeceleratBlock:^(NSInteger index) {
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:index inSection:indexPath.section];
        [self.tableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        CGFloat newcellToWinY = [self cellToWinYWithIndexPath:newIndexPath];
        self.previewView.animationOffsetY = newcellToWinY;
    }];
    [previewView previewDismissAnimationCompleteBlock:^{
        [self.previewView removeFromSuperview];
        self.previewView = nil;
    }];
    
    [self.view addSubview:previewView];
    //preview展开动画
    [previewView previewShowAnimation];
    self.previewView = previewView;
}

- (CGFloat)cellToWinYWithIndexPath:(NSIndexPath *)indexPath
{
    HomeListItemCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    CGRect cellToWinRect = [cell convertRect:cell.bounds toView:nil];
    CGFloat cellToWinY = cellToWinRect.origin.y;
    return cellToWinY;
}

#pragma mark - 懒加载
- (NSMutableArray *)listHandleMArr
{
    if (!_listHandleMArr) {
        self.listHandleMArr = [NSMutableArray array];
    }
    return _listHandleMArr;
}

- (NSMutableArray *)listOriginMArr
{
    if (!_listOriginMArr) {
        self.listOriginMArr = [NSMutableArray array];
    }
    return _listOriginMArr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
