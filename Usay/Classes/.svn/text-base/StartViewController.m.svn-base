//
//  StartViewController.m
//  USayApp
//
//  Created by Jong-Sung Park on 10. 5. 28..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "StartViewController.h"
#import "USayAppAppDelegate.h"
#import "AddressBookData.h"
#import "HttpAgent.h"
#import "json.h"
#import "USayHttpData.h"
#import "SQLiteDatabase.h"
#import "UserInfo.h"
#import "SystemMessageTable.h"

#import "GroupInfo.h"

#import "RoomInfo.h"				// 대화방 리스트 관리				_TROOMINFO
#import "MessageInfo.h"				// 대화내용 관리					_TMESSAGEINFO
#import "MessageUserInfo.h"			// 대봐방에 있는 버디 리스트 관리		_TMESSAGEUSERINFO
#import "CellMsgListData.h"
#import <objc/runtime.h>
#import "MyDeviceClass.h"
#import <CommonCrypto/CommonDigest.h>
#import "USayDefine.h"				// sochae 2010.09.27
#import "Reachability.h"			// sochae 2010.09.27
#import "blockView.h"
#import "AddressViewController.h"

//#define ID_LOGOIMAGEVIEW	3001

@implementation StartViewController
@synthesize startTimer;

BOOL CHKOFF;
BOOL LOGINSUCESS;
BOOL LOGINSTART;
BOOL LOGINEND;
extern NSString *LOGINTYPE;



extern BOOL gsmchk;
extern BOOL joinchk;

-(NSString*) md5:(NSString *)str
{
	const char *cStr = [str UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	
	CC_MD5(cStr, strlen(cStr), result);
	
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
			result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];
	
	//    return [diskCachePath stringByAppendingPathComponent:filename];
}


