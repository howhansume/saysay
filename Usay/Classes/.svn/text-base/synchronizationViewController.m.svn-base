//
//  synchronizationViewController.m
//  USayApp
//
//  Created by ku jung on 10. 10. 28..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//
#import "SQLiteDatabase.h"
#import "synchronizationViewController.h"
#import "AddressBookData.h"
#import "UserInfo.h"
#import "GroupInfo.h"

#import "json.h"
#import "USayAppAppDelegate.h"
#import <objc/runtime.h>
#import <unistd.h>
#import "USayDefine.h"
#import "USayHttpData.h"
#import "MessageInfo.h"
#import "MessageUserInfo.h"
#import "RoomInfo.h"
#import "webjoinViewController.h"
#import "JYGanTracker.h"

#define USAYTOIPHONE 33
#define BACKTOIPHONE 44
#define WEBTOMOBILE 55
#define MOBILETOWEB 66
#define CANCLE	77
#define IPHONECNT 99
#define DATET	00
#define PROGRESSCNT	88
#define USAYCNT 1024




@implementation synchronizationViewController

NSMutableDictionary *groupNameDic=nil;
NSMutableDictionary *groupKeyDic=nil;
NSString *webCnt=nil;
UILabel *webCntLabel = nil;
NSInteger warningLevel = 0;
BOOL loadingFlag = NO;
NSMutableDictionary *recordKeyDic=nil;
UILabel *dateLabel = nil;
NSMutableArray *resaveArray = nil;
BOOL delete = NO;




@synthesize flag;
@synthesize cur, tot;   // sochae 2010.12.29 - cLang
@synthesize	timer;

int idx = 0;	// for Timer


NSInteger flag2;
BOOL complete, complete2;
#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

float percent;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/
-(USayAppAppDelegate *) appDelegate
{
	return (USayAppAppDelegate *)[[UIApplication sharedApplication] delegate];
}

-(void)operationQueueSyncDatabase:(NSDictionary*)data{
	
	
	
	
	
	DebugLog(@"data count = %d",[data count]);
	DebugLog(@"=======> start database insert <===========");
	[[NSUserDefaults standardUserDefaults] setInteger:-1 forKey:@"CertificationStatus"];
	
	
//	DebugLog(@"DATA = %@", data);
	
	
	NSArray* userData = [data objectForKey:@"USERDATA"];
	NSArray* groupData = [data objectForKey:@"GROUPDATA"];
	NSString* revisionPoint = [data objectForKey:@"REVISIONPOINT"];
	int currentIndex = 0;
	SQLiteDataAccess* trans = [DataAccessObject database];
	[trans beginTransaction];
	
	if(userData != nil){
		for(UserInfo* userInfo in userData) {
			
			currentIndex++;
			percent =  ((float)currentIndex/(float)[userData count])*100;
			
			cur = currentIndex;
			tot = [userData count];
			
			
//			DebugLog(@"percent = %f", percent);
			
			
			[NSThread detachNewThreadSelector:@selector(showImg) toTarget:self withObject:nil];
			
			
			if([userInfo.ISTRASH isEqualToString:@"N"] ){
							
				
				DebugLog(@"currentIndex %d (%@)", currentIndex, userInfo.FORMATTED);
				
//				DebugLog(@"디비에 인서트 부분 들어와야 한다.");
				if(userInfo.RPCREATED || userInfo.RPUPDATED )
				{
					[userInfo saveSyncData];
					[[NSUserDefaults standardUserDefaults] setObject:userInfo.RPCREATED forKey:@"RevisionPoints"];
#ifdef MEZZO_DEBUG
						DebugLog(@"부분동기화 = %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"RevisionPoints"]);
#endif
					[trans commit];
					
					
									
					
					
					
					
					
					if([trans hasError])
						break;
				}else if(userInfo.RPDELETED && [userInfo.RPDELETED length] > 0){
//					DebugLog(@"DB delete UserInfo");
					[userInfo deleteData];
					
					
					
					
					
									
				}
			}
			else if([userInfo.ISTRASH isEqualToString:@"Y"])
			{
				DebugLog(@"DB delete UserInfo");
				[userInfo deleteData];
			}
			
		//	currentPosition = 1.0 * currentIndex /progressCnt;
		}
	}
	else {
		DebugLog(@"userData nil");
		percent = 100.0f;
		[NSThread detachNewThreadSelector:@selector(showImg) toTarget:self withObject:nil];
	}

	
	//	DebugLog(@"GroupInfo DB insert groupcount = %i", [groupData count]);
	if([trans hasError] == NO){
		if(groupData != nil){
			for(GroupInfo* groupInfo in groupData){
				//			DebugLog(@"DB insert GroupInfo");
				currentIndex++;
				if(groupInfo.RPCREATED || groupInfo.RPUPDATED){
					for(int i = 0;i<[oemGroupArray count];i++){
						NSDictionary* oem = [oemGroupArray objectAtIndex:i];
						if([groupInfo.GROUPTITLE isEqualToString:[oem valueForKey:@"grouptitle"]]){
							groupInfo.RECORDID = [NSString stringWithFormat:@"%@",[oem valueForKey:@"gid"]];
							break;
						}
					}
					[groupInfo saveSyncData];
					if([trans hasError])
						break;
				}else if(groupInfo.RPDELETED && [groupInfo.RPDELETED length] > 0 ){
					[groupInfo deleteData];
				}
				
			//	currentPosition = 1.0 * currentIndex /progressCnt;
		//		[self performSelectorInBackground:@selector(progressControl:) withObject:[NSNumber numberWithFloat:currentPosition]];
			}
		}
	}
	[oemGroupArray release];
	DebugLog(@"DB insert End");
	if([trans hasError] == NO){
		[trans commit];
		//데이터 베이스에 저장후 마지막 동기화 포인트 저장
		if(revisionPoint != nil){
			NSString* revisionPoints = [[NSString alloc] initWithFormat:@"%@",revisionPoint];
			[[NSUserDefaults standardUserDefaults] setObject:revisionPoints forKey:@"RevisionPoints"];
			
			
			
			DebugLog(@"동기화후 여기 들어오냐???");
			
			
			
			
			[revisionPoints release];
		}
		//오늘 일자를 구해 NSUserDefaults로 app 사용자 값에 저장한다.
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		NSLocale *locale = [NSLocale currentLocale];
		[formatter setLocale:locale];
		[formatter setDateFormat:@"yyyyMMddHHmmss"];
		NSDate *today = [NSDate date];
		NSString *lastSyncDate = [[NSString alloc] initWithFormat:@"%@",[formatter stringFromDate:today]];
		
		
		
		
		
		if(userData != nil || groupData != nil){
			DebugLog(@"여기도 들어오냐????");
			[[NSUserDefaults standardUserDefaults] setObject:lastSyncDate forKey:@"lastSyncDate"];
		}
		
		
		
		[lastSyncDate release];
		[formatter release];
		
		NSLog(@"==========> End Database Sync and rp setting <================");
		
		
		
	//	[NSThread detachNewThreadSelector:@selector(startComplete2) toTarget:self withObject:nil];
		
		[self startComplete2];
		
		
		
	//	[self performSelectorInBackground:@selector(progressControl:) withObject:[NSNumber numberWithFloat:1.0]];
//		[startActIndicator stopAnimating];
		[[UIApplication sharedApplication] setStatusBarHidden:NO];
	//	[[self appDelegate] goUseGuide];
//		self.endDBQueue = YES;
		
		[syncBlockView dismissAlertView];
		[syncBlockView release];
		
	}else {
		DebugLog(@"Error insert");
		[trans rollback];
	//	[self performSelectorOnMainThread:@selector(retrySyncAddress:) withObject:[NSNumber numberWithBool:[trans hasError]] waitUntilDone:NO];
		
	}
	
	

	
	
	
}

-(void)syncDatabase:(NSArray*)userData withGroupinfo:(NSArray*)groupData saveRevisionPoint:(NSString*)revisionPoint {
	
	
	
	
	NSMutableDictionary* threadDBData = [NSMutableDictionary dictionary];
	if(userData != nil){
		[threadDBData setObject:userData forKey:@"USERDATA"];
	}
	
	if(groupData != nil){
		[threadDBData setObject:groupData forKey:@"GROUPDATA"];
	}
	
	if(revisionPoint != nil){
		[threadDBData setObject:revisionPoint forKey:@"REVISIONPOINT"];
	}
	//[self performSelectorInBackground:@selector(progressControl:) withObject:[NSNumber numberWithFloat:0.0]];
	NSInvocationOperation* operation = [[NSInvocationOperation alloc] initWithTarget:self 
																			selector:@selector(operationQueueSyncDatabase:) 
																			  object:threadDBData];
	
	NSOperationQueue* queue = [[NSOperationQueue alloc] init];
	[queue setMaxConcurrentOperationCount:1];
	[queue addOperation:operation];
	[operation release];
	[queue release];
	

}

-(void)addListContact:(NSNotification *)notification {
	NSLog(@"==========> addListContact sync sync ==========");
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"addListContactIncludeGroup" object:nil];
	[[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"sendingStatus"];
	USayHttpData *data = (USayHttpData*)[notification object];
	if (data == nil) {
		//200 이외의 오류
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 오류" 
															message:@"네트워크 오류가 발생하였습니다.\n3G 나 wifi 상태를 확인해주세요." 
														   delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return;
	}
	
	//	NSString *api = data.api;
	
	//	NSString *resultData = data.responseData;
	NSString* resultData = [[NSString alloc] initWithString:data.responseData];
	// 1. Create BSJSON parser.
	SBJSON *jsonParser = [[SBJSON alloc] init];
	
	// 2. Get the result dictionary from the response string.
	NSDictionary *dic = (NSDictionary*)[jsonParser objectWithString:resultData error:NULL];
	[jsonParser release];
	[resultData release];
	// 3. Show response
	// key and value type
	NSString *rtcode = nil;
	rtcode = [dic objectForKey:@"rtcode"];	// 프로토콜문서에는 result로 되어 있는것을 rtcode로 변경
	if ([rtcode isEqualToString:@"0"]) {	// success
		NSString *rtType = [dic objectForKey:@"rttype"];
		NSString *count = [dic objectForKey:@"count"]; //리스트 개수
		NSString *RP = [dic objectForKey:@"RP"];  //마지막 동기화 RP
		//		NSMutableArray* serverData = [NSMutableArray array];
		if ([rtType isEqualToString:@"list"]) {
			// Key and Dictionary as its value type
			NSMutableArray* userArray = [NSMutableArray array];
			NSMutableArray* groupArray = [NSMutableArray array];
			int nCount = 0;
			for(NSDictionary *addressDic in [dic objectForKey:@"list"]) {
				GroupInfo* groupData = [[GroupInfo alloc] init];
				UserInfo* userData = [[UserInfo alloc] init];
				NSArray* keyArray = [addressDic allKeys];
				for(NSString* key in keyArray) {
					if([addressDic objectForKey:@"groupTitle"]){//그룹 정보
						NSAutoreleasePool * grouppool = [[NSAutoreleasePool alloc] init];
						unsigned int numIvars = 0;
						Ivar* ivars = class_copyIvarList([GroupInfo class], &numIvars);
						for(int i = 0; i < numIvars; i++) {
							Ivar thisIvar = ivars[i];
							NSString* classkey = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
							
						
							if([key isEqualToString:@"gid"]){
								[groupData  setValue:[addressDic objectForKey:key] forKey:@"ID"];
							}else if([[key uppercaseString] isEqualToString:classkey]){
								[groupData  setValue:[addressDic objectForKey:key] forKey:classkey];
							}
							
							
							
							
							thisIvar = nil;
						}
						
						
						
						NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
						NSLocale *locale = [NSLocale currentLocale];
						[formatter setLocale:locale];
						[formatter setDateFormat:@"yyyyMMddHHmmss"];
						NSDate *today = [NSDate date];
						NSString *lastSyncDate = [[NSString alloc] initWithFormat:@"%@",[formatter stringFromDate:today]];
						
						
						[userData  setValue:lastSyncDate forKey:@"CHANGEDATE"];
						
						[formatter release];
						[lastSyncDate release];
						
						
						if(numIvars > 0) free(ivars);
						[grouppool release];
					}else {//유저 정보
						NSAutoreleasePool * userpool = [[NSAutoreleasePool alloc] init];
						unsigned int numIvars = 0;
						Ivar* ivars = class_copyIvarList([UserInfo class], &numIvars);						
						for(int i = 0; i < numIvars; i++) {
							Ivar thisIvar = ivars[i];
							NSString* classkey = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
							if([[key uppercaseString] isEqualToString:classkey])
								[userData  setValue:[addressDic objectForKey:key] forKey:classkey];
							thisIvar = nil;
						}
						if(numIvars > 0) free(ivars);
						[userpool release];
						
					}
				}
				if([groupData valueForKey:@"ID"]){
					[groupArray addObject:groupData];
				}
				[groupData release];
				
				if([userData valueForKey:@"ID"]){
					[userArray addObject:userData];
				}
				[userData release];
				
				nCount++;
			//	float currentPosition = (0.8 * nCount /[count intValue]);
				//	DebugLog(@"=====> Progress 1 Pos : %f, count = %i", currentPosition, nCount);
			//	[self performSelectorInBackground:@selector(progressControl:) withObject:[NSNumber numberWithFloat:currentPosition]];
				//				DebugLog(@"%i",nCount);
			}
			
			//내려 받은 개수와 리스트를 파싱한 개수가 같을 경우에 저장.
			if([count isEqualToString:[NSString stringWithFormat:@"%i",nCount]]){
			//	[self performSelectorInBackground:@selector(progressControl:) withObject:[NSNumber numberWithFloat:1.0]];
				
				
				
				[self syncDatabase:userArray withGroupinfo:groupArray saveRevisionPoint:RP];
				
				
				sendButton2.frame =CGRectMake(119, 105+(82/2), 83, 73);
				
				if(flag != 2)
				{
				[sendButton2 setImage:[UIImage imageNamed:@"7_btn_complete_1.png"] forState:UIControlStateDisabled];
				sendButton2.enabled=NO;
				sendButton.hidden=YES;
				}
				
				[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"SERVERLOGIN"];
				
				
				
				
				NSLog(@"주소록 리로드");
	
				
				
			}
		} else {
			// TODO: 예외처리
			//아무 자료 없음. rttype : only
			[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"SERVERLOGIN"];
			[self syncDatabase:nil withGroupinfo:nil saveRevisionPoint:nil];
		}
	} else if ([rtcode isEqualToString:@"-9010"]) {
		// TODO: 데이터를 찾을 수 없음.
		/*		AddressBookData* addrData = [[[AddressBookData alloc] init] autorelease];
		 NSDictionary* contacts = nil;
		 contacts = [addrData readFullOEMContacts];
		 if(contacts != nil){
		 // 노티피케이션처리관련 등록..
		 NSMutableDictionary* dicContacts = [NSMutableDictionary dictionary];
		 NSArray* localGroup = [GroupInfo findAll];
		 
		 NSMutableArray* groupArray  = [NSMutableArray arrayWithArray:[contacts objectForKey:@"GROUP"] ];
		 
		 for(GroupInfo* oemGroup in [contacts objectForKey:@"GROUP"]){//oem 그룹
		 for(GroupInfo* dbGroup in localGroup){
		 if([dbGroup.GROUPTITLE	isEqualToString:oemGroup.GROUPTITLE]){
		 //그룹을 뺀다.
		 if(dbGroup.RECORDID == nil && [dbGroup.RECORDID length] == 0){
		 dbGroup.RECORDID = [NSString stringWithFormat:@"%@", oemGroup.RECORDID];
		 NSString* sql = [NSString stringWithFormat:@"UPDATE %@ SET RECORDID = ? WHERE GROUPTITLE=?",[GroupInfo tableName]];
		 [GroupInfo findWithSqlWithParameters:sql, oemGroup.RECORDID, dbGroup.GROUPTITLE,nil];
		 }
		 [groupArray removeObject:oemGroup];
		 }
		 }
		 }
		 
		 NSArray* reLocalGroup = [GroupInfo findAll];
		 for(UserInfo* oemUser in [contacts objectForKey:@"PERSON"]){
		 for(GroupInfo* dbGroup in reLocalGroup){
		 if([dbGroup.RECORDID isEqualToString:oemUser.GID]){
		 // 이미 저장된 그룹. 그룹 아이디를 가져온다.
		 oemUser.GID = [NSString stringWithFormat:@"%@",dbGroup.ID];
		 }
		 }
		 }
		 
		 [dicContacts setObject:groupArray forKey:@"GROUP"];
		 [dicContacts setObject:[contacts objectForKey:@"PERSON"] forKey:@"PERSON"];
		 [self changeDataDictionary:contacts];
		 //*/			
		//		}else{
		//
		//			[self syncDatabase:nil withGroupinfo:nil saveRevisionPoint:nil];
		//		}
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"동기화 실패" message:@"저장된 데이타가 없습니다.(-9010)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return;
		
	} else if ([rtcode isEqualToString:@"-9020"]) {
		// TODO: 잘못된 인자가 넘어옴
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"동기화 실패" message:@"잘못된 값이 포함되어 있습니다.(-9020)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return;
	} else if ([rtcode isEqualToString:@"-9030"]) {
		// TODO: 서버상의 처리 오류. 예외처리 필요
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"동기화 실패" message:@"잘못된 값이 포함되어 있습니다.(-9030)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else if ([rtcode isEqualToString:@"-8012"]) {
		// TODO: 서버상의 처리 오류. 예외처리 필요
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"동기화 실패" message:@"정상적인 인증을 받지 못했습니다.\n종료후 다시 실행해주세요.(-8012)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return;
	} else {
		// TODO: 기타오류 예외처리 필요
		//		DebugLog(@"rtcode %@",rtcode);
		NSString* errcode = [NSString stringWithFormat:@"(%@)",rtcode];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"동기화 실패" message:errcode delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return;
		
		
	}
	
}

-(NSArray *)arrayForMultiValue :(ABRecordRef)theRecord propertyIDOfArray:(ABPropertyID) propertyId {
	ABMultiValueRef theProperty = ABRecordCopyValue(theRecord, propertyId);
	//	NSArray *items = (NSArray *)ABMultiValueCopyArrayOfAllValues(theProperty);
	NSMutableArray *itemArray = [NSMutableArray array];
	

	if(ABMultiValueGetCount(theProperty) != 0)
	{
		for(CFIndex i = 0;i<ABMultiValueGetCount(theProperty);i++)
		{
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
	}
	CFRelease(theProperty);
	
	return (NSArray *)itemArray;
}

// iPhone 주소록 읽어오기.
-(NSMutableArray*)readOEM
{
	// 주소록 객체 생성.
	ABAddressBookRef addressBook = ABAddressBookCreate();
	// 저장된 (그룹/개인)목록 복사해서 가져오기.
	CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
//	CFArrayRef groups = ABAddressBookCopyArrayOfAllGroups(addressBook);
	
	CFIndex personCount = ABAddressBookGetPersonCount(addressBook);
//	CFRelease(addressBook);
//	CFIndex groupCount = ABAddressBookGetGroupCount(addressBook);
	CFIndex tmpIndex = personCount;

	
	//서치 딕셔너리...
//	NSMutableArray *DataArray = [[[NSMutableArray alloc] init] autorelease];
	NSMutableArray *DataArray = [NSMutableArray array];	// sochae 2010.12.16 - memory leak
	
	
	
	NSMutableDictionary *keyDic = [NSMutableDictionary dictionary];
	recordKeyDic = [NSMutableDictionary dictionary];
	/* sochae 2010.12.16 - 복구 기능 삭제
	DebugLog(@"===== (iPhone -> USay memory) 기존 백업 삭제 =====>");
	

	//기존 백업 데이터 삭제
	NSString *deleteQuery = @"delete from _TbackGroupInfo";
	[backGroupInfo findWithSql:deleteQuery];
	NSString *deleteQuery2 = @"delete from _TbackUserInfo";
	[backUserInfo findWithSql:deleteQuery2];

	
	[[backUserInfo database] commit];
	*/
	
	
//	DebugLog(@"===== (iPhone -> USay memory) 기존 백업 삭제완료 =====>");
//	DebugLog(@"===== (iPhone -> USay memory) 주소록백업 시작 =====>");
	
//최신날짜가 맨 처음에 오게
	
	
	
	for(CFIndex i = 0; i<personCount; i++)
	{
	
		
		//메모리 워닝 레벨이 2면 브레이크
		
		if(warningLevel >= 2)
			break;
		
		
		
		
		tmpIndex--;
		
	//	DebugLog(@"tmpIndex = %i", tmpIndex);
		NSMutableArray *valueArray = nil;
		// 해당 row(g)의 Record(개인) 정보 가져오기.
		ABRecordRef aRecord = CFArrayGetValueAtIndex(people, tmpIndex);
		NSString *recordID =nil;
		recordID = [NSString stringWithFormat:@"%i", ABRecordGetRecordID(aRecord)];
		NSString *gid, *homeMail, *orgemail, *mobileNumber, *iphoneNumber, *mainNumber, *homeNumber, *orgNumber, *otherNumber, *parseNumber, *homefaxNumber, *orgfaxNumber, *url1, *url2, *formatted;
		gid=nil;
		homeMail=nil;
		orgemail=nil;
		mobileNumber=nil;
		iphoneNumber=nil;
		mainNumber=nil;
		homeNumber=nil;
		orgNumber=nil;
		otherNumber=nil;
		parseNumber=nil;
		homefaxNumber=nil;
		orgfaxNumber=nil;
		url1=nil;
		url2=nil;
		formatted=nil;
// sochae 2010.12.29 - cLang		NSString* note = nil;
		
		
	//	NSString *yahoo, *jabber, *msn, *icq, *aim, *usernamekey;
	//	NSDate *birthday;
	//	NSString* nickname=nil;
	//	NSString* organization=nil;
		
		
		
		NSString* firstname = [(NSString *)ABRecordCopyValue(aRecord,kABPersonFirstNameProperty) autorelease];
		NSString* lastname = [(NSString *)ABRecordCopyValue(aRecord,kABPersonLastNameProperty) autorelease];
		formatted = [NSString stringWithFormat:@"%@%@",lastname?lastname:@"",firstname?firstname:@""];
		
		
		NSArray* lEmailArray = [self arrayForMultiValue:aRecord propertyIDOfArray:kABPersonEmailProperty];
		if(lEmailArray != nil){
			// Generic labels // kABWorkLabel, kABHomeLabel, kABOtherLabel
			for(NSDictionary* item in lEmailArray) {
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABHomeLabel])
					homeMail = [item valueForKey:@"value"];
				/*
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABWorkLabel])
					orgemail = [item valueForKey:@"value"];
				 */
			}
		}
		NSArray* lPhoneArray = [self arrayForMultiValue:aRecord propertyIDOfArray:kABPersonPhoneProperty];
		if(lPhoneArray != nil) {
			for(NSDictionary* item in lPhoneArray) {
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneMobileLabel]){  //mobilephone
					mobileNumber = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
					mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				}
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneIPhoneLabel]){  //iphone
					iphoneNumber = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
					iphoneNumber = [iphoneNumber stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				}
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneMainLabel]){		//mainphone
					mainNumber = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
					mainNumber = [mainNumber stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				}
				/*
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABHomeLabel]){				//homephone
					homeNumber = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
					homeNumber = [homeNumber stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				}
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABWorkLabel]){				//orgphone
					orgNumber = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
					orgNumber = [orgNumber stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				}
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABOtherLabel]){				//otherphone
					otherNumber = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
					otherNumber = [otherNumber stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				}
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhonePagerLabel]){  //phonepaser
					parseNumber = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
					parseNumber= [parseNumber stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				}
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneHomeFAXLabel]){ //homefax
					homefaxNumber = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
					homefaxNumber = [homefaxNumber stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				}
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneWorkFAXLabel]){ //orgfax
					orgfaxNumber = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
					orgfaxNumber = [orgfaxNumber stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				}
				 */
			}
			
		}
		
		/*
			NSArray* lUrlArray = [self arrayForMultiValue:aRecord propertyIDOfArray:kABPersonURLProperty];
		if(lUrlArray != nil) {
			for(NSDictionary* item in lUrlArray) {
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABHomeLabel])
					url2 = [item valueForKey:@"value"];
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonHomePageLabel])
					url1 = [item valueForKey:@"value"];
			}
		}
		
		
		
		
		if (ABPersonHasImageData(aRecord)) {
			CFDataRef imageData = ABPersonCopyImageData(aRecord);
			CFRelease(imageData);
		}
		*/
		
		
		
	
		if(formatted == NULL)
			formatted=@"";
		/*
		if(nickname == NULL)
			nickname=@"";
		 
		if(organization==NULL)
			organization=@"";
		 */
		if(homeMail==NULL)
			homeMail=@"";
		/*
		if(orgemail==NULL)
			orgemail=@"";
*/
		 if(mobileNumber==NULL)
			mobileNumber=@"";
		if(iphoneNumber==NULL)
			iphoneNumber=@"";
		/*
		if(homeNumber==NULL)
			homeNumber=@"";
		if(orgNumber==NULL)
			orgNumber=@"";
		*/
		if(mainNumber==NULL)
			mainNumber=@"";
		/*
		if(homefaxNumber==NULL)
			homefaxNumber=@"";
		if(orgfaxNumber==NULL)
			orgfaxNumber=@"";
		if(parseNumber==NULL)
			parseNumber=@"";
		if(otherNumber==NULL)
			otherNumber=@"";
		if(url1==NULL)
			url1=@"";
		if(url2==NULL)
			url2=@"";
		if(note==NULL)
			note=@"";
*/
		// sochae - quotation mark 
		NSString *name = [NSString stringWithFormat:@"%@", formatted];
		name = [name stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
		
		
		// sochae 2010.12.16 - memory leak
//		NSString *cDate, *mDate =nil;
//		cDate =  [NSString stringWithFormat:@"%@",(NSString *)ABRecordCopyValue(aRecord,kABPersonCreationDateProperty)];
//		mDate =  [NSString stringWithFormat:@"%@",(NSString *)ABRecordCopyValue(aRecord,kABPersonModificationDateProperty)];
		NSString* cDate = [(NSString *)ABRecordCopyValue(aRecord, kABPersonCreationDateProperty) autorelease];
		NSString* mDate = [(NSString *)ABRecordCopyValue(aRecord, kABPersonModificationDateProperty) autorelease];
		// ~sochae
		
		//DebugLog(@"name =  %@ cDate = %@, mDate = %@", name, cDate, mDate);
		
		
		
		homeMail = [homeMail stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
		
		if ([name length] == 0) {
		//	DebugLog(@"이름이 없으면 걍 통과");
			name = @"";
		//	continue;
			
		}
		
	//	DebugLog(@"formatted : (%@ -> %@)", formatted, name);
		// ~sochae
		
		
		
		//레코드아이디, 이름, 전화번호, 이메일 최소한의 데이터만 입력하자.. 201011.11.26
		/*
		NSString *insertQuery = [NSString stringWithFormat:@"insert into _TbackUserInfo\n" 
		"(RECORDID,\n"
		"FORMATTED,\n"
		"NICKNAME,\n"
		"ORGNAME,\n"
		"HOMEEMAILADDRESS,\n"
		"ORGEMAILADDRESS,\n"
		"MOBILEPHONENUMBER,\n"
		"IPHONENUMBER,\n"
		"HOMEPHONENUMBER,\n"
		"ORGPHONENUMBER,\n"
		"MAINPHONENUMBER,\n"
		"HOMEFAXPHONENUMBER,\n"
		"ORGFAXPHONENUMBER,\n"
		"PARSERNUMBER,\n" 
		"OTHERPHONENUMBER,\n"
		"GID,\n"
		"URL1,\n"
		"URL2,\n"
		"NOTE)\n"
		"values(\n"
		"'%@','%@','%@','%@','%@','%@',\n"
		"'%@','%@','%@','%@',\n"
		"'%@','%@','%@','%@', '%@',\n"
		"'%@','%@','%@','%@')",recordID, name, nickname, organization, homeMail, orgemail,
								 mobileNumber, iphoneNumber, homeNumber, orgNumber,
								 mainNumber, homefaxNumber, orgfaxNumber, parseNumber,
								 otherNumber, gid, url1, url2, note];
		
		*/
		/*
		NSString *insertQuery = [NSString stringWithFormat:@"insert into _TbackUserInfo\n" 
								 "(RECORDID,\n"
								 "FORMATTED,\n"
								 "HOMEEMAILADDRESS,\n"
								 "MOBILEPHONENUMBER,\n"
								 "IPHONENUMBER,\n"
								 "mDate,\n"
								 "cDate,\n"
								 "MAINPHONENUMBER)\n"
								 "values(\n"
								 "'%@',\n"
								 "'%@','%@','%@','%@',\n"
								 "'%@','%@','%@')",
								 recordID, name, homeMail,
								 mobileNumber, iphoneNumber, cDate, mDate,
								 mainNumber];
		
		DebugLog(@"백업 인서트 쿼리 %@", insertQuery);
		
		
		[backUserInfo findWithSql:insertQuery];
		
		*/
		
		
		
		
		
		[DataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:recordID,@"RECORDID",
							  name,@"FORMATTED",
							  homeMail,@"HOMEEMAILADDRESS",
							  mobileNumber,@"MOBILEPHONENUMBER",
							  iphoneNumber,@"IPHONENUMBER",
							  cDate,@"cDate",
							  mDate,@"mDate",
							  mainNumber,@"MAINPHONENUMBER", nil
							  ]] ;
		 
		 
		 
	//	DebugLog(@"self index = %d", i);
		
		 if([keyDic objectForKey:[[DataArray objectAtIndex:i] objectForKey:@"FORMATTED"]])
		 {
			 //만약에 기존 키딕셔너리에 똑같은 이름이 존재하면
			 //기존 배열 얻어온다..
			 valueArray = [keyDic objectForKey:[[DataArray objectAtIndex:i] objectForKey:@"FORMATTED"]];
			 //		DebugLog(@"기존 사용자 카운트 %d 이름 %@", [valueArray count], [[DataArray objectAtIndex:i] objectForKey:@"name"]);
			
			 //지금 값을 넣어준다.
			 [valueArray addObject:[NSString stringWithFormat:@"%d", i]];
			 [keyDic setObject:valueArray forKey:[[DataArray objectAtIndex:i] objectForKey:@"FORMATTED"]];
			 valueArray = nil; //2010.12.15
		 }
		else {
			//같은 이름이 존재 하지 않으면..
			valueArray = [[NSMutableArray alloc] init];
			//지금 값을 넣어준다.
			[valueArray addObject:[NSString stringWithFormat:@"%d", i]];
			[keyDic setObject:valueArray forKey:[[DataArray objectAtIndex:i] objectForKey:@"FORMATTED"]];
			[valueArray release]; //release 2010.12.15
			valueArray = nil;//nil 2010.12.15
		
		}

		
		
		
		
		
		
		
		
		
		///레코드 딕셔너리에다가는 데이터배열의 인덱스 값만 저장하면된다..
		
		
		
		[recordKeyDic setObject:[NSString stringWithFormat:@"%d",i] forKey:[[DataArray objectAtIndex:i] objectForKey:@"RECORDID"]];
		
		
		
		
		
		
		
		
		
		
// sochae 대신 timer 별도 처리
//		percent =  ((float)i/(float)personCount)*100;
//		[NSThread detachNewThreadSelector:@selector(showImg) toTarget:self withObject:nil];
// ~sochae
		
		
		
		
		
	//arecord release
		CFRelease(aRecord);
		
	
	}
	
 	CFRelease(people);
