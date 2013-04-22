//
//  AddressBookData.m
//  USayApp
//
//  Created by Jong-Sung Park on 10. 5. 28..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "AddressBookData.h"
#import "UserInfo.h"
#import "GroupInfo.h"
#import "USayAppAppDelegate.h"
#import "USayDefine.h"

//key-value의 키 정의
#define RECORDID_STRING		@"RecordId"
#define FIRST_NAME_STRING	@"First Name"
#define MIDDLE_NAME_STRING	@"Middle Name"
#define LAST_NAME_STRING	@"Last Name"

#define PREFIX_STRING	@"Prefix"
#define SUFFIX_STRING	@"Suffix"
#define NICKNAME_STRING	@"Nickname"

#define PHONETIC_FIRST_STRING	@"Phonetic First Name"
#define PHONETIC_MIDDLE_STRING	@"Phonetic Middle Name"
#define PHONETIC_LAST_STRING	@"Phonetic Last Name"

#define ORGANIZATION_STRING	@"Organization"
#define JOBTITLE_STRING		@"Job Title"
#define DEPARTMENT_STRING	@"Department"

#define NOTE_STRING	@"Note"

#define BIRTHDAY_STRING				@"Birthday"
#define CREATION_DATE_STRING		@"Creation Date"
#define MODIFICATION_DATE_STRING	@"Modification Date"

#define KIND_STRING	@"Kind"

#define EMAIL_STRING	@"Email"
#define ADDRESS_STRING	@"Address"
#define DATE_STRING		@"Date"
#define PHONE_STRING	@"Phone"
#define SMS_STRING		@"Instant Message"
#define URL_STRING		@"URL"
#define RELATED_STRING	@"Related Name"

#define IMAGE_STRING	@"Image"

@implementation AddressBookData

//@synthesize allAddrs, values, keys;
////singlevalue
//@synthesize firstname, lastname, middlename, prefix, suffix, nickname, firstnamephonetic, lastnamephonetic;
//@synthesize middlenamephonetic, organization, jobtitle, department, note;
////date
//@synthesize birthday,creationDate, modificationDate;
////mutivalue
//@synthesize emailArray, phoneArray, relatedNameArray, urlArray;
//@synthesize dateArray, addressArray, smsArray;
//@synthesize emailaddresses, phonenumbers, urls,image;

NSMutableDictionary *tmpGroupDic;
-(USayAppAppDelegate *) appDelegate
{
	return (USayAppAppDelegate *)[[UIApplication sharedApplication] delegate];
}

-(NSArray *)arrayForMultiValue :(ABRecordRef)theRecord propertyIDOfArray:(ABPropertyID) propertyId {
	ABMultiValueRef theProperty = ABRecordCopyValue(theRecord, propertyId);
	//	NSArray *items = (NSArray *)ABMultiValueCopyArrayOfAllValues(theProperty);
	NSMutableArray *itemArray = [NSMutableArray array];
	if(ABMultiValueGetCount(theProperty) != 0){
		for(CFIndex i = 0;i<ABMultiValueGetCount(theProperty);i++){
			NSString *propertyValue = (NSString *)ABMultiValueCopyValueAtIndex(theProperty, i);
			NSString *propertyLabel = (NSString *)ABMultiValueCopyLabelAtIndex(theProperty, i);
			NSMutableDictionary *itemDic = [NSMutableDictionary dictionary];
			if(propertyValue != nil)
			[itemDic setObject:propertyValue forKey:@"value"];
			if(propertyLabel != nil)
			[itemDic setObject:propertyLabel forKey:@"label"];
			[itemArray addObject:itemDic];
			[propertyValue release];
			[propertyLabel release];
		}
		CFRelease(theProperty);
	}else {
		
		CFRelease(theProperty);
	}

	
	return (NSArray *)itemArray;
}

-(NSString*)parseNumber:(NSString*)phonenum
{
	NSString *number = nil;
	number = [phonenum stringByReplacingOccurrencesOfString:@"-" withString:@""];
	number = [number stringByReplacingOccurrencesOfString:@" " withString:@""];
	number = [number stringByReplacingOccurrencesOfString:@"(" withString:@""];
	number = [number stringByReplacingOccurrencesOfString:@")" withString:@""];
	number = [number stringByReplacingOccurrencesOfString:@"+82" withString:@""];
	return number;
}

#pragma mark ( iPhone -> USay ) : 변경  이력 데이터만 입력



#pragma mark ( iPhone -> USay ) : 이름,레코드아이디,휴대폰번호 로딩
-(BOOL)readFullnowData
{

	[self appDelegate].LoadingData = YES;
	
	//임시 메모리를 지워준다
	[[self appDelegate].tmpGroupArray removeAllObjects];
	
	NSTimeInterval starttime1 = [[NSDate date] timeIntervalSince1970];
	//테스트용 유세이 업데이트
	SQLiteDataAccess* trans = [DataAccessObject database];
	//이전 테이블 삭제한다
	NSString *deleteQ = @"delete from _TChangePhone";
	NSString *deleteP = @"delete from _TRecord";
	[trans beginTransaction];
	[trans executeSql:deleteQ];
	[trans executeSql:deleteP];
	[trans commit];
	//이전 테이블 삭제 완료
	
	
	
	//중간에 쓰레드가 종료되면 바로 리턴
/*
	if([[self appDelegate].Thread isCancelled] == YES)
	{
		return NO;
	}
*/
	if([self appDelegate].LoadingData == NO)
	{
		NSLog(@"여기냐?");
		return NO;
	}
	
	
	
	
	
	
	ABAddressBookRef addressBook = ABAddressBookCreate();
	CFArrayRef peopleRef = ABAddressBookCopyArrayOfAllPeople(addressBook); //모든 사용자 데이터 
	CFArrayRef groupsRef = ABAddressBookCopyArrayOfAllGroups(addressBook); //올그룹 데이터 
	CFIndex personCount = ABAddressBookGetPersonCount(addressBook); //유저 인원
	CFIndex groupCount = ABAddressBookGetGroupCount(addressBook); //총 그룹 갯수 
	
	
	
	
	NSString *findquery = @"select RID from _TUsayUserInfo where TYPE !='N' and RID IS NOT NULL";
	NSArray *UsayDataA = [trans executeSql:findquery];
	NSMutableDictionary *UsayData = [NSMutableDictionary dictionary];
	

	//변경된 테이터를 찾기 위한 날짜 셋팅
	NSString *lastSyncDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastSyncDate"];
	NSLog(@"lastSyncDate = %@", lastSyncDate);
	
	
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	[formatter setDateFormat:@"yyyyMMddHHmmss"];
	NSLocale *locale = [NSLocale currentLocale];
	[formatter setLocale:locale];
	NSDate *basisDate = [formatter dateFromString:lastSyncDate];
	
	
	
	
	//예전 유세이 친구 목록을 해쉬 테이블로 가져온다.
	for (int i=0; i<[UsayDataA count]; i++) {
		NSString *recid = [NSString stringWithFormat:@"%@",[[UsayDataA objectAtIndex:i] objectForKey:@"RID"]];
		[UsayData setObject:@"Y" forKey:recid];
	}
	//그룹에 포함 된 사용자를 찾기 위한 레코드 딕셔너리
	NSMutableDictionary *inGrouplist = [NSMutableDictionary dictionary];
	
	
	
	//그룹이 전혀 없는 사용자를 위한 유세이 카운트 유저 배열
	int nousaycnt = 0;
	NSMutableArray *noPeopleArray = [NSMutableArray array];
	NSMutableArray *recordArray =[NSMutableArray array];
	[trans beginTransaction];
	for(CFIndex i = 0; i<personCount; i++)
	{
		//if([[self appDelegate].Thread isCancelled] == YES)
		if([self appDelegate].LoadingData == NO)
		{
			//메모리 해제 하고 리턴
			CFRelease(peopleRef);
			CFRelease(groupsRef);
			CFRelease(addressBook);
			return NO;
		}
		
		//레코드에서 읽어오는 정보들
		ABRecordRef aRecord = CFArrayGetValueAtIndex(peopleRef, i);
		NSString *recordid = [NSString stringWithFormat:@"%i", (NSUInteger)ABRecordGetRecordID(aRecord)];
		NSArray* lPhoneArray = [self arrayForMultiValue:aRecord propertyIDOfArray:kABPersonPhoneProperty];
		NSDate* cdate = [(NSDate *)ABRecordCopyValue(aRecord,kABPersonModificationDateProperty) autorelease];
		
		NSDate* currentDate = [NSDate date];
		NSNumber *intervalNumber = [NSNumber numberWithLongLong:[currentDate timeIntervalSinceDate:cdate]];
		NSString* firstname = [(NSString *)ABRecordCopyValue(aRecord,kABPersonFirstNameProperty) autorelease];
		NSString* lastname = [(NSString *)ABRecordCopyValue(aRecord,kABPersonLastNameProperty) autorelease];
		NSString *name = [NSString stringWithFormat:@"%@ %@",lastname?lastname:@"",firstname?firstname:@""];
		
		NSData *imageData = (NSData*)ABPersonCopyImageData(aRecord);
		
		
		
		
		//신규 유저들.
		NSMutableDictionary *personDic = [NSMutableDictionary dictionary];
	
		if (imageData != nil && imageData != NULL) {
			[personDic setObject:imageData forKey:@"IMAGE"];
		}
		
		if([intervalNumber intValue] > 86400)
		{
			[personDic setObject:@"N" forKey:@"NEWUSER"];
		}
		else {
			[personDic setObject:@"Y" forKey:@"NEWUSER"];
		}
		if ([name isEqualToString:@" "]) {
			name=@"이름없음";
		}
		
		if([name length] > 0)
			[personDic setObject:name forKey:@"NAME"];
		else {
			[personDic setObject:@"이름없음" forKey:@"NAME"];
		}
		
		
		
		if(firstname == nil || firstname == NULL)
			firstname =@"";
		if (lastname == nil || lastname == NULL) {
			lastname =@"";
		}
		
		
		[personDic setObject:firstname forKey:@"FN"];
		[personDic setObject:lastname	forKey:@"LN"];
		[personDic setObject:@"N"	forKey:@"TYPE"];
		
		//유세이 셋팅
	//	[personDic setObject:recordid forKey:@"RECID"];
		//레코드 아이디가 발견이 된다면
		
		if([UsayData objectForKey:recordid])
		{
			//		NSLog(@"발견 됨 %@", recordid);
		//	[personDic setObject:@"Y" forKey:@"TYPE"];
			nousaycnt++;
			
		}
		else {
			//		NSLog(@"발견 안ㄷ됨 %@", recordid);
		//	[personDic setObject:@"N" forKey:@"TYPE"];
		}
		
		
		
		
		
		NSString *fieldchk = nil;
		if(lPhoneArray != nil) {
			for(NSDictionary* item in lPhoneArray) {
				//순서가 모바일/아이폰/메인폰 순으로 내려옴
				NSString *number = nil;
				number = [self parseNumber:[item valueForKey:@"value"]];
				if ([number length] > 0) {
					//맨 처음것만 집어넣고 나머진 넣을필요가 없다 
					if(![personDic objectForKey:@"NUMBER"])
					{
						if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneMobileLabel]){  //mobilephone
							[personDic setObject:number forKey:@"NUMBER"];
							continue;
						}
						else if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneIPhoneLabel]){  //iphone
							[personDic setObject:number forKey:@"NUMBER"];
							fieldchk = @"kABPersonPhoneIPhoneLabel";
						}
						else if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneMainLabel]){
							//아이폰으로 한번이라도 입력을 했다면 컨티뉴
							[personDic setObject:number forKey:@"NUMBER"];
							fieldchk = @"kABPersonPhoneMainLabel";
						}
						else {
							[personDic setObject:number forKey:@"NUMBER"];
						}
					}
					else {
						if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneMobileLabel]){  //mobilephone
							[personDic setObject:number forKey:@"NUMBER"];
							continue;
						}
						else if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneIPhoneLabel]){  //iphone
							//필드를 검사해서 아이폰을 이미 넣었다면 패스
							if (![fieldchk isEqualToString:@"kABPersonPhoneIPhoneLabel"]) {
								[personDic setObject:number forKey:@"NUMBER"];
								fieldchk = @"kABPersonPhoneIPhoneLabel";
							}
							
						}
						else if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneMainLabel]){
							
							//아이폰으로 한번이라도 입력을 했다면 컨티뉴
							if (![fieldchk isEqualToString:@"kABPersonPhoneIPhoneLabel"]) {
								[personDic setObject:number forKey:@"NUMBER"];
								fieldchk = @"kABPersonPhoneMainLabel";
							}
							
						}//mainphone
					}
					
					
				}
				else {
					NSLog(@"번호입력이 비어있다.");
				}
				
				
				
				
			}
			
		
		
		
		}
		
	//	[noPeopleArray addObject:personDic];
	
		
		[[self appDelegate].userAllDataDic setObject:personDic forKey:recordid];
		NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
		[tmpDic setObject:recordid forKey:@"RECID"];
		[tmpDic setObject:name forKey:@"NAME"];
		[noPeopleArray addObject:tmpDic];
		
		
		
		//변경된 데이터들만 _TChangePhone 으로 인서트
		if([basisDate compare:cdate] ==  NSOrderedAscending)
		{
			NSLog(@"업데이트 된거 저장%@ 단말%@ 이름 %@", basisDate, cdate, name);
			if([lPhoneArray count] > 0) {
				for(NSDictionary* item in lPhoneArray) {
					NSString *number = nil;
					number = [self parseNumber:[item valueForKey:@"value"]];
					NSString *insertQ = [NSString stringWithFormat:@"insert into _TChangePhone (RECID, PHONE)values(%@,'%@')",recordid,number];
					[trans executeSql:insertQ];
					//번호가 있는 필드들만 딕셔너리에 넣는다 _TContact에 넣기 위한 설정
				}
			}
			else {
				NSLog(@"번호가 없다");
				NSString *insertQ = [NSString stringWithFormat:@"insert into _TChangePhone (RECID, PHONE)values(%@,'')",recordid];
				[trans executeSql:insertQ];
			}

		}
		
		
		
