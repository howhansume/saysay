//
//  UsayDBData.m
//  USayApp
//
//  Created by Jong-Sung Park on 10. 6. 1..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "SQLiteDataAccess.h"

@interface SQLiteDataAccess(PrivateMethods)
- (void) open;
-(void) close;
- (NSArray *) columnNamesForStatement: (sqlite3_stmt *) statement;
- (NSArray *) columnTypesForStatement: (sqlite3_stmt *) statement;
- (int) typeForStatement: (sqlite3_stmt *) statement column: (int) column;
- (int) columnTypeToInt: (NSString *) columnType;
- (void) copyValuesFromStatement: (sqlite3_stmt *) statement toRow: (id) row queryInfo: (NSDictionary *) queryInfo columnTypes: (NSArray *) columnTypes columnNames: (NSArray *) columnNames;
- (id) valueFromStatement: (sqlite3_stmt *) statement column: (int) column queryInfo: (NSDictionary *) queryInfo columnTypes: (NSArray *) columnTypes;
- (void) bindArguments: (NSArray *) arguments toStatement: (sqlite3_stmt *) statement queryInfo: (NSDictionary *) queryInfo;
-(void) raiseSqliteException:(NSString *)errorMessage;
@end

@implementation SQLiteDataAccess

@synthesize pathToDatabase;
@synthesize logging;
@synthesize existError;

-(id) initWithPath:(NSString *)filePath{
	if(self = [super init])
	{
		self.pathToDatabase = filePath;
		[self open];
	}
	return self;
}

-(id)initWithFileName:(NSString *)fileName{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:fileName];
	//파일이 Documents에 존재하는지 확인
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL exist = [fileManager fileExistsAtPath:dbPath];
	if(exist){
		self = [self initWithPath:dbPath];
	}else {
		self = nil;
	}
	
	return self;
}

-(id) initWithCopyFileName:(NSString *)fileName {//데이터 베이스 파일을 리소스에서 복사하여 경로에 붙여넣기.
	//Documents 디렉터리 와 db 파일 경로 얻어 오기
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:fileName];
//	NSString *bundleDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
	
//	NSFileManager *fileManager = [NSFileManager defaultManager];
//	NSError *error;
//	BOOL exist = [fileManager copyItemAtPath:bundleDBPath toPath:dbPath error:&error];
	
	return [self initWithPath:dbPath];
}

-(BOOL)replaceDBFile:(NSString *)fileName {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:fileName];
	NSString *bundleDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	BOOL exist = NO;
	if([fileManager fileExistsAtPath:dbPath]) {
		[self close];
		BOOL remove = [fileManager removeItemAtPath:dbPath error:&error];
		
		if(remove)
			exist = [fileManager copyItemAtPath:bundleDBPath toPath:dbPath error:&error];
		
		if(exist)
			[self open];
	}
	
	return exist;
}

#pragma mark -
#pragma mark Opening and Closing the Database
-(void)close{
	if(sqlite3_close(database) != SQLITE_OK){
		[self raiseSqliteException:@"failed to close database with message '%S'."];
	}else {
		existError = NO;
	}

}