-(USayAppAppDelegate *) appDelegate
{
	return (USayAppAppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark -
#pragma alertViewmark UIAlertView delegate Method
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	DebugLog(@"buttonIndex %i",buttonIndex);
	if([alertView.title isEqualToString:@"단말 중복 등록(-1060)"] || [alertView.title isEqualToString:@"인증 실패(-1070)"])
	{
		DebugLog(@"====> 중복 오류로 인한 종료 처리");
		
		//삭제 루틴 추가 함 20101010
		//plist 삭제
		[[NSUserDefaults standardUserDefaults] setPersistentDomain:[NSDictionary dictionary]
														   forName:[[NSBundle mainBundle] bundleIdentifier]];
		
		// mezzo 로컬 sql 파일 삭제
		NSString *appSqlPath;// = [[NSBundle mainBundle] resourcePath];
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSString *subFolder = [NSString stringWithFormat:@"Documents/%@", @"usay.sqlite"] ;
		appSqlPath = [NSHomeDirectory() stringByAppendingPathComponent:subFolder];
		DebugLog(@"App sql file is : %@", appSqlPath);
		
		BOOL            result;
		
		result = [fileManager removeItemAtPath:appSqlPath error:nil];
		if (result == YES) {
			DebugLog(@"usay.sqlite delete success!!");
		}	
		
		
		
		exit(0);
		
		return;
	}
	
	if(buttonIndex == 0){
		//		self.logoImageAnimationTimer = nil;
		[[self appDelegate] goMain:self];
	}
}


#pragma mark -
#pragma mark controller Method
-(void) startControl:(NSTimer *)theTimer
{
	
	AddressBookData* addrData = [[[AddressBookData alloc] init] autorelease];
	NSLog(@"스타트 뷰 컨트롤러.");
	[[NSUserDefaults standardUserDefaults] setObject:@"2" forKey:@"INSTALL"];
	
	
	/*
	 NSString *version = [NSString stringWithFormat:@"%@", 
	 [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
	 DebugLog(@"===== startControl (ver.%@) CALLED. =====>", version);
	 */
	
	
	
	[theTimer invalidate];
	self.startTimer = nil;
	[indicator startAnimating];
	
	SQLiteDatabase* dataBase = [[SQLiteDatabase alloc] init];	// sochae 2010.12.29
	SQLiteDataAccess* isDatabase = [dataBase initWithOpenSQLite];
	//[dataBase release]; mezzo
	
	// 기존의 db file이 있는지 검사.
	if(isDatabase != nil) {
		[self appDelegate].database = isDatabase;
		[isDatabase release];
	}
	
	//헐 파일은 있는데 디비가 없는 경우가 있음
	if([self appDelegate].database == nil || [self appDelegate].database == NULL)
	{
		[[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"INSTALL"];
		// MARK: < ----- 회원 가입 ( db가 없는 경우, 최초 설치 ) ----- >
				DebugLog(@"\n========== 회원 가입 절차 시작 ==========>");
		[self migrationDatabase];
		[[self appDelegate] dbInitialize];
		[[self appDelegate] setIsFirstUser:YES];
		[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"CertificationStatus"];
		[[self appDelegate] goRegistration];	// 가입처리
		//쓰레드로 처리 
	//	[NSThread detachNewThreadSelector:@selector(th_readFullOEMData) toTarget:self withObject:nil];
		//		self.logoImageAnimationTimer = nil;
	}
	else
	{
		// MARK: < ----- 로그인 (기존 db가 존재하는 경우) ----- >
		DebugLog(@"\n========== 로그인 절차 시작 ==========>");
		NSArray *tableNames = [[self appDelegate].database tableNames];
		if(![tableNames containsObject:[UserInfo tableName]])
		{
			NSLog(@"버그 !!!!");
			[[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"INSTALL"];
			// MARK: < ----- 회원 가입 ( db가 없는 경우, 최초 설치 ) ----- >
			DebugLog(@"\n========== 회원 가입 절차 시작 ==========>");
			[self migrationDatabase];
			[[self appDelegate] dbInitialize];
			[[self appDelegate] setIsFirstUser:YES];
			[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"CertificationStatus"];
			[[self appDelegate] goRegistration];	// 가입처리
			
		//	[NSThread detachNewThreadSelector:@selector(th_readFullOEMData) toTarget:self withObject:nil];

			return;
		}
		if(![tableNames containsObject:[SystemMessageTable tableName]])
		{
			// MARK: # 사용자(_TUserInfo) 테이블 생성.
			SystemMessageTable* systemTable = [[SystemMessageTable alloc] init];
			[systemTable createTableForClass];
			[systemTable release];
			NSString *insertData = [NSString stringWithFormat:@"insert into _TSystemMessageTable (ISSUCESS)values('0')"];
			[SystemMessageTable findWithSql:insertData];
			NSLog(@"시스템 테이블 만들기 성공.");
		}
		[[self appDelegate] dbInitialize];
		[addrData readFullnowData];
		BOOL isProcesstime = NO;
		BOOL isSucess = NO;
		NSArray *tmpCols = [[UserInfo database] columnsForTableName:[UserInfo tableName]];
	//	NSLog(@"기존 테이블 컬럼명 : %@", tmpCols);
		NSArray *roomtmp = [[RoomInfo database] columnsForTableName:[RoomInfo tableName]];
		for (NSString *col in roomtmp) 
		{
			if ([col isEqualToString:@"ISSUCESS"])
			{
				isProcesstime = YES;
				
			}
			if ([col isEqualToString:@"PROCESSTIME"])
			{
				isSucess = YES;
			}
		}
		if (isProcesstime == NO)
		{
			NSString *tmp = @"alter table _TRoomInfo add PROCESSTIME BIGINT;";	// sochae 2011.02.24 - DataAccessObject의 생성시의 자료형과 맞아야 하는거 안니가요? 
			[RoomInfo findWithSql:tmp];
			[[RoomInfo database] commit];
		}
		if (isSucess == NO)
		{
			NSString *tmp = @"alter table _TRoomInfo add ISSUCESS INTEGER;";	// sochae 2011.02.24 - DataAccessObject의 생성시의 자료형과 맞아야 하는거 안니가요? 
			[RoomInfo findWithSql:tmp];
			[[RoomInfo database] commit];
		}
	
		// sochae 2011.02.24 - index 
		if (isProcesstime == NO && isSucess == NO)
		{
			NSString *tmp = [NSString stringWithFormat:
							 @"CREATE INDEX \"idx_session_search\" ON \"_TRoomInfo\" (\"LASTUPDATETIME\" DESC, \"PROCESSTIME\" DESC, \"ISSUCESS\" DESC);"];
			DebugLog(@"[DB INDEX added] %@", tmp);
			[RoomInfo findWithSql:tmp];
			[[RoomInfo database] commit];
		}	
		// ~sochae
		
		NSArray *groupCols = [[GroupInfo database] columnsForTableName:[GroupInfo tableName]];
		
		
		//레코드테이블, 변경테이블, 백업테이블, API테이블, 유세이테이블 신규 테이블 추가
		if(![tableNames containsObject:@"_TRecord"])
		{
			SQLiteDataAccess* trans = [DataAccessObject database];
			NSString *createContact = @"CREATE  TABLE _TRecord ('RECID' integer not null, PRIMARY KEY('RECID'))";
			NSString *indexQuery = @"CREATE INDEX 'idx_Record' ON '_TRecord' ('RECID' DESC)";
			[trans executeSql:createContact];
			[trans executeSql:indexQuery];
		}
		if(![tableNames containsObject:@"_TChangePhone"])
		{
			SQLiteDataAccess* trans = [DataAccessObject database];
			NSString *createContact = @"CREATE  TABLE _TChangePhone ('RECID' integer not null, 'PHONE' TEXT not null, PRIMARY KEY('RECID','PHONE'))";
			NSString *indexQuery = @"CREATE INDEX 'idx_ChangePhone' ON '_TChangePhone' ('RECID' DESC, 'PHONE' DESC)";
			[trans executeSql:createContact];
			[trans executeSql:indexQuery];
		}
		if(![tableNames containsObject:@"_TPreContact"])
		{
			SQLiteDataAccess* trans = [DataAccessObject database];
			NSString *createContact = @"CREATE  TABLE _TPreContact ('RECID' integer not null, 'PHONE' TEXT not null, 'TID' integer, 'FIRST' text, 'LAST' text, 'SUCESS' CHAR,  'TYPE' CHAR, PRIMARY KEY('RECID','PHONE'))";
			NSString *indexQuery = @"CREATE INDEX 'idx_PreContact' ON '_TPreContact' ('RECID' DESC, 'PHONE' DESC,'TYPE' DESC)";
			[trans executeSql:createContact];
			[trans executeSql:indexQuery];
		}
		if(![tableNames containsObject:@"_TRequestAPI"])
		{
			SQLiteDataAccess* trans = [DataAccessObject database];
			NSString *createContact = @"CREATE  TABLE _TRequestAPI ('API' text, 'PARAMETER' TEXT, 'SUCESS' INTEGER)";
			NSString *indexQuery = @"CREATE INDEX 'idx_RequestAPI' ON '_TRequestAPI' ('API' DESC, 'SUCESS' DESC)";
			[trans executeSql:createContact];
			[trans executeSql:indexQuery];
		}
		if(![tableNames containsObject:@"_TRecordIndex"])
		{
			SQLiteDataAccess* trans = [DataAccessObject database];
			NSString *createContact = @"CREATE  TABLE _TRecordIndex ('RECID' integer, 'SECTION' integer, 'INDEXNUM' INTEGER, PRIMARY KEY('RECID','SECTION'))";
			NSString *indexQuery = @"CREATE INDEX 'idx_RecordIndex' ON '_TRecordIndex' ('RECID' DESC, 'SECTION' DESC)";
			[trans executeSql:createContact];
			[trans executeSql:indexQuery];
		}
		if(![tableNames containsObject:@"_TUsayUserInfo"])
		{
			
			SQLiteDataAccess* trans = [DataAccessObject database];
			NSString *createContact = @"CREATE  TABLE _TUsayUserInfo\n"
			"('CHO' CHAR, 'FPK' TEXT NOT NULL, 'RID' INTEGER, 'MP' TEXT, 'TYPE' CHAR, 'NAME' TEXT, 'PMP' TEXT, 'UFLAG' INTEGER,\n"
			"'PRP' TEXT, 'PNN' TEXT, 'ST' TEXT,'PO' TEXT,\n"
			"'PURL' TEXT, 'PE' TEXT, 'PHP' TEXT,'POP' TEXT, 'NEWUSER' TEXT, 'INSERTTIME' TEXT, 'STATE' INTEGER, 'CHOSUNG' CHAR, PRIMARY KEY('FPK'))";
			NSString *indexQuery = @"CREATE INDEX 'idx_UsayUserInfo' ON '_TUsayUserInfo' ('RID' DESC, 'FPK' DESC)";
			
			
			/*
			NSString *createContact = @"CREATE  TABLE _TUsayUserInfo\n"
			"('PKEY' TEXT NOT NULL, 'RECID' INTEGER, 'PHONE' TEXT, 'TYPE' CHAR, 'NAME' TEXT,\n"
			"'PROFILENAME' TEXT, 'TODAYDAY' TEXT, 'IMGURL' TEXT, 'JOB' TEXT,\n"
			"'HOMEPAGE' TEXT, 'EMAIL' TEXT, 'HOMEPHONE' TEXT, 'NEWUSER' TEXT, 'NOWTIME' TEXT, 'INSERTTIME' TEXT, 'STATUS' INTEGER, PRIMARY KEY('PKEY'))";
			NSString *indexQuery = @"CREATE INDEX 'idx_UsayUserInfo' ON '_TUsayUserInfo' ('RECID' DESC, 'PKEY' DESC)";
		 */
			[trans executeSql:createContact];
			[trans executeSql:indexQuery];
		}
		//주소록 화면이 한번이라도 노출된 사용자는 바로 주소록화면으로 이동
		if([[NSUserDefaults standardUserDefaults] objectForKey:@"ADDRESSAPPEAR"])
		{
			[[self appDelegate] goMain:self];
		}
		else {
			NSLog(@"한번도 안나타남??");
			[[self appDelegate] goRegistration];
		}
		return;
	}
}
/*
 -(void)logoImageAnimation:(NSTimer *)timecall
 {
 UIImageView *logoImageView = (UIImageView *)[self.view viewWithTag:ID_LOGOIMAGEVIEW];
 if ([self logoImageCount] > 34) {
 [timecall invalidate];
 // success
 self.startTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self 
 selector:@selector(startControl:) 
 userInfo:nil repeats:NO];
 return;
 } else {
 [timecall invalidate];
 timecall = nil;
 [self setLogoImageCount:[self logoImageCount] + 1];
 }
 
 NSString *fileName = [NSString stringWithFormat:@"intro_%02i.gif", [self logoImageCount]];
 [logoImageView setImage:[UIImage imageNamed:fileName]];
 [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(logoImageAnimation:) userInfo:nil repeats:NO];
 }
 
 -(void)releaseLoadImageView
 {
 UIImageView *logoImageView = (UIImageView *)[self.view viewWithTag:ID_LOGOIMAGEVIEW];
 if (logoImageView) {
 [logoImageView removeFromSuperview];
 }
 }
 
 -(void)setLogoImageCount:(NSInteger)count
 {
 logoImageCount = count;
 }
 
 -(NSInteger)logoImageCount
 {
 return logoImageCount;
 }
 //*/
#pragma mark -
#pragma mark NSNotification initOnMobile response
-(void)initOnMobile:(NSNotification *)notification
{
	NSString *data = (NSString*)[notification object];
	if ([data isEqualToString:@"SUCCESS"]) {
		// success
		
		DebugLog(@"로그온 초기화 성공");
		
		self.startTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self 
														 selector:@selector(startControl:) 
														 userInfo:nil repeats:NO];
	} else {
		// fail
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0063)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		//		self.startTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self 
		//														 selector:@selector(startControl:) 
		//														 userInfo:nil repeats:NO];
		
		
		
	}
}
-(void)closeBlockView
{
	if(authBlockView !=nil && authBlockView != NULL)
	{
		[authBlockView dismissAlertView];
		[authBlockView release];
		
		authBlockView = nil;
	}
}



-(void)loginOnMobile:(NSNotification *)notification
{
	
	

	
	//로그인 시작 종료
	LOGINSTART = NO;
	LOGINEND = YES;
	
	// 2010.12.21 인디케이터 디드 어피어로 옮긴다.	[indicator stopAnimating];
	USayHttpData *data = (USayHttpData*)[notification object];
	if (data == nil) {
		
		//2011.01.19 로그인 실패시 오프라인 모드로 변환한다..
		[self appDelegate].connectionType = -2;
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		
		/*
		 UINavigationController *tmp = [[self appDelegate].rootController.viewControllers objectAtIndex:0];
		 AddressViewController *tmpAdd = (AddressViewController*)[tmp.viewControllers objectAtIndex:0];
		 [tmpAdd setDisabled];
		 
		 
		 UINavigationController *tmp2 = [[self appDelegate].rootController.viewControllers objectAtIndex:1];
		 AddressViewController *tmpAdd2 = (AddressViewController*)[tmp2.viewControllers objectAtIndex:0];
		 
		 [tmpAdd2 setDisabled];
		 */
		
		
		
		
		
		
		
		
		
		
		//	[JYUtil alertWithType:ALERT_NET_OFFLINE delegate:self];
		
		
		
		// 200 이외의 에러
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"로그인 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		
		
		LOGINSUCESS = NO;
		
		return;
	}
	
	//	NSString *api = data.api;
	
	NSString *resultData = data.responseData;
	
	// 1. Create BSJSON parser.
	SBJSON *jsonParser = [[SBJSON alloc] init];
	
	// 2. Get the result dictionary from the response string.
	NSDictionary *dic = (NSDictionary*)[jsonParser objectWithString:resultData error:NULL];
	[jsonParser release];
	// 3. Show response
	// key and value type
	NSString *rtcode = nil;
	rtcode = [dic objectForKey:@"rtcode"];	// 프로토콜문서에는 result로 되어 있는것을 rtcode로 변경
	DebugLog(@"rtcode: %@", rtcode);
	if ([rtcode isEqualToString:@"0"]) {	// success
		NSString *rtType = [dic objectForKey:@"rttype"];
		DebugLog(@"rttype: %@", rtType);
		
		if ([rtType isEqualToString:@"map"]) {
			// Key and Dictionary as its value type
			NSDictionary *addressDic = [dic objectForKey:@"map"];
			NSString *ucmc = [addressDic objectForKey:@"UCMC"];
			NSString *uccs = [addressDic objectForKey:@"UCCS"];
			NSString *mc = [addressDic objectForKey:@"MC"];			// 파란ID 매핑된 회원 인 경우만 내려옴
			NSString *cs = [addressDic objectForKey:@"CS"];			// 파란ID 매핑된 회원 인 경우만 내려옴
			
			[[[self appDelegate] myInfoDictionary] setObject:[addressDic objectForKey:@"pkey"] forKey:@"pkey"];
			[[[self appDelegate] myInfoDictionary] setObject:[addressDic objectForKey:@"exip"] forKey:@"exip"];
			//			[[[self appDelegate] myInfoDictionary] setObject:[addressDic objectForKey:@"userno"] forKey:@"userno"];
			// sochae 2010.10.12 - nickname은 NSUserDefaults에만 저장.
			//[[[self appDelegate] myInfoDictionary] setObject:[addressDic objectForKey:@"nickName"] forKey:@"nickname"];
			[[[self appDelegate] myInfoDictionary] setObject:ucmc forKey:@"UCMC"];
			[[[self appDelegate] myInfoDictionary] setObject:uccs forKey:@"UCCS"];
			//[[NSUserDefaults standardUserDefaults] setObject:[addressDic objectForKey:@"nickName"] forKey:@"nickName"];
			[JYUtil saveToUserDefaults:[addressDic objectForKey:kNickname] forKey:kNickname];
			// ~sochae
			
			if ([mc length]) {
				[[[self appDelegate] myInfoDictionary] setObject:mc forKey:@"MC"];
			} else {
				[[[self appDelegate] myInfoDictionary] setObject:@"" forKey:@"MC"];
			}
			if ([cs length]) {
				[[[self appDelegate] myInfoDictionary] setObject:cs forKey:@"CS"];
			} else {
				[[[self appDelegate] myInfoDictionary] setObject:@"" forKey:@"CS"];
			}
			// cookie setting
			[HttpAgent setCookie:ucmc cookieUCCS:uccs cookieMC:mc cookieCS:cs];
			
			NSString *improxy = [NSString stringWithString:[addressDic objectForKey:@"improxy"]];
			NSString *improxyAddr = nil;
			NSString *improxyPort = nil;
			if ([improxy length] > 0) {
				NSRange range = [improxy rangeOfString:@":"];
				if (range.location == NSNotFound) {
					// TODO: 세션접속 정보 format 에러. 예외처리 필요
				} else {
					improxyAddr = [improxy substringToIndex:range.location];
					improxyPort = [[improxy substringFromIndex:range.location+1] substringToIndex:[improxy length]-(range.location+1)];
					
					
					NSLog(@"imadd = %@", improxyAddr);
					NSLog(@"import = %@", improxyPort);
					
					
					
					[[self appDelegate].myInfoDictionary setObject:improxyAddr forKey:@"proxyhost"];
					[[self appDelegate].myInfoDictionary setObject:improxyPort forKey:@"proxyport"];
				}
			}
			
			// sochae 2010.09.30 - Login 성공 시 device token 전송
			appD.isLogin = YES;
			LOGINSUCESS = YES;
			[[self appDelegate] sendDeviceToken];
			// ~sochae
			
			// sochae 2010.09.27 - 여기서 Reachability 한번만 실행. 
			DebugLog(@"[RESPONSE] Login Success (%@) !!!", improxyAddr);
			[[self appDelegate] setupReachability:improxyAddr];
			// ~sochae
			
			// TODO: Host Connect
			if([[self appDelegate] connect:improxyAddr PORT:[improxyPort intValue]]) {
				
				
			
				//단말에서 데이터 가져와서 서버로 요청 하기
				//[[self appDelegate].Thread start];
				
				[[self appDelegate] LoadingDataRequest];					
				
				
				
			//	[[self appDelegate] requestSyncFriendsInfoCnt:50 syncType:3];
				
				
				
				
				
				
				
				//즉 로그인 전에 gsm이 호출 되는 경우
				if(gsmchk == YES)
				{
					//다시 gsm을 호출한다.
					[[NSNotificationCenter defaultCenter] postNotificationName:@"requestRetrieveSessionMessage" object:nil];
					gsmchk == NO;
				}
				if(joinchk == YES)
				{
					//다시 reSession을 호출한다.
					[[NSNotificationCenter defaultCenter] postNotificationName:@"CreateReSession" object:nil];
					joinchk == NO;
				}
				if([LOGINTYPE isEqualToString:@"TCPCONNECT"])
				{
					[[self appDelegate] callSysteMsg:6];
					LOGINTYPE = @"";
				}
				
				
				
				
				
				
				
				//sucess login 2011.01.24
				NSMutableDictionary *bodyObject2 = [[[NSMutableDictionary alloc] init] autorelease];
				[bodyObject2 setObject:[[self appDelegate]getSvcIdx] forKey:@"svcidx"];
				
				USayHttpData *data2 = [[[USayHttpData alloc] initWithRequestData:@"getRecommendFriendsList" 
															   andWithDictionary:bodyObject2 
																		 timeout:10] autorelease];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data2];
				
				
				//2011.01.24 add profile
			//	[[self appDelegate] requestGetChangedProfileInfo];
				
				
				
				//2011.01.25 시스템 메시지 추가
				[[self appDelegate] OnlySysteMsg];

				
				
				
				
				
				//sync 
				/*
				 UINavigationController *tmp = [[self appDelegate].rootController.viewControllers objectAtIndex:0];
				 AddressViewController *tmpAdd = (AddressViewController*)[tmp.viewControllers objectAtIndex:0];
				 [tmpAdd syncOEMAddress];
				 */
				//	[self syncOEMAddress];
				
				
				
				
				//2011.02.07 kjh RP 추가
				//	[self requestContactsData];
				
				
				
				//로그인이 성공했으면 데이터 가져온다.
				NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
				NSLocale *locale = [NSLocale currentLocale];
				[formatter setLocale:locale];
				[formatter setDateFormat:@"yyyyMMddHHmmss"];
				NSDate *today = [NSDate date];
				NSString *lastSyncDate = [[NSString alloc] initWithFormat:@"%@",[formatter stringFromDate:today]];
				[[NSUserDefaults standardUserDefaults] setObject:lastSyncDate forKey:@"lastSyncDate"];
				
				
				
				
				
				// success!
			} else {
				
				// TODO: 예외처리 필요 (세션연결 실패)
				
				
				if([[self appDelegate] connect:improxyAddr PORT:[improxyPort intValue]]) {
					
					
					LOGINSUCESS = YES;
					//sucess login 2011.01.24
					NSMutableDictionary *bodyObject2 = [[[NSMutableDictionary alloc] init] autorelease];
					[bodyObject2 setObject:[[self appDelegate]getSvcIdx] forKey:@"svcidx"];
					
					USayHttpData *data2 = [[[USayHttpData alloc] initWithRequestData:@"getRecommendFriendsList" 
																   andWithDictionary:bodyObject2 
																			 timeout:10] autorelease];
					[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data2];
					
					
					//2011.01.24 add profile
				//	[[self appDelegate] requestGetChangedProfileInfo];
					
					
					
					//2011.01.25 시스템 메시지 추가
					[[self appDelegate] OnlySysteMsg];
					
					
					//2011.02.07 kjh RP 추가
					//[self requestContactsData];
					
					
					
					//sync 
					/*
					 UINavigationController *tmp = [[self appDelegate].rootController.viewControllers objectAtIndex:0];
					 AddressViewController *tmpAdd = (AddressViewController*)[tmp.viewControllers objectAtIndex:0];
					 [tmpAdd syncOEMAddress];
					 */
					[self syncOEMAddress];
					
					
					
					// success!
				} else {
					
					// TODO: 예외처리 필요 (세션연결 실패)
					
				}
				
			}
			
		} else {
			// TODO: 예외처리
		}
	}
	else if ([rtcode isEqualToString:@"1000"] || [rtcode isEqualToString:@"-1000"]) 
	{
		// TODO: 인증실패(가입 필요) 예외처리 필요  재설치 후 가입하여 주세요.(errcode 1000,-1000)
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"로그인 실패" message:@"가입 정보가 없습니다. 어플을 재실행 해주세요" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} 
	else if ([rtcode isEqualToString:@"-1010"] || [rtcode isEqualToString:@"-1020"] || [rtcode isEqualToString:@"-1050"] || [rtcode isEqualToString:@"-1070"])
	{
		
		
		
		
		//plist 삭제
		[[NSUserDefaults standardUserDefaults] setPersistentDomain:[NSDictionary dictionary]
														   forName:[[NSBundle mainBundle] bundleIdentifier]];
		
		// mezzo 로컬 sql 파일 삭제
		NSString *appSqlPath;// = [[NSBundle mainBundle] resourcePath];
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSString *subFolder = [NSString stringWithFormat:@"Documents/%@", @"usay.sqlite"] ;
		appSqlPath = [NSHomeDirectory() stringByAppendingPathComponent:subFolder];
		DebugLog(@"App sql file is : %@", appSqlPath);
		
		BOOL            result;
		
		result = [fileManager removeItemAtPath:appSqlPath error:nil];
		if (result == YES) {
			DebugLog(@"usay.sqlite delete success!!");
			
		}	
		
		
		
		// TODO: 인증실패 예외처리 필요 (pKey 를 찾을수 없음)
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"등록이 안된 사용자 입니다." message:@"자세한 안내는 1588-5668로 문의 바랍니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else if ([rtcode isEqualToString:@"-1020"]) {
		// TODO: 인증실패 예외처리 필요 (UserId 를 찾을수 없음)
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"로그인 실패" message:@"가입 정보가 없습니다. 문의 해주세요.(errcode -1020)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else if ([rtcode isEqualToString:@"-1050"]) {
		// TODO: 인증실패 예외처리 필요 (비밀번호를 찾을수 없음)
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"로그인 실패" message:@"가입 정보가 없습니다. 문의 해주세요.(errcode -1050)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else if ([rtcode isEqualToString:@"-1060"]) {
		// TODO: 인증실패 예외처리 필요 (비밀번호가 일치하지 않는 경우)
		
		//plist 삭제
		[[NSUserDefaults standardUserDefaults] setPersistentDomain:[NSDictionary dictionary]
														   forName:[[NSBundle mainBundle] bundleIdentifier]];
		// mezzo 로컬 sql 파일 삭제
		NSString *appSqlPath;// = [[NSBundle mainBundle] resourcePath];
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSString *subFolder = [NSString stringWithFormat:@"Documents/%@", @"usay.sqlite"] ;
		appSqlPath = [NSHomeDirectory() stringByAppendingPathComponent:subFolder];
		DebugLog(@"App sql file is : %@", appSqlPath);
		
		BOOL            result;
		
		result = [fileManager removeItemAtPath:appSqlPath error:nil];
		if (result == YES) {
			DebugLog(@"usay.sqlite delete success!!");
		}	
		
		
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"단말 중복 등록(-1060)" message:@"다른 단말에 중복가입을 하셔서 이용하실 수 없습니다.(errcode -1060)" delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		// soche 2010.09.29 - 여기도 회원 탈퇴 처리 루틴과 동일하게 호출되도록... 
	} else if ([rtcode isEqualToString:@"-1070"]) {
		// TODO: 인증실패 예외처리 필요 (삭제된 이용자임)
		
		//plist 삭제
		[[NSUserDefaults standardUserDefaults] setPersistentDomain:[NSDictionary dictionary]
														   forName:[[NSBundle mainBundle] bundleIdentifier]];
		
		// mezzo 로컬 sql 파일 삭제
		NSString *appSqlPath;// = [[NSBundle mainBundle] resourcePath];
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSString *subFolder = [NSString stringWithFormat:@"Documents/%@", @"usay.sqlite"] ;
		appSqlPath = [NSHomeDirectory() stringByAppendingPathComponent:subFolder];
		DebugLog(@"App sql file is : %@", appSqlPath);
		
		BOOL            result;
		
		result = [fileManager removeItemAtPath:appSqlPath error:nil];
		if (result == YES) {
			DebugLog(@"usay.sqlite delete success!!");
		}	
		
		
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"인증 실패(-1070)" message:@"삭제된 이용자 입니다.(errcode -1070)" delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		
		
		
		
		
		
	} else if ([rtcode isEqualToString:@"-1090"]) {
		// TODO: 인증실패 예외처리 필요 (이메일 인증되지 않았음)
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"인증 실패" message:@"이메일 인증이 되지 않은 사용자 입니다.(errcode -1090)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		
	} else if ([rtcode isEqualToString:@"-9030"]) {
		// TODO: 인증실패 예외처리 필요 (처리 오류)
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"로그인 실패" message:@"처리중 오류가 발생하였습니다. 다시 시작해 주세요.(errcode -9030)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		
	} else {
		// TODO: 실패 예외처리 필요
		// fail (-8080 이외 기타오류)
		NSString* errMsg = [NSString stringWithFormat:@"오류가 발생하였습니다.(errcode %@)",rtcode];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"로그인 실패" message:errMsg delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	}
}


