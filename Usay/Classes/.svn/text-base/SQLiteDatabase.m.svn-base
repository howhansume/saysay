//
//  SQLiteDatabase.m
//  USayApp
//
//  Created by Jong-Sung Park on 10. 6. 28..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "SQLiteDatabase.h"
#import "DataAccessObject.h"

#define kFilename @"usay.sqlite"
#define kDatabaseVersion 2

@implementation SQLiteDatabase

#pragma mark -
#pragma mark Application Properties

- (void) updateApplicationProperty: (NSString *) propertyName value: (id) value
{
	[self executeSqlWithParameters: @"update ApplicationProperties set value = ? where name = ?", value, propertyName, nil];
}

- (id) getApplicationProperty: (NSString *) propertyName
{
	NSArray *rows = [self executeSqlWithParameters: @"select value from ApplicationProperties where name = ?", propertyName, nil];
	
	if([rows count] == 0)
	{
		return nil;
	}
	
	id object = [[rows lastObject] objectForKey:@"value"];
	if([object isKindOfClass: [NSString class]])
	{
		object = [NSNumber numberWithInteger:[(NSString *)object integerValue]];
	}
	return object;
}

- (NSUInteger) databaseVersion
{
	return [[self getApplicationProperty:@"databaseVersion"] unsignedIntegerValue];
}

- (void) setDatabaseVersion: (NSUInteger) newVersionNumber
{
	return [self updateApplicationProperty:@"databaseVersion" value:[NSNumber numberWithUnsignedInteger: newVersionNumber]];
}

#pragma mark -
#pragma mark database instance Method

- (void) createApplicationPropertiesTable
{
	[self executeSql:@"create table ApplicationProperties (primaryKey integer primary key autoincrement, name text, value integer)"];
	[self executeSql:@"insert into ApplicationProperties (name, value) values('databaseVersion', 1)"];
}

-(void)runMigrations {
	[self beginTransaction];

	NSArray *tableNames = [self tableNames];
	if(![tableNames containsObject:@"ApplicationProperties"]) {
		[self replaceDBFile:kFilename];
		[self createApplicationPropertiesTable];
		[self setDatabaseVersion:kDatabaseVersion];
	}
	
	if([self databaseVersion] < kDatabaseVersion) {
		[self replaceDBFile:kFilename];
		[self createApplicationPropertiesTable];
		[self setDatabaseVersion:kDatabaseVersion];
	}
	
	[self commit];
}

-(void)initMigrations {
	[self beginTransaction];
	NSArray *tableNames = [self tableNames];
	
	if(![tableNames containsObject:@"ApplicationProperties"]) {
		[self createApplicationPropertiesTable];
		[self setDatabaseVersion:kDatabaseVersion];
	}
	
	[self commit];
}
//app 실행시. document 경로에 파일이 있으면 DB를 열고 DB인스턴스 설정, 파일이 없으면 nil을 반환
-(id)initWithOpenSQLite {
	self = [super initWithFileName:kFilename];
	if(self != nil){
		[self runMigrations];
		[DataAccessObject setDatabase:self];
	}
	return self;
}

//인증을 받고 나서, DB파일을 document 경로로 복사 하여 넣고, DB를 열어 인스턴스 설정
-(id)initWithCreateSQLite {
	self = [super initWithCopyFileName:kFilename];
	if(self != nil){
		[self initMigrations];
		[DataAccessObject setDatabase:self];
	}
	return self;
}

@end
