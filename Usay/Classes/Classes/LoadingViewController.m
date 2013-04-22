//
//  LoadingViewController.m
//  USayApp
//
//  Created by Jong-Sung Park on 10. 5. 24..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "LoadingViewController.h"
#import "USayAppAppDelegate.h"
#import "AddressBookData.h"
#import "SQLiteDatabase.h"
#import "UserInfo.h"
#import "GroupInfo.h"
#import "HttpAgent.h"
#import "json.h"
#import "USayHttpData.h"
#import <objc/runtime.h>
#import <unistd.h>
#import <QuartzCore/QuartzCore.h>
#import "USayDefine.h"


#define ID_LOADINGIMAGEVIEW	7771
#define kSyncTitleLabel     7801
#define kSyncSubLabel		7802
#define kSyncTitleLabel2    7803	// sochae 2010.09.08
#define kSyncTitleLabel3    7804	// sochae 2010.09.08
@implementation LoadingViewController
@synthesize		startActIndicator;
@synthesize		startTimer;
@synthesize		loadingImageTimer;
@synthesize		loadingImageCount;
@synthesize		startDBQueue;
@synthesize     endDBQueue;
//@synthesize		isMemoryWarning;
//@synthesize		progressTimer;
//@synthesize		currentPersent;



int a;
-(USayAppAppDelegate *) appDelegate
{
	return [[UIApplication sharedApplication] delegate];
}

- (void)viewDidAppear:(BOOL)animated
{
	DebugLog(@"===== (동기화 페이지) appear =====>");
	[[NSUserDefaults standardUserDefaults] setInteger:4 forKey:@"CertificationStatus"];
    [super viewDidAppear:animated];
	startDBQueue = NO;
	endDBQueue = NO;
	[[UIApplication sharedApplication] setStatusBarHidden:YES];
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	DebugLog(@"===== (동기화 페이지) load =====>");
//	if(isMemoryWarning == YES){
//		isMemoryWarning = NO;
//		[super viewDidLoad];
//		return;
//	}
	
	[super viewDidLoad];
//	isMemoryWarning = NO;
	// sochae 2010.09.10 - UI Position
//	[self.view setFrame:CGRectMake(0, 0, 320, 480)];
	[self.view setFrame:[[UIScreen mainScreen] bounds]];
	// ~sochae
	
	UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loading_bg.png"]];
//	assert(backgroundImageView != nil);
	[self.view addSubview:backgroundImageView];
	[backgroundImageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, 480)];	//self.view.frame.size.height)];
	[backgroundImageView release];
	
	UIImageView *loadimgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loading_1.PNG"]];
//	assert(loadimgImageView != nil);
	[self.view addSubview:loadimgImageView];
	[loadimgImageView setFrame:CGRectMake(140, 382, 26, 4)];
	loadimgImageView.tag = ID_LOADINGIMAGEVIEW;
	[loadimgImageView release];

	syncState = 1;//1단계

	if(syncView != nil)
		[syncView release];
	
	syncView = [[UIView alloc]initWithFrame:CGRectMake(46, 321, 213, 82)];
	syncView.backgroundColor = [UIColor whiteColor];
	
	UILabel* syncTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 20)];
	syncTitleLabel.text = @"주소록 데이터를 동기화 중입니다.";
	syncTitleLabel.textAlignment = UITextAlignmentCenter;
	syncTitleLabel.textColor = [UIColor blackColor];
	syncTitleLabel.font = [UIFont boldSystemFontOfSize:13.0];
	syncTitleLabel.tag = kSyncTitleLabel;
	[syncView addSubview:syncTitleLabel];
	[syncTitleLabel release];
	
	UILabel* syncSubLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, 200, 20)];
	syncSubLabel.text = @"잠시만 기다려 주세요.";
	syncSubLabel.textAlignment = UITextAlignmentCenter;
	syncSubLabel.textColor = [UIColor blackColor];
	syncSubLabel.font = [UIFont boldSystemFontOfSize:13.0];
	syncSubLabel.tag = kSyncSubLabel;
	[syncView addSubview:syncSubLabel];
	[syncSubLabel release];

	// sochae 2010.09.08
	UILabel* syncTitleLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(-10, 90, 240, 20)];
	syncTitleLabel2.text = @"주소록 데이터가 1000개 이상인 경우";
	syncTitleLabel2.textAlignment = UITextAlignmentCenter;
	syncTitleLabel2.textColor = [UIColor blackColor];
	syncTitleLabel2.font = [UIFont boldSystemFontOfSize:13.0];
	syncTitleLabel2.tag = kSyncTitleLabel2;
	syncTitleLabel2.backgroundColor = [UIColor clearColor];
	[syncView addSubview:syncTitleLabel2];
	[syncTitleLabel2 release];

	UILabel* syncTitleLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(-10, 110, 240, 20)];
	syncTitleLabel3.text = @"자동잠금 해제 후 설치를 권장합니다.";
	syncTitleLabel3.textAlignment = UITextAlignmentCenter;
	syncTitleLabel3.textColor = [UIColor blackColor];
	syncTitleLabel3.font = [UIFont boldSystemFontOfSize:13.0];
	syncTitleLabel3.tag = kSyncTitleLabel3;
	syncTitleLabel3.backgroundColor = [UIColor clearColor];
	[syncView addSubview:syncTitleLabel3];
	[syncTitleLabel3 release];
	// ~sochae
	
	if(progressView != nil)
		[progressView release];
	
	progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(30, 60, 140, 20)];