-(void)showBlock
{
	
	NSAutoreleasePool *pool =[[NSAutoreleasePool alloc] init];
	authBlockView.alertText = @"주소록 동기화 중..";
	authBlockView.alertDetailText = @"잠시만 기다려 주세요.";
	[authBlockView show];
	[pool release];
	
	//
	
	
	
}

-(void)goReload:(NSTimer*)theTimer
{
	
	NSLog(@"END RELOAD!!!");
	[theTimer invalidate];
	theTimer = nil;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadAddressData" object:nil];
}

#pragma mark <--- 싱크된(서버) 주소록 수신 (addListContactIncludeGroup)
-(void)addListContact:(NSNotification *)notification
{
	
	CHKOFF = NO;
	
	//버튼 활성화
	
	if([self appDelegate].connectionType != -1)
	{
		NSLog(@"커넥션 살아 있다.");
		UINavigationController *tmp = [[self appDelegate].rootController.viewControllers objectAtIndex:0];
		AddressViewController *tmpAdd = (AddressViewController*)[tmp.viewControllers objectAtIndex:0];
		[tmpAdd setEnabledAdd];
	}
	else {
		NSLog(@"커넥션이 죽음");
	}

	
	
	
	//즉 50개 이상이면.
	if(authBlockView != nil && authBlockView != NULL)
	{
		[authBlockView dismissAlertView];
		[authBlockView release];
		authBlockView = nil;
	}
	
	
	
	
	NSLog(@"여기는 들어오냐?? 스타트뷰 노티");
	
	
	
	
	
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	NSLog(@"\n----- [HTTP] 로그인 싱크 주소록 수신 ( addListContactIncludeGroup )  start----->");
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"addListContactIncludeGroup" object:nil];
	
	USayHttpData *data = (USayHttpData*)[notification object];
	if (data == nil) {
		// 200 이외의 에러
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 오류" message:@"서버와의 통신에 실패하였습니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return;
	}
	
	//	NSString *api = data.api;	
	NSString *resultData = data.responseData;
	
	// 1. Create BSJSON parser.
	SBJSON *jsonParser = [[SBJSON alloc] init];
	
	// 2. Get the result dictionary from the response string.
	NSDictionary *dic = (NSDictionary*)[jsonParser objectWithString:resultData error:NULL];
	//	[resultData release];
	[jsonParser release];
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
						Ivar* ivars = class_copyIvarList([groupData class], &numIvars);
						for(int i = 0; i < numIvars; i++) {
							Ivar thisIvar = ivars[i];
							NSString * classkey = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
							
							
							
							
							if([key isEqualToString:@"gid"]){
								[groupData  setValue:[addressDic objectForKey:key] forKey:@"ID"];
								
							}else if([[key uppercaseString] isEqualToString:classkey]){
								[groupData  setValue:[addressDic objectForKey:key] forKey:classkey];
							}
							
							
							
							
						}
						if(numIvars > 0) free(ivars);
						[grouppool release];
					}else {//유저 정보
						NSAutoreleasePool * userpool = [[NSAutoreleasePool alloc] init];
						if([[key uppercaseString] isEqualToString:@"ISBLOCK"])
							[userData  setValue:@"N" forKey:[key uppercaseString]];
						unsigned int numIvars = 0;
						Ivar* ivars = class_copyIvarList([userData class], &numIvars);
						for(int i = 0; i < numIvars; i++) {
							Ivar thisIvar = ivars[i];
							NSString * classkey = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
							if([[key uppercaseString] isEqualToString:classkey])
								[userData  setValue:[addressDic objectForKey:key] forKey:classkey];
							
							
							
						}
						
						
						NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
						NSLocale *locale = [NSLocale currentLocale];
						[formatter setLocale:locale];
						[formatter setDateFormat:@"yyyyMMddHHmmss"];
						NSDate *today = [NSDate date];
						NSString *lastSyncDate = [[NSString alloc] initWithFormat:@"%@",[formatter stringFromDate:today]];
						
						
						[formatter release];
						[userData  setValue:lastSyncDate forKey:@"CHANGEDATE"];
						[lastSyncDate release];
						
						if(numIvars > 0) free(ivars);
						[userpool release];
					}
				}				
				if([groupData valueForKey:@"ID"]){
					[groupArray addObject:groupData];
				}
				if(groupData) [groupData release];
				
				if([userData valueForKey:@"ID"]){
					[userArray addObject:userData];
				}
				if(userData)[userData release];
				
				NSLog(@"CNT[%d], NAME [%@]", nCount, userData.FORMATTED);
				nCount++;
			}
			
			//내려 받은 개수와 리스트를 파싱한 개수가 같을 경우에 저장.
			if([count isEqualToString:[NSString stringWithFormat:@"%i",nCount]])
			{
				[self syncDatabase:userArray withGroupinfo:groupArray saveRevisionPoint:RP];	
			//	authBlockView = [[blockView alloc] initWithFrame:CGRectMake(0.0, 0.0, 250.0, 150.0)];
			//	[NSThread detachNewThreadSelector:@selector(showBlock) toTarget:self withObject:nil];
				//[self showBlock];
				NSLog(@"주소록과 유세이 메모리 리로드");
				
		
				/*
				[NSTimer scheduledTimerWithTimeInterval:0.001 target:self 
											   selector:@selector(goReload:) 
											   userInfo:nil repeats:NO];
			*/
			}
			else
			{
				NSLog(@"카운트가 다른다 무냐 이건. %@ %d", count, nCount);
			}
		} else {
			//변경된 데이터가 없다.
			// TODO: 예외처리
						[self syncDatabase:nil withGroupinfo:nil saveRevisionPoint:nil];
		}
	} else if ([rtcode isEqualToString:@"-9010"]) {
		// TODO: 데이터를 찾을 수 없음.
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"동기화 경고" message:@"저장된 데이타가 없습니다.(-9010)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		[self syncDatabase:nil withGroupinfo:nil saveRevisionPoint:nil];
		
	}
	else if ([rtcode isEqualToString:@"-9020"]) {
		// TODO: 잘못된 인자가 넘어옴
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"동기화 경고" message:@"잘못된 값이 포함되어 있습니다.(-9020)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		[self syncDatabase:nil withGroupinfo:nil saveRevisionPoint:nil];
		
	} 
	else if ([rtcode isEqualToString:@"-9030"]) {
		// TODO: 서버상의 처리 오류. 예외처리 필요
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"동기화 경고" message:@"처리 오류가 발생하였습니다.\n종료후 다시 실행해주세요.(-9030)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		[self syncDatabase:nil withGroupinfo:nil saveRevisionPoint:nil];
	} 
	else {
		// TODO: 기타오류 예외처리 필요
		NSLog(@"들어오냐??");
		NSString* errcode = [NSString stringWithFormat:@"(%@)",rtcode];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"동기화 경고" message:errcode delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		[self syncDatabase:nil withGroupinfo:nil saveRevisionPoint:nil];
		
	}
	
	//주소록 갱신이 되면 사운드 및 알림..
	[[self appDelegate] playSystemSoundIDSound];
	[[self appDelegate] playSystemSoundIDVibrate];
	
	
	
	
	
}
/*
 -(void)getContacts:(NSNotification *)notification {
 
 USayHttpData *data = (USayHttpData*)[notification object];
 if (data == nil) {
 // 200 이외의 에러
 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 오류" message:@"서버와의 통신에 실패하였습니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
 [alertView show];
 [alertView release];
 return;
 }
 
 //	NSString *api = data.api;	
 NSString *resultData = data.responseData;
 
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
 NSString *count = [dic objectForKey:@"count"]; //리스트 개수
 NSMutableArray* serverData = [NSMutableArray array];
 if ([rtType isEqualToString:@"list"]) {
 // Key and Dictionary as its value type
 int nCount = 0;
 for(NSDictionary *addressDic in [dic objectForKey:@"list"]) {
 id userData = (NSMutableDictionary*)[[UserInfo alloc] init];
 NSArray* keyArray = [addressDic allKeys];
 for(NSString* key in keyArray) {
 [userData  setValue:[addressDic objectForKey:key] forKey:[key uppercaseString]];
 }
 [serverData addObject:userData];
 [userData release];
 nCount++;
 }
 //내려 받은 개수와 리스트를 파싱한 개수가 같을 경우에 저장.
 if([count isEqualToString:[NSString stringWithFormat:@"%i",nCount]])
 [self syncDatabase:serverData saveRevisionPoint:nil];
 } else {
 // TODO:rtType이 다를 경우 예외처리
 }
 } else if ([rtcode isEqualToString:@"-9010"]) {
 // TODO: 데이터를 찾을 수 없음.
 } else if ([rtcode isEqualToString:@"-9020"]) {
 // TODO: 잘못된 인자가 넘어옴
 } else if ([rtcode isEqualToString:@"-9030"]) {
 // TODO: 서버상의 처리 오류. 예외처리 필요
 } else {
 // TODO: 기타오류 예외처리 필요
 }
 
 }
 */