//	CFRelease(groups);
//release 2010.12.21

	[DataArray addObject:keyDic];
	DebugLog(@"===== (iPhone -> USay memory) 주소록백업 완료 =====>");
	
	return DataArray;



}



-(void)saveSyncData
{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	NSLocale *locale = [NSLocale currentLocale];
	[formatter setLocale:locale];
	[formatter setDateFormat:@"yyyyMMddHHmmss"];
	NSDate *today = [NSDate date];
	NSString *lastSyncDate = [[NSString alloc] initWithFormat:@"%@",[formatter stringFromDate:today]];
	DebugLog(@"저장한다. %@", lastSyncDate);
	[[NSUserDefaults standardUserDefaults] setObject:lastSyncDate forKey:@"lastOemSync"];
	[[NSUserDefaults standardUserDefaults] setObject:lastSyncDate forKey:@"lastSyncDate"];
	
	
	[formatter release];
	[lastSyncDate release];
}


-(void)completeWebtoMobile:(NSTimer *)aTimer
{
	
	
	NSLog(@"웹과 동기화 완료");
	[self stopTimer];
	
	NSLog(@"flag = %d", flag2);
	
	
	//웹->모바일
	if(flag2 == 2)
	{
	sendButton2.frame =CGRectMake(119, 105+(82/2), 83, 73);
	[sendButton2 setImage:[UIImage imageNamed:@"7_btn_complete_1.png"] forState:UIControlStateDisabled];
	sendButton2.enabled=NO;
	}
	else {
		sendButton2.frame =CGRectMake(119, 105+(82/2), 83, 73);
		[sendButton2 setImage:[UIImage imageNamed:@"7_btn_complete_2.png"] forState:UIControlStateDisabled];
		sendButton2.enabled=NO;
		
	}

	sendButton.hidden=YES;
	
	
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadAddressData" object:nil];
	webjoinViewController *alreadyJoinView = [[webjoinViewController alloc] init];
	alreadyJoinView.hidesBottomBarWhenPushed=YES;
	[self.navigationController pushViewController:alreadyJoinView animated:YES];
	[alreadyJoinView release];
	
}



-(void)showImg
{
	NSAutoreleasePool *pool =[[NSAutoreleasePool alloc] init];
	
	if(percent <=10.0)
	{
//		DebugLog(@"percent 10");
		if(flag == 1)
		{
			
			if(loadingFlag == YES)
			{
			}
			else 
				[sendButton setImage:[UIImage imageNamed:@"7_sending_1_1.png"] forState:UIControlStateDisabled];
		}
		else if(flag == 0) {
//			[sendButton setImage:[UIImage imageNamed:@"7_sending_2_1.PNG"] forState:UIControlStateDisabled];
		}
		else {
			[sendButton2 setImage:[UIImage imageNamed:@"7_sending_3_1.png"] forState:UIControlStateDisabled];
		}
	}
	else if(percent <=20.0)
	{
//		DebugLog(@"percent 20");
		if(flag == 1)
		{
			if(loadingFlag == YES)
			{
			}
			else
			[sendButton setImage:[UIImage imageNamed:@"7_sending_1_2.png"] forState:UIControlStateDisabled];
		}
		else if(flag == 0) {
//			[sendButton setImage:[UIImage imageNamed:@"7_sending_2_2.PNG"] forState:UIControlStateDisabled];
		}
		else {
			[sendButton2 setImage:[UIImage imageNamed:@"7_sending_3_2.png"] forState:UIControlStateDisabled];
		}
	}
	else if(percent <=30.0)
	{
//		DebugLog(@"percent 30");
		if(flag == 1)
		{
			if(loadingFlag == YES)
			{
			}
			else
			[sendButton setImage:[UIImage imageNamed:@"7_sending_1_3.png"] forState:UIControlStateDisabled];
		}
		else if(flag == 0) {
//			[sendButton setImage:[UIImage imageNamed:@"7_sending_2_3.PNG"] forState:UIControlStateDisabled];
		}
		else {
			[sendButton2 setImage:[UIImage imageNamed:@"7_sending_3_3.png"] forState:UIControlStateDisabled];
		}
		
	}
	else if(percent <=40.0)
	{
//		DebugLog(@"percent 40");
		if(flag == 1)
		{
			if(loadingFlag == YES)
			{
			}
			else
			[sendButton setImage:[UIImage imageNamed:@"7_sending_1_4.png"] forState:UIControlStateDisabled];
		}
		else if(flag == 0) {
//			[sendButton setImage:[UIImage imageNamed:@"7_sending_2_4.PNG"] forState:UIControlStateDisabled];
		}
		else {
			[sendButton2 setImage:[UIImage imageNamed:@"7_sending_3_4.png"] forState:UIControlStateDisabled];
		}
	}
	else if(percent <=50.0)
	{
//		DebugLog(@"percent 50");
		if(flag == 1)
		{
			if(loadingFlag == YES)
			{
			}
			else
			[sendButton setImage:[UIImage imageNamed:@"7_sending_1_5.png"] forState:UIControlStateDisabled];
		}
		else if(flag == 0) {
//			[sendButton setImage:[UIImage imageNamed:@"7_sending_2_5.PNG"] forState:UIControlStateDisabled];
		}
		else {
			[sendButton2 setImage:[UIImage imageNamed:@"7_sending_3_5.png"] forState:UIControlStateDisabled];
		}	
	}
	else if(percent <=60.0)
	{
		if(flag == 1)
		{
			if(loadingFlag == YES)
			{
			}
			else
			[sendButton setImage:[UIImage imageNamed:@"7_sending_1_6.png"] forState:UIControlStateDisabled];
		}
		else if(flag == 0) {
//			[sendButton setImage:[UIImage imageNamed:@"7_sending_2_6.PNG"] forState:UIControlStateDisabled];
		}
		else {
			[sendButton2 setImage:[UIImage imageNamed:@"7_sending_3_6.png"] forState:UIControlStateDisabled];
		}
		
//		DebugLog(@"percent 60");
	}
	else if(percent <=70.0)
	{
		if(flag == 1)
		{
			if(loadingFlag == YES)
			{
			}
			else
			[sendButton setImage:[UIImage imageNamed:@"7_sending_1_7.png"] forState:UIControlStateDisabled];
		}
		else if(flag == 0) {
//			[sendButton setImage:[UIImage imageNamed:@"7_sending_2_7.PNG"] forState:UIControlStateDisabled];
		}
		else {
			[sendButton2 setImage:[UIImage imageNamed:@"7_sending_3_7.png"] forState:UIControlStateDisabled];
		}
	}
	else if(percent <=80.0)
	{
//		DebugLog(@"percent 80");
		if(flag == 1)
		{
			if(loadingFlag == YES)
			{
			}
			else
			[sendButton setImage:[UIImage imageNamed:@"7_sending_1_8.png"] forState:UIControlStateDisabled];
		}
		else if(flag == 0) {
//			[sendButton setImage:[UIImage imageNamed:@"7_sending_2_8.PNG"] forState:UIControlStateDisabled];
		}
		else {
			[sendButton2 setImage:[UIImage imageNamed:@"7_sending_3_8.png"] forState:UIControlStateDisabled];
		}
		
		
	}
	else if(percent <=90.0)
	{
//		DebugLog(@"percent 90");
		if(flag == 1)
		{
			if(loadingFlag == YES)
			{
			}
			else
			[sendButton setImage:[UIImage imageNamed:@"7_sending_1_9.png"] forState:UIControlStateDisabled];
		}
		else if(flag == 0) {
//			[sendButton setImage:[UIImage imageNamed:@"7_sending_2_9.PNG"] forState:UIControlStateDisabled];
		}
		else {
			[sendButton2 setImage:[UIImage imageNamed:@"7_sending_3_9.png"] forState:UIControlStateDisabled];
		}
		
		
	}
	else if(percent <=100.0)
	{
		DebugLog(@"percent 100");
		if(flag == 1)
		{
			if(loadingFlag == YES)
			{
			}
			else
			[sendButton setImage:[UIImage imageNamed:@"7_sending_1_10.png"] forState:UIControlStateDisabled];
		}
		else if(flag == 0) {
//			[sendButton setImage:[UIImage imageNamed:@"7_sending_2_10.PNG"] forState:UIControlStateDisabled];
		}
		else {
			
			
			
			[sendButton2 setImage:[UIImage imageNamed:@"7_sending_3_10.png"] forState:UIControlStateDisabled];
			explainLabel.textColor=ColorFromRGB(0x39c9dd);
			explainLabel.text=@"동기화를 완료 하였습니다.";
			
			leftButton.enabled=YES;
			sendButton.enabled=YES;
			UILabel *cntLabel = (UILabel*)[self.view viewWithTag:USAYCNT];
			NSArray *totalArray =[UserInfo findAll];
			cntLabel.text =[NSString stringWithFormat:@"%d건", [totalArray count]];
			//sendButton2.enabled=YES;
		}
		
		
	}
	
	// 내보내기 개수 표시 
	curCount.text = [NSString stringWithFormat:@"총%i건", tot];
	curCount2.text = [NSString stringWithFormat:@"%i", cur];
	

	
	[pool release];
}

-(NSArray*)getList
{
	
	NSMutableArray *addressArray =[[[NSMutableArray alloc] init] autorelease];
	
	// 주소록 객체 생성.
	ABAddressBookRef addressBook = ABAddressBookCreate();
	
	// 저장된 (그룹/개인)목록 복사해서 가져오기.
	CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
	CFArrayRef groups = ABAddressBookCopyArrayOfAllGroups(addressBook);
	
	CFIndex personCount = ABAddressBookGetPersonCount(addressBook);
	CFIndex groupCount = ABAddressBookGetGroupCount(addressBook);
	
	
	for(CFIndex i = 0; i<personCount; i++)
	{
		// 해당 row(g)의 Record(개인) 정보 가져오기.
		ABRecordRef aRecord = CFArrayGetValueAtIndex(people, i);
		NSString *recordID =nil;
		recordID = [NSString stringWithFormat:@"%i", ABRecordGetRecordID(aRecord)];
		NSString *gid, *homeMail, *orgemail, *mobileNumber, *iphoneNumber, *mainNumber, *homeNumber, *orgNumber, *otherNumber, *parseNumber, *homefaxNumber, *orgfaxNumber, *url1, *url2, *formatted;
		gid=nil;
		homeMail=nil;
		orgemail=nil;
		mobileNumber=nil;
		iphoneNumber=nil;
		mainNumber=nil;
		homeNumber=nil;
		orgNumber=nil;
		otherNumber=nil;
		parseNumber=nil;
		homefaxNumber=nil;
		orgfaxNumber=nil;
		url1=nil;
		url2=nil;
		formatted=nil;
		
		NSString *mDate, *cDate;
		mDate = nil;
		cDate = nil;
		
		//사용자의 그룹아이디를 구해서 배열에 저장
		for(CFIndex g = 0;g<groupCount;g++){
			ABRecordRef gRecord = CFArrayGetValueAtIndex(groups, g);
			NSArray* groupContacts = (NSArray*)ABGroupCopyArrayOfAllMembers(gRecord);
			
			//사용자의 그룹아이디를 찾는다.
			if([groupContacts count] > 0){
				for(id person in groupContacts){
					
					if((NSUInteger) ABRecordGetRecordID(person) == (NSUInteger)ABRecordGetRecordID(aRecord))
						gid = [NSString stringWithFormat:@"%i", ABRecordGetRecordID(gRecord)];
				}				
			}			
			[groupContacts release];
		}
		
		
		NSString* firstname = [(NSString *)ABRecordCopyValue(aRecord,kABPersonFirstNameProperty) autorelease];
		NSString* lastname = [(NSString *)ABRecordCopyValue(aRecord,kABPersonLastNameProperty) autorelease];
		formatted = [NSString stringWithFormat:@"%@%@",lastname?lastname:@"",firstname?firstname:@""];
		
		NSDate *birthday = (NSDate *)ABRecordCopyValue(aRecord,kABPersonBirthdayProperty);
		
		
		/*
		cDate =(NSString *)ABRecordCopyValue(aRecord,kABPersonCreationDateProperty);
		mDate =(NSString *)ABRecordCopyValue(aRecord,kABPersonModificationDateProperty);
		*/
		
		
		cDate =  [[NSString stringWithFormat:@"%@",(NSString *)ABRecordCopyValue(aRecord,kABPersonCreationDateProperty)] autorelease];
		mDate =  [[NSString stringWithFormat:@"%@",(NSString *)ABRecordCopyValue(aRecord,kABPersonModificationDateProperty)] autorelease];
		
		
		
		
		//formatted =	[firstname stringByAppendingFormat:"%@", lastname];
		
		NSString* nickname=nil;
		nickname = [(NSString *)ABRecordCopyValue(aRecord,kABPersonNicknameProperty) autorelease];
		NSString* organization = nil;
		organization = [(NSString *)ABRecordCopyValue(aRecord,kABPersonOrganizationProperty) autorelease];
		NSString* note = nil;
		note = [(NSString *)ABRecordCopyValue(aRecord,kABPersonNoteProperty) autorelease];
		NSArray* lEmailArray = [self arrayForMultiValue:aRecord propertyIDOfArray:kABPersonEmailProperty];
		if(lEmailArray != nil){
			// Generic labels // kABWorkLabel, kABHomeLabel, kABOtherLabel
			for(NSDictionary* item in lEmailArray) {
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABHomeLabel])
					homeMail = [item valueForKey:@"value"];
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABWorkLabel])
					orgemail = [item valueForKey:@"value"];
			}
		}
		NSArray* lPhoneArray = [self arrayForMultiValue:aRecord propertyIDOfArray:kABPersonPhoneProperty];
		if(lPhoneArray != nil) {
			for(NSDictionary* item in lPhoneArray) {
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneMobileLabel]){  //mobilephone
					mobileNumber = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
					mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				}
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneIPhoneLabel]){  //iphone
					iphoneNumber = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
					iphoneNumber = [iphoneNumber stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				}
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneMainLabel]){		//mainphone
					mainNumber = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
					mainNumber = [mainNumber stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				}
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABHomeLabel]){				//homephone
					homeNumber = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
					homeNumber = [homeNumber stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				}
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABWorkLabel]){				//orgphone
					orgNumber = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
					orgNumber = [orgNumber stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				}
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABOtherLabel]){				//otherphone
					otherNumber = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
					otherNumber = [otherNumber stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				}
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhonePagerLabel]){  //phonepaser
					parseNumber = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
					parseNumber= [parseNumber stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				}
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneHomeFAXLabel]){ //homefax
					homefaxNumber = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
					homefaxNumber = [homefaxNumber stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				}
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneWorkFAXLabel]){ //orgfax
					orgfaxNumber = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
					orgfaxNumber = [orgfaxNumber stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				}
			}
			
		}
		NSArray* lUrlArray = [self arrayForMultiValue:aRecord propertyIDOfArray:kABPersonURLProperty];
		if(lUrlArray != nil) {
			for(NSDictionary* item in lUrlArray) {
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABHomeLabel])
					url2 = [item valueForKey:@"value"];
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonHomePageLabel])
					url1 = [item valueForKey:@"value"];
			}
		}
		
		
		
		
		
		
		
		if(formatted == NULL)
			formatted=@"";
		if(nickname == NULL)
			nickname=@"";
		if(organization==NULL)
			organization=@"";
		if(homeMail==NULL)
			homeMail=@"";
		if(orgemail==NULL)
			orgemail=@"";
		if(mobileNumber==NULL)
			mobileNumber=@"";
		if(iphoneNumber==NULL)
			iphoneNumber=@"";
		if(homeNumber==NULL)
			homeNumber=@"";
		if(orgNumber==NULL)
			orgNumber=@"";
		
		if(mainNumber==NULL)
			mainNumber=@"";
		if(homefaxNumber==NULL)
			homefaxNumber=@"";
		if(orgfaxNumber==NULL)
			orgfaxNumber=@"";
		if(parseNumber==NULL)
			parseNumber=@"";
		if(otherNumber==NULL)
			otherNumber=@"";
		if(url1==NULL)
			url1=@"";
		if(url2==NULL)
			url2=@"";
		if(note==NULL)
			note=@"";
		
		// sochae - quotation mark 
		/*NSString *name = [NSString stringWithFormat:@"%@", formatted];
		name = [name stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
		DebugLog(@"formatted : (%@ -> %@)", formatted, name);
		*/// ~sochae
		
		
		[addressArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:
								 recordID,@"recordID",
								 formatted,@"formatted",
								 nickname,@"nickname",
								 organization,@"organization",
								 homeMail,@"homeMail",
								 orgemail,@"orgemail",
								 mobileNumber,@"mobileNumber",
								 iphoneNumber,@"iphoneNumber",
								 homeNumber,@"homeNumber",
								 orgNumber,@"orgNumber",
								 mainNumber,@"mainNumber",
								 homefaxNumber,@"homefaxNumber",
								 orgfaxNumber,@"orgfaxNumber",
								 parseNumber,@"parseNumber",
								 otherNumber,@"otherNumber",
								 url1,@"url1",
								 url2,@"url2",
								 note,@"note",
								 gid,@"gid",
								 mDate,@"mDate",
								 cDate,@"cDate",
								 birthday,@"birthday",
								 nil]];
		
		
		
		
	}
	CFRelease(people);
	CFRelease(groups);
	CFRelease(addressBook);	
	
	
	DebugLog(@"addressArray cnt %d", [addressArray count]);
	
	return addressArray;
	
	
	
}






#pragma mark 트리메모리 할당


#pragma mark 트리구조로 만들기.







