//
//  USayAppAppDelegate.h
//  USayApp
//
//  Created by Jong-Sung Park on 10. 5. 17..
//  Copyright inamass 2010. All rights reserved.
//
//
#ifndef USAYAPPAPPDELEGATE
#define USAYAPPAPPDELEGATE

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>


@class CertificationViewController;
@class LoadingViewController;
@class StartViewController;
@class AsyncSocket;
@class HttpAgent;
@class SQLiteDataAccess;
@class MsgUserData;
@class CellMsgListData;
@class UseGuideViewController;
@class Reachability;
@class RotatingTabBarController;
@class SignAgreeViewController;


@interface USayAppAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow					*window;
	RotatingTabBarController	*rootController;
	UINavigationController		*authNaviController;
//	CertificationViewController *authViewController;
	LoadingViewController		*loadViewController;
	StartViewController			*startViewController;
	UseGuideViewController		*useGuidController;
	
	AsyncSocket					*clientAsyncSocket;
	NSMutableArray				*httpAgentArray;
	
	NSMutableArray				*msgListArray;			// 메시지 리스트
	NSMutableArray				*msgArray;				// 대화 히스토리 정보
	
	NSMutableArray				*proposeUserArray;		// 추천친구 리스트
	
	NSMutableDictionary			*tempMsgListDic;		// 신규메시지가 왔을때 패킷을 두번 보내 정보을 통합하는 이유로 임시로 dic 구성
														// 최종적으로 패킷이 왔을때는 msgListArray에 넣어서 관리
														// retrieveSystemMessage(11.9), getChatParticipants(11.1) 를 보내서 통합 처리
	
	NSMutableDictionary			*myInfoDictionary;		// name, nickname, status, exip, inip, devicetoken, userno, email, passwd, ssk, pkey, ucmc, uccs, mc, cs, imstatus
														// openChatSession, proxyhost, proxyport, mobilePhoneNumber, homePhoneNumber, orgPhoneNumber
	NSMutableDictionary			*protocolUrlDictionary;

	NSMutableDictionary			*imStatusDictionary;	// 상태 정보. key : fPkey   value : 상태 정보		0:offline  1:online  2:busy (바빠요)  8:곧 돌아옵니다.  16:다른용무중
	
	BOOL						isConnected;
	BOOL						isFirstUser;			// 프로그램 새로 설치후 진행?
	BOOL						isLogin;				// 로그인 상태 여부 - sochae 2010.09.30
	
	//데이터 베이스를 한번 오픈하고 나면 계속 사용할수 있게 핸들값을 appDelegate에서 관리한다.
	SQLiteDataAccess			*database;
	
	SystemSoundID				systemSoundID;
	
	Reachability				*hostReach;
    Reachability				*internetReach;
    Reachability				*wifiReach;
	
	NSInteger					connectionType;		// -1:offline mode 0:disconnect 1:Wi-Fi 2:3G
	BOOL						exceptionDisconnect;
	
	NSInteger					apnsNotiCount;
	NSInteger					reConnectCount;
	
	NSTimer						*requestTimeOutTimer;		// initOnMobile, loginOnMobile
	NSString					*registSynctime;			//registOnMobile 에서 받아온 lastsynctime 메모리 저장
	
	BOOL						inEnterBackGround;
	BOOL						isLoginfail;
	
	SignAgreeViewController *SignAgreeView;
	UINavigationController *SignNaviController;
}

//+(NSString *) localCellularIPAddress;
//+(NSString *) localWiFiIPAddress;
//+(NSString *) localAddressForInterface:(NSString *)interface;

-(void) goLoading;
-(void) goRegistration;			// 가입
-(void) goMain:(id)controller;
-(void) goUseGuide;

-(NSString*)getSvcIdx;

// 네트워크 연결 상태 확인
-(BOOL) connectedToNetwork;
// 3G 망? Wifi 망?
-(BOOL) isCellNetwork;
-(NSString*) localIPAddress;
// 사이트 도메인으로 ip 주소 조회
-(NSString*)getIPAddressFromHost:(NSString*)theHost;
// 특정 사이트에 도달 할 수 있는지 조회
-(BOOL)hostAvailable:(NSString*)theHost;
// Direct from Apple
-(BOOL)addressFromString:(NSString*)IPAddress address:(struct sockaddr_in *)address;

#pragma mark -
#pragma mark 추천친구 리스트 요청
-(void) requestProposeUserList;

#pragma mark -
#pragma mark Host Connect
-(BOOL) connect:(NSString*)host PORT:(NSInteger)port;
-(BOOL) setupReachability:(NSString*)host;		// sochae 2010.09.27

#pragma mark -
#pragma mark 전용패킷 전송
-(BOOL) sendLogin;
-(BOOL) updatePresence:(NSString*)imstatus;		// 본인의 상태 정보 변경  0:offline  1:online  2:busy (바빠요)  8:곧 돌아옵니다.  16:다른용무중
-(BOOL) getOnBuddyStatus;
-(void)requestGetChangedProfileInfo;			//시작 들어왔을때 친구의 마지막 변경 정보 받아 오기.
#pragma mark -
#pragma mark pKey값으로 대화방 사진, nickName DB에서 읽어오기
-(MsgUserData*)getNickNameRepresentPhoto:(NSString*)pKey;

