//
//  DataAccessObject.m
//  USayApp
//
//  Created by Jong-Sung Park on 10. 6. 27..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "DataAccessObject.h"
#import "SQLiteDataAccess.h"
#import <objc/runtime.h>
#import "USayDefine.h"			// sochae 2010.10.05

static SQLiteDataAccess *database = nil;
static NSMutableDictionary *tableCache = nil;

@implementation DataAccessObject
@synthesize primaryKey;
@synthesize savedInDatabase;

+ (void) setDatabase: (SQLiteDataAccess *) newDatabase
{
	[database autorelease];
	database = [newDatabase retain];
}

+ (SQLiteDataAccess *) database
{
	return database;
}

+ (NSString *) tableName
{
	return [NSString stringWithFormat:@"_T%@",NSStringFromClass([self class])];
}

+ (void) assertDatabaseExists
{
	NSAssert1(database, @"Database not set.  Set the database using [DataAccessObject setDatabase] before using ActiveRecord.", @"");
}

//테이블에서 칼럼명만 구한다
- (NSArray *) columns
{
	if(tableCache == nil)
	{
		tableCache = [[NSMutableDictionary dictionary] retain];
	}
	
	NSString *tableName = [[self class] tableName];
//	NSLog(@"==========칼럼 구하는곳 테이블명은 tableName:%@", tableName);
	NSArray *columns = [tableCache objectForKey:tableName];
	for (int i=0; i<[columns count]; i++) {
	//	NSLog(@"#######columns[%d]:%@#########", i, [columns objectAtIndex:i]);
	}
	
	if(columns == nil)
	{
		columns = [database columnsForTableName: tableName];
		[tableCache setObject: columns forKey: tableName];
	//	NSLog(@"######Columns nil#########");
	}
	
	return columns;
}

- (NSArray *) columnsWithoutPrimaryKey
{
	NSMutableArray *columns = [NSMutableArray arrayWithArray: [self columns]];
	[columns removeObjectAtIndex:0];
	
	return columns;
}

- (NSArray *) columnsWithoutPrimaryKeyWithoutNullValue
{
	NSMutableArray *columns = [NSMutableArray arrayWithArray: [self columns]];
	NSMutableArray *withoutNullColumns = [NSMutableArray array];
	for(NSString* key in columns){
		if([key isEqualToString:@"INDEXNO"])
			continue;
		if([self valueForKey:key])
			[withoutNullColumns addObject:key];
	}
	
	return withoutNullColumns;
}

- (NSArray *) propertyWithoutNullValues
{
	NSMutableArray *values = [NSMutableArray array];
	for(NSString *columnName in [self columnsWithoutPrimaryKey])
	{
	//	NSLog(@"columnName = %@", columnName);
		id value = [self valueForKey: columnName];
	//	NSLog(@"vale = %@", value);
		
		if(value != nil)
		{
			[values addObject: value];
		}
	}
	return values;
}

