//
//  AuthNumberViewController.m
//  USayApp
//
//  Created by Jong-Sung Park on 10. 6. 28..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "AuthNumberViewController.h"
#import "HttpAgent.h"
#import "USayAppAppDelegate.h"
#import "json.h"
#import "USayHttpData.h"
#import "SetNickNameViewController.h"
#import "blockView.h"
//#import "MyDeviceClass.h"			// sochae 2010.09.11 - UI Position

#define ID_AUTHNUMBER	7615

#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
										green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
										blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@implementation AuthNumberViewController


#pragma mark -
#pragma mark Initialization


- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
    }
    return self;
}

-(USayAppAppDelegate *)appDelegate
{
	return [[UIApplication sharedApplication] delegate];
}
#pragma mark -
#pragma mark View lifecycle
- (void)viewDidAppear:(BOOL)animated {
	[[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"CertificationStatus"];
	[super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];

	
	UIImage* leftBarBtnImg = [UIImage imageNamed:@"btn_top_left.png"];
	UIImage* leftBarBtnSelImg = [UIImage imageNamed:@"btn_top_left_focus.png"];
	UIButton* leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[leftBarButton addTarget:self action:@selector(backBarButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
	[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateSelected];
	leftBarButton.frame = CGRectMake(0.0, 0.0, leftBarBtnImg.size.width, leftBarBtnImg.size.height);
	UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
	self.navigationItem.leftBarButtonItem = leftButton;
	[leftButton release];
	
	self.view.backgroundColor = [UIColor colorWithRed:237.0/255.0 green:239.0/255.0 blue:242.0/255.0 alpha:1.0f];
	UIView* customHeaderView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 35)] autorelease];
//	headerImage.image = [UIImage imageNamed:@"text_auth_top.png"];
	// sochae 2010.09.11 - UI Position
	//CGRect rect = [MyDeviceClass deviceOrientation];
	CGRect rect = [[UIScreen mainScreen] applicationFrame];
	// ~sochae
	UIFont *informationFont = [UIFont systemFontOfSize:15];
	CGSize infoStringSize = [@"인증번호를 입력해 주세요." sizeWithFont:informationFont constrainedToSize:(CGSizeMake(rect.size.width-30.0, 20.0f))];
	UILabel *informationLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 13, rect.size.width-40.0, infoStringSize.height)];
	[informationLabel setFont:informationFont];
	[informationLabel setTextColor:ColorFromRGB(0x313b48)];
	[informationLabel setBackgroundColor:[UIColor clearColor]];
	[informationLabel setText:@"인증번호를 입력해 주세요."];
	[customHeaderView addSubview:informationLabel];
	[informationLabel release];
	
	self.tableView.tableHeaderView = customHeaderView;
	[self addCustomFooterView];
	
	self.tableView.scrollEnabled = NO;
	
}
- (void)viewDidDisappear:(BOOL)animated 
{
    [super viewDidDisappear:animated];
}