#pragma mark 단말 업데이트 메소드.
-(void)updateOEM:(UserInfo*)userInfo withRecord:(NSString*)recordid
{
	
	
		
	
	ABAddressBookRef iPhoneAddressBook = ABAddressBookCreate();
	CFErrorRef error = NULL;
	ABRecordID recID	= (ABRecordID)[recordid intValue];
	ABRecordRef newPerson =	ABAddressBookGetPersonWithRecordID(iPhoneAddressBook, recID);
	CFIndex nGroup = ABAddressBookGetGroupCount(iPhoneAddressBook);
	CFArrayRef allGroup = ABAddressBookCopyArrayOfAllGroups(iPhoneAddressBook);
	NSString *groupString;
	ABRecordRef sameGroupRef;
	//유세이 디비에서 그룹 타이틀을 가져온다ㅏ
	NSString *tmpGroupTitle = [NSString stringWithFormat:@"select GROUPTITLE from _TGroupInfo where id=%@ limit 0, 1", userInfo.GID];
	NSArray *groupArray = [GroupInfo findWithSql:tmpGroupTitle];
	GroupInfo* group = nil;
	BOOL	isFindGroup = NO;	// sochae 2010.12.30 - sameGroupRef를 할당 받은지 여부 (exchange 연동)
	
	NSLog(@"groupArray = %@", groupArray);
	
	//예외 처리..
	if([groupArray count] == 0)
	{
		NSLog(@"들어오냐..");
		/*
		 CFRelease(sameGroupRef); //2010.12.16 release
		 CFRelease(newPerson); //2010.12.21 release
		 */
		CFRelease(iPhoneAddressBook);
		
		return;
	}
	
	
	
	if([groupArray objectAtIndex:0])
		group = [groupArray objectAtIndex:0];
	
	
	NSLog(@"group %@", group);
	
	groupArray = nil;
	groupString = group.GROUPTITLE;

	
	BOOL createGroup = NO;
//	NSString *GID;
	//유세이 그룹타이틀이 단말 그룹 찾을때 까지 루프..
	for(int i=0; i< nGroup; i++)
	{
		//그룹 정보
		ABRecordRef ref = CFArrayGetValueAtIndex(allGroup, i);
		
		// 110124 analyze
		CFStringRef groupTitleRef = ABRecordCopyValue(ref, kABGroupNameProperty);
		
		NSString *groupTitle = (NSString*)groupTitleRef;
		
		//단말 그룹이랑 같은 그룹명이 발견되면..
		DebugLog(@"groupTitle %@", groupTitle);
		if([groupTitle isEqualToString:groupString])
		{
			DebugLog(@"그룹 찾았다. %@", groupTitle);
//			ABGID = ABRecordGetRecordID(ref);
		//	GID = [NSString stringWithFormat:@"%i", ABRecordGetRecordID(ref)];
		//	DebugLog(@"GID = %@", GID);
			sameGroupRef = CFArrayGetValueAtIndex(allGroup, i);
			isFindGroup	= YES;	// sochae 2010.12.30
			createGroup = NO;
			
			// 110124 analyze
			CFRelease(groupTitleRef);

			break;
		}
		else {
			createGroup = YES;
		}
		// 110124 analyze
		CFRelease(groupTitleRef);
	}
//	CFRelease(allGroup); //release 2010.12.15
	
	
	
	
		//유세이 디비에서 포맷티드이름, 닉네임이 있으면 퍼스트네임으로 입력
		if([userInfo.FORMATTED length] >0)
		{
			ABRecordRemoveValue(newPerson, kABPersonFirstNameProperty, &error);
			ABRecordRemoveValue(newPerson, kABPersonLastNameProperty, &error);
			ABRecordSetValue(newPerson, kABPersonFirstNameProperty, userInfo.FORMATTED, &error);
		//임시 주석	ABAddressBookSave(iPhoneAddressBook, &error);
			if([userInfo.NICKNAME length]>0)
			{
				ABRecordSetValue(newPerson, kABPersonNicknameProperty, userInfo.NICKNAME, &error);
		//임시로 주석		ABAddressBookSave(iPhoneAddressBook, &error);
			}
			
			
			NSLog(@"userInfo.formatted = %@", userInfo.FORMATTED);
			
			
			
		}
		else if([userInfo.NICKNAME length] >0)
		{
			ABRecordSetValue(newPerson, kABPersonFirstNameProperty, userInfo.NICKNAME, &error);
		//임시 주석 	ABAddressBookSave(iPhoneAddressBook, &error);
			ABRecordSetValue(newPerson, kABPersonNicknameProperty, userInfo.NICKNAME, &error);
		//임시 주석	ABAddressBookSave(iPhoneAddressBook, &error);
			}
		//회사 
		if([userInfo.ORGNAME length] >0)
		{
			ABRecordSetValue(newPerson, kABPersonOrganizationProperty, userInfo.ORGNAME, &error);
		//임시주석		ABAddressBookSave(iPhoneAddressBook, &error);
		}
		
	/*
		if([userInfo.HOMEEMAILADDRESS length] >0)
		{
			DebugLog(@"이메일 %@", userInfo.HOMEEMAILADDRESS);
			ABMultiValueRef email = ABMultiValueCreateMutable(kABMultiStringPropertyType);
			if([userInfo.ORGEMAILADDRESS length] > 0)
			{
				DebugLog(@"직장이메일 %@", userInfo.ORGEMAILADDRESS);
				ABMultiValueAddValueAndLabel(email, userInfo.ORGEMAILADDRESS, kABWorkLabel, NULL);	
			}
			ABMultiValueAddValueAndLabel(email, userInfo.HOMEEMAILADDRESS, kABHomeLabel, NULL);	
			ABRecordSetValue(newPerson, kABPersonEmailProperty, email, &error);
			ABAddressBookSave(iPhoneAddressBook, &error);
			CFRelease(email); //release 2010.12.15
		}
	*/	
		if([userInfo.NOTE length] >0)
		{
			ABRecordSetValue(newPerson, kABPersonNoteProperty, userInfo.NOTE, &error);
	//임시주석		ABAddressBookSave(iPhoneAddressBook, &error);
		}
	
	
	NSMutableArray *lMOBILEPHONENUMBER, *lIPHONENUMBER, *lMAINPHONENUMBER, *lHOMEFAXPHONENUMBER, *lORGFAXPHONENUMBER, *lORGPHONENUMBER, *lHOMEPHONENUMBER, *lOTHERPHONENUMBER, *lPARSERNUMBER;
	/*
	NSString *URL1, *URL2;
	URL1 = nil, URL2 = nil;
	*/
	
	
	
	
	NSMutableArray *URL1;
	//, *URL2;
	URL1 = nil;
	//URL2 = nil;
	
	URL1 = [[NSMutableArray alloc] init];
	//URL2 = [[NSMutableArray alloc] init];
	
	
	
	
	
	NSString *MOBILEPHONENUMBER, *IPHONENUMBER, *MAINPHONENUMBER, *HOMEFAXPHONENUMBER, *ORGFAXPHONENUMBER, *ORGPHONENUMBER, *HOMEPHONENUMBER, *OTHERPHONENUMBER, *PARSERNUMBER;
	
	
	
	lMOBILEPHONENUMBER = [[NSMutableArray alloc] init];
	lIPHONENUMBER = [[NSMutableArray alloc] init];
	lMAINPHONENUMBER = [[NSMutableArray alloc] init];
	lHOMEFAXPHONENUMBER = [[NSMutableArray alloc] init];
	lORGFAXPHONENUMBER = [[NSMutableArray alloc] init];
	lORGPHONENUMBER = [[NSMutableArray alloc] init];
	lHOMEPHONENUMBER = [[NSMutableArray alloc] init];
	lOTHERPHONENUMBER = [[NSMutableArray alloc] init];
	lPARSERNUMBER = [[NSMutableArray alloc] init];
	
	
	MOBILEPHONENUMBER = nil, IPHONENUMBER = nil, MAINPHONENUMBER = nil, HOMEFAXPHONENUMBER = nil, ORGFAXPHONENUMBER = nil, ORGPHONENUMBER = nil, HOMEPHONENUMBER = nil;
	OTHERPHONENUMBER = nil, PARSERNUMBER = nil;
	
	DebugLog(@"시작5");
	
	BOOL isField1,isField2,isField3,isField4,isField5,isField6,isField7,isField8,isField9;
	
	isField1 = NO;
	isField2 = NO;
	isField3 = NO;
	isField4 = NO;
	isField5 = NO;
	isField6 = NO;
	isField7 = NO;
	isField8 = NO;
	isField9 = NO;
	
	
	
	NSArray* lPhoneArray = [self arrayForMultiValue:newPerson propertyIDOfArray:kABPersonPhoneProperty];
	
	DebugLog(@"lphoneArray = %@", lPhoneArray);
	if(lPhoneArray != nil) {
		//각 멀티필드 들의 배열을 구한다 그래서 구한 배열에서 새롭게 추가하려는 데이터가 있는지 검사해서 있으면 입력한다..
		for(NSDictionary* item in lPhoneArray) {
			if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneMobileLabel])
			{
				//모바일 이면
				
				
				
				
				MOBILEPHONENUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
				MOBILEPHONENUMBER = [MOBILEPHONENUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				
				
				DebugLog(@"lMobileNumber = %@", MOBILEPHONENUMBER);
				
				[lMOBILEPHONENUMBER addObject:MOBILEPHONENUMBER];
			}
			else if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneIPhoneLabel]){
			
				IPHONENUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
				IPHONENUMBER = [IPHONENUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				[lIPHONENUMBER addObject:IPHONENUMBER];
			}
			else if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneMainLabel]){
				MAINPHONENUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
				MAINPHONENUMBER = [MAINPHONENUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				[lMAINPHONENUMBER addObject:MAINPHONENUMBER];
			}
			else if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABHomeLabel]){
				HOMEPHONENUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
				HOMEPHONENUMBER = [HOMEPHONENUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				[lHOMEPHONENUMBER addObject:HOMEPHONENUMBER];
				
			}
			else if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABWorkLabel]){
				ORGPHONENUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
				ORGPHONENUMBER = [ORGPHONENUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				[lORGPHONENUMBER addObject:ORGPHONENUMBER];
			}
			else if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABOtherLabel]){
				OTHERPHONENUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
				OTHERPHONENUMBER = [OTHERPHONENUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				[lOTHERPHONENUMBER addObject:OTHERPHONENUMBER];
			}
			else if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhonePagerLabel]){
				
				PARSERNUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
				PARSERNUMBER = [PARSERNUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				[lPARSERNUMBER addObject:PARSERNUMBER];
				
			}
			else if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneHomeFAXLabel]){
				
				HOMEFAXPHONENUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
				HOMEFAXPHONENUMBER = [HOMEFAXPHONENUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				[lHOMEFAXPHONENUMBER addObject:HOMEFAXPHONENUMBER];
				
			}
			else if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneWorkFAXLabel]){
				ORGFAXPHONENUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
				ORGFAXPHONENUMBER = [ORGFAXPHONENUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				[lORGFAXPHONENUMBER addObject:ORGFAXPHONENUMBER];
				
			
			}
			
		}
		
		DebugLog(@"데이터 가져옴 ..");
		
		
		
		
			  //mobilephone
				if([userInfo.MOBILEPHONENUMBER length] > 0)
				{
					MOBILEPHONENUMBER = userInfo.MOBILEPHONENUMBER;
					BOOL mflag = NO;
					for(int i=0; i<[lMOBILEPHONENUMBER count]; i++)
					{
						//기존 배열에 존재하면..
						if([[lMOBILEPHONENUMBER objectAtIndex:i] isEqualToString:MOBILEPHONENUMBER])
						{
							DebugLog(@"기존 배열에 존재한다 %@", MOBILEPHONENUMBER); 
							//[lMOBILEPHONENUMBER removeObjectAtIndex:i]; //같은거니깐 배열에서 빼버린다..
							mflag = YES;
							isField1 = YES;
							[lMOBILEPHONENUMBER removeAllObjects];
							break;
						}
					}
					if(mflag == NO)
					{
						DebugLog(@"다른번호... %@", MOBILEPHONENUMBER);
						[lMOBILEPHONENUMBER removeAllObjects];
	//					[lMOBILEPHONENUMBER addObject:MOBILEPHONENUMBER];
					}
				}
				else {
					[lMOBILEPHONENUMBER removeAllObjects];
				}
			
			  //iphone
				if([userInfo.IPHONENUMBER length] > 0)
				{
					IPHONENUMBER = userInfo.IPHONENUMBER;
					BOOL mflag = NO;
					for(int i=0; i<[lIPHONENUMBER count]; i++)
					{
						//기존 배열에 존재하면..
						if([[lIPHONENUMBER objectAtIndex:i] isEqualToString:IPHONENUMBER])
						{
							isField2 = YES;
						//	[lIPHONENUMBER removeObjectAtIndex:i]; //같은거니깐 배열에서 빼버린다..
						[lIPHONENUMBER removeAllObjects];
							mflag = YES;
							break;
						}
						
					}
					if(mflag == NO)
					{
						DebugLog(@"다른번호... %@", IPHONENUMBER);
						[lIPHONENUMBER removeAllObjects];
						//	[lIPHONENUMBER addObject:IPHONENUMBER];
					}
					
				}
				else {
					[lIPHONENUMBER removeAllObjects];
					
				}
				
			
					//mainphone
				if([userInfo.MAINPHONENUMBER length] > 0)
				{
					MAINPHONENUMBER = userInfo.MAINPHONENUMBER;
					BOOL mflag = NO;
					for(int i=0; i<[lMAINPHONENUMBER count]; i++)
					{
						//기존 배열에 존재하면..
						if([[lMAINPHONENUMBER objectAtIndex:i] isEqualToString:MAINPHONENUMBER])
						{
							isField3 = YES;
						//	[lMAINPHONENUMBER removeObjectAtIndex:i]; //같은거니깐 배열에서 빼버린다..
						[lMAINPHONENUMBER removeAllObjects];
							mflag = YES;
							break;
						}
						
					}
					if(mflag == NO)
					{
						DebugLog(@"다른번호... %@", MAINPHONENUMBER);
						//			DebugLog(@"다른 번호이다 넣어도 된다(모바일). %@ %@", MOBILEPHONENUMBER, [lMOBILEPHONENUMBER objectAtIndex:i]);
					
						[lMAINPHONENUMBER removeAllObjects];
						//	[lMAINPHONENUMBER addObject:MAINPHONENUMBER];
					}
				}
				else {
					[lMAINPHONENUMBER removeAllObjects];
					
				}
			
							//homephone
				if([userInfo.HOMEPHONENUMBER length] > 0)
				{
					HOMEPHONENUMBER = userInfo.HOMEPHONENUMBER;
					BOOL mflag = NO;
					for(int i=0; i<[lHOMEPHONENUMBER count]; i++)
					{
						//기존 배열에 존재하면..
						if([[lHOMEPHONENUMBER objectAtIndex:i] isEqualToString:HOMEPHONENUMBER])
						{
							isField4 = YES;
						//	[lHOMEPHONENUMBER removeObjectAtIndex:i]; //같은거니깐 배열에서 빼버린다..
						[lHOMEPHONENUMBER removeAllObjects];
							mflag = YES;
							break;
						}
						
					}
					if(mflag == NO)
					{
						DebugLog(@"다른번호... %@", HOMEPHONENUMBER);
						//			DebugLog(@"다른 번호이다 넣어도 된다(모바일). %@ %@", MOBILEPHONENUMBER, [lMOBILEPHONENUMBER objectAtIndex:i]);
						[lHOMEPHONENUMBER removeAllObjects];
						//	[lHOMEPHONENUMBER addObject:HOMEPHONENUMBER];
					}
				}
				else {
					[lHOMEPHONENUMBER removeAllObjects];
					
				}
			
							//orgphone
				
				
				if([userInfo.ORGPHONENUMBER length] > 0)
				{
					ORGPHONENUMBER = userInfo.ORGPHONENUMBER;
					BOOL mflag = NO;
					//	int i=0;
					//모바일 배열에 같은 번호가 발견이 되면 넣지 않는다..
					
					
					
					
					for(int i=0; i<[lORGPHONENUMBER count]; i++)
					{
						//기존 배열에 존재하면..
						if([[lORGPHONENUMBER objectAtIndex:i] isEqualToString:ORGPHONENUMBER])
						{
							isField5 = YES;
					//		[lORGPHONENUMBER removeObjectAtIndex:i]; //같은거니깐 배열에서 빼버린다..
					[lORGPHONENUMBER removeAllObjects];
							mflag = YES;
							break;
						}
						
					}
					if(mflag == NO)
					{
						DebugLog(@"다른번호... %@", ORGPHONENUMBER);
						//			DebugLog(@"다른 번호이다 넣어도 된다(모바일). %@ %@", MOBILEPHONENUMBER, [lMOBILEPHONENUMBER objectAtIndex:i]);
					
						[lORGPHONENUMBER removeAllObjects];
						//	[lORGPHONENUMBER addObject:ORGPHONENUMBER];
					}
				}
				else {
					[lORGPHONENUMBER removeAllObjects];
					
				}
				
			
							//otherphone
				if([userInfo.OTHERPHONENUMBER length] > 0)
				{
					OTHERPHONENUMBER = userInfo.OTHERPHONENUMBER;
					BOOL mflag = NO;
					//	int i=0;
					//모바일 배열에 같은 번호가 발견이 되면 넣지 않는다..
					
					
					
					
					for(int i=0; i<[lOTHERPHONENUMBER count]; i++)
					{
						//기존 배열에 존재하면..
						if([[lOTHERPHONENUMBER objectAtIndex:i] isEqualToString:OTHERPHONENUMBER])
						{
							isField6 = YES;
						//	[lOTHERPHONENUMBER removeObjectAtIndex:i]; //같은거니깐 배열에서 빼버린다..
							mflag = YES;
							[lOTHERPHONENUMBER removeAllObjects];
							break;
						}
						
					}
					if(mflag == NO)
					{
						DebugLog(@"다른번호... %@", OTHERPHONENUMBER);
						//			DebugLog(@"다른 번호이다 넣어도 된다(모바일). %@ %@", MOBILEPHONENUMBER, [lMOBILEPHONENUMBER objectAtIndex:i]);
					
						[lOTHERPHONENUMBER removeAllObjects];
						
						//	[lOTHERPHONENUMBER addObject:OTHERPHONENUMBER];
					}
				}
				else {
					[lOTHERPHONENUMBER removeAllObjects];
					
				}
				
				
				
				
			
			  //phonepaser
				
				
				
				if([userInfo.PARSERNUMBER length] > 0)
				{
					PARSERNUMBER = userInfo.PARSERNUMBER;
					BOOL mflag = NO;
					//	int i=0;
					//모바일 배열에 같은 번호가 발견이 되면 넣지 않는다..
					
					
					
					
					for(int i=0; i<[lPARSERNUMBER count]; i++)
					{
						//기존 배열에 존재하면..
						if([[lPARSERNUMBER objectAtIndex:i] isEqualToString:PARSERNUMBER])
						{
							isField7 = YES;
							[lPARSERNUMBER removeAllObjects];
						//	[lPARSERNUMBER removeObjectAtIndex:i]; //같은거니깐 배열에서 빼버린다..
							mflag = YES;
							break;
						}
						
					}
					if(mflag == NO)
					{
						DebugLog(@"다른번호... %@", PARSERNUMBER);
						//			DebugLog(@"다른 번호이다 넣어도 된다(모바일). %@ %@", MOBILEPHONENUMBER, [lMOBILEPHONENUMBER objectAtIndex:i]);
					//	[lPARSERNUMBER addObject:PARSERNUMBER];
						[lPARSERNUMBER removeAllObjects];
					}
				}
				else {
					[lPARSERNUMBER removeAllObjects];
					
				}
				
				
				
			
			 //homefax
			if([userInfo.HOMEFAXPHONENUMBER length] > 0)
				{
					HOMEFAXPHONENUMBER = userInfo.HOMEFAXPHONENUMBER;
					BOOL mflag = NO;
					//		int i=0;
					//모바일 배열에 같은 번호가 발견이 되면 넣지 않는다..
					
					
					
					
					for(int i=0; i<[lHOMEFAXPHONENUMBER count]; i++)
					{
						//기존 배열에 존재하면..
						if([[lHOMEFAXPHONENUMBER objectAtIndex:i] isEqualToString:HOMEFAXPHONENUMBER])
						{
							isField8 = YES;
						//	[lHOMEFAXPHONENUMBER removeObjectAtIndex:i]; //같은거니깐 배열에서 빼버린다..
							[lHOMEFAXPHONENUMBER removeAllObjects];
							mflag = YES;
							break;
						}
						
					}
					if(mflag == NO)
					{
						DebugLog(@"다른번호... %@", HOMEFAXPHONENUMBER);
						//			DebugLog(@"다른 번호이다 넣어도 된다(모바일). %@ %@", MOBILEPHONENUMBER, [lMOBILEPHONENUMBER objectAtIndex:i]);
					
						[lHOMEFAXPHONENUMBER removeAllObjects];
						//	[lHOMEFAXPHONENUMBER addObject:HOMEFAXPHONENUMBER];
					}
				}
				else {
					[lHOMEFAXPHONENUMBER removeAllObjects];
					
				}
				
				
				
				
				
			
			 //orgfax
				
				
				if([userInfo.ORGFAXPHONENUMBER length] > 0)
				{
					ORGFAXPHONENUMBER = userInfo.ORGFAXPHONENUMBER;
					BOOL mflag = NO;
					//		int i=0;
					//모바일 배열에 같은 번호가 발견이 되면 넣지 않는다..
					
					
					
					
					for(int i=0; i<[lORGFAXPHONENUMBER count]; i++)
					{
						//기존 배열에 존재하면..
						if([[lORGFAXPHONENUMBER objectAtIndex:i] isEqualToString:ORGFAXPHONENUMBER])
						{
						//	[lORGFAXPHONENUMBER removeObjectAtIndex:i]; //같은거니깐 배열에서 빼버린다..
							isField9 = YES;
							mflag = YES;
							[lORGFAXPHONENUMBER removeAllObjects];
							break;
						}
						
					}
					
					if(mflag == NO)
					{
						DebugLog(@"다른번호... %@", ORGFAXPHONENUMBER);
						//			DebugLog(@"다른 번호이다 넣어도 된다(모바일). %@ %@", MOBILEPHONENUMBER, [lMOBILEPHONENUMBER objectAtIndex:i]);
						//[lORGFAXPHONENUMBER addObject:ORGFAXPHONENUMBER];
						
						[lORGFAXPHONENUMBER removeAllObjects];
					}
				}
				else {
					[lORGFAXPHONENUMBER removeAllObjects];
					
				}
				
				
				
			
			
			
			
			
			
		
		
		
		/*
		for(NSDictionary* item in lPhoneArray) {
			if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneMobileLabel])
			{  //mobilephone
				if([userInfo.MOBILEPHONENUMBER length] > 0)
				{
					MOBILEPHONENUMBER = userInfo.MOBILEPHONENUMBER;
					BOOL mflag = NO;
				//	int i=0;
					
					
					
					
					
					for(int i=0; i<[lMOBILEPHONENUMBER count]; i++)
					{
						//기존 배열에 존재하면..
						if([[lMOBILEPHONENUMBER objectAtIndex:i] isEqualToString:MOBILEPHONENUMBER])
						{
							DebugLog(@"기존 배열에 존재한다 %@", MOBILEPHONENUMBER); 
							[lMOBILEPHONENUMBER removeObjectAtIndex:i]; //같은거니깐 배열에서 빼버린다..
							mflag = YES;
							isField1 = YES;
							break;
						}
						
					}
					if(mflag == NO)
					{
						DebugLog(@"다른번호... %@", MOBILEPHONENUMBER);
						[lMOBILEPHONENUMBER removeAllObjects];
						//			DebugLog(@"다른 번호이다 넣어도 된다(모바일). %@ %@", MOBILEPHONENUMBER, [lMOBILEPHONENUMBER objectAtIndex:i]);
						[lMOBILEPHONENUMBER addObject:MOBILEPHONENUMBER];
					}
					
					
				}
				else {
					[lMOBILEPHONENUMBER removeAllObjects];
					
				}
			}
			else if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneIPhoneLabel]){  //iphone
				if([userInfo.IPHONENUMBER length] > 0)
				{
					IPHONENUMBER = userInfo.IPHONENUMBER;
					BOOL mflag = NO;
				//	int i=0;
					//모바일 배열에 같은 번호가 발견이 되면 넣지 않는다..
					
					
					
					
					for(int i=0; i<[lIPHONENUMBER count]; i++)
					{
						//기존 배열에 존재하면..
						if([[lIPHONENUMBER objectAtIndex:i] isEqualToString:IPHONENUMBER])
						{
									isField2 = YES;
							[lIPHONENUMBER removeObjectAtIndex:i]; //같은거니깐 배열에서 빼버린다..
							mflag = YES;
							break;
						}
						
					}
					if(mflag == NO)
					{
						DebugLog(@"다른번호... %@", IPHONENUMBER);
						//			DebugLog(@"다른 번호이다 넣어도 된다(모바일). %@ %@", MOBILEPHONENUMBER, [lMOBILEPHONENUMBER objectAtIndex:i]);
						[lIPHONENUMBER addObject:IPHONENUMBER];
					}
					
				}
				else {
					[lIPHONENUMBER removeAllObjects];
			
				}

			}
			else if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneMainLabel]){		//mainphone
			
					
				
				if([userInfo.MAINPHONENUMBER length] > 0)
				{
					MAINPHONENUMBER = userInfo.MAINPHONENUMBER;
					BOOL mflag = NO;
		//			int i=0;
					//모바일 배열에 같은 번호가 발견이 되면 넣지 않는다..
					
					
					
					
					for(int i=0; i<[lMAINPHONENUMBER count]; i++)
					{
						//기존 배열에 존재하면..
						if([[lMAINPHONENUMBER objectAtIndex:i] isEqualToString:MAINPHONENUMBER])
						{
							isField3 = YES;
							[lMAINPHONENUMBER removeObjectAtIndex:i]; //같은거니깐 배열에서 빼버린다..
							mflag = YES;
							break;
						}
						
					}
					if(mflag == NO)
					{
						DebugLog(@"다른번호... %@", MAINPHONENUMBER);
						//			DebugLog(@"다른 번호이다 넣어도 된다(모바일). %@ %@", MOBILEPHONENUMBER, [lMOBILEPHONENUMBER objectAtIndex:i]);
						[lMAINPHONENUMBER addObject:MAINPHONENUMBER];
					}
				}
				else {
					[lMAINPHONENUMBER removeAllObjects];
					
				}
				
				
				
				
				
				
			}
			else if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABHomeLabel]){				//homephone
				
				
				
					
				if([userInfo.HOMEPHONENUMBER length] > 0)
				{
					HOMEPHONENUMBER = userInfo.HOMEPHONENUMBER;
					BOOL mflag = NO;
			//		int i=0;
					//모바일 배열에 같은 번호가 발견이 되면 넣지 않는다..
					
					
					
					
					for(int i=0; i<[lHOMEPHONENUMBER count]; i++)
					{
						//기존 배열에 존재하면..
						if([[lHOMEPHONENUMBER objectAtIndex:i] isEqualToString:HOMEPHONENUMBER])
						{
							isField4 = YES;
							[lHOMEPHONENUMBER removeObjectAtIndex:i]; //같은거니깐 배열에서 빼버린다..
							mflag = YES;
							break;
						}
						
					}
					if(mflag == NO)
					{
						DebugLog(@"다른번호... %@", HOMEPHONENUMBER);
						//			DebugLog(@"다른 번호이다 넣어도 된다(모바일). %@ %@", MOBILEPHONENUMBER, [lMOBILEPHONENUMBER objectAtIndex:i]);
						[lHOMEPHONENUMBER addObject:HOMEPHONENUMBER];
					}
				}
				else {
					[lHOMEPHONENUMBER removeAllObjects];
					
				}
				
				
			}
			else if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABWorkLabel]){				//orgphone
				
				
				if([userInfo.ORGPHONENUMBER length] > 0)
				{
					ORGPHONENUMBER = userInfo.ORGPHONENUMBER;
					BOOL mflag = NO;
				//	int i=0;
					//모바일 배열에 같은 번호가 발견이 되면 넣지 않는다..
					
					
					
					
					for(int i=0; i<[lORGPHONENUMBER count]; i++)
					{
						//기존 배열에 존재하면..
						if([[lORGPHONENUMBER objectAtIndex:i] isEqualToString:ORGPHONENUMBER])
						{
							isField5 = YES;
							[lORGPHONENUMBER removeObjectAtIndex:i]; //같은거니깐 배열에서 빼버린다..
							mflag = YES;
							break;
						}
						
					}
					if(mflag == NO)
					{
						DebugLog(@"다른번호... %@", ORGPHONENUMBER);
						//			DebugLog(@"다른 번호이다 넣어도 된다(모바일). %@ %@", MOBILEPHONENUMBER, [lMOBILEPHONENUMBER objectAtIndex:i]);
						[lORGPHONENUMBER addObject:ORGPHONENUMBER];
					}
				}
				else {
					[lORGPHONENUMBER removeAllObjects];
					
				}
				
			}
			else if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABOtherLabel]){				//otherphone
				
				
				
				if([userInfo.OTHERPHONENUMBER length] > 0)
				{
					OTHERPHONENUMBER = userInfo.OTHERPHONENUMBER;
					BOOL mflag = NO;
				//	int i=0;
					//모바일 배열에 같은 번호가 발견이 되면 넣지 않는다..
					
					
					
					
					for(int i=0; i<[lOTHERPHONENUMBER count]; i++)
					{
						//기존 배열에 존재하면..
						if([[lOTHERPHONENUMBER objectAtIndex:i] isEqualToString:OTHERPHONENUMBER])
						{
							isField6 = YES;
							[lOTHERPHONENUMBER removeObjectAtIndex:i]; //같은거니깐 배열에서 빼버린다..
							mflag = YES;
							break;
						}
						
					}
					if(mflag == NO)
					{
						DebugLog(@"다른번호... %@", OTHERPHONENUMBER);
						//			DebugLog(@"다른 번호이다 넣어도 된다(모바일). %@ %@", MOBILEPHONENUMBER, [lMOBILEPHONENUMBER objectAtIndex:i]);
						[lOTHERPHONENUMBER addObject:OTHERPHONENUMBER];
					}
				}
				else {
					[lOTHERPHONENUMBER removeAllObjects];
					
				}
				

				
				
			}
			else if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhonePagerLabel]){  //phonepaser
				
				
				
				if([userInfo.PARSERNUMBER length] > 0)
				{
					PARSERNUMBER = userInfo.PARSERNUMBER;
					BOOL mflag = NO;
				//	int i=0;
					//모바일 배열에 같은 번호가 발견이 되면 넣지 않는다..
					
					
					
					
					for(int i=0; i<[lPARSERNUMBER count]; i++)
					{
						//기존 배열에 존재하면..
						if([[lPARSERNUMBER objectAtIndex:i] isEqualToString:PARSERNUMBER])
						{
							isField7 = YES;
							[lPARSERNUMBER removeObjectAtIndex:i]; //같은거니깐 배열에서 빼버린다..
							mflag = YES;
							break;
						}
						
					}
					if(mflag == NO)
					{
						DebugLog(@"다른번호... %@", PARSERNUMBER);
						//			DebugLog(@"다른 번호이다 넣어도 된다(모바일). %@ %@", MOBILEPHONENUMBER, [lMOBILEPHONENUMBER objectAtIndex:i]);
						[lPARSERNUMBER addObject:PARSERNUMBER];
					}
				}
				else {
					[lPARSERNUMBER removeAllObjects];
					
				}
			
				
				
			}
			else if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneHomeFAXLabel]){ //homefax
				
				
				
				if([userInfo.HOMEFAXPHONENUMBER length] > 0)
				{
					HOMEFAXPHONENUMBER = userInfo.HOMEFAXPHONENUMBER;
					BOOL mflag = NO;
			//		int i=0;
					//모바일 배열에 같은 번호가 발견이 되면 넣지 않는다..
					
					
					
					
					for(int i=0; i<[lHOMEFAXPHONENUMBER count]; i++)
					{
						//기존 배열에 존재하면..
						if([[lHOMEFAXPHONENUMBER objectAtIndex:i] isEqualToString:HOMEFAXPHONENUMBER])
						{
							isField8 = YES;
							[lHOMEFAXPHONENUMBER removeObjectAtIndex:i]; //같은거니깐 배열에서 빼버린다..
							mflag = YES;
							break;
						}
						
					}
					if(mflag == NO)
					{
						DebugLog(@"다른번호... %@", HOMEFAXPHONENUMBER);
						//			DebugLog(@"다른 번호이다 넣어도 된다(모바일). %@ %@", MOBILEPHONENUMBER, [lMOBILEPHONENUMBER objectAtIndex:i]);
						[lHOMEFAXPHONENUMBER addObject:HOMEFAXPHONENUMBER];
					}
				}
				else {
					[lHOMEFAXPHONENUMBER removeAllObjects];
					
				}
				

				
				
				
			}
			else if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneWorkFAXLabel]){ //orgfax
				
				
				if([userInfo.ORGFAXPHONENUMBER length] > 0)
				{
					ORGFAXPHONENUMBER = userInfo.ORGFAXPHONENUMBER;
					BOOL mflag = NO;
			//		int i=0;
					//모바일 배열에 같은 번호가 발견이 되면 넣지 않는다..
					
					
					
					
					for(int i=0; i<[lORGFAXPHONENUMBER count]; i++)
					{
						//기존 배열에 존재하면..
						if([[lORGFAXPHONENUMBER objectAtIndex:i] isEqualToString:ORGFAXPHONENUMBER])
						{
							[lORGFAXPHONENUMBER removeObjectAtIndex:i]; //같은거니깐 배열에서 빼버린다..
							isField9 = YES;
							mflag = YES;
							break;
						}
						
					}
										
					if(mflag == NO)
					{
						DebugLog(@"다른번호... %@", ORGFAXPHONENUMBER);
						//			DebugLog(@"다른 번호이다 넣어도 된다(모바일). %@ %@", MOBILEPHONENUMBER, [lMOBILEPHONENUMBER objectAtIndex:i]);
						[lORGFAXPHONENUMBER addObject:ORGFAXPHONENUMBER];
						
					}
				}
				else {
					[lORGFAXPHONENUMBER removeAllObjects];
					
				}
				
			
				
			}
		
		
		
		
		
		}
		*/
		
		//if([lMOBILEPHONENUMBER count] == 0 )
		if(isField1 == NO)
		{
			DebugLog(@"모바일 없다.1");
			
			for(int i=0; i<[lMOBILEPHONENUMBER count]; i++)
			{
				DebugLog(@"모바일 폰번호 들어와야함... %@", [lMOBILEPHONENUMBER objectAtIndex:i]);
			}
			
			
			if([userInfo.MOBILEPHONENUMBER length] > 0)
				[lMOBILEPHONENUMBER addObject:userInfo.MOBILEPHONENUMBER];
		}
		if(isField2 == NO)
		//if([lIPHONENUMBER count] == 0)
		{
		//	DebugLog(@"모바일 없다.2");
			if([userInfo.IPHONENUMBER length] > 0)
				[lIPHONENUMBER addObject:userInfo.IPHONENUMBER];
		}
		if(isField3 == NO)
		//if([lMAINPHONENUMBER count] == 0)
		{
		//	DebugLog(@"모바일 없다.3");
			if([userInfo.MAINPHONENUMBER length] > 0)
			[lMAINPHONENUMBER addObject:userInfo.MAINPHONENUMBER];
		}
		if(isField4 == NO)
		//if([lHOMEPHONENUMBER count] == 0)
		{
		//	DebugLog(@"모바일 없다.4");
			if([userInfo.HOMEPHONENUMBER length] > 0)
			[lHOMEPHONENUMBER addObject:userInfo.HOMEPHONENUMBER];
		}
		if(isField5 == NO)
		//if([lORGPHONENUMBER count] == 0)
		{
		//	DebugLog(@"모바일 없다.5");
			if([userInfo.ORGPHONENUMBER length] > 0)
			[lORGPHONENUMBER addObject:userInfo.ORGPHONENUMBER];
		}
		if(isField6 == NO)
		//if([lOTHERPHONENUMBER count] == 0)
		{
		//	DebugLog(@"모바일 없다.6");
			if([userInfo.OTHERPHONENUMBER length] > 0)
			[lOTHERPHONENUMBER addObject:userInfo.OTHERPHONENUMBER];
		}
		if(isField7 == NO)
		//if([lPARSERNUMBER count] == 0)
		{
		//	DebugLog(@"모바일 없다.7");
			if([userInfo.PARSERNUMBER length] > 0)
			[lPARSERNUMBER addObject:userInfo.PARSERNUMBER];
		}
		if(isField8 == NO)
		//if([lHOMEFAXPHONENUMBER count] == 0)
		{
		//	DebugLog(@"모바일 없다.8");
			if([userInfo.HOMEFAXPHONENUMBER length] > 0)
			[lHOMEFAXPHONENUMBER addObject:userInfo.HOMEFAXPHONENUMBER];
		}
		if(isField9 == NO)
		//if([lORGFAXPHONENUMBER count] == 0)
		{
		//	DebugLog(@"모바일 없다.9");
			if([userInfo.ORGFAXPHONENUMBER length] > 0)
			[lORGFAXPHONENUMBER addObject:userInfo.ORGFAXPHONENUMBER];
		}
		 
		
	}
			
	
	//홈페이지 멀티필드...
	ABMultiValueRef multiMail = ABRecordCopyValue(newPerson, kABPersonURLProperty);
