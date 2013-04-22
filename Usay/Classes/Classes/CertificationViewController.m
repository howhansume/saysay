//
//  CertificationViewController.m
//  USayApp
//
//  Created by Jong-Sung Park on 10. 5. 24..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "CertificationViewController.h"
#import "USayAppAppDelegate.h"
#import "CheckPhoneNumber.h"
#import "HttpAgent.h"
#import "json.h"
#import "USayHttpData.h"
#import "AuthNumberViewController.h"
#import "SetNickNameViewController.h"
#import "blockView.h"
//#import "MyDeviceClass.h"		// sochae 2010.09.11 - UI Position
#import "USayDefine.h"			// sochae 2010.09.28

//2010.10.24 add ViewController

#import "nationalViewController.h"

#define ID_PHONENUMBER	7612
#define NATIONALTAG	82
#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
										green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
										blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation CertificationViewController

@synthesize phoneNumber, national, nationalCode;


#pragma mark -
#pragma mark 국가코드 딜리게이트
-(void)codeName:(NSString*)name codeNum:(NSString*)number
{

	[nationalCode setTitle:number forState:UIControlStateNormal];
	[national setTitle:name forState:UIControlStateNormal];
	
}

-(void)pushNationalView
{
	nationalViewController *nationalView = [[[nationalViewController alloc] init] autorelease];
	nationalView.parent = self;
	[self.navigationController pushViewController:nationalView animated:YES];

}


#pragma mark -
#pragma mark Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	NSInteger rowCount = 1;
	
    return rowCount;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *kMyInfoSettingCellIdentifier = @"sendPhoneNumberCellIdentifier";
    	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMyInfoSettingCellIdentifier];
	
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kMyInfoSettingCellIdentifier] autorelease];

		UITextField *phoneNumberTextField = [[[UITextField alloc] initWithFrame:CGRectMake(10, 10, cell.contentView.frame.size.width-20, 30)] autorelease];
		phoneNumberTextField.delegate = self;
		phoneNumberTextField.keyboardType = UIKeyboardTypeNumberPad;
		phoneNumberTextField.textColor = [UIColor colorWithRed:40.0/255.0 green:95.0/255.0 blue:122.0/255.0 alpha:1.0f];
		phoneNumberTextField.tag = ID_PHONENUMBER;
		phoneNumberTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		[phoneNumberTextField becomeFirstResponder];
		[cell.contentView addSubview:phoneNumberTextField];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
    // Configure the cell...
//	UITextField* phoneNumField = (UITextField *)[cell.contentView viewWithTag:ID_PHONENUMBER];

#if TARGET_IPHONE_SIMULATOR
  //  phoneNumField.text  = @"01032310142";
#endif
	
    return cell;
}

#pragma mark -

-(USayAppAppDelegate *) appDelegate
{
	return [[UIApplication sharedApplication] delegate];
}

-(void) sendNumber {
	//입력된 전화 번호 체크 후 전화 번호 전송. 전송되었다는 메시지를 받으면 페이지 전환.
	UITextField *phoneNumberTextField = (UITextField *)[self.view viewWithTag:ID_PHONENUMBER];
	
	NSMutableString *phoneFieldValue = [[[NSMutableString alloc] initWithFormat:@"%@", phoneNumberTextField.text] autorelease];
	if ([phoneFieldValue length] == 0) {
		UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"핸드폰 번호 확인" 
														   message:@"핸드폰 번호를 입력하십시오." 
														  delegate:self 
												 cancelButtonTitle:@"확인" 
												 otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		[phoneNumberTextField becomeFirstResponder];
		return;
	}
	
	// TODO: blockView 사용
	certiblockView = [[blockView alloc] initWithFrame:CGRectMake(0.0, 0.0, 250.0, 150.0)];
	certiblockView.alertText = @"인증 번호 요청중..";
	certiblockView.alertDetailText = @"잠시만 기다려 주세요.";
	[certiblockView show];
	// 노티피케이션처리관련 등록..
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mobilePhoneNumberAuthSending:) name:@"mobilePhoneNumberAuthSending" object:nil];

	phoneFieldValue = (NSMutableString*)[phoneFieldValue stringByReplacingOccurrencesOfString:@"-" withString:@""];
	self.phoneNumber = phoneFieldValue;
	
	NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:
								phoneFieldValue, @"mobilePhoneNumber",
								[[self appDelegate] getSvcIdx], @"svcidx",
								nil];
	
	// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
	//		[httpAgent requestUrl:url bodyObject:bodyObject parent:self timeout:10];
	USayHttpData *data = [[[USayHttpData alloc]initWithRequestData:@"mobilePhoneNumberAuthSending" andWithDictionary:bodyObject timeout:10]autorelease];
