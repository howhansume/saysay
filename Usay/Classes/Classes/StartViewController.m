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

//#define ID_LOGOIMAGEVIEW	3001

@implementation StartViewController
@synthesize startTimer;


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
	return [[UIApplication sharedApplication] delegate];
}

#pragma mark -
#pragma alertViewmark UIAlertView delegate Method
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	NSLog(@"buttonIndex %i",buttonIndex);
	if([alertView.title isEqualToString:@"단말 중복 등록(-1060)"] || [alertView.title isEqualToString:@"인증 실패(-1070)"])
	{
		NSLog(@"====> 중복 오류로 인한 종료 처리");
		
		//삭제 루틴 추가 함 20101010
		//plist 삭제
		[[NSUserDefaults standardUserDefaults] setPersistentDomain:[NSDictionary dictionary]
														   forName:[[NSBundle mainBundle] bundleIdentifier]];
		
		// mezzo 로컬 sql 파일 삭제
		NSString *appSqlPath;// = [[NSBundle mainBundle] resourcePath];
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSString *subFolder = [NSString stringWithFormat:@"Documents/%@", @"usay.sqlite"] ;
		appSqlPath = [NSHomeDirectory() stringByAppendingPathComponent:subFolder];
		NSLog(@"App sql file is : %@", appSqlPath);
		
		BOOL            result;
		
		result = [fileManager removeItemAtPath:appSqlPath error:nil];
		if (result == YES) {
			NSLog(@"usay.sqlite delete success!!");
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
-(void) startControl:(NSTimer *)theTimer{
	[theTimer invalidate];
	 self.startTimer = nil;
	[indicator startAnimating];
	
	SQLiteDatabase* dataBase = [[SQLiteDatabase alloc] init];
	SQLiteDataAccess* isDatabase	= [dataBase initWithOpenSQLite];
	//[dataBase release]; mezzo
	if(isDatabase != nil){
		[self appDelegate].database = isDatabase;
		[isDatabase release];
	}
	
	if([self appDelegate].database == nil){
		[self migrationDatabase];
		[[self appDelegate] dbInitialize];
		[[self appDelegate] setIsFirstUser:YES];
		[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"CertificationStatus"];
#ifdef MEZZO_DEBUG
		NSLog(@"DB OKOKOK");
#endif
		[[self appDelegate] goRegistration];	// 가입처리
//		self.logoImageAnimationTimer = nil;
	} else {
		[[self appDelegate] dbInitialize];
		NSInteger authState = [[NSUserDefaults standardUserDefaults] integerForKey:@"CertificationStatus"];
		NSArray *tmpA = [UserInfo findWithSql:@"select id from _TUserInfo"];
		if(authState != -1 && [tmpA count]<=0){ //
			[[self appDelegate] setIsFirstUser:YES];
			
			DebugLog(@"authStae = %d", authState);
			DebugLog(@"tmpa = %d", [tmpA count]);
			
			//2면 아이디 발급전 상태 4면 시작 -1완료 
	//		여기에 데이터 베이스도 존재하면 추가한다.
			if(authState == 4) {//로딩중 종료 되었다면 로딩 화면 부터 다시 시작.
				// sochae 2010.10.12
				//NSString* nickName = [[NSUserDefaults standardUserDefaults] objectForKey:@"nickName"];
				NSString *nickName = (NSString *)[JYUtil loadFromUserDefaults:kNickname];
				// ~sochae
				if([[NSUserDefaults standardUserDefaults] valueForKey:@"AuthPhoneNumber"]) {// key is Defined
					NSString *authPhoneNumber = [[NSUserDefaults standardUserDefaults] valueForKey:@"AuthPhoneNumber"];
					if(authPhoneNumber != nil && [authPhoneNumber length] > 0){
						authPhoneNumber = (NSMutableString *)[authPhoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
						
						// 노티피케이션처리관련 등록..
						[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registOnMobile:) name:@"registOnMobile" object:nil];
						
						NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:
													authPhoneNumber, @"mobilePhoneNumber",
													[self md5:[UIDevice currentDevice].uniqueIdentifier], @"mobileSecretKey",
#if TARGET_IPHONE_SIMULATOR
													@"1234567890123456789012345678901234567890123456789012345678901234", @"devtoken", 
#else
													([[[self appDelegate] myInfoDictionary] objectForKey:@"devicetoken"] == nil) ? [NSNull null] : [[[self appDelegate] myInfoDictionary] objectForKey:@"devicetoken"], @"devtoken", 
#endif
													[[self appDelegate] getSvcIdx], @"svcidx", 
													nickName, @"nickName",
													@"Y", @"secretKeyAlreadyEncryped",
													nil];
						
						
						USayHttpData *data = [[[USayHttpData alloc]initWithRequestData:@"registOnMobile" andWithDictionary:bodyObject timeout:10] autorelease];
						
//						assert(data != nil);		
						[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
					}else {
						//전화 번호가 저장되어 있지 않다. 처음부터 다시 시작하게 유도.
						UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"등록 실패" 
																			message:@"입력된 폰번호 정보가 없습니다.\n앱 종료후 처음부터 진행하여 주세요." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
						[alertView show];
						[alertView release];
						
						[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"CertificationStatus"];
						
					}
					
				}else {
					//plist에 키값이 없다.
					UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"등록 실패" 
																		message:@"폰번호 정보를 읽어오지 못했습니다.\n앱 종료후 처음부터 진행하여 주세요." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
					[alertView show];
					[alertView release];
					
					[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"CertificationStatus"];
				}
				return;
			}
			else {
				
				//가입화면
				[[self appDelegate] goRegistration];	// 가입처리
			}
//			self.logoImageAnimationTimer = nil;
			return;
		}
		
		
		//한번이라도 로딩이 완료된 유저
		if([self appDelegate].connectionType == -1){ //오프라인 모드 일경우 가입중이 아니라면 바로 메인으로 넘긴다.
			/* sochae 2010.09.28
			UIAlertView* offlineAlert = [[UIAlertView alloc] initWithTitle:@"오프라인"
																   message:@"현재 네트워크 연결이 불가능한 상태 입니다.\nUsay의 모든 기능을 이용하기 위해서는 네트워크 연결이 필요합니다." 
																  delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
			[offlineAlert show];
			[offlineAlert release];
			*/
			[JYUtil alertWithType:ALERT_NET_OFFLINE delegate:self];
			//~sochae
			return;
		}
//		[self syncOEMAddress];
//		return;
#if TARGET_IPHONE_SIMULATOR
		NSMutableString *devicePhoneNumer = [NSMutableString stringWithString:@"01032310142"];
#else
		NSMutableString *devicePhoneNumer = (NSMutableString*)[[NSUserDefaults standardUserDefaults] stringForKey:@"AuthPhoneNumber"];
#endif
		////////////////////////////////////////////////////////////////////////
		// 국가번호 제거후 +82 10-1234-5678 ===> 010-1234-5678 형태로 만듬.
		NSRange findRange;
		findRange = [devicePhoneNumer rangeOfString:@" "];
		if(findRange.location != NSNotFound) {
			devicePhoneNumer = (NSMutableString *)[devicePhoneNumer substringFromIndex:findRange.location+1];
			devicePhoneNumer = (NSMutableString *)[NSString stringWithFormat:@"0%@", devicePhoneNumer];
		}
		////////////////////////////////////////////////////////////////////////
		
		// '-' 제거 010-1234-5678 ===> 01012345678 형태로 만듬.
		devicePhoneNumer = (NSMutableString *)[devicePhoneNumer stringByReplacingOccurrencesOfString:@"-" withString:@""];
		
		// 인증 처리
		// 폰 인증 프로토콜
//		NSString *url = [[self appDelegate] protocolUrl:@"AUTH"]; //@"http://imbeta.paran.com:8081/usay/auth.json";
		// value, key, value, key ...
		
		
		NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
//		assert(bodyObject != nil);
		[bodyObject setObject:devicePhoneNumer forKey:@"mobilePhoneNumber"];
		[bodyObject setObject:[self md5:[UIDevice currentDevice].uniqueIdentifier] forKey:@"mobileSecretKey"];
		if ([[[self appDelegate] myInfoDictionary] objectForKey:@"devicetoken"] && [[[[self appDelegate] myInfoDictionary] objectForKey:@"devicetoken"] length] > 0) {
			[bodyObject setObject:[[[self appDelegate] myInfoDictionary] objectForKey:@"devicetoken"] forKey:@"devtoken"];
		}
		[bodyObject setObject:[[self appDelegate] getSvcIdx] forKey:@"svcidx"];
		[bodyObject setObject:@"Y" forKey:@"secretKeyAlreadyEncryped"];
		
		
		// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정		
		USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"loginOnMobile" andWithDictionary:bodyObject timeout:15] autorelease];
//		assert(data != nil);
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
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

-(void)loginOnMobile:(NSNotification *)notification
{
	[indicator stopAnimating];
	USayHttpData *data = (USayHttpData*)[notification object];
	if (data == nil) {
		// 200 이외의 에러
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0064)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
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
	//		NSLog(@"rtcode: %@", rtcode);
	if ([rtcode isEqualToString:@"0"]) {	// success
		NSString *rtType = [dic objectForKey:@"rttype"];
		//			NSLog(@"rttype: %@", rtType);
		
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
					[[self appDelegate].myInfoDictionary setObject:improxyAddr forKey:@"proxyhost"];
					[[self appDelegate].myInfoDictionary setObject:improxyPort forKey:@"proxyport"];
				}
			}

			// sochae 2010.09.30 - Login 성공 시 device token 전송
			appD.isLogin = YES;
			[[self appDelegate] sendDeviceToken];
			// ~sochae

			// sochae 2010.09.27 - 여기서 Reachability 한번만 실행. 
			DebugLog(@"[RESPONSE] Login Success (%@) !!!", improxyAddr);
			[[self appDelegate] setupReachability:improxyAddr];
			// ~sochae

			// TODO: Host Connect
			if([[self appDelegate] connect:improxyAddr PORT:[improxyPort intValue]]) {
				// success!
			} else {
				// TODO: 예외처리 필요 (세션연결 실패)
			}
			
		} else {
			// TODO: 예외처리
		}
	} else if ([rtcode isEqualToString:@"1000"] || [rtcode isEqualToString:@"-1000"]) {
		// TODO: 인증실패(가입 필요) 예외처리 필요
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"로그인 실패" message:@"가입 정보가 없습니다. 재설치 후 가입하여 주세요.(errcode 1000,-1000)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else if ([rtcode isEqualToString:@"-1010"]) {
		
		// TODO: 인증실패 예외처리 필요 (pKey 를 찾을수 없음)
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"로그인 실패" message:@"가입 정보가 없습니다. 재설치후 가입하여 주세요.(errcode -1010)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
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
		NSLog(@"App sql file is : %@", appSqlPath);
		
		BOOL            result;
		
		result = [fileManager removeItemAtPath:appSqlPath error:nil];
		if (result == YES) {
			NSLog(@"usay.sqlite delete success!!");
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
		NSLog(@"App sql file is : %@", appSqlPath);
		
		BOOL            result;
		
		result = [fileManager removeItemAtPath:appSqlPath error:nil];
		if (result == YES) {
			NSLog(@"usay.sqlite delete success!!");
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


-(void)addListContact:(NSNotification *)notification {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"addListContactIncludeGroup" object:nil];
//	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"addListContact" object:nil];
	
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
				
				nCount++;
			}
			
			//내려 받은 개수와 리스트를 파싱한 개수가 같을 경우에 저장.
			if([count isEqualToString:[NSString stringWithFormat:@"%i",nCount]])
				[self syncDatabase:userArray withGroupinfo:groupArray saveRevisionPoint:RP];			
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
		
	} else if ([rtcode isEqualToString:@"-9020"]) {
		// TODO: 잘못된 인자가 넘어옴
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"동기화 경고" message:@"잘못된 값이 포함되어 있습니다.(-9020)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		[self syncDatabase:nil withGroupinfo:nil saveRevisionPoint:nil];
		
	} else if ([rtcode isEqualToString:@"-9030"]) {
		// TODO: 서버상의 처리 오류. 예외처리 필요
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"동기화 경고" message:@"처리 오류가 발생하였습니다.\n종료후 다시 실행해주세요.(-9030)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		[self syncDatabase:nil withGroupinfo:nil saveRevisionPoint:nil];
	} else {
		// TODO: 기타오류 예외처리 필요
		NSString* errcode = [NSString stringWithFormat:@"(%@)",rtcode];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"동기화 경고" message:errcode delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		[self syncDatabase:nil withGroupinfo:nil saveRevisionPoint:nil];
		
	}
	
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

-(void)getLastAfterRP:(NSNotification *)notification {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"getLastAfterRP" object:nil];
	
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
				[self syncDatabase:userArray withGroupinfo:groupArray saveRevisionPoint:RP];
			
		} else if([rtType isEqualToString:@"only"] ) {
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
    [super viewDidAppear:animated];
	[[UIApplication sharedApplication] setStatusBarHidden:YES];
	indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	indicator.frame = CGRectMake(self.view.frame.size.width/2.0, (self.view.frame.size.height/2.0)+50, 20.0, 20.0);
//	indicator.center = self.view.center;
	[self.view addSubview:indicator];

	// 노티피케이션처리관련 등록..
	//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initOnMobile:) name:@"initOnMobile" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginOnMobile:) name:@"loginOnMobile" object:nil];

	/* sochae 2010.09.27
	if ([[self appDelegate] connectedToNetwork]) {
		NSLog(@"네트워크 연결 됨");
		if ([[self appDelegate] isCellNetwork]) {
			NSLog(@"3G 네트워크 연결 됨");
			[self appDelegate].connectionType = 2;	// -1:offline mode 0:disconnect 1:Wi-Fi 2:3G
		} else {
			NSLog(@"Wifi 네트워크 연결 됨");
			[self appDelegate].connectionType = 1;	// -1:offline mode 0:disconnect 1:Wi-Fi 2:3G
		}
	} else {
		[self appDelegate].connectionType = -1;	// -1:offline mode 0:disconnect 1:Wi-Fi 2:3G
		NSLog(@"네트워크 연결 안됨");
		
		//		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"오프라인" message:@"현재 네트워크 연결이 불가능한 상태입니다./nUsay의 모든 기능을 이용하기 위해서는 네트워크 연결이 필요합니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		//		[alertView show];
		//		[alertView release];
	}
	*/// New
	Reachability *internetReach = [Reachability reachabilityForInternetConnection];
	NetworkStatus netStatus = [internetReach currentReachabilityStatus];
	switch (netStatus)
    {
        case ReachableViaWWAN:
        {
            DebugLog(@"3G 연결 됨");
			[self appDelegate].connectionType = 2;		// 3G
            break;
        }
        
		case ReachableViaWiFi:
        {
            DebugLog(@"Wi-Fi 연결 됨");
			[self appDelegate].connectionType = 1;		// Wi-Fi
            break;
        }

		case NotReachable:
        {
            DebugLog(@"Network 연결 안됨");
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
	
	self.startTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self 
													 selector:@selector(startControl:) 
													 userInfo:nil repeats:NO];
	
	//	UIImageView *companyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"KTH_logo.png"]];
	//	assert(companyImageView != nil);
	//	[self.view addSubview:companyImageView];
	//	[companyImageView setFrame:CGRectMake(133, 428, 50, 11)];
	//	[companyImageView release];
	
	
//	if([self appDelegate].connectionType == -1){
//		
//		self.startTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self 
//														 selector:@selector(startControl:) 
//														 userInfo:nil repeats:NO];
//	}else {
//		NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:
//									[[self appDelegate] getSvcIdx], @"svcidx", 
//									nil];
//		
//		// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정		
//		USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"initOnMobile" andWithDictionary:bodyObject timeout:10] autorelease];
//		assert(data != nil);
//		
//		[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
		
//	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
#ifdef MEZZO_DEBUG
	NSLog(@"스타트 뷰");
#endif
	
	
	
	// sochae 2010.09.11 - UI Position
	[self.view setFrame:[[UIScreen mainScreen] bounds]];
	 
/*	//디바이스 해상도
	DeviceResolutionType resolutionType = [MyDeviceClass deviceResolution];
	if (resolutionType == Type_320_480) {
		[self.view setFrame:CGRectMake(0, 0, 320, 480)];
	} else if (resolutionType == Type_640_960) {
		[self.view setFrame:CGRectMake(0, 0, 640, 960)];
	} else {	// Type_768_1024
		[self.view setFrame:CGRectMake(0, 0, 768, 1024)];
	}
*/
	UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default.png"]];
//	assert(backgroundImageView != nil);
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
}

- (void)viewDidDisappear:(BOOL)animated 
{
	//뷰가 사라지면 노티 삭제
    [super viewDidDisappear:animated];
//	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"initOnMobile" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"loginOnMobile" object:nil];
	
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
//	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"initOnMobile" object:nil];
	[indicator release];
//	if (logoImageAnimationTimer != nil) {
//		[logoImageAnimationTimer release];
//	}
	
    [super dealloc];
}

#pragma mark -
#pragma mark NSDictionary convert to SQLiteDataAccess`s NSDictionary
-(BOOL)changeDataDictionary:(NSMutableDictionary *)dicData{
	
	UserInfo *userData22 = [[dicData objectForKey:@"PERSON"] objectAtIndex:0];
	
	NSLog(@"함수 넘어왔다. %@", userData22.RECORDID);
	
	//사용자 정보 저장
	NSDictionary *rpdict = nil, *contactDic = nil, *contactCnt = nil, *recordDic =nil;
	NSString	*body = nil;
	NSString	*listbody = nil;
	
	NSMutableArray* contactList = [NSMutableArray array];
	if ([oemGroupArray count] > 0) {
		[oemGroupArray removeAllObjects];
		[oemGroupArray release];
	}
	oemGroupArray = [[NSMutableArray alloc] initWithCapacity:0];
	for(GroupInfo *groupData in [dicData objectForKey:@"GROUP"]){
		NSArray* compareGroup = [GroupInfo findAll];
		NSMutableDictionary *group = [[NSMutableDictionary alloc] initWithCapacity:0];
		for(GroupInfo* localgroup in compareGroup){
			if([groupData.RECORDID	isEqualToString:localgroup.RECORDID]){
				groupData.ID = localgroup.ID;
				if(![groupData.GROUPTITLE isEqualToString:localgroup.GROUPTITLE]){//레코드번호는 같고 그룹이름이 다를 경우 그룹 이름이 바뀐걸로 설정
					groupData.SIDUPDATED = @"mobile";
					[group setObject:[groupData valueForKey:@"RECORDID"  ] forKey:@"gid"];
					[group setObject:[groupData valueForKey:@"GROUPTITLE"] forKey:@"grouptitle"];
					[group setObject:[groupData valueForKey:@"SIDUPDATED"] forKey:@"sidupdated"];
				}
				break;
			}
		}
		
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
		NSLog(@"dicCount = %d", [[dicData objectForKey:@"PERSON"] count]);
		
		
		
		
	
		UserInfo *userData2;
		
		//[[dicData objectForKey:@"PERSON"] objectAtIndex:i];
		
		
		
		
		//UserInfo *userData33 = [[dicData objectForKey:@"PERSON"] objectAtIndex:i];
		
		userData2 = (UserInfo*)[[[dicData objectForKey:@"PERSON"] objectAtIndex:i] copy];
		
	
		
	//	[userData2 copy:[[dicData objectForKey:@"PERSON"] objectAtIndex:i]];
		
		//[[[dicData objectForKey:@"PERSON"] objectAtIndex:i] copy:userData2];		
		
		
		NSLog(@"함수 넘어왔다333. %@", userData2.RECORDID);
		
		
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
				
				if([key isEqualToString:@"RECORDID"] || [key isEqualToString:@"IMSTATUS"] || 
				   [key isEqualToString:@"IDXNO"] || [key isEqualToString:@"ISBLOCK"])
					continue;
				
				[contact setObject:[userData2 valueForKey:key] forKey:[key lowercaseString]];
				
				
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
	
	NSArray *newRP = [UserInfo findWithSql:@"select * from _TUserInfo order by RPCREATED+0 desc limit 1"];
	
	for (UserInfo *newUser in newRP) {
		
	
			NSLog(@"============newUSER.RP = %@", newUser.RPCREATED);

		if(![[NSUserDefaults standardUserDefaults] objectForKey:@"lastSyncDate"])
		{
			//20101002
			NSInteger newRp = [newUser.RPCREATED intValue]-2;
			if (newRP <=0) {
				newRP = 0;
			}
			NSString *newRpstring = [NSString stringWithFormat:@"%d", newRp];
			revisionPoint = newRpstring;
			NSLog(@"/////////중간에 끊겨서 싱크 맞춘다.. %@", revisionPoint);
			
		}
		
		/*
		if([revisionPoint isEqualToString:@"0"] && [newRP count]>0)
		{
			//20101002
			revisionPoint = newUser.RPCREATED;
			NSLog(@"/////////중간에 끊겨서 싱크 맞춘다.. %@", revisionPoint);
		}else {
			NSLog(@"RP is %@", revisionPoint);
		}
*/
		
	}
	
	
	/*
	
	
	rpdict = [NSDictionary dictionaryWithObjectsAndKeys:
			  revisionPoint, @"RP",
			  nil];
	
	[paramArray addObject:rpdict];
	
	contactCnt = [NSDictionary dictionaryWithObjectsAndKeys:
				  [NSString stringWithFormat:@"%i",[contactList count]], @"count",
				  nil];
	
	[paramArray addObject:contactCnt];
	
	contactDic = [NSDictionary dictionaryWithObjectsAndKeys: 
				  contactList,  @"contact",
				  nil];
	
	
	
	
	
	[paramArray addObject:contactDic];
	 
	 */
	
	
	
	
	rpdict = [NSDictionary dictionaryWithObjectsAndKeys:
			  revisionPoint, @"RP",
			  nil];
	
	[paramArray addObject:rpdict];
	//[paramArray addObject:userData22.RECORDID];
	
	contactDic = [NSDictionary dictionaryWithObjectsAndKeys: 
				  contactList,  @"contact",
				  nil];
	
	
	
	
	
	if(![[NSUserDefaults standardUserDefaults] objectForKey:@"lastSyncDate"])
	{
		contactCnt = [NSDictionary dictionaryWithObjectsAndKeys:
					  [NSString stringWithFormat:@"%i", 0], @"count",
					  nil];
		
		[paramArray addObject:contactCnt];
		
		
		
	}
	else {
		contactCnt = [NSDictionary dictionaryWithObjectsAndKeys:
					  [NSString stringWithFormat:@"%i",[contactList count]], @"count",
					  nil];
		
		NSLog(@"contact cnt  = %i", [contactList count]);
		[paramArray addObject:contactCnt];
		[paramArray addObject:contactDic];
	
		
		
	}
	
	
	recordDic = [NSDictionary dictionaryWithObjectsAndKeys:userData22.RECORDID,@"RECORDID", nil];
	[paramArray addObject:recordDic];
	
	
	
	// JSON 라이브러리 생성
	SBJSON *json = [[SBJSON alloc]init];
	[json setHumanReadable:YES];
	// 변환
	listbody = [json stringWithObject:paramArray error:nil];
	
	
	
	//여기에다가 RECORDID 셋팅하면 된다..
	
	NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:
								[[self appDelegate] getSvcIdx],@"svcidx",
								listbody, @"param",
								nil];
	
	// 변환
	body = [json stringWithObject:bodyObject error:nil];
	//	NSLog(@"%@",listbody);
	NSLog(@"딕셔너리 %@",body);
	[json release];
	USayHttpData *data = [[[USayHttpData alloc]initWithRequestData:@"addListContactIncludeGroup" andWithDictionary:bodyObject timeout:10] autorelease];
//	USayHttpData *data = [[USayHttpData alloc]initWithRequestData:@"addListContact" andWithDictionary:bodyObject timeout:10];	
//	assert(data != nil);		
	[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
	
	return YES;
}

-(BOOL)requestContactsData{
	
	NSString* revisionPoint = [[NSUserDefaults standardUserDefaults] objectForKey:@"RevisionPoints"];
	
	NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:
								[[self appDelegate] getSvcIdx],@"svcidx",
								(revisionPoint == nil) ? @"0" : revisionPoint, @"RP",
								nil];
	
//	SBJSON *json = [SBJSON alloc];
//	[json setHumanReadable:YES];
//	NSLog(@"%@",[json stringWithObject:bodyObject error:nil]);
//	[json release];
	USayHttpData *data = [[[USayHttpData alloc]initWithRequestData:@"getLastAfterRP" andWithDictionary:bodyObject timeout:10] autorelease];	
//	assert(data != nil);		
	[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
	
	return YES;
}

#pragma mark -
#pragma mark syncOEMAddress
-(void)syncOEMAddress
{
	// 1. 동기화 할 데이터 있는지 확인
	// 2. 없으면 goMain으로 처리
	// 3. 있으면 데이터 JSON 으로 생성후 (http or 전용소켓) 으로 패킷 전송후 Response 팻킷으로 Usay db에 추가 하고 plist에 동기화 시간 저장 goMain으로 처리
	AddressBookData* addrData = [[[AddressBookData alloc] init] autorelease];
	NSDictionary* contacts = [addrData readOEMContactsAlterData];
	
	
		
	
	
	
	//처음 설치자가 아니면서 DATABASE가 없으면 예전버젼 설치자..
	if(![[NSUserDefaults standardUserDefaults] objectForKey:@"DATABASE"])
	{
		
		NSLog(@"aaaaa %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"DATABASE"]);
		
		
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
		
		NSString *tmp = @"alter table _TUserInfo add CHANGEDATE2 text;";
		NSArray *tmpArr =  [[UserInfo database] executeSql:tmp];
		NSLog(@"tmpArr = %@", tmpArr);
		[[UserInfo database] commit];
		
		
		
			}
	[[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"DATABASE"];
	
	NSLog(@"bbbb %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"DATABASE"]);
	
	
	
	
	
	
	
	
	
	NSMutableDictionary* dicContacts = [NSMutableDictionary dictionary];
	NSArray* localGroup = [GroupInfo findAll];
	
	NSMutableArray* contactArray = [NSMutableArray arrayWithArray:[contacts objectForKey:@"PERSON"]];
	NSMutableArray* groupArray  = [NSMutableArray arrayWithArray:[contacts objectForKey:@"GROUP"]];
	
	for(GroupInfo* oemGroup in [contacts objectForKey:@"GROUP"]){//oem 그룹
		for(GroupInfo* dbGroup in localGroup){
			if([dbGroup.GROUPTITLE	isEqualToString:oemGroup.GROUPTITLE]){
				//그룹을 뺀다.
		//		if(dbGroup.RECORDID == nil && [dbGroup.RECORDID length] == 0){
					dbGroup.RECORDID = [NSString stringWithFormat:@"%@", oemGroup.RECORDID];
					NSString* sql = [NSString stringWithFormat:@"UPDATE %@ SET RECORDID = ? WHERE GROUPTITLE=?",[GroupInfo tableName]];
					[GroupInfo findWithSqlWithParameters:sql, oemGroup.RECORDID, dbGroup.GROUPTITLE,nil];
		//		}
				[groupArray removeObject:oemGroup];
			}
		}
	}
	
	NSArray* reLocalGroup = [GroupInfo findAll];
	for(UserInfo* oemUser in contactArray){
		
		NSLog(@"startView Oem ID  %@", oemUser.RECORDID);
		
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
		// 주소록 Bulk로 올리기. 노티피케이션처리관련 등록..
//		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addListContact:) name:@"addListContact" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addListContact:) name:@"addListContactIncludeGroup" object:nil];

		//웹으로 연결하여 유저 값을 받아 오면 database에 저장하기
		NSLog(@"StartViewController addListContact 호출");
		
		/*
		UserInfo *tmpData = [contactArray objectAtIndex:0];
		
		UserInfo *tmpData2 = [[dicContacts objectForKey:@"PERSON"] objectAtIndex:0];
		
		
		NSLog(@"함수 호출 전 RECORDID = %@", tmpData2.RECORDID);
		여기까진 문제 없이 값을 넘긴다.. */
		
		[self changeDataDictionary:dicContacts];
	} else {
		
		// 올릴 주소록이 없으면 주소록 얻기 노티피케이션처리관련 등록..
	//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getContacts:) name:@"getContacts" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getLastAfterRP:) name:@"getLastAfterRP" object:nil];

		//웹으로 연결하여 유저 값을 받아 오면 database에 저장하기
		[self requestContactsData];
		
//		[indicator stopAnimating];
//		[[self appDelegate] goMain:self];
	}
}
#pragma mark -
#pragma mark set database Method
-(void)migrationDatabase {
	[self appDelegate].database	= [[SQLiteDatabase alloc] initWithCreateSQLite];
	
	[[self appDelegate].database beginTransaction];//테이블 생성 시 트랜잭션 처리
	
	NSArray *tableNames = [[self appDelegate].database tableNames];
    if(![tableNames containsObject:[UserInfo tableName]]){
	   UserInfo* userInfo = [[UserInfo alloc] init];
	   [userInfo createTableForClass];
	   [userInfo release];
    }
	if(![tableNames containsObject:[GroupInfo tableName]]){
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
	if(![tableNames containsObject:[RoomInfo tableName]]){
		// 대화방 리스트 테이블 생성. _TROOMINFO
		RoomInfo* roomInfo = [[RoomInfo alloc] init];
		[roomInfo createTableForClass];
		[roomInfo release];
	}
	if(![tableNames containsObject:[MessageUserInfo tableName]]){
		// 대화방 버디 리스트 테이블 생성(대화방 리스트 보여줄때 필요) _TMESSAGEUSERINFO
		MessageUserInfo* msgUserInfo = [[MessageUserInfo alloc] init];
		[msgUserInfo createTableForClass];
		[msgUserInfo release];
	}
	if(![tableNames containsObject:[MessageInfo tableName]]){
		// 대화내용 테이블 생성. _TMESSAGEINFO
		MessageInfo* msgInfo = [[MessageInfo alloc] init];
		[msgInfo createTableForClass];
		[msgInfo release];
	}
//	
	[[self appDelegate].database commit];
}
		
-(void)syncDatabase:(NSArray*)userData withGroupinfo:(NSArray*)groupData saveRevisionPoint:(NSString*)revisionPoint {
//	[self appDelegate].database	= [[[SQLiteDatabase alloc] initWithCreateSQLite]autorelease];
	//오늘 일자를 구해 NSUserDefaults로 app 사용자 값에 저장한다.
	
	
	


	
	

	
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
				NSLog(@"DB delete UserInfo");
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
				NSLog(@"DB insert GroupInfo");
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
		if ([oemGroupArray count] > 0) {
			[oemGroupArray removeAllObjects];
			[oemGroupArray release];
		}		
	}
	
	
	if([trans hasError] == NO){
		[trans commit];
		//데이터 베이스에 저장후 마지막 동기화 포인트 저장
		if(revisionPoint != nil){
			NSString* revisionPoints = [[NSString alloc] initWithFormat:@"%@",revisionPoint];
			[[NSUserDefaults standardUserDefaults] setObject:revisionPoints forKey:@"RevisionPoints"];
			[revisionPoints release];
		}
		
		if(userData != nil || groupData != nil){
			DebugLog(@"여기냐??");
			[[NSUserDefaults standardUserDefaults] setObject:lastSyncDate forKey:@"lastSyncDate"];
		}
		
	//mezzo	[lastSyncDate release];
	//mezzo	[formatter release];
		//	self.logoImageAnimationTimer = nil;
		[[self appDelegate] goMain:self];

	}else {
		[trans rollback];
	}

}

#pragma mark -
#pragma mark NSNotification registOnMobile response
-(void)registOnMobile:(NSNotification *)notification
{	
	NSLog(@"=====================================================SET ONMOBILE===============================");
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
				// success!
			} else {
				// TODO: 예외처리 필요 (세션연결 실패)
			}
			//*/
		} else {
			// TODO: 예외처리
		}
	} else if ([rtcode isEqualToString:@"12"]) {
		NSString *rtType = [dic objectForKey:@"rttype"];
		
		if ([rtType isEqualToString:@"map"]) {
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
			[self appDelegate].registSynctime = lastSyncDate;
			[[NSUserDefaults standardUserDefaults] setObject:lastSyncDate forKey:@"lastSyncDate"];
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
				// success!
			} else {
				// TODO: 예외처리 필요 (세션연결 실패)
			}
			//*/
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