//현재 모든 레코드 번호를 입력한다.
		NSString *insertRecord = [NSString stringWithFormat:@"insert into _TRecord (RECID)values(%@)", recordid];
		[trans executeSql:insertRecord];
		
		
		
				
		
		
	}
	[trans commit];
	if (groupCount == 0) {
		
		
		
		NSMutableDictionary *tmpGroup =[NSMutableDictionary dictionary];
		
		[tmpGroup setObject:@"미지정 그룹" forKey:@"TITLE"];
		[tmpGroup setObject:@"-1" forKey:@"GID"];
		
		
		//임시 그룹에다가 사용자들을 넣는다., 유세이 사용자 숫자도 파악
		[tmpGroup setObject:noPeopleArray forKey:@"UserInfo"];
		[[self appDelegate].tmpGroupArray addObject:tmpGroup];
		NSTimeInterval starttime2 = [[NSDate date] timeIntervalSince1970];
		NSLog(@"################### 주소록 로딩 완료222 %f #####################",starttime2 - starttime1);
		
		return YES;
	}
	
	
	//그룹이 존재 하는 경우 
	for(CFIndex g = 0;g<groupCount;g++){
		//그룹 배열 만큼 돌면서
		
		if([self appDelegate].LoadingData == NO)
		//if([[self appDelegate].Thread isCancelled] == YES)
		{
			//메모리 해제 하고 리턴
			CFRelease(peopleRef);
			CFRelease(groupsRef);
			CFRelease(addressBook);
			return NO;
		}
		
		
		//그룹 정보를 얻고 
		ABRecordRef gRecord = CFArrayGetValueAtIndex(groupsRef, g);
		NSString *gid = [NSString stringWithFormat:@"%i", ABRecordGetRecordID(gRecord)];
		
		//해당 그룹 멤버를 받아서 		
		NSArray* groupContacts = (NSArray*)ABGroupCopyArrayOfAllMembers(gRecord);
		//그룹 정보를 셋팅하고
		NSMutableArray *PeopleArray = [NSMutableArray array];
		NSMutableDictionary *tmpGroup = [NSMutableDictionary dictionary];
		NSString *gtitle =  [(NSString*)ABRecordCopyValue(gRecord, kABGroupNameProperty) autorelease];
		
		[tmpGroup setObject:gid forKey:@"GID"];
		[tmpGroup setObject:gtitle forKey:@"TITLE"];
		//그룹별 메모리도 있어야 겠다..
		int usaycnt = 0;
		if([groupContacts count] > 0){ //그룹멤버 갯수가 1개라도 존재하면..
			for(id person in groupContacts){
				
				
				if([self appDelegate].LoadingData == NO)
				//if([[self appDelegate].Thread isCancelled] == YES)
				{
					//메모리 해제 하고 리턴
					CFRelease(peopleRef);
					CFRelease(groupsRef);
					CFRelease(addressBook);
					return NO;
				}
				
				
				//그룹에 레코드 번호랑 사용자의 레코드 번호랑 일치하면 같은 사용자..
				NSMutableDictionary *personDic = [NSMutableDictionary dictionary];
				NSString *recordid = [NSString stringWithFormat:@"%i", (NSUInteger)ABRecordGetRecordID(person)];
				NSString* firstname = [(NSString *)ABRecordCopyValue(person,kABPersonFirstNameProperty) autorelease];
				NSString* lastname = [(NSString *)ABRecordCopyValue(person,kABPersonLastNameProperty) autorelease];
				//사용자 이름
				NSString *name = [NSString stringWithFormat:@"%@ %@",lastname?lastname:@"",firstname?firstname:@""];
				//이름,
				
				NSData *imageData = (NSData*)ABPersonCopyImageData(person);
				
				
				if (imageData != nil && imageData != NULL) {
					[personDic setObject:imageData forKey:@"IMAGE"];
				}
				
				if ([name isEqualToString:@" "]) {
					name=@"이름없음";
				}
				
				if([name length] > 0)
					[personDic setObject:name forKey:@"NAME"];
				else {
					[personDic setObject:@"이름없음" forKey:@"NAME"];
				}
				
				//[personDic setObject:recordid forKey:@"RECID"];
				//레코드 아이디가 발견이 된다면
				
				if([UsayData objectForKey:recordid])
				{
				//	[personDic setObject:@"Y" forKey:@"TYPE"];
					usaycnt++;
				}
				else {
				//	[personDic setObject:@"N" forKey:@"TYPE"];
				}
				
				
				if(firstname == nil || firstname == NULL)
					firstname =@"";
				if (lastname == nil || lastname == NULL) {
					lastname =@"";
				}
				
				
				[personDic setObject:firstname forKey:@"FN"];
				[personDic setObject:lastname	forKey:@"LN"];
				[personDic setObject:@"N"	forKey:@"TYPE"];
				
				
				NSDate* cdate = [(NSDate *)ABRecordCopyValue(person,kABPersonCreationDateProperty) autorelease];
				NSDate* currentDate = [NSDate date];
				NSNumber *intervalNumber = [NSNumber numberWithLongLong:[currentDate timeIntervalSinceDate:cdate]];
				
				
				//	NSLog(@"inteval %@", intervalNumber);
				
				
				if([intervalNumber intValue] > 86400)
				{
					[personDic setObject:@"N" forKey:@"NEWUSER"];
				}
				else {
					[personDic setObject:@"Y" forKey:@"NEWUSER"];
				}
				
				
				
				
				//해당 레코드 아이디가 없을때만 추가 
				if(![inGrouplist objectForKey:recordid])
					[inGrouplist setObject:@"" forKey:recordid];
				
				
				
				
				
				NSArray* lPhoneArray = [self arrayForMultiValue:person propertyIDOfArray:kABPersonPhoneProperty];
				NSString* fieldchk = nil;
				if(lPhoneArray != nil) {
					
					for(NSDictionary* item in lPhoneArray) {
						//순서가 모바일/아이폰/메인폰 순으로 내려옴
						NSString *number = nil;
						number = [self parseNumber:[item valueForKey:@"value"]];
						
						
						
						
						
						
						if ([number length] > 0) {
							
							//맨 처음것만 집어넣고 나머진 넣을필요가 없다 
							if(![personDic objectForKey:@"NUMBER"])
							{
								if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneMobileLabel]){  //mobilephone
									[personDic setObject:number forKey:@"NUMBER"];
									continue;
								}
								else if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneIPhoneLabel]){  //iphone
									[personDic setObject:number forKey:@"NUMBER"];
									fieldchk = @"kABPersonPhoneIPhoneLabel";
								}
								else if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneMainLabel]){
									//아이폰으로 한번이라도 입력을 했다면 컨티뉴
									[personDic setObject:number forKey:@"NUMBER"];
									fieldchk = @"kABPersonPhoneMainLabel";
								}
								else {
									[personDic setObject:number forKey:@"NUMBER"];
								}
							}
							else {
								if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneMobileLabel]){  //mobilephone
									[personDic setObject:number forKey:@"NUMBER"];
									continue;
								}
								else if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneIPhoneLabel]){  //iphone
									//필드를 검사해서 아이폰을 이미 넣었다면 패스
									if (![fieldchk isEqualToString:@"kABPersonPhoneIPhoneLabel"]) {
										[personDic setObject:number forKey:@"NUMBER"];
										fieldchk = @"kABPersonPhoneIPhoneLabel";
									}
									
								}
								else if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneMainLabel]){
									
									//아이폰으로 한번이라도 입력을 했다면 컨티뉴
									if (![fieldchk isEqualToString:@"kABPersonPhoneIPhoneLabel"]) {
										[personDic setObject:number forKey:@"NUMBER"];
										fieldchk = @"kABPersonPhoneMainLabel";
									}
									
								}//mainphone
							}
							
							
						}
						else {
							NSLog(@"번호입력이 비어있다.");
						}
						
						
					}
					
					
				}
				[[self appDelegate].userAllDataDic setObject:personDic forKey:recordid];
				NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
				[tmpDic setObject:recordid forKey:@"RECID"];
				[tmpDic setObject:name forKey:@"NAME"];
				[PeopleArray addObject:tmpDic];
				
				//[PeopleArray addObject:personDic];
			}
		}
		//그룹이 하나씩 끝날때 마다 그룹을 전체 그룹 배열에 넣어준다.
		[tmpGroup setObject:PeopleArray forKey:@"UserInfo"];
		[[self appDelegate].tmpGroupArray addObject:tmpGroup];
		//[[self appDelegate].GroupArray addObject:PeopleArray];
		[groupContacts release];
		//	DebugLog(@"GroupArray Log %@ Cnt %d RecCnt %d",GroupArray, [GroupArray count], [[GroupArray objectAtIndex:0] count]);
		
	}
	
	
	
	
	//그룹에 속하지 않는 사용자들도 추가하기
	NSMutableDictionary *tmpGroup =[NSMutableDictionary dictionary];
	[tmpGroup setObject:@"미지정 그룹" forKey:@"TITLE"];
	[tmpGroup setObject:@"-1" forKey:@"GID"];
	NSMutableArray *PeopleArray = [NSMutableArray array];
	
	
	
	int usaycnt = 0;
	for(CFIndex i = 0; i<personCount; i++)
	{
		if([self appDelegate].LoadingData == NO)
		//if([[self appDelegate].Thread isCancelled] == YES)
		{
			//메모리 해제 하고 리턴
			CFRelease(peopleRef);
			CFRelease(groupsRef);
			CFRelease(addressBook);
			return NO;
		}
		
		
		ABRecordRef person = CFArrayGetValueAtIndex(peopleRef, i);
		//그룹에 레코드 번호랑 사용자의 레코드 번호랑 일치하면 같은 사용자..
		NSMutableDictionary *personDic = [NSMutableDictionary dictionary];
		NSString *recordid = [NSString stringWithFormat:@"%i", (NSUInteger)ABRecordGetRecordID(person)];
		
		
		//해당 레코드가 존재하면 
		if([inGrouplist objectForKey:recordid])
			continue;
		
		
		
		
		NSString* firstname = [(NSString *)ABRecordCopyValue(person,kABPersonFirstNameProperty) autorelease];
		NSString* lastname = [(NSString *)ABRecordCopyValue(person,kABPersonLastNameProperty) autorelease];
		//사용자 이름
		NSString *name = [NSString stringWithFormat:@"%@ %@",lastname?lastname:@"",firstname?firstname:@""];
		//이름,
		
		
		
		NSData *imageData = (NSData*)ABPersonCopyImageData(person);
		
		
		if (imageData != nil && imageData != NULL) {
			[personDic setObject:imageData forKey:@"IMAGE"];
		}
		if ([name isEqualToString:@" "]) {
			name=@"이름없음";
		}
		
		
		if([name length] > 0)
			[personDic setObject:name forKey:@"NAME"];
		else {
			[personDic setObject:@"이름없음" forKey:@"NAME"];
		}
		
	//	[personDic setObject:recordid forKey:@"RECID"];
		
		
		if([UsayData objectForKey:recordid])
		{
		//	[personDic setObject:@"Y" forKey:@"TYPE"];
			usaycnt++;
		}
		else {
		//	[personDic setObject:@"N" forKey:@"TYPE"];
		}
		
		
		
		if(firstname == nil || firstname == NULL)
			firstname =@"";
		if (lastname == nil || lastname == NULL) {
			lastname =@"";
		}
		
		
		[personDic setObject:firstname forKey:@"FN"];
		[personDic setObject:lastname	forKey:@"LN"];
		[personDic setObject:@"N"	forKey:@"TYPE"];
		
		
		
		NSDate* cdate = [(NSDate *)ABRecordCopyValue(person,kABPersonCreationDateProperty) autorelease];
		NSDate* currentDate = [NSDate date];
		NSNumber *intervalNumber = [NSNumber numberWithLongLong:[currentDate timeIntervalSinceDate:cdate]];
		
		
		//	NSLog(@"inteval %@", intervalNumber);
		
		
		if([intervalNumber intValue] > 86400)
		{
			[personDic setObject:@"N" forKey:@"NEWUSER"];
		}
		else {
			[personDic setObject:@"Y" forKey:@"NEWUSER"];
		}
		
		
		
		
		
		NSArray* lPhoneArray = [self arrayForMultiValue:person propertyIDOfArray:kABPersonPhoneProperty];
		NSString* fieldchk = nil;
		if(lPhoneArray != nil) {
			
			for(NSDictionary* item in lPhoneArray) {
				
				//순서가 모바일/아이폰/메인폰 순으로 내려옴
				NSString *number = nil;
				number = [self parseNumber:[item valueForKey:@"value"]];
				
				
				
				if ([number length] > 0) {
					//맨 처음것만 집어넣고 나머진 넣을필요가 없다 
					//맨 처음것만 집어넣고 나머진 넣을필요가 없다 
					if(![personDic objectForKey:@"NUMBER"])
					{
						if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneMobileLabel]){  //mobilephone
							[personDic setObject:number forKey:@"NUMBER"];
							continue;
						}
						else if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneIPhoneLabel]){  //iphone
							[personDic setObject:number forKey:@"NUMBER"];
							fieldchk = @"kABPersonPhoneIPhoneLabel";
						}
						else if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneMainLabel]){
							//아이폰으로 한번이라도 입력을 했다면 컨티뉴
							[personDic setObject:number forKey:@"NUMBER"];
							fieldchk = @"kABPersonPhoneMainLabel";
						}
						else {
							[personDic setObject:number forKey:@"NUMBER"];
						}
					}
					else {
						if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneMobileLabel]){  //mobilephone
							[personDic setObject:number forKey:@"NUMBER"];
							continue;
						}
						else if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneIPhoneLabel]){  //iphone
							//필드를 검사해서 아이폰을 이미 넣었다면 패스
							if (![fieldchk isEqualToString:@"kABPersonPhoneIPhoneLabel"]) {
								[personDic setObject:number forKey:@"NUMBER"];
								fieldchk = @"kABPersonPhoneIPhoneLabel";
							}
							
						}
						else if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneMainLabel]){
							
							//아이폰으로 한번이라도 입력을 했다면 컨티뉴
							if (![fieldchk isEqualToString:@"kABPersonPhoneIPhoneLabel"]) {
								[personDic setObject:number forKey:@"NUMBER"];
								fieldchk = @"kABPersonPhoneMainLabel";
							}
							
						}//mainphone
					}
					
					
				}
				else {
					NSLog(@"번호입력이 비어있다.");
				}
				
				
				
				
				
			}
			
			
		}
	//	[PeopleArray addObject:personDic];
	
		[[self appDelegate].userAllDataDic setObject:personDic forKey:recordid];
		NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
		[tmpDic setObject:recordid forKey:@"RECID"];
		[tmpDic setObject:name forKey:@"NAME"];
		[PeopleArray addObject:tmpDic];
		
		
		
	}
	
	//사람이 한명이라도 존재할때만
	if([PeopleArray count] > 0)
	{
		
		
		[tmpGroup setObject:PeopleArray forKey:@"UserInfo"];
		
		[[self appDelegate].tmpGroupArray addObject:tmpGroup];
	}
	
	
	NSTimeInterval starttime2 = [[NSDate date] timeIntervalSince1970];
	NSLog(@"################## 주소록 로딩 완료 %f ###################",starttime2 - starttime1);
	
	
	CFRelease(peopleRef);
	CFRelease(groupsRef);
	// ~sochae
	
	//2011.01.11 릭 갯수 줄이기 위해 위에꺼 주석 풀고 아래꺼 주석 한다.
	// 110124 analyze
	CFRelease(addressBook);	
	return YES;
}