-(void)getLastAfterRP:(NSNotification *)notification
{
	NSLog(@"\n---------- [HTTP] notification ( getLastAfterRP ) ---------->");
	//[[NSNotificationCenter defaultCenter] removeObserver:self name:@"getLastAfterRP" object:nil];
	
	USayHttpData *data = (USayHttpData*)[notification object];
	if (data == nil) {
		/*알럿창 숨김 2011.02.09
		// 200 이외의 에러
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 오류" message:@"서버와의 통신에 실패하였습니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		 */
		return;
	}
	
	//	NSString *api = data.api;	
	NSString *resultData = data.responseData;
	
	// 1. Create BSJSON parser.
	SBJSON *jsonParser = [[SBJSON alloc] init];
	
	// 2. Get the result dictionary from the response string.
	NSDictionary *dic = (NSDictionary*)[jsonParser objectWithString:resultData error:NULL];
	//	[resultData release];
	[jsonParser release];
	// 3. Show response
	// key and value type
	NSString *rtcode = nil;
	rtcode = [dic objectForKey:@"rtcode"];	// 프로토콜문서에는 result로 되어 있는것을 rtcode로 변경
	if ([rtcode isEqualToString:@"0"]) {	// success
		
		NSString *rtType = [dic objectForKey:@"rttype"];
		NSString *count = [dic objectForKey:@"count"]; //리스트 개수
		NSString *RP = [dic objectForKey:@"RP"];  //마지막 동기화 RP
		DebugLog(@"getLAstRP : RP = %@, api = %@, count = %@", RP, [dic objectForKey:@"RP"], count);
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
						Ivar* ivars = class_copyIvarList([groupData class], &numIvars);
						for(int i = 0; i < numIvars; i++) {
							Ivar thisIvar = ivars[i];
							NSString * classkey = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
							if([key isEqualToString:@"gid"]){
								[groupData  setValue:[addressDic objectForKey:key] forKey:@"ID"];
								
							}else if([[key uppercaseString] isEqualToString:classkey]){
								[groupData  setValue:[addressDic objectForKey:key] forKey:classkey];
							}
						}
						if(numIvars>0)free(ivars);
						[grouppool release];
					}else {//유저 정보
						NSAutoreleasePool * userpool = [[NSAutoreleasePool alloc] init];
						if([[key uppercaseString] isEqualToString:@"ISBLOCK"])
							[userData  setValue:@"N" forKey:[key uppercaseString]];
						unsigned int numIvars = 0;
						Ivar* ivars = class_copyIvarList([userData class], &numIvars);
						for(int i = 0; i < numIvars; i++) {
							Ivar thisIvar = ivars[i];
							NSString * classkey = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
							if([[key uppercaseString] isEqualToString:classkey]) {
								[userData  setValue:[addressDic objectForKey:key] forKey:classkey];
							}
						}
						if(numIvars > 0)free(ivars);
						[userpool release];
					}
				}				
				if([groupData valueForKey:@"ID"]){
					[groupArray addObject:groupData];
				}
				if(groupData) [groupData release];
				
				if([userData valueForKey:@"ID"]){
					[userArray addObject:userData];
				}
				if(userData)[userData release];
				
				nCount++;
			}
			/*			
			 if (userArray && [userArray count] > 0) {
			 NSString* pkey = nil;
			 NSString* representPhoto = nil;
			 for(UserInfo* chatUser in userArray){
			 if(chatUser.RPKEY != nil && [chatUser.RPKEY length]> 0){
			 pkey = chatUser.RPKEY;
			 if (chatUser.REPRESENTPHOTO && [chatUser.REPRESENTPHOTO length] > 0) {
			 representPhoto = chatUser.REPRESENTPHOTO;
			 } else if (chatUser.THUMBNAILURL && [chatUser.THUMBNAILURL length] > 0) {
			 representPhoto = chatUser.THUMBNAILURL;
			 } else {
			 representPhoto = @"";
			 }
			 
			 NSArray *checkDBMessageUserInfo = [MessageUserInfo findWithSqlWithParameters:@"select * from _TMessageUserInfo where PKEY=?", pkey, nil];
			 if (checkDBMessageUserInfo && [checkDBMessageUserInfo count] > 0) {
			 [MessageUserInfo findWithSqlWithParameters:@"update _TMessageUserInfo set PHOTOURL=? where PKEY=?", representPhoto, pkey, nil];
			 }
			 
			 @synchronized([self appDelegate].msgListArray) {
			 if ([self appDelegate].msgListArray && [[self appDelegate].msgListArray count] > 0) {
			 for (CellMsgListData *msgListData in [self appDelegate].msgListArray) {
			 if (msgListData.userDataDic && [msgListData.userDataDic count] > 0) {
			 for (id key in msgListData.userDataDic) {
			 if ([(NSString*)key isEqualToString:pkey]) {
			 MsgUserData *userData = [msgListData.userDataDic objectForKey:key];
			 if (userData) {
			 if (representPhoto && [representPhoto length] > 0) {
			 // skip
			 } else {
			 representPhoto = @"";
			 }
			 userData.photoUrl = representPhoto;
			 }
			 }
			 }
			 }
			 }
			 }
			 }
			 }
			 }
			 }
			 //*/
			//내려 받은 개수와 리스트를 파싱한 개수가 같을 경우에 저장.
			if([count isEqualToString:[NSString stringWithFormat:@"%i",nCount]])
			{
				NSLog(@"애프터 알피 들어오냐");
				[self syncDatabase:userArray withGroupinfo:groupArray saveRevisionPoint:RP];
				
				//RP호출후 리로드..
				
				[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadAddressData" object:nil];
			}
			
		} else if([rtType isEqualToString:@"only"] ) {
			//온리로 들어오면 안된다.. 2011.01.24
			return;
			
			[self syncDatabase:nil withGroupinfo:nil saveRevisionPoint:nil];
			// TODO: 예외처리
		} else {
			//TODO: 예외처리
		}
		
	
	
	
		
	
	
	
	} else if ([rtcode isEqualToString:@"-9010"]) {
		// TODO: 데이터를 찾을 수 없음.
		[self syncDatabase:nil withGroupinfo:nil saveRevisionPoint:nil];
	} else if ([rtcode isEqualToString:@"-9020"]) {
		// TODO: 잘못된 인자가 넘어옴
	} else if ([rtcode isEqualToString:@"-9030"]) {		
		// TODO: 서버상의 처리 오류. 예외처리 필요
	} else {
		// TODO: 기타오류 예외처리 필요
	}
	
}

#pragma mark -

- (void)viewDidAppear:(BOOL)animated
{
	
	[indicator stopAnimating];
		NSLog(@"===== StartView : viewDidAppear =====>");
    [super viewDidAppear:animated];
	[[UIApplication sharedApplication] setStatusBarHidden:YES];
	indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	indicator.frame = CGRectMake(self.view.frame.size.width/2.0, (self.view.frame.size.height/2.0)+50, 20.0, 20.0);
	//	indicator.center = self.view.center;
	[self.view addSubview:indicator];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginOnMobile:) name:@"loginOnMobile" object:nil];
	Reachability *internetReach = [Reachability reachabilityForInternetConnection];
	NetworkStatus netStatus = [internetReach currentReachabilityStatus];
	switch (netStatus)
    {
        case ReachableViaWWAN:
        {
			//            DebugLog(@"===== [net] 3G 연결 됨 =====>");
			[self appDelegate].connectionType = 2;		// 3G
            break;
        }
			
		case ReachableViaWiFi:
        {
			//            DebugLog(@"===== [net] Wi-Fi 연결 됨 =====>");
			[self appDelegate].connectionType = 1;		// Wi-Fi
            break;
        }
			
		case NotReachable:
        {
			//            DebugLog(@"===== [net] Network 연결 안됨 =====>");
			[self appDelegate].connectionType = -1;		// offline
			
			NSInteger authState = [[NSUserDefaults standardUserDefaults] integerForKey:@"CertificationStatus"];
			if(authState == 0)
			{
				[JYUtil alertWithType:ALERT_NET_OFFLINE delegate:nil];
				return;
			}
			break;
        }
    }
	// ~sochae 
	
	//	[NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(logoImageAnimation:) userInfo:nil repeats:NO];
	////////////////////////////////////////////////////////////////
	// sochae - crash log 전송 작업 중에는 잠시 usay process 중단.
	NSString *existCrashLog = [JYUtil loadFromUserDefaults:kIsCrashLog];
	if ([existCrashLog isEqualToString:@"1"])
	{
		DebugLog(@"sochae : crash log return");
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(doUSayStartProcess:) 
													 name:@"doUSayStart" 
												   object:nil];
		return;
	}
	////////////////////////////////////////////////////////////////
	
	
	if([[[NSUserDefaults standardUserDefaults] objectForKey:@"VERSION"] isEqualToString:@"1.0"])
	{
		if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"INSTALL"] isEqualToString:@"2"]) {
			[[NSUserDefaults standardUserDefaults] setObject:@"2" forKey:@"INSTALL"];
		}
		SQLiteDatabase* dataBase = [[SQLiteDatabase alloc] init];	// sochae 2010.12.29
		SQLiteDataAccess* isDatabase = [dataBase initWithOpenSQLite];
		[self appDelegate].database = isDatabase;
		[[self appDelegate] goMain:self];
		return;
	}
	
	self.startTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self 
													 selector:@selector(startControl:) 
													 userInfo:nil repeats:NO];
}