#pragma mark -
#pragma mark pKey값으로 상태 정보 읽어오기
-(NSString*)getImStatus:(NSString*)fPKey;	// 리턴값  0:offline  1:online  2:busy (바빠요)  8:곧 돌아옵니다.  16:다른용무중

#pragma mark -
#pragma mark 새로운 글 카운트 (DB에서 얻어옴)
-(NSInteger)newMessageCount;
#pragma mark -
#pragma mark 대화방 리스트 관리 (msgListArray)
-(BOOL) IsChatSession:(NSString*)chatsession;
-(BOOL) AddNewMessageCount:(NSString*)chatsession;
-(MsgUserData*) MsgListUserInfo:(NSString*)chatsession pkey:(NSString*)pkey;	// 채팅 방 안의 userInfo
-(CellMsgListData*) MsgListDataFromChatSession:(NSString*)chatsession;	// 채팅 리스트에 있는 cell 정보
-(NSString*)chatSessionFrompKey:(NSArray*)pkeyArray;
-(NSInteger)chatSessionPeopleCount:(NSString*)chatsession;	// 채팅방에 있는 친구 수. (본인제외)
// 대화 리스트에 들어가는 값.
// ex) AM 12:6, PM 3:24, 2010-07-09
-(NSString*)generateMsgListDateFromUnixTimeStamp:(NSNumber*)unixtimestamp;
-(NSString*)generateMsgListDateFromUnixTimeStampFromString:(NSString*)unixtimestamp;
// 대화시 풍선 팁 안에 들어가는 값.
// ex) AM 12:6, PM 3:24
-(NSString*)generateMsgDateFromUnixTimeStamp:(NSNumber*)unixtimestamp;
-(NSString*)generateMsgDateFromUnixTimeStampFromString:(NSString*)unixtimestamp;
-(NSString*)compareLastMsgDate:(NSNumber*)beforeMsgUnixTimeStamp afterMsgUnixTimeStamp:(NSNumber*)afterMsgUnixTimeStamp;
// 자신이 대화를 보내기 전에 마지막 대화 날짜와 현재 대화 날짜와 비교해서 추가
// 대화방에서 사용하는 현재 날짜/요일
// ex) "2010년 7월 8일 목요일"
-(NSString*)currentDateUseMsg;	

// retrieveSessionMessage 패킷이 왔을때 패킷 정보를 보고 이전 데이터와 날짜가 변경되면 DB, 메모리에 추가
// 대화방에서 사용하는 현재 날짜/요일
// ex) "2010년 7월 8일 목요일"
-(NSString*)dateUseMsgFromUnixTimeStamp:(NSString*)unixtimestamp;
#pragma mark -
#pragma mark 대화방 관리 (msgArray)

#pragma mark -
#pragma mark UserInfo
-(NSMutableDictionary*) myInfoDictionary;
#pragma mark -

#pragma mark Property
-(void) Initialize;			// 초기화	 (array, dictionary 초기화/object 생성, 기타)
-(void) dbInitialize;		// db 초기화	(db에서 메시지 리스트 load, 기타)
-(NSString *)deviceIPAdress;
-(NSString *)protocolUrl:(NSString*)key;
-(void) createSystemSoundID;
-(void) playSystemSoundIDSound;
-(void) disposeSystemSoundID;
-(void) playSystemSoundIDVibrate;
-(NSString *)generateUUIDString;
-(UIColor *)getColor:(NSString*)hexColorStr;

- (void) sendDeviceToken;					// usay server로 device token을 보낸다. - sochae 2010.09.29

#pragma mark -
//
@property (nonatomic, retain) IBOutlet	UIWindow				*window;
@property (nonatomic, retain) IBOutlet	UITabBarController		*rootController;
//@property (nonatomic, retain) IBOutlet	CertificationViewController *authNaviController;
@property (nonatomic, retain) IBOutlet	LoadingViewController	*loadViewController;
@property (nonatomic, retain) IBOutlet	StartViewController		*startViewController;
@property (nonatomic, retain) IBOutlet  UINavigationController	*authNaviController;
@property (nonatomic, retain) UseGuideViewController			*useGuidController;
@property (nonatomic, assign) BOOL								isFirstUser;
@property (nonatomic, retain) NSMutableArray					*httpAgentArray;
@property (nonatomic, retain) NSMutableArray					*msgListArray;
@property (nonatomic, retain) NSMutableArray					*msgArray;
@property (nonatomic, retain) NSMutableArray					*proposeUserArray;

@property (nonatomic, retain) NSMutableDictionary				*myInfoDictionary;
@property (nonatomic, retain) NSMutableDictionary				*protocolUrlDictionary;
@property (nonatomic, retain) NSMutableDictionary				*tempMsgListDic;
@property (nonatomic, retain) NSMutableDictionary				*imStatusDictionary;
@property (nonatomic, retain) NSString							*registSynctime;

@property (nonatomic, assign) BOOL								inEnterBackGround;
//데이터 베이스 핸들 retain
@property (nonatomic, retain) SQLiteDataAccess					*database;

@property (readwrite) NSInteger	connectionType;
@property (readwrite) BOOL	exceptionDisconnect;
@property (readwrite) NSInteger	apnsNotiCount;
@property (readwrite) NSInteger	reConnectCount;

@property (readwrite) BOOL	isLoginfail;
@property (readwrite) BOOL	isLogin;		// sochae 2010.09.30

@end
#endif // USAYAPPAPPDELEGATE