//	NSArray *multiMailArray =  (NSArray*)ABMultiValueCopyArrayOfAllValues(multiMail);
	ABMutableMultiValueRef multiPhoneMail = ABMultiValueCreateMutableCopy(multiMail);
	CFRelease(multiMail); //release 2010.12.21
//	DebugLog(@"email = %@", multiMailArray);
	
	
	
	
	//이메일 멀티필드..
	ABMultiValueRef thePropertyEmail = ABRecordCopyValue(newPerson, kABPersonEmailProperty);
	ABMutableMultiValueRef multiEmail = ABMultiValueCreateMutableCopy(thePropertyEmail);
	
	
	
	NSMutableArray *homeMailArray =[[NSMutableArray alloc] init];
	NSMutableArray *orgMailArray = [[NSMutableArray alloc] init];
	
	
	NSArray* lUrlArray = [self arrayForMultiValue:newPerson propertyIDOfArray:kABPersonURLProperty];
	if(lUrlArray != nil) {
		for(NSDictionary* item in lUrlArray) {
			
			DebugLog(@"item =  %@", item);
			
			if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonHomePageLabel])
			{
				[URL1 addObject:[item valueForKey:@"value"]];
			//	URL1 = [item valueForKey:@"value"];
				DebugLog(@"URL1 = %@", [item valueForKey:@"value"]);
			}
		}
	}
	
	NSArray* mArray = [self arrayForMultiValue:newPerson propertyIDOfArray:kABPersonEmailProperty];
	if(mArray != nil) {
		for(NSDictionary* item in mArray) {
			DebugLog(@"MarrayItem =  %@", item);
			if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABHomeLabel])
			{
				[homeMailArray addObject:[item valueForKey:@"value"]];
				DebugLog(@"집메일.. %@", [item valueForKey:@"value"]);
			}
			if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABWorkLabel])
			{
				[orgMailArray addObject:[item valueForKey:@"value"]];
				DebugLog(@"직장메일 %@", [item valueForKey:@"value"]);
			}
		}
	}

	
	
	
	
	
	
	
	
	
	
	
			
			
			
	
	
		
		ABMultiValueRef theProperty = ABRecordCopyValue(newPerson, kABPersonPhoneProperty);
	/*
    NSArray *tmpArray =  (NSArray*)ABMultiValueCopyArrayOfAllValues(theProperty);
		DebugLog(@"tmpArray = %@", tmpArray);
	*/

	
	
	
	
	
	
	
	
	
	
	
		//번호입력란.
	
	//	ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
		ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutableCopy(theProperty);
	CFRelease(theProperty); //release 2010.12.21
	
	
	
	if([lMOBILEPHONENUMBER count] > 0)
	{
		for(int i=0; i<[lMOBILEPHONENUMBER count]; i++)
		{
			DebugLog(@"모바일 폰번호 들어와야함... %@", [lMOBILEPHONENUMBER objectAtIndex:i]);
			ABMultiValueAddValueAndLabel(multiPhone, [lMOBILEPHONENUMBER objectAtIndex:i], kABPersonPhoneMobileLabel, NULL);
		}
		//release 2010.12.15
		[lMOBILEPHONENUMBER removeAllObjects];
	}
	[lMOBILEPHONENUMBER release];
	if([lIPHONENUMBER count] > 0)
	{
		for(int i=0; i<[lIPHONENUMBER count]; i++)
		{
//			DebugLog(@"아이폰 들어와야함.... %@", [lMOBILEPHONENUMBER objectAtIndex:i]);
		ABMultiValueAddValueAndLabel(multiPhone, [lIPHONENUMBER objectAtIndex:i], kABPersonPhoneIPhoneLabel, NULL);
		}
		//release 2010.12.15
		[lIPHONENUMBER removeAllObjects];
	}
	[lIPHONENUMBER release];

	if([lMAINPHONENUMBER count] > 0)
	{
		for(int i=0; i<[lMAINPHONENUMBER count]; i++)
		{
		ABMultiValueAddValueAndLabel(multiPhone, [lMAINPHONENUMBER objectAtIndex:i], kABPersonPhoneMainLabel, NULL);
		}
		[lMAINPHONENUMBER removeAllObjects];
	}
	[lMAINPHONENUMBER release];

	if([lHOMEFAXPHONENUMBER count] > 0)
	{
		for(int i=0; i<[lHOMEFAXPHONENUMBER count]; i++)
		{
		ABMultiValueAddValueAndLabel(multiPhone, [lHOMEFAXPHONENUMBER objectAtIndex:i], kABPersonPhoneHomeFAXLabel, NULL);
		}
		[lHOMEFAXPHONENUMBER removeAllObjects];
	}
	[lHOMEFAXPHONENUMBER release];

	if([lORGFAXPHONENUMBER count] > 0)
	{
		for(int i=0; i<[lORGFAXPHONENUMBER count]; i++)
		{
		ABMultiValueAddValueAndLabel(multiPhone, [lORGFAXPHONENUMBER objectAtIndex:i], kABPersonPhoneWorkFAXLabel, NULL);
		}
		
		[lORGFAXPHONENUMBER removeAllObjects];
	}
	[lORGFAXPHONENUMBER release];

	if([lORGPHONENUMBER count] > 0)
	{
		for(int i=0; i<[lORGPHONENUMBER count]; i++)
		{
		ABMultiValueAddValueAndLabel(multiPhone, [lORGPHONENUMBER objectAtIndex:i], kABWorkLabel, NULL);
		}
		[lORGPHONENUMBER removeAllObjects];
	}
	[lORGPHONENUMBER release];

	if([lHOMEPHONENUMBER count] > 0)
	{
		for(int i=0; i<[lHOMEPHONENUMBER count]; i++)
		{
		ABMultiValueAddValueAndLabel(multiPhone, [lHOMEPHONENUMBER objectAtIndex:i], kABHomeLabel, NULL);
		}
		
		[lHOMEPHONENUMBER removeAllObjects];
	}
	[lHOMEPHONENUMBER release];

	if([lOTHERPHONENUMBER count] > 0)
	{
		for(int i=0; i<[lOTHERPHONENUMBER count]; i++)
		{
		ABMultiValueAddValueAndLabel(multiPhone, [lOTHERPHONENUMBER objectAtIndex:i], kABOtherLabel, NULL);
		}
		
		[lOTHERPHONENUMBER removeAllObjects];
	}
	[lOTHERPHONENUMBER release];

	if([lPARSERNUMBER count] > 0)
	{
		for(int i=0; i<[lPARSERNUMBER count]; i++)
		{
		ABMultiValueAddValueAndLabel(multiPhone, [lPARSERNUMBER objectAtIndex:i], kABPersonPhonePagerLabel, NULL);
		}
		[lPARSERNUMBER removeAllObjects];
	}
	[lPARSERNUMBER release];

	
	
	
	
			
		if([userInfo.URL1 length] >0)
		{
			DebugLog(@"홈페이지 주소 %@ %@", userInfo.URL1, URL1);
			//멀티필드 메일이 존재하면..
			if ([URL1 count] > 0 && URL1 != NULL) 
			{
				//홈페이지 주소가 동일하면.. 추가할 필요가 없다..
				BOOL ishomePage = NO;
				for (int i=0; i<[URL1 count];i++)
				{
					ishomePage = NO;
					
				if ([[URL1 objectAtIndex:i] isEqualToString:userInfo.URL1]) {
					DebugLog(@"홈페이지 주소가 동일하다 %@", URL1);
					ishomePage = YES;
					break;
				}
				else {
					DebugLog(@"주소가 다르다 추가한다.. %@", URL1);
		
				}
					
				}
				
				
				//left garbage value
					if(ishomePage != NO)
					{
						DebugLog(@"동일한 주소가 발견됨 ");
					}
					else {
						DebugLog(@"동일주소 발견 안함");
								ABMultiValueAddValueAndLabel(multiPhoneMail, userInfo.URL1, kABPersonHomePageLabel, NULL);
					}
				//2010.12.16 release
				if([URL1 count] >0)
				{
					[URL1 removeAllObjects];
				}
				
					
				
				
				
			}
			else {
				DebugLog(@"기존에 홈페이지 주소가 존재 하지 않는군");
				ABMultiValueAddValueAndLabel(multiPhoneMail, userInfo.URL1, kABPersonHomePageLabel, NULL);
			}

			
			
			
//			ABMultiValueAddValueAndLabel(email, userInfo.URL1, kABPersonHomePageLabel, NULL);	
	//임시 주석		ABRecordSetValue(newPerson, kABPersonURLProperty, email, &error);
			ABRecordSetValue(newPerson, kABPersonURLProperty, multiPhoneMail, &error);
	//임시		ABAddressBookSave(iPhoneAddressBook, &error);
	
		//	CFRelease(multiMail);
			
			
			
		//	CFRelease(email); //release 2010.12.15
		
			
		}
	
	
	
	//2010.12.21 release
	[URL1 release];
	URL1 = nil;
			CFRelease(multiPhoneMail); //release 2010.12.21 자리옮김..
	
	
	if([userInfo.HOMEEMAILADDRESS length] > 0)
	{
		
		//멀티필드 메일이 존재하면..
		if ([homeMailArray count] > 0 && homeMailArray != NULL) {
			//홈페이지 주소가 동일하면.. 추가할 필요가 없다..
			BOOL ishomePage = NO;	// sochae 2010.12.29
			for (int i=0; i<[homeMailArray count];i++) {
				ishomePage = NO;
				if ([[homeMailArray objectAtIndex:i] isEqualToString:userInfo.HOMEEMAILADDRESS]) {
					ishomePage = YES;
					break;
				}
				else {
				}
				
			}
			if(ishomePage == YES)
			{
				DebugLog(@"동일한 주소가 발견됨");
			}
			else {
				DebugLog(@"동일주소 발견 안함");
				ABMultiValueAddValueAndLabel(multiEmail, userInfo.HOMEEMAILADDRESS, kABHomeLabel, NULL);
			}
			[homeMailArray removeAllObjects];
			
		}
		else {
			DebugLog(@"기존에 메일 주소가 존재 안해서 걍 넣으면 된다..");
			ABMultiValueAddValueAndLabel(multiEmail, userInfo.HOMEEMAILADDRESS, kABHomeLabel, NULL);
		}

		

		
				
		ABRecordSetValue(newPerson, kABPersonEmailProperty, multiEmail, &error);
	//이메일	ABAddressBookSave(iPhoneAddressBook, &error);
	}
	//2010.12.21 release 위치 변경
	[homeMailArray release];
	homeMailArray = nil;

	if([userInfo.ORGEMAILADDRESS length] > 0)
	{
		//멀티필드 메일이 존재하면..
		if ([orgMailArray count] > 0 && orgMailArray != NULL)
		{
			//홈페이지 주소가 동일하면.. 추가할 필요가 없다..
			BOOL ishomePage = NO;	// sochae 2011.03.07 - 정적 분석 오류

			for (int i=0; i<[orgMailArray count]; i++)
			{
				ishomePage = NO;
				DebugLog(@"그룹메일 %@ 그룹배열 메일 %@", userInfo.ORGEMAILADDRESS, [orgMailArray objectAtIndex:i]);
				
				if ([[orgMailArray objectAtIndex:i] isEqualToString:userInfo.ORGEMAILADDRESS])
				{
					ishomePage = YES;
					break;
				}
			}

			if(ishomePage == YES)
			{
				DebugLog(@"동일한 주소가 발견됨 %@", userInfo.ORGEMAILADDRESS);
			}
			else
			{
				DebugLog(@"동일주소 발견 안함 %@", userInfo.ORGEMAILADDRESS);
				ABMultiValueAddValueAndLabel(multiEmail, userInfo.ORGEMAILADDRESS, kABWorkLabel, NULL);
			}
			
			[orgMailArray removeAllObjects];
			
		}
		else
		{
			DebugLog(@"기존에 메일 주소가 존재 안해서 걍 넣으면 된다..");
			ABMultiValueAddValueAndLabel(multiEmail, userInfo.ORGEMAILADDRESS, kABWorkLabel, NULL);
		}

		
		//위치 옮긴다. 2011.01.10
		/*
		[orgMailArray release];
		orgMailArray = nil;
		*/
		ABRecordSetValue(newPerson, kABPersonEmailProperty, multiEmail, &error);
		//임시 주석	ABAddressBookSave(iPhoneAddressBook, &error);
		
	} //if([userInfo.ORGEMAILADDRESS length] > 0)
	
	//2010.01.10
	[orgMailArray release];
	orgMailArray = nil;
	
	
	//2010.12.16 release
	CFRelease(thePropertyEmail);
	CFRelease(multiEmail);

	
		
	if([userInfo.HOMECITY length]>0)
		ABMultiValueAddValueAndLabel(multiPhone, userInfo.HOMECITY, kABPersonAddressCityKey, NULL);
	if([userInfo.HOMEZIPCODE length]>0)
		ABMultiValueAddValueAndLabel(multiPhone, userInfo.HOMEZIPCODE, kABPersonAddressZIPKey, NULL);
	if([userInfo.HOMEADDRESSDETAIL length]>0)
		ABMultiValueAddValueAndLabel(multiPhone, userInfo.HOMEADDRESSDETAIL, kABPersonAddressStreetKey, NULL);
	if([userInfo.HOMESTATE length]>0)
		ABMultiValueAddValueAndLabel(multiPhone, userInfo.HOMESTATE, kABPersonAddressCountryKey, NULL);
	if([userInfo.HOMEADDRESS length]>0)
		ABMultiValueAddValueAndLabel(multiPhone, userInfo.HOMEADDRESS, kABPersonAddressStateKey, NULL);
	
	//기존꺼에 업데이트는 하는데 계속 넣기는 힘들다..
	
	
	
	DebugLog(@"multiphone %@", multiPhone);
	
	
	ABRecordSetValue(newPerson, kABPersonPhoneProperty, multiPhone,nil);
	
//임시 주석	ABAddressBookSave(iPhoneAddressBook, &error);
	
	
	
	//업데이트 사용자의 레코드 아이드를 구한다.
	//		NSString *newRecID =[NSString stringWithFormat:@"%d",(NSUInteger)ABRecordGetRecordID(newPerson)];
	//만약 키딕셔너리에서 레코드 아이디가 발견되면..
	
	if(createGroup == NO)
	{
		//이미 그룹은 만들어져 있다... 해당 유저의 아이디가 레코드키 딕셔너리에 존재하면 이건 무조건 존재해야 한다..
		//단말에서 그룹이 있는 사용자 라면...
		if([groupKeyDic objectForKey:recordid])
		{
			//기존 단말 버젼..
			
			
			//무조건 최초를 가져온다..
			NSString *grecordID;
			
			//한사용자가 친구,가족,동료에 포함되어 있을때 3개중에 한개만 들어간다..
			grecordID = [[groupKeyDic objectForKey:recordid] objectAtIndex:0];
			DebugLog(@"그룹 레코드 %i  유저 레코드 recordID = %@", grecordID, recordid);
		//	DebugLog(@"그룹 레코드 아이디 = %@", [groupKeyDic objectForKey:recordid]);
		//	NSString *sameRec = [NSString stringWithFormat:@"%i", ABRecordGetRecordID([groupKeyDic objectForKey:recordid])];
			//기존 레코드 아이디로 그룹 아이디를 얻는다.. 근데 왜 널이나옴....
	//		ABRecordRef oldgroup =	ABAddressBookGetGroupWithRecordID(iPhoneAddressBook, ABRecordGetRecordID([groupKeyDic objectForKey:recordid]));
	//		ABRecordRef oldgroup =	ABAddressBookGetGroupWithRecordID(iPhoneAddressBook, [groupKeyDic objectForKey:recordid]);
	//		ABRecordRef oldgroup = [groupKeyDic objectForKey:recordid];
		
			//예전 그룹 레코드 아이디
			NSString *oemGroupRecordID = grecordID;
		//	NSString *oemGroupRecordID =[groupKeyDic objectForKey:recordid];
			NSString *usayGroupRecordID =[NSString stringWithFormat:@"%d", (NSUInteger)ABRecordGetRecordID(sameGroupRef)];
			NSLog(@"단말그룹[%@]] 유세이 그룹[%@]]", oemGroupRecordID, usayGroupRecordID);
			
			
			
			
			
			
	/*
			CFStringRef groupTitle = ABRecordCopyValue([groupKeyDic objectForKey:recordid], kABGroupNameProperty);
			DebugLog(@"예전 그룹 %@", groupTitle);
	*/
										 

			//임시주석..
//			ABRecordRef oldgroup2 =	ABAddressBookGetGroupWithRecordID(iPhoneAddressBook, (ABRecordID)[[groupKeyDic objectForKey:recordid] intValue]);
			ABRecordRef oldgroup2 =	ABAddressBookGetGroupWithRecordID(iPhoneAddressBook, (ABRecordID)[oemGroupRecordID intValue]);
			
			
			if(oldgroup2 == 0x0)
			{
				DebugLog(@"why null...");
			}
		//기존에 그룹이 없으면 그냥 추가	
			/*
			if(oldgroup == nil || oldgroup == NULL)
			{
				if(ABGroupRemoveMember(oldgroup2, newPerson, &error))
				{
					DebugLog(@"예전 그룹 삭제함");
				}
					DebugLog(@"기존 구룹이 없다..");
				//	ABAddressBookAddRecord(iPhoneAddressBook, newPerson, &error);
					ABGroupAddMember(sameGroupRef, newPerson, &error);
			}//기존그룹이랑 지금 그룹이면 같다면..
			else*/
			//if(ABRecordGetRecordID(oldgroup) == ABRecordGetRecordID(sameGroupRef))
		//	if([groupKeyDic objectForKey:recordid] == ABRecordGetRecordID(sameGroupRef))//유세이 그룹이랑 단말 그룹이랑 같다면..
			if([oemGroupRecordID isEqualToString:usayGroupRecordID])
			{
				DebugLog(@"그룹에 변하지 않았다..");
				//안먹은 경우가 생긴다.....
				ABAddressBookAddRecord(iPhoneAddressBook, newPerson, &error);
			}//기존그룹이랑 지금 그룹이랑 같지 않다면...
			else
			{
				//		DebugLog(@"삭제한다.. 해당 그룹에서 %@ %@", ABRecordCopyValue([groupKeyDic objectForKey:recordid], kABGroupNameProperty), userInfo.FORMATTED);
				DebugLog(@"그룹이 변함. 이제 배열 전체를 검사하자..");
				BOOL arrayChk = NO;
				for(int i=0; i<[[groupKeyDic objectForKey:recordid] count]; i++)
				{
					NSString *oem = [[groupKeyDic objectForKey:recordid] objectAtIndex:i];
					if([oem isEqualToString:usayGroupRecordID])
					{
						DebugLog(@"배열속에서 같은 그룹을 찾음..");
						arrayChk = YES;
						break;
					}
					
				}
				if(arrayChk == YES)
				{
					ABAddressBookAddRecord(iPhoneAddressBook, newPerson, &error);
				}
				else
				{
					if (isFindGroup == YES)	// sochae 2010.12.30
						ABGroupAddMember(sameGroupRef, newPerson, &error);
				}
				
				
				
				
				
				
				//		ABRecordRef oldgroup2 =	ABAddressBookGetGroupWithRecordID(iPhoneAddressBook, ABRecordGetRecordID([groupKeyDic objectForKey:recordid]));
				
				//2010.12.13 기존그룹에서 지울필요가 없다..
				/*
				 if(ABGroupRemoveMember(oldgroup2, newPerson, &error))
				 {
				 DebugLog(@"지워버렸다.");
				 }
				 */
				//	ABGroupAddMember(sameGroupRef, newPerson, &error);
				
			}
		}
		else
		{
			DebugLog(@"해당 사용자는 그룹이 존재 하지 않는다.");
			if (isFindGroup == YES)	// sochae 2010.12.30
				ABGroupAddMember(sameGroupRef, newPerson, &error);
		}


	}
	else
	{
		ABAddressBookAddRecord(iPhoneAddressBook, newPerson, &error);
	}
	
	
	ABAddressBookSave(iPhoneAddressBook, &error);	
	CFRelease(multiPhone);
	
	/*
	if(ABAddressBookHasUnsavedChanges(iPhoneAddressBook))
	{
		DebugLog(@"정상적으로 저장됨");
	}
	else {
		DebugLog(@"저장이 안됨");
	}

	*/
		
	
	
	
	NSString *mDate =  [NSString stringWithFormat:@"%@",(NSString *)ABRecordCopyValue(newPerson,kABPersonModificationDateProperty)];
	NSLog(@"마지막 업데이트 저장 시간은1 %@", mDate);
	mDate = [self dateFormat:mDate];
	NSLog(@"마지막 업데이트 저장 시간은 %@", mDate);
	
	
	
	//업데이트 기록..
	NSString *updateModifyDate = [NSString stringWithFormat:@"update _TUserInfo set OEMMODIFYDATE='%@' where INDEXNO=%@", mDate, userInfo.INDEXNO];
	DebugLog(@"updateMo %@", updateModifyDate);
	
	[UserInfo findWithSql:updateModifyDate];
//	[[UserInfo database] commit];
//	[self saveSyncData];	

	/*
	CFRelease(sameGroupRef); //2010.12.16 release
	CFRelease(newPerson); //2010.12.21 release
	*/
	CFRelease(iPhoneAddressBook);

}

#pragma mark +0900 날짜 형식을 yyyyMMddHHmmss 으로 바꿔줌 
-(NSString*)dateFormat:(NSString*)date
{
	NSString *currentLocalDate = [NSString stringWithFormat:@"%@", [NSTimeZone localTimeZone]];
	//날짜 변환할때 알아서 GMT 0으로 맞춰버린다..대한민국은 gmt 기준 9시간이 빠르다.. 
	NSTimeInterval secondsPerDay = 9*60*60;
	NSRange dateRange = {0,19};
	//서울에서 +0000이면 +9시간을 더해준다.. 4.1로 업데이트 되면서 gmt시간이 +0000으로 바뀌어 버림...
	if([currentLocalDate rangeOfString:@"Seoul"].location != NSNotFound)
	{
		if([date rangeOfString:@"+0000"].location != NSNotFound)
		{
			//+0900 즉 GMT를 없앤다..
			if([date length] >19)
				date = [date substringWithRange:dateRange];
			
			date = [date stringByReplacingOccurrencesOfString:@"-" withString:@""];
			date = [date stringByReplacingOccurrencesOfString:@" " withString:@""];
			date = [date stringByReplacingOccurrencesOfString:@":" withString:@""];
			
			NSDateFormatter *currentDateFormat = [[[NSDateFormatter alloc] init] autorelease];
			[currentDateFormat setDateFormat:@"yyyyMMddHHmmss"];
			
			
			NSDate *newDate = [currentDateFormat dateFromString:date];
			newDate = (NSDate*)[newDate addTimeInterval:secondsPerDay];
			DebugLog(@"newDate = %@", newDate);
			
			date =  [NSString stringWithFormat:@"%@",[currentDateFormat stringFromDate:newDate]];
			
			DebugLog(@"return");
			return date;
		}
		else {
			
			//정상적으로 들어간 놈이면..
			if([date length] >19)
				date = [date substringWithRange:dateRange];
			
			date = [date stringByReplacingOccurrencesOfString:@"-" withString:@""];
			date = [date stringByReplacingOccurrencesOfString:@" " withString:@""];
			date = [date stringByReplacingOccurrencesOfString:@":" withString:@""];
			
			return date;
			
			
		}
		
	}
	return date;
}






-(void)showText1
{
	
	
	NSAutoreleasePool *pool =[[NSAutoreleasePool alloc] init];
	//self.navigationItem.rightBarButtonItem=RightButton;
	explainLabel.text = @"주소록 내보내기 준비중입니다.";
	
	UILabel *cntLabel = (UILabel*)[self.view viewWithTag:IPHONECNT];
	cntLabel.text=@"";
	dateLabel.text = @"";
	
	
	[pool release];
}

-(void)showText2
{
	
	
	NSAutoreleasePool *pool =[[NSAutoreleasePool alloc] init];
	explainLabel.text = @"Usay주소록을\n iPhone 연락처로 내보내는 중입니다.";
	UILabel *cntLabel = (UILabel*)[self.view viewWithTag:IPHONECNT];
	cntLabel.text=@"∙ ∙ ∙";
	
	
//	explainLabel.text = @"주소록 내보내기 준비중입니다";
	dateLabel.text = @"";
	[pool release];
}

- (void)loadingPlay: (NSTimer *)aTimer
{
	if ( idx >= 12 )
		idx = 1;
	NSLog(@"=== sochae timer img = %@", [NSString stringWithFormat:@"7_load_%d.png", idx]);
	
	if(flag !=2)
	[sendButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"7_load_%d.png", idx++]] forState:UIControlStateDisabled];
	else {
		[sendButton2 setImage:[UIImage imageNamed:[NSString stringWithFormat:@"7_load_%d.png", idx++]] forState:UIControlStateDisabled];
	}

}

- (void)stopTimer
{
	NSLog(@"=== sochae timer stop");
	if(self.timer != nil)
	{
		NSLog(@"=== sochae timer release");
		[self.timer invalidate];
		self.timer = nil;
	}
}

-(void) startComplete2
{
		NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
		NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
	[[[NSTimer scheduledTimerWithTimeInterval:0.2f
									   target: self
									 selector: @selector(completeWebtoMobile:)
									 userInfo: nil
									  repeats: NO] retain] autorelease];
	
		[runLoop run];
		[pool release];
}

-(void) startComplete
{
//	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
//	NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
	[[[NSTimer scheduledTimerWithTimeInterval:0.2f
												   target: self
												 selector: @selector(completeWebtoMobile:)
												 userInfo: nil
												  repeats: NO] retain] autorelease];
	
//	[runLoop run];
//	[pool release];
}



-(void) startTimerThread
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
	idx = 1;
	loadingFlag = YES;
	self.timer = [[NSTimer scheduledTimerWithTimeInterval:0.2f
									  target: self
									selector: @selector(loadingPlay:)
									userInfo: nil
									 repeats: YES] retain];

	
	[runLoop run];
	[pool release];
}


-(void) startTimer
{
	NSThread* timerThread = [[[NSThread alloc] initWithTarget:self selector:@selector(startTimerThread) object:nil] autorelease];
	[timerThread start];
}