// sochae - crash log 전송 후에 받는 noti (usay process 진행)
- (void)doUSayStartProcess:(NSNotification *)noti
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"doUSayStart" object:nil];
	
	self.startTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self 
													 selector:@selector(startControl:) 
													 userInfo:nil repeats:NO];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.



- (void)viewDidLoad {
    [super viewDidLoad];
	
	
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getLastAfterRP:) name:@"getLastAfterRP" object:nil];
	
	
//	[[NSUserDefaults standardUserDefaults] setInteger:-1 forKey:@"CertificationStatus"];
	
	
	[self.view setFrame:[[UIScreen mainScreen] bounds]];
	
	UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default.png"]];
	[self.view addSubview:backgroundImageView];
	/*	if (resolutionType == Type_320_480) {
	 [backgroundImageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, 480)];	//self.view.frame.size.height)];
	 } else if (resolutionType == Type_640_960) {
	 [backgroundImageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, 960)];	//self.view.frame.size.height)];
	 } else {	// Type_768_1024
	 [backgroundImageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, 1024)];	//self.view.frame.size.height)];
	 }
	 */// ~sochae
	[backgroundImageView release];
	
	//	UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_00.gif"]];
	//	assert(logoImageView != nil);
	//	[self.view addSubview:logoImageView];
	//	[logoImageView setFrame:CGRectMake((self.view.frame.size.width - 320)/2, 166, 320, 120)];
	//	logoImageView.tag = ID_LOGOIMAGEVIEW;
	//	[logoImageView release];
	
	
	NSLog(@"didLoadComplete");
}

- (void)viewDidDisappear:(BOOL)animated 
{
	//뷰가 사라지면 노티 삭제
    [super viewDidDisappear:animated];
	//	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"initOnMobile" object:nil];
	//  [[NSNotificationCenter defaultCenter] removeObserver:self name:@"loginOnMobile" object:nil];
	
	//	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"getContacts" object:nil];
	
	//	[self setLogoImageCount:1];
	//	[[UIApplication sharedApplication] setStatusBarHidden:NO];
	
	
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
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	NSLog(@"뷰 디얼록");
	//	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"initOnMobile" object:nil];
	[indicator release];
	//	if (logoImageAnimationTimer != nil) {
	//		[logoImageAnimationTimer release];
	//	}
	
    [super dealloc];
}


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
			//			DebugLog(@"newDate = %@", newDate);
			
			date =  [NSString stringWithFormat:@"%@",[currentDateFormat stringFromDate:newDate]];
			
			//			DebugLog(@"return");
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




#pragma mark -
#pragma mark NSDictionary convert to SQLiteDataAccess`s NSDictionary
#pragma mark ---> OEM 주소록 가공 및 서버로 전송
-(BOOL)changeDataDictionary:(NSMutableDictionary *)dicData{
	
	//사용자 정보 저장
	NSDictionary *rpdict = nil, *contactDic = nil, *contactCnt = nil/*, *recordDic =nil*/;
	//	NSString	*body = nil;
	NSString	*listbody = nil;
	
	NSMutableArray* contactList = [NSMutableArray array];
	
	
	oemGroupArray = [[NSMutableArray alloc] initWithCapacity:0];
	DebugLog(@"groupArr = %@",oemGroupArray);
	
	for(GroupInfo *groupData in [dicData objectForKey:@"GROUP"]){
		NSArray* compareGroup = [GroupInfo findAll];
		NSMutableDictionary *group = [[NSMutableDictionary alloc] initWithCapacity:0];
		for(GroupInfo* localgroup in compareGroup){
			if([groupData.RECORDID	isEqualToString:localgroup.RECORDID]){
				groupData.ID = localgroup.ID;
				
				//2010.12.08일.. 무조건 닐값으로 변경
				
				if(![groupData.GROUPTITLE isEqualToString:localgroup.GROUPTITLE]){//레코드번호는 같고 그룹이름이 다를 경우 그룹 이름이 바뀐걸로 설정
					groupData.SIDUPDATED = @"mobile";
					//		[group setObject:[groupData valueForKey:@"RECORDID"  ] forKey:@"gid"];
					[group setObject:groupData.ID forKey:@"gid"];
					[group setObject:[groupData valueForKey:@"GROUPTITLE"] forKey:@"grouptitle"];
					[group setObject:[groupData valueForKey:@"SIDUPDATED"] forKey:@"sidupdated"];
				}
				
				break;
			}
		}
		
		//무조건 새로 추가하면 그룹은 없다...
		//	[group release];
		
		if(group != nil && [[group allKeys] count] > 0){//로컬 DB에 recordID가 같은게 있고, 그룹 이름이 다르면 전송 목록에 추가
			[contactList addObject:group];
			[oemGroupArray addObject:group];
			[group release];
		}else if(groupData.ID != nil && [groupData.ID length]>0){//기본 그룹에 같은 레코드 아이디가 존재.
			[group release];
		}else {// 읽어온 그룹 정보당 로컬 그룹 정보와의 비교로  값이 없다면 새로 추가한 그룹
			groupData.SIDCREATED = @"mobile";
			[group setObject:[groupData valueForKey:@"RECORDID"  ] forKey:@"gid"];
			[group setObject:[groupData valueForKey:@"GROUPTITLE"] forKey:@"grouptitle"];
			[group setObject:[groupData valueForKey:@"SIDCREATED"] forKey:@"sidcreated"];
			[contactList addObject:group];
			[oemGroupArray addObject:group];
			[group release];
		}
		
	}
	
	//for(UserInfo *userData2 in [dicData objectForKey:@"PERSON"]){
	for(NSInteger i=0; i<[[dicData objectForKey:@"PERSON"] count]; i++){
		//	DebugLog(@"dicCount = %d", [[dicData objectForKey:@"PERSON"] count]);
		
		
		
		UserInfo *userData2;
		
		//[[dicData objectForKey:@"PERSON"] objectAtIndex:i];
		
		
		
		
		//UserInfo *userData33 = [[dicData objectForKey:@"PERSON"] objectAtIndex:i];
		
		userData2 = (UserInfo*)[[[dicData objectForKey:@"PERSON"] objectAtIndex:i] copy];
		
		
		
		//	[userData2 copy:[[dicData objectForKey:@"PERSON"] objectAtIndex:i]];
		
		//[[[dicData objectForKey:@"PERSON"] objectAtIndex:i] copy:userData2];		
		
		
		//	NSLog(@"함수 넘어왔다333. %@", userData2.RECORDID);
		
		
		//	NSLog(@"userData RECORDID = %@"), userData33.RECORDID;	
		
		NSMutableDictionary *contact = [[NSMutableDictionary alloc] initWithCapacity:0];
		userData2.SIDCREATED = @"mobile";
		
		
		
		NSAutoreleasePool* varpool = [[NSAutoreleasePool alloc] init];
		unsigned int numIvars = 0;
		Ivar* ivars = class_copyIvarList([userData2 class], &numIvars);
		for(int i = 0; i < numIvars; i++) {
			Ivar thisIvar = ivars[i];
			NSString * key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
			//	NSLog(@"key value = %@", key);
			
			//	NSLog(@"orgname =  %@", userData2.ORGNAME);
			
			
			if([userData2 valueForKey:key] != nil){
				//RECORDID 값 제외 //20101013
				
				//		NSLog(@"aaa");
				
				//if([key isEqualToString:@"RECORDID"] || [key isEqualToString:@"IMSTATUS"] ||
				if([key isEqualToString:@"IMSTATUS"] ||
				   [key isEqualToString:@"IDXNO"] || [key isEqualToString:@"ISBLOCK"])
					continue;
				
				if([key isEqualToString:@"OEMCREATEDATE"])
				{
					
					
					NSString *newDate = [userData2 valueForKey:key];
					//		NSRange dateRange = {0,19};
					
					newDate = [self dateFormat:newDate];
					
					//					DebugLog(@"생성 시간. %@", newDate);
					
					
					
					
					
					//newDate = [newDate substringWithRange:dateRange];
					[contact setObject:newDate forKey:@"oemcreatedate"];	
				}
				else if([key isEqualToString:@"OEMMODIFYDATE"])
				{
					
					
					
					
					
					
					NSString *newDate = [userData2 valueForKey:key];
					
					newDate = [self dateFormat:newDate];
					//					DebugLog(@"변경 시간. %@", newDate);
					
					
					
					//	NSRange dateRange = {0,19};
					//	newDate = [newDate substringWithRange:dateRange];
					[contact setObject:newDate forKey:@"oemmodifydate"];
					
					
					
					
				}
				else {
					[contact setObject:[userData2 valueForKey:key] forKey:[key lowercaseString]];	
				}
				
				
				
				
				
				
			}
			
		}
		if(numIvars > 0)free(ivars);
		[varpool release];
		[contactList addObject:contact];
		[contact release];
		[userData2 release];
	}
	
	
	NSMutableArray* paramArray = [NSMutableArray array];
	
	NSString* revisionPoint = [[NSUserDefaults standardUserDefaults] objectForKey:@"RevisionPoints"];
	if(revisionPoint == nil) revisionPoint = @"0";
	
	rpdict = [NSDictionary dictionaryWithObjectsAndKeys:
			  revisionPoint, @"RP",
			  nil];
	
	[paramArray addObject:rpdict];
	contactDic = [NSDictionary dictionaryWithObjectsAndKeys: 
				  contactList,  @"contact",
				  nil];
	//2011.01.26
	NSString	*initializeCode;
	
	if(![[NSUserDefaults standardUserDefaults] objectForKey:@"lastSyncDate"])
	{
		initializeCode = [NSString stringWithFormat:@"Y"];	
	}
	else {
		initializeCode = [NSString stringWithFormat:@"N"];
	}
	
	contactCnt = [NSDictionary dictionaryWithObjectsAndKeys:
				  [NSString stringWithFormat:@"%i",[contactList count]], @"count",
				  nil];
	[paramArray addObject:contactCnt];
	[paramArray addObject:contactDic];
	
	
	
	
	// JSON 라이브러리 생성
	SBJSON *json = [[SBJSON alloc]init];
	[json setHumanReadable:YES];
	// 변환
	
	listbody = [json stringWithObject:paramArray error:nil];
	NSLog(@"listBody value  Cnt =%d", [contactList count]);
	NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:
								initializeCode, @"initialize",
								[[self appDelegate] getSvcIdx],@"svcidx",
								listbody, @"param",
								nil];
	
	[json release];
	CHKOFF = YES; //동기화 시작
	USayHttpData *data = [[[USayHttpData alloc]initWithRequestData:@"addListContactIncludeGroup" andWithDictionary:bodyObject timeout:90] autorelease];
	//	USayHttpData *data = [[USayHttpData alloc]initWithRequestData:@"addListContact" andWithDictionary:bodyObject timeout:10];	
	NSLog(@"\n----- [HTTP] OEM 주소록 전송 ( addListContactIncludeGroup ) ----->");
	[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
	
	return YES;
}