#pragma mark ( iPhone -> USay ) : 이름,레코드아이디,휴대폰번호 로딩
-(void*)readFullOEMData
{
	
	
	NSTimeInterval starttime1 = [[NSDate date] timeIntervalSince1970];
	
	
	//테스트용 유세이 업데이트
	SQLiteDataAccess* trans = [DataAccessObject database];
	
	//	[trans executeSql:@"update _TPreContact set TYPE='S'"];
	
	
	
	
	ABAddressBookRef addressBook = ABAddressBookCreate();
	CFArrayRef peopleRef = ABAddressBookCopyArrayOfAllPeople(addressBook); //모든 사용자 데이터 
	CFArrayRef groupsRef = ABAddressBookCopyArrayOfAllGroups(addressBook); //올그룹 데이터 
	CFIndex personCount = ABAddressBookGetPersonCount(addressBook); //유저 인원
	CFIndex groupCount = ABAddressBookGetGroupCount(addressBook); //총 그룹 갯수 
	
	
	//그룹에 포함 된 사용자를 찾기 위한 레코드 딕셔너리
	NSMutableDictionary *inGrouplist = [NSMutableDictionary dictionary];
	
	/*
	//번호가 있는 레코드들만 메모리에 설정
	[trans beginTransaction];
	for(CFIndex i = 0; i<personCount; i++)
	{
		
		
		ABRecordRef aRecord = CFArrayGetValueAtIndex(peopleRef, i);
		NSString *recordid = [NSString stringWithFormat:@"%i", (NSUInteger)ABRecordGetRecordID(aRecord)];
		NSArray* lPhoneArray = [self arrayForMultiValue:aRecord propertyIDOfArray:kABPersonPhoneProperty];
		
		if(lPhoneArray != nil) {
			for(NSDictionary* item in lPhoneArray) {
				NSString *number = nil;
				number = [self parseNumber:[item valueForKey:@"value"]];
				if([number length] > 0)
				{
					//REPLACE 문으로 있으면 업데이트 없으면 인서트 한다 
					NSString *update = [NSString stringWithFormat:@"INSERT OR REPLACE INTO _TPreContact (RECID,PHONE,TYPE)values(%@,'%@','N')",recordid,number];
					[trans executeSql:update];
				}		  
				
				
			}
		}
	}
	[trans commit];
	*/
	 
	//그룹이 전혀 없는 경우 전부 다 미지정 그룹으로 간다
	if(groupCount == 0)
	{
		NSMutableArray *PeopleArray = [NSMutableArray array];
		NSMutableDictionary *tmpGroup =[NSMutableDictionary dictionary];
		
		[tmpGroup setObject:@"미지정 그룹" forKey:@"TITLE"];
		[tmpGroup setObject:@"-1" forKey:@"GID"];
		//	[PeopleArray addObject:tmpGroup];
		int usaycnt = 0;
		[trans beginTransaction];
		
		
		
		for(CFIndex i = 0; i<personCount; i++)
		{
			ABRecordRef aRecord = CFArrayGetValueAtIndex(peopleRef, i);
			
			//유저의 모든 정보를 가지고 있는딕셔너리 
			NSMutableDictionary *personDic = [NSMutableDictionary dictionary];
			
					
			
			NSDate* cdate = [(NSDate *)ABRecordCopyValue(aRecord,kABPersonCreationDateProperty) autorelease];
			NSDate* currentDate = [NSDate date];
			NSNumber *intervalNumber = [NSNumber numberWithLongLong:[currentDate timeIntervalSinceDate:cdate]];
			//	NSLog(@"inteval %@", intervalNumber);
			NSData *imageData = (NSData*)ABPersonCopyImageData(aRecord);
			if (imageData != nil && imageData != NULL) {
				[personDic setObject:imageData forKey:@"IMAGE"];
			}
			
			if([intervalNumber intValue] > 86400)
			{
				[personDic setObject:@"N" forKey:@"NEWUSER"];
			}
			else {
				[personDic setObject:@"Y" forKey:@"NEWUSER"];
			}
			NSString* firstname = [(NSString *)ABRecordCopyValue(aRecord,kABPersonFirstNameProperty) autorelease];
			NSString* lastname = [(NSString *)ABRecordCopyValue(aRecord,kABPersonLastNameProperty) autorelease];
			
			//이름의 공란 제거
			
			
			//사용자 이름
			NSString *name = [NSString stringWithFormat:@"%@ %@",lastname?lastname:@"",firstname?firstname:@""];
			NSString *recordid = [NSString stringWithFormat:@"%i", (NSUInteger)ABRecordGetRecordID(aRecord)];
			
			
			if ([name isEqualToString:@" "]) {
				name=@"이름없음";
			}
			
			if([name length] > 0)
				[personDic setObject:name forKey:@"NAME"];
			else {
				[personDic setObject:@"이름없음" forKey:@"NAME"];
			}
			
			if(firstname == nil || firstname == NULL)
				firstname =@"";
			if (lastname == nil || lastname == NULL) {
				lastname =@"";
			}
			
			[personDic setObject:firstname forKey:@"FN"];
			[personDic setObject:lastname	forKey:@"LN"];
			[personDic setObject:@"N"	forKey:@"TYPE"];
			
			//최초 에는 유세이 친구를 모르기 때문에
		//	[personDic setObject:recordid forKey:@"RECID"];
			
			
			
			
			
			
			
			//번호중에서 한개만 넣는다.
			NSString *fieldchk = nil;
			NSArray* lPhoneArray = [self arrayForMultiValue:aRecord propertyIDOfArray:kABPersonPhoneProperty];
			if(lPhoneArray != nil) {
				for(NSDictionary* item in lPhoneArray) {
					//순서가 모바일/아이폰/메인폰 순으로 내려옴
					NSString *number = nil;
					number = [self parseNumber:[item valueForKey:@"value"]];
					if ([number length] > 0) {
						
						//REPLACE 문으로 있으면 업데이트 없으면 인서트 한다 
						
						/*
						NSString *update = [NSString stringWithFormat:@"INSERT OR REPLACE INTO _TPreContact (RECID,PHONE,TYPE,FIRST,LAST,SUCESS)values(%@,'%@','C','%@','%@','N')",
											recordid,number, firstname, lastname];
					
						//[trans executeSql:update];
						*/
					//	[trans executeSqlWithParameters:@"INSERT OR REPLACE INTO _TPreContact (RECID,PHONE,TYPE,FIRST,LAST,SUCESS)values(?,?,C,?,?,N", recordid, number, firstname, lastname, nil];
						[trans executeSqlWithParameters:@"INSERT OR REPLACE INTO _TPreContact (RECID,PHONE,TYPE,FIRST,LAST,SUCESS)values(?,?,?,?,?,?)", recordid, number, @"C", firstname, lastname, @"N", nil];

						
						
						
						
						
						//맨 처음것만 집어넣고 나머진 넣을필요가 없다 
						if(![personDic objectForKey:@"NUMBER"])
						{
							if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneMobileLabel]){  //mobilephone
								[personDic setObject:number forKey:@"NUMBER"];
								continue;
							}
							else if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneIPhoneLabel]){  //iphone
								[personDic setObject:number forKey:@"NUMBER"];
								fieldchk = @"kABPersonPhoneIPhoneLabel";
							}
							else if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneMainLabel]){
								//아이폰으로 한번이라도 입력을 했다면 컨티뉴
								[personDic setObject:number forKey:@"NUMBER"];
								fieldchk = @"kABPersonPhoneMainLabel";
							}
							else {
								[personDic setObject:number forKey:@"NUMBER"];
							}
						}
						else {
							if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneMobileLabel]){  //mobilephone
								[personDic setObject:number forKey:@"NUMBER"];
								continue;
							}
							else if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneIPhoneLabel]){  //iphone
								//필드를 검사해서 아이폰을 이미 넣었다면 패스
								if (![fieldchk isEqualToString:@"kABPersonPhoneIPhoneLabel"]) {
									[personDic setObject:number forKey:@"NUMBER"];
									fieldchk = @"kABPersonPhoneIPhoneLabel";
								}
								
							}
							else if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneMainLabel]){
								
								//아이폰으로 한번이라도 입력을 했다면 컨티뉴
								if (![fieldchk isEqualToString:@"kABPersonPhoneIPhoneLabel"]) {
									[personDic setObject:number forKey:@"NUMBER"];
									fieldchk = @"kABPersonPhoneMainLabel";
								}
								
							}//mainphone
						}
						
						
					}
					else {
						NSLog(@"번호입력이 비어있다.");
					}
					
					
					
					
					
				}
				
			}
			
			//레코드별 전체 데이터를 가져고 있는 메모리
			[[self appDelegate].userAllDataDic setObject:personDic forKey:recordid];
			
			
			//레코드 아이디만 들고 있는다
			NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
			[tmpDic setObject:recordid forKey:@"RECID"];
			[tmpDic setObject:name forKey:@"NAME"];
			[PeopleArray addObject:tmpDic];
			
		}
		[trans commit];
		
		//임시 그룹에다가 사용자들을 넣는다., 유세이 사용자 숫자도 파악
		[tmpGroup setObject:PeopleArray forKey:@"UserInfo"];
		[[self appDelegate].GroupArray addObject:tmpGroup];
		NSTimeInterval starttime2 = [[NSDate date] timeIntervalSince1970];
		NSLog(@"################### 주소록 로딩 완료111 %f #####################",starttime2 - starttime1);
		return nil;
	}
	
	
	//그룹이 존재 하는 경우 
	[trans beginTransaction];
	for(CFIndex g = 0;g<groupCount;g++){
		//그룹 배열 만큼 돌면서
		
		//그룹 정보를 얻고 
		ABRecordRef gRecord = CFArrayGetValueAtIndex(groupsRef, g);
		NSString *gid = [NSString stringWithFormat:@"%i", ABRecordGetRecordID(gRecord)];
		
		//해당 그룹 멤버를 받아서 		
		NSArray* groupContacts = (NSArray*)ABGroupCopyArrayOfAllMembers(gRecord);
		//그룹 정보를 셋팅하고
		NSMutableArray *PeopleArray = [NSMutableArray array];
		NSMutableDictionary *tmpGroup = [NSMutableDictionary dictionary];
		NSString *gtitle =  [(NSString*)ABRecordCopyValue(gRecord, kABGroupNameProperty) autorelease];
		
		[tmpGroup setObject:gid forKey:@"GID"];
		[tmpGroup setObject:gtitle forKey:@"TITLE"];
		//그룹별 메모리도 있어야 겠다..
		int usaycnt = 0;
		if([groupContacts count] > 0){ //그룹멤버 갯수가 1개라도 존재하면..
			for(id person in groupContacts){
				
				//그룹에 레코드 번호랑 사용자의 레코드 번호랑 일치하면 같은 사용자..
				NSMutableDictionary *personDic = [NSMutableDictionary dictionary];
				NSString *recordid = [NSString stringWithFormat:@"%i", (NSUInteger)ABRecordGetRecordID(person)];
				NSString* firstname = [(NSString *)ABRecordCopyValue(person,kABPersonFirstNameProperty) autorelease];
				NSString* lastname = [(NSString *)ABRecordCopyValue(person,kABPersonLastNameProperty) autorelease];
				//사용자 이름
				NSString *name = [NSString stringWithFormat:@"%@ %@",lastname?lastname:@"",firstname?firstname:@""];
				//이름,
				
				NSData *imageData = (NSData*)ABPersonCopyImageData(person);
				if (imageData != nil && imageData != NULL) {
					[personDic setObject:imageData forKey:@"IMAGE"];
				}
				
				if ([name isEqualToString:@" "]) {
					name=@"이름없음";
				}
				
				if([name length] > 0)
					[personDic setObject:name forKey:@"NAME"];
				else {
					[personDic setObject:@"이름없음" forKey:@"NAME"];
				}
				
			//	[personDic setObject:recordid forKey:@"RECID"];
				
				
				if(firstname == nil || firstname == NULL)
					firstname =@"";
				if (lastname == nil || lastname == NULL) {
					lastname =@"";
				}
				
				
				[personDic setObject:firstname forKey:@"FN"];
				[personDic setObject:lastname	forKey:@"LN"];
				[personDic setObject:@"N"	forKey:@"TYPE"];
				
				
				
				NSDate* cdate = [(NSDate *)ABRecordCopyValue(person,kABPersonCreationDateProperty) autorelease];
				NSDate* currentDate = [NSDate date];
				NSNumber *intervalNumber = [NSNumber numberWithLongLong:[currentDate timeIntervalSinceDate:cdate]];
				
				
				//	NSLog(@"inteval %@", intervalNumber);
				
				
				if([intervalNumber intValue] > 86400)
				{
					[personDic setObject:@"N" forKey:@"NEWUSER"];
				}
				else {
					[personDic setObject:@"Y" forKey:@"NEWUSER"];
				}
				
				
				
				
				//해당 레코드 아이디가 없을때만 추가 
				if(![inGrouplist objectForKey:recordid])
					[inGrouplist setObject:@"" forKey:recordid];
				
				
				
				
				
				NSArray* lPhoneArray = [self arrayForMultiValue:person propertyIDOfArray:kABPersonPhoneProperty];
				NSString* fieldchk = nil;
				if(lPhoneArray != nil) {
					
					for(NSDictionary* item in lPhoneArray) {
						//순서가 모바일/아이폰/메인폰 순으로 내려옴
						NSString *number = nil;
						number = [self parseNumber:[item valueForKey:@"value"]];
						
						
						
						
						if ([number length] > 0) {
							
							
							if(firstname == nil || firstname == NULL)
								firstname =@"";
							if (lastname == nil || lastname == NULL) {
								lastname =@"";
							}
							
							
							//REPLACE 문으로 있으면 업데이트 없으면 인서트 한다 
							/*
							NSString *update = [NSString stringWithFormat:@"INSERT OR REPLACE INTO _TPreContact (RECID,PHONE,TYPE,FIRST,LAST,SUCESS)values(%@,'%@','C','%@','%@','N')",
												recordid,number, firstname, lastname];
						*/
						//	[trans executeSqlWithParameters:@"INSERT OR REPLACE INTO _TPreContact (RECID,PHONE,TYPE,FIRST,LAST,SUCESS)values(?,?,C,?,?,N", recordid, number, firstname, lastname, nil];

							
							[trans executeSqlWithParameters:@"INSERT OR REPLACE INTO _TPreContact (RECID,PHONE,TYPE,FIRST,LAST,SUCESS)values(?,?,?,?,?,?)", recordid, number, @"C", firstname, lastname, @"N", nil];

							
							//맨 처음것만 집어넣고 나머진 넣을필요가 없다 
							if(![personDic objectForKey:@"NUMBER"])
							{
								if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneMobileLabel]){  //mobilephone
									[personDic setObject:number forKey:@"NUMBER"];
									continue;
								}
								else if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneIPhoneLabel]){  //iphone
									[personDic setObject:number forKey:@"NUMBER"];
									fieldchk = @"kABPersonPhoneIPhoneLabel";
								}
								else if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneMainLabel]){
									//아이폰으로 한번이라도 입력을 했다면 컨티뉴
									[personDic setObject:number forKey:@"NUMBER"];
									fieldchk = @"kABPersonPhoneMainLabel";
								}
								else {
									[personDic setObject:number forKey:@"NUMBER"];
								}
							}
							else {
								if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneMobileLabel]){  //mobilephone
									[personDic setObject:number forKey:@"NUMBER"];
									continue;
								}
								else if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneIPhoneLabel]){  //iphone
									//필드를 검사해서 아이폰을 이미 넣었다면 패스
									if (![fieldchk isEqualToString:@"kABPersonPhoneIPhoneLabel"]) {
										[personDic setObject:number forKey:@"NUMBER"];
										fieldchk = @"kABPersonPhoneIPhoneLabel";
									}
									
								}
								else if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneMainLabel]){
									
									//아이폰으로 한번이라도 입력을 했다면 컨티뉴
									if (![fieldchk isEqualToString:@"kABPersonPhoneIPhoneLabel"]) {
										[personDic setObject:number forKey:@"NUMBER"];
										fieldchk = @"kABPersonPhoneMainLabel";
									}
									
								}//mainphone
							}
							
							
						}
						else {
							NSLog(@"번호입력이 비어있다.");
						}
						
						
						
					}
					
					
				}
				
				[[self appDelegate].userAllDataDic setObject:personDic forKey:recordid];
				NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
				[tmpDic setObject:recordid forKey:@"RECID"];
				[tmpDic setObject:name forKey:@"NAME"];
				[PeopleArray addObject:tmpDic];
				
			}
		}
		//그룹이 하나씩 끝날때 마다 그룹을 전체 그룹 배열에 넣어준다.
		[tmpGroup setObject:PeopleArray forKey:@"UserInfo"];
		[[self appDelegate].GroupArray addObject:tmpGroup];
		//[[self appDelegate].GroupArray addObject:PeopleArray];
		[groupContacts release];
		//	DebugLog(@"GroupArray Log %@ Cnt %d RecCnt %d",GroupArray, [GroupArray count], [[GroupArray objectAtIndex:0] count]);
		
	}
	[trans commit];
	
	
	
	
	
	//그룹에 속하지 않는 사용자들도 추가하기
	
	
	
	
	NSMutableDictionary *tmpGroup =[NSMutableDictionary dictionary];
	
	[tmpGroup setObject:@"미지정 그룹" forKey:@"TITLE"];
	[tmpGroup setObject:@"-1" forKey:@"GID"];
	
	
	NSMutableArray *PeopleArray = [NSMutableArray array];
	
	
	
	int usaycnt = 0;
	[trans beginTransaction];
	for(CFIndex i = 0; i<personCount; i++)
	{
		
		
		
		
		
		ABRecordRef person = CFArrayGetValueAtIndex(peopleRef, i);
		//그룹에 레코드 번호랑 사용자의 레코드 번호랑 일치하면 같은 사용자..
		NSMutableDictionary *personDic = [NSMutableDictionary dictionary];
		NSString *recordid = [NSString stringWithFormat:@"%i", (NSUInteger)ABRecordGetRecordID(person)];
		
		
		//해당 레코드가 존재하면 
		if([inGrouplist objectForKey:recordid])
			continue;
		
		
		
		
		NSString* firstname = [(NSString *)ABRecordCopyValue(person,kABPersonFirstNameProperty) autorelease];
		NSString* lastname = [(NSString *)ABRecordCopyValue(person,kABPersonLastNameProperty) autorelease];
		//사용자 이름
		NSString *name = [NSString stringWithFormat:@"%@ %@",lastname?lastname:@"",firstname?firstname:@""];
		//이름,
		
		NSData *imageData = (NSData*)ABPersonCopyImageData(person);
		if (imageData != nil && imageData != NULL) {
			[personDic setObject:imageData forKey:@"IMAGE"];
		}
		if ([name isEqualToString:@" "]) {
			name=@"이름없음";
		}
		
		
		if([name length] > 0)
			[personDic setObject:name forKey:@"NAME"];
		else {
			[personDic setObject:@"이름없음" forKey:@"NAME"];
		}
		
	//	[personDic setObject:recordid forKey:@"RECID"];
		
		
		if(firstname == nil || firstname == NULL)
			firstname =@"";
		if (lastname == nil || lastname == NULL) {
			lastname =@"";
		}
		
		
		[personDic setObject:firstname forKey:@"FN"];
		[personDic setObject:lastname	forKey:@"LN"];
		[personDic setObject:@"N"	forKey:@"TYPE"];
		
		
		
		NSDate* cdate = [(NSDate *)ABRecordCopyValue(person,kABPersonCreationDateProperty) autorelease];
		NSDate* currentDate = [NSDate date];
		NSNumber *intervalNumber = [NSNumber numberWithLongLong:[currentDate timeIntervalSinceDate:cdate]];
		
		
		//	NSLog(@"inteval %@", intervalNumber);
		
		
		if([intervalNumber intValue] > 86400)
		{
			[personDic setObject:@"N" forKey:@"NEWUSER"];
		}
		else {
			[personDic setObject:@"Y" forKey:@"NEWUSER"];
		}
		
		
		
		
		
		NSArray* lPhoneArray = [self arrayForMultiValue:person propertyIDOfArray:kABPersonPhoneProperty];
		NSString* fieldchk = nil;
		if(lPhoneArray != nil) {
			
			for(NSDictionary* item in lPhoneArray) {
				
				//순서가 모바일/아이폰/메인폰 순으로 내려옴
				NSString *number = nil;
				number = [self parseNumber:[item valueForKey:@"value"]];
				
				
				
				if ([number length] > 0) {
					
					
					//REPLACE 문으로 있으면 업데이트 없으면 인서트 한다 
					/*
					NSString *update = [NSString stringWithFormat:@"INSERT OR REPLACE INTO _TPreContact (RECID,PHONE,TYPE,FIRST,LAST,SUCESS)values(%@,'%@','C','%@','%@','N')",
										recordid,number, firstname, lastname];
					[trans executeSql:update];
					*/
					[trans executeSqlWithParameters:@"INSERT OR REPLACE INTO _TPreContact (RECID,PHONE,TYPE,FIRST,LAST,SUCESS)values(?,?,?,?,?,?)", recordid, number, @"C", firstname, lastname, @"N", nil];

					
					//맨 처음것만 집어넣고 나머진 넣을필요가 없다 
					//맨 처음것만 집어넣고 나머진 넣을필요가 없다 
					if(![personDic objectForKey:@"NUMBER"])
					{
						if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneMobileLabel]){  //mobilephone
							[personDic setObject:number forKey:@"NUMBER"];
							continue;
						}
						else if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneIPhoneLabel]){  //iphone
							[personDic setObject:number forKey:@"NUMBER"];
							fieldchk = @"kABPersonPhoneIPhoneLabel";
						}
						else if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneMainLabel]){
							//아이폰으로 한번이라도 입력을 했다면 컨티뉴
							[personDic setObject:number forKey:@"NUMBER"];
							fieldchk = @"kABPersonPhoneMainLabel";
						}
						else {
							[personDic setObject:number forKey:@"NUMBER"];
						}
					}
					else {
						if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneMobileLabel]){  //mobilephone
							[personDic setObject:number forKey:@"NUMBER"];
							continue;
						}
						else if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneIPhoneLabel]){  //iphone
							//필드를 검사해서 아이폰을 이미 넣었다면 패스
							if (![fieldchk isEqualToString:@"kABPersonPhoneIPhoneLabel"]) {
								[personDic setObject:number forKey:@"NUMBER"];
								fieldchk = @"kABPersonPhoneIPhoneLabel";
							}
							
						}
						else if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneMainLabel]){
							
							//아이폰으로 한번이라도 입력을 했다면 컨티뉴
							if (![fieldchk isEqualToString:@"kABPersonPhoneIPhoneLabel"]) {
								[personDic setObject:number forKey:@"NUMBER"];
								fieldchk = @"kABPersonPhoneMainLabel";
							}
							
						}//mainphone
					}
					
					
				}
				else {
					NSLog(@"번호입력이 비어있다.");
				}
				
				
				
				
			}
			
			
		}
		//[PeopleArray addObject:personDic];
		[[self appDelegate].userAllDataDic setObject:personDic forKey:recordid];
		NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
		[tmpDic setObject:recordid forKey:@"RECID"];
		[tmpDic setObject:name forKey:@"NAME"];
		[PeopleArray addObject:tmpDic];
		
		
		
	}
	[trans commit];
	
	
	//사람이 한명이라도 존재할때만
	if([PeopleArray count] > 0)
	{
		[tmpGroup setObject:PeopleArray forKey:@"UserInfo"];
		
		[[self appDelegate].GroupArray addObject:tmpGroup];
	}
	
	
	NSTimeInterval starttime2 = [[NSDate date] timeIntervalSince1970];
	NSLog(@"################## 주소록 로딩 완료 %f ###################",starttime2 - starttime1);
	CFRelease(peopleRef);
	CFRelease(groupsRef);
	// ~sochae
	
	//2011.01.11 릭 갯수 줄이기 위해 위에꺼 주석 풀고 아래꺼 주석 한다.
	// 110124 analyze
	CFRelease(addressBook);	
	return nil;
}