#pragma mark < Usay -> iPhone 내보내기 >
-(void)saveiPhone
{
	NSAutoreleasePool *pool =[[NSAutoreleasePool alloc] init];
	
	[self startTimer]; //로딩 인디케이터

	[NSThread detachNewThreadSelector:@selector(showText1) toTarget:self withObject:nil];
	explainLabel.text=@"주소록 내보내기 준비중입니다.";
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

	
	if(delete == YES)
	{
		[self removeAllGroup];	// oem 전체 그룹 삭제하기
	}
	
	
	NSMutableArray *DataArray = [self readOEM]; //메모리로 해쉬 데이터 만들기
	loadingFlag = NO;

	[NSThread detachNewThreadSelector:@selector(showText2) toTarget:self withObject:nil];
	NSDictionary *keyDic = [DataArray lastObject]; //가져온 데이터 에서 키 딕셔너리만 분리하기
	[DataArray removeLastObject];
	
	
	
	
	CFErrorRef error = NULL;
	ABAddressBookRef iPhoneAddressBook = ABAddressBookCreate(); //주소록 객체 생성

//	NSString *fromUsaytoOem = @"select * from _TUserInfo where ISBLOCK='N' and (recordid is not null || mobilephonenumber is not null) and formatted is not null";
	NSString *fromUsaytoOem = @"select * from _TUserInfo where ISBLOCK='N' and formatted is not null and ((RECORDID is not null) or (MOBILEPHONENUMBER is not null) or (IPHONENUMBER is not null) or (MAINPHONENUMBER is not null) or (HOMEPHONENUMBER is not null) or (ORGPHONENUMBER is not null) or (HOMEEMAILADDRESS is not null) or (ORGEMAILADDRESS is not null))";	// sochae 2011.01.03 - 추천 친구 이름만 있고 연락처(전화번호, 이메일) 없는 사용자는 내보내지 않도록 거른다.
	NSArray *checkDBUserInfo = [UserInfo findWithSql:fromUsaytoOem];
	NSArray *compareGroup = [GroupInfo findAll];
	
	
	DebugLog(@"내보내기 총 개수 %d", [checkDBUserInfo count]);
	
	CFIndex nGroup = ABAddressBookGetGroupCount(iPhoneAddressBook); //그룹 카운트
	CFArrayRef allGroup = ABAddressBookCopyArrayOfAllGroups(iPhoneAddressBook); //그룹 정보
	NSMutableArray *groupTitleArray =[[NSMutableArray alloc] init];
	
	
	if(groupKeyDic !=nil)
	{
		DebugLog(@"remove group key dic");
		if([groupKeyDic count] > 0)
		{
			[groupKeyDic removeAllObjects];
		}
		groupKeyDic = nil;
	}

	if(groupNameDic !=nil)
	{
		DebugLog(@"remove groupName key dic");
		if([groupNameDic count] >0)
		{
			[groupNameDic removeAllObjects];
		}
		groupNameDic = nil;
	}
	
	groupKeyDic =[NSMutableDictionary dictionary];
	groupNameDic =[NSMutableDictionary dictionary];

	//그룹별로 사람 딕셔너리를 만드는 곳 그룹이 없으면 딕셔너리에도 없다.
	for(int i=0; i< nGroup; i++)
	{
		//그룹 정보
		ABRecordRef ref = CFArrayGetValueAtIndex(allGroup, i);
		CFStringRef groupTitle = ABRecordCopyValue(ref, kABGroupNameProperty);
		//그룹 레코드 아이디..
	/*
		NSString *RecordID = [NSString stringWithFormat:@"%i", ABRecordGetRecordID(ref)];
		DebugLog(@"삭제 그룹명[%@]  레코드 아이디[%@]", (NSString*)groupTitle, RecordID);
	*/
		[groupTitleArray addObject:(NSString*)groupTitle];
		NSArray* groupArray = (NSArray*)ABGroupCopyArrayOfAllMembers(ref);

		//그룹별로 키 만든다.. //그룹에 없는 애들은 키가 생성이 안되겠군...
		for(id person in groupArray)
		{
			NSString *tmpRecord = [NSString stringWithFormat:@"%d",(NSUInteger)ABRecordGetRecordID(person)];
			NSMutableArray *groupArray;	
			//레코드 아이디가 리스트에 있는지 검사 한사용자가 여러 그룹에 걸쳐 있을경우 발생한다..
			if([groupKeyDic objectForKey:tmpRecord])
			{
				NSLog(@"하나의 레코드 아이디에 그룹이 여러개 존재한다.. %@", tmpRecord);
				groupArray = [groupKeyDic objectForKey:tmpRecord];
			}else {
				//그룹 배열 처음이면 초기화...
				groupArray = [[[NSMutableArray alloc] init] autorelease]; //오토 릴리즈 죽으면 걍 빼자..
			}

			//배열에 추가..
			[groupArray addObject:[NSString stringWithFormat:@"%i", ABRecordGetRecordID(ref)]];
			[groupKeyDic setObject:groupArray forKey:tmpRecord]; //그룹레코드아이디, 사람별레코드 아이디..										
		
			//임시 주석 배열로 바꿈..
		//	[groupKeyDic setObject:[NSString stringWithFormat:@"%i", ABRecordGetRecordID(ref)] forKey:tmpRecord]; //그룹레코드아이디, 사람별레코드 아이디..
			NSLog(@"그룹명... %@ tmpRecordID %@", (NSString*)ABRecordCopyValue(ref, kABGroupNameProperty), tmpRecord);
			//단말 유저 레코의 아이디별 그룹명을 넣어둠..
			[groupNameDic setObject:[NSString stringWithFormat:@"%@", (NSString*)ABRecordCopyValue(ref, kABGroupNameProperty)] forKey:tmpRecord];
			
			groupArray = nil; //nil처리..
			
		}
	//하면 안된다..	CFRelease(ref); //release 2010.12.17
		CFRelease(groupTitle); //release 2010.12.15
		
		// 110124 analyze 여기 죽는다..
	//	CFRelease(groupArray);
	}

	//유세이 그룹만큼.. 돌면서..
	for(GroupInfo *tmpGroup in compareGroup)
	{
		NSInteger chk = 0;
		ABRecordRef newGroup = ABGroupCreate();
		ABRecordSetValue (newGroup, kABGroupNameProperty, tmpGroup.GROUPTITLE, &error);
		//유세이 그룹명과 단말 그룹명 같은거 찾기..
		for(int i=0; i<[groupTitleArray count]; i++)
		{
			if([[groupTitleArray objectAtIndex:i] isEqualToString:tmpGroup.GROUPTITLE])
			{
				chk =1;
				break;
			}
		}
		if(chk == 1)
		{
		}
		else {
			//아니면 그룹을 생성한다...
			ABAddressBookAddRecord(iPhoneAddressBook, newGroup, &error);
			ABAddressBookSave(iPhoneAddressBook, &error);
			DebugLog(@"단말로 새로운 그룹을 생성. %@", tmpGroup.GROUPTITLE);
		}
		CFRelease(newGroup); //릴리즈 20101215
	}
	if([groupTitleArray count] > 0)
	{
		[groupTitleArray removeAllObjects];
		
	}
	[groupTitleArray release];
	groupTitleArray = nil;
	DebugLog(@"그룹 동기화가 완료되었다.");
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	//유세이 로컬디비에 사용자 정보가 있다면..
	
	
	[self stopTimer];

	if(checkDBUserInfo !=nil)
	{
		
		//단말 그룹 갯수. 그룹을 생성 해줬으니 다시 읽어와야 한다..
		nGroup = ABAddressBookGetGroupCount(iPhoneAddressBook);
		allGroup = ABAddressBookCopyArrayOfAllGroups(iPhoneAddressBook);
		
		// TODO: 내보내기 총 개수 - (현재는 매번 전체를 내보내지만 차후에 변경된 것만 내보내기할 경우 개수 다시 산정)
		tot = [checkDBUserInfo count];
		
		BOOL createGroup;
		createGroup = YES;
		ABRecordRef sameGroupRef;
		NSString *groupString;
		NSInteger index=0;

		//유세이 로컬 만큼 루프 돌면서
		for (UserInfo *userInfo in checkDBUserInfo)
		{
			
			//메모리 워닝이 2이면 브레이크..
			if(warningLevel >= 2)
				break;
			
			
			//로컬 단말에서 해당 데이터가 있는지 검사한다..
			//먼저 레코드 아이디가 있는지 검사부터 한다..
			
		//	DebugLog(@"userInfo REC FORMATTED %@ %@", userInfo.RECORDID, userInfo.FORMATTED);
			
			// 1. 단말에서 동일한 레코드 아이디를 찾은 경우
			if([recordKeyDic objectForKey:userInfo.RECORDID])
			{
				NSInteger dataIndex = [[recordKeyDic objectForKey:userInfo.RECORDID] intValue];
				DebugLog(@"dataIndex = %i", dataIndex);
				NSString *tmpDate =[[DataArray objectAtIndex:dataIndex] objectForKey:@"mDate"];
				NSString *oemupDate = [NSString stringWithFormat:@"%@", tmpDate];
				NSString *localupDate = [NSString stringWithFormat:@"%@", userInfo.OEMMODIFYDATE];
				
				
				oemupDate = [self dateFormat:oemupDate];
				localupDate = [self dateFormat:localupDate];
				NSLog(@"oem date = %@ local date = %@ %d %@", oemupDate, localupDate, [localupDate length], userInfo.FORMATTED);
				//만약에 업데이트 날짜가 존재하지 않는다면 로컬에 업데이트 시키고 단말에 업데이트한다.
				if ([localupDate length] < 14) {
					NSString *update =[NSString stringWithFormat:@"update _TUserInfo set OEMMODIFYDATE='%@' where indexno=%@",oemupDate, userInfo.INDEXNO]; 
					DebugLog(@"updateQuery = %@", update);
					DebugLog(@"업데이트에 날짜가 존재하지 않음 = %@", update);
					[UserInfo findWithSql:update];
					[[UserInfo database] commit];
					[self updateOEM:userInfo withRecord:[[DataArray objectAtIndex:dataIndex] objectForKey:@"RECORDID"]];
				}
				else if([localupDate compare:oemupDate] != 0)
				{
					[self updateOEM:userInfo withRecord:[[DataArray objectAtIndex:dataIndex] objectForKey:@"RECORDID"]];
				}
				else {
					//업데이트 일자가 같을경우
					NSString *usayGroupTitle = nil;
					NSString *oemGroupTitle = nil;
					oemGroupTitle = [groupNameDic objectForKey:userInfo.RECORDID];
			//		DebugLog(@"gropTitle = %@", oemGroupTitle);
					NSString *getGidQuery = [NSString stringWithFormat:@"select gid from _TUserInfo where indexno=%@", userInfo.INDEXNO];
			//		DebugLog(@"getGidQuery = %@", getGidQuery);
					NSArray *tmpUserInfoArray = [UserInfo findWithSql:getGidQuery];
					UserInfo *tmpUserInfo = [tmpUserInfoArray objectAtIndex:0];
					NSString *getGroupTitleQuery = [NSString stringWithFormat:@"select grouptitle from _TGroupInfo where id=%@ limit 0, 1",tmpUserInfo.GID];
			//		DebugLog(@"group Query = %@", getGroupTitleQuery);
					NSArray *tmp =  nil;
					tmp =[GroupInfo findWithSql:getGroupTitleQuery];
					if(tmp != nil && [tmp count] > 0)
					{
		//				DebugLog(@"그룹 정보 갯수 %d", [tmp count]);
						GroupInfo *tmpGroup = [tmp objectAtIndex:0];
						usayGroupTitle = tmpGroup.GROUPTITLE;
						if([usayGroupTitle isEqualToString:oemGroupTitle])
						{
							NSLog(@"그룹명이 유세이와 동일한다..");
						}
						else {
							
							NSString *recordid = [[DataArray objectAtIndex:dataIndex] objectForKey:@"RECORDID"]; //
							NSLog(@"그룹명이 다르다.. %@ %@", oemGroupTitle, recordid); //이제 그룹 레코드 아이디로 검사해야 한다.
							NSLog(@"그룹 키 딕셔너리 %@", groupKeyDic);
							
							
							
							//그룹별 레코드 아이디 딕셔너리에 해당 레코드 아이디가 존재한다면..
							//그룹을 찾는다.
							if([groupKeyDic objectForKey:recordid])
							{
								
								
																							
								[self updateOEM:userInfo withRecord:[[DataArray objectAtIndex:dataIndex] objectForKey:@"RECORDID"]];
								
								
								
								/*
								NSString *grecordID;
								grecordID = [[groupKeyDic objectForKey:recordid] objectAtIndex:0];
								
								NSString *oemGroupRecordID = grecordID;
								
								*/
								
								
															
								
								
								
								/*
								NSString *usayGroupRecordID =[NSString stringWithFormat:@"%i", ABRecordGetRecordID(sameGroupRef)];
								NSLog(@"단말그룹[%@]] 유세이 그룹[%@]]", oemGroupRecordID, usayGroupRecordID);
								ABRecordRef oldgroup2 =	ABAddressBookGetGroupWithRecordID(iPhoneAddressBook, (ABRecordID)[oemGroupRecordID intValue]);
								if(oldgroup2 == 0x0)
								{
									DebugLog(@"why null...");
								}
								else {
									CFRelease(oldgroup2);
								}
								if([oemGroupRecordID isEqualToString:usayGroupRecordID])
								{
									DebugLog(@"그룹에 변하지 않았다..");
								}//기존그룹이랑 지금 그룹이랑 같지 않다면...
								 
								{
									NSLog(@"그룹이 변함. 이제 배열 전체를 검사하자..");
									BOOL arrayChk = NO;
									for(int i=0; i<[[groupKeyDic objectForKey:recordid] count]; i++)
									{
										NSString *oem = [[groupKeyDic objectForKey:recordid] objectAtIndex:i];
										if([oem isEqualToString:usayGroupRecordID])
										{
											NSLog(@"배열속에서 같은 그룹을 찾음..");
											arrayChk = YES;
											break;
										}
									}
									if(arrayChk == YES)
									{
									}
									else {
											[self updateOEM:userInfo withRecord:[[DataArray objectAtIndex:dataIndex] objectForKey:@"RECORDID"]];
									}
																
								}
								 */
							}
							else
							{
								NSLog(@"단말 그룹명이 존재 하지 않는다..");
								[self updateOEM:userInfo withRecord:[[DataArray objectAtIndex:dataIndex] objectForKey:@"RECORDID"]];
								
							}
						}
					}
					
					
				}
			

				
				
				index++;
				percent =  ((float)index/(float)[checkDBUserInfo count])*100;
				DebugLog(@"프로그래스 진행 상태 %f", percent);
				// 내보내기 개수 
				cur = index;
				[NSThread detachNewThreadSelector:@selector(showImg) toTarget:self withObject:nil];
				//입력할때만 해야 할듯.. 이건..	[self saveSyncData];	
				
				continue;
			}
			else 
			{
				// 2. 단말에서 동일한 레코드 아이디를 찾지 못한 경우
				DebugLog(@"레코드 아이디가 존재 안한다 %@", userInfo.FORMATTED);
				
				if([keyDic objectForKey:userInfo.FORMATTED])
				{
					DebugLog(@"단말에서 같은 사용자 찾았다.. %@", userInfo.FORMATTED);
					NSArray *tmp = [keyDic objectForKey:userInfo.FORMATTED];
					NSString *phone = nil;
					NSString *email = nil;
				//	NSString *rID = nil;
					NSInteger outflag = 0;
					//같은 이름 사용자 에서 고른다..
					
					DebugLog(@"tmpCnt = %d", [tmp count]);
					DebugLog(@"내보내기 : %@, %@, %@, %@", userInfo.HOMEEMAILADDRESS, userInfo.MOBILEPHONENUMBER, userInfo.MAINPHONENUMBER, userInfo.IPHONENUMBER);
					for(int z=0; z<[tmp count]; z++)
					{
						NSInteger index2;
						outflag=0;
						index2 = [[tmp objectAtIndex:z] intValue];
						//모바일,아이폰,메인폰..
						
						
						if(userInfo.HOMEEMAILADDRESS)
						{
							DebugLog(@"이메일 검사 %@ %@", userInfo.FORMATTED, email);
							email = [[DataArray objectAtIndex:index2] objectForKey:@"HOMEEMAILADDRESS"];
						
							
							if([email isEqualToString:userInfo.HOMEEMAILADDRESS])
							{
								
								DebugLog(@"이메일 일치한다 %@ %@", userInfo.FORMATTED, userInfo.HOMEEMAILADDRESS);
								outflag = 1;
								
								
									NSString *update = [NSString stringWithFormat:@"update _TUserInfo set recordid='%@' where indexno=%@",
														[[DataArray objectAtIndex:index2] objectForKey:@"RECORDID"], userInfo.INDEXNO];
									[UserInfo findWithSql:update];
									[[UserInfo database] commit];
								
								NSString *oemupDate = [NSString stringWithFormat:@"%@", [[DataArray objectAtIndex:index2] objectForKey:@"mDate"]];
								NSString *localupDate = [NSString stringWithFormat:@"%@", userInfo.OEMMODIFYDATE];
								
								
								oemupDate = [self dateFormat:oemupDate];
								localupDate = [self dateFormat:localupDate];
								
								
								
								DebugLog(@"oem date = %@ local date = %@", oemupDate, localupDate);
								if ([localupDate length] <12) {
									
									NSString *update =[NSString stringWithFormat:@"update _TUserInfo set OEMMODIFYDATE='%@' where indexno=%@",oemupDate ,userInfo.INDEXNO]; 
									[UserInfo findWithSql:update];
									[[UserInfo database] commit];
									[self updateOEM:userInfo withRecord:[[DataArray objectAtIndex:index2] objectForKey:@"RECORDID"]];
								}
								else if([localupDate compare:oemupDate] !=  0)
								{
									[self updateOEM:userInfo withRecord:[[DataArray objectAtIndex:index2] objectForKey:@"RECORDID"]];
								}
								else {
									//업데이트 일자가 같을경우
									NSString *usayGroupTitle = nil;
									NSString *oemGroupTitle = nil;
									
									//단말 그룹 타이틀을 구한다..
									oemGroupTitle = [groupNameDic objectForKey:[[DataArray objectAtIndex:index2] objectForKey:@"RECORDID"]];
									
									
									NSString *query1 = [NSString stringWithFormat:@"select gid from _TUserInfo where indexno=%@", userInfo.INDEXNO];
									NSArray *query1Array = [UserInfo findWithSql:query1];
									
									//그룹 타이틀을 구한다.. 사용자의 인덱스 번호로
									if(query1Array == NULL || query1Array == nil)
									{}
									else {
										UserInfo *tmpUserInfo = [query1Array objectAtIndex:0];
										NSString *gid = tmpUserInfo.GID;
										tmpUserInfo = nil;
										NSString *query2 = [NSString stringWithFormat:@"select grouptitle from _TGroupInfo where id=%@", gid];
										
										NSArray *tmp = [GroupInfo findWithSql:query2];
										//타이틀이 발견되면 
										if(tmp != nil)
										{
											GroupInfo *tmpGroup = [tmp objectAtIndex:0];
											usayGroupTitle = tmpGroup.GROUPTITLE;
											
											
											//발견된 타이틀의 그룹명이 동일하면.. 
											if([usayGroupTitle isEqualToString:oemGroupTitle])
											{
												DebugLog(@"그룹명이 유세이와 동일한다..");
											}
											else {
												DebugLog(@"그룹명이 다르다..");
												NSString *recordid = [DataArray objectAtIndex:index2];
												if([groupKeyDic objectForKey:recordid])
												{
													
													[self updateOEM:userInfo withRecord:[[DataArray objectAtIndex:index2] objectForKey:@"RECORDID"]];
													//기존 단말 버젼..
													/*
													NSString *grecordID;
													grecordID = [[groupKeyDic objectForKey:recordid] objectAtIndex:0];
													NSString *oemGroupRecordID = grecordID;
													NSString *usayGroupRecordID =[NSString stringWithFormat:@"%i", ABRecordGetRecordID(sameGroupRef)];
													NSLog(@"단말그룹[%@]] 유세이 그룹[%@]]", oemGroupRecordID, usayGroupRecordID);
													ABRecordRef oldgroup2 =	ABAddressBookGetGroupWithRecordID(iPhoneAddressBook, (ABRecordID)[oemGroupRecordID intValue]);
													if(oldgroup2 == 0x0)
													{
														DebugLog(@"why null...");
													}
													if([oemGroupRecordID isEqualToString:usayGroupRecordID])
													{
														DebugLog(@"그룹에 변하지 않았다..");
													}//기존그룹이랑 지금 그룹이랑 같지 않다면...
													 
													{
														DebugLog(@"그룹이 변함. 이제 배열 전체를 검사하자..");
														BOOL arrayChk = NO;
														for(int i=0; i<[[groupKeyDic objectForKey:recordid] count]; i++)
														{
															NSString *oem = [[groupKeyDic objectForKey:recordid] objectAtIndex:i];
															if([oem isEqualToString:usayGroupRecordID])
															{
																DebugLog(@"배열속에서 같은 그룹을 찾음..");
																arrayChk = YES;
																break;
															}
														}
														if(arrayChk == YES)
														{
														}
														else {
															[self updateOEM:userInfo withRecord:[[DataArray objectAtIndex:index2] objectForKey:@"RECORDID"]];
														}
														
													}
													 */
												}
											}
										}
										
										
									}
									
									
									/*
									NSString *getGroupTitleQuery = [NSString stringWithFormat:@"select grouptitle from _TGroupInfo a, (select gid from _TUserInfo where indexno=%@) b where a.id=b.gid limit 0, 1",
																	userInfo.INDEXNO];
									
									NSArray *tmp = [GroupInfo findWithSql:getGroupTitleQuery];
									if(tmp != nil)
									{
										GroupInfo *tmpGroup = [tmp objectAtIndex:0];
										usayGroupTitle = tmpGroup.GROUPTITLE;
										
										if([usayGroupTitle isEqualToString:oemGroupTitle])
										{
											DebugLog(@"그룹명이 유세이와 동일한다..");
										}
										else {
											[self updateOEM:userInfo withRecord:[[DataArray objectAtIndex:index2] objectForKey:@"RECORDID"]];
										}
									}
									 */
									
									
								}

								break;
							}
						}
						
						
						for(int y=0; y<3; y++)
						{

							
							if (y == 0) {
								phone = [[DataArray objectAtIndex:index2] objectForKey:@"MOBILEPHONENUMBER"];	
							}
							else if(y == 1)
							{
								phone = [[DataArray objectAtIndex:index2] objectForKey:@"IPHONENUMBER"];
							}
							else {
								phone = [[DataArray objectAtIndex:index2] objectForKey:@"MAINPHONENUMBER"];
							}
							//전화번호가 없으면 해당 필드는 패스..
							if(phone == nil || [phone length] == 0)
								continue;
							DebugLog(@"phone number = %@", phone);
							
							
							//유세이 폰이 있으면..
							if(userInfo.MOBILEPHONENUMBER)
							{
								//단말폰이랑 유세이랑 같으면..
								if([phone isEqualToString:userInfo.MOBILEPHONENUMBER])
								{
									DebugLog(@"모바일 번호랑 일치한다. %@ %@", userInfo.FORMATTED, userInfo.MOBILEPHONENUMBER);
									outflag = 1;
									
										NSString *update = [NSString stringWithFormat:@"update _TUserInfo set recordid='%@' where indexno=%@",
															[[DataArray objectAtIndex:index2] objectForKey:@"RECORDID"], userInfo.INDEXNO];
										[UserInfo findWithSql:update];
										[[UserInfo database] commit];
									
									NSString *oemupDate = [NSString stringWithFormat:@"%@", [[DataArray objectAtIndex:index2] objectForKey:@"mDate"]];
									NSString *localupDate = [NSString stringWithFormat:@"%@", userInfo.OEMMODIFYDATE];
									
									
									
									
									oemupDate = [self dateFormat:oemupDate];
									localupDate = [self dateFormat:localupDate];
									
									DebugLog(@"oem date = %@ local date = %@", oemupDate, localupDate);
									
									
									if([localupDate length] < 12) {
										NSString *update =[NSString stringWithFormat:@"update _TUserInfo set OEMMODIFYDATE='%@' where indexno=%@",oemupDate, userInfo.INDEXNO]; 
										[UserInfo findWithSql:update];
										[[UserInfo database] commit];
										[self updateOEM:userInfo withRecord:[[DataArray objectAtIndex:index2] objectForKey:@"RECORDID"]];
									}
									else if([localupDate compare:oemupDate] !=  0)
									{
										[self updateOEM:userInfo withRecord:[[DataArray objectAtIndex:index2] objectForKey:@"RECORDID"]];
									}
									else {
										//업데이트 일자가 같을경우
										NSString *usayGroupTitle = nil;
										NSString *oemGroupTitle = nil;
										
										//이전 그룹 타이틀을 구한다..
										oemGroupTitle = [groupNameDic objectForKey:[[DataArray objectAtIndex:index2] objectForKey:@"RECORDID"]];
										
										DebugLog(@"oemGroupTitle %@", oemGroupTitle);
										
										NSString *query1 = [NSString stringWithFormat:@"select gid from _TUserInfo where indexno=%@", userInfo.INDEXNO];
										DebugLog(@"query1 = %@", query1);
										NSArray *query1Array = [UserInfo findWithSql:query1];
										
										if(query1Array == NULL || query1Array == nil)
										{}
										else {
											UserInfo *tmpUserInfo = [query1Array objectAtIndex:0];
											NSString *gid = tmpUserInfo.GID;
											tmpUserInfo = nil;
											NSString *query2 = [NSString stringWithFormat:@"select grouptitle from _TGroupInfo where id=%@", gid];
										DebugLog(@"query2 = %@", query2);	
											NSArray *tmp = [GroupInfo findWithSql:query2];
											if(tmp != nil)
											{
												GroupInfo *tmpGroup = [tmp objectAtIndex:0];
												usayGroupTitle = tmpGroup.GROUPTITLE;
												
												if([usayGroupTitle isEqualToString:oemGroupTitle])
												{
													DebugLog(@"그룹명이 유세이와 동일한다..");
												}
												else {
											//		DebugLog(@"그룹명이 다르다..");
													DebugLog(@"그룹명이 다르다..");
													NSString *recordid = [DataArray objectAtIndex:index2];
													if([groupKeyDic objectForKey:recordid])
													{
													
														[self updateOEM:userInfo withRecord:[[DataArray objectAtIndex:index2] objectForKey:@"RECORDID"]];
														//기존 단말 버젼..
														/*
														NSString *grecordID;
														grecordID = [[groupKeyDic objectForKey:recordid] objectAtIndex:0];
														NSString *oemGroupRecordID = grecordID;
														NSString *usayGroupRecordID =[NSString stringWithFormat:@"%i", ABRecordGetRecordID(sameGroupRef)];
														NSLog(@"단말그룹[%@]] 유세이 그룹[%@]]", oemGroupRecordID, usayGroupRecordID);
														ABRecordRef oldgroup2 =	ABAddressBookGetGroupWithRecordID(iPhoneAddressBook, (ABRecordID)[oemGroupRecordID intValue]);
														if(oldgroup2 == 0x0)
														{
															DebugLog(@"why null...");
														}
														if([oemGroupRecordID isEqualToString:usayGroupRecordID])
														{
															DebugLog(@"그룹에 변하지 않았다..");
														}//기존그룹이랑 지금 그룹이랑 같지 않다면...
														
														 {
															DebugLog(@"그룹이 변함. 이제 배열 전체를 검사하자..");
															BOOL arrayChk = NO;
															for(int i=0; i<[[groupKeyDic objectForKey:recordid] count]; i++)
															{
																NSString *oem = [[groupKeyDic objectForKey:recordid] objectAtIndex:i];
																if([oem isEqualToString:usayGroupRecordID])
																{
																	DebugLog(@"배열속에서 같은 그룹을 찾음..");
																	arrayChk = YES;
																	break;
																}
															}
															if(arrayChk == YES)
															{
															}
															else {
																[self updateOEM:userInfo withRecord:[[DataArray objectAtIndex:index2] objectForKey:@"RECORDID"]];
															}
															
														}
														 */
													}
												}
											}
											
											
										}
										/*
										NSString *getGroupTitleQuery = [NSString stringWithFormat:@"select grouptitle from _TGroupInfo a, (select gid from _TUserInfo where indexno=%@) b where a.id=b.gid limit 0, 1",
																		userInfo.INDEXNO];
										
										
										DebugLog(@"getGroupQuery = %@", getGroupTitleQuery);
										
										NSArray *tmp = [GroupInfo findWithSql:getGroupTitleQuery];
										if(tmp != nil)
										{
											GroupInfo *tmpGroup = [tmp objectAtIndex:0];
											usayGroupTitle = tmpGroup.GROUPTITLE;
											
											if([usayGroupTitle isEqualToString:oemGroupTitle])
											{
												DebugLog(@"그룹명이 유세이와 동일한다..");
											}
											else {
												DebugLog(@"그룹명이 동일하지 않다..");
												[self updateOEM:userInfo withRecord:[[DataArray objectAtIndex:index2] objectForKey:@"RECORDID"]];
											}
										}
										 */
										
										
									}
									
									break;
								}
							}
							if(userInfo.IPHONENUMBER)
							{
								//단말폰이랑 유세이랑 같으면..
								if([phone isEqualToString:userInfo.IPHONENUMBER])
								{
									DebugLog(@"완전히 일치 함1.. %@ %@", userInfo.FORMATTED, userInfo.IPHONENUMBER);
									outflag = 1;
									
									
									if(!userInfo.RECORDID || userInfo.RECORDID == nil || userInfo.RECORDID == NULL )
									{
										NSString *update = [NSString stringWithFormat:@"update _TUserInfo set recordid='%@' where indexno=%@",
															[[DataArray objectAtIndex:index2] objectForKey:@"RECORDID"], userInfo.INDEXNO];
										[UserInfo findWithSql:update];
									}
									
									
									NSString *oemupDate = [NSString stringWithFormat:@"%@", [[DataArray objectAtIndex:index2] objectForKey:@"mDate"]];
									NSString *localupDate = [NSString stringWithFormat:@"%@", userInfo.OEMMODIFYDATE];
									
									
									
									
									oemupDate = [self dateFormat:oemupDate];
									localupDate = [self dateFormat:localupDate];
									DebugLog(@"oem date = %@ local date = %@", oemupDate, localupDate);
									if ( localupDate == nil || [localupDate length] < 12) {    // sochae - 서버에서 안내려주더라도 죽은면 안됨
										NSString *update =[NSString stringWithFormat:@"update _TUserInfo set OEMMODIFYDATE='%@' where indexno=%@",oemupDate, userInfo.INDEXNO]; 
										[UserInfo findWithSql:update];
										[[UserInfo database] commit];
										[self updateOEM:userInfo withRecord:[[DataArray objectAtIndex:index2] objectForKey:@"RECORDID"]];
									}
									else if([localupDate compare:oemupDate] !=  0)
									{
										[self updateOEM:userInfo withRecord:[[DataArray objectAtIndex:index2] objectForKey:@"RECORDID"]];
									}
									else {
										//업데이트 일자가 같을경우
										NSString *usayGroupTitle = nil;
										NSString *oemGroupTitle = nil;
										
										//이전 그룹 타이틀을 구한다..
										oemGroupTitle = [groupNameDic objectForKey:[[DataArray objectAtIndex:index2] objectForKey:@"RECORDID"]];
									
										NSString *query1 = [NSString stringWithFormat:@"select gid from _TUserInfo where indexno=%@", userInfo.INDEXNO];
										NSArray *query1Array = [UserInfo findWithSql:query1];
										
										if(query1Array == NULL || query1Array == nil)
										{}
										else {
											UserInfo *tmpUserInfo = [query1Array objectAtIndex:0];
											NSString *gid = tmpUserInfo.GID;
											tmpUserInfo = nil;
											NSString *query2 = [NSString stringWithFormat:@"select grouptitle from _TGroupInfo where id=%@", gid];
											
											NSArray *tmp = [GroupInfo findWithSql:query2];
											if(tmp != nil)
											{
												GroupInfo *tmpGroup = [tmp objectAtIndex:0];
												usayGroupTitle = tmpGroup.GROUPTITLE;
												
												if([usayGroupTitle isEqualToString:oemGroupTitle])
												{
													DebugLog(@"그룹명이 유세이와 동일한다..");
												}
												else {
													DebugLog(@"그룹명이 다르다..");
													NSString *recordid = [DataArray objectAtIndex:index2];
													if([groupKeyDic objectForKey:recordid])
													{
														
														[self updateOEM:userInfo withRecord:[[DataArray objectAtIndex:index2] objectForKey:@"RECORDID"]];
														/*
														//기존 단말 버젼..
														NSString *grecordID;
														grecordID = [[groupKeyDic objectForKey:recordid] objectAtIndex:0];
														NSString *oemGroupRecordID = grecordID;
														NSString *usayGroupRecordID =[NSString stringWithFormat:@"%i", ABRecordGetRecordID(sameGroupRef)];
														NSLog(@"단말그룹[%@]] 유세이 그룹[%@]]", oemGroupRecordID, usayGroupRecordID);
														ABRecordRef oldgroup2 =	ABAddressBookGetGroupWithRecordID(iPhoneAddressBook, (ABRecordID)[oemGroupRecordID intValue]);
														if(oldgroup2 == 0x0)
														{
															DebugLog(@"why null...");
														}
														if([oemGroupRecordID isEqualToString:usayGroupRecordID])
														{
															DebugLog(@"그룹에 변하지 않았다..");
														}//기존그룹이랑 지금 그룹이랑 같지 않다면...
														else 
														{
															DebugLog(@"그룹이 변함. 이제 배열 전체를 검사하자..");
															BOOL arrayChk = NO;
															for(int i=0; i<[[groupKeyDic objectForKey:recordid] count]; i++)
															{
																NSString *oem = [[groupKeyDic objectForKey:recordid] objectAtIndex:i];
																if([oem isEqualToString:usayGroupRecordID])
																{
																	DebugLog(@"배열속에서 같은 그룹을 찾음..");
																	arrayChk = YES;
																	break;
																}
															}
															if(arrayChk == YES)
															{
															}
															else {
																[self updateOEM:userInfo withRecord:[[DataArray objectAtIndex:index2] objectForKey:@"RECORDID"]];
															}
															
														}
														 */
													}
												}
											}
											
											
										}
										
										
										/*
										NSString *getGroupTitleQuery = [NSString stringWithFormat:@"select grouptitle from _TGroupInfo a, (select gid from _TUserInfo where indexno=%@) b where a.id=b.gid limit 0, 1",
																		userInfo.INDEXNO];
										
										NSArray *tmp = [GroupInfo findWithSql:getGroupTitleQuery];
										if(tmp != nil)
										{
											GroupInfo *tmpGroup = [tmp objectAtIndex:0];
											usayGroupTitle = tmpGroup.GROUPTITLE;
											
											if([usayGroupTitle isEqualToString:oemGroupTitle])
											{
												DebugLog(@"그룹명이 유세이와 동일한다..");
											}
											else {
												[self updateOEM:userInfo withRecord:[[DataArray objectAtIndex:index2] objectForKey:@"RECORDID"]];
											}
										}
										*/
										
									}
									break;
								}
							}
							if(userInfo.MAINPHONENUMBER)
							{
								//단말폰이랑 유세이랑 같으면..
								if([phone isEqualToString:userInfo.MAINPHONENUMBER])
								{
									DebugLog(@"완전히 일치 함1.. %@ %@", userInfo.FORMATTED, userInfo.MAINPHONENUMBER);
									outflag = 1;
									
									
									
										NSString *update = [NSString stringWithFormat:@"update _TUserInfo set recordid='%@' where indexno=%@",
															[[DataArray objectAtIndex:index2] objectForKey:@"RECORDID"], userInfo.INDEXNO];
										[UserInfo findWithSql:update];
									
									
									
									
									NSString *oemupDate = [NSString stringWithFormat:@"%@", [[DataArray objectAtIndex:index2] objectForKey:@"mDate"]];
									NSString *localupDate = [NSString stringWithFormat:@"%@", userInfo.OEMMODIFYDATE];
									
									
									
									
									oemupDate = [self dateFormat:oemupDate];
									localupDate = [self dateFormat:localupDate];
									
									
									DebugLog(@"oem date = %@ local date = %@", oemupDate, localupDate);
									if ([localupDate length] < 12) {
										NSString *update =[NSString stringWithFormat:@"update _TUserInfo set mDate='%@' where indexno=%@",oemupDate,userInfo.INDEXNO]; 
										[UserInfo findWithSql:update];
										[[UserInfo database] commit];
										[self updateOEM:userInfo withRecord:[[DataArray objectAtIndex:index2] objectForKey:@"RECORDID"]];
									}
									else if([localupDate compare:oemupDate] !=  0)
									{
										[self updateOEM:userInfo withRecord:[[DataArray objectAtIndex:index2] objectForKey:@"RECORDID"]];
									}
									else {
										//업데이트 일자가 같을경우
										NSString *usayGroupTitle = nil;
										NSString *oemGroupTitle = nil;
										
										//이전 그룹 타이틀을 구한다..
										oemGroupTitle = [groupNameDic objectForKey:[[DataArray objectAtIndex:index2] objectForKey:@"RECORDID"]];
										
										
										NSString *query1 = [NSString stringWithFormat:@"select gid from _TUserInfo where indexno=%@", userInfo.INDEXNO];
										NSArray *query1Array = [UserInfo findWithSql:query1];
										
										if(query1Array == NULL || query1Array == nil)
										{}
										else {
											UserInfo *tmpUserInfo = [query1Array objectAtIndex:0];
											NSString *gid = tmpUserInfo.GID;
											tmpUserInfo = nil;
											NSString *query2 = [NSString stringWithFormat:@"select grouptitle from _TGroupInfo where id=%@", gid];
											
											NSArray *tmp = [GroupInfo findWithSql:query2];
											if(tmp != nil)
											{
												GroupInfo *tmpGroup = [tmp objectAtIndex:0];
												usayGroupTitle = tmpGroup.GROUPTITLE;
												
												if([usayGroupTitle isEqualToString:oemGroupTitle])
												{
													DebugLog(@"그룹명이 유세이와 동일한다..");
												}
												else {
													DebugLog(@"그룹명이 다르다..");
													NSString *recordid = [DataArray objectAtIndex:index2];
													if([groupKeyDic objectForKey:recordid])
													{
														
														[self updateOEM:userInfo withRecord:[[DataArray objectAtIndex:index2] objectForKey:@"RECORDID"]];
														//기존 단말 버젼..
														/*
														NSString *grecordID;
														grecordID = [[groupKeyDic objectForKey:recordid] objectAtIndex:0];
														NSString *oemGroupRecordID = grecordID;
														NSString *usayGroupRecordID =[NSString stringWithFormat:@"%i", ABRecordGetRecordID(sameGroupRef)];
														NSLog(@"단말그룹[%@]] 유세이 그룹[%@]]", oemGroupRecordID, usayGroupRecordID);
														ABRecordRef oldgroup2 =	ABAddressBookGetGroupWithRecordID(iPhoneAddressBook, (ABRecordID)[oemGroupRecordID intValue]);
														if(oldgroup2 == 0x0)
														{
															DebugLog(@"why null...");
														}
														if([oemGroupRecordID isEqualToString:usayGroupRecordID])
														{
															DebugLog(@"그룹에 변하지 않았다..");
														}//기존그룹이랑 지금 그룹이랑 같지 않다면...
														else 
														 {
															DebugLog(@"그룹이 변함. 이제 배열 전체를 검사하자..");
															BOOL arrayChk = NO;
															for(int i=0; i<[[groupKeyDic objectForKey:recordid] count]; i++)
															{
																NSString *oem = [[groupKeyDic objectForKey:recordid] objectAtIndex:i];
																if([oem isEqualToString:usayGroupRecordID])
																{
																	DebugLog(@"배열속에서 같은 그룹을 찾음..");
																	arrayChk = YES;
																	break;
																}
															}
															if(arrayChk == YES)
															{
															}
															else {
																[self updateOEM:userInfo withRecord:[[DataArray objectAtIndex:index2] objectForKey:@"RECORDID"]];
															}
															
														}
														 */
													}
												}
											}
											
											
										}

										
										
										
										/*
										NSString *getGroupTitleQuery = [NSString stringWithFormat:@"select grouptitle from _TGroupInfo a, (select gid from _TUserInfo where indexno=%@) b where a.id=b.gid limit 0, 1",
																		userInfo.INDEXNO];
										*/
																				
										
									}
									
									
									break;
								}
							}
							
						
						}
						if(outflag == 1)
						{
							break;
						}				}
					
					
					if (outflag == 1) {
						index++;
						percent =  ((float)index/(float)[checkDBUserInfo count])*100;
						DebugLog(@"프로그래스 진행 상태 %f", percent);
						// 내보내기 개수 
						cur = index;
						[NSThread detachNewThreadSelector:@selector(showImg) toTarget:self withObject:nil];
				//이건 입력할때만..		[self saveSyncData];	
						continue;
					}
					else {
						index++;
						DebugLog(@"이름은 같으나 단말에는 해당 사용자를 찾을수가 없다.. 그럼 인서트..");
					}
					
					
				}
				else { //로컬 단말에서 이름을 찾지 못하면..
					DebugLog(@"존재 하지 않는다.. %@", userInfo.FORMATTED);
					DebugLog(@"존재 하지 않는다 nick.. %@", userInfo.NICKNAME);
					
					index++;
				}
			
			}
			
			
			
			// sochae 2010.12.31 - 이름만 있고 전화번호, 이메일 없는 사용자가 못나가게 하자. (위의 sql query문 제대로 동작 안함)
			DebugLog(@"정보 mobile:%@, iphone:%@, main:%@, home:%@, org:%@", userInfo.MOBILEPHONENUMBER, userInfo.IPHONENUMBER,
					 userInfo.MAINPHONENUMBER, userInfo.HOMEPHONENUMBER, userInfo.ORGPHONENUMBER);
			if ([userInfo.MOBILEPHONENUMBER length] == 0 && [userInfo.IPHONENUMBER length] == 0 && 
				[userInfo.MAINPHONENUMBER length] == 0 &&
			    [userInfo.HOMEEMAILADDRESS length] == 0 && [userInfo.ORGEMAILADDRESS length] == 0 )
			{
				index--;
				continue;
			}
			// ~sochae
			
			
			
			
			
			
			//입력 한다.
			ABRecordRef newPerson = ABPersonCreate();
			NSString *tmpGroupTitle = [NSString stringWithFormat:@"select grouptitle from _TGroupInfo where id=%@ limit 0, 1", userInfo.GID];
			NSArray *groupArray = [GroupInfo findWithSql:tmpGroupTitle];
			GroupInfo* group = nil;
			//if([groupArray objectAtIndex:0])	// sochae 2011.02.25 - cpok 내보내기 죽는 원인 (apple crash)
			if([groupArray count] > 0)
				group = [groupArray objectAtIndex:0];
			groupString = group.GROUPTITLE;
			
			
			
			//해당 그룹명에서 단말 그룹명을 찾는다.
			for(int i=0; i< nGroup; i++)
			{
				//그룹 정보
				
				
			
				
				ABRecordRef ref = CFArrayGetValueAtIndex(allGroup, i);
				//CFStringRef groupTitle = ABRecordCopyValue(ref, kABGroupNameProperty);
				
				NSString *groupTitle =  (NSString*)ABRecordCopyValue(ref, kABGroupNameProperty);
				
				
				DebugLog(@"groupTitle %@ groupString %@", groupTitle, groupString);
				if([(NSString*)groupTitle isEqualToString:groupString])
				{
					
					sameGroupRef = CFArrayGetValueAtIndex(allGroup, i);
			//		CFStringRef	 tmpTitle = ABRecordCopyValue(sameGroupRef, kABGroupNameProperty);
					
					//110124 analyze
					CFRelease(groupTitle);
					
					createGroup = NO;
					break;
				}
				else {
					createGroup = YES;
				}
				DebugLog(@"루프 종료..");
				CFRelease(groupTitle); //release 2010.12.15

			}
			
			//유세이 디비에서 포맷티드이름, 닉네임이 있으면 퍼스트네임으로 입력
			if([userInfo.FORMATTED length] >0)
			{
				DebugLog(@"입력할 이름은.. %@", userInfo.FORMATTED);
				ABRecordSetValue(newPerson, kABPersonFirstNameProperty, userInfo.FORMATTED, &error);
				if([userInfo.NICKNAME length]>0)
				{
					ABRecordSetValue(newPerson, kABPersonNicknameProperty, userInfo.NICKNAME, &error);
				}
			}
			else if([userInfo.NICKNAME length] >0)
			{
				
				DebugLog(@"입력할 별명은.. %@", userInfo.NICKNAME);
				
				ABRecordSetValue(newPerson, kABPersonFirstNameProperty, userInfo.NICKNAME, &error);
				ABRecordSetValue(newPerson, kABPersonNicknameProperty, userInfo.NICKNAME, &error);
			}
			else if([userInfo.PROFILENICKNAME length] >0)
			{
				
				DebugLog(@"입력할 프로파일명은 %@", userInfo.PROFILENICKNAME);
				
				ABRecordSetValue(newPerson, kABPersonFirstNameProperty, userInfo.PROFILENICKNAME, &error);
			//	ABRecordSetValue(newPerson, kABPersonNicknameProperty, userInfo.NICKNAME, &error);
			}
			//회사 
			if([userInfo.ORGNAME length] >0)
				ABRecordSetValue(newPerson, kABPersonOrganizationProperty, userInfo.ORGNAME, &error);
			
			// sochae 2010.12.29
			/*if([userInfo.HOMEEMAILADDRESS length] >0)
			{
				
				ABMultiValueRef email = ABMultiValueCreateMutable(kABMultiStringPropertyType);
				
				if([userInfo.ORGEMAILADDRESS length] > 0)
				{
					ABMultiValueAddValueAndLabel(email, userInfo.ORGEMAILADDRESS, kABWorkLabel, NULL);	
					
				}
				
				
				
				ABMultiValueAddValueAndLabel(email, userInfo.HOMEEMAILADDRESS, kABHomeLabel, NULL);	
				ABRecordSetValue(newPerson, kABPersonEmailProperty, email, &error);
				CFRelease(email); //release 2010.12.15
			 }*/
			// 이메일 업데이트
			ABMultiValueRef email = ABMultiValueCreateMutable(kABMultiStringPropertyType);

			if ([userInfo.HOMEEMAILADDRESS length] > 0)
				ABMultiValueAddValueAndLabel(email, userInfo.HOMEEMAILADDRESS, kABHomeLabel, NULL);	

			if ([userInfo.ORGEMAILADDRESS length] > 0)
				ABMultiValueAddValueAndLabel(email, userInfo.ORGEMAILADDRESS, kABWorkLabel, NULL);

			ABRecordSetValue(newPerson, kABPersonEmailProperty, email, &error);
			CFRelease(email);
			// ~sochae
			
			
			if([userInfo.NOTE length] >0)
				ABRecordSetValue(newPerson, kABPersonNoteProperty, userInfo.NOTE, &error);
			
			//번호입력란.
			ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
			
			if([userInfo.MOBILEPHONENUMBER length] >0)
				ABMultiValueAddValueAndLabel(multiPhone, userInfo.MOBILEPHONENUMBER, kABPersonPhoneMobileLabel, NULL);
			if([userInfo.IPHONENUMBER length] >0)
				ABMultiValueAddValueAndLabel(multiPhone, userInfo.IPHONENUMBER, kABPersonPhoneIPhoneLabel, NULL);
			if([userInfo.MAINPHONENUMBER length] >0)
				ABMultiValueAddValueAndLabel(multiPhone, userInfo.MAINPHONENUMBER, kABPersonPhoneMainLabel, NULL);
			if([userInfo.HOMEFAXPHONENUMBER length] >0)
				ABMultiValueAddValueAndLabel(multiPhone, userInfo.HOMEFAXPHONENUMBER, kABPersonPhoneHomeFAXLabel, NULL);
			if([userInfo.ORGFAXPHONENUMBER length] >0)
				ABMultiValueAddValueAndLabel(multiPhone, userInfo.ORGFAXPHONENUMBER, kABPersonPhoneWorkFAXLabel, NULL);
			if([userInfo.ORGPHONENUMBER length] >0)
				ABMultiValueAddValueAndLabel(multiPhone, userInfo.ORGPHONENUMBER, kABWorkLabel, NULL);
			if([userInfo.HOMEPHONENUMBER length] >0)
				ABMultiValueAddValueAndLabel(multiPhone, userInfo.HOMEPHONENUMBER, kABHomeLabel, NULL);
			if([userInfo.OTHERPHONENUMBER length] >0)
				ABMultiValueAddValueAndLabel(multiPhone, userInfo.OTHERPHONENUMBER, kABOtherLabel, NULL);
			if([userInfo.PARSERNUMBER length] >0)
				ABMultiValueAddValueAndLabel(multiPhone, userInfo.PARSERNUMBER, kABPersonPhonePagerLabel, NULL);
			/*
			if([userInfo.URL1 length] >0)
				ABMultiValueAddValueAndLabel(multiPhone, userInfo.URL1, kABHomeLabel, NULL);
			*/
			if([userInfo.URL1 length] >0)
			{
				ABMultiValueRef email = ABMultiValueCreateMutable(kABMultiStringPropertyType);
				
				
				if([userInfo.URL2 length] > 0)
				{
					ABMultiValueAddValueAndLabel(email, userInfo.URL2, kABHomeLabel, NULL);	
					
				}
				
				
				ABMultiValueAddValueAndLabel(email, userInfo.URL1, kABPersonHomePageLabel, NULL);	
				ABRecordSetValue(newPerson, kABPersonURLProperty, email, &error);
				CFRelease(email); //release 2010.12.15
			}
			
			
			
			if([userInfo.HOMECITY length]>0)
				ABMultiValueAddValueAndLabel(multiPhone, userInfo.HOMECITY, kABPersonAddressCityKey, NULL);
			if([userInfo.HOMEZIPCODE length]>0)
				ABMultiValueAddValueAndLabel(multiPhone, userInfo.HOMEZIPCODE, kABPersonAddressZIPKey, NULL);
			if([userInfo.HOMEADDRESSDETAIL length]>0)
				ABMultiValueAddValueAndLabel(multiPhone, userInfo.HOMEADDRESSDETAIL, kABPersonAddressStreetKey, NULL);
			if([userInfo.HOMESTATE length]>0)
				ABMultiValueAddValueAndLabel(multiPhone, userInfo.HOMESTATE, kABPersonAddressCountryKey, NULL);
			if([userInfo.HOMEADDRESS length]>0)
				ABMultiValueAddValueAndLabel(multiPhone, userInfo.HOMEADDRESS, kABPersonAddressStateKey, NULL);
			ABRecordSetValue(newPerson, kABPersonPhoneProperty, multiPhone,nil);
			
			
			
			if(createGroup == NO)
			{
				
				DebugLog(@"기존 그룹에추가하기.. sameGroupRef %@  %@ %@", sameGroupRef, ABRecordCopyValue(sameGroupRef, kABGroupNameProperty), newPerson);
				//기존 그룹에 멤버를 추가한다. //먼저 기록하고 애드해야지만 생성됨 ....
				ABAddressBookAddRecord(iPhoneAddressBook, newPerson, &error);
				ABGroupAddMember(sameGroupRef, newPerson, &error);
				
			}
			else {
				DebugLog(@"뭔가 이상하다 프로그램 흐름상 그룹을 모두 만들어 주기 때문에 여기로 드러울 수가 없다.... 만약 들어오면 왜 들어오는지.. 확인해야함");
				ABAddressBookAddRecord(iPhoneAddressBook, newPerson, &error);
			}
			CFRelease(multiPhone);
			ABAddressBookSave(iPhoneAddressBook, &error);			
			
			
					
			
			
			
			
			//recordid 업데이트 해준다..
			NSString *updateRecordID = [NSString stringWithFormat:@"update _TUserInfo set recordid='%d' where INDEXNO=%@", ABRecordGetRecordID(newPerson), userInfo.INDEXNO];
			DebugLog(@"insert local %@ oldRecord %@", updateRecordID, userInfo.RECORDID);
			[UserInfo findWithSql:updateRecordID];
			[[UserInfo database] commit];
			DebugLog(@"index =%i dbCnt %d", index, [checkDBUserInfo count]);
			percent =  ((float)index/(float)[checkDBUserInfo count])*100;
			DebugLog(@"프로그래스 진행 상태 %f", percent);
			// 내보내기 개수 
			cur = index;
			[NSThread detachNewThreadSelector:@selector(showImg) toTarget:self withObject:nil];
			
			
			DebugLog(@"마지막 레코드 값은 얼마냐??? %d", ABRecordGetRecordID(newPerson));
			NSString *mDate =  [NSString stringWithFormat:@"%@",(NSString *)ABRecordCopyValue(newPerson,kABPersonModificationDateProperty)];
			/*
			 if([mDate isKindOfClass:[NSString class]])
			 {
			 DebugLog(@"mdate string...");
			 }
			 */	
			
			
			
			NSLog(@"마지막 저장 시간은1 %@", mDate);
			mDate = [self dateFormat:mDate];
			NSLog(@"마지막 저장 시간은 %@", mDate);
			
			
		
			
			
			
			//유세이 로컬 디비도 업데이트 해준다..
			 NSString *updateModifydate = [NSString stringWithFormat:@"update _TUserInfo set OEMMODIFYDATE='%@' where INDEXNO=%@", mDate, userInfo.INDEXNO];
			[UserInfo findWithSql:updateModifydate];
			[[UserInfo database] commit];
			
			
			
			
			CFRelease(newPerson);	//release 2010.12.15			
			
			//이거 해줘야지 다시 접속했을때 사용자 안 읽어온다.. 
			[self saveSyncData];	
		}
	//	CFRelease(sameGroupRef); //release 2010.12.15 하면 죽어버림..
	}
	
	
	
	self.navigationItem.rightBarButtonItem=nil;
	explainLabel.text=@"";
	
	if (flag == 1) {
		explainLabel.text=[NSString stringWithFormat:@"Usay 주소록 %d건을\niPhone 연락처로 내보냈습니다.\n(중복데이터 통합 완료)",[checkDBUserInfo count]];
		
		NSString *lastSyncDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastOemSync"];
		
		
		DebugLog(@"last = %@", lastSyncDate);
		NSString *dateTime;
				NSRange year, month, day, hour, mi, sec;
				year.location=0;
				year.length=4;
				month.location=4;
				month.length=2;
				day.location=6;
				day.length=2;
				hour.location=8;
				hour.length=2;
				mi.location=10;
				mi.length=2;
				sec.location=12;
				sec.length=2;
				
				
		dateTime = [NSString stringWithFormat:@"최근 내보내기 | %@.%@.%@ %@:%@", [lastSyncDate substringWithRange:year],
					[lastSyncDate substringWithRange:month],
					[lastSyncDate substringWithRange:day],
					[lastSyncDate substringWithRange:hour],
					[lastSyncDate substringWithRange:mi]];
				
		dateLabel.text = dateTime;
		curCount.text = @"";
		curCount2.text = @"";
	}
	else {
		explainLabel.text=@"주소록 내보내기를 완료 하였습니다.";	
	}


	sendButton.enabled=YES;
	[sendButton setImage:[UIImage imageNamed:@"7_btn_complete_2.png"] forState:UIControlStateNormal];
	complete=YES;
	leftButton.enabled=YES;
	
//	DebugLog(@"DataArray retainCnt = %d", [DataArray retainCount]);
	if([DataArray count] > 0)
		[DataArray removeAllObjects];

//	[DataArray release]; //alloc 를 안했기 때문에 release 할 이유가 없다..
	DataArray=nil;
	
//	DebugLog(@"DataArray retainCnt after = %d", [DataArray retainCount]);
	
	
	if(groupKeyDic != nil)
	{
		DebugLog(@"after removie groupKeyDic");
		if([groupKeyDic count] > 0)
			[groupKeyDic removeAllObjects];
		groupKeyDic = nil;
		
	}
	if(groupNameDic != nil)
	{
		DebugLog(@"after removie groupName");
		if([groupNameDic count] > 0)
			[groupNameDic removeAllObjects];
		groupNameDic = nil;
		
	}
	
	
	if(recordKeyDic !=nil)
	{
		[recordKeyDic removeAllObjects];
		recordKeyDic = nil;
	}
	
	
	DebugLog(@"groupKeyDic after = %d", [groupKeyDic retainCount]);
	
	
	CFIndex nPeople = ABAddressBookGetPersonCount(iPhoneAddressBook);
	
	
	DebugLog(@"nPeople = %i", nPeople);
	
	

	//주소 객체를 릴리즈 하면 객제를 사용하던 것들은 릴리즈 안해줘도 된다.. 하면 죽음...
//	CFRelease(allGroup);	// release 해주면 죽는다 2010.12.15
	CFRelease(iPhoneAddressBook); //release 하면 죽는다...
	
	UILabel *cntLabel = (UILabel*)[self.view viewWithTag:IPHONECNT];
	cntLabel.text=[NSString stringWithFormat:@"%i건", nPeople];
	
	
	if(pool)
	{
		DebugLog(@"find pool");
	}
	else
	{
		DebugLog(@"not pool");
	}
	 
	
	[pool release];




}