-(void)addCustomFooterView {
	UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 80.0)];
	customView.backgroundColor = [UIColor clearColor];
	
	UIImageView* footerImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 34)] autorelease];	
	footerImageView.image = [[UIImage imageNamed:@"text_auth_bottom.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
	[customView addSubview:footerImageView];
	
	UIImage* authCheckNormalImage = [UIImage imageNamed:@"btn_auth.png"];
	UIImage* authCheckClickedImage = [UIImage imageNamed:@"btn_auth_focus.png"];
	UIButton* customCheckImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[customCheckImageButton addTarget:self action:@selector(authCheckNumber) forControlEvents:UIControlEventTouchUpInside];
	[customCheckImageButton setImage:[authCheckNormalImage stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] forState:UIControlStateNormal];
	[customCheckImageButton setImage:[authCheckClickedImage stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] forState:UIControlStateSelected];
	customCheckImageButton.frame = CGRectMake(9.0, 36.0, 149.0, 38.0);	
	[customView addSubview:customCheckImageButton];
	
	UIImage* authResendNormalImage = [UIImage imageNamed:@"btn_authresend.png"];
	UIImage* authResendClickedImage = [UIImage imageNamed:@"btn_authresend_focus.png"];
	UIButton* customResendImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[customResendImageButton addTarget:self action:@selector(reRequestNumber) forControlEvents:UIControlEventTouchUpInside];
	[customResendImageButton setImage:[authResendNormalImage stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] forState:UIControlStateNormal];
	[customResendImageButton setImage:[authResendClickedImage stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] forState:UIControlStateSelected];
	customResendImageButton.frame = CGRectMake(162.0, 36.0, 149.0, 38.0);	
	[customView addSubview:customResendImageButton];
	
	self.tableView.tableFooterView = customView;
	[customView release];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
#pragma mark -
#pragma mark button Event Method
-(void) backBarButtonClicked {
	[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"CertificationStatus"];
	
	[self.navigationController popViewControllerAnimated:YES]; 
}

-(void) authCheckNumber {
	
	//입력된 인증 번호 체크 후 인증 번호 전송. 인증 성공 되면 닉네임 설정 페이지로 전환.
	UITextField *authNumberTextField = (UITextField *)[self.view viewWithTag:ID_AUTHNUMBER];
	
	NSMutableString *authNumberValue = [[[NSString alloc] initWithFormat:@"%@", authNumberTextField.text] autorelease];

	if ([authNumberValue length] == 0) {
		UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"인증 코드 입력" 
														   message:@"인증 코드를 입력하십시오." 
														  delegate:nil 
												 cancelButtonTitle:@"확인" 
												 otherButtonTitles:nil];
		[alertView show];
		[alertView release];
//		[authNumberTextField becomeFirstResponder];
		return;
	}
	// TODO: blockView 사용
	authBlockView = [[blockView alloc] initWithFrame:CGRectMake(0.0, 0.0, 250.0, 150.0)];
	authBlockView.alertText = @"인증 확인 중..";
	authBlockView.alertDetailText = @"잠시만 기다려 주세요.";
	[authBlockView show];

	// 노티피케이션처리관련 등록..
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isMobilePhoneNumberAuth:) name:@"isMobilePhoneNumberAuth" object:nil];
	
	NSString *authPhoneNumber = [[NSUserDefaults standardUserDefaults] valueForKey:@"AuthPhoneNumber"];
	NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:
								authPhoneNumber, @"mobilePhoneNumber",
								authNumberValue,@"authNumber",
								[[self appDelegate] getSvcIdx], @"svcidx",
								nil];
	
	// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
	//		[httpAgent requestUrl:url bodyObject:bodyObject parent:self timeout:10];
	USayHttpData *data = [[[USayHttpData alloc]initWithRequestData:@"isMobilePhoneNumberAuth" andWithDictionary:bodyObject timeout:10]autorelease];
//	assert(data != nil);
		
	[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
}