#pragma mark ( iPhone -> USay ) : OEM주소록의 전체 데이터 가져 오기
-(NSDictionary *)readFullOEMContacts
{
	DebugLog(@"===== (iPhone -> USay memory) OEM 주소록 전체 가져오기 =====>");
	// 주소록 객체 생성.
	ABAddressBookRef addressBook = ABAddressBookCreate();

	// 저장된 (그룹/개인)목록 복사해서 가져오기.
//	CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
//	CFArrayRef groups = ABAddressBookCopyArrayOfAllGroups(addressBook);

	// 110124 analyze
	CFArrayRef peopleRef = ABAddressBookCopyArrayOfAllPeople(addressBook);
//	NSArray *people = (NSArray*)peopleRef;

	CFArrayRef groupsRef = ABAddressBookCopyArrayOfAllGroups(addressBook);
//	NSArray *groups = (NSArray*)groupsRef;
	

	CFIndex personCount = ABAddressBookGetPersonCount(addressBook);
	CFIndex groupCount = ABAddressBookGetGroupCount(addressBook);
	
	NSMutableArray *arrayGroups = [NSMutableArray array];
	NSMutableArray *arrayContacts = [NSMutableArray array];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	NSLocale *locale = [NSLocale currentLocale];
	[formatter setLocale:locale];
	[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
	tmpGroupDic =[NSMutableDictionary dictionary];
	
	
	
	/*
	
	
	if([[NSUserDefaults standardUserDefaults] objectForKey:@"GRECORDID"])
	{
		NSLog(@"마지막 그룹 아이디가 존재한다. %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"GRECORDID"]);
	}
	else {
		NSString *maxID=nil;
		
		for(CFIndex g = 0;g<groupCount;g++){
			ABRecordRef gRecord = CFArrayGetValueAtIndex(groups,g);
			NSString *recID = [NSString stringWithFormat:@"%@", (NSString*)gRecord];
			NSLog(@"recID = %@", recID);
		}
		
		maxID = recID;
		[[NSUserDefaults standardUserDefaults] setObject:maxGID forKey:@"GRECORDID"];
	}
	
	*/
	
	// oem 그룹이 있는지 확인하고 그룹이 존재하면 배열에 인서트 한다.
	for(CFIndex g = 0; g<groupCount; g++)
	{
		GroupInfo* abGroup = [[GroupInfo alloc] init];
		
		// 해당 row(g)의 Record(그룹) 정보 가져오기.
		ABRecordRef gRecord = CFArrayGetValueAtIndex(groupsRef,g);
		
		abGroup.RECORDID = [NSString stringWithFormat:@"%i", ABRecordGetRecordID(gRecord)*-1];			// 그룹 레코드 ID
		abGroup.GROUPTITLE = [(NSString*)ABRecordCopyValue(gRecord, kABGroupNameProperty) autorelease];	// 그룹 이름
		if(abGroup.GROUPTITLE != nil && [abGroup.GROUPTITLE length] > 0)
		{
			//그룹리스트에서 그룹 타이틀이 발견되면 중복으로 넣으줄 필요가 없다 따라서 걍 무시..
			if ([tmpGroupDic objectForKey:abGroup.GROUPTITLE]) {
				//맨 첫번째 그룹 아이디값을 넣어준다..
				DebugLog(@"새로운 그룹이 아니군... %@", abGroup.GROUPTITLE);
			//	abGroup.RECORDID = [tmpGroupDic objectForKey:abGroup.GROUPTITLE];
			}
			else //새로운 그룹이라면 배열을 만든다..
			{
				DebugLog(@"새로운 그룹이다.. %@", abGroup.GROUPTITLE);
				//발견이 안되면 새로운 그룹이다. 리스트 추가해준다..
				[tmpGroupDic setObject:abGroup.RECORDID forKey:abGroup.GROUPTITLE];
				[arrayGroups addObject:abGroup];
			}
		}
		[abGroup release];
	}
	DebugLog(@"===> group array \n:%@", arrayGroups);

	// oem 개인 정보를 (local memory) 배열에 추가함.
	
	
	
	
	for(CFIndex i = 0; i<personCount; i++)
	{
		UserInfo* abUser = [[UserInfo alloc] init];
		
		
		
		// 해당 row(g)의 Record(개인) 정보 가져오기.
		ABRecordRef aRecord = CFArrayGetValueAtIndex(peopleRef, i);
		
		
		
		
		abUser.OEMCREATEDATE = [NSString stringWithFormat:@"%@", [(NSString *)ABRecordCopyValue(aRecord,kABPersonCreationDateProperty) autorelease]];
		abUser.OEMMODIFYDATE = [NSString stringWithFormat:@"%@", [(NSString *)ABRecordCopyValue(aRecord,kABPersonModificationDateProperty) autorelease]];
		
		
		DebugLog(@"신규 데이터 수정일(%d) = %@", (NSInteger)i, abUser.OEMMODIFYDATE); 
		
		
//		NSInteger aRecordID = ABRecordGetRecordID(aRecord);
		abUser.RECORDID = [NSString stringWithFormat:@"%i", ABRecordGetRecordID(aRecord)];
//		DebugLog(@"===> RECORDID = %i", abUser.RECORDID);
		
		//single-line string
		NSString* firstname = [(NSString *)ABRecordCopyValue(aRecord,kABPersonFirstNameProperty) autorelease];
		NSString* lastname = [(NSString *)ABRecordCopyValue(aRecord,kABPersonLastNameProperty) autorelease];
		//사용자 이름
		abUser.FORMATTED = [NSString stringWithFormat:@"%@ %@",lastname?lastname:@"",firstname?firstname:@""];
		
		DebugLog(@"신규 데이터 이름 = %@", abUser.FORMATTED); 
		
		
		//사용자의 그룹아이디를 구해서 배열에 저장
		for(CFIndex g = 0;g<groupCount;g++){
			ABRecordRef gRecord = CFArrayGetValueAtIndex(groupsRef, g);
			NSArray* groupContacts = (NSArray*)ABGroupCopyArrayOfAllMembers(gRecord);
			if([groupContacts count] > 0){
				for(id person in groupContacts){
					
					if((NSUInteger) ABRecordGetRecordID(person) == (NSUInteger)ABRecordGetRecordID(aRecord))
					{
						NSString *gtitle =  [(NSString*)ABRecordCopyValue(gRecord, kABGroupNameProperty) autorelease];
						//리스트에서 발견이 되어야 한다.. 왜냐 위에서 리스트를 이미 만들었으니깐...
						if ([tmpGroupDic objectForKey:gtitle]) {
							//맨 첫번째 그룹 아이디값을 넣어준다..
							//	abGroup.RECORDID = [tmpGroupDic objectForKey:abGroup.GROUPTITLE];
							DebugLog(@"기존 그룹이다.. %@ %@", gtitle, [tmpGroupDic objectForKey:gtitle]);
							abUser.GID = [tmpGroupDic objectForKey:gtitle];
						}
					//임시 주석....	
					//	abUser.GID = [NSString stringWithFormat:@"%i", ABRecordGetRecordID(gRecord)*-1];
					}
				}				
			}else {
			//mezzo	[groupContacts release];
			}

			[groupContacts release];
		}
		
/*		middlename = (NSString *)ABRecordCopyValue(aRecord,kABPersonMiddleNameProperty);
		if(middlename) abUser.MIDDLENAME = middlename;
		prefix = (NSString *)ABRecordCopyValue(aRecord,kABPersonPrefixProperty);
		if(prefix) abUser.FAMILYNAME = prefix;										//경칭
		suffix = (NSString *)ABRecordCopyValue(aRecord,kABPersonSuffixProperty);
		if(suffix) abUser.GIVENNAME = suffix;										//이름 접미사, 호칭
*/		
		NSString* nickname = [(NSString *)ABRecordCopyValue(aRecord,kABPersonNicknameProperty) autorelease];
		if(nickname) abUser.NICKNAME = nickname;
		
/*		firstnamephonetic = (NSString *)ABRecordCopyValue(aRecord,kABPersonFirstNamePhoneticProperty);
		if(firstnamephonetic) abUser.PHONETICNAME = firstnamephonetic;		
		lastnamephonetic = (NSString *)ABRecordCopyValue(aRecord,kABPersonLastNamePhoneticProperty);
		if(lastnamephonetic) [arrayContact setObject:lastnamephonetic forKey:PHONETIC_LAST_STRING];
		middlenamephonetic = (NSString *)ABRecordCopyValue(aRecord,kABPersonMiddleNamePhoneticProperty);
		if(middlenamephonetic) [arrayContact setObject:middlenamephonetic forKey:PHONETIC_MIDDLE_STRING];
*/
		NSString* organization = [(NSString *)ABRecordCopyValue(aRecord,kABPersonOrganizationProperty) autorelease];
		if(organization) abUser.ORGNAME = organization;
//		jobtitle = (NSString *)ABRecordCopyValue(aRecord,kABPersonJobTitleProperty);
//		if(jobtitle) abUser.JOBTITLE = jobtitle;
//		department = (NSString *)ABRecordCopyValue(aRecord,kABPersonDepartmentProperty);
//		if(department) abUser.DEPARTMENT = department;
		NSString* note = [(NSString *)ABRecordCopyValue(aRecord,kABPersonNoteProperty) autorelease];
		if(note) abUser.NOTE = note;
		//Date
//		birthday = (NSDate *)ABRecordCopyValue(aRecord,kABPersonBirthdayProperty);
//		if(birthday) abUser.BIRTHDAY = [formatter stringFromDate:birthday];
	
		//multyValue property;
		NSArray* lEmailArray = [self arrayForMultiValue:aRecord propertyIDOfArray:kABPersonEmailProperty];
		if(lEmailArray != nil){
			// Generic labels // kABWorkLabel, kABHomeLabel, kABOtherLabel
			for(NSDictionary* item in lEmailArray) {
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABHomeLabel])
					abUser.HOMEEMAILADDRESS = [item valueForKey:@"value"];
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABWorkLabel])
					abUser.ORGEMAILADDRESS = [item valueForKey:@"value"];
//				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABOtherLabel])
//					abUser.OTHEREMAILADDRESS = [item valueForKey:@"value"];
			}
		}
