//
//  ViewController.m
//  SearchList
//
//  Created by myhg on 16/4/7.
//  Copyright © 2016年 zhuming. All rights reserved.
//

#import "ViewController.h"
#import "SearchDBManage.h"

#define UIColorFromRGB(rgbValue) [UIColor  colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0  green:((float)((rgbValue & 0xFF00) >> 8))/255.0  blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
//设置RGB颜色值
#define COLOR(R,G,B,A)	[UIColor colorWithRed:(CGFloat)R/255 green:(CGFloat)G/255 blue:(CGFloat)B/255 alpha:A]
// 最大存储的搜索历史 条数
#define MAX_COUNT 5

@interface ViewController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>
/**
 *  搜索历史数据表单
 */
@property (nonatomic,strong)UITableView *tabeleView;
/**
 *  数据集合
 */
@property (nonatomic,strong)NSMutableArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
    
    [self initData];
    
    [self setNavTitleView];
    
    [self initTabelView];
    
    // Do any additional setup after loading the view, typically from a nib.
}
/**
 *  数据初始化
 */
- (void)initData{
    self.dataArray = [[NSMutableArray alloc] init];
//    [[SearchDBManage shareSearchDBManage] deleteAllSearchModel];
    self.dataArray = [[SearchDBManage shareSearchDBManage] selectAllSearchModel];
}


/**
 *  设置导航栏搜索框
 */
- (void)setNavTitleView{
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.frame = CGRectMake(0, 0, 140, 30);
     [searchBar setImage:[UIImage imageNamed:@"icon_search2"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    searchBar.delegate = self;
    searchBar.placeholder = @"请输入搜索内容";
    searchBar.backgroundColor = [UIColor clearColor];
    searchBar.barTintColor = UIColorFromRGB(0xf7f7f7);
    self.navigationItem.titleView = searchBar;
}
/**
 *  设置搜索历史显示表格
 */
- (void)initTabelView{
    self.tabeleView = [[UITableView alloc] init];
    self.tabeleView.frame = self.view.bounds;
    self.tabeleView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tabeleView.delegate = self;
    self.tabeleView.dataSource = self;
    [self.view addSubview:self.tabeleView];
    
    // 清空历史搜索按钮
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 104)];
    
    UIButton *clearButton = [[UIButton alloc] init];
    clearButton.frame = CGRectMake(60, 60, self.view.frame.size.width - 120, 44);
    [clearButton setTitle:@"清空历史搜索" forState:UIControlStateNormal];
    [clearButton setTitleColor:[UIColor colorWithRed:242/256 green:242/256 blue:242/256 alpha:1] forState:UIControlStateNormal];
    clearButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [clearButton addTarget:self action:@selector(clearButtonClick) forControlEvents:UIControlEventTouchDown];
    clearButton.layer.cornerRadius = 3;
    clearButton.layer.borderWidth = 0.5;
    clearButton.layer.borderColor = [UIColor colorWithRed:242/256 green:242/256 blue:242/256 alpha:1].CGColor;
    [footView addSubview:clearButton];
    self.tabeleView.tableFooterView = footView;
}
#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.dataArray.count == 0) {
        self.tabeleView.tableFooterView.hidden = YES; // 没有历史数据时隐藏
    }
    else{
        self.tabeleView.tableFooterView.hidden = NO; // 有历史数据时显示
    }
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"identify";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identify];
        // cell 下面的横线
        UILabel *lineLabel = [[UILabel alloc] init];
        lineLabel.frame = CGRectMake(0, cell.frame.size.height - 0.5, cell.frame.size.width, 0.5);
        lineLabel.backgroundColor = [UIColor colorWithRed:242/256 green:242/256 blue:242/256 alpha:1];
        [cell addSubview:lineLabel];
    }
    
    SearchModel *model = (SearchModel *)[self exchangeArray:self.dataArray][indexPath.row];
    cell.textLabel.text = model.keyWord;
    cell.detailTextLabel.text = model.currentTime;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SearchModel *model = (SearchModel *)[self exchangeArray:self.dataArray][indexPath.row];
    UIAlertView *alView = [[UIAlertView alloc] init];
    alView.title = @"选中的数据";
    alView.message = [NSString stringWithFormat:@"%@\n%@",model.keyWord,model.currentTime];
    [alView addButtonWithTitle:@"确定"];
    [alView show];
}

/**
 *  清空搜索历史操作
 */
