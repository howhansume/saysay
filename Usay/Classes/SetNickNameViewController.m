//
//  SetNickNameViewController.m
//  USayApp
//
//  Created by Jong-Sung Park on 10. 6. 29..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "SetNickNameViewController.h"
#import "USayAppAppDelegate.h"
#import "HttpAgent.h"
#import "json.h"
#import "USayHttpData.h"
#import "blockView.h"
//#import "MyDeviceClass.h"			// sochae 2010.09.11 - UI Position
#import <CommonCrypto/CommonDigest.h>
#import "USayDefine.h"
#import "AddressBookData.h"
#define ID_NICKNAME		7613

#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]



@implementation SetNickNameViewController


extern BOOL LOGINSTART;
extern BOOL LOGINEND;
extern BOOL LOGINSUCESS;



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


#pragma mark -
#pragma mark Initialization

- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
    }
    return self;
}

#pragma mark -
#pragma mark button Event Method
#pragma mark ---> 별명 입력, 이용자 등록 요청 ( registOnMobile )
-(void) nickNameCompleteClicked {
	//nick 글자 검사, 서버로 전송, ok수신후 main페이지로 전환.
	UITextField *nickNameTextField = (UITextField *)[self.view viewWithTag:ID_NICKNAME];
	NSString *nickName = [nickNameTextField text];
	nickName = [nickName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	nickNameTextField.text = nickName;
	if ([self displayTextLength:nickName] > 10) {
		UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"별명 확인" message:@"별명은 최대 한글5자(영문10자) 입니다." delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		[nickNameTextField becomeFirstResponder];
		return;
	} else if ([self displayTextLength:nickName] == 0) {
		UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"별명 확인" message:@"별명은 최소 영문1자 입니다." delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		[nickNameTextField becomeFirstResponder];
		return;
	}
	
	// TODO: blockView 사용
	textBlockView = [[blockView alloc] initWithFrame:CGRectMake(0.0, 0.0, 250.0, 150.0)];
	textBlockView.alertText = @"사용자 등록 중..";
	textBlockView.alertDetailText = @"잠시만 기다려 주세요.";
	[textBlockView show];
	
	/*
	 NSString *authPhoneNumber = [[NSUserDefaults standardUserDefaults] valueForKey:@"AuthPhoneNumber"];
	 DebugLog(@"\n  ===> [plist] AuthPhoneNumber : %@ ", authPhoneNumber);
	 */
	
	
	// TODO : 여기 수정 필요. 중복 루틴
	if([[NSUserDefaults standardUserDefaults] valueForKey:@"AuthPhoneNumber"]) {// key is Defined
		NSString *authPhoneNumber = [[NSUserDefaults standardUserDefaults] valueForKey:@"AuthPhoneNumber"];
		if(authPhoneNumber != nil && [authPhoneNumber length] > 0){
			authPhoneNumber = (NSMutableString *)[authPhoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
			
			// 노티피케이션처리관련 등록..
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registOnMobile:) name:@"registOnMobile" object:nil];
			
			// 버전 정보 추가 
			NSString *version = [NSString stringWithFormat:@"%@", 
								 [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
			
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
										version, kAppVersion,	// 버전 정보 추가
										nil];
			
			USayHttpData *data = [[[USayHttpData alloc]initWithRequestData:@"registOnMobile" andWithDictionary:bodyObject timeout:10]autorelease];
			DebugLog(@"\n----- [HTTP] 이용자 등록 요청 ( registOnMobile ) ---------->");
			[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
			
			
			
			
			
			
		}else {
			//전화 번호가 저장되어 있지 않다. 처음부터 다시 시작하게 유도.
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"등록 실패" 
																message:@"입력된 폰번호 정보가 없습니다.\n앱 종료후 처음부터 진행하여 주세요." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
			[alertView show];
			[alertView release];
			
			[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"CertificationStatus"];
			
		}
		
	}
	else {
		//plist에 키값이 없다.
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"등록 실패" 
															message:@"폰번호 정보를 읽어오지 못했습니다.\n앱 종료후 처음부터 진행하여 주세요." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		
		[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"CertificationStatus"];
	}
	
}

#pragma mark -
#pragma mark Initialize
- (void)viewDidAppear:(BOOL)animated 
{
	DebugLog(@"===== viewDidAppear =====>");
	[[NSUserDefaults standardUserDefaults] setInteger:3 forKey:@"CertificationStatus"];
	[super viewDidAppear:animated];
}


-(void)th_readFullOEMData
{
//	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	AddressBookData* addrData = [[[AddressBookData alloc] init] autorelease];
	[addrData readFullOEMData];
//	[pool release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	
	//[NSThread detachNewThreadSelector:@selector(th_readFullOEMData) toTarget:self withObject:nil];
	
	[self th_readFullOEMData];
	
	
    UIImage* rightBarBtnImg = [[UIImage imageNamed:@"btn_top_next.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	UIImage* rightBarBtnSelImg = [[UIImage imageNamed:@"btn_top_next_focus.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[rightBarButton addTarget:self action:@selector(nickNameCompleteClicked) forControlEvents:UIControlEventTouchUpInside];
	[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
	[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
	rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
	self.navigationItem.rightBarButtonItem = rightButton;
	[rightButton release];
	
	self.navigationItem.leftBarButtonItem = nil;
	
	self.navigationItem.hidesBackButton = YES;
	
	self.view.backgroundColor = [UIColor colorWithRed:237.0/255.0 green:239.0/255.0 blue:242.0/255.0 alpha:1.0f];
	
	//	UIView* tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];
	//	tableHeaderView.backgroundColor = [UIColor clearColor];
	//	[tableHeaderView release];
	UIView* customHeaderView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 35)] autorelease];
	//	headerImage.image = [UIImage imageNamed:@"text_Usay.png"];
	// sochae 2010.09.11 - UI Position
	//CGRect rect = [MyDeviceClass deviceOrientation];
	CGRect rect = self.view.frame;
	// ~sochae
	
	UIFont *titleFont = [UIFont systemFontOfSize:12];
	UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(14, 15, 320, 200)] autorelease];
	[titleLabel setFont:titleFont];
	[titleLabel setTextColor:ColorFromRGB(0x666666)];
	[titleLabel setNumberOfLines:4];
	[titleLabel setText:@"실명을 입력하시면 USay 친구들이 회원님을 쉽게 알아\n볼 수 있습니다."];	// sochae 2010.09.09 - 기획 요청으로 문구 수정
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	
	
	
	
	UIFont *informationFont = [UIFont systemFontOfSize:14];
	CGSize infoStringSize = [@"Usay에서 사용하실 별명을 입력해 주세요." sizeWithFont:informationFont constrainedToSize:(CGSizeMake(rect.size.width-20.0, 20.0f))];
	UILabel *informationLabel = [[UILabel alloc]initWithFrame:CGRectMake(14, 13, rect.size.width-30.0, infoStringSize.height)];
	[informationLabel setBackgroundColor:[UIColor redColor]];
	[informationLabel setFont:informationFont];
	[informationLabel setTextColor:ColorFromRGB(0x23232a)];
	[informationLabel setBackgroundColor:[UIColor clearColor]];
	[informationLabel setText:@"Usay에서 사용하실 별명을 입력해 주세요."];
	[customHeaderView addSubview:informationLabel];
	[informationLabel release];
	
	self.tableView.tableHeaderView = customHeaderView;	
	self.tableView.scrollEnabled = NO;
	[self.view addSubview:titleLabel];
}

- (void)viewDidDisappear:(BOOL)animated 
{
    [super viewDidDisappear:animated];
}
#pragma mark -
#pragma mark USay Application delegate
-(USayAppAppDelegate *) appDelegate
{
	return (USayAppAppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"nickNameSetCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		UITextField* textField = [[UITextField alloc] 
								  initWithFrame:CGRectMake(10.0, 10.0, cell.contentView.frame.size.width-25, 30)];
		textField.font = [UIFont systemFontOfSize:20];
		textField.placeholder = @"한글 최대 5자";
		textField.delegate = self;
		textField.tag = ID_NICKNAME;
		textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		[cell.contentView addSubview:textField];
		[textField release];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // Configure the cell...
	UITextField* authNumberField = (UITextField*)[cell.contentView viewWithTag:ID_NICKNAME];
	authNumberField.keyboardType = UIKeyboardTypeDefault;
	authNumberField.returnKeyType = UIReturnKeyDone;
	[authNumberField becomeFirstResponder];
	//device 이름 얻어오기
	/*	UIDevice *device = [UIDevice currentDevice];
	 NSString* deviceName = [NSString stringWithFormat:@"name:%@, systemname:%@, systemVersion:%@ model:%@",
	 [device name],[device systemName],[device systemVersion],[device model]];
	 NSLog(@"deviceInfo >> %@",deviceName);	
	 */	
	
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark Text Field delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	UITextField *nickNameTextField = (UITextField *)[self.view viewWithTag:ID_NICKNAME];
	
	if (nickNameTextField != nil) {
		if (textField == nickNameTextField) {
			[textField resignFirstResponder];
			[self nickNameCompleteClicked];
		} else {
			
		}
		return YES;
	}
	
	return NO;
}

#pragma mark -
#pragma mark text value check Method
-(NSInteger) displayTextLength:(NSString*)text
{
	NSInteger textLength = [text length];
	NSInteger textLengthUTF8 = [text lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	NSInteger correntLength = (textLengthUTF8 - textLength)/2 + textLength;
	
	return correntLength;
}
#pragma mark -
#pragma mark NSNotification registOnMobile response
#pragma mark <--- 이용자 등록 완료 ( registOnMobile )
-(void)registOnMobile:(NSNotification *)notification
{
	NSLog(@"\n----- [HTTP] 이용자 등록 완료 ( nickname ) ---------->");
	
	LOGINSTART = NO;
	LOGINEND = YES;
	
	// TODO: blockview 제거
	[textBlockView dismissAlertView];
	[textBlockView release];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"registOnMobile" object:nil];
	
	USayHttpData *data = (USayHttpData*)[notification object];
	if (data == nil) {
		// 200 이외의 에러
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" 
															message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0013)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
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
	DebugLog(@"\n  ===> rtcode : %@ ===", rtcode);
	
	
	
	if ([rtcode isEqualToString:@"0"])			// MARK: # 최초 가입 사용자인 경우 (0) ===== >
	{
		NSString *rtType = [dic objectForKey:@"rttype"];
		if ([rtType isEqualToString:@"map"])
		{
			
			[[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"ADDRESSAPPEAR"];	
			
			// Key and Dictionary as its value type
			NSDictionary *addressDic = [dic objectForKey:@"map"];
			
			NSString *ucmc = [addressDic objectForKey:@"UCMC"];
			NSString *uccs = [addressDic objectForKey:@"UCCS"];
			NSString *mc = [addressDic objectForKey:@"MC"];			// 파란ID 매핑된 회원 인 경우만 내려옴
			NSString *cs = [addressDic objectForKey:@"CS"];			// 파란ID 매핑된 회원 인 경우만 내려옴
			NSString *userno = [addressDic objectForKey:@"userno"];
			
			[[[self appDelegate] myInfoDictionary] setObject:[addressDic objectForKey:@"pkey"] forKey:@"pkey"];
			[[[self appDelegate] myInfoDictionary] setObject:[addressDic objectForKey:@"exip"] forKey:@"exip"];
			//[[[self appDelegate] myInfoDictionary] setObject:[addressDic objectForKey:@"userno"] forKey:@"userno"];
			// sochae 2010.10.12 - nickname은 NSUserDefaults에만 저장하도록..
			//[[[self appDelegate] myInfoDictionary] setObject:[addressDic objectForKey:@"nickName"] forKey:@"nickname"];
			[[[self appDelegate] myInfoDictionary] setObject:ucmc forKey:@"UCMC"];
			[[[self appDelegate] myInfoDictionary] setObject:uccs forKey:@"UCCS"];
			//[[NSUserDefaults standardUserDefaults] setObject:[addressDic objectForKey:@"nickName"] forKey:@"nickName"];
			[JYUtil saveToUserDefaults:[addressDic objectForKey:kNickname] forKey:kNickname];
			//~sochae
			DebugLog(@"\n  ===> [myInfo] pkey : %@ ", [addressDic objectForKey:@"pkey"]);
			DebugLog(@"\n  ===> [plist] nickName : %@ ", [JYUtil loadFromUserDefaults:kNickname]);
			
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
					[[self appDelegate].myInfoDictionary setObject:improxyAddr forKey:@"proxyhost"];
					[[self appDelegate].myInfoDictionary setObject:improxyPort forKey:@"proxyport"];
				}
			}
			// MARK: [socket] connect =====>
			//*
			if([[self appDelegate] connect:improxyAddr PORT:[improxyPort intValue]]) {
				LOGINSUCESS = YES;
				
				
				[[self appDelegate] goMain:self];
				//	[[self appDelegate] requestProposeUserList];
				// success!
			} else {
				// TODO: 예외처리 필요 (세션연결 실패)
			}
			//*/
		} else {
			// TODO: 예외처리
		}
		
	}
	else if ([rtcode isEqualToString:@"12"])	// MARK: # 이전 가입한 사용자인 경우 (12) ===== >
	{
		[[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"ADDRESSAPPEAR"];	
		NSLog(@"이전에 가입한 사용자 이다.");
		//	[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"joinWebUser"];
		//kjh 2010.11.04	[[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"isFirstUser"];
		NSString *rtType = [dic objectForKey:@"rttype"];
		if ([rtType isEqualToString:@"map"])
		{
			// Key and Dictionary as its value type
			NSDictionary *addressDic = [dic objectForKey:@"map"];
			
			NSString *ucmc = [addressDic objectForKey:@"UCMC"];
			NSString *uccs = [addressDic objectForKey:@"UCCS"];
			NSString *mc = [addressDic objectForKey:@"MC"];			// 파란ID 매핑된 회원 인 경우만 내려옴
			NSString *cs = [addressDic objectForKey:@"CS"];			// 파란ID 매핑된 회원 인 경우만 내려옴
			NSString *userno = [addressDic objectForKey:@"userno"];
			//		NSString *lastsyncdate = [addressDic objectForKey:@"lastsynctime"];		// unix TimeStamp 13 자리로 옴.
			
			NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
			//		NSDate* lastsynctime = [NSDate dateWithTimeIntervalSince1970:[lastsyncdate doubleValue]/1000 ];
			NSLocale* locale = [NSLocale currentLocale];
			[formatter setLocale:locale];
			[formatter setDateFormat:@"yyyyMMddHHmmss"];
			
			//	NSString* lastSyncDate = [[NSString alloc] initWithFormat:@"%@",[formatter stringFromDate:lastsynctime]];
			//	NSLog(@"12code lastSyncDate = %@", lastSyncDate);
			
			
			//기 사용자가 다시 설치하였을 경우. oem 주소록의 정보는 마지막 싱크 날짜 이후의 날자를 보내준다.
			//	if(lastSyncDate){
			//			NSString* revisionPoint = [[NSUserDefaults standardUserDefaults] objectForKey:@"RevisionPoints"];
			//	if(revisionPoint == nil || [revisionPoint isEqualToString:@"0"]){
			//			}else{
			//		[self appDelegate].registSynctime = [NSString stringWithFormat:@"%@",lastSyncDate];
			//		[[NSUserDefaults standardUserDefaults] setObject:lastSyncDate forKey:@"lastSyncDate"];
			//	}
			//	}
			[formatter release];
			//	[lastSyncDate release];
			
			[[[self appDelegate] myInfoDictionary] setObject:[addressDic objectForKey:@"pkey"] forKey:@"pkey"];
			[[[self appDelegate] myInfoDictionary] setObject:[addressDic objectForKey:@"exip"] forKey:@"exip"];
			//			[[[self appDelegate] myInfoDictionary] setObject:[addressDic objectForKey:@"userno"] forKey:@"userno"];
			// sochae 2010.10.12 - nickname은 NSUserDefaults에만 저장하도록..
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
					UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0014)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
					[alertView show];
					[alertView release];
				} else {
					improxyAddr = [improxy substringToIndex:range.location];
					improxyPort = [[improxy substringFromIndex:range.location+1] substringToIndex:[improxy length]-(range.location+1)];
					[[self appDelegate].myInfoDictionary setObject:improxyAddr forKey:@"proxyhost"];
					[[self appDelegate].myInfoDictionary setObject:improxyPort forKey:@"proxyport"];
				}
			}
			// MARK: # socket 연결
			//*
			if([[self appDelegate] connect:improxyAddr PORT:[improxyPort intValue]]) {
				LOGINSUCESS = YES;
				
				
				
				[[self appDelegate] goMain:self];
				//	[[self appDelegate] requestProposeUserList];
				// success!
			} else {
				// TODO: 예외처리 필요 (세션연결 실패)
			}
			
		} else {
			// TODO: 예외처리
		}
	}
	
	else if ([rtcode isEqualToString:@"1000"] || [rtcode isEqualToString:@"-1000"]) {
		// TODO: 가입실패(가입 필요) 예외처리 필요
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"가입 실패" message:@"핸드폰 번호를 다시 한번\n확인 해주시기 바랍니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"CertificationStatus"];
	} 
	else if ([rtcode isEqualToString:@"-9030"]) {
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
	} 
	else {
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