/*		addressArray = [self arrayForMultiValue:aRecord propertyIDOfArray:kABPersonAddressProperty];
		if(addressArray) {
			// kABPersonAddressStreetKey, kABPersonAddressCityKey, kABPersonAddressStateKey
			// kABPersonAddressZIPKey, kABPersonAddressCountryKey, kABPersonAddressCountryCodeKey
			for(NSDictionary* item in addressArray) {
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonAddressCityKey])
					abUser.HOMECITY = [item valueForKey:@"value"];
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonAddressZIPKey])
					abUser.HOMEZIPCODE = [item valueForKey:@"value"];
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonAddressStreetKey])
					abUser.HOMEADDRESSDETAIL = [item valueForKey:@"value"];
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonAddressCountryKey])
					abUser.HOMESTATE = [item valueForKey:@"value"];
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonAddressStateKey])
					abUser.HOMEADDRESS = [item valueForKey:@"value"];
				
			}
		}*/
//		dateArray = [self arrayForMultiValue:aRecord propertyIDOfArray:kABPersonDateProperty];
/*		if(dateArray) {
			//kABPersonAnniversaryLabel
			for(NSDictionary* item in dateArray) {
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonAnniversaryLabel])
					abUser.ANNIVERSARY = [item valueForKey:@"value"];
			}			
		}
*/		
		NSArray* lPhoneArray = [self arrayForMultiValue:aRecord propertyIDOfArray:kABPersonPhoneProperty];
		if(lPhoneArray != nil) {
			// kABWorkLabel, kABHomeLabel, kABOtherLabel
			// kABPersonPhoneMobileLabel, kABPersonPhoneIPhoneLabel, kABPersonPhoneMainLabel
			// kABPersonPhoneHomeFAXLabel, kABPersonPhoneWorkFAXLabel, kABPersonPhonePagerLabel
			for(NSDictionary* item in lPhoneArray) {
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneMobileLabel]){  //mobilephone
					abUser.MOBILEPHONENUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
					abUser.MOBILEPHONENUMBER = [abUser.MOBILEPHONENUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				}
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneIPhoneLabel]){  //iphone
					abUser.IPHONENUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
					abUser.IPHONENUMBER = [abUser.IPHONENUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				}
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneMainLabel]){		//mainphone
					abUser.MAINPHONENUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
					abUser.MAINPHONENUMBER = [abUser.MAINPHONENUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				}
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABHomeLabel]){				//homephone
					abUser.HOMEPHONENUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
					abUser.HOMEPHONENUMBER = [abUser.HOMEPHONENUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				}
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABWorkLabel]){				//orgphone
					abUser.ORGPHONENUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
					abUser.ORGPHONENUMBER = [abUser.ORGPHONENUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				}
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABOtherLabel]){				//otherphone
					abUser.OTHERPHONENUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
					abUser.OTHERPHONENUMBER = [abUser.OTHERPHONENUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				}
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhonePagerLabel]){  //phonepaser
					abUser.PARSERNUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
					abUser.PARSERNUMBER = [abUser.PARSERNUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				}
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneHomeFAXLabel]){ //homefax
					abUser.HOMEFAXPHONENUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
					abUser.HOMEFAXPHONENUMBER = [abUser.HOMEFAXPHONENUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				}
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneWorkFAXLabel]){ //orgfax
					abUser.ORGFAXPHONENUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
					abUser.ORGFAXPHONENUMBER = [abUser.ORGFAXPHONENUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				}
			}
			
		}
		
		
