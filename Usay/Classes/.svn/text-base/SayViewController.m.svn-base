//
//  SayViewController.m
//  USayApp
//
//  Created by 1team on 10. 6. 14..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "SayViewController.h"
#import "USayAppAppDelegate.h"
#import "BalloomTableCell.h"
#import "HttpAgent.h"
#import "json.h"
#import "USayHttpData.h"
#import "InviteMsgViewController.h"
#import "CellMsgListData.h"
#import "CellMsgData.h"
#import "MessageInfo.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"
#import "SayInputTextView.h"
#import	"RoomInfo.h"
#import "UserInfo.h"
#import "ShowMediaViewController.h"
//#import "MyDeviceClass.h"			// sochae 2010.09.10 - UI Position
#import "USayDefine.h"				// sochae 2010.09.09 - added
#import "unistd.h" 
#import "openImgViewController.h"
#import <CommonCrypto/CommonDigest.h>

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216.0;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162.0;

//#define INPUTVIEW_CY		20
// sochae 2010.09.10
#define INPUTVIEW_CY		39
// ~sochae
#define INPUTTEXTVIEW_Y		5	// sochae 2010.09.30
#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define ID_ATTACH_ACTIONSHEET	6011
#define ID_RESEND_ACTIONSHEET	6012
#define ID_INPUTTEXTVIEW		6013

#define	kMaxResolution			800

//사진 동영상 주소 정의

@implementation SayViewController

@synthesize sayTableView, inputView, inputTextView, addBtn, sendBtn, keyboardHeight, buddyArray, sessionKey, alreadySession, photoLibraryShown;
@synthesize	animateHeightChange;
@synthesize maxNumberOfLines;
@synthesize minNumberOfLines;
@synthesize reSendCellRow;
@synthesize viewDidLoadSuccess, menu, sayMsgArr;



extern BOOL LOGINSUCESS;
static inline double radians(double degrees) {
    return degrees * M_PI / 180;
}


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

-(void)showImage:(NSString*)cellImage cell:(BalloomTableCell*)nowcell
{
	
	NSLog(@"nowcell = %@", nowcell);
	
	
	NSLog(@"cellImg = %@", cellImage);
	if(cellImage == NULL)
		return;
	NSLog(@"md5 = %@", [self md5:cellImage]);
	if(self.view.frame.size.width == 480)
	{
		return;
	//	imageView.frame=CGRectMake(0, 0, 480, 300);
		
	}
	else {
		UIImageView *imageView = [[UIImageView alloc] init];

		imageView.frame=CGRectMake(0, 0, 320, 460);

	
		openImgViewController *tmpImgView  =[[openImgViewController alloc] init] ; //2010.12.16 release

	
	[self.navigationController.navigationBar setHidden:YES];
	
	
	
	
	/*
	NSArray *tmpArray =[cellImage componentsSeparatedByString:@"/"];
	
	if(tmpArray)
	{
		for (int i=0; i<[tmpArray count]; i++) {
			
			NSLog(@"%@", [tmpArray objectAtIndex:i]);
		}
	}
	*/
	
	
	NSString *newImgPath = [NSString stringWithFormat:@"%@", [self md5:cellImage]];
	
	NSLog(@"newImgPath = %@",  newImgPath);
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	//NSLog(@"paths = %@", paths);
	NSString *cachesDirectory =  [NSString stringWithFormat:@"%@/ImageCache",[paths objectAtIndex:0]];
	//NSLog(@"cacshess Dic = %@", cachesDirectory);
	
	NSString *imagePath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", newImgPath]];

//	NSString *imagePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", cellImage]];

	NSLog(@"imagePath = %@", imagePath);
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath isDirectory:NO]) {
		[imageView setImageWithURL:[NSURL URLWithString:cellImage]
		 placeholderImage:nowcell.imageView.image];		
		 // placeholderImage:[UIImage imageNamed:@"img_default.png"]];

		// not exist file
		NSLog(@"imagePath not exist file");
		
	}
	else {
		NSData *data =[[NSData alloc] initWithContentsOfFile:imagePath];
	
		[imageView setImage:[UIImage imageWithData:data]];
		NSLog(@"img ok");
		[data release]; //2010.12.17 release
	}

	
	
	
	
		
	
	[tmpImgView.view addSubview:imageView];
	
	
	
	
	//[self presentModalViewController:tmpImgView animated:NO];
	[self.navigationController pushViewController:tmpImgView animated:NO];
	
	//release 2010.12.28 위에서 오토 릴리즈 함 그래서 주석 처리..
	[tmpImgView release];
	[imageView release];
	}
	

}


-(id)initWithNibNameBuddyListMsgType:(NSString*)nibName chatSession:(NSString*)chatsession type:(NSString*)msgCType BuddyList:(NSArray*)buddyList bundle:(NSBundle *)nibBundle
{
	self = [super initWithNibName:nibName bundle:nibBundle];
	
	
	NSLog(@"처음 데이터1 %@", buddyList);
	NSLog(@"세션 %@", chatsession);
	if(self != nil) {
		if (chatsession && [chatsession length] > 0) {
			// 기존 대화
			NSLog(@"기존 체탱방..");
			self.alreadySession = YES;
			if (chatsession && [chatsession length] > 0) {
				sessionKey = nil;
				sessionKey = [[NSMutableString alloc] initWithString:chatsession];
				self.buddyArray = buddyList;
			} else {
				sessionKey = nil;
			}
			
		//	buddyArray = nil; //이거 왜 닐을 해줌?????
			[[self appDelegate].myInfoDictionary setObject:chatsession forKey:@"openChatSession"];
		} else {
			// 신규 대화. buddyList를 가지고 joinToChatSession 요청
			self.alreadySession = NO;	// 신규 대화방이니 joinToChatSession 요청해라~
			self.buddyArray = buddyList;
			[[self appDelegate].myInfoDictionary setObject:@"" forKey:@"openChatSession"];
			sessionKey = nil;
		}
		viewDidLoadSuccess = NO;
		
		sayTableView = nil;
		inputView = nil;
		inputTextView = nil;
		addBtn = nil;
		sendBtn = nil;
	}
	
	return self;
}



#pragma mark -

-(void) scrollsToBottom:(NSTimer *)theTimer {
	[theTimer invalidate];
	startTimer = nil;
//	if ([[self appDelegate].msgArray count] > 0) {
	if ([sayMsgArr count] > 0) {
//		int reloadToRow = [[self appDelegate].msgArray count] - 1;
		int reloadToRow = [sayMsgArr count] - 1;
		if (reloadToRow > 0) {
			// create C array of values for NSIndexPath
			NSUInteger indexArr[] = {0,reloadToRow}; 
			//move table to new entry
			[sayTableView scrollToRowAtIndexPath:[NSIndexPath indexPathWithIndexes:indexArr length:2] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
			//options for scroll position are UITableViewScrollPositionTop, UITableViewScrollPositionMiddle, UITableViewScrollPositionBottom
		}
	}
}

-(void) scrollsToMiddle:(NSTimer *)theTimer {
	[theTimer invalidate];
	startTimer = nil;
 
	if ([sayMsgArr count] > 0) {
        // create C array of values for NSIndexPath
        NSUInteger indexArr[] = {0,nScrollPos}; 
        //move table to new entry
        [sayTableView scrollToRowAtIndexPath:[NSIndexPath indexPathWithIndexes:indexArr length:2] atScrollPosition:UITableViewScrollPositionTop animated:NO];
 	}
    
    bFirstLoadTable = NO;
}

-(void) keyboardUpTimerFunction:(NSTimer *)theTimer {
	[theTimer invalidate];
	keyboardUpTimer = nil;
	[inputTextView becomeFirstResponder];
}


- (void)drawRect:(CGRect)rect
{
	//	NSLog(@"(void)drawRect:(CGRect)rect");
}

// 대화 화면 > 버튼 선택 시
- (IBAction) clicked:(id)sender
{
	if ([self appDelegate].connectionType == -1) {	// -1:offline mode  0:disconnect 1:Wi-Fi 2:3G
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"오프라인" message:@"현재 네트워크 연결이 불가능한 상태입니다.\nUsay의 모든 기능을 이용하기 위해서는 네트워크 연결이 필요합니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return;
	} else if ([self appDelegate].connectionType == 0) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"3G 또는 Wi-Fi 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0028)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return;
	}
	else if(LOGINSUCESS != YES)
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"로그인 전에는 대화를 보낼 수 없습니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return;
		
	}
	
	if(sender == addBtn) {
		[inputTextView resignFirstResponder];
		
		if (menu != nil) {
			menu = nil;
		}
		// 110124 member 처리, autorelease
		//		UIActionSheet *menu = nil;
		if (menu != nil) {
			[menu release];
			menu = nil;
		}
		
		if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
			// 카메라 사용 못함.
			menu = [[UIActionSheet alloc] initWithTitle:nil 
											   delegate:self
									  cancelButtonTitle:@"취소"
								 destructiveButtonTitle:nil
									  otherButtonTitles:@"앨범에서 사진/동영상 선택", nil];
		} else {
			menu = [[UIActionSheet alloc] initWithTitle:nil 
											   delegate:self
									  cancelButtonTitle:@"취소"
								 destructiveButtonTitle:nil
									  otherButtonTitles:@"사진/동영상 촬영", @"앨범에서 사진/동영상 선택", nil];
		}
		menu.tag = ID_ATTACH_ACTIONSHEET;
		[menu showInView:self.view];
		//release 하면 앱 종료된다..
		
		
	}
	else if (sender == sendBtn)	// 대화 [보내기] 버튼
	{
		
		NSNumber *currentTimeNumber = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]*1000];	// 13자리로 변경
		NSString *message = [inputTextView text];
		
		DebugLog(@"=====> createNewMessage message : %@", message);
		
		if ( !message || (message && [message length] <= 0) ) {
			return;
		}
		// sochae 2010.10.12
		//NSString *nickName = [[NSUserDefaults standardUserDefaults] objectForKey:@"nickName"];
		NSString *nickName = (NSString *)[JYUtil loadFromUserDefaults:kNickname];
		// ~sochae
		NSInteger userCount = [[self appDelegate] chatSessionPeopleCount:sessionKey];
		NSString *uuid = [[self appDelegate] generateUUIDString];
		
		////////////////////////////////////////////////////////////////////////////////////////
		// 날짜 비교후 날짜 정보 저장
		NSArray *lastRegDateArray = nil;
		
		if(sessionKey && [sessionKey length] > 0) {
			lastRegDateArray = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where ISSUCCESS=? and CHATSESSION=? order by REGDATE desc limit 1", @"1", sessionKey, nil];
		} else {
		}
		
		//마지막으로 보낸 날짜
		NSNumber *lastRegDateNumber = nil;
		if (lastRegDateArray && [lastRegDateArray count] > 0) {
			for (MessageInfo *messageInfo in lastRegDateArray) {
				lastRegDateNumber = messageInfo.REGDATE;
			}
		} else {
			
		}
		
		NSString *noticeDateMsg = [[self appDelegate] compareLastMsgDate:lastRegDateNumber afterMsgUnixTimeStamp:currentTimeNumber];
		if (noticeDateMsg) {
			// 메시지 DB, 메모리에 추가
			
			
			NSDate *currentDate = [NSDate date];
			NSCalendar *calendar = [NSCalendar currentCalendar];
			NSDateComponents *currentComp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSWeekdayCalendarUnit fromDate:currentDate];
			NSInteger currentYear = [currentComp year];
			NSInteger currentMonth = [currentComp month];
			NSInteger currentDay = [currentComp day];
			NSDate *date;
			NSDateComponents *com;
			com = [[NSDateComponents alloc] init];
			[com setYear:currentYear];
			[com setMonth:currentMonth];
			[com setDay:currentDay];
			[com setHour:00];
			[com setMinute:00];
			[com setSecond:00];
			date = [[NSCalendar currentCalendar] dateFromComponents:com];
			[com release];	// sochae 2011.03.06 - 정적 분석 오류 
			
			//자정시간으로 바꾼다..
			NSNumber *currentTimeNumber2 = [NSNumber numberWithLongLong:[date timeIntervalSince1970]*1000];
			
			
			//날짜 혹시 같은게 있으면 굳이 넣어주지 말자
			
			NSString *findDate = [NSString stringWithFormat:@"select MSG from _TMessageInfo where MSG = '%@' and CHATSESSION ='%@'", noticeDateMsg, self.sessionKey];
			NSArray *tmpArray = [MessageInfo findWithSql:findDate];
			if([tmpArray count] > 0)
			{
				NSLog(@"같은 세션에 같은 날짜가 발견됨 넣어줄 필요가 없다 그럼");
			}
			else {
				
				[MessageInfo findWithSqlWithParameters:
				 @"insert into _TMessageInfo(CHATSESSION, MESSAGEKEY, MSG, MSGTYPE, REGDATE, PKEY, NICKNAME, PHOTOURL, ISSENDMSG, ISSUCCESS, READMARKCOUNT) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", 
				 self.sessionKey, [[self appDelegate] generateUUIDString], noticeDateMsg, @"D", currentTimeNumber2, @"", @"", @"", @"", @"1", [NSNumber numberWithInt:0], nil];
				
				CellMsgData *newMsgData = [[CellMsgData alloc] init];
				newMsgData.chatsession = self.sessionKey;
				newMsgData.contentsMsg = noticeDateMsg;
				newMsgData.msgType = @"D";
				newMsgData.regTime = currentTimeNumber;
				[newMsgData setIsSend:NO];
//				@synchronized([self appDelegate].msgArray) {
				@synchronized(sayMsgArr) {
					[[self appDelegate].msgArray addObject:newMsgData];
//					[sayMsgArr addObject:newMsgData];
				}
				[newMsgData release];
				
			}
			
			
			
		}
		////////////////////////////////////////////////////////////////////////////////////////
		
		// 메시지 메모리 추가
		CellMsgData *msgData = [[CellMsgData alloc] init];
		msgData.chatsession = sessionKey;
		msgData.messagekey = uuid;	// 임시 메시지 키
		msgData.contentsMsg = message;
		msgData.msgType = @"T";
		msgData.nickName = nickName;
		msgData.regTime = currentTimeNumber;
		[msgData setIsSend:YES];
		msgData.sendMsgSuccess = @"0";
		[msgData setReadMarkCount:userCount];
		[[self appDelegate].msgArray addObject:msgData];
//		[sayMsgArr addObject:msgData];
		[msgData release];
		
		// 메시지 DB 추가
		[MessageInfo findWithSqlWithParameters:@"insert into _TMessageInfo(CHATSESSION, MESSAGEKEY, MSG, MSGTYPE, REGDATE, PKEY, NICKNAME, PHOTOURL, ISSENDMSG, ISSUCCESS, PHOTOFILEPATH, MOVIEFILEPATH, READMARKCOUNT) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", 
		 self.sessionKey, uuid, message, @"T", currentTimeNumber, @"", nickName, @"", @"1", @"0", @"", @"", [NSNumber numberWithInt:userCount], nil];
		
		
		//화면 갱신
		[self.sayTableView reloadData];
		
		
		
		
		NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
		[bodyObject setObject:sessionKey forKey:@"sk"];
		[bodyObject setObject:[[self appDelegate] getSvcIdx] forKey:@"o"];
		[bodyObject setObject:@"T" forKey:@"mt"];
		[bodyObject setObject:message forKey:@"m"];
		[bodyObject setObject:uuid forKey:@"u"];
		
		
		
		//리드마크 요청 부분.
		NSArray *sendMsgArray = nil;
		//서버 부하 때문에 최대 5개로 제한..
		if (sessionKey && [sessionKey length] > 0) {
			sendMsgArray = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where CHATSESSION=? and ISSENDMSG=? and ISSUCCESS=? and READMARKCOUNT > ? order by REGDATE desc limit 5",self.sessionKey, @"1", @"1", [NSNumber numberWithInt:0], nil]; 
			NSLog(@"session %@", sessionKey);
		}
		
		
		NSString *messageKeys = nil;
		if (sendMsgArray && [sendMsgArray count] > 0) {
			for (MessageInfo *messageInfo in sendMsgArray) {
				if (messageKeys == nil) {
					messageKeys = messageInfo.MESSAGEKEY;
				} else {
					messageKeys = [messageKeys stringByAppendingString:@"|"];
					messageKeys = [messageKeys stringByAppendingString:messageInfo.MESSAGEKEY];
				}
			}
			[bodyObject setObject:messageKeys forKey:@"mklp"];
			
			NSLog(@"messagekey = %@ ", messageKeys);
		}
		
		
#ifdef DEVEL_MODE	// sochae 2011.02.25 - 이거 개발로 안묶어주면 appStore 등록 버전 노티 잘못 나감. 
		[bodyObject setObject:@"1" forKey:@"t"];
#endif		
		NSLog(@"body = %@", bodyObject);
		
		
		
		// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
		USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"tm" andWithDictionary:bodyObject timeout:10] autorelease];
		data.messageKey = uuid;
		data.sessionKey = sessionKey;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
		
		/*
		 NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
		 [bodyObject setObject:sessionKey forKey:@"sessionKey"];
		 [bodyObject setObject:[[self appDelegate] getSvcIdx] forKey:@"svcidx"];
		 [bodyObject setObject:@"T" forKey:@"mType"];
		 [bodyObject setObject:[inputTextView text] forKey:@"message"];
		 [bodyObject setObject:uuid forKey:@"uuid"];
		 #ifdef DEVEL_MODE   // sochae 2010.09.15 - noti certification
		 DebugLog(@"[NOTI] client test push noti cert. ~ ~ ~ ~ ~");
		 [bodyObject setObject:CERT_KIND forKey:PARAM_CERT];
		 #endif  // ~sochae
		 DebugLog(@"requestHTTP (createNewMessage) : %@", [bodyObject description]);
		 
		 // 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
		 USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"createNewMessage" andWithDictionary:bodyObject timeout:10] autorelease];
		 data.messageKey = uuid;
		 data.sessionKey = sessionKey;
		 //슬립은 왜??	sleep(0.5);
		 NSLog(@"bodyRequest %@", data.sessionKey);
		 
		 
		 
		 [[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
		 */
		
		//메세지를 지운다.
		[inputTextView setText:@""];
		
		
		//스크롤 위치 맞추는 부분
//		if ([[self appDelegate].msgArray count] > 0) {
		if ([sayMsgArr count] > 0) {
//			int reloadToRow = [[self appDelegate].msgArray count] - 1;
			int reloadToRow = [sayMsgArr count] - 1;
			if (reloadToRow > 0) {
				// create C array of values for NSIndexPath
				NSUInteger indexArr[] = {0,reloadToRow}; 
				//move table to new entry
				[sayTableView scrollToRowAtIndexPath:[NSIndexPath indexPathWithIndexes:indexArr length:2] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
				//options for scroll position are UITableViewScrollPositionTop, UITableViewScrollPositionMiddle, UITableViewScrollPositionBottom
			}
		}
	} else {
		
	}
	
}

// 친구 초대 버튼 선택 
- (void)inviteButtonClicked
{
	DebugLog(@"친구 초대");
	if ([self appDelegate].connectionType == -1) {	// -1:offline mode  0:disconnect 1:Wi-Fi 2:3G
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"오프라인" message:@"현재 네트워크 연결이 불가능한 상태입니다.\nUsay의 모든 기능을 이용하기 위해서는 네트워크 연결이 필요합니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return;
	} else if ([self appDelegate].connectionType == 0) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"3G 또는 Wi-Fi 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0029)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return;
	}
	else if (LOGINSUCESS != YES) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"로그인 실패" message:@"로그인 전에는 초대 할 수 없습니다" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return;
	}
	
	CellMsgListData *msgListData = [[self appDelegate] MsgListDataFromChatSession:sessionKey];
	if (msgListData)
	{
		NSMutableArray *buddyUserInfoArray = [[[NSMutableArray alloc] init] autorelease];	// 참여중인 대화상대 UserInfo class object
		for (id key in msgListData.userDataDic)
		{
			MsgUserData *userData = [msgListData.userDataDic objectForKey:key];
			UserInfo *userInfo = [[UserInfo alloc] init];
			userInfo.RPKEY = key;
			userInfo.REPRESENTPHOTO = userData.photoUrl;
			userInfo.FORMATTED = userData.nickName;
			DebugLog(@"userinfo imstatus = %@", userInfo.IMSTATUS);
			
			[buddyUserInfoArray addObject:userInfo];
			[userInfo release];
		}
		
		if (buddyUserInfoArray && [buddyUserInfoArray count] > 0)	// sochae 2011.02.27 - 참여자가 없으면 더이상 다른 상대를 대화 초대할 수 없다. 왜? 
		{
			InviteMsgViewController *inviteMsgViewController = [[InviteMsgViewController alloc] initWithAlreadyUserInfo:buddyUserInfoArray MsgType:msgListData.cType];
			
			DebugLog(@"Invite count = %@", inviteMsgViewController.alreadyJoinUserArray);
			
			inviteMsgViewController.hidesBottomBarWhenPushed = YES;
			inviteMsgViewController.navigationTitle = @"대화 초대";
			[self.navigationController pushViewController:inviteMsgViewController animated:NO];
			[inviteMsgViewController release];
			
			[[UIDevice currentDevice] performSelector:@selector(setOrientation:) withObject:(id)UIDeviceOrientationPortrait];
			
		}
		else {
			//참ㅇ자가 없는경우.
			InviteMsgViewController *inviteMsgViewController = [[InviteMsgViewController alloc] initWithAlreadyUserInfo:nil MsgType:@"N"];
			
			NSLog(@"Invite count = %@", inviteMsgViewController.alreadyJoinUserArray);
			
			inviteMsgViewController.hidesBottomBarWhenPushed = YES;
			inviteMsgViewController.navigationTitle = @"대화 초대";
			[self.navigationController pushViewController:inviteMsgViewController animated:NO];
			[inviteMsgViewController release];
			
			[[UIDevice currentDevice] performSelector:@selector(setOrientation:) withObject:(id)UIDeviceOrientationPortrait];
			
			
		}
		
	}
}