//	assert(data != nil);
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
/*	
	////////////////////////////////////////////////////////////////////////
#if TARGET_IPHONE_SIMULATOR
	NSMutableString *devicePhoneNumer = [NSMutableString stringWithString:@"010-1111-1111"];
#else
	NSMutableString *devicePhoneNumer = (NSMutableString*)[[NSUserDefaults standardUserDefaults] stringForKey:@"SBFormattedPhoneNumber"];
#endif
	
	
	// 국가번호 제거후 +82 10-1234-5678 ===> 010-1234-5678 형태로 만듬.
	NSRange findRange;
	findRange = [devicePhoneNumer rangeOfString:@" "];
	if(findRange.location != NSNotFound) {
		devicePhoneNumer = (NSMutableString *)[devicePhoneNumer substringFromIndex:findRange.location+1];
		devicePhoneNumer = (NSMutableString *)[NSString stringWithFormat:@"0%@", devicePhoneNumer];
	}
	////////////////////////////////////////////////////////////////////////
 */
	
}


#pragma mark -
#pragma mark NSNotification mobilePhoneNumberAuthSending response
-(void)mobilePhoneNumberAuthSending:(NSNotification *)notification
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"mobilePhoneNumberAuthSending" object:nil];
	
	// TODO: blockview 제거
	[certiblockView dismissAlertView];
	[certiblockView release];
	
	USayHttpData *data = (USayHttpData*)[notification object];
	if (data == nil) {
		// 200 이외의 에러
		UITextField *phoneNumberTextField = (UITextField *)[self.view viewWithTag:ID_PHONENUMBER];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 오류" 
												message:@"네트워크 오류가 발생하였습니다.\n3G 나 wifi 상태를 확인해주세요." 
												delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		[phoneNumberTextField becomeFirstResponder];
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
		
		[[NSUserDefaults standardUserDefaults] setObject:phoneNumber forKey:@"AuthPhoneNumber"];
		
		AuthNumberViewController* authNumControlller = [[AuthNumberViewController alloc] initWithStyle:UITableViewStyleGrouped];
//		authNumControlller.title = @"회원 가입 인증";
		UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
//		assert(titleView != nil);
		UIFont *titleFont = [UIFont systemFontOfSize:20];
		CGSize titleStringSize = [@"회원 가입 인증" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
//		assert(titleFont != nil);
		UILabel *naviTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
//		assert(naviTitleLabel != nil);
		[naviTitleLabel setFont:titleFont];
		naviTitleLabel.textAlignment = UITextAlignmentCenter;
		[naviTitleLabel setTextColor:ColorFromRGB(0x053844)];
		[naviTitleLabel setBackgroundColor:[UIColor clearColor]];
		[naviTitleLabel setText:@"회원 가입 인증"];
//		naviTitleLabel.shadowColor = [UIColor whiteColor];
		[titleView addSubview:naviTitleLabel];	
		[naviTitleLabel release];
		authNumControlller.navigationItem.titleView = titleView;
		[titleView release];
		authNumControlller.navigationItem.titleView.frame = CGRectMake((self.view.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);
		
		[self.navigationController pushViewController:authNumControlller animated:YES];
		[authNumControlller release];
		
	} else if ([rtcode isEqualToString:@"1000"] || [rtcode isEqualToString:@"-1000"]) {
		// TODO: 가입실패(가입 필요) 예외처리 필요
//		UITextField *phoneNumberTextField = (UITextField *)[self.view viewWithTag:ID_PHONENUMBER];
//		assert(phoneNumberTextField != nil);
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"가입 실패" message:@"핸드폰 번호를 다시 한번\n확인 해주시기 바랍니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else if ([rtcode isEqualToString:@"-9030"]) {
		// TODO: 처리오류. 예외처리 필요
		UITextField *phoneNumberTextField = (UITextField *)[self.view viewWithTag:ID_PHONENUMBER];
//		assert(phoneNumberTextField != nil);
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"가입 실패" message:@"핸드폰 번호를 다시 한번\n확인 해주시기 바랍니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		[phoneNumberTextField becomeFirstResponder];
	} else if ([rtcode isEqualToString:@"-1080"]) {
		// TODO: 이미 존재하는 이용자임. 예외처리 필요
		UITextField *phoneNumberTextField = (UITextField *)[self.view viewWithTag:ID_PHONENUMBER];
//		assert(phoneNumberTextField != nil);
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"가입 실패" message:@"이미 등록된 폰번호 입니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		[phoneNumberTextField becomeFirstResponder];
	}else if ([rtcode isEqualToString:@"-1042"]) {
			// TODO: 인증번호 일일 요청한도 초과
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"인증 번호 요청 제한" message:@"1일 5회까지만 인증 번호 \n요청을 하실 수 있습니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
			[alertView show];
			[alertView release];
	} else {
		// TODO: 기타오류 예외처리 필요
		// fail (-9030, -1080 이외 기타오류)
		UITextField *phoneNumberTextField = (UITextField *)[self.view viewWithTag:ID_PHONENUMBER];
//		assert(phoneNumberTextField != nil);
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"가입 실패" message:@"네트워크나 기타 다른 이유로 가입 실패 되었습니다.\n잠시후 다시 시도해 주시기 바랍니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		[phoneNumberTextField becomeFirstResponder];
	}
	
}
#pragma mark -
#pragma alertViewmark UIAlertView delegate Method
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	NSLog(@"buttonIndex %i",buttonIndex);
	if(buttonIndex == 0){
		return;
		
	}
}