-(void) reRequestNumber {
	
	// TODO: blockView 사용
	authBlockView = [[blockView alloc] initWithFrame:CGRectMake(0.0, 0.0, 250.0, 150.0)];
	authBlockView.alertText = @"인증 번호 요청 중..";
	authBlockView.alertDetailText = @"잠시만 기다려 주세요.";
	[authBlockView show];
	
	// 노티피케이션처리관련 등록..
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mobilePhoneNumberAuthSending:) name:@"mobilePhoneNumberAuthSending" object:nil];
	
	if([[NSUserDefaults standardUserDefaults] valueForKey:@"AuthPhoneNumber"]) {// key is Defined
		NSString *authPhoneNumber = [[NSUserDefaults standardUserDefaults] valueForKey:@"AuthPhoneNumber"];
		if(authPhoneNumber != nil && [authPhoneNumber length] > 0){
			authPhoneNumber = (NSMutableString *)[authPhoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
	
	
			NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:
										authPhoneNumber, @"mobilePhoneNumber",
										[[self appDelegate] getSvcIdx], @"svcidx",
										nil];
			
			USayHttpData *data = [[[USayHttpData alloc]initWithRequestData:@"mobilePhoneNumberAuthSending" andWithDictionary:bodyObject timeout:10]autorelease];
//			assert(data != nil);
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
		}else {
			//전화 번호가 저장되어 있지 않다. 처음부터 다시 시작하게 유도.
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"인증 번호 요청 실패" 
										message:@"입력된 폰번호 정보가 없습니다.\n앱 종료후 처음부터 진행하여 주세요." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
			[alertView show];
			[alertView release];
			
			[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"CertificationStatus"];
			
		}

	}else {
		//plist에 키값이 없다.
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"인증 번호 요청 실패" 
															message:@"폰번호 정보를 읽어오지 못했습니다.\n앱 종료후 처음부터 진행하여 주세요." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		
		[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"CertificationStatus"];
	}

	
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
    
    static NSString *CellIdentifier = @"AuthNumberCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		UITextField* textField = [[UITextField alloc] 
								  initWithFrame:CGRectMake(10.0, 10.0, cell.contentView.frame.size.width-25, 30)];
		textField.font = [UIFont systemFontOfSize:20];
		textField.keyboardType = UIKeyboardTypeNumberPad;
		textField.tag = ID_AUTHNUMBER;
		textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		[cell.contentView addSubview:textField];
		[textField release];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // Configure the cell...
    UITextField* authNumberField = (UITextField*)[cell.contentView viewWithTag:ID_AUTHNUMBER];
	[authNumberField becomeFirstResponder];
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
#pragma mark NSNotificationCenter isMobilePhoneNumberAuth response
-(void)isMobilePhoneNumberAuth:(NSNotification *)notification {
	
	// TODO: blockview 제거
	[authBlockView dismissAlertView];
	[authBlockView release];
	
	USayHttpData *data = (USayHttpData*)[notification object];
	//노티피케이션 제거
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"isMobilePhoneNumberAuth" object:nil];
	if (data == nil) {
		// 200 이외의 에러
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 오류" 
								message:@"네트워크 오류가 발생하였습니다.\n3G 나 wifi 상태를 확인해주세요." 
								delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		
		UITextField *authNumberTextField = (UITextField *)[self.view viewWithTag:ID_AUTHNUMBER];
		if(authNumberTextField != nil) {
			[authNumberTextField becomeFirstResponder];
		}
		
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
		
		SetNickNameViewController* nickController = [[SetNickNameViewController alloc]initWithStyle:UITableViewStyleGrouped];
//		nickController.title = @"회원 가입 인증";
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
		nickController.navigationItem.titleView = titleView;
		[titleView release];
		nickController.navigationItem.titleView.frame = CGRectMake((self.tableView.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);
		
		
		[self.navigationController pushViewController:nickController animated:YES];
		[nickController release];
	
	} else if ([rtcode isEqualToString:@"1000"] || [rtcode isEqualToString:@"-1000"]) {
		// TODO: 가입실패(가입 필요) 예외처리 필요
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"인증 실패" 
															message:@"폰번호 정보가 없습니다.\n앱 종료후 처음부터 진행하여 주세요." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		
		[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"CertificationStatus"];
		
	} else if ([rtcode isEqualToString:@"-9010"]) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"인증 실패" 
								message:@"인증 코드가 틀렸습니다.\n 인증번호를 확인해주세요." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		
		UITextField *authNumberTextField = (UITextField *)[self.view viewWithTag:ID_AUTHNUMBER];
		if(authNumberTextField != nil) {
			[authNumberTextField becomeFirstResponder];
		}
	} else if ([rtcode isEqualToString:@"-9030"]) {
		// TODO: 처리오류. 예외처리 필요
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"인증 실패" 
								message:@"인증 번호 확인에 실패하였습니다.\n잠시후 다시 시도하여 주시기 바랍니다." 
								delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"CertificationStatus"];
//	} else if ([rtcode isEqualToString:@"-9010"]) {
//		// TODO: 인증번호가 다름
//		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"인증실패" message:@"인증번호가 다름니다. \n인증번호를 새로 발급 받으세요." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
//		[alertView show];
//		[alertView release];
//		
	} else {
		// TODO: 기타오류 예외처리 필요
		// fail (-9030, -1080 이외 기타오류)
	}
}

-(void)mobilePhoneNumberAuthSending:(NSNotification *)notification
{
	
	// TODO: blockview 제거
	[authBlockView dismissAlertView];
	[authBlockView release];
	
	USayHttpData *data = (USayHttpData*)[notification object];
	//노티피케이션 제거
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"mobilePhoneNumberAuthSending" object:nil];
	if (data == nil) {
		// 200 이외의 에러
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"발송실패" message:@"처음부터 다시\n시도 해주시기 바랍니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
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
	}  else if ([rtcode isEqualToString:@"-1080"]) {
		// TODO: 이미 존재하는 이용자임. 예외처리 필요
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"가입 실패" message:@"이미 등록된 폰번호 입니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"CertificationStatus"];
	}else if ([rtcode isEqualToString:@"-1042"]) {
		// TODO: 인증번호 일일 요청한도 초과
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"인증 번호 요청 제한" message:@"1일 5회까지만 인증 번호 \n요청을 하실 수 있습니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
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