-(BOOL)requestContactsData{
	
	NSString* revisionPoint = [[NSUserDefaults standardUserDefaults] objectForKey:@"RevisionPoints"];
	DebugLog(@"\n===== requestContactsData (RP : %@) =====>", revisionPoint);
	
	NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:
								[[self appDelegate] getSvcIdx],@"svcidx",
								(revisionPoint == nil) ? @"0" : revisionPoint, @"RP",
								nil];
	
	
	
	
	//	SBJSON *json = [SBJSON alloc];
	//	[json setHumanReadable:YES];
	//	NSLog(@"%@",[json stringWithObject:bodyObject error:nil]);
	//	[json release];
	USayHttpData *data = [[[USayHttpData alloc]initWithRequestData:@"getLastAfterRP" andWithDictionary:bodyObject timeout:10] autorelease];	
	DebugLog(@"\n---------- [HTTP] request ( getLastAfterRP ) ---------->");
	[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
	
	return YES;
}

#pragma mark -
#pragma mark syncOEMAddress
// MARK: 주소록 추가된 항목만 동기화 ===== >
-(void)syncOEMAddress
{
	NSLog(@"\n========== syncOEMAddress (추가된 항목 동기화) ==========>");
	
	
	
	
	
	
	// 1. 동기화 할 데이터 있는지 확인
	// 2. 없으면 goMain으로 처리
	// 3. 있으면 데이터 JSON 으로 생성후 (http or 전용소켓) 으로 패킷 전송후 Response 팻킷으로 Usay db에 추가 하고 plist에 동기화 시간 저장 goMain으로 처리
	//2011.01.12	AddressBookData* addrData = [[[AddressBookData alloc] init] autorelease];
	
	
	
	
	/*
	
	BOOL isFindCol = NO;
	BOOL isFindcDate = NO;
	BOOL isFindmDate = NO;
	BOOL isGroupCDate = NO;
	BOOL isGroupMDate = NO;
	
	
	
	NSArray *tmpCols = [[UserInfo database] columnsForTableName:[UserInfo tableName]];
	DebugLog(@"기존 테이블 컬럼명 : %@", tmpCols);
	for (NSString *col in tmpCols) 
	{
		if ([col isEqualToString:@"CHANGEDATE2"])
		{
			isFindCol = YES;
			
		}
		if ([col isEqualToString:@"OEMCREATEDATE"])
		{
			isFindcDate = YES;
		}
		if ([col isEqualToString:@"OEMMODIFYDATE"])
		{
			isFindmDate = YES;			
		}
		
	}	
	// ~sochae
	
	
	
	if (isFindCol == NO)
	{
		NSString *tmp = @"alter table _TUserInfo add CHANGEDATE2 text;";
		[UserInfo findWithSql:tmp];
		[[UserInfo database] commit];
	}
	if (isFindmDate == NO)
		
	{
		NSString *tmp = @"alter table _TUserInfo add OEMMODIFYDATE text;";
		[UserInfo findWithSql:tmp];
		[[UserInfo database] commit];
	}
	if (isFindcDate == NO)
	{
		NSString *tmp = @"alter table _TUserInfo add OEMCREATEDATE text;";
		[UserInfo findWithSql:tmp];
		[[UserInfo database] commit];
	}
	
	
	
	NSArray *groupCols = [[GroupInfo database] columnsForTableName:[GroupInfo tableName]];
	
	
	for (NSString *col in groupCols) 
	{
		if ([col isEqualToString:@"OEMMODIFYDATE"])
		{
			isGroupMDate = YES;
		}
		if ([col isEqualToString:@"OEMCREATEDATE"])
		{
			isGroupCDate = YES;
		}
		
	}	
	
	if(isGroupCDate == NO)
	{
		NSString *tmp = @"alter table _TGroupInfo add OEMCREATEDATE text;";
		[GroupInfo findWithSql:tmp];
		[[GroupInfo database] commit];
		
		
	}
	if(isGroupMDate == NO)
	{
		NSString *tmp = @"alter table _TGroupInfo add OEMMODIFYDATE text;";
		[GroupInfo findWithSql:tmp];
		[[GroupInfo database] commit];
		
		
	}
	
	
	*/
	// lastsynctime 기준으로 oem 주소록에 추가된 항목 가져오기. AddressViewController 로뺏기때문에 걍 널처리함..
	//	NSDictionary* contacts = [addrData readOEMContactsAlterData];
	
	
	NSDictionary* contacts = nil;
	
	
//	NSInteger authState = [[NSUserDefaults standardUserDefaults] integerForKey:@"CertificationStatus"];
	
	
	
	AddressBookData* addrData = [[[AddressBookData alloc] init] autorelease];
	contacts =[addrData readOEMContactsAlterData];

	
	/*
	// 주소록 화면이 나타나면..
	if([[[NSUserDefaults standardUserDefaults] objectForKey:@"OEMSYNC"] isEqualToString:@"1"])
	{
		AddressBookData* addrData = [[[AddressBookData alloc] init] autorelease];
		contacts =[addrData readOEMContactsAlterData];
	}//최초 동기화가 안되었는데 여기로 들어오면 최초 동기화 중에 나갔다는 의미이다.
	else if(authState != -1)
	{
		AddressBookData* addrData = [[[AddressBookData alloc] init] autorelease];
		contacts =[addrData readOEMContactsAlterData];
	}
	else { //최초 동기화도 완료하고 들어온 사람이라면 처음에는 닐처리 한다.
		NSLog(@"nil 이어야 함.");
	}
	 */

		
	
	
	
	//DebugLog(@"여기로 반드시 들어오지.. %@", contacts);
	
	
	
	//처음 설치자가 아니면서 DATABASE가 없으면 예전버젼 설치자.. //무조건 검사로 바굼..
	//	if(![[NSUserDefaults standardUserDefaults] objectForKey:@"DATABASE"])
	//	{
	
	DebugLog(@"\n===> syncOEMAddress, [plist] DATABASE(NULL) : %@ ===", [[NSUserDefaults standardUserDefaults] objectForKey:@"DATABASE"]);
	
	/*
	 
	 NSString *find = @"select sql from sqlite_master where name='_TUserInfo'";
	 NSArray *findArray = [[UserInfo database] executeSql:find];
	 for (int i=0; i<[findArray count]; i++) {
	 NSLog(@"findArray = %@", [findArray objectAtIndex:i]);
	 }
	 
	 
	 
	 NSString *sqlCreate = [NSString stringWithFormat:@"%@", [findArray objectAtIndex:0]];
	 
	 //나중에 업데이트 하자 
	 //테이블에서 chagedate2칼럼을 발견하지 못한다면 칼럼을 추가해준다..		
	 if([sqlCreate rangeOfString:@"CHANGEDATE2"].location == NSNotFound)
	 {
	 NSLog(@"발견하지 못함..");
	 NSString *tmp = @"alter table _TUserInfo add CHANGEDATE2 text;";
	 NSArray *tmpArr =  [[UserInfo database] executeSql:tmp];
	 NSLog(@"tmpArr = %@", tmpArr);
	 [[UserInfo database] commit];
	 }
	 */
	// sochae - CHANGEDATE2 컬럼이 이미 존재하면 추가 안함.
	//#if 0
	
	
	
	//	}
	[[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"DATABASE"];
	
	DebugLog(@"\n===> syncOEMAddress, [plist] DATABASE : %@ ===", [[NSUserDefaults standardUserDefaults] objectForKey:@"DATABASE"]);
	
	
	
	
	
	
	
	
	
	NSMutableDictionary* dicContacts = [NSMutableDictionary dictionary];
	NSArray* localGroup = [GroupInfo findAll];
	
	NSMutableArray* contactArray = [NSMutableArray arrayWithArray:[contacts objectForKey:@"PERSON"]];
	NSMutableArray* groupArray  = [NSMutableArray arrayWithArray:[contacts objectForKey:@"GROUP"]];
	
	
	
	for(GroupInfo* oemGroup in [contacts objectForKey:@"GROUP"]){//oem 그룹
		for(GroupInfo* dbGroup in localGroup){
			
			DebugLog(@"dbTitle localTitle = %@ %@", dbGroup.GROUPTITLE, oemGroup.GROUPTITLE);
			if([dbGroup.GROUPTITLE	isEqualToString:oemGroup.GROUPTITLE]){
				//그룹을 뺀다.
				
				DebugLog(@"그룹이 같다...");
				
				DebugLog(@"디비레코드 아이디는 %@", dbGroup.RECORDID);
				//	if(dbGroup.RECORDID == nil && [dbGroup.RECORDID length] == 0){
				
				
				
				
				dbGroup.RECORDID = [NSString stringWithFormat:@"%@", oemGroup.RECORDID];
				NSString* sql = [NSString stringWithFormat:@"UPDATE %@ SET RECORDID = ? WHERE GROUPTITLE=?",[GroupInfo tableName]];
				
				
				DebugLog(@"그룹레코드 업데이트 쿼리... %@", sql);
				
				
				
				//그룹명이 같으면 단말 레코드 아이디로 셋팅...
				
				
				[GroupInfo findWithSqlWithParameters:sql, oemGroup.RECORDID, dbGroup.GROUPTITLE,nil];
				//	}
				DebugLog(@"groupTitle = %@", oemGroup.GROUPTITLE);
				[groupArray removeObject:oemGroup];
			}
		}
	}
	
	//	DebugLog(@"groupArray22 cnt = %d", [groupArray count]);
	
	NSArray* reLocalGroup = [GroupInfo findAll];
	for(UserInfo* oemUser in contactArray){
		
		//	DebugLog(@"startView Oem ID  %@", oemUser.RECORDID);
		
		
		//유저 그룹아이디를 다시 로드한다..
		for(GroupInfo* dbGroup in reLocalGroup){
			if([dbGroup.RECORDID isEqualToString:oemUser.GID]){
				// 이미 저장된 그룹. 그룹 아이디를 가져온다.
				oemUser.GID = [NSString stringWithFormat:@"%@",dbGroup.ID];
			}
		}
	}
	
	[dicContacts setObject:groupArray forKey:@"GROUP"];
	[dicContacts setObject:contactArray forKey:@"PERSON"];
	
	if ([[dicContacts objectForKey:@"PERSON"] count] > 0) {	// 추가된 주소록
		
		
		
		//전송 갯수가 50개 이상일 경우에만 블록뷰를 띄운다..
		if ([[dicContacts objectForKey:@"PERSON"] count] > 50)
		{
		/*
			authBlockView = [[blockView alloc] initWithFrame:CGRectMake(0.0, 0.0, 250.0, 150.0)];
			[NSThread detachNewThreadSelector:@selector(showBlock) toTarget:self withObject:nil];
		*/
		}
		// 주소록 Bulk로 올리기. 노티피케이션처리관련 등록..
		//		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addListContact:) name:@"addListContact" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addListContact:) name:@"addListContactIncludeGroup" object:nil];
		
		//웹으로 연결하여 유저 값을 받아 오면 database에 저장하기
		NSLog(@"\n  ===> StartViewController addListContact 호출");
		[self changeDataDictionary:dicContacts];
	}
	else {
		
		CHKOFF = NO;
		
		if([self appDelegate].connectionType != -1)
		{
			NSLog(@"커넥션 살아 있다.");
			UINavigationController *tmp = [[self appDelegate].rootController.viewControllers objectAtIndex:0];
			AddressViewController *tmpAdd = (AddressViewController*)[tmp.viewControllers objectAtIndex:0];
			[tmpAdd setEnabledAdd];
		}
		else {
			NSLog(@"커넥션이 죽음");
		}
		
		
		
		
		
		
		
	
		//임시주석..AddressViewController로 옮겼다..		[self requestContactsData];
		[indicator stopAnimating];
		NSLog(@"싱크단말 고메인");
		
	
		[[self appDelegate] goMain:self];
	}


}

#pragma mark -
#pragma mark set database Method
-(void)migrationDatabase {
	DebugLog(@"\n========== [DB] create tables ==========>");
	
	
	
	
	
	[self appDelegate].database	= [[SQLiteDatabase alloc] initWithCreateSQLite];
	
	[[self appDelegate].database beginTransaction];//테이블 생성 시 트랜잭션 처리
	
	NSArray *tableNames = [[self appDelegate].database tableNames];
	
	
	
	
	
	

	
    if(![tableNames containsObject:[UserInfo tableName]])
	{
		// MARK: # 사용자(_TUserInfo) 테이블 생성.
		UserInfo* userInfo = [[UserInfo alloc] init];
		[userInfo createTableForClass];
		[userInfo release];
    }
	//시스템 메세지 테이블 생성..
	if(![tableNames containsObject:[SystemMessageTable tableName]])
	{
		// MARK: # 사용자(_TUserInfo) 테이블 생성.
		SystemMessageTable* systemTable = [[SystemMessageTable alloc] init];
		[systemTable createTableForClass];
		[systemTable release];
		NSString *insertData = [NSString stringWithFormat:@"insert into _TSystemMessageTable (ISSUCESS)values('0')"];
		[SystemMessageTable findWithSql:insertData];
		
		
	
	}
	
	
	
	
	
	if(![tableNames containsObject:[GroupInfo tableName]])
	{
		// MARK: # 그룹(_TGroupInfo) 테이블 생성.
		GroupInfo* groupData = [[GroupInfo alloc] init];
		[groupData createTableForClass];
		//기본값 저장
		[groupData setValue:@"0" forKey:@"ID"];
		//	[groupData setValue:@"새로 등록한 주소" forKey:@"GROUPTITLE"];
		[groupData setValue:@"그룹미지정" forKey:@"GROUPTITLE"];
		[groupData insert];
		[groupData setValue:@"1" forKey:@"ID"];
		[groupData setValue:@"친구" forKey:@"GROUPTITLE"];
		[groupData insert];
		[groupData setValue:@"2" forKey:@"ID"];
		[groupData setValue:@"가족" forKey:@"GROUPTITLE"];
		[groupData insert];
		
		[groupData release];
	}
	

	if(![tableNames containsObject:[RoomInfo tableName]])
	{
		// MARK: # 대화방 리스트(_TRoomInfo) 테이블 생성.
		RoomInfo* roomInfo = [[RoomInfo alloc] init];
		[roomInfo createTableForClass];
		[roomInfo release];
	}
	
	if(![tableNames containsObject:[MessageUserInfo tableName]])
	{
		// MARK: # 대화방 버디 리스트(_TMessageUserInfo) 테이블 생성. (대화방 리스트 보여줄때 필요) 
		MessageUserInfo* msgUserInfo = [[MessageUserInfo alloc] init];
		[msgUserInfo createTableForClass];
		[msgUserInfo release];
	}
	
	if(![tableNames containsObject:[MessageInfo tableName]])
	{
		// MARK: # 대화내용(_TMessageInfo) 테이블 생성.
		MessageInfo* msgInfo = [[MessageInfo alloc] init];
		[msgInfo createTableForClass];
		[msgInfo release];
	}
	
	
	//레코드테이블, 변경테이블, 백업테이블, API테이블, 유세이테이블 신규 테이블 추가
	if(![tableNames containsObject:@"_TRecord"])
	{
		SQLiteDataAccess* trans = [DataAccessObject database];
		NSString *createContact = @"CREATE  TABLE _TRecord ('RECID' integer not null, PRIMARY KEY('RECID'))";
		NSString *indexQuery = @"CREATE INDEX 'idx_Record' ON '_TRecord' ('RECID' DESC)";
		[trans executeSql:createContact];
		[trans executeSql:indexQuery];
	}
	if(![tableNames containsObject:@"_TChangePhone"])
	{
		SQLiteDataAccess* trans = [DataAccessObject database];
		NSString *createContact = @"CREATE  TABLE _TChangePhone ('RECID' integer not null, 'PHONE' TEXT not null, PRIMARY KEY('RECID','PHONE'))";
		NSString *indexQuery = @"CREATE INDEX 'idx_ChangePhone' ON '_TChangePhone' ('RECID' DESC, 'PHONE' DESC)";
		[trans executeSql:createContact];
		[trans executeSql:indexQuery];
	}
	if(![tableNames containsObject:@"_TPreContact"])
	{
		SQLiteDataAccess* trans = [DataAccessObject database];
		NSString *createContact = @"CREATE  TABLE _TPreContact ('RECID' integer not null, 'PHONE' TEXT not null, 'TID' integer, 'FIRST' text, 'LAST' text, 'SUCESS' CHAR,  'TYPE' CHAR, PRIMARY KEY('RECID','PHONE'))";
		NSString *indexQuery = @"CREATE INDEX 'idx_PreContact' ON '_TPreContact' ('RECID' DESC, 'PHONE' DESC,'TYPE' DESC)";
		[trans executeSql:createContact];
		[trans executeSql:indexQuery];
	}
	if(![tableNames containsObject:@"_TRequestAPI"])
	{
		SQLiteDataAccess* trans = [DataAccessObject database];
		NSString *createContact = @"CREATE  TABLE _TRequestAPI ('API' text, 'PARAMETER' TEXT, 'SUCESS' INTEGER)";
		NSString *indexQuery = @"CREATE INDEX 'idx_RequestAPI' ON '_TRequestAPI' ('API' DESC, 'SUCESS' DESC)";
		[trans executeSql:createContact];
		[trans executeSql:indexQuery];
	}
	if(![tableNames containsObject:@"_TRecordIndex"])
	{
		SQLiteDataAccess* trans = [DataAccessObject database];
		NSString *createContact = @"CREATE  TABLE _TRecordIndex ('RECID' integer, 'SECTION' integer, 'INDEXNUM' INTEGER, PRIMARY KEY('RECID','SECTION'))";
		NSString *indexQuery = @"CREATE INDEX 'idx_RecordIndex' ON '_TRecordIndex' ('RECID' DESC, 'SECTION' DESC)";
		[trans executeSql:createContact];
		[trans executeSql:indexQuery];
	}
	if(![tableNames containsObject:@"_TUsayUserInfo"])
	{
		SQLiteDataAccess* trans = [DataAccessObject database];
		NSString *createContact = @"CREATE  TABLE _TUsayUserInfo\n"
		"('CHO' CHAR, 'FPK' TEXT NOT NULL, 'RID' INTEGER, 'MP' TEXT, 'TYPE' CHAR, 'NAME' TEXT, 'PMP' TEXT, 'UFLAG' INTEGER,\n"
		"'PRP' TEXT, 'PNN' TEXT, 'ST' TEXT,'PO' TEXT,\n"
		"'PURL' TEXT, 'PE' TEXT, 'PHP' TEXT,'POP' TEXT, 'NEWUSER' TEXT, 'INSERTTIME' TEXT, 'STATE' INTEGER, 'CHOSUNG' CHAR, PRIMARY KEY('FPK'))";
		NSString *indexQuery = @"CREATE INDEX 'idx_UsayUserInfo' ON '_TUsayUserInfo' ('RID' DESC, 'FPK' DESC)";
		/*
		NSString *createContact = @"CREATE  TABLE _TUsayUserInfo\n"
		"('PKEY' TEXT NOT NULL, 'RECID' INTEGER, 'PHONE' TEXT, 'TYPE' CHAR, 'NAME' TEXT,\n"
		"'PROFILENAME' TEXT, 'TODAYDAY' TEXT, 'IMGURL' TEXT, 'JOB' TEXT,\n"
		"'HOMEPAGE' TEXT, 'EMAIL' TEXT, 'HOMEPHONE' TEXT, 'NEWUSER' TEXT, 'NOWTIME' TEXT, 'INSERTTIME' TEXT, 'STATUS' INTEGER, PRIMARY KEY('PKEY'))";
		NSString *indexQuery = @"CREATE INDEX 'idx_UsayUserInfo' ON '_TUsayUserInfo' ('RECID' DESC, 'PKEY' DESC)";
		 */
		[trans executeSql:createContact];
		[trans executeSql:indexQuery];
	}
	
	
	
	[[self appDelegate].database commit];
	
	
	[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"install"];
	
	
	
	
	
	
	
	
	
}

-(void)syncDatabase:(NSArray*)userData withGroupinfo:(NSArray*)groupData saveRevisionPoint:(NSString*)revisionPoint {
	//	[self appDelegate].database	= [[[SQLiteDatabase alloc] initWithCreateSQLite]autorelease];
	//오늘 일자를 구해 NSUserDefaults로 app 사용자 값에 저장한다.
	
	if(userData == nil && groupData == nil && revisionPoint == nil)
		return;
	
	
	
	
	
	
	
	
	
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	NSLocale *locale = [NSLocale currentLocale];
	[formatter setLocale:locale];
	[formatter setDateFormat:@"yyyyMMddHHmmss"];
	NSDate *today = [NSDate date];
	NSString *lastSyncDate = [[[NSString alloc] initWithFormat:@"%@",[formatter stringFromDate:today]] autorelease];
	SQLiteDataAccess* trans = [DataAccessObject database];
	[trans beginTransaction];
	
	if(userData != nil){
		for(UserInfo* userInfo in userData) {
			if([userInfo.ISTRASH isEqualToString:@"N"] ){
				if((userInfo.RPCREATED  && [userInfo.RPCREATED length] > 0)|| (userInfo.RPUPDATED && [userInfo.RPUPDATED length] > 0)){
					NSString *authPhoneNumber = [[NSUserDefaults standardUserDefaults] valueForKey:@"AuthPhoneNumber"];
					if(![userInfo.MOBILEPHONENUMBER isEqualToString:authPhoneNumber]){
						if([userInfo.ISFRIEND isEqualToString:@"S"]){
							userInfo.CHANGEDATE = lastSyncDate;
						}
						[userInfo saveData];
					}
				}else if(userInfo.RPDELETED && [userInfo.RPDELETED length] > 0){
					[userInfo deleteData];
				}
			}else if([userInfo.ISTRASH isEqualToString:@"Y"]){
				NSLog(@"DB delete UserInfo %@", userInfo.FORMATTED);
				[userInfo deleteData];
			}
		}
	}
	if(oemGroupArray == nil){
		if(groupData != nil){
			for(GroupInfo* groupInfo in groupData){
				if(groupInfo.RPCREATED || groupInfo.RPUPDATED)
					[groupInfo saveData];
				else if(groupInfo.RPDELETED)
					[groupInfo deleteData];
			}
		}
	}else {
		if(groupData != nil){
			for(GroupInfo* groupInfo in groupData){
				DebugLog(@"DB insert GroupInfo");
				if(groupInfo.RPCREATED || groupInfo.RPUPDATED){
					for(int i = 0;i<[oemGroupArray count];i++){
						NSDictionary* oem = [oemGroupArray objectAtIndex:i];
						if([groupInfo.GROUPTITLE isEqualToString:[oem valueForKey:@"grouptitle"]]){
							groupInfo.RECORDID = [NSString stringWithFormat:@"%@",[oem valueForKey:@"gid"]];
							break;
						}
					}
					[groupInfo saveData];
				}else if(groupInfo.RPDELETED){
					[groupInfo deleteData];
				}
			}
		}
		//		[oemGroupArray release];
		
		//여기에서 죽는 현상이 있어서 예외처리한다.. 2010.12.15
		
		if(oemGroupArray != nil && oemGroupArray != NULL)
		{
			DebugLog(@"그룹배열이 널이 아닌다....");
    		if ([oemGroupArray count] > 0) {
    			[oemGroupArray removeAllObjects];
    			[oemGroupArray release];
    		}
		}
	}
	
	
	if([trans hasError] == NO){
		[trans commit];
		//데이터 베이스에 저장후 마지막 동기화 포인트 저장
		if(revisionPoint != nil){
			NSLog(@"동기화 포인트다.");
			NSString* revisionPoints = [[NSString alloc] initWithFormat:@"%@",revisionPoint];
			[[NSUserDefaults standardUserDefaults] setObject:revisionPoints forKey:@"RevisionPoints"];
			[revisionPoints release];
		}
		
		//유저 데이터만 업데이트 되면
		if(userData != nil){
			DebugLog(@"여기냐??");
			[[NSUserDefaults standardUserDefaults] setObject:lastSyncDate forKey:@"lastSyncDate"];
		}
		
		//mezzo	[lastSyncDate release];
		//mezzo	[formatter release];
		//	self.logoImageAnimationTimer = nil;
		//tmp	[[self appDelegate] goMain:self];
		
	}else {
		[trans rollback];
	}
	
}

#pragma mark -
#pragma mark NSNotification registOnMobile response
-(void)registOnMobile:(NSNotification *)notification
{	
	DebugLog(@"\n----- [HTTP] 이용자 가입 완료 ( registOnMobile ) ---------->");
	LOGINSTART = NO;
	LOGINEND = YES;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"registOnMobile" object:nil];
	
	USayHttpData *data = (USayHttpData*)[notification object];
	if (data == nil) {
		// 200 이외의 에러
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" 
															message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0065)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return;
	}
	
	//	NSString *api = data.api;	
	NSString *resultData = data.responseData;
	
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
		
		if ([rtType isEqualToString:@"map"]) {
			// Key and Dictionary as its value type
			NSDictionary *addressDic = [dic objectForKey:@"map"];
			
			NSString *ucmc = [addressDic objectForKey:@"UCMC"];
			NSString *uccs = [addressDic objectForKey:@"UCCS"];
			NSString *mc = [addressDic objectForKey:@"MC"];			// 파란ID 매핑된 회원 인 경우만 내려옴
			NSString *cs = [addressDic objectForKey:@"CS"];			// 파란ID 매핑된 회원 인 경우만 내려옴
			NSString *userno = [addressDic objectForKey:@"userno"];
			
			[[[self appDelegate] myInfoDictionary] setObject:[addressDic objectForKey:@"pkey"] forKey:@"pkey"];
			[[[self appDelegate] myInfoDictionary] setObject:[addressDic objectForKey:@"exip"] forKey:@"exip"];
			//			[[[self appDelegate] myInfoDictionary] setObject:[addressDic objectForKey:@"userno"] forKey:@"userno"];
			// sochae 2010.10.12 - nickname은 NSUserDefaults에만 저장.
			//[[[self appDelegate] myInfoDictionary] setObject:[addressDic objectForKey:@"nickName"] forKey:@"nickname"];
			[[[self appDelegate] myInfoDictionary] setObject:ucmc forKey:@"UCMC"];
			[[[self appDelegate] myInfoDictionary] setObject:uccs forKey:@"UCCS"];
			//[[NSUserDefaults standardUserDefaults] setObject:[addressDic objectForKey:@"nickName"] forKey:@"nickName"];
			[JYUtil saveToUserDefaults:[addressDic objectForKey:kNickname] forKey:kNickname];
			// ~sochae
			
			if ([userno length]) {
				[[[self appDelegate] myInfoDictionary] setObject:userno forKey:@"userno"];
			} else {
				[[[self appDelegate] myInfoDictionary] setObject:[NSNull null] forKey:@"userno"];
			}
			if ([mc length]) {
				[[[self appDelegate] myInfoDictionary] setObject:mc forKey:@"MC"];
			} else {
				[[[self appDelegate] myInfoDictionary] setObject:[NSNull null] forKey:@"MC"];
			}
			if ([cs length]) {
				[[[self appDelegate] myInfoDictionary] setObject:cs forKey:@"CS"];
			} else {
				[[[self appDelegate] myInfoDictionary] setObject:[NSNull null] forKey:@"CS"];
			}
			
			// cookie setting
			[HttpAgent setCookie:ucmc cookieUCCS:uccs cookieMC:mc cookieCS:cs];
			
			[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"notivibrate"];
			[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"notisound"];
			[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"apnsonpreview"];
			
			NSString *improxy = [NSString stringWithString:[addressDic objectForKey:@"improxy"]];	// format "아이피:포트" 
			NSString *improxyAddr = nil;
			NSString *improxyPort = nil;
			if ([improxy length] > 0) {
				NSRange range = [improxy rangeOfString:@":"];
				if (range.location == NSNotFound) {
					// TODO: 세션접속 정보 format 에러. 예외처리 필요
				} else {
					improxyAddr = [improxy substringToIndex:range.location];
					improxyPort = [[improxy substringFromIndex:range.location+1] substringToIndex:[improxy length]-(range.location+1)];
				}
			}
			//*
			if([[self appDelegate] connect:improxyAddr PORT:[improxyPort intValue]]) {
				LOGINSUCESS = YES;
				
				
				
				
//				[[self appDelegate] requestProposeUserList];
				// success!
			} else {
				// TODO: 예외처리 필요 (세션연결 실패)
			}
			//*/
		} else {
			// TODO: 예외처리
		}
	} //웹가입자..
	
	else if ([rtcode isEqualToString:@"12"]) {
		DebugLog(@"웹 가입지ㅏ..");
		
		NSString *rtType = [dic objectForKey:@"rttype"];
		
		if ([rtType isEqualToString:@"map"]) {
			
			
	//		[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"joinWebUser"];
			
			// Key and Dictionary as its value type
			NSDictionary *addressDic = [dic objectForKey:@"map"];
			
			NSString *ucmc = [addressDic objectForKey:@"UCMC"];
			NSString *uccs = [addressDic objectForKey:@"UCCS"];
			NSString *mc = [addressDic objectForKey:@"MC"];			// 파란ID 매핑된 회원 인 경우만 내려옴
			NSString *cs = [addressDic objectForKey:@"CS"];			// 파란ID 매핑된 회원 인 경우만 내려옴
			NSString *userno = [addressDic objectForKey:@"userno"];
			NSString *lastsyncdate = [addressDic objectForKey:@"lastsynctime"];		// unix TimeStamp 13 자리로 옴.
			
			NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
			NSDate* lastsynctime = [NSDate dateWithTimeIntervalSince1970:[lastsyncdate doubleValue]/1000 ];
			NSLocale* locale = [NSLocale currentLocale];
			[formatter setLocale:locale];
			[formatter setDateFormat:@"yyyyMMddHHmmss"];
			
			NSString* lastSyncDate = [[NSString alloc] initWithFormat:@"%@",[formatter stringFromDate:lastsynctime]];
			//기 사용자가 다시 설치하였을 경우. oem 주소록의 정보는 마지막 싱크 날짜 이후의 날자를 보내준다.
			//	if(lastSyncDate){
			//			NSString* revisionPoint = [[NSUserDefaults standardUserDefaults] objectForKey:@"RevisionPoints"];
			//	if(revisionPoint == nil || [revisionPoint isEqualToString:@"0"]){
			//			}else{
		//	[self appDelegate].registSynctime = lastSyncDate;
			
			
			
			NSLog(@"바뀌는 구간.. %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"lastSyncDate"]);
			
			
			
			
			
	//		[[NSUserDefaults standardUserDefaults] setObject:lastSyncDate forKey:@"lastSyncDate"];
			
			NSLog(@"바뀌는 구간2.. %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"lastSyncDate"]);
			
			
			//	}
			//	}
			[lastSyncDate release];
			[formatter release];
			
			[[[self appDelegate] myInfoDictionary] setObject:[addressDic objectForKey:@"pkey"] forKey:@"pkey"];
			[[[self appDelegate] myInfoDictionary] setObject:[addressDic objectForKey:@"exip"] forKey:@"exip"];
			//			[[[self appDelegate] myInfoDictionary] setObject:[addressDic objectForKey:@"userno"] forKey:@"userno"];
			// sochae 2010.10.12 - nickname은 NSUserDefaults에만 저장.
			//[[[self appDelegate] myInfoDictionary] setObject:[addressDic objectForKey:@"nickName"] forKey:@"nickname"];
			[[[self appDelegate] myInfoDictionary] setObject:ucmc forKey:@"UCMC"];
			[[[self appDelegate] myInfoDictionary] setObject:uccs forKey:@"UCCS"];
			//[[NSUserDefaults standardUserDefaults] setObject:[addressDic objectForKey:@"nickName"] forKey:@"nickName"];
			[JYUtil saveToUserDefaults:[addressDic objectForKey:kNickname] forKey:kNickname];
			// ~sochae
			DebugLog(@"\n  ===> [myInfo] pkey : %@ ", [addressDic objectForKey:@"pkey"]);
			DebugLog(@"\n  ===> [plist] nickName : %@ ", [JYUtil loadFromUserDefaults:kNickname]);
			DebugLog(@"\n  ===> [plist] lastsynctime : %@ (%@)", [JYUtil loadFromUserDefaults:kLastSyncTime], [appD registSynctime]);
			
			if ([userno length]) {
				[[[self appDelegate] myInfoDictionary] setObject:userno forKey:@"userno"];
			} else {
				[[[self appDelegate] myInfoDictionary] setObject:[NSNull null] forKey:@"userno"];
			}
			if ([mc length]) {
				[[[self appDelegate] myInfoDictionary] setObject:mc forKey:@"MC"];
			} else {
				[[[self appDelegate] myInfoDictionary] setObject:[NSNull null] forKey:@"MC"];
			}
			if ([cs length]) {
				[[[self appDelegate] myInfoDictionary] setObject:cs forKey:@"CS"];
			} else {
				[[[self appDelegate] myInfoDictionary] setObject:[NSNull null] forKey:@"CS"];
			}
			
			// cookie setting
			[HttpAgent setCookie:ucmc cookieUCCS:uccs cookieMC:mc cookieCS:cs];
			
			[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"notivibrate"];
			[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"notisound"];
			[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"apnsonpreview"];
			
			NSString *improxy = [NSString stringWithString:[addressDic objectForKey:@"improxy"]];	// format "아이피:포트" 
			NSString *improxyAddr = nil;
			NSString *improxyPort = nil;
			if ([improxy length] > 0) {
				NSRange range = [improxy rangeOfString:@":"];
				if (range.location == NSNotFound) {
					// TODO: 세션접속 정보 format 에러. 예외처리 필요
					UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0066)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
					[alertView show];
					[alertView release];
				} else {
					improxyAddr = [improxy substringToIndex:range.location];
					improxyPort = [[improxy substringFromIndex:range.location+1] substringToIndex:[improxy length]-(range.location+1)];
					[[self appDelegate].myInfoDictionary setObject:improxyAddr forKey:@"proxyhost"];
					[[self appDelegate].myInfoDictionary setObject:improxyPort forKey:@"proxyport"];
				}
			}
			//*
			if([[self appDelegate] connect:improxyAddr PORT:[improxyPort intValue]]) {
				
				LOGINSUCESS = YES;
		// 				[[self appDelegate] requestProposeUserList];
				// success!
			} else {
				// TODO: 예외처리 필요 (세션연결 실패)
			}
			
		} else {
			// TODO: 예외처리
		}
		
	} else if ([rtcode isEqualToString:@"1000"] || [rtcode isEqualToString:@"-1000"]) {
		// TODO: 가입실패(가입 필요) 예외처리 필요
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"가입 실패" message:@"핸드폰 번호를 다시 한번\n확인 해주시기 바랍니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"CertificationStatus"];
	} else if ([rtcode isEqualToString:@"-9030"]) {
		// TODO: 처리오류. 예외처리 필요
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"가입 실패" message:@"핸드폰 번호를 다시 한번\n확인 해주시기 바랍니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"CertificationStatus"];
	} else if ([rtcode isEqualToString:@"-1080"]) {
		// TODO: 이미 존재하는 이용자임. 예외처리 필요
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"가입 실패" message:@"이미 등록된 폰번호 입니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"CertificationStatus"];
	} else {
		// TODO: 기타오류 예외처리 필요
		// fail (-9030, -1080 이외 기타오류)
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"가입 실패" 
															message:@"네트워크나 기타 다른 이유로 가입 실패 되었습니다.\n잠시후 다시 시도해 주시기 바랍니다." 
														   delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"CertificationStatus"];
	}
}


@end
