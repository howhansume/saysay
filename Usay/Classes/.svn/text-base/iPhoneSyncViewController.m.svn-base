    //
//  iPhoneSyncViewController.m
//  USayApp
//
//  Created by ku jung on 10. 10. 29..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "iPhoneSyncViewController.h"
#import "AddressBookData.h"
#import "AddressBookData.h"
#import "UserInfo.h"
#import "GroupInfo.h"
#import "json.h"
#import "USayAppAppDelegate.h"
#import <objc/runtime.h>
#import <unistd.h>
#import "USayDefine.h"
#import "USayHttpData.h"
#import "SQLiteDatabase.h"
#import <QuartzCore/QuartzCore.h>


#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation iPhoneSyncViewController

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

-(void)saveSyncData
{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	NSLocale *locale = [NSLocale currentLocale];
	[formatter setLocale:locale];
	[formatter setDateFormat:@"yyyyMMddHHmmss"];
	NSDate *today = [NSDate date];
	NSString *lastSyncDate = [[NSString alloc] initWithFormat:@"%@",[formatter stringFromDate:today]];
	[[NSUserDefaults standardUserDefaults] setObject:lastSyncDate forKey:@"lastSyncDate"];
	
	[formatter release];
	[lastSyncDate release];
}


-(USayAppAppDelegate *) appDelegate
{
	return [[UIApplication sharedApplication] delegate];
}