- (void)clearButtonClick{
    [[SearchDBManage shareSearchDBManage] deleteAllSearchModel];
    [self.dataArray removeAllObjects];
    [self.tabeleView reloadData];
}

#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    return YES;
}// return NO to not become first responder
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    searchBar.showsCancelButton = YES;
    for(UIView *view in  [[[searchBar subviews] objectAtIndex:0] subviews]) {
        if([view isKindOfClass:[NSClassFromString(@"UINavigationButton") class]]) {
            UIButton * cancel =(UIButton *)view;
            [cancel setTitle:@"搜索" forState:UIControlStateNormal];
            cancel.titleLabel.font = [UIFont systemFontOfSize:14];
        }
    }
}// called when text starts editing
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    return YES;
}// return NO to not resign first responder
- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    return YES;
}// called before text changes
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self insterDBData:searchBar.text]; // 插入数据库
    [searchBar resignFirstResponder];
}// called when keyboard search button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self insterDBData:searchBar.text]; // 插入数据库
    [searchBar resignFirstResponder];
}// called when cancel button pressed

/**
 *  获取当前时间
 *
 *  @return 当前时间
 */
- (NSString *)getCurrentTime{
    NSDate *  senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY年MM月dd日HH:mm:ss"];
    NSString *  locationString=[dateformatter stringFromDate:senddate];
    return locationString;
}

/**
 *  去除数据库中已有的相同的关键词
 *
 *  @param keyword 关键词
 */
- (void)removeSameData:(NSString *)keyword{
    NSMutableArray *array = [[SearchDBManage shareSearchDBManage] selectAllSearchModel];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SearchModel *model = (SearchModel *)obj;
        if ([model.keyWord isEqualToString:keyword]) {
            [[SearchDBManage shareSearchDBManage] deleteSearchModelByKeyword:keyword];
        }
    }];
}

/**
 *  数组左移
 *
 *  @param array   需要左移的数组
 *  @param keyword 搜索关键字
 *
 *  @return 返回新的数组
 */
- (NSMutableArray *)moveArrayToLeft:(NSMutableArray *)array keyword:(NSString *)keyword{
    [array addObject:[SearchModel creatSearchModel:keyword currentTime:[self getCurrentTime]]];
    [array removeObjectAtIndex:0];
    return array;
}
/**
 *  数组逆序
 *
 *  @param array 需要逆序的数组
 *
 *  @return 逆序后的输出
 */
- (NSMutableArray *)exchangeArray:(NSMutableArray *)array{
    NSInteger num = array.count;
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    for (NSInteger i = num - 1; i >= 0; i --) {
        [temp addObject:[array objectAtIndex:i]];
        
    }
    return temp;
}

/**
 *  多余20条数据就把第0条去除
 *
 *  @param keyword 插入数据库的模型需要的关键字
 */
- (void)moreThan20Data:(NSString *)keyword{
    // 读取数据库里面的数据
    NSMutableArray *array = [[SearchDBManage shareSearchDBManage] selectAllSearchModel];
    
    if (array.count > MAX_COUNT - 1) {
        NSMutableArray *temp = [self moveArrayToLeft:array keyword:keyword]; // 数组左移
        [[SearchDBManage shareSearchDBManage] deleteAllSearchModel]; //清空数据库
        [self.dataArray removeAllObjects];
        [self.tabeleView reloadData];
        [temp enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            SearchModel *model = (SearchModel *)obj; // 取出 数组里面的搜索模型
            [[SearchDBManage shareSearchDBManage] insterSearchModel:model]; // 插入数据库
        }];
    }
    else if (array.count <= MAX_COUNT - 1){ // 小于等于19 就把第20条插入数据库
        [[SearchDBManage shareSearchDBManage] insterSearchModel:[SearchModel creatSearchModel:keyword currentTime:[self getCurrentTime]]];
    }
}
/**
 *  关键词插入数据库
 *
 *  @param keyword 关键词
 */
- (BOOL)insterDBData:(NSString *)keyword{
    if (keyword.length == 0) {
        return NO;
    }
    else{//搜索历史插入数据库
        //先删除数据库中相同的数据
        [self removeSameData:keyword];
        //再插入数据库
        [self moreThan20Data:keyword];
        // 读取数据库里面的数据
        self.dataArray = [[SearchDBManage shareSearchDBManage] selectAllSearchModel];
        [self.tabeleView reloadData];
        return YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