//		smsArray = [self arrayForMultiValue:aRecord propertyIDOfArray:kABPersonInstantMessageProperty];
/*		if(smsArray) {
			// kABWorkLabel, kABHomeLabel, kABOtherLabel, 
			// kABPersonInstantMessageServiceKey, kABPersonInstantMessageUsernameKey
			// kABPersonInstantMessageServiceYahoo, kABPersonInstantMessageServiceJabber
			// kABPersonInstantMessageServiceMSN, kABPersonInstantMessageServiceICQ
			// kABPersonInstantMessageServiceAIM
			for(NSDictionary* item in smsArray) {
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABHomeLabel])
					abUser.IMS1 = [item valueForKey:@"value"];
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABWorkLabel])
					abUser.IMS2 = [item valueForKey:@"value"];
			}		
		}
*/
		NSArray* lUrlArray = [self arrayForMultiValue:aRecord propertyIDOfArray:kABPersonURLProperty];
		if(lUrlArray != nil) {
			// kABWorkLabel, kABHomeLabel, kABOtherLabel
			// kABPersonHomePageLabel
			for(NSDictionary* item in lUrlArray) {
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonHomePageLabel])
					abUser.URL1 = [item valueForKey:@"value"];
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABHomeLabel])
					abUser.URL2 = [item valueForKey:@"value"];
			}
		}
	
		/* sochae 2011.01.03 - 이미지 release하면서 죽음. 현재 이미지 사용 안하지 않나? 
		if (ABPersonHasImageData(aRecord)) {
			CFDataRef imageData = ABPersonCopyImageData(aRecord);
//			UIImage *abimage = [UIImage imageWithData:(NSData *) imageData];
			CFRelease(imageData);
		}*/
		
		[arrayContacts addObject:abUser];
		[abUser release];
		
	}
	[formatter release];
	// sochae 2011.01.03 - 여기 addressBook과 함께 release 하면 죽는다.. 지금까지는 왜 안죽었지?
	// 110124 analyze
	CFRelease(peopleRef);
	CFRelease(groupsRef);
	// ~sochae
	
	//2011.01.11 릭 갯수 줄이기 위해 위에꺼 주석 풀고 아래꺼 주석 한다.
	// 110124 analyze
	CFRelease(addressBook);	
	
	
	NSMutableDictionary* fullAddressBook = [NSMutableDictionary dictionary];

	[fullAddressBook setObject:arrayGroups forKey:@"GROUP"];
	[fullAddressBook setObject:arrayContacts forKey:@"PERSON"];

	NSLog(@"oem 주소록 개수 (그룹 포함) : %d", [arrayGroups count]+[arrayContacts count]);
	
	
	
	if([tmpGroupDic count] > 0)
	{
		[tmpGroupDic removeAllObjects];
		tmpGroupDic=nil;
	}
	
	return fullAddressBook;
	
}