-(void)operationQueueSyncDatabase:(NSDictionary*)data{
	DebugLog(@"data count = %d",[data count]);
	DebugLog(@"=======> start database insert <===========");
	[[NSUserDefaults standardUserDefaults] setInteger:-1 forKey:@"CertificationStatus"];
	
	//self.startDBQueue = YES;
	//	syncState = 2;//2단계
	NSArray* userData = [data objectForKey:@"USERDATA"];
	NSArray* groupData = [data objectForKey:@"GROUPDATA"];
	NSString* revisionPoint = [data objectForKey:@"REVISIONPOINT"];
	//	[self performSelectorInBackground:@selector(progressControl:) withObject:[NSNumber numberWithFloat:0.0]];
	int progressCnt = [userData count]+[groupData count];
	int currentIndex = 0;
	float currentPosition = (1.0 * currentIndex /progressCnt);
	DebugLog(@"=====> Progress Sync2 Pos : %f", currentPosition);
	//	[self performSelectorInBackground:@selector(progressControl:) withObject:[NSNumber numberWithFloat:currentPosition]];
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
		
		DebugLog(@"==========> End Database Sync and rp setting <================");
		//	[self performSelectorInBackground:@selector(progressControl:) withObject:[NSNumber numberWithFloat:1.0]];
		//		[startActIndicator stopAnimating];
		[[UIApplication sharedApplication] setStatusBarHidden:NO];
		//	[[self appDelegate] goUseGuide];
		//		self.endDBQueue = YES;
		/*
		[syncBlockView dismissAlertView];
		[syncBlockView release];
		*/
		
		[waitingView removeFromSuperview];
		[waitingView release];
		waitingView=nil;
		
		[self.navigationController.navigationItem.leftBarButtonItem setEnabled:YES];
		
	}else {
		NSLog(@"Error insert");
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
	DebugLog(@"==========> addListContact notification iphoneSync==========");
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
				[groupData release];
				
				if([userData valueForKey:@"ID"]){
					[userArray addObject:userData];
				}
				[userData release];
				
				nCount++;
				//	DebugLog(@"=====> Progress 1 Pos : %f, count = %i", currentPosition, nCount);
				//	[self performSelectorInBackground:@selector(progressControl:) withObject:[NSNumber numberWithFloat:currentPosition]];
				//				NSLog(@"%i",nCount);
			}
			
			//내려 받은 개수와 리스트를 파싱한 개수가 같을 경우에 저장.
			if([count isEqualToString:[NSString stringWithFormat:@"%i",nCount]]){
				//	[self performSelectorInBackground:@selector(progressControl:) withObject:[NSNumber numberWithFloat:1.0]];
				[self syncDatabase:userArray withGroupinfo:groupArray saveRevisionPoint:RP];
				
				
				NSLog(@"주소록 리로드...");
				[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadAddressData" object:nil];

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







-(void)uploadAction
{
	/*
	
	syncBlockView = [[blockView alloc] initWithFrame:CGRectMake(0.0, 0.0, 250.0, 150.0)];
	syncBlockView.alertText = @"업로드 중...";
	syncBlockView.alertDetailText = @"waiting...";
	[syncBlockView show];
	*/
	
	CFErrorRef error = NULL;
	ABAddressBookRef iPhoneAddressBook = ABAddressBookCreate();
	NSString *fromUsaytoOem = @"select * from _TUserInfo where is BLOCK='N'";
	NSArray *checkDBUserInfo = [UserInfo findWithSql:fromUsaytoOem];
	NSArray *compareGroup = [GroupInfo findAll];
	
	CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(iPhoneAddressBook);
	CFIndex nPeople = ABAddressBookGetPersonCount(iPhoneAddressBook);	
	CFIndex nGroup = ABAddressBookGetGroupCount(iPhoneAddressBook);
	CFArrayRef allGroup = ABAddressBookCopyArrayOfAllGroups(iPhoneAddressBook);
	
	
	//OEM 그룹 삭제
	 for(int i=0; i< nGroup; i++)
	 {
	 //그룹 정보
		 ABRecordRef ref = CFArrayGetValueAtIndex(allGroup, i);
		 CFStringRef groupTitle = ABRecordCopyValue(ref, kABGroupNameProperty);
		 NSString *RecordID = [NSString stringWithFormat:@"%i", ABRecordGetRecordID(ref)];
		 NSLog(@"삭제 그룹명[%@]  레코드 아이디[%@]", (NSString*)groupTitle, RecordID);
		 ABAddressBookRemoveRecord(iPhoneAddressBook, ref, nil);
		 ABAddressBookSave(iPhoneAddressBook, nil);
	 }
	//OEM 주소록 삭제
	 for (int i=0; i< nPeople; i++) {
		 
		 ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i);
		 CFStringRef firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
		 NSString *RecordID = [NSString stringWithFormat:@"%i", ABRecordGetRecordID(ref)];
		 ABAddressBookRemoveRecord(iPhoneAddressBook, ref, nil);
		 NSLog(@"삭제 유저명<%@> 레코드 아이디<%@>",(NSString*)firstName, RecordID);
		 ABAddressBookSave(iPhoneAddressBook, nil);

		 
	 }
	for(GroupInfo *tmpGroup in compareGroup)
	{
		ABRecordRef newGroup = ABGroupCreate();
		ABRecordSetValue (newGroup, kABGroupNameProperty, tmpGroup.GROUPTITLE, &error);
		ABAddressBookAddRecord(iPhoneAddressBook, newGroup, &error);
		ABAddressBookSave(iPhoneAddressBook, &error);
		NSLog(@"단말로 새로운 그룹을 생성. %@", tmpGroup.GROUPTITLE);
	}
	///그룹 동기화 완료...
	DebugLog(@"그룹 동기화가 완료되었다.");
	
	
	
	
	//유세이 로컬디비에 사용자 정보가 있다면..
	if(checkDBUserInfo !=nil)
	{
		
		//단말 그룹 갯수.
		nGroup = ABAddressBookGetGroupCount(iPhoneAddressBook);
		allGroup = ABAddressBookCopyArrayOfAllGroups(iPhoneAddressBook);
		
		
		
		BOOL createGroup;
		createGroup = YES;
		ABRecordRef sameGroupRef;
		NSString *groupString;
		//유세이 로컬 만큼 루프 돌면서
		for (UserInfo *userInfo in checkDBUserInfo) {

			
			//입력 한다.
			ABRecordRef newPerson = ABPersonCreate();
			NSLog(@"로컬 디비의 그룹 갯수=%d", [compareGroup count]);
			NSString *tmpGroupTitle = [NSString stringWithFormat:@"select * from _TGroupInfo where id=%@", userInfo.GID];
			NSArray *groupArray = [GroupInfo findWithSql:tmpGroupTitle];
			GroupInfo* group = nil;
			if([groupArray objectAtIndex:0])
				group = [groupArray objectAtIndex:0];
			groupString = group.GROUPTITLE;
			NSLog(@"그룹타이틀 = %@", groupString);
			//해당 그룹명에서 단말 그룹명을 찾는다.
			for(int i=0; i< nGroup; i++)
			{
				//그룹 정보
				ABRecordRef ref = CFArrayGetValueAtIndex(allGroup, i);
				CFStringRef groupTitle = ABRecordCopyValue(ref, kABGroupNameProperty);
				//단말 그룹이랑 같은 그룹명이 발견되면..
				if([(NSString*)groupTitle isEqualToString:groupString])
				{
					NSLog(@"같은 그룹명 찾았다.");
					sameGroupRef = CFArrayGetValueAtIndex(allGroup, i);
					CFStringRef	 tmpTitle = ABRecordCopyValue(sameGroupRef, kABGroupNameProperty);
					NSLog(@"title = %@", (NSString*)tmpTitle );
					createGroup = NO;
					break;
				}
				else {
					NSLog(@"YESYESYESYES");
					createGroup = YES;
				}
			}
			//유세이 디비에서 포맷티드이름, 닉네임이 있으면 퍼스트네임으로 입력
			if([userInfo.FORMATTED length] >0)
			{
				ABRecordSetValue(newPerson, kABPersonFirstNameProperty, userInfo.FORMATTED, &error);
				if([userInfo.NICKNAME length]>0)
				{
					ABRecordSetValue(newPerson, kABPersonNicknameProperty, userInfo.NICKNAME, &error);
				}
			}
			else if([userInfo.NICKNAME length] >0)
			{
				ABRecordSetValue(newPerson, kABPersonFirstNameProperty, userInfo.NICKNAME, &error);
				ABRecordSetValue(newPerson, kABPersonNicknameProperty, userInfo.NICKNAME, &error);
			}
			//회사 
			if([userInfo.ORGNAME length] >0)
				ABRecordSetValue(newPerson, kABPersonOrganizationProperty, userInfo.ORGNAME, &error);
			if([userInfo.HOMEEMAILADDRESS length] >0)
			{
				//여기에서 왜 죽지??
			//	ABRecordSetValue(newPerson, kABPersonEmailProperty, userInfo.HOMEEMAILADDRESS, &error);
			}
			if([userInfo.NOTE length] >0)
				ABRecordSetValue(newPerson, kABPersonNoteProperty, userInfo.NOTE, &error);
			
			
			
			
			
			//대표이미지 검사.
			UIImage *dataImg = [[UIImage alloc] initWithData:userInfo.USERIMAGE];
			
			if(dataImg)
			{
				NSLog(@"대표 이미지가 존재한다. %@", userInfo.FORMATTED);
			/*
				ABPersonRemoveImageData(newPerson, &error); // <-- clean any image first from ref
				ABAddressBookSave(iPhoneAddressBook, &error);
			*/	
				if(ABPersonSetImageData(newPerson, (CFDataRef)(userInfo.USERIMAGE), &error))
				{
					NSLog(@"이미지 저장 성공");
				}
				else {
					NSLog(@"이미지 저장 실패 =%@", error);
				}
				
			}
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
				ABMultiValueAddValueAndLabel(multiPhone, userInfo.ORGPHONENUMBER, kABPersonPhonePagerLabel, NULL);
			if([userInfo.HOMEPHONENUMBER length] >0)
				ABMultiValueAddValueAndLabel(multiPhone, userInfo.HOMEPHONENUMBER, kABHomeLabel, NULL);
			if([userInfo.OTHERPHONENUMBER length] >0)
				ABMultiValueAddValueAndLabel(multiPhone, userInfo.OTHERPHONENUMBER, kABOtherLabel, NULL);
			if([userInfo.PARSERNUMBER length] >0)
				ABMultiValueAddValueAndLabel(multiPhone, userInfo.PARSERNUMBER, kABPersonPhonePagerLabel, NULL);
			
			if([userInfo.URL1 length] >0)
				ABMultiValueAddValueAndLabel(multiPhone, userInfo.URL1, kABPersonHomePageLabel, NULL);
			if([userInfo.URL2 length] >0)
				ABMultiValueAddValueAndLabel(multiPhone, userInfo.URL2, kABHomeLabel, NULL);
			
			
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
				//전화번호 저장..
			//	copyGroup = sameGroupRef;
				ABGroupAddMember(sameGroupRef, newPerson, &error);
				ABAddressBookAddRecord(iPhoneAddressBook, newPerson, &error);

				
			}
			else {
				//전화번호 저장..
				ABAddressBookAddRecord(iPhoneAddressBook, newPerson, &error);
			}
			CFRelease(multiPhone);
			ABAddressBookSave(iPhoneAddressBook, &error);			
			
			
			
			
		
					
			
			
			//로컬 그룹이 없으면 만들어주자..
			/*
			if(createGroup == YES)
			{
				NSLog(@"YEs");
				ABRecordSetValue (newGroup, kABGroupNameProperty, groupString, &error);
				ABGroupAddMember(newGroup, newPerson, &error);
				ABAddressBookAddRecord(iPhoneAddressBook, newGroup, &error);
			}
			else {
				NSLog(@"NO");
				BOOL flag;
				
		//OEM단말에서 RECORDID 검사
				
				for(int i=0; i<nPeople; i++)
				{
					CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(iPhoneAddressBook);
					ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i);
					NSString *RecordID = [NSString stringWithFormat:@"%i", ABRecordGetRecordID(ref)];
					
					NSLog(@"userRecord %@ oemRecord %@", userInfo.RECORDID, RecordID);
					
					if([userInfo.RECORDID isEqualToString:RecordID])
					{
						NSLog(@"레코드 아이디가 존재한다. %@", userInfo.FORMATTED);
						flag = YES;
						break;
						
					}
					
					
					
					ABAddressBookSave(iPhoneAddressBook, nil);
				}
				
				
				if(flag == YES)
					continue;
				
				ABGroupAddMember(sameGroupRef, newPerson, &error);
			//	ABAddressBookAddRecord(iPhoneAddressBook, sameGroupRef, &error);
			}

			ABAddressBookSave(iPhoneAddressBook, &error);
			
			
			
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			NSLocale *locale = [NSLocale currentLocale];
			[formatter setLocale:locale];
			[formatter setDateFormat:@"yyyyMMddHHmmss"];
			NSDate *today = [NSDate date];
			NSString *lastSyncDate = [[NSString alloc] initWithFormat:@"%@",[formatter stringFromDate:today]];
			
			[[NSUserDefaults standardUserDefaults] setObject:lastSyncDate forKey:@"lastSyncDate"];
			*/	
			
		}
					
		
		
	}
	[self saveSyncData];
	/*[syncBlockView dismissAlertView];
	[syncBlockView release];					
	*/
	
	
	
	
	
}

