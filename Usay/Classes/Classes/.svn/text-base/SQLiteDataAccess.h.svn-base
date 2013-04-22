//
//  UsayDBData.h
//  USayApp
//
//  Created by Jong-Sung Park on 10. 6. 1..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <sqlite3.h>

@interface SQLiteDataAccess : NSObject {
	sqlite3 *database;
	NSString *pathToDatabase;
	BOOL logging;
	BOOL existError;
}
@property (nonatomic, retain)NSString * pathToDatabase;
@property (nonatomic)BOOL logging;
@property (nonatomic)BOOL existError;

-(id)initWithPath: (NSString *)filePath;
-(id)initWithFileName:(NSString *)fileName;
-(id)initWithCopyFileName:(NSString *)fileName;
-(BOOL)replaceDBFile:(NSString *)fileName;

- (NSArray *) executeSql: (NSString *) sql;
-(NSArray *)executeSql:(NSString *)sql withParameters:(NSArray *)parameters;
-(NSArray *)SyncExecuteSql:(NSString *)sql withParameters:(NSArray *)parameters;
-(NSArray*)executeSqlWithParameters:(NSString *)sql, ...;
- (NSArray *) executeSql: (NSString *) sql withParameters: (NSArray *) parameters withClassForRow: (Class) rowClass;
- (NSArray *) SyncExecuteSql: (NSString *) sql withParameters:(NSArray *)parameters withClassForRow:(Class)rowClass;
- (NSArray *) tableNames;
- (NSArray *) columnsForTableName: (NSString *) tableName;

-(void)beginTransaction;
-(void)commit;
-(void)rollback;
- (NSUInteger) lastInsertRowId;
-(BOOL)hasError;
@end