#pragma mark ( iPhone added -> USay ) : OEM주소록에 추가된 데이터만 가져오기
-(NSDictionary *)readOEMContactsAlterData{
	tmpGroupDic = [NSMutableDictionary dictionary];
	//저장되어 있는 날짜 데이터를 읽어온다.테스트로 하드코딩 했으며 저장되는 날짜 스트링 형식은 하드코딩된 날짜 스트링대로 저장 되게 한다.
	NSString *lastSyncDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastSyncDate"];
	
	
	//동기화 일자가 없으면 기본값으로 셋팅해 준다. kjh
	if(lastSyncDate == nil || lastSyncDate == NULL || [lastSyncDate length] <= 0)
	   lastSyncDate = [[[NSString alloc]initWithFormat:@"19700101000000"] autorelease];

	
	
	NSLog(@"\n  ===> 추가된 OEM Address 가져오기 (lastsynctime : %@) =====>", lastSyncDate);
	
	
	
	//주소록
	ABAddressBookRef addressBook = ABAddressBookCreate();
	
	// 110124 analyze
//	CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
//	CFArrayRef groups = ABAddressBookCopyArrayOfAllGroups(addressBook);
	
	CFArrayRef peopleRef = ABAddressBookCopyArrayOfAllPeople(addressBook);
//	NSArray *people = (NSArray*)peopleRef;
	
	CFArrayRef groupsRef = ABAddressBookCopyArrayOfAllGroups(addressBook);
//	NSArray *groups = (NSArray*)groupsRef;
	
	
	CFIndex personCount = ABAddressBookGetPersonCount(addressBook);
	CFIndex groupCount = ABAddressBookGetGroupCount(addressBook);
	
	NSLog(@"\n  ===> personCount = %d", personCount);
	
	NSMutableArray *arrayContacts = [NSMutableArray array];
	NSMutableArray *arrayGroups = [NSMutableArray array];
	
	
	
	//날짜 형식을 맞추기
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyyMMddHHmmss"];
	
	
	
	NSLocale *locale = [NSLocale currentLocale];
	[formatter setLocale:locale];
	
	

	//라스트 싱크 포맷이 안 맞을 경우 예전에 코드가 잘못되서 바로 잡으려고 넣은 코드이다. kjh
	if([lastSyncDate length] != 14)
	{
		NSLog(@"라스트 싱크 =  %@", lastSyncDate);
		lastSyncDate = @"19700101000000";
		
	}
	else {
		NSLog(@"정상 로그");
	}

	
	
	NSDate *basisDate = [formatter dateFromString:lastSyncDate];

	
	
	
	
	
	for(CFIndex i =personCount-1; i>=0; i--)
	{
//		DebugLog(@"person number = %d", i);
		ABRecordRef aRecord = CFArrayGetValueAtIndex(peopleRef ,i);
		UserInfo* abUser = [[UserInfo alloc] init];
		
		NSDate* cdate = [(NSDate *)ABRecordCopyValue(aRecord,kABPersonCreationDateProperty) autorelease];
		//날자 비교. 년-월-일 시:분:초 로 초다위 까지 비교 하는 것이고, basisDate가 비교 하려는 날짜 보다 빠른지 검사.
		// NSOrderedAscending, NSOrderedSame, NSOrderedDescending관련 참조.
		//즉 나중 데이터면
		
		NSLog(@"마지막 싱크데이터 %@ 단말 저장날짜 =%@", basisDate, cdate);
		
		if([basisDate compare:cdate] ==  NSOrderedAscending)
		{
		//	NSLog(@"있다");
	//		NSInteger aRecordID = ABRecordGetRecordID(aRecord);
			abUser.RECORDID = [NSString stringWithFormat:@"%i", ABRecordGetRecordID(aRecord)]; 
			
			
			
			//생성일 추가
		
			
			abUser.OEMCREATEDATE = [NSString stringWithFormat:@"%@", [(NSString *)ABRecordCopyValue(aRecord,kABPersonCreationDateProperty) autorelease]];
			abUser.OEMMODIFYDATE = [NSString stringWithFormat:@"%@", [(NSString *)ABRecordCopyValue(aRecord,kABPersonModificationDateProperty) autorelease]];
			
//			DebugLog(@"추가 데이터 mdate = %@", abUser.OEMMODIFYDATE); 
		//	DebugLog(@"추가 데이터 날짜 레코드 %@", abUser.RECORDID);
			
		//	NSLog(@"RECORDID = %i", ABRecordGetRecordID(aRecord));
			
			for(CFIndex g = 0;g<groupCount;g++){
				
				ABRecordRef gRecord = CFArrayGetValueAtIndex(groupsRef ,g);
				NSArray* groupContacts = (NSArray*)ABGroupCopyArrayOfAllMembers(gRecord);
				if([groupContacts count] > 0){
					for(id person in groupContacts){
						
						if((NSUInteger) ABRecordGetRecordID(person) == (NSUInteger)ABRecordGetRecordID(aRecord))
						{
							NSString *gtitle =  [(NSString*)ABRecordCopyValue(gRecord, kABGroupNameProperty) autorelease];
							
							//2010.12.09 그룹 없이 간다.
						//	abUser.GID=0;
							//그룹 리스트를 만드는데 만약 기존 리스트에 해당 그룹명이 존재한다면... 그룹아이디는 기존 그룹명의 아이디를 가져간다.
							if ([tmpGroupDic objectForKey:gtitle]) {
								//맨 첫번째 그룹 아이디값을 넣어준다..
								//	abGroup.RECORDID = [tmpGroupDic objectForKey:abGroup.GROUPTITLE];
							//	DebugLog(@"기존 그룹이다.. %@ %@" , gtitle, [tmpGroupDic objectForKey:gtitle]);
								
								abUser.GID = [tmpGroupDic objectForKey:gtitle];
								
							}
							else //만약 리스트에서 발견하지 못한다면 그룹아이디는 새로 입력해준다..
							{
								DebugLog(@"새로운 그룹이다.. %@", gtitle);
								//발견이 안되면 새로운 그룹이다. 리스트 추가해준다..
								abUser.GID = [NSString stringWithFormat:@"%i", ABRecordGetRecordID(gRecord)*-1];
								[tmpGroupDic setObject:abUser.GID forKey:gtitle];
							}
								
						}
					}
					
				}else {
			//mezzo		[groupContacts release];
				}
				
				[groupContacts release];				
			}
			
			//single-line string
			NSString* firstname = [(NSString *)ABRecordCopyValue(aRecord,kABPersonFirstNameProperty) autorelease];
			NSString* lastname = [(NSString *)ABRecordCopyValue(aRecord,kABPersonLastNameProperty) autorelease];
			
			
			abUser.FORMATTED = [NSString stringWithFormat:@"%@ %@",lastname?lastname:@"",firstname?firstname:@""];
			
			
//			DebugLog(@"합쳐진 이름 %@", abUser.FORMATTED);
			
/*
			middlename = (NSString *)ABRecordCopyValue(aRecord,kABPersonMiddleNameProperty);
			if(middlename) abUser.MIDDLENAME = middlename;
			prefix = (NSString *)ABRecordCopyValue(aRecord,kABPersonPrefixProperty);
			if(prefix) abUser.FAMILYNAME = prefix;										//경칭
			suffix = (NSString *)ABRecordCopyValue(aRecord,kABPersonSuffixProperty);
			if(suffix) abUser.GIVENNAME = suffix;										//이름 접미사, 호칭
*/
			NSString* nickname = [(NSString *)ABRecordCopyValue(aRecord,kABPersonNicknameProperty) autorelease];
			if(nickname) abUser.NICKNAME = nickname;
/*			
			firstnamephonetic = (NSString *)ABRecordCopyValue(aRecord,kABPersonFirstNamePhoneticProperty);
			if(firstnamephonetic) abUser.PHONETICNAME = firstnamephonetic;
			
			 lastnamephonetic = (NSString *)ABRecordCopyValue(aRecord,kABPersonLastNamePhoneticProperty);
			 if(lastnamephonetic) [arrayContact setObject:lastnamephonetic forKey:PHONETIC_LAST_STRING];
			 middlenamephonetic = (NSString *)ABRecordCopyValue(aRecord,kABPersonMiddleNamePhoneticProperty);
			 if(middlenamephonetic) [arrayContact setObject:middlenamephonetic forKey:PHONETIC_MIDDLE_STRING];
			 */
			NSString* organization = [(NSString *)ABRecordCopyValue(aRecord,kABPersonOrganizationProperty) autorelease];
			if(organization) abUser.ORGNAME = organization;
//			NSString* jobtitle = [(NSString *)ABRecordCopyValue(aRecord,kABPersonJobTitleProperty) autorelease];
//			if(jobtitle) abUser.JOBTITLE = jobtitle;
//			department = [(NSString *)ABRecordCopyValue(aRecord,kABPersonDepartmentProperty) autorelease];
//			if(department) abUser.DEPARTMENT = department;
			NSString* note = [(NSString *)ABRecordCopyValue(aRecord,kABPersonNoteProperty) autorelease];
			if(note) abUser.NOTE = note;
			//Date
//			birthday = (NSDate *)ABRecordCopyValue(aRecord,kABPersonBirthdayProperty);
//			if(birthday) abUser.BIRTHDAY = [formatter stringFromDate:birthday];
			
			//multyValue property;
			NSArray* emailArray = [self arrayForMultiValue:aRecord propertyIDOfArray:kABPersonEmailProperty];
			if(emailArray != nil){
				// Generic labels // kABWorkLabel, kABHomeLabel, kABOtherLabel
				for(NSDictionary* item in emailArray) {
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABHomeLabel])
						abUser.HOMEEMAILADDRESS = [item valueForKey:@"value"];
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABWorkLabel])
						abUser.ORGEMAILADDRESS = [item valueForKey:@"value"];
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABOtherLabel])
						abUser.OTHEREMAILADDRESS = [item valueForKey:@"value"];
				}
			}