-(void)mediaViewAction:(id)sender
{
	[inputTextView resignFirstResponder];
	
	if ([sender isKindOfClass:[UIControl class]]) {
		UIControl *mediaView = (UIControl*)sender;
		if (mediaView) {
			NSInteger row = mediaView.tag;
//			CellMsgData *msgData = [[self appDelegate].msgArray objectAtIndex:row];
			CellMsgData *msgData = [sayMsgArr objectAtIndex:row];
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
			NSString *cachesDirectory = [paths objectAtIndex:0];
			
			if ([msgData.msgType isEqualToString:@"P"]) {			// 사진
				if (msgData.isSend == YES) {	// 발신
					NSLog(@"발신");
					id parentView = [mediaView superview];
					id parentParentView = [parentView superview];
					if ([parentParentView isKindOfClass:[BalloomTableCell class]]) {
						BalloomTableCell *cell = (BalloomTableCell*)parentParentView;
						ShowMediaViewController *showMediaViewController = [[ShowMediaViewController alloc] init];
						showMediaViewController.hidesBottomBarWhenPushed = YES;
						showMediaViewController.isPhotoView = YES;
						if (cell.contentsMediaImageView.image) {
							if (showMediaViewController.thumbnailImage) {
								[showMediaViewController.thumbnailImage release];
								showMediaViewController.thumbnailImage = nil;
								showMediaViewController.thumbnailImage = [[UIImage alloc] initWithCGImage:cell.contentsMediaImageView.image.CGImage];
							} else {
								showMediaViewController.thumbnailImage = [[UIImage alloc] initWithCGImage:cell.contentsMediaImageView.image.CGImage];
							}
						} else {
							
						}
						
						if (msgData.messagekey && [msgData.messagekey length] > 0) {
							if (showMediaViewController.messageKey) {
								[showMediaViewController.messageKey release];
								showMediaViewController.messageKey = nil;
								showMediaViewController.messageKey = [[NSMutableString alloc] initWithString:msgData.messagekey];
							} else {
								showMediaViewController.messageKey = [[NSMutableString alloc] initWithString:msgData.messagekey];
							}
						}
						if (msgData.chatsession && [msgData.chatsession length] > 0) {
							if (showMediaViewController.chatSession) {
								[showMediaViewController.chatSession release];
								showMediaViewController.chatSession = nil;
								showMediaViewController.chatSession = [[NSMutableString alloc] initWithString:msgData.chatsession];
							} else {
								showMediaViewController.chatSession = [[NSMutableString alloc] initWithString:msgData.chatsession];
							}
						}
						if (msgData.contentsMsg && [msgData.contentsMsg length] > 0) {
							showMediaViewController.originalPhotoUrl = [NSString stringWithFormat:@"%@/008", msgData.contentsMsg];
						}
						if (msgData.photoFilePath && [msgData.photoFilePath length] > 0) {
							showMediaViewController.originalPhotoPath = (NSMutableString*)[cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", msgData.photoFilePath]];
						}
						[self.navigationController pushViewController:showMediaViewController animated:YES];
						[showMediaViewController release];
					}
				} else {						// 수신
					id parentView = [mediaView superview];
					id parentParentView = [parentView superview];
					if ([parentParentView isKindOfClass:[BalloomTableCell class]]) {
						BalloomTableCell *cell = (BalloomTableCell*)parentParentView;
						ShowMediaViewController *showMediaViewController = [[ShowMediaViewController alloc] init];
						showMediaViewController.hidesBottomBarWhenPushed = YES;
						showMediaViewController.isPhotoView = YES;
						if (cell.contentsMediaImageView.image) {
							if (showMediaViewController.thumbnailImage) {
								[showMediaViewController.thumbnailImage release];
								showMediaViewController.thumbnailImage = nil;
								showMediaViewController.thumbnailImage = [[UIImage alloc] initWithCGImage:cell.contentsMediaImageView.image.CGImage];
							} else {
								showMediaViewController.thumbnailImage = [[UIImage alloc] initWithCGImage:cell.contentsMediaImageView.image.CGImage];
							}
						} else {
							
						}
						if (msgData.messagekey && [msgData.messagekey length] > 0) {
							if (showMediaViewController.messageKey) {
								[showMediaViewController.messageKey release];
								showMediaViewController.messageKey = nil;
								showMediaViewController.messageKey = [[NSMutableString alloc] initWithString:msgData.messagekey];
							} else {
								showMediaViewController.messageKey = [[NSMutableString alloc] initWithString:msgData.messagekey];
							}
						}
						if (msgData.chatsession && [msgData.chatsession length] > 0) {
							if (showMediaViewController.chatSession) {
								[showMediaViewController.chatSession release];
								showMediaViewController.chatSession = nil;
								showMediaViewController.chatSession = [[NSMutableString alloc] initWithString:msgData.chatsession];
							} else {
								showMediaViewController.chatSession = [[NSMutableString alloc] initWithString:msgData.chatsession];
							}
						}
						if (msgData.contentsMsg && [msgData.contentsMsg length] > 0) {
							showMediaViewController.originalPhotoUrl = [NSString stringWithFormat:@"%@/008", msgData.contentsMsg];
						}
						if (msgData.photoFilePath && [msgData.photoFilePath length] > 0) {
							showMediaViewController.originalPhotoPath = (NSMutableString*)[cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", msgData.photoFilePath]];
						}
						
						[self.navigationController pushViewController:showMediaViewController animated:YES];
						[showMediaViewController release];
					}
				}
			} else if ([msgData.msgType isEqualToString:@"V"]) {	// 동영상
				if (msgData.isSend == YES) {	// 발신
					NSLog(@"동영상 발신..");
					NSLog(@"msgDate1 %@", msgData.movieFilePath);
					NSLog(@"msgDate2 %@", msgData.contentsMsg);
					
					
					
					
					ShowMediaViewController *showMediaViewController = [[ShowMediaViewController alloc] init];
					showMediaViewController.hidesBottomBarWhenPushed = YES;
					showMediaViewController.isPhotoView = NO;
					if (msgData.messagekey && [msgData.messagekey length] > 0) {
						if (showMediaViewController.messageKey) {
							[showMediaViewController.messageKey release];
							showMediaViewController.messageKey = nil;
							showMediaViewController.messageKey = [[NSMutableString alloc] initWithString:msgData.messagekey];
						} else {
							showMediaViewController.messageKey = [[NSMutableString alloc] initWithString:msgData.messagekey];
						}
					}
					if (msgData.chatsession && [msgData.chatsession length] > 0) {
						if (showMediaViewController.chatSession) {
							[showMediaViewController.chatSession release];
							showMediaViewController.chatSession = nil;
							showMediaViewController.chatSession = [[NSMutableString alloc] initWithString:msgData.chatsession];
						} else {
							showMediaViewController.chatSession = [[NSMutableString alloc] initWithString:msgData.chatsession];
						}
					}
					if (msgData.contentsMsg && [msgData.contentsMsg length] > 0) {
						if (showMediaViewController.originalMovieUrl) {
							
							NSLog(@"오리지날 무브 %@", showMediaViewController.originalMovieUrl);
							
							[showMediaViewController.originalMovieUrl release];
							showMediaViewController.originalMovieUrl = nil;
							showMediaViewController.originalMovieUrl = [[NSMutableString alloc] initWithFormat:@"%@/200", msgData.contentsMsg];
						} else {
							showMediaViewController.originalMovieUrl = [[NSMutableString alloc] initWithFormat:@"%@/200", msgData.contentsMsg];
						}
					}
					
					if (msgData.movieFilePath && [msgData.movieFilePath length] > 0) {
						if (showMediaViewController.originalMoviePath) {
							[showMediaViewController.originalMoviePath release];
							showMediaViewController.originalMoviePath = nil;
							showMediaViewController.originalMoviePath = [[NSMutableString alloc] initWithString:[cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", msgData.movieFilePath]]];
						} else {
							showMediaViewController.originalMoviePath = [[NSMutableString alloc] initWithString:[cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", msgData.movieFilePath]]];
						}
					}
					else {
						//파일 정보를 모르면 로컬에 있나 찾아봐야 한다...
						
						
						NSURL *videoURL = [sourceMovie objectForKey:UIImagePickerControllerMediaURL];
						if (videoURL) {
							NSString *moviePath = [videoURL path];
							
							
							
							showMediaViewController.originalMoviePath = [[NSMutableString alloc] initWithString:moviePath];
							//	showMediaViewController.originalMoviePath=moviePath;
							
							[sourceMovie removeAllObjects];
							
						}
						
					}
					
					NSLog(@"data2 %@", showMediaViewController.originalMovieUrl);
					
					[self.navigationController pushViewController:showMediaViewController animated:YES];
					[showMediaViewController release];
				} else {						// 수신
					ShowMediaViewController *showMediaViewController = [[ShowMediaViewController alloc] init];
					showMediaViewController.hidesBottomBarWhenPushed = YES;
					showMediaViewController.isPhotoView = NO;
					if (msgData.messagekey && [msgData.messagekey length] > 0) {
						if (showMediaViewController.messageKey) {
							[showMediaViewController.messageKey release];
							showMediaViewController.messageKey = nil;
							showMediaViewController.messageKey = [[NSMutableString alloc] initWithString:msgData.messagekey];
						} else {
							showMediaViewController.messageKey = [[NSMutableString alloc] initWithString:msgData.messagekey];
						}
					}
					if (msgData.chatsession && [msgData.chatsession length] > 0) {
						if (showMediaViewController.chatSession) {
							[showMediaViewController.chatSession release];
							showMediaViewController.chatSession = nil;
							showMediaViewController.chatSession = [[NSMutableString alloc] initWithString:msgData.chatsession];
						} else {
							showMediaViewController.chatSession = [[NSMutableString alloc] initWithString:msgData.chatsession];
						}
					}
					if (msgData.contentsMsg && [msgData.contentsMsg length] > 0) {
						if (showMediaViewController.originalMovieUrl) {
							[showMediaViewController.originalMovieUrl release];
							showMediaViewController.originalMovieUrl = nil;
							showMediaViewController.originalMovieUrl = [[NSMutableString alloc] initWithFormat:@"%@/200", msgData.contentsMsg];
						} else {
							showMediaViewController.originalMovieUrl = [[NSMutableString alloc] initWithFormat:@"%@/200", msgData.contentsMsg];
						}
					}
					if (msgData.movieFilePath && [msgData.movieFilePath length] > 0) {
						if (showMediaViewController.originalMoviePath) {
							[showMediaViewController.originalMoviePath release];
							showMediaViewController.originalMoviePath = nil;
							showMediaViewController.originalMoviePath = [[NSMutableString alloc] initWithString:[cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", msgData.movieFilePath]]];
						} else {
							showMediaViewController.originalMoviePath = [[NSMutableString alloc] initWithString:[cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", msgData.movieFilePath]]];
						}
					}
					[self.navigationController pushViewController:showMediaViewController animated:YES];
					[showMediaViewController release];
				}
			} else {
				// skip
			}
		}
	}
}

-(void)reSendContentsAction:(id)sender
{	
	[inputTextView resignFirstResponder];
	
	if ([self appDelegate].connectionType == -1) {	// -1:offline mode  0:disconnect 1:Wi-Fi 2:3G
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"오프라인" message:@"현재 네트워크 연결이 불가능한 상태입니다.\nUsay의 모든 기능을 이용하기 위해서는 네트워크 연결이 필요합니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return;
	} else if ([self appDelegate].connectionType == 0) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"3G 또는 Wi-Fi 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0030)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return;
	}
	
	if ([sender isKindOfClass:[UIControl class]]) {
		UIControl *reSendImageView = (UIControl*)sender;
		if (reSendImageView) {
			reSendCellRow = reSendImageView.tag;
			if (reSendCellRow >= 0) {
				// 110124 member 처리, autorelease
				//				UIActionSheet *menu = nil;
				if (menu != nil) {
					[menu release];
					menu = nil;
				}
				
				menu = [[UIActionSheet alloc] initWithTitle:nil 
												   delegate:self
										  cancelButtonTitle:@"취소"
									 destructiveButtonTitle:nil
										  otherButtonTitles:@"재전송", @"삭제", nil];
				menu.tag = ID_RESEND_ACTIONSHEET;
				[menu showInView:self.view]; //release 하면 죽을꺼 같다.. 2011.01.11
				//	[menu release]; 릴리즈 하면 죽는다...
			}
		}
	}
}

-(void)balloomAction:(id)sender
{
	
}



- (void)viewWillAppear:(BOOL)animated
{	
	
	CGRect rect = self.view.frame;
	[[UIDevice currentDevice] performSelector:@selector(setOrientation:) withObject:(id)UIDeviceOrientationPortrait];
	
    bFirstLoadTable = NO;
    
	fullCount = [[self appDelegate].msgArray count];
	
	sayMsgArr = [[NSMutableArray alloc] init];

	
	if (fullCount > 0 && fullCount <= 15) {
		[sayMsgArr addObjectsFromArray:[self appDelegate].msgArray];
		nViewStart = 1;
		nViewEnd = fullCount;
	}
	else if(fullCount > 15) {
		for (int i=15; i > 0; i--) {
			[sayMsgArr addObject:[[self appDelegate].msgArray objectAtIndex:fullCount-i] ];
		}
		
		nViewStart = fullCount - 14;
		nViewEnd = fullCount;
	}
	
	
	UIImage* leftBarBtnImg = nil;
	UIImage* leftBarBtnSelImg = nil;
	UIImage* rightBarBtnImg = nil;
	UIImage* rightBarBtnSelImg = nil;
	
	if (rect.size.width < rect.size.height) {
		leftBarBtnImg = [UIImage imageNamed:@"btn_top_left.png"];
		leftBarBtnSelImg = [UIImage imageNamed:@"btn_top_left_focus.png"];
		rightBarBtnImg = [UIImage imageNamed:@"btn_top_group_add.png"];
		rightBarBtnSelImg = [UIImage imageNamed:@"btn_top_group_add_focus.png"];
	} else {
		leftBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_left.png"];
		leftBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_left_focus.png"];
		rightBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_group_add.png"];
		rightBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_group_add_focus.png"];
	}
	
	UIButton* leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[leftBarButton addTarget:self action:@selector(backBarButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
	[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateSelected];
	leftBarButton.frame = CGRectMake(0.0, 0.0, leftBarBtnImg.size.width, leftBarBtnImg.size.height);	
	UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
	self.navigationItem.leftBarButtonItem = leftButton;
	[leftButton release];
	
	UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[rightBarButton addTarget:self action:@selector(inviteButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
	[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
	rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
	self.navigationItem.rightBarButtonItem = rightButton;
	[rightButton release];
	
	
	if (photoLibraryShown) {
		photoLibraryShown = NO;
	}
	else
	{
		// sochae 2010.09.10 - UI Position
		//CGRect rect = [MyDeviceClass deviceOrientation];
		//CGRect rect = [[UIScreen mainScreen] applicationFrame];
		//	CGRect rect = self.view.frame;
		// ~sochae
		
		//이전 버튼으로 넘어오면 네비게이션을 잡지 못한다...
		USayAppAppDelegate *parentView = (USayAppAppDelegate*) [[UIApplication sharedApplication] delegate];
		
		//CGRect rect = self.view.frame;
		// 상태바 뺀다 3g는 20 4는 40
		CGRect rect;
		
		
		
		
		NSLog(@"부모 뷰 %f", parentView.window.frame.size.width);
		
		rect = CGRectMake(0, 0, parentView.window.frame.size.width, parentView.window.frame.size.height-self.navigationController.navigationBar.frame.size.height-20);
		/*
		 if(parentView.window.frame.size.width == 320)
		 rect = CGRectMake(0, 0, parentView.window.frame.size.width, parentView.window.frame.size.height-self.navigationController.navigationBar.frame.size.height-20);
		 else {
		 rect = CGRectMake(0, 0, parentView.window.frame.size.width, parentView.window.frame.size.height-self.navigationController.navigationBar.frame.size.height-20);
		 }
		 */
		
		
		
		
		//	NSLog(@"size width %f height %f navi %f", rect.size.width, rect.size.height, self.navigationController.navigationBar.frame.size.height);
		
		
		
		CGRect inputViewFrame = inputView.frame;
		CGRect sayTableViewFrame = sayTableView.frame;
		sayTableViewFrame.size.width = rect.size.width;
		sayTableViewFrame.size.height = rect.size.height - inputViewFrame.size.height;
		
		sayTableView.frame = sayTableViewFrame;
		
		inputViewFrame.origin.y = rect.size.height - inputViewFrame.size.height;
		
		NSLog(@"Say viewWillAppear inputViewFrame.origin.y = %i", inputViewFrame.origin.y);
		inputViewFrame.size.width = rect.size.width;
		inputView.frame = inputViewFrame;
		
		for (UIView *view in inputView.subviews) {
			if ( [view isKindOfClass:[UIImageView class]] ) {
				CGRect imageViewFrame = ((UIImageView*)view).frame;
				imageViewFrame.size.width = rect.size.width;
				((UIImageView*)view).frame = imageViewFrame;
				break;
			}
		}
		
		CGRect inputTextViewFrame = inputTextView.frame;
		inputTextViewFrame.size.width = rect.size.width-110;
		inputTextView.frame = inputTextViewFrame;
		
		CGRect sendBtnFrame = sendBtn.frame;
		sendBtnFrame.origin.x = rect.size.width-58;
		sendBtnFrame.origin.y = inputView.frame.size.height - 33;
		sendBtn.frame = sendBtnFrame;
		
		[sayTableView reloadData];
	}
}

-(void)backBarButtonClicked 
{
	
	
	
	[[UIDevice currentDevice] performSelector:@selector(setOrientation:) withObject:(id)UIDeviceOrientationPortrait];
	[self.navigationController popViewControllerAnimated:YES];
	
}

-(void)createJoinChatSession:(NSArray*)newBuddyArray
{
	
	NSLog(@"newBuddyArray = %@", newBuddyArray);
	if (newBuddyArray && [newBuddyArray count] > 0) {
		
		NSString *chatSession = [[self appDelegate] chatSessionFrompKey:newBuddyArray];
		if (chatSession && [chatSession length] > 0) {
			// 기존 대화 load
			CellMsgListData *msgListData = [[self appDelegate] MsgListDataFromChatSession:chatSession];
			if (chatSession && [chatSession length] > 0) {
				if (sessionKey) {
					[sessionKey release];
					sessionKey = nil;
					sessionKey = [[NSMutableString alloc] initWithString:chatSession];
				} else {
					sessionKey = [[NSMutableString alloc] initWithString:chatSession];
				}
			}
			
			// DB에서 메모리로 로드.
			[[self appDelegate].msgArray removeAllObjects];	
			[sayMsgArr removeAllObjects];
			
			if (msgListData.chatsession && [msgListData.chatsession length] > 0) {
				NSArray *messageInfoDBArray = (NSMutableArray*)[MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where CHATSESSION=?", msgListData.chatsession, nil];
				if (messageInfoDBArray != nil && [messageInfoDBArray count] > 0) {
					for (MessageInfo *messageInfo in messageInfoDBArray) {
						CellMsgData *msgData = [[CellMsgData alloc] init];
						msgData.chatsession = msgListData.chatsession;
						msgData.contentsMsg = messageInfo.MSG;
						if ([messageInfo.ISSENDMSG isEqualToString:@"1"]) {
							msgData.isSend = YES;
						} else {
							msgData.isSend = NO;
						}
						msgData.messagekey = messageInfo.MESSAGEKEY;
						msgData.movieFilePath = messageInfo.MOVIEFILEPATH;
						msgData.msgType = messageInfo.MSGTYPE;
						msgData.nickName = messageInfo.NICKNAME;
						msgData.photoFilePath = messageInfo.PHOTOFILEPATH;
						msgData.photoUrl = messageInfo.PHOTOURL;
						msgData.pKey = messageInfo.PKEY;
						msgData.readMarkCount = [messageInfo.READMARKCOUNT intValue];
						msgData.regTime = messageInfo.REGDATE;
						if (msgData.msgType && [msgData.msgType length]> 0) {
							if ([msgData.msgType isEqualToString:@"P"]) {
								if (msgData.photoFilePath && [msgData.photoFilePath length]> 0) {
									msgData.mediaImage = [UIImage imageWithData:UIImageJPEGRepresentation([UIImage imageWithContentsOfFile:msgData.photoFilePath], 0.1f)];
								}
							} else {
							}
						}
						msgData.sendMsgSuccess = messageInfo.ISSUCCESS;
						[[self appDelegate].msgArray addObject:msgData];
//						[sayMsgArr addObject:msgData];
						[msgData release];
					}
				}
			}
			
			// sochae 2010.09.10 - UI Position
			//CGRect rect = [MyDeviceClass deviceOrientation];
			CGRect rect = self.view.frame;
			// ~sochae
			
			// NavigationBar title 변경
			if ([newBuddyArray count] > 0) {
				if ([newBuddyArray count] > 1) {
					UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];// 본인 포함
					UIFont *titleFont = [UIFont systemFontOfSize:20];
					CGSize titleStringSize = [[NSString stringWithFormat:@"그룹채팅 (%i명)", [newBuddyArray count]] sizeWithFont:titleFont constrainedToSize:(CGSizeMake(rect.size.width-120.0, MAXFLOAT))];
					UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, 20.0f)];
					[titleLabel setFont:titleFont];
					titleLabel.textAlignment = UITextAlignmentCenter;
					[titleLabel setTextColor:ColorFromRGB(0x053844)];
					[titleLabel setBackgroundColor:[UIColor clearColor]];
					[titleLabel setText:[NSString stringWithFormat:@"그룹채팅 (%i명)", [newBuddyArray count]]];
					[titleView addSubview:titleLabel];	
					[titleLabel release];
					self.navigationItem.titleView = titleView;
					[titleView release];
					self.navigationItem.titleView.frame = CGRectMake((self.sayTableView.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, 20.0f);
				} else if ([newBuddyArray count] == 1) {
					// 1:1
					NSString	*sayTitie = nil;
					for (NSString *RPKEY in newBuddyArray) {
						NSArray* checkDBUserInfo = [UserInfo findWithSqlWithParameters:@"select * from _TUserInfo where RPKEY=? and ISFRIEND<>? and ISBLOCK<>?", RPKEY,@"N",@"Y", nil];
						if (checkDBUserInfo && [checkDBUserInfo count] > 0) {
							for (UserInfo *userInfo in checkDBUserInfo) {
								if (userInfo.FORMATTED && [userInfo.FORMATTED length] > 0) {
									sayTitie = userInfo.FORMATTED;
								} else if (userInfo.PROFILENICKNAME && [userInfo.PROFILENICKNAME length] > 0) {	
									sayTitie = userInfo.PROFILENICKNAME;
								} else {
									sayTitie = @"이름 없음";
								}
								UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
								UIFont *titleFont = [UIFont systemFontOfSize:20];
								CGSize titleStringSize = [sayTitie sizeWithFont:titleFont constrainedToSize:(CGSizeMake(rect.size.width-120.0, MAXFLOAT))];
								UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, 20.0f)];
								[titleLabel setFont:titleFont];
								titleLabel.textAlignment = UITextAlignmentCenter;
								[titleLabel setTextColor:ColorFromRGB(0x053844)];
								[titleLabel setBackgroundColor:[UIColor clearColor]];
								[titleLabel setText:sayTitie];
								[titleView addSubview:titleLabel];	
								[titleLabel release];
								self.navigationItem.titleView = titleView;
								[titleView release];
								self.navigationItem.titleView.frame = CGRectMake((self.sayTableView.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, 20.0f);
								break;
							}
						} else {
							// error
							UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Usay" message:@"대화 하려고 하는 친구가 없습니다.(error 1)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
							[alertView show];
							[alertView release];
						}
					}
				} else {
					
					UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];// 본인 포함
					UIFont *titleFont = [UIFont systemFontOfSize:20];
					CGSize titleStringSize = [@"대화자 없음" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(rect.size.width-120.0, MAXFLOAT))];
					UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, 20.0f)];
					[titleLabel setFont:titleFont];
					titleLabel.textAlignment = UITextAlignmentCenter;
					[titleLabel setTextColor:ColorFromRGB(0x053844)];
					[titleLabel setBackgroundColor:[UIColor clearColor]];
					[titleLabel setText:@"대화자 없음"];
					[titleView addSubview:titleLabel];	
					[titleLabel release];
					self.navigationItem.titleView = titleView;
					[titleView release];
					self.navigationItem.titleView.frame = CGRectMake((self.sayTableView.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, 20.0f);
				}
				
			}
			
			[sayTableView reloadData];
			
			//	[self getReadMark];
			[self getRetrieveSessionMessage];
		} else {
			// 신규 대화방
			// sochae 2010.09.10 - UI Position
			//CGRect rect = [MyDeviceClass deviceOrientation];
			CGRect rect = self.view.frame;
			// ~sochae
			
			if ([newBuddyArray count] > 1) {
				UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
				UIFont *titleFont = [UIFont systemFontOfSize:20];
				CGSize titleStringSize = [[NSString stringWithFormat:@"그룹채팅 (%i명)", [newBuddyArray count]] sizeWithFont:titleFont constrainedToSize:(CGSizeMake(rect.size.width-120.0, MAXFLOAT))];
				UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, 20.0f)];
				[titleLabel setFont:titleFont];
				titleLabel.textAlignment = UITextAlignmentCenter;
				[titleLabel setTextColor:ColorFromRGB(0x053844)];
				[titleLabel setBackgroundColor:[UIColor clearColor]];
				[titleLabel setText:[NSString stringWithFormat:@"그룹채팅 (%i명)", [newBuddyArray count]]];
				[titleView addSubview:titleLabel];	
				[titleLabel release];
				self.navigationItem.titleView = titleView;
				[titleView release];
				self.navigationItem.titleView.frame = CGRectMake((self.sayTableView.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, 20.0f);
				
			} else if ([newBuddyArray count] == 1) {
				// 1:1
				NSString *sayTitie = nil;
				for (NSString *RPKEY in newBuddyArray) {
					NSArray* checkDBUserInfo = [UserInfo findWithSqlWithParameters:@"select * from _TUserInfo where RPKEY=? and ISFRIEND<>? and ISBLOCK<>?", RPKEY,@"N",@"Y", nil];
					if (checkDBUserInfo && [checkDBUserInfo count] > 0) {
						for (UserInfo *userInfo in checkDBUserInfo) {
							if (userInfo.FORMATTED && [userInfo.FORMATTED length] > 0) {
								sayTitie = userInfo.FORMATTED;
							} else if (userInfo.PROFILENICKNAME && [userInfo.PROFILENICKNAME length] > 0) {	
								sayTitie = userInfo.PROFILENICKNAME;
							} else {
								sayTitie = @"이름 없음";
							}
							UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
							UIFont *titleFont = [UIFont systemFontOfSize:20];
							CGSize titleStringSize = [sayTitie sizeWithFont:titleFont constrainedToSize:(CGSizeMake(rect.size.width-120.0, MAXFLOAT))];
							UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, 20.0f)];
							[titleLabel setFont:titleFont];
							titleLabel.textAlignment = UITextAlignmentCenter;
							[titleLabel setTextColor:ColorFromRGB(0x053844)];
							[titleLabel setBackgroundColor:[UIColor clearColor]];
							[titleLabel setText:sayTitie];
							[titleView addSubview:titleLabel];	
							[titleLabel release];
							self.navigationItem.titleView = titleView;
							[titleView release];
							self.navigationItem.titleView.frame = CGRectMake((self.sayTableView.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, 20.0f);
							break;
						}
					} else {
						// error
						UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Usay" message:@"대화 하려고 하는 친구가 없습니다.(error 2)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
						[alertView show];
						[alertView release];
					}
				}
			} else {
				UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];// 본인 포함
				UIFont *titleFont = [UIFont systemFontOfSize:20];
				CGSize titleStringSize = [@"대화자 없음" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(rect.size.width-120.0, MAXFLOAT))];
				UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, 20.0f)];
				[titleLabel setFont:titleFont];
				titleLabel.textAlignment = UITextAlignmentCenter;
				[titleLabel setTextColor:ColorFromRGB(0x053844)];
				[titleLabel setBackgroundColor:[UIColor clearColor]];
				[titleLabel setText:@"대화자 없음"];
				[titleView addSubview:titleLabel];	
				[titleLabel release];
				self.navigationItem.titleView = titleView;
				[titleView release];
				self.navigationItem.titleView.frame = CGRectMake((self.sayTableView.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, 20.0f);
			}
			
			[[self appDelegate].msgArray removeAllObjects];	
			[sayMsgArr removeAllObjects];
			
			[sayTableView reloadData];
			
			// joinToChatSession 요청
			NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
			[bodyObject setObject:[[self appDelegate] getSvcIdx] forKey:@"svcidx"];
			NSMutableString *buddyPKey = nil;
			
			NSString *uuid = [[self appDelegate]generateUUIDString];
			if (uuid && [uuid length] > 0) {
				if (sessionKey) {
					[sessionKey release];
					sessionKey = nil;
					sessionKey = [[NSMutableString alloc] initWithString:uuid];
				} else {
					sessionKey = [[NSMutableString alloc] initWithString:uuid];
				}
			}
			
			buddyPKey = (NSMutableString*)[newBuddyArray componentsJoinedByString:@"|"];
			[bodyObject setObject:buddyPKey forKey:@"pKeys"];
			[bodyObject setObject:uuid forKey:@"uuid"];
			
			// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
			USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"joinToChatSession" andWithDictionary:bodyObject timeout:10] autorelease];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
		}
	}
	
	
}

-(void)inviteJoinChatSession:(NSArray*)inviteBuddyArray
{
	// sochae 2010.09.10 - UI Position
	//CGRect rect = [MyDeviceClass deviceOrientation];
	CGRect rect = self.view.frame;
	// ~sochae
	
	if (inviteBuddyArray && [inviteBuddyArray count] > 0) {
		if ([self appDelegate].msgListArray && [[self appDelegate].msgListArray count] > 0) {
			for (CellMsgListData * msgListData in [self appDelegate].msgListArray) {
				if ([msgListData.chatsession isEqualToString:sessionKey]) {
					if (msgListData.userDataDic && [msgListData.userDataDic count] > 0) {
						UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
						UIFont *titleFont = [UIFont systemFontOfSize:20];
						CGSize titleStringSize = [[NSString stringWithFormat:@"그룹채팅 (%i명)", [msgListData.userDataDic count] + [inviteBuddyArray count]] sizeWithFont:titleFont constrainedToSize:(CGSizeMake(rect.size.width-120.0, MAXFLOAT))];
						UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, 20.0f)];
						[titleLabel setFont:titleFont];
						titleLabel.textAlignment = UITextAlignmentCenter;
						[titleLabel setTextColor:ColorFromRGB(0x053844)];
						[titleLabel setBackgroundColor:[UIColor clearColor]];
						[titleLabel setText:[NSString stringWithFormat:@"그룹채팅 (%i명)", [msgListData.userDataDic count] + [inviteBuddyArray count]]];
						[titleView addSubview:titleLabel];	
						[titleLabel release];
						self.navigationItem.titleView = titleView;
						[titleView release];
						self.navigationItem.titleView.frame = CGRectMake((self.sayTableView.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, 20.0f);
					}
					break;
				}
			}
		}
		NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
		
		[bodyObject setObject:[[self appDelegate].myInfoDictionary objectForKey:@"openChatSession"] forKey:@"sessionKey"];	// 신규 대화일때는 세션 없음
		[bodyObject setObject:[[self appDelegate] getSvcIdx] forKey:@"svcidx"];
		NSMutableString *buddyPKey = nil;
		buddyPKey = (NSMutableString*)[inviteBuddyArray componentsJoinedByString:@"|"];
		[bodyObject setObject:buddyPKey forKey:@"pKeys"];
		[bodyObject setObject:[[self appDelegate]generateUUIDString] forKey:@"uuid"];
		
		// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
		USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"joinToChatSession" andWithDictionary:bodyObject timeout:10] autorelease];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
	}
}

