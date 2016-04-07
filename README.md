# SearchList
##一种仿京东搜索历史记录的表格的实现<br>
###功能点
准确的来说，不是仿制京东的，因为年前就是做好了这个功能。昨天看看京东，发现效果是一样的。<br>
年前公司APP的功能需求点：<br>
1.限制最多存储20条历史搜索数据(Demo为了演示，做的是5条)<br>
2.最新的历史数据在最上面<br>
3.数据不能重复<br>
4.历史数据支持点击，点击后发起搜索(Demo做的是弹出框展示)<br>
###效果图
![](https://github.com/zhuming3834/SearchList/blob/master/SL.gif)<br>
在公司的项目中，由于整个项目使用的是FMDB，为了再次复习一下sqlite3，所以我直接使用的是sqlite3，没有使用封装之后的FMDB<br>
###数据库的操作
关于FMDB，sqlite3和Core Data的使用，我有4篇博客做了介绍<br>
[《【iOS】数据库FMDB的使用(一)》](http://blog.csdn.net/zhuming3834/article/details/50388097)<br>
[《【iOS】数据库FMDB的使用(二)》](http://blog.csdn.net/zhuming3834/article/details/50392887)<br>
[《【iOS】数据库Core Data的使用》](http://blog.csdn.net/zhuming3834/article/details/50442579)<br>
[《【iOS】数据库SQLite3的使用》](http://blog.csdn.net/zhuming3834/article/details/50455597)<br>
###需求难点
#####1.最新的数据展示在最上面<br>
我的解决办法：数据库还是按照正常的写入和读取方法操作，我们在最数据显示的时候，先把数据逆序后再显示<br>
数组逆序：<br>
```OC
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
```
#####2.数据不能重复<br>
实现这个功能点，需要先实现数据不能重复和限制条数这两个功能点<br>
数据不能重复，我的解决办法：先用搜索的关键字去数据库查找，如果有相同的就先删除数据库里面相同的数据，在插入新的数据；<br>
经过测试这个可以有效的实现数据不能重复的这个功能，且不影响最新的数据展示在最上面这个功能点<br>
```OC
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
```
#####3.限制搜索历史数据条数(假设是限制20条)<br>
这个我的思路是，第19条数据那里是一个分界点<br>
数据库里面的数据小于等于19条的时候，直接插入数据库(暂不考虑去重的问题)<br>
数据库里面的数据大于19条的时候，先数据左移，去除数组里面的第0个元素，清空数据库，再把新的数组写入数据库<br>
```OC
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
```
最后再把上面的方法封装一下，做一个插入数据库的方法：<br>
```OC
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
```
清楚搜索历史，就是清空数据库和清空搜索数据模型集合的数组后reload一下tableView<br>
```OC
/**
 *  清空搜索历史操作
 */
- (void)clearButtonClick{
    [[SearchDBManage shareSearchDBManage] deleteAllSearchModel];
    [self.dataArray removeAllObjects];
    [self.tabeleView reloadData];
}
```

##UISearchBar修改右边取消按钮的方法
在它的代理- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar；里面实现下面的操作就可以了。<br>
```OC
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    searchBar.showsCancelButton = YES;
    for(UIView *view in  [[[searchBar subviews] objectAtIndex:0] subviews]) {
        if([view isKindOfClass:[NSClassFromString(@"UINavigationButton") class]]) {
            UIButton * cancel =(UIButton *)view;
            [cancel setTitle:@"搜索" forState:UIControlStateNormal];
            cancel.titleLabel.font = [UIFont systemFontOfSize:14];
        }
    }
}
```