-(void)downloadAction
{
	/*
	 2010.10.28 KJH
	 처음 동기화 사용자
	 _TUserInfo 테이블을 삭제 한다.
	 주소록을 읽어드린다.
	 다시 _TUserInfo 테이블에 입력한다.
	 서버에 요청한다.
	 
	 
	 
	 
	 
	 */
	
	
	
	if([[NSUserDefaults standardUserDefaults] objectForKey:@"syncData"])
	{
		
		
	}
	else {
		
		waitingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
		[waitingView setBackgroundColor:[UIColor blackColor]];
		waitingView.alpha=0.5;
		
		[self.view addSubview:waitingView];
		[self.view addSubview:showView];
		
		
		
	
		
		
		
		//동기화가 처음인 사용자이면
		/*
		syncBlockView = [[blockView alloc] initWithFrame:CGRectMake(0.0, 0.0, 250.0, 150.0)];
		syncBlockView.alertText = @"주소록 동기화 중입니다.";
		syncBlockView.alertDetailText = @"잠시만 기다려 주세요";
		[syncBlockView show];
		*/
		
		
		
		AddressBookData *_AddressBookData =[[AddressBookData alloc] init];
		NSDictionary *dicData =[[NSDictionary alloc] init];
		dicData = [_AddressBookData readFullOEMContacts];
		
		
		
		
		
		
		
		
		
		NSDictionary *rpdict = nil, *contactDic = nil, *contactCnt = nil;
		NSString	*listbody = nil;
		
		NSMutableArray* contactList = [NSMutableArray array];
		NSArray* compareGroup = [GroupInfo findAll];
		
		oemGroupArray = [[NSMutableArray alloc] initWithCapacity:0];
		NSArray* oemGroupArr = [dicData objectForKey:@"GROUP"];
		NSArray* sameGroupArr = [dicData objectForKey:@"SAMEGROUP"];
		for(GroupInfo *groupData in oemGroupArr){
			NSMutableDictionary *group = [[NSMutableDictionary alloc] initWithCapacity:0];
			for(GroupInfo* localgroup in compareGroup){
				NSLog(@"RECORDID = %@", groupData.RECORDID);
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
					if([key isEqualToString:@"IMSTATUS"] || 
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
		
		
		
		
				
		 NSString *deleteQuery =@"delete from _TUserInfo";
		 [UserInfo findWithSql:deleteQuery];
		
		
		
		
		NSString *deleteGroup = @"delete from _TGroupInfo where id > 2";
		[GroupInfo findWithSql:deleteGroup];
		
		
		
		
		
		rpdict = [NSDictionary dictionaryWithObjectsAndKeys:
				  @"0", @"RP",
				  nil];
		
		
		NSMutableArray* paramArray = [NSMutableArray array];
		[paramArray addObject:rpdict];
		
		contactCnt = [NSDictionary dictionaryWithObjectsAndKeys:
					  [NSString stringWithFormat:@"%i",[contactList count]], @"count",
					  nil];
		[paramArray addObject:contactCnt];
		
		contactDic = [NSDictionary dictionaryWithObjectsAndKeys: 
					  contactList,  @"contact",
					  nil];
		
		[paramArray addObject:contactDic];
		
		
		SBJSON *json = [[SBJSON alloc] init];
		[json setHumanReadable:YES];
		NSString *initCode = @"Y";
		// 변환
		listbody = [json stringWithObject:paramArray error:nil];
		NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:
									initCode, @"initialize",
									[[self appDelegate] getSvcIdx],@"svcidx",
									listbody, @"param",
									nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addListContact:) name:@"addListContactIncludeGroup" object:nil];
		
		//	NSLog(@"list = %@", listbody);
		USayHttpData *data = [[[USayHttpData alloc]initWithRequestData:@"addListContactIncludeGroup" andWithDictionary:bodyObject timeout:10]autorelease];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
		
		
		//[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"syncData"];
		
		
		
		
		
		
		
		
		
	}
	
	
	
	
	
	
	
	
	
	
	
	
}

-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[self saveSyncData];
	
	
}