// 기존 대화일 경우만 요청
-(void)getReadMark
{
	// ReadMark 팻킷 전송 (발송건중 최근 5건)
	NSArray *sendMsgArray = nil;
	if (sessionKey && [sessionKey length] > 0) {
		sendMsgArray = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where CHATSESSION=? and ISSENDMSG=? and ISSUCCESS=? and READMARKCOUNT > ? order by REGDATE desc limit 5",self.sessionKey, @"1", @"1", [NSNumber numberWithInt:0], nil]; 
		
		
		NSLog(@"session %@", sessionKey);
		
	}
	NSString *messageKeys = nil;
	if (sendMsgArray && [sendMsgArray count] > 0) {
		for (MessageInfo *messageInfo in sendMsgArray) {
			if (messageKeys == nil) {
				messageKeys = messageInfo.MESSAGEKEY;
			} else {
				messageKeys = [messageKeys stringByAppendingString:@"|"];
				messageKeys = [messageKeys stringByAppendingString:messageInfo.MESSAGEKEY];
			}
		}
		NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
		[bodyObject setObject:sessionKey forKey:@"sessionKey"];
		[bodyObject setObject:[[self appDelegate] getSvcIdx] forKey:@"svcidx"];
		[bodyObject setObject:messageKeys forKey:@"messageKeys"];
		
		// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
		USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"getReadMark" andWithDictionary:bodyObject timeout:10] autorelease];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
		
		
		
		
	}
}


-(void)setDisabledButton:(NSNotification*)noti{
	[inputTextView setEditable:NO];
	[addBtn setEnabled:NO];
	[inputTextView resignFirstResponder];
}



//#pragma mark 이전 대화내용 요청 (retrieveSessionMessage)
- (void)getRetrieveSessionMessage
{
	// 메시지 요청
	// 1. 친구가 대화방을 만들고 대화를 보냈을 경우 대화방에 한번이라도 입장하지 않았더라면 lastMessageKey값이 없으므로 null로 해서 보내는 경우
	// 2. 기존 대화방에서 한번이라도 대화를 나눴으면 lastMessageKey 값이 있으므로 lastMessageKey 값 넣어서 요청
	//	CellMsgListData *msgListData = [[self appDelegate] MsgListDataFromChatSession:sessionKey];
	
	NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
	
	[bodyObject setObject:sessionKey forKey:@"sk"];
	[bodyObject setObject:[[self appDelegate] getSvcIdx] forKey:@"o"];
	
	
	
	
	//메세지 키 디비에서 읽어오도록
	//NSString *lastmsgkey =  [NSString stringWithFormat:@"select LASTMESSAGEKEY from _TRoomInfo where CHATSESSION='%@' limit 0, 1", sessionKey];
	
	NSString *lastmsgkey =  [NSString stringWithFormat:@"select MESSAGEKEY from _TMessageInfo where CHATSESSION='%@' and MSGTYPE !='D' and ISSENDMSG !=1 order by REGDATE desc limit 0, 1", sessionKey];
	
	
	
	
	NSArray *keyArray = [MessageInfo findWithSql:lastmsgkey];
	
	
	
	
	if([keyArray count] > 0)
	{
		
		
		MessageInfo *room = (MessageInfo*)[keyArray objectAtIndex:0];
		
		
		NSString *msgkey = room.MESSAGEKEY;
		NSLog(@"msgkey = %@", msgkey);
		
		
		
		if(msgkey == nil || [msgkey length] == 0)
		{
			
			NSLog(@"nil이다");
		}
		else {
			[bodyObject setObject:msgkey forKey:@"mk"];
		}
		
		
	}
	
	
	NSArray *sendMsgArray = nil;
	//서버 부하 때문에 최대 5개로 제한..
	if (sessionKey && [sessionKey length] > 0) {
		sendMsgArray = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where CHATSESSION=? and ISSENDMSG=? and ISSUCCESS=? and READMARKCOUNT > ? order by REGDATE desc limit 5",self.sessionKey, @"1", @"1", [NSNumber numberWithInt:0], nil]; 
		NSLog(@"session %@", sessionKey);
	}
	NSString *messageKeys = nil;
	if (sendMsgArray && [sendMsgArray count] > 0) {
		for (MessageInfo *messageInfo in sendMsgArray) {
			if (messageKeys == nil) {
				messageKeys = messageInfo.MESSAGEKEY;
			} else {
				messageKeys = [messageKeys stringByAppendingString:@"|"];
				messageKeys = [messageKeys stringByAppendingString:messageInfo.MESSAGEKEY];
			}
		}
		//	NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
		[bodyObject setObject:messageKeys forKey:@"mklp"];
		
		NSLog(@"messagekey = %@ ", messageKeys);
	}
	
	
	
	
	
	
	
	
	NSString *updateRoom = [NSString stringWithFormat:@"update _TRoomInfo set ISSUCESS=0 where CHATSESSION='%@'", sessionKey];
	[RoomInfo findWithSql:updateRoom];
	
	
	/*
	 
	 if (msgListData)
	 {
	 if (msgListData.lastmessagekey && [msgListData.lastmessagekey length] > 0) {
	 [bodyObject setObject:msgListData.lastmessagekey forKey:@"lastMessageKey"];
	 DebugLog(@"  ===> sayview lastmessageKey = %@", msgListData.lastmessagekey);
	 } else {
	 // skip
	 }
	 }
	 */
	// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
	USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"gsm" andWithDictionary:bodyObject timeout:10] autorelease];
	DebugLog(@"\n----- [HTTP] 이전 대화내용 요청 (gsm) ---------->");
	[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
	//요청 후 성공 상태값 0으로 변경한다..
	/*
	 NSString *sessionState = [NSString stringWithFormat:@"update _TRoomInfo set SUCESS=0 where CHATSESSION='%@'",sessionKey];
	 [RoomInfo findWithSql:sessionState];
	 */
	
	
}

//#pragma mark -
//*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	sourceMovie = [[NSMutableDictionary alloc] init];
	
	NSLog(@"budy aRRay %@",self.buddyArray);
	DebugLog(@"\n---------- 대화창 시작 ---------->");
	// sochae 2010.09.11 - UI Position
	//CGRect rect = [MyDeviceClass deviceOrientation];
	//CGRect rect = [[UIScreen mainScreen] applicationFrame];
	CGRect rect = self.view.frame;
	
	DebugLog(@"Show rect : %@", NSStringFromCGRect(rect));
	DebugLog(@"Show self.view.frame: %@", NSStringFromCGRect(self.view.frame));
	// ~sochae
	
	//내비게이션 바 버튼 설정
	UIImage* leftBarBtnImg = nil;
	UIImage* leftBarBtnSelImg = nil;
	UIImage* rightBarBtnImg = nil;
	UIImage* rightBarBtnSelImg = nil;
	
	if (rect.size.width < rect.size.height) {
		leftBarBtnImg = [UIImage imageNamed:@"btn_top_left.png"];
		leftBarBtnSelImg = [UIImage imageNamed:@"btn_top_left_focus.png"];
		rightBarBtnImg = [UIImage imageNamed:@"btn_top_group_add.png"];
		rightBarBtnSelImg = [UIImage imageNamed:@"btn_top_group_add_focus.png"];
	} else {
		leftBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_left.png"];
		leftBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_left_focus.png"];
		rightBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_group_add.png"];
		rightBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_group_add_focus.png"];
	}
	
	UIButton* leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[leftBarButton addTarget:self action:@selector(backBarButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
	[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateSelected];
	leftBarButton.frame = CGRectMake(0.0, 0.0, leftBarBtnImg.size.width, leftBarBtnImg.size.height);	
	UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
	self.navigationItem.leftBarButtonItem = leftButton;
	[leftButton release];
	
	UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[rightBarButton addTarget:self action:@selector(inviteButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
	[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
	rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
	self.navigationItem.rightBarButtonItem = rightButton;
	[rightButton release];
	
	[self.view setBackgroundColor:ColorFromRGB(0xecf7ff)];
	
	
	//viewDidLoad에서 처리 하는 것을 이동.......110321 shyoon
	if (sayTableView == nil) {
		// sochae 2010.09.10 - modify (INPUTVIEW_CY)
		//		sayTableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height-39)] autorelease];
		//		sayTableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-INPUTVIEW_CY)] autorelease];
		sayTableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height-INPUTVIEW_CY)] autorelease];
		// ~sochae
		[sayTableView setBackgroundColor:[UIColor clearColor]];
		sayTableView.delegate = self;
		sayTableView.dataSource = self;

 		sayTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		[self.view addSubview:sayTableView];
	}
	
	
	if (inputView == nil) {
		inputView = [[UIView alloc] initWithFrame:CGRectMake(0, rect.size.height-INPUTVIEW_CY, rect.size.width, INPUTVIEW_CY)];	// sochae 2010.09.11 - INPUTVIEW_CY
		[self.view addSubview:inputView];
		
		UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
		bgImageView.image = [[UIImage imageNamed:@"bg_input.png"] stretchableImageWithLeftCapWidth:54 topCapHeight:18];
		// sochae 2010.09.10 - UI Position
		//bgImageView.frame = CGRectMake(0, 0, rect.size.width, 39);
		bgImageView.frame = CGRectMake(0, 0, rect.size.width, INPUTVIEW_CY);
		// ~sochae
		bgImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		
		[inputView addSubview:bgImageView];
		[bgImageView release];
	}
	//
	if (inputTextView == nil) {
		inputTextView = [[SayInputTextView alloc] initWithFrame:CGRectZero];
		[inputTextView setBackgroundColor:[UIColor clearColor]];
		[inputTextView setFont:[UIFont systemFontOfSize:15.0f]];
		[inputTextView setTextColor:[UIColor colorWithRed:32.0/255.0 green:32.0/255.0 blue:42.0/255.0 alpha:1.0f]];	// color : #23232a
		inputTextView.contentInset = UIEdgeInsetsZero;
		inputTextView.showsHorizontalScrollIndicator = NO;
		inputTextView.returnKeyType = UIReturnKeyDefault;
		inputTextView.enablesReturnKeyAutomatically = YES;
		inputTextView.scrollEnabled = NO;
		inputTextView.editable = YES;
		inputTextView.delegate = self;
		inputTextView.autocapitalizationType = UITextAutocapitalizationTypeNone;
		inputTextView.tag = ID_INPUTTEXTVIEW;
		[inputView addSubview:inputTextView];
		inputTextView.frame = CGRectMake(50, INPUTTEXTVIEW_Y, rect.size.width-110, inputView.frame.size.height-10);
		
		if (addBtn == nil) {
			addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
			[addBtn setImage:[UIImage imageNamed:@"btn_attach.png"] forState:UIControlStateNormal];
			//			[addBtn setImage:[UIImage imageNamed:@"btn_attach_focus.png"] forState:UIControlStateHighlighted];
			[addBtn addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
			[inputView addSubview:addBtn];
			addBtn.frame = CGRectMake(5, 6, 38, 29);
		}
		
		if (sendBtn == nil) {
			sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
			[sendBtn setImage:[UIImage imageNamed:@"btn_send.png"] forState:UIControlStateNormal];
			[sendBtn setImage:[UIImage imageNamed:@"btn_send_focus.png"] forState:UIControlStateHighlighted];
			[sendBtn addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
			sendBtn.enabled = NO;
			[inputView addSubview:sendBtn];
			sendBtn.frame = CGRectMake(rect.size.width-58, 6, 53, 29);
		}
		
		UIView *internal = (UIView*)[[inputTextView subviews] objectAtIndex:0];
		minHeight = internal.frame.size.height;
		animateHeightChange = YES;
		inputTextView.text = @"";
		
		minNumberOfLines = 1;
		[self setMinNumberOfLines:1];
		[self setMaxNumberOfLines:3];
		
		keyboardShown = NO;
		
		[self registerForKeyboardNotifications];
		
		// 노티피케이션처리관련 등록..
		//2011.02.08 노티추가 디스에이블..
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setDisabledButton:) name:@"setDisabledButton" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ReloadMessage:) name:@"ReloadMessage" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestRetrieveSessionMessage:) name:@"requestRetrieveSessionMessage" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseJoinToChatSession:) name:@"responseJoinToChatSession" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:@"applicationWillTerminate" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CreateReSession:) name:@"CreateReSession" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setSession:) name:@"setSession" object:nil];
		
//		startTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self 
//													selector:@selector(scrollsToBottom:) 
//													userInfo:nil repeats:NO];
		
//		[sayTableView setContentOffset:CGPointMake(0,sayTableView.frame.size.height) animated:NO];

		// 아래 부터 보여 주기 위하여 타이머를 사용 하지 않고 바로 스크롤 위치 변경 .....110321 shyoon
//		if ([[self appDelegate].msgArray count] > 0) {
		if ([sayMsgArr count] > 0) {
//			int reloadToRow = [[self appDelegate].msgArray count] - 1;
			int reloadToRow = [sayMsgArr count] - 1;
			if (reloadToRow > 0) {
				// create C array of values for NSIndexPath
				NSUInteger indexArr[] = {0,reloadToRow}; 
				//move table to new entry
				[sayTableView scrollToRowAtIndexPath:[NSIndexPath indexPathWithIndexes:indexArr length:2] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
				//options for scroll position are UITableViewScrollPositionTop, UITableViewScrollPositionMiddle, UITableViewScrollPositionBottom
			}
		}
		
		
		keyboardUpTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self 
														 selector:@selector(keyboardUpTimerFunction:) 
														 userInfo:nil repeats:NO];
		
		
		NSLog(@"budyArray = %@", self.buddyArray);
		
		if (self.alreadySession == YES) {	// 기존 대화방
			NSLog(@"기존 대화방");
			//	[self getReadMark];	
			[self getRetrieveSessionMessage];
			
		} else {
			NSLog(@"시규");
			// 신규 대화방 joinToChatSession 요청
			[self createJoinChatSession:buddyArray];
		}
		
		viewDidLoadSuccess = YES;
		photoLibraryShown = NO;
	}
	
	
	
    [super viewDidLoad];
}
//*/



- (void)viewDidDisappear:(BOOL)animated 
{
	
    [super viewDidDisappear:animated];
}