//	assert(progressView != nil);
	[progressView setProgressViewStyle:UIProgressViewStyleDefault];
	[progressView setProgress:0.0f];
	[syncView addSubview:progressView];
	[self.view addSubview:syncView];
//	endDBQueue = NO;
	
	self.loadingImageCount = 1;

	[self requestGetGroups];
	
	
//	self.startTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self 
//													 selector:@selector(startControl:) 
//													 userInfo:nil repeats:NO];
	
	self.loadingImageTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(loadingImageControl:) userInfo:nil repeats:NO]; //REPEART 원래 YES

}
//

//서버에 request 날린 후 getGroups 실행
-(void)requestGetGroups {
	NSString *initCode = @"Y";
	DebugLog(@"========== requestGetGroups ==========>");
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getGroups:) name:@"getGroups" object:nil];
	NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:
								[[self appDelegate] getSvcIdx], @"svcidx",
								initCode, @"initialize",
								nil];
	
	
	
	USayHttpData *data = [[[USayHttpData alloc]initWithRequestData:@"getGroups" andWithDictionary:bodyObject timeout:10]autorelease];	
	//	assert(data != nil);		
	[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
}

-(void)getGroups:(NSNotification *)notification {
	
	
	
	DebugLog(@"==========> getGroups notification ==========");
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
	
	
	
	
	self.startTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self 
													 selector:@selector(startControl:) 
													 userInfo:nil repeats:NO];
	 
	 
}

- (void)viewDidDisappear:(BOOL)animated 
{
    [super viewDidDisappear:animated];
	[[UIApplication sharedApplication] setStatusBarHidden:NO];
	if(self.startTimer != nil){
		[self.startTimer invalidate];
		self.startTimer = nil;
	}
//  [[NSNotificationCenter defaultCenter] removeObserver:self name:@"addListContact" object:nil];
//	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"getContacts" object:nil];
}

