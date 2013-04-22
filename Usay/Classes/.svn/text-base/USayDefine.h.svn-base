/*
 *  USayDefine.h
 *  USayApp
 *
 *  Created by 선옥 채 on 10. 9. 9..
 *  Copyright 2010 INAMASS.NET. All rights reserved.
 *
 */


#import "JYUtil.h"

#define appD		((USayAppAppDelegate *)[[UIApplication sharedApplication] delegate])

////////////////////////////////////////////////////
//
//#define	_DEVEL_MODE					// 개발 모드 -> 개발 서버 사용하도록.
#define _DEBUG_MODE					// Debug 모드 -> Loging
#define _MEZZO_DEBUG
#define _SEND_USAY_SERVER

////////////////////////////////////////////////////
// url info.
#ifdef DEVEL_MODE
	#define	URL_SET_DEVTOKEN			@"https://social.paran.com/KTH/setDevToken.json"		// DeviceToken 전송
	#define URL_SEND_CRASH_REPORT		@"https://social.paran.com/KTH/sendCrashReport.json"	// Crash Report 전송
#else

	#define	URL_SET_DEVTOKEN			@"https://dev.usay.net/KTH/setDevToken.json"
	#define URL_SEND_CRASH_REPORT		@"https://dev.usay.net/KTH/sendCrashReport.json"		// Crash Report 전송

#endif //DEVEL_MODE

////////////////////////////////////////////////////
// notification key values
#define kNotiSetDevToken		@"setDevToken"
#define kNotiSendCrashReport	@"sendCrashReport"

#define kNotiRequestHttp		@"requestHttp"

////////////////////////////////////////////////////
// server protocol(http body) key values
#define kSvrDevToken			@"devtoken"

////////////////////////////////////////////////////
// user default property key values
#define kDeviceToken			@"devicetoken"
#define kNickname				@"nickName"			// nickName은 NSUserDefaults에 저장.
#define kRevisionPoint			@"RevisionPoints"
#define kCertState				@"CertificationStatus"
#define	kLastSyncTime			@"lastsynctime"
#define kLastUpdateTime			@"lastUpdateTime"	// 마지막 세션 업데이트 시간.
#define kAppVersion				@"appVersion"			// usay app version 
#define kIsCrashLog				@"isCrashLog"			// App 구동 시, crash report check
#define kWebPKey				@"webKey"				// 웹의 pKey
#define kPKey					@"pKey"					// 단말 고유 pKey

////////////////////////////////////////////////////
// HTTP BODY TYPE
#define PARAM_SVCIDX			@"svcid"
#define PARAM_MTYPE				@"mType"
#define PARAM_SKEY				@"sessionKey"
#define PARAM_MSG				@"message"
#define PARAM_UUID				@"uuid"
#define PARAM_CERT				@"test"		         // inhouse 인증서 사용을 위해 추가. 

////////////////////////////////////////////////////
// string
#define DEF_MENU_SYNC			@" iPhone 연락처로 내보내기"

#define DEF_TEXT_EXPORT			@"Usay 주소록을\niPhone연락처로 내보냅니다."

////////////////////////////////////////////////////
// DB Query
#define QUERY_USER_NO_BLOCK				@"select * from _TUserInfo where ISBLOCK='N'"

////////////////////////////////////////////////////
// Certificate

#ifdef DEVEL_MODE
	#define CERT_KIND			@"1"		         // inHouse Certificate
#else
	#define CERT_KIND			@""			         // AppStore Certificate
#endif

////////////////////////////////////////////////////
// Log
#ifdef DEBUG_MODE

//	#define DebugLog( s, ... ) NSLog( @"<%@:(%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
//	#define DebugLog( s, ... ) NSLog( @"<%s:(%d)> %@", __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )

//#else // DEBUG_MODE

//	#define DebugLog( s, ... ) 

#define LOG_NORMAL
#define LOG_APNS
#define LOG_TIME

#endif // DEBUG_MODE

//
#ifdef LOG_TIME
#define timeLog( s, ... ) NSLog( @"<%s:(%d)> %@", __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else // DEBUG_MODE
#define timeLog( s, ... ) 
#endif

//
#ifdef LOG_APNS
#define apnsLog( s, ... ) NSLog( @"<%s:(%d)> %@", __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else // DEBUG_MODE
#define apnsLog( s, ... ) 
#endif

//
#ifdef LOG_NORMAL
#define DebugLog( s, ... ) NSLog( @"<%s:(%d)> %@", __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define DebugLog( s, ... ) 
#endif // DEBUG_MODE