//*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	DebugLog(@"가로 모드 들어오나??");
	
	interfaceOrientation = UIInterfaceOrientationPortrait;
	
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
	
	
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	CGRect rect = self.view.frame;
	NSLog(@"fdsafdasfsad");
	
	
	UIImage* leftBarBtnImg = nil;
	UIImage* leftBarBtnSelImg = nil;
	UIImage* rightBarBtnImg = nil;
	UIImage* rightBarBtnSelImg = nil;
	
	if (rect.size.width < rect.size.height) {
		leftBarBtnImg = [UIImage imageNamed:@"btn_top_left.png"];
		leftBarBtnSelImg = [UIImage imageNamed:@"btn_top_left_focus.png"];
		rightBarBtnImg = [UIImage imageNamed:@"btn_top_group_add.png"];
		rightBarBtnSelImg = [UIImage imageNamed:@"btn_top_group_add_focus.png"];
	} else {
		leftBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_left.png"];
		leftBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_left_focus.png"];
		rightBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_group_add.png"];
		rightBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_group_add_focus.png"];
	}
	
	UIButton* leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[leftBarButton addTarget:self action:@selector(backBarButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
	[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateSelected];
	leftBarButton.frame = CGRectMake(0.0, 0.0, leftBarBtnImg.size.width, leftBarBtnImg.size.height);	
	UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
	self.navigationItem.leftBarButtonItem = leftButton;
	[leftButton release];
	
	UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[rightBarButton addTarget:self action:@selector(inviteButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
	[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
	rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
	self.navigationItem.rightBarButtonItem = rightButton;
	[rightButton release];
	
	
}
//*/

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	NSLog(@"fdsafdsafdsaf");
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	// sochae 2010.09.10 - UI Position
	//CGRect rect = [MyDeviceClass deviceOrientation];
	//	CGRect rect = self.view.frame;
	// ~sochae
	
	
	
	switch (toInterfaceOrientation)  
    {  
			
			
        case UIDeviceOrientationPortrait: 
		{
			NSLog(@"가운데..");
			if(keyboardShown)
			{
				
				
				inputView.frame= CGRectMake(0, 161, 320, 39);
				inputTextView.frame=CGRectMake(50, 5, 210, 29);
				sayTableView.frame=CGRectMake(0, 0, 320, 161);
				sendBtn.frame = CGRectMake(262, sendBtn.frame.origin.y, sendBtn.frame.size.width, sendBtn.frame.size.height);
				
			}
			else {
				inputView.frame= CGRectMake(0, 377, 320, 39);
				inputTextView.frame=CGRectMake(50, 5, 210, 29);
				sayTableView.frame=CGRectMake(0, 0, 320, 377);
				sendBtn.frame = CGRectMake(262, sendBtn.frame.origin.y, sendBtn.frame.size.width, sendBtn.frame.size.height);
			}
		}
            break;  
        case UIDeviceOrientationLandscapeLeft:
		{
			
			NSLog(@"왼쪽방향..");
			
			if(keyboardShown)
			{
				
				inputView.frame= CGRectMake(0, 69, 480, 39);
				inputTextView.frame=CGRectMake(50, 5, 210, 29);
				sayTableView.frame=CGRectMake(0, 0, 480, 231);
			}
			else {
				
				NSLog(@"키보드 없다.");
				
				
				sayTableView.frame=CGRectMake(0, 0, 480, 229);			
				inputView.frame= CGRectMake(0, sayTableView.frame.origin.y+229, 480, 39);
				inputTextView.frame=CGRectMake(50, 5, 210, 29);
				
				
			}
			
			sendBtn.frame = CGRectMake(422, sendBtn.frame.origin.y, sendBtn.frame.size.width, sendBtn.frame.size.height);
			
			
			
		}
            break;  
        case UIDeviceOrientationLandscapeRight:  
		{
			NSLog(@"오른족방향..");
			
			if(keyboardShown)
			{
				inputView.frame= CGRectMake(0, 69, 480, 39);
				inputTextView.frame=CGRectMake(50, 5, 210, 29);
				sayTableView.frame=CGRectMake(0, 0, 480, 231);
			}
			else {
				
				sayTableView.frame=CGRectMake(0, 0, 480, 229);			
				inputView.frame= CGRectMake(0, sayTableView.frame.origin.y+229, 480, 39);
				inputTextView.frame=CGRectMake(50, 5, 210, 29);
				
			}
			
			
			sendBtn.frame = CGRectMake(422, sendBtn.frame.origin.y, sendBtn.frame.size.width, sendBtn.frame.size.height);
			
			
		}
            break;  
        case UIDeviceOrientationPortraitUpsideDown:  
		{
			
			if(keyboardShown)
			{
				
				
				inputView.frame= CGRectMake(0, 161, 320, 39);
				inputTextView.frame=CGRectMake(50, 5, 210, 29);
				sayTableView.frame=CGRectMake(0, 0, 320, 161);
				sendBtn.frame = CGRectMake(262, sendBtn.frame.origin.y, sendBtn.frame.size.width, sendBtn.frame.size.height);
				
			}
			else {
				inputView.frame= CGRectMake(0, 377, 320, 39);
				inputTextView.frame=CGRectMake(50, 5, 210, 29);
				sayTableView.frame=CGRectMake(0, 0, 320, 377);
				sendBtn.frame = CGRectMake(262, sendBtn.frame.origin.y, sendBtn.frame.size.width, sendBtn.frame.size.height);
			}
			
			
			NSLog(@"아래방향..");
			
		}
            break;  
			
		case UIDeviceOrientationFaceUp:
		{
			NSLog(@"faceup");
		}
            break;
			
		case UIDeviceOrientationFaceDown:
		{
			NSLog(@"facedown");
		}
            break;  
			
		case UIDeviceOrientationUnknown:
		{	
			
			
			
		}
			
        default:  
            break;  
    }  
	
	/*
	 //내비게이션 바 버튼 설정
	 UIImage* leftBarBtnImg = nil;
	 UIImage* leftBarBtnSelImg = nil;
	 UIImage* rightBarBtnImg = nil;
	 UIImage* rightBarBtnSelImg = nil;
	 
	 if (rect.size.width < rect.size.height) {
	 leftBarBtnImg = [UIImage imageNamed:@"btn_top_left.png"];
	 leftBarBtnSelImg = [UIImage imageNamed:@"btn_top_left_focus.png"];
	 rightBarBtnImg = [UIImage imageNamed:@"btn_top_group_add.png"];
	 rightBarBtnSelImg = [UIImage imageNamed:@"btn_top_group_add_focus.png"];
	 } else {
	 leftBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_left.png"];
	 leftBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_left_focus.png"];
	 rightBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_group_add.png"];
	 rightBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_group_add_focus.png"];
	 }
	 
	 UIButton* leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	 [leftBarButton addTarget:self action:@selector(backBarButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	 [leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
	 [leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateSelected];
	 leftBarButton.frame = CGRectMake(0.0, 0.0, leftBarBtnImg.size.width, leftBarBtnImg.size.height);	
	 UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
	 self.navigationItem.leftBarButtonItem = leftButton;
	 [leftButton release];
	 
	 UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	 [rightBarButton addTarget:self action:@selector(inviteButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	 [rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
	 [rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
	 rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
	 UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
	 self.navigationItem.rightBarButtonItem = rightButton;
	 [rightButton release];
	 
	 */
	[self.sayTableView reloadData];
	
	
	
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
	
    [super didReceiveMemoryWarning];
	
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc 
{
	
	//방을 나가면 타임아웃 취소
	
	[[self appDelegate].myInfoDictionary setObject:@"" forKey:@"openChatSession"];
	[[self appDelegate].msgArray removeAllObjects];	
	[sayMsgArr removeAllObjects];
	
	[sayMsgArr release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"ReloadMessage" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"requestRetrieveSessionMessage" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"responseJoinToChatSession" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"applicationWillTerminate" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"CreateReSession" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"setSession" object:nil];
	
	
	if (sessionKey) {
		[sessionKey release];
		sessionKey = nil;
	}
	if (inputView) {
		[inputView release];
	}
	if (buddyArray) {
		[buddyArray release];
	}
	
	[myLabel release];
    [super dealloc];
}

-(void)setMaxNumberOfLines:(int)n
{
	UITextView *test = [[UITextView alloc] init];	
	test.font = inputTextView.font;
	test.hidden = YES;
	
	NSMutableString *newLines = [NSMutableString string];
	
	if(n == 1){
		[newLines appendString:@"-"];
	} else {
		for(int i = 1; i<n; i++){
			[newLines appendString:@"\n"];
		}
	}
	
	test.text = newLines;
	
	
	[inputView addSubview:test];
	
	maxHeight = test.contentSize.height;
	
	maxHeight = 78;
	maxNumberOfLines = n;
	
	[test removeFromSuperview];
	[test release];	
}

-(void)setMinNumberOfLines:(int)m
{
	
	UITextView *test = [[UITextView alloc] init];	
	test.font = inputTextView.font;
	test.hidden = YES;
	
	NSMutableString *newLines = [NSMutableString string];
	
	if(m == 1){
		[newLines appendString:@"-"];
	} else {
		for(int i = 1; i<m; i++){
			[newLines appendString:@"\n"];
		}
	}
	
	test.text = newLines;
	
	
	[inputView addSubview:test];
	
	minHeight = test.contentSize.height;
	
	minHeight = 39;
	
	minNumberOfLines = m;
	
	[test removeFromSuperview];
	[test release];
}


-(void)willChangeHeight:(float)newSizeHeight
{
	// sochae 2010.09.10 - UI Position
	//CGRect rect = [MyDeviceClass deviceOrientation];
	CGRect rect = self.view.frame;
	// ~sochae
	
	float diff = (inputView.frame.size.height - newSizeHeight);
	
	CGRect r = inputView.frame;
	r.origin.y += diff;
	inputView.frame = r;
	
	addBtn.frame = CGRectMake(5, inputView.frame.size.height - 33, 38, 29);
	sendBtn.frame = CGRectMake(rect.size.width-58, inputView.frame.size.height - 33, 53, 29);
}


#pragma mark -
#pragma mark NSNotification response

-(void)ReloadMessage:(NSNotification *)notification
{
	DebugLog(@"메시지 갱신");
	NSString *data = (NSString*)[notification object];
	if (data == nil) {
		return;
	}
	if ([data isEqualToString:self.sessionKey]) {
		// 여기에서 변경 데이터를 sayMsgArr에 넣어 준다.....shyoon
        fullCount = [[self appDelegate].msgArray count];

        if (fullCount > nViewEnd) {
//            int nAddCount = fullCount - nViewEnd;
            
            for (int i = nViewEnd; i < fullCount; i++) {
//                [sayMsgArr insertObject:[[self appDelegate].msgArray objectAtIndex:i] atIndex:i-1];
                [sayMsgArr addObject:[[self appDelegate].msgArray objectAtIndex:i]];
            }
            
            nViewEnd = fullCount;
        }
		
		[self.sayTableView reloadData];
		
//		if ([[self appDelegate].msgArray count] > 0) {
		if ([sayMsgArr count] > 0) {
//			int reloadToRow = [[self appDelegate].msgArray count] - 1;
			int reloadToRow = [sayMsgArr count] - 1;
			if (reloadToRow > 0) {
				// create C array of values for NSIndexPath
				NSUInteger indexArr[] = {0,reloadToRow}; 
				//move table to new entry
				[sayTableView scrollToRowAtIndexPath:[NSIndexPath indexPathWithIndexes:indexArr length:2] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
				//options for scroll position are UITableViewScrollPositionTop, UITableViewScrollPositionMiddle, UITableViewScrollPositionBottom
			}
		}
		
		NSString *sayTitle = nil;
		// sochae 2010.09.10 - UI Position
		//CGRect rect = [MyDeviceClass deviceOrientation];
		CGRect rect = self.view.frame;
		// ~sochae
		
		if ([self appDelegate].msgListArray && [[self appDelegate].msgListArray count] > 0) {
			for (CellMsgListData * msgListData in [self appDelegate].msgListArray) {
				if ([msgListData.chatsession isEqualToString:sessionKey]) {
					if (msgListData.userDataDic) {
						if ([msgListData.userDataDic count] > 1) {
							sayTitle = [NSString stringWithFormat:@"그룹채팅 (%i명)", [msgListData.userDataDic count]];
						} else if ([msgListData.userDataDic count] == 1) {
							for (id key in msgListData.userDataDic) {
								MsgUserData *userData = [msgListData.userDataDic objectForKey:key];
								if (userData.nickName && [userData.nickName length] > 0) {
									sayTitle = userData.nickName;
								} else {
									sayTitle = @"이름 없음";
								}
							}
						} else {
							sayTitle = @"대화자 없음";
						}
						
						UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
						UIFont *titleFont = [UIFont systemFontOfSize:20];
						if (sayTitle == nil)
							sayTitle = @"";
						CGSize titleStringSize = [sayTitle sizeWithFont:titleFont constrainedToSize:(CGSizeMake(rect.size.width-120.0, MAXFLOAT))];
						UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, 20.0f)];
						[titleLabel setFont:titleFont];
						titleLabel.textAlignment = UITextAlignmentCenter;
						[titleLabel setTextColor:ColorFromRGB(0x053844)];
						[titleLabel setBackgroundColor:[UIColor clearColor]];
						[titleLabel setText:sayTitle];
						[titleView addSubview:titleLabel];	
						[titleLabel release];
						self.navigationItem.titleView = titleView;
						[titleView release];
						self.navigationItem.titleView.frame = CGRectMake((self.sayTableView.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, 20.0f);
						
					} 
					break;
				}
			}
		}
	}
	/* 프로그래스바 때문에 리로드를 할 수 가 없다..
	NSLog(@"RELOAD MEssage");
	NSString *data = (NSString*)[notification object];
	if (data == nil) {
		return;
	}
	if ([data isEqualToString:self.sessionKey]) {
		
		[self.sayTableView reloadData];
		
		
		//날짜순으로 재정렬..
		[[self appDelegate].msgArray removeAllObjects];
		
		NSMutableArray *tmpMsgArray =[NSMutableArray array];
			NSArray *messageInfoDBArray = (NSMutableArray*)[MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where CHATSESSION=? order by REGDATE", sessionKey, nil];
			if (messageInfoDBArray != nil && [messageInfoDBArray count] > 0) {
				for (MessageInfo *messageInfo in messageInfoDBArray) {
					CellMsgData *msgData = [[CellMsgData alloc] init];
					msgData.chatsession = sessionKey;
					msgData.contentsMsg = messageInfo.MSG;
					if ([messageInfo.ISSENDMSG isEqualToString:@"1"]) {
						msgData.isSend = YES;
					} else {
						msgData.isSend = NO;
					}
					msgData.messagekey = messageInfo.MESSAGEKEY;
					msgData.movieFilePath = messageInfo.MOVIEFILEPATH;
					msgData.msgType = messageInfo.MSGTYPE;
					msgData.nickName = messageInfo.NICKNAME;
					msgData.photoFilePath = messageInfo.PHOTOFILEPATH;
					msgData.photoUrl = messageInfo.PHOTOURL;
					msgData.pKey = messageInfo.PKEY;
					msgData.readMarkCount = [messageInfo.READMARKCOUNT intValue];
					msgData.regTime = messageInfo.REGDATE;
					msgData.sendMsgSuccess = messageInfo.ISSUCCESS;
				
				//	[tmpMsgArray addObject:msgData];
					[[self appDelegate].msgArray addObject:msgData];
					[msgData release];
				}
			}
		
		
		// 기존 대화가 있으면 DB에서 메모리로 로드.
	//	[[self appDelegate].msgArray removeAllObjects];	
		//새로운 데이터로 체인지
	//	[self appDelegate].msgArray = nil;
	//	[self appDelegate].msgArray = tmpMsgArray;
		
		
		
		
		
		
		
		
		
		
		if ([[self appDelegate].msgArray count] > 0) {
			NSLog(@"RELOAD MEssage111");
			int reloadToRow = [[self appDelegate].msgArray count] - 1;
			if (reloadToRow > 0) {
			NSLog(@"AAAAAAAAAAAAAAA");
				
				// create C array of values for NSIndexPath
				NSUInteger indexArr[] = {0,reloadToRow}; 
				NSLog(@"BBBBBBBBB");
				//move table to new entry
				[sayTableView scrollToRowAtIndexPath:[NSIndexPath indexPathWithIndexes:indexArr length:2] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
				NSLog(@"CCCC");
				//options for scroll position are UITableViewScrollPositionTop, UITableViewScrollPositionMiddle, UITableViewScrollPositionBottom
			}
		}
		
		
		NSLog(@"RELOAD MEssage22222");
		NSString *sayTitle = nil;
		// sochae 2010.09.10 - UI Position
		//CGRect rect = [MyDeviceClass deviceOrientation];
		CGRect rect = self.view.frame;
		// ~sochae
		NSLog(@"RELOAD MEssage3333");
		if ([self appDelegate].msgListArray && [[self appDelegate].msgListArray count] > 0) {
			NSLog(@"RELOAD MEssage4444");
			for (CellMsgListData * msgListData in [self appDelegate].msgListArray) {
				if ([msgListData.chatsession isEqualToString:sessionKey]) {
					
					NSLog(@"RELOAD MEssage55555");
					if (msgListData.userDataDic) {
						NSLog(@"RELOAD MEssage66666");
						if ([msgListData.userDataDic count] > 1) {
							sayTitle = [NSString stringWithFormat:@"그룹채팅 (%i명)", [msgListData.userDataDic count] + 1];
						} else if ([msgListData.userDataDic count] == 1) {
							for (id key in msgListData.userDataDic) {
								MsgUserData *userData = [msgListData.userDataDic objectForKey:key];
								if (userData.nickName && [userData.nickName length] > 0) {
									sayTitle = userData.nickName;
								} else {
									sayTitle = @"이름 없음";
								}
							}
						} else {
							sayTitle = @"대화자 없음";
						}
						
						
						
						UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
						UIFont *titleFont = [UIFont systemFontOfSize:20];
						if (sayTitle == nil)
							sayTitle = @"";
						CGSize titleStringSize = [sayTitle sizeWithFont:titleFont constrainedToSize:(CGSizeMake(rect.size.width-120.0, MAXFLOAT))];
						UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, 20.0f)];
						[titleLabel setFont:titleFont];
						titleLabel.textAlignment = UITextAlignmentCenter;
						[titleLabel setTextColor:ColorFromRGB(0x053844)];
						[titleLabel setBackgroundColor:[UIColor clearColor]];
						[titleLabel setText:sayTitle];
						[titleView addSubview:titleLabel];	
						[titleLabel release];
						self.navigationItem.titleView = titleView;
						[titleView release];
						self.navigationItem.titleView.frame = CGRectMake((self.sayTableView.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, 20.0f);
						
					} 
					break;
				}
			}
		}
	
	
	
	
	
	
	}
	else
	{
		NSLog(@"세션이 다른다.");
	}
	 */
		
}

-(void)setSession:(NSNotification*)noti
{
	NSString *key = (NSString*)[noti object];
	self.sessionKey = (NSMutableString*)key;
	NSLog(@"key = %@", key);
	
}

-(void)CreateReSession:(NSNotification*)noti
{
	NSLog(@"세션이 존재 하지 않는다 ");
	
	/*
	[[self appDelegate].myInfoDictionary setObject:@"" forKey:@"openChatSession"];
	sessionKey = nil;
	*/
	
	
	
	
	// joinToChatSession 요청
	NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
	[bodyObject setObject:[[self appDelegate] getSvcIdx] forKey:@"svcidx"];
	NSMutableString *buddyPKey = nil;
	
	
	[bodyObject setObject:sessionKey forKey:@"sessionKey"];
	
	NSString *uuid = [[self appDelegate]generateUUIDString];
	if (uuid && [uuid length] > 0) {
		if (sessionKey) {
			[sessionKey release];
			sessionKey = nil;
			sessionKey = [[NSMutableString alloc] initWithString:uuid];
		} else {
			sessionKey = [[NSMutableString alloc] initWithString:uuid];
		}
	}
	
	buddyPKey = (NSMutableString*)[buddyArray componentsJoinedByString:@"|"];
	[bodyObject setObject:buddyPKey forKey:@"pKeys"];
	
	[bodyObject setObject:uuid forKey:@"uuid"];
	
	// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
	USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"joinToChatSession" andWithDictionary:bodyObject timeout:10] autorelease];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
	
	
	
//	[self createJoinChatSession:buddyArray];
}

// 신규로 대화방을 신청했을때 서버에서 joinToChatSession response 받은후 sessionKey 저장. cType 메모리에서 읽어와야함.
-(void)responseJoinToChatSession:(NSNotification *)notification
{
	NSLog(@"SayViewController responseJoinToChatSession sessionKey = %@", sessionKey);
	NSString *data = (NSString*)[notification object];
	if (data == nil) {
		return;
	} else {
		// data  uuid|sessionKey 형태로 넘어옴.
		NSArray *responseArray = [data componentsSeparatedByString:@"|"];	
		
		if (responseArray && [responseArray count] > 0) {
			NSLog(@"%@", responseArray);
			NSLog(@"SayViewController responseJoinToChatSession uuid = %@   sessionKey = %@", (NSString*)[responseArray objectAtIndex:0], (NSString*)[responseArray objectAtIndex:1]);
			if ([sessionKey isEqualToString:(NSString*)[responseArray objectAtIndex:0]]) {
				if ([responseArray objectAtIndex:0] && [(NSString*)[responseArray objectAtIndex:0] length] > 0) {
					if (sessionKey) {
						[sessionKey release];
						sessionKey = nil;
						sessionKey = [[NSMutableString alloc] initWithString:[responseArray objectAtIndex:1]];
					} else {
						sessionKey = [[NSMutableString alloc] initWithString:[responseArray objectAtIndex:1]];
					}
				}
				[[self appDelegate].myInfoDictionary setObject:(NSString*)[responseArray objectAtIndex:1] forKey:@"openChatSession"];
			}
		}
	}
}

-(void)requestRetrieveSessionMessage:(NSNotification *)notification
{
	[self getRetrieveSessionMessage];
}

-(void)applicationWillTerminate:(NSNotification *)notification
{
	// TODO: 종료 처리
	NSLog(@"SayViewController applicationWillTerminate");
	
}

#pragma mark -

-(USayAppAppDelegate *) appDelegate
{
	return (USayAppAppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark -
#pragma mark UITableViewDelegate Protocol


-(void)hiddenKeyboard
{
	[inputTextView resignFirstResponder];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[inputTextView resignFirstResponder];
	// skip
}

// Asks the delegate for the height to use for a row in a specified location.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//	CellMsgData *msgData = [[self appDelegate].msgArray objectAtIndex:indexPath.row];
	CellMsgData *msgData = [sayMsgArr objectAtIndex:indexPath.row];
	
	//	CGRect rect = [MyDeviceClass deviceOrientation];
	
	if (msgData != nil) {
		if ([msgData.msgType isEqualToString:@"T"]) {
			UIImage *stretchImage = [[UIImage imageNamed:@"Balloon_Green.png"] stretchableImageWithLeftCapWidth:12 topCapHeight:34];
			CGSize size = [stretchImage size];
			UIFont *contentsFont = [UIFont boldSystemFontOfSize:15];
			//UIFont *contentsFont = [UIFont systemFontOfSize:15];
			CGSize contentsStringSize = [msgData.contentsMsg sizeWithFont:contentsFont constrainedToSize:(CGSizeMake(193.0f, MAXFLOAT))];
			return size.height + contentsStringSize.height - 7;
		} 
		else if ([msgData.msgType isEqualToString:@"P"]) {
			return 126.0f;
		} 
		else if ([msgData.msgType isEqualToString:@"V"]) {
			return 126.0f;
		} 
		else if ([msgData.msgType isEqualToString:@"J"]) {
			UIFont *contentsFont = [UIFont boldSystemFontOfSize:13];
		//	UIFont *contentsFont = [UIFont systemFontOfSize:13];
			
			CGSize contentsStringSize = [msgData.contentsMsg sizeWithFont:contentsFont constrainedToSize:(CGSizeMake(self.view.frame.size.width - 34, MAXFLOAT))];
			return contentsStringSize.height + 18;
		} 
		else if ([msgData.msgType isEqualToString:@"Q"]) {
			UIFont *contentsFont = [UIFont boldSystemFontOfSize:13];
		//	UIFont *contentsFont = [UIFont systemFontOfSize:13];
			CGSize contentsStringSize = [msgData.contentsMsg sizeWithFont:contentsFont constrainedToSize:(CGSizeMake(self.view.frame.size.width - 34, MAXFLOAT))];
			return contentsStringSize.height + 10;
		} 
		else if ([msgData.msgType isEqualToString:@"D"]) {
			return 30.0f;
		}
		else 
		{
			
		}
	}
	/*
	 NSString	*headText = nil;
	 CGSize		headSize = [headText sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(193.0f, MAXFLOAT)];
	 
	 // TODO: text, image, movie 에 따라 설정
	 NSString	*bodyText = nil;
	 CGSize		bodySize = [bodyText sizeWithFont:[UIFont boldSystemFontOfSize:15] constrainedToSize:CGSizeMake(193.0f, MAXFLOAT)];
	 //*/
	// headSize.height + bodySize.height + padding
	return 30.0f;
}


#pragma mark -
#pragma mark 스크롤 뷰 델리게이트

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
 	NSLog(@"scrollViewDidEndDragging contentOffset.y = %f", scrollView.contentOffset.y);
   
	if(scrollView.contentOffset.y < 0){
/*
 		
		@synchronized([self sayMsgArr]) {
//           if (bFirstLoadTable) {
                int tempCount = [[self appDelegate].msgArray count];
                
                //		NSMutableArray *tempPreArr = [[NSMutableArray alloc] init];
                //		NSMutableArray *tempNextArr = [[NSMutableArray alloc] init];
                //		NSMutableArray *tempArr = [[NSMutableArray alloc] init];
                nScrollPos = 0;
                
                if(tempCount > 15 && nViewStart > 1) {
                    int i;
                    for (i=1; i < 16; i++) {
                        nViewStart -= 1;
                        //				[tempPreArr addObject:[[self appDelegate].msgArray objectAtIndex:nViewStart-1] ];
                        //                [self.sayTableView beginUpdates];
                        [sayMsgArr insertObject:[[self appDelegate].msgArray objectAtIndex:nViewStart-1] atIndex:0];
                       
                        nScrollPos = i-1;
//                        
//                        startTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self 
//                                                                    selector:@selector(scrollsToMiddle:) 
//                                                                    userInfo:nil repeats:NO];
//
//                        [self.sayTableView beginUpdates];
//                        [self.sayTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] 
//                                                 withRowAnimation:UITableViewRowAnimationTop];
//                        
//                        startTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self 
//                                                                    selector:@selector(scrollsToMiddle:) 
//                                                                    userInfo:nil repeats:NO];
//                      
//                        [self.sayTableView endUpdates];
//                        
                        if (nViewStart - 1 == 0) {
                            break;
                        }
                    }
                    //			[tempArr addObjectsFromArray:sayMsgArr];
                    //			[sayMsgArr removeAllObjects];
                    //			[sayMsgArr addObjectsFromArray:tempPreArr];
                    //			[sayMsgArr addObjectsFromArray:tempArr];		
                    
                    //                NSIndexPath *scrollIndexPath;
                    
                    //                scrollIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    //                [self.sayTableView selectRowAtIndexPath:scrollIndexPath animated:YES
                    //                                         scrollPosition:UITableViewScrollPositionTop];
                    
                    
                    
                    
//                    nViewEnd = fullCount;
                    
 
//                    [sayTableView reloadData];

                    loadingTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(endLoading) userInfo:nil repeats:NO];

                }
                
//                bFirstLoadTable = NO;
                
                //		[tempPreArr release];
                //		[tempNextArr release];
                //		[tempArr release];
            }
//            else
//                bFirstLoadTable = YES;

//        }
        
 
//*/        
	}
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
//	NSLog(@"%f", scrollView.contentOffset.y);
   
    if (scrollView.contentOffset.y < 100 && bFirstLoadTable == NO) {
//        NSThread* timerThread = [[[NSThread alloc] initWithTarget:self selector:@selector(addItemThread) object:nil] autorelease];
//        [timerThread start];
        
    }
/*     
    if (baddItemFinish) {
        
        startTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self 
                                                    selector:@selector(scrollsToMiddle:) 
                                                    userInfo:nil repeats:NO];
        
        [sayTableView reloadData];
        
        startTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self 
                                                    selector:@selector(scrollsToMiddle:) 
                                                    userInfo:nil repeats:NO];
        baddItemFinish = NO;
    }
//*/    
	//여기서 45는 데이블 로우의 height값이다.
	if(scrollView.contentOffset.y < 0){
        
//		if(!updateFlag) firstCell.textLabel.text = @"Release to Refresh";		
        
	}else{
//		if(!updateFlag) firstCell.textLabel.text = @"Pull down to Refresh";
		
	}
    
	
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"====> scrollViewDidEndDecelerating");
     
    int tempCount = [[self appDelegate].msgArray count];
    
    
    nScrollPos = 0;
    
    if(scrollView.contentOffset.y < 70 && tempCount > 15 && nViewStart > 1 && bFirstLoadTable == NO) {
        int i;

        bFirstLoadTable = YES;

//        NSMutableArray *arrTemp = [[NSMutableArray alloc] init];
        
        for (i=1; i < 16; i++) {
            nViewStart -= 1;
            
            NSLog(@"#####contentsMsg nViewStart = %d", nViewStart );
            
            [sayMsgArr insertObject:[[self appDelegate].msgArray objectAtIndex:nViewStart-1] atIndex:0];
//            [arrTemp insertObject:[[self appDelegate].msgArray objectAtIndex:nViewStart-1] atIndex:0];
            
//            CellMsgData *msgData = [sayMsgArr objectAtIndex:0];
//            NSLog(@"#####contentsMsg = %@", msgData.contentsMsg );
            
            nScrollPos = i-1;
            
            if (nViewStart - 1 == 0) {
                break;
            }
        }
/*        
        int index = -1;
        for (int j = [arrTemp count]-1; j > -1; j--) {
//            startTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self 
//                                                        selector:@selector(scrollsToMiddle:) 
//                                                        userInfo:nil repeats:NO];
            
            [sayMsgArr insertObject:[arrTemp objectAtIndex:j] atIndex:0];     
            
            [self.sayTableView beginUpdates];
            [self.sayTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] 
                                     withRowAnimation:UITableViewRowAnimationNone];

            index += 1;
            nScrollPos = index;
            startTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self 
                                                        selector:@selector(scrollsToMiddle:) 
                                                        userInfo:nil repeats:NO];
                               
            [self.sayTableView endUpdates];
        }
        
        
        [arrTemp removeAllObjects];
        [arrTemp release];
 //*/       
//        if (bFirstLoadTable) {
            
            loadingTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(endLoading) userInfo:nil repeats:NO];
            
//        }
    }
    else
    {
        
    }
    
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    NSLog(@"====> scrollViewDidEndScrollingAnimation");
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    NSLog(@"====> scrollViewDidScrollToTop");

}

-(void)endLoading
{	
    NSLog(@"====> endLoading"); 
//    startTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self 
//                                                selector:@selector(scrollsToMiddle:) 
//                                                userInfo:nil repeats:NO];
    NSUInteger indexArr[] = {0,nScrollPos}; 
   
    [self.sayTableView reloadData];
    
    //move table to new entry
    [sayTableView scrollToRowAtIndexPath:[NSIndexPath indexPathWithIndexes:indexArr length:2] atScrollPosition:UITableViewScrollPositionTop animated:NO];

    bFirstLoadTable = NO;
    
    NSLog(@"#####say message count = %d", [sayMsgArr count]);
    NSLog(@"#####say nScrollPos = %d", nScrollPos);

//    for (int i=0; i < [sayMsgArr count]; i++) {
//        CellMsgData *msgData = [sayMsgArr objectAtIndex:i];
//        NSLog(@"#####contentsMsg = %@", msgData.contentsMsg );
//    }

//    if (nViewStart > 1) {
//        startTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self 
//                                                    selector:@selector(scrollsToMiddle:) 
//                                                    userInfo:nil repeats:NO];

//    }


}