-(void) startControl:(NSTimer *)timecall{
	DebugLog(@"========== startControl ==========>");
	//루트 도는걸 막으려고 한듯....
	if(self.startTimer != nil){
		[self.startTimer invalidate];
		self.startTimer = nil;
	}
	
	[startActIndicator startAnimating];
	AddressBookData* addrData = [[[AddressBookData alloc] init] autorelease];
	NSDictionary* contacts = nil;
	
//	NSArray* userData = [UserInfo findAll];
	NSString* lastSyncDateTime = nil;
	[self performSelectorInBackground:@selector(progressControl:) withObject:[NSNumber numberWithFloat:0.0]];
	
	NSMutableArray* sameGroupArray = [[NSMutableArray alloc] init];
	NSAutoreleasePool* varpool = [[NSAutoreleasePool alloc] init];
	
	//테이블에 쿼리 날린다. 음 이부분이 이해가 안간다..
	NSArray* initGroup = [GroupInfo findAll];
	DebugLog(@"initGroup =======================   %d, %@", [initGroup count], [initGroup objectAtIndex:0]);
	
	
	
	NSArray* compareGroup = [GroupInfo findAll];
	
	DebugLog(@"compareGroup =======================   %d, %@", [compareGroup count], [compareGroup objectAtIndex:0]);
	
	for(GroupInfo* locGroup in initGroup){
		for(GroupInfo* compGroup in compareGroup){
			//로컬 그룹이름이랑 서버 그룹이랑 같을 경우
			if([locGroup.GROUPTITLE isEqualToString:compGroup.GROUPTITLE]){
				DebugLog(@"locGroup Title = %@ %d %d", locGroup.GROUPTITLE, [locGroup.ID intValue], [compGroup.ID intValue]);
				//로컬 그룹 아이디가 서버 그룹 아이디보다 클경우 즉 뭔가 추가가 되었을 경우??
				if([locGroup.ID intValue] > [compGroup.ID intValue]){
					locGroup.GROUPTITLE = [NSString stringWithFormat:@"%@ 1", locGroup.GROUPTITLE];
					[locGroup saveData];
					[sameGroupArray addObject:locGroup];
					//로컬 그룹 아이디가 서버 그룹 아이디보다 작을 경우 그룹이 삭제 되었을때??
				}else if([locGroup.ID intValue] < [compGroup.ID intValue]){
					compGroup.GROUPTITLE = [NSString stringWithFormat:@"%@ 1", compGroup.GROUPTITLE];
					[compGroup saveData];
					[sameGroupArray addObject:compGroup];
				}
			}
		}
	}
	[varpool release];
	
	
	lastSyncDateTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastSyncDate"];
	
	
	DebugLog(@"lastSyncDateTime = %@", lastSyncDateTime);
	
	
	
	if(lastSyncDateTime == nil || [lastSyncDateTime length] <= 0)
		lastSyncDateTime = [NSString stringWithFormat:@"%@",[self appDelegate].registSynctime];
	//싱크를 한번이라도 맞췄으면 새로 추가된것들만 읽어온다.
	if(lastSyncDateTime){
		//전체 데이터를 루프 돌면서 싱크 데이터 보다 큰 날짜 들만 가져온다...
		DebugLog(@"lastSyjcDateTime = %@", lastSyncDateTime);
		contacts = [addrData readOEMContactsAlterData];
	}else{
		DebugLog(@"=========> readFullOEMContacts   <=============");
		contacts = [addrData readFullOEMContacts];
		DebugLog(@"=========> readFullOEMContacts end count %i   <=============",[contacts count]);
	}
	
	NSMutableDictionary* dicContacts = [NSMutableDictionary dictionary];
		
	NSArray* localGroup = [GroupInfo findAll]; //쿼리 날린다...
	NSMutableArray* groupArray  = [NSMutableArray arrayWithArray:[contacts objectForKey:@"GROUP"] ]; //단말에서 가져온 데이터에서 그룹을 찾는다.
	
	for(GroupInfo* oemGroup in [contacts objectForKey:@"GROUP"]){//oem 그룹
		for(GroupInfo* dbGroup in localGroup){ //sqllite DB
			if([dbGroup.GROUPTITLE	isEqualToString:oemGroup.GROUPTITLE]){ //디비랑 새로 추가된 OEM이 같을경우  없어야지 정상일꺼 같다..
				//그룹을 뺀다.
				if(dbGroup.RECORDID == nil && [dbGroup.RECORDID length] == 0){
					dbGroup.RECORDID = [NSString stringWithFormat:@"%@", oemGroup.RECORDID];
					NSString* sql = [NSString stringWithFormat:@"UPDATE %@ SET RECORDID = ? WHERE GROUPTITLE=?",[GroupInfo tableName]];
				//	NSLog(@"SQL = %@, %@, %@", sql, oemGroup.RECORDID, dbGroup.GROUPTITLE);
					[GroupInfo findWithSqlWithParameters:sql, oemGroup.RECORDID, dbGroup.GROUPTITLE,nil];
				}
				//기존 디비에 존재하면  업데이트 하면서 삭제한다.
				[groupArray removeObject:oemGroup];
			}
		}
	}
	NSArray* reLocalGroup = [GroupInfo findAll]; //로컬디비에서 전체 데이터 긁어온다.
	
	NSLog(@"그룹 끝.");
	for(UserInfo* oemUser in [contacts objectForKey:@"PERSON"]){
		
		//NSLog(@"oemUser record = %@", oemUser.RECORDID);
		
		for(GroupInfo* dbGroup in reLocalGroup){
			//사용자가 단말이랑 같은 그룹이라면
			if([dbGroup.RECORDID isEqualToString:oemUser.GID]){
				// 이미 저장된 그룹. 그룹 아이디를 가져온다.
				oemUser.GID = [NSString stringWithFormat:@"%@",dbGroup.ID];
			}
		}
	}
	
	[dicContacts setObject:groupArray forKey:@"GROUP"];
	[dicContacts setObject:[contacts objectForKey:@"PERSON"] forKey:@"PERSON"];
	[dicContacts setObject:sameGroupArray forKey:@"SAMEGROUP"];
	[sameGroupArray release];
//	NSLog(@"LoadingViewController addListContact 호출");
	[self changeDataDictionary:dicContacts];
}

