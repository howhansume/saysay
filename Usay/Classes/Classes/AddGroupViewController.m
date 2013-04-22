//
//  AddGroupViewController.m
//  USayApp
//
//  Created by Jong-Sung Park on 10. 6. 20..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "AddGroupViewController.h"
#import "USayHttpData.h"
#import "GroupInfo.h"
#import "UserInfo.h"
#import "HttpAgent.h"
#import "json.h"
#import "blockView.h"
#import "USayAppAppDelegate.h"
//#import "MyDeviceClass.h"			// sochae 2010.09.11 - UI Position
#import "USayDefine.h"			// sochae 2010.09.13

#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
@implementation AddGroupViewController
@synthesize groupChanged, userList, addDelegate;
#pragma mark -
#pragma mark Initialization
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
	self = [super initWithStyle:style];
	if (self != nil) {
		
    }
    return self;
}

#pragma mark -
#pragma mark View lifecycle
-(void)backBarButtonClicked {
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)completedClicked {
	
	
	NSString* revisionPoint = [[NSUserDefaults standardUserDefaults] objectForKey:@"RevisionPoints"];
	
	NSDictionary *bodyObject2 = [NSDictionary dictionaryWithObjectsAndKeys:
								[[self appDelegate] getSvcIdx],@"svcidx",
								(revisionPoint == nil) ? @"0" : revisionPoint, @"RP",
								nil];
	USayHttpData *data2 = [[[USayHttpData alloc]initWithRequestData:@"getLastAfterRP" andWithDictionary:bodyObject2 timeout:10] autorelease];	
	//	assert(data != nil);		
	[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data2];
	
	
	
	//저장 완료를 받은 후에 popViewControllerAnimated 호출
//	NSUInteger newPath[] = {0, 0};
//	NSIndexPath *row0IndexPath = [NSIndexPath indexPathWithIndexes:newPath length:2];
	
	UITextField* value = (UITextField*)[self.tableView viewWithTag:1];
	[value resignFirstResponder];
	
	NSString* fieldGroupName = [NSString stringWithFormat:@"%@",value.text];
	fieldGroupName = [fieldGroupName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//#if TARGET_IPHONE_SIMULATOR	
	DebugLog(@"fieldGroupName : %@", fieldGroupName);
//#endif
	if([self appDelegate].connectionType == -1){
		UIButton* rightButton = (UIButton*)self.navigationItem.rightBarButtonItem;
		rightButton.enabled = NO;
		UIAlertView* offlineAlert = [[UIAlertView alloc] initWithTitle:@"오프라인"
															   message:@"현재 네트워크 연결이 불가능한 상태 입니다.\nUsay의 모든 기능을 이용하기 위해서는 네트워크 연결이 필요합니다." 
															  delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
		[offlineAlert show];
		[offlineAlert release];
		return;
		
	}
	
	if([self displayTextLength:fieldGroupName] > 30){
		UIAlertView* textLenErr = [[UIAlertView alloc] initWithTitle:@"그룹 이름 제한" message:@"그룹명은 한글 15자리 까지 입니다." 
															delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
		[textLenErr show];
		[textLenErr release];
		[value becomeFirstResponder];
		return;
	}else if([self displayTextLength:fieldGroupName] < 1){
		UIAlertView* textLenErr = [[UIAlertView alloc] initWithTitle:@"그룹 이름 제한" message:@"그룹명은 최소 1자 이상 입력하셔야합니다." 
															delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
		[textLenErr show];
		[textLenErr release];
		[value becomeFirstResponder];
		return;
	}
	
	NSString* groupStrName = nil;
	NSArray* groupArray = [GroupInfo findAll];
	BOOL isFindGroup = NO;
	
	for(GroupInfo* groupName in groupArray){
		NSString* equalGroupName = [NSString stringWithString:groupName.GROUPTITLE];
		
		if([equalGroupName caseInsensitiveCompare:fieldGroupName] == NSOrderedSame){
			UIAlertView* textLenErr = [[UIAlertView alloc] initWithTitle:@"그룹 생성 제한" message:@"같은 그룹 이름이 있습니다.\n다른 그룹 이름으로 입력해 주세요." 
																delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
			[textLenErr show];
			[textLenErr release];
			[value becomeFirstResponder];
			return;			
		}
	}
	if(isFindGroup == NO) {
		groupStrName = [NSString stringWithFormat:@"%@",fieldGroupName];
	}
	
	GroupInfo* groupData = [[GroupInfo alloc] init];
	
	DebugLog(@"GroupTitle : %@",groupStrName);
	
	
	groupData.GROUPTITLE = groupStrName;
	
	// TODO: blockView 사용
	addGroupBlock = [[blockView alloc] initWithFrame:CGRectMake(0.0, 0.0, 250.0, 150.0)];
	addGroupBlock.alertText = @"그룹 정보 전송 중...";
	addGroupBlock.alertDetailText = @"잠시만 기다려 주세요.";
	[addGroupBlock show];
	
	if(self.groupChanged != nil){
		groupData.ID = self.groupChanged.ID;
		groupData.SIDUPDATED = @"mobile";
		
		//20101017 요청전에 알피 호출
		
		NSString* revisionPoint = [[NSUserDefaults standardUserDefaults] objectForKey:@"RevisionPoints"];
		
		NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:
									[[self appDelegate] getSvcIdx],@"svcidx",
									(revisionPoint == nil) ? @"0" : revisionPoint, @"RP",
									nil];
		USayHttpData *data = [[[USayHttpData alloc]initWithRequestData:@"getLastAfterRP" andWithDictionary:bodyObject timeout:10] autorelease];	
		//	assert(data != nil);		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
		
		
		
		[self requestUpdateGroup:groupData];
		[groupData release];
	}else{
		groupData.SIDCREATED = @"mobile";
		
		
		
		NSString* revisionPoint = [[NSUserDefaults standardUserDefaults] objectForKey:@"RevisionPoints"];
		
		NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:
									[[self appDelegate] getSvcIdx],@"svcidx",
									(revisionPoint == nil) ? @"0" : revisionPoint, @"RP",
									nil];
		USayHttpData *data = [[[USayHttpData alloc]initWithRequestData:@"getLastAfterRP" andWithDictionary:bodyObject timeout:10] autorelease];	
		//	assert(data != nil);		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
		
		
		
		
		[self requestAddGroup:groupData];
		[groupData release];
	}
	
}

- (void)viewDidDisappear:(BOOL)animated 
{
    [super viewDidDisappear:animated];
}

-(USayAppAppDelegate *) appDelegate
{
	return [[UIApplication sharedApplication] delegate];
}

- (void)viewDidLoad {
	
	self.view.backgroundColor = ColorFromRGB(0xedeff2);
	UIImage* rightBarBtnImg = [[UIImage imageNamed:@"btn_top_complete.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	UIImage* rightBarBtnSelImg = [[UIImage imageNamed:@"btn_top_complete_focus.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[rightBarButton addTarget:self action:@selector(completedClicked) forControlEvents:UIControlEventTouchUpInside];
	[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
	[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
	rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
	self.navigationItem.rightBarButtonItem = rightButton;
	[rightButton release];
	
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
	
	
	UIView* tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 35.0)];
	tableHeaderView.backgroundColor = self.tableView.backgroundColor;

	// sochae 2010.09.11 - UI Position
	//CGRect rect = [MyDeviceClass deviceOrientation];
	CGRect rect = self.view.frame;
	// ~sochae
	UIFont *informationFont = [UIFont systemFontOfSize:15];
	CGSize infoStringSize = [@"그룹명을 입력해 주세요. 한글 최대 15자" sizeWithFont:informationFont constrainedToSize:(CGSizeMake(rect.size.width-30.0, 20.0f))];
	UILabel *informationLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 13, rect.size.width-40.0, infoStringSize.height)];
	[informationLabel setFont:informationFont];
	[informationLabel setTextColor:ColorFromRGB(0x313b48)];
	[informationLabel setBackgroundColor:[UIColor clearColor]];
	[informationLabel setText:@"그룹명을 입력해 주세요. 한글 최대 15자"];
	[tableHeaderView addSubview:informationLabel];
	[informationLabel release];
	
	UILabel *titleLabel = [[UILabel alloc] init];
	titleLabel.textColor = [UIColor colorWithRed:97.0/255.0 green:92.0/255.0 blue:92.0/255.0 alpha:1.0f];
	titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.numberOfLines = 2;
	[tableHeaderView addSubview:titleLabel];
	titleLabel.frame = CGRectMake(15, 5, 292, 35);
	titleLabel.text = @"그룹명을 입력해 주세요. 한글 최대 15자";
	self.tableView.tableHeaderView = tableHeaderView;
	[titleLabel release];
	[tableHeaderView release];
	
    [super viewDidLoad];
	self.tableView.scrollEnabled = NO;
	
    // Uncomment the following line to preserve selection between presentations.
	
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */
#pragma mark -
#pragma mark network Method

// 그룹 추가 요청
-(BOOL)requestAddGroup:(GroupInfo*)addGroupData{

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addGroup:) name:@"addGroup" object:nil];
	NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:
								addGroupData.GROUPTITLE, @"title",
								addGroupData.SIDCREATED, @"sidCreated",
								[[self appDelegate] getSvcIdx], @"svcidx",
								nil];
	
//	SBJSON *json = [[SBJSON alloc] init];
//	[json setHumanReadable:YES];
//	NSLog(@"addGroup >> %@",[json stringWithObject:bodyObject error:nil]);
//	[json release];
	
	USayHttpData *data = [[[USayHttpData alloc]initWithRequestData:@"addGroup" andWithDictionary:bodyObject timeout:10]autorelease];	
//	assert(data != nil);		
	[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
	return YES;
}

-(void)addGroup:(NSNotification *)notification {
	USayHttpData *data = (USayHttpData*)[notification object];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"addGroup" object:nil];
	// TODO: blockView 제거
	[addGroupBlock dismissAlertView];
	[addGroupBlock release];
	if (data == nil) {

		// 200 이외의 에러
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" 
															message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0010)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return;
	}
	
	//	NSString *api = data.api;	
	NSString *resultData = data.responseData;
	DebugLog(@"+ http result data : %@", resultData);

	// 1. Create BSJSON parser.
	SBJSON *jsonParser = [[SBJSON alloc] init];
	
	// 2. Get the result dictionary from the response string.
	NSDictionary *dic = (NSDictionary*)[jsonParser objectWithString:resultData error:NULL];
	[jsonParser release];
	// 3. Show response
	// key and value type
	NSString *rtcode = nil;
	rtcode = [dic objectForKey:@"rtcode"];	// 프로토콜문서에는 result로 되어 있는것을 rtcode로 변경
	DebugLog(@"+ rtcode : %@, ", rtcode );
	if ([rtcode isEqualToString:@"0"]) {	// success
		NSString *rtType = [dic objectForKey:@"rttype"];
		NSString *RP = [dic objectForKey:@"RP"];  //마지막 동기화 RP
		DebugLog(@"+ rtType : %@, RP : %@ ", rtType, RP );
		if ([rtType isEqualToString:@"map"]) {
			NSDictionary *addressDic = [dic objectForKey:@"map"];
			NSMutableArray* serverData = [NSMutableArray array];
			if(addressDic != nil){
				id groupData = (NSMutableDictionary*)[[GroupInfo alloc] init];
				NSArray* keyArray = [addressDic allKeys];
				for(NSString* key in keyArray) {
					if([key isEqualToString:@"title"]){ 
						[groupData  setValue:[addressDic objectForKey:key] forKey:@"GROUPTITLE"];
					}else {
						[groupData  setValue:[addressDic objectForKey:key] forKey:[key uppercaseString]];
					}
				}
				[serverData addObject:groupData];
				[groupData release];
			}
			[self syncDataSaveDB:serverData withRevisionPoint:RP];
		}
		
	} else if ([rtcode isEqualToString:@"-9010"]) {
		// TODO: 데이터를 찾을 수 없음
		UIAlertView* failAlert = [[UIAlertView alloc] initWithTitle:@"그룹 추가 실패" 
															message:@"그룹 추가를 실패하였습니다.(-9010)" 
														   delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[failAlert show];
		[failAlert release];
		UITextField* value = (UITextField*)[self.tableView viewWithTag:1];
		[value resignFirstResponder];
	} else if ([rtcode isEqualToString:@"-9020"]) {
		// TODO: 잘못된 인자가 넘어옴
		UIAlertView* failAlert = [[UIAlertView alloc] initWithTitle:@"그룹 추가 실패" 
															message:@"그룹 추가를 실패하였습니다.(-9020)" 
														   delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[failAlert show];
		[failAlert release];
		UITextField* value = (UITextField*)[self.tableView viewWithTag:1];
		[value resignFirstResponder];
	} else if ([rtcode isEqualToString:@"-9030"]) {
		// TODO: 처리 오류
		UIAlertView* failAlert = [[UIAlertView alloc] initWithTitle:@"그룹 추가 실패" 
															message:@"그룹 추가를 실패하였습니다.(-9030)" 
														   delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[failAlert show];
		[failAlert release];
		UITextField* value = (UITextField*)[self.tableView viewWithTag:1];
		[value resignFirstResponder];
	} else {
		// TODO: 기타오류 예외처리 필요
		NSString* errCode = [NSString stringWithFormat:@"그룹 추가를 실패하였습니다.(%@)",rtcode];
		UIAlertView* failAlert = [[UIAlertView alloc] initWithTitle:@"그룹 추가 실패" 
															message:errCode 
														   delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[failAlert show];
		[failAlert release];
		UITextField* value = (UITextField*)[self.tableView viewWithTag:1];
		[value resignFirstResponder];
	}
}

-(BOOL)requestUpdateGroup:(GroupInfo*)GroupData {
	//노티피케이션 설정
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateGroup:) name:@"updateGroup" object:nil];
	NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:
								[[self appDelegate] getSvcIdx],@"svcidx",
								GroupData.ID, @"id",
								GroupData.GROUPTITLE, @"title",
								GroupData.SIDUPDATED, @"sidUpdated",
								nil];
	
	SBJSON *json = [[SBJSON alloc] init];
	[json setHumanReadable:YES];
	NSLog(@"updateGroup >> %@",[json stringWithObject:bodyObject error:nil]);
	[json release];
	USayHttpData *data = [[[USayHttpData alloc]initWithRequestData:@"updateGroup" andWithDictionary:bodyObject timeout:10]autorelease];	
//	assert(data != nil);		
	[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
	return YES;
	
}

-(void)updateGroup:(NSNotification *)notification {
	USayHttpData *data = (USayHttpData*)[notification object];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateGroup" object:nil];
	[addGroupBlock dismissAlertView];
	[addGroupBlock release];
	if (data == nil) {
		// 200 이외의 에러
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" 
															message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0011)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
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
		NSString *rtType = [dic objectForKey:@"rttype"];
		NSString *RP = [dic objectForKey:@"RP"];  //마지막 동기화 RP
		if ([rtType isEqualToString:@"map"]) {
			NSDictionary *addressDic = [dic objectForKey:@"map"];
			NSMutableArray* serverData = [NSMutableArray array];
			if(addressDic != nil){
				id groupData = (NSMutableDictionary*)[[GroupInfo alloc] init];
				NSArray* keyArray = [addressDic allKeys];
				for(NSString* key in keyArray) {
					if([key isEqualToString:@"title"]) 
						[groupData  setValue:[addressDic objectForKey:key] forKey:@"GROUPTITLE"];
					else
						[groupData  setValue:[addressDic objectForKey:key] forKey:[key uppercaseString]];
				}
				[serverData addObject:groupData];
				[groupData release];
			}
			[self syncDataSaveDB:serverData withRevisionPoint:RP];
		}
		
	} else if ([rtcode isEqualToString:@"-9010"]) {
		// TODO: 데이터를 찾을 수 없음
		UIAlertView* failAlert = [[UIAlertView alloc] initWithTitle:@"그룹 이름 변경 실패" 
															message:@"그룹 추가를 실패하였습니다.(-9010)" 
														   delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[failAlert show];
		[failAlert release];
		UITextField* value = (UITextField*)[self.tableView viewWithTag:1];
		[value resignFirstResponder];
	} else if ([rtcode isEqualToString:@"-9020"]) {
		// TODO: 잘못된 인자가 넘어옴
		UIAlertView* failAlert = [[UIAlertView alloc] initWithTitle:@"그룹 이름 변경 실패" 
															message:@"그룹 추가를 실패하였습니다.(-9020)" 
														   delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[failAlert show];
		[failAlert release];
		UITextField* value = (UITextField*)[self.tableView viewWithTag:1];
		[value resignFirstResponder];
	} else if ([rtcode isEqualToString:@"-9030"]) {
		// TODO: 처리 오류
		UIAlertView* failAlert = [[UIAlertView alloc] initWithTitle:@"그룹 이름 변경 실패" 
															message:@"그룹 추가를 실패하였습니다.(-9030)" 
														   delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[failAlert show];
		[failAlert release];
		UITextField* value = (UITextField*)[self.tableView viewWithTag:1];
		[value resignFirstResponder];
	} else {
		// TODO: 기타오류 예외처리 필요
		NSString* errCode = [NSString stringWithFormat:@"그룹 추가를 실패하였습니다.(%@)",rtcode];
		UIAlertView* failAlert = [[UIAlertView alloc] initWithTitle:@"그룹 이름 변경 실패" 
															message:errCode 
														   delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[failAlert show];
		[failAlert release];
		UITextField* value = (UITextField*)[self.tableView viewWithTag:1];
		[value resignFirstResponder];
	}
	
}

-(void)syncDataSaveDB:(NSArray*)dataArray withRevisionPoint:(NSString *)revisionPoint {
	//NSString* revisionPoints = nil;
	if(dataArray != nil){
		for(GroupInfo* groupData in dataArray){
	//		revisionPoints = groupData.RPCREATED;
			DebugLog(@"update group %@ ID %@", groupData.GROUPTITLE, groupData.ID);
//			for(UserInfo* gidChgUser in self.userList){
//				gidChgUser.GID =groupData.ID;
//				[gidChgUser saveData];
//			}
			[groupData saveData];
			[self.addDelegate updateGroupWithGroupInfo: groupData];
		}
	}
	if(revisionPoint == nil)
		[[NSUserDefaults standardUserDefaults] setObject:revisionPoint forKey:@"RevisionPoints"];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	NSLocale *locale = [NSLocale currentLocale];
	[formatter setLocale:locale];
	[formatter setDateFormat:@"yyyyMMddHHmmss"];
	NSDate *today = [NSDate date];
	NSString *lastSyncDate = [[NSString alloc] initWithFormat:@"%@",[formatter stringFromDate:today]];
	[[NSUserDefaults standardUserDefaults] setObject:lastSyncDate forKey:@"lastSyncDate"];
	[lastSyncDate release];
	[formatter release];	
	
	[self.navigationController popViewControllerAnimated:YES];
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
    
    static NSString *CellIdentifier = @"addGroupCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		
		UITextField* textField = [[UITextField alloc] 
								  initWithFrame:CGRectMake(10.0, 10.0, cell.contentView.frame.size.width-35, 30)];
		textField.font = [UIFont systemFontOfSize:20];
		textField.tag = 1;
		textField.delegate = self;
		textField.clearButtonMode = UITextFieldViewModeWhileEditing;
		textField.textColor = ColorFromRGB(0x7c7c86);
		textField.returnKeyType = UIReturnKeyDone;
		textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		[cell.contentView addSubview:textField];
		[textField release];
		
    }
    
    // Configure the cell...
	UITextField* groupNameField = (UITextField*)[cell.contentView viewWithTag:1];
	if(self.groupChanged != nil){
		groupNameField.text = self.groupChanged.GROUPTITLE;
	}
	[groupNameField becomeFirstResponder];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	[self completedClicked];
	return NO;
}
#pragma mark -
#pragma mark Table view delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44;
}

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
#pragma mark deltailView data update delegate Method

-(void)updateDataValue:(NSString*)value forkey:(NSString*)key{
	
}

-(void)updateDataWithArray:(NSArray*)value forkey:(NSString*)key {
	
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
	if(groupChanged)[groupChanged release];
	if(userList)[userList release];
    [super dealloc];
}


@end

