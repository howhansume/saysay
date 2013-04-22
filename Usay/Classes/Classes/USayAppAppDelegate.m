//
//  USayAppAppDelegate.m
//  USayApp
//
//  Created by Jong-Sung Park on 10. 5. 17..
//  Copyright inamass 2010. All rights reserved.
//

#import "USayAppAppDelegate.h"
#import "StartViewController.h"
#import "CertificationViewController.h"
#import "LoadingViewController.h"
#import	"UseGuideViewController.h"
#import "ProposeUserViewController.h"
#import "AsyncSocket.h"
#import "TransPacket.h"
#include"IPAddress.h"
#import "HttpAgent.h"
#import "JSON.h"
#import "USayHttpData.h"
#import "CellMsgListData.h"
#import "CellUserData.h"
#import "CellMsgData.h"
#import "tempMsgListData.h"
#import "UserInfo.h"
#import "RoomInfo.h"				// 대화방 리스트 관리				_TROOMINFO
#import "MessageInfo.h"				// 대화내용 관리					_TMESSAGEINFO
#import "MessageUserInfo.h"			// 대봐방에 있는 버디 리스트 관리		_TMESSAGEUSERINFO
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <netdb.h>
#import "Reachability.h"
#import "NSData-AES.h"
#import <unistd.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "RotatingTabBarController.h"
#import "MyDeviceClass.h"
#import "SignAgreeViewController.h"
#import "USayDefine.h"				// sochae 2010.09.09 - added
#import "NWAppUsageLogger.h"		// sochae 2010.09.17 - 통계 모듈
#import "SignAgreeViewController.h"

#ifndef NSEUCKREncoding
#define NSEUCKREncoding (-2147481280)
#endif

#define kAESKey		@"TopOfTheUC=>Usay" 
#define kAESIV		@"enjoy~U..say..yo"

#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]





@implementation USayAppAppDelegate

@synthesize window;
@synthesize rootController;
@synthesize authNaviController;
@synthesize loadViewController;
@synthesize startViewController;
@synthesize	useGuidController;
@synthesize isFirstUser;
@synthesize	httpAgentArray;
@synthesize msgListArray;
@synthesize msgArray;
@synthesize	proposeUserArray;
@synthesize database;
@synthesize myInfoDictionary;
@synthesize protocolUrlDictionary;
@synthesize tempMsgListDic;
@synthesize imStatusDictionary;
@synthesize connectionType;			// 0:disconnect 1:Wi-Fi 2:3G
@synthesize exceptionDisconnect;
@synthesize apnsNotiCount;
@synthesize reConnectCount;
@synthesize inEnterBackGround;		//4.0에서 홀드 되었다가 호출 되었는지 여부.
@synthesize isLoginfail;
@synthesize registSynctime;			// registOnMobile에서 받아온 lastsynctime
@synthesize isLogin;				// sochae 2010.09.30

#pragma mark -
#pragma mark Initialize
-(id)init {
	if(self = [super init]) {
		isConnected = NO;
		isFirstUser = NO;	// 프로그램 새로 설치후 진행?
		clientAsyncSocket = [[AsyncSocket alloc] initWithDelegate:self];
		myInfoDictionary = [[NSMutableDictionary alloc] init];
		if(myInfoDictionary) {
			[myInfoDictionary setObject:[self deviceIPAdress] forKey:@"inip"]; //디바이스 정보 입력
		}
		imStatusDictionary = nil;
		useGuidController = nil;
		connectionType = 0;
		exceptionDisconnect = NO;
		reConnectCount = 0;
		requestTimeOutTimer = nil;
		inEnterBackGround = NO;
		isLoginfail = NO;
		isLogin = NO;		// sochae 2010.09.30

		// sochae 2010.09.17 - 통계 관련
		[NWAppUsageLogger loggerWithUsageWebURL:@"http://mstatlog.paran.com/usagelog.html" andAppName:@"USayApp"];
		// ~sochae
	}
	
	return self;
}

#pragma mark -
#pragma mark APNS
// APNS 인증서 사용 시 Device Token 수신 CALLBACK
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
	DebugLog(@"===== didRegisterForRemoteNotificationsWithDeviceToken =====>");
	DebugLog(@"=====> Device Token : %@", deviceToken);

	NSString *strDeviceToken = [[deviceToken description] stringByTrimmingCharactersInSet:
					[NSCharacterSet characterSetWithCharactersInString:@"&lt;&gt;"]];
	strDeviceToken = [strDeviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];

	// <> 제거 후 64byte 로 만듬
	strDeviceToken = [[strDeviceToken substringFromIndex:1] substringToIndex:64];
//	DebugLog(@"=====> Device Token Trim : %@", strDeviceToken);

	// 아래와 둘 중 하나로만 관리되도록.. (차후 수정)
	[[self myInfoDictionary] setObject:strDeviceToken forKey:@"devicetoken"];

	// sochae 2010.09.29 - 로그인후에 서버로 전송하도록..
	//[[NSUserDefaults standardUserDefaults] setObject:dt forKey:@"devicetoken"];
	if ([JYUtil saveToUserDefaults:strDeviceToken forKey:kDeviceToken]) 
	{
		// Device Token 전송 - sochae 2010.09.29
		[self sendDeviceToken];
	} 
	else
	{
		DebugLog(@"=====> Device Token Save Failed. <=====");
	}
}

//APNS에 등록을 시도했으나 실패한 경우 호출되는 메서드
-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
	DebugLog(@"[APNS] didFailToRegisterForRemoteNotificationsWithError ERROR : %@",error);
}

//애플리케이션이 실행중일때 알림이 오면 호출되는 메서드.
-(void)application: (UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	//	NSDictionary *apns = [userInfo valueForKey:@"aps"];
	//	for (NSString *key in apns) {
	//		NSLog(@"Key: %@, Value: %@", key, [apns valueForKey:key]);
	//	}
	//	int nCount = 0;
	//	
	//	for (id key in userInfo) {
	//		NSLog(@"key: %@, value: %@", key, [userInfo objectForKey:key]);
	//		nCount++;
	//	}
	//
	//	// 기존 BadgeNumber과 신규로 들어온 BadgeNumber 값을 더해서 표시 처리
	//	application.applicationIconBadgeNumber = nCount;
	
	DebugLog(@"[APNS] didReceiveRemoteNotification CALLED. =====");

	// mezzo 10.09.15 APNS 노티를 받고 재접속 시도 
	NSString *failCode = [userInfo objectForKey:@"fail"];
	
	if ( [failCode isEqualToString:@"NOTI_CHAT_ENTER"] || [failCode isEqualToString:@"NOTI_CHAT_EXIT"]
		|| [failCode isEqualToString:@"NOTI_CHAT_RECORD"] ) {
		// Socket 연결 진행
		if (exceptionDisconnect && !isConnected) {
			NSString *improxyAddr = [myInfoDictionary objectForKey:@"proxyhost"];
			NSString *improxyPort = [myInfoDictionary objectForKey:@"proxyport"];
			if (improxyAddr && [improxyAddr length] > 0 && improxyPort && [improxyPort length] > 0) {
				//			NSLog(@"Reachable WiFi ipod 재접속 시작");
				if([self connect:improxyAddr PORT:[improxyPort intValue]]) {
					
					
					NSArray *roomInfoArray = [RoomInfo findWithSql:@"select * from _TRoomInfo"];
					if ([roomInfoArray count] > 0) {
						NSArray *lastUpdateTimeArray = [RoomInfo findWithSqlWithParameters:@"select * from _TRoomInfo order by LASTUPDATETIME desc limit 1", nil];
						if (lastUpdateTimeArray && [lastUpdateTimeArray count] == 1) {
							for (RoomInfo *roomdata in lastUpdateTimeArray) {
								NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
								//				assert(bodyObject != nil);
								[bodyObject setObject:[self getSvcIdx] forKey:@"svcidx"];
								NSNumber *lastUpdateTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastUpdateTime"];
								if (lastUpdateTime) {
									[bodyObject setObject:[NSString stringWithFormat:@"%llu",[lastUpdateTime longLongValue]] forKey:@"lastSessionUpdateTime"];
								} else {
									// skip
								}
								// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
								USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"retrieveSystemMessage" andWithDictionary:bodyObject timeout:10] autorelease];
								//				assert(data != nil);
								[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
							}
						}
					}
					
					
					// success!
				} else {
					// TODO: 예외처리 필요 (세션연결 실패)
					if([self connect:improxyAddr PORT:[improxyPort intValue]]) {
					} else {
						// TODO: 예외처리 필요 (세션연결 실패)
						if([self connect:improxyAddr PORT:[improxyPort intValue]]) {
						} else {	
						}
					}
				}
			} else {
				
				
				//시스템 연결메세지
				
				
				
				
				
				// skip
			}
		} else {
			// skip
			//소켓이 비정상이라서 다시 한번 읽어드려서 요청한다.
			//20101002
			
			NSArray *roomInfoArray = [RoomInfo findWithSql:@"select * from _TRoomInfo"];
			if ([roomInfoArray count] > 0) {
				NSArray *lastUpdateTimeArray = [RoomInfo findWithSqlWithParameters:@"select * from _TRoomInfo order by LASTUPDATETIME desc limit 1", nil];
				if (lastUpdateTimeArray && [lastUpdateTimeArray count] == 1) {
					for (RoomInfo *roomdata in lastUpdateTimeArray) {
						NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
						//				assert(bodyObject != nil);
						[bodyObject setObject:[self getSvcIdx] forKey:@"svcidx"];
						NSNumber *lastUpdateTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastUpdateTime"];
						if (lastUpdateTime) {
							[bodyObject setObject:[NSString stringWithFormat:@"%llu",[lastUpdateTime longLongValue]] forKey:@"lastSessionUpdateTime"];
						} else {
							// skip
						}
						// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
						USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"retrieveSystemMessage" andWithDictionary:bodyObject timeout:10] autorelease];
						//				assert(data != nil);
						[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
					}
				}
			}
			
			NSLog(@"===> didReceiveRemoteNotification : socket은 비정상이지만 연결 되어 있는 상태!");
		}		
	}
}

// sochae 2010.09.29
// Device Token을 서버로 전송하는 함수
- (void) sendDeviceToken
{
	if( self.isLogin == YES )
	{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respSetDevToken:) 
													 name:kNotiSetDevToken object:nil];
		
		NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:
									[JYUtil loadFromUserDefaults:kDeviceToken], kSvrDevToken, nil];

		USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:kNotiSetDevToken 
													  andWithDictionary:bodyObject timeout:10]autorelease];

		[[NSNotificationCenter defaultCenter] postNotificationName:kNotiRequestHttp object:data];
//		DebugLog(@"<========== request send DeviceToken ==========");
	}
}

- (void) respSetDevToken:(NSNotification *)notification
{
	DebugLog(@"========== respSetDevToken notify ==========>");

	[[NSNotificationCenter defaultCenter] removeObserver:self name:kNotiSetDevToken object:nil];	// sochae 2010.09.29

	USayHttpData *data = (USayHttpData*)[notification object];
	if( data != nil )
	{
		NSString *resultData = data.responseData;
		DebugLog(@"=====> noti response data : %@", resultData);

		// 1. Create BSJSON parser.
		SBJSON *jsonParser = [[SBJSON alloc] init];

		// 2. Get the result dictionary from the response string.
		NSDictionary *dic = (NSDictionary*)[jsonParser objectWithString:resultData error:NULL];
		[jsonParser release];

		// 3. Show response
		NSString *rtcode = [dic objectForKey:@"rtcode"];
		DebugLog(@"=====> noti return code : %@", rtcode);

		if ([rtcode isEqualToString:@"0"])
		{
			// success
			NSString *rtType = [dic objectForKey:@"rttype"];
			if ([rtType isEqualToString:@"map"]) {
			} else {
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0051)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
				[alertView show];
				[alertView release];
			}
		}
		else
		{
			// fail
			NSString *string = [NSString stringWithFormat:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-%@)", rtcode];
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:string delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
			[alertView show];
			[alertView release];
		}
	}
	else
	{
		// Device Token 전송 실패 한 경우
		DebugLog(@"=====> noti DeviceToken Failed."); 
	}
}
// ~sochae

#pragma mark -
#pragma mark UIApplicationDelegate
//백그라운드시 실행되는 메서드
- (void)applicationDidEnterBackground:(UIApplication *)application
{
	DebugLog(@"[Suspand] applicationDidEnterBackground CALLED. =====");
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	//	NSLog(@"applicationDidEnterBackground start");
	inEnterBackGround = YES;
	//서버와 커넥팅 종료
	if (clientAsyncSocket) {
		//		NSLog(@"applicationDidEnterBackground 1");
		if([clientAsyncSocket isConnected]) {
			//			NSLog(@"applicationDidEnterBackground 2 접속 종료");
			DebugLog(@"[SOCKET] disconnect!!!");
			[clientAsyncSocket disconnect];
			isConnected = NO;
			//			NSLog(@"applicationDidEnterBackground 3");
		}
	}
	
	exceptionDisconnect = YES;
	
	//백그라운드 직전에 서버에 데이터 올리는듯??	
	if (httpAgentArray && [httpAgentArray count] > 0) {
		//		NSLog(@"applicationDidEnterBackground 4");
		for (HttpAgent *httpAgent in httpAgentArray) {
			if ([httpAgent isRequest]) {
				if (httpAgent.delegateParameter.requestApi && [httpAgent.delegateParameter.requestApi length] > 0) {
					if ([httpAgent.delegateParameter.requestApi isEqualToString:@"albumUpload"] ||
						[httpAgent.delegateParameter.requestApi isEqualToString:@"albumUploadComplete"]) {
						if (httpAgent.delegateParameter.requestSubApi && [httpAgent.delegateParameter.requestSubApi length] > 0) {
							if ([httpAgent.delegateParameter.requestSubApi isEqualToString:@"insertProfilePhoto"]) {
								[[NSNotificationCenter defaultCenter] postNotificationName:@"completeProfilePhoto" object:nil];
								[httpAgent cancelRequest];
								[httpAgentArray removeObject:httpAgent];
							} else if ([httpAgent.delegateParameter.requestSubApi isEqualToString:@"updateProfilePhoto"]) {
								[[NSNotificationCenter defaultCenter] postNotificationName:@"completeProfilePhoto" object:nil];
								[httpAgent cancelRequest];
								[httpAgentArray removeObject:httpAgent];
							} else if ([httpAgent.delegateParameter.requestSubApi isEqualToString:@"insertContactPhoto"]) {
								[httpAgent cancelRequest];
								[httpAgentArray removeObject:httpAgent];
							} else if ([httpAgent.delegateParameter.requestSubApi isEqualToString:@"updateContactPhoto"]) {
								[httpAgent cancelRequest];
								[httpAgentArray removeObject:httpAgent];
							} else if ([httpAgent.delegateParameter.requestSubApi isEqualToString:@"insertMsgMediaPhoto"]) {
								//								NSLog(@"applicationDidEnterBackground insertMsgMediaPhoto 1");
								// DB, 메모리 변경
								@synchronized(msgArray) {
									if (msgArray && [msgArray count] > 0) {
										//										NSLog(@"applicationDidEnterBackground insertMsgMediaPhoto 2");
										for (CellMsgData *msgData in msgArray) {
											//											NSLog(@"applicationDidEnterBackground insertMsgMediaPhoto 3");
											if ([msgData.messagekey isEqualToString:httpAgent.delegateParameter.messageKey]) {
												//												NSLog(@"applicationDidEnterBackground insertMsgMediaPhoto 4");
												msgData.sendMsgSuccess = @"-1";
												break;
											}
										}
									}
								}
								//								NSLog(@"applicationDidEnterBackground insertMsgMediaPhoto 5");
								NSArray *checkDBArray = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where MESSAGEKEY=?", httpAgent.delegateParameter.messageKey, nil];
								if (checkDBArray && [checkDBArray count] > 0) {
									//									NSLog(@"applicationDidEnterBackground insertMsgMediaPhoto 6");
									[MessageInfo findWithSqlWithParameters:@"update _TMessageInfo set ISSUCCESS=? where MESSAGEKEY=?", @"-1", httpAgent.delegateParameter.messageKey, nil];
								}
								//								NSLog(@"applicationDidEnterBackground insertMsgMediaPhoto 7");
								NSString *openChatSession = [self.myInfoDictionary objectForKey:@"openChatSession"];
								if (openChatSession && [openChatSession length] > 0) {
									//									NSLog(@"applicationDidEnterBackground insertMsgMediaPhoto 8");
									[[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadMessage" object:openChatSession];
								}
								//								NSLog(@"applicationDidEnterBackground insertMsgMediaPhoto 9");
								[httpAgent cancelRequest];
								[httpAgentArray removeObject:httpAgent];
							} else {
								// skip
							}
						}
					} else if ([httpAgent.delegateParameter.requestApi isEqualToString:@"loadProfile"]) {
						[[NSNotificationCenter defaultCenter] postNotificationName:@"loadProfile" object:nil];
						[httpAgent cancelRequest];
						[httpAgentArray removeObject:httpAgent];
					} else if ([httpAgent.delegateParameter.requestApi isEqualToString:@"updateNickName"]) {
						[[NSNotificationCenter defaultCenter] postNotificationName:@"completeNickName" object:nil];
						[httpAgent cancelRequest];
						[httpAgentArray removeObject:httpAgent];
					} else if ([httpAgent.delegateParameter.requestApi isEqualToString:@"updateStatus"]) {
						[[NSNotificationCenter defaultCenter] postNotificationName:@"completeStatus" object:nil];
						[httpAgent cancelRequest];
						[httpAgentArray removeObject:httpAgent];
					} else if ([httpAgent.delegateParameter.requestApi isEqualToString:@"updateMyInfo"]) {
						[[NSNotificationCenter defaultCenter] postNotificationName:@"updateMyInfo" object:nil];
						[httpAgent cancelRequest];
						[httpAgentArray removeObject:httpAgent];
					} else if ([httpAgent.delegateParameter.requestApi isEqualToString:@"setMessagePreviewOnMobile"]) {
					} else if ([httpAgent.delegateParameter.requestApi isEqualToString:@"getBlockedFriendsList"]) {
					} else if ([httpAgent.delegateParameter.requestApi isEqualToString:@"toggleCommStatus"]) {
						if (httpAgent.delegateParameter.requestSubApi && [httpAgent.delegateParameter.requestSubApi length] > 0) {
							if ([httpAgent.delegateParameter.requestSubApi isEqualToString:@"BlockUserCancel"]) {
							}
						}
					} else {
						
					}
				}
			}
		}
	}
	//	NSLog(@"applicationDidEnterBackground 5");
}

// App 재활성 되는 시점에 호출 (+ 화면잠금 해제시)
-(void)applicationDidBecomeActive:(UIApplication *)application
{
	DebugLog(@"[Resume] applicationDidBecomeActive CALLED.");
	DebugLog(@"Backgrond ==> Foreground전환 !!!!");

	// sochae 2010.09.17 - 시작 정보 통계 처리	
	DebugLog(@"main = %d", rootController.selectedIndex);
	NWAppUsageLogger *logger = [NWAppUsageLogger logger];
	[logger fireUsageLog:@"APP_START" andEventDesc:nil andCategoryId:nil];
	// ~sochae

	if (exceptionDisconnect && !isConnected)
	{
		// sochae 2010.09.28 - 활성화 되는 시점에 network check
		if (![Reachability isInternetReachable])
		{
			[JYUtil alertWithType:ALERT_NET_OFFLINE delegate:nil];
		}
		// ~sochae
		
		NSString *improxyAddr = [myInfoDictionary objectForKey:@"proxyhost"];
		NSString *improxyPort = [myInfoDictionary objectForKey:@"proxyport"];
		if (improxyAddr && [improxyAddr length] > 0 && improxyPort && [improxyPort length] > 0) {
			//			NSLog(@"Reachable WiFi ipod 재접속 시작");
			if([self connect:improxyAddr PORT:[improxyPort intValue]]) {
				// success!
			} else {
				// TODO: 예외처리 필요 (세션연결 실패)
				if([self connect:improxyAddr PORT:[improxyPort intValue]]) {
				} else {
					// TODO: 예외처리 필요 (세션연결 실패)
					if([self connect:improxyAddr PORT:[improxyPort intValue]]) {
					} else {	
					}
				}
			}
		} else {
			// skip
		}
	} else {
		// skip
	}
	
}

// sochae 2010.09.17 - 전화가 왔을 때 통화/거부 메시지창 이전에 호출 (+ 화면잠금 시)
- (void) applicationWillResignActive:(UIApplication *)application
{
	
	NSLog(@"afdsafd %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"CertificationStatus"]);
	
		
	
	
	
	NSString *tmp = [[NSUserDefaults standardUserDefaults] objectForKey:@"CertificationStatus"];
	
	NSLog(@"tmp %@", tmp);
	NSLog(@"last = %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"lastSyncDate"]);
	
	
	/*
	 
	 if(![[NSUserDefaults standardUserDefaults] objectForKey:@"lastSyncDate"] && [tmp intValue] != -1 )
	 {
		 NSArray *tmpArray = [UserInfo findWithSql:@"select * from _TUserInfo"];
		 
		 
		 if([tmp intValue] == 4)
		 {
			 NSLog(@"fdsafdafdasfsdaf");
			 //동기화 전에 백그라운드는 인정안함..
			// sleep(2);
			 exit(1);
			 
		 }
		 else {
		
			 
			 
		 }

		 
		 
	}
	 
	*/
	
	
	if([tmp intValue]== 9 || [tmp intValue] == 4)
	{
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"lastSyncDate"];
		if([[NSUserDefaults standardUserDefaults] objectForKey:@"lastSyncDate"])
		{
			DebugLog(@"왜 라스트 싱크가 존재하냐..??");
		}
	//	sleep(1);
		exit(0);
	}
	
	NSString *guide = [[NSUserDefaults standardUserDefaults] objectForKey:@"userguide"];
	
	if([guide isEqualToString:@"1"])
	{
		DebugLog(@"유저 가이드 화면이면 강종이다.");
		exit(0);
	}
	
	
	
	DebugLog(@"Foreground --> Background !!!");	
	// 종료 정보 통계 처리
	NWAppUsageLogger *logger = [NWAppUsageLogger logger];
	[logger fireUsageLog:@"APP_FINISH" andEventDesc:nil andCategoryId:nil];
}
// ~sochae

// remote notification에 의해 App이 실행되는 경우
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	
    // Override point for customization after application launch
	//	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
	DebugLog(@"didFinishLaunchingWithOptions CALLED. =====");	
	apnsNotiCount = 0;
	
	[self Initialize];	// 초기화
	[MyDeviceClass initialize];

	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];//상태바 색상 변경
	//	[[UIApplication sharedApplication] setStatusBarHidden:NO];
	[window addSubview:startViewController.view];
    [window makeKeyAndVisible];
	
	NSDictionary* userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
	if(userInfo != nil) {
		[self application:application didReceiveRemoteNotification:userInfo];
	}
	
	
	apnsNotiCount = [userInfo count];
	
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
	 UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
	
	//	NSInteger nCount = [application applicationIconBadgeNumber];
	//	[UIApplication sharedApplication].applicationIconBadgeNumber = 2;
	
	return YES;
}

#pragma mark -
#pragma mark View Change
-(void)goLoading{
	[[NSUserDefaults standardUserDefaults] setInteger:4 forKey:@"CertificationStatus"];
	[window insertSubview:loadViewController.view atIndex:0];
	
#ifdef MEZZO_DEBUG
	NSLog(@"==============GO LOADING======================");
#endif
	if(SignNaviController.view.superview != nil)
	{
		[SignAgreeView release];
		[SignNaviController.view removeFromSuperview];
	//	[SignNaviController release];
	//	SignNaviController = nil;
	}
	if(authNaviController.view.superview != nil ) {
		[authNaviController.view removeFromSuperview];
		[authNaviController release];
		authNaviController = nil;
	} else if(startViewController.view.superview != nil) {
		//		[startViewController releaseLoadImageView];
		[startViewController.view removeFromSuperview];
	}
#ifdef MEZZO_DEBUG
	NSLog(@"==============GO LOADING END======================");
#endif
	
	//20101002 
	[self setIsFirstUser:NO];
	
}


-(void)goRegistration {	// 가입처리

	DebugLog(@"========== (가입처리) goRegistration (RP : %@) ==========>", [JYUtil loadFromUserDefaults:kRevisionPoint]);
//	NSLog(@"rprprprp = %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"RevisionPoints"]);
	
	NSString *sql = @"select * from _TUserInfo order by RPCREATED+0 desc";
	NSArray *tmpArray = [UserInfo findWithSql:sql];
	
	DebugLog(@"=====> (사용자 정보 RP 정렬) tmpArray = %@", tmpArray);
	
	if(tmpArray != nil && [tmpArray count] >0 && tmpArray != NULL)
	{
	//	NSLog(@"tmpARR = %@", [[tmpArray objectAtIndex:0] objectForKey:@"aa"]);
		//mezzo go main으로 가야하나?
		DebugLog(@"라스트 데이터가 있다.");
	//	[self goLoading];
		//[self goLoading:self];	
	}
	else
	{
		DebugLog(@"왜 없냐...");
		[[UIApplication sharedApplication] setStatusBarHidden:NO];

		SignAgreeView = [[SignAgreeViewController alloc] init];
		SignNaviController = [[UINavigationController alloc] initWithRootViewController:SignAgreeView];
		[window insertSubview:SignNaviController.view atIndex:0];
		//[window insertSubview:authNaviController.view atIndex:0];
		
		//	[startViewController releaseLoadImageView];
		[startViewController.view removeFromSuperview];
	}
}

-(void)goMain:(id)controller
{
	DebugLog(@"========== goMain ==========>");
	[[UIApplication sharedApplication] setStatusBarHidden:NO];

	UIViewController *rmController = (UIViewController *)controller;
	[window insertSubview:rootController.view atIndex:0];
	[rmController.view removeFromSuperview];

	if (useGuidController != nil)
	{
		[useGuidController release];
		useGuidController = nil;
	}

	NSArray *roomInfoArray = [RoomInfo findWithSql:@"select * from _TRoomInfo"];
	if ([roomInfoArray count] > 0)
	{
		NSArray *lastUpdateTimeArray = [RoomInfo findWithSqlWithParameters:@"select * from _TRoomInfo order by LASTUPDATETIME desc limit 1", nil];
		if (lastUpdateTimeArray && [lastUpdateTimeArray count] == 1)	// 추가된 항목이 있는 경우
		{
			for (RoomInfo *roomdata in lastUpdateTimeArray) {
				NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
				//				assert(bodyObject != nil);
				[bodyObject setObject:[self getSvcIdx] forKey:@"svcidx"];

				NSNumber *lastUpdateTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastUpdateTime"];
				if (lastUpdateTime) {
					[bodyObject setObject:[NSString stringWithFormat:@"%llu",[lastUpdateTime longLongValue]] forKey:@"lastSessionUpdateTime"];
				} else {
					// skip
				}
				// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
				USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"retrieveSystemMessage" 
															  andWithDictionary:bodyObject timeout:10] autorelease];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
			}
		}
	} else {
		NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
		//		assert(bodyObject != nil);
		[bodyObject setObject:[self getSvcIdx] forKey:@"svcidx"];

		NSNumber *lastUpdateTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastUpdateTime"];
		if (lastUpdateTime) {
			[bodyObject setObject:[NSString stringWithFormat:@"%llu",[lastUpdateTime longLongValue]] forKey:@"lastSessionUpdateTime"];
		} else {
			// skip
		}		
		
		// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
		USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"retrieveSystemMessage" 
													  andWithDictionary:bodyObject timeout:10] autorelease];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
	}
	
	// 추천친구 리스트 요청
#ifdef MEZZO_DEBUG
	DebugLog(@"추천친구 리스트 요청");
#endif
	[self requestProposeUserList];
}



//가이드 화면
-(void) goUseGuide
{
	useGuidController = [[UseGuideViewController alloc] init];
	[window insertSubview:useGuidController.view atIndex:0];
	[loadViewController.view removeFromSuperview];
	[loadViewController release];
	loadViewController = nil;
	
}

-(NSString*)getSvcIdx
{
	return @"ucmbip";		// 테스트 서버 : usay_mobile_iphone  실서버 : ucmbip
}

#pragma mark -
#pragma mark Property 
-(void) Initialize
{
	// 서버로 전송할 노티피케이션처리관련 등록..
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestHttp:) name:@"requestHttp" object:nil];
	// 
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestUploadUrlMultipartForm:) name:@"requestUploadUrlMultipartForm" object:nil];
	// 
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(retrieveSystemMessage:) name:@"retrieveSystemMessage" object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getChatParticipants:) name:@"getChatParticipants" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getChatParticipantsNotiChatEnter:) name:@"getChatParticipantsNotiChatEnter" object:nil];
	// 
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(retrieveSessionMessage:) name:@"retrieveSessionMessage" object:nil];
	// 메시지의 읽은 카운트수 가져오기
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getReadMark:) name:@"getReadMark" object:nil];
	// 새로운 메시지 생성 (사진/동영상 업로드)	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumUploadComplete:) name:@"albumUploadComplete" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createNewMessage:) name:@"createNewMessage" object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getRecommendFriendsList:) name:@"getRecommendFriendsList" object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStatus:) name:@"updateStatus" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNickName:) name:@"updateNickName" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setMessagePreviewOnMobile:) name:@"setMessagePreviewOnMobile" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteMyMessage:) name:@"deleteMyMessage" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setFriendFromRecommand:) name:@"setFriendFromRecommand" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(BlockUserCancel:) name:@"BlockUserCancel" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(joinToChatSession:) name:@"joinToChatSession" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(insertProfilePhoto:) name:@"insertProfilePhoto" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(insertContactPhoto:) name:@"insertContactPhoto" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object: nil];

	// mezzo
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(withdrawal:) name:@"withdrawal" object:nil];

	
	
	httpAgentArray = [[NSMutableArray alloc]init];			// http request 관리
	//	assert(httpAgentArray != nil);
	
	msgListArray = [[NSMutableArray alloc]init];			// 메시지창 관리
	//	assert(msgListArray != nil);
	
	msgArray = [[NSMutableArray alloc]init];				// 메시지 관리
	//	assert(msgArray != nil);
	
	proposeUserArray = [[NSMutableArray alloc]init];		// 추천친구 리스트
	//	assert(proposeUserArray != nil);
	
	tempMsgListDic = [[NSMutableDictionary alloc] init];
	//	assert(tempMsgListDic != nil);
	
	imStatusDictionary = [[NSMutableDictionary alloc] init];
	
	// 개발 서버
#ifdef DEVEL_MODE	// sochae 2010.09.09 - dev server
	DebugLog(@"=== KTH : social.paran.com START!!! ===");
	//*
	protocolUrlDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
							 @"https://social.paran.com/KTH/initOnMobile.json", @"initOnMobile",										// URL 요청
							 @"https://social.paran.com/KTH/mobilePhoneNumberAuthSending.json",@"mobilePhoneNumberAuthSending",			// sms 인증
							 @"https://social.paran.com/KTH/isMobilePhoneNumberAuth.json",@"isMobilePhoneNumberAuth",					// 인증번호 입력후 가입요청
							 @"https://social.paran.com/KTH/registOnMobile.json", @"registOnMobile",									// 가입
							 @"https://social.paran.com/KTH/loginOnMobile.json", @"loginOnMobile",										// 인증
							 @"https://social.paran.com/KTH/getContacts.json", @"getContacts",											// 주소록 얻어오기
							 @"https://social.paran.com/KTH/getGroups.json", @"getGroups",												// 그룹 정보 얻기.
							 @"https://social.paran.com/KTH/addContact.json", @"addContact",											// 주소 추가. 단건으로
							 @"https://social.paran.com/KTH/addGroup.json", @"addGroup",												// 그룹 추가. 단건으로
							 @"https://social.paran.com/KTH/updateGroup.json",@"updateGroup",											// 그룹 수정
							 @"https://social.paran.com/KTH/addListContact.json", @"addListContact",										// 주소 Bulk 올리기.
							 @"https://social.paran.com/KTH/addListContactIncludeGroup.json", @"addListContactIncludeGroup",				// 그룹이 포함된 주소 bulk 올리기.							 
							 @"https://social.paran.com/KTH/getLastAfterRP.json", @"getLastAfterRP",									// 특정 RP포인트 이후에 올리기
							 @"https://social.paran.com/KTH/getFriendsList.json", @"getFriendsList",									// 전체 친구 프로필 리스트 가져오기-주소록 목록		
							 @"https://social.paran.com/KTH/updateContact.json", @"updateContact",										// 주소 수정.
							 @"https://social.paran.com/KTH/updateListContact.json", @"updateListContact",								// 주소 멀티 그룹 이동.
							 @"https://social.paran.com/KTH/deleteContact.json", @"deleteContact",										// 주소 삭제.
							 @"https://social.paran.com/KTH/deleteListContact.json", @"deleteListContact",								// 주소 멀티 삭제.
							 @"https://social.paran.com/KTH/deleteGroup.json", @"deleteGroup",											// 주소록 - 그룹 삭제.
							 @"https://social.paran.com/KTH/toggleCommStatus.json", @"toggleCommStatus",								// 주소록 - 친구 차단 하기, 설정 - 차단 친구 목록 - 친구 차단 해제 하기
							 @"https://social.paran.com/KTH/retrieveSystemMessage.json", @"retrieveSystemMessage",						// 메시지 - 시스템 정보 메시지 가져오기
							 @"https://social.paran.com/KTH/getChatParticipants.json", @"getChatParticipants",							// 메시지 - 대화방 참여자 정보 가져오기
							 @"https://social.paran.com/KTH/quitFromChatSession.json", @"quitFromChatSession",							// 메시지 - 대봐방에서 나가기
							 @"https://social.paran.com/KTH/joinToChatSession.json", @"joinToChatSession",								// 대화 세션 참가
							 @"https://social.paran.com/KTH/retrieveSessionMessage.json", @"retrieveSessionMessage",					// 대화 - 대화 메시지 가져오기
							 @"https://social.paran.com/KTH/createNewMessage.json", @"createNewMessage",								// 대화 - 텍스트 메시지 보내기
							 @"https://social.paran.com/KTH/getReadMark.json", @"getReadMark",											// 대화 - 메시지의 읽은 카운트수 가져오기
							 @"https://social.paran.com/KTH/deleteMyMessage.json", @"deleteMyMessage",									// 대화 - 메시지 지우기
							 @"https://social.paran.com/KTH/getNewSessionMsgCount.json", @"getNewSessionMsgCount",						// 대화 - 세션별 카운트 얻기
							 @"https://social.paran.com/KTH/getRecommendFriendsList.json", @"getRecommendFriendsList",					// 추천 친구 - 추천 친구 목록
							 @"https://social.paran.com/KTH/setFriendFromRecommand.json", @"setFriendFromRecommand",					// 추천 친구 - 친구 수락
							 @"https://social.paran.com/KTH/deleteRecommendFriend.json", @"deleteRecommendFriend",						// 추천 친구 - 추천 친구 목록에서 삭제
							 @"https://social.paran.com/KTH/loadProfile.json", @"loadProfile",											// 설정 - 프로필 설정 - 전체 정보 가져오기
							 @"https://social.paran.com/KTH/loadSimpleProfile.json", @"loadSimpleProfile",								// 설정 - 프로필 설정 - simple 정보 가져오기
							 @"https://social.paran.com/KTH/getChangedProfileInfo.json", @"getChangedProfileInfo",						// 최초 받아오는 버디 변경 정보
							 @"http://mtool.usay.net/main/usay/albumUpload", @"albumUpload",											// 주소록, 대화, 프로필 설정 - 사진 추가 1단계
							 @"http://mtool.usay.net/main/usay/albumUploadComplete", @"albumUploadComplete",							// 주소록, 대화, 프로필 설정 - 사진 추가 2단계
							 @"https://social.paran.com/KTH/deleteProfilePhoto.json", @"deleteProfilePhoto",							// 설정 - 프로필 설정 - 사진 삭제
							 @"https://social.paran.com/KTH/serRepresentPhoto.json", @"serRepresentPhoto",								// 설정 - 프로필 설정 - 사진 대표사진 선택
							 @"https://social.paran.com/KTH/updatePresence.json", @"updatePresence",									// 설정 - 프로필 설정 - 상태 설정
							 @"https://social.paran.com/KTH/updateNickName.json", @"updateNickName",									// 설정 - 프로필 설정 - 별명 설정
							 @"https://social.paran.com/KTH/updateStatus.json", @"updateStatus",										// 설정 - 프로필 설정 - 오늘의 한마디 설정
							 @"https://social.paran.com/KTH/updateMyInfo.json", @"updateMyInfo",										// 설정 - 프로필 설정 - 내 정보 설정
							 @"https://social.paran.com/KTH/withdrawal.json", @"withdrawal",											// 설정 - 회원 탈퇴
							 @"https://social.paran.com/KTH/setMessagePreviewOnMobile.json", @"setMessagePreviewOnMobile",				// 설정 - 알림설정 - 내용 미리보기 설정
							 @"https://social.paran.com/KTH/getBlockedFriendsList.json", @"getBlockedFriendsList",						// 설정 - 차단 친구 목록 - 차단된 친구 목록
							 @"http://social.paran.com/mobile/01.html", @"linkIdUrl",
							 @"http://m.paran.com/mini/apps/appsList.jsp", @"otherKTHAppUrl",
							 URL_SET_DEVTOKEN, kNotiSetDevToken,	                                // DeviceToken 전송 - sochae 2010.09.29
							 nil];
	//*/
#else	// sochae 2010.09.09 - #ifdef DEVEL_MODE
	DebugLog(@"=== KTH : dev.usay.net START!!! ===");
	// 실서버
	//*
	protocolUrlDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
							 @"https://dev.usay.net/KTH/initOnMobile.json", @"initOnMobile",										// URL 요청
							 @"https://dev.usay.net/KTH/mobilePhoneNumberAuthSending.json",@"mobilePhoneNumberAuthSending",			// sms 인증
							 @"https://dev.usay.net/KTH/isMobilePhoneNumberAuth.json",@"isMobilePhoneNumberAuth",					// 인증번호 입력후 가입요청
							 @"https://dev.usay.net/KTH/registOnMobile.json", @"registOnMobile",									// 가입
							 @"https://dev.usay.net/KTH/loginOnMobile.json", @"loginOnMobile",										// 인증
							 @"https://dev.usay.net/KTH/getGroups.json", @"getGroups",												// 그룹 정보 얻기.
							 @"https://dev.usay.net/KTH/getContacts.json", @"getContacts",											// 주소록 얻어오기
							 @"https://dev.usay.net/KTH/addContact.json", @"addContact",											// 주소 추가. 단건으로
							 @"https://dev.usay.net/KTH/addGroup.json", @"addGroup",												// 그룹 추가. 단건으로
							 @"https://dev.usay.net/KTH/updateGroup.json",@"updateGroup",											// 그룹 수정
							 @"https://dev.usay.net/KTH/addListContact.json", @"addListContact",										// 주소 Bulk 올리기.
							 @"https://dev.usay.net/KTH/addListContactIncludeGroup.json", @"addListContactIncludeGroup",				// 그룹이 포함된 주소 bulk 올리기.							 
							 @"https://dev.usay.net/KTH/getLastAfterRP.json", @"getLastAfterRP",									// 특정 RP포인트 이후에 올리기
							 @"https://dev.usay.net/KTH/getFriendsList.json", @"getFriendsList",									// 전체 친구 프로필 리스트 가져오기-주소록 목록		
							 @"https://dev.usay.net/KTH/updateContact.json", @"updateContact",										// 주소 수정.
							 @"https://dev.usay.net/KTH/updateListContact.json", @"updateListContact",								// 주소 멀티 그룹 이동.
							 @"https://dev.usay.net/KTH/deleteContact.json", @"deleteContact",										// 주소 삭제.
							 @"https://dev.usay.net/KTH/deleteListContact.json", @"deleteListContact",								// 주소 멀티 삭제.
							 @"https://dev.usay.net/KTH/deleteGroup.json", @"deleteGroup",											// 주소록 - 그룹 삭제.
							 @"https://dev.usay.net/KTH/toggleCommStatus.json", @"toggleCommStatus",								// 주소록 - 친구 차단 하기, 설정 - 차단 친구 목록 - 친구 차단 해제 하기
							 @"https://dev.usay.net/KTH/retrieveSystemMessage.json", @"retrieveSystemMessage",						// 메시지 - 시스템 정보 메시지 가져오기
							 @"https://dev.usay.net/KTH/getChatParticipants.json", @"getChatParticipants",							// 메시지 - 대화방 참여자 정보 가져오기
							 @"https://dev.usay.net/KTH/quitFromChatSession.json", @"quitFromChatSession",							// 메시지 - 대봐방에서 나가기
							 @"https://dev.usay.net/KTH/joinToChatSession.json", @"joinToChatSession",								// 대화 세션 참가
							 @"https://dev.usay.net/KTH/retrieveSessionMessage.json", @"retrieveSessionMessage",					// 대화 - 대화 메시지 가져오기
							 @"https://dev.usay.net/KTH/createNewMessage.json", @"createNewMessage",								// 대화 - 텍스트 메시지 보내기
							 @"https://dev.usay.net/KTH/getReadMark.json", @"getReadMark",											// 대화 - 메시지의 읽은 카운트수 가져오기
							 @"https://dev.usay.net/KTH/deleteMyMessage.json", @"deleteMyMessage",									// 대화 - 메시지 지우기
							 @"https://dev.usay.net/KTH/getNewSessionMsgCount.json", @"getNewSessionMsgCount",						// 대화 - 세션별 카운트 얻기
							 
							 @"https://dev.usay.net/KTH/getRecommendFriendsList.json", @"getRecommendFriendsList",					// 추천 친구 - 추천 친구 목록
							 @"https://dev.usay.net/KTH/setFriendFromRecommand.json", @"setFriendFromRecommand",					// 추천 친구 - 친구 수락
							 @"https://dev.usay.net/KTH/deleteRecommendFriend.json", @"deleteRecommendFriend",						// 추천 친구 - 추천 친구 목록에서 삭제
							 @"https://dev.usay.net/KTH/loadProfile.json", @"loadProfile",											// 설정 - 프로필 설정 - 전체 정보 가져오기
							 @"https://dev.usay.net/KTH/loadSimpleProfile.json", @"loadSimpleProfile",								// 설정 - 프로필 설정 - simple 정보 가져오기
							 @"https://dev.usay.net/KTH/getChangedProfileInfo.json", @"getChangedProfileInfo",					// 최초 받아오는 버디 변경 정보
							 @"http://mtool.usay.net/main/usay/albumUpload", @"albumUpload",											// 주소록, 대화, 프로필 설정 - 사진 추가 1단계
							 @"http://mtool.usay.net/main/usay/albumUploadComplete", @"albumUploadComplete",							// 주소록, 대화, 프로필 설정 - 사진 추가 2단계
							 @"https://dev.usay.net/KTH/deleteProfilePhoto.json", @"deleteProfilePhoto",							// 설정 - 프로필 설정 - 사진 삭제
							 @"https://dev.usay.net/KTH/serRepresentPhoto.json", @"serRepresentPhoto",								// 설정 - 프로필 설정 - 사진 대표사진 선택
							 @"https://dev.usay.net/KTH/updatePresence.json", @"updatePresence",									// 설정 - 프로필 설정 - 상태 설정
							 @"https://dev.usay.net/KTH/updateNickName.json", @"updateNickName",									// 설정 - 프로필 설정 - 별명 설정
							 @"https://dev.usay.net/KTH/updateStatus.json", @"updateStatus",										// 설정 - 프로필 설정 - 오늘의 한마디 설정
							 @"https://dev.usay.net/KTH/updateMyInfo.json", @"updateMyInfo",										// 설정 - 프로필 설정 - 내 정보 설정
							 @"https://dev.usay.net/KTH/withdrawal.json", @"withdrawal",											// 설정 - 회원 탈퇴
							 @"https://dev.usay.net/KTH/setMessagePreviewOnMobile.json", @"setMessagePreviewOnMobile",				// 설정 - 알림설정 - 내용 미리보기 설정
							 @"https://dev.usay.net/KTH/getBlockedFriendsList.json", @"getBlockedFriendsList",						// 설정 - 차단 친구 목록 - 차단된 친구 목록
							 @"http://dev.usay.net/mobile/01.html", @"linkIdUrl",
							 @"http://m.paran.com/mini/apps/appsList.jsp", @"otherKTHAppUrl",
							 URL_SET_DEVTOKEN, kNotiSetDevToken,	                               // DeviceToken 전송 - sochae 2010.09.29
							 nil];
	 //*/
#endif	// sochae 2010.09.09 - #ifdef DEVEL_MODE
	//	assert(protocolUrlDictionary != nil);
	
	systemSoundID = 0;
	[[NSUserDefaults standardUserDefaults] setInteger:1	forKey:@"stateValue"];
	[self createSystemSoundID];
	
	//	internetReach = [[Reachability reachabilityForInternetConnection] retain];
	//	[internetReach startNotifier];
	
	//	wifiReach = [[Reachability reachabilityForLocalWiFi] retain];
	//	[wifiReach startNotifier];
}

// db 초기화	(db에서 메시지 리스트 load, 기타)
-(void) dbInitialize	
{
	NSArray *roomInfoArray = [RoomInfo findAll];
	if (roomInfoArray && [roomInfoArray count] > 0) {
		NSInteger totalNewCount = 0;
		//		long long testDate = 1000000000;
		for(RoomInfo *roomInfo in roomInfoArray){
			// msgListArray 추가
			CellMsgListData *msgListData = [[[CellMsgListData alloc] init] autorelease];
			//			assert(msgListData != nil);
			msgListData.chatsession = roomInfo.CHATSESSION;
			msgListData.lastMsg = roomInfo.LASTMSG;
			msgListData.lastMsgDate = [NSString stringWithFormat:@"%llu", [roomInfo.LASTMSGDATE longLongValue]];			// timestamp 13자리
			//			msgListData.lastMsgDate = [NSNumber numberWithLongLong:testDate++];
			msgListData.lastMsgType = roomInfo.LASTMSGTYPE;
			msgListData.lastmessagekey = roomInfo.LASTMESSAGEKEY;
			msgListData.lastUpdateTime = roomInfo.LASTUPDATETIME;	// timestamp 13자리
			msgListData.cType = roomInfo.CTYPE;
			NSInteger newMsgCount = [roomInfo.NEWMSGCOUNT intValue];
			if (newMsgCount > 0) {
				msgListData.newMsgCount = newMsgCount;
				totalNewCount += newMsgCount;
			} else {
				msgListData.newMsgCount = 0;
			}
			//			NSLog(@"dbInitialize chatsession=%@  lastMsgDate=%@", msgListData.chatsession, msgListData.lastMsgDate);
			
			if (msgListData.chatsession && [msgListData.chatsession length] > 0) {
				NSArray *messageUserInfoArray = [MessageUserInfo findWithSqlWithParameters:@"select * from _TMessageUserInfo where CHATSESSION=?", roomInfo.CHATSESSION, nil];
				if (messageUserInfoArray) {
					if (msgListData.userDataDic) {
						// skip
					} else {
						msgListData.userDataDic = [NSMutableDictionary dictionaryWithCapacity:10];
					}
					
					for(MessageUserInfo *messageUserInfo in messageUserInfoArray) {
						MsgUserData *userData = [[[MsgUserData alloc] init] autorelease];
						userData.nickName = messageUserInfo.NICKNAME;
						//						NSLog(@"dbInitialize chatsession = %@  PKEY = %@  nickName = %@", msgListData.chatsession, messageUserInfo.PKEY ,userData.nickName);
						userData.photoUrl = messageUserInfo.PHOTOURL;						
						[msgListData.userDataDic setObject:userData forKey:messageUserInfo.PKEY];
						//						[userData release];
					}
				}
				[msgListArray addObject:msgListData];
			}
			//			[msgListData release];
		}
		if (msgListArray && [msgListArray count] > 0) {
			//			for (CellMsgListData *msgListData1 in msgListArray) {
			//				NSLog(@"dbInitialize lastMsgDate=%@", msgListData1.lastMsgDate);
			//			}
			NSSortDescriptor *lastMsgDateSort = [[NSSortDescriptor alloc] initWithKey:@"lastMsgDate" ascending:NO selector:@selector(compare:)];
			[msgListArray sortUsingDescriptors:[NSArray arrayWithObject:lastMsgDateSort]];
			[lastMsgDateSort release];
		}
		
		if (connectionType == -1) {
			totalNewCount += apnsNotiCount;
		} else {
			totalNewCount += apnsNotiCount;
		}
		
		if (totalNewCount > 0) {
			// DB에서 읽어서 Badge표기
			UITabBarItem *tbi = [rootController.tabBar.items objectAtIndex:2]; //기존 1->2로
			if (tbi) {
				tbi.badgeValue = [NSString stringWithFormat:@"%i", totalNewCount];
			}
			//			[[UIApplication sharedApplication] setApplicationIconBadgeNumber:totalNewCount];
			[self playSystemSoundIDSound];
			[self playSystemSoundIDVibrate];
		} else {
			UITabBarItem *tbi = [rootController.tabBar.items objectAtIndex:2]; //기존 1->2로
			if (tbi) {
				tbi.badgeValue = nil;
			}
			//			[[UIApplication sharedApplication] setApplicationIconBadgeNumber:nNewMsgCount];
		}
		
	} else {
		// MessageUserInfo 값이 필요 없음
		[MessageUserInfo findWithSql:@"delete from _TMessageUserInfo"];
	}
}

- (NSString *)deviceIPAdress {
	InitAddresses();
	GetIPAddresses();
	//	GetHWAddresses();
	return [NSString stringWithFormat:@"%s",ip_names[1]];
}

// 개인정보
-(NSDictionary*) myInfoDictionary
{
	return myInfoDictionary;
}

-(NSString *)protocolUrl:(NSString*)key
{
	if(key == nil) return nil;
	if(protocolUrlDictionary == nil) return nil;
	if([protocolUrlDictionary count] == 0) return nil;
	
	return [protocolUrlDictionary objectForKey:key];
}

-(void) createSystemSoundID
{
	id soundPath = [[NSBundle mainBundle] pathForResource:@"sound" ofType:@"wav" inDirectory:@"/"];
	
	// URL 타입 생성
	CFURLRef baseURL = (CFURLRef)[[[NSURL alloc] initFileURLWithPath:soundPath] autorelease];
	
	// SoundID 생성
	AudioServicesCreateSystemSoundID(baseURL, &systemSoundID);
}

-(void) playSystemSoundIDSound
{
	NSUInteger	notisound = [[NSUserDefaults standardUserDefaults] integerForKey:@"notisound"];	// 0: off  1: on
	if (notisound == 1) {	
		AudioServicesPlaySystemSound(systemSoundID);
	}
}

-(void) disposeSystemSoundID
{
	AudioServicesDisposeSystemSoundID(systemSoundID);
	systemSoundID = 0;
}

-(void) playSystemSoundIDVibrate
{
	NSUInteger	notivibrate = [[NSUserDefaults standardUserDefaults] integerForKey:@"notivibrate"];	// 0: off  1: on
	if (notivibrate == 1) {
		AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
	}
}

-(NSString *)generateUUIDString
{
	CFUUIDRef       uuid;
    CFStringRef     uuidStr;
    NSString *      result;
    
    uuid = CFUUIDCreate(NULL);
	//    assert(uuid != NULL);
    
    uuidStr = CFUUIDCreateString(NULL, uuid);
	//    assert(uuidStr != NULL);
	
    result = [NSString stringWithFormat:@"%@", uuidStr];
    
    CFRelease(uuidStr);
    CFRelease(uuid);
	
	return result;
}

-(UIColor *)getColor:(NSString*)hexColorStr
{
	unsigned int red, green, blue;
	NSRange range;
	range.length = 2;
	
	range.location = 0;
	[[NSScanner scannerWithString:[hexColorStr substringWithRange:range]] scanHexInt:&red];
	
	range.location = 2;
	[[NSScanner scannerWithString:[hexColorStr substringWithRange:range]] scanHexInt:&green];
	
	range.location = 4;
	[[NSScanner scannerWithString:[hexColorStr substringWithRange:range]] scanHexInt:&blue];
	
	return [UIColor colorWithRed:(float)(red/255.0f) green:(float)(green/255.0f) blue:(float)(blue/255.0f) alpha:1.0f];
}


#pragma mark -
// 네트워크 연결 상태 확인
-(BOOL) connectedToNetwork
{
	// 제로주소의 생성
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
	
	// 네트워크 도달 가능 플래그
	SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *) &zeroAddress);
	
	SCNetworkReachabilityFlags flags;	
	BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
	CFRelease(defaultRouteReachability);
	
	if(!didRetrieveFlags) {
		printf("Error. Could not recover network reachability flags\n");
		return NO;
	}
	
	BOOL isReachable = flags & kSCNetworkFlagsReachable;
	BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
	
	return (isReachable && !needsConnection) ? YES : NO;
}

- (BOOL) isCellNetwork
{
	// 1. 빈 socket 생성하기
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
	
	// 2. SCNetworkReachabilityRef 만들기
	SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *) &zeroAddress);
	
	// 3. 플래그 값 가져오기
	SCNetworkReachabilityFlags flag;
	BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flag);
	CFRelease(defaultRouteReachability);
	
	if(!didRetrieveFlags) {
		printf("Error. Could not recover network reachability flags\n");
		return NO;
	}
	
	if (flag & kSCNetworkReachabilityFlagsIsWWAN) {
		return YES;
	} else {
		return NO;
	}
}
/*
 +(NSString *) localAddressForInterface:(NSString *)interface {
 BOOL success;
 struct ifaddrs * addrs;
 const struct ifaddrs * cursor;
 
 success = getifaddrs(&addrs) == 0;
 if (success) {
 cursor = addrs;
 while (cursor != NULL) {
 // the second test keeps from picking up the loopback address
 if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0) 
 {
 NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
 if ([name isEqualToString:interface])  // Wi-Fi adapter
 return [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
 }
 cursor = cursor->ifa_next;
 }
 freeifaddrs(addrs);
 }
 return nil;	
 }
 
 +(NSString *) localWiFiIPAddress
 {
 return [self localAddressForInterface:@"en0"];
 }
 
 +(NSString *) localCellularIPAddress
 {
 return [self localAddressForInterface:@"pdp_ip0"];
 }
 //*/
-(NSString*) localIPAddress
{
	/*
	 BOOL success;
	 struct ifaddrs * addrs;
	 const struct ifaddrs * cursor;
	 
	 success = getifaddrs(&addrs) == 0;
	 if (success) {
	 cursor = addrs;
	 while (cursor != NULL) {
	 // the second test keeps from picking up the loopback address
	 if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0) 
	 {
	 NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
	 if ([name isEqualToString:interface])  // Wi-Fi adapter
	 return [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
	 }
	 cursor = cursor->ifa_next;
	 }
	 freeifaddrs(addrs);
	 }
	 return nil;
	 //*/
	/*
	 NSString *address = @"error";
	 struct ifaddrs *interfaces = NULL;
	 struct ifaddrs *temp_addr = NULL;
	 int success = 0;
	 
	 // retrieve the current interfaces - returns 0 on success
	 success = getifaddrs(&interfaces);
	 if (success == 0)
	 {
	 // Loop through linked list of interfaces
	 temp_addr = interfaces;
	 while(temp_addr != NULL)
	 {
	 if(temp_addr->ifa_addr->sa_family == AF_INET)
	 {
	 // Check if interface is en0 which is the wifi connection on the iPhone
	 if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
	 {
	 // Get NSString from C String
	 address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
	 }
	 }
	 
	 temp_addr = temp_addr->ifa_next;
	 }
	 }
	 
	 // Free memory
	 freeifaddrs(interfaces);
	 
	 return address;
	 //*/
	
	//	char baseHostName[255];
	//	gethostname(baseHostName, 255);
	//	
	//	char hn[255];	
	//	if([[NSString stringWithCString:baseHostName] hasSuffix:@".local"]) {
	//		sprintf(hn, "%s", baseHostName);
	//	} else {
	//		sprintf(hn, "%s.local", baseHostName);
	//	}
	//	
	//	struct hostent *host = gethostbyname(hn);
	//	
	//	if(host == NULL) {
	//		herror("resolv");
	//		return NULL;
	//	} else {
	//		struct in_addr **list = (struct in_addr **) host->h_addr_list;
	//		return [NSString stringWithCString:inet_ntoa(*list[0])];
	//	}
	return nil;
}

// 사이트 도메인으로 ip 주소 조회
-(NSString*)getIPAddressFromHost:(NSString*)theHost
{
	struct hostent *host = gethostbyname([theHost UTF8String]);
	
	if (host == NULL) {
		herror("resolv");
		return NULL;
	}
	
	struct in_addr **list = (struct in_addr **)host->h_addr_list;
	NSString *addressString = [NSString stringWithCString:inet_ntoa(*list[0]) encoding:NSUTF8StringEncoding];
	
	return addressString;
}

// 특정 사이트에 도달 할 수 있는지 조회
-(BOOL)hostAvailable:(NSString*)theHost
{
	NSString *addressString = [self getIPAddressFromHost:theHost];
	if (!addressString) {
		printf("Error recovering IP address from host name\n");
		return NO;
	}
	
	struct sockaddr_in address;
	BOOL gotAddress = [self addressFromString:addressString address:&address];
	
	if (!gotAddress) {
		printf("Error recovering sockaddr address from %s\n", [addressString UTF8String]);
		return NO;
	}
	
	SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr*)&address);
	SCNetworkReachabilityFlags flags;
	BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
	CFRelease(defaultRouteReachability);
	
	if (!didRetrieveFlags) {
		printf("Error. Could not recover network rechability flags\n");
		return NO;
	}
	BOOL isReachable = flags & kSCNetworkFlagsReachable;
	return isReachable ? YES:NO;
}

// Direct from Apple
-(BOOL)addressFromString:(NSString*)IPAddress address:(struct sockaddr_in *)address
{
	if (!IPAddress || ![IPAddress length]) {
		return NO;
	}
	memset((char*)address, sizeof(struct sockaddr_in), 0);
	address->sin_family = AF_INET;
	address->sin_len = sizeof(struct sockaddr_in);
	
	int conversionResult = inet_aton([IPAddress UTF8String], &address->sin_addr);
	if (conversionResult == 0) {
		//		NSAssert1(conversionResult != 1, @"Failed to convert the IP address string into a sockaddr_in: %@", IPAddress);
		return NO;
	}
	
	return YES;
}

#pragma mark -
#pragma mark 추천친구 리스트 요청
-(void) requestProposeUserList
{
	DebugLog(@"===== (추천친구 목록 요청) requestProposeUserList =====>");

	// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
	NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
	[bodyObject setObject:[self getSvcIdx] forKey:@"svcidx"];
	
	USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"getRecommendFriendsList" 
												  andWithDictionary:bodyObject timeout:10] autorelease];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
}

#pragma mark -
#pragma mark TCP/IP Connect / SendPacket
-(BOOL) connect:(NSString*)host PORT:(NSInteger)port
{
	if(host == nil || [host length] <= 0 || port <= 0) return NO;
	
	if(clientAsyncSocket == nil) {
		isConnected = NO;
		clientAsyncSocket = [[AsyncSocket alloc] initWithDelegate:self];
	}
	// disconnect이 안되고 들어오는 경우가 있음.
	if([clientAsyncSocket isConnected]){
		isConnected = NO;
		[clientAsyncSocket disconnect];
	}
	
	NSString *hostAddress = host;
	NSInteger hostPort = port;
	
	NSError *err = nil;
	
	if (![clientAsyncSocket connectToHost:hostAddress onPort:hostPort withTimeout:60 error:&err]) {
		NSLog(@"connectToHost Error: %@", err);
		return NO;
	}

	/* sochae 2010.09.27 - 아래 함수로 이동
	struct sockaddr_in address;
	if ([self addressFromString:hostAddress address:&address]) {
		
	//	hostReach = [[Reachability reachabilityWithHostName: @"www.apple.com"] retain];

		
		hostReach = [[Reachability reachabilityWithAddress:&address] retain];
		[hostReach connectionRequired];
		[hostReach startNotifier];
	}*/

	return YES;
}

// sochae 2010.09.27
-(BOOL) setupReachability:(NSString*)host
{
	BOOL result = NO;
	if ([host length] > 0)
	{
		NSString *hostAddress = host;
		DebugLog(@"Reachability Host : %@", hostAddress);

		if (hostReach != nil)
			[hostReach release];

//		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotificationV2 object:nil];

		struct sockaddr_in address;
		if ([self addressFromString:hostAddress address:&address])
		{
			hostReach = [[Reachability reachabilityWithAddress:&address] retain];
			[hostReach startNotifier];
			result = YES;
		}
	}
	return result;
}
// ~sochae

-(BOOL) sendLogin
{
	DebugLog(@"[SUN] sendLogin CALLED ==========>");
	if(clientAsyncSocket == nil || [clientAsyncSocket isConnected] == NO) return NO;
	
	isLoginfail = NO;
	
	ExtStrPacket *headExtStringPacket = nil;
	NSDictionary *dict = nil, *mapData = nil;
	NSString	*body = nil;
	headExtStringPacket = [[ExtStrPacket alloc] init];
	if(headExtStringPacket) {
		[headExtStringPacket AddItemString:@"bodytype" Value:@"6" IsReplace:YES];
		[headExtStringPacket AddItemString:@"svc" Value:@"presence" IsReplace:YES];
		[headExtStringPacket AddItemString:@"pkey" Value:[myInfoDictionary objectForKey:@"pkey"] IsReplace:YES];
		
		mapData = [NSDictionary dictionaryWithObjectsAndKeys:
				   ([myInfoDictionary objectForKey:@"pkey"] == nil) ? [NSNull null] : [myInfoDictionary objectForKey:@"pkey"], @"pkey",
				   ([myInfoDictionary objectForKey:@"userno"] == nil) ? [NSNull null] : [myInfoDictionary objectForKey:@"userno"], @"userno",
				   ([myInfoDictionary objectForKey:@"userid"] == nil) ? [NSNull null] : [myInfoDictionary objectForKey:@"userid"], @"userid",
				   // sochae 2010.10.12 - nickname은 NSUserDefaults에만 저장.
				   //([myInfoDictionary objectForKey:@"nickname"] == nil) ? [NSNull null] : [myInfoDictionary objectForKey:@"nickname"], @"nickname",
				   ([JYUtil loadFromUserDefaults:kNickname] == nil) ? [NSNull null] : [JYUtil loadFromUserDefaults:kNickname], kNickname,
				   // ~sochae
				   ([myInfoDictionary objectForKey:@"exip"] == nil) ? [NSNull null] : [myInfoDictionary objectForKey:@"exip"], @"exip",
				   ([myInfoDictionary objectForKey:@"inip"] == nil) ? [NSNull null] : [myInfoDictionary objectForKey:@"inip"], @"inip",
				   ([myInfoDictionary objectForKey:@"ssk"] == nil) ? [NSNull null] : [myInfoDictionary objectForKey:@"ssk"], @"ssk",
				   @"1", @"imstatus",
				   [self getSvcIdx], @"svcidx",
				   ([myInfoDictionary objectForKey:@"devicetoken"] == nil) ? [NSNull null] : [myInfoDictionary objectForKey:@"devicetoken"], @"devtoken",
				   @"mobile", @"device",
				   [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"], @"version",
				   [[UIDevice currentDevice] systemName], @"os",
				   @"1", @"exclusive",
				   nil];
		dict = [NSDictionary dictionaryWithObjectsAndKeys:
				@"map", @"rqtype",
				@"LOGIN", @"cmd",
				mapData, @"map",
				nil];
		DebugLog(@"=====> [SUN] sendLogin dict : %@", [dict description]);
		
		[[NSUserDefaults standardUserDefaults] setValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] forKey:@"UsayVerSion"];
		NSLog(@"Usay VerSion = %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]); 
		 
		
#if TARGET_IPHONE_SIMULATOR			
		// 결과 출력
		//		for (id key in mapData) {
		//			NSLog(@"Key: %@, Value: %@", key, [mapData valueForKey:key]);
		//		}
#endif
		//		mapData = nil;
		
		// JSON 라이브러리 생성
		SBJSON *json = [[SBJSON alloc]init];
		[json setHumanReadable:YES];
		// 변환
		body = [json stringWithObject:dict error:nil];
		[json release];
		TransPacket *transPacket = nil;
		transPacket = [[TransPacket alloc] init];
		
		if(transPacket) {
			//			if([transPacket SetPacketExtHeadBuffBody:headExtStringPacket Body:[body UTF8String] BodySize:strlen([body UTF8String])]) {
			NSData *data = [NSData dataWithBytes:[body UTF8String] length:strlen([body UTF8String])];
			if (data) {
				data = [data AESEncryptWithKey:kAESKey InitializationVector:kAESIV];
				if([transPacket SetPacketExtHeadBuffBody:headExtStringPacket Body:[data bytes] BodySize:[data length]]) {
					const void *pPacket = [transPacket GetPacketPtr];
					NSUInteger packetsize = (NSUInteger)[transPacket GetPacketSize];
					if(packetsize <= 0) {
						[headExtStringPacket release];
						[transPacket release];
						return NO;
					} else {
						DebugLog(@"=====> [SUN] clientAsyncSocket writeData size : %i", packetsize);
						[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
						[clientAsyncSocket writeData:[NSData dataWithBytes:pPacket length:packetsize] withTimeout:5 tag:0];
					}
					[headExtStringPacket release];
					[transPacket release];
				} else {
					[headExtStringPacket release];
					[transPacket release];
					return NO;
				}
			} else {
				[headExtStringPacket release];
				[transPacket release];
			}
		} else {
			[headExtStringPacket release];
			return NO;
		}
	} else {
		[headExtStringPacket release];
		return NO;
	}
	
	return YES;
}

// 설정 - 프로필 설정 - 상태 정보 변경 패킷 전송
-(BOOL) updatePresence:(NSString*)imstatus		// 0:offline  1:online  2:busy (바빠요)  8:곧 돌아옵니다.  16:다른용무중
{
	if(clientAsyncSocket == nil || [clientAsyncSocket isConnected] == NO) return NO;
	
	ExtStrPacket *headExtStringPacket = nil;
	NSDictionary *dict = nil, *mapData = nil;
	NSString	*body = nil;
	headExtStringPacket = [[ExtStrPacket alloc] init];
	if(headExtStringPacket) {
		[headExtStringPacket AddItemString:@"bodytype" Value:@"5" IsReplace:YES];
		[headExtStringPacket AddItemString:@"svc" Value:@"presence" IsReplace:YES];
		[headExtStringPacket AddItemString:@"pkey" Value:[myInfoDictionary objectForKey:@"pkey"] IsReplace:YES];
		mapData = [NSDictionary dictionaryWithObjectsAndKeys:
				   ([myInfoDictionary objectForKey:@"tupleid"] == nil) ? [NSNull null] : [myInfoDictionary objectForKey:@"tupleid"], @"tupleid",
				   imstatus, @"imstatus",
				   nil];
		//		NSLog(@"updatePresence %@", mapData);
		dict = [NSDictionary dictionaryWithObjectsAndKeys:
				@"map", @"rqtype",
				@"UPDATE_PRESENCE", @"cmd",
				mapData, @"map",
				nil];
		
		// JSON 라이브러리 생성
		SBJSON *json = [[SBJSON alloc]init];
		[json setHumanReadable:YES];
		// 변환
		body = [json stringWithObject:dict error:nil];
		[json release];
		
		TransPacket *transPacket = nil;
		transPacket = [[TransPacket alloc] init];
		
		if(transPacket) {
			if([transPacket SetPacketExtHeadBuffBody:headExtStringPacket Body:[body cStringUsingEncoding:NSEUCKREncoding] BodySize:strlen([body cStringUsingEncoding:NSEUCKREncoding])]) {
				const void *pPacket = [transPacket GetPacketPtr];
				NSUInteger packetsize = (NSUInteger)[transPacket GetPacketSize];
				if(packetsize <= 0) {
					[headExtStringPacket release];
					[transPacket release];
					return NO;
				} else {
					[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
					[clientAsyncSocket writeData:[NSData dataWithBytes:pPacket length:packetsize] withTimeout:5 tag:0];
				}
				[headExtStringPacket release];
				[transPacket release];
			} else {
				[headExtStringPacket release];
				[transPacket release];
				return NO;
			}
		} else {
			[headExtStringPacket release];
			return NO;
		}
	} else {
		[headExtStringPacket release];
		return NO;
	}
	
	return YES;
}
#pragma mark -
#pragma mark getChangedProfileInfo Method
-(void)requestGetChangedProfileInfo {
	//서버로 친구 프로파일 요청
	//*	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getChangedProfileInfo:) name:@"getChangedProfileInfo" object:nil];
	
	NSString* sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE ISFRIEND = ?",[UserInfo tableName]];
	DebugLog(@"request progileinfo %@", sql);
	NSArray* allBuddyArray = [UserInfo findWithSqlWithParameters:sql,@"S",nil];
	NSMutableArray* profileArray = [NSMutableArray array];
	
	for(UserInfo* userInBuddy in allBuddyArray){
		if([userInBuddy.ISFRIEND isEqualToString:@"S"]){
			NSMutableDictionary* dicBuddyInfo = [NSMutableDictionary dictionary];
			[dicBuddyInfo setValue:userInBuddy.ID forKey:@"id"];
			if(userInBuddy.STATUSSP != nil && [userInBuddy.STATUSSP length] > 0){
				[dicBuddyInfo setValue:userInBuddy.STATUSSP forKey:@"s"];
			}else {
				[dicBuddyInfo setValue:@"0" forKey:@"s"];
			}
			
			if(userInBuddy.REPRESENTPHOTOSP != nil && [userInBuddy.REPRESENTPHOTOSP length]>0){
				[dicBuddyInfo setValue:userInBuddy.REPRESENTPHOTOSP forKey:@"r"];
			}else {
				[dicBuddyInfo setValue:@"0" forKey:@"r"];
			}
			
			if(userInBuddy.NICKNAMESP != nil && [userInBuddy.NICKNAMESP length]>0){
				[dicBuddyInfo setObject:userInBuddy.NICKNAMESP forKey:@"n"];
			}else {
				[dicBuddyInfo setObject:@"0" forKey:@"n"];
			}
			
			
			[profileArray addObject:dicBuddyInfo];
		}
	}
	
	SBJSON *json = [[SBJSON alloc] init];
	[json setHumanReadable:YES];
	//	NSString* count = nil;
	//	if([profileArray count] > 0)
	//		count = [NSString stringWithFormat:@"%@",[profileArray count]];
	//	else
	//		count = 0;
	
	NSString* listbody = [json stringWithObject:profileArray error:nil];
	
	//	NSLog(@"%@", listbody);
	NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:
								listbody, @"param",
								[self  getSvcIdx], @"svcidx",
								//							count,@"count",
								nil];
	//	assert(bodyObject != nil);
	
	//	NSString* temp = [json stringWithObject:bodyObject error:nil];
	//	NSLog(@"%@",temp);
	[json release];
	// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
	USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"getChangedProfileInfo" andWithDictionary:bodyObject timeout:10]autorelease];
	//	assert(data != nil);
	[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
	
	// */
}

-(void)getChangedProfileInfo:(NSNotification *)notification {
	DebugLog(@"========== getChangedProfileInfo ==========");
	// TODO: 친구의 최신 정보를 받아온다. status, represenphoto, nickname;
	USayHttpData *data = (USayHttpData*)[notification object];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"getChangedProfileInfo" object:nil];
	
	if (data == nil) {
		// 200 이외의 에러
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" 
															message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0039)" 
														   delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return ;
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
		NSString *count = [dic objectForKey:@"count"];		
		if([rtType isEqualToString:@"list"]){			
			// Key and Dictionary as its value type
			NSArray* userArray = [dic objectForKey:@"list"];
			if([count intValue] > 0){
				if([count intValue] == [userArray count]){
					for(NSDictionary* userData in userArray) {
						UserInfo* profileInfo = [[UserInfo alloc] init];
						if([userData objectForKey:@"id"] && [[userData objectForKey:@"id"] length] > 0){
							profileInfo.ID = [userData objectForKey:@"id"];
							if([userData objectForKey:@"nickName"] && [[userData objectForKey:@"nickName"] length] > 0){
								profileInfo.PROFILENICKNAME = [userData objectForKey:@"nickName"];
							}
							if([userData objectForKey:@"nickNameSP"] && [[userData objectForKey:@"nickNameSP"] length] > 0){
								profileInfo.NICKNAMESP  = [userData objectForKey:@"nickNameSP"];
							}
							if([userData objectForKey:@"status"] && [[userData objectForKey:@"status"] length] > 0){
								profileInfo.STATUS = [userData objectForKey:@"status"];
							}
							if([userData objectForKey:@"statusSP"] && [[userData objectForKey:@"statusSP"] length] > 0){
								profileInfo.STATUSSP = [userData objectForKey:@"statusSP"];
							}
							if([userData objectForKey:@"representPhoto"] && [[userData objectForKey:@"representPhoto"] length] > 0){
								profileInfo.REPRESENTPHOTO = [userData objectForKey:@"representPhoto"];
								// 대화창 사진 변경 start
								NSArray *checkDBUserInfo = [UserInfo findWithSqlWithParameters:@"select * from _TUserInfo where ID=?", profileInfo.ID, nil];
								if (checkDBUserInfo && [checkDBUserInfo count] > 0) {
									for (UserInfo *userInfo in checkDBUserInfo) {
										NSLog(@"DBUSer = %@ %@", userInfo.NICKNAME, userInfo.MOBILEPHONENUMBER);															   
															   
										if(userInfo.RPKEY != nil && [userInfo.RPKEY length]> 0){
											if (profileInfo.REPRESENTPHOTO != nil && [profileInfo.REPRESENTPHOTO length] > 0) {
												NSArray *checkDBMessageUserInfo = [MessageUserInfo findWithSqlWithParameters:@"select * from _TMessageUserInfo where PKEY=?", userInfo.RPKEY, nil];
												if (checkDBMessageUserInfo && [checkDBMessageUserInfo count] > 0) {
													[MessageUserInfo findWithSqlWithParameters:@"update _TMessageUserInfo set PHOTOURL=? where PKEY=?", profileInfo.REPRESENTPHOTO, userInfo.RPKEY, nil];
												}
												//												@synchronized(self.msgListArray) {
												if (self.msgListArray && [self.msgListArray count] > 0) {
													for (CellMsgListData *msgListData in self.msgListArray) {
														if (msgListData.userDataDic && [msgListData.userDataDic count] > 0) {
															for (id key in msgListData.userDataDic) {
																if ([(NSString*)key isEqualToString:userInfo.RPKEY]) {
																	MsgUserData *userData = [msgListData.userDataDic objectForKey:key];
																	if (userData) {
																		userData.photoUrl = profileInfo.REPRESENTPHOTO;
																	}
																}
															}
														}
													}
													// 대화창 리스트에 notification (테이블 reload 처리)
													[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadMsgList" object:nil];
												}
												//												}
											} else {
											}
										}
									}
								}
								// 대화창 사진 변경 end
							}
							if([userData objectForKey:@"representPhotoSP"] && [[userData objectForKey:@"representPhotoSP"] length] > 0){
								profileInfo.REPRESENTPHOTOSP = [userData objectForKey:@"representPhotoSP"];
							}
						}
						
						[profileInfo release];
					}
					
				}
				
			}
			[[NSNotificationCenter defaultCenter] postNotificationName:@"updateChangedProfileInfo" object:userArray];
		}else {
			//error
		}
		
	} else if ([rtcode isEqualToString:@"4040"]) {
		
	} else if ([rtcode isEqualToString:@"-9010"]) {
		// TODO: 데이터를 찾을 수 없음
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"업데이트 실패" 
															message:@"변경된 데이터를\n찾지 못하였습니다.(-9010)" 
														   delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		
	} else if ([rtcode isEqualToString:@"-9020"]) {
		// TODO: 잘못된 인자가 넘어옴
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"업데이트 실패" 
															message:@"맞지 않는 데이터가 들어 있습니다.(-9020)" 
														   delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];		
	} else if ([rtcode isEqualToString:@"-9030"]) {
		// TODO: 처리 오류
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"업데이트 실패" 
															message:@"데이터 처리중\n오류가 발생하였습니다.(-9030)" 
														   delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		
	} else {
		// TODO: 기타오류 예외처리 필요
		NSString* alertStr = [NSString stringWithFormat:@"오류 발생으로 데이터를 처리하지 못하였습니다.(%@)",rtcode];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"업데이트 실패" 
															message:alertStr 
														   delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		
	}
}



#pragma mark -
// 나의 친구 상태 정보 요청 (온라인중인 버디 상태 정보 조회. 오프라인 버디 정보는 내려오지 않음)
-(BOOL) getOnBuddyStatus
{
	if(clientAsyncSocket == nil || [clientAsyncSocket isConnected] == NO) return NO;
	
	ExtStrPacket *headExtStringPacket = nil;
	NSDictionary *dict = nil, *mapData = nil;
	NSString	*body = nil;
	headExtStringPacket = [[ExtStrPacket alloc] init];
	if(headExtStringPacket) {
		[headExtStringPacket AddItemString:@"bodytype" Value:@"5" IsReplace:YES];
		[headExtStringPacket AddItemString:@"svc" Value:@"presence" IsReplace:YES];
		//		[headExtStringPacket AddItemString:@"pkey" Value:[myInfoDictionary objectForKey:@"pkey"] IsReplace:YES];
		NSNumber *savedLastUpdateTimeNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastUpdateTime"];
		if (savedLastUpdateTimeNumber) {
			mapData = [NSDictionary dictionaryWithObjectsAndKeys:
					   ([myInfoDictionary objectForKey:@"pkey"] == nil) ? @"" : [myInfoDictionary objectForKey:@"pkey"], @"pkey",
					   [self getSvcIdx], @"svcidx",
					   savedLastUpdateTimeNumber, @"lastupdatetime",
					   nil];
		} else {
			mapData = [NSDictionary dictionaryWithObjectsAndKeys:
					   ([myInfoDictionary objectForKey:@"pkey"] == nil) ? @"" : [myInfoDictionary objectForKey:@"pkey"], @"pkey",
					   [self getSvcIdx], @"svcidx",
					   nil];
		}
		
		dict = [NSDictionary dictionaryWithObjectsAndKeys:
				@"map", @"rqtype",
				@"GET_ONBUDDY_STATUS", @"cmd",
				mapData, @"map",
				nil];
		
		// JSON 라이브러리 생성
		SBJSON *json = [[SBJSON alloc]init];
		[json setHumanReadable:YES];
		// 변환
		body = [json stringWithObject:dict error:nil];
		[json release];
		TransPacket *transPacket = nil;
		transPacket = [[TransPacket alloc] init];
		
		if(transPacket) {
			if([transPacket SetPacketExtHeadBuffBody:headExtStringPacket Body:[body cStringUsingEncoding:NSEUCKREncoding] BodySize:strlen([body cStringUsingEncoding:NSEUCKREncoding])]) {
				const void *pPacket = [transPacket GetPacketPtr];
				NSUInteger packetsize = (NSUInteger)[transPacket GetPacketSize];
				if(packetsize <= 0) {
					[headExtStringPacket release];
					[transPacket release];
					return NO;
				} else {
					[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
					[clientAsyncSocket writeData:[NSData dataWithBytes:pPacket length:packetsize] withTimeout:5 tag:0];
				}
				[headExtStringPacket release];
				[transPacket release];
			} else {
				[headExtStringPacket release];
				[transPacket release];
				return NO;
			}
		} else {
			[headExtStringPacket release];
			return NO;
		}
	} else {
		[headExtStringPacket release];
		return NO;
	}
	
	return YES;
}

#pragma mark -
#pragma mark pKey값으로 대화방 사진, nickName DB에서 읽어오기. 읽은곳에서 userData release 처리 필요
-(MsgUserData*)getNickNameRepresentPhoto:(NSString*)pKey
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	MsgUserData *userData = nil;
	NSArray *userListArray = [UserInfo findWithSqlWithParameters:@"select * from _TUserInfo where PKEY=?", pKey, nil];
	if (userListArray && [userListArray count] == 1) {
		for (UserInfo *userInfo in userListArray) {
			userData = [[[MsgUserData alloc] init] autorelease];
			//			assert(userData != nil);
			userData.pKey = pKey;
			if (userInfo.FORMATTED && [userInfo.FORMATTED length] > 0) {
				userData.nickName = userInfo.FORMATTED;
			} else if (userInfo.PROFILENICKNAME && [userInfo.PROFILENICKNAME length] > 0) {
				userData.nickName = userInfo.PROFILENICKNAME;
			} else {
				userData.nickName = @"이름 없음";
			}
			
			userData.photoUrl = userInfo.THUMBNAILURL;
		}
	}
	
	[pool release];
	return userData;
}

#pragma mark -
#pragma mark pKey값으로 상태 정보 읽어오기
-(NSString*)getImStatus:(NSString*)fPKey
{
	if (fPKey == nil || [fPKey length] <= 0) {
		return nil;
	}
	
	if(imStatusDictionary && [imStatusDictionary count] > 0) {
		NSString *imStatus = [imStatusDictionary objectForKey:fPKey];
		if (imStatus == nil || (imStatus && [imStatus length] > 0 && [imStatus isEqualToString:@"0"])) {
			return @"1";	// 값이 없으면 무조건 온라인 처리
		}
		return [imStatusDictionary objectForKey:fPKey];
	} else {
		return @"1";
	}
	
	return nil;
}


#pragma mark -
#pragma mark 새로운 글 카운트 (DB에서 얻어옴)
-(NSInteger)newMessageCount
{
	NSInteger nNewCount = 0;
	NSArray *roomDBInfoArray = [RoomInfo findWithSqlWithParameters:@"select * from _TRoomInfo", nil];
	
	DebugLog(@"=====> DB _TRoomInfo : %@",[roomDBInfoArray description]);
	if (roomDBInfoArray && [roomDBInfoArray count] > 0) {
		for (RoomInfo *roomInfo in roomDBInfoArray) {
			if ([roomInfo.NEWMSGCOUNT intValue] >= 0) {
				nNewCount += [roomInfo.NEWMSGCOUNT intValue];
			}
		}
	}
	
	return nNewCount;
}

#pragma mark -
#pragma mark 대화방 리스트 관리 (msgListArray)
-(BOOL) IsChatSession:(NSString*)chatsession
{
	if (chatsession == nil || [chatsession length] == 0) {
		return NO;
	}
	
	for (CellMsgListData *msgListData in msgListArray) {
		//		assert(msgListData != nil);
		if ([msgListData.chatsession isEqualToString:chatsession]) {
			return YES;
		}
	}
	
	return NO;
}

-(BOOL) AddNewMessageCount:(NSString*)chatsession
{
	if (chatsession == nil || [chatsession length] == 0) {
		return NO;
	}
	
	for (CellMsgListData *msgListData in msgListArray) {
		//		assert(msgListData != nil);
		if ([msgListData.chatsession isEqualToString:chatsession]) {
			NSInteger currentCount = [msgListData newMsgCount];
			[msgListData setNewMsgCount:currentCount+1];
			return YES;
		}
	}
	
	return NO;
}

// 닉, 이미지 url 값 얻는 함수. 인자값은 대화방세션값, pkey 값
-(MsgUserData*) MsgListUserInfo:(NSString*)chatsession pkey:(NSString*)pkey
{
	if (chatsession == nil || [chatsession length] == 0) {
		return nil;
	}
	if (pkey == nil || [pkey length] == 0) {
		return nil;
	}
	
	for (CellMsgListData *msgListData in msgListArray) {
		//		assert(msgListData != nil);
		if ([msgListData.chatsession isEqualToString:chatsession]) {
			MsgUserData *userData = [msgListData.userDataDic objectForKey:pkey];
			if (userData != nil) {
				return userData;
			}
		}
	}
	return nil;
}

-(CellMsgListData*) MsgListDataFromChatSession:(NSString*)chatsession	// 채팅 리스트에 있는 cell 정보
{
	if (chatsession == nil || [chatsession length] == 0) {
		return nil;
	}
	for (CellMsgListData *msgListData in msgListArray) {
		//		assert(msgListData != nil);
		if ([msgListData.chatsession isEqualToString:chatsession]) {
			return msgListData;
		}
	}
	return nil;
}

// 1:1대화 or 그룹대화 대화방이 있는지 확인. 인자값은 친구 or 친구들의 pkey 값
-(NSString*)chatSessionFrompKey:(NSArray*)pkeyArray
{
	if (pkeyArray == nil || [pkeyArray count] == 0) {
		return nil;
	}
	int nCheckCount = 0;
	
	for (CellMsgListData *msgListData in msgListArray) {
		//		assert(msgListData != nil);
		if ([msgListData.userDataDic count] == [pkeyArray count]) {
			for(NSString* key in msgListData.userDataDic) {
				for (NSString* pkey in pkeyArray) {
					if ([pkey isEqualToString:key]) {
						nCheckCount++;
					}
				}
			}
			if ([pkeyArray count] == nCheckCount) {
				return msgListData.chatsession;
			} else {
				nCheckCount = 0;
			}
		}
	}
	
	return nil;
}

-(NSInteger)chatSessionPeopleCount:(NSString*)chatsession	// 채팅방에 있는 친구 수. (본인제외)
{
	if (chatsession == nil || [chatsession length] == 0) {
		return 0;
	}
	for (CellMsgListData *msgListData in msgListArray) {
		//		assert(msgListData != nil);
		if ([msgListData.chatsession isEqualToString:chatsession]) {
			return [msgListData.userDataDic count];
		}
	}
	
	return 0;
}

// 현재 시간을 구해서 오늘 날짜는 AM, PM 시간 처리
// 오늘이 아닐때는 YYYY-MM-DD
// ex) AM 10:08   ===> AM 10:8 처리
// ex) 2010-07-08 ===> 2010-7-8 처리
-(NSString*)generateMsgListDateFromUnixTimeStamp:(NSNumber*)unixtimestamp
{
	if (unixtimestamp == nil) {
		return nil;
	}
	NSDate *date = nil;
	NSString *strUnixTimeStamp = [NSString stringWithFormat:@"%llu", [unixtimestamp longLongValue]];
	
	if ([strUnixTimeStamp length] == 13) {
		date = [NSDate dateWithTimeIntervalSince1970:[strUnixTimeStamp longLongValue]/1000];
	} else {
		date = [NSDate dateWithTimeIntervalSince1970:[strUnixTimeStamp longLongValue]];
	}
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *comp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSWeekdayCalendarUnit fromDate:date];
	NSInteger year = [comp year];
	NSInteger month = [comp month];
	NSInteger day = [comp day];
	NSInteger hour = [comp hour];
	NSInteger minute = [comp minute];
	//	NSInteger second = [comp second];
	//	NSInteger weekday = [comp weekday];	// N=7 and 1 is Sunday
	//	NSLog(@"%04i-%02i-%02i %02i:%02i:%02i %i", year, month, day, hour, minute, second, weekday);
	
	NSDate *currentDate = [NSDate date];
	NSDateComponents *currentComp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSWeekdayCalendarUnit fromDate:currentDate];
	NSInteger currentYear = [currentComp year];
	NSInteger currentMonth = [currentComp month];
	NSInteger currentDay = [currentComp day];
	//	NSInteger currentHour = [currentComp hour];
	//	NSInteger currentMinute = [currentComp minute];
	//	NSInteger currentSecond = [currentComp second];
	//	NSInteger currentWeekday = [currentComp weekday];
	
	NSString *generateDate = nil;
	
	if (year < currentYear) {
		// YYYY-MM-DD
		generateDate = [NSString stringWithFormat:@"%i-%i-%i", year, month, day];
	} else if (year == currentYear) {
		if (month < currentMonth) {
			// YYYY-MM-DD
			generateDate = [NSString stringWithFormat:@"%i-%i-%i", year, month, day];
		} else if (month == currentMonth) {
			if (day < currentDay) {
				// YYYY-MM-DD
				generateDate = [NSString stringWithFormat:@"%i-%i-%i", year, month, day];
			} else if (day == currentDay) {
				// AM, PM 시간 형식으로 처리
				if (hour >= 0 && hour < 12) {
					if (hour == 0) {
						hour = 12;
					}
					generateDate = [NSString stringWithFormat:@"AM %i:%02i", hour, minute];
				} else if (hour >= 12 && hour <= 23) {
					if (hour == 12) {
						// skip
					} else {
						hour -= 12;
					}
					
					generateDate = [NSString stringWithFormat:@"PM %i:%02i", hour, minute];
				} else {
					// error
					return nil;
				}
			} else {
				// error
				return nil;
			}
		} else {
			// error
			return nil;
		}
	} else {
		// error
		return nil;
	}
	
	return generateDate;
}

-(NSString*)generateMsgListDateFromUnixTimeStampFromString:(NSString*)unixtimestamp
{
	if (unixtimestamp == nil) {
		return nil;
	}
	NSDate *date = nil;
	NSString *strUnixTimeStamp = unixtimestamp;
	
	if ([strUnixTimeStamp length] == 13) {
		date = [NSDate dateWithTimeIntervalSince1970:[strUnixTimeStamp longLongValue]/1000];
	} else {
		date = [NSDate dateWithTimeIntervalSince1970:[strUnixTimeStamp longLongValue]];
	}
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *comp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSWeekdayCalendarUnit fromDate:date];
	NSInteger year = [comp year];
	NSInteger month = [comp month];
	NSInteger day = [comp day];
	NSInteger hour = [comp hour];
	NSInteger minute = [comp minute];
	//	NSInteger second = [comp second];
	//	NSInteger weekday = [comp weekday];	// N=7 and 1 is Sunday
	//	NSLog(@"%04i-%02i-%02i %02i:%02i:%02i %i", year, month, day, hour, minute, second, weekday);
	
	NSDate *currentDate = [NSDate date];
	NSDateComponents *currentComp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSWeekdayCalendarUnit fromDate:currentDate];
	NSInteger currentYear = [currentComp year];
	NSInteger currentMonth = [currentComp month];
	NSInteger currentDay = [currentComp day];
	//	NSInteger currentHour = [currentComp hour];
	//	NSInteger currentMinute = [currentComp minute];
	//	NSInteger currentSecond = [currentComp second];
	//	NSInteger currentWeekday = [currentComp weekday];
	
	NSString *generateDate = nil;
	
	if (year < currentYear) {
		// YYYY-MM-DD
		generateDate = [NSString stringWithFormat:@"%i-%i-%i", year, month, day];
	} else if (year == currentYear) {
		if (month < currentMonth) {
			// YYYY-MM-DD
			generateDate = [NSString stringWithFormat:@"%i-%i-%i", year, month, day];
		} else if (month == currentMonth) {
			if (day < currentDay) {
				// YYYY-MM-DD
				generateDate = [NSString stringWithFormat:@"%i-%i-%i", year, month, day];
			} else if (day == currentDay) {
				// AM, PM 시간 형식으로 처리
				if (hour >= 0 && hour < 12) {
					if (hour == 0) {
						hour = 12;
					}
					generateDate = [NSString stringWithFormat:@"AM %i:%02i", hour, minute];
				} else if (hour >= 12 && hour <= 23) {
					if (hour == 12) {
						// skip
					} else {
						hour -= 12;
					}
					
					generateDate = [NSString stringWithFormat:@"PM %i:%02i", hour, minute];
				} else {
					// error
					return nil;
				}
			} else {
				// error
				return nil;
			}
		} else {
			// error
			return nil;
		}
	} else {
		// error
		return nil;
	}
	
	return generateDate;
}

// 현재 시간을 구해서 오늘 날짜는 AM, PM 시간 처리
// ex) AM 10:08   ===> AM 10:8 처리
-(NSString*)generateMsgDateFromUnixTimeStamp:(NSNumber*)unixtimestamp
{
	if (unixtimestamp == nil) {
		return nil;
	}
	NSDate *date = nil;
	NSString *strUnixTimeStamp = [NSString stringWithFormat:@"%llu", [unixtimestamp longLongValue]];
	
	if ([strUnixTimeStamp length] == 13) {
		date = [NSDate dateWithTimeIntervalSince1970:[strUnixTimeStamp longLongValue]/1000];
	} else {
		date = [NSDate dateWithTimeIntervalSince1970:[strUnixTimeStamp longLongValue]];
	}
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *comp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSWeekdayCalendarUnit fromDate:date];
	//	NSInteger year = [comp year];
	//	NSInteger month = [comp month];
	//	NSInteger day = [comp day];
	NSInteger hour = [comp hour];
	NSInteger minute = [comp minute];
	//	NSInteger second = [comp second];
	//	NSInteger weekday = [comp weekday];	// N=7 and 1 is Sunday
	//	NSLog(@"%04i-%02i-%02i %02i:%02i:%02i %i", year, month, day, hour, minute, second, weekday);
	
	NSString *generateDate = nil;
	
	if (hour >= 0 && hour < 12) {
		if (hour == 0) {
			hour = 12;
		}
		generateDate = [NSString stringWithFormat:@"AM %i:%02i", hour, minute];
	} else if (hour >= 12 && hour <= 23) {
		if (hour == 12) {
			// skip
		} else {
			hour -= 12;
		}
		
		generateDate = [NSString stringWithFormat:@"PM %i:%02i", hour, minute];
	} else {
		// error
		return nil;
	}
	
	return generateDate;
}

-(NSString*)generateMsgDateFromUnixTimeStampFromString:(NSString*)unixtimestamp
{
	NSDate *date = nil;
	NSString *strUnixTimeStamp = unixtimestamp;
	
	if ([strUnixTimeStamp length] == 13) {
		date = [NSDate dateWithTimeIntervalSince1970:[strUnixTimeStamp longLongValue]/1000];
	} else {
		date = [NSDate dateWithTimeIntervalSince1970:[strUnixTimeStamp longLongValue]];
	}
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *comp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSWeekdayCalendarUnit fromDate:date];
	
	NSInteger hour = [comp hour];
	NSInteger minute = [comp minute];
	
	NSString *generateDate = nil;
	
	if (hour >= 0 && hour < 12) {
		if (hour == 0) {
			hour = 12;
		}
		generateDate = [NSString stringWithFormat:@"AM %i:%02i", hour, minute];
	} else if (hour >= 12 && hour <= 23) {
		if (hour == 12) {
			// skip
		} else {
			hour -= 12;
		}
		
		generateDate = [NSString stringWithFormat:@"PM %i:%02i", hour, minute];
	} else {
		// error
		return nil;
	}
	
	return generateDate;
}

-(NSString*)compareLastMsgDate:(NSNumber*)beforeMsgUnixTimeStamp afterMsgUnixTimeStamp:(NSNumber*)afterMsgUnixTimeStamp
{
	if (beforeMsgUnixTimeStamp == nil && afterMsgUnixTimeStamp == nil) {
		return nil;
	} else if (beforeMsgUnixTimeStamp != nil && afterMsgUnixTimeStamp == nil) {
		return nil;
	}
	
	NSDate *beforeDate = nil, *afterDate = nil;
	
	NSString *strAfterUnixTimeStamp = [NSString stringWithFormat:@"%llu", [afterMsgUnixTimeStamp longLongValue]];
	
	if (beforeMsgUnixTimeStamp == nil && afterMsgUnixTimeStamp != nil) {
		if ([strAfterUnixTimeStamp length] == 13) {
			afterDate = [NSDate dateWithTimeIntervalSince1970:[strAfterUnixTimeStamp longLongValue]/1000];
		} else {
			afterDate = [NSDate dateWithTimeIntervalSince1970:[strAfterUnixTimeStamp longLongValue]];
		}
		NSCalendar *calendar = [NSCalendar currentCalendar];
		NSDateComponents *afterComp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSWeekdayCalendarUnit fromDate:afterDate];
		NSInteger afterYear = [afterComp year];
		NSInteger afterMonth = [afterComp month];
		NSInteger afterDay = [afterComp day];
		//		NSInteger afterHour = [afterComp hour];
		//		NSInteger afterMinute = [afterComp minute];
		//		NSInteger afterSecond = [afterComp second];
		NSInteger afterWeekday = [afterComp weekday];	// N=7 and 1 is Sunday
		
		NSString *generateDate = nil;
		
		if (afterWeekday == 1) {
			generateDate = [NSString stringWithFormat:@"%i년 %i월 %i일 일요일", afterYear, afterMonth, afterDay];
		} else if (afterWeekday == 2) {
			generateDate = [NSString stringWithFormat:@"%i년 %i월 %i일 월요일", afterYear, afterMonth, afterDay];
		} else if (afterWeekday == 3) {
			generateDate = [NSString stringWithFormat:@"%i년 %i월 %i일 화요일", afterYear, afterMonth, afterDay];
		} else if (afterWeekday == 4) {
			generateDate = [NSString stringWithFormat:@"%i년 %i월 %i일 수요일", afterYear, afterMonth, afterDay];
		} else if (afterWeekday == 5) {
			generateDate = [NSString stringWithFormat:@"%i년 %i월 %i일 목요일", afterYear, afterMonth, afterDay];
		} else if (afterWeekday == 6) {
			generateDate = [NSString stringWithFormat:@"%i년 %i월 %i일 금요일", afterYear, afterMonth, afterDay];
		} else if (afterWeekday == 7) {
			generateDate = [NSString stringWithFormat:@"%i년 %i월 %i일 토요일", afterYear, afterMonth, afterDay];
		} else {
			// error
			return nil;
		}
		
		return generateDate;
	}
	
	NSString *strBeforeUnixTimeStamp = [NSString stringWithFormat:@"%llu", [beforeMsgUnixTimeStamp longLongValue]];
	
	if ([strBeforeUnixTimeStamp length] == 13) {
		beforeDate = [NSDate dateWithTimeIntervalSince1970:[strBeforeUnixTimeStamp longLongValue]/1000];
	} else {
		beforeDate = [NSDate dateWithTimeIntervalSince1970:[strBeforeUnixTimeStamp longLongValue]];
	}
	if ([strAfterUnixTimeStamp length] == 13) {
		afterDate = [NSDate dateWithTimeIntervalSince1970:[strAfterUnixTimeStamp longLongValue]/1000];
	} else {
		afterDate = [NSDate dateWithTimeIntervalSince1970:[strAfterUnixTimeStamp longLongValue]];
	}
	
	NSCalendar *calendar = [NSCalendar currentCalendar];
	
	NSDateComponents *beforeComp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSWeekdayCalendarUnit fromDate:beforeDate];
	NSInteger beforeYear = [beforeComp year];
	NSInteger beforeMonth = [beforeComp month];
	NSInteger beforeDay = [beforeComp day];
	//	NSInteger beforeHour = [beforeComp hour];
	//	NSInteger beforeMinute = [beforeComp minute];
	//	NSInteger beforeSecond = [beforeComp second];
	//	NSInteger beforeWeekday = [beforeComp weekday];	// N=7 and 1 is Sunday
	
	NSDateComponents *afterComp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSWeekdayCalendarUnit fromDate:afterDate];
	NSInteger afterYear = [afterComp year];
	NSInteger afterMonth = [afterComp month];
	NSInteger afterDay = [afterComp day];
	//	NSInteger afterHour = [afterComp hour];
	//	NSInteger afterMinute = [afterComp minute];
	//	NSInteger afterSecond = [afterComp second];
	NSInteger afterWeekday = [afterComp weekday];	// N=7 and 1 is Sunday
	
	BOOL isDiffferent = NO;
	if (beforeYear < afterYear) {
		isDiffferent = YES;
	} else {
		if (beforeMonth < afterMonth) {
			isDiffferent = YES;
		} else {
			if (beforeDay < afterDay) {
				isDiffferent = YES;
			}
		}
	}
	
	NSString *generateDate = nil;
	
	if (isDiffferent == YES) {
		if (afterWeekday == 1) {
			generateDate = [NSString stringWithFormat:@"%i년 %i월 %i일 일요일", afterYear, afterMonth, afterDay];
		} else if (afterWeekday == 2) {
			generateDate = [NSString stringWithFormat:@"%i년 %i월 %i일 월요일", afterYear, afterMonth, afterDay];
		} else if (afterWeekday == 3) {
			generateDate = [NSString stringWithFormat:@"%i년 %i월 %i일 화요일", afterYear, afterMonth, afterDay];
		} else if (afterWeekday == 4) {
			generateDate = [NSString stringWithFormat:@"%i년 %i월 %i일 수요일", afterYear, afterMonth, afterDay];
		} else if (afterWeekday == 5) {
			generateDate = [NSString stringWithFormat:@"%i년 %i월 %i일 목요일", afterYear, afterMonth, afterDay];
		} else if (afterWeekday == 6) {
			generateDate = [NSString stringWithFormat:@"%i년 %i월 %i일 금요일", afterYear, afterMonth, afterDay];
		} else if (afterWeekday == 7) {
			generateDate = [NSString stringWithFormat:@"%i년 %i월 %i일 토요일", afterYear, afterMonth, afterDay];
		} else {
			// error
			return nil;
		}
	}
	
	return generateDate;
}

// 대화창에서 사용하는 시간
-(NSString*)currentDateUseMsg
{
	NSDate *currentDate = [NSDate date];
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *currentComp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSWeekdayCalendarUnit fromDate:currentDate];
	NSInteger currentYear = [currentComp year];
	NSInteger currentMonth = [currentComp month];
	NSInteger currentDay = [currentComp day];
	//	NSInteger currentHour = [currentComp hour];
	//	NSInteger currentMinute = [currentComp minute];
	//	NSInteger currentSecond = [currentComp second];
	NSInteger currentWeekday = [currentComp weekday];	// N=7 and 1 is Sunday
	
	NSString *generateDate = nil;
	
	if (currentWeekday == 1) {
		generateDate = [NSString stringWithFormat:@"%i년 %i월 %i일 일요일", currentYear, currentMonth, currentDay];
	} else if (currentWeekday == 2) {
		generateDate = [NSString stringWithFormat:@"%i년 %i월 %i일 월요일", currentYear, currentMonth, currentDay];
	} else if (currentWeekday == 3) {
		generateDate = [NSString stringWithFormat:@"%i년 %i월 %i일 화요일", currentYear, currentMonth, currentDay];
	} else if (currentWeekday == 4) {
		generateDate = [NSString stringWithFormat:@"%i년 %i월 %i일 수요일", currentYear, currentMonth, currentDay];
	} else if (currentWeekday == 5) {
		generateDate = [NSString stringWithFormat:@"%i년 %i월 %i일 목요일", currentYear, currentMonth, currentDay];
	} else if (currentWeekday == 6) {
		generateDate = [NSString stringWithFormat:@"%i년 %i월 %i일 금요일", currentYear, currentMonth, currentDay];
	} else if (currentWeekday == 7) {
		generateDate = [NSString stringWithFormat:@"%i년 %i월 %i일 토요일", currentYear, currentMonth, currentDay];
	} else {
		// error
		return nil;
	}
	
	return generateDate;
}

-(NSString*)dateUseMsgFromUnixTimeStamp:(NSString*)unixtimestamp
{
	if (unixtimestamp == nil || [unixtimestamp length] == 0) {
		return nil;
	}
	NSDate *date = nil;
	if ([unixtimestamp length] == 13) {
		date = [NSDate dateWithTimeIntervalSince1970:[unixtimestamp longLongValue]/1000];
	} else {
		date = [NSDate dateWithTimeIntervalSince1970:[unixtimestamp longLongValue]];
	}
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *comp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSWeekdayCalendarUnit fromDate:date];
	NSInteger year = [comp year];
	NSInteger month = [comp month];
	NSInteger day = [comp day];
	//	NSInteger hour = [comp hour];
	//	NSInteger minute = [comp minute];
	//	NSInteger second = [comp second];
	NSInteger weekday = [comp weekday];	// N=7 and 1 is Sunday	
	
	NSString *generateDate = nil;
	
	if (weekday == 1) {
		generateDate = [NSString stringWithFormat:@"%i년 %i월 %i일 일요일", year, month, day];
	} else if (weekday == 2) {
		generateDate = [NSString stringWithFormat:@"%i년 %i월 %i일 월요일", year, month, day];
	} else if (weekday == 3) {
		generateDate = [NSString stringWithFormat:@"%i년 %i월 %i일 화요일", year, month, day];
	} else if (weekday == 4) {
		generateDate = [NSString stringWithFormat:@"%i년 %i월 %i일 수요일", year, month, day];
	} else if (weekday == 5) {
		generateDate = [NSString stringWithFormat:@"%i년 %i월 %i일 목요일", year, month, day];
	} else if (weekday == 6) {
		generateDate = [NSString stringWithFormat:@"%i년 %i월 %i일 금요일", year, month, day];
	} else if (weekday == 7) {
		generateDate = [NSString stringWithFormat:@"%i년 %i월 %i일 토요일", year, month, day];
	} else {
		// error
		return nil;
	}
	
	return generateDate;
}

#pragma mark -
#pragma mark 대화방 관리 (msgArray)

-(void) reConnect:(NSTimer *)theTimer {
	[theTimer invalidate];
	//	NSLog(@"onSocketDidDisconnect: 재접속 시도 1");
	NSString *improxyAddr = [myInfoDictionary objectForKey:@"proxyhost"];
	NSString *improxyPort = [myInfoDictionary objectForKey:@"proxyport"];
	if (improxyAddr && [improxyAddr length] > 0 && improxyPort && [improxyPort length] > 0) {
		//		NSLog(@"onSocketDidDisconnect: 재접속 시도 2");
		reConnectCount++;
		if([self connect:improxyAddr PORT:[improxyPort intValue]]) {
			//			NSLog(@"onSocketDidDisconnect: 재접속 시도 3 success");
			// success!
		} else {
			//			NSLog(@"onSocketDidDisconnect: 재접속 시도 4 fail 재접속 시도");
			// TODO: 예외처리 필요 (세션연결 실패)
		}
	} else {
		// skip
		//		NSLog(@"onSocketDidDisconnect: 재접속 시도 fail 접속 정보가 없습니다.");
	}
}

#pragma mark -
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0) {		// 취소
		//		NSLog(@"재연결 취소");
		connectionType = -1;
		/* sochae 2010.09.28
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"오프라인" message:@"현재 네트워크 연결이 불가능한 상태입니다.\nUsay의 모든 기능을 이용하기 위해서는 네트워크 연결이 필요합니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		*/
		[JYUtil alertWithType:ALERT_NET_OFFLINE delegate:nil];
		// ~sochae
	} else {					// 재연결하기
		//		NSLog(@"재연결하기");
		reConnectCount = 0;
		[NSTimer scheduledTimerWithTimeInterval:0.5 target:self 
									   selector:@selector(reConnect:) 
									   userInfo:nil repeats:NO];
	}
}

#pragma mark -
#pragma mark AsyncSocketDelegate delegate
// AsyncSocketDelegate
- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
	//	NSLog(@"onSocket:%p willDisconnectWithError:%@", sock, err);
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

// AsyncSocketDelegate
- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
	[myInfoDictionary setObject:@"0" forKey:@"imstatus"];
	//	NSLog(@"onSocketDidDisconnect:%p", sock);
	isConnected = NO;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	if (isLoginfail) {
		// skip
	} else {
		if (!exceptionDisconnect) {
			if (reConnectCount < 3) {
				[NSTimer scheduledTimerWithTimeInterval:3.0 target:self 
											   selector:@selector(reConnect:) 
											   userInfo:nil repeats:NO];
			} else {
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"로그인 실패" message:@"로그인에 실패하였습니다.\n재로그인 하시겠습니까?" delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"재연결하기", nil];
				[alertView show];
				[alertView release];
			}
		} else {
			// skip
		}
	}
}

// AsyncSocketDelegate
- (BOOL)onSocketWillConnect:(AsyncSocket *)sock
{
	//	NSLog(@"onSocketWillConnect:%p", sock);
	
	return TRUE;
}

// AsyncSocketDelegate - OnConnect
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	//	NSLog(@"onSocket:%p didConnectToHost:%@ port:%hu", sock, host, port);
	reConnectCount = 0;
	isConnected = TRUE;
	isLoginfail = NO;
	NSData *newline = [@"\n" dataUsingEncoding:NSASCIIStringEncoding];
	
	// start reading
	[clientAsyncSocket readDataToData:newline withTimeout:-1 tag:0];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self sendLogin];
}

// AsyncSocketDelegate
- (void)onSocket:(AsyncSocket *)sock didReadPartialDataOfLength:(CFIndex)partialLength tag:(long)tag
{
	//	NSLog(@"onSocket:%p didReadPartialDataOfLength: %d", sock, tag);
}

// AsyncSocketDelegate
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	//	NSLog(@"didReadData");
	NSData *byteData = [data subdataWithRange:NSMakeRange(0, [data length])];
	
	/*	Binary Data Programming Guide for Cocoa
	 1)
	 NSString *thePath = @"/u/smith/myFile.txt";
	 NSData *myData = [NSData dataWithContentsOfFile:thePath];
	 2)
	 unsigned char aBuffer[20];
	 NSString *myString = @"Test string.";
	 const char *utfString = [myString UTF8String];
	 NSData *myData = [NSData dataWithBytes: utfString length: strlen(utfString)];
	 [myData getBytes:aBuffer];
	 3) 
	 NSString *myString = @"ABCDEFG";
	 const char *utfString = [myString UTF8String];
	 NSRange range = {2, 4};
	 NSData *data1, *data2;
	 data1 = [NSData dataWithBytes:utfString length:strlen(utfString)];
	 data2 = [data1 subdataWithRange:range];
	 
	 참고
	 char* buffer = nil;
	 buffer = (char*)malloc(packetsize);
	 if(buffer) {
	 [[NSData dataWithBytes:pPacket length:packetsize] getBytes:buffer length:packetsize];
	 TransPacket *transPacket1 = nil;
	 transPacket1 = [[TransPacket alloc] init];
	 if(transPacket1) {
	 NSInteger nRet = [transPacket1 FromStream:buffer BuffSize:packetsize];
	 if (nRet > 0) {
	 ExtStrPacket *recvHead = nil;
	 void *pBodyPacket = nil;
	 recvHead = [[ExtStrPacket alloc] init];
	 if (recvHead) {
	 if ([transPacket1 GetHeadPacketExt:recvHead]) {
	 NSLog(@"recvHead = %@", [recvHead ToString]);
	 NSString *value = nil;
	 if(value = [recvHead LookupString:@"pkey"]) {
	 NSLog(@"pkey = %@", value);
	 }
	 }
	 }
	 if (pBodyPacket = [transPacket1 GetBodyPtr]) {
	 NSLog(@"GetBodyPtr success");
	 NSString *strBodyPacket = [NSString stringWithCString:pBodyPacket encoding:NSASCIIStringEncoding];
	 NSLog(@"strBodyPacket = %@", strBodyPacket);
	 }
	 } else {
	 NSLog(@"FromStream fail");
	 }
	 }
	 } else {
	 NSLog(@"buffer null");
	 }
	 //*/
	//	NSString *msg = [[[NSString alloc] initWithData:byteData encoding:NSUTF8StringEncoding] autorelease];
	//	if([msg length] > 0) {
	//		NSLog(@"onSocket:%p didReadData:%@", sock, msg);
	// msg 사용
	
	if([byteData length] > 0) {
		char* buffer = nil;
		buffer = (char*)malloc([byteData length]);
		if(buffer) {
			[byteData getBytes:buffer length:[byteData length]];
			TransPacket *transPacket = nil;
			transPacket = [[[TransPacket alloc] init] autorelease];
			if(transPacket) {
				NSInteger nRet = [transPacket FromStream:buffer BuffSize:[byteData length]];
				if (nRet > 0) {
					ExtStrPacket *recvHead = nil;
					
					NSLog(@"======> onSocket didReadData byte = %s", buffer);
					
					recvHead = [[[ExtStrPacket alloc] init] autorelease];
					if (recvHead) {
						if ([transPacket GetHeadPacketExt:recvHead]) {
							
							DebugLog(@"======> recvHead = %@", [recvHead ToString]);
							
							NSString *bodyType = nil;
							NSString *rttype = nil;
							NSString *notinoACK = nil;
							
							// mezzo 10.09.15 
							// 전용세션에서 ACK를 요청 할경우 notino가 포함 되어 있으며
							// 포함 되어 있을 경우 받은 notino 값을 ACK 규격으로 전송. 
							if (notinoACK = [recvHead LookupString:@"notino"]) {
								ExtStrPacket *headExtStringPacket = nil;
								headExtStringPacket = [[ExtStrPacket alloc] init];
								if(headExtStringPacket) {
									[headExtStringPacket AddItemString:@"svc" Value:@"notisvr" IsReplace:YES];
									[headExtStringPacket AddItemString:@"notino" Value:notinoACK IsReplace:YES];
								
									TransPacket *transPacket = nil;
									transPacket = [[TransPacket alloc] init];
									
									if(transPacket) {
										if([transPacket SetPacketExtHeadBuffBody:headExtStringPacket Body:nil BodySize:0]) {
											const void *pPacket = [transPacket GetPacketPtr];
											NSUInteger packetsize = (NSUInteger)[transPacket GetPacketSize];
											if(packetsize <= 0) {
												[headExtStringPacket release];
												[transPacket release];
											} else {
												[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
												[clientAsyncSocket writeData:[NSData dataWithBytes:pPacket length:packetsize] withTimeout:5 tag:0];
											}
											[headExtStringPacket release];
											[transPacket release];
										} else {
											[headExtStringPacket release];
											[transPacket release];
										}
									} else {
										[headExtStringPacket release];
									}
								} else {
									[headExtStringPacket release];
								}
							}
							
							if(bodyType = [recvHead LookupString:@"bodytype"]) {
								if ([bodyType isEqualToString:@"0"]) {			// XML
									// skip
								} else if ([bodyType isEqualToString:@"1"]) {	// extended cgi string 
								} else if ([bodyType isEqualToString:@"2"]) {	// cgi string
									// skip
								} else if ([bodyType isEqualToString:@"3"]) {	// binary (compact)
									// skip
								} else if ([bodyType isEqualToString:@"4"]) {	// AES 암호화된 XML body 
									// skip
								} else if ([bodyType isEqualToString:@"5"]) {	// JSON
									void *pBodyPacket = nil;
									pBodyPacket = malloc([transPacket GetBodySize]+1);
									//									assert(pBodyPacket != nil);
									memset(pBodyPacket, 0x00, [transPacket GetBodySize]+1);
									memcpy(pBodyPacket, (const char*)[transPacket GetBodyPtr], [transPacket GetBodySize]);
									if (pBodyPacket) {
										NSLog(@"======> pBodyPacket strlen = %d", strlen(pBodyPacket));
										NSLog(@"======> pBodyPacket GetBodySize = %d", [transPacket GetBodySize]);
										
										NSString *strBodyPacket = [NSString stringWithCString:pBodyPacket encoding:NSUTF8StringEncoding];
										// NSString *strBodyPacket = [NSString stringWithCString:pBodyPacket encoding:NSASCIIStringEncoding];
										// The array must end with a NULL character
										free(pBodyPacket);
										//										assert(strBodyPacket != nil);
										// 1. Create BSJSON parser.
										SBJSON *jsonParser = [[SBJSON alloc] init];
										//										assert(jsonParser != nil);
										// 2. Get the result dictionary from the response string.
										NSDictionary *packetDic = (NSDictionary*)[jsonParser objectWithString:strBodyPacket error:NULL];
										//										assert(packetDic != nil);
										[jsonParser release];
										
										// 3. Show response
										NSString *inform = [packetDic objectForKey:@"inform"];
										NSLog(@"======> inform NOT AES JSON = %@ %@", inform, strBodyPacket);
										
										//										assert(inform != nil);
										if ([inform isEqualToString:@"LOGIN"]) {
											NSString *rtcode = [packetDic objectForKey:@"rtcode"];
											//											assert(rtcode != nil);
											DebugLog(@"[SUN] inform LOGIN rtcode : %@", rtcode);
											if ([rtcode isEqualToString:@"0"]) {			// success
												rttype = [packetDic objectForKey:@"rttype"];
												//												assert(rttype != nil);
												if ([rttype isEqualToString:@"only"]) {
													// skip
												} else if ([rttype isEqualToString:@"map"]) {
													NSDictionary *loginDic = [packetDic objectForKey:@"map"];
													//													assert(loginDic != nil);
													NSString *tupleid = [loginDic objectForKey:@"tupleid"];
													//													NSString *imstatus = [loginDic objectForKey:@"imstatus"];
													NSString *nodeaddr = [loginDic objectForKey:@"nodeaddr"];
													//													NSString *device = [loginDic objectForKey:@"device"];
													//													NSString *svcidx = [loginDic objectForKey:@"svcidx"];
													//													NSString *tmstamp = [loginDic objectForKey:@"tmstamp"];
													[myInfoDictionary setObject:tupleid forKey:@"tupleid"];
													[[NSUserDefaults standardUserDefaults] setObject:tupleid forKey:@"tupleid"];
													[[NSUserDefaults standardUserDefaults] setObject:nodeaddr forKey:@"nodeaddr"];
													
													if ([self isFirstUser]) {	// App 처음 설치 한 사람
														// 전체 동기화
														NSLog(@"처음 사용자 이다.");
														[self goLoading];
														//20101002 추가
													} else {					// 기존 사용자
														// OEM 주소록에서 추가된것 확인 후 goMain 처리
														[startViewController syncOEMAddress];
													}
												} else if ([rttype isEqualToString:@"list"]) {
													// skip
												} else {
												}
											} else if ([rtcode isEqualToString:@"-1200"]) {	// fail
												rttype = [packetDic objectForKey:@"rttype"];
												//												assert(rttype != nil);
												if ([rttype isEqualToString:@"only"]) {
													// skip
												} else if ([rttype isEqualToString:@"map"]) {
													// skip
												} else if ([rttype isEqualToString:@"list"]) {
													// skip
												} else {
												}
												// TODO: LOGIN 로긴 실패 예외 처리
											} else if ([rtcode isEqualToString:@"1201"]) {	// 중복 로그인
												rttype = [packetDic objectForKey:@"rttype"];
												//												assert(rttype != nil);
												if ([rttype isEqualToString:@"only"]) {
													// skip
												} else if ([rttype isEqualToString:@"map"]) {
													// skip
												} else if ([rttype isEqualToString:@"list"]) {
													NSArray *listArray = [packetDic objectForKey:@"list"];
													//													assert(listArray != nil);
													for (int i=0; i < [listArray count]; i++) {
														//														NSDictionary *listDic = [listArray objectAtIndex:i];
														//														assert(listDic != nil);
														//														NSString *tupleid = [listDic objectForKey:@"tupleid"];
														//														NSString *imstatus = [listDic objectForKey:@"imstatus"];
														//														NSString *nodeaddr = [listDic objectForKey:@"nodeaddr"];
														//														NSString *device = [listDic objectForKey:@"device"];
														//														NSString *svcidx = [listDic objectForKey:@"svcidx"];
														//														NSString *tmstamp = [listDic objectForKey:@"tmstamp"];
													}
													
												} else {
												}
											} else {
												// TODO: LOGIN 예외처리
												//												NSLog(@"inform LOGIN error rtcode = %@", rtcode);
											}
										} 
										else if ([inform isEqualToString:@"UPDATE_PRESENCE"]) {
											NSString *rtcode = [packetDic objectForKey:@"rtcode"];
											//											assert(rtcode != nil);
											DebugLog(@"[SUN] inform UPDATE_PRESENCE rtcode : %@", rtcode);
											if ([rtcode isEqualToString:@"0"]) {			// success
												rttype = [packetDic objectForKey:@"rttype"];
												//												assert(rttype != nil);
												if ([rttype isEqualToString:@"only"]) {
													// skip
												} else if ([rttype isEqualToString:@"map"]) {
													NSDictionary *loginDic = [packetDic objectForKey:@"map"];
													//													assert(loginDic != nil);
													//													NSString *tupleid = [loginDic objectForKey:@"tupleid"];
													NSString *imstatus = [loginDic objectForKey:@"imstatus"];
													if (imstatus && [imstatus length] > 0) {
														[myInfoDictionary setObject:imstatus forKey:@"imstatus"];
														[[NSNotificationCenter defaultCenter] postNotificationName:@"completeImStatus" object:imstatus];
													} else {
														[[NSNotificationCenter defaultCenter] postNotificationName:@"completeImStatus" object:nil];
													}
												} else if ([rttype isEqualToString:@"list"]) {
													// skip
													[[NSNotificationCenter defaultCenter] postNotificationName:@"completeImStatus" object:nil];
												} else {
													[[NSNotificationCenter defaultCenter] postNotificationName:@"completeImStatus" object:nil];
												}
											} else {
												// TODO: UPDATE_PRESENCE 예외처리
												[[NSNotificationCenter defaultCenter] postNotificationName:@"completeImStatus" object:nil];
												//												NSLog(@"inform UPDATE_PRESENCE error rtcode = %@", rtcode);
											}
										} 
										else if ([inform isEqualToString:@"GET_ONBUDDY_STATUS"]) {
											NSString *rtcode = [packetDic objectForKey:@"rtcode"];
											//											assert(rtcode != nil);
											if ([rtcode isEqualToString:@"0"]) {			// success
												rttype = [packetDic objectForKey:@"rttype"];
												//												assert(rttype != nil);
												if ([rttype isEqualToString:@"only"]) {
													// skip
													[[NSNotificationCenter defaultCenter] postNotificationName:@"getBuddyImstatus" object:nil];
												} else if ([rttype isEqualToString:@"map"]) {
													NSDictionary *loginDic = [packetDic objectForKey:@"map"];
													//													assert(loginDic != nil);
													NSString *pkey = [loginDic objectForKey:@"pkey"];						// 친구 pkey
													NSString *imstatus = [loginDic objectForKey:@"imstatus"];				// 0:offline  1:online  2:busy (바빠요)  8:곧 돌아옵니다.  16:다른용무중
													//													NSString *status = [loginDic objectForKey:@"status"];					// 오늘의 한마디
													//													NSString *representphoto = [loginDic objectForKey:@"representphoto"];
													if (pkey && [pkey length] > 0 && imstatus && [imstatus length] > 0) {
														if (imStatusDictionary) {
															[imStatusDictionary setObject:imstatus forKey:pkey];
														}
													}
													NSArray* imstatusArray = [NSArray arrayWithObject:loginDic];
													[[NSNotificationCenter defaultCenter] postNotificationName:@"getBuddyImstatus" object:imstatusArray];
												} else if ([rttype isEqualToString:@"list"]) {
													NSArray *listArray = [packetDic objectForKey:@"list"];
													//													assert(listArray != nil);
													for (int i=0; i < [listArray count]; i++) {
														NSDictionary *listDic = [listArray objectAtIndex:i];
														//														assert(listDic != nil);
														NSString *pkey = [listDic objectForKey:@"pkey"];						// 친구 pkey
														NSString *imstatus = [listDic objectForKey:@"imstatus"];				// 0:offline  1:online  2:busy (바빠요)  8:곧 돌아옵니다.  16:다른용무중
														//														NSString *status = [listDic objectForKey:@"status"];					// 오늘의 한마디
														//														NSString *representphoto = [listDic objectForKey:@"representphoto"];	// 대표사진 url
														
														if (pkey != nil && [pkey length] > 0) {
															NSArray *checkDBUserInfo = [UserInfo findWithSqlWithParameters:@"select * from _TUserInfo where RPKEY=? and ISFRIEND=?", pkey, @"S", nil];
															if (checkDBUserInfo && [checkDBUserInfo count] > 0) {
																if (imstatus && [imstatus length] > 0) {
																	if (imStatusDictionary) {
																		[imStatusDictionary setObject:imstatus forKey:pkey];
																	}
																}
															}
														}
													}
													[[NSNotificationCenter defaultCenter] postNotificationName:@"getBuddyImstatus" object:listArray];
												} else {
												}
												
											} else {
												// TODO: GET_ONBUDDY_STATUS 예외처리
												//												NSLog(@"inform GET_ONBUDDY_STATUS error rtcode = %@", rtcode);
											}
										} 
										else if ([inform isEqualToString:@"NOTI_KICK"]) {
											NSData *newline = [@"\n" dataUsingEncoding:NSASCIIStringEncoding];
											[clientAsyncSocket readDataToData:newline withTimeout:-1 tag:0];
											NSString *rtcode = [packetDic objectForKey:@"rtcode"];
											//											assert(rtcode != nil);
											if ([rtcode isEqualToString:@"1210"]) {			// success
												rttype = [packetDic objectForKey:@"rttype"];
												//												assert(rttype != nil);
												if ([rttype isEqualToString:@"only"]) {
													// skip
												} else if ([rttype isEqualToString:@"map"]) {
													// skip
												} else if ([rttype isEqualToString:@"list"]) {
													// skip
												} else {
												}
												// TODO: NOTI_KICK 강제 접속 종료 처리
											} else {
												// TODO: NOTI_KICK 예외처리
												//												NSLog(@"inform NOTI_KICK error rtcode = %@", rtcode);
											}
										} 
										else if ([inform isEqualToString:@"NOTI_CHAT_ENTER"]) {		// 멀티 대화시 대화방 입장 알림
											NSData *newline = [@"\n" dataUsingEncoding:NSASCIIStringEncoding];
											[clientAsyncSocket readDataToData:newline withTimeout:-1 tag:0];
											NSString *rtcode = [packetDic objectForKey:@"rtcode"];
											//											assert(rtcode != nil);
											if ([rtcode isEqualToString:@"0"]) {			// success
												rttype = [packetDic objectForKey:@"rttype"];
												//												assert(rttype != nil);
												
												if ([rttype isEqualToString:@"only"]) {
													// skip
												} else if ([rttype isEqualToString:@"map"]) {
													NSDictionary *loginDic = [packetDic objectForKey:@"map"];
													//													assert(loginDic != nil);
													NSString *chatsession = [loginDic objectForKey:@"sessionKey"];
													//													NSString *pkey = [loginDic objectForKey:@"senderPkey"];
													//													NSString *nickname = [loginDic objectForKey:@"senderName"];
													//													NSString *imgurl = [loginDic objectForKey:@"representPhoto"];
													NSString *lastUpdateTime = [loginDic objectForKey:@"createTime"];
													NSNumber *lastUpdateTimeNumber = [NSNumber numberWithLongLong:[lastUpdateTime longLongValue]];
													
													if (chatsession && [chatsession length] > 0) {
														NSArray *checkDBMsgListArray = [RoomInfo findWithSqlWithParameters:@"select * from _TRoomInfo where CHATSESSION=?", chatsession, nil];
														if (checkDBMsgListArray && [checkDBMsgListArray count] > 0) {
															NSNumber *savedLastUpdateTimeNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastUpdateTime"];
															if (savedLastUpdateTimeNumber) {
																if ([savedLastUpdateTimeNumber longLongValue] <= [lastUpdateTimeNumber longLongValue]) {
																	[[NSUserDefaults standardUserDefaults] setObject:lastUpdateTimeNumber forKey:@"lastUpdateTime"];
																} else {
																	// skip
																	lastUpdateTimeNumber = savedLastUpdateTimeNumber;
																}
															} else {
																[[NSUserDefaults standardUserDefaults] setObject:lastUpdateTimeNumber forKey:@"lastUpdateTime"];
															}
															
															NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
															//															assert(bodyObject != nil);
															[bodyObject setObject:chatsession forKey:@"sessionKey"];
															[bodyObject setObject:[self getSvcIdx] forKey:@"svcidx"];
															
															NSArray *checkDBRoomInfoArray = [RoomInfo findWithSqlWithParameters:@"select * from _TRoomInfo where CHATSESSION=?", chatsession, nil];
															if (checkDBRoomInfoArray && [checkDBRoomInfoArray count] > 0) {
																
																[RoomInfo findWithSqlWithParameters:@"update _TRoomInfo set LASTUPDATETIME=? where CHATSESSION=?", lastUpdateTimeNumber, chatsession, nil];
																
																NSNumber *lastSessionUpdateTimeNumber = nil;
																for (RoomInfo *roomInfo in checkDBRoomInfoArray) {
																	lastSessionUpdateTimeNumber = roomInfo.LASTUPDATETIME;
																}
																if (lastSessionUpdateTimeNumber) {
																	[bodyObject setObject:[NSString stringWithFormat:@"%llu",[lastSessionUpdateTimeNumber longLongValue]] forKey:@"lastUpdateTime"];
																} else {
																	// skip
																}
															} else {
																// skip
															}
															
															// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
															USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"getChatParticipants" andWithDictionary:bodyObject timeout:10] autorelease];
															//															assert(data != nil);
															data.subApi = @"NOTI_CHAT_ENTER";
															[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
														}
													}
													
													/*													
													 NSNumber *savedLastUpdateTimeNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastUpdateTime"];
													 if (savedLastUpdateTimeNumber) {
													 if ([savedLastUpdateTimeNumber longLongValue] <= [lastUpdateTimeNumber longLongValue]) {
													 [[NSUserDefaults standardUserDefaults] setObject:lastUpdateTimeNumber forKey:@"lastUpdateTime"];
													 } else {
													 // skip
													 lastUpdateTimeNumber = savedLastUpdateTimeNumber;
													 }
													 } else {
													 [[NSUserDefaults standardUserDefaults] setObject:lastUpdateTimeNumber forKey:@"lastUpdateTime"];
													 }
													 NSString *lastMessageKey = nil;
													 
													 if (chatsession && [chatsession length] > 0 && pkey && [pkey length] > 0) {
													 // DB 추가
													 NSArray *checkDBMsgListArray = [RoomInfo findWithSqlWithParameters:@"select * from _TRoomInfo where CHATSESSION=?", chatsession, nil];
													 if (checkDBMsgListArray && [checkDBMsgListArray count] > 0) {
													 NSArray *checkDBUserInfo = [UserInfo findWithSqlWithParameters:@"select * from _TUserInfo where RPKEY=?", pkey, nil];
													 if (checkDBUserInfo && [checkDBUserInfo count] > 0) {
													 for (UserInfo *userInfo in checkDBUserInfo) {
													 if (userInfo.FORMATTED && [userInfo.FORMATTED length] > 0) {
													 nickname = userInfo.FORMATTED;
													 } else if (userInfo.PROFILENICKNAME && [userInfo.PROFILENICKNAME length] > 0) {
													 nickname = userInfo.PROFILENICKNAME;
													 } else {
													 if (nickname && [nickname length] > 0) {
													 // 서버에서 내려온 nickname 사용
													 } else {
													 nickname = @"이름 없음";
													 }
													 }
													 }
													 } else {
													 if (nickname && [nickname length] > 0) {
													 // 서버에서 내려온 nickname 사용
													 } else {
													 nickname = @"이름 없음";
													 }
													 }
													 
													 [RoomInfo findWithSqlWithParameters:@"update _TRoomInfo set LASTUPDATETIME=? where CHATSESSION=?", lastUpdateTimeNumber, chatsession, nil];
													 
													 NSArray *checkDBMessageUserInfoArray = [MessageUserInfo findWithSqlWithParameters:@"select * from _TMessageUserInfo where CHATSESSION=? and PKEY=?", 
													 chatsession, pkey, nil];
													 if (checkDBMessageUserInfoArray && [checkDBMessageUserInfoArray count] > 0) {
													 // update
													 [MessageUserInfo findWithSqlWithParameters:@"update _TMessageUserInfo set NICKNAME=?, PHOTOURL=? where CHATSESSION=? and PKEY=?", 
													 nickname, imgurl, chatsession, pkey, nil];
													 } else {
													 // insert
													 [MessageUserInfo findWithSqlWithParameters:@"insert into _TMessageUserInfo(CHATSESSION, PKEY, NICKNAME, PHOTOURL) values(?,?,?,?)", 
													 chatsession, pkey, nickname, imgurl, nil];
													 }
													 
													 // 메모리 추가
													 @synchronized(msgListArray) {
													 if (msgListArray && [msgListArray count] > 0) {
													 for (CellMsgListData *msgListData in msgListArray) {
													 if ([msgListData.chatsession isEqualToString:chatsession]) {
													 msgListData.lastUpdateTime = lastUpdateTimeNumber;
													 if (msgListData.userDataDic) {
													 MsgUserData *userData = [msgListData.userDataDic objectForKey:pkey];
													 if (userData) {	// 수정
													 userData.pKey = pkey;
													 userData.nickName = nickname;
													 userData.photoUrl = imgurl;
													 break;
													 } else {	// 추가
													 MsgUserData *newUserData = [[MsgUserData alloc] init];
													 if (newUserData) {
													 newUserData.pKey = pkey;
													 newUserData.nickName = nickname;
													 newUserData.photoUrl = imgurl;
													 
													 [msgListData.userDataDic setObject:newUserData forKey:pkey];
													 break;
													 } else {
													 // error
													 }
													 }
													 break;
													 } else {
													 // skip
													 }
													 break;
													 }
													 }
													 } else {
													 // error
													 }
													 }
													 
													 [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadMsgList" object:nil];
													 
													 // open 된 채팅방 확인후 retrieveSessionMessage 발송
													 // TODO : NOTI_CHAT_RECORD open된 메시지 창과 chatsessionkey 과 동일하면 retrieveSessionMessage 요청
													 NSString *openChatSession = [self.myInfoDictionary objectForKey:@"openChatSession"];
													 
													 if ([openChatSession isEqualToString:chatsession]) {
													 NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
													 assert(bodyObject != nil);
													 [bodyObject setObject:chatsession forKey:@"sessionKey"];
													 [bodyObject setObject:[self getSvcIdx] forKey:@"svcidx"];
													 if (lastMessageKey && [lastMessageKey length] > 0) {
													 [bodyObject setObject:lastMessageKey forKey:@"lastMessageKey"];
													 } else {
													 // skip
													 }
													 
													 // 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
													 USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"retrieveSessionMessage" andWithDictionary:bodyObject timeout:10] autorelease];
													 assert(data != nil);
													 [[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
													 
													 } else {
													 // 알람은 없어도 됨.
													 }
													 }
													 }
													 //*/
												} else if ([rttype isEqualToString:@"list"]) {
													// skip
												} else {
												}
												
												/*												// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
												 NSMutableDictionary *bodyObject = [[NSMutableDictionary alloc] init];
												 assert(bodyObject != nil);
												 [bodyObject setObject:[self getSvcIdx] forKey:@"svcidx"];
												 NSNumber *lastUpdateTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastUpdateTime"];
												 if (lastUpdateTime) {
												 if ([lastUpdateTime longLongValue] < 0) {
												 [bodyObject setObject:[NSString stringWithFormat:@"%llu",[lastUpdateTime longLongValue]*-1] forKey:@"lastUpdateTime"];
												 } else {
												 [bodyObject setObject:[NSString stringWithFormat:@"%llu",[lastUpdateTime longLongValue]] forKey:@"lastUpdateTime"];
												 }
												 } else {
												 // skip
												 }
												 USayHttpData *data = [[USayHttpData alloc] initWithRequestData:@"retrieveSystemMessage" andWithDictionary:bodyObject timeout:10];
												 assert(data != nil);
												 [[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
												 //*/											
											} else {
												// TODO: NOTI_CHAT_ENTER 예외처리
											}
										} 
										else if ([inform isEqualToString:@"NOTI_CHAT_EXIT"]) {	// 멀티 대화시 상대방 퇴장 메시지
											NSData *newline = [@"\n" dataUsingEncoding:NSASCIIStringEncoding];
											[clientAsyncSocket readDataToData:newline withTimeout:-1 tag:0];
											NSString *rtcode = [packetDic objectForKey:@"rtcode"];
											//											assert(rtcode != nil);
											if ([rtcode isEqualToString:@"0"]) {			// success
												rttype = [packetDic objectForKey:@"rttype"];
												//												assert(rttype != nil);
												if ([rttype isEqualToString:@"only"]) {
													// skip
												} else if ([rttype isEqualToString:@"map"]) {
													NSDictionary *loginDic = [packetDic objectForKey:@"map"];
													//													assert(loginDic != nil);
													NSString *chatSessionkey = [loginDic objectForKey:@"chatSessionkey"];
													NSString *pkey = [loginDic objectForKey:@"senderPkey"];
													//													NSString *lastUpdateTime = [loginDic objectForKey:@"lastUpdateTime"];
													//													NSNumber *lastUpdateTimeNumber = [NSNumber numberWithLongLong:[lastUpdateTime longLongValue]];
													//													NSNumber *savedLastUpdateTimeNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastUpdateTime"];
													//													if (savedLastUpdateTimeNumber) {
													//														if ([savedLastUpdateTimeNumber longLongValue] <= [lastUpdateTimeNumber longLongValue]) {
													//															[[NSUserDefaults standardUserDefaults] setObject:lastUpdateTimeNumber forKey:@"lastUpdateTime"];
													//														} else {
													//															// skip
													//															lastUpdateTimeNumber = savedLastUpdateTimeNumber;
													//														}
													//													} else {
													//														[[NSUserDefaults standardUserDefaults] setObject:lastUpdateTimeNumber forKey:@"lastUpdateTime"];
													//													}
													
													if (chatSessionkey && [chatSessionkey length] > 0 && pkey && [pkey length] > 0) {
														/* 
														 // DB 에서 나간 사람 삭제
														 NSArray *checkDBMsgListArray = [RoomInfo findWithSqlWithParameters:@"select * from _TRoomInfo where CHATSESSION=?", chatSessionkey, nil];
														 if (checkDBMsgListArray && [checkDBMsgListArray count] > 0) {
														 [RoomInfo findWithSqlWithParameters:@"update _TRoomInfo set LASTUPDATETIME=? where CHATSESSION=?", lastUpdateTimeNumber, chatSessionkey, nil];
														 
														 NSArray *checkDBMessageUserInfoArray = [MessageUserInfo findWithSqlWithParameters:@"select * from _TMessageUserInfo where CHATSESSION=? and PKEY=?", 
														 chatSessionkey, pkey, nil];
														 if (checkDBMessageUserInfoArray && [checkDBMessageUserInfoArray count] > 0) {
														 // delete
														 [MessageUserInfo findWithSqlWithParameters:@"delete from _TMessageUserInfo where CHATSESSION=? and PKEY=?", 
														 chatSessionkey, pkey, nil];
														 } else {
														 // skip
														 }
														 }
														 
														 // 대화방에서 나간 유저 메모리에서 제거
														 @synchronized(msgListArray) {
														 if (msgListArray && [msgListArray count] > 0) {
														 for (CellMsgListData *msgListData in msgListArray) {
														 if ([msgListData.chatsession isEqualToString:chatSessionkey]) {
														 msgListData.lastUpdateTime = lastUpdateTimeNumber;
														 if (msgListData.userDataDic) {
														 MsgUserData *userData = [msgListData.userDataDic objectForKey:pkey];
														 if (userData) {	// 삭제
														 [msgListData.userDataDic removeObjectForKey:pkey];
														 } else {	
														 // skip
														 }
														 break;
														 } else {
														 // skip
														 }
														 break;
														 }
														 }
														 } else {
														 // error
														 }
														 }
														 //*/														
														// open 된 채팅방 확인후 retrieveSessionMessage 발송
														// TODO : NOTI_CHAT_RECORD open된 메시지 창과 chatsessionkey 과 동일하면 retrieveSessionMessage 요청														
														NSString *openChatSession = [self.myInfoDictionary objectForKey:@"openChatSession"];
														
														if ([openChatSession isEqualToString:chatSessionkey]) {
															NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
															//															assert(bodyObject != nil);
															[bodyObject setObject:chatSessionkey forKey:@"sessionKey"];
															[bodyObject setObject:[self getSvcIdx] forKey:@"svcidx"];
															CellMsgListData *msgListData = [self MsgListDataFromChatSession:chatSessionkey];
															if (msgListData) {
																if (msgListData.lastmessagekey && [msgListData.lastmessagekey length] > 0) {
																	[bodyObject setObject:msgListData.lastmessagekey forKey:@"lastMessageKey"];
																} else {
																	// skip
																}
															}
															// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
															USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"retrieveSessionMessage" andWithDictionary:bodyObject timeout:10] autorelease];
															//															assert(data != nil);
															[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
															
														} else {
															// 알림은 없어도 됨.
														}
													}
												} else if ([rttype isEqualToString:@"list"]) {
													// skip	
												} else {
													// skip
												}
												
											} else {
												// TODO: NOTI_CHAT_EXIT 예외처리
											}
										}
										else if ([inform isEqualToString:@"NOTI_CHAT_RECORD"]) {		// 대화 시 새로운 대화 글 등록 알림 (상대방이 새로운 대화를 보냈을 경우)
											DebugLog(@"=====> 새로운 대화 수신.");
											NSData *newline = [@"\n" dataUsingEncoding:NSASCIIStringEncoding];
											[clientAsyncSocket readDataToData:newline withTimeout:-1 tag:0];
											NSString *rtcode = [packetDic objectForKey:@"rtcode"];
											//											assert(rtcode != nil);
											if ([rtcode isEqualToString:@"0"]) {			// success
												rttype = [packetDic objectForKey:@"rttype"];
												//												assert(rttype != nil);
												if ([rttype isEqualToString:@"only"]) {
													// skip
												} else if ([rttype isEqualToString:@"map"]) {
													NSDictionary *loginDic = [packetDic objectForKey:@"map"];
													//													assert(loginDic != nil);
													NSString *chatsessionkey = [loginDic objectForKey:@"chatSessionkey"];
													NSString *message = [loginDic objectForKey:@"message"];
													//													NSString *nickName = [loginDic objectForKey:@"senderName"];
													NSString *messageType = [loginDic objectForKey:@"messageType"];
													NSString *createTime = [loginDic objectForKey:@"createTime"];						// unix timestamp 13자리
													NSString *openChatSession = [self.myInfoDictionary objectForKey:@"openChatSession"];
													
													NSLog(@"======chatsessionkey 12 : %@", chatsessionkey);
													NSLog(@"======message 12 : %@", message);
													NSLog(@"======messageType 12 : %@", messageType);
													NSLog(@"======createTime 12 : %@", createTime);
													NSLog(@"======openChatSession 12 : %@", openChatSession);
													
													if (chatsessionkey != nil && [chatsessionkey length] > 0 ) {
														if (message != nil && [message length] > 0 && createTime && [createTime length] > 0) {
															if (messageType != nil && [messageType length] > 0) {
																NSNumber *createTimeNumber = [NSNumber numberWithLongLong:[createTime longLongValue]];
																NSArray *checkDBMsgListArray = [RoomInfo findWithSqlWithParameters:@"select * from _TRoomInfo where CHATSESSION=?", chatsessionkey, nil];
																NSString* lastMessageKey = nil;
																if (checkDBMsgListArray && [checkDBMsgListArray count] > 0) {
																	// update
																	// 대화리스트 DB 추가
																	//*
																	int newCount = 0;
																	for (RoomInfo *roomInfo in checkDBMsgListArray) {
																		newCount = [roomInfo.NEWMSGCOUNT intValue];
																		lastMessageKey = roomInfo.LASTMESSAGEKEY;
																	}
																	if (openChatSession && [openChatSession length] > 0) {
																		if ([openChatSession isEqualToString:chatsessionkey]) {
																			if (newCount >= 1) {
																				newCount -= 1;
																			} else {
																				newCount = 0;
																			}
																		} else {
																			if (newCount >= 0) {
																				newCount += 1;
																			} else {
																				newCount = 1;
																			}
																		}
																	} else {
																		if (newCount >= 0) {
																			newCount += 1;
																		} else {
																			newCount = 1;
																		}
																	}
																	//*/
																	// mezzo 10.09.14 DB에 직접 입력 하는 부분을 retrieveSystemMessage 요청 하도록 변경
																	[RoomInfo findWithSqlWithParameters:@"update _TRoomInfo set LASTMSG=?, LASTMSGTYPE=?, LASTMSGDATE=?, NEWMSGCOUNT=? where CHATSESSION=?", 
																	 message, messageType, createTimeNumber, [NSNumber numberWithInt:newCount], chatsessionkey, nil];
																	/*
																	NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
																	//																	assert(bodyObject != nil);
																	[bodyObject setObject:[self getSvcIdx] forKey:@"svcidx"];
																	NSNumber *lastUpdateTimeNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastUpdateTime"];
																	if (lastUpdateTimeNumber) {
																		[bodyObject setObject:[NSString stringWithFormat:@"%llu",[lastUpdateTimeNumber longLongValue]] forKey:@"lastSessionUpdateTime"];
																	} else {
																		// skip
																	}		
																	// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
																	USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"retrieveSystemMessage" andWithDictionary:bodyObject timeout:10] autorelease];
																	//																	assert(data != nil);
																	
																	[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
																	//*/
																	 
																} else {
																	// TODO: NOTI_CHAT_RECORD insert 대화상대 구성은 어떻게 해야 하나? ㅡㅡ;
																	// 대화방 추가, 대화친구들 추가 ???
																	NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
																	//																	assert(bodyObject != nil);
																	[bodyObject setObject:[self getSvcIdx] forKey:@"svcidx"];
																	NSNumber *lastUpdateTimeNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastUpdateTime"];
																	if (lastUpdateTimeNumber) {
																		[bodyObject setObject:[NSString stringWithFormat:@"%llu",[lastUpdateTimeNumber longLongValue]] forKey:@"lastSessionUpdateTime"];
																	} else {
																		// skip
																	}		
																	// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
																	USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"retrieveSystemMessage" andWithDictionary:bodyObject timeout:10] autorelease];
																	//																	assert(data != nil);
																	
																	[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
																	return;
																}
																// 대화리스트 메모리 변경
																if (self.msgListArray && [msgListArray count] > 0) {
																	for (CellMsgListData *msgListData in msgListArray) {
																		if ([msgListData.chatsession isEqualToString:chatsessionkey]) {
																			msgListData.lastMsg = message;
																			msgListData.lastMsgDate = [NSString stringWithFormat:@"%llu", [createTimeNumber longLongValue]];
																			msgListData.lastMsgType = messageType;
																			if (openChatSession && [openChatSession length] > 0) {
																				if ([openChatSession isEqualToString:chatsessionkey]) {
																					if (msgListData.newMsgCount >= 1) {
																						msgListData.newMsgCount -=1;
																					} else {
																						msgListData.newMsgCount = 0;
																					}
																				} else {
																					msgListData.newMsgCount += 1;
																				}
																			} else {
																				msgListData.newMsgCount += 1;
																			}	
																			break;
																		}
																	}
																	//																	for (CellMsgListData *msgListData1 in msgListArray) {
																	//																		NSLog(@"NOTI_CHAT_RECORD lastMsgDate=%@", msgListData1.lastMsgDate);
																	//																	}
																	NSSortDescriptor *lastMsgDateSort = [[NSSortDescriptor alloc] initWithKey:@"lastMsgDate" ascending:NO];
																	[msgListArray sortUsingDescriptors:[NSArray arrayWithObject:lastMsgDateSort]];
																	[lastMsgDateSort release];
																}
																
																// TODO : NOTI_CHAT_RECORD open된 메시지 창과 chatsessionkey 과 동일하면 retrieveSessionMessage 요청
																if ([openChatSession isEqualToString:chatsessionkey]) {
																	NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
																	//																	assert(bodyObject != nil);
																	[bodyObject setObject:chatsessionkey forKey:@"sessionKey"];
																	[bodyObject setObject:[self getSvcIdx] forKey:@"svcidx"];
																	if (lastMessageKey && [lastMessageKey length] > 0) {
																		[bodyObject setObject:lastMessageKey forKey:@"lastMessageKey"];
																	} else {
																		// skip
																	}
																	
																	// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
																	USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"retrieveSessionMessage" andWithDictionary:bodyObject timeout:10] autorelease];
																	//																	assert(data != nil);
																	[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
																} else {
																	// DB에서 읽어서 Badge표기
																	NSInteger nNewMsgCount = [self newMessageCount];
																	if (nNewMsgCount == 0) {
																		UITabBarItem *tbi = [rootController.tabBar.items objectAtIndex:2]; //기존 1->2로
																		if (tbi) {
																			tbi.badgeValue = nil;
																		}
																		[[UIApplication sharedApplication] setApplicationIconBadgeNumber:nNewMsgCount];
																		NSLog(@"======badgeValue 12 : %d", nNewMsgCount);
																	} else if (nNewMsgCount > 0) {
																		UITabBarItem *tbi = [rootController.tabBar.items objectAtIndex:2]; //기존 1->2로
																		if (tbi) {
																			tbi.badgeValue = [NSString stringWithFormat:@"%i", nNewMsgCount];
																		}
																		[[UIApplication sharedApplication] setApplicationIconBadgeNumber:nNewMsgCount];
																		
																		NSLog(@"======badgeValue 11 : %d", nNewMsgCount);
																	} else {
																		
																	}
																	[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadMsgList" object:nil];
																	[self playSystemSoundIDSound];
																	[self playSystemSoundIDVibrate];
																}
															}
														}
													}
												} else if ([rttype isEqualToString:@"list"]) {
													// skip
												} else {
												}
												
												
											} else {
												// TODO: NOTI_CHAT_RECORD 예외처리
											}
										} 
										else if ([inform isEqualToString:@"NOTI_READ_MARK"]) {		// 대화 시 읽음 표시 알림
											NSData *newline = [@"\n" dataUsingEncoding:NSASCIIStringEncoding];
											[clientAsyncSocket readDataToData:newline withTimeout:-1 tag:0];
											NSString *rtcode = [packetDic objectForKey:@"rtcode"];
											//											assert(rtcode != nil);
											if ([rtcode isEqualToString:@"0"]) {			// success
												rttype = [packetDic objectForKey:@"rttype"];
												//												assert(rttype != nil);
												if ([rttype isEqualToString:@"only"]) {
													// skip
												} else if ([rttype isEqualToString:@"map"]) {
													NSDictionary *loginDic = [packetDic objectForKey:@"map"];
													//													assert(loginDic != nil);
													NSString *chatSessionkey = [loginDic objectForKey:@"chatSessionkey"];
													NSString *messageKey = [loginDic objectForKey:@"messageKey"];
													NSString *messageCount = [loginDic objectForKey:@"messageCount"];	// 읽은 카운트수
													//													NSLog(@"chatSessionkey = %@, messageKey = %@ messageCount = %@", chatSessionkey, messageKey, messageCount);
													// TODO: NOTI_READ_MARK 메모리, DB에서 readCount 변경처리 필요
													if (chatSessionkey && [chatSessionkey length] > 0) {
														if (messageKey && [messageKey length] > 0) {
															if (messageCount && [messageCount length] > 0) {
																// DB 변경
																NSInteger count = 0;
																NSInteger serverCount = [messageCount intValue];
																NSArray *messageDBInfo = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where CHATSESSION=? and MESSAGEKEY=?", chatSessionkey, messageKey, nil];
																if (messageDBInfo && [messageDBInfo count] > 0) {
																	for (MessageInfo *messageInfo in messageDBInfo) {
																		NSInteger dbCount = [messageInfo.READMARKCOUNT intValue];
																		if (serverCount > dbCount) {
																			// error
																			return;
																		} else {
																			count = dbCount - serverCount;
																		}
																		if (count < 0) {
																			count = 0;
																		}
																		//																		NSLog(@"count = %i", count);
																		[MessageInfo findWithSqlWithParameters:@"update _TMessageInfo set READMARKCOUNT=? where CHATSESSION=? and MESSAGEKEY=?", [NSNumber numberWithInt:count], chatSessionkey, messageKey, nil];
																	}
																}
																// 메모리 변경
																@synchronized(msgArray) {
																	if (msgArray && [msgArray count] > 0) {
																		for (CellMsgData *msgData in msgArray) {
																			//																			NSLog(@"msgData.chatsession = %@, msgData.messageKey = %@ msgData.readMarkCount = %i", msgData.chatsession, msgData.messagekey, msgData.readMarkCount);
																			if ([msgData.chatsession isEqualToString:chatSessionkey] && [msgData.messagekey isEqualToString:messageKey]) {
																				if (msgData.readMarkCount > 0) {
																					if (serverCount > msgData.readMarkCount) {
																						// error
																						return;
																					} else {
																						msgData.readMarkCount -= serverCount;
																					}
																					if (msgData.readMarkCount < 0) {
																						msgData.readMarkCount = 0;
																					}
																				}
																				break;
																			}
																		}
																	}
																}
																NSString *openChatSession = [self.myInfoDictionary objectForKey:@"openChatSession"];
																
																if ([openChatSession isEqualToString:chatSessionkey]) {
																	[[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadMessage" object:chatSessionkey];
																}
															}
														}
													}
												} else if ([rttype isEqualToString:@"list"]) {
													// skip
												} else {
												}
											} else {
												// TODO: NOTI_READ_MARK 예외처리
											}
										} 
										else if ([inform isEqualToString:@"NOTI_PHOTO_MODIFY"]) {		// 친구 사진 변경 알림
											NSData *newline = [@"\n" dataUsingEncoding:NSASCIIStringEncoding];
											[clientAsyncSocket readDataToData:newline withTimeout:-1 tag:0];
											NSString *rtcode = [packetDic objectForKey:@"rtcode"];
											//											assert(rtcode != nil);
											if ([rtcode isEqualToString:@"0"]) {			// success
												rttype = [packetDic objectForKey:@"rttype"];
												//												assert(rttype != nil);
												if ([rttype isEqualToString:@"only"]) {
													// skip
												} else if ([rttype isEqualToString:@"map"]) {
													//													NSDictionary *loginDic = [packetDic objectForKey:@"map"];
													//													assert(loginDic != nil);
													//													NSString *pkey = [loginDic objectForKey:@"pkey"];
													//													NSString *thumurl = [loginDic objectForKey:@"thumurl"];
													//													NSString *origurl = [loginDic objectForKey:@"origurl"];
												} else if ([rttype isEqualToString:@"list"]) {
													// skip
												} else {
												}
											} else {
												// TODO: NOTI_PHOTO_MODIFY 예외처리
											}
										}
										else if ([inform isEqualToString:@"NOTI_PRESENCE"]) {		// 친구 상태 정보 변경 알림
											NSData *newline = [@"\n" dataUsingEncoding:NSASCIIStringEncoding];
											[clientAsyncSocket readDataToData:newline withTimeout:-1 tag:0];
											NSString *rtcode = [packetDic objectForKey:@"rtcode"];
											//											assert(rtcode != nil);
											if ([rtcode isEqualToString:@"0"]) {			// success
												rttype = [packetDic objectForKey:@"rttype"];
												//												assert(rttype != nil);
												if ([rttype isEqualToString:@"only"]) {
													// skip
												} else if ([rttype isEqualToString:@"map"]) {
													NSDictionary *loginDic = [packetDic objectForKey:@"map"];
													
													
													
													//별명이 바꾸면 업데이트 해야한다.
													if([loginDic objectForKey:@"nickName"])
													{
														DebugLog(@"changed nickname = %@", [loginDic objectForKey:@"nickName"]);
														
														NSString *selectQuery = [NSString stringWithFormat:@"SELECT * FROM _TUserInfo where MOBILEPHONENUMBER isnull and iphonenumber isnull and homephonenumber isnull and orgphonenumber isnull and mainphonenumber isnull and RPKEY='%@'", [loginDic objectForKey:@"senderPkey"]];
													NSArray *tmpArray =	[UserInfo findWithSql:selectQuery];
														
#ifdef MEZZO_DEBUG
														NSLog(@"selectQuery = %@", selectQuery);
#endif
														
														if(tmpArray == nil || tmpArray == NULL || [tmpArray count] <=0)
														{
															NSLog(@"이사용자는 연락처에 등록된 사람이다..");
														}
														else {
															//연락처에 등록된 사람이 아니면 닉네임 업데이트 한다..
															NSString *updateNickName = [NSString stringWithFormat:@"update _TMessageUserInfo set NICKNAME='%@' where PKEY='%@'",[loginDic objectForKey:@"nickName"], [loginDic objectForKey:@"senderPkey"]];
															
#ifdef MEZZO_DEBUG
															NSLog(@"udateNickName = %@", updateNickName);
															
#endif
															[MessageUserInfo findWithSql:updateNickName];
															
															
															NSString *updateNickName2 =[NSString stringWithFormat:@"update _TMessageinfo set NICKNAME='%@' where PKEY = '%@'", [loginDic objectForKey:@"nickName"], [loginDic objectForKey:@"senderPkey"]];
															
															
															
#ifdef MEZZO_DEBUG
															NSLog(@"udateNickName2 = %@", updateNickName2);
															
#endif
															
															
															[MessageInfo findWithSql:updateNickName2];
															
															
															for (CellMsgListData *msgListData in msgListArray) {
																if (msgListData.userDataDic && [msgListData.userDataDic count] > 0) {
																	for (id key in msgListData.userDataDic) {
																		if ([(NSString*)key isEqualToString:[loginDic objectForKey:@"senderPkey"]]) {
																			MsgUserData *userData = [msgListData.userDataDic objectForKey:key];
																			if (userData) {
																				NSLog(@"nick name 벼srud");
																				userData.nickName = [loginDic objectForKey:@"nickName"];
																				
																			}
																		}
																	}
																}
															}
															
															[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadMsgList" object:nil];
															[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadAddressData" object:nil];
															
														}

														
														
													
														
													}
													
													
													
													
													NSLog(@"all key = %@",[loginDic allKeys]);
													//													assert(loginDic != nil);
													NSString *pkey = [loginDic objectForKey:@"senderPkey"];
													NSString *presencestatus = [loginDic objectForKey:@"imstatus"];	// 0:offline  1:online  2:busy (바빠요)  8:곧 돌아옵니다.  16:다른용무중
													NSString *representPhoto = [loginDic objectForKey:@"representPhoto"];
													//													NSLog(@"NOTI_PRESENCE #1");
													if (pkey != nil && [pkey length] > 0) {
														//														NSLog(@"NOTI_PRESENCE #2");
														[[NSNotificationCenter defaultCenter] postNotificationName:@"buddyPresenceChange" object:loginDic];
														
														NSArray *checkDBUserInfo = [UserInfo findWithSqlWithParameters:@"select * from _TUserInfo where RPKEY=? and ISFRIEND=?", pkey, @"S", nil];
														NSLog(@"================DBUSERINFO %@================", checkDBUserInfo);
														if (checkDBUserInfo && [checkDBUserInfo count] > 0) {
															//															NSLog(@"NOTI_PRESENCE #3");
															if (presencestatus != nil && [presencestatus length] > 0) {
																if (imStatusDictionary) {
																	[imStatusDictionary setObject:presencestatus forKey:pkey];
																	[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadAddressData" object:nil];
																}
															}
														}
														//														NSLog(@"NOTI_PRESENCE #4");
														if (representPhoto != nil) {
															//															NSLog(@"NOTI_PRESENCE #5");
															NSArray *checkDBMessageUserInfo = [MessageUserInfo findWithSqlWithParameters:@"select * from _TMessageUserInfo where PKEY=?", pkey, nil];
															if (checkDBMessageUserInfo && [checkDBMessageUserInfo count] > 0) {
																//																NSLog(@"NOTI_PRESENCE #6");
																if (representPhoto && [representPhoto length] > 0) {
																	
																} else {
																	representPhoto = @"";
																}
																//																NSLog(@"NOTI_PRESENCE #7 representPhoto = %@", representPhoto);
																[MessageUserInfo findWithSqlWithParameters:@"update _TMessageUserInfo set PHOTOURL=? where PKEY=?", representPhoto, pkey, nil];
															}
															
															//															@synchronized(msgListArray) {
															if (msgListArray && [msgListArray count] > 0) {
																//																	NSLog(@"NOTI_PRESENCE #8 representPhoto = %@", representPhoto);
																for (CellMsgListData *msgListData in msgListArray) {
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
																					//																						NSLog(@"NOTI_PRESENCE #9 변경 representPhoto = %@", representPhoto);
																					userData.photoUrl = representPhoto;
																					
																				}
																			}
																		}
																	}
																}
																// 대화창 리스트에 notification (테이블 reload 처리)
																NSLog(@"reload ok??");
																[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadMsgList" object:nil];
															}
															//															}
														}
													}
												}
												else if ([rttype isEqualToString:@"list"]) {
													// skip
												} else {
												}
											} else {
												// TODO: NOTI_PRESENCE 예외처리
											}
										} 
										else {
											
										}
									} else {
										// TODO: pBodyPacket이 없음. 예외처리 
									}
								} else if ([bodyType isEqualToString:@"6"]) {	// AES 암호화된 JSON
									void *pBodyPacket = nil;
									pBodyPacket = malloc([transPacket GetBodySize]+1);
									//									assert(pBodyPacket != nil);
									memset(pBodyPacket, 0x00, [transPacket GetBodySize]+1);
									memcpy(pBodyPacket, (const char*)[transPacket GetBodyPtr], [transPacket GetBodySize]);
									//									NSLog(@"[transPacket GetBodySize] = %i", [transPacket GetBodySize]);
									if (pBodyPacket) {
										NSData *data = [NSData dataWithBytes:pBodyPacket length:[transPacket GetBodySize]];
										if (data == nil) {
											return;
										}
										data = [data AESDecryptWithKey:kAESKey InitializationVector:kAESIV]; 
										if (data == nil) {
											return;
										}
										NSString *strBodyPacket = [[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding] autorelease];
										
										// NSString *strBodyPacket = [NSString stringWithCString:pBodyPacket encoding:NSASCIIStringEncoding];
										// The array must end with a NULL character
										free(pBodyPacket);
										//										assert(strBodyPacket != nil);
										
										// 1. Create BSJSON parser.
										SBJSON *jsonParser = [[SBJSON alloc] init];
										//										assert(jsonParser != nil);
										// 2. Get the result dictionary from the response string.
										
										NSDictionary *packetDic = (NSDictionary*)[jsonParser objectWithString:strBodyPacket error:NULL];
										//										assert(packetDic != nil);
										
										[jsonParser release];
										// 3. Show response
										NSString *inform = [packetDic objectForKey:@"inform"];
										//										NSLog(@"inform AES JSON = %@ %@", inform, strBodyPacket);
										//										assert(inform != nil);
										if ([inform isEqualToString:@"LOGIN"]) {
											NSString *rtcode = [packetDic objectForKey:@"rtcode"];
											//											assert(rtcode != nil);
											if ([rtcode isEqualToString:@"0"]) {			// success
												rttype = [packetDic objectForKey:@"rttype"];
												//												assert(rttype != nil);
												if ([rttype isEqualToString:@"only"]) {
													// skip
													//													NSLog(@"inform AES JSON rtype only");
												} else if ([rttype isEqualToString:@"map"]) {
													NSDictionary *loginDic = [packetDic objectForKey:@"map"];
													//													assert(loginDic != nil);
													NSString *tupleid = [loginDic objectForKey:@"tupleid"];
													NSString *imstatus = [loginDic objectForKey:@"imstatus"];
													NSString *nodeaddr = [loginDic objectForKey:@"nodeaddr"];
													//													NSString *device = [loginDic objectForKey:@"device"];
													//													NSString *svcidx = [loginDic objectForKey:@"svcidx"];
													[myInfoDictionary setObject:tupleid forKey:@"tupleid"];
													[[NSUserDefaults standardUserDefaults] setObject:tupleid forKey:@"tupleid"];
													[[NSUserDefaults standardUserDefaults] setObject:nodeaddr forKey:@"nodeaddr"];
													
													if (imstatus && [imstatus length] > 0) {
														[myInfoDictionary setObject:imstatus forKey:@"imstatus"];
													} else {
														[myInfoDictionary setObject:@"1" forKey:@"imstatus"];
													}
													
													// Wi-Fi ===> 3G로 변경되면서 전용세션이 끊겼을때는 로긴 처리만 해준다.
													if (exceptionDisconnect) {
														exceptionDisconnect = NO;
														if(isFirstUser==YES){
															// 전체 동기화 20101002
#ifdef MEZZO_DEBUG
															NSLog(@"================LOGIN============");
#endif

															[self goLoading];
															NSLog(@"처음 사용자 이다.");
															
														}else {
															// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
															//															USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"retrieveSystemMessage" andWithDictionary:bodyObject timeout:10] autorelease];
															//				assert(data != nil);
															//															[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
															
															// OEM 주소록에서 추가된것 확인 후 goMain 처리
															if (startViewController) {
																[startViewController syncOEMAddress];
															}
														}
														
														//	[startViewController syncOEMAddress];
													} else {
														if ([self isFirstUser]) {	// App 처음 설치 한 사람
															// 전체 동기화 20101002
															[self goLoading];
															
														} else {					// 기존 사용자
															// OEM 주소록에서 추가된것 확인 후 goMain 처리
															if (startViewController) {
																[startViewController syncOEMAddress];
															}
														}
													}
												} else if ([rttype isEqualToString:@"list"]) {
													// skip
													//													NSLog(@"inform AES JSON rtype list");
												} else {
													//													NSLog(@"inform AES JSON rtype else %@",rttype);
												}
											} else if ([rtcode isEqualToString:@"-1200"]) {	// fail
												rttype = [packetDic objectForKey:@"rttype"];
												//												assert(rttype != nil);
												if ([rttype isEqualToString:@"only"]) {
													// skip
												} else if ([rttype isEqualToString:@"map"]) {
													// skip
												} else if ([rttype isEqualToString:@"list"]) {
													// skip
												} else {
												}
												// TODO: LOGIN 로긴 실패 예외 처리
												isLoginfail = YES;
												if (clientAsyncSocket) {
													if([clientAsyncSocket isConnected]) {
														[clientAsyncSocket disconnect];
														isConnected = NO;
													}
												}
												
												UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"서비스가 원활하지 않습니다.\n재접속 해 주세요.(e-1200)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
												[alertView show];
												[alertView release];
												
											} else if ([rtcode isEqualToString:@"1201"]) {	// 중복 로그인
												// error
												isLoginfail = YES;
												if (clientAsyncSocket) {
													if([clientAsyncSocket isConnected]) {
														[clientAsyncSocket disconnect];
														isConnected = NO;
													}
												}
												
												UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"서비스가 원활하지 않습니다.\n재접속 해 주세요.(e-1201)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
												[alertView show];
												[alertView release];
												
												rttype = [packetDic objectForKey:@"rttype"];
												//												assert(rttype != nil);
												if ([rttype isEqualToString:@"only"]) {
													// skip
												} else if ([rttype isEqualToString:@"map"]) {
													// skip
												} else if ([rttype isEqualToString:@"list"]) {
													NSArray *listArray = [packetDic objectForKey:@"list"];
													//													assert(listArray != nil);
													for (int i=0; i < [listArray count]; i++) {
														//														NSDictionary *listDic = [listArray objectAtIndex:i];
														//														assert(listDic != nil);
														//														NSString *tupleid = [listDic objectForKey:@"tupleid"];
														//														NSString *imstatus = [listDic objectForKey:@"imstatus"];
														//														NSString *nodeaddr = [listDic objectForKey:@"nodeaddr"];
														//														NSString *device = [listDic objectForKey:@"device"];
														//														NSString *svcidx = [listDic objectForKey:@"svcidx"];
														//														NSString *tmstamp = [listDic objectForKey:@"tmstamp"];
													}
													
												} else {
												}
											} else {
												// TODO: LOGIN 예외처리
												isLoginfail = YES;
												if (clientAsyncSocket) {
													if([clientAsyncSocket isConnected]) {
														[clientAsyncSocket disconnect];
														isConnected = NO;
													}
												}
												
												UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"서비스가 원활하지 않습니다.\n재접속 해 주세요.(e0040)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
												[alertView show];
												[alertView release];
												
												//												NSLog(@"inform LOGIN error rtcode = %@", rtcode);
											}
											//mezzo		[strBodyPacket release];
										} 
									}
								} else {
									// TODO: 예외처리 (등록되지 않은 bodytype)
								}
							}
						}
					}
					//mezzo					[recvHead release];
					
				} else {
					//					NSLog(@"FromStream fail");
				}
			}
			//mezzo	[transPacket release];
			free(buffer);
		}
	}
	else
	{
		//		NSLog(@"didReadData Error converting received data into UTF-8 String");
	}
	// Read more from this socket.
	NSData *newline = [@"\n" dataUsingEncoding:NSASCIIStringEncoding];
	[clientAsyncSocket readDataToData:newline withTimeout:-1 tag:0];
}

// AsyncSocketDelegate
- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
	//	NSLog(@"%s", __FUNCTION__);
}

/*
 socket 발송시
 NSString *textData = [[NSString alloc] initWithText:@"test1234"];
 NSData *data = [textData dataUsingEncoding:NSUTF8StringEncoding];
 [clientAsyncSocket writeData:data withTimeout:-1 tag:0];
 //*/

#pragma mark -
#pragma mark HttpAgent Delegate
-(void)connectionDidFinish:(HttpAgent *)aHttpAgent
{
	DebugLog(@"========== connectionDidFinish ==========>");
//	NSLog(@"<======request %@", aHttpAgent.delegateParameter.requestApi);
	
	NSString *resultData = [[[NSString alloc] initWithData:[aHttpAgent receivedData] encoding:NSUTF8StringEncoding] autorelease];
	DebugLog(@"=====> httpResponse data: %@", resultData);

	if ([aHttpAgent.delegateParameter.requestApi isEqualToString:@"addListContactIncludeGroup"]) {
				//usay.net
				DebugLog(@"===============> httpResponse data: addListContactIncludeGroup\n");
	} else {

	}
	
	if ((aHttpAgent.responseStatusCode / 100) == 2) {	// response OK!
		if ([aHttpAgent.delegateParameter.requestApi isEqualToString:@"albumUpload"]) {		
			if ([aHttpAgent.delegateParameter.requestSubApi isEqualToString:@"insertProfilePhoto"]) {			// 프로필 사진 올리기
				NSLog(@"connectionDidFinish success albumUpload insertProfilePhoto end requestTimeoutTimer");
				[requestTimeOutTimer invalidate];
				[requestTimeOutTimer release];
				requestTimeOutTimer = nil;
				//				NSLog(@"프로필 사진 올리기 requestApi=%@ requestSubApi=%@", aHttpAgent.delegateParameter.requestApi, aHttpAgent.delegateParameter.requestSubApi);
				NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
				//				assert(bodyObject != nil);
				[bodyObject setObject:[myInfoDictionary objectForKey:@"pkey"] forKey:@"pKey"];
				[bodyObject setObject:@"-1" forKey:@"albumNo"];
				if (aHttpAgent.delegateParameter.uniqueId) {
					//					NSLog(@"aHttpAgent.delegateParameter.uniqueId = %@", aHttpAgent.delegateParameter.uniqueId);
					[bodyObject setObject:aHttpAgent.delegateParameter.uniqueId forKey:@"uuid"];
				}
				[bodyObject setObject:@"1" forKey:@"mediaType"];
				[bodyObject setObject:@"1" forKey:@"inputType"];		// 0: 유선  1:무선 2:IPTV
				//				NSLog(@"insertProfilePhoto sleep before");
				sleep(3);
				//				NSLog(@"insertProfilePhoto sleep after");
				[httpAgentArray removeObject:aHttpAgent];
				// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
				USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"albumUploadComplete" andWithDictionary:bodyObject timeout:10] autorelease];
				//				assert(data != nil);
				data.subApi = @"insertProfilePhoto";
				[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
				return;
			} else if ([aHttpAgent.delegateParameter.requestSubApi isEqualToString:@"updateProfilePhoto"]) {	// 프로필 사진 변경하기
				//				NSLog(@"connectionDidFinish success albumUpload updateProfilePhoto end requestTimeoutTimer");
				[requestTimeOutTimer invalidate];
				[requestTimeOutTimer release];
				requestTimeOutTimer = nil;
				//				NSLog(@"프로필 사진 변경하기 requestApi=%@ requestSubApi=%@", aHttpAgent.delegateParameter.requestApi, aHttpAgent.delegateParameter.requestSubApi);
				NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
				//				assert(bodyObject != nil);
				[bodyObject setObject:[myInfoDictionary objectForKey:@"pkey"] forKey:@"pKey"];
				[bodyObject setObject:@"-1" forKey:@"albumNo"];
				[bodyObject setObject:aHttpAgent.delegateParameter.uniqueId forKey:@"uuid"];
				[bodyObject setObject:@"1" forKey:@"mediaType"];
				[bodyObject setObject:@"1" forKey:@"inputType"];		// 0: 유선  1:무선 2:IPTV
				//				NSLog(@"updateProfilePhoto sleep before");
				sleep(3);
				//				NSLog(@"updateProfilePhoto sleep after");
				[httpAgentArray removeObject:aHttpAgent];
				// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
				USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"albumUploadComplete" andWithDictionary:bodyObject timeout:10] autorelease];
				//				assert(data != nil);
				data.subApi = @"updateProfilePhoto";
				[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
				return;
			} else if ([aHttpAgent.delegateParameter.requestSubApi isEqualToString:@"insertContactPhoto"]) {	// 주소록 사진 올리기
				//				NSLog(@"주소록 사진 올리기 requestApi=%@ requestSubApi=%@", aHttpAgent.delegateParameter.requestApi, aHttpAgent.delegateParameter.requestSubApi);
				NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
				//				assert(bodyObject != nil);
				[bodyObject setObject:[myInfoDictionary objectForKey:@"pkey"] forKey:@"pKey"];
				[bodyObject setObject:@"-2" forKey:@"albumNo"];
				[bodyObject setObject:aHttpAgent.delegateParameter.uniqueId forKey:@"uuid"];
				[bodyObject setObject:@"1" forKey:@"mediaType"];
				[bodyObject setObject:@"1" forKey:@"inputType"];		// 0: 유선  1:무선 2:IPTV
				//				NSLog(@"updateProfilePhoto sleep before");
				sleep(3);
				//				NSLog(@"updateProfilePhoto sleep after");
				[httpAgentArray removeObject:aHttpAgent];
				// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
				USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"albumUploadComplete" andWithDictionary:bodyObject timeout:10] autorelease];
				//				assert(data != nil);
				data.subApi = @"insertContactPhoto";
				[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
				return;
			} else if ([aHttpAgent.delegateParameter.requestSubApi isEqualToString:@"updateContactPhoto"]) {	// 주소록 사진 변경하기
				//				NSLog(@"주소록 사진 변경하기 requestApi=%@ requestSubApi=%@", aHttpAgent.delegateParameter.requestApi, aHttpAgent.delegateParameter.requestSubApi);
				NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
				//				assert(bodyObject != nil);
				[bodyObject setObject:[myInfoDictionary objectForKey:@"pkey"] forKey:@"pKey"];
				[bodyObject setObject:@"-2" forKey:@"albumNo"];
				[bodyObject setObject:aHttpAgent.delegateParameter.uniqueId forKey:@"uuid"];
				[bodyObject setObject:@"1" forKey:@"mediaType"];
				[bodyObject setObject:@"1" forKey:@"inputType"];		// 0: 유선  1:무선 2:IPTV
				
				[httpAgentArray removeObject:aHttpAgent];
				//				NSLog(@"updateContactPhoto sleep before");
				sleep(3);
				//				NSLog(@"updateContactPhoto sleep after");
				// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
				USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"albumUploadComplete" andWithDictionary:bodyObject timeout:10] autorelease];
				//				assert(data != nil);
				data.subApi = @"updateContactPhoto";
				[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
				return;
			} else if ([aHttpAgent.delegateParameter.requestSubApi isEqualToString:@"insertMsgMediaPhoto"]) {	// 대화시 사진/동영상 보내기
				//				NSLog(@"대화 사진/동영상 보내기 requestApi=%@ requestSubApi=%@", aHttpAgent.delegateParameter.requestApi, aHttpAgent.delegateParameter.requestSubApi);
				NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
				//				assert(bodyObject != nil);
				[bodyObject setObject:[myInfoDictionary objectForKey:@"pkey"] forKey:@"pKey"];
				[bodyObject setObject:@"-3" forKey:@"albumNo"];
				[bodyObject setObject:aHttpAgent.delegateParameter.uniqueId forKey:@"uuid"];
				if ([aHttpAgent.delegateParameter.mType isEqualToString:@"P"]) {
					[bodyObject setObject:@"1" forKey:@"mediaType"];
				} else if ([aHttpAgent.delegateParameter.mType isEqualToString:@"V"]) {
					[bodyObject setObject:@"0" forKey:@"mediaType"];
				} else {
					// skip
				}
				[bodyObject setObject:@"1" forKey:@"inputType"];		// 0: 유선  1:무선 2:IPTV
				//				[bodyObject setObject:@"Y" forKey:@"isDebug"];
				
				[httpAgentArray removeObject:aHttpAgent];
				
				// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
				USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"albumUploadComplete" andWithDictionary:bodyObject timeout:10] autorelease];
				//				assert(data != nil);
				data.subApi = @"insertMsgMediaPhoto";
				data.messageKey = aHttpAgent.delegateParameter.messageKey;
				data.sessionKey = aHttpAgent.delegateParameter.sessionKey;
				//				NSLog(@"insertMsgMediaPhoto sleep before");
				sleep(3);
				//				NSLog(@"insertMsgMediaPhoto sleep after");
				[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
				return;
			} else {
				//				NSLog(@"albumUpload skip");
				// skip
				[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
				[[NSNotificationCenter defaultCenter] postNotificationName:aHttpAgent.delegateParameter.requestApi object:nil];
				return;
			}
		}
		DebugLog(@"========== connectionDidFinish response Success. ==========>");

		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		// 1. Create BSJSON parser.
		SBJSON *jsonParser = [[SBJSON alloc] init];
		
		// 2. Get the result dictionary from the response string.
		NSDictionary *dic = (NSDictionary*)[jsonParser objectWithString:resultData error:NULL];
		[jsonParser release];
		
		// 3. Show response
		// key and value type
		NSString *api = nil;
		//		api = [dic objectForKey:@"api"];
		api = aHttpAgent.delegateParameter.requestApi;
		NSString* httpResponseApi = [dic objectForKey:@"api"];
		
		
	
		
	
		
		//		assert(api != nil);
		if ([api isEqualToString:@"initOnMobile"]) {							// URL 요청
			//			NSLog(@"connectionDidFinish success initOnMobile end requestTimeoutTimer");
			[requestTimeOutTimer invalidate];
			[requestTimeOutTimer release];
			requestTimeOutTimer = nil;
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
					//					assert(addressDic != nil);
					for (id key in addressDic) {
						//						NSLog(@"%@  %@", key, (NSString*)[addressDic objectForKey:key]);
					}
					
				} else {
					// TODO: 예외처리
				}
			}
			[httpAgentArray removeObject:aHttpAgent];
			resultData = @"SUCCESS";
			[[NSNotificationCenter defaultCenter] postNotificationName:api object:resultData];
			return;
		} else if ([api isEqualToString:@"registOnMobile"]) {					// 회원가입
		} else if ([api isEqualToString:@"mobilePhoneNumberAuthSending"]) {		// 인증 번호를 받기 위한 전화 번호 전송
		} else if ([api isEqualToString:@"isMobilePhoneNumberAuth"]) {			// 인증 번호 전송
		} else if ([api isEqualToString:@"loginOnMobile"]) {					// 로그인 (인증)
			//			NSLog(@"connectionDidFinish success loginOnMobile start requestTimeoutTimer");
			[requestTimeOutTimer invalidate];
			[requestTimeOutTimer release];
			requestTimeOutTimer = nil;
		} else if ([api isEqualToString:@"convertPKeyOnMobile"]) {				// 전환가입
		} else if ([api isEqualToString:@"updateProfile"]) {					// 프로파일 정보 변경하기
		} else if ([api isEqualToString:@"addListContact"]) {					// 주소 Bulk 올리기.
		} else if ([api isEqualToString:@"addListContactIncludeGroup"]) {		// 그룹을 포함하는 주소 Bulk 올리기.
		} else if ([api isEqualToString:@"getFriendsList"]) {					// 전체 친구 프로필 리스트 가져오기
		} else if ([api isEqualToString:@"updateListContact"]) {				// 주소 멀티 그룹 수정.
		} else if ([api isEqualToString:@"deleteContact"]) {					// 주소 삭제.
		} else if ([api isEqualToString:@"deleteListContact"]) {				// 주소 멀티 삭제.
		} else if ([api isEqualToString:@"deleteGroup"]) {						// 주소록 그룹 삭제.
		} else if ([api isEqualToString:@"toggleCommStatus"]) {					
			if ([aHttpAgent.delegateParameter.requestSubApi isEqualToString:@"BlockUserOk"]) {			// 주소록 - 친구 차단 하기
				api = @"BlockUserOk";
			} else if ([aHttpAgent.delegateParameter.requestSubApi isEqualToString:@"BlockUserCancel"]) {	// 설정 - 차단 친구 목록 - 친구 차단 해제 하기
				api = @"BlockUserCancel";
			}
		} else if ([api isEqualToString:@"albumUploadComplete"]) {
			if (httpResponseApi && [httpResponseApi length] > 0 && [httpResponseApi isEqualToString:@"createNewMessage"]) {
				// 대화 사진 보내기
				api = @"createNewMessage";
			} else if (httpResponseApi && [httpResponseApi length] > 0 && [httpResponseApi isEqualToString:@"insertProfilePhoto"]) {
				// 프로필 사진 올리기
				api = @"insertProfilePhoto";
				NSLog(@"connectionDidFinish fail albumUploadComplete insertProfilePhoto end requestTimeoutTimer");
				[requestTimeOutTimer invalidate];
				[requestTimeOutTimer release];
				requestTimeOutTimer = nil;
			} else if (httpResponseApi && [httpResponseApi length] > 0 && [httpResponseApi isEqualToString:@"updateProfilePhoto"]) {
				// 프로필 사진 올리기
				NSLog(@"connectionDidFinish fail albumUploadComplete updateProfilePhoto end requestTimeoutTimer");
				[requestTimeOutTimer invalidate];
				[requestTimeOutTimer release];
				requestTimeOutTimer = nil;
				api = @"insertProfilePhoto";
			} else if (httpResponseApi && [httpResponseApi length] > 0 && [httpResponseApi isEqualToString:@"insertContactPhoto"]) {
				// 주소록 추가하기 (사진)
				api = @"insertContactPhoto";
			} else if (httpResponseApi && [httpResponseApi length] > 0 && [httpResponseApi isEqualToString:@"updateContactPhoto"]) {
				// 주소록 변경하기 (사진)
				api = @"updateContactPhoto";
				
			} else {
				if ([aHttpAgent.delegateParameter.requestSubApi isEqualToString:@"insertProfilePhoto"]) {
					api = @"insertProfilePhoto";
				} else if ([aHttpAgent.delegateParameter.requestSubApi isEqualToString:@"updateProfilePhoto"]) {
					api = @"insertProfilePhoto";
				} else if ([aHttpAgent.delegateParameter.requestSubApi isEqualToString:@"insertContactPhoto"]) {
					if ([resultData isEqualToString:@"500"]) {
						// error
						return;
					}
				} else if ([aHttpAgent.delegateParameter.requestSubApi isEqualToString:@"updateContactPhoto"]) {
					if ([resultData isEqualToString:@"500"]) {
						// error
						return;
					}
				} else if ([aHttpAgent.delegateParameter.requestSubApi isEqualToString:@"insertMsgMediaPhoto"]) {
					if ([resultData isEqualToString:@"500"]) {
						// error
						//						NSLog(@"대화시 파일전송 예외처리 sessionKey = %@  messageKey = %@", aHttpAgent.delegateParameter.sessionKey, aHttpAgent.delegateParameter.messageKey);
						NSArray *checkDBMessageInfoArray = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where CHATSESSION=? and MESSAGEKEY=?", 
															aHttpAgent.delegateParameter.sessionKey, aHttpAgent.delegateParameter.messageKey, nil];
						if (checkDBMessageInfoArray && [checkDBMessageInfoArray count] > 0) {
							[MessageInfo findWithSqlWithParameters:@"update _TMessageInfo set ISSUCCESS=? where CHATSESSION=? and MESSAGEKEY=?", 
							 @"-1", aHttpAgent.delegateParameter.sessionKey, aHttpAgent.delegateParameter.messageKey, nil];
						}
						@synchronized(msgArray) {
							if (msgArray && [msgArray count] > 0) {
								for (CellMsgData *msgData in msgArray) {
									if ([msgData.chatsession isEqualToString:aHttpAgent.delegateParameter.sessionKey] && 
										[msgData.messagekey isEqualToString:aHttpAgent.delegateParameter.messageKey]) {
										msgData.sendMsgSuccess = @"-1";
										break;
									}
								}
							}
						}
						NSString *openChatSession = [self.myInfoDictionary objectForKey:@"openChatSession"];
						if (openChatSession && [openChatSession length] > 0 && [openChatSession isEqualToString:aHttpAgent.delegateParameter.sessionKey]) {
							[[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadMessage" object:aHttpAgent.delegateParameter.sessionKey];
						}
						UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0041)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
						[alertView show];
						[alertView release];
						[httpAgentArray removeObject:aHttpAgent];
						return;
					} else {
						[httpAgentArray removeObject:aHttpAgent];
					}
				} else {
					// error
					[httpAgentArray removeObject:aHttpAgent];
					return;
				}
			}
		} else if ([api isEqualToString:@"requestMakeFriend"]) {				// 친구 신청
		} else if ([api isEqualToString:@"getMakeSendList"]) {					// 친구 신청 리스트 조회
		} else if ([api isEqualToString:@"getMakeReceivedList"]) {				// 친구 요청 리스트 조회
		} else if ([api isEqualToString:@"getGroupsForMobile"]) {				// 주소록 - 그룹 리스트 조회
		} else if ([api isEqualToString:@"addGroup"]) {							// 주소록 - 그룹 추가
		} else if ([api isEqualToString:@"updateGroup"]) {						// 주소록 - 그룹 수정
		} else if ([api isEqualToString:@"deleteGroupForMobile"]) {				// 주소록 - 그룹 삭제
		} else if ([api isEqualToString:@"getContacts"]) {						// 주소록 - 주소 리스트 조회
		} else if ([api isEqualToString:@"getGroups"]) {						// 주소록 - 그룹 정보 얻어오기
		} else if ([api isEqualToString:@"addContact"]) {						// 주소록 - 주소 추가
		} else if ([api isEqualToString:@"updateContact"]) {					// 주소록 - 주소 수정
		} else if ([api isEqualToString:@"deleteContactForMobile"]) {			// 주소록 - 주소 삭제
		} else if ([api isEqualToString:@"getHistoryByRP"]) {					// 주소록 싱크 - RP 히스토리 별 조회
		} else if ([api isEqualToString:@"getLastAfterRP"]) {					// 주소록 싱크 - RP 마지막 변경 내용 조회
		} else if ([api isEqualToString:@"getAllAtRP"]) {						// 주소록 싱크 - 특정 시점의 RP 형상 조회
		} else if ([api isEqualToString:@"getCountByRP"]) {						// 주소록 싱크 - 특정 시점의 RP 형상 조회
		} else if ([api isEqualToString:@"getChatParticipants"]) {				// 대화 - 참가자 정보 가져오기
			if (aHttpAgent.delegateParameter.requestSubApi && [aHttpAgent.delegateParameter.requestSubApi isEqualToString:@"NOTI_CHAT_ENTER"]) {
				api = @"getChatParticipantsNotiChatEnter";
			}
		} else if ([api isEqualToString:@"getMyChatSessionList"]) {				// 대화 - 전체 메시지 가져오기
		} else if ([api isEqualToString:@"retrieveSessionMessage"]) {			// 대화 - 대화 메시지 가져오기
		} else if ([api isEqualToString:@"joinToChatSession"]) {				// 대화 - 대화 세션 참가
		} else if ([api isEqualToString:@"quitFromChatSession"]) {				// 대화 - 대화 세션에서 나가기
		} else if ([api isEqualToString:@"createNewMessage"]) {					// 대화 - 새로운 메시지 생성 (텍스트 메시지 보내기)
			if ([aHttpAgent.delegateParameter.requestSubApi isEqualToString:@"insertMsgMediaPhoto"]) {	// 대화 - 사진 보내기 성공시 전송
				// map, message(url), mType(P,V), sessionKey, messageKey
				//				api = @"messageMediaUpload";
				
				// 임시로 만든 파일 삭제
				//				NSError *error = nil;
				//				[[NSFileManager defaultManager]removeItemAtPath:aHttpAgent.delegateParameter.filePath error:error];
			}
		} else if ([api isEqualToString:@"getReadMark"]) {						// 대화 - 메시지에 대한 읽은 카운트수 가져오기
		} else if ([api isEqualToString:@"deleteMyMessage"]) {					// 대화 - 메시지 지우기
		} else if ([api isEqualToString:@"retrieveSystemMessage"]) {			// 시스템 정보 메시지 가져오기
		} else if ([api isEqualToString:@"getRecommendFriendsList"]) {	// 추천 친구 - 추친 친구 리스트 가져오기
		} else if ([api isEqualToString:@"setFriendFromRecommand"]) {						// 추천 친구 - 친구 수락
		} else if ([api isEqualToString:@"deleteRecommendFriend"]) {			// 추천 친구 목록에서 삭제하기
		} else if ([api isEqualToString:@"loadProfile"]) {				// 설정 - 프로필 설정 - 전체 정보 가져오기
			//			NSLog(@"connectionDidFinish success loadProfile start requestTimeoutTimer");
			[requestTimeOutTimer invalidate];
			[requestTimeOutTimer release];
			requestTimeOutTimer = nil;
		} else if ([api isEqualToString:@"loadSimpleProfile"]) {			// 설정 - 프로필 설정 - simple 정보 가져오기
		} else if ([api isEqualToString:@"getChangedProfileInfo"]) {		// 초기 정보 - 버디들의 최근 정보 가져오기
		} else if ([api isEqualToString:@"deleteProfilePhoto"]) {				// 설정 - 프로필 설정 - 사진 삭제
		} else if ([api isEqualToString:@"serRepresentPhoto"]) {				// 설정 - 프로필 설정 - 사진 선택 (대표사진 선택) 
		} else if ([api isEqualToString:@"updatePresence"]) {			// 설정 - 프로필 설정 - 상태 설정
		} else if ([api isEqualToString:@"updateNickName"]) {			// 설정 - 프로필 설정 - 별명 설정
			//			NSLog(@"connectionDidFinish success updateNickName start requestTimeoutTimer");
			[requestTimeOutTimer invalidate];
			[requestTimeOutTimer release];
			requestTimeOutTimer = nil;
		} else if ([api isEqualToString:@"updateStatus"]) {				// 설정 - 프로필 설정 - 오늘의 한마디 설정
			//			NSLog(@"connectionDidFinish success updateStatus start requestTimeoutTimer");
			[requestTimeOutTimer invalidate];
			[requestTimeOutTimer release];
			requestTimeOutTimer = nil;
		} else if ([api isEqualToString:@"updateMyInfo"]) {				// 설정 - 프로필 설정 - 내 정보 설정 하기
			//			NSLog(@"connectionDidFinish success updateMyInfo start requestTimeoutTimer");
			[requestTimeOutTimer invalidate];
			[requestTimeOutTimer release];
			requestTimeOutTimer = nil;
		} else if ([api isEqualToString:@"withdrawal"]) {						// 설정 - 회원 탈퇴
		} else if ([api isEqualToString:@"setMessagePreviewOnMobile"]) {		// 설정 - 알림 설정 - 내용 미리보기
		} else if ([api isEqualToString:@"getBlockedFriendsList"]) {	// 설정 - 차단 친구 목록 - 차단 친구 프로필 리스트 가져오기
		} else {
			// error skip!
			[httpAgentArray removeObject:aHttpAgent];
			return;
		}
		[httpAgentArray removeObject:aHttpAgent];
		USayHttpData *data = [[[USayHttpData alloc] initWithResponseData:api andWithString:resultData] autorelease];
		[[NSNotificationCenter defaultCenter] postNotificationName:api object:data];
	} else {
		DebugLog(@"========== connectionDidFinish response Failed. ==========>");
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		// TODO: 예외처리
		//		NSLog(@"connectionDidFinish responseStatusCode = %d", [aHttpAgent responseStatusCode]);
		NSString *api = nil;
		api = aHttpAgent.delegateParameter.requestApi;
		//		assert(api != nil);
		
		// object 에 nil 값을 넘기면 에러 처리
		if ([api isEqualToString:@"initOnMobile"]) {
			//			NSLog(@"connectionDidFinish fail initOnMobile start requestTimeoutTimer");
			[requestTimeOutTimer invalidate];
			[requestTimeOutTimer release];
			requestTimeOutTimer = nil;
			//mezzo		resultData = @"FAIL";
		} else if ([api isEqualToString:@"registOnMobile"]) {							// 회원가입
		} else if ([api isEqualToString:@"mobilePhoneNumberAuthSending"]) {		// 인증 번호를 받기 위한 전화 번호 전송
		} else if ([api isEqualToString:@"isMobilePhoneNumberAuth"]) {			// 인증 번호 전송
		} else if ([api isEqualToString:@"loginOnMobile"]) {					// 로그인 (인증)
			//			NSLog(@"connectionDidFinish fail loginOnMobile start requestTimeoutTimer");
			[requestTimeOutTimer invalidate];
			[requestTimeOutTimer release];
			requestTimeOutTimer = nil;
		} else if ([api isEqualToString:@"convertPKeyOnMobile"]) {				// 전환가입
		} else if ([api isEqualToString:@"updateProfile"]) {					// 프로파일 정보 변경하기
		} else if ([api isEqualToString:@"addListContact"]) {					// 주소 Bulk 올리기.
		} else if ([api isEqualToString:@"addListContactIncludeGroup"]) {		// 그룹을 포함하는 주소 Bulk 올리기.
		} else if ([api isEqualToString:@"getFriendsList"]) {					// 전체 친구 프로필 리스트 가져오기
		} else if ([api isEqualToString:@"updateListContact"]) {				// 주소 멀티 그룹 수정.
		} else if ([api isEqualToString:@"deleteContact"]) {					// 주소 삭제.
		} else if ([api isEqualToString:@"toggleCommStatus"]) {
			if ([aHttpAgent.delegateParameter.requestSubApi isEqualToString:@"BlockUserOk"]) {			// 주소록 - 친구 차단 하기
				api = @"BlockUserOk";
			} else if ([aHttpAgent.delegateParameter.requestSubApi isEqualToString:@"BlockUserCancel"]) {	// 설정 - 차단 친구 목록 - 친구 차단 해제 하기
				api = @"BlockUserCancel";
			}
		} else if ([api isEqualToString:@"albumUpload"]) {
			if ([aHttpAgent.delegateParameter.requestSubApi isEqualToString:@"insertProfilePhoto"]) {			// 프로필 사진 올리기
				//				NSLog(@"connectionDidFinish fail albumUpload insertProfilePhoto end requestTimeoutTimer");
				[requestTimeOutTimer invalidate];
				[requestTimeOutTimer release];
				requestTimeOutTimer = nil;
				api = @"insertProfilePhoto";
			} else if ([aHttpAgent.delegateParameter.requestSubApi isEqualToString:@"updateProfilePhoto"]) {	// 프로필 사진 올리기
				//				NSLog(@"connectionDidFinish fail albumUpload updateProfilePhoto end requestTimeoutTimer");
				[requestTimeOutTimer invalidate];
				[requestTimeOutTimer release];
				requestTimeOutTimer = nil;
				api = @"insertProfilePhoto";
			} else if ([aHttpAgent.delegateParameter.requestSubApi isEqualToString:@"insertContactPhoto"]) {	// 주소록 사진 올리기
				api = @"insertContactPhoto";
			} else if ([aHttpAgent.delegateParameter.requestSubApi isEqualToString:@"updateContactPhoto"]) {	// 주소록 사진 올리기
				api = @"updateContactPhoto";
			} else if ([aHttpAgent.delegateParameter.requestSubApi isEqualToString:@"insertMsgMediaPhoto"]) {	// 대화시 사진/동영상 보내기
				// TODO: 대화시 파일전송 예외처리
				NSArray *checkDBMessageInfoArray = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where CHATSESSION=? and MESSAGEKEY=?", 
													aHttpAgent.delegateParameter.sessionKey, aHttpAgent.delegateParameter.messageKey, nil];
				if (checkDBMessageInfoArray && [checkDBMessageInfoArray count] > 0) {
					[MessageInfo findWithSqlWithParameters:@"update _TMessageInfo set ISSUCCESS=? where CHATSESSION=? and MESSAGEKEY=?", 
					 @"-1", aHttpAgent.delegateParameter.sessionKey, aHttpAgent.delegateParameter.messageKey, nil];
				}
				@synchronized(msgArray) {
					if (msgArray && [msgArray count] > 0) {
						for (CellMsgData *msgData in msgArray) {
							if ([msgData.chatsession isEqualToString:aHttpAgent.delegateParameter.sessionKey] && 
								[msgData.messagekey isEqualToString:aHttpAgent.delegateParameter.messageKey]) {
								msgData.sendMsgSuccess = @"-1";
								break;
							}
						}
					}
				}
				NSString *openChatSession = [self.myInfoDictionary objectForKey:@"openChatSession"];
				if (openChatSession && [openChatSession length] > 0 && [openChatSession isEqualToString:aHttpAgent.delegateParameter.sessionKey]) {
					[[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadMessage" object:aHttpAgent.delegateParameter.sessionKey];
				}
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0042)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
				[alertView show];
				[alertView release];
				[httpAgentArray removeObject:aHttpAgent];
				return;
			} else {
				// skip
				[httpAgentArray removeObject:aHttpAgent];
				return;
			}
		} else if ([api isEqualToString:@"albumUploadComplete"]) {
			if ([aHttpAgent.delegateParameter.requestSubApi isEqualToString:@"insertProfilePhoto"]) {			// 프로필 사진 올리기
				//				NSLog(@"connectionDidFinish fail albumUploadComplete insertProfilePhoto end requestTimeoutTimer");
				[requestTimeOutTimer invalidate];
				[requestTimeOutTimer release];
				requestTimeOutTimer = nil;
				api = @"insertProfilePhoto";
			} else if ([aHttpAgent.delegateParameter.requestSubApi isEqualToString:@"updateProfilePhoto"]) {	// 프로필 사진 올리기
				//				NSLog(@"connectionDidFinish fail albumUploadComplete updateProfilePhoto end requestTimeoutTimer");
				[requestTimeOutTimer invalidate];
				[requestTimeOutTimer release];
				requestTimeOutTimer = nil;
				api = @"insertProfilePhoto";
			} else if ([aHttpAgent.delegateParameter.requestSubApi isEqualToString:@"insertContactPhoto"]) {	// 주소록 사진 올리기
				// TODO: 주소록 사진 올리기 예외처리 필요
				api = @"insertContactPhoto";
			} else if ([aHttpAgent.delegateParameter.requestSubApi isEqualToString:@"updateContactPhoto"]) {	// 주소록 사진 올리기
				// TODO: 주소록 사진 올리기 예외처리 필요
				api = @"updateContactPhoto";
			} else if ([aHttpAgent.delegateParameter.requestSubApi isEqualToString:@"insertMsgMediaPhoto"]) {	// 대화시 사진/동영상 보내기
				NSArray *checkDBMessageInfoArray = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where CHATSESSION=? and MESSAGEKEY=?", 
													aHttpAgent.delegateParameter.sessionKey, aHttpAgent.delegateParameter.messageKey, nil];
				if (checkDBMessageInfoArray && [checkDBMessageInfoArray count] > 0) {
					[MessageInfo findWithSqlWithParameters:@"update _TMessageInfo set ISSUCCESS=? where CHATSESSION=? and MESSAGEKEY=?", 
					 @"-1", aHttpAgent.delegateParameter.sessionKey, aHttpAgent.delegateParameter.messageKey, nil];
				}
				@synchronized(msgArray) {
					if (msgArray && [msgArray count] > 0) {
						for (CellMsgData *msgData in msgArray) {
							if ([msgData.chatsession isEqualToString:aHttpAgent.delegateParameter.sessionKey] && 
								[msgData.messagekey isEqualToString:aHttpAgent.delegateParameter.messageKey]) {
								msgData.sendMsgSuccess = @"-1";
								break;
							}
						}
					}
				}
				NSString *openChatSession = [self.myInfoDictionary objectForKey:@"openChatSession"];
				if (openChatSession && [openChatSession length] > 0 && [openChatSession isEqualToString:aHttpAgent.delegateParameter.sessionKey]) {
					[[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadMessage" object:aHttpAgent.delegateParameter.sessionKey];
				}
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0043)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
				[alertView show];
				[alertView release];
				[httpAgentArray removeObject:aHttpAgent];
				return;
			} else {
				// skip
				[httpAgentArray removeObject:aHttpAgent];
				return;
			}
		} else if ([api isEqualToString:@"createNewMessage"]) {					// 대화 - 새로운 메시지 생성 (텍스트 메시지 보내기)
			// TODO: 대화시 예외처리
			if (aHttpAgent.delegateParameter.sessionKey && [aHttpAgent.delegateParameter.sessionKey length] > 0 &&
				aHttpAgent.delegateParameter.messageKey && [aHttpAgent.delegateParameter.messageKey length] > 0) {
				NSArray *checkDBMessageInfoArray = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where CHATSESSION=? and SESSIONKEY=?", 
													aHttpAgent.delegateParameter.sessionKey, aHttpAgent.delegateParameter.messageKey, nil];
				if (checkDBMessageInfoArray && [checkDBMessageInfoArray count] > 0) {
					[MessageInfo findWithSqlWithParameters:@"update _TMessageInfo set ISSUCCESS=? where CHATSESSION=? and SESSIONKEY=?", 
					 @"-1", aHttpAgent.delegateParameter.sessionKey, aHttpAgent.delegateParameter.messageKey, nil];
				}
				@synchronized(msgArray) {
					if (msgArray && [msgArray count] > 0) {
						for (CellMsgData *msgData in msgArray) {
							if ([msgData.chatsession isEqualToString:aHttpAgent.delegateParameter.sessionKey] && 
								[msgData.messagekey isEqualToString:aHttpAgent.delegateParameter.messageKey]) {
								msgData.sendMsgSuccess = @"-1";
								break;
							}
						}
					}
				}
				NSString *openChatSession = [self.myInfoDictionary objectForKey:@"openChatSession"];
				if (openChatSession && [openChatSession length] > 0 && [openChatSession isEqualToString:aHttpAgent.delegateParameter.sessionKey]) {
					[[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadMessage" object:aHttpAgent.delegateParameter.sessionKey];
				}
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0044)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
				[alertView show];
				[alertView release];
				[httpAgentArray removeObject:aHttpAgent];
			}
			return;
		} else if ([api isEqualToString:@"requestMakeFriend"]) {				// 친구 신청
		} else if ([api isEqualToString:@"getMakeSendList"]) {					// 친구 신청 리스트 조회
		} else if ([api isEqualToString:@"getMakeReceivedList"]) {				// 친구 요청 리스트 조회
		} else if ([api isEqualToString:@"getGroupsForMobile"]) {				// 주소록 - 그룹 리스트 조회
		} else if ([api isEqualToString:@"addGroup"]) {							// 주소록 - 그룹 추가
		} else if ([api isEqualToString:@"updateGroup"]) {						// 주소록 - 그룹 수정
		} else if ([api isEqualToString:@"deleteGroupForMobile"]) {				// 주소록 - 그룹 삭제
		} else if ([api isEqualToString:@"getContacts"]) {						// 주소록 - 주소 리스트 조회
		} else if ([api isEqualToString:@"getGroups"]) {						// 주소록 - 그룹 정보 얻어오기
		} else if ([api isEqualToString:@"addContact"]) {						// 주소록 - 주소 추가
		} else if ([api isEqualToString:@"updateContact"]) {					// 주소록 - 주소 수정
		} else if ([api isEqualToString:@"deleteContactForMobile"]) {			// 주소록 - 주소 삭제
		} else if ([api isEqualToString:@"deleteListContact"]) {				// 주소록 - 멀티 삭제.
		} else if ([api isEqualToString:@"deleteGroup"]) {						// 주소록 - 그룹 삭제.
		} else if ([api isEqualToString:@"getHistoryByRP"]) {					// 주소록 싱크 - RP 히스토리 별 조회
		} else if ([api isEqualToString:@"getLastAfterRP"]) {					// 주소록 싱크 - RP 마지막 변경 내용 조회
		} else if ([api isEqualToString:@"getAllAtRP"]) {						// 주소록 싱크 - 특정 시점의 RP 형상 조회
		} else if ([api isEqualToString:@"getCountByRP"]) {						// 주소록 싱크 - 특정 시점의 RP 형상 조회
		} else if ([api isEqualToString:@"getChatParticipants"]) {				// 대화 - 참가자 정보 가져오기
			if (aHttpAgent.delegateParameter.requestSubApi && [aHttpAgent.delegateParameter.requestSubApi isEqualToString:@"NOTI_CHAT_ENTER"]) {
				api = @"getChatParticipantsNotiChatEnter";
			}
		} else if ([api isEqualToString:@"getMyChatSessionList"]) {				// 대화 - 전체 메시지 가져오기
		} else if ([api isEqualToString:@"retrieveSessionMessage"]) {			// 대화 - 대화 메시지 가져오기
		} else if ([api isEqualToString:@"joinToChatSession"]) {				// 대화 - 대화 세션 참가
		} else if ([api isEqualToString:@"quitFromChatSession"]) {				// 대화 - 대화 세션에서 나가기			
		} else if ([api isEqualToString:@"getReadMark"]) {						// 대화 - 메시지에 대한 읽은 카운트수 가져오기
		} else if ([api isEqualToString:@"deleteMyMessage"]) {					// 대화 - 메시지 지우기
		} else if ([api isEqualToString:@"retrieveSystemMessage"]) {			// 시스템 정보 메시지 가져오기
		} else if ([api isEqualToString:@"getRecommendFriendsList"]) {			// 추천 친구 - 추친 친구 리스트 가져오기
		} else if ([api isEqualToString:@"setFriendFromRecommand"]) {			// 추천 친구 - 친구 수락
		} else if ([api isEqualToString:@"deleteRecommendFriend"]) {			// 추천 친구 목록에서 삭제하기
		} else if ([api isEqualToString:@"loadProfile"]) {						// 설정 - 프로필 설정 - 전체 정보 가져오기
			//			NSLog(@"connectionDidFinish success loadProfile start requestTimeoutTimer");
			[requestTimeOutTimer invalidate];
			[requestTimeOutTimer release];
			requestTimeOutTimer = nil;
		} else if ([api isEqualToString:@"loadSimpleProfile"]) {				// 설정 - 프로필 설정 - simple 정보 가져오기
		} else if ([api isEqualToString:@"getChangedProfileInfo"]) {		// 초기 정보 - 버디들의 최근 정보 가져오기
		} else if ([api isEqualToString:@"deleteProfilePhoto"]) {				// 설정 - 프로필 설정 - 사진 삭제
		} else if ([api isEqualToString:@"serRepresentPhoto"]) {				// 설정 - 프로필 설정 - 사진 선택 (대표사진 선택) 
		} else if ([api isEqualToString:@"updatePresence"]) {					// 설정 - 프로필 설정 - 상태 설정
		} else if ([api isEqualToString:@"updateNickName"]) {					// 설정 - 프로필 설정 - 별명 설정
			//			NSLog(@"connectionDidFinish success updateNickName start requestTimeoutTimer");
			[requestTimeOutTimer invalidate];
			[requestTimeOutTimer release];
			requestTimeOutTimer = nil;
		} else if ([api isEqualToString:@"updateStatus"]) {						// 설정 - 프로필 설정 - 오늘의 한마디 설정
			//			NSLog(@"connectionDidFinish success updateStatus start requestTimeoutTimer");
			[requestTimeOutTimer invalidate];
			[requestTimeOutTimer release];
			requestTimeOutTimer = nil;
		} else if ([api isEqualToString:@"updateMyInfo"]) {						// 설정 - 프로필 설정 - 내 정보 설정 하기
			//			NSLog(@"connectionDidFinish success updateMyInfo start requestTimeoutTimer");
			[requestTimeOutTimer invalidate];
			[requestTimeOutTimer release];
			requestTimeOutTimer = nil;
		} else if ([api isEqualToString:@"withdrawal"]) {						// 설정 - 회원 탈퇴
		} else if ([api isEqualToString:@"setMessagePreviewOnMobile"]) {		// 설정 - 알림 설정 - 내용 미리보기
		} else if ([api isEqualToString:@"getBlockedFriendsList"]) {			// 설정 - 차단 친구 목록 - 차단 친구 프로필 리스트 가져오기
		} else {
			// error skip!
			[httpAgentArray removeObject:aHttpAgent];
			return;
		}
		
		[[NSNotificationCenter defaultCenter] postNotificationName:api object:nil];
		[httpAgentArray removeObject:aHttpAgent];
		return;
	}
}

-(void)connectionDidFail:(HttpAgent *)aHttpAgent {
	//	NSLog(@"connectionDidFail:(HttpAgent *)aHttpAgent");
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	/*	
	 // TODO: 예외처리
	 [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	 NSLog(@"connectionDidFinish responseStatusCode = %d", [aHttpAgent responseStatusCode]);
	 NSString *api = nil;
	 api = aHttpAgent.delegateParameter.requestApi;
	 assert(api != nil);
	 
	 // object 에 nil 값을 넘기면 에러 처리
	 
	 if ([api isEqualToString:@"initOnMobile"]) {
	 NSString *resultData = @"FAIL";
	 [[NSNotificationCenter defaultCenter] postNotificationName:api object:resultData];
	 } else if ([api isEqualToString:@"registOnMobile"]) {							// 회원가입
	 } else if ([api isEqualToString:@"mobilePhoneNumberAuthSending"]) {		// 인증 번호를 받기 위한 전화 번호 전송
	 } else if ([api isEqualToString:@"isMobilePhoneNumberAuth"]) {			// 인증 번호 전송
	 } else if ([api isEqualToString:@"loginOnMobile"]) {					// 로그인 (인증)
	 } else if ([api isEqualToString:@"convertPKeyOnMobile"]) {				// 전환가입
	 } else if ([api isEqualToString:@"updateProfile"]) {			// 프로파일 정보 변경하기
	 } else if ([api isEqualToString:@"addListContact"]) {					// 주소 Bulk 올리기.
	 } else if ([api isEqualToString:@"addListContactIncludeGroup"]) {		// 그룹을 포함하는 주소 Bulk 올리기.
	 } else if ([api isEqualToString:@"getFriendsList"]) {		// 전체 친구 프로필 리스트 가져오기
	 } else if ([api isEqualToString:@"updateListContact"]) {				// 주소 멀티 그룹 수정.
	 } else if ([api isEqualToString:@"deleteContact"]) {					// 주소 삭제.
	 } else if ([api isEqualToString:@"deleteListContact"]) {				// 주소 멀티 삭제.
	 } else if ([api isEqualToString:@"deleteGroup"]) {						// 주소록 - 그룹 삭제.
	 } else if ([api isEqualToString:@"toggleCommStatus"]) {
	 if ([aHttpAgent.delegateParameter.requestSubApi isEqualToString:@"BlockUserOk"]) {				// 주소록 - 친구 차단 하기
	 api = @"BlockUserOk";
	 } else if ([aHttpAgent.delegateParameter.requestSubApi isEqualToString:@"BlockUserCancel"]) {	// 설정 - 차단 친구 목록 - 친구 차단 해제 하기
	 api = @"BlockUserCancel";
	 }
	 } else if ([api isEqualToString:@"albumUpload"]) {
	 if ([aHttpAgent.delegateParameter.requestSubApi isEqualToString:@"insertProfilePhoto"]) {			// 프로필 사진 올리기
	 api = @"insertProfilePhoto";
	 } else if ([aHttpAgent.delegateParameter.requestSubApi isEqualToString:@"updateProfilePhoto"]) {	// 프로필 사진 올리기
	 api = @"insertProfilePhoto";
	 } else if ([aHttpAgent.delegateParameter.requestSubApi isEqualToString:@"insertContactPhoto"]) {	// 주소록 사진 올리기
	 } else if ([aHttpAgent.delegateParameter.requestSubApi isEqualToString:@"updateContactPhoto"]) {	// 주소록 사진 올리기
	 
	 } else if ([aHttpAgent.delegateParameter.requestSubApi isEqualToString:@"insertMsgMediaPhoto"]) {	// 대화시 사진/동영상 보내기
	 NSArray *checkDBMessageInfoArray = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where CHATSESSION=? and SESSIONKEY=?", 
	 aHttpAgent.delegateParameter.sessionKey, aHttpAgent.delegateParameter.messageKey, nil];
	 if (checkDBMessageInfoArray && [checkDBMessageInfoArray count] > 0) {
	 [MessageInfo findWithSqlWithParameters:@"update _TMessageInfo set ISSUCCESS=? where CHATSESSION=? and SESSIONKEY=?", 
	 @"-1", aHttpAgent.delegateParameter.sessionKey, aHttpAgent.delegateParameter.messageKey, nil];
	 }
	 @synchronized(msgArray) {
	 if (msgArray && [msgArray count] > 0) {
	 for (CellMsgData *msgData in msgArray) {
	 if ([msgData.chatsession isEqualToString:aHttpAgent.delegateParameter.sessionKey] && 
	 [msgData.messagekey isEqualToString:aHttpAgent.delegateParameter.messageKey]) {
	 msgData.sendMsgSuccess = @"-1";
	 break;
	 }
	 }
	 }
	 }
	 NSString *openChatSession = [self.myInfoDictionary objectForKey:@"openChatSession"];
	 if (openChatSession && [openChatSession length] > 0 && [openChatSession isEqualToString:aHttpAgent.delegateParameter.sessionKey]) {
	 [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadMessage" object:aHttpAgent.delegateParameter.sessionKey];
	 }
	 } else {
	 // skip
	 return;
	 }
	 } else if ([api isEqualToString:@"albumUploadComplete"]) {
	 if ([aHttpAgent.delegateParameter.requestSubApi isEqualToString:@"insertProfilePhoto"]) {			// 프로필 사진 올리기
	 api = @"completeProfilePhoto";
	 } else if ([aHttpAgent.delegateParameter.requestSubApi isEqualToString:@"updateProfilePhoto"]) {	// 프로필 사진 올리기
	 api = @"completeProfilePhoto";
	 } else if ([aHttpAgent.delegateParameter.requestSubApi isEqualToString:@"insertContactPhoto"]) {	// 주소록 사진 올리기
	 } else if ([aHttpAgent.delegateParameter.requestSubApi isEqualToString:@"updateContactPhoto"]) {	// 주소록 사진 올리기
	 
	 } else if ([aHttpAgent.delegateParameter.requestSubApi isEqualToString:@"insertMsgMediaPhoto"]) {	// 대화시 사진/동영상 보내기
	 NSArray *checkDBMessageInfoArray = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where CHATSESSION=? and SESSIONKEY=?", 
	 aHttpAgent.delegateParameter.sessionKey, aHttpAgent.delegateParameter.messageKey, nil];
	 if (checkDBMessageInfoArray && [checkDBMessageInfoArray count] > 0) {
	 [MessageInfo findWithSqlWithParameters:@"update _TMessageInfo set ISSUCCESS=? where CHATSESSION=? and SESSIONKEY=?", 
	 @"-1", aHttpAgent.delegateParameter.sessionKey, aHttpAgent.delegateParameter.messageKey, nil];
	 }
	 @synchronized(msgArray) {
	 if (msgArray && [msgArray count] > 0) {
	 for (CellMsgData *msgData in msgArray) {
	 if ([msgData.chatsession isEqualToString:aHttpAgent.delegateParameter.sessionKey] && 
	 [msgData.messagekey isEqualToString:aHttpAgent.delegateParameter.messageKey]) {
	 msgData.sendMsgSuccess = @"-1";
	 break;
	 }
	 }
	 }
	 }
	 NSString *openChatSession = [self.myInfoDictionary objectForKey:@"openChatSession"];
	 if (openChatSession && [openChatSession length] > 0 && [openChatSession isEqualToString:aHttpAgent.delegateParameter.sessionKey]) {
	 [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadMessage" object:aHttpAgent.delegateParameter.sessionKey];
	 }
	 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
	 [alertView show];
	 [alertView release];
	 } else {
	 // skip
	 return;
	 }
	 } else if ([api isEqualToString:@"createNewMessage"]) {					// 대화 - 새로운 메시지 생성 (텍스트 메시지 보내기)
	 NSArray *checkDBMessageInfoArray = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where CHATSESSION=? and SESSIONKEY=?", 
	 aHttpAgent.delegateParameter.sessionKey, aHttpAgent.delegateParameter.messageKey, nil];
	 if (checkDBMessageInfoArray && [checkDBMessageInfoArray count] > 0) {
	 [MessageInfo findWithSqlWithParameters:@"update _TMessageInfo set ISSUCCESS=? where CHATSESSION=? and SESSIONKEY=?", 
	 @"-1", aHttpAgent.delegateParameter.sessionKey, aHttpAgent.delegateParameter.messageKey, nil];
	 }
	 @synchronized(msgArray) {
	 if (msgArray && [msgArray count] > 0) {
	 for (CellMsgData *msgData in msgArray) {
	 if ([msgData.chatsession isEqualToString:aHttpAgent.delegateParameter.sessionKey] && 
	 [msgData.messagekey isEqualToString:aHttpAgent.delegateParameter.messageKey]) {
	 msgData.sendMsgSuccess = @"-1";
	 break;
	 }
	 }
	 }
	 }
	 NSString *openChatSession = [self.myInfoDictionary objectForKey:@"openChatSession"];
	 if (openChatSession && [openChatSession length] > 0 && [openChatSession isEqualToString:aHttpAgent.delegateParameter.sessionKey]) {
	 [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadMessage" object:aHttpAgent.delegateParameter.sessionKey];
	 }
	 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
	 [alertView show];
	 [alertView release];
	 return;
	 } else if ([api isEqualToString:@"requestMakeFriend"]) {				// 친구 신청
	 } else if ([api isEqualToString:@"getMakeSendList"]) {					// 친구 신청 리스트 조회
	 } else if ([api isEqualToString:@"getMakeReceivedList"]) {				// 친구 요청 리스트 조회
	 } else if ([api isEqualToString:@"getGroupsForMobile"]) {				// 주소록 - 그룹 리스트 조회
	 } else if ([api isEqualToString:@"addGroup"]) {							// 주소록 - 그룹 추가
	 } else if ([api isEqualToString:@"updateGroup"]) {						// 주소록 - 그룹 수정
	 } else if ([api isEqualToString:@"deleteGroupForMobile"]) {				// 주소록 - 그룹 삭제
	 } else if ([api isEqualToString:@"getContacts"]) {						// 주소록 - 주소 리스트 조회
	 } else if ([api isEqualToString:@"getGroups"]) {						// 주소록 - 그룹 정보 얻어오기
	 } else if ([api isEqualToString:@"addContact"]) {						// 주소록 - 주소 추가
	 } else if ([api isEqualToString:@"updateContact"]) {					// 주소록 - 주소 수정
	 } else if ([api isEqualToString:@"deleteContactForMobile"]) {			// 주소록 - 주소 삭제
	 } else if ([api isEqualToString:@"getHistoryByRP"]) {					// 주소록 싱크 - RP 히스토리 별 조회
	 } else if ([api isEqualToString:@"getLastAfterRP"]) {					// 주소록 싱크 - RP 마지막 변경 내용 조회
	 } else if ([api isEqualToString:@"getAllAtRP"]) {						// 주소록 싱크 - 특정 시점의 RP 형상 조회
	 } else if ([api isEqualToString:@"getCountByRP"]) {						// 주소록 싱크 - 특정 시점의 RP 형상 조회
	 } else if ([api isEqualToString:@"getChatParticipants"]) {				// 대화 - 참가자 정보 가져오기
	 } else if ([api isEqualToString:@"getMyChatSessionList"]) {				// 대화 - 전체 메시지 가져오기
	 } else if ([api isEqualToString:@"retrieveSessionMessage"]) {			// 대화 - 대화 메시지 가져오기
	 } else if ([api isEqualToString:@"joinToChatSession"]) {				// 대화 - 대화 세션 참가
	 } else if ([api isEqualToString:@"quitFromChatSession"]) {				// 대화 - 대화 세션에서 나가기
	 } else if ([api isEqualToString:@"getReadMark"]) {						// 대화 - 메시지에 대한 읽은 카운트수 가져오기
	 } else if ([api isEqualToString:@"deleteMyMessage"]) {					// 대화 - 메시지 지우기
	 } else if ([api isEqualToString:@"retrieveSystemMessage"]) {			// 시스템 정보 메시지 가져오기
	 } else if ([api isEqualToString:@"getRecommendFriendsList"]) {			// 추천 친구 - 추친 친구 리스트 가져오기
	 } else if ([api isEqualToString:@"setFriendFromRecommand"]) {			// 추천 친구 - 친구 수락
	 } else if ([api isEqualToString:@"deleteRecommendFriend"]) {			// 추천 친구 목록에서 삭제하기
	 } else if ([api isEqualToString:@"loadProfile"]) {						// 설정 - 프로필 설정 - 전체 정보 가져오기
	 } else if ([api isEqualToString:@"loadSimpleProfile"]) {				// 설정 - 프로필 설정 - simple 정보 가져오기
	 } else if ([api isEqualToString:@"getChangedProfileInfo"]) {		// 초기 정보 - 버디들의 최근 정보 가져오기
	 } else if ([api isEqualToString:@"deleteProfilePhoto"]) {				// 설정 - 프로필 설정 - 사진 삭제
	 } else if ([api isEqualToString:@"serRepresentPhoto"]) {				// 설정 - 프로필 설정 - 사진 선택 (대표사진 선택)	
	 } else if ([api isEqualToString:@"updatePresence"]) {					// 설정 - 프로필 설정 - 상태 설정
	 } else if ([api isEqualToString:@"updateNickName"]) {					// 설정 - 프로필 설정 - 별명 설정
	 } else if ([api isEqualToString:@"updateStatus"]) {						// 설정 - 프로필 설정 - 오늘의 한마디 설정
	 } else if ([api isEqualToString:@"updateMyInfo"]) {						// 설정 - 프로필 설정 - 내 정보 설정 하기
	 } else if ([api isEqualToString:@"setMessagePreviewOnMobile"]) {		// 설정 - 알림 설정 - 내용 미리보기
	 } else if ([api isEqualToString:@"getBlockedFriendsList"]) {			// 설정 - 차단 친구 목록 - 차단 친구 프로필 리스트 가져오기
	 } else {
	 // error skip!
	 return;
	 }
	 
	 [[NSNotificationCenter defaultCenter] postNotificationName:api object:nil];
	 //*/
}

- (void)request:(HttpAgent*)aHttpAgent hadStatusCodeErrorWithResponse:(NSURLResponse *)aResponse
{
	//	NSLog(@"request:(HttpAgent*)aHttpAgent hadStatusCodeErrorWithResponse:(NSURLResponse *)aResponse");
}

- (void)reloadProgress:(HttpAgent*)aHttpAgent Persent:(CGFloat)persent
{
/*	
mezzo 20100914 kjh sessionKey 문제 out of scope 로 나온다 sessionKey 값이 제대로 할당이 안된다. alloc 로 변경함
 이부분을
 httpAgent.delegateParameter.sessionKey = data.sessionKey
 다음과 같이 변경
 httpAgent.delegateParameter.sessionKey = [[NSString alloc] initWithString:data.sessionKey];
 
*/	
	/*
//	NSLog(@"delegate reloadProgress progress = %f", persent);
	if(aHttpAgent.delegateParameter.sessionKey)
	NSLog(@"sessionKey = %@", aHttpAgent.delegateParameter.sessionKey);
	   else
	   NSLog(@"=============NOT FOUND============");
*/
	 @synchronized(msgArray) {
		NSString *openChatSession = [self.myInfoDictionary objectForKey:@"openChatSession"];
		//		NSLog(@"delegate reloadProgress progress 1");
		if (msgArray && [msgArray count] > 0) {
			//			NSLog(@"delegate reloadProgress progress 2");
			for (CellMsgData *msgData in msgArray) {
				//				NSLog(@"delegate reloadProgress progress 3");
				if([msgData.messagekey isEqualToString:aHttpAgent.delegateParameter.messageKey]) {	// messageKey 값은 임시로 넣은 값.
					//					NSLog(@"delegate reloadProgress progress 4");
					if (1.0f == (float)(persent/100.0f)) {
												//NSLog(@"delegate reloadProgress progress 5");
						[msgData setMediaProgressPos:(float)(persent/100.0f)];
						if (openChatSession != nil && [openChatSession isEqualToString:aHttpAgent.delegateParameter.sessionKey]) {
													//	NSLog(@"delegate reloadProgress progress 6");
													//	NSLog(@"delegate 에서 progress 전송 progress=%f", [msgData mediaProgressPos]);
							[[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadMessage" object:aHttpAgent.delegateParameter.sessionKey];
						}
					} else if (msgData.mediaProgressPos < 0.2f && (float)(persent/100.0f) >= 0.2f && (float)(persent/100.0f) < 0.3f) {
											//	NSLog(@"delegate reloadProgress progress 7");
						[msgData setMediaProgressPos:(float)(persent/100.0f)];
						if (openChatSession != nil && [openChatSession isEqualToString:aHttpAgent.delegateParameter.sessionKey]) {
												//		NSLog(@"delegate reloadProgress progress 8");
												//		NSLog(@"delegate 에서 progress 전송 progress=%f", [msgData mediaProgressPos]);
						//	NSLog(@"BEFORE");
							[[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadMessage" object:aHttpAgent.delegateParameter.sessionKey];
						//	NSLog(@"RELOAD AFTER");
						}
					} else if (msgData.mediaProgressPos < 0.4f && (float)(persent/100.0f) >= 0.4f && (float)(persent/100.0f) < 0.5f) {
										//		NSLog(@"delegate reloadProgress progress 9");
						[msgData setMediaProgressPos:(float)(persent/100.0f)];
						if (openChatSession != nil && [openChatSession isEqualToString:aHttpAgent.delegateParameter.sessionKey]) {
													//	NSLog(@"delegate reloadProgress progress 10");
													//	NSLog(@"delegate 에서 progress 전송 progress=%f", [msgData mediaProgressPos]);
							[[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadMessage" object:aHttpAgent.delegateParameter.sessionKey];
						}
					} else if (msgData.mediaProgressPos < 0.6f &&  (float)(persent/100.0f) >= 0.6f && (float)(persent/100.0f) < 0.7f) {
											//	NSLog(@"delegate reloadProgress progress 11");
						[msgData setMediaProgressPos:(float)(persent/100.0f)];
						if (openChatSession != nil && [openChatSession isEqualToString:aHttpAgent.delegateParameter.sessionKey]) {
											//			NSLog(@"delegate reloadProgress progress 12");
											//			NSLog(@"delegate 에서 progress 전송 progress=%f", [msgData mediaProgressPos]);
							[[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadMessage" object:aHttpAgent.delegateParameter.sessionKey];
						}
					} else if (msgData.mediaProgressPos < 0.8f && (float)(persent/100.0f) >= 0.8f && (float)(persent/100.0f) < 0.9f) {
											//	NSLog(@"delegate reloadProgress progress 13");
						[msgData setMediaProgressPos:(float)(persent/100.0f)];
						if (openChatSession != nil && [openChatSession isEqualToString:aHttpAgent.delegateParameter.sessionKey]) {
											//			NSLog(@"delegate reloadProgress progress 14");
											//			NSLog(@"delegate 에서 progress 전송 progress=%f", [msgData mediaProgressPos]);
							[[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadMessage" object:aHttpAgent.delegateParameter.sessionKey];
						}
					} else {
											//	NSLog(@"delegate reloadProgress progress 15");
						[msgData setMediaProgressPos:(float)(persent/100.0f)];
					}
				}
			}
		}
	}
	//*/
}

#pragma mark -
#pragma mark RequestTimerOutTimer		// OS에서 제공하는 API에서 Http timeout 설정을 해도 정상 동작을 하지 않아서 추가
-(void)requestTimerOutAction:(NSTimer *)timer
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	//	NSLog(@"requestTimerOutAction 1");
	HttpAgent *httpAgent = (HttpAgent*)[timer userInfo];
	[requestTimeOutTimer invalidate];
	[requestTimeOutTimer release];
	requestTimeOutTimer = nil;
	
	if (httpAgent) {
		//		NSLog(@"requestTimerOutAction 2");
		if ([httpAgent isRequest]) {
			//			NSLog(@"requestTimerOutAction 3 cancelRequest");
			[httpAgent cancelRequest];
		}
		//		NSLog(@"requestTimerOutAction 4");
		if (httpAgent.delegateParameter.requestApi && [httpAgent.delegateParameter.requestApi length] > 0) {
			//			NSLog(@"requestTimerOutAction 5");
			if ([httpAgent.delegateParameter.requestApi isEqualToString:@"initOnMobile"]) {
								NSLog(@"requestTimerOutAction initOnMobile timeout");
				[[NSNotificationCenter defaultCenter] postNotificationName:@"initOnMobile" object:@"FAIL"];
			} else if ([httpAgent.delegateParameter.requestApi isEqualToString:@"loginOnMobile"]) {
								NSLog(@"requestTimerOutAction loginOnMobile timeout");
				[[NSNotificationCenter defaultCenter] postNotificationName:@"loginOnMobile" object:nil];
			} else if ([httpAgent.delegateParameter.requestApi isEqualToString:@"loadProfile"]) {
								NSLog(@"requestTimerOutAction loadProfile timeout");
				[[NSNotificationCenter defaultCenter] postNotificationName:@"loadProfile" object:nil];
			} else if ([httpAgent.delegateParameter.requestApi isEqualToString:@"updateNickName"]) {
								NSLog(@"requestTimerOutAction updateNickName timeout");
				[[NSNotificationCenter defaultCenter] postNotificationName:@"updateNickName" object:nil];
			} else if ([httpAgent.delegateParameter.requestApi isEqualToString:@"updateStatus"]) {
								NSLog(@"requestTimerOutAction updateStatus timeout");
				[[NSNotificationCenter defaultCenter] postNotificationName:@"updateStatus" object:nil];
			} else if ([httpAgent.delegateParameter.requestApi isEqualToString:@"updateMyInfo"]) {
								NSLog(@"requestTimerOutAction updateMyInfo timeout");
				[[NSNotificationCenter defaultCenter] postNotificationName:@"updateMyInfo" object:nil];
			} else if ([httpAgent.delegateParameter.requestApi isEqualToString:@"albumUpload"]) {	
				if (httpAgent.delegateParameter.requestSubApi && [httpAgent.delegateParameter.requestSubApi length] > 0) {
					if ([httpAgent.delegateParameter.requestSubApi isEqualToString:@"insertProfilePhoto"]) {
						[[NSNotificationCenter defaultCenter] postNotificationName:@"insertProfilePhoto" object:nil];
					} else if ([httpAgent.delegateParameter.requestSubApi isEqualToString:@"updateProfilePhoto"]) {
						[[NSNotificationCenter defaultCenter] postNotificationName:@"insertProfilePhoto" object:nil];
					}
				}
			} else if ([httpAgent.delegateParameter.requestApi isEqualToString:@"albumUploadComplete"]) {	
				if (httpAgent.delegateParameter.requestSubApi && [httpAgent.delegateParameter.requestSubApi length] > 0) {
					if ([httpAgent.delegateParameter.requestSubApi isEqualToString:@"insertProfilePhoto"]) {
						[[NSNotificationCenter defaultCenter] postNotificationName:@"insertProfilePhoto" object:nil];
					} else if ([httpAgent.delegateParameter.requestSubApi isEqualToString:@"updateProfilePhoto"]) {
						[[NSNotificationCenter defaultCenter] postNotificationName:@"insertProfilePhoto" object:nil];
					}
				}
			}
		}
		//		NSLog(@"requestTimerOutAction 6");
		[httpAgentArray removeObject:httpAgent];
	}
}

#pragma mark -
#pragma mark NSNotification
// Http 패킷 전송
-(void)requestHttp:(NSNotification *)notification
{
	if (connectionType == -1 ||connectionType == 0) {	// -1:offline mode  0:disconnect 1:Wi-Fi 2:3G
		return;
	}
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	USayHttpData *data = (USayHttpData*)[notification object];
	//	assert(data != nil);
	
	NSString *api = data.api;
	//	assert(data != nil);
	
	NSString *url = [self protocolUrl:api];
	//	assert(url != nil);
	DebugLog(@"requestHttp api : %@, url : %@", api, url);

	HttpAgent *httpAgent = [[HttpAgent alloc] init];
	//	assert(httpAgent != nil);
	
	if (httpAgent.delegateParameter.requestApi) {
		[httpAgent.delegateParameter.requestApi release];
		httpAgent.delegateParameter.requestApi = nil;
		httpAgent.delegateParameter.requestApi = api;//[[NSString alloc] initWithString:api];
	} else {
		httpAgent.delegateParameter.requestApi = api;//[[NSString alloc] initWithString:api];
	}
	
	if (data.subApi != nil) {
		if (httpAgent.delegateParameter.requestSubApi) {	// 동일한 requestApi를 사용할때, 구분할수 있도록 추가
			[httpAgent.delegateParameter.requestSubApi release];
			httpAgent.delegateParameter.requestSubApi = nil;
			httpAgent.delegateParameter.requestSubApi = data.subApi;//[[NSString alloc] initWithString:data.subApi];
		} else {
			httpAgent.delegateParameter.requestSubApi = data.subApi;//[[NSString alloc] initWithString:data.subApi];
		}
	}
	
	if ([api isEqualToString:@"albumUploadComplete"]) {	
		if ([data.subApi isEqualToString:@"insertMsgMediaPhoto"]) {
			if (httpAgent.delegateParameter.sessionKey) {	// 예외처리 할때 필요
				[httpAgent.delegateParameter.sessionKey release];
				httpAgent.delegateParameter.sessionKey = nil;
			httpAgent.delegateParameter.sessionKey = [[NSString alloc] initWithString:data.sessionKey];
				//mezzo	httpAgent.delegateParameter.sessionKey = data.sessionKey;//[[NSString alloc] initWithString:data.sessionKey];
			} else {
				httpAgent.delegateParameter.sessionKey = [[NSString alloc] initWithString:data.sessionKey];
			//mezzo	httpAgent.delegateParameter.sessionKey = data.sessionKey;//[[NSString alloc] initWithString:data.sessionKey];
			}
			if (httpAgent.delegateParameter.messageKey) {	
				[httpAgent.delegateParameter.messageKey release];
				httpAgent.delegateParameter.messageKey = nil;
				httpAgent.delegateParameter.messageKey = [[NSString alloc] initWithString:data.messageKey];
		//mezzo		httpAgent.delegateParameter.messageKey = data.messageKey;//[[NSString alloc] initWithString:data.messageKey];
			} else {
				httpAgent.delegateParameter.messageKey = [[NSString alloc] initWithString:data.messageKey];
		//mezzo		httpAgent.delegateParameter.messageKey = data.messageKey;//[[NSString alloc] initWithString:data.messageKey];
			}
		}
	}
	
	// OS에서 제공하는 API에서 Http timeout 설정을 해도 정상 동작을 하지 않아서 추가
	if ([httpAgent.delegateParameter.requestApi isEqualToString:@"initOnMobile"]) {
		//		NSLog(@"requestHttp initOnMobile start requestTimeoutTimer");
		requestTimeOutTimer = [[NSTimer scheduledTimerWithTimeInterval:(CGFloat)data.timeout target:self selector:@selector(requestTimerOutAction:) userInfo:httpAgent repeats:NO] retain];
	} else if ([httpAgent.delegateParameter.requestApi isEqualToString:@"loginOnMobile"]) {
		//		NSLog(@"requestHttp loginOnMobile start requestTimeoutTimer");
		requestTimeOutTimer = [[NSTimer scheduledTimerWithTimeInterval:(CGFloat)data.timeout target:self selector:@selector(requestTimerOutAction:) userInfo:httpAgent repeats:NO] retain];
	} else if ([httpAgent.delegateParameter.requestApi isEqualToString:@"loadProfile"]) {
		//		NSLog(@"requestHttp loadProfile start requestTimeoutTimer");
		requestTimeOutTimer = [[NSTimer scheduledTimerWithTimeInterval:(CGFloat)data.timeout target:self selector:@selector(requestTimerOutAction:) userInfo:httpAgent repeats:NO] retain];	
	} else if ([httpAgent.delegateParameter.requestApi isEqualToString:@"updateNickName"]) {
		//		NSLog(@"requestHttp updateNickName start requestTimeoutTimer");
		requestTimeOutTimer = [[NSTimer scheduledTimerWithTimeInterval:(CGFloat)data.timeout target:self selector:@selector(requestTimerOutAction:) userInfo:httpAgent repeats:NO] retain];	
	} else if ([httpAgent.delegateParameter.requestApi isEqualToString:@"updateStatus"]) {
		//		NSLog(@"requestHttp updateStatus start requestTimeoutTimer");
		requestTimeOutTimer = [[NSTimer scheduledTimerWithTimeInterval:(CGFloat)data.timeout target:self selector:@selector(requestTimerOutAction:) userInfo:httpAgent repeats:NO] retain];	
	} else if ([httpAgent.delegateParameter.requestApi isEqualToString:@"updateMyInfo"]) {
		//		NSLog(@"requestHttp updateMyInfo start requestTimeoutTimer");
		requestTimeOutTimer = [[NSTimer scheduledTimerWithTimeInterval:(CGFloat)data.timeout target:self selector:@selector(requestTimerOutAction:) userInfo:httpAgent repeats:NO] retain];	
	} else if ([httpAgent.delegateParameter.requestApi isEqualToString:@"albumUploadComplete"]) {
		if ([httpAgent.delegateParameter.requestSubApi isEqualToString:@"insertProfilePhoto"]) {
						NSLog(@"requestHttp albumUploadComplete insertProfilePhoto start requestTimeoutTimer");
			//			requestTimeOutTimer = [[NSTimer scheduledTimerWithTimeInterval:(CGFloat)data.timeout target:self selector:@selector(requestTimerOutAction:) userInfo:httpAgent repeats:NO] retain];
		} else if ([httpAgent.delegateParameter.requestSubApi isEqualToString:@"updateProfilePhoto"]) {
						NSLog(@"requestHttp albumUploadComplete updateProfilePhoto start requestTimeoutTimer");
			//			requestTimeOutTimer = [[NSTimer scheduledTimerWithTimeInterval:(CGFloat)data.timeout target:self selector:@selector(requestTimerOutAction:) userInfo:httpAgent repeats:NO] retain];	
		}
	} else {
	}
	
	//	NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] initWithCapacity:10];
	//	NSString *value = nil;
	//	for (id key in data.bodyObjectDic) {
	//		value = [data.bodyObjectDic objectForKey:key];
	//		[bodyDic setObject:value forKey:key];
	//	}
	[httpAgent requestUrl:url bodyObject:data.bodyObjectDic parent:self timeout:data.timeout];
	
	[httpAgentArray addObject:httpAgent];
	[httpAgent release];
	//	[data release];
}

// POST multipart-form fileUpload
-(void)requestUploadUrlMultipartForm:(NSNotification *)notification
{
	if (connectionType == -1 ||connectionType == 0) {	// -1:offline mode  0:disconnect 1:Wi-Fi 2:3G
		return;
	}
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	USayHttpData *data = (USayHttpData*)[notification object];
	//	assert(data != nil);
	
	NSString *api = data.api;
	//	assert(data != nil);
	
	NSString *url = [self protocolUrl:api];
	//	assert(url != nil);
	
	HttpAgent *httpAgent = [[HttpAgent alloc] init];
	//	assert(httpAgent != nil);
	
	if (httpAgent.delegateParameter.requestApi) {
		[httpAgent.delegateParameter.requestApi release];
		httpAgent.delegateParameter.requestApi = nil;
		httpAgent.delegateParameter.requestApi = api;//[[NSString alloc] initWithString:api];
	} else {
		httpAgent.delegateParameter.requestApi = api;//[[NSString alloc] initWithString:api];
	}
	
	if (data.subApi != nil) {
		if (httpAgent.delegateParameter.requestSubApi) {	// 동일한 requestApi를 사용할때, 구분할수 있도록 추가
			[httpAgent.delegateParameter.requestSubApi release];
			httpAgent.delegateParameter.requestSubApi = nil;
			httpAgent.delegateParameter.requestSubApi = data.subApi;//[[NSString alloc] initWithString:data.subApi];
		} else {
			httpAgent.delegateParameter.requestSubApi = data.subApi;//[[NSString alloc] initWithString:data.subApi];
		}
	}
	if (data.uniqueId != nil) {
		if (httpAgent.delegateParameter.uniqueId) {
			[httpAgent.delegateParameter.uniqueId release];
			httpAgent.delegateParameter.uniqueId = nil;
			httpAgent.delegateParameter.uniqueId = data.uniqueId;//[[NSString alloc] initWithString:data.uniqueId];
		} else {
			httpAgent.delegateParameter.uniqueId = data.uniqueId;//[[[NSString alloc] initWithString:data.uniqueId] autorelease];
		}
	}
	if (data.filePath != nil) {
		if (httpAgent.delegateParameter.filePath) {
			[httpAgent.delegateParameter.filePath release];
			httpAgent.delegateParameter.filePath = nil;
			httpAgent.delegateParameter.filePath = data.filePath;//[[NSString alloc] initWithString:data.filePath];
		} else {
			httpAgent.delegateParameter.filePath = data.filePath;//[[NSString alloc] initWithString:data.filePath];
		}
	}
	if (data.mediaData != nil) {
		if (httpAgent.delegateParameter.mediaData) {
			[httpAgent.delegateParameter.mediaData release];
			httpAgent.delegateParameter.mediaData = nil;
			httpAgent.delegateParameter.mediaData = data.mediaData;//[[NSData alloc] initWithData:data.mediaData];
		} else {
			httpAgent.delegateParameter.mediaData = data.mediaData;//[[NSData alloc] initWithData:data.mediaData];
		}
	}
	
	if ([api isEqualToString:@"albumUpload"]) {		
		if ([data.subApi isEqualToString:@"insertProfilePhoto"]) {			// 프로필 사진 올리기
			if (data.isRepresent != nil) {
				if (httpAgent.delegateParameter.isRepresent) {
					[httpAgent.delegateParameter.isRepresent release];
					httpAgent.delegateParameter.isRepresent = nil;
					httpAgent.delegateParameter.isRepresent = data.isRepresent;//[[NSString alloc] initWithString:data.isRepresent];
				} else {
					httpAgent.delegateParameter.isRepresent = data.isRepresent;//[[NSString alloc] initWithString:data.isRepresent];
				}
			}
			// OS에서 제공하는 API에서 Http timeout 설정을 해도 정상 동작을 하지 않아서 추가
			//			NSLog(@"requestHttp albumUpload insertProfilePhoto start requestTimeoutTimer");
			//			requestTimeOutTimer = [[NSTimer scheduledTimerWithTimeInterval:(CGFloat)data.timeout target:self selector:@selector(requestTimerOutAction:) userInfo:httpAgent repeats:NO] retain];
		} else if ([data.subApi isEqualToString:@"updateProfilePhoto"]) {	// 프로필 사진 올리기
			if (data.isRepresent != nil) {
				if (httpAgent.delegateParameter.isRepresent) {
					[httpAgent.delegateParameter.isRepresent release];
					httpAgent.delegateParameter.isRepresent = nil;
					httpAgent.delegateParameter.isRepresent = data.isRepresent;//[[NSString alloc] initWithString:data.isRepresent];
				} else {
					httpAgent.delegateParameter.isRepresent = data.isRepresent;//[[NSString alloc] initWithString:data.isRepresent];
				}
			}
			// OS에서 제공하는 API에서 Http timeout 설정을 해도 정상 동작을 하지 않아서 추가
			//			NSLog(@"requestHttp albumUpload updateProfilePhoto start requestTimeoutTimer");
			//			requestTimeOutTimer = [[NSTimer scheduledTimerWithTimeInterval:(CGFloat)data.timeout target:self selector:@selector(requestTimerOutAction:) userInfo:httpAgent repeats:NO] retain];
		} else if ([data.subApi isEqualToString:@"insertContactPhoto"]) {	// 주소록 사진 올리기
			NSLog(@"insert photo");
			if (httpAgent.delegateParameter.cid) {
				[httpAgent.delegateParameter.cid release];
				httpAgent.delegateParameter.cid = nil;
				httpAgent.delegateParameter.cid = data.cid;//[[NSString alloc] initWithString:data.cid];
			} else {
				httpAgent.delegateParameter.cid = data.cid;//[[NSString alloc] initWithString:data.cid];
			}
		} else if ([data.subApi isEqualToString:@"updateContactPhoto"]) {	// 주소록 사진 올리기
			if (httpAgent.delegateParameter.cid) {
				[httpAgent.delegateParameter.cid release];
				httpAgent.delegateParameter.cid = nil;
				httpAgent.delegateParameter.cid = data.cid;//[[NSString alloc] initWithString:data.cid];
			} else {
				httpAgent.delegateParameter.cid = data.cid;//[[NSString alloc] initWithString:data.cid];
			}
		} else if ([data.subApi isEqualToString:@"insertMsgMediaPhoto"]) {	// 대화시 사진/동영상 보내기
			if (httpAgent.delegateParameter.sessionKey) {	// 예외처리 할때 필요
				[httpAgent.delegateParameter.sessionKey release];
				httpAgent.delegateParameter.sessionKey = nil;
				httpAgent.delegateParameter.sessionKey = [[NSString alloc] initWithString:data.sessionKey];
			//mezzo	httpAgent.delegateParameter.sessionKey = data.sessionKey;//[[NSString alloc] initWithString:data.sessionKey];
			} else {
				httpAgent.delegateParameter.sessionKey = [[NSString alloc] initWithString:data.sessionKey];
			//mezzo	httpAgent.delegateParameter.sessionKey = data.sessionKey;//[[NSString alloc] initWithString:data.sessionKey];
			}
			if (httpAgent.delegateParameter.messageKey) {	
				[httpAgent.delegateParameter.messageKey release];
				httpAgent.delegateParameter.messageKey = nil;
				httpAgent.delegateParameter.messageKey = data.messageKey;//[[NSString alloc] initWithString:data.messageKey];
			} else {
				httpAgent.delegateParameter.messageKey = data.messageKey;//[[NSString alloc] initWithString:data.messageKey];
			}
			if (httpAgent.delegateParameter.mType) {
				[httpAgent.delegateParameter.mType release];
				httpAgent.delegateParameter.mType = nil;
				httpAgent.delegateParameter.mType = data.mType;//[[NSString alloc] initWithString:data.mType];
			} else {
				httpAgent.delegateParameter.mType = data.mType;//[[NSString alloc] initWithString:data.mType];
			}
			if (data.message && [data.message length] > 0) {
				if (httpAgent.delegateParameter.message) {	
					[httpAgent.delegateParameter.message release];
					httpAgent.delegateParameter.message = nil;
					httpAgent.delegateParameter.message = data.message;//[[NSString alloc] initWithString:data.message];
				} else {
					httpAgent.delegateParameter.message = data.message;//[[NSString alloc] initWithString:data.message];
				}
			}
		} else {
			// skip
			[httpAgent release];
			//			[data release];
			[[NSNotificationCenter defaultCenter] postNotificationName:api object:nil];
			return;
		}
	}
	
	//	NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] initWithCapacity:10];
	//	NSString *value = nil;
	//	for (id key in data.bodyObjectDic) {
	//		value = [data.bodyObjectDic objectForKey:key];
	//		[bodyDic setObject:value forKey:key];
	//	}
	
	[httpAgent requestUploadUrlMultipartForm:url bodyObject:data.bodyObjectDic parent:self timeout:data.timeout];
	
	//	[httpAgent _startSend:data.filePath url:url];
	[httpAgentArray addObject:httpAgent];
	[httpAgent release];
	//	[data release];
}

// 시스템 정보메시지 가져오기 (대화의 시스템 정보메시지를 가져온다 (채팅 세션 개설, 공지사항 등))
-(void)retrieveSystemMessage:(NSNotification *)notification
{
	
	NSLog(@"들어온다....");
	USayHttpData *data = (USayHttpData*)[notification object];
	if (data == nil) {
		// 200 이외의 에러
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0045)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
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
	rtcode = [dic objectForKey:@"rtcode"];
	
	if ([rtcode isEqualToString:@"0"]) {	// success
		//		NSString *count = [dic objectForKey:@"count"];
		NSString *rtType = [dic objectForKey:@"rttype"];
		
		NSLog(@"======rtType 1 : %@", rtType);
		if ([rtType isEqualToString:@"list"]) {
			// Key and Dictionary as its value type
			NSArray *listArray = [dic objectForKey:@"list"];
			//			assert(listArray != nil);
			for (int i=0; i < [listArray count]; i++) {
				NSDictionary *listDic = [listArray objectAtIndex:i];
				//				assert(listDic != nil);
				NSString *nCount = [listDic objectForKey:@"nCount"];			// 신규 메시지 카운트 수
				NSString *sType = [listDic objectForKey:@"sType"];				// C : 생성   U : 업데이트
				NSString *sessionKey = [listDic objectForKey:@"sessionKey"];
				NSString *pCount = [listDic objectForKey:@"pCount"];			// 참가자 카운트 수
				NSString *cType = [listDic objectForKey:@"cType"];				// 채팅세션 타입 P: 1:1  G: 그룹
				NSString *mType = [listDic objectForKey:@"mType"];
				
				NSString *lastMsg = [listDic objectForKey:@"message"];
				NSString *lastMsgDate = [listDic objectForKey:@"lastMessageCreateTime"];	// unix timestamp server 13자리
				NSString *lastUpdateTime = [listDic objectForKey:@"lastUpdateTime"];		// unix timestamp server 13자리
				NSString *lastMsgUpdate = [listDic objectForKey:@"lastMsgUpdate"];
				
				NSLog(@"======nCount 1 : %@", nCount);
				NSLog(@"======sType 1 : %@", sType);
				NSLog(@"======pCount 1 : %@", pCount);
				NSLog(@"======cType 1 : %@", cType);
				NSLog(@"======mType 1 : %@", mType);
				NSLog(@"======lastMsg 1 : %@", lastMsg);
				NSLog(@"======lastMsgDate 1 : %@", lastMsgDate);
				NSLog(@"======lastUpdateTime 1 : %@", lastUpdateTime);
				NSLog(@"======lastMsgUpdate 1 : %@", lastMsgUpdate);
				
				// mezzo 10.09.17
				// open 된 채팅방 확인후 retrieveSessionMessage 발송
				// TODO : NOTI_CHAT_RECORD open된 메시지 창과 chatsessionkey 과 동일하면 retrieveSessionMessage 요청														
				NSString *openChatSession = [self.myInfoDictionary objectForKey:@"openChatSession"];
				
				if ([openChatSession isEqualToString:sessionKey]) {
					CellMsgListData *msgListData = [self MsgListDataFromChatSession:sessionKey];
					
					NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
					[bodyObject setObject:sessionKey forKey:@"sessionKey"];
					[bodyObject setObject:[self getSvcIdx] forKey:@"svcidx"];
					if (msgListData) {
						if (msgListData.lastmessagekey && [msgListData.lastmessagekey length] > 0) {
							[bodyObject setObject:msgListData.lastmessagekey forKey:@"lastMessageKey"];
						} else {
							// skip
						}
					}
					
					// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
					USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"retrieveSessionMessage" andWithDictionary:bodyObject timeout:10] autorelease];
					//																	assert(data != nil);
					[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
				} 
				
				if (lastMsg && [lastMsg length] > 0) {
					if ( [sType isEqualToString:@"C"] || [sType isEqualToString:@"U"] ) { 
						TempMsgListData *tempMsgListData = [[TempMsgListData alloc] init];
						tempMsgListData.nCount = nCount;
						tempMsgListData.sType = sType;
						tempMsgListData.pCount = pCount;
						tempMsgListData.cType = cType;
						tempMsgListData.lastMsgType = mType;
						tempMsgListData.lastMsg = lastMsg;
						tempMsgListData.lastMsgDate = [NSNumber numberWithLongLong:[lastMsgDate longLongValue]];	
						tempMsgListData.lastUpdateTime = [NSNumber numberWithLongLong:[lastUpdateTime longLongValue]];
						[tempMsgListDic setObject:tempMsgListData forKey:sessionKey];
						[tempMsgListData release];
						
						NSLog(@"======tempMsgListData.nCount 2 : %@", nCount);
						
						NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
						//						assert(bodyObject != nil);
						[bodyObject setObject:sessionKey forKey:@"sessionKey"];
						[bodyObject setObject:[self getSvcIdx] forKey:@"svcidx"];
						
						NSArray *checkDBRoomInfoArray = [RoomInfo findWithSqlWithParameters:@"select * from _TRoomInfo where CHATSESSION=?", sessionKey, nil];
						if (checkDBRoomInfoArray && [checkDBRoomInfoArray count] > 0) {
							NSNumber *lastSessionUpdateTimeNumber = nil;
							for (RoomInfo *roomInfo in checkDBRoomInfoArray) {
								lastSessionUpdateTimeNumber = roomInfo.LASTUPDATETIME;
							}
							if (lastSessionUpdateTimeNumber) {
								[bodyObject setObject:[NSString stringWithFormat:@"%llu",[lastSessionUpdateTimeNumber longLongValue]] forKey:@"lastUpdateTime"];
							} else {
								// skip
							}
						} else {
							// skip
						}
						
						// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
						USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"getChatParticipants" andWithDictionary:bodyObject timeout:10] autorelease];
						//						assert(data != nil);
						[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
					} else if ( [sType isEqualToString:@"N"] && [lastMsgUpdate isEqualToString:@"Y"] ) {
						TempMsgListData *tempMsgListData = [[TempMsgListData alloc] init];
						tempMsgListData.nCount = nCount;
						tempMsgListData.sType = sType;
						tempMsgListData.pCount = pCount;
						tempMsgListData.cType = cType;
						tempMsgListData.lastMsgType = mType;
						tempMsgListData.lastMsg = lastMsg;
						tempMsgListData.lastMsgDate = [NSNumber numberWithLongLong:[lastMsgDate longLongValue]];	
						tempMsgListData.lastUpdateTime = [NSNumber numberWithLongLong:[lastUpdateTime longLongValue]];
						
						[tempMsgListDic setObject:tempMsgListData forKey:sessionKey];
						
						NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
						//						assert(bodyObject != nil);
						[bodyObject setObject:sessionKey forKey:@"sessionKey"];
						[bodyObject setObject:[self getSvcIdx] forKey:@"svcidx"];
						NSArray *checkDBRoomInfoArray = [RoomInfo findWithSqlWithParameters:@"select * from _TRoomInfo where CHATSESSION=?", sessionKey, nil];
						if (checkDBRoomInfoArray && [checkDBRoomInfoArray count] > 0) {
							
							[RoomInfo findWithSqlWithParameters:@"update _TRoomInfo set LASTMSG=?, LASTMSGTYPE=?, LASTMSGDATE=?, NEWMSGCOUNT=? where CHATSESSION=?", 
							 lastMsg, mType, tempMsgListData.lastUpdateTime, [NSNumber numberWithInt:[nCount intValue]], sessionKey, nil];
							
							NSNumber *lastSessionUpdateTimeNumber = nil;
							for (RoomInfo *roomInfo in checkDBRoomInfoArray) {
								lastSessionUpdateTimeNumber = roomInfo.LASTUPDATETIME;
							}
							if (lastSessionUpdateTimeNumber) {
								[bodyObject setObject:[NSString stringWithFormat:@"%llu",[lastSessionUpdateTimeNumber longLongValue]] forKey:@"lastUpdateTime"];
							} else {
								// skip
							}
						} else {
							// skip
						}
						
						
						if (self.msgListArray && [msgListArray count] > 0) {
							for (CellMsgListData *msgListData in msgListArray) {
								if ([msgListData.chatsession isEqualToString:sessionKey]) {
									msgListData.newMsgCount = [nCount intValue];
									
									NSLog(@"======msgListData.newMsgCount 1 : %d", [nCount intValue]);
									break;
								}
							}
						}
						
						//mezzo 20101001 수정완료
						if (msgListArray && [msgListArray count] > 0) {
							for (CellMsgListData *msgListData in msgListArray) {
								if ([msgListData.chatsession isEqualToString:sessionKey]) {
									msgListData.lastMsg = [NSString stringWithString:lastMsg];
									NSLog(@"lastMsg =%@", msgListData.lastMsg);
									break;
								} else {
								}
							}
						}
						
						
						[tempMsgListData release];
						
						
						// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
						USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"getChatParticipants" andWithDictionary:bodyObject timeout:10] autorelease];
						//						assert(data != nil);
						[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
					} else {
						
					}
				}
			}
			
			// DB에서 읽어서 Badge표기
			NSInteger nNewMsgCount = [self newMessageCount];
			if (nNewMsgCount == 0) {
				UITabBarItem *tbi = [rootController.tabBar.items objectAtIndex:2]; //기존 1->2로
				if (tbi) {
					tbi.badgeValue = nil;
				}
				NSLog(@"======badgeValue 21 : %d", nNewMsgCount);
				[[UIApplication sharedApplication] setApplicationIconBadgeNumber:nNewMsgCount];
			} else if (nNewMsgCount > 0) {
				UITabBarItem *tbi = [rootController.tabBar.items objectAtIndex:2]; //기존 1->2로
				if (tbi) {
					tbi.badgeValue = [NSString stringWithFormat:@"%i", nNewMsgCount];
				}
				[[UIApplication sharedApplication] setApplicationIconBadgeNumber:nNewMsgCount];
				[self playSystemSoundIDSound];
				[self playSystemSoundIDVibrate];
			//	NSLog(@"======badgeValue 22 : %d", nNewMsgCount);
			//	NSLog(@"root1 %d", rootController.selectedIndex);
				//20101004 대화이동
			//	rootController.selectedIndex=1;
			} else {
				
			}
			
			//20100930 라스트 메세지 표기
			
			
			
			
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadMsgList" object:nil];
			
			
		} else if ([rtType isEqualToString:@"only"]) {
			// DB에서 읽어서 Badge표기
			NSInteger nNewMsgCount = [self newMessageCount];
			if (nNewMsgCount == 0) {
				UITabBarItem *tbi = [rootController.tabBar.items objectAtIndex:2]; //기존 1->2로
				if (tbi) {
					tbi.badgeValue = nil;
				}
				NSLog(@"======badgeValue 1 : %d", nNewMsgCount);
				[[UIApplication sharedApplication] setApplicationIconBadgeNumber:nNewMsgCount];
			} else if (nNewMsgCount > 0) {
				UITabBarItem *tbi = [rootController.tabBar.items objectAtIndex:2]; //기존 1->2로
				if (tbi) {
					tbi.badgeValue = [NSString stringWithFormat:@"%i", nNewMsgCount];
				}
				[[UIApplication sharedApplication] setApplicationIconBadgeNumber:nNewMsgCount];
				[self playSystemSoundIDSound];
				[self playSystemSoundIDVibrate];
				NSLog(@"======badgeValue 2 : %d", nNewMsgCount);
				NSLog(@"root %@",rootController.tabBarController.selectedViewController);	
			} else {
				
			}
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadMsgList" object:nil];
			
		} else {
			// 예외처리
		}
	} else if ([rtcode isEqualToString:@"-9030"]) {
		// 처리 오류
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-9030)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else {
		// TODO: 실패 예외처리 필요
		// fail (-8080 이외 기타오류)
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0046)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	}
}
// 대화에 참가한 참가자 정보를 가져온다.
-(void)getChatParticipantsNotiChatEnter:(NSNotification *)notification
{
	USayHttpData *data = (USayHttpData*)[notification object];
	if (data == nil) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0047)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
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
	NSString *rtcode = [dic objectForKey:@"rtcode"];
	
	if ([rtcode isEqualToString:@"0"]) {	// success
		//		NSString *count = [dic objectForKey:@"count"];
		NSString *rtType = [dic objectForKey:@"rttype"];
		NSString *sessionKey = [dic objectForKey:@"sessionKey"];
		
		//		NSLog(@"getChatParticipants sessionKey = %@", sessionKey);
		NSString *openChatSession = [self.myInfoDictionary objectForKey:@"openChatSession"];
		
		if ([rtType isEqualToString:@"list"]) {
			// Key and Dictionary as its value type
			NSArray *listArray = [dic objectForKey:@"list"];
			//			assert(listArray != nil);
			for (int i=0; i < [listArray count]; i++) {
				NSDictionary *listDic = [listArray objectAtIndex:i];
				//				assert(listDic != nil);
				NSString *representPhoto = [listDic objectForKey:@"representPhoto"];
				NSString *nickName = [listDic objectForKey:@"nickName"];
				NSString *pKey = [listDic objectForKey:@"pKey"];
				NSString *isJoined = [listDic objectForKey:@"isJoined"];
				
				if (sessionKey && [sessionKey length] > 0 && pKey && [pKey length] > 0 && isJoined && [isJoined isEqualToString:@"Y"]) {
					NSArray *checkDBRoomInfo = [RoomInfo findWithSqlWithParameters:@"select * from _TRoomInfo where CHATSESSION=?", sessionKey, nil];
					if (checkDBRoomInfo) {
						NSArray *checkDBUserInfo = [UserInfo findWithSqlWithParameters:@"select * from _TUserInfo where RPKEY=?", pKey, nil];
						if (checkDBUserInfo && [checkDBUserInfo count] > 0) {
							for (UserInfo *userInfo in checkDBUserInfo) {
								if (userInfo.FORMATTED && [userInfo.FORMATTED length] > 0) {
									nickName = userInfo.FORMATTED;
								} else if (userInfo.PROFILENICKNAME && [userInfo.PROFILENICKNAME length] > 0) {
									nickName = userInfo.PROFILENICKNAME;
								} else {
									if (nickName && [nickName length] > 0) {
										// 서버에서 내려온 nickName 사용
									} else {
										nickName = @"이름 없음";
									}
								}
							}
						} else {
							if (nickName && [nickName length] > 0) {
								// 서버에서 내려온 nickName 사용
							} else {
								nickName = @"이름 없음";
							}
						}
						// DB, 메모리 추가
						CellMsgListData *msgListData = [self MsgListDataFromChatSession:sessionKey];
						// 메시지에서 확인
						if (msgListData ) {
							if ([msgListData.chatsession isEqualToString:sessionKey]) {
								MsgUserData *userData = [msgListData.userDataDic objectForKey:pKey];
								if (userData != nil) {
									// 기존 대화 상대 존재
									if ([userData.nickName isEqualToString:nickName] == NO && [userData.photoUrl isEqualToString:representPhoto] == NO) {
										userData.nickName = nickName;
										userData.photoUrl = representPhoto;
										[MessageUserInfo findWithSqlWithParameters:@"update _TMessageUserInfo set NICKNAME=?, PHOTOURL=? where CHATSESSION=?", nickName, representPhoto, sessionKey, nil];
									} else if ([userData.nickName isEqualToString:nickName] == NO && [userData.photoUrl isEqualToString:representPhoto] == YES) {
										userData.nickName = nickName;
										[MessageUserInfo findWithSqlWithParameters:@"update _TMessageUserInfo set NICKNAME=? where CHATSESSION=?", nickName, sessionKey, nil];
									} else if ([userData.nickName isEqualToString:nickName] == YES && [userData.photoUrl isEqualToString:representPhoto] == NO) {
										userData.photoUrl = representPhoto;
										[MessageUserInfo findWithSqlWithParameters:@"update _TMessageUserInfo set PHOTOURL=? where CHATSESSION=?", representPhoto, sessionKey, nil];
									} else {
										// skip 변경사항 없음
									}
								} else {
									// 신규 대화 상대 입장 (DB, 메모리 추가)
									MsgUserData *newUserInfo = [[[MsgUserData alloc] init] autorelease];
									//									assert(newUserInfo != nil);
									newUserInfo.nickName = nickName;
									newUserInfo.photoUrl = representPhoto;
									newUserInfo.pKey = pKey;
									if (msgListData.userDataDic) {
										// skip
									} else {
										msgListData.userDataDic = [NSMutableDictionary dictionaryWithCapacity:10];
									}
									[msgListData.userDataDic setObject:newUserInfo forKey:pKey];
									[MessageUserInfo findWithSqlWithParameters:@"insert into _TMessageUserInfo(CHATSESSION, PKEY, PHOTOURL, NICKNAME) values(?, ?, ?, ?)", sessionKey, pKey, representPhoto, nickName, nil];
								}
							}
						} else {
							// error
							return;
						}
					} else {
						// error
						return;
					}
				}
			}
		}
		// 대화창 리스트에 notification (테이블 reload 처리)
		[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadMsgList" object:nil];
		
		// sessionKey 값과 현재 열려진 대화방 키값과 동일하면 대화방에 refresh 요청
		if ([openChatSession isEqualToString:sessionKey]) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"requestRetrieveSessionMessage" object:nil];
		} else {
		}
	} else if ([rtcode isEqualToString:@"-9010"]) {
		// 참가자 정보 없음
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-9010)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else if ([rtcode isEqualToString:@"-9030"]) {
		// 처리 오류
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-9030)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else {
		// TODO: 실패 예외처리 필요
		// fail (-8080 이외 기타오류)
		NSString *string = [NSString stringWithFormat:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-%@)", rtcode];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:string delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	}
}

// 대화에 참가한 참가자 정보를 가져온다.
-(void)getChatParticipants:(NSNotification *)notification
{
	USayHttpData *data = (USayHttpData*)[notification object];
	if (data == nil) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0047)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
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
	NSString *rtcode = [dic objectForKey:@"rtcode"];
	
	if ([rtcode isEqualToString:@"0"]) {	// success
		//		NSString *count = [dic objectForKey:@"count"];
		NSString *rtType = [dic objectForKey:@"rttype"];
		NSString *sessionKey = [dic objectForKey:@"sessionKey"];
		
		//		NSLog(@"getChatParticipants sessionKey = %@", sessionKey);
		NSString *openChatSession = [self.myInfoDictionary objectForKey:@"openChatSession"];
		
		if ([rtType isEqualToString:@"list"]) {
			// Key and Dictionary as its value type
			NSArray *listArray = [dic objectForKey:@"list"];
			//			assert(listArray != nil);
			if (tempMsgListDic && [tempMsgListDic count] > 0) {
				@synchronized(tempMsgListDic) {
					TempMsgListData *tempMsgListData = (TempMsgListData *)[tempMsgListDic objectForKey:sessionKey];
					//					assert(tempMsgListData != nil);
					/*	TempMsgListData
					 NSString *nCount;			// 신규 메시지 카운트 수
					 NSString *sType;			// C : 생성   U : 업데이트
					 NSString *pCount;			// 참가자 카운트 수
					 NSString *cType;			// 채팅세션 타입 P: 1:1  G: 그룹
					 //*/
					BOOL isCreate = NO;
					CellMsgListData *msgListData = nil;
					
					//			NSLog(@"getChatParticipants111 tempMsgListData.lastUpdateTime = %@", tempMsgListData.lastUpdateTime);
					
					// 메시지에서 확인
					msgListData = [self MsgListDataFromChatSession:sessionKey];
					if (msgListData != nil) {
						// 대화방 리스트 수정
						msgListData.lastMsg = tempMsgListData.lastMsg;
						msgListData.lastMsgType = tempMsgListData.lastMsgType;
						msgListData.lastMsgDate = [NSString stringWithFormat:@"%llu", [tempMsgListData.lastMsgDate longLongValue]];
						msgListData.lastUpdateTime = tempMsgListData.lastUpdateTime;
						msgListData.newMsgCount = [tempMsgListData.nCount intValue];
						if (msgListData.newMsgCount <= 0) {
							msgListData.newMsgCount = 0;
						}
						if (msgListData.lastMsg && [msgListData.lastMsg length] > 0 && msgListData.lastMsgType && [msgListData.lastMsgType length] > 0 &&
							tempMsgListData.lastMsgDate && msgListData.lastUpdateTime && sessionKey && [sessionKey length] > 0) {
							[RoomInfo findWithSqlWithParameters:@"update _TRoomInfo set LASTMSGDATE=?, LASTMSG=?, LASTMSGTYPE=?, LASTUPDATETIME=?, NEWMSGCOUNT=? where CHATSESSION=?", tempMsgListData.lastMsgDate,
							 msgListData.lastMsg,
							 msgListData.lastMsgType,
							 msgListData.lastUpdateTime,
							 [NSNumber numberWithInt:msgListData.newMsgCount],
							 sessionKey, nil];
						}
					} else {
						// 대화방 리스트 생성. DB insert/update
						isCreate = YES;
						msgListData = [[CellMsgListData alloc] init];
						msgListData.chatsession = sessionKey;
						msgListData.lastMsg = tempMsgListData.lastMsg;
						msgListData.cType = tempMsgListData.cType;
						msgListData.lastMsgType = tempMsgListData.lastMsgType;
						msgListData.lastMsgDate = [NSString stringWithFormat:@"%llu", [tempMsgListData.lastMsgDate longLongValue]];
						msgListData.lastUpdateTime = tempMsgListData.lastUpdateTime;
						msgListData.newMsgCount = [tempMsgListData.nCount intValue];
						
						if (msgListData.newMsgCount <= 0) {
							msgListData.newMsgCount = 0;
						}
						if (msgListData.lastMsg && [msgListData.lastMsg length] > 0 && msgListData.lastMsgType && [msgListData.lastMsgType length] > 0 &&
							tempMsgListData.lastMsgDate  && msgListData.lastUpdateTime && sessionKey && [sessionKey length] > 0) {
							if (msgListData.lastMsgType) {
								if ([msgListData.lastMsgType isEqualToString:@"T"]) {
									[RoomInfo findWithSqlWithParameters:@"insert into _TRoomInfo(CHATSESSION, LASTMESSAGEKEY, CTYPE, LASTMSG, LASTMSGTYPE, LASTMSGDATE, LASTUPDATETIME, NEWMSGCOUNT) values (?, ?, ?, ?, ?, ?, ?, ?)", sessionKey,  @"", msgListData.cType, msgListData.lastMsg, @"T", tempMsgListData.lastMsgDate, msgListData.lastUpdateTime, [NSNumber numberWithInt:[tempMsgListData.nCount intValue]], nil];
								} else if ([msgListData.lastMsgType isEqualToString:@"P"]) {
									[RoomInfo findWithSqlWithParameters:@"insert into _TRoomInfo(CHATSESSION, LASTMESSAGEKEY, CTYPE, LASTMSG, LASTMSGTYPE, LASTMSGDATE, LASTUPDATETIME, NEWMSGCOUNT) values (?, ?, ?, ?, ?, ?, ?, ?)", sessionKey,  @"", msgListData.cType, msgListData.lastMsg, @"P", tempMsgListData.lastMsgDate, msgListData.lastUpdateTime, [NSNumber numberWithInt:[tempMsgListData.nCount intValue]], nil];
								} else if ([msgListData.lastMsgType isEqualToString:@"V"]) {
									[RoomInfo findWithSqlWithParameters:@"insert into _TRoomInfo(CHATSESSION, LASTMESSAGEKEY, CTYPE, LASTMSG, LASTMSGTYPE, LASTMSGDATE, LASTUPDATETIME, NEWMSGCOUNT) values (?, ?, ?, ?, ?, ?, ?, ?)", sessionKey,  @"", msgListData.cType, msgListData.lastMsg, @"V", tempMsgListData.lastMsgDate, msgListData.lastUpdateTime, [NSNumber numberWithInt:[tempMsgListData.nCount intValue]], nil];
								} else if ([msgListData.lastMsgType isEqualToString:@"J"]) {
									// skip
								} else if ([msgListData.lastMsgType isEqualToString:@"Q"]) {
									// skip
								} else {
									// skip
								}
							}
						}
					}
					NSArray *lastUpdateTimeArray = [RoomInfo findWithSqlWithParameters:@"select * from _TRoomInfo order by LASTUPDATETIME desc limit 1", nil];
					
					NSNumber *lastUpdateTimeNumber = nil;
					if (lastUpdateTimeArray && [lastUpdateTimeArray count] > 0) {
						for (RoomInfo *roomInfo in lastUpdateTimeArray) {
							lastUpdateTimeNumber = roomInfo.LASTUPDATETIME;
							NSNumber *savedLastUpdateTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastUpdateTime"];
							if (savedLastUpdateTime) {
								if ([savedLastUpdateTime longLongValue] <= [lastUpdateTimeNumber longLongValue]) {
									[[NSUserDefaults standardUserDefaults] setObject:lastUpdateTimeNumber forKey:@"lastUpdateTime"];
								} else {
									// skip
								}
							} else {
								[[NSUserDefaults standardUserDefaults] setObject:lastUpdateTimeNumber forKey:@"lastUpdateTime"];
							}				
						}
					}
					for (int i=0; i < [listArray count]; i++) {
						NSDictionary *listDic = [listArray objectAtIndex:i];
						//						assert(listDic != nil);
						NSString *representPhoto = [listDic objectForKey:@"representPhoto"];
						NSString *nickName = [listDic objectForKey:@"nickName"];
						NSString *pKey = [listDic objectForKey:@"pKey"];
						NSString *isJoined = [listDic objectForKey:@"isJoined"];
						
						if (pKey && [pKey length] > 0 && isJoined && [isJoined length] > 0 && [isJoined isEqualToString:@"Y"]) {
							NSArray *checkDBUserInfo = [UserInfo findWithSqlWithParameters:@"select * from _TUserInfo where RPKEY=?", pKey, nil];
							if (checkDBUserInfo && [checkDBUserInfo count] > 0) {
								for (UserInfo *userInfo in checkDBUserInfo) {
									if (userInfo.FORMATTED && [userInfo.FORMATTED length] > 0) {
										nickName = userInfo.FORMATTED;
									} else if (userInfo.PROFILENICKNAME && [userInfo.PROFILENICKNAME length] > 0) {
										nickName = userInfo.PROFILENICKNAME;
									} else {
										if (nickName && [nickName length] > 0) {
											// 서버에서 내려온 nickName 사용
										} else {
											nickName = @"이름 없음";
										}
									}
								}
							} else {
								if (nickName && [nickName length] > 0) {
									// 서버에서 내려온 nickName 사용
								} else {
									nickName = @"이름 없음";
								}
							}
							if ([msgListData.chatsession isEqualToString:sessionKey]) {
								MsgUserData *userData = [msgListData.userDataDic objectForKey:pKey];
								if (userData != nil) {
									// 기존 대화 상대 존재
									if ([userData.nickName isEqualToString:nickName] == NO && [userData.photoUrl isEqualToString:representPhoto] == NO) {
										userData.nickName = nickName;
										userData.photoUrl = representPhoto;
										[MessageUserInfo findWithSqlWithParameters:@"update _TMessageUserInfo set NICKNAME=?, PHOTOURL=? where CHATSESSION=?", nickName, representPhoto, sessionKey, nil];
									} else if ([userData.nickName isEqualToString:nickName] == NO && [userData.photoUrl isEqualToString:representPhoto] == YES) {
										userData.nickName = nickName;
										[MessageUserInfo findWithSqlWithParameters:@"update _TMessageUserInfo set NICKNAME=? where CHATSESSION=?", nickName, sessionKey, nil];
									} else if ([userData.nickName isEqualToString:nickName] == YES && [userData.photoUrl isEqualToString:representPhoto] == NO) {
										userData.photoUrl = representPhoto;
										[MessageUserInfo findWithSqlWithParameters:@"update _TMessageUserInfo set PHOTOURL=? where CHATSESSION=?", representPhoto, sessionKey, nil];
									} else {
										// skip 변경사항 없음
									}
								} else {
									// 신규 대화 상대 입장 (DB, 메모리 추가)
									MsgUserData *newUserInfo = [[[MsgUserData alloc] init] autorelease];
									//									assert(newUserInfo != nil);
									newUserInfo.nickName = nickName;
									newUserInfo.photoUrl = representPhoto;
									newUserInfo.pKey = pKey;
									if (msgListData.userDataDic) {
										// skip
									} else {
										msgListData.userDataDic = [NSMutableDictionary dictionaryWithCapacity:10];
									}
									[msgListData.userDataDic setObject:newUserInfo forKey:pKey];
									[MessageUserInfo findWithSqlWithParameters:@"insert into _TMessageUserInfo(CHATSESSION, PKEY, PHOTOURL, NICKNAME) values(?, ?, ?, ?)", sessionKey, pKey, representPhoto, nickName, nil];
									//							[newUserInfo release];
								}
							}
						} else {
							continue;
						}
					}
					if (isCreate) {
						[self.msgListArray addObject:msgListData];
						[msgListData release];
						//						for (CellMsgListData *msgListData1 in msgListArray) {
						//							NSLog(@"getChatParticipants lastMsgDate=%@", msgListData1.lastMsgDate);
						//						}
						NSSortDescriptor *lastMsgDateSort = [[NSSortDescriptor alloc] initWithKey:@"lastMsgDate" ascending:NO selector:@selector(compare:)];
						[msgListArray sortUsingDescriptors:[NSArray arrayWithObject:lastMsgDateSort]];
						[lastMsgDateSort release];
					}
					// DB 에 추가
					[tempMsgListDic removeObjectForKey:sessionKey];
				}
				// 대화창 리스트에 notification (테이블 reload 처리)
				[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadMsgList" object:nil];
				
				// DB에서 읽어서 Badge표기
				NSInteger nNewMsgCount = [self newMessageCount];
				if (nNewMsgCount == 0) {
					UITabBarItem *tbi = [rootController.tabBar.items objectAtIndex:2]; //기존 1->2로
					if (tbi) {
						tbi.badgeValue = nil;
					}
					NSLog(@"======badgeValue 3 : %d", nNewMsgCount);
					[[UIApplication sharedApplication] setApplicationIconBadgeNumber:nNewMsgCount];
				} else if (nNewMsgCount > 0) {
					UITabBarItem *tbi = [rootController.tabBar.items objectAtIndex:2]; //기존 1->2로
					if (tbi) {
						tbi.badgeValue = [NSString stringWithFormat:@"%i", nNewMsgCount];
					}
					[[UIApplication sharedApplication] setApplicationIconBadgeNumber:nNewMsgCount];
					
					NSLog(@"======badgeValue 4 : %d", nNewMsgCount);
				} else {
					
				}
			}
			// sessionKey 값과 현재 열려진 대화방 키값과 동일하면 대화방에 refresh 요청
			// sessionKey 값과 현재 열려진 대화방 키값과 다르면 진동/소리 요청
			if ([openChatSession isEqualToString:sessionKey]) {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"requestRetrieveSessionMessage" object:nil];
			} else {
				[self playSystemSoundIDSound];
				[self playSystemSoundIDVibrate];
			}
		} else {
			// 예외처리
		}
	} else if ([rtcode isEqualToString:@"-9010"]) {
		// 참가자 정보 없음
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-9010)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else if ([rtcode isEqualToString:@"-9030"]) {
		// 처리 오류
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-9030)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else {
		// TODO: 실패 예외처리 필요
		// fail (-8080 이외 기타오류)
		NSString *string = [NSString stringWithFormat:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-%@)", rtcode];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:string delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	}
}

-(void)joinToChatSession:(NSNotification *)notification
{
	USayHttpData *data = (USayHttpData*)[notification object];
	if (data == nil) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0048)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
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
	rtcode = [dic objectForKey:@"rtcode"];
	
	if ([rtcode isEqualToString:@"0"]) {	// success
		NSString *rtType = [dic objectForKey:@"rttype"];
		if ([rtType isEqualToString:@"map"]) {
			// Key and Dictionary as its value type
			NSDictionary *addressDic = [dic objectForKey:@"map"];
			//			assert(addressDic != nil);
			NSString *createTime = [addressDic objectForKey:@"createTime"];			// unix timestamp 13자리 대화방의 LastUpdateTime
			NSString *chatSessionKey = [addressDic objectForKey:@"sessionKey"];		// 대화방 세션
			//			NSString *isNewSession = [addressDic objectForKey:@"isNewSession"];		// 새로운 세션인지 여부
			//			NSString *pCount = [addressDic objectForKey:@"pCount"];					// 대화참가자 수
			//			NSString *ownerPKey = [addressDic objectForKey:@"ownerPKey"];			// 소유자 pKey
			NSMutableString *pKeys = [addressDic objectForKey:@"pKeys"];			// 참여된 Buddy pKey "|" 구분자로 내려옴.
			NSString *uuid = [addressDic objectForKey:@"uuid"];
			NSString *cType = [addressDic objectForKey:@"cType"];
			[self.myInfoDictionary setObject:chatSessionKey forKey:@"openChatSession"];
			// TODO : 메시지리스트 DB추가
			
			if (!(chatSessionKey && [chatSessionKey length] > 0)) return;
			if (!(pKeys && [pKeys length] > 0)) return;
			
			NSString *lastMessageKey = nil;
			NSMutableString *photoUrl = nil;
			NSMutableString *name = nil;
			NSNumber *createTimeNumber = [NSNumber numberWithLongLong:[createTime longLongValue]];
			if (pKeys) {
				pKeys = (NSMutableString *)[pKeys stringByReplacingOccurrencesOfString:@" " withString:@""];
				NSArray *pKeyArray = [pKeys componentsSeparatedByString:@"|"];
				if (pKeyArray) {
					NSMutableArray *parameterList = [NSMutableArray array];
					for (id pkey in pKeyArray) {
						[parameterList addObject: @"?"];
					}
					NSString *sql = [NSString stringWithFormat:@"select * from _TUserInfo where RPKEY in (%@)", [parameterList componentsJoinedByString:@","]];
					NSArray *userDBInfoArray = [UserInfo findWithSql:sql withParameters:pKeyArray];
					if (userDBInfoArray && [userDBInfoArray count] > 0) {
						NSArray *checkRoomInfoArray = [RoomInfo findWithSqlWithParameters:@"select * from _TRoomInfo where CHATSESSION=?", chatSessionKey, nil];
						if (checkRoomInfoArray && [checkRoomInfoArray count] == 1) {
							// 기존 대화방 (그룹 대화에 유저 추가. DB, 메모리)
							[RoomInfo findWithSqlWithParameters:@"update _TRoomInfo set LASTUPDATETIME=? where CHATSESSION=?", createTimeNumber,chatSessionKey, nil];
							for (RoomInfo *roomInfo in checkRoomInfoArray) {
								lastMessageKey = roomInfo.LASTMESSAGEKEY;
							}
							
							[[NSUserDefaults standardUserDefaults] setObject:createTimeNumber forKey:@"lastUpdateTime"];
							
							// 메모리
							@synchronized(msgListArray) {
								for (CellMsgListData *msgListData in msgListArray) {
									if ([msgListData.chatsession isEqualToString:chatSessionKey]) {
										for(UserInfo *userInfo in userDBInfoArray) {
											// DB
											if (userInfo.REPRESENTPHOTO && [userInfo.REPRESENTPHOTO length] > 0) {
												photoUrl = [NSMutableString stringWithFormat:@"%@",userInfo.REPRESENTPHOTO];
											} else if (userInfo.THUMBNAILURL && [userInfo.THUMBNAILURL length] > 0) {
												photoUrl = [NSMutableString stringWithFormat:@"%@",userInfo.THUMBNAILURL];
											} else {
												photoUrl = [NSMutableString stringWithFormat:@""];
											}
											
											if (userInfo.FORMATTED && [userInfo.FORMATTED length] > 0) {
												[MessageUserInfo findWithSqlWithParameters:@"insert into _TMessageUserInfo(CHATSESSION, PKEY, PHOTOURL, NICKNAME) values (?, ?, ?, ?)",
												 chatSessionKey, userInfo.RPKEY, photoUrl, userInfo.FORMATTED, nil];
												name = [NSMutableString stringWithFormat:@"%@",userInfo.FORMATTED];
											} else if (userInfo.PROFILENICKNAME && [userInfo.PROFILENICKNAME length] > 0) {
												[MessageUserInfo findWithSqlWithParameters:@"insert into _TMessageUserInfo(CHATSESSION, PKEY, PHOTOURL, NICKNAME) values (?, ?, ?, ?)",
												 chatSessionKey, userInfo.RPKEY, photoUrl, userInfo.PROFILENICKNAME, nil];
												name = [NSMutableString stringWithFormat:@"%@",userInfo.PROFILENICKNAME];
											} else {
												[MessageUserInfo findWithSqlWithParameters:@"insert into _TMessageUserInfo(CHATSESSION, PKEY, PHOTOURL, NICKNAME) values (?, ?, ?, ?)",
												 chatSessionKey, userInfo.RPKEY, photoUrl, @"이름 없음", nil];
												name = [NSMutableString stringWithFormat:@"이름 없음"];
											}
											
											[MessageUserInfo findWithSqlWithParameters:@"insert into _TMessageUserInfo(CHATSESSION, PKEY, PHOTOURL, NICKNAME) values (?, ?, ?, ?)",
											 chatSessionKey, userInfo.RPKEY, photoUrl, name, nil];
											// 메모리
											if (msgListData.userDataDic) {
												MsgUserData *userData = [[MsgUserData alloc] init];
												if (userInfo.FORMATTED && [userInfo.FORMATTED length] > 0) {
													userData.nickName = userInfo.FORMATTED;
												} else if (userInfo.PROFILENICKNAME && [userInfo.PROFILENICKNAME length] > 0) {	
													userData.nickName = userInfo.PROFILENICKNAME;
												} else {
													userData.nickName = @"이름 없음";
												}
												userData.pKey = userInfo.RPKEY;
												userData.photoUrl = photoUrl;
												[msgListData.userDataDic setObject:userData forKey:userInfo.RPKEY];
												[userData release];
											} else {
												// error. 이런 경우는 없음. ㅠㅠ
												msgListData.userDataDic = [NSMutableDictionary dictionaryWithCapacity:10];
												MsgUserData *userData = [[MsgUserData alloc] init];
												if (userInfo.FORMATTED && [userInfo.FORMATTED length] > 0) {
													userData.nickName = userInfo.FORMATTED;
												} else if (userInfo.PROFILENICKNAME && [userInfo.PROFILENICKNAME length] > 0) {	
													userData.nickName = userInfo.PROFILENICKNAME;
												} else {
													userData.nickName = @"이름 없음";
												}
												userData.pKey = userInfo.RPKEY;
												userData.photoUrl = photoUrl;
												[msgListData.userDataDic setObject:userData forKey:userInfo.RPKEY];
												[userData release];
											}
										}
										break;
									} 
								}
								if (msgListArray && [msgListArray count] > 0) {
									//									for (CellMsgListData *msgListData1 in msgListArray) {
									//										NSLog(@"joinToChatSession 1 lastMsgDate=%@", msgListData1.lastMsgDate);
									//									}
									NSSortDescriptor *lastMsgDateSort = [[NSSortDescriptor alloc] initWithKey:@"lastMsgDate" ascending:NO selector:@selector(compare:)];
									[msgListArray sortUsingDescriptors:[NSArray arrayWithObject:lastMsgDateSort]];
									[lastMsgDateSort release];
									[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadMsgList" object:nil];
								}
							}
							
							// 기존 대화방에서 초대한것이므로 세션값은 동일. 네비게이션 타이틀바 변경 처리 필요.
							[[NSNotificationCenter defaultCenter] postNotificationName:@"responseJoinToChatSession" object:nil];
							
							// 기존 그룹대화에 초대 되었으므로 "XXX 님이 초대 되었습니다. 표기하기 위해서 요청"
							NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
							//							assert(bodyObject != nil);
							[bodyObject setObject:chatSessionKey forKey:@"sessionKey"];
							[bodyObject setObject:[self getSvcIdx] forKey:@"svcidx"];
							if (lastMessageKey && [lastMessageKey length] > 0) {
								[bodyObject setObject:lastMessageKey forKey:@"lastMessageKey"];
							} else {
								
							}
							
							// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
							USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"retrieveSessionMessage" andWithDictionary:bodyObject timeout:10] autorelease];
							//							assert(data != nil);
							[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
							
						} else {
							// 신규 대화방 생성
							// 1. 대화방 생성 필요 (DB, 메모리)
							// 2. 참가자 정보 추가 (DB, 메모리)
							// 3. 메시지 초기화 (메모리)
							
							// DB 대화방 생성
							
							[RoomInfo findWithSqlWithParameters:@"insert into _TRoomInfo(CHATSESSION, LASTMESSAGEKEY, CTYPE, LASTMSG, LASTMSGTYPE, LASTMSGDATE, LASTUPDATETIME, NEWMSGCOUNT) values (?, ?, ?, ?, ?, ?, ?, ?)", 
							 chatSessionKey, @"", cType, @"", @"", [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]*1000],  createTimeNumber, [NSNumber numberWithInt:0], nil];
							
							[[NSUserDefaults standardUserDefaults] setObject:createTimeNumber forKey:@"lastUpdateTime"];
							
							for(UserInfo *userInfo in userDBInfoArray) {
								// DB 참가자 추가
								NSArray *checkDBMessageUserInfoArray = [MessageUserInfo findWithSqlWithParameters:@"select * from _TMessageUserInfo where CHATSESSION=? and PKEY=?", chatSessionKey, userInfo.RPKEY, nil];
								if (userInfo.REPRESENTPHOTO && [userInfo.REPRESENTPHOTO length] > 0) {
									photoUrl = [NSMutableString stringWithFormat:@"%@",userInfo.REPRESENTPHOTO];
								} else if (userInfo.THUMBNAILURL && [userInfo.THUMBNAILURL length] > 0) {
									photoUrl = [NSMutableString stringWithFormat:@"%@",userInfo.THUMBNAILURL];
								} else {
									photoUrl = [NSMutableString stringWithFormat:@""];
								}
								if (checkDBMessageUserInfoArray && [checkDBMessageUserInfoArray count] > 0) {
									// update
									if (userInfo.FORMATTED && [userInfo.FORMATTED length] > 0) {
										[MessageUserInfo findWithSqlWithParameters:@"update _TMessageUserInfo set NICKNAME=?, PHOTOURL=? where CHATSESSION=? and PKEY=?", userInfo.FORMATTED, photoUrl, chatSessionKey, userInfo.RPKEY, nil];
									} else if (userInfo.PROFILENICKNAME && [userInfo.PROFILENICKNAME length] > 0) {
										[MessageUserInfo findWithSqlWithParameters:@"update _TMessageUserInfo set NICKNAME=?, PHOTOURL=? where CHATSESSION=? and PKEY=?", userInfo.PROFILENICKNAME, photoUrl, chatSessionKey, userInfo.RPKEY, nil];
									} else {
										[MessageUserInfo findWithSqlWithParameters:@"update _TMessageUserInfo set NICKNAME=?, PHOTOURL=? where CHATSESSION=? and PKEY=?", @"이름 없음", photoUrl, chatSessionKey, userInfo.RPKEY, nil];
									}
									
								} else {
									// insert
									if (userInfo.FORMATTED && [userInfo.FORMATTED length] > 0) {
										[MessageUserInfo findWithSqlWithParameters:@"insert into _TMessageUserInfo(CHATSESSION, PKEY, NICKNAME, PHOTOURL)  values(?, ?, ?, ?)", chatSessionKey, userInfo.RPKEY, userInfo.FORMATTED, photoUrl, nil];									
									} else if (userInfo.PROFILENICKNAME && [userInfo.PROFILENICKNAME length] > 0) {
										[MessageUserInfo findWithSqlWithParameters:@"insert into _TMessageUserInfo(CHATSESSION, PKEY, NICKNAME, PHOTOURL)  values(?, ?, ?, ?)", chatSessionKey, userInfo.RPKEY, userInfo.PROFILENICKNAME, photoUrl, nil];									
									} else {
										[MessageUserInfo findWithSqlWithParameters:@"insert into _TMessageUserInfo(CHATSESSION, PKEY, NICKNAME, PHOTOURL)  values(?, ?, ?, ?)", chatSessionKey, userInfo.RPKEY, @"이름 없음", photoUrl, nil];									
									}
									
								}
								// 메모리 대화방/참가자 생성
								BOOL isExistMsgList = NO;
								@synchronized(msgListArray) {
									for (CellMsgListData *msgListData in msgListArray) {
										if ([msgListData.chatsession isEqualToString:chatSessionKey]) {
											isExistMsgList = YES;
											msgListData.lastUpdateTime = createTimeNumber;
											if (msgListData.userDataDic) {
												MsgUserData *userData = [msgListData.userDataDic objectForKey:userInfo.RPKEY];
												if (userData == nil) {
													// 추가
													userData = [[[MsgUserData alloc] init] autorelease];
													userData.pKey = userInfo.RPKEY;
													if (userInfo.FORMATTED && [userInfo.FORMATTED length] > 0) {
														userData.nickName = userInfo.FORMATTED;
													} else if (userInfo.PROFILENICKNAME && [userInfo.PROFILENICKNAME length] > 0) {
														userData.nickName = userInfo.PROFILENICKNAME;
													} else {
														userData.nickName = @"이름 없음";
													}
													userData.photoUrl = photoUrl;
													[msgListData.userDataDic setObject:userData forKey:userInfo.RPKEY];
												} else {
													// skip
												}	
											}
											msgListData.lastMsgDate = [NSString stringWithFormat:@"%llu", [createTimeNumber longLongValue]];
											break;
										}
									}
									if (!isExistMsgList) {
										// 추가
										CellMsgListData *msgListData = [[[CellMsgListData alloc] init] autorelease];
										msgListData.chatsession = chatSessionKey;
										msgListData.cType = cType;
										msgListData.lastmessagekey = @"";
										msgListData.lastMsg = @"";
										msgListData.lastMsgDate = [NSString stringWithFormat:@"%llu", [createTimeNumber longLongValue]];;
										msgListData.lastMsgType = @"";
										msgListData.lastUpdateTime = createTimeNumber;
										msgListData.newMsgCount = 0;
										msgListData.userDataDic = [NSMutableDictionary dictionaryWithCapacity:10];
										MsgUserData *userData = [[MsgUserData alloc] init];
										if (userInfo.FORMATTED && [userInfo.FORMATTED length] > 0) {
											userData.nickName = userInfo.FORMATTED;
										} else if (userInfo.PROFILENICKNAME && [userInfo.PROFILENICKNAME length] > 0) {
											userData.nickName = userInfo.PROFILENICKNAME;
										} else {
											userData.nickName = @"이름 없음";
										}
										userData.pKey = userInfo.RPKEY;
										userData.photoUrl = photoUrl;
										[msgListData.userDataDic setObject:userData forKey:userInfo.RPKEY];
										[msgListArray addObject:msgListData];
										[userData release];
									}
									
									[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadMsgList" object:nil];
								}
								@synchronized(msgArray) {
									[msgArray removeAllObjects];
								}
							}
							if (msgListArray && [msgListArray count] > 0) {
								//								for (CellMsgListData *msgListData1 in msgListArray) {
								//									NSLog(@"joinToChatSession 2 lastMsgDate=%@", msgListData1.lastMsgDate);
								//								}
								NSSortDescriptor *lastMsgDateSort = [[NSSortDescriptor alloc] initWithKey:@"lastMsgDate" ascending:NO selector:@selector(compare:)];
								[msgListArray sortUsingDescriptors:[NSArray arrayWithObject:lastMsgDateSort]];
								[lastMsgDateSort release];
							}
							
							// 채팅방 sessionKey, cType 값을 변경해줘야 함.
							[[NSNotificationCenter defaultCenter] postNotificationName:@"responseJoinToChatSession" object:[NSString stringWithFormat:@"%@|%@", uuid, chatSessionKey]];
							
							NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
							//							assert(bodyObject != nil);
							[bodyObject setObject:chatSessionKey forKey:@"sessionKey"];
							[bodyObject setObject:[self getSvcIdx] forKey:@"svcidx"];
							
							if (lastMessageKey && [lastMessageKey length] > 0) {
								[bodyObject setObject:lastMessageKey forKey:@"lastMessageKey"];
							}
							
							// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
							USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"retrieveSessionMessage" andWithDictionary:bodyObject timeout:10] autorelease];
							//							assert(data != nil);
							[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
						}
					}
				}
			}
			
		} else {
			// 예외처리
		}
	} else if ([rtcode isEqualToString:@"-8012"]) {
		// 처리 오류
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-8012)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else if ([rtcode isEqualToString:@"-9030"]) {
		// 처리 오류
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-9030)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else {
		// TODO: 실패 예외처리 필요
		// fail (-8080 이외 기타오류)
		NSString *string = [NSString stringWithFormat:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-%@)", rtcode];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:string delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		
		//		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0048)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	}
}

// 대화창 메시지 가져오기
-(void)retrieveSessionMessage:(NSNotification *)notification
{
	USayHttpData *data = (USayHttpData*)[notification object];
	if (data == nil) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0049)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
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
	rtcode = [dic objectForKey:@"rtcode"];
	
	if ([rtcode isEqualToString:@"0"]) {	// success
		//		NSString *count = [dic objectForKey:@"count"];
		NSString *chatSessionKey = [dic objectForKey:@"sessionKey"];
		NSString *rtType = [dic objectForKey:@"rttype"];
		
		if (!(chatSessionKey && [chatSessionKey length] > 0)) return;
		
		if ([rtType isEqualToString:@"list"]) {
			// Key and Dictionary as its value type
			NSArray *listArray = [dic objectForKey:@"list"];
			//			assert(listArray != nil);
			NSInteger nReadMsgCount = 0;
			//	NSString *nCount = nil, *message = nil, *mType = nil, *createTime = nil, *messageKey = nil, *rCount = nil, *ownerPKey = nil;
			NSString *message = nil, *mType = nil, *createTime = nil, *messageKey = nil,*ownerPKey = nil;
			NSNumber *createTimeNumber = nil;
			//mezzo	NSString *lastMessageKey = nil;
			NSString *openChatSession = [self.myInfoDictionary objectForKey:@"openChatSession"];
			NSString *lastMessage = nil;
			NSString *lastMessageType = nil;
			NSNumber *lastMessageDateNumber = nil;
			for (int i=0; i < [listArray count]; i++) {
				NSDictionary *listDic = [listArray objectAtIndex:i];
				//				assert(listDic != nil);
				//mezzo	nCount = [listDic objectForKey:@"nCount"];				// 메시지 갯수
				message = [listDic objectForKey:@"message"];			// 메시지 내용
				mType = [listDic objectForKey:@"mType"];				// 메시지 타입	T:텍스트 P:사진 V:동영상 J:입장 Q:퇴장
				createTime = [listDic objectForKey:@"createTime"];		// 메시지 생성시간
				messageKey = [listDic objectForKey:@"messageKey"];		// 메시지 고유키
				//mezzo		rCount  = [listDic objectForKey:@"rCount"];				// 메시지 읽은 카운트 수
				ownerPKey  = [listDic objectForKey:@"ownerPKey"];		// 메시지 보낸사람의 pKey
				
				if (messageKey && [messageKey length] > 0) {
					NSArray  *checkDuplicationMessageInfoArray = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where MESSAGEKEY=?", messageKey, nil];
					if (checkDuplicationMessageInfoArray && [checkDuplicationMessageInfoArray count] > 0) {
						continue;
					}
				}
				
				//mezzo		lastMessageKey = messageKey;
				//				NSLog(@"retrieveSessionMessage count = %@", count);
				NSArray *lastRegDateArray = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where ISSUCCESS=? and CHATSESSION=? order by REGDATE desc limit 1", @"1", chatSessionKey, nil];
				
				NSNumber *lastRegDateNumber = nil;
				if (lastRegDateArray && [lastRegDateArray count] > 0) {
					for (MessageInfo *messageInfo in lastRegDateArray) {
						lastRegDateNumber = messageInfo.REGDATE;
					}
				}
				//				NSLog(@"retrieveSessionMessage 이전데이터와 비교해서 날짜정보 넣어주기 lastRegDateNumber = %@", lastRegDateNumber);
				createTimeNumber = [NSNumber numberWithLongLong:[createTime longLongValue]];
				
				// DB에서 pkey 값으로 별명, 사진 요청
				if ([mType isEqualToString:@"T"] || [mType isEqualToString:@"P"] || [mType isEqualToString:@"V"]) {
					//					NSLog(@"retrieveSessionMessage ownerPKey = %@", ownerPKey);
					//					NSLog(@"retrieveSessionMessage 저장된 Key = %@", [myInfoDictionary objectForKey:@"pkey"]);
					lastMessage = message;
					lastMessageType = mType;
					lastMessageDateNumber = [NSNumber numberWithLongLong:[createTime longLongValue]];
					if ([ownerPKey isEqualToString:[myInfoDictionary objectForKey:@"pkey"]]) {	// 내 자신이 다른 device에서 보낸 데이터
						// DB에 추가
						// 날짜 비교후 날짜 정보 저장
						nReadMsgCount++;
						//						NSLog(@"retrieveSessionMessage 내 자신이 다른 device에서 보낸 데이터 nReadMsgCount = %i", nReadMsgCount);
						NSString *noticeDateMsg = [self compareLastMsgDate:lastRegDateNumber afterMsgUnixTimeStamp:createTimeNumber];
						//						NSLog(@"retrieveSessionMessage 이전데이터날짜 = %@  신규 데이터 날짜 = %@", lastRegDateNumber, createTimeNumber);
						if (noticeDateMsg) {
							// 메시지 DB, 메모리에 추가
							[MessageInfo findWithSqlWithParameters:
							 @"insert into _TMessageInfo(CHATSESSION, MESSAGEKEY, MSG, MSGTYPE, REGDATE, PKEY, NICKNAME, PHOTOURL, ISSENDMSG, ISSUCCESS, READMARKCOUNT) "
							 "values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", 
							 chatSessionKey, [self generateUUIDString], noticeDateMsg, @"D", createTimeNumber, @"", @"", @"", @"", @"1", [NSNumber numberWithInt:0], nil];
							
							CellMsgData *newMsgData = [[CellMsgData alloc] init];
							//							assert(newMsgData != nil);
							newMsgData.chatsession = chatSessionKey;
							newMsgData.contentsMsg = noticeDateMsg;
							newMsgData.msgType = @"D";
							newMsgData.regTime = createTimeNumber;
							[newMsgData setIsSend:NO];
							@synchronized(msgArray) {
								[msgArray addObject:newMsgData];
							}
							[newMsgData release];
						}
						
						// 메모리에 추가
						if (openChatSession && [openChatSession isEqualToString:chatSessionKey]) {
							// msgArray
							@synchronized(msgArray) {
								for (CellMsgData *msgData in msgArray) {
									if([msgData.chatsession isEqualToString:chatSessionKey]) {
										CellMsgData *newMsgData = [[CellMsgData alloc] init];
										//										assert(newMsgData != nil);
										newMsgData.chatsession = chatSessionKey;
										newMsgData.contentsMsg = message;
										newMsgData.messagekey = messageKey;
										newMsgData.msgType = mType;
										// sochae 2010.10.12 - nicname은 NSUserDefaults에만 저장.
										//newMsgData.nickName = [myInfoDictionary objectForKey:@"nickName"];
										//DebugLog(@"내가 보낸 메시지 nickname = %@", newMsgData.nickName);
										newMsgData.nickName = (NSString *)[JYUtil loadFromUserDefaults:kNickname];
										DebugLog(@"다른 곳에서 내가 보낸 메시지 nickname = %@", newMsgData.nickName);
										newMsgData.photoUrl = @"";
										newMsgData.pKey = ownerPKey;
										newMsgData.regTime = createTimeNumber;
										[newMsgData setIsSend:YES];
										[msgArray addObject:newMsgData];
										[newMsgData release];
										break;
									} else {
										// error
										break;
									}
								}
							}
						}
						
						/* sochae 2010.09.30 issue - 웹에서 대화 수신 시 죽는 문제 수정. (실시간 대화 업데이트는 수정 필요)
						[MessageInfo findWithSqlWithParameters:
						 @"insert into _TMessageInfo(CHATSESSION, MESSAGEKEY, MSG, MSGTYPE, REGDATE, PKEY, NICKNAME, PHOTOURL, ISSENDMSG, ISSUCCESS, READMARKCOUNT) "
						 "values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", chatSessionKey, messageKey, message, mType, createTimeNumber, ownerPKey, (NSString*)[myInfoDictionary objectForKey:@"nickName"], @"", @"1", @"1", [NSNumber numberWithInt:0], nil];
						 */
						[MessageInfo findWithSqlWithParameters:
						 @"insert into _TMessageInfo(CHATSESSION, MESSAGEKEY, MSG, MSGTYPE, REGDATE, PKEY, NICKNAME, PHOTOURL, ISSENDMSG, ISSUCCESS, READMARKCOUNT) "
						 "values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", chatSessionKey, messageKey, message, mType, createTimeNumber, ownerPKey, ([JYUtil loadFromUserDefaults:kNickname] == nil)? [NSNull null] : [JYUtil loadFromUserDefaults:kNickname], @"", @"1", @"1", [NSNumber numberWithInt:0], nil];
						// ~sochae
						
						// 대화 리스트창에 마지막 메시지 업데이트 처리
						NSArray *checkDB = [RoomInfo findWithSqlWithParameters:@"select * from _TRoomInfo where CHATSESSION=?", chatSessionKey, nil];
						if (checkDB && [checkDB count] > 0) {
							[RoomInfo findWithSqlWithParameters:@"update _TRoomInfo set LASTMESSAGEKEY=?, LASTMSG=?, LASTMSGTYPE=?, LASTMSGDATE=? where CHATSESSION=?",
							 messageKey, message, mType, createTimeNumber, chatSessionKey, nil];
							//							[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadMsgList" object:nil];
						} else {
							// error
						}
					} else {	// 친구가 보낸 데이터
						nReadMsgCount++;
						//						NSLog(@"retrieveSessionMessage 친구가 보낸 데이터 nReadMsgCount = %i", nReadMsgCount);
						// DB에 추가
						// 날짜 비교후 날짜 정보 저장
						NSString *noticeDateMsg = [self compareLastMsgDate:lastRegDateNumber afterMsgUnixTimeStamp:createTimeNumber];
						//						NSLog(@"retrieveSessionMessage 이전데이터날짜 = %@  신규 데이터 날짜 = %@", lastRegDateNumber, createTimeNumber);
						if (noticeDateMsg) {
							// 메시지 DB, 메모리에 추가
							[MessageInfo findWithSqlWithParameters:
							 @"insert into _TMessageInfo(CHATSESSION, MESSAGEKEY, MSG, MSGTYPE, REGDATE, PKEY, NICKNAME, PHOTOURL, ISSENDMSG, ISSUCCESS, READMARKCOUNT) "
							 "values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", chatSessionKey, [self generateUUIDString], noticeDateMsg, @"D", createTimeNumber, @"", @"", @"", @"", @"1", [NSNumber numberWithInt:0], nil];
							
							CellMsgData *newMsgData = [[CellMsgData alloc] init];
							//							assert(newMsgData != nil);
							newMsgData.chatsession = chatSessionKey;
							newMsgData.contentsMsg = noticeDateMsg;
							newMsgData.msgType = @"D";
							newMsgData.regTime = createTimeNumber;
							[newMsgData setIsSend:NO];
							@synchronized(msgArray) {
								[msgArray addObject:newMsgData];
							}
							[newMsgData release];
						}
						
						//						NSLog(@"retrieveSessionMessage  chatSessionKey = %@   ownerPKey = %@", chatSessionKey, ownerPKey);
						// 메모리에서 확인
						MsgUserData *userData = [self MsgListUserInfo:chatSessionKey pkey:ownerPKey];
						if (userData) {
							// 메모리에 추가
							if (openChatSession && [openChatSession isEqualToString:chatSessionKey]) {
								// msgArray
								@synchronized(msgArray) {
									if (msgArray) {
										if ([msgArray count] > 0) {
											for (CellMsgData *msgData in msgArray) {	// 메모리에 있는 값의 채팅방 세션이 같은가?
												if([msgData.chatsession isEqualToString:chatSessionKey]) {
													CellMsgData *newMsgData = [[CellMsgData alloc] init];
													//													assert(newMsgData != nil);
													newMsgData.chatsession = chatSessionKey;
													newMsgData.contentsMsg = message;
													newMsgData.messagekey = messageKey;
													newMsgData.msgType = mType;
													if (userData) {
														newMsgData.nickName = userData.nickName;
														newMsgData.photoUrl = userData.photoUrl;
														newMsgData.pKey = userData.pKey;
													} else {
														// error
													}
													newMsgData.regTime = createTimeNumber;
													[newMsgData setIsSend:NO];
													
													[msgArray addObject:newMsgData];
													[newMsgData release];
													break;
												} else {
													// error
													break;
												}
											}
										} else {
											CellMsgData *newMsgData = [[CellMsgData alloc] init];
											//											assert(newMsgData != nil);
											newMsgData.chatsession = chatSessionKey;
											newMsgData.contentsMsg = message;
											newMsgData.messagekey = messageKey;
											newMsgData.msgType = mType;
											if (userData) {
												newMsgData.nickName = userData.nickName;
												newMsgData.photoUrl = userData.photoUrl;
												newMsgData.pKey = userData.pKey;
											} else {
												// error
											}
											newMsgData.regTime = createTimeNumber;
											[newMsgData setIsSend:NO];
											
											[msgArray addObject:newMsgData];
											[newMsgData release];
										}
									}
								}
							}
							[MessageInfo findWithSqlWithParameters:
							 @"insert into _TMessageInfo(CHATSESSION, MESSAGEKEY, MSG, MSGTYPE, REGDATE, PKEY, NICKNAME, PHOTOURL, ISSENDMSG, ISSUCCESS, READMARKCOUNT) "
							 "values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", chatSessionKey, messageKey, message, mType, createTimeNumber, ownerPKey, userData.nickName, userData.photoUrl, @"0", @"1", [NSNumber numberWithInt:0], nil];
						} else {
							// skip
							// 대화창 메모리 정보에 친구 정보 있어야 함. 없으면 에러. ㅠㅠ
							NSLog(@"retrieveSessionMessage 대화창 메모리 정보에 친구 정보 있어야 함. 없으면 에러. ㅠㅠ");
						}
					}
				} else {	// J:입장 Q:퇴장
					// 날짜 비교후 날짜 정보 저장
					NSLog(@"retrieveSessionMessage J:입장 Q:퇴장 mType = %@", mType);
					
					if ([mType isEqualToString:@"Q"] && [ownerPKey isEqualToString:[self.myInfoDictionary objectForKey:@"pkey"]]) {
						
					} else {
						NSString *noticeDateMsg = [self compareLastMsgDate:lastRegDateNumber afterMsgUnixTimeStamp:createTimeNumber];
						//						NSLog(@"retrieveSessionMessage 이전데이터날짜 = %@  신규 데이터 날짜 = %@", lastRegDateNumber, createTimeNumber);
						if (noticeDateMsg) {
							// 메시지 DB, 메모리에 추가
							[MessageInfo findWithSqlWithParameters:
							 @"insert into _TMessageInfo(CHATSESSION, MESSAGEKEY, MSG, MSGTYPE, REGDATE, PKEY, NICKNAME, PHOTOURL, ISSENDMSG, ISSUCCESS, READMARKCOUNT) "
							 "values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", chatSessionKey, [self generateUUIDString], noticeDateMsg, @"D", createTimeNumber, @"", @"", @"", @"", @"1", [NSNumber numberWithInt:0], nil];
							
							CellMsgData *newMsgData = [[CellMsgData alloc] init];
							//							assert(newMsgData != nil);
							newMsgData.chatsession = chatSessionKey;
							newMsgData.contentsMsg = noticeDateMsg;
							newMsgData.msgType = @"D";
							newMsgData.regTime = createTimeNumber;
							[newMsgData setIsSend:NO];
							@synchronized(msgArray) {
								[msgArray addObject:newMsgData];
							}
							[newMsgData release];
						}
						
						// DB 저장
						[MessageInfo findWithSqlWithParameters:
						 @"insert into _TMessageInfo(CHATSESSION, MESSAGEKEY, MSG, MSGTYPE, REGDATE, PKEY, NICKNAME, PHOTOURL, ISSENDMSG, ISSUCCESS, READMARKCOUNT) "
						 "values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", chatSessionKey, messageKey, message, mType, createTimeNumber, @"", @"", @"", @"", @"1", [NSNumber numberWithInt:0], nil];
						
						// 현재 열려 있는 대화방과 같으면 입력
						if ([openChatSession isEqualToString:chatSessionKey]) {
							// 메모리 저장
							@synchronized(msgArray) {
								if (msgArray) {
									CellMsgData *msgData = [[CellMsgData alloc] init];
									//									assert(msgData != nil);
									msgData.chatsession = chatSessionKey;
									msgData.msgType = mType;
									msgData.contentsMsg = message;
									msgData.messagekey = messageKey;
									msgData.readMarkCount = 0;
									msgData.regTime = createTimeNumber;
									msgData.sendMsgSuccess = @"1";
									[msgArray addObject:msgData];
									[msgData release];
								}
							}
						}
						if ([mType isEqualToString:@"J"]) {
							// 사람이 들어왔을 경우 getChatPationPants NOTI_CHAT_ENTER 에서 DB, 메모리 추가 처리
						} else if ([mType isEqualToString:@"Q"]) {
							//*						// 사람이 나갔을 경우 NOTI_CHAT_EXIT 에서 DB, 메모리 제거 처리
							// DB 삭제
							NSArray *checkDBMsgUserArray = [MessageUserInfo findWithSqlWithParameters:@"select * from _TMessageUserInfo where CHATSESSION=? and PKEY=?", chatSessionKey, ownerPKey, nil];
							if (checkDBMsgUserArray && [checkDBMsgUserArray count] > 0) {
								[MessageUserInfo findWithSqlWithParameters:@"delete from _TMessageUserInfo where CHATSESSION=? and PKEY=?", chatSessionKey, ownerPKey, nil];
							}
							// 메모리 삭제
							@synchronized(msgListArray) {
								if (msgListArray && [msgListArray count] > 0) {
									for (CellMsgListData *msgListData in msgListArray) {
										if ([msgListData.chatsession isEqualToString:chatSessionKey]) {
											if (msgListData.userDataDic && [msgListData.userDataDic count] > 0) {
												[msgListData.userDataDic removeObjectForKey:ownerPKey];
											}
											break;
										}
									}
								}
							}
							//*/
						}
					}
					
					// msgList
				}
			}
			// 대화 리스트창에 마지막 메시지 업데이트 처리
			
			//			NSLog(@"retrieveSessionMessage total nReadMsgCount = %i", nReadMsgCount);
			if (nReadMsgCount == 0) {
				if (messageKey && [messageKey length] > 0 && chatSessionKey && [chatSessionKey length] > 0) {
					NSArray *checkDB = [RoomInfo findWithSqlWithParameters:@"select * from _TRoomInfo where CHATSESSION=?", chatSessionKey, nil];
					if (checkDB && [checkDB count] > 0) {
						[RoomInfo findWithSqlWithParameters:@"update _TRoomInfo set LASTMESSAGEKEY=? where CHATSESSION=?",
						 messageKey, chatSessionKey, nil];
					}
				}
			} else if (nReadMsgCount > 0) {
				// 새 메시지 수 DB에서 삭제.
				NSArray *checkDB = [RoomInfo findWithSqlWithParameters:@"select * from _TRoomInfo where CHATSESSION=?", chatSessionKey, nil];
				if (checkDB && [checkDB count] > 0) {
					NSInteger dbNewMsgCount = 0;
					for (RoomInfo *roomInfo in checkDB) {
						dbNewMsgCount = [roomInfo.NEWMSGCOUNT intValue];
						if(nReadMsgCount <= dbNewMsgCount) {
							dbNewMsgCount -= nReadMsgCount;
						} else {
							dbNewMsgCount = 0;
						}
					}
					
					[RoomInfo findWithSqlWithParameters:@"update _TRoomInfo set LASTMESSAGEKEY=?, LASTMSG=?, LASTMSGTYPE=?, LASTMSGDATE=?, NEWMSGCOUNT=? where CHATSESSION=?",
					 messageKey, lastMessage, lastMessageType, lastMessageDateNumber, [NSNumber numberWithInt:dbNewMsgCount], chatSessionKey, nil];
				} else {
					// error
				}
				
				if (msgListArray && [msgListArray count] > 0) {
					for (CellMsgListData *msgListData in msgListArray) {
						if ([msgListData.chatsession isEqualToString:chatSessionKey]) {
							msgListData.lastmessagekey = messageKey;
							if ([lastMessageType isEqualToString:@"T"] || [lastMessageType isEqualToString:@"P"] || [lastMessageType isEqualToString:@"V"]) {
								msgListData.lastMsg = lastMessage;
								msgListData.lastMsgType = lastMessageType;
								msgListData.lastMsgDate = [NSString stringWithFormat:@"%llu", [lastMessageDateNumber longLongValue]];
								if (nReadMsgCount <= msgListData.newMsgCount) {
									msgListData.newMsgCount -= nReadMsgCount;
								} else {
									msgListData.newMsgCount = 0;
								}
							}
							break;
						}
					}
					//					for (CellMsgListData *msgListData1 in msgListArray) {
					//						NSLog(@"retrieveSessionMessage lastMsgDate=%@", msgListData1.lastMsgDate);
					//					}
					NSSortDescriptor *lastMsgDateSort = [[NSSortDescriptor alloc] initWithKey:@"lastMsgDate" ascending:NO selector:@selector(compare:)];
					[msgListArray sortUsingDescriptors:[NSArray arrayWithObject:lastMsgDateSort]];
					[lastMsgDateSort release];
				}
			}
			
			// DB에서 읽어서 Badge표기
			NSInteger nNewMsgCount = [self newMessageCount];
			if (nNewMsgCount == 0) {
				UITabBarItem *tbi = [rootController.tabBar.items objectAtIndex:2]; //기존 1->2로
				if (tbi) {
					tbi.badgeValue = nil;
				}
				[[UIApplication sharedApplication] setApplicationIconBadgeNumber:nNewMsgCount];
				
				NSLog(@"======badgeValue 5 : %d", nNewMsgCount);
			} else if (nNewMsgCount > 0) {
				UITabBarItem *tbi = [rootController.tabBar.items objectAtIndex:2]; //기존 1->2로
				if (tbi) {
					tbi.badgeValue = [NSString stringWithFormat:@"%i", nNewMsgCount];
				}
				[[UIApplication sharedApplication] setApplicationIconBadgeNumber:nNewMsgCount];
				
				NSLog(@"======badgeValue 6 : %d", nNewMsgCount);
			} else {
				
			}
			// 현재 열린 대화창과 sessionKey 값이 같으면 Notification 요청
			if (openChatSession && [openChatSession isEqualToString:chatSessionKey]) {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadMessage" object:chatSessionKey];
			}
			if (msgListArray && [msgListArray count] > 0) {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadMsgList" object:nil];
			}
		} else {
			// 예외처리
		}
	} else if ([rtcode isEqualToString:@"-9030"]) {
		// 처리 오류9030
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-9030)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else {
		// TODO: 실패 예외처리 필요
		// fail (-8080 이외 기타오류)
		NSString *string = [NSString stringWithFormat:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-%@)", rtcode];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:string delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		
		//		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0050)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	}
}

// 발송한 메시지 응답. 텍스트, 사진, 동영상
-(void)createNewMessage:(NSNotification *)notification
{
	USayHttpData *data = (USayHttpData*)[notification object];
	if (data == nil) {
		//		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		//		[alertView show];
		//		[alertView release];
		//		return;
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
	rtcode = [dic objectForKey:@"rtcode"];
	
	// 1. 성공시 (ISSUCCESS 1: 성공)
	//    T : MESSAGEKEY, ISSUCCESS update 처리			
	//    P : MESSAGEKEY, MSG, ISSUCCESS update 처리
	//    V : MESSAGEKEY, MSG, ISSUCCESS update 처리  MOVIEFILEPATH 파일 삭제
	
	// 2. 실패시 (ISSUCCESS -1: 실패)
	//    T : ISSUCCESS update 처리
	//    P : ISSUCCESS update 처리
	//    V : ISSUCCESS update 처리
	
	if ([rtcode isEqualToString:@"0"]) {	// success
		NSString *rtType = [dic objectForKey:@"rttype"];
		if ([rtType isEqualToString:@"map"]) {
			// Key and Dictionary as its value type
			NSDictionary *addressDic = [dic objectForKey:@"map"];
			//			assert(addressDic != nil);
			NSString *message = [addressDic objectForKey:@"message"];		// 메시지 내용
			NSString *mType = [addressDic objectForKey:@"mType"];			// 메시지 타입	T:텍스트 P:사진 V:동영상
			NSString *sessionkey = [addressDic objectForKey:@"sessionKey"];
			NSString *messagekey = [addressDic objectForKey:@"messageKey"];	// 메시지 고유키
			NSString *uuid = [addressDic objectForKey:@"uuid"];
			
			if (!(message && [message length] > 0)) return;
			if (!(mType && [mType length] > 0)) return;
			if (!(sessionkey && [sessionkey length] > 0)) return;
			if (!(messagekey && [messagekey length] > 0)) return;
			if (!(uuid && [uuid length] > 0)) return;
			
			NSNumber *createTimeNumber = nil;
			//			NSString *lastMessageKey = nil;
			// 대화 DB update
			NSArray *checkDB = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where MESSAGEKEY=?", messagekey, nil];
			if (checkDB && [checkDB count] > 0) {
				// skip
			} else {
				if ([mType isEqualToString:@"T"]) {
					NSArray *checkDB = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where MESSAGEKEY=?", uuid, nil];
					if (checkDB && [checkDB count] > 0) {
						[MessageInfo findWithSqlWithParameters:@"update _TMessageInfo set MESSAGEKEY=?, ISSUCCESS=? where MESSAGEKEY=?", 
						 messagekey, @"1", uuid, nil];
						for (MessageInfo *messageInfo in checkDB) {
							createTimeNumber = messageInfo.REGDATE;
						}
					}
				} else if ([mType isEqualToString:@"P"]) {
					NSArray *checkDB = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where MESSAGEKEY=?", uuid, nil];
					if (checkDB && [checkDB count] > 0) {
						[MessageInfo findWithSqlWithParameters:@"update _TMessageInfo set MESSAGEKEY=?, MSG=?, ISSUCCESS=? where MESSAGEKEY=?", 
						 messagekey, message, @"1", uuid, nil]; 
						for (MessageInfo *messageInfo in checkDB) {
							createTimeNumber = messageInfo.REGDATE;
						}
					}
				} else if ([mType isEqualToString:@"V"]) {
					NSArray *checkDB = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where MESSAGEKEY=?", uuid, nil];
					if (checkDB && [checkDB count] > 0) {
						[MessageInfo findWithSqlWithParameters:@"update _TMessageInfo set MESSAGEKEY=?, MSG=?, ISSUCCESS=? where MESSAGEKEY=?", 
						 messagekey, message, @"1", uuid, nil];
						for (MessageInfo *messageInfo in checkDB) {
							createTimeNumber = messageInfo.REGDATE;
						}
					}
					
					NSArray *messageInfoDBArray = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where MESSAGEKEY=?", messagekey, nil];
					
					if (messageInfoDBArray && [messageInfoDBArray count] == 1) {
						for (MessageInfo *messageInfo in messageInfoDBArray) {
							if (messageInfo.MOVIEFILEPATH && [messageInfo.MOVIEFILEPATH length] > 0) {
								if ([[NSFileManager defaultManager] fileExistsAtPath:messageInfo.MOVIEFILEPATH isDirectory:NO]) {
									NSError *error = nil;
									BOOL successed = [[NSFileManager defaultManager] removeItemAtPath:messageInfo.MOVIEFILEPATH error:&error];
									if (!successed) {
										NSLog(@"error removeItemAtPath %@", [error localizedDescription]);
									}
								}
							}
						}
					}
				} else {
					// skip
					return;
				}
			}
			//			NSString	*messageCType = nil;
			// 대화 메모리 update
			@synchronized(msgArray) {
				if (msgArray) {
					//					NSLog(@"msgArray = %i", [msgArray count]);
					for (CellMsgData *msgData in msgArray) {
						//						NSLog(@"msgData.chatsession = %@  sessionkey = %@", msgData.chatsession, sessionkey);
						if ([msgData.chatsession isEqualToString:sessionkey]) {
							if ([msgData.messagekey isEqualToString:uuid]) {
								msgData.messagekey = messagekey;
								msgData.sendMsgSuccess = @"1";
								if ([mType isEqualToString:@"T"]) {
									// skip
								} else if ([mType isEqualToString:@"P"]) {
									// skip
									//									msgData.contentsMsg = message;
								} else if ([mType isEqualToString:@"V"]) {
									msgData.contentsMsg = message;
									msgData.movieFilePath = @"";
								} else {
									// skip
								}
								break;
							}
						} else {
						}
					}
				}
			}
			
			// 대화리스트 메모리 update
			if (msgListArray && [msgListArray count] > 0) {
				for (CellMsgListData *msgListData in msgListArray) {
					//						NSLog(@"CreateNewMessage msgListData.chatsession = %@   sessiokey = %@   msgListArray.count = %i", msgListData.chatsession, sessionkey, [msgListArray count]);
					if ([msgListData.chatsession isEqualToString:sessionkey]) {
						//							msgListData.lastmessagekey = messagekey;
						msgListData.lastMsg = [NSString stringWithString:message];
						msgListData.lastMsgType = [NSString stringWithString:mType];
						//NSLog(@"longlong %llu", [createTimeNumber longLongValue]);
						msgListData.lastMsgDate = [NSString stringWithFormat:@"%llu", [createTimeNumber longLongValue]];
						//							messageCType = msgListData.cType;
						break;
					} else {
					}
				}
			}
			// 대화리스트 DB 
			NSArray *checkDBRoomInfo = [RoomInfo findWithSqlWithParameters:@"select * from _TRoomInfo where CHATSESSION=?", sessionkey, nil];			
			if (checkDBRoomInfo && [checkDBRoomInfo count] > 0) {
				// update
				//				[RoomInfo findWithSqlWithParameters:@"update _TRoomInfo set LASTMESSAGEKEY=?, LASTMSG=?, LASTMSGTYPE=?, LASTMSGDATE=? where CHATSESSION=?",
				//				 messagekey, message, mType, createTimeNumber, sessionkey, nil];
				
				[RoomInfo findWithSqlWithParameters:@"update _TRoomInfo set LASTMSG=?, LASTMSGTYPE=?, LASTMSGDATE=? where CHATSESSION=?",
				 message, mType, createTimeNumber, sessionkey, nil];
			} else {
				// error
				//				if (messageCType && [messageCType length] > 0) {
				//					[RoomInfo findWithSqlWithParameters:@"insert into _TRoomInfo(CHATSESSION, CTYPE, LASTMSG, LASTMSGTYPE, LASTMSGDATE, NEWMSGCOUNT) values(?,?,?,?,?,?,?,?)",
				//					 sessionkey, messageCType, message, mType, createTimeNumber, [NSNumber numberWithInt:0], nil];
				//				} else {
				//					[RoomInfo findWithSqlWithParameters:@"insert into _TRoomInfo(CHATSESSION, CTYPE, LASTMSG, LASTMSGTYPE, LASTMSGDATE, NEWMSGCOUNT) values(?,?,?,?,?,?,?,?)",
				//					 sessionkey, @"", message, mType, createTimeNumber, [NSNumber numberWithInt:0],nil];
				//				}
			}
			/*
			 // 대화리스트 DB update (마지막 메시지 업데이트 (마지막메시지키, msg))
			 NSArray *checkRoomInfoDB = [RoomInfo findWithSqlWithParameters:@"select * from _TRoomInfo where CHATSESSION=?", sessionkey, nil];
			 if (checkRoomInfoDB && [checkRoomInfoDB count] > 0) {
			 NSArray *messageInfoDBArray = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where MESSAGEKEY=?", messagekey, nil];
			 if (messageInfoDBArray && [messageInfoDBArray count] == 1) {
			 for(MessageInfo *messageInfo in messageInfoDBArray) {
			 
			 if ([mType isEqualToString:@"T"]) {
			 [RoomInfo findWithSqlWithParameters:@"update _TRoomInfo set LASTMESSAGEKEY=? where CHATSESSION=?",
			 messagekey, sessionkey, nil];
			 } else if ([mType isEqualToString:@"P"]) {
			 // url 변경
			 [RoomInfo findWithSqlWithParameters:@"update _TRoomInfo set LASTMESSAGEKEY=?, LASTMSG=? where CHATSESSION=?",
			 messagekey, message, sessionkey, nil];
			 } else if ([mType isEqualToString:@"V"]) {
			 // url 변경
			 [RoomInfo findWithSqlWithParameters:@"update _TRoomInfo set LASTMESSAGEKEY=?, LASTMSG=? where CHATSESSION=?",
			 messagekey, message, sessionkey, nil];
			 } else {
			 // skip
			 }
			 }						
			 }
			 }
			 //*/
			
			if (msgListArray && [msgListArray count] > 0) {
				//				for (CellMsgListData *msgListDate1 in msgListArray) {
				//					NSLog(@"CreateNewMessage lastMsgDate=%@", msgListDate1.lastMsgDate);
				//				}
				NSSortDescriptor *lastMsgDateSort = [[NSSortDescriptor alloc] initWithKey:@"lastMsgDate" ascending:NO selector:@selector(compare:)];
				if (lastMsgDateSort) {
					[msgListArray sortUsingDescriptors:[NSArray arrayWithObject:lastMsgDateSort]];
					[lastMsgDateSort release];
				}
				[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadMsgList" object:nil];
			}
			[[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadMessage" object:sessionkey];
		} else {
			// 예외처리
			//			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
			//			[alertView show];
			//			[alertView release];
		}
		
		/*	} else if ([rtcode isEqualToString:@"-8080"]) {
		 // 알수 없는 오류
		 NSString *rtType = [dic objectForKey:@"rttype"];
		 if ([rtType isEqualToString:@"only"]) {
		 
		 }
		 } else if ([rtcode isEqualToString:@"-9010"]) {
		 // 데이터를 찾을 수 없음
		 NSString *rtType = [dic objectForKey:@"rttype"];
		 if ([rtType isEqualToString:@"only"]) {
		 
		 }
		 } else if ([rtcode isEqualToString:@"-9020"]) {
		 // 필수 파라미터 없음
		 NSString *rtType = [dic objectForKey:@"rttype"];
		 if ([rtType isEqualToString:@"only"]) {
		 
		 }
		 /*/
	} else if ([rtcode isEqualToString:@"-9030"]) {
		// 처리 오류
		NSString *rtType = [dic objectForKey:@"rttype"];
		if ([rtType isEqualToString:@"map"]) {
			// Key and Dictionary as its value type
			NSDictionary *addressDic = [dic objectForKey:@"map"];
			//			assert(addressDic != nil);
			NSString *uuid = [addressDic objectForKey:@"uuid"];
			
			// DB update
			NSArray *checkDB = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where MESSAGEKEY=?", uuid, nil];
			if (checkDB && [checkDB count] > 0) {
				// 발송 성공?		-1:실패  0:기본  1:성공 
				[MessageInfo findWithSqlWithParameters:@"update _TMessageInfo set ISSUCCESS=? where MESSAGEKEY=?", 
				 @"-1", uuid, nil]; 
			}
			// msgArray 메모리 update
			@synchronized(msgArray) {
				if (msgArray) {
					for (CellMsgData *msgData in msgArray) {
						if ([msgData.messagekey isEqualToString:uuid]) {
							msgData.sendMsgSuccess = @"-1";
							[[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadMessage" object:msgData.chatsession];
							break;
						}
					}
				}
			}
		}
		//		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(error -9030)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		//		[alertView show];
		//		[alertView release];
	} else {
		// TODO: 실패 예외처리 필요
		// fail (-8080 이외 기타오류)
		NSString *rtType = [dic objectForKey:@"rttype"];
		if ([rtType isEqualToString:@"map"]) {
			// Key and Dictionary as its value type
			NSDictionary *addressDic = [dic objectForKey:@"map"];
			//			assert(addressDic != nil);
			NSString *uuid = [addressDic objectForKey:@"uuid"];
			
			// DB update
			NSArray *checkDB = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where MESSAGEKEY=?", uuid, nil];
			if (checkDB && [checkDB count] > 0) {
				// 발송 성공?		-1:실패  0:기본  1:성공 
				[MessageInfo findWithSqlWithParameters:@"update _TMessageInfo set ISSUCCESS=? where MESSAGEKEY=?", 
				 @"-1", uuid, nil]; 
			}
			// msgArray 메모리 update
			@synchronized(msgArray) {
				if (msgArray) {
					for (CellMsgData *msgData in msgArray) {
						if ([msgData.messagekey isEqualToString:uuid]) {
							msgData.sendMsgSuccess = @"-1";
							[[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadMessage" object:msgData.chatsession];
							break;
						}
					}
				}
			}
		}
		
		//		NSString *string = [NSString stringWithFormat:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(error %@)", rtcode];
		//		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:string delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		//		[alertView show];
		//		[alertView release];
	}
}

-(void)albumUploadComplete:(NSNotification *)notification
{
	USayHttpData *data = (USayHttpData*)[notification object];
	if (data == nil) {
		// 200 이외의 에러
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0050)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return;
	}
	
	//	NSString *api = data.api;
	
	NSString *resultData = data.responseData;
	
	NSLog(@"albumUploadComplete Notification = %@", resultData);
	
	// 1. Create BSJSON parser.
	SBJSON *jsonParser = [[SBJSON alloc] init];
	
	// 2. Get the result dictionary from the response string.
	NSDictionary *dic = (NSDictionary*)[jsonParser objectWithString:resultData error:NULL];
	[jsonParser release];
	// 3. Show response
	// key and value type
	NSString *rtcode = nil;
	rtcode = [dic objectForKey:@"rtcode"];
	
	if ([rtcode isEqualToString:@"0"]) {	// success
		NSString *rtType = [dic objectForKey:@"rttype"];
		if ([rtType isEqualToString:@"map"]) {
		} else {
			// 예외처리
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0051)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
			[alertView show];
			[alertView release];
		}
	} else if ([rtcode isEqualToString:@"-9030"]) {
		// 처리 오류
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-9030)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else {
		// TODO: 실패 예외처리 필요
		// fail (-8080 이외 기타오류)
		NSString *string = [NSString stringWithFormat:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-%@)", rtcode];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:string delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		
		//		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0052)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	}
}

-(void)getReadMark:(NSNotification *)notification
{
	USayHttpData *data = (USayHttpData*)[notification object];
	if (data == nil) {
		// 200 이외의 에러
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0052)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
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
	rtcode = [dic objectForKey:@"rtcode"];
	
	if ([rtcode isEqualToString:@"0"]) {	// success
		//		NSString *count = [dic objectForKey:@"count"];							// 총 메시지 데이터 리턴갯수
		NSString *rtType = [dic objectForKey:@"rttype"];
		NSString *sessionKey = [dic objectForKey:@"sessionKey"];			// 대화창 세션
		
		if (!(sessionKey && [sessionKey length] > 0)) return;
		
		if ([rtType isEqualToString:@"list"]) {
			// Key and Dictionary as its value type
			NSArray *listArray = [dic objectForKey:@"list"];
			//			assert(listArray != nil);
			for (int i=0; i < [listArray count]; i++) {
				NSDictionary *listDic = [listArray objectAtIndex:i];
				//				assert(listDic != nil);
				NSString *messageKey = [listDic objectForKey:@"messageKey"];	// 메세지 세션
				NSString *rCount = [listDic objectForKey:@"rCount"];			// 메시지 읽은 카운트 수
				
				if (!(messageKey && [messageKey length] > 0)) continue;
				if (!(rCount && [rCount length] > 0)) continue;
				
				NSArray *msgInfoArray = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where MESSAGEKEY=? and CHATSESSION=?", messageKey, sessionKey, nil];
				
				// DB 변경
				if(msgInfoArray && [msgInfoArray count] > 0) {
					for (MessageInfo* msgInfo in msgInfoArray) {
						NSInteger resultCount = [msgInfo.READMARKCOUNT intValue];
						resultCount -= [rCount intValue];
						if (resultCount < 0) {
							resultCount = 0;
						}
						[MessageInfo findWithSqlWithParameters:@"update _TMessageInfo set READMARKCOUNT=? where MESSAGEKEY=? and CHATSESSION=?", [NSNumber numberWithInt:resultCount], messageKey, sessionKey, nil]; 
						// 메모리
						@synchronized(msgArray) {
							for(CellMsgData *msgData in msgArray) {
								if ([msgData.chatsession isEqualToString:sessionKey]) {
									if ([msgData.messagekey isEqualToString:messageKey]) {
										[msgData setReadMarkCount:resultCount];
										break;
									}
								}
							}
						}
					}
				}
			}
			NSString *openChatSession = [self.myInfoDictionary objectForKey:@"openChatSession"];
			
			if ([openChatSession isEqualToString:sessionKey]) {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadMessage" object:sessionKey];
			}
		} else {
			// 예외처리
		}
	} else if ([rtcode isEqualToString:@"-9030"]) {
		// 처리 오류
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-9030)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else {
		// TODO: 실패 예외처리 필요
		// fail (-8080 이외 기타오류)
		NSString *string = [NSString stringWithFormat:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-%@)", rtcode];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:string delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		
		
		//		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	}
}

// 설정 - 프로필 설정 - 오늘의 한마디 수정
-(void)updateStatus:(NSNotification *)notification
{
	USayHttpData *data = (USayHttpData*)[notification object];
	if (data == nil) {
		// 200 이외의 에러
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0053)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
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
	rtcode = [dic objectForKey:@"rtcode"];
	
	if ([rtcode isEqualToString:@"0"]) {	// success
		NSString *rtType = [dic objectForKey:@"rttype"];
		if ([rtType isEqualToString:@"map"]) {
			NSDictionary *addressDic = [dic objectForKey:@"map"];
			//			assert(addressDic != nil);
			NSString *status = [addressDic objectForKey:@"status"];	// 오늘의 한마디
			if (status) {
				if ([status length] > 0) {
					[[NSUserDefaults standardUserDefaults] setObject:status forKey:@"status"];
					[[NSNotificationCenter defaultCenter] postNotificationName:@"completeStatus" object:status];
				} else {
					[[NSUserDefaults standardUserDefaults] setObject:status forKey:@"status"];
					[[NSNotificationCenter defaultCenter] postNotificationName:@"completeStatus" object:@""];
				}
			} else {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"completeStatus" object:nil];
			}			
		} else {
			// 예외처리
			[[NSNotificationCenter defaultCenter] postNotificationName:@"completeStatus" object:nil];
		}
	} else if ([rtcode isEqualToString:@"-8080"]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"completeStatus" object:nil];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-8080)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else if ([rtcode isEqualToString:@"-1090"]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"completeStatus" object:nil];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-1090)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else if ([rtcode isEqualToString:@"-2010"]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"completeStatus" object:nil];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-2010)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else if ([rtcode isEqualToString:@"-9030"]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"completeStatus" object:nil];
		// 처리 오류
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-9030)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"completeStatus" object:nil];
		// TODO: 실패 예외처리 필요
		// fail (-8080 이외 기타오류)
		NSString *string = [NSString stringWithFormat:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-%@)", rtcode];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:string delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		
		
		//		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	}
}

// 설정 - 프로필 설정 - 별명 수정
-(void)updateNickName:(NSNotification *)notification
{
	USayHttpData *data = (USayHttpData*)[notification object];
	if (data == nil) {
		// 200 이외의 에러
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0054)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
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
	rtcode = [dic objectForKey:@"rtcode"];
	
	if ([rtcode isEqualToString:@"0"]) {	// success
		NSString *rtType = [dic objectForKey:@"rttype"];
		if ([rtType isEqualToString:@"map"]) {
			// Key and Dictionary as its value type
			// 닉 변경
			NSDictionary *addressDic = [dic objectForKey:@"map"];
			//			assert(addressDic != nil);
			NSString *nickName = [addressDic objectForKey:@"nickName"];
			if (nickName && [nickName length] > 0)
			{
				// sochae 2010.10.12
				//[[NSUserDefaults standardUserDefaults] setObject:nickName forKey:@"nickName"];
				[JYUtil saveToUserDefaults:nickName forKey:kNickname];
				// ~sochae
				[[NSNotificationCenter defaultCenter] postNotificationName:@"completeNickName" object:nickName];
			} else {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"completeNickName" object:nil];
				return;				// 정책 : 닉이 널인 경우는 없음
			}
		} else {
			// TODO: 예외처리
		}
	} else if ([rtcode isEqualToString:@"-9030"]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"completeNickName" object:nil];
		// 처리 오류
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-9030)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else if ([rtcode isEqualToString:@"-1090"]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"completeNickName" object:nil];
		// 인증되지 않음
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-1090)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else if ([rtcode isEqualToString:@"-2010"]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"completeNickName" object:nil];
		// 세션정보를 찾을 수 없음
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-2010)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else if ([rtcode isEqualToString:@"-8080"]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"completeNickName" object:nil];
		// 기타 오류
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-8080)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"completeNickName" object:nil];
		// TODO: 실패 예외처리 필요
		// fail (-8080 이외 기타오류)
		NSString *string = [NSString stringWithFormat:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-%@)", rtcode];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:string delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		
		//		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	}
}

-(void)setMessagePreviewOnMobile:(NSNotification *)notification
{
	USayHttpData *data = (USayHttpData*)[notification object];
	if (data == nil) {
		// 200 이외의 에러
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0055)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
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
	rtcode = [dic objectForKey:@"rtcode"];
	
	if ([rtcode isEqualToString:@"0"]) {	// success
		NSString *rtType = [dic objectForKey:@"rttype"];
		if ([rtType isEqualToString:@"map"]) {
			// Key and Dictionary as its value type
			NSDictionary *addressDic = [dic objectForKey:@"map"];
			//			assert(addressDic != nil);
			NSString *isOnPreview = [addressDic objectForKey:@"isOnPreview"];
			if (isOnPreview && [isOnPreview length] > 0) {
				if ([isOnPreview isEqualToString:@"Y"]) {
					[[NSUserDefaults standardUserDefaults] setInteger:1	forKey:@"apnsonpreview"];	// 설정
				} else {
					[[NSUserDefaults standardUserDefaults] setInteger:0	forKey:@"apnsonpreview"];	// 미설정
				}
			} else {
				[[NSUserDefaults standardUserDefaults] setInteger:0	forKey:@"apnsonpreview"];	// 미설정
			}
		} else {
			// 예외처리
		}
	} else if ([rtcode isEqualToString:@"-9030"]) {
		// 처리 오류
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-9030)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else if ([rtcode isEqualToString:@"-8080"]) {	
		// unknow error
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-8080)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else {
		// TODO: 실패 예외처리 필요
		// fail (-8080 이외 기타오류)
		NSString *string = [NSString stringWithFormat:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-%@)", rtcode];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:string delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		
		//		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	}
}

-(void)deleteMyMessage:(NSNotification *)notification
{
	USayHttpData *data = (USayHttpData*)[notification object];
	if (data == nil) {
		// 200 이외의 에러
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0056)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
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
	rtcode = [dic objectForKey:@"rtcode"];
	
	if ([rtcode isEqualToString:@"0"]) {	// success
		NSString *rtType = [dic objectForKey:@"rttype"];
		if ([rtType isEqualToString:@"map"]) {
			// Key and Dictionary as its value type
			NSDictionary *addressDic = [dic objectForKey:@"map"];
			//			assert(addressDic != nil);
			NSString *messageKeys = [addressDic objectForKey:@"messageKeys"];	// 메시지 세션
			NSString *sessionKey = [addressDic objectForKey:@"sessionKey"];		// 대화방 세션
			
			if (sessionKey && [sessionKey length] > 0 && messageKeys && [messageKeys length] > 0) {
				// DB 삭제, 파일 확인후 삭제
				NSArray *checkDBMessageInfoArray = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where CHATSESSION=? and MESSAGEKEY=?", sessionKey, messageKeys, nil];
				
				if (checkDBMessageInfoArray && [checkDBMessageInfoArray count] > 0) {
					for (MessageInfo *messageInfo in checkDBMessageInfoArray) {
						if([messageInfo.MSGTYPE isEqualToString:@"P"]) {		// cache에 저장된 파일이 있으면 삭제 처리
							if (messageInfo.PHOTOFILEPATH && [messageInfo.PHOTOFILEPATH length] > 0) {
								NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
								NSString *cachesDirectory = [paths objectAtIndex:0];
								NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
								NSString *imagePath = [cachesDirectory stringByAppendingPathComponent:messageInfo.PHOTOFILEPATH];
								if (imagePath && [imagePath length] > 0) {
									if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath isDirectory:NO]) {
										NSError *error = nil;
										BOOL successed = [[NSFileManager defaultManager] removeItemAtPath:imagePath error:&error]; 
										if (!successed) {
											NSLog(@"error deleteMyMessage photo removeItemAtPath %@", [error localizedDescription]);
										}
									}
								}
								[pool release];
							}
						} else if ([messageInfo.MSGTYPE isEqualToString:@"V"]) {// cache에 저장된 파일이 있으면 삭제 처리
							if (messageInfo.MOVIEFILEPATH && [messageInfo.MOVIEFILEPATH length] > 0) {
								NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
								NSString *cachesDirectory = [paths objectAtIndex:0];
								NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
								NSString *imagePath = [cachesDirectory stringByAppendingPathComponent:messageInfo.MOVIEFILEPATH];
								if (imagePath && [imagePath length] > 0) {
									if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath isDirectory:NO]) {
										NSError *error = nil;
										BOOL successed = [[NSFileManager defaultManager] removeItemAtPath:imagePath error:&error]; 
										if (!successed) {
											NSLog(@"error deleteMyMessage movie removeItemAtPath %@", [error localizedDescription]);
										}
									}
								}
								[pool release];
							}
						} else {
							// skip
						}
					}
					[MessageInfo findWithSqlWithParameters:@"delete from _TMessageInfo where CHATSESSION=? and MESSAGEKEY=?", sessionKey, messageKeys, nil];
				}
			}
		} else {
			// 예외처리
		}
	} else if ([rtcode isEqualToString:@"-9030"]) {
		// 처리 오류
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-9030)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else if ([rtcode isEqualToString:@"-8080"]) {	
		// unknow error
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-8080)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else {
		// TODO: 실패 예외처리 필요
		// fail (-8080 이외 기타오류)
		NSString *string = [NSString stringWithFormat:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-%@)", rtcode];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:string delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		
		//		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	}
}

-(void)getRecommendFriendsList:(NSNotification *)notification
{
	USayHttpData *data = (USayHttpData*)[notification object];
	if (data == nil) {
		// 200 이외의 에러
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0057)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
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
	rtcode = [dic objectForKey:@"rtcode"];
	
	if ([rtcode isEqualToString:@"0"]) {	// success
		NSString *rtType = [dic objectForKey:@"rttype"];
		if ([rtType isEqualToString:@"list"]) {
			// Key and Dictionary as its value type
			NSArray *listArray = [dic objectForKey:@"list"];
			//			assert(listArray != nil);
			BOOL	bExist = NO;
			for (int i=0; i < [listArray count]; i++) {
				NSDictionary *listDic = [listArray objectAtIndex:i];
				//				assert(listDic != nil);
				CellUserData *cellUserData = [[CellUserData alloc] init];
				//				assert(cellUserData != nil);
				cellUserData.pkey = [listDic objectForKey:@"pKey"];						// 
				cellUserData.nickName = [listDic objectForKey:@"nickName"];				// 별명
				cellUserData.status = [listDic objectForKey:@"status"];					// 오늘의 한마디
				cellUserData.representPhoto = [listDic objectForKey:@"representPhoto"];	// 대표사진
				if (cellUserData.pkey && [cellUserData.pkey length] > 0 && cellUserData.nickName && [cellUserData.nickName length] > 0) {
					if (proposeUserArray) {
						for (CellUserData *userData in proposeUserArray) {
							if (userData) {
								if ([userData.pkey isEqualToString:cellUserData.pkey]) {
									bExist = YES;
									break;
								}
							}
						}
					}
					if(bExist == NO) {
						[proposeUserArray addObject:cellUserData];
					}
				} else {
				}
				[cellUserData release];
			}		
			
			NSInteger nCount = [proposeUserArray count];
			if (nCount == 0) {
				UITabBarItem *tbi = [rootController.tabBar.items objectAtIndex:3]; //기존 2->3로
				if (tbi) {
					tbi.badgeValue = nil;
				}
			} else if (nCount > 0) {
				UITabBarItem *tbi = [rootController.tabBar.items objectAtIndex:3]; //기존 2->3로
				if (tbi) {
					tbi.badgeValue = [NSString stringWithFormat:@"%i", nCount];
					[self playSystemSoundIDSound];
					[self playSystemSoundIDVibrate];
				}
				NSSortDescriptor *nickNameSort = [[NSSortDescriptor alloc] initWithKey:@"nickName" ascending:YES];
				if (nickNameSort) {
					[proposeUserArray sortUsingDescriptors:[NSArray arrayWithObject:nickNameSort]];
					[nickNameSort release];
				}
			} else {
				// skip
			}
			
			UINavigationController* proposeUserNaviController = [rootController.tabBarController.viewControllers objectAtIndex:2];
			if (proposeUserNaviController) {
				UIViewController* proposeUserViewController = [proposeUserNaviController.viewControllers objectAtIndex:0];
				if (proposeUserViewController ) {
					[((ProposeUserViewController*)proposeUserNaviController).tableView reloadData];
				}
			}
		} else {
			// 예외처리
		}
	} else if ([rtcode isEqualToString:@"4040"]) {
		
#ifdef MEZZO_DEBUG
		NSLog(@"서버에서 친구 정보를 찾을수 없다고 내려옴");
#endif	
		
		
		// 친구 정보를 찾을 수 없음
		/*
		 CellUserData *cellUserData = [[CellUserData alloc] init];
		 assert(cellUserData != nil);
		 cellUserData.pkey = @"1";						// 
		 cellUserData.nickName = @"111";				// 별명
		 cellUserData.status = @"a";					// 오늘의 한마디
		 [proposeUserArray addObject:cellUserData];
		 [cellUserData release];
		 
		 cellUserData = [[CellUserData alloc] init];
		 assert(cellUserData != nil);
		 cellUserData.pkey = @"2";						// 
		 cellUserData.nickName = @"222";				// 별명
		 cellUserData.status = @"b";					// 오늘의 한마디
		 [proposeUserArray addObject:cellUserData];
		 [cellUserData release];
		 
		 cellUserData = [[CellUserData alloc] init];
		 assert(cellUserData != nil);
		 cellUserData.pkey = @"3";						// 
		 cellUserData.nickName = @"333";				// 별명
		 cellUserData.status = @"c";					// 오늘의 한마디
		 [proposeUserArray addObject:cellUserData];
		 [cellUserData release];
		 
		 cellUserData = [[CellUserData alloc] init];
		 assert(cellUserData != nil);
		 cellUserData.pkey = @"4";						// 
		 cellUserData.nickName = @"444";				// 별명
		 cellUserData.status = @"d";					// 오늘의 한마디
		 [proposeUserArray addObject:cellUserData];
		 [cellUserData release];
		 
		 cellUserData = [[CellUserData alloc] init];
		 assert(cellUserData != nil);
		 cellUserData.pkey = @"5";						// 
		 cellUserData.nickName = @"555";				// 별명
		 cellUserData.status = @"e";					// 오늘의 한마디
		 [proposeUserArray addObject:cellUserData];
		 [cellUserData release];
		 
		 cellUserData = [[CellUserData alloc] init];
		 assert(cellUserData != nil);
		 cellUserData.pkey = @"6";						// 
		 cellUserData.nickName = @"666";				// 별명
		 cellUserData.status = @"f";					// 오늘의 한마디
		 [proposeUserArray addObject:cellUserData];
		 [cellUserData release];
		 
		 cellUserData = [[CellUserData alloc] init];
		 assert(cellUserData != nil);
		 cellUserData.pkey = @"7";						// 
		 cellUserData.nickName = @"777";				// 별명
		 cellUserData.status = @"g";					// 오늘의 한마디
		 [proposeUserArray addObject:cellUserData];
		 [cellUserData release];
		 
		 cellUserData = [[CellUserData alloc] init];
		 assert(cellUserData != nil);
		 cellUserData.pkey = @"8";						// 
		 cellUserData.nickName = @"888";				// 별명
		 cellUserData.status = @"h";					// 오늘의 한마디
		 [proposeUserArray addObject:cellUserData];
		 [cellUserData release];
		 
		 cellUserData = [[CellUserData alloc] init];
		 assert(cellUserData != nil);
		 cellUserData.pkey = @"9";						// 
		 cellUserData.nickName = @"999";				// 별명
		 cellUserData.status = @"i";					// 오늘의 한마디
		 [proposeUserArray addObject:cellUserData];
		 [cellUserData release];
		 
		 NSInteger nCount = [proposeUserArray count];
		 if (nCount == 0) {
		 UITabBarItem *tbi = [rootController.tabBar.items objectAtIndex:2];
		 if (tbi) {
		 tbi.badgeValue = nil;
		 }
		 } else if (nCount > 0) {
		 UITabBarItem *tbi = [rootController.tabBar.items objectAtIndex:2];
		 if (tbi) {
		 tbi.badgeValue = [NSString stringWithFormat:@"%i", nCount];
		 [self playSystemSoundIDSound];
		 [self playSystemSoundIDVibrate];
		 }
		 NSSortDescriptor *nickNameSort = [[NSSortDescriptor alloc] initWithKey:@"nickName" ascending:YES];
		 if (nickNameSort) {
		 [proposeUserArray sortUsingDescriptors:[NSArray arrayWithObject:nickNameSort]];
		 [nickNameSort release];
		 }
		 } else {
		 // skip
		 }
		 
		 UINavigationController* proposeUserNaviController = [rootController.tabBarController.viewControllers objectAtIndex:2];
		 if (proposeUserNaviController) {
		 UIViewController* proposeUserViewController = [proposeUserNaviController.viewControllers objectAtIndex:0];
		 if (proposeUserViewController ) {
		 [((ProposeUserViewController*)proposeUserNaviController).tableView reloadData];
		 }
		 }
		 //*/
	} else if ([rtcode isEqualToString:@"-9030"]) {
		// 처리 오류
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-9030)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else {
		// TODO: 실패 예외처리 필요
		// fail (-8080 이외 기타오류)
		NSString *string = [NSString stringWithFormat:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-%@)", rtcode];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:string delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		
		//		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	}
	//	[self.tableView reloadData];
}

-(void)deleteRecommendFriend:(NSNotification *)notification
{
	USayHttpData *data = (USayHttpData*)[notification object];
	if (data == nil) {
		// 200 이외의 에러
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0058)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
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
	rtcode = [dic objectForKey:@"rtcode"];
	
	if ([rtcode isEqualToString:@"0"]) {	// success
		
	} else if ([rtcode isEqualToString:@"-9030"]) {
		// 처리 오류
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-9030)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else {
		// TODO: 실패 예외처리 필요
		// fail (-8080 이외 기타오류)
		NSString *string = [NSString stringWithFormat:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-%@)", rtcode];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:string delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		
		//		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	}
}

-(void)setFriendFromRecommand:(NSNotification *)notification
{
#ifdef MEZZO_DEBUG
	NSLog(@"\n=========setFriendFromRecommand==========");
#endif
	USayHttpData *data = (USayHttpData*)[notification object];
	if (data == nil) {
		// 200 이외의 에러
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 수정 내용이 반영되지 않았을 수 있습니다. 잠시 후 다시 시도해 주세요.(e0059)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
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
	rtcode = [dic objectForKey:@"rtcode"];
	
	if ([rtcode isEqualToString:@"0"]) {	// success
		// TODO: 추천친구 승락 후 response 성공 했을 때 getLastRP 요청 해야함.
		NSString *rtType = [dic objectForKey:@"rttype"];
		NSString *rp = [dic objectForKey:@"RP"];
		if ([rtType isEqualToString:@"map"]) {
			// Key and Dictionary as its value type
			NSDictionary *addressDic = [dic objectForKey:@"map"];
			
			//			NSString *imstatus = [addressDic objectForKey:@"imstatus"];
			//			NSString *formatted = [addressDic objectForKey:@"formatted"];
			//			NSString *representPhoto = [addressDic objectForKey:@"representPhoto"];
			//			NSString *status = [addressDic objectForKey:@"status"];
			//			NSString *rPCreated = [addressDic objectForKey:@"rPCreated"];
			//			NSString *sidUpdated = [addressDic objectForKey:@"sidUpdated"];
			//			NSString *mobilePhoneNumber = [addressDic objectForKey:@"mobilePhoneNumber"];
			//			NSString *userid = [addressDic objectForKey:@"id"];
			//			NSString *sidCreated = [addressDic objectForKey:@"sidCreated"];
			//			NSString *isFriend = [addressDic objectForKey:@"isFriend"];
			//			NSString *isInviteMailSented = [addressDic objectForKey:@"isInviteMailSented"];
			NSString *rPKey = [addressDic objectForKey:@"rPKey"];
			//			NSString *gid = [addressDic objectForKey:@"gid"];
			//			NSString *isTrash = [addressDic objectForKey:@"isTrash"];
			//			NSString *profileNickName = [addressDic objectForKey:@"profileNickName"];
			[addressDic setValue:rp forKey:@"RP"];
			// TODO: 차단해제하기, 닉, 대표사진, 오늘의 한마디, 상태정보 DB 값 변경후 주소록 reloadData 처리
			if (!(rPKey && [rPKey length] > 0)) return;
			[[NSNotificationCenter defaultCenter] postNotificationName:@"newFriendIncome" object:addressDic];
			
		} else {
			// 예외처리
		}
	} else if ([rtcode isEqualToString:@"-9030"]) {
		// 처리 오류
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 수정 내용이 반영되지 않았을 수 있습니다. 잠시 후 다시 시도해 주세요.(e-9030)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else {
		// TODO: 실패 예외처리 필요
		// fail (-8080 이외 기타오류)
		NSString *string;
		if([rtcode isEqualToString:@"-1070"]) {
			string= [NSString stringWithFormat:@"이미 삭제된 사용자 입니다. 에러코드 e-1070"];
			// sochae 2010.09.29
			// 탈퇴 버튼 호출했을 때와 동일한 루틴이 되도록 수정이 필요. 
			
			
			
			
		}
		else
		{
		string = [NSString stringWithFormat:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-%@)", rtcode];
		}
		UIAlertView *alertView;
		
		if([rtcode isEqualToString:@"-1070"])
		{
		alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:string delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		}
		else {
			alertView = [[UIAlertView alloc] initWithTitle:@"친구 추가 에러" message:string delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
			
		}

		//		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 수정 내용이 반영되지 않았을 수 있습니다. 잠시 후 다시 시도해 주세요." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	}
}

-(void)BlockUserCancel:(NSNotification *)notification
{
	USayHttpData *data = (USayHttpData*)[notification object];
	if (data == nil) {
		// 200 이외의 에러
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 수정 내용이 반영되지 않았을 수 있습니다. 잠시 후 다시 시도해 주세요.(e0060)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
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
	rtcode = [dic objectForKey:@"rtcode"];
	
	if ([rtcode isEqualToString:@"0"]) {			// success
		NSString *rtType = [dic objectForKey:@"rttype"];
		if ([rtType isEqualToString:@"map"]) {
			// Key and Dictionary as its value type
			NSDictionary *addressDic = [dic objectForKey:@"map"];
			//			assert(addressDic != nil);
			NSString *commStatus = [addressDic objectForKey:@"commStatus"];	
			//			assert(commStatus != nil);
			if ([commStatus isEqualToString:@"normal"]) {	// commStatus  normal:차단해제   block:차단
				//				NSString *imstatus = [addressDic objectForKey:@"imstatus"];
				//				NSString *representPhoto = [addressDic objectForKey:@"representPhoto"];
				//				NSString *nickName = [addressDic objectForKey:@"nickName"];
				//				NSString *status = [addressDic objectForKey:@"status"];
				NSString *fPkey = [addressDic objectForKey:@"fPkey"];
				[addressDic setValue:[dic objectForKey:@"RP"] forKey:@"RP"];
				// TODO: 차단해제하기, 닉, 대표사진, 오늘의 한마디, 상태정보 DB 값 변경후 주소록 reloadData 처리
				if (!(fPkey && [fPkey length] > 0)) return;
				[[NSNotificationCenter defaultCenter] postNotificationName:@"buddyBlockCancel" object:addressDic];
			} else if ([commStatus isEqualToString:@"block"]) {
				NSString *fPkey = [addressDic objectForKey:@"fPkey"];
				// TODO: 차단하기 DB 값 변경후 주소록 reloadData 처리
				if (!(fPkey && [fPkey length] > 0)) return;
				
			}
		} else {
			// 예외처리
		}
	} else if ([rtcode isEqualToString:@"4040"]) {	// 친구 정보를 찾을 수 없음
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 수정 내용이 반영되지 않았을 수 있습니다. 잠시 후 다시 시도해 주세요.(e4040)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else if ([rtcode isEqualToString:@"-9020"]) {	// 잘못 된 인자가 넘어
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 수정 내용이 반영되지 않았을 수 있습니다. 잠시 후 다시 시도해 주세요.(e-9020)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else if ([rtcode isEqualToString:@"-9030"]) {	// 처리 오류
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 수정 내용이 반영되지 않았을 수 있습니다. 잠시 후 다시 시도해 주세요.(e-9030)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else {
		// TODO: 실패 예외처리 필요
		// fail (-8080 이외 기타오류)
		NSString *string = [NSString stringWithFormat:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-%@)", rtcode];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:string delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		
		//		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 수정 내용이 반영되지 않았을 수 있습니다. 잠시 후 다시 시도해 주세요." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	}
}

-(void)insertProfilePhoto:(NSNotification *)notification
{
	USayHttpData *data = (USayHttpData*)[notification object];
	if (data == nil) {
		// 200 이외의 에러
		[[NSNotificationCenter defaultCenter] postNotificationName:@"completeProfilePhoto" object:nil];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0061)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
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
	rtcode = [dic objectForKey:@"rtcode"];
	
	if ([rtcode isEqualToString:@"0"]) {			// success
		NSString *rtType = [dic objectForKey:@"rttype"];
		if ([rtType isEqualToString:@"map"]) {
			// Key and Dictionary as its value type
			NSDictionary *addressDic = [dic objectForKey:@"map"];
			//			assert(addressDic != nil);
			//			NSString *pKey = [addressDic objectForKey:@"pKey"];	
			NSString *photoUrl = [addressDic objectForKey:@"photoUrl"];
			if (photoUrl && [photoUrl length] > 0) {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"completeProfilePhoto" object:photoUrl];
				[[NSUserDefaults standardUserDefaults] setObject:photoUrl forKey:@"representPhoto"];
				//				UINavigationController* settingNaviController = [rootController.tabBarController.viewControllers objectAtIndex:3];
				//				if (settingNaviController) {
				//					UIViewController* viewController = [settingNaviController.viewControllers objectAtIndex:1];
				////					if (viewController && ) {	
				////					}
				//				}
			}
		} else {
			// 예외처리
			[[NSNotificationCenter defaultCenter] postNotificationName:@"completeProfilePhoto" object:nil];
		}
	} 
	else if ([rtcode isEqualToString:@"4040"]) {	// 친구 정보를 찾을 수 없음
		[[NSNotificationCenter defaultCenter] postNotificationName:@"completeProfilePhoto" object:nil];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e4040)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else if ([rtcode isEqualToString:@"-9020"]) {	// 잘못 된 인자가 넘어
		[[NSNotificationCenter defaultCenter] postNotificationName:@"completeProfilePhoto" object:nil];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-9020)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else if ([rtcode isEqualToString:@"-9030"]) {	// 처리 오류
		[[NSNotificationCenter defaultCenter] postNotificationName:@"completeProfilePhoto" object:nil];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-9030)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else {
		// TODO: 실패 예외처리 필요
		// fail (-8080 이외 기타오류)
		[[NSNotificationCenter defaultCenter] postNotificationName:@"completeProfilePhoto" object:nil];
		NSString *string = [NSString stringWithFormat:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-%@)", rtcode];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:string delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		
		//		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	}
}

-(void)insertContactPhoto:(NSNotification *)notification
{
	USayHttpData *data = (USayHttpData*)[notification object];
	if (data == nil) {
		// 200 이외의 에러
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0062)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
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
	rtcode = [dic objectForKey:@"rtcode"];
	
	if ([rtcode isEqualToString:@"0"]) {			// success
		NSString *rtType = [dic objectForKey:@"rttype"];
		if ([rtType isEqualToString:@"map"]) {
			// Key and Dictionary as its value type
			NSDictionary *addressDic = [dic objectForKey:@"map"];
			//			assert(addressDic != nil);
			//			NSString *pKey = [addressDic objectForKey:@"pKey"];	
			//			NSString *cid = [addressDic objectForKey:@"cid"];	
			NSString *photoUrl = [addressDic objectForKey:@"photoUrl"];
			if (photoUrl && [photoUrl length] > 0) {
				//
			}
		} else {
			// 예외처리
		}
	} else if ([rtcode isEqualToString:@"-9020"]) {	// 잘못 된 인자가 넘어
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-9020)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else if ([rtcode isEqualToString:@"-9030"]) {	// 처리 오류
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-9030)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else {
		// TODO: 실패 예외처리 필요
		// fail (-8080 이외 기타오류)
		NSString *string = [NSString stringWithFormat:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-%@)", rtcode];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:string delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		
		//		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	}
}

// mezzo 회원 탈퇴
-(void)withdrawal:(NSNotification *)notification
{
	NSLog(@"USayAppAppDelegate :: withdrawal");
	USayHttpData *data = (USayHttpData*)[notification object];
	if (data == nil) {
		// 200 이외의 에러
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0062)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
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
	rtcode = [dic objectForKey:@"rtcode"];
	
	if ([rtcode isEqualToString:@"0"]) {			// success
		[[NSNotificationCenter defaultCenter] postNotificationName:@"responseWithdrawal" object:[NSString stringWithFormat:rtcode]];
		//plist 삭제
/*		[[NSUserDefaults standardUserDefaults] setPersistentDomain:[NSDictionary dictionary]
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
		
		UIAlertView *myAlert =[[UIAlertView alloc] 
							   initWithTitle:@"회원탈퇴 완료" 
							   message:@"회원탈퇴 되었습니다. Usay주소록을\n종료합니다." 
							   delegate:self 
							   cancelButtonTitle:@"확인" 
							   otherButtonTitles:nil];
		[myAlert show];
		[myAlert release];
	
		//여기에서 탈퇴 완료후 종료.
		exit(0);
//*/ 
	}
	else {
		UIAlertView *myAlert =[[UIAlertView alloc] 
							   initWithTitle:@"회원탈퇴 실패" 
							   message:@"회원탈퇴를 실패 하였습니다. \n잠시후 다시 이용해 주세요." 
							   delegate:self 
							   cancelButtonTitle:@"확인" 
							   otherButtonTitles:nil];
		[myAlert show];
		[myAlert release];
	}

	
	
}




#pragma mark -
#pragma mark 네트워크 상태 변경시 Callback
//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )notification
{
	Reachability* curReach = [notification object];
    NetworkStatus netStatus = [curReach currentReachabilityStatus];

//	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
//	[self updateInterfaceWithReachability: curReach];
	DebugLog(@"[NET] ========== reachabilityChanged ==========");
	DebugLog(@"[NET] curReach = %@", curReach);
	DebugLog(@"[NET] netStatus (%d), connectionType (%d)", netStatus, connectionType);

	DebugLog(@"[Device] %@", [[UIDevice currentDevice] model]);
	
	//if(curReach == hostReach)
	{
		//mezzo	NSString* statusString= nil;
		switch (netStatus)
		{
			case NotReachable:
			{
				NSLog(@"[NET] NotReachable ========== >>");
				//mezzo		statusString = @"Access Not Available";
				
				//Minor interface detail- connectionRequired may return yes, even when the host is unreachable.  We cover that up here...
				//mezzo		connectionRequired= NO;
				
				if (connectionType == -1) return;	// offline 모드로 들어왔을때는 세션을 다시 접속해야 함.
				
				self.connectionType = 0;	// -1:offline mode 0:disconnect 1:Wi-Fi 2:3G
				
				NSString *model = [[UIDevice currentDevice] model];
				if (model && [model length] > 0) {
					model = [model lowercaseString];
					NSRange range = [model rangeOfString:@"iphone"];
					if (range.location != NSNotFound) {
						// iphone
					} else {
						range = [model rangeOfString:@"ipod"];
						if (range.location != NSNotFound) {
							// ipod
						} else {
							// ipad
						}
					}
				} else {
					// error
				}
				break;
			}

			case ReachableViaWWAN:	// 3G
			{
				NSLog(@"[NET] Reachable 3G ========== >>");
				//mezzo	statusString = @"Reachable WWAN";
				
				if (connectionType == -1) return;	// offline 모드로 들어왔을때는 세션을 다시 접속해야 함.
				
				if (connectionType == 0 || connectionType == 1) {
					exceptionDisconnect = YES;
					if (clientAsyncSocket) {
						if([clientAsyncSocket isConnected]) {
							[clientAsyncSocket disconnect];
							isConnected = NO;
						}
					}
				} else {
					return;
				}
				
				NSLog(@"Reachable WWAN 3G");
				self.connectionType = 2;	// -1:offline mode 0:disconnect 1:Wi-Fi 2:3G
				
				NSString *model = [[UIDevice currentDevice] model];
				if (model && [model length] > 0) {
					model = [model lowercaseString];
					NSRange range = [model rangeOfString:@"iphone"];
					if (range.location != NSNotFound) {
						// iphone
						if ([self connectedToNetwork]) {
							// 네트워크 연결 됨
							if ([self isCellNetwork]) {
								// 3G 네트워크 연결 됨
								if (exceptionDisconnect && !isConnected) {
									NSString *improxyAddr = [myInfoDictionary objectForKey:@"proxyhost"];
									NSString *improxyPort = [myInfoDictionary objectForKey:@"proxyport"];
									if (improxyAddr && [improxyAddr length] > 0 && improxyPort && [improxyPort length] > 0) {
										NSLog(@"Reachable WWAN 3G iphone 재접속 시작");
										if([self connect:improxyAddr PORT:[improxyPort intValue]]) {
											// success!
										} else {
											// TODO: 예외처리 필요 (세션연결 실패)
											if([self connect:improxyAddr PORT:[improxyPort intValue]]) {
											} else {
												// TODO: 예외처리 필요 (세션연결 실패)
												if([self connect:improxyAddr PORT:[improxyPort intValue]]) {
												} else {	
												}
											}
										}
									} else {
										// skip
									}
								} else {
									// skip
								}
							} else {
								// Wi-Fi 네트워크 연결 됨 skip
							}
						} else {
							// 연결 안되어 있으면 error
						}
					} else {
						range = [model rangeOfString:@"ipod"];
						if (range.location != NSNotFound) {
							// ipod
							// 3G 서비스는 하지 않음
						} else {
							// ipad
						}
					}
				} else {
					// error
				}
				break;
			}

			case ReachableViaWiFi:	// WiFi
			{
				NSLog(@"[NET] Reachable Wi-fFi ========== >>");
				if (connectionType == -1) return;	// offline 모드로 들어왔을때는 세션을 다시 접속해야 함.
				
				if (connectionType == 0) {		// 이전 상태 오프였을 경우는 다시 접속 처리
					exceptionDisconnect = YES;
					if (clientAsyncSocket) {
						if([clientAsyncSocket isConnected]) {
							[clientAsyncSocket disconnect];
							isConnected = NO;
						}
					}
				} else if (connectionType == 2) {	// 이전 상태가 3G 상태 였으면 skip
					NSLog(@"Reachable 3G ===> WiFi");
					self.connectionType = 1;
					return;
				} else {
					// 이전 상태가 Wi-Fi 상태 였으면 skip
					return;
				}
				
				self.connectionType = 1;	// -1:offline mode 0:disconnect 1:Wi-Fi 2:3G
				
				//mezzo	statusString= @"Reachable WiFi";
				
				NSLog(@"Reachable WiFi");
				
				NSString *model = [[UIDevice currentDevice] model];
				if (model && [model length] > 0) {
					model = [model lowercaseString];
					NSRange range = [model rangeOfString:@"iphone"];
					if (range.location != NSNotFound) {
						// iphone
						if ([self connectedToNetwork]) {
							// 네트워크 연결 됨
							if ([self isCellNetwork]) {
								// 3G 네트워크 연결 됨 skip
							} else {
								// Wi-Fi 네트워크 연결 됨
								if (exceptionDisconnect && !isConnected) {
									NSString *improxyAddr = [myInfoDictionary objectForKey:@"proxyhost"];
									NSString *improxyPort = [myInfoDictionary objectForKey:@"proxyport"];
									if (improxyAddr && [improxyAddr length] > 0 && improxyPort && [improxyPort length] > 0) {
										NSLog(@"Reachable WiFi iphone 재접속 시작");
										if([self connect:improxyAddr PORT:[improxyPort intValue]]) {
											// success!
										} else {
											// TODO: 예외처리 필요 (세션연결 실패)
											if([self connect:improxyAddr PORT:[improxyPort intValue]]) {
											} else {
												// TODO: 예외처리 필요 (세션연결 실패)
												if([self connect:improxyAddr PORT:[improxyPort intValue]]) {
												} else {	
												}
											}
										}
									} else {
										// skip
									}
								} else {
									// skip
								}
							}
						} else {
							// 연결 안되어 있으면 error
						}
					} else {
						range = [model rangeOfString:@"ipod"];
						if (range.location != NSNotFound) {
							// ipod
							if ([self connectedToNetwork]) {
								// 네트워크 연결 됨
								if ([self isCellNetwork]) {
									// 3G 네트워크 연결 됨 skip
								} else {
									// Wi-Fi 네트워크 연결 됨
									if (exceptionDisconnect && !isConnected) {
										NSString *improxyAddr = [myInfoDictionary objectForKey:@"proxyhost"];
										NSString *improxyPort = [myInfoDictionary objectForKey:@"proxyport"];
										if (improxyAddr && [improxyAddr length] > 0 && improxyPort && [improxyPort length] > 0) {
											NSLog(@"Reachable WiFi ipod 재접속 시작");
											if([self connect:improxyAddr PORT:[improxyPort intValue]]) {
												// success!
											} else {
												// TODO: 예외처리 필요 (세션연결 실패)
												if([self connect:improxyAddr PORT:[improxyPort intValue]]) {
												} else {
													// TODO: 예외처리 필요 (세션연결 실패)
													if([self connect:improxyAddr PORT:[improxyPort intValue]]) {
													} else {	
													}
												}
											}
										} else {
											// skip
										}
									} else {
										// skip
									}
								}
							} else {
								// 연결 안되어 있으면 error
							}
						} else {
							// ipad
						}
					}
				} else {
					// error
				}
				break;
			}
		}
    }
	/*
	else {
		connectionType = 0;
		NSLog(@"에어 플레인 모드");
		NetworkStatus netStatus = [curReach currentReachabilityStatus];
		NSLog(@"netStatus = %d", netStatus);
		
		if(curReach == internetReach)
		{
			NSLog(@"fdsaf");
		}
		if(curReach == wifiReach)
		{
			NSLog(@"wifi reach");
		}
	}
*/
	//	if(curReach == internetReach)
	//	{	
	////		[self configureTextField: internetConnectionStatusField imageView: internetConnectionIcon reachability: curReach];
	//		NetworkStatus netStatus = [curReach currentReachabilityStatus];
	//		BOOL connectionRequired= [curReach connectionRequired];
	//		NSString* statusString= @"";
	//		switch (netStatus)
	//		{
	//			case NotReachable:
	//			{
	//				statusString = @"Access Not Available";
	//				//Minor interface detail- connectionRequired may return yes, even when the host is unreachable.  We cover that up here...
	//				connectionRequired= NO;  
	//				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"internetReach" message:statusString delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
	//				[alertView show];
	//				[alertView release];
	//				break;
	//			}
	//			case ReachableViaWWAN:
	//			{
	//				statusString = @"Reachable WWAN";
	//				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"internetReach" message:statusString delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
	//				[alertView show];
	//				[alertView release];
	//				break;
	//			}
	//			case ReachableViaWiFi:
	//			{
	//				statusString= @"Reachable WiFi";
	//				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"internetReach" message:statusString delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
	//				[alertView show];
	//				[alertView release];
	//				break;
	//			}
	//		}
	//	}
	//	if(curReach == wifiReach)
	//	{	
	////		[self configureTextField: localWiFiConnectionStatusField imageView: localWiFiConnectionIcon reachability: curReach];
	//		NetworkStatus netStatus = [curReach currentReachabilityStatus];
	//		BOOL connectionRequired= [curReach connectionRequired];
	//		NSString* statusString= @"";
	//		switch (netStatus)
	//		{
	//			case NotReachable:
	//			{
	//				statusString = @"Access Not Available";
	//				//Minor interface detail- connectionRequired may return yes, even when the host is unreachable.  We cover that up here...
	//				connectionRequired= NO;
	//				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"wifiReach" message:statusString delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
	//				[alertView show];
	//				[alertView release];
	//				break;
	//			}
	//			case ReachableViaWWAN:
	//			{
	//				statusString = @"Reachable WWAN";
	//				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"wifiReach" message:statusString delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
	//				[alertView show];
	//				[alertView release];
	//				break;
	//			}
	//			case ReachableViaWiFi:
	//			{
	//				statusString= @"Reachable WiFi";
	//				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"wifiReach" message:statusString delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
	//				[alertView show];
	//				[alertView release];
	//				break;
	//			}
	//		}
	//	}
}

#pragma mark -
#pragma mark Finalize

// event 발생으로 App종료 시 (App 상태 저장 필요)
- (void)applicationWillTerminate:(UIApplication *)application
{
	// TODO: db가 존재 하면 처리
	// 보낸 메시지중 아직 응답이 안왔을 경우 모두 실패로 처리
	if([MessageInfo database] != nil) { 
		NSArray *checkDBMessageInfo = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where ISSUCCESS=?", @"0", nil];
		if (checkDBMessageInfo && [checkDBMessageInfo count] > 0) {
			//		NSLog(@"issuccess update");
			[MessageInfo findWithSqlWithParameters:@"update _TMessageInfo set ISSUCCESS=? where ISSUCCESS=?",@"-1", @"0", nil];
		} else {
			//		NSLog(@"issuccess not update");
		}
	}
	
	//db오픈 되어 있으면, 종료할때 모든 유저의 imstatus상태를 0으로 초기화 시켜 둔다.
	if([UserInfo database] != nil){
		//		NSLog(@"====> imstatus initialize <==");
		NSString* sql = [NSString stringWithFormat:@"UPDATE %@ SET IMSTATUS=?",[UserInfo tableName]];
		[UserInfo findWithSqlWithParameters:sql, @"0", nil];
	}
	inEnterBackGround = NO;
	
	//	NSLog(@"Delegate applicationWillTerminate");
	[[NSNotificationCenter defaultCenter] postNotificationName:@"applicationWillTerminate" object:nil];
}

- (void)dealloc 
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"requestHttp" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"requestUploadUrlMultipartForm" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"retrieveSystemMessage" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"getChatParticipants" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"getChatParticipantsNotiChatEnter" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"retrieveSessionMessage" object:nil];	// 대화 메시지 가져오기
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"createNewMessage" object:nil];			// 새로운 메시지 생성
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"albumUpload" object:nil];				// 사진 업로드 1단계	- sochae 2010.09.29 : 추가한 곳이 없는데 ???
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"albumUploadComplete" object:nil];		// 사진 업로드 2단계
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"getReadMark" object:nil];				// 메시지의 읽은 카운트수 가져오기
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"getRecommendFriendsList" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateStatus" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateNickName" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"setMessagePreviewOnMobile" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"deleteMyMessage" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"setFriendFromRecommand" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"BlockUserCancel" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"joinToChatSession" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"insertProfilePhoto" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"insertContactPhoto" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
	
	// mezzo
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"joinToChatSession" object:nil];
	
	[self disposeSystemSoundID];
	
	if (requestTimeOutTimer) {
		[requestTimeOutTimer invalidate];
		[requestTimeOutTimer release];
		requestTimeOutTimer = nil;
	}

	// sochae 2010.09.27 - network release
	if (hostReach != nil)
	   [hostReach release];
    if (internetReach != nil)
	   [internetReach release];
	if (wifiReach != nil)
	   [wifiReach release];
	// ~sochae

	[httpAgentArray release];
	[msgListArray release];
	[msgArray release];
	[proposeUserArray release];
	
	[tempMsgListDic release];
	
	if (protocolUrlDictionary != nil) {
		[protocolUrlDictionary release];
	}
	if (imStatusDictionary != nil) {
		[imStatusDictionary release];
	}
	
	if(myInfoDictionary != nil) {
		[myInfoDictionary release];
	}
	if(startViewController != nil)
		[startViewController release];
	if(loadViewController != nil)
		[loadViewController release];
	if (useGuidController != nil) {
		[useGuidController release];
	}
	if(authNaviController != nil)
		[authNaviController release];
	if(rootController != nil)
		[rootController release];
	
	if(database != nil){
		[database release];
	}
	
	if(registSynctime != nil){
		[registSynctime release];
	}
    [window release];
    [super dealloc];
}

@end


