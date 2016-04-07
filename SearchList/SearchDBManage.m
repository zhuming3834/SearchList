//
//  SearchDBManage.m
//  SearchList
//
//  Created by zhuming on 16/4/7.
//  Copyright © 2016年 zhuming. All rights reserved.
//

#import "SearchDBManage.h"

#define FILE_NAME   @"SearchDataDB"
#define TABLE_NAME  @"SearchDataDB"

@interface SearchDBManage (){
    sqlite3 *dataBase;
}
@end

@implementation SearchDBManage

/**
 *  操作数据库单例
 *
 *  @return 操作数据库对象
 */
+ (SearchDBManage *)shareSearchDBManage{
    static SearchDBManage *shareDB = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        shareDB = [[self alloc] init];
        [shareDB creatDataBase];
    });
    return shareDB;
}

/**
 *  根据文件名获取文件路径
 *
 *  @param fileName 文件名
 *
 *  @return 返回文件路径
 */
- (NSString *)getFilePath:(NSString *)fileName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documetsDirectory = [paths objectAtIndex:0];
    return [documetsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",fileName]];
}

/**
 *  打开数据库
 *
 *  @return YES:打开成功  NO:打开失败
 */
- (BOOL)openDataBase{
    NSLog(@"FilePath = %@",[self getFilePath:FILE_NAME]);
    int result = sqlite3_open([self getFilePath:FILE_NAME].UTF8String, &dataBase);
    if (result == SQLITE_OK) {
        NSLog(@"数据库打开成功");
        return YES;
    }
    else{
        NSLog(@"数据库打开失败");
        return NO;
    }
}
/**
 *  关闭数据库
 */
- (void)closeDataBase{
    sqlite3_close(dataBase);
}

/**
 *  数据库中创建表
 */
- (void)creatDataBase{
    if (![self openDataBase]) {
        return; // 数据库打开失败
    }
    NSString *creatSQL = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (rowid INTEGER PRIMARY KEY AUTOINCREMENT, keyWord text,currentTime text)",TABLE_NAME];
    char *errorMsg;
    int result = sqlite3_exec(dataBase, creatSQL.UTF8String, NULL, NULL, &errorMsg);
    if (result == SQLITE_OK) {
        [self closeDataBase];
        NSLog(@"表单：%@创建成功",TABLE_NAME);
    }
    else{
        NSLog(@"表单：%@创建失败：%s",TABLE_NAME,errorMsg);
    }
}
/**
 *  以搜索数据模型插入数据库
 *
 *  @param searchModel 搜索数据模型
 */
- (void)insterSearchModel:(SearchModel *)searchModel{
    if (![self openDataBase]) {
        return;
    }
    NSString *insterSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (keyWord,currentTime) VALUES (?,?)",TABLE_NAME];
    char *errorMsg;
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(dataBase, insterSQL.UTF8String, -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, searchModel.keyWord.UTF8String, -1, nil);
        sqlite3_bind_text(stmt, 2, searchModel.currentTime.UTF8String, -1, nil);
    }
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        NSLog(@"数据插入失败：%s",errorMsg);
    }
    else NSLog(@"数据插入成功");
    sqlite3_finalize(stmt);
    [self closeDataBase];
}
/**
 *  根据关键字删除搜索数据模型
 *
 *  @param keyWord 搜索关键字
 */
- (void)deleteSearchModelByKeyword:(NSString *)keyWord{
    if (![self openDataBase]) {
        return;
    }
    NSString *deleteSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE keyWord = '%@'",TABLE_NAME,keyWord];
    char *errorMsg;
    if (sqlite3_exec(dataBase, deleteSQL.UTF8String, NULL, NULL, &errorMsg) == SQLITE_OK) {
        NSLog(@"数据删除成功");
        [self closeDataBase];
    }
    else{
        NSLog(@"数据删除失败：%s",errorMsg);
    }
}
/**
 *  删除全部数据
 */
- (void)deleteAllSearchModel{
    if (![self openDataBase]) {
        return;
    }
    NSString *deleteSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE 1>0",TABLE_NAME];
    char *errorMsg;
    if (sqlite3_exec(dataBase, deleteSQL.UTF8String, NULL, NULL, &errorMsg) == SQLITE_OK) {
        NSLog(@"数据删除成功");
        [self closeDataBase];
    }
    else{
        NSLog(@"数据删除失败：%s",errorMsg);
    }
}
/**
 *  获取数据库里面的全部数据
 *
 *  @return 搜索数据的集合
 */
- (NSMutableArray *)selectAllSearchModel{
    if (![self openDataBase]) {
        return nil;
    }
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    NSString *selecteSQL = [NSString stringWithFormat:@"SELECT * FROM %@",TABLE_NAME];
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(dataBase, selecteSQL.UTF8String, -1, &stmt, nil) == SQLITE_OK) {
        NSLog(@"筛选成功");
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            NSMutableString *keyWord=[NSMutableString stringWithCString:(char*)sqlite3_column_text(stmt, 1) encoding:NSUTF8StringEncoding];
            NSMutableString *currentTime=[NSMutableString stringWithCString:(char*)sqlite3_column_text(stmt, 2) encoding:NSUTF8StringEncoding];
            SearchModel *searchModel = [SearchModel creatSearchModel:keyWord currentTime:currentTime];
            [dataArray addObject:searchModel];
        }
        sqlite3_finalize(stmt);
        [self closeDataBase];
        return dataArray;
    }
    else{
        NSLog(@"筛选失败");
        return nil;
    }
}

@end
