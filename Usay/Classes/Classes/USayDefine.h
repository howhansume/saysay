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
#define	DEVEL_MODE					// 개발 모드 -> 개발 서버 사용하도록.
#define DEBUG_MODE					// Debug 모드 -> Loging
#define MEZZO_DEBUG

////////////////////////////////////////////////////
// url info.
#ifdef DEVEL_MODE
	#define	URL_SET_DEVTOKEN			@"https://social.paran.com/KTH/setDevToken.json"	// DeviceToken 전송

#else //!DEVEL_MODE

	#define	URL_SET_DEVTOKEN			@"https://dev.usay.net/KTH/setDevToken.json"

#endif //DEVEL_MODE

////////////////////////////////////////////////////
// notification key values
#define kNotiSetDevToken		@"setDevToken"
#define kNotiRequestHttp		@"requestHttp"

////////////////////////////////////////////////////
// server protocol(http body) key values
#define kSvrDevToken			@"devtoken"

////////////////////////////////////////////////////
// user default property key values
#define kDeviceToken			@"devicetoken"
#define kNickname				@"nickName"			// nickName은 NSUserDefaults에 저장.
#define kRevisionPoint			@"RevisionPoints"

////////////////////////////////////////////////////
// HTTP BODY TYPE
#define PARAM_SVCIDX			@"svcid"
#define PARAM_MTYPE				@"mType"
#define PARAM_SKEY				@"sessionKey"
#define PARAM_MSG				@"message"
#define PARAM_UUID				@"uuid"
#define PARAM_CERT				@"test"		         // inhouse 인증서 사용을 위해 추가. 

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

	#define DebugLog( s, ... ) NSLog( @"<%p %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )

#else // DEBUG_MODE

	#define DebugLog( s, ... ) 

#endif // DEBUG_MODE
