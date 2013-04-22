//
//  EditGroupViewController.m
//  USayApp
//
//  Created by Jong-Sung Park on 10. 6. 24..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "EditGroupViewController.h"
#import "GroupInfo.h"
#import "UserInfo.h"
#import "HttpAgent.h"
#import "json.h"
#import "USayHttpData.h"
#import "blockView.h"
#import "USayAppAppDelegate.h"

#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation EditGroupViewController
@synthesize editGroupInfo, groupDelKind, editGroupDelegate;
#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
    }
    return self;
}
*/


#pragma mark -
#pragma mark View lifecycle
//navigationbar left button event
-(void)backBarButtonClicked {
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	NSArray* dbDataReload = [GroupInfo findByColumn:@"ID" value:self.editGroupInfo.ID];

	for(GroupInfo* reloadgroup in dbDataReload){
		self.editGroupInfo = reloadgroup;
	}

	[self.tableView reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
	//create custombutton navigationbarleftbutton
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
	
//20101007
//	[self addCustomFooterView];
	
	self.view.backgroundColor = ColorFromRGB(0xedeff2);
}

-(void)addCustomFooterView {
	UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 90.0)];
	customView.backgroundColor = [UIColor clearColor];
	
	UIImage* onlyNormalImage = [UIImage imageNamed:@"btn_del_group_normal.png"];
	UIImage* onlyClickedImage = [UIImage imageNamed:@"btn_del_group_focus.png"];
	UIButton* customOnlyButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[customOnlyButton addTarget:self action:@selector(delOnlyGroup) forControlEvents:UIControlEventTouchUpInside];
	[customOnlyButton setImage:[onlyNormalImage stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] forState:UIControlStateNormal];
	[customOnlyButton setImage:[onlyClickedImage stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
	customOnlyButton.frame = CGRectMake(customView.frame.origin.x, customView.frame.origin.y+4, customView.frame.size.width, 38.0);	
	[customView addSubview:customOnlyButton];
	
	UIImage* allNormalImage = [UIImage imageNamed:@"btn_del_all_group_normal.png"];
	UIImage* allClickedImage = [UIImage imageNamed:@"btn_del_all_group_focus.png"];
	UIButton* customAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[customAllButton addTarget:self action:@selector(delAllInGroup) forControlEvents:UIControlEventTouchUpInside];
	[customAllButton setImage:[allNormalImage stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] forState:UIControlStateNormal];
	[customAllButton setImage:[allClickedImage stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
	customAllButton.frame = CGRectMake(customView.frame.origin.x, customView.frame.origin.y+48, customView.frame.size.width, 38.0);	
	[customView addSubview:customAllButton];
	
	self.tableView.tableFooterView = customView;
	[customView release];
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	
	
	
	if([alertView.message isEqualToString:@"삭제 하시겠습니까?"] && buttonIndex==1)
	{
		
#if TARGET_IPHONE_SIMULATOR	
		NSLog(@"delOnlyGroup");
#endif
		self.groupDelKind = [NSString stringWithFormat:@"groupDelete"];
		[self requestDeleteGroup:@"N" withGroupId:self.editGroupInfo.ID];
		
		
	}
	
	
	if([alertView.message isEqualToString:@"모든 주소록을 삭제 하시겠습니까?"] && buttonIndex==1)
	{
		
		
#if TARGET_IPHONE_SIMULATOR	
		NSLog(@"delAllInGroup");
#endif
		self.groupDelKind = [NSString stringWithFormat:@"allDelete"];
		[self requestDeleteGroup:@"Y" withGroupId:self.editGroupInfo.ID];
		
		
		
	}
	
}

-(void)delOnlyGroup{
	
	
	
		
		UIAlertView *alertView = [[UIAlertView alloc] 
								  initWithTitle:@"삭제 알림" message:@"삭제 하시겠습니까?" delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"확인", nil];
		[alertView show];
		[alertView release];
		
			
	
	
	if([self appDelegate].connectionType == -1){
		UIAlertView* offlineAlert = [[UIAlertView alloc] initWithTitle:@"오프라인"
															   message:@"현재 네트워크 연결이 불가능한 상태 입니다.\nUsay의 모든 기능을 이용하기 위해서는 네트워크 연결이 필요합니다." 
															  delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
		[offlineAlert show];
		[offlineAlert release];
		return;
		
	}
}

-(void)delAllInGroup {
	
	
	
	UIAlertView *alertView = [[UIAlertView alloc] 
							  initWithTitle:@"삭제 알림" message:@"모든 주소록을 삭제 하시겠습니까?" delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"확인", nil];
	[alertView show];
	[alertView release];
	
	if([self appDelegate].connectionType == -1){
		UIAlertView* offlineAlert = [[UIAlertView alloc] initWithTitle:@"오프라인"
															   message:@"현재 네트워크 연결이 불가능한 상태 입니다.\nUsay의 모든 기능을 이용하기 위해서는 네트워크 연결이 필요합니다." 
															  delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
		[offlineAlert show];
		[offlineAlert release];
		return;
		
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

-(void)requestDeleteGroup:(NSString*)include withGroupId:(NSString*)gid{
	
	// TODO: blockView 사용
	editGroupBlock = [[blockView alloc] initWithFrame:CGRectMake(0.0, 0.0, 250.0, 150.0)];
	editGroupBlock.alertText = @"그룹 데이터 통신 중...";
	editGroupBlock.alertDetailText = @"잠시만 기다려 주세요.";
	[editGroupBlock show];
	
		
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteGroup:) name:@"deleteGroup" object:nil];
	
	NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:
								[[self appDelegate] getSvcIdx],@"svcidx",
								gid, @"id",
								@"mobile", @"sidDeleted",
								include, @"include",
								nil];
	
	SBJSON *json = [[SBJSON alloc] init];
	[json setHumanReadable:YES];
	NSLog(@"deleteGroup >> %@",[json stringWithObject:bodyObject error:nil]);
	[json release];
	USayHttpData *data = [[[USayHttpData alloc]initWithRequestData:@"deleteGroup" andWithDictionary:bodyObject timeout:10]autorelease];	
//	assert(data != nil);		
	[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
}

-(void)deleteGroup:(NSNotification *)notification {
	
	
	
	
	
	NSString* revisionPoint = [[NSUserDefaults standardUserDefaults] objectForKey:@"RevisionPoints"];
	
	NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:
								[[self appDelegate] getSvcIdx],@"svcidx",
								(revisionPoint == nil) ? @"0" : revisionPoint, @"RP",
								nil];
	USayHttpData *data2 = [[[USayHttpData alloc]initWithRequestData:@"getLastAfterRP" andWithDictionary:bodyObject timeout:10] autorelease];	
	//	assert(data != nil);		
	[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data2];
	
	
	
	
	NSLog(@"딜리트그룹 노티 왜 안들어오냐??");
	USayHttpData *data = (USayHttpData*)[notification object];
	 [[NSNotificationCenter defaultCenter] removeObserver:self name:@"deleteGroup" object:nil];
	// TODO : blockView제거
	[editGroupBlock dismissAlertView];
	[editGroupBlock release];
	if (data == nil) {
		// 200 이외의 에러
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" 
															message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0009)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
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
//		NSString *count = [dic objectForKey:@"count"];
		NSString *RP = [dic objectForKey:@"RP"];
		if([rtType isEqualToString:@"list"]){			
			// Key and Dictionary as its value type
			NSArray* userArray = [dic objectForKey:@"list"];
			
			[self syncDataBase:userArray withRevisionPoint:RP];
			
		}
		
	} else if ([rtcode isEqualToString:@"-9010"]) {
		// TODO: 데이터를 찾을 수 없음
//		[editGroupBlock dismissAlertView];
//		[editGroupBlock release];
	} else if ([rtcode isEqualToString:@"-9020"]) {
		// TODO: 잘못된 인자가 넘어옴
//		[editGroupBlock dismissAlertView];
//		[editGroupBlock release];
	} else if ([rtcode isEqualToString:@"-9030"]) {
		// TODO: 처리 오류
//		[editGroupBlock dismissAlertView];
//		[editGroupBlock release];
	} else {
		// TODO: 기타오류 예외처리 필요
//		[editGroupBlock dismissAlertView];
//		[editGroupBlock release];
	}
}

-(void) syncDataBase:(NSArray*)delArray withRevisionPoint:(NSString*)revisionPoint{
	
	for(NSDictionary* delItem in delArray){
		if([self.groupDelKind isEqualToString:@"groupDelete"]){//그룹만 삭제하고 해당 유저는 기본 그룹으로 이동
			if([[delItem objectForKey:@"gid"] length] > 0){ //그룹 삭제.
				NSLog(@"groupDelete");
				NSString* groupId = [delItem objectForKey:@"gid"];
				NSString* sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE ID=?",[GroupInfo tableName]];
				NSLog(@"delete group sql %@", sql);
				[GroupInfo findWithSqlWithParameters:sql, groupId, nil];
			}
			if([[delItem objectForKey:@"id"] length]>0){// 유저 정보가 있으면 기본 그룹으로 변경
				NSString* UserId = [delItem objectForKey:@"id"];
				NSString* sql = [NSString stringWithFormat:@"UPDATE %@ SET GID='0' WHERE ID=?",[UserInfo tableName]];
				NSLog(@"delete group sql %@", sql);
				[UserInfo findWithSqlWithParameters:sql, UserId, nil];
			}
		}else if([self.groupDelKind isEqualToString:@"allDelete"]){//그룹과 그룹안의 모든 유저 삭제.
			NSLog(@"allDelete");
			if([[delItem objectForKey:@"gid"] length] > 0){ //그룹 삭제.
				NSString* groupId = [delItem objectForKey:@"gid"];
				NSString* sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE ID=?",[GroupInfo tableName]];
				[GroupInfo findWithSqlWithParameters:sql, groupId, nil];
			}
			if([[delItem objectForKey:@"id"] length]>0){// 유저 정보가 있으면 기본 그룹으로 변경
				NSString* UserId = [delItem objectForKey:@"id"];
				NSString* sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE ID=?",[UserInfo tableName]];
				[UserInfo findWithSqlWithParameters:sql, UserId, nil];
			}
		}
	}
	
	//데이터 베이스에 저장후 마지막 동기화 포인트 저장
	if(revisionPoint != nil && [revisionPoint length] > 0){
		if([revisionPoint intValue] > [[[NSUserDefaults standardUserDefaults] objectForKey:@"RevisionPoints"] intValue]){
			NSString* revisionPoints = [[NSString alloc] initWithFormat:@"%@",revisionPoint];
			[[NSUserDefaults standardUserDefaults] setObject:revisionPoints forKey:@"RevisionPoints"];
			[revisionPoints release];
		}
		
	}
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	NSLocale *locale = [NSLocale currentLocale];
	[formatter setLocale:locale];
	[formatter setDateFormat:@"yyyyMMddHHmmss"];
	NSDate *today = [NSDate date];
	NSString *lastSyncDate = [[NSString alloc] initWithFormat:@"%@",[formatter stringFromDate:today]];
	
	if(revisionPoint != nil && [revisionPoint length] > 0){
		[[NSUserDefaults standardUserDefaults] setObject:lastSyncDate forKey:@"lastSyncDate"];
	}
	
	[lastSyncDate release];
	[formatter release];
	
//	[editGroupBlock dismissAlertView];
//	[editGroupBlock release];
	[self.editGroupDelegate editGroupDataInfo];
	
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)updateGroupWithGroupInfo:(GroupInfo*)value {
	// 그룹명 변경시 이름 변경 처리	
	self.editGroupInfo.GROUPTITLE = value.GROUPTITLE;
	[self.tableView reloadData];
	[self.editGroupDelegate editGroupDataInfo];
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
    
    static NSString *CellIdentifier = @"editGroupCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
		
		cell.textLabel.textColor = ColorFromRGB(0x2284ac);
		cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0];
		cell.detailTextLabel.textColor = ColorFromRGB(0x7c7c86);
		cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:17.0];
		
    }
    cell.textLabel.text = @"그룹명";
	cell.detailTextLabel.text = self.editGroupInfo.GROUPTITLE;
    // Configure the cell...
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	
	NSLog(@"indexpath = %d", indexPath.row);

	AddGroupViewController* addGroupController = [[AddGroupViewController alloc] initWithStyle:UITableViewStyleGrouped];
//	addGroupController.hidesBottomBarWhenPushed = YES;
	addGroupController.groupChanged = self.editGroupInfo;
//	addGroupController.title = @"그룹명 변경";
	addGroupController.addDelegate = self;
	
	UIView *titleView = [[UIView alloc] initWithFrame:addGroupController.navigationItem.titleView.bounds];
//	assert(titleView != nil);
	UIFont *titleFont = [UIFont systemFontOfSize:20];
	CGSize titleStringSize = [@"그룹명 변경" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
//	assert(titleFont != nil);
	UILabel *naviTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
//	assert(naviTitleLabel != nil);
	[naviTitleLabel setFont:titleFont];
	naviTitleLabel.textAlignment = UITextAlignmentCenter;
	[naviTitleLabel setTextColor:ColorFromRGB(0x053844)];
	[naviTitleLabel setBackgroundColor:[UIColor clearColor]];
	[naviTitleLabel setText:@"그룹명 변경"];
//	naviTitleLabel.shadowColor = [UIColor whiteColor];
	[titleView addSubview:naviTitleLabel];	
	[naviTitleLabel release];
	addGroupController.navigationItem.titleView = titleView;
	[titleView release];
	addGroupController.navigationItem.titleView.frame = CGRectMake((addGroupController.tableView.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);
	
	
	[self.navigationController pushViewController:addGroupController animated:YES];
	[addGroupController release];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
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
	[super viewDidLoad];
}


- (void)dealloc {
//	if(editGroupInfo)[editGroupInfo release];
//	if(groupDelKind)[groupDelKind release];
    [super dealloc];
}


@end