-(void)open{
	if (sqlite3_open([self.pathToDatabase UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
		[self raiseSqliteException:@"failed to open database with message '%S'."];
	}else {
		existError = NO;
	}

	
}
-(BOOL)hasError {
	return existError;
}
- (NSUInteger) lastInsertRowId
{
	return (NSUInteger) sqlite3_last_insert_rowid(database);
}

#pragma mark -
#pragma mark Exception Handling
-(void) raiseSqliteException:(NSString *)errorMessage{
	existError = YES;
	[NSException raise:@"SQLiteDataAccessException" format:@"message %S", sqlite3_errmsg16(database)];
}

-(void) raiseSqliteSyncDataException:(NSString *)errorMessage{
	existError = YES;
//	[NSException raise:@"SQLiteDataAccessException" format:@"message %S", sqlite3_errmsg16(database)];
}

-(void)dealloc{
	[self close];
	[pathToDatabase release];
	[super dealloc];
}
#pragma mark -
#pragma mark syncData SQL
- (NSArray *) SyncExecuteSql: (NSString *) sql withParameters:(NSArray *)parameters withClassForRow:(Class)rowClass
{
	NSMutableDictionary *queryInfo = [NSMutableDictionary dictionary];
	[queryInfo setObject:sql forKey:@"sql"];
	
	if(parameters == nil)
	{
		parameters = [NSArray array];
	}
	
	[queryInfo setObject:parameters forKey:@"parameters"];
	
	NSMutableArray *rows = [NSMutableArray array];
	
#if TARGET_IPHONE_SIMULATOR
//	NSLog(@"SQL: %@ \n parameters: %@", sql, parameters);
#endif
	sqlite3_stmt *statement = NULL;
	if(sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK)
	{
		[self bindArguments: parameters toStatement: statement queryInfo: queryInfo];
		
		BOOL needsToFetchColumnTypesAndNames = YES;
		NSArray *columnTypes = nil;
		NSArray *columnNames = nil;
		
		while (sqlite3_step(statement) == SQLITE_ROW) {
			if(needsToFetchColumnTypesAndNames)
			{
				columnTypes = [self columnTypesForStatement: statement];
				columnNames = [self columnNamesForStatement: statement];
				needsToFetchColumnTypesAndNames = NO;
			}
			
			id row = [[rowClass alloc] init];
			[self copyValuesFromStatement: statement toRow: row queryInfo: queryInfo columnTypes: columnTypes columnNames: columnNames];
			[rows addObject:row];
			[row release];
		}
		sqlite3_finalize(statement);
		return rows;
	}else{
		sqlite3_finalize(statement);
		[self raiseSqliteSyncDataException: [[NSString stringWithFormat:@"failed to execute statement: '%@', parameters: '%@' with message: ", sql, parameters] stringByAppendingString:@"%S"]];
	}
	
	return nil;
}

-(NSArray *)SyncExecuteSql:(NSString *)sql withParameters:(NSArray *)parameters{
	return [self SyncExecuteSql:sql withParameters:parameters withClassForRow: [NSMutableDictionary class]];
}

#pragma mark -
#pragma mark SQL
- (NSArray *) executeSql: (NSString *) sql withParameters:(NSArray *)parameters withClassForRow:(Class)rowClass
{
	//20101001
	NSMutableDictionary *queryInfo = [NSMutableDictionary dictionary];
	[queryInfo setObject:sql forKey:@"sql"];
	
	if(parameters == nil)
	{
		parameters = [NSArray array];
	}
	
	[queryInfo setObject:parameters forKey:@"parameters"];
	
	NSMutableArray *rows = [NSMutableArray array];


	
	
//#if TARGET_IPHONE_SIMULATOR
//	NSLog(@"SQL: %@ \n parameters: %@", sql, parameters);
//#endif
	sqlite3_stmt *statement = NULL;
	if(sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK)
	{
		[self bindArguments: parameters toStatement: statement queryInfo: queryInfo];
		
		BOOL needsToFetchColumnTypesAndNames = YES;
		NSArray *columnTypes = nil;
		NSArray *columnNames = nil;
		
		while (sqlite3_step(statement) == SQLITE_ROW) {
			if(needsToFetchColumnTypesAndNames)
			{
				columnTypes = [self columnTypesForStatement: statement];
				columnNames = [self columnNamesForStatement: statement];
				needsToFetchColumnTypesAndNames = NO;
			}
			
			id row = [[rowClass alloc] init];
			[self copyValuesFromStatement: statement toRow: row queryInfo: queryInfo columnTypes: columnTypes columnNames: columnNames];
			[rows addObject:row];
			[row release];
		}
		sqlite3_finalize(statement);
		return rows;
	}else{
		sqlite3_finalize(statement);
		[self raiseSqliteException: [[NSString stringWithFormat:@"failed to execute statement: '%@', parameters: '%@' with message: ", sql, parameters] stringByAppendingString:@"%S"]];
	}
	
	return nil;
}

-(NSArray *)executeSql:(NSString *)sql withParameters:(NSArray *)parameters{
//	NSLog(@"exec sql = %@", sql);
	return [self executeSql:sql withParameters:parameters withClassForRow: [NSMutableDictionary class]];
}

-(NSArray *)executeSql:(NSString *)sql{
	return [self executeSql:sql withParameters:nil];
}


-(NSArray*)executeSqlWithParameters:(NSString *)sql, ...
{
	va_list argumentList;
	va_start(argumentList, sql);
	NSMutableArray *arguments = [NSMutableArray array];
	id argument;
	
	while(argument = va_arg(argumentList, id)){
		[arguments addObject:argument];
	}
	
	va_end(argumentList);
	
	return [self executeSql:sql withParameters:arguments];
}

-(NSArray *)columnNamesForStatement:(sqlite3_stmt *)statement {
	int columnCount = sqlite3_column_count(statement);
	
	NSMutableArray *columnNames = [NSMutableArray array];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	for(int i = 0;i<columnCount;i++){
		[columnNames addObject:[NSString stringWithUTF8String:sqlite3_column_name(statement, i)]];
	}
	[pool release];
	return columnNames;
}

-(NSArray *)columnTypesForStatement:(sqlite3_stmt *)statement{
	int columnCount = sqlite3_column_count(statement);
	
	NSMutableArray *columnTypes = [NSMutableArray array];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	for(int i = 0;i<columnCount;i++){
		[columnTypes addObject:[NSNumber numberWithInt:[self typeForStatement:statement column:i]]];
	}
	[pool release];
	return columnTypes;
}

-(int) typeForStatement:(sqlite3_stmt *)statement column:(int)column{
	const char* columnType = sqlite3_column_decltype(statement, column);
	if(columnType != NULL){
		return [self columnTypeToInt:[[NSString stringWithUTF8String:columnType] uppercaseString]];
	}
	return sqlite3_column_type(statement, column);
}

-(int)columnTypeToInt:(NSString*)columnType{
	
	if([columnType isEqualToString:@"INTEGER"])
	{
		return SQLITE_INTEGER;
	}else if([columnType isEqualToString:@"REAL"])
	{
		return SQLITE_FLOAT;
	}else if([columnType isEqualToString:@"TEXT"])
	{
		return SQLITE_TEXT;
	}else if ([columnType isEqualToString:@"BLOB"])
	{
		return SQLITE_BLOB;
	}else if ([columnType isEqualToString:@"NULL"])
	{
		return SQLITE_NULL;
	}
	
	return SQLITE_TEXT;
}

-(void) copyValuesFromStatement:(sqlite3_stmt *)statement toRow:(NSMutableDictionary *)row queryInfo:(NSDictionary *)queryInfo columnTypes:(NSArray *)columnTypes columnNames:(NSArray *)columnNames
{
	int columnCount = sqlite3_column_count(statement);
	
	for(int i = 0;i<columnCount;i++){
		 NSAutoreleasePool * valuepool = [[NSAutoreleasePool alloc] init];
		id value = [self valueFromStatement:statement column:i queryInfo:queryInfo columnTypes:columnTypes];
		
		if(value != nil){
//			NSLog(@"%@ columnames %@",value,[columnNames objectAtIndex:i]);
			[row setValue:value forKey:[columnNames objectAtIndex:i]];
		}
		[valuepool release];
	}
}

-(id)valueFromStatement:(sqlite3_stmt *)statement column:(int)column 
			  queryInfo:(NSDictionary *)queryInfo columnTypes:(NSArray *)columnTypes
{
	int columnType = [[columnTypes objectAtIndex:column] intValue];
	
	//sql의 기능을 이용해서 알맞은 형식으로 형변환을 실시. 이렇게 하면 NSNULL 값을 할당하는 문제를 방지할 수 있다.
	if(columnType == SQLITE_INTEGER){
		return [NSNumber numberWithInt:sqlite3_column_int(statement, column)];
	}else if(columnType == SQLITE_FLOAT){
		return [NSNumber numberWithDouble:sqlite3_column_double(statement, column)];
	}else if(columnType == SQLITE_TEXT){
		const char* text = (const char *)sqlite3_column_text(statement, column);
		if(text != nil) return [NSString stringWithUTF8String:text];
		else return nil;
	}else if(columnType == SQLITE_BLOB){
		//NSData 객체를 해당 크기의 blob으로 생성한다.
		return [NSData dataWithBytes:sqlite3_column_blob(statement, column) length:sqlite3_column_bytes(statement, column)];
	}else if(columnType == SQLITE_NULL){
		return nil;
	}
	
	return nil;
}

-(void)bindArguments:(NSArray *)arguments toStatement:(sqlite3_stmt*)statement queryInfo:(NSDictionary *)queryInfo {
	
	int expectedArguments = sqlite3_bind_parameter_count(statement);
	
	NSAssert2(expectedArguments == [arguments count], @"Number of bound parameters does not match for sql: %@ parameters:'%@'",
			  [queryInfo objectForKey:@"sql"], [queryInfo objectForKey:@"parameters"]);
	
	for(int i = 1;i<=expectedArguments;i++){
		id argument = [arguments objectAtIndex:i - 1];
		if([argument isKindOfClass:[NSString class]])
			sqlite3_bind_text(statement, i, [argument UTF8String], -1, SQLITE_TRANSIENT);
		else if([argument isKindOfClass:[NSData class]])
			sqlite3_bind_blob(statement, i, [argument bytes], [argument length], SQLITE_TRANSIENT);
		else if([argument isKindOfClass:[NSDate class]])
			sqlite3_bind_double(statement, i, [argument timeIntervalSince1970]);
		else if([argument isKindOfClass:[NSNumber class]])
			sqlite3_bind_double(statement, i, [argument doubleValue]);
		else if([argument isKindOfClass:[NSNull class]])
			sqlite3_bind_null(statement, i);
		else {
			sqlite3_finalize(statement);
			[NSException raise:@"Unrecognized object type" format:@"Active record doesn't know how to handle object:'%@' bound to sql: %@ position: %i", 
			 argument, [queryInfo objectForKey:@"sql"], i];
		}

	}
}


#pragma mark -
#pragma mark Table Info
- (NSArray *) tables
{
	return [self executeSql:@"select * from sqlite_master where type = 'table'"];
}

- (NSArray *) tableNames
{
	return [[self tables] valueForKey:@"name"];
}

- (NSArray *) columnsForTableName: (NSString *) tableName
{	
	NSArray *results = [self executeSql: [NSString stringWithFormat:@"pragma table_info(%@)", tableName]];
	
	return [results valueForKey:@"name"];
}

#pragma mark -
#pragma mark Transaction Support
-(void)beginTransaction{
	[self executeSql:@"BEGIN IMMEDIATE TRANSACTION;"];
}

-(void)commit{
	[self executeSql:@"COMMIT TRANSACTION;"];
}
	 
-(void)rollback{
	[self executeSql:@"ROLLBACK TRANSACTION;"];
}


@end
