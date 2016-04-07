//
//  SearchDBManage.h
//  SearchList
//
//  Created by zhuming on 16/4/7.
//  Copyright © 2016年 zhuming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "SearchModel.h"

@interface SearchDBManage : NSObject

/**
 *  操作数据库单例
 *
 *  @return 操作数据库对象
 */
+ (SearchDBManage *)shareSearchDBManage;
/**
 *  以搜索数据模型插入数据库
 *
 *  @param searchModel 搜索数据模型
 */
- (void)insterSearchModel:(SearchModel *)searchModel;
/**
 *  根据关键字删除搜索数据模型
 *
 *  @param keyWord 搜索关键字
 */
- (void)deleteSearchModelByKeyword:(NSString *)keyWord;
/**
 *  删除全部数据
 */
- (void)deleteAllSearchModel;
/**
 *  获取数据库里面的全部数据
 *
 *  @return 搜索数据的集合
 */
- (NSMutableArray *)selectAllSearchModel;
@end