#pragma mark -
#pragma mark UITableViewDataSource Protocol
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;	// 날짜, 초대, 퇴장이 섹션에 입력 가능
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
//    return [[self appDelegate].msgArray count];
	return [sayMsgArr count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	
	NSLog(@"indexpath.row %d", indexPath.row);
    

/*	
	if (indexPath.row == 0 && bFirstLoadTable) {
		int tempCount = [[self appDelegate].msgArray count];
		
//		NSMutableArray *tempPreArr = [[NSMutableArray alloc] init];
//		NSMutableArray *tempNextArr = [[NSMutableArray alloc] init];
//		NSMutableArray *tempArr = [[NSMutableArray alloc] init];

		if(tempCount > 15 && nViewStart > 1) {
			for (int i=1; i < 16; i++) {
				nViewStart -= 1;
//				[tempPreArr addObject:[[self appDelegate].msgArray objectAtIndex:nViewStart-1] ];
//                [self.sayTableView beginUpdates];
                [sayMsgArr insertObject:[[self appDelegate].msgArray objectAtIndex:nViewStart-1] atIndex:0];
				
                [self.sayTableView beginUpdates];
                [self.sayTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] 
                                      withRowAnimation:UITableViewRowAnimationBottom];
                [self.sayTableView endUpdates];
				
                if (nViewStart - 1 == 0) {
					break;
				}
			}
//			[tempArr addObjectsFromArray:sayMsgArr];
//			[sayMsgArr removeAllObjects];
//			[sayMsgArr addObjectsFromArray:tempPreArr];
//			[sayMsgArr addObjectsFromArray:tempArr];		

			nViewEnd = fullCount;
            
//            [sayTableView reloadData];
            
 		}
		
        bFirstLoadTable = NO;
        
//		[tempPreArr release];
//		[tempNextArr release];
//		[tempArr release];
	}
    else
        bFirstLoadTable = YES;
//*/
	
//	if ([[self appDelegate].msgArray count] < indexPath.row) {
	if ([sayMsgArr count] < indexPath.row) {
		static NSString *CellIdentifier = @"Cell";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if(cell == nil) {
			
			
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			NSLog(@"first Cell");
		}
		return cell;
	} else {
		static NSString *msgCellIdentifier = @"msgMessageCell";
		
		BalloomTableCell *cell = (BalloomTableCell*)[tableView dequeueReusableCellWithIdentifier:msgCellIdentifier];
		if (cell == nil) {
			cell = [[[BalloomTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:msgCellIdentifier] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			
			
		}
		
		// Configure the cell...
//		CellMsgData *msgData = [[self appDelegate].msgArray objectAtIndex:indexPath.row];
		CellMsgData *msgData = [sayMsgArr objectAtIndex:indexPath.row];
		
		NSString *photoUrl2 = [NSString stringWithFormat:@"%@/008", msgData.photoUrl];
		cell.photoUrl=photoUrl2;
		cell.parentDelegate =self;
		
		if ([msgData.msgType isEqualToString:@"T"]) 
		{			// 텍스트
			if (msgData.isSend == NO) {	// 수신된 텍스트 데이터
				if (msgData.photoUrl && [msgData.photoUrl length] > 0) {
					NSString *photoUrl = [NSString stringWithFormat:@"%@/011", msgData.photoUrl];
				//	NSString *photoUrl2 = [NSString stringWithFormat:@"%@/008", msgData.photoUrl];
				//	cell.parentDelegate =self;
				//	cell.photoUrl=photoUrl2;
					[cell.photoImageView setImageWithURL:[NSURL URLWithString:photoUrl]
										placeholderImage:[UIImage imageNamed:@"img_default.png"]];
				} else {				// 발신한 데이터
					cell.photoImageView.image = [UIImage imageNamed:@"img_default.png"];
				}
			} else {					// 발신 텍스트
				[cell setReadMarkCount:[msgData readMarkCount]];
				cell.sendMsgSuccess = msgData.sendMsgSuccess;
				cell.failSendContentsUIControl.tag = indexPath.row;
			}
			cell.msgType = msgData.msgType;
			cell.nickName = msgData.nickName;
			[cell.nickNameLabel setText:msgData.nickName];
			cell.time = [[self appDelegate] generateMsgDateFromUnixTimeStamp:msgData.regTime];
			cell.contentsMsg = msgData.contentsMsg;
			[cell.tmpTextField setText:msgData.contentsMsg];
			cell.tmpTextField.dataDetectorTypes=UIDataDetectorTypeAll;
			
			
			
			
			[cell.contentsLabel setText:@""];
			
		//	[cell.contentsLabel setText:msgData.contentsMsg];
			
			
			
			/*
			
			UITextField *tmpField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, cell.contentsLabel.frame.size.width, cell.contentsLabel.frame.size.height)];
			[tmpField setText:msgData.contentsMsg];
			[cell.contentsLabel addSubview:tmpField];
			[tmpField setBackgroundColor:[UIColor redColor]];
			[tmpField setEnabled:YES];
			
			*/
			
			
			cell.isSend = msgData.isSend;
		
			
		
			
		} 
		else if ([msgData.msgType isEqualToString:@"P"])
		{	// 사진
			
		
			if (msgData.isSend == NO) {	// 수신 사진
				
				if (msgData.photoUrl && [msgData.photoUrl length] > 0) {
					NSString *photoUrl = [NSString stringWithFormat:@"%@/011", msgData.photoUrl];		// 41*41
					[cell.photoImageView setImageWithURL:[NSURL URLWithString:photoUrl]
										placeholderImage:[UIImage imageNamed:@"img_default.png"]];
				} else {
					// error
					cell.photoImageView.image = [UIImage imageNamed:@"img_default.png"];
				}
				
				if (msgData.contentsMsg && [msgData.contentsMsg length] > 0) {				
					NSString *photoUrl = [NSString stringWithFormat:@"%@/012", msgData.contentsMsg];	// 64*64
					[cell.contentsMediaImageView setImageWithURL:[NSURL URLWithString:photoUrl]
												placeholderImage:[UIImage imageNamed:@"img_default_photo.png"]];
				} else {
					// error
					cell.contentsMediaImageView.image = [UIImage imageNamed:@"img_default_photo.png"];
				}
				
				cell.contentsUIControl.tag = indexPath.row;
			} else {	// 발송 사진
				[cell setReadMarkCount:[msgData readMarkCount]];
				cell.sendMsgSuccess = msgData.sendMsgSuccess;
				if ([msgData.sendMsgSuccess isEqualToString:@"0"]) {
					cell.progressPosition = msgData.mediaProgressPos;
				} else if ([msgData.sendMsgSuccess isEqualToString:@"1"]) {
				} else {
					// fail
					NSLog(@"사진 메세지 전송 실패");
				}
				
				if (msgData.contentsMsg && [msgData.contentsMsg length] > 0) {				
					NSString *photoUrl = [NSString stringWithFormat:@"%@/012", msgData.contentsMsg];	// 64*64
					[cell.contentsMediaImageView setImageWithURL:[NSURL URLWithString:photoUrl]
												placeholderImage:[UIImage imageNamed:@"img_default_photo.png"]];
				} else {
					//파일이 Documents에 존재하는지 확인
					NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
					NSString *documentsDirectory = [paths objectAtIndex:0];
					NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", msgData.photoFilePath]];
					if (filePath && [filePath length] > 0) {
						BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:NO];
						if (exist) {
							if (msgData.mediaImage) {
								[cell.contentsMediaImageView setImage:msgData.mediaImage];
							} else {
								msgData.mediaImage = [UIImage imageWithContentsOfFile:filePath];
								[cell.contentsMediaImageView setImage:msgData.mediaImage];
							}
						} else {
							if (msgData.contentsMsg && [msgData.contentsMsg length] > 0) {				
								NSString *photoUrl = [NSString stringWithFormat:@"%@/012", msgData.contentsMsg];
								[cell.contentsMediaImageView setImageWithURL:[NSURL URLWithString:photoUrl]
															placeholderImage:[UIImage imageNamed:@"img_default_photo.png"]];
							} else {
								cell.contentsMediaImageView.image = [UIImage imageNamed:@"img_default_photo.png"];
							}
						}
					} else {
						// error
						cell.contentsMediaImageView.image = [UIImage imageNamed:@"img_default_photo.png"];
					}
				}
				
				cell.contentsUIControl.tag = indexPath.row;
				cell.failSendContentsUIControl.tag = indexPath.row;
			}
			
			cell.msgType = msgData.msgType;
			cell.nickName = msgData.nickName;
			[cell.nickNameLabel setText:msgData.nickName];
			cell.time = [[self appDelegate] generateMsgDateFromUnixTimeStamp:msgData.regTime];
			
			
			NSLog(@"포토 컨텐츠 메세지 %@", msgData.contentsMsg);
			cell.contentsMsg = msgData.contentsMsg;
//			[cell.contentsLabel setText:msgData.contentsMsg];
			cell.isSend = msgData.isSend;
			cell.parentDelegate = self;
			cell.tmpTextField.text=@"";
		} 
		else if ([msgData.msgType isEqualToString:@"V"])
		{		// 동영상
			if ([msgData isSend] == NO) {	// 수신 동영상
				if (msgData.photoUrl && [msgData.photoUrl length] > 0) {
					NSString *photoUrl = [NSString stringWithFormat:@"%@/011", msgData.photoUrl];
					[cell.photoImageView setImageWithURL:[NSURL URLWithString:photoUrl]
										placeholderImage:[UIImage imageNamed:@"img_default.png"]];
				} else {
					cell.photoImageView.image = [UIImage imageNamed:@"img_default.png"];
				}
			} else {						// 발신 동영상
				[cell setReadMarkCount:[msgData readMarkCount]];
				cell.sendMsgSuccess = msgData.sendMsgSuccess;
				if ([msgData.sendMsgSuccess isEqualToString:@"0"]) {
					cell.progressPosition = msgData.mediaProgressPos;
				} else if ([msgData.sendMsgSuccess isEqualToString:@"1"]) {
				} else {
					
					
					
					NSLog(@"동영상 메세지 전송 실패");
					
					
					
					// fail
				}
			}
			
			// 동영상은 default image
			cell.contentsMediaImageView.image = [UIImage imageNamed:@"img_video_message.png"];
			cell.msgType = msgData.msgType;
			cell.nickName = msgData.nickName;
			[cell.nickNameLabel setText:msgData.nickName];
			cell.time = [[self appDelegate] generateMsgDateFromUnixTimeStamp:msgData.regTime];
			cell.contentsMsg = msgData.contentsMsg;
			[cell.contentsLabel setText:msgData.contentsMsg];
			cell.isSend = msgData.isSend;
			cell.parentDelegate = self;
			cell.failSendContentsUIControl.tag = indexPath.row;
			cell.contentsUIControl.tag = indexPath.row;
			
			
			
			
			cell.tmpTextField.text=@"";
			
			
			
		}
		else if ([msgData.msgType isEqualToString:@"J"]) {
			cell.msgType = msgData.msgType;
			cell.contentsMsg = msgData.contentsMsg;
			[cell.nickNameLabel setText:msgData.contentsMsg];
			cell.tmpTextField.text=@"";
		} 
		else if ([msgData.msgType isEqualToString:@"Q"]) {
			cell.msgType = msgData.msgType;
			cell.contentsMsg = msgData.contentsMsg;
			[cell.nickNameLabel setText:msgData.contentsMsg];
			
			cell.tmpTextField.text=@"";
		} 
		else if ([msgData.msgType isEqualToString:@"D"]) {
			//여기가 날짜 이다..
			cell.msgType = msgData.msgType;
			cell.contentsMsg = msgData.contentsMsg;
			[cell.nickNameLabel setText:msgData.contentsMsg];
			
			cell.tmpTextField.text=@"";
			
			
		
		} else {
			
			
			
			
			
			
		}
		
				
		return cell;
	}
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([self appDelegate].connectionType == -1) {	// -1:offline mode  0:disconnect 1:Wi-Fi 2:3G
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"오프라인" message:@"현재 네트워크 연결이 불가능한 상태입니다.\nUsay의 모든 기능을 이용하기 위해서는 네트워크 연결이 필요합니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return;
	} else if ([self appDelegate].connectionType == 0) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"3G 또는 Wi-Fi 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0027)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return;
	}
	
	if(editingStyle == UITableViewCellEditingStyleDelete) {
		// 메모리에서 메시지 삭제
		// Delete the row from the data source 
//		@synchronized([self appDelegate].msgArray) {
		@synchronized([self sayMsgArr]) {
//			CellMsgData *msgData = [[[self appDelegate] msgArray] objectAtIndex:indexPath.row];
			CellMsgData *msgData = [sayMsgArr objectAtIndex:indexPath.row];
			if (msgData) {
				if ([msgData.sendMsgSuccess isEqualToString:@"1"]) {	// 성공한 패킷만 서버에 전송후 삭제 처리
					// DB에서는 서버에서 응답 받고 삭제
					// 서버에 Request
					NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
					[bodyObject setObject:msgData.chatsession forKey:@"sessionKey"];
					[bodyObject setObject:msgData.messagekey forKey:@"messageKeys"];
					[bodyObject setObject:[[self appDelegate] getSvcIdx] forKey:@"svcidx"];
					
					// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
					USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"deleteMyMessage" andWithDictionary:bodyObject timeout:10] autorelease];
					[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
				} else {
					// 보내는 중이거나 실패한 패킷은 바로 DB에서 삭제
					if (msgData.chatsession && [msgData.chatsession length] > 0 && msgData.messagekey && [msgData.messagekey length] > 0) {
						NSArray *checkDBMessageInfo = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where CHATSESSION=? and MESSAGEKEY=?", msgData.chatsession, msgData.messagekey, nil];
						if (checkDBMessageInfo && [checkDBMessageInfo count] > 0) {
							[MessageInfo findWithSqlWithParameters:@"delete from _TMessageInfo where CHATSESSION=? and MESSAGEKEY=?", msgData.chatsession, msgData.messagekey, nil];
						}
					}
				}
			}
			[[[self appDelegate] msgArray] removeObjectAtIndex:indexPath.row+nViewStart];
			[sayMsgArr removeObjectAtIndex:indexPath.row];
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
		}
	} else if (editingStyle == UITableViewCellEditingStyleInsert) {
		// Create a new instance of the appropriate class, insert in into the array, and add a new row to the table view
	}
}

// cell 삭제여부 체크
- (UITableViewCellEditingStyle)tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath
{
//	CellMsgData *msgData = [[[self appDelegate] msgArray] objectAtIndex:indexPath.row];
	CellMsgData *msgData = [sayMsgArr objectAtIndex:indexPath.row];
	
	if (msgData != nil) {
		if ([msgData.msgType isEqualToString:@"T"]) {
			return UITableViewCellEditingStyleDelete;	
		} else if ([msgData.msgType isEqualToString:@"P"]) {
			return UITableViewCellEditingStyleDelete;
		} else if ([msgData.msgType isEqualToString:@"V"]) {
			return UITableViewCellEditingStyleDelete;
		}
	}
	
	return UITableViewCellEditingStyleNone;
}

#pragma mark -
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShown:)
												 name:UIKeyboardWillShowNotification object:nil];
	
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHidden:)
												 name:UIKeyboardWillHideNotification object:nil];
}