-(void)associateMobileToWebMain:(NSNotification *)notification
{
	DebugLog(@"모바일에서 웹으로");

	NSString *rtcode =[notification object];

	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	leftButton.enabled=YES;
	[sendButton setImage:[UIImage imageNamed:@"7_btn_complete_2.png"] forState:UIControlStateDisabled];

	
	
	
	//동기화가 완료됬으면..
	if ([rtcode isEqualToString:@"0"]) {			// success
		
		
		[self requestgetWebCnt];
		
		
		
		
		explainLabel.text=@"동기화가 완료되었습니다";
		
		
		
		sendButton.frame =CGRectMake(119, 105+(82/2), 83, 73);
		[sendButton setImage:[UIImage imageNamed:@"7_btn_complete_2.png"] forState:UIControlStateDisabled];
		sendButton.enabled=NO;
		
		sendButton2.hidden=YES;
		
		
		[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"SERVERLOGIN"];
		//2011.02.06 kjh 동기화 화면으로 변환
		[self startComplete];
		
		//return;
	}//앞에서 체크했기 때문에 여기까지 올수가 없다.
	else if([rtcode isEqualToString:@"-1080"]) {
		
		sendButton.frame =CGRectMake(119, 105+(82/2), 83, 73);
		
		
		
		[sendButton setImage:[UIImage imageNamed:@"7_btn_complete_2.png"] forState:UIControlStateDisabled];
		sendButton.enabled=NO;
		sendButton2.hidden=YES;
		
		explainLabel.text=@"이미 동기화가 완료되었습니다";
		[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"SERVERLOGIN"];
		UIAlertView *myAlert =[[UIAlertView alloc] 
							   initWithTitle:@"아이디 연동" 
							   message:@"이미 아이디가 연동되어 있습니다." 
							   delegate:self 
							   cancelButtonTitle:@"확인" 
							   otherButtonTitles:nil];
		[myAlert show];
		[myAlert release];
		
	}
	else if([rtcode isEqualToString:@"-9020"]) {
		sendButton.enabled=YES;
		
		UIAlertView *myAlert =[[UIAlertView alloc] 
							   initWithTitle:@"아이디 연동" 
							   message:@"파라미터 값이 잘못되었습니다." 
							   delegate:self 
							   cancelButtonTitle:@"확인" 
							   otherButtonTitles:nil];
		[myAlert show];
		[myAlert release];
		
	}
	else if([rtcode isEqualToString:@"-9030"]) {
		sendButton.enabled=YES;
		
		UIAlertView *myAlert =[[UIAlertView alloc] 
							   initWithTitle:@"아이디 연동" 
							   message:@"아이디가 연동되어 있지 않습니다." 
							   delegate:self 
							   cancelButtonTitle:@"확인" 
							   otherButtonTitles:nil];
		[myAlert show];
		[myAlert release];
		
	}
	else {
		sendButton.enabled=YES;
		UIAlertView *myAlert =[[UIAlertView alloc] 
							   initWithTitle:@"아이디 연동" 
							   message:@"처리 오류 입니다." 
							   delegate:self 
							   cancelButtonTitle:@"확인" 
							   otherButtonTitles:nil];
		[myAlert show];
		[myAlert release];
	}

}
-(void)deleteTableAll
{
	DebugLog(@"테이블 삭제");
	NSString *deleteDB = @"delete from _TUserInfo";
	NSString *deleteDB2 = @"delete from _TGroupInfo";
	NSString *deleteDB3 = @"delete from _TRoomInfo";
	NSString *deleteDB4 = @"delete from _TMessageInfo";
	NSString *deleteDB5 = @"delete from _TMessageUserInfo";
	[UserInfo findWithSql:deleteDB];
	[GroupInfo findWithSql:deleteDB2];
	[MessageInfo findWithSql:deleteDB4];
	[RoomInfo findWithSql:deleteDB3];
	[MessageUserInfo findWithSql:deleteDB5];
	
	
}