-(void)loadingImageControl:(NSTimer *)timecall
{
	DebugLog(@"==============loading start======================");
	UIImageView *loadimgImageView = (UIImageView *)[self.view viewWithTag:ID_LOADINGIMAGEVIEW];
	
	
		
	if (self.loadingImageCount >= 3) {
		self.loadingImageCount = 1;
	} else {
		self.loadingImageCount += 1;
	}
	
	NSString *fileName = [NSString stringWithFormat:@"loading_%i.PNG", self.loadingImageCount];
	loadimgImageView.image = [UIImage imageNamed:fileName];
	
	DebugLog(@"==============LOADING VIEW======================");

}

//-(void)progressControl:(NSTimer *)timecall
//{
//	[timecall invalidate];
//	self.startTimer = nil;
//	
//	if (currentPersent >= 0.2f && currentPersent <= 1.0f) {
//		[progressView setProgress:currentPersent];
//	}
//}

-(void)progressControl:(NSNumber*)currentPersent
{
	if(syncState == 1){
		UILabel* syncTitle = (UILabel*)[syncView viewWithTag:kSyncTitleLabel];
		syncTitle.text = @"주소록 데이터를 동기화 중입니다.";
		
		// sochae 2010.09.08
		UILabel* syncTitle2 = (UILabel*)[syncView viewWithTag:kSyncTitleLabel2];
		syncTitle2.text = @"주소록 데이터가 1000개 이상인 경우";

		UILabel* syncTitle3 = (UILabel*)[syncView viewWithTag:kSyncTitleLabel3];
		syncTitle3.text = @"자동잠금 해제 후 설치를 권장합니다.";
		// ~sochae

		UILabel* syncSub = (UILabel*)[syncView viewWithTag:kSyncSubLabel];
		syncSub.text = @"잠시만 기다려 주십시오.";		
	}
	
	if(syncState == 2){
		UILabel* syncTitle = (UILabel*)[syncView viewWithTag:kSyncTitleLabel];
		syncTitle.text = @"주소록 데이터를 정렬중입니다.";
		UILabel* syncSub = (UILabel*)[syncView viewWithTag:kSyncSubLabel];
		syncSub.text = @"잠시만 기다려 주십시오.";
	}
		
//	if ([currentPersent floatValue]>= 0.2f && [currentPersent floatValue]<= 1.0f) {
		[progressView setProgress:[currentPersent floatValue]];
//	}
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
//	isMemoryWarning = YES;
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
//	if(isMemoryWarning){
//	}else {
		self.startActIndicator = nil;
		self.loadingImageTimer = nil;
//	}

}


- (void)dealloc {
	[progressView release];
	[syncView release];
	[startActIndicator release];
    [super dealloc];
}