-(void) keyboardWillShown:(NSNotification *)aNotification
{	
	keyboardShown = YES;
	
	if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 3.2) {
		// Get animation info from userInfo
		NSTimeInterval animationDuration;
		UIViewAnimationCurve animationCurve;
		
		CGRect keyboardEndFrame;
		
		[[aNotification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
		[[aNotification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
		[[aNotification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
		
		// Animate up or down
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:animationDuration];
		[UIView setAnimationCurve:animationCurve];

		CGRect keyboardFrame = [self.sayTableView convertRect:keyboardEndFrame toView:nil];

		CGRect textViewFrame = inputView.frame;
		textViewFrame.origin.y -= keyboardFrame.size.height;

		CGRect tableViewFrame = sayTableView.frame;
		tableViewFrame.size.height -= keyboardFrame.size.height;
		
		keyboardHeight = keyboardFrame.size.height;
		
		inputView.frame = textViewFrame;
		sayTableView.frame = tableViewFrame;
		
		
		

		
		
		
		
		
		
		
		
		
		
		
		
		[UIView commitAnimations];
	} else {
		// get keyboard size and loctaion
		CGRect keyboardBounds;
		
		[[aNotification.userInfo valueForKey:UIKeyboardBoundsUserInfoKey] getValue: &keyboardBounds];
		
		// get the height since this is the main value that we need.
		NSInteger kbSizeH = keyboardBounds.size.height;
	
		// sochae 2010.09.10 - UI Position
		//CGRect rect = [MyDeviceClass deviceOrientation];
		CGRect rect = self.view.frame;
		// ~sochae
		
		// get a rect for the textView frame
		CGRect textViewFrame = inputView.frame;
		
		CGRect tableViewFrame = sayTableView.frame;
		tableViewFrame.size.height = rect.size.height - textViewFrame.size.height;
		tableViewFrame.size.height -= kbSizeH;
		
		textViewFrame.origin.y = tableViewFrame.size.height;
		
		keyboardHeight = kbSizeH;
		
		// animations settings
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
		
		// set views with new info
		inputView.frame = textViewFrame;
		sayTableView.frame = tableViewFrame;
		
		// commit animations
		
		
			
		
		
	
		
		[UIView commitAnimations];
	}
	
	[sendBtn setImage:[UIImage imageNamed:@"btn_send_bsend.png"] forState:UIControlStateNormal];
	[sendBtn setImage:[UIImage imageNamed:@"btn_send_bsend_focus.png"] forState:UIControlStateHighlighted];

	addBtn.frame = CGRectMake(5, inputView.frame.size.height - 33, 38, 29);
	sendBtn.frame = CGRectMake(self.view.frame.size.width-58, inputView.frame.size.height - 33, 53, 29);
	
	[sendBtn becomeFirstResponder];
	
	if (viewDidLoadSuccess) {
//		if ([[self appDelegate].msgArray count] > 0) {
		if ([sayMsgArr count] > 0) {
//			int reloadToRow = [[self appDelegate].msgArray count] - 1;
			int reloadToRow = [sayMsgArr count] - 1;
			if (reloadToRow > 0) {
				// create C array of values for NSIndexPath
				NSUInteger indexArr[] = {0,reloadToRow}; 
				//move table to new entry
				[sayTableView scrollToRowAtIndexPath:[NSIndexPath indexPathWithIndexes:indexArr length:2] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
				//options for scroll position are UITableViewScrollPositionTop, UITableViewScrollPositionMiddle, UITableViewScrollPositionBottom
			}
		}
	}
	
	
	
	
	if(UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
	{
		NSLog(@"가로");
		sayTableView.frame=CGRectMake(0, 0, 480, 67);			
		inputView.frame= CGRectMake(0, sayTableView.frame.origin.y+67, 480, 39);
		inputTextView.frame=CGRectMake(50, 5, 210+150, 29);
		
	}
	else if(UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
		//일반 키보드..
		inputView.frame= CGRectMake(0, 161, 320, 39);
		inputTextView.frame=CGRectMake(50, 5, 210, 29);
		sayTableView.frame=CGRectMake(0, 0, 320, 161);
		
		
		
		
		
		
				
		
		
		
		
	}
	else {
		
	}

	
	
		
	
	
	NSLog(@"input %f %f %f %f", inputView.frame.origin.x, inputView.frame.origin.y, inputView.frame.size.width, inputView.frame.size.height);
	NSLog(@"table %f %f %f %f", sayTableView.frame.origin.x, sayTableView.frame.origin.y, sayTableView.frame.size.width, sayTableView.frame.size.height);
	
	NSLog(@"table text %f %f %f %f", inputTextView.frame.origin.x, inputTextView.frame.origin.y, inputTextView.frame.size.width, inputTextView.frame.size.height);
	NSLog(@"send btn %f", sendBtn.frame.origin.x);
	
}

-(void) keyboardWillHidden:(NSNotification *)aNotification
{	
	keyboardShown = NO;
	
	
	NSLog(@"keyboard hide");
	
	if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 3.2) {
		// Get animation info from userInfo
		NSTimeInterval animationDuration;
		UIViewAnimationCurve animationCurve;
		
		CGRect keyboardEndFrame;
		
		[[aNotification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
		[[aNotification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
		[[aNotification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
		
		// Animate up or down
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:animationDuration];
		[UIView setAnimationCurve:animationCurve];
		
		CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];
		
		keyboardHeight = 0;
		// get a rect for the textView frame
		CGRect textViewFrame = inputView.frame;
		textViewFrame.origin.y += keyboardFrame.size.height;
		
		CGRect tableViewFrame = sayTableView.frame;
		tableViewFrame.size.height += keyboardFrame.size.height;
		
		// set views with new info
		inputView.frame = textViewFrame;
		sayTableView.frame = tableViewFrame;
		
		[UIView commitAnimations];
	} else {
		// get keyboard size and location
		CGRect keyboardBounds;
		[[aNotification.userInfo valueForKey:UIKeyboardBoundsUserInfoKey] getValue: &keyboardBounds];
		// get the height since this is the main value that we need.

		// sochae 2010.09.10 - UI Position
		//CGRect rect = [MyDeviceClass deviceOrientation];
		CGRect rect = self.view.frame;
		// ~sochae
		
		// get a rect for the textView frame
		CGRect textViewFrame = inputView.frame;
		
		CGRect tableViewFrame = sayTableView.frame;
		tableViewFrame.size.height = rect.size.height - textViewFrame.size.height;
		
		textViewFrame.origin.y = tableViewFrame.size.height;
		
		keyboardHeight = 0;
		
		// animations settings
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
		
		// set views with new info
		inputView.frame = textViewFrame;
		sayTableView.frame = tableViewFrame;
		
		// commit animations
		[UIView commitAnimations];
	}
	
	addBtn.frame = CGRectMake(5, inputView.frame.size.height - 33, 38, 29);
	sendBtn.frame = CGRectMake(self.view.frame.size.width-58, inputView.frame.size.height - 33, 53, 29);
	[sendBtn setImage:[UIImage imageNamed:@"btn_send.png"] forState:UIControlStateNormal];
	[sendBtn setImage:[UIImage imageNamed:@"btn_send_focus.png"] forState:UIControlStateHighlighted];
	[sendBtn resignFirstResponder];
	
	startTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self 
												selector:@selector(scrollsToBottom:) 
												userInfo:nil repeats:NO];
	
	
	
	
	if(UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
	{
		NSLog(@"가로");
		sayTableView.frame=CGRectMake(0, 0, 480, 229);			
		inputView.frame= CGRectMake(0, sayTableView.frame.origin.y+229, 480, 39);
		inputTextView.frame=CGRectMake(50, 5, 210, 29);
		
	}
	else if(UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation))  {
		//NSLog(@"device %@", [UIDevice currentDevice].orientation);
		
		//일반 키보드..
		inputView.frame= CGRectMake(0, 377, 320, 39);
		inputTextView.frame=CGRectMake(50, 5, 210, 29);
		sayTableView.frame=CGRectMake(0, 0, 320, 377);
	}
	else {
		NSLog(@"device is unknown");
	}

	
	
	
	
	NSLog(@"input %f %f %f %f", inputView.frame.origin.x, inputView.frame.origin.y, inputView.frame.size.width, inputView.frame.size.height);
	NSLog(@"table %f %f %f %f", sayTableView.frame.origin.x, sayTableView.frame.origin.y, sayTableView.frame.size.width, sayTableView.frame.size.height);
	
	NSLog(@"table text hidden %f %f %f %f", inputTextView.frame.origin.x, inputTextView.frame.origin.y, inputTextView.frame.size.width, inputTextView.frame.size.height);
	
	
}

#pragma mark -

#pragma mark UITextViewDelegate Protocol

- (void)textViewDidChange:(UITextView *)textView
{
	NSInteger newSizeH = inputTextView.contentSize.height;
	if (newSizeH < minHeight || !inputTextView.hasText) {
		newSizeH = minHeight;
	}
	
	if (newSizeH != INPUTVIEW_CY) {		// sochae 2010.09.11 - INPUTVIEW_CY
		newSizeH += 5;
	}
	
	if (inputTextView.hasText) {
		sendBtn.enabled = YES;
	} else {
		sendBtn.enabled = NO;
	}
	
	if (inputTextView.frame.size.height != newSizeH) {
		if (newSizeH <= maxHeight) {
			if (animateHeightChange) {
				[UIView beginAnimations:@"" context:nil];
				[UIView setAnimationDelegate:self];
				[UIView setAnimationBeginsFromCurrentState:YES];
			}
			
			[self willChangeHeight:newSizeH];
			
			CGRect inputViewFrame = inputView.frame;
			inputViewFrame.size.height = newSizeH; // + padding
			inputView.frame = inputViewFrame;
			
			inputViewFrame.origin.x = 50;
			inputViewFrame.origin.y = INPUTTEXTVIEW_Y;
			inputViewFrame.size.width -= 110;
			inputViewFrame.size.height -= 10;    // sochae 2010.09.27 (14 -> 10)
			
			// sochae 2010.09.10 - UI Position
			//CGRect rect = [MyDeviceClass deviceOrientation];
			CGRect rect = self.view.frame;
			// ~sochae
			
			addBtn.frame = CGRectMake(5, inputView.frame.size.height - 33, 38, 29);
			sendBtn.frame = CGRectMake(rect.size.width-58, inputView.frame.size.height - 33, 53, 29);
			
			inputTextView.frame = inputViewFrame;
			
			sayTableView.frame = CGRectMake(sayTableView.frame.origin.x,
											sayTableView.frame.origin.y, 
											sayTableView.frame.size.width, 
											rect.size.height - inputView.frame.size.height - keyboardHeight);
			
			if(animateHeightChange){
				[UIView commitAnimations];
			}
		}
		if (newSizeH >= maxHeight)
		{
			if(!inputTextView.scrollEnabled){
				inputTextView.scrollEnabled = YES;
				[inputTextView flashScrollIndicators];
			}
			
		} else {
			inputTextView.scrollEnabled = NO;
		}
	}
	
//	if ([self appDelegate].msgArray && [[self appDelegate].msgArray count] > 0) {
	if (sayMsgArr && [sayMsgArr count] > 0) {
//		int reloadToRow = [[self appDelegate].msgArray count] - 1;
		int reloadToRow = [sayMsgArr count] - 1;
		if (reloadToRow > 0) {
			// create C array of values for NSIndexPath
			NSUInteger indexArr[] = {0,reloadToRow}; 
			//move table to new entry
			[sayTableView scrollToRowAtIndexPath:[NSIndexPath indexPathWithIndexes:indexArr length:2] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
			//options for scroll position are UITableViewScrollPositionTop, UITableViewScrollPositionMiddle, UITableViewScrollPositionBottom
		}
	}
}


#pragma mark -
#pragma mark 이미지피커 커스텀
-(void)cancleModal
{
	
	NSLog(@"self.view.height %f", self.sayTableView.frame.origin.y);
	UIImagePickerController *myPicker = (UIImagePickerController*)self.modalViewController;
	[myPicker dismissModalViewControllerAnimated:YES];
	
}

-(void)backNavi
{
	UIImagePickerController *myPicker = (UIImagePickerController*)self.modalViewController;
	[myPicker popViewControllerAnimated:YES];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	UIImagePickerController *myPicker = (UIImagePickerController*)self.modalViewController;
	myPicker.navigationBar.topItem.title=@"";
	NSLog(@"1afdsfdsafasfsdadsafdsafdsafdsaf");
	myPicker.navigationBar.alpha=0.0001;
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	
	UIImagePickerController *myPicker = (UIImagePickerController*)self.modalViewController;
	
	UIButton *preButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 52, 31)];
	[preButton setBackgroundImage:[UIImage imageNamed:@"btn_top_left.png"] forState:UIControlStateNormal];
	[preButton setBackgroundImage:[UIImage imageNamed:@"btn_top_left_focus"] forState:UIControlStateHighlighted];
	[preButton addTarget:self action:@selector(backNavi) forControlEvents:UIControlEventTouchUpInside];
	
	
	UIBarButtonItem *backButton = [[[UIBarButtonItem alloc] initWithCustomView:preButton] autorelease];
	
	[preButton release];	// sochae 2010.09.07 - memory leak
	
	
	
	UIButton *cancleButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 47, 31)] autorelease];
	[cancleButton setBackgroundImage:[UIImage imageNamed:@"btn_searchbar_cancel.png"] forState:UIControlStateNormal];
	[cancleButton setBackgroundImage:[UIImage imageNamed:@"btn_searchbar_cancel_focus.png"] forState:UIControlStateHighlighted];
	[cancleButton addTarget:self action:@selector(cancleModal) forControlEvents:UIControlEventTouchUpInside];
	
	UIBarButtonItem *rightButton = [[[UIBarButtonItem alloc] initWithCustomView:cancleButton] autorelease];
	
	
	
	
	[myPicker.navigationBar.topItem.backBarButtonItem setImage:[UIImage imageNamed:@"btn_top_left.png"]];
	myPicker.navigationBar.alpha=1;
	NSLog(@"title = %@", myPicker.navigationBar.topItem.title);
	if(![myPicker.navigationBar.topItem.title isEqualToString:@""])
	{
		myPicker.navigationBar.topItem.leftBarButtonItem = backButton;
		
	}
	
	
	myPicker.navigationBar.topItem.title=@"";
	
	NSLog(@"fdsafd");
	myPicker.navigationBar.topItem.rightBarButtonItem = rightButton;
	if(myLabel == NULL)
	{
		myLabel = [[UILabel alloc] initWithFrame:CGRectMake(115, 0, 120, 44)];
		[myLabel setBackgroundColor:[UIColor clearColor]];
		[myLabel setText:@"사진 앨범"];
		[myLabel setFont:[UIFont systemFontOfSize:18]];
		[myLabel setTextColor:ColorFromRGB(0x053844)];
	}
	if(![myLabel superview])
		[myPicker.navigationBar addSubview:myLabel];
}


#pragma mark -
#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	//	NSLog(@"User Pressed Button %i", buttonIndex);
	
	
	if(LOGINSUCESS != YES)
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"로그인 후 이용 가능합니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return;
		
	}
	
	
	
	
	
	
	
	
	
	if (actionSheet) {
		if (actionSheet.tag == ID_ATTACH_ACTIONSHEET) {
			if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
				// 카메라 사용 못함.
				if (buttonIndex == 0) {	// album 사진, 동영상
					if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
						photoLibraryShown = YES;
						UIImagePickerController *picker = [[UIImagePickerController alloc] init];
						picker.delegate = self;
						picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
						picker.mediaTypes = [NSArray arrayWithObjects:@"public.movie", @"public.image", nil];
						[self presentModalViewController:picker animated:YES];
						[picker release];
					} else {
						// skip
					}
				} else if (buttonIndex == 1) {	// cancel
					
				} else {
					// skip
				}
			} else {
				if (buttonIndex == 0) {			// 사진 / 동영상 촬영
					photoLibraryShown = YES;
					UIImagePickerController *picker = [[UIImagePickerController alloc] init];
					picker.delegate = self;
					picker.sourceType = UIImagePickerControllerSourceTypeCamera;
					picker.mediaTypes = [NSArray arrayWithObjects:@"public.movie", @"public.image", nil];
					[self presentModalViewController:picker animated:YES];
					[picker release];
				} else if (buttonIndex == 1) {	// album 사진, 동영상
					if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
						photoLibraryShown = YES;
						UIImagePickerController *picker = [[UIImagePickerController alloc] init];
						picker.delegate = self;
						picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
						picker.mediaTypes = [NSArray arrayWithObjects:@"public.movie", @"public.image", nil];
						[self presentModalViewController:picker animated:YES];
						
						
						picker.navigationBar.topItem.title=@" ";
						
						
						/*
						 UILabel *titleLabel  = [[[UILabel alloc] initWithFrame:CGRectMake(115, 9, 320, 44)] autorelease];
						 [titleLabel setText:@"사진 앨범"];
						 [titleLabel setBackgroundColor:[UIColor clearColor]];
						 [titleLabel setTextColor:[UIColor blackColor]];
						 [titleLabel setFont:[UIFont systemFontOfSize:20]];
						 [titleLabel sizeToFit];
						 [picker.navigationBar.topItem setTitle:@" "];
						 [picker.navigationBar addSubview:titleLabel];
						 */
						[picker release];
					} else {
						// skip
					}
				} else if (buttonIndex == 2) {	// cancel
					
				} else {
					// skip
				}
			}
		} else if (actionSheet.tag == ID_RESEND_ACTIONSHEET) {
			if (reSendCellRow >= 0) {
				if (buttonIndex == 0) {	// 재전송
					// Text, Photo, Movie 재전송
//					@synchronized([self appDelegate].msgArray) {
					@synchronized(sayMsgArr) {
//						CellMsgData *msgData = [[self appDelegate].msgArray objectAtIndex:reSendCellRow];
						CellMsgData *msgData = [sayMsgArr objectAtIndex:reSendCellRow];
						if ([msgData.msgType isEqualToString:@"T"]) {
							NSString *message = [NSString stringWithString:msgData.contentsMsg];
							
							////////////////////////////////////////////////////////////////////////////////////////
							// 이전 데이터 삭제
							NSArray *checkDBMessageInfo = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where MESSAGEKEY=?", msgData.messagekey, nil];
							if (checkDBMessageInfo && [checkDBMessageInfo count] > 0) {
								[MessageInfo findWithSqlWithParameters:@"delete from _TMessageInfo where MESSAGEKEY=?", msgData.messagekey, nil];
							}

							[[self appDelegate].msgArray removeObjectAtIndex:reSendCellRow+nViewStart];
							[sayMsgArr removeObjectAtIndex:reSendCellRow];
							////////////////////////////////////////////////////////////////////////////////////////
							
							NSNumber *currentTimeNumber = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]*1000];	// 13자리로 변경
							// sochae 2010.10.12
							//NSString *nickName = [[NSUserDefaults standardUserDefaults] objectForKey:kNickname];
							NSString *nickName = (NSString *)[JYUtil loadFromUserDefaults:kNickname];
							// ~sochae
							NSInteger userCount = [[self appDelegate] chatSessionPeopleCount:sessionKey];
							NSString *uuid = [[self appDelegate] generateUUIDString];
							
							////////////////////////////////////////////////////////////////////////////////////////
							// 날짜 비교후 날짜 정보 저장
							NSArray *lastRegDateArray = nil;
							if(sessionKey && [sessionKey length] > 0) {
								lastRegDateArray = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where ISSUCCESS=? and CHATSESSION=? order by REGDATE desc limit 1", @"1", sessionKey, nil];
							} else {
							}
							NSNumber *lastRegDateNumber = nil;
							if (lastRegDateArray && [lastRegDateArray count] > 0) {
								for (MessageInfo *messageInfo in lastRegDateArray) {
									lastRegDateNumber = messageInfo.REGDATE;
								}
							} else {
							}
							NSString *noticeDateMsg = [[self appDelegate] compareLastMsgDate:lastRegDateNumber afterMsgUnixTimeStamp:currentTimeNumber];
							if (noticeDateMsg) {
								
								/*
								NSLog(@"CTTIME3 = %@", currentTimeNumber);
								double newtime = [currentTimeNumber doubleValue] - fmod([currentTimeNumber doubleValue], 86400000);
								NSString *tmpTime = [NSString stringWithFormat:@"%f", newtime];
								NSNumber *currentTimeNumber2 =[NSNumber numberWithLongLong:[tmpTime longLongValue]];
								
								//	currentTimeNumber = [NSNumber numberWithLongLong:[tmpTime longLongValue]];
								NSLog(@"CTTIME4 = %@", currentTimeNumber2);
								*/
								
								
								
								NSDate *currentDate = [NSDate date];
								NSCalendar *calendar = [NSCalendar currentCalendar];
								NSDateComponents *currentComp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSWeekdayCalendarUnit fromDate:currentDate];
								NSInteger currentYear = [currentComp year];
								NSInteger currentMonth = [currentComp month];
								NSInteger currentDay = [currentComp day];
								NSDate *date;
								NSDateComponents *com;
								com = [[NSDateComponents alloc] init];
								[com setYear:currentYear];
								[com setMonth:currentMonth];
								[com setDay:currentDay];
								[com setHour:00];
								[com setMinute:00];
								[com setSecond:00];
								date = [[NSCalendar currentCalendar] dateFromComponents:com];
								[com release];	// sochae 2011.03.06 - 정적 분석 오류 
								
								//자정시간으로 바꾼다..
								NSNumber *currentTimeNumber2 = [NSNumber numberWithLongLong:[date timeIntervalSince1970]*1000];
								
								
								
								
								
								// 메시지 DB, 메모리에 추가
								[MessageInfo findWithSqlWithParameters:
								 @"insert into _TMessageInfo(CHATSESSION, MESSAGEKEY, MSG, MSGTYPE, REGDATE, PKEY, NICKNAME, PHOTOURL, ISSENDMSG, ISSUCCESS, READMARKCOUNT) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", 
								 self.sessionKey, @"", noticeDateMsg, @"D", currentTimeNumber2, @"", @"", @"", @"", @"1", [NSNumber numberWithInt:0], nil];
								
								CellMsgData *newMsgData = [[CellMsgData alloc] init];
								newMsgData.chatsession = self.sessionKey;
								newMsgData.contentsMsg = noticeDateMsg;
								newMsgData.msgType = @"D";
								newMsgData.regTime = currentTimeNumber;
								[newMsgData setIsSend:NO];
								[[self appDelegate].msgArray addObject:newMsgData];
//								[sayMsgArr addObject:newMsgData];
								[newMsgData release];
							}
							////////////////////////////////////////////////////////////////////////////////////////
							
							// 메시지 메모리 추가
							CellMsgData *msgData = [[CellMsgData alloc] init];
							msgData.chatsession = sessionKey;
							msgData.messagekey = uuid;	// 임시 메시지 키
							msgData.contentsMsg = message;
							msgData.msgType = @"T";
							msgData.nickName = nickName;
							msgData.regTime = currentTimeNumber;
							[msgData setIsSend:YES];
							msgData.sendMsgSuccess = @"0";
							[msgData setReadMarkCount:userCount];
							[[self appDelegate].msgArray addObject:msgData];
//							[sayMsgArr addObject:msgData];
							[msgData release];
							
							// 메시지 DB 추가
							[MessageInfo findWithSqlWithParameters:@"insert into _TMessageInfo(CHATSESSION, MESSAGEKEY, MSG, MSGTYPE, REGDATE, PKEY, NICKNAME, PHOTOURL, ISSENDMSG, ISSUCCESS, PHOTOFILEPATH, MOVIEFILEPATH, READMARKCOUNT) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", 
							 self.sessionKey, uuid, message, @"T", currentTimeNumber, @"", nickName, @"", @"1", @"0", @"", @"", [NSNumber numberWithInt:userCount], nil];
							
							[self.sayTableView reloadData];
							
							
							
							NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
							[bodyObject setObject:sessionKey forKey:@"sk"];
							[bodyObject setObject:[[self appDelegate] getSvcIdx] forKey:@"o"];
							[bodyObject setObject:@"T" forKey:@"mt"];
							[bodyObject setObject:message forKey:@"m"];
							[bodyObject setObject:uuid forKey:@"u"];
							
							
							
							NSArray *sendMsgArray = nil;
							//서버 부하 때문에 최대 5개로 제한..
							if (sessionKey && [sessionKey length] > 0) {
								sendMsgArray = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where CHATSESSION=? and ISSENDMSG=? and ISSUCCESS=? and READMARKCOUNT > ? order by REGDATE desc limit 5",self.sessionKey, @"1", @"1", [NSNumber numberWithInt:0], nil]; 
								NSLog(@"session %@", sessionKey);
							}
							NSString *messageKeys = nil;
							if (sendMsgArray && [sendMsgArray count] > 0) {
								for (MessageInfo *messageInfo in sendMsgArray) {
									if (messageKeys == nil) {
										messageKeys = messageInfo.MESSAGEKEY;
									} else {
										messageKeys = [messageKeys stringByAppendingString:@"|"];
										messageKeys = [messageKeys stringByAppendingString:messageInfo.MESSAGEKEY];
									}
								}
							//	NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
								[bodyObject setObject:messageKeys forKey:@"mklp"];
								
								NSLog(@"messagekey = %@ ", messageKeys);
							}
							
							
#ifdef DEVEL_MODE	// sochae 2011.02.25 - 이거 개발로 안묶어주면 appStore 등록 버전 노티 잘못 나감. 
							[bodyObject setObject:@"1" forKey:@"t"];
#endif
							NSLog(@"body = %@", bodyObject);
							
							
							
							
							
							// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
							USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"tm" andWithDictionary:bodyObject timeout:10] autorelease];
							data.messageKey = uuid;
							data.sessionKey = sessionKey;
							[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
							
							
							
							
							
							
							
							
							
							/*
							
							NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
							[bodyObject setObject:sessionKey forKey:@"sessionKey"];
							[bodyObject setObject:[[self appDelegate] getSvcIdx] forKey:@"svcidx"];
							[bodyObject setObject:@"T" forKey:@"mType"];
							[bodyObject setObject:message forKey:@"message"];
							[bodyObject setObject:uuid forKey:@"uuid"];
							
							DebugLog(@"bodyObject = %@", [bodyObject description]);
							
							NSLog(@"body = %@", bodyObject);
							// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
							USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"createNewMessage" andWithDictionary:bodyObject timeout:10] autorelease];
							
							 data.messageKey = uuid;
							data.sessionKey = sessionKey;
							[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
							
							*/
							
							NSLog(@"bodyRequest %@", data.sessionKey);
							[inputTextView setText:@""];
							
//							if ([[self appDelegate].msgArray count] > 0) {
							if ([sayMsgArr count] > 0) {
//								int reloadToRow = [[self appDelegate].msgArray count] - 1;
								int reloadToRow = [sayMsgArr count] - 1;
								if (reloadToRow > 0) {
									// create C array of values for NSIndexPath
									NSUInteger indexArr[] = {0,reloadToRow}; 
									//move table to new entry
									[sayTableView scrollToRowAtIndexPath:[NSIndexPath indexPathWithIndexes:indexArr length:2] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
									//options for scroll position are UITableViewScrollPositionTop, UITableViewScrollPositionMiddle, UITableViewScrollPositionBottom
								}
							}
							
						} else if ([msgData.msgType isEqualToString:@"P"]) {
							
							
							
							
							
							
							
							
							NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
						//	NSLog(@"count = %d", [paths count]);
							NSString *cachesDirectory = [paths objectAtIndex:0];
							NSString *imagePath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", msgData.photoFilePath]];
							
							if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath isDirectory:NO]) {
								// not exist file
								NSLog(@"imagePath not exist file");
								return;
							}
							
							////////////////////////////////////////////////////////////////////////////////////////
							// 이전 데이터 삭제
							NSArray *checkDBMessageInfo = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where MESSAGEKEY=?", msgData.messagekey, nil];
							if (checkDBMessageInfo && [checkDBMessageInfo count] > 0) {
								[MessageInfo findWithSqlWithParameters:@"delete from _TMessageInfo where MESSAGEKEY=?", msgData.messagekey, nil];
							}

							[[self appDelegate].msgArray removeObjectAtIndex:reSendCellRow+nViewStart];
							[sayMsgArr removeObjectAtIndex:reSendCellRow];
							////////////////////////////////////////////////////////////////////////////////////////
							
							NSNumber *currentTimeNumber = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]*1000];	// 13자리로 변경
							// sochae 2010.10.12
							//NSString *nickName = [[NSUserDefaults standardUserDefaults] objectForKey:@"nickName"];
							NSString *nickName = (NSString *)[JYUtil loadFromUserDefaults:kNickname];
							// ~sochae
							NSInteger userCount = [[self appDelegate] chatSessionPeopleCount:sessionKey];
							NSString *uuid = [[self appDelegate] generateUUIDString];
							
							NSString *pkey = [[self appDelegate].myInfoDictionary objectForKey:@"pkey"];
							NSString *transParam = nil;
							
							
							//리드마크 요청 부분.
							NSArray *sendMsgArray = nil;
							NSString *messageKeys = nil;
							//서버 부하 때문에 최대 5개로 제한..
							if (sessionKey && [sessionKey length] > 0) {
								sendMsgArray = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where CHATSESSION=? and ISSENDMSG=? and ISSUCCESS=? and READMARKCOUNT > ? order by REGDATE desc limit 5",self.sessionKey, @"1", @"1", [NSNumber numberWithInt:0], nil]; 
								NSLog(@"session %@", sessionKey);
							}
							
							
							if (sendMsgArray && [sendMsgArray count] > 0) {
								for (MessageInfo *messageInfo in sendMsgArray) {
									if (messageKeys == nil) {
										messageKeys = messageInfo.MESSAGEKEY;
									} else {
										messageKeys = [messageKeys stringByAppendingString:@"|"];
										messageKeys = [messageKeys stringByAppendingString:messageInfo.MESSAGEKEY];
									}
								}
								
								NSLog(@"messagekey = %@ ", messageKeys);
							}
							if ([HttpAgent mc] == nil || [HttpAgent cs] == nil) {
								
								
								#ifdef DEVEL_MODE
								if(messageKeys != nil)
								{
									transParam = [[NSString alloc ] initWithFormat:@"https://social.paran.com/KTH/tm.json?pKey=%@&UCMC=%@&UCCS=%@&o=%@&mt=P&sk=%@&u=%@&t=1&mklp=%@",
															   pkey, [HttpAgent ucmc], [HttpAgent uccs], [[self appDelegate] getSvcIdx], self.sessionKey, uuid, messageKeys];

								}
								else {
									transParam = [[NSString alloc ] initWithFormat:@"https://social.paran.com/KTH/tm.json?pKey=%@&UCMC=%@&UCCS=%@&o=%@&mt=P&sk=%@&u=%@&t=1",
															   pkey, [HttpAgent ucmc], [HttpAgent uccs], [[self appDelegate] getSvcIdx], self.sessionKey, uuid];

								}
								#else
								if(messageKeys != nil)
								{
									transParam = [[NSString alloc ] initWithFormat:@"https://dev.usay.net/KTH/tm.json?pKey=%@&UCMC=%@&UCCS=%@&o=%@&mt=P&sk=%@&u=%@&mklp=%@",
															   pkey, [HttpAgent ucmc], [HttpAgent uccs], [[self appDelegate] getSvcIdx], self.sessionKey, uuid, messageKeys];
									
								}
								else {
									transParam = [[NSString alloc ] initWithFormat:@"https://dev.usay.net/KTH/tm.json?pKey=%@&UCMC=%@&UCCS=%@&o=%@&mt=P&sk=%@&u=%@",
															   pkey, [HttpAgent ucmc], [HttpAgent uccs], [[self appDelegate] getSvcIdx], self.sessionKey, uuid];
									
								}
								#endif
								
								
							} else {
								
								
#ifdef DEVEL_MODE
								if(messageKeys != nil)
								{
									transParam = [[NSString alloc ] initWithFormat:@"https://social.paran.com/KTH/tm.json?pKey=%@&MC=%@&CS=%@&UCMC=%@&UCCS=%@&o=%@&mt=P&sk=%@&u=%@&t=1&mklp=%@",
															   pkey, [HttpAgent ucmc], [HttpAgent uccs], [[self appDelegate] getSvcIdx], self.sessionKey, uuid, messageKeys];
									
								}
								else {
									transParam = [[NSString alloc ] initWithFormat:@"https://social.paran.com/KTH/tm.json?pKey=%@&MC=%@&CS=%@&UCMC=%@&UCCS=%@&o=%@&mt=P&sk=%@&u=%@&t=1",
															   pkey, [HttpAgent ucmc], [HttpAgent uccs], [[self appDelegate] getSvcIdx], self.sessionKey, uuid];
									
								}
#else
								if(messageKeys != nil)
								{
									transParam = [[NSString alloc ] initWithFormat:@"https://dev.usay.net/KTH/tm.json?pKey=%@&MC=%@&CS=%@&UCMC=%@&UCCS=%@&o=%@&mt=P&sk=%@&u=%@&mklp=%@",
															   pkey, [HttpAgent ucmc], [HttpAgent uccs], [[self appDelegate] getSvcIdx], self.sessionKey, uuid, messageKeys];
									
								}
								else {
									transParam = [[NSString alloc ] initWithFormat:@"https://dev.usay.net/KTH/tm.json?pKey=%@&MC=%@&CS=%@&UCMC=%@&UCCS=%@&o=%@&mt=P&sk=%@&u=%@",
															   pkey, [HttpAgent ucmc], [HttpAgent uccs], [[self appDelegate] getSvcIdx], self.sessionKey, uuid];
									
								}
#endif
								/*
#ifdef DEVEL_MODE	// sochae 2010.09.09 - dev server
								transParam = [[NSString alloc ] initWithFormat:@"https://social.paran.com/KTH/tm.json?pKey=%@&MC=%@&CS=%@&UCMC=%@&UCCS=%@&o=%@&mt=P&sk=%@&u=%@&t=1", 
#else
								transParam = [[NSString alloc ] initWithFormat:@"https://dev.usay.net/KTH/tm.json?pKey=%@&MC=%@&CS=%@&UCMC=%@&UCCS=%@&svcidx=%@&mType=P&sessionKey=%@&uuid=%@", 
#endif // #ifdef DEVEL_MODE
											  pkey, [HttpAgent mc], [HttpAgent cs],
											  [HttpAgent ucmc], [HttpAgent uccs], [[self appDelegate] getSvcIdx], self.sessionKey, uuid];
											  
								*/			  
											  
							}
							DebugLog(@"=== KTH : transParam = %@", transParam);
							
							NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
							[bodyObject setObject:@"1" forKey:@"mediaType"];		// 0: video  1: photo
							[bodyObject setObject:uuid forKey:@"uuid"];
							[bodyObject setObject:[NSNull null] forKey:@"uploadFile"];
							[bodyObject setObject:transParam forKey:@"transParam"];
							//
							////////////////////////////////////////////////////////////////////////////////////////
							// 날짜 비교후 날짜 정보 저장
							NSArray *lastRegDateArray = nil;
							if(sessionKey && [sessionKey length] > 0) {
								lastRegDateArray = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where ISSUCCESS=? and CHATSESSION=? order by REGDATE desc limit 1", @"1", sessionKey, nil];
							} else {
							}
							NSNumber *lastRegDateNumber = nil;
							if (lastRegDateArray && [lastRegDateArray count] > 0) {
								for (MessageInfo *messageInfo in lastRegDateArray) {
									lastRegDateNumber = messageInfo.REGDATE;
								}
							} else {
							}
							NSString *noticeDateMsg = [[self appDelegate] compareLastMsgDate:lastRegDateNumber afterMsgUnixTimeStamp:currentTimeNumber];
							if (noticeDateMsg) {
								// 메시지 DB, 메모리에 추가
								/*
								
								NSLog(@"CTTIME3 = %@", currentTimeNumber);
								double newtime = [currentTimeNumber doubleValue] - fmod([currentTimeNumber doubleValue], 86400000);
								NSString *tmpTime = [NSString stringWithFormat:@"%f", newtime];
								NSNumber *currentTimeNumber2 =[NSNumber numberWithLongLong:[tmpTime longLongValue]];
								
								//	currentTimeNumber = [NSNumber numberWithLongLong:[tmpTime longLongValue]];
								NSLog(@"CTTIME4 = %@", currentTimeNumber2);
								
								*/
								
								NSDate *currentDate = [NSDate date];
								NSCalendar *calendar = [NSCalendar currentCalendar];
								NSDateComponents *currentComp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSWeekdayCalendarUnit fromDate:currentDate];
								NSInteger currentYear = [currentComp year];
								NSInteger currentMonth = [currentComp month];
								NSInteger currentDay = [currentComp day];
								NSDate *date;
								NSDateComponents *com;
								com = [[NSDateComponents alloc] init];
								[com setYear:currentYear];
								[com setMonth:currentMonth];
								[com setDay:currentDay];
								[com setHour:00];
								[com setMinute:00];
								[com setSecond:00];
								date = [[NSCalendar currentCalendar] dateFromComponents:com];
								[com release];	// sochae 2011.03.06 - 정적 분석 오류 
								
								//자정시간으로 바꾼다..
								NSNumber *currentTimeNumber2 = [NSNumber numberWithLongLong:[date timeIntervalSince1970]*1000];
								
								
								[MessageInfo findWithSqlWithParameters:
								 @"insert into _TMessageInfo(CHATSESSION, MESSAGEKEY, MSG, MSGTYPE, REGDATE, PKEY, NICKNAME, PHOTOURL, ISSENDMSG, ISSUCCESS, READMARKCOUNT) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", 
								 self.sessionKey, @"", noticeDateMsg, @"D", currentTimeNumber2, @"", @"", @"", @"", @"1", [NSNumber numberWithInt:0], nil];
								
								CellMsgData *newMsgData = [[CellMsgData alloc] init];
								newMsgData.chatsession = self.sessionKey;
								newMsgData.contentsMsg = noticeDateMsg;
								newMsgData.msgType = @"D";
								newMsgData.regTime = currentTimeNumber;
								[newMsgData setIsSend:NO];
								[[self appDelegate].msgArray addObject:newMsgData];