-(void)backBarButtonClicked
{
	
	if(waitingView.superview)
	{
		return;
	}
	[self.navigationController popViewControllerAnimated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	
	
	
	UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 44)];
	UIFont *titleFont = [UIFont systemFontOfSize:20];
//	CGSize titleStringSize = [@"주소록 동기화" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
	UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 240, 44)];
	[titleLabel setFont:titleFont];
	titleLabel.textAlignment = UITextAlignmentCenter;
	[titleLabel setTextColor:ColorFromRGB(0x053844)];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	[titleLabel setText:DEF_MENU_SYNC];
	[titleView addSubview:titleLabel];	
	[titleLabel release];
	self.navigationItem.titleView = titleView;
	[titleView release];
	
	
	
	
	showView = [[UIView alloc] initWithFrame:CGRectMake(50, 100, 220, 200)];
	
	
	
	showView.contentMode = UIViewContentModeScaleAspectFit;
	[showView setBackgroundColor:[UIColor whiteColor]];
	showView.layer.masksToBounds = YES;
	showView.layer.cornerRadius = 5.0;
	//	mainPhotoView.layer.borderWidth = 1.0;
	showView.clipsToBounds = YES;
	
	
	
	showLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 220, 200)];
	showLabel.numberOfLines=4;
	showLabel.text=@"주소록 데이터가 많은 경우\n동기화 시간이 오래 걸릴 수\n있습니다.";
	showLabel.font=[UIFont systemFontOfSize:15];
	showLabel.textAlignment=UITextAlignmentCenter;
	[showView addSubview:showLabel];
	
	[showLabel release];
	
	
	
	
	
	
	
	
	
	UIImage* leftBarBtnImg = [UIImage imageNamed:@"btn_top_left.png"];
	UIImage* leftBarBtnSelImg = [UIImage imageNamed:@"btn_top_left_focus.png"];
	UIButton* leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[leftBarButton addTarget:self action:@selector(backBarButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
	[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateSelected];
	[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateDisabled];
	leftBarButton.frame = CGRectMake(0.0, 0.0, leftBarBtnImg.size.width, leftBarBtnImg.size.height);
	UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
	self.navigationItem.leftBarButtonItem = leftButton;
	[leftButton release];
	
	UILabel *titleLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(60, 60, 320-120, 40)];
	titleLabel2.text=@"원하시는 기능을 선택해 주세요";
	[self.view addSubview:titleLabel2];
	[titleLabel2 release];
	
	UILabel *iphoneLabel, *UsayLabel;
	iphoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 140, 100, 60)];
	UsayLabel = [[UILabel alloc] initWithFrame:CGRectMake(320-40-100-100, 140, 100, 60)];
	
	

	iphoneLabel.text=[NSString stringWithFormat:@"iPhone 연락처\n(주소 :1건)"];
	
	UsayLabel.text=[NSString stringWithFormat:@"Usay 주소록\n(주소 :1건)"];
	

	[self.view addSubview:iphoneLabel];
	[self.view addSubview:UsayLabel];
	
	
	
	UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
	UIButton *uploadButton = [UIButton buttonWithType:UIButtonTypeCustom];
	
	[downloadButton setFrame:CGRectMake(130, 200, 40, 40)];
	[uploadButton setFrame:CGRectMake(130, 260, 40, 40)];
	
	[downloadButton setImage:[UIImage imageNamed:@"btn_top_add.png"] forState:UIControlStateNormal];
	[uploadButton setImage:[UIImage imageNamed:@"btn_top_add.png"] forState:UIControlStateNormal];
	
	
	[uploadButton addTarget:self action:@selector(uploadAction) forControlEvents:UIControlEventTouchUpInside];
	[downloadButton addTarget:self action:@selector(downloadAction) forControlEvents:UIControlEventTouchUpInside];
	
	[self.view addSubview:uploadButton];
	[self.view addSubview:downloadButton];
	
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
    [super dealloc];
}


@end