#pragma mark -
#pragma mark notification
-(void)addListContact:(NSNotification *)notification {
	DebugLog(@"==========> addListContact notification ==========");
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
				float currentPosition = (0.8 * nCount /[count intValue]);
			//	DebugLog(@"=====> Progress 1 Pos : %f, count = %i", currentPosition, nCount);
				[self performSelectorInBackground:@selector(progressControl:) withObject:[NSNumber numberWithFloat:currentPosition]];
//				NSLog(@"%i",nCount);
			}
			
			//내려 받은 개수와 리스트를 파싱한 개수가 같을 경우에 저장.
			if([count isEqualToString:[NSString stringWithFormat:@"%i",nCount]]){
				[self performSelectorInBackground:@selector(progressControl:) withObject:[NSNumber numberWithFloat:1.0]];
				[self syncDatabase:userArray withGroupinfo:groupArray saveRevisionPoint:RP];		
			}
		} else {
			// TODO: 예외처리
			//아무 자료 없음. rttype : only
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
//		NSLog(@"rtcode %@",rtcode);
		NSString* errcode = [NSString stringWithFormat:@"(%@)",rtcode];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"동기화 실패" message:errcode delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return;
		
		
	}
	
}

#pragma mark -
#pragma mark NSDictionary convert to SQLiteDataAccess`s NSDictionary
//NSDictionary에 있는 주소록 정보를 데이터 베이스에 넣기 편한 구조의 NSDictionary로 변환
-(BOOL)changeDataDictionary:(NSDictionary *)dicData{
	DebugLog(@"=======> request data parser <===========");
	//사용자 정보 저장
	NSDictionary *rpdict = nil, *contactDic = nil, *contactCnt = nil;
//	NSString	*body = nil;
	NSString	*listbody = nil;
	
	NSMutableArray* contactList = [NSMutableArray array];
	NSArray* compareGroup = [GroupInfo findAll];
	
	oemGroupArray = [[NSMutableArray alloc] initWithCapacity:0];
	NSArray* oemGroupArr = [dicData objectForKey:@"GROUP"];
	NSArray* sameGroupArr = [dicData objectForKey:@"SAMEGROUP"];
	for(GroupInfo *groupData in oemGroupArr){
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
	
	for(GroupInfo* sameGroup in sameGroupArr){
		NSMutableDictionary *group = [[NSMutableDictionary alloc] initWithCapacity:0];
		[group setObject:[sameGroup valueForKey:@"ID"  ] forKey:@"gid"];
		[group setObject:[sameGroup valueForKey:@"GROUPTITLE"] forKey:@"grouptitle"];
		[group setObject:@"mobile" forKey:@"sidupdated"];
		[contactList addObject:group];
		[group release];
	}
	
	
	DebugLog(@"dicData Cnt =%d", [[dicData objectForKey:@"PERSON"] count]);
	
	
	
	
	for(UserInfo *userData in [dicData objectForKey:@"PERSON"]){
		NSMutableDictionary *contact = [[NSMutableDictionary alloc] initWithCapacity:0];
		userData.SIDCREATED = @"mobile";
		NSAutoreleasePool* varpool = [[NSAutoreleasePool alloc] init];
		unsigned int numIvars = 0;
		Ivar* ivars = class_copyIvarList([userData class], &numIvars);
		for(int i = 0; i < numIvars; i++) {
			Ivar thisIvar = ivars[i];
			NSString * key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
			if([userData valueForKey:key] != nil){
				if([key isEqualToString:@"RECORDID"] || [key isEqualToString:@"IMSTATUS"] || 
				   [key isEqualToString:@"IDXNO"] || [key isEqualToString:@"ISBLOCK"])
					continue;
				
				 [contact setObject:[userData valueForKey:key] forKey:[key lowercaseString]];
			}
		}
		if(numIvars > 0)free(ivars);
		[varpool release];
		[contactList addObject:contact];
		[contact release];
	}

//	int currentIndex = 1;
	float currentPosition = (0.2 * 20 /100);
	syncState = 1;
	DebugLog(@"=====> progress pos chaned : %f", currentPosition);
	[self performSelectorInBackground:@selector(progressControl:) withObject:[NSNumber numberWithFloat:currentPosition]];
	// 노티피케이션처리관련 등록..
	//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addListContact:) name:@"addListContact" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addListContact:) name:@"addListContactIncludeGroup" object:nil];
	
//	NSLog(@"=======> request data parser test <===========");
	NSMutableArray* paramArray = [NSMutableArray array];
	
	NSString* revisionPoint = [[NSUserDefaults standardUserDefaults] objectForKey:@"RevisionPoints"];
	if(revisionPoint == nil) revisionPoint = @"0";
	
	NSString* lastSyncDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastSyncDate"];
	
	
	
	DebugLog(@"RP = %@", revisionPoint);
	DebugLog(@"LAST = %@", lastSyncDate);
	
	/*
	if([revisionPoint isEqualToString:@"0"])
	{
		if (lastSyncDate) {
			
			lastSyncDate = @"197001010000";
			NSLog(@"lastSyncDate를 초기화 시켜버리자..... %@", lastSyncDate);
			[[NSUserDefaults standardUserDefaults] setObject:lastSyncDate forKey:@"lastSyncDate"];
			
			NSLog(@"lastsnce AAAA = %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"lastSyncDate"]);
		}
	}
	*/
	
//	NSArray* userArray = [UserInfo findAll];

	
	//싱크가 죽었을경우 로컬디비가 데이터가 있는지 확인해야함..
	//mezzo 여기에서 수정하자
	//20101001
	
	
	rpdict = [NSDictionary dictionaryWithObjectsAndKeys:
			  revisionPoint, @"RP",
			  nil];
	
	NSString* initializeCode = nil;
	
	/* 20101016
	if(revisionPoint == nil || revisionPoint == NULL)
	{
		NSString *Query = [NSString stringWithFormat:@"select * from _TUserInfo order by RPCREATED+0 desc"];
		NSArray *tmpArray =	[UserInfo findWithSql:Query];
		
		for (UserInfo *myUser in tmpArray) {
		
			revisionPoint = myUser.RPCREATED;
			
			break;
		}
		DebugLog(@"MEZZORP = %@", revisionPoint);
		
		
		
	}
	*/
	
	if(lastSyncDate != nil && [lastSyncDate length] > 0  && revisionPoint != nil){
		if([revisionPoint isEqualToString:@"0"])
		{
			initializeCode = [NSString stringWithFormat:@"Y"];	
		}
		else {
			initializeCode = [NSString stringWithFormat:@"N"];	
		}
	}else {
		initializeCode = [NSString stringWithFormat:@"Y"];
	
	}

	
	
	[paramArray addObject:rpdict];
	
	contactCnt = [NSDictionary dictionaryWithObjectsAndKeys:
				  [NSString stringWithFormat:@"%i",[contactList count]], @"count",
				  nil];
	
	[paramArray addObject:contactCnt];
	
	contactDic = [NSDictionary dictionaryWithObjectsAndKeys: 
				 contactList,  @"contact",
				 nil];
	
	[paramArray addObject:contactDic];
	// JSON 라이브러리 생성
	SBJSON *json = [[SBJSON alloc] init];
	[json setHumanReadable:YES];
	// 변환
	listbody = [json stringWithObject:paramArray error:nil];
	
	[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"sendingStatus"];
	
	NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:
								initializeCode, @"initialize",
								[[self appDelegate] getSvcIdx],@"svcidx",
								listbody, @"param",
								nil];
	
	

//	NSLog(@"listBody = %@", listbody);
	
	
	// 변환
	NSString	*body = nil;
	body = [json stringWithObject:bodyObject error:nil];
//	NSLog(@"=======> addListContactIncludeGroup = %@",listbody);
//	NSLog(@"=======> addListContactIncludeGroup = %@",body);
	[json release];
//	USayHttpData *data = [[[USayHttpData alloc]initWithRequestData:@"addListContact" andWithDictionary:bodyObject timeout:10]autorelease];
	USayHttpData *data = [[[USayHttpData alloc]initWithRequestData:@"addListContactIncludeGroup" andWithDictionary:bodyObject timeout:10]autorelease];
//	assert(data != nil);		
	[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
	
	
	
	
	
	
	
	
	
	return YES;
}

#pragma mark -
#pragma mark set database Method

// mezzo 데이터베이스에 저장이 완료되면, RP 라는 전체 동기화 버전 번호를 저장
-(void)operationQueueSyncDatabase:(NSDictionary*)data{
	DebugLog(@"data count = %d",[data count]);
	DebugLog(@"=======> start database insert <===========");
	//[[NSUserDefaults standardUserDefaults] setInteger:-1 forKey:@"CertificationStatus"];
	
	self.startDBQueue = YES;
	syncState = 2;//2단계
	NSArray* userData = [data objectForKey:@"USERDATA"];
	NSArray* groupData = [data objectForKey:@"GROUPDATA"];
	NSString* revisionPoint = [data objectForKey:@"REVISIONPOINT"];
//	[self performSelectorInBackground:@selector(progressControl:) withObject:[NSNumber numberWithFloat:0.0]];
	int progressCnt = [userData count]+[groupData count];
	int currentIndex = 0;
	float currentPosition = (1.0 * currentIndex /progressCnt);
	DebugLog(@"=====> Progress Sync2 Pos : %f", currentPosition);
	[self performSelectorInBackground:@selector(progressControl:) withObject:[NSNumber numberWithFloat:currentPosition]];
	SQLiteDataAccess* trans = [DataAccessObject database];
	[trans beginTransaction];
	
//	NSLog(@"DB insert Start");
//	NSLog(@"UserInfo DB insert usercount = %i", [userData count]);
	if(userData != nil){
		for(UserInfo* userInfo in userData) {
			currentIndex++;
			if([userInfo.ISTRASH isEqualToString:@"N"] ){
				if(userInfo.RPCREATED || userInfo.RPUPDATED ){
					//trimleft 처리 추가 필요
//					NSLog(@"DB insert UserInfo");
					[userInfo saveSyncData];
				//부분 동기화
					
					
						[[NSUserDefaults standardUserDefaults] setObject:userInfo.RPCREATED forKey:@"RevisionPoints"];
#ifdef MEZZO_DEBUG
					//	DebugLog(@"부분동기화 = %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"RevisionPoints"]);
#endif
					[trans commit];
					
					[[NSUserDefaults standardUserDefaults] setInteger:9 forKey:@"CertificationStatus"];
					a++;
					if(a == 2)
					{
					//	exit(1);
					}
					
					
					if([trans hasError])
						break;
				}else if(userInfo.RPDELETED && [userInfo.RPDELETED length] > 0){
		//			NSLog(@"DB delete UserInfo");
					[userInfo deleteData];
				}
			}else if([userInfo.ISTRASH isEqualToString:@"Y"]){
//				NSLog(@"DB delete UserInfo");
				[userInfo deleteData];
			}
			
			currentPosition = 1.0 * currentIndex /progressCnt;
			[self performSelectorInBackground:@selector(progressControl:) withObject:[NSNumber numberWithFloat:currentPosition]];
		}
	}
	
//	NSLog(@"GroupInfo DB insert groupcount = %i", [groupData count]);
	if([trans hasError] == NO){
		if(groupData != nil){
			for(GroupInfo* groupInfo in groupData){
	//			NSLog(@"DB insert GroupInfo");
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
				
				currentPosition = 1.0 * currentIndex /progressCnt;
				[self performSelectorInBackground:@selector(progressControl:) withObject:[NSNumber numberWithFloat:currentPosition]];
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
		
		DebugLog(@"==========> End Database Sync and rp setting <================");
		[self performSelectorInBackground:@selector(progressControl:) withObject:[NSNumber numberWithFloat:1.0]];
		[startActIndicator stopAnimating];
		[[NSUserDefaults standardUserDefaults] setInteger:-1 forKey:@"CertificationStatus"];
		[[UIApplication sharedApplication] setStatusBarHidden:NO];
		[[self appDelegate] goUseGuide];
		self.endDBQueue = YES;
		
	}else {
		[trans rollback];
		[self performSelectorOnMainThread:@selector(retrySyncAddress:) withObject:[NSNumber numberWithBool:[trans hasError]] waitUntilDone:NO];
		
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
	[self performSelectorInBackground:@selector(progressControl:) withObject:[NSNumber numberWithFloat:0.0]];
	NSInvocationOperation* operation = [[NSInvocationOperation alloc] initWithTarget:self 
																			 selector:@selector(operationQueueSyncDatabase:) 
																			   object:threadDBData];
	
	NSOperationQueue* queue = [[NSOperationQueue alloc] init];
	[queue setMaxConcurrentOperationCount:1];
	[queue addOperation:operation];
	[operation release];
	[queue release];
	
	//	currentPersent = 0.2f;
	//	self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(progressControl:) userInfo:nil repeats:YES];
	//	[progressView setProgress:0.2];
	//	NSInteger currentIndex = 0;
	//	CGFloat beforePersent = 0.2f;
	//	currentPersent = 0.9f;
	//	[progressView setProgress:currentPersent];
	//	self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(progressControl:) userInfo:nil repeats:YES];
	/*
	 currentPersent = 0.2f+((CGFloat)(7*currentIndex)/(CGFloat)([userData count]*10));
	 if (beforePersent < 0.3f && currentPersent >= 0.3f && currentPersent < 0.4f) {
	 NSLog(@"30 currentPersent = %f", currentPersent);
	 currentPersent = 0.3f;
	 [progressView setProgress:0.3];
	 //				self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(progressControl:) userInfo:nil repeats:YES];
	 } else if (beforePersent < 0.4f && currentPersent >= 0.4f && currentPersent < 0.5f) {
	 NSLog(@"40 currentPersent = %f", currentPersent);
	 currentPersent = 0.4f;
	 [progressView setProgress:0.4];
	 //				self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(progressControl:) userInfo:nil repeats:YES];
	 } else if (beforePersent < 0.5f && currentPersent >= 0.5f && currentPersent < 0.6f) {
	 NSLog(@"50 currentPersent = %f", currentPersent);
	 currentPersent = 0.5f;
	 [progressView setProgress:0.4];
	 //				self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(progressControl:) userInfo:nil repeats:YES];
	 } else if (beforePersent < 0.6f && currentPersent >= 0.6f && currentPersent < 0.7f) {
	 NSLog(@"60 currentPersent = %f", currentPersent);
	 currentPersent = 0.6f;
	 [progressView setProgress:0.6];
	 //				self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(progressControl:) userInfo:nil repeats:YES];
	 } else if (beforePersent < 0.7f && currentPersent >= 0.7f && currentPersent < 0.8f) {
	 NSLog(@"70 currentPersent = %f", currentPersent);
	 currentPersent = 0.7f;
	 [progressView setProgress:0.7];
	 //				self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(progressControl:) userInfo:nil repeats:YES];
	 } else if (beforePersent < 0.8f && currentPersent >= 0.8f && currentPersent < 0.9f) {
	 NSLog(@"80 currentPersent = %f", currentPersent);
	 currentPersent = 0.8f;
	 [progressView setProgress:0.8];
	 //				self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(progressControl:) userInfo:nil repeats:YES];
	 } else if (beforePersent < 0.9f && currentPersent >= 0.9f && currentPersent < 1.0f) {
	 NSLog(@"90 currentPersent = %f", currentPersent);
	 currentPersent = 0.9f;
	 [progressView setProgress:0.9];
	 //				self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(progressControl:) userInfo:nil repeats:YES];
	 } else {
	 // skip
	 }
	 beforePersent = currentPersent;
	 //*/
	//	currentPersent = 1.0f;
	//	[progressView setProgress:currentPersent];
	//	self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(progressControl:) userInfo:nil repeats:YES];
}


-(void)retrySyncAddress:(NSNumber*)hasError {
	BOOL hasDBError = [hasError boolValue];
	if(hasDBError){
		/**
		 * 동기화 루틴을 다시 탄다. 인증은 된 상태이다.
		 */
		if([self appDelegate].database != nil)
			[[self appDelegate].database release];
		
		[self appDelegate].database	= [[SQLiteDatabase alloc] initWithCreateSQLite];
		[[self appDelegate] dbInitialize];
		self.startTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self 
														 selector:@selector(startControl:) 
														 userInfo:nil repeats:NO];
	}else {
		//skip
	}

}
@end