//								[sayMsgArr addObject:newMsgData];
								[newMsgData release];
							}
							////////////////////////////////////////////////////////////////////////////////////////
							
							// 메시지 메모리 추가
							CellMsgData *msgData = [[CellMsgData alloc] init];
							msgData.pKey = pkey;
							// sochae 2010.10.12
							//msgData.nickName = [[NSUserDefaults standardUserDefaults] objectForKey:@"nickName"];
							msgData.nickName = (NSString *)[JYUtil loadFromUserDefaults:kNickname];
							// ~sochae
							msgData.chatsession = self.sessionKey;
							msgData.messagekey = uuid;	// 임시 메시지 키. 
							msgData.isSend = YES;
							msgData.msgType = @"P";
							msgData.readMarkCount = userCount;
							msgData.regTime = currentTimeNumber;
							msgData.mediaImage = [UIImage imageWithData:UIImageJPEGRepresentation([UIImage imageWithContentsOfFile:imagePath], 0.1f)];
							msgData.photoFilePath = [imagePath lastPathComponent];
							msgData.sendMsgSuccess = @"0";	// default
							[[self appDelegate].msgArray addObject:msgData];
//							[sayMsgArr addObject:msgData];
							[msgData release];
							
							// 메시지 DB 추가 (messageKey값에 임시로 uuid 값을 넣어서 처리. 프로그래스 처리 / response 처리시 필요)
							[MessageInfo findWithSqlWithParameters:@"insert into _TMessageInfo(CHATSESSION, MESSAGEKEY, MSG, MSGTYPE, REGDATE, PKEY, NICKNAME, PHOTOURL, ISSENDMSG, ISSUCCESS, PHOTOFILEPATH, MOVIEFILEPATH, READMARKCOUNT) "
							 "values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", 
							 self.sessionKey, uuid, @"", @"P", 
							 currentTimeNumber, 				 
							 pkey, 
							 nickName, 
							 @"", 
							 @"1", 
							 @"0", 
							 [imagePath lastPathComponent], 
							 @"",
							 [NSNumber numberWithInt:userCount], 
							 nil];
							/////////////////////////////
							
							//	NSArray *msgListDBArray = nil;
							if (sessionKey && [sessionKey length] > 0) {
								//		msgListDBArray = [RoomInfo findWithSqlWithParameters:@"select * from _TRoomInfo where CHATSESSION=?", sessionKey, nil];
							}
							// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
							USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"albumUpload" andWithDictionary:bodyObject timeout:30] autorelease];
							data.subApi = @"insertMsgMediaPhoto";
							data.filePath = imagePath;	// 서버에 전송시에는 fullPath 인자로.
							data.uniqueId = uuid;
							data.mType = @"P";
							data.sessionKey = self.sessionKey;
							data.messageKey = uuid;
							[transParam release];
							[[NSNotificationCenter defaultCenter] postNotificationName:@"requestUploadUrlMultipartForm" object:data];
						} 
						else if ([msgData.msgType isEqualToString:@"V"]) {
							NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
							NSString *cachesDirectory = [paths objectAtIndex:0];
							NSString *moviePath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", msgData.movieFilePath]];
							
							
							NSLog(@"moviePath = %@", moviePath);
							
							if (![[NSFileManager defaultManager] fileExistsAtPath:moviePath isDirectory:NO]) {
								// not exist file
								NSLog(@"moviePath not exist file");
								return;
							}
							
							////////////////////////////////////////////////////////////////////////////////////////
							// 이전 데이터 삭제
							NSArray *checkDBMessageInfo = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where MESSAGEKEY=?", msgData.messagekey, nil];
							if (checkDBMessageInfo && [checkDBMessageInfo count] > 0) {
								[MessageInfo findWithSqlWithParameters:@"delete from _TMessageInfo where MESSAGEKEY=?", msgData.messagekey, nil];
							}

							[[self appDelegate].msgArray removeObjectAtIndex:reSendCellRow+nViewStart];
							[sayMsgArr removeObjectAtIndex:reSendCellRow];
							////////////////////////////////////////////////////////////////////////////////////////
							
							NSNumber *currentTimeNumber = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]*1000];	// 13자리로 변경
							// sochae 2010.10.12
							//NSString *nickName = [[NSUserDefaults standardUserDefaults] objectForKey:@"nickName"];
							NSString *nickName = (NSString *)[JYUtil loadFromUserDefaults:kNickname];
							// ~sochae
							NSInteger userCount = [[self appDelegate] chatSessionPeopleCount:sessionKey];
							NSString *uuid = [[self appDelegate] generateUUIDString];
							
							NSString *pkey = [[self appDelegate].myInfoDictionary objectForKey:@"pkey"];
							NSString *transParam = nil;
							
							
							
							//리드마크 요청 부분.
							NSArray *sendMsgArray = nil;
							NSString *messageKeys = nil;
							//서버 부하 때문에 최대 5개로 제한..
							if (sessionKey && [sessionKey length] > 0) {
								sendMsgArray = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where CHATSESSION=? and ISSENDMSG=? and ISSUCCESS=? and READMARKCOUNT > ? order by REGDATE desc limit 5",self.sessionKey, @"1", @"1", [NSNumber numberWithInt:0], nil]; 
								NSLog(@"session %@", sessionKey);
							}
							
							
							if (sendMsgArray && [sendMsgArray count] > 0) {
								for (MessageInfo *messageInfo in sendMsgArray) {
									if (messageKeys == nil) {
										messageKeys = messageInfo.MESSAGEKEY;
									} else {
										messageKeys = [messageKeys stringByAppendingString:@"|"];
										messageKeys = [messageKeys stringByAppendingString:messageInfo.MESSAGEKEY];
									}
								}
								
								NSLog(@"messagekey = %@ ", messageKeys);
							}
							
							if ([HttpAgent mc] == nil || [HttpAgent cs] == nil) {
								#ifdef DEVEL_MODE
								if(messageKeys != nil)
								{
									transParam = [[NSString alloc ] initWithFormat:@"https://social.paran.com/KTH/tm.json?pKey=%@&UCMC=%@&UCCS=%@&o=%@&mt=V&sk=%@&u=%@&t=1&mklp=%@",
												  pkey, 
												  [HttpAgent ucmc], [HttpAgent uccs], [[self appDelegate] getSvcIdx], self.sessionKey, uuid, messageKeys];			  
								}
								else {
									transParam = [[NSString alloc ] initWithFormat:@"https://social.paran.com/KTH/tm.json?pKey=%@&UCMC=%@&UCCS=%@&o=%@&mt=V&sk=%@&u=%@&t=1",
												  pkey, 
												  [HttpAgent ucmc], [HttpAgent uccs], [[self appDelegate] getSvcIdx], self.sessionKey, uuid];			  
									
									
									
								}
								#else
								if(messageKeys != nil)
								{
									transParam = [[NSString alloc ] initWithFormat:@"https://dev.usay.net/KTH/tm.json?pKey=%@&UCMC=%@&UCCS=%@&o=%@&mt=V&sk=%@&u=%@&mklp=%@",
												  pkey, 
												  [HttpAgent ucmc], [HttpAgent uccs], [[self appDelegate] getSvcIdx], self.sessionKey, uuid, messageKeys];		  
									
								}
								else {
									transParam = [[NSString alloc ] initWithFormat:@"https://dev.usay.net/KTH/tm.json?pKey=%@&UCMC=%@&UCCS=%@&o=%@&mt=V&sk=%@&u=%@",
												  pkey, 
												  [HttpAgent ucmc], [HttpAgent uccs], [[self appDelegate] getSvcIdx], self.sessionKey, uuid];
									
								}
								#endif


								
								
								
								
								
					/*			
#ifdef DEVEL_MODE	// sochae 2010.09.09 - dev server
								transParam = [[NSString alloc ] initWithFormat:@"https://social.paran.com/KTH/tm.json?pKey=%@&UCMC=%@&UCCS=%@&o=%@&mt=V&sk=%@&u=%@&t=1", 
#else
								transParam = [[NSString alloc ] initWithFormat:@"https://dev.usay.net/KTH/tm.json?pKey=%@&UCMC=%@&UCCS=%@&svcidx=%@&mType=V&sessionKey=%@&uuid=%@", 
#endif // #ifdef DEVEL_MODE
											  pkey, 
											  [HttpAgent ucmc], [HttpAgent uccs], [[self appDelegate] getSvcIdx], self.sessionKey, uuid];
					 
					 */
							} else {
								
								
								
								#ifdef DEVEL_MODE
								if(messageKeys != nil)
								{
									transParam = [[NSString alloc ] initWithFormat:@"https://social.paran.com/KTH/tm.json?pKey=%@&MC=%@&CS=%@&UCMC=%@&UCCS=%@&o=%@&mt=V&sk=%@&u=%@&t=1&mklp=%@",
												  pkey, [HttpAgent mc], [HttpAgent cs],
												  [HttpAgent ucmc], [HttpAgent uccs], [[self appDelegate] getSvcIdx], self.sessionKey, uuid, messageKeys];	  
									
									
								}
								else {
									transParam = [[NSString alloc ] initWithFormat:@"https://social.paran.com/KTH/tm.json?pKey=%@&MC=%@&CS=%@&UCMC=%@&UCCS=%@&o=%@&mt=V&sk=%@&u=%@&t=1",
												  pkey, [HttpAgent mc], [HttpAgent cs],
												  [HttpAgent ucmc], [HttpAgent uccs], [[self appDelegate] getSvcIdx], self.sessionKey, uuid];	
									
								}
								#else
								if(messageKeys != nil)
								{
									transParam = [[NSString alloc ] initWithFormat:@"https://dev.usay.net/KTH/tm.json?pKey=%@&MC=%@&CS=%@&UCMC=%@&UCCS=%@&o=%@&mt=V&sk=%@&u=%@&mklp=%@",
												  pkey, [HttpAgent mc], [HttpAgent cs],
												  [HttpAgent ucmc], [HttpAgent uccs], [[self appDelegate] getSvcIdx], self.sessionKey, uuid, messageKeys];	  
									
									
								}
								else {
									transParam = [[NSString alloc ] initWithFormat:@"https://dev.usay.net/KTH/tm.json?pKey=%@&MC=%@&CS=%@&UCMC=%@&UCCS=%@&o=%@&mt=V&sk=%@&u=%@",
												  pkey, [HttpAgent mc], [HttpAgent cs],
												  [HttpAgent ucmc], [HttpAgent uccs], [[self appDelegate] getSvcIdx], self.sessionKey, uuid];	
									
								}
								
								#endif

								
								
								/*
#ifdef DEVEL_MODE	// sochae 2010.09.09 - dev server
								transParam = [[NSString alloc ] initWithFormat:@"https://social.paran.com/KTH/tm.json?pKey=%@&MC=%@&CS=%@&UCMC=%@&UCCS=%@&o=%@&mt=V&sk=%@&u=%@&t=1", 
#else
								transParam = [[NSString alloc ] initWithFormat:@"https://dev.usay.net/KTH/tm.json?pKey=%@&MC=%@&CS=%@&UCMC=%@&UCCS=%@&svcidx=%@&mType=V&sessionKey=%@&uuid=%@", 
#endif // #ifdef DEVEL_MODE
											  pkey, [HttpAgent mc], [HttpAgent cs],
											  [HttpAgent ucmc], [HttpAgent uccs], [[self appDelegate] getSvcIdx], self.sessionKey, uuid];
								 
								 */
							}
							DebugLog(@"=== KTH : transParam = %@", transParam);
							
							NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
							[bodyObject setObject:@"0" forKey:@"mediaType"];		// 0: video  1: photo
							[bodyObject setObject:uuid forKey:@"uuid"];
							[bodyObject setObject:[NSNull null] forKey:@"uploadFile"];
							[bodyObject setObject:transParam forKey:@"transParam"];
							
							////////////////////////////////////////////////////////////////////////////////////////
							// 날짜 비교후 날짜 정보 저장
							NSArray *lastRegDateArray = nil;
							if(sessionKey && [sessionKey length] > 0) {
								lastRegDateArray = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where ISSUCCESS=? and CHATSESSION=? order by REGDATE desc limit 1", @"1", sessionKey, nil];
							} else {
							}
							NSNumber *lastRegDateNumber = nil;
							if (lastRegDateArray && [lastRegDateArray count] > 0) {
								for (MessageInfo *messageInfo in lastRegDateArray) {
									lastRegDateNumber = messageInfo.REGDATE;
								}
							} else {
							}
							NSString *noticeDateMsg = [[self appDelegate] compareLastMsgDate:lastRegDateNumber afterMsgUnixTimeStamp:currentTimeNumber];
							if (noticeDateMsg) {
								// 메시지 DB, 메모리에 추가
								
								
								/*
								NSLog(@"CTTIME3 = %@", currentTimeNumber);
								double newtime = [currentTimeNumber doubleValue] - fmod([currentTimeNumber doubleValue], 86400000);
								NSString *tmpTime = [NSString stringWithFormat:@"%f", newtime];
								NSNumber *currentTimeNumber2 =[NSNumber numberWithLongLong:[tmpTime longLongValue]];
								
								//	currentTimeNumber = [NSNumber numberWithLongLong:[tmpTime longLongValue]];
								NSLog(@"CTTIME4 = %@", currentTimeNumber2);	
								
								*/
								NSDate *currentDate = [NSDate date];
								NSCalendar *calendar = [NSCalendar currentCalendar];
								NSDateComponents *currentComp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSWeekdayCalendarUnit fromDate:currentDate];
								NSInteger currentYear = [currentComp year];
								NSInteger currentMonth = [currentComp month];
								NSInteger currentDay = [currentComp day];
								NSDate *date;
								NSDateComponents *com;
								com = [[NSDateComponents alloc] init];
								[com setYear:currentYear];
								[com setMonth:currentMonth];
								[com setDay:currentDay];
								[com setHour:00];
								[com setMinute:00];
								[com setSecond:00];
								date = [[NSCalendar currentCalendar] dateFromComponents:com];
								[com release];	// sochae 2011.03.06 - 정적 분석 오류 
								
								//자정시간으로 바꾼다..
								NSNumber *currentTimeNumber2 = [NSNumber numberWithLongLong:[date timeIntervalSince1970]*1000];
								
								
								[MessageInfo findWithSqlWithParameters:
								 @"insert into _TMessageInfo(CHATSESSION, MESSAGEKEY, MSG, MSGTYPE, REGDATE, PKEY, NICKNAME, PHOTOURL, ISSENDMSG, ISSUCCESS, READMARKCOUNT) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", 
								 self.sessionKey, @"", noticeDateMsg, @"D", currentTimeNumber2, @"", @"", @"", @"", @"1", [NSNumber numberWithInt:0], nil];
								
								CellMsgData *newMsgData = [[CellMsgData alloc] init];
								newMsgData.chatsession = self.sessionKey;
								newMsgData.contentsMsg = noticeDateMsg;
								newMsgData.msgType = @"D";
								newMsgData.regTime = currentTimeNumber;
								[newMsgData setIsSend:NO];
								[[self appDelegate].msgArray addObject:newMsgData];
//								[sayMsgArr addObject:newMsgData];
								[newMsgData release];
							}
							////////////////////////////////////////////////////////////////////////////////////////
							
							// 메시지 메모리 추가
							CellMsgData *msgData = [[CellMsgData alloc] init];
							//							assert(msgData != nil);
							msgData.pKey = pkey;
							// sochae 2010.10.12
							//msgData.nickName = [[NSUserDefaults standardUserDefaults] objectForKey:@"nickName"];
							msgData.nickName = (NSString *)[JYUtil loadFromUserDefaults:kNickname];
							// ~sochae
							msgData.chatsession = self.sessionKey;
							msgData.messagekey = uuid;	// 임시 메시지 키. 
							msgData.isSend = YES;
							msgData.msgType = @"V";
							msgData.readMarkCount = userCount;
							msgData.regTime = currentTimeNumber;
							msgData.movieFilePath = [moviePath lastPathComponent];
							msgData.sendMsgSuccess = @"0";	// default
							[[self appDelegate].msgArray addObject:msgData];
//							[sayMsgArr addObject:msgData];
							[msgData release];
							
							// 메시지 DB 추가 (messageKey값에 임시로 uuid 값을 넣어서 처리. 프로그래스 처리 / response 처리시 필요)
							[MessageInfo findWithSqlWithParameters:@"insert into _TMessageInfo(CHATSESSION, MESSAGEKEY, MSG, MSGTYPE, REGDATE, PKEY, NICKNAME, PHOTOURL, ISSENDMSG, ISSUCCESS, PHOTOFILEPATH, MOVIEFILEPATH, READMARKCOUNT) "
							 "values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", 
							 self.sessionKey, uuid, @"", @"V", 
							 currentTimeNumber, 				 
							 pkey, 
							 nickName, 
							 @"", 
							 @"1", 
							 @"0", 
							 [moviePath lastPathComponent], 
							 @"",
							 [NSNumber numberWithInt:userCount], 
							 nil];
							/////////////////////////////
							
							//mezzo	NSArray *msgListDBArray = nil;
							if (sessionKey && [sessionKey length] > 0) {
								//		msgListDBArray = [RoomInfo findWithSqlWithParameters:@"select * from _TRoomInfo where CHATSESSION=?", sessionKey, nil];
							}
							// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
							USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"albumUpload" andWithDictionary:bodyObject timeout:30] autorelease];
							data.subApi = @"insertMsgMediaPhoto";
							data.filePath = moviePath;	// 서버에 전송시에는 fullPath 인자로.
							data.uniqueId = uuid;
							data.mType = @"V";
							data.sessionKey = self.sessionKey;
							data.messageKey = uuid;
							[transParam release];
							[[NSNotificationCenter defaultCenter] postNotificationName:@"requestUploadUrlMultipartForm" object:data];
						} else {
							// skip
						}
					}
				} else if (buttonIndex == 1) {	// 삭제
//					@synchronized([self appDelegate].msgArray) {
					@synchronized(sayMsgArr) {
//						CellMsgData *msgData = [[self appDelegate].msgArray objectAtIndex:reSendCellRow];
						CellMsgData *msgData = [sayMsgArr objectAtIndex:reSendCellRow];
						NSArray *checkDBMessageInfo = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where MESSAGEKEY=?", msgData.messagekey, nil];
						if (checkDBMessageInfo && [checkDBMessageInfo count] > 0) {
							[MessageInfo findWithSqlWithParameters:@"delete from _TMessageInfo where MESSAGEKEY=?", msgData.messagekey, nil];
						}
						[[self appDelegate].msgArray removeObjectAtIndex:reSendCellRow+nViewStart];	
						[sayMsgArr removeObjectAtIndex:reSendCellRow];
						[self.sayTableView reloadData];
					}
				} else if (buttonIndex == 2) {	// cancel
					
				} else {
					// skip
				}
			}
			reSendCellRow = -1;
		}
		
		//[actionSheet release];
				
		// 110125 analyze									  
		if (menu != nil) {
			menu = nil;
		}
	}
	
}

-(UIImage*)resizeImage:(UIImage*)image scaleFlag:(BOOL)aFlag
{
	//	CGFloat resizeCX = 0.0f, resizeCY = 0.0f;
	UIImage *originImage = [image retain];
    CGImageRef imgRef = originImage.CGImage;
	
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
	
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
	
    if (aFlag) {
		if (width > kMaxResolution || height > kMaxResolution) {
			CGFloat ratio = width / height;
			if (ratio > 1) {
				bounds.size.width = kMaxResolution;
				bounds.size.height = bounds.size.width / ratio;
			} else {
				bounds.size.width = bounds.size.height * ratio;
				bounds.size.height = kMaxResolution;
			}
		} else {
		}
    }
	
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
	
    switch (orient) {
        case UIImageOrientationUp: 
            transform = CGAffineTransformIdentity;
            break;
			
        case UIImageOrientationUpMirrored:
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
			
        case UIImageOrientationDown: 
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
			
        case UIImageOrientationDownMirrored: 
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
			
        case UIImageOrientationLeftMirrored: 
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
			
        case UIImageOrientationLeft: 
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
			
        case UIImageOrientationRightMirrored: 
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
			
        case UIImageOrientationRight: 
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
			
        default:
            [NSException raise:NSInternalInconsistencyException format:@"SayViewController Invalid image orientation"];
    }
	
    UIGraphicsBeginImageContext(bounds.size);
	
    CGContextRef context = UIGraphicsGetCurrentContext();
	
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    } else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
	
    CGContextConcatCTM(context, transform);
	
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
	[originImage release];
	
    return imageCopy;
}

-(UIImage*)thumbNailImage:(UIImage*)image Size:(CGFloat)resizeSize
{
	UIImage *originImage = [image retain];
	UIGraphicsBeginImageContext(CGSizeMake(resizeSize, resizeSize));
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, 0.0, resizeSize);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	CGContextDrawImage(context, CGRectMake(0.0, 0.0, resizeSize, resizeSize), [originImage CGImage]);
	UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	[originImage release];
	
	return scaledImage;
}


#pragma mark -
#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[picker dismissModalViewControllerAnimated:YES];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	if([sourceMovie count] > 0)
		[sourceMovie removeAllObjects];
	
	[sourceMovie setDictionary:info];
	
	