- (NSArray *) propertyValues
{
	NSMutableArray *values = [NSMutableArray array];
	for(NSString *columnName in [self columnsWithoutPrimaryKey])
	{
		id value = [self valueForKey: columnName];
		
		if(value != nil)
		{
			[values addObject: value];
		}else{
			[values addObject:[NSNull null]];
		}
	}
	return values;
}
#pragma mark -
#pragma mark create table Method
-(void) createTableForClass {
	NSMutableArray *columnList = [NSMutableArray array];
	NSMutableArray* keyArray = [NSMutableArray array];
	NSMutableArray* typeArray = [NSMutableArray array];

	NSAutoreleasePool* varpool = [[NSAutoreleasePool alloc] init];
	unsigned int numIvars = 0;
    Ivar* ivars = class_copyIvarList([self class], &numIvars);
    for(int i = 0; i < numIvars; i++) {
		Ivar thisIvar = ivars[i];
		NSString * key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
		
		NSString * type = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivars[i])];
		if ([type length] > 3) {
			NSString * class = [type substringWithRange:NSMakeRange(2, [type length]-3)];
			[typeArray addObject:class];
		}
		[keyArray addObject:key];
		
    }
	if(numIvars > 0)free(ivars);
	[varpool release];
	for(int i = 0; [keyArray count] > i ; i++) {
		NSString* key = [keyArray objectAtIndex:i];
		Class typeClass = NSClassFromString([typeArray objectAtIndex:i]);
	//	id typeClass = [[class alloc] init];
		
		if([typeClass isEqual:[NSString class]]){
			[columnList addObject:[NSString stringWithFormat:@"%@ TEXT",key]];
		}else if([typeClass isEqual:[NSData class]]){
			[columnList addObject:[NSString stringWithFormat:@"%@ BLOB",key]];
		}else if([typeClass isEqual:[NSDate class]]){
			[columnList addObject:[NSString stringWithFormat:@"%@ DOUBLE",key]];
		}else if([typeClass isEqual:[NSNumber class]]){
			if([key isEqualToString:@"INDEXNO"])
				[columnList addObject:[NSString stringWithFormat:@"%@ INTEGER PRIMARY KEY AUTOINCREMENT",key]];
			else if([key isEqualToString:@"LASTUPDATETIME"]) 
				[columnList addObject:[NSString stringWithFormat:@"%@ BIGINT",key]];
			else if([key isEqualToString:@"LASTMSGDATE"]) 
				[columnList addObject:[NSString stringWithFormat:@"%@ BIGINT",key]];
			else if([key isEqualToString:@"REGDATE"])
				[columnList addObject:[NSString stringWithFormat:@"%@ BIGINT",key]];
			else
				[columnList addObject:[NSString stringWithFormat:@"%@ INTEGER",key]];
		}else{
			[columnList addObject:[NSString stringWithFormat:@"%@ TEXT",key]];
		}
	}
	
	NSString *sql = nil;
	if ([[[self class] tableName] isEqualToString:@"_TRoomInfo"]) {
		sql = [NSString stringWithFormat:@"create table %@ (%@%@)", [[self class] tableName], 
											[columnList componentsJoinedByString:@","], @",UNIQUE (CHATSESSION,LASTMESSAGEKEY)"];
	} else if ([[[self class] tableName] isEqualToString:@"_TMessageInfo"]) {
		sql = [NSString stringWithFormat:@"create table %@ (%@%@)", [[self class] tableName], 
											[columnList componentsJoinedByString:@","], @",UNIQUE (MESSAGEKEY)"];
	} else {
		sql = [NSString stringWithFormat:@"create table %@ (%@)", [[self class] tableName], 
											[columnList componentsJoinedByString:@","]];
	}

	
	
	[database executeSql: sql];
	
	
	[[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"DATABASE"];
	
		NSLog(@"exec bb %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"DATABASE"]);
	
	
}

#pragma mark -
#pragma mark Insert/Update/Delete
- (void) beforeSave
{
	NSString* value = [self valueForKey:@"ID"];
	NSString* column = [NSString stringWithString:@"ID"];
	NSString *sql = [NSString stringWithFormat:@"select INDEXNO from %@ where %@=?", [[self class] tableName],column];
	NSArray* array = [[self class] findWithSqlWithParameters:sql,value,nil];
	if(array!=nil && [array count]>0){
		primaryKey = [[[array objectAtIndex:0] valueForKey:@"INDEXNO"] integerValue];
		savedInDatabase = YES;
	}else {
		savedInDatabase = NO;
	}

}

- (void) saveSyncData
{
	[[self class] assertDatabaseExists];
	
	[self beforeSave];
	
	if(!savedInDatabase)
	{
		[self insertSyncData];
	}else{
		[self updateSyncData];
	}
}

- (void) insertSyncData
{
	NSMutableArray *parameterList = [NSMutableArray array];
	
	NSArray *columnsWithoutPrimaryKey = [self columnsWithoutPrimaryKey];
	
	for(int i = 0; i < [columnsWithoutPrimaryKey count]; i++)
	{
		[parameterList addObject: @"?"];
	}
	
	
	
		
	
	
	NSString *sql = [NSString stringWithFormat:@"insert into %@ (%@) values(%@)", [[self class] tableName], [columnsWithoutPrimaryKey componentsJoinedByString: @","], 
					 [parameterList componentsJoinedByString:@","]];
	
//	NSLog(@"===========insertSyncData================\n %@ \n parameter:%@", sql, [self propertyValues]);
	//	NSArray* resultArray = nil;
	[database SyncExecuteSql: sql withParameters: [self propertyValues]];
	savedInDatabase = YES;
	primaryKey = [database lastInsertRowId];
	
	
	
	//RP 값및 싱크데이터
//	[[NSUserDefaults standardUserDefaults] setObject:[[self propertyValues] objectAtIndex:32] forKey:@"RevisionPoints"];
//	NSLog(@"RPVALUE = %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"RevisionPoints"]);
	
	
/*	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	NSLocale *locale = [NSLocale currentLocale];
	[formatter setLocale:locale];
	[formatter setDateFormat:@"yyyyMMddHHmmss"];
	NSDate *today = [NSDate date];
	NSString *lastSyncDate = [[NSString alloc] initWithFormat:@"%@",[formatter stringFromDate:today]];
//	[[NSUserDefaults standardUserDefaults] setObject:lastSyncDate forKey:@"lastSyncDate"];
*/	
	
//	NSLog(@"sync data = %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"lastSyncDate"]);
	
	
	
	if([[[self propertyValues] objectAtIndex:1] isEqualToString:@"4"])
	{
	//	exit(1);
	//	NSLog(@"여기 부터 들어오면 처음부터 다시 받는구나....");
	}
	 
//	[database commit];
	
}

- (void) updateSyncData
{
	NSString *setValues = [[[self columnsWithoutPrimaryKeyWithoutNullValue] componentsJoinedByString:@" = ?, "] stringByAppendingString:@" = ?"];
	NSString *sql = [NSString stringWithFormat:@"update %@ set %@ where INDEXNO = ?", [[self class] tableName], setValues];
	
	
	DebugLog(@"===========updateSyncData===========\n%@ \n parameter:%@", sql, [self propertyValues]);
	
	NSArray *parameters = [[self propertyWithoutNullValues] arrayByAddingObject: [NSNumber numberWithUnsignedInt:primaryKey]];
	for (int i=0; i<[parameters count]; i++) {
		//NSLog(@"parameters = %@", [parameters objectAtIndex:i]);
	}
	
	
	
	[database SyncExecuteSql: sql withParameters: parameters];
	savedInDatabase = YES;
}

- (void) saveData
{
	[[self class] assertDatabaseExists];
	
	[self beforeSave];
	
	if(!savedInDatabase)
	{
		[self insert];
	}else{
		[self update];
	}
}

- (void) insert
{
	NSMutableArray *parameterList = [NSMutableArray array];
	
	NSArray *columnsWithoutPrimaryKey = [self columnsWithoutPrimaryKey];
	
	for (int i=0; i<[columnsWithoutPrimaryKey count]; i++) {
		//NSLog(@"PKEY = %@", [columnsWithoutPrimaryKey objectAtIndex:i]);
	}
	
	for(int i = 0; i < [columnsWithoutPrimaryKey count]; i++)
	{
		[parameterList addObject: @"?"];
	}
	
	
	
		
	
	
//	NSLog(@">>>>>>>>>>>>>>>>>>>>INSERT QUERY<<<<<<<<<<<<<<<");
	
	//mezzo 인서트 할때 TUserInfo 에 같은 칼럼이 있는지 찾아서 있으면 걍 리턴 시킨다..
	
	if([[[self class]tableName] isEqualToString:@"_TUserInfo"])
	{
		
		NSString *MOBILEPHONENUMBER;
		NSString *IPHONENUMBER;
		NSString *HOMEPHONENUMBER;
		NSString *ORGPHONENUMBER;
		NSString *MAINPHONENUMBER;
		
		
		if([[self propertyValues] objectAtIndex:9] == [NSNull null])
		{
			MOBILEPHONENUMBER = @"isnull";
		}else {
		//	MOBILEPHONENUMBER = [[self propertyValues] objectAtIndex:9];
			MOBILEPHONENUMBER =[NSString stringWithFormat:@"='%@'", [[self propertyValues] objectAtIndex:9]];
		}
		
		if([[self propertyValues] objectAtIndex:10] == [NSNull null])
		{
			IPHONENUMBER = @"isnull";
		//	NSLog(@"nullllllllll");
		}else {
			NSLog(@"pro %d", [[[self propertyValues] objectAtIndex:10] length]);
			//IPHONENUMBER = [[self propertyValues] objectAtIndex:10];
			IPHONENUMBER =[NSString stringWithFormat:@"='%@'", [[self propertyValues] objectAtIndex:10]];

		}
		
		if([[self propertyValues] objectAtIndex:11] == [NSNull null])
		{
			HOMEPHONENUMBER = @"isnull";
		}else {
			//HOMEPHONENUMBER = [[self propertyValues] objectAtIndex:11];
			HOMEPHONENUMBER =[NSString stringWithFormat:@"='%@'", [[self propertyValues] objectAtIndex:11]];

		}

		if([[self propertyValues] objectAtIndex:12] == [NSNull null])
		{
			ORGPHONENUMBER = @"isnull";
		}else {
			ORGPHONENUMBER =[NSString stringWithFormat:@"='%@'", [[self propertyValues] objectAtIndex:12]];

		//	ORGPHONENUMBER = [[self propertyValues] objectAtIndex:12];
		}

		if([[self propertyValues] objectAtIndex:13] == [NSNull null])
		{
			MAINPHONENUMBER = @"isnull";
		}else {
			MAINPHONENUMBER =[NSString stringWithFormat:@"='%@'", [[self propertyValues] objectAtIndex:13]];

		//	MAINPHONENUMBER = [[self propertyValues] objectAtIndex:13];
		}

		NSArray *tmpArray;
		
		if ([[self propertyValues] objectAtIndex:3] == [NSNull null])
		{
			tmpArray = nil;
		}
		else
		{
		//	NSLog(@"MOBILEPHONENUMBER IPHONENUMBER HOMEPHONENUMBER ORGPHONENUMBER MAINPHONENUMBER %@ %@ %@ %@ %@", MOBILEPHONENUMBER, IPHONENUMBER, HOMEPHONENUMBER,	ORGPHONENUMBER, MAINPHONENUMBER);
			// sochae 2010.10.05 - sql query 수정
			/*
			NSString *selectSql = [NSString stringWithFormat:@"select * from _TUserInfo where "
								   "MOBILEPHONENUMBER %@ "
								   "AND IPHONENUMBER %@ " 
								   "AND HOMEPHONENUMBER %@ "
								   "AND ORGPHONENUMBER %@ "
								   "AND MAINPHONENUMBER %@ "
								   "and FORMATTED = \'%@\' ",
								   MOBILEPHONENUMBER,
								   IPHONENUMBER,
								   HOMEPHONENUMBER,
								   ORGPHONENUMBER,
								   MAINPHONENUMBER,
								   [[self propertyValues] objectAtIndex:3]];
			*/
			NSString *strTemp = [NSString stringWithFormat:@"%@", [[self propertyValues] objectAtIndex:3]] ;
			strTemp = [strTemp stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
		//	DebugLog(@"formatted : %@", strTemp);

			NSString *selectSql = [NSString stringWithFormat:@"select * from _TUserInfo where "
								   "MOBILEPHONENUMBER %@ "
								   "AND IPHONENUMBER %@ " 
								   "AND HOMEPHONENUMBER %@ "
								   "AND ORGPHONENUMBER %@ "
								   "AND MAINPHONENUMBER %@ "
								   "and FORMATTED = '%@' ",
								   MOBILEPHONENUMBER,
								   IPHONENUMBER,
								   HOMEPHONENUMBER,
								   ORGPHONENUMBER,
								   MAINPHONENUMBER,
								   strTemp];
			// ~sochae
		//	DebugLog(@"QUERY = %@", selectSql);
			
			tmpArray = [[self class] findWithSqlWithParameters:selectSql, nil];
			
		}
		
		//
		if(tmpArray == nil || tmpArray == NULL || [tmpArray count] <=0)
		{
			DebugLog(@"NOT FOUND OK");
			
			NSString *sql = [NSString stringWithFormat:@"insert into %@ (%@) values(%@)", [[self class] tableName], [columnsWithoutPrimaryKey componentsJoinedByString: @","], 
							 [parameterList componentsJoinedByString:@","]];
			DebugLog(@"===============>INSERT QUERY %@ %@<=========================", sql, [self propertyValues]);
			
			
	
			//	NSArray* resultArray = nil;
			[database executeSql: sql withParameters: [self propertyValues]];
			savedInDatabase = YES;
			primaryKey = [database lastInsertRowId];
			
			
			/*
			
				if([[self propertyValues] objectAtIndex:9] == [NSNull null] && [[self propertyValues] objectAtIndex:10] == [NSNull null] && [[self propertyValues] objectAtIndex:11] == [NSNull null] && [[self propertyValues] objectAtIndex:12] == [NSNull null] && [[self propertyValues] objectAtIndex:13] == [NSNull null])
				{
			//		NSLog(@"여기 들어와야지 ........");
					NSString *update = [NSString stringWithFormat:@"update _TUserInfo set FORMATTED='' where id='%@'", [[self propertyValues] objectAtIndex:1]];
					NSLog(@"update sql = %@", update);
					[database executeSql:update];
					
				}
			 */
				return;
		}
		else {
			NSLog(@"FIND %@", [[self propertyValues] objectAtIndex:9]);
			return;
		}
	}
	
	NSString *sql = [NSString stringWithFormat:@"insert into %@ (%@) values(%@)", [[self class] tableName], [columnsWithoutPrimaryKey componentsJoinedByString: @","], 
					 [parameterList componentsJoinedByString:@","]];
	
	
	
	
	[database executeSql: sql withParameters: [self propertyValues]];
	
	
	
	savedInDatabase = YES;
	primaryKey = [database lastInsertRowId];
	
	
	

	
	
	
		
}

- (void) update
{
	
	
	//mezzo 2011 update 문에서 ISBLOCK를 뺀다 아마 친구니깐 무조건 블록이 N이라고 생각한 모양이다.
	NSString *setValues = [[[self columnsWithoutPrimaryKeyWithoutNullValue] componentsJoinedByString:@" = ?, "] stringByAppendingString:@" = ?"];
	
//	NSLog(@"DataAccessObject update method = %@", setValues);
	//NSLog(@"setValues = %@", setValues);
	NSString *setNewValue = [setValues stringByReplacingOccurrencesOfString:@"ISBLOCK = ?, " withString:@""];
//	NSLog(@"setNewValue = %@", setNewValue);
	NSArray *parameters = [[self propertyWithoutNullValues] arrayByAddingObject: [NSNumber numberWithUnsignedInt:primaryKey]];
	int number=0;

	
	//문자열을 배열로 치환
	NSArray *tmpArray = [setValues componentsSeparatedByString:@", "];
	
	NSLog(@"tmp cnt  =  %d", [tmpArray count]);
	if ([tmpArray count] <14) {
		for(int i=0; i<[tmpArray count]; i++)
		{
			//NSLog(@"tmpArray name:%@", [tmpArray objectAtIndex:i]);
			if([[tmpArray objectAtIndex:i] isEqualToString:@"ISBLOCK = ?"])
			{
				number = i;
				break;
			}
		}
		NSString *sql = [NSString stringWithFormat:@"update %@ set %@ where INDEXNO = ?", [[self class] tableName], setNewValue];
		
	//	NSLog(@"DataAccessObject update method \n Query = %@", sql);
		
		NSMutableArray *newparameters = [[NSMutableArray alloc] init];
		for (int i=0; i<[parameters count]; i++) {
			if (i==number) {
				continue;
			}
			//	NSLog(@"parameters index:%d value:%@", i, [parameters objectAtIndex:i]);
			[newparameters addObject:[parameters objectAtIndex:i]];
		}
		for (int i=0; i<[newparameters count]; i++) {
	//		NSLog(@"parameters index:%d value:%@", i, [newparameters objectAtIndex:i]);
		}
	//	NSLog(@"update sqlAAAA = %@", sql);
		
		
		//20101001 구정현 쿼리에서 아이디가 들어갈 필요가 없다.
		NSString *tmpSql;
		
		if([sql isEqualToString:@"update _TGroupInfo set ID = ?, GROUPTITLE = ?, RPUPDATED = ? where INDEXNO = ?"])
		{
			
			tmpSql = [NSString stringWithFormat:@"update _TGroupInfo set GROUPTITLE = ?, RPUPDATED = ? where INDEXNO = ?"];
		//	NSLog(@"testsql = %@", tmpSql);
			
			[database executeSql: tmpSql withParameters: newparameters];
		}
		else if([sql isEqualToString:@"update _TGroupInfo set ID = ?, GROUPTITLE = ?, RPCREATED = ?, SIDCREATED = ?, SIDUPDATED = ?, CONTACTCOUNT = ? where INDEXNO = ?"])
		{
			tmpSql = [NSString stringWithFormat:@"update _TGroupInfo set GROUPTITLE = ?, RPCREATED = ?, SIDCREATED = ?, SIDUPDATED = ?, CONTACTCOUNT = ? where INDEXNO = ?"];
		//	NSLog(@"testsql = %@", tmpSql);
			[database executeSql: tmpSql withParameters: newparameters];
			
			
		}
		else {
			
			
			NSString *tmp2 = [sql stringByReplacingOccurrencesOfString:@"update _TGroupInfo set ID = ?," withString:@"update _TGroupInfo set"];

		//	NSLog(@"==========>tmp2 = %@", tmp2);
			[database executeSql:tmp2 withParameters: newparameters];	
		}

		
		
		
	}//진짜 친구 차단 할 경우
	else {
		NSString *sql = [NSString stringWithFormat:@"update %@ set %@ where INDEXNO = ?", [[self class] tableName], setValues];

		NSLog(@"DataAccessObjec update 친구차단 \n %@", sql);
		[database executeSql: sql withParameters: parameters];
		
	}
	[database commit];
	//	NSLog(@"number = %d", number);
	
	
	
	/*
	NSLog(@"update sql = %@", sql);
	
	NSString *testQuery = @"select ID from _TUserInfo where ISBLOCK='Y'";
	NSArray* tmpArray =  [database executeSql:testQuery];
	if(tmpArray == nil || tmpArray == NULL || [tmpArray count]< 0)
	{
		NSLog(@"=================not found============");
	}
	else
	{
		NSLog(@"ID === %@", tmpArray);
	}
	*/
	savedInDatabase = YES;
}

- (void) beforeDelete
{
	NSString* value = [self valueForKey:@"ID"];
	NSString* column = [NSString stringWithString:@"ID"];
	NSString *sql = [NSString stringWithFormat:@"select INDEXNO from %@ where %@=?", [[self class] tableName],column];
	NSArray* array = [[self class] findWithSqlWithParameters:sql,value,nil];
	if(array!=nil && [array count]>0){
		primaryKey = [[[array objectAtIndex:0] valueForKey:@"INDEXNO"] integerValue];
		savedInDatabase = YES;
	}else {
		savedInDatabase = NO;
	}

	
}

- (void) deleteData
{
	[[self class] assertDatabaseExists];
	
	[self beforeDelete];
	
	if(!savedInDatabase)
	{
		return;
	}
	
	NSString *sql = [NSString stringWithFormat:@"delete from %@ where INDEXNO = ?", [[self class] tableName]];
	[database executeSqlWithParameters: sql, [NSNumber numberWithUnsignedInt:primaryKey], nil];
	savedInDatabase = NO;
	primaryKey = 0;
}

#pragma mark -
#pragma mark Find Model Objects

+ (NSArray *) findWithSql: (NSString *) sql withParameters: (NSArray *) parameters
{
	[self assertDatabaseExists];
	
	NSArray *results = [database executeSql:sql withParameters: parameters withClassForRow: [self class]];
	
	[results setValue:[NSNumber numberWithBool:YES] forKey:@"savedInDatabase"];
	
	return results;
}

+ (NSArray *) findWithSqlWithParameters: (NSString *) sql, ...
{
	va_list argumentList;
	va_start(argumentList, sql);
	NSMutableArray *arguments = [NSMutableArray array];
	id argument;
	
	while(argument = va_arg(argumentList, id))
	{
		[arguments addObject:argument];
	}
	
	va_end(argumentList);
	
	return [self findWithSql:sql withParameters: arguments];
}

+ (NSArray *) findWithSql: (NSString *) sql
{
	return [self findWithSqlWithParameters:sql, nil];
}

+ (NSArray *) findByColumn: (NSString *) column value: (id) value
{
	
	
	return [self findWithSqlWithParameters:[NSString stringWithFormat:@"select * from %@ where %@ = ?", [self tableName], column], value, nil];
}

+ (NSArray *) findByColumn: (NSString *) column unsignedIntegerValue: (NSUInteger) value
{
	return [self findByColumn:column value: [NSNumber numberWithUnsignedInteger:value]];
}

+ (NSArray *) findByColumn: (NSString *) column integerValue: (NSInteger) value
{
	return [self findByColumn:column value: [NSNumber numberWithInteger:value]];
}

+ (NSArray *) findByColumn: (NSString *) column doubleValue: (double) value
{
	return [self findByColumn:column value: [NSNumber numberWithDouble:value]];
}

+ (id) find: (NSUInteger) primaryKey 
{
	NSArray *results = [self findByColumn: @"INDEXNO" unsignedIntegerValue: primaryKey];
	
	if([results count] < 1)
	{
		return nil;
	}
	return [results objectAtIndex:0];
}

+ (NSArray *) findAll
{
	//mezzo sql Query
//	NSLog(@"===========QUERY select * from %@ =================",[self tableName]);
	
	//20101018 정렬순서 변경..
	if([[self tableName] isEqualToString:@"_TUserInfo"])
	{
		return [self findWithSql: [NSString stringWithFormat:@"select * from %@ order by formatted, profilenickname, nickname", [self tableName]]];
		
	}
	else {
		return [self findWithSql: [NSString stringWithFormat:@"select * from %@", [self tableName]]];
		
	}

	
}

@end