/*			addressArray = [self arrayForMultiValue:aRecord propertyIDOfArray:kABPersonAddressProperty];
			if(addressArray) {
				// kABPersonAddressStreetKey, kABPersonAddressCityKey, kABPersonAddressStateKey
				// kABPersonAddressZIPKey, kABPersonAddressCountryKey, kABPersonAddressCountryCodeKey
				for(NSDictionary* item in addressArray) {
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonAddressCityKey])
						abUser.HOMECITY = [item valueForKey:@"value"];
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonAddressZIPKey])
						abUser.HOMEZIPCODE = [item valueForKey:@"value"];
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonAddressStreetKey])
						abUser.HOMEADDRESSDETAIL = [item valueForKey:@"value"];
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonAddressCountryKey])
						abUser.HOMESTATE = [item valueForKey:@"value"];
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonAddressStateKey])
						abUser.HOMEADDRESS = [item valueForKey:@"value"];
					
				}
			}*/
/*			dateArray = [self arrayForMultiValue:aRecord propertyIDOfArray:kABPersonDateProperty];
			if(dateArray) {
				//kABPersonAnniversaryLabel
				for(NSDictionary* item in dateArray) {
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonAnniversaryLabel])
						abUser.ANNIVERSARY = [item valueForKey:@"value"];
				}			
			}
	*/		
			NSArray* phoneArray = [self arrayForMultiValue:aRecord propertyIDOfArray:kABPersonPhoneProperty];
			if(phoneArray != nil) {
				// kABWorkLabel, kABHomeLabel, kABOtherLabel
				// kABPersonPhoneMobileLabel, kABPersonPhoneIPhoneLabel, kABPersonPhoneMainLabel
				// kABPersonPhoneHomeFAXLabel, kABPersonPhoneWorkFAXLabel, kABPersonPhonePagerLabel
				for(NSDictionary* item in phoneArray) {
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneMobileLabel]){  //mobilephone
						abUser.MOBILEPHONENUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
						abUser.MOBILEPHONENUMBER = [abUser.MOBILEPHONENUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
					}
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneIPhoneLabel]){  //iphone
						abUser.IPHONENUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
						abUser.IPHONENUMBER = [abUser.IPHONENUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
					}
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneMainLabel]){		//mainphone
						abUser.MAINPHONENUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
						abUser.MAINPHONENUMBER = [abUser.MAINPHONENUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
					}
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABHomeLabel]){				//homephone
						abUser.HOMEPHONENUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
						abUser.HOMEPHONENUMBER = [abUser.HOMEPHONENUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
					}
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABWorkLabel]){				//orgphone
						abUser.ORGPHONENUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
						abUser.ORGPHONENUMBER = [abUser.ORGPHONENUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
					}
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABOtherLabel]){				//otherphone
						abUser.OTHERPHONENUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
						abUser.OTHERPHONENUMBER = [abUser.OTHERPHONENUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
					}
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhonePagerLabel]){  //phonepaser
						abUser.PARSERNUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
						abUser.PARSERNUMBER = [abUser.PARSERNUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
					}
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneHomeFAXLabel]){ //homefax
						abUser.HOMEFAXPHONENUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
						abUser.HOMEFAXPHONENUMBER = [abUser.HOMEFAXPHONENUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
					}
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneWorkFAXLabel]){ //orgfax
						abUser.ORGFAXPHONENUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
						abUser.ORGFAXPHONENUMBER = [abUser.ORGFAXPHONENUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
					}
				}
				
			}
	//		smsArray = [self arrayForMultiValue:aRecord propertyIDOfArray:kABPersonInstantMessageProperty];
	/*		if(smsArray) {
				// kABWorkLabel, kABHomeLabel, kABOtherLabel, 
				// kABPersonInstantMessageServiceKey, kABPersonInstantMessageUsernameKey
				// kABPersonInstantMessageServiceYahoo, kABPersonInstantMessageServiceJabber
				// kABPersonInstantMessageServiceMSN, kABPersonInstantMessageServiceICQ
				// kABPersonInstantMessageServiceAIM
				for(NSDictionary* item in smsArray) {
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABHomeLabel])
						abUser.IMS1 = [item valueForKey:@"value"];
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABWorkLabel])
						abUser.IMS2 = [item valueForKey:@"value"];
				}		
			}
	 */
			NSArray* urlArray = [self arrayForMultiValue:aRecord propertyIDOfArray:kABPersonURLProperty];
			if(urlArray != nil) {
				// kABWorkLabel, kABHomeLabel, kABOtherLabel
				// kABPersonHomePageLabel
				for(NSDictionary* item in urlArray) {
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonHomePageLabel])
						abUser.URL1 = [item valueForKey:@"value"];
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABHomeLabel])
						abUser.URL2 = [item valueForKey:@"value"];
				}
			}
			/* sochae 2011.01.03 - 이미지 사용 안하므로 주석 처리.
			if (ABPersonHasImageData(aRecord)) {
//				CFDataRef imageData = ABPersonCopyImageData(aRecord);
//				UIImage *abimage = [UIImage imageWithData:(NSData *) imageData];
//				CFRelease(imageData);
			}*/
			
			[arrayContacts addObject:abUser];
			[abUser release];
		} else {
			
	//		NSLog(@"가져올 데이터가 없다 %@", arrayContacts);
			[abUser release];
			break;
		}
		
	}
	
//	NSString *lastGID = [[NSUserDefaults standardUserDefaults] objectForKey:@"GRECORDID"]; 
	
	//추가 사용자가 한명이라도 존재하면...
	if([arrayContacts count] > 0){
		
		
		
		NSLog(@"추가 카운트 %d", [arrayContacts count]);
		
		
		
		for(CFIndex g = 0;g<groupCount;g++){
			GroupInfo* abGroup = [[[GroupInfo alloc] init] autorelease]; // sochae 2010.12.16 - memory leak
			
			ABRecordRef gRecord = CFArrayGetValueAtIndex(groupsRef,g);
			abGroup.RECORDID = [NSString stringWithFormat:@"%i", ABRecordGetRecordID(gRecord)*-1]; 
		
		//	abGroup.RECORDID = @"-273";
			
			
			DebugLog(@"abGroup.RECORDID %@ %@", abGroup.RECORDID, abGroup.ID);
			
			//새롭운 사용자는 무조건 그룹이 없다..
			abGroup.GROUPTITLE = [(NSString*)ABRecordCopyValue(gRecord, kABGroupNameProperty) autorelease];
		//	abGroup.GROUPTITLE=nil;
			//그룹이 존재하면..
			if(abGroup.GROUPTITLE != nil && [abGroup.GROUPTITLE length] > 0)
			{
				//만약 그룹 타이틀이 발견되면..
				if ([tmpGroupDic objectForKey:abGroup.GROUPTITLE]) {
					//새로 추가한 사람에 있는 그룹만 넣어준다..
					//맨 첫번째 그룹 아이디값을 넣어준다..
				//	abGroup.RECORDID = [tmpGroupDic objectForKey:abGroup.GROUPTITLE];
				//	NSLog(@"기존 그룹이다A.. %@", abGroup.GROUPTITLE);
					{
						abGroup.RECORDID = [tmpGroupDic objectForKey:abGroup.GROUPTITLE];
						DebugLog(@"abGroup.RECORDID %@", abGroup.RECORDID);
						[arrayGroups addObject:abGroup];
					}
					//서버로 전송할 그룹목록을 만드는거다..
				//	break;
				}
				else
				{
					DebugLog(@"새로운 그룹이다B.. %@", abGroup.GROUPTITLE);
					//발견이 안되면 새로운 그룹이다. 리스트 추가해준다..
//					[tmpGroupDic setObject:abGroup.RECORDID forKey:abGroup.GROUPTITLE];
					
					
				}
				
			}
			
			//[abGroup release];
		}
	}
	else {

		//혹시 새롭게 생성된 그룹이 있는지 살펴보자..
		/*
		for(CFIndex g = 0;g<groupCount;g++){
			GroupInfo* abGroup = [[GroupInfo alloc] init];
			
			ABRecordRef gRecord = CFArrayGetValueAtIndex(groups,g);
			NSString *gRecordID =[NSString stringWithFormat:@"%i", ABRecordGetRecordID(gRecord)];
			
			
			abGroup.RECORDID = [NSString stringWithFormat:@"%i", ABRecordGetRecordID(gRecord)*-1]; 
			abGroup.GROUPTITLE = [(NSString*)ABRecordCopyValue(gRecord, kABGroupNameProperty) autorelease];
			if(abGroup.GROUPTITLE != nil && [abGroup.GROUPTITLE length] > 0)
			{
				//라스트가 생성 시간보다 작으면... 그룹추가한다...
				NSString *groupQuery =[NSString stringWithFormat:@"select * from _TGroupInfo where grouptitle='%@'", abGroup.GROUPTITLE];
				NSArray *findGroup = nil;
				
				NSLog(@"groupQuert %@", groupQuery);
				findGroup = [GroupInfo findWithSql:groupQuery];
				if([findGroup count] <= 0)
				{
					NSLog(@"해당 그룹이 유세이에 존재하지 않는다.");
								[arrayGroups addObject:abGroup];
				}
				else	
				{
					NSLog(@"findAAAAA %@", findGroup);
				}
				
				
			}
			[abGroup release];
		}
	//	[[NSUserDefaults standardUserDefaults] setObject:maxGID forKey:@"GRECORDID"];
		 */
		
	}

	
	
	NSLog(@"그룹 카운트.. %d", [arrayGroups count]);
	
	
	
	
	

	[formatter release];
	// sochae 2011.01.03 - 여기도 addressBook과 같이 release하면 안됨
	// 110124 analyze
	CFRelease(peopleRef);
	CFRelease(groupsRef);
	// ~sochae
	//2011.01.11
	//메모리 릭 문제로 addressBook을 릭안하고 그룹과 피플을 해제 한다.
	// 110124 analyze
	CFRelease(addressBook);		
	
	NSMutableDictionary* fullAddressBook = [NSMutableDictionary dictionary];
	
	[fullAddressBook setObject:arrayGroups forKey:@"GROUP"];
	[fullAddressBook setObject:arrayContacts forKey:@"PERSON"];
	
	if([tmpGroupDic count] > 0)
	{
		[tmpGroupDic removeAllObjects];
		tmpGroupDic=nil;
	}
	
	return fullAddressBook;
}

-(void)dealloc{
//	if(allAddrs)[allAddrs release];
//	if(values)[values release];
//	if(keys)[keys release];
	
	[super dealloc];
}
@end