//	NSLog(@"sourceMovie = %@", [sourceMovie allKeys]);
	
	
//	NSLog(@"sourceMovie = %@", [sourceMovie objectForKey:UIImagePickerControllerMediaURL]);
	
	
	
	[self dismissModalViewControllerAnimated:TRUE];
	NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
	if ([mediaType isEqualToString:@"public.image"]) {			// 사진
		UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
		if (image) {
			
	//		NSLog(@"=======Image Size %d========", [image ]);
		

			UIImage *resizeImage = [self resizeImage:image scaleFlag:YES];
			if (!resizeImage) {
				[picker dismissModalViewControllerAnimated:TRUE];
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"이미지파일 오류" message:@"잘못된 이미지 파일입니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
				[alertView show];
				[alertView release];
				return;
			}
			NSData *imageData = nil;
			CGImageRef imgRef = image.CGImage;
			CGFloat width = CGImageGetWidth(imgRef);
			CGFloat height = CGImageGetHeight(imgRef);
			if (width > kMaxResolution || height > kMaxResolution) {
				imageData = UIImageJPEGRepresentation(resizeImage, 0.9f);
			} else {
				imageData = UIImageJPEGRepresentation(resizeImage, 1.0f);
			}
			if (!imageData) {
				[picker dismissModalViewControllerAnimated:TRUE];
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"이미지파일 오류" message:@"잘못된 이미지 파일입니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
				[alertView show];
				[alertView release];
				return;
			}
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
			NSString *cachesDirectory = [paths objectAtIndex:0];
			NSString *imagePath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", [[self appDelegate] generateUUIDString]]];
			if (!imagePath) {
				[picker dismissModalViewControllerAnimated:TRUE];
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"이미지파일 오류" message:@"잘못된 이미지 파일입니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
				[alertView show];
				[alertView release];
				return;
			}
			if (![imageData writeToFile:imagePath atomically:YES]) {
				[picker dismissModalViewControllerAnimated:TRUE];
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"이미지파일 오류" message:@"잘못된 이미지 파일입니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
				[alertView show];
				[alertView release];
				return;
			}
			
			if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath isDirectory:NO]) {
				// not exist file
				[picker dismissModalViewControllerAnimated:YES];
				[picker dismissModalViewControllerAnimated:TRUE];
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"이미지파일 오류" message:@"잘못된 이미지 파일입니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
				[alertView show];
				[alertView release];
				return;
			}
			
			NSString *uuid = [[self appDelegate] generateUUIDString];
			if (!uuid) {
				[picker dismissModalViewControllerAnimated:TRUE];
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"이미지파일 오류" message:@"잘못된 이미지 파일입니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
				[alertView show];
				[alertView release];
				return;
			}
			NSString *pkey = [[self appDelegate].myInfoDictionary objectForKey:@"pkey"];
			NSString *transParam = nil;
			
			
			
			//리드마크 요청 부분.
			NSArray *sendMsgArray = nil;
			NSString *messageKeys = nil;
			//서버 부하 때문에 최대 5개로 제한..
			if (sessionKey && [sessionKey length] > 0) {
				sendMsgArray = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where CHATSESSION=? and ISSENDMSG=? and ISSUCCESS=? and READMARKCOUNT > ? order by REGDATE desc limit 5",self.sessionKey, @"1", @"1", [NSNumber numberWithInt:0], nil]; 
				NSLog(@"session %@", sessionKey);
			}
			
			
			if (sendMsgArray && [sendMsgArray count] > 0) {
				for (MessageInfo *messageInfo in sendMsgArray) {
					if (messageKeys == nil) {
						messageKeys = messageInfo.MESSAGEKEY;
					} else {
						messageKeys = [messageKeys stringByAppendingString:@"|"];
						messageKeys = [messageKeys stringByAppendingString:messageInfo.MESSAGEKEY];
					}
				}
				
				NSLog(@"messagekey = %@ ", messageKeys);
			}
			
			
			
			if ([HttpAgent mc] == nil || [HttpAgent cs] == nil) {
				
				if(messageKeys != nil)
				{
#ifdef DEVEL_MODE	// sochae 2010.09.09 - dev server
					transParam = [[NSString alloc ] initWithFormat:@"https://social.paran.com/KTH/tm.json?pKey=%@&UCMC=%@&UCCS=%@&o=%@&mt=P&sk=%@&u=%@&t=1&mklp=%@", 
#else
								  transParam = [[NSString alloc ] initWithFormat:@"https://dev.usay.net/KTH/tm.json?pKey=%@&UCMC=%@&UCCS=%@&o=%@&mt=P&sk=%@&u=%@&mklp=%@", 
#endif // #ifdef DEVEL_MODE
												pkey, 
												[HttpAgent ucmc], [HttpAgent uccs], [[self appDelegate] getSvcIdx], self.sessionKey, uuid, messageKeys];
								  
					
				}
				else {
#ifdef DEVEL_MODE	// sochae 2010.09.09 - dev server
					transParam = [[NSString alloc ] initWithFormat:@"https://social.paran.com/KTH/tm.json?pKey=%@&UCMC=%@&UCCS=%@&o=%@&mt=P&sk=%@&u=%@&t=1", 
#else
								  transParam = [[NSString alloc ] initWithFormat:@"https://dev.usay.net/KTH/tm.json?pKey=%@&UCMC=%@&UCCS=%@&o=%@&mt=P&sk=%@&u=%@", 
#endif // #ifdef DEVEL_MODE
												pkey, 
												[HttpAgent ucmc], [HttpAgent uccs], [[self appDelegate] getSvcIdx], self.sessionKey, uuid];
								  
					
				}

				/*
#ifdef DEVEL_MODE	// sochae 2010.09.09 - dev server
				transParam = [[NSString alloc ] initWithFormat:@"https://social.paran.com/KTH/tm.json?pKey=%@&UCMC=%@&UCCS=%@&o=%@&mt=P&sk=%@&u=%@&t=1", 
#else
				transParam = [[NSString alloc ] initWithFormat:@"https://dev.usay.net/KTH/tm.json?pKey=%@&UCMC=%@&UCCS=%@&svcidx=%@&mType=P&sessionKey=%@&uuid=%@", 
#endif // #ifdef DEVEL_MODE
							  pkey, 
							  [HttpAgent ucmc], [HttpAgent uccs], [[self appDelegate] getSvcIdx], self.sessionKey, uuid];
				 */
			}
				else {
					
					if(messageKeys != nil)
					{
#ifdef DEVEL_MODE	// sochae 2010.09.09 - dev server
						transParam = [[NSString alloc ] initWithFormat:@"https://social.paran.com/KTH/tm.json?pKey=%@&MC=%@&CS=%@&UCMC=%@&UCCS=%@&o=%@&mt=P&sk=%@&u=%@&t=1&mklp=%@", 
#else
									  transParam = [[NSString alloc ] initWithFormat:@"https://dev.usay.net/KTH/tm.json?pKey=%@&MC=%@&CS=%@&UCMC=%@&UCCS=%@&o=%@&mt=P&sk=%@&u=%@&mklp=%@", 
#endif // #ifdef DEVEL_MODE
													pkey, [HttpAgent mc], [HttpAgent cs],
													[HttpAgent ucmc], [HttpAgent uccs], [[self appDelegate] getSvcIdx], self.sessionKey, uuid, messageKeys];
						
					}
					else {
						
#ifdef DEVEL_MODE	// sochae 2010.09.09 - dev server
						transParam = [[NSString alloc ] initWithFormat:@"https://social.paran.com/KTH/tm.json?pKey=%@&MC=%@&CS=%@&UCMC=%@&UCCS=%@&o=%@&mt=P&sk=%@&u=%@&t=1", 
#else
									  transParam = [[NSString alloc ] initWithFormat:@"https://dev.usay.net/KTH/tm.json?pKey=%@&MC=%@&CS=%@&UCMC=%@&UCCS=%@&o=%@&mt=P&sk=%@&u=%@", 
#endif // #ifdef DEVEL_MODE
													pkey, [HttpAgent mc], [HttpAgent cs],
													[HttpAgent ucmc], [HttpAgent uccs], [[self appDelegate] getSvcIdx], self.sessionKey, uuid];
						
						
					}
					/*
#ifdef DEVEL_MODE	// sochae 2010.09.09 - dev server
				transParam = [[NSString alloc ] initWithFormat:@"https://social.paran.com/KTH/tm.json?pKey=%@&MC=%@&CS=%@&UCMC=%@&UCCS=%@&o=%@&mt=P&sk=%@&u=%@&t=1", 
#else
				transParam = [[NSString alloc ] initWithFormat:@"https://dev.usay.net/KTH/tm.json?pKey=%@&MC=%@&CS=%@&UCMC=%@&UCCS=%@&svcidx=%@&mType=P&sessionKey=%@&uuid=%@", 
#endif // #ifdef DEVEL_MODE
							  pkey, [HttpAgent mc], [HttpAgent cs],
							  [HttpAgent ucmc], [HttpAgent uccs], [[self appDelegate] getSvcIdx], self.sessionKey, uuid];
					 */
			}
				 
				 
				 
			DebugLog(@"=== KTH : transParam = %@", transParam);
			
			NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
			if (!bodyObject) {
				[picker dismissModalViewControllerAnimated:TRUE];
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"이미지파일 오류" message:@"잘못된 이미지 파일입니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
				[alertView show];
				[alertView release];
				return;
			}
			[bodyObject setObject:@"1" forKey:@"mediaType"];		// 0: video  1: photo
			[bodyObject setObject:uuid forKey:@"uuid"];
			[bodyObject setObject:[NSNull null] forKey:@"uploadFile"];
			[bodyObject setObject:transParam forKey:@"transParam"];
			
			// 대화 메모리 추가
			NSNumber *currentTimeNumber = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]*1000];	// 13자리로 변경
			NSInteger userCount = [[self appDelegate] chatSessionPeopleCount:self.sessionKey];
			
			////////////////////////////////////////////////////////////////////////////////////////
			// 날짜 비교후 날짜 정보 저장
			NSArray *lastRegDateArray = nil;
			if(sessionKey && [sessionKey length] > 0) {
				lastRegDateArray = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where ISSUCCESS=? and CHATSESSION=? order by REGDATE desc limit 1", @"1", sessionKey, nil];
			}
			NSNumber *lastRegDate = nil;
			if (lastRegDateArray && [lastRegDateArray count] > 0) {
				for (MessageInfo *messageInfo in lastRegDateArray) {
					lastRegDate = messageInfo.REGDATE;
				}
			}
			NSString *noticeDateMsg = [[self appDelegate] compareLastMsgDate:lastRegDate afterMsgUnixTimeStamp:currentTimeNumber];
			if (noticeDateMsg) {
				// 메시지 DB, 메모리에 추가
				
				/*
				NSLog(@"CTTIME3 = %@", currentTimeNumber);
				double newtime = [currentTimeNumber doubleValue] - fmod([currentTimeNumber doubleValue], 86400000);
				NSString *tmpTime = [NSString stringWithFormat:@"%f", newtime];
				NSNumber *currentTimeNumber2 =[NSNumber numberWithLongLong:[tmpTime longLongValue]];
				
				//	currentTimeNumber = [NSNumber numberWithLongLong:[tmpTime longLongValue]];
				NSLog(@"CTTIME4 = %@", currentTimeNumber2);
				*/
				
				
				NSDate *currentDate = [NSDate date];
				NSCalendar *calendar = [NSCalendar currentCalendar];
				NSDateComponents *currentComp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSWeekdayCalendarUnit fromDate:currentDate];
				NSInteger currentYear = [currentComp year];
				NSInteger currentMonth = [currentComp month];
				NSInteger currentDay = [currentComp day];
				NSDate *date;
				NSDateComponents *com;
				com = [[NSDateComponents alloc] init];
				[com setYear:currentYear];
				[com setMonth:currentMonth];
				[com setDay:currentDay];
				[com setHour:00];
				[com setMinute:00];
				[com setSecond:00];
				date = [[NSCalendar currentCalendar] dateFromComponents:com];
				[com release];	// sochae 2011.03.06 - 정적 분석 오류 
				
				//자정시간으로 바꾼다..
				NSNumber *currentTimeNumber2 = [NSNumber numberWithLongLong:[date timeIntervalSince1970]*1000];
				
				[MessageInfo findWithSqlWithParameters:
				 @"insert into _TMessageInfo(CHATSESSION, MESSAGEKEY, MSG, MSGTYPE, REGDATE, PKEY, NICKNAME, PHOTOURL, ISSENDMSG, ISSUCCESS, READMARKCOUNT, PHOTOFILEPATH) "
				 "values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", 
				 self.sessionKey, [[self appDelegate] generateUUIDString], noticeDateMsg, @"D", currentTimeNumber2, @"", @"", @"", @"", @"1", [NSNumber numberWithInt:0], [imagePath lastPathComponent], nil];
				
				CellMsgData *newMsgData = [[CellMsgData alloc] init];
				newMsgData.chatsession = self.sessionKey;
				newMsgData.contentsMsg = noticeDateMsg;
				newMsgData.msgType = @"D";
				newMsgData.regTime = currentTimeNumber;
				[newMsgData setIsSend:NO];
				[[self appDelegate].msgArray addObject:newMsgData];
//				[sayMsgArr addObject:newMsgData];
				[newMsgData release];
			}
			////////////////////////////////////////////////////////////////////////////////////////
			// 메시지 메모리 추가
			CellMsgData *msgData = [[CellMsgData alloc] init];
			msgData.pKey = pkey;
			// sochae 2010.10.12
			//msgData.nickName = [[NSUserDefaults standardUserDefaults] objectForKey:@"nickName"];
			msgData.nickName = (NSString *)[JYUtil loadFromUserDefaults:kNickname];
			// ~sochae
			msgData.chatsession = self.sessionKey;
			msgData.messagekey = uuid;	// 임시 메시지 키. 
			msgData.isSend = YES;
			msgData.msgType = @"P";
			msgData.readMarkCount = userCount;
			msgData.regTime = currentTimeNumber;
			msgData.mediaImage = [self thumbNailImage:resizeImage Size:64.0f]; // [UIImage imageWithData:imageData];
			msgData.photoFilePath = [imagePath lastPathComponent];
			msgData.sendMsgSuccess = @"0";	// default
			[[self appDelegate].msgArray addObject:msgData];
//			[sayMsgArr addObject:msgData];
			[msgData release];
			
			// 메시지 DB 추가 (messageKey값에 임시로 uuid 값을 넣어서 처리. 프로그래스 처리 / response 처리시 필요)
			[MessageInfo findWithSqlWithParameters:@"insert into _TMessageInfo(CHATSESSION, MESSAGEKEY, MSG, MSGTYPE, REGDATE, PKEY, NICKNAME, PHOTOURL, ISSENDMSG, ISSUCCESS, PHOTOFILEPATH, MOVIEFILEPATH, READMARKCOUNT) "
			 "values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", 
			 self.sessionKey, uuid, @"", @"P", 
			 currentTimeNumber, 				 
			 pkey, 
			 [[NSUserDefaults standardUserDefaults] objectForKey:kNickname], 
			 @"", 
			 @"1", 
			 @"0", 
			 [imagePath lastPathComponent], 
			 @"",
			 [NSNumber numberWithInt:userCount], 
			 nil];
			
			[self.sayTableView reloadData];
			startTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self 
														selector:@selector(scrollsToBottom:)
														userInfo:nil repeats:NO];
			// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
			USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"albumUpload" andWithDictionary:bodyObject timeout:30] autorelease];
			data.subApi = @"insertMsgMediaPhoto";
			data.filePath = imagePath;	// 서버에 전송시에는 fullPath 인자로.
			data.uniqueId = uuid;
			data.mType = @"P";
			data.sessionKey = self.sessionKey;
			data.messageKey = uuid;
			[transParam release];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"requestUploadUrlMultipartForm" object:data];
		} else {
			if (photoLibraryShown == YES) {
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"이미지파일 오류" message:@"잘못된 이미지 파일입니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
				[alertView show];
				[alertView release];
			}
		}
	} else if ([mediaType isEqualToString:@"public.movie"]) {	// 직접 찍은 동영상 MOV 확장자로 생성
		NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
		if (videoURL) {
			NSString *moviePath = [videoURL path];
			
			NSLog(@"moviePath = %@", [videoURL path]);
			
			if (![[NSFileManager defaultManager] fileExistsAtPath:moviePath isDirectory:NO]) {
				// not exist file
				[picker dismissModalViewControllerAnimated:YES];
				return;
			}
			NSString *uuid = [[self appDelegate] generateUUIDString];
			
			NSString *pkey = [[self appDelegate].myInfoDictionary objectForKey:@"pkey"];
			
			NSString *transParam = nil;
			
			
			//리드마크 요청 부분.
			NSArray *sendMsgArray = nil;
			NSString *messageKeys = nil;
			//서버 부하 때문에 최대 5개로 제한..
			if (sessionKey && [sessionKey length] > 0) {
				sendMsgArray = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where CHATSESSION=? and ISSENDMSG=? and ISSUCCESS=? and READMARKCOUNT > ? order by REGDATE desc limit 5",self.sessionKey, @"1", @"1", [NSNumber numberWithInt:0], nil]; 
				NSLog(@"session %@", sessionKey);
			}
			
			
			if (sendMsgArray && [sendMsgArray count] > 0) {
				for (MessageInfo *messageInfo in sendMsgArray) {
					if (messageKeys == nil) {
						messageKeys = messageInfo.MESSAGEKEY;
					} else {
						messageKeys = [messageKeys stringByAppendingString:@"|"];
						messageKeys = [messageKeys stringByAppendingString:messageInfo.MESSAGEKEY];
					}
				}
				
				NSLog(@"messagekey = %@ ", messageKeys);
			}
			
			
			if ([HttpAgent mc] == nil || [HttpAgent cs] == nil) {
				
				if(messageKeys != nil)
				{
#ifdef DEVEL_MODE	// sochae 2010.09.09 - dev server
					transParam = [[NSString alloc ] initWithFormat:@"https://social.paran.com/KTH/tm.json?pKey=%@&UCMC=%@&UCCS=%@&o=%@&mt=V&sk=%@&u=%@&t=1&mklp=%@", 
#else
								  transParam = [[NSString alloc ] initWithFormat:@"https://dev.usay.net/KTH/tm.json?pKey=%@&UCMC=%@&UCCS=%@&o=%@&mt=V&sk=%@&u=%@&mklp=%@", 
#endif // #ifdef DEVEL_MODE
												pkey,
												[HttpAgent ucmc], [HttpAgent uccs], [[self appDelegate] getSvcIdx], self.sessionKey, uuid, messageKeys];
					
				}
				else {
					
#ifdef DEVEL_MODE	// sochae 2010.09.09 - dev server
					transParam = [[NSString alloc ] initWithFormat:@"https://social.paran.com/KTH/tm.json?pKey=%@&UCMC=%@&UCCS=%@&o=%@&mt=V&sk=%@&u=%@&t=1", 
#else
								  transParam = [[NSString alloc ] initWithFormat:@"https://dev.usay.net/KTH/tm.json?pKey=%@&UCMC=%@&UCCS=%@&o=%@&mt=V&sk=%@&u=%@", 
#endif // #ifdef DEVEL_MODE
												pkey,
												[HttpAgent ucmc], [HttpAgent uccs], [[self appDelegate] getSvcIdx], self.sessionKey, uuid];
					
				}

				
				/*
#ifdef DEVEL_MODE	// sochae 2010.09.09 - dev server
				transParam = [[NSString alloc ] initWithFormat:@"https://social.paran.com/KTH/tm.json?pKey=%@&UCMC=%@&UCCS=%@&o=%@&mt=V&sk=%@&u=%@&t=1", 
#else
				transParam = [[NSString alloc ] initWithFormat:@"https://dev.usay.net/KTH/tm.json?pKey=%@&UCMC=%@&UCCS=%@&svcidx=%@&mType=V&sessionKey=%@&uuid=%@", 
#endif // #ifdef DEVEL_MODE
							  pkey,
							  [HttpAgent ucmc], [HttpAgent uccs], [[self appDelegate] getSvcIdx], self.sessionKey, uuid];
				 */
				
			} else {
				
				
				if(messageKeys != nil)
				{
#ifdef DEVEL_MODE	// sochae 2010.09.09 - dev server
					transParam = [[NSString alloc ] initWithFormat:@"https://social.paran.com/KTH/tm.json?pKey=%@&MC=%@&CS=%@&UCMC=%@&UCCS=%@&o=%@&mt=V&sk=%@&u=%@&t=1&mklp=%@", 
#else
								  transParam = [[NSString alloc ] initWithFormat:@"https://dev.usay.net/KTH/tm.json?pKey=%@&MC=%@&CS=%@&UCMC=%@&UCCS=%@&o=%@&mt=V&sk=%@&u=%@&mklp=%@", 
#endif // #ifdef DEVEL_MODE
												pkey, [HttpAgent mc], [HttpAgent cs],
												[HttpAgent ucmc], [HttpAgent uccs], [[self appDelegate] getSvcIdx], self.sessionKey, uuid, messageKeys];
					
				}
				else {
#ifdef DEVEL_MODE	// sochae 2010.09.09 - dev server
					transParam = [[NSString alloc ] initWithFormat:@"https://social.paran.com/KTH/tm.json?pKey=%@&MC=%@&CS=%@&UCMC=%@&UCCS=%@&o=%@&mt=V&sk=%@&u=%@&t=1", 
#else
								  transParam = [[NSString alloc ] initWithFormat:@"https://dev.usay.net/KTH/tm.json?pKey=%@&MC=%@&CS=%@&UCMC=%@&UCCS=%@&o=%@&mt=V&sk=%@&u=%@", 
#endif // #ifdef DEVEL_MODE
												pkey, [HttpAgent mc], [HttpAgent cs],
												[HttpAgent ucmc], [HttpAgent uccs], [[self appDelegate] getSvcIdx], self.sessionKey, uuid];
					
				}


				
				/*
#ifdef DEVEL_MODE	// sochae 2010.09.09 - dev server
				transParam = [[NSString alloc ] initWithFormat:@"https://social.paran.com/KTH/tm.json?pKey=%@&MC=%@&CS=%@&UCMC=%@&UCCS=%@&o=%@&mt=V&sk=%@&u=%@&t=1", 
#else
				transParam = [[NSString alloc ] initWithFormat:@"https://dev.usay.net/KTH/tm.json?pKey=%@&MC=%@&CS=%@&UCMC=%@&UCCS=%@&svcidx=%@&mType=V&sessionKey=%@&uuid=%@", 
#endif // #ifdef DEVEL_MODE
							  pkey, [HttpAgent mc], [HttpAgent cs],
							  [HttpAgent ucmc], [HttpAgent uccs], [[self appDelegate] getSvcIdx], self.sessionKey, uuid];
				 */
				
				
			}
			DebugLog(@"=== KTH : transParam = %@", transParam);

			NSString *fileExtend = [[moviePath substringFromIndex:[moviePath length]-3] substringToIndex:3];	
			NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
			[bodyObject setObject:@"0" forKey:@"mediaType"];		// 0: video  1: photo
			[bodyObject setObject:uuid forKey:@"uuid"];
			[bodyObject setObject:[NSNull null] forKey:@"uploadFile"];
			[bodyObject setObject:transParam forKey:@"transParam"];
			
			/////////////////////////////
			// 메모리 추가, DB 추가
			// 동영상 임시 폴더에 저장. 실패시 재전송 하기 위해서.  (messageKey값에 임시로 uuid 값을 넣어서 처리. 프로그래스 처리 / response 처리시 필요)
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
			NSString *cachesDirectory = [paths objectAtIndex:0];
			NSString *backupMoviePath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", uuid, fileExtend]];
			NSError *error = nil;
			BOOL successed = [[NSFileManager defaultManager] copyItemAtPath:moviePath toPath:backupMoviePath error:&error];
			if (!successed) {
				NSLog(@"error copyItemAtPath %@", [error localizedDescription]);
			}
			
			// 메모리 추가
			NSNumber *currentTimeNumber = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]*1000];
			NSInteger userCount = [[self appDelegate] chatSessionPeopleCount:self.sessionKey];
			
			////////////////////////////////////////////////////////////////////////////////////////
			// 날짜 비교후 날짜 정보 저장
			NSArray *lastRegDateArray = nil;
			if (sessionKey && [sessionKey length] > 0) {
				lastRegDateArray = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where ISSUCCESS=? and CHATSESSION=? order by REGDATE desc limit 1", @"1", sessionKey, nil];
			}
			
			NSNumber *lastRegDate = nil;
			if (lastRegDateArray && [lastRegDateArray count] > 0) {
				for (MessageInfo *messageInfo in lastRegDateArray) {
					lastRegDate = messageInfo.REGDATE;
				}
			}
			NSString *noticeDateMsg = [[self appDelegate] compareLastMsgDate:lastRegDate afterMsgUnixTimeStamp:currentTimeNumber];
			if (noticeDateMsg) {
				// 대화 DB에 추가
				
				/*
				NSLog(@"CTTIME3 = %@", currentTimeNumber);
				double newtime = [currentTimeNumber doubleValue] - fmod([currentTimeNumber doubleValue], 86400000);
				NSString *tmpTime = [NSString stringWithFormat:@"%f", newtime];
				NSNumber *currentTimeNumber2 =[NSNumber numberWithLongLong:[tmpTime longLongValue]];
				
				//	currentTimeNumber = [NSNumber numberWithLongLong:[tmpTime longLongValue]];
				NSLog(@"CTTIME4 = %@", currentTimeNumber2);
				
				*/
				NSDate *currentDate = [NSDate date];
				NSCalendar *calendar = [NSCalendar currentCalendar];
				NSDateComponents *currentComp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSWeekdayCalendarUnit fromDate:currentDate];
				NSInteger currentYear = [currentComp year];
				NSInteger currentMonth = [currentComp month];
				NSInteger currentDay = [currentComp day];
				NSDate *date;
				NSDateComponents *com;
				com = [[NSDateComponents alloc] init];
				[com setYear:currentYear];
				[com setMonth:currentMonth];
				[com setDay:currentDay];
				[com setHour:00];
				[com setMinute:00];
				[com setSecond:00];
				date = [[NSCalendar currentCalendar] dateFromComponents:com];
				[com release];	// sochae 2011.03.06 - 정적 분석 오류 
				
				//자정시간으로 바꾼다..
				NSNumber *currentTimeNumber2 = [NSNumber numberWithLongLong:[date timeIntervalSince1970]*1000];
				
				[MessageInfo findWithSqlWithParameters:
				 @"insert into _TMessageInfo(CHATSESSION, MESSAGEKEY, MSG, MSGTYPE, REGDATE, PKEY, NICKNAME, PHOTOURL, ISSENDMSG, ISSUCCESS, READMARKCOUNT, MOVIEFILEPATH) "
				 "values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", 
				 self.sessionKey, [[self appDelegate] generateUUIDString], noticeDateMsg, @"D", currentTimeNumber2, @"", @"", @"", @"", @"1", [NSNumber numberWithInt:0], [backupMoviePath lastPathComponent], nil];
				
				CellMsgData *newMsgData = [[CellMsgData alloc] init];
				newMsgData.chatsession = self.sessionKey;
				newMsgData.contentsMsg = noticeDateMsg;
				newMsgData.msgType = @"D";
				newMsgData.regTime = currentTimeNumber;
				[newMsgData setIsSend:NO];
//				@synchronized([self appDelegate].msgArray) {
				@synchronized(sayMsgArr) {
					[[self appDelegate].msgArray addObject:newMsgData];
//					[sayMsgArr addObject:newMsgData];
				}
				[newMsgData release];
			}
			////////////////////////////////////////////////////////////////////////////////////////
			
			// 대화 메모리에 추가
			CellMsgData *msgData = [[CellMsgData alloc] init];
			msgData.pKey = pkey;
			// sochae 2010.10.12
			//msgData.nickName = [[NSUserDefaults standardUserDefaults] objectForKey:@"nickName"];
			msgData.nickName = (NSString *)[JYUtil loadFromUserDefaults:kNickname];
			// ~sochae
			msgData.chatsession = self.sessionKey;
			msgData.messagekey = uuid;	// 임시 메시지 키.
			msgData.isSend = YES;
			msgData.msgType = @"V";
			msgData.readMarkCount = userCount;
			msgData.regTime = currentTimeNumber;
			msgData.movieFilePath = [backupMoviePath lastPathComponent];
			msgData.sendMsgSuccess = @"0";	// default
			msgData.mediaProgressPos = 0.0f;
//			@synchronized([self appDelegate].msgArray) {
			@synchronized(sayMsgArr) {
				[[self appDelegate].msgArray addObject:msgData];
//				[sayMsgArr addObject:msgData];
			}
			[msgData release];
			// DB 추가
							  
							  //kNickName이 널인경우가 있다 이러면 100프로 죽는다.. 2011.02.07 kjh
							  NSString *tmpnickName = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:kNickname]];
							  
							  if(tmpnickName == nil || [tmpnickName length] == 0 || tmpnickName == NULL)
							  {
								  tmpnickName = @"";
							  }
							  if(pkey == nil || pkey == NULL)
							  {
								  pkey=@"";
							  }
							  NSLog(@"tmpNickName = %@ pkey = %@", tmpnickName, pkey);
							  
							  
							  
			[MessageInfo findWithSqlWithParameters:@"insert into _TMessageInfo(CHATSESSION, MESSAGEKEY, MSG, MSGTYPE, REGDATE, PKEY, NICKNAME, PHOTOURL, ISSENDMSG, ISSUCCESS, PHOTOFILEPATH, MOVIEFILEPATH, READMARKCOUNT) "
			 "values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", 
			 self.sessionKey, uuid, @"", @"V", 
			 currentTimeNumber, 				 
			 pkey, 
			 tmpnickName, 
			 @"", 
			 @"1", 
			 @"0", 
			 @"", 
			 [backupMoviePath lastPathComponent],
			 [NSNumber numberWithInt:userCount], 
			 nil];
			/////////////////////////////	
			
			[self.sayTableView reloadData];
			startTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self 
														selector:@selector(scrollsToBottom:) 
														userInfo:nil repeats:NO];
			
			// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
			USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"albumUpload" andWithDictionary:bodyObject timeout:30] autorelease];
			data.subApi = @"insertMsgMediaPhoto";
			data.filePath = moviePath;		// 서버로 전송시에는 fullPath
			data.uniqueId = uuid;
			data.mType = @"V";
			data.sessionKey = self.sessionKey;
			data.messageKey = uuid;
			[transParam release];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"requestUploadUrlMultipartForm" object:data];
		}
	}
	
	[picker dismissModalViewControllerAnimated:YES];
}
	
#pragma mark -


@end