-(void)associateWebToMobileMain:(NSNotification *)notification
{
	DebugLog(@"Web ---> iPhone 주소록 연동 ...");
	
	
	
	[self stopTimer];
	
	
	
	leftButton.enabled=YES;
	
	
	
	/*
	sendButton2.frame =CGRectMake(119, 105+(82/2), 83, 73);
	[sendButton2 setImage:[UIImage imageNamed:@"7_btn_complete_1.png"] forState:UIControlStateDisabled];
	sendButton2.enabled=NO;
	sendButton.hidden=YES;
	*/
	
	
	leftButton.enabled=YES;
	
	
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	NSString *rtcode = [notification object];
	
	//동기화 하면 웹키로 친구리스트 요청
	if ([rtcode isEqualToString:@"0"]) {			// success
		
		
		
	//	[sendButton2 setImage:[UIImage imageNamed:@"7_btn_complete_1.png"] forState:UIControlStateDisabled];
		
		
		
		
		
		//기존 테이블 삭제 
		[self deleteTableAll];
		//서버로 그룹 요청
		
		//대화 목록 삭제 - mantis 0000178
		
		[[self appDelegate].msgListArray removeAllObjects];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadMsgList" object:nil]; //메세지 갱신
		
		
		[[self appDelegate].proposeUserArray removeAllObjects]; //추천친구 배열 삭제 - mantis 0000178
		
		UITabBarItem *tbi = [[self appDelegate].rootController.tabBar.items objectAtIndex:3];
		tbi.badgeValue = nil;
		
		
		
		[self requestGetGroups];	
		
		
		NSMutableArray* paramArray = [NSMutableArray array];
		NSString	*initializeCode = [NSString stringWithFormat:@"N"];	
		NSDictionary	*contactCnt = [NSDictionary dictionaryWithObjectsAndKeys:
									   [NSString stringWithFormat:@"0"], @"count",
									   nil];
		
		[paramArray addObject:contactCnt];
		NSDictionary	*contactDic = [NSDictionary dictionaryWithObjectsAndKeys: 
									   @"",  @"contact",
									   nil];
		
		[paramArray addObject:contactDic];
		
		NSDictionary *rpdict = [NSDictionary dictionaryWithObjectsAndKeys:
								@"0", @"RP",
								nil];
		[paramArray addObject:rpdict];
		// JSON 라이브러리 생성
		SBJSON *json = [[SBJSON alloc] init];
		[json setHumanReadable:YES];
		// 변환
		NSString *listbody = [json stringWithObject:paramArray error:nil];
		
		NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:
									initializeCode, @"initialize",
									[[NSUserDefaults standardUserDefaults] objectForKey:@"webKey"], @"svcidx",
									//[[self appDelegate] getSvcIdx],@"svcidx",
									listbody, @"param",
									nil];
		
		DebugLog(@"listBody = %@", listbody);
		
		
		[json release]; //release 2010.12.15
		
		
		
		//노티등록...
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addListContact:) name:@"addListContactIncludeGroup" object:nil];
		
		// 전송 
		USayHttpData *data = [[[USayHttpData alloc]initWithRequestData:@"addListContactIncludeGroup" andWithDictionary:bodyObject timeout:90]autorelease];
		DebugLog(@"\n----- [HTTP] OEM 주소록 전송 ( addListContactIncludeGroup ) ----->");
		[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
		DebugLog(@"웹 동기화 완료");
		
		
		
		
		
		
		[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"WebDownload"];
		//추천친구 내려받기
		[[self appDelegate] requestProposeUserList];
		//시스템 메세지
		
		
		/*
		NSMutableDictionary *bodyObject3 = [[[NSMutableDictionary alloc] init] autorelease];
		[bodyObject3 setObject:[[self appDelegate] getSvcIdx] forKey:@"svcidx"];
		NSString *initalize =@"Y";
		[bodyObject3 setObject:initalize forKey:@"initalize"];
		USayHttpData *data3 = [[[USayHttpData alloc] initWithRequestData:@"retrieveSystemMessage" andWithDictionary:bodyObject3 timeout:10] autorelease];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data3];
		*/
		
		[[self appDelegate] callSysteMsg:4];
		
		
		
		DebugLog(@"여기까지 오면 웹에서 모바일까지 동기화가 끗남..");
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
	}//여기도 내려 올수 없다...
	else if([rtcode isEqualToString:@"-1080"]) {
		[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"WebDownload"];
		[sendButton2 setImage:[UIImage imageNamed:@"7_btn_complete_1.png"] forState:UIControlStateDisabled];
		UIAlertView *myAlert =[[UIAlertView alloc] 
							   initWithTitle:@"아이디 연동" 
							   message:@"이미 아이디가 연동되어 있습니다." 
							   delegate:self 
							   cancelButtonTitle:@"확인" 
							   otherButtonTitles:nil];
		[myAlert show];
		[myAlert release];
	
	}
	else if([rtcode isEqualToString:@"-9020"]) {
		
		sendButton2.enabled=YES;
		
		
		UIAlertView *myAlert =[[UIAlertView alloc] 
							   initWithTitle:@"아이디 연동" 
							   message:@"파라미터 값이 잘못되었습니다." 
							   delegate:self 
							   cancelButtonTitle:@"확인" 
							   otherButtonTitles:nil];
		[myAlert show];
		[myAlert release];
		
	}
	else if([rtcode isEqualToString:@"-9030"]) {
		sendButton2.enabled=YES;
		
		UIAlertView *myAlert =[[UIAlertView alloc] 
							   initWithTitle:@"아이디 연동" 
							   message:@"아이디가 연동되어 있지 않습니다." 
							   delegate:self 
							   cancelButtonTitle:@"확인" 
							   otherButtonTitles:nil];
		[myAlert show];
		[myAlert release];
		
	}
	else {
		sendButton2.enabled=YES;
		UIAlertView *myAlert =[[UIAlertView alloc] 
							   initWithTitle:@"아이디 연동" 
							   message:@"처리 오류 입니다." 
							   delegate:self 
							   cancelButtonTitle:@"확인" 
							   otherButtonTitles:nil];
		[myAlert show];
		[myAlert release];
	}
}

-(void)isAlreadyAssociatedMain:(NSNotification *)notification
{
	
	DebugLog(@">>>>>>>>가입 여부 확인<<<<<<<<<");
	NSString *rtcode =[notification object];
	NSLog(@"rtcode =%@", rtcode);
	//이미 동기화를 한 사용자이면
	if([rtcode isEqualToString:@"0"])
	{
		
		leftButton.enabled=YES;
				
		
		explainLabel.text=@"Usay주소록 App과 Web을 동기화하시면\n주소록 데이터가 자동으로 업데이트 됩니다";
		
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		
		
		
		
		
		leftButton.enabled=YES;
		
		
		
				
		
		
		
		/*
		[sendButton setImage:[UIImage imageNamed:@"7_btn_complete_2.png"] forState:UIControlStateDisabled];
		[sendButton2 setImage:[UIImage imageNamed:@"7_btn_complete_1.png"] forState:UIControlStateDisabled];
		sendButton.enabled=NO;
		sendButton2.enabled=NO;
		 */
		
		
		/* 연동 되어 있다는 메세지 안보이게..
		UIAlertView *myAlert =[[UIAlertView alloc] 
							   initWithTitle:@"아이디 연동" 
							   message:@"이미 아이디가 연동되어 있습니다." 
							   delegate:self 
							   cancelButtonTitle:@"확인" 
							   otherButtonTitles:nil];
		[myAlert show];
		[myAlert release];
		
		 */
		[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"SERVERLOGIN"];
		
	
	
		//바로 실행하면 실행이 안되는 경우가 발생한다.
	//	[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(startComplete) userInfo:nil repeats:NO];
		
	[self startComplete];
		
		
		
		
		
	}
	else if([rtcode isEqualToString:@"-1010"]){
		

		//웹키로 웹에서 모바일 테이터를 요청
		if(flag2 == 2)
		{
			sendButton2.enabled=NO;
			//웹 --> 유세이..
			NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
			[bodyObject setObject:@"ucmbip" forKey:@"svcidx"];
			[bodyObject setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"webKey"] forKey:@"webPKey"];
			//	[bodyObject setObject:[[self appDelegate].myInfoDictionary objectForKey:@"pkey"] forKey:@"pKey"];

			
			USayHttpData *data = [[[USayHttpData alloc] 
								   initWithRequestData:@"associateWebToMobile" 
								   andWithDictionary:bodyObject timeout:10] autorelease];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
			
		}
		//웹키로 모바일에서 웹으로 요청
		if(flag2 == 1)
		{
			
			//유세이 -> 웹
			NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
			[bodyObject setObject:@"ucmbip" forKey:@"svcidx"];
			[bodyObject setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"webKey"] forKey:@"webPKey"];
			USayHttpData *data = [[[USayHttpData alloc] 
								   initWithRequestData:@"associateMobileToWeb" 
								   andWithDictionary:bodyObject timeout:10] autorelease];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
		}
	}
	else if([rtcode isEqualToString:@"-1080"])
	{
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		leftButton.enabled=YES;
		sendButton.enabled=YES;
		sendButton2.enabled=YES;
		UIAlertView *myAlert =[[UIAlertView alloc] 
							   initWithTitle:@"아이디 연동" 
							   message:@"해당 pKeyrk가 존재 하지 않음" 
							   delegate:self 
							   cancelButtonTitle:@"확인" 
							   otherButtonTitles:nil];
		[myAlert show];
		[myAlert release];
		
	}
	else {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		leftButton.enabled=YES;
		sendButton.enabled=YES;
		sendButton2.enabled=YES;
		UIAlertView *myAlert =[[UIAlertView alloc] 
							   initWithTitle:@"아이디 연동" 
							   message:@"파라미터 오류" 
							   delegate:self 
							   cancelButtonTitle:@"확인" 
							   otherButtonTitles:nil];
		[myAlert show];
		[myAlert release];
		
	}


	
	
	//웹키 호출..
	/*
	NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
	[bodyObject setObject:@"ucmbip" forKey:@"svcidx"];
	
	
	[bodyObject setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"webKey"] forKey:@"webPKey"]
	//[bodyObject setObject:[[self appDelegate].myInfoDictionary objectForKey:@"pkey"] forKey:@"webPKey"];
	
	
	USayHttpData *data = [[[USayHttpData alloc] 
						   initWithRequestData:@"associateWebToMobile" 
						   andWithDictionary:bodyObject timeout:10] autorelease];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
	 */
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	DebugLog(@"btn index %i", buttonIndex);
	if(buttonIndex == 0)
	{
		
		if(alertView.tag==USAYTOIPHONE)
		{
//			[JYGanTracker trackEvent:@"button_click" action:TAG_EVENT_SYNC_USAYTOOEM label:@"event_saveiPhone"];

			//explainLabel.text=@"";
			// sochae 2010.12.23 - delete = NO;
			[NSThread detachNewThreadSelector:@selector(saveiPhone) toTarget:self withObject:nil];
			
			[self saveSyncData];
		}
/*		if(alertView.tag==BACKTOIPHONE)
		{
			explainLabel.text=@"";
			explainLabel.text=@"iPhone 연락처를 복원 중입니다.\n 주소록 데이터가 많은 경우 시간이 오래 걸릴 수 있습니다.";
			
			[NSThread detachNewThreadSelector:@selector(recoverOem) toTarget:self withObject:nil];	
		}
*/		if(alertView.tag==WEBTOMOBILE) //웹에서 모바일..
		{
			
			
//			[JYGanTracker trackEvent:@"button_click" action:TAG_EVENT_SYNC_WEBTOUSAY label:@"event_webtousay"];

			explainLabel.text=@"동기화 중입니다.\n 주소록 데이터가 많은 경우 시간이 오래 걸릴 수 있습니다.";
			//[NSThread detachNewThreadSelector:@selector(startTimerThread) toTarget:self withObject:nil];	
			[self startTimer];	// sochae 2010.12.29

			[self weReadThread];			
		
			sendButton2.frame =CGRectMake(119, 105+(82/2), 83, 73);
			[sendButton2 setImage:[UIImage imageNamed:@"7_btn_back_bg.png"] forState:UIControlStateDisabled];
			sendButton2.enabled=NO;
			
			sendButton.hidden=YES;
		}
		if(alertView.tag==MOBILETOWEB) //모바일에서 웹.
		{
//			[JYGanTracker trackEvent:@"button_click" action:TAG_EVENT_SYNC_USAYTOWEB label:@"event_usaytoweb"];
			
			
			NSLog(@"모바일을 웨브로");
			explainLabel.text=@"";
			explainLabel.text=@"동기화 중입니다.\n 주소록 데이터가 많은 경우 시간이 오래 걸릴 수 있습니다.";			
			[self usaytoweb];			
			
		}
	}
/*	else if(buttonIndex == 2){
		
		if(alertView.tag==USAYTOIPHONE)
		{
			
			delete = YES;	
			[NSThread detachNewThreadSelector:@selector(saveiPhone) toTarget:self withObject:nil];
			[self saveSyncData];
		}
	}
*/// sochae 2010.12.23
	else
	{
		if (groupCheckButton != nil)
			groupCheckButton.enabled = YES;		// sochae 2010.12.28
		
		if(alertView.tag==USAYTOIPHONE || alertView.tag == BACKTOIPHONE)
		{
			sendButton.enabled=YES;
			leftButton.enabled=YES;
		}
		else if(alertView.tag==CANCLE)
		{
			sendButton.enabled=YES;
			leftButton.enabled=YES;
		}
		else {
			
			
			/* 임시 주석
			//업로드 동기화를 했으면
			if([[[NSUserDefaults standardUserDefaults] objectForKey:@"WebUpload"] isEqualToString:@"YES"])
			{
				[sendButton setImage:[UIImage imageNamed:@"7_btn_complete_2.png"] forState:UIControlStateDisabled];
				sendButton.enabled=NO;
			}
			
			//다운로드 동기화를 했으면
			if([[[NSUserDefaults standardUserDefaults] objectForKey:@"WebDownload"] isEqualToString:@"YES"])
			{
				[sendButton2 setImage:[UIImage imageNamed:@"7_btn_complete_1.png"] forState:UIControlStateDisabled];
				sendButton2.enabled=NO;
			}
		*/
			leftButton.enabled=YES;
		}
		
	}

}

-(void)deleteAllGroup
{
	
}

-(void)usaytoweb
{
	
	
	flag2=1;
	NSMutableDictionary *bodyObject2 = [[[NSMutableDictionary alloc] init] autorelease];
	[bodyObject2 setObject:@"ucmbip" forKey:@"svcidx"];
	// sochae 2011.02.18 - 웹 연동 시의 서로 다른 단말에서 같은 웹 계정으로 로그인 후 한쪽만 웹 동기화 하면 나머지도 동기화 된 것 처럼 보이는 문제에 대한 예외처리 ( 안드로이드만 발생 되었음 )
	//[bodyObject2 setObject:[[self appDelegate].myInfoDictionary objectForKey:@"pkey"] forKey:@"pKey"];
	[bodyObject2 setObject:[[self appDelegate].myInfoDictionary objectForKey:@"pkey"] forKey:@"myPKey"];
	[bodyObject2 setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"webKey"] forKey:@"pKey"];
	// ~sochae
	
	USayHttpData *data2 = [[[USayHttpData alloc] 
							initWithRequestData:@"isAlreadyAssociated" 
							andWithDictionary:bodyObject2 timeout:10] autorelease];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data2];
}


-(UIAlertView*)makeAlertView
{
	NSString *msg = nil;
	
	switch (flag)
	{
		case 0:		// 복원하기
			{
				msg = [NSString stringWithFormat:@"iPhone연락처가 백업되어 있는 기존의 데이터로 다시 대체됩니다.\n\n\"복원하기\"를 진행하시겠습니까?"];
			}
			break;
			
		case 1:		// 내보내기
			{
				// Usay 주소록 개수
				NSArray *checkDBUserInfo = [UserInfo findWithSql:QUERY_USER_NO_BLOCK];
				msg = [NSString stringWithFormat:@"Usay주소록 데이터를 iPhone 연락처로 내보내시겠습니까?\n\n※ 내보내기 시 중복 여부를 체크하여 동일한 주소록을 정리 해 드립니다.", [checkDBUserInfo count]];
				
				//	msg = [NSString stringWithFormat:@"iPhone연락처는 삭제되고 Usay주소록(%d건)정보로 대체됩니다.\n(*삭제된 데이터는 자동백업되어 복원가능)\n\n\"내보내기\"를 진행하시겠습니까?", [checkDBUserInfo count]];
			}
			break;
			
		case 2:		// 웹과 동기화
			{
				NSArray *checkDBUserInfo = [UserInfo findWithSql:QUERY_USER_NO_BLOCK];
				msg = [NSString stringWithFormat:@"Web주소록이 App주소록(%d건)정보로 대체됩니다.\n동기화 된 Web주소록은 복원하실 수 없습니다.\n\n\"동기화\"를 진행하시겠습니까?", [checkDBUserInfo count]];
			}
			break;
		

	}
	UIAlertView *alertView;
/*	if(flag == 1)
	{
		alertView = [[UIAlertView alloc] initWithTitle:@"" 
														message:msg 
													   delegate:nil 
											  cancelButtonTitle:@"확인" 
											  otherButtonTitles:@"취소", nil];
	}
	else
*/// sochae 2010.12.29 - cLang
	{
		alertView = [[[UIAlertView alloc] initWithTitle:@"" 
												message:msg 
											   delegate:nil 
									  cancelButtonTitle:@"확인" 
									  otherButtonTitles:@"취소", nil] autorelease];
	}

	/*	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"동기화" 
														message:@"정말 동기화 하시겠습니까?" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:@"취소", nil];
*/	alertView.delegate=self;
//	[alertView release];
	return alertView;
}

// 내보내기 버튼 선택 시
-(void)pushIPhoneSync
{
	
	
	
	leftButton.enabled=NO;
	
	
	
	
	if(flag == 0 || flag == 1)
	{
		sendButton.enabled = NO;
		groupCheckButton.enabled = NO;
	}

	if(flag == 1){ //아이폰으로 내보내기.
		if(complete==YES)
		{
			sendButton.enabled=YES;
			leftButton.enabled=YES;
			explainLabel.text = @"";
			explainLabel.text = DEF_TEXT_EXPORT;
			[sendButton setImage:[UIImage imageNamed:@"7_btn_send.png"] forState:UIControlStateNormal];
			[sendButton setImage:[UIImage imageNamed:@"7_btn_send_bg.png"] forState:UIControlStateDisabled];
			complete=NO;
			groupCheckButton.enabled = YES;
			
			// TODO: 여기에 내보내기 이후의 개수 초기화
			return;
			
		}

		UIAlertView *alertView = [self makeAlertView];
		alertView.tag = USAYTOIPHONE;
		[alertView show];
// sochae 2010.12.29 - cLang		[alertView release];

	}
/* sochae -		else if(flag == 0) { //복원하기..
		
		
		
		NSString *lastSyncDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastOemSync"];
		if(lastSyncDate == nil)
		{
			DebugLog(@"내역 없음");
			leftButton.enabled=YES;
			sendButton.enabled=YES;
			return;
		}
		if(complete2==YES)
		{
			sendButton.enabled=YES;
			leftButton.enabled=YES;
			explainLabel.textColor=ColorFromRGB(0x56575C);
			
			
			explainLabel.text=@"Usay주소록 내보내기 시 백업 되었던 iPhone연락처 데이터가 복원됩니다.";	
			[sendButton setImage:[UIImage imageNamed:@"7_btn_backup.png"] forState:UIControlStateNormal];
			[sendButton setImage:[UIImage imageNamed:@"7_btn_backup_bg.png"] forState:UIControlStateDisabled];
			
			
			
			complete2=NO;
			return;
			
		}
		
		
		UIAlertView *alertView = [self makeAlertView];
		alertView.tag=BACKTOIPHONE;
		[alertView show];
		[alertView release];
	}
*/	else
	{
		//완료에서 다시 클릭 했을 경우 근데 이걸 왜함???
		
		UIAlertView *alertView = [self makeAlertView];
		alertView.tag=MOBILETOWEB;
		[alertView show];
// sochae 2010.12.29 - cLang		[alertView release];	
		
		
		
		[sendButton setImage:[UIImage imageNamed:@"7_btn_send.png"] forState:UIControlStateNormal];
		[sendButton setImage:[UIImage imageNamed:@"7_btn_send_bg.png"] forState:UIControlStateDisabled];
		
		[sendButton addTarget:self action:@selector(pushIPhoneSync) forControlEvents:UIControlEventTouchUpInside];
		
		
		
		
	}
}
-(void)backBarButtonClicked
{
	[self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark <--- 서버 그룹 목록 수신 (getGroups)
-(void)getGroups:(NSNotification *)notification
{
	DebugLog(@"\n----- [HTTP] 서버 그룹 목록 수신 ( getGroups ) ---------->");
	USayHttpData *data = (USayHttpData*)[notification object];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"getGroups" object:nil];
	
	if (data == nil) {
		
		// 200 이외의 에러
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" 
															message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0015)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return;
	}
	
	//	NSString *api = data.api;	
	NSString *resultData = data.responseData;
	//기본 적인 정보가 내려온다. 새로 등록한 주소, 친구, 가족
	DebugLog(@"resultData = %@", resultData);
	
	// 1. Create BSJSON parser.
	SBJSON *jsonParser = [[SBJSON alloc] init];
	
	// 2. Get the result dictionary from the response string.
	NSDictionary *dic = (NSDictionary*)[jsonParser objectWithString:resultData error:NULL];
	[jsonParser release];
	// 3. Show response
	// key and value type
	NSString *rtcode = nil;
	rtcode = [dic objectForKey:@"rtcode"];	// 프로토콜문서에는 result로 되어 있는것을 rtcode로 변경
	if ([rtcode isEqualToString:@"0"]) {	// success
		NSString *rtType = [dic objectForKey:@"rttype"];
		//		NSString *count = [dic objectForKey:@"count"];  
		if([rtType isEqualToString:@"list"]){
			//list 새로등록한주소, 친구, 가족
			for(NSDictionary *addressDic in [dic objectForKey:@"list"]) {
				
				GroupInfo* groupData = [[GroupInfo alloc] init];
				NSArray* keyArray = [addressDic allKeys];
				//딕셔너리에서 그룹타이틀, 아이디, 그룹별 카운트 숫자 기본은 0,0,0 으로 내려온다.
				for(NSString* key in keyArray) {
					if([key isEqualToString:@"title"]){ 
						[groupData  setValue:[addressDic objectForKey:key] forKey:@"GROUPTITLE"];
					}else if([key isEqualToString:@"id"]) {
						[groupData  setValue:[addressDic objectForKey:key] forKey:@"ID"];
					}else if([key isEqualToString:@"contactCount"]) {
						[groupData  setValue:[addressDic objectForKey:key] forKey:@"CONTACTCOUNT"];
					}
				}
				//로컬 디비에 인서트 하거나 업데이트 맨처음 할 경우는 인서트 나머진 업데이트???
				// MARK: [DB] 수신받은 그룹 local DB 저장 ===== >
				[groupData saveSyncData];
				[groupData release];
				
			}
		}else {
			//에러
		}
		
		
	} else if ([rtcode isEqualToString:@"-9030"]) {
		// TODO: 처리 오류
		UIAlertView* failAlert = [[UIAlertView alloc] initWithTitle:@"그룹 정보 확인 실패" 
															message:@"그룹 확인을 실패하였습니다.(-9030)" 
														   delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[failAlert show];
		[failAlert release];
	} else {
		// TODO: 기타오류 예외처리 필요
		NSString* errCode = [NSString stringWithFormat:@"그룹 확인을 실패하였습니다.(%@)",rtcode];
		UIAlertView* failAlert = [[UIAlertView alloc] initWithTitle:@"그룹 정보 확인 실패" 
															message:errCode 
														   delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[failAlert show];
		[failAlert release];
	}
	
	/*임시 코딩
	 
	 
	 GroupInfo* groupData = [[GroupInfo alloc] init];
	 [groupData  setValue:@"새로 등록한 주소" forKey:@"GROUPTITLE"];
	 [groupData  setValue:@"0" forKey:@"ID"];
	 [groupData  setValue:@"0" forKey:@"CONTACTCOUNT"];
	 [groupData saveSyncData];
	 [groupData release];
	 
	 
	 */
}

-(void)requestGetGroups
{
	NSString *initCode = @"N";
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getGroups:) name:@"getGroups" object:nil];
	NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:
								[[self appDelegate] getSvcIdx], @"svcidx",
								initCode, @"initialize",
								nil];
	USayHttpData *data = [[[USayHttpData alloc]initWithRequestData:@"getGroups" andWithDictionary:bodyObject timeout:10]autorelease];	
	DebugLog(@"\n----- [HTTP] 서버 그룹 목록 요청 ( getGroups ) initialize:Y ----->");
	[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
}


-(void)cancleAction
{
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" 
														message:@"주소록 내보내기를 취소 하시겠습니까?" 
													   delegate:nil 
											  cancelButtonTitle:@"확인" 
											  otherButtonTitles:@"취소", nil];
	alertView.delegate=self;
	alertView.tag=CANCLE;
	[alertView show];
	[alertView release];
}

