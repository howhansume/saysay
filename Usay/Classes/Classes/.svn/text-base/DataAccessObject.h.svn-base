//
//  DataAccessObject.h
//  USayApp
//
//  Created by Jong-Sung Park on 10. 6. 27..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

@class SQLiteDataAccess;

@interface DataAccessObject : NSObject {

	NSUInteger primaryKey;
	BOOL savedInDatabase;
}

@property (nonatomic) NSUInteger primaryKey;
@property (nonatomic) BOOL savedInDatabase;

- (void) insert;
- (void) update;
- (void) insertSyncData;
- (void) updateSyncData;
+ (void) setDatabase: (SQLiteDataAccess *) newDatabase;
+ (SQLiteDataAccess *) database;
+ (NSString *) tableName;
- (void) createTableForClass;
- (void) saveData;
- (void) saveSyncData;
- (void) deleteData;
- (NSArray *) columnsWithoutPrimaryKey;
+ (NSArray *) findWithSql: (NSString *) sql withParameters: (NSArray *) parameters;
+ (NSArray *) findWithSqlWithParameters: (NSString *) sql, ...;
+ (NSArray *) findWithSql: (NSString *) sql;
+ (NSArray *) findByColumn: (NSString *) column value: (id) value;
+ (NSArray *) findByColumn: (NSString *) column unsignedIntegerValue: (NSUInteger) value;
+ (NSArray *) findByColumn: (NSString *) column integerValue: (NSInteger) value;
+ (NSArray *) findByColumn: (NSString *) column doubleValue: (double) value;
+ (id) find: (NSUInteger) primaryKey;
+ (NSArray *) findAll;

@end