#pragma mark -
#pragma mark initialize
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[[UIApplication sharedApplication] setStatusBarHidden:NO];
	if([self appDelegate].connectionType == -1){ //오프라인 모드 일경우 가입 화면을 보여 주지 않고, 안내문을 띄우고 종료하게 한다.
		/* sochae 2010.09.28
		UIAlertView* offlineAlert = [[UIAlertView alloc] initWithTitle:@"오프라인"
					message:@"현재 네트워크 연결이 불가능한 상태 입니다.\nUsay의 모든 기능을 이용하기 위해서는 네트워크 연결이 필요합니다." 
				delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
		[offlineAlert show];
		[offlineAlert release];
		return;
		*/
		[JYUtil alertWithType:ALERT_NET_OFFLINE delegate:self];
		// ~sochae
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	
//	self.navigationItem.backBarButtonItem=nil;
	NSInteger authState = [[NSUserDefaults standardUserDefaults] integerForKey:@"CertificationStatus"];
	NSLog(@"authsta = %d", authState);
	
	/*
	if(authState == 2){
		NSLog(@"인증이다.");
		AuthNumberViewController* authNumControlller = [[AuthNumberViewController alloc] initWithStyle:UITableViewStyleGrouped];
//		authNumControlller.title = @"회원 가입 인증";
		
		UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
//		assert(titleView != nil);
		UIFont *titleFont = [UIFont systemFontOfSize:20];
		CGSize titleStringSize = [@"회원 가입 인증" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
//		assert(titleFont != nil);
		UILabel *naviTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
//		assert(naviTitleLabel != nil);
		[naviTitleLabel setFont:titleFont];
		naviTitleLabel.textAlignment = UITextAlignmentCenter;
		[naviTitleLabel setTextColor:ColorFromRGB(0x053844)];
		[naviTitleLabel setBackgroundColor:[UIColor clearColor]];
		[naviTitleLabel setText:@"회원 가입 인증"];
//		naviTitleLabel.shadowColor = [UIColor whiteColor];
		[titleView addSubview:naviTitleLabel];	
		[naviTitleLabel release];
		authNumControlller.navigationItem.titleView = titleView;
		[titleView release];
		authNumControlller.navigationItem.titleView.frame = CGRectMake((self.view.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);
		
		[self.navigationController pushViewController:authNumControlller animated:NO];
		[authNumControlller release];
	}else if (authState == 3) {
		SetNickNameViewController* nickNameController = [[SetNickNameViewController alloc] initWithStyle:UITableViewStyleGrouped];
		NSLog(@"33333333333");
		
//		nickNameController.title = @"회원 가입 인증";
		UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
//		assert(titleView != nil);
		UIFont *titleFont = [UIFont systemFontOfSize:20];
		CGSize titleStringSize = [@"회원 가입 인증" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
//		assert(titleFont != nil);
		UILabel *naviTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
//		assert(naviTitleLabel != nil);
		[naviTitleLabel setFont:titleFont];
		naviTitleLabel.textAlignment = UITextAlignmentCenter;
		[naviTitleLabel setTextColor:ColorFromRGB(0x053844)];
		[naviTitleLabel setBackgroundColor:[UIColor clearColor]];
		[naviTitleLabel setText:@"회원 가입 인증"];
//		naviTitleLabel.shadowColor = [UIColor whiteColor];
		[titleView addSubview:naviTitleLabel];	
		[naviTitleLabel release];
		nickNameController.navigationItem.titleView = titleView;
		[titleView release];
		nickNameController.navigationItem.titleView.frame = CGRectMake((self.view.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);
		
		[self.navigationController pushViewController:nickNameController animated:NO];
		[nickNameController release];
	}
	
	 */
	if (authState == 3) {
		SetNickNameViewController* nickNameController = [[SetNickNameViewController alloc] initWithStyle:UITableViewStyleGrouped];
		NSLog(@"33333333333");
		
		//		nickNameController.title = @"회원 가입 인증";
		UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
		//		assert(titleView != nil);
		UIFont *titleFont = [UIFont systemFontOfSize:20];
		CGSize titleStringSize = [@"회원 가입 인증" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
		//		assert(titleFont != nil);
		UILabel *naviTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
		//		assert(naviTitleLabel != nil);
		[naviTitleLabel setFont:titleFont];
		naviTitleLabel.textAlignment = UITextAlignmentCenter;
		[naviTitleLabel setTextColor:ColorFromRGB(0x053844)];
		[naviTitleLabel setBackgroundColor:[UIColor clearColor]];
		[naviTitleLabel setText:@"회원 가입 인증"];
		//		naviTitleLabel.shadowColor = [UIColor whiteColor];
		[titleView addSubview:naviTitleLabel];	
		[naviTitleLabel release];
		nickNameController.navigationItem.titleView = titleView;
		[titleView release];
		nickNameController.navigationItem.titleView.frame = CGRectMake((self.view.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);
		
		[self.navigationController pushViewController:nickNameController animated:NO];
		[nickNameController release];
	}
	
	 
	 
	[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"CertificationStatus"];
//	self.title = @"회원 가입 인증";
	UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
//	assert(titleView != nil);
	UIFont *titleFont = [UIFont systemFontOfSize:20];
	CGSize titleStringSize = [@"회원 가입 인증" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
//	assert(titleFont != nil);
	UILabel *naviTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
//	assert(naviTitleLabel != nil);
	[naviTitleLabel setFont:titleFont];
	naviTitleLabel.textAlignment = UITextAlignmentCenter;
	[naviTitleLabel setTextColor:ColorFromRGB(0x053844)];
	[naviTitleLabel setBackgroundColor:[UIColor clearColor]];
	[naviTitleLabel setText:@"회원 가입 인증"];
//	naviTitleLabel.shadowColor = [UIColor whiteColor];
	[titleView addSubview:naviTitleLabel];	
	[naviTitleLabel release];
	self.navigationItem.titleView = titleView;
	[titleView release];
	self.navigationItem.titleView.frame = CGRectMake((self.view.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);
	
	
	//인증 번호 전송
	UIImage* rightBarBtnImg = [[UIImage imageNamed:@"btn_top_next.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	UIImage* rightBarBtnSelImg = [[UIImage imageNamed:@"btn_top_next_focus.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[rightBarButton addTarget:self action:@selector(sendNumber) forControlEvents:UIControlEventTouchUpInside];
	[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
	[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
	rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
	self.navigationItem.rightBarButtonItem = rightButton;
	if([self appDelegate].connectionType == -1){
		rightButton.enabled = NO;
	}
	[rightButton release];
	
	self.view.backgroundColor = [UIColor colorWithRed:237.0/255.0 green:239.0/255.0 blue:242.0/255.0 alpha:1.0f];
	UITableView *certificationTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
//	assert(certificationTableView != nil);
	certificationTableView.delegate = self;
	certificationTableView.dataSource = self;
	certificationTableView.backgroundColor = [UIColor colorWithRed:237.0/255.0 green:239.0/255.0 blue:242.0/255.0 alpha:1.0f];
	certificationTableView.scrollEnabled = NO;
	
	
//20101024	UIView* customHeaderView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 35)]autorelease];
	CGRect rect = self.view.frame;
	UIView* customHeaderView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)]autorelease];

	UIFont *informationFont = [UIFont systemFontOfSize:15];
//국가 코드 및 국가명 필드 추가. 2010.10.24

	nationalCode = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	national = [UIButton buttonWithType:UIButtonTypeRoundedRect];

	
	
	
	[nationalCode setFrame:CGRectMake(15, 13, 60, 45)];
	[national setFrame:CGRectMake(25+60, 13, rect.size.width-95, 45)];
	[national setTitle:@"대한민국" forState:UIControlStateNormal];
	[nationalCode setTitle:@"+82" forState:UIControlStateNormal];
	
	
	
	
	national.showsTouchWhenHighlighted=NO;
	nationalCode.showsTouchWhenHighlighted=NO;
	
	//설정이 안먹는다..
	national.highlighted = NO;
	nationalCode.highlighted = NO;
	
	[national addTarget:self action:@selector(pushNationalView) forControlEvents:UIControlEventTouchUpInside];
	[nationalCode addTarget:self action:@selector(pushNationalView) forControlEvents:UIControlEventTouchUpInside];
	
	
	/*
	UITextField *nationalCode = [[UITextField alloc] initWithFrame:CGRectMake(15, 13, 60, 35)];
	UITextField *national	=[[UITextField alloc] initWithFrame:CGRectMake(25+60, 13, rect.size.width-95, 35)];
	
	national.delegate=self;
	nationalCode.delegate = self;
	
	nationalCode.tag = NATIONALTAG;
	national.tag = NATIONALTAG;
	
	nationalCode.text=@"+82";
	national.text=@"대한민국";
	national.textAlignment=UITextAlignmentCenter;
	nationalCode.textAlignment=UITextAlignmentCenter;
	//세로 정렬
	nationalCode.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
	national.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
	
	
	[nationalCode setFont:informationFont];
	nationalCode.textColor = [UIColor colorWithRed:40.0/255.0 green:95.0/255.0 blue:122.0/255.0 alpha:1.0f];
	[national setFont:informationFont];
	national.textColor = [UIColor colorWithRed:40.0/255.0 green:95.0/255.0 blue:122.0/255.0 alpha:1.0f];
	
	nationalCode.borderStyle=UITextBorderStyleRoundedRect;
	national.borderStyle=UITextBorderStyleRoundedRect;
	
	
	
	
	
	
		
*/	
	
	[customHeaderView addSubview:nationalCode];
	[customHeaderView addSubview:national];

	
	
	
	
	customHeaderView.backgroundColor = [UIColor clearColor];
//	headerImageView.image = [[UIImage imageNamed:@"text_phonenum_top.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
	// sochae 2010.09.11 - UI Position
	//CGRect rect = [MyDeviceClass deviceOrientation];
	
	// ~sochae
	CGSize infoStringSize = [@"본인의 핸드폰 번호를 입력해 주세요." sizeWithFont:informationFont constrainedToSize:(CGSizeMake(rect.size.width-30.0, 20.0f))];
//	UILabel *informationLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 13, rect.size.width-40.0, infoStringSize.height)];
	UILabel *informationLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 13+55, rect.size.width-40.0, infoStringSize.height)];
	[informationLabel setFont:informationFont];
	[informationLabel setTextColor:ColorFromRGB(0x313b48)];
	[informationLabel setBackgroundColor:[UIColor clearColor]];
	[informationLabel setText:@"본인의 핸드폰 번호를 입력해 주세요."];
	[customHeaderView addSubview:informationLabel];
	[informationLabel release];
	

	
	
	
	certificationTableView.tableHeaderView = customHeaderView;
	
	
	UIImageView* footerImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 34)] autorelease];	
	footerImageView.image = [[UIImage imageNamed:@"text_phonenum_bottom.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
	certificationTableView.tableFooterView = footerImageView;
	
	[self.view addSubview:certificationTableView];
	[certificationTableView release];
	
	
		
}

- (void)viewDidDisappear:(BOOL)animated 
{
    [super viewDidDisappear:animated];
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
	if(certiblockView)[certiblockView release];
	[nationalCode release];
	[national release];
    [super dealloc];
}

#pragma mark -
#pragma mark Text Field delegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
	
	UITextField *phoneNumberTextField = (UITextField *)[self.view viewWithTag:ID_PHONENUMBER];
	if(textField == phoneNumberTextField){	
		CheckPhoneNumber *checkNumber = [[[CheckPhoneNumber alloc] initMaxLength:14] autorelease];
		return [checkNumber checkTextFieldPhoneNumber:textField shouldChangeCharactersInRange:range replacementString:string];
	}
	return NO;
}



/*
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	NSLog(@"textField.tag = %d", textField.tag);
	if (textField.tag == NATIONALTAG ) {
		NSLog(@"nationalCode Click");
		
		
		nationalViewController *nationalView = [[nationalViewController alloc] init];
		
		
		[self.navigationController pushViewController:nationalView animated:YES];
	}
	return YES;
	
	
}
 */









@end