-(void)weReadThread
{
	flag2=2;
	//이미 동기화 했는지 안했는지 체크를 한다.. 웹키가지고 한다.
	NSMutableDictionary *bodyObject2 = [[[NSMutableDictionary alloc] init] autorelease];
	[bodyObject2 setObject:@"ucmbip" forKey:@"svcidx"];
	// sochae 2011.02.18 - 웹 연동 시의 서로 다른 단말에서 같은 웹 계정으로 로그인 후 한쪽만 웹 동기화 하면 나머지도 동기화 된 것 처럼 보이는 문제에 대한 예외처리 ( 안드로이드만 발생 되었음 )
	//[bodyObject2 setObject:[[self appDelegate].myInfoDictionary objectForKey:@"pkey"] forKey:@"pKey"];
	[bodyObject2 setObject:[[self appDelegate].myInfoDictionary objectForKey:@"pkey"] forKey:@"myPKey"];
	[bodyObject2 setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"webKey"] forKey:@"pKey"];
	// ~sochae
	
	USayHttpData *data2 = [[[USayHttpData alloc] 
						   initWithRequestData:@"isAlreadyAssociated" 
						   andWithDictionary:bodyObject2 timeout:10] autorelease];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data2];
	return;
}

-(void)webReadData
{
	NSString *msg = [NSString stringWithFormat:@"App주소록이 Web주소록(%@) 정보로 대체됩니다.\n동기화 된 App주소록은 복원하실 수 없습니다.\n\n\"동기화\"를 진행하시겠습니까?", webCntLabel.text];
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" 
														message:msg delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:@"취소", nil];
	
	alertView.tag=WEBTOMOBILE;
	alertView.delegate=self;
	[alertView show];
	[alertView release];
}


-(void)getContactsCount:(NSNotification *)notification {
	
	
	DebugLog(@"여기로 카운트 들어와야함");
	DebugLog(@"\n----- 웹 그룹 카운ㅌ, ---------->");
	USayHttpData *data = (USayHttpData*)[notification object];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"getGroups" object:nil];
	
	if (data == nil) {
		
		// 200 이외의 에러
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" 
															message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0015)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return;
	}
	
	//	NSString *api = data.api;	
	NSString *resultData = data.responseData;
	//기본 적인 정보가 내려온다. 새로 등록한 주소, 친구, 가족
	DebugLog(@"resultData = %@", resultData);
	
	// 1. Create BSJSON parser.
	SBJSON *jsonParser = [[SBJSON alloc] init];
	
	// 2. Get the result dictionary from the response string.
	NSDictionary *dic = (NSDictionary*)[jsonParser objectWithString:resultData error:NULL];
	[jsonParser release];
	// 3. Show response
	// key and value type
	NSString *rtcode = nil;
	rtcode = [dic objectForKey:@"rtcode"];	// 프로토콜문서에는 result로 되어 있는것을 rtcode로 변경
	if ([rtcode isEqualToString:@"0"]) {	// success
		NSString *rtType = [dic objectForKey:@"rttype"];
		//		NSString *count = [dic objectForKey:@"count"];  
		if([rtType isEqualToString:@"map"]){
		
			
			
			NSDictionary *cntDic = [dic objectForKey:@"map"];
			
			
			webCnt = [cntDic objectForKey:@"count"];
			
			DebugLog(@"webCnt = %@", webCnt);
			
			
			webCntLabel.text=[NSString stringWithFormat:@"%@건", webCnt];
			
			
			
		}
	} else if ([rtcode isEqualToString:@"-9030"]) {
		// TODO: 처리 오류
		UIAlertView* failAlert = [[UIAlertView alloc] initWithTitle:@"웹 주소록" 
															message:@"조회 실패(-9030)" 
														   delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[failAlert show];
		[failAlert release];
	} else {
		// TODO: 기타오류 예외처리 필요
		NSString* errCode = [NSString stringWithFormat:@"웹 주소록",rtcode];
		UIAlertView* failAlert = [[UIAlertView alloc] initWithTitle:@"알수 없는 에러.." 
															message:errCode 
														   delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[failAlert show];
		[failAlert release];
	}
	
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	
	
	
	
}

#pragma mark 웹 주소록 개수 요청
-(void)requestgetWebCnt
{
	NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:
								[[self appDelegate] getSvcIdx], @"svcidx",
								[JYUtil loadFromUserDefaults:kWebPKey], kPKey,
								nil];
	USayHttpData *data = [[[USayHttpData alloc]initWithRequestData:@"getContactsCount" andWithDictionary:bodyObject timeout:10]autorelease];	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
	
	
	DebugLog(@"카운트 리퀘스트 %@", bodyObject);
}

-(void)removeAllGroup
{
	ABAddressBookRef iPhoneAddressBook = ABAddressBookCreate();
	CFIndex nGroup = ABAddressBookGetGroupCount(iPhoneAddressBook);
	CFArrayRef allGroup = ABAddressBookCopyArrayOfAllGroups(iPhoneAddressBook);
	
	//OEM 그룹 삭제
	for(int i=0; i< nGroup; i++)
	{
		
		//그룹 정보
		ABRecordRef ref = CFArrayGetValueAtIndex(allGroup, i);
		CFStringRef groupTitle = ABRecordCopyValue(ref, kABGroupNameProperty);
	//	NSString *RecordID = [NSString stringWithFormat:@"%i", ABRecordGetRecordID(ref)];
//		DebugLog(@"삭제 그룹명[%@]  레코드 아이디[%@]", (NSString*)groupTitle, RecordID);
		ABAddressBookRemoveRecord(iPhoneAddressBook, ref, nil);
		ABAddressBookSave(iPhoneAddressBook, nil);
		
		CFRelease(groupTitle);
	}
//	CFRelease(iPhoneAddressBook);
	NSLog(@"oem 그룹 삭제 완료");
	CFRelease(iPhoneAddressBook);
//	CFRelease(allGroup);
	
}

- (void)checkBoxClicked
{
	delete = !delete;
	if (delete == NO)
	{
		[groupCheckButton setImage:[UIImage imageNamed:@"chkbox_off.png"] forState:UIControlStateNormal];
	}
	else
	{
		[groupCheckButton setImage:[UIImage imageNamed:@"chkbox_on.png"] forState:UIControlStateNormal];
//		[self removeAllGroup];
	}

}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	DebugLog(@"===== 내보내기 화면 =====>");
	
	
	complete=NO;
	complete2=NO;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getContactsCount:) name:@"getContactsCount" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getGroups:) name:@"getGroups" object:nil];
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addListContact:) name:@"addListContactIncludeGroup" object:nil];
	
	
	/* sochae 2010.12.16 - 복구 기능 삭제
	NSArray *tableNames = [[self appDelegate].database tableNames];
	if(![tableNames containsObject:[backUserInfo tableName]])
	{
		
		DebugLog(@"backUserInfo %@", [backUserInfo tableName]);
		
		backUserInfo* backuserInfo = [[backUserInfo alloc] init];
		[backuserInfo createTableForClass];
		
		[backuserInfo release];
		
    }
	if(![tableNames containsObject:[backGroupInfo tableName]])
	{
		
		DebugLog(@"backUserInfo %@", [backGroupInfo tableName]);
		
		backGroupInfo* backgroupInfo = [[backGroupInfo alloc] init];
		[backgroupInfo createTableForClass];
		
		[backgroupInfo release];
		
    }
	*/
	
	ABAddressBookRef iPhoneAddressBook = ABAddressBookCreate();
//	iPhoneAddressBook   = ABAddressBookCreate();
	NSString *fromUsaytoOem = @"select * from _TUserInfo where ISBLOCK='N'";
	NSArray *checkDBUserInfo = [UserInfo findWithSql:fromUsaytoOem];
	CFIndex nPeople = ABAddressBookGetPersonCount(iPhoneAddressBook);	
//	CFRelease(iPhoneAddressBook); //release 2010.12.15
	
	
	
	
	
	
	self.view.backgroundColor=ColorFromRGB(0xF1F3F5);	
	
	UIScrollView *mainScrollView = [[UIScrollView alloc] init];
	
	
	if(flag == 2)
	{
		mainScrollView.frame=CGRectMake(0, 0, 320, 460);
		mainScrollView.contentSize = CGSizeMake(320, 460);
	}
	else {
		mainScrollView.frame=CGRectMake(0, 0, 320, 460-44);
		mainScrollView.contentSize = CGSizeMake(320, 600-20);
	}

	
	/*
	if (flag ==2) {
		mainScrollView.contentSize =	CGSizeMake(320, 460);
	}else
	{
		mainScrollView.contentSize =	CGSizeMake(320, 600-30);
	}
	*/
	
	[self.view addSubview:mainScrollView];
	
	
	
	
	UILabel *iPhoneCntLabel, *UsayCntLabel, *iPhoneNameLabel, *UsayNameLabel;
	UsayNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 270, 82, 13)];
	UsayNameLabel.text=@"Usay주소록";
	UsayNameLabel.textColor=ColorFromRGB(0x16acc2);
	UsayNameLabel.font=[UIFont systemFontOfSize:13];
	
	
	
	explainLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 320-30, 60)];
	explainLabel.numberOfLines=3;
	explainLabel.textColor=ColorFromRGB(0x053844);
	
	
	iPhoneNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(320-15-82, 270, 82, 13)];
	
	explainLabel.backgroundColor=[UIColor clearColor];
	UIView *UsayView =[[UIView alloc] initWithFrame:CGRectMake(15, 15+150+50+50+40, 320, 40)];
	UsayView.backgroundColor=[UIColor clearColor];
	//내보내기 이미지 셋ㅌ팅..
	sendButton =[UIButton buttonWithType:UIButtonTypeCustom];
	sendButton2 =[UIButton buttonWithType:UIButtonTypeCustom];
	sendButton.frame=CGRectMake(40+82, 105+43.5, 83, 73);

	// sochae - 내보내기 진행 개수 표시.
	curCount = [[UILabel alloc] initWithFrame:CGRectMake(120, 230-120, 90, 30)];
	curCount.textColor = ColorFromRGB(0x16acc2);
//	curCount.font = [UIFont systemFontOfSize:18];
	curCount.font = [UIFont systemFontOfSize:12];
	curCount.textAlignment = UITextAlignmentCenter;
	curCount.backgroundColor = [UIColor clearColor];
//	curCount.text = [NSString stringWithFormat:@"0/%i", [checkDBUserInfo count]];
	curCount.text = [NSString stringWithFormat:@""];
	[mainScrollView addSubview:curCount];
	
	
//디자인 변경
	curCount2 = [[UILabel alloc] initWithFrame:CGRectMake(120, 230-150, 90, 30)];
	curCount2.textColor = ColorFromRGB(0x16acc2);
	curCount2.font = [UIFont systemFontOfSize:30];
	curCount2.textAlignment = UITextAlignmentCenter;
	curCount2.backgroundColor = [UIColor clearColor];
	curCount2.text = [NSString stringWithFormat:@""];
	[mainScrollView addSubview:curCount2];
	
	
	// ~sochae
	
	iPhoneNameLabel.textColor=ColorFromRGB(0x16acc2);
	iPhoneNameLabel.font=[UIFont systemFontOfSize:13];
	iPhoneCntLabel = [[UILabel alloc] initWithFrame:CGRectMake(320-15-82, 270+15, 82, 20)];
	webCntLabel = [[UILabel alloc] initWithFrame:CGRectMake(320-15-82, 270+15, 82, 20)];
	UsayCntLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 270+15, 82, 20)];
	
	
/* sochae -
	if(flag == 0)
	{
		iPhoneNameLabel.text=@"iPhone연락처";
		NSArray *CntArray =  [backUserInfo findAll];
		iPhoneCntLabel.text=[NSString stringWithFormat:@"%d건", [CntArray count]];
		CntArray = nil;	
		explainLabel.text=@"Usay주소록 내보내기 시 백업 되었던 iPhone연락처 데이터가 복원됩니다.";	
		[sendButton setImage:[UIImage imageNamed:@"7_btn_backup.png"] forState:UIControlStateNormal];
		[sendButton setImage:[UIImage imageNamed:@"7_btn_backup_bg.png"] forState:UIControlStateDisabled];
		
		
	}
	else
*/	if(flag == 1)
	{
		iPhoneNameLabel.text=@"iPhone연락처";
		iPhoneCntLabel.tag=IPHONECNT;
		iPhoneCntLabel.text=[NSString stringWithFormat:@"%i건", nPeople];
		
		explainLabel.text = DEF_TEXT_EXPORT;
		[sendButton setImage:[UIImage imageNamed:@"7_btn_send.png"] forState:UIControlStateNormal];
		[sendButton setImage:[UIImage imageNamed:@"7_btn_send_bg.png"] forState:UIControlStateDisabled];
		
	}
	else { //웹과 동기화 쪽..
		
		[self requestgetWebCnt];
		iPhoneNameLabel.text=@"usay.net";
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isAlreadyAssociatedMain:) name:@"isAlreadyAssociatedMain" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(associateWebToMobileMain:) name:@"associateWebToMobileMain" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(associateMobileToWebMain:) name:@"associateMobileToWebMain" object:nil];
		//explainLabel.font=[UIFont systemFontOfSize:15];
		explainLabel.text=@"원하는 기능을 선택해 주세요.";	
		
		if([[NSUserDefaults standardUserDefaults] objectForKey:@"SERVERLOGIN"])
		{
			[sendButton setImage:[UIImage imageNamed:@"7_btn_send.png"] forState:UIControlStateNormal];
			[sendButton2 setImage:[UIImage imageNamed:@"7_btn_back.png"] forState:UIControlStateNormal];
			/* 임시
			[sendButton setImage:[UIImage imageNamed:@"7_btn_complete_2.png"] forState:UIControlStateDisabled];
			[sendButton2 setImage:[UIImage imageNamed:@"7_btn_complete_1.png"] forState:UIControlStateDisabled];
			
			sendButton.enabled=NO;
			sendButton2.enabled=NO;
			*/
		}
		else
		{
			[sendButton setImage:[UIImage imageNamed:@"7_btn_send.png"] forState:UIControlStateNormal];
			[sendButton2 setImage:[UIImage imageNamed:@"7_btn_back.png"] forState:UIControlStateNormal];
		}
		
		[sendButton2 addTarget:self action:@selector(webReadData) forControlEvents:UIControlEventTouchUpInside];
		sendButton2.frame=CGRectMake(122, 110+73, 83, 73);
		
		sendButton.frame=CGRectMake(40+82, 105, 83, 73);
		
			[mainScrollView addSubview:sendButton2];
	}
	CFRelease(iPhoneAddressBook); // sochae 2010.12.28
	
	UsayCntLabel.text=[NSString stringWithFormat:@"%d건", [checkDBUserInfo count]];
	UsayCntLabel.tag=USAYCNT;
	checkDBUserInfo=nil;
	
					   
	
	UsayCntLabel.textColor=ColorFromRGB(0x053844);
	iPhoneCntLabel.textColor=ColorFromRGB(0x053844);
	webCntLabel.textColor=ColorFromRGB(0x053844);
	
	webCntLabel.font=[UIFont systemFontOfSize:20];
	iPhoneCntLabel.font=[UIFont systemFontOfSize:20];
	UsayCntLabel.font=[UIFont systemFontOfSize:20];
	
	webCntLabel.textAlignment=UITextAlignmentCenter;
	iPhoneCntLabel.textAlignment=UITextAlignmentCenter;
	UsayCntLabel.textAlignment=UITextAlignmentCenter;
	iPhoneNameLabel.textAlignment=UITextAlignmentCenter;
	UsayNameLabel.textAlignment=UITextAlignmentCenter;
	
	
	
	UsayCntLabel.backgroundColor=[UIColor clearColor];
	UsayNameLabel.backgroundColor=[UIColor clearColor];
	
	
	
	
	webCntLabel.backgroundColor=[UIColor clearColor];
	iPhoneCntLabel.backgroundColor=[UIColor clearColor];
	iPhoneNameLabel.backgroundColor=[UIColor clearColor];
	

	[mainScrollView addSubview:UsayCntLabel];
	if(flag == 0 || flag == 1)
		[mainScrollView addSubview:iPhoneCntLabel];
	else {
		[mainScrollView addSubview:webCntLabel];	
	}

	
	
	
	
	
	
	
//	UIScrollView *warningScrollView =[[UIScrollView alloc] initWithFrame:CGRectMake(0, 295+18, 320, 460-44-295-18)];
//	warningScrollView.contentSize=CGSizeMake(320, 180);

	
	warningDetailText =[[UILabel alloc] initWithFrame:CGRectMake(0, 345-20+40, 320, 600-30-320)];
	
	if(flag == 0 || flag == 1)
	{
		warningDetailText.text = @"     ∙ Usay주소록과 iPhone연락처에 저장된\n       데이터를 비교하여 중복된 주소록은 \n       정리합니다.\n\n     ※ 중복체크 기준: 이름, 이메일, 전화번호 중\n        2개 이상 데이터가 같으면 동일 인물로\n        판단하여 중복체크 됨\n\n     ※ 합치기 기준: 중복체크된 데이터 중 최근\n        등록된 기준으로 데이터가 합쳐짐";
	}
	else {
		warningDetailText.text=@"";
	}

	warningDetailText.numberOfLines=13;
	warningDetailText.font=[UIFont systemFontOfSize:13];
	warningDetailText.textColor=ColorFromRGB(0x053844);
	
	
	
	
	
	
//	[warningScrollView addSubview:warningDetailText];
//	[mainScrollView addSubview:warningScrollView];

	if(flag != 2)
		[mainScrollView addSubview:warningDetailText];
	
	
	explainLabel.font=[UIFont systemFontOfSize:14];
	[sendButton addTarget:self action:@selector(pushIPhoneSync) forControlEvents:UIControlEventTouchUpInside];
	
	
	
	
	
	
	
	
	
	
	
	
	/*
	UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 44)];
	UIFont *titleFont = [UIFont systemFontOfSize:20];
	//	CGSize titleStringSize = [@"주소록 동기화" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
	UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 210, 44)];
	[titleLabel setFont:titleFont];
	titleLabel.textAlignment = UITextAlignmentCenter;
	[titleLabel setTextColor:ColorFromRGB(0x053844)];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	if(flag == 1)
		[titleLabel setText:@"내보내기"];
	else if(flag == 0){
		[titleLabel setText:@"복원하기"];
	}
	else {
		[titleLabel setText:@"웹과 동기화(Usay.ney)"];
	}


	[titleView addSubview:titleLabel];	
	[titleLabel release];
	self.navigationItem.titleView = titleView;
	[titleView release];
	*/
	
	UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
	UIFont *titleFont = [UIFont systemFontOfSize:20];
	CGSize titleStringSize;
	if (flag == 1) {
		titleStringSize  = [@"내보내기" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
	}
	else {
		titleStringSize  = [@"웹과 동기화(Usay.net)" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
	}

	
	UILabel *naviTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
	[naviTitleLabel setFont:titleFont];
	naviTitleLabel.textAlignment = UITextAlignmentCenter;
	[naviTitleLabel setTextColor:ColorFromRGB(0x053844)];
	[naviTitleLabel setBackgroundColor:[UIColor clearColor]];
	
	if (flag == 1) {
		[naviTitleLabel setText:@"내보내기"];
	}
	else {
		[naviTitleLabel setText:@"웹과 동기화(Usay.net)"];
	}
	
	[titleView addSubview:naviTitleLabel];	
	[naviTitleLabel release];
	self.navigationItem.titleView = titleView;
	[titleView release];
	self.navigationItem.titleView.frame = CGRectMake((320-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);
	
	
	
	
	
	UIImage* leftBarBtnImg = [UIImage imageNamed:@"btn_top_left.png"];
	UIImage* leftBarBtnSelImg = [UIImage imageNamed:@"btn_top_left_focus.png"];
	UIButton* leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[leftBarButton addTarget:self action:@selector(backBarButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
	[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateSelected];
//	[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateDisabled];
	[leftBarButton setImage:[UIImage imageNamed:@"empty"] forState:UIControlStateDisabled];
	leftBarButton.frame = CGRectMake(0.0, 0.0, leftBarBtnImg.size.width, leftBarBtnImg.size.height);
	leftButton = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
	
	
	
	self.navigationItem.backBarButtonItem=nil;
	self.navigationItem.leftBarButtonItem = leftButton;
	
	
	
	
	
	
	//2010.12.15 그룹삭제 임시로 함...
	UIImage* RightBarBtnImg = [UIImage imageNamed:@"btn_top_left.png"];
	UIImage* RightBarBtnSelImg = [UIImage imageNamed:@"btn_top_left_focus.png"];
	UIButton* RightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	[RightBarButton addTarget:self action:@selector(cancleAction) forControlEvents:UIControlEventTouchUpInside];
	[RightBarButton addTarget:self action:@selector(removeAllGroup) forControlEvents:UIControlEventTouchUpInside];
	[RightBarButton setImage:RightBarBtnImg forState:UIControlStateNormal];
	[RightBarButton setImage:RightBarBtnSelImg forState:UIControlStateSelected];
	[RightBarButton setImage:RightBarBtnSelImg forState:UIControlStateDisabled];
	RightBarButton.frame = CGRectMake(0.0, 0.0, RightBarBtnImg.size.width, RightBarBtnImg.size.height);
	RightButton = [[UIBarButtonItem alloc] initWithCustomView:RightBarButton];

	
//	self.navigationItem.rightBarButtonItem = RightButton;
	
//	[leftButton release];
	
	
	
	self.navigationItem.backBarButtonItem=nil;
	
	
	explainLabel.adjustsFontSizeToFitWidth=YES;
	explainLabel.textAlignment=UITextAlignmentCenter;
	
	[mainScrollView addSubview:explainLabel];
	
	
	NSRange year, month, day, hour, mi, sec;
	year.location=0;
	year.length=4;
	month.location=4;
	month.length=2;
	day.location=6;
	day.length=2;
	hour.location=8;
	hour.length=2;
	mi.location=10;
	mi.length=2;
	sec.location=12;
	sec.length=2;
	
	
	
	
	
	
	NSString *lastSyncDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastOemSync"];
	
	NSString *dateTime;
	dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15+55, 320, 25)];
	if(lastSyncDate == nil)
	{
		
		if(flag == 2)
		{
			dateTime =[NSString stringWithFormat:@""];
		}
		else {
		dateTime =[NSString stringWithFormat:@"최근 내보내기 | 내역 없음"];	
		}

		
		
	}
	else
	{
		if(flag == 0 || flag == 1)
		{
			dateTime = [NSString stringWithFormat:@"최근 내보내기 | %@.%@.%@ %@:%@",
						[lastSyncDate substringWithRange:year],
						[lastSyncDate substringWithRange:month], 
						[lastSyncDate substringWithRange:day],
						[lastSyncDate substringWithRange:hour],
						[lastSyncDate substringWithRange:mi]];
			
			dateLabel.text = dateTime;	
		}
		else
		{
			dateTime=@"";
		}
	}
	
	
	[dateLabel setBackgroundColor:[UIColor clearColor]];
	

	dateLabel.text=dateTime;
	dateLabel.font=[UIFont systemFontOfSize:12];
	dateLabel.textColor=ColorFromRGB(0x16acc2);
	dateLabel.textAlignment=UITextAlignmentCenter;
	[mainScrollView addSubview:dateLabel];
	
	
	
	
	UIImageView *iconImg = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15+60+30, 82, 160)];
	[iconImg setImage:[UIImage imageNamed:@"7_usayadd_1.png"]];
	
	
	UIImageView *iphoneImg;
	
	
	if(flag == 2)
	{
		iphoneImg= [[UIImageView alloc] initWithFrame:CGRectMake(320-15-82, 15+60+30, 82, 160)];
		[iphoneImg setImage:[UIImage imageNamed:@"7_usayadd_4.png"]];
	}
	else {
		iphoneImg= [[UIImageView alloc] initWithFrame:CGRectMake(320-15-82, 15+60+30, 82, 160)];
		[iphoneImg setImage:[UIImage imageNamed:@"7_usayadd_2.png"]];
		
	}

							  
	
	UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 319+40, 320, 1)];
	[lineView setBackgroundColor:ColorFromRGB(0x99999c)];
	
	UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(15, 365+40, 290, 1)];
	[lineView2 setBackgroundColor:ColorFromRGB(0xBDBBBF)];
	
	if(flag !=2)
		[mainScrollView addSubview:lineView2];
	
	
	
	
	
	UIView *warView = [[UIView alloc] initWithFrame:CGRectMake(0, 320+40, 320, 30)];
	[warView setBackgroundColor:[UIColor whiteColor]];

	
	 
	
	
	
	
	UIImageView *warningView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 20, 20)];
	warningView.backgroundColor=[UIColor whiteColor];
	UILabel *warningText =[[UILabel alloc] initWithFrame:CGRectMake(15+25, 10, 200, 20)];
	warningText.text=@"주의사항";
	warningText.textColor=[UIColor redColor];
	warningText.font=[UIFont systemFontOfSize:18];
	
	
	
	
	
	warningText.backgroundColor=[UIColor whiteColor];
	warningView.image=[UIImage imageNamed:@"7_warning.png"];
	
	
	[mainScrollView addSubview:iconImg];
	[mainScrollView addSubview:iphoneImg];
	
	
	
	if(flag !=2)
		[warView addSubview:warningView];
	
	if(flag !=2)
		[warView addSubview:warningText];
	
	
	if(flag !=2)
		[mainScrollView addSubview:warView];
	
	
	if(flag !=2)
		[mainScrollView addSubview:lineView];
	
	
	
	
	
	[mainScrollView addSubview:UsayNameLabel];
	[mainScrollView addSubview:iPhoneNameLabel];
	
	
	[mainScrollView addSubview:sendButton];
	
		
	
	// 내보내기 시 그룹 삭제 버튼.
	delete = YES;
	if (flag == 1)	// 내보내기 시에만 보이도록 
	{
		// group remove check button
		groupCheckButton = [UIButton buttonWithType:UIButtonTypeCustom];
		groupCheckButton.frame = CGRectMake(25, 320, 35, 35);
		[groupCheckButton addTarget:self action:@selector(checkBoxClicked) forControlEvents:UIControlEventTouchUpInside];
		[groupCheckButton setImage:[UIImage imageNamed:@"chkbox_on.png"] forState:UIControlStateNormal];
		[mainScrollView addSubview:groupCheckButton];
		
		UILabel *checkLabel = [[UILabel alloc] initWithFrame:CGRectMake(20+30+20, 315, 320-(20+25+20)-40, 40)];
		checkLabel.text = @"iPhone 연락처 그룹을 삭제하고 Usay주소록 그룹으로 대체하기";
		checkLabel.textColor = ColorFromRGB(0x56575C);

		checkLabel.backgroundColor = [UIColor clearColor];
		checkLabel.font = [UIFont systemFontOfSize:13];
		checkLabel.textAlignment = UITextAlignmentLeft;
		checkLabel.numberOfLines = 2;
		[mainScrollView addSubview:checkLabel];
		[checkLabel release];
	}
	
	//release
	[warView release];
	[lineView release];
	
	[mainScrollView release];
	[UsayNameLabel release];
	[iPhoneNameLabel release];
	[UsayCntLabel release];
	[iPhoneCntLabel release];
	[UsayView release];
	[iconImg release];
	[iphoneImg release];
	[lineView2 release];
	[warningView release];
	[warningText release];
	
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
	
	
//메모리 워닝을 잡을 방법이 딱히 없는듯... 이거 때문에 들어가다 말다 한듯하다...	
//	warningLevel++;
	
	
	if(warningLevel == 2)
	{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"메모리 오류" 
														message:@"메모리가 부족하니 실행중인 어플들을 종료한 후 이용하세요" 
													   delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
	[alertView show];
	[alertView release];
		
		
		warningLevel = 0;
		[self.navigationController popViewControllerAnimated:YES];
	}
	return;
	
	
	
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	if(leftButton !=nil)
	{
		[leftButton release];
		leftButton=nil;
	}
	if(webCntLabel != nil)
	{
		[webCntLabel release];
		webCntLabel=nil;
	}
	if(sendButton  != nil)
	{
		sendButton=nil;
	}
	if(sendButton2 != nil)
	{
		sendButton2=nil;
	}
	if(warningDetailText != nil)
	{
		
		[warningDetailText release];
		warningDetailText=nil;
	}
	if(explainLabel != nil)
	{
		[explainLabel release];
		explainLabel=nil;
	}
	
	[dateLabel release];
	[curCount release];
	[curCount2 release];
	[timer release];

	if (groupCheckButton != nil)
	{
		groupCheckButton = nil;
	}
    [super dealloc];
}


@end
