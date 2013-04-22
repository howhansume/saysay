//
//  ManagedObjectMultiSelectionListEditor.m
//  USayApp
//
//  Created by Jong-Sung Park on 10. 6. 22..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "EditAddressGroupMultiSelectionViewController.h"
#import "GroupInfo.h"
#import "UserInfo.h"
#import "HttpAgent.h"
#import "json.h"
#import "USayHttpData.h"
#import <objc/runtime.h>
#import "blockView.h"
#import "USayAppAppDelegate.h"
//#import "MyDeviceClass.h"			// sochae 2010.09.11 - UI Position
#import "USayDefine.h"

#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define kTitleLabel 8201
@implementation EditAddressGroupMultiSelectionViewController
@synthesize list;
@synthesize keypath;
@synthesize labelString;
@synthesize customTableView, userList, selectedGroup, moveDelegate, peopleInGroup;


-(void)backBarButtonClicked {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated 
{
	
	if(self.customTableView == nil){
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
		
		
		
		UIImage* rightBarBtnImg = [UIImage imageNamed:@"btn_top_complete.png"];
		UIImage* rightBarBtnSelImg = [UIImage imageNamed:@"btn_top_complete_focus.png"];
		UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[rightBarButton addTarget:self action:@selector(rightButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
		[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
		[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
		rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
		UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
		self.navigationItem.rightBarButtonItem = rightButton;
		[rightButton release];
		
		
		
		CGRect mainViewBounds = self.view.bounds;
		self.view.backgroundColor = ColorFromRGB(0xedeff2);
		CGRect tableFrame = CGRectMake(CGRectGetMinX(mainViewBounds), 
									   CGRectGetMinY(mainViewBounds), 
									   CGRectGetWidth(mainViewBounds), 
									   CGRectGetHeight(mainViewBounds));
		
		customTableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStyleGrouped];
		//	[customTableView sizeToFit];
		customTableView.delegate = self;
		customTableView.dataSource = self;
		self.customTableView.backgroundColor = [UIColor clearColor];
		
		
		[self.view addSubview:customTableView];
		
		[self addCustomHeaderView];
		[self addCustomFooterView];
	//	[self addCustomBottomToolBarView];
		
		self.selectedGroup = [[NSMutableArray alloc] init];
	}
	[super viewWillAppear:animated];
	
}

-(void)viewDidLoad
{
	
}

-(void)createNewGroup {
	AddGroupViewController* addGroupController = [[AddGroupViewController alloc] initWithStyle:UITableViewStyleGrouped];
	addGroupController.hidesBottomBarWhenPushed = YES;
//	addGroupController.title = @"새그룹 생성";
	
	UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
//	assert(titleView != nil);
	UIFont *titleFont = [UIFont systemFontOfSize:20];
	CGSize titleStringSize = [@"새그룹 생성" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
//	assert(titleFont != nil);
	UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
//	assert(titleLabel != nil);
	[titleLabel setFont:titleFont];
	titleLabel.textAlignment = UITextAlignmentCenter;
	[titleLabel setTextColor:ColorFromRGB(0x053844)];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	[titleLabel setText:@"새그룹 생성"];
//	titleLabel.shadowColor = [UIColor whiteColor];
	[titleView addSubview:titleLabel];	
	[titleLabel release];
	addGroupController.navigationItem.titleView = titleView;
	[titleView release];
	addGroupController.navigationItem.titleView.frame = CGRectMake((self.view.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);
	
	
//	addGroupController.userList = self.userList;
	addGroupController.addDelegate = self;
	[self.navigationController pushViewController:addGroupController animated:YES];
	[addGroupController release];
}

-(void)addCustomHeaderView {
	UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 
																  self.customTableView.frame.size.width, 37.0)];
	customView.backgroundColor = [UIColor clearColor];
//	UIImageView* customImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"text_move_group.png"]];
//	customImageView.frame = CGRectMake(0.0, 9.0, self.customTableView.frame.size.width, 33.0);
//	[customView addSubview:customImageView];
	// sochae 2010.09.11 - UI Position
	//CGRect rect = [MyDeviceClass deviceOrientation];
	CGRect rect = self.view.frame;
	// ~sochae
	UIFont *informationFont = [UIFont systemFontOfSize:14];
	CGSize infoStringSize = [@"그룹을 선택하고 완료 버튼을 클릭해주세요." sizeWithFont:informationFont constrainedToSize:(CGSizeMake(rect.size.width-10.0, 20.0f))];
	UILabel *informationLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 13, rect.size.width-20.0, infoStringSize.height)];
	[informationLabel setFont:informationFont];
	[informationLabel setTextColor:ColorFromRGB(0x313b48)];
	[informationLabel setBackgroundColor:[UIColor clearColor]];
	[informationLabel setText:@"그룹을 선택하고 완료 버튼을 클릭해주세요."];
	[customView addSubview:informationLabel];
	[informationLabel release];
	self.customTableView.tableHeaderView = customView;
	[customView release];
}

-(void)addCustomFooterView {
	UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.customTableView.frame.size.width, 46.0)];
	customView.backgroundColor = [UIColor clearColor];

	UIImage* normalImage = [UIImage imageNamed:@"btn_newgroup.png"];
	UIImage* clickedImage = [UIImage imageNamed:@"btn_newgroup_over.png"];
	UIButton* customImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[customImageButton addTarget:self action:@selector(createNewGroup) forControlEvents:UIControlEventTouchUpInside];
	[customImageButton setImage:[normalImage stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] forState:UIControlStateNormal];
	[customImageButton setImage:[clickedImage stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
	customImageButton.frame = customView.frame;	
	[customView addSubview:customImageButton];
	self.customTableView.tableFooterView = customView;
	[customView release];
}

-(void)addCustomBottomToolBarView {
	CGRect mainViewBounds = self.view.bounds;
	buttonToolBar = [UIToolbar new];
	buttonToolBar.barStyle = UIBarStyleDefault;
	
	// size up the toolbar and set its frame
	[buttonToolBar sizeToFit];
	CGFloat toolbarHeight = (CGFloat)46.0;
	[buttonToolBar setFrame:CGRectMake(CGRectGetMinX(mainViewBounds),
									   CGRectGetMinY(mainViewBounds) + CGRectGetHeight(mainViewBounds) - (toolbarHeight) + 2.0,
									   CGRectGetWidth(mainViewBounds),
									   toolbarHeight)];
	
//	UIImage* customImage = [UIImage imageNamed:@"moveaddr_bg_toolbar.png"];

    buttonToolBar.backgroundColor = [UIColor clearColor];
	buttonToolBar.tintColor = [UIColor clearColor];

	[self.view addSubview:buttonToolBar];
	
	//버튼생성
	UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			  target:nil
																			  action:nil];
	
	// create a special tab bar item with a custom image and title
	// Create a final modal view controller
	UIImage* leftNormalImage = [UIImage imageNamed:@"moveaddr_btn_cancel.png"];
	UIImage* leftClieckImage = [UIImage imageNamed:@"moveaddr_btn_cancel_over.png"];
	UIButton* modalleftViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[modalleftViewButton addTarget:self action:@selector(leftButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[modalleftViewButton setImage:[leftNormalImage stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] forState:UIControlStateNormal];
	[modalleftViewButton setImage:[leftClieckImage stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] forState:UIControlStateSelected];
	modalleftViewButton.frame = CGRectMake(0.0, 0.0, leftNormalImage.size.width, leftNormalImage.size.height);	
	modalleftViewButton.backgroundColor = [UIColor blackColor];
	UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:modalleftViewButton];
	
	// create a bordered style button with custom title
	UIImage* rightNormalImage = [UIImage imageNamed:@"moveaddr_btn_move.png"];
	UIImage* rightClickImage = [UIImage imageNamed:@"moveaddr_btn_move_over.png"];
	UIButton* modalrightViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[modalrightViewButton addTarget:self action:@selector(rightButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[modalrightViewButton setImage:[rightNormalImage stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] forState:UIControlStateNormal];
	[modalrightViewButton setImage:[rightClickImage stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] forState:UIControlStateSelected];
	modalrightViewButton.frame = CGRectMake(0.0, 0.0, rightNormalImage.size.width, rightNormalImage.size.height);	
	modalrightViewButton.backgroundColor = [UIColor blackColor];
	UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:modalrightViewButton];
	
	
	NSArray *items = [NSArray arrayWithObjects:flexItem, leftButtonItem, rightButtonItem,flexItem,  nil];
	[buttonToolBar setItems:items animated:NO];
	
//	[modalleftViewButton release];
//	[modalrightViewButton release];
	[flexItem release];
	[leftButtonItem release];
	[rightButtonItem release];
	
}
#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Relinquish ownership any cached data, images, etc that aren't in use.
}
- (void)dealloc {
//	[keypath release];
//    [labelString release];
//    [list release];
	[customTableView release];
//	[userList release];
	[selectedGroup release];
    [super dealloc];
}

-(IBAction)leftButtonClicked:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)rightButtonClicked:(id)sender {
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
	
	UIAlertView *alertView;
	if([self.selectedGroup count] > 0){
		alertView = [[UIAlertView alloc] initWithTitle:@"주소 이동" 
														message:@"확인 버튼을 누르시면\n 그룹을 이동합니다." 
													   delegate:self 
											  cancelButtonTitle:@"취소" otherButtonTitles:@"확인", nil];
	}
	else {
		alertView = [[UIAlertView alloc] initWithTitle:@"주소 이동" 
											   message:@"그룹을 선택해 주세요." 
											  delegate:self 
									 cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
	}

	[alertView show];
	[alertView release];
}

#pragma mark -
#pragma mark Table View Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [list count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSUInteger row = [indexPath row];
	if([self.selectedGroup count] > 0){
		NSIndexPath* oldIndexPath = [self.selectedGroup objectAtIndex:0];
		if(row != [oldIndexPath row]){
			UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
			oldCell.accessoryType = UITableViewCellAccessoryNone;
			oldCell.accessoryView = nil;
			[self.selectedGroup removeObjectAtIndex:[self.selectedGroup indexOfObject:oldIndexPath]];
			UILabel* oldTitleLabel = (UILabel*)[oldCell viewWithTag:kTitleLabel];
			oldTitleLabel.textColor = ColorFromRGB(0x285f7a);
			UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
			newCell.accessoryType = UITableViewCellAccessoryCheckmark;
			newCell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CheckIcon.png"]]autorelease];
			UILabel* newTitleLabel = (UILabel*)[newCell viewWithTag:kTitleLabel];
			newTitleLabel.textColor = ColorFromRGB(0x7c7c86);
			[self.selectedGroup addObject:indexPath];
		}
	}else {
		UITableViewCell *beginCell = [tableView cellForRowAtIndexPath:indexPath];
		beginCell.accessoryType = UITableViewCellAccessoryCheckmark;
		beginCell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CheckIcon.png"]]autorelease];
		UILabel* newTitleLabel = (UILabel*)[beginCell viewWithTag:kTitleLabel];
		newTitleLabel.textColor = ColorFromRGB(0x7c7c86);
		[self.selectedGroup addObject:indexPath];
	}
	
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *GenericManagedObjectListSelectorCell = 
    @"GenericManagedObjectMultiSelectorCell";
    
    UITableViewCell *cell = [tableView 
                             dequeueReusableCellWithIdentifier:GenericManagedObjectListSelectorCell];
	
	NSUInteger row = [indexPath row];
	NSUInteger oldRow = -1;
	if([self.selectedGroup count] >0){
		NSIndexPath* oldIndexPath = [self.selectedGroup objectAtIndex:0];
		oldRow = [oldIndexPath row];
	}

    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 
                                       reuseIdentifier:GenericManagedObjectListSelectorCell] autorelease];
		
		CGRect lbRect = CGRectMake(10.0f, 10.0f, 180.0f, 20.0f);
		UILabel* titleLabel = [[UILabel alloc] initWithFrame:lbRect];
		titleLabel.frame = lbRect;
		if(indexPath.row == 0 && oldRow == -1)
		{
			titleLabel.textColor = ColorFromRGB(0x7c7c86);
		}
		else {
			titleLabel.textColor = ColorFromRGB(0x285f7a);
		}
		titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
		titleLabel.textAlignment = UITextAlignmentLeft;
		titleLabel.tag = kTitleLabel;
		[cell.contentView addSubview:titleLabel];
		[titleLabel release];
		
    }
	
  
	
	DebugLog(@"oldRow = %d", oldRow);
	
	GroupInfo* dataItem = [list objectAtIndex:row];
	UILabel* groupTitleLabel = (UILabel*)[cell viewWithTag:kTitleLabel];
    groupTitleLabel.text = dataItem.GROUPTITLE;
	
	NSArray *nameSection = [self.peopleInGroup objectForKey:dataItem.GROUPTITLE];
	
	groupTitleLabel.text =[NSString stringWithFormat:@"%@(%i)",dataItem.GROUPTITLE, [nameSection count]];
	
	
//	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	//움직였을대 클릭한거랑 이전꺼랑 같으면 아이콘을 보여줌..
	if(row == oldRow){
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		cell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CheckIcon.png"]]autorelease];
	}
	else if(oldRow == -1 && indexPath.row ==0)
	{
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		cell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CheckIcon.png"]]autorelease];
		[self.selectedGroup addObject:indexPath];
			
	}
	else{
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.accessoryView = nil;
	}
	
    return cell;
}
- (void)viewDidDisappear:(BOOL)animated 
{
    [super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	//	NSLog(@"alert button index %i", buttonIndex);
	if(buttonIndex == 1){
		NSUInteger selRow = [[self.selectedGroup objectAtIndex:0] row];
		DebugLog(@"selRow = %i", selRow);
		GroupInfo* dataItem = [list objectAtIndex:selRow];
	//20101012 안써서 주석처리	UITableViewCell* cell = [self.customTableView cellForRowAtIndexPath:[self.selectedGroup objectAtIndex:0]];
	//20101010	UILabel* cellTitleLable = (UILabel*)[cell viewWithTag:kTitleLabel];
		for(GroupInfo* checkedGroup in self.list){
			if([checkedGroup.GROUPTITLE isEqualToString:dataItem.GROUPTITLE]){
				// TODO: blockView 사용
				moveGroupBlock = [[blockView alloc] initWithFrame:CGRectMake(0.0, 0.0, 250.0, 150.0)];
				moveGroupBlock.alertText = @"주소 이동 중...";
				moveGroupBlock.alertDetailText = @"잠시만 기다려 주세요.";
				[moveGroupBlock show];
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				NSString* revisionPoint = [[NSUserDefaults standardUserDefaults] objectForKey:@"RevisionPoints"];
				
				NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:
											[[self appDelegate] getSvcIdx],@"svcidx",
											(revisionPoint == nil) ? @"0" : revisionPoint, @"RP",
											nil];
				USayHttpData *data = [[[USayHttpData alloc]initWithRequestData:@"getLastAfterRP" andWithDictionary:bodyObject timeout:10] autorelease];	
				//	assert(data != nil);		
				[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
				
				
				
				
				
				
				
				
				[self requestUpdateListContact:self.userList withGroup:checkedGroup];
				break;
			}
		}
	}
}

-(void)updateGroupWithGroupInfo:(GroupInfo*)value {
	
	NSMutableArray* groupList = [NSMutableArray arrayWithArray:self.list];
	if(value != nil){
		[groupList addObject:value];
		NSSortDescriptor *groupNameSort = [[NSSortDescriptor alloc] initWithKey:@"GROUPTITLE" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
		[groupList sortUsingDescriptors:[NSArray arrayWithObject:groupNameSort]];
		[groupNameSort release];
		for(int g=0;g<[groupList count];g++){
			GroupInfo* tempGroup = [groupList objectAtIndex:g];
			GroupInfo* instGroup = [[GroupInfo alloc] init];
			NSAutoreleasePool* varpool = [[NSAutoreleasePool alloc] init];
			unsigned int numIvars = 0;
			Ivar* ivars = class_copyIvarList([instGroup class], &numIvars);
			for(int i = 0; i < numIvars; i++) {
				Ivar thisIvar = ivars[i];
				NSString * classkey = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
				if([tempGroup valueForKey:classkey] && [tempGroup valueForKey:classkey] != nil)
					[instGroup  setValue:[tempGroup valueForKey:classkey] forKey:classkey];
			}
			if(numIvars > 0)free(ivars);
			[varpool release];
			if([tempGroup.ID isEqualToString:@"0"]){
				[groupList removeObject:tempGroup];
				[groupList insertObject:instGroup atIndex:0];
				[instGroup release];
				break;
			}else {
				[instGroup release];
			}
			
		}
		
		self.list = nil;
		self.list = groupList;
		[self.customTableView reloadData];
		[self.moveDelegate createGroupInMove];
	}
}

#pragma mark -
#pragma mark move multi address user to select group network Method

-(BOOL)requestUpdateListContact:(NSArray *)dicData withGroup:(GroupInfo*)selGroup{
	DebugLog(@"requestUpdateListContact");
	//사용자 정보 저장
	NSDictionary *rpdict = nil, *contactDic = nil;
//	NSDictionary *contactCnt = nil;
//	NSString	*body = nil;
	NSString	*listbody = nil;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateListContact:) name:@"updateListContact" object:nil];
	

	NSMutableArray* contactList = [NSMutableArray array];
	
	for(UserInfo *userData in dicData){
		userData.SIDUPDATED = @"mobile";
		NSMutableDictionary *contact = [[NSMutableDictionary alloc] initWithCapacity:0];
		NSAutoreleasePool* varpool = [[NSAutoreleasePool alloc] init];
		unsigned int numIvars = 0;
		Ivar* ivars = class_copyIvarList([userData class], &numIvars);
		for(int i = 0; i < numIvars; i++) {
			Ivar thisIvar = ivars[i];
			NSString * key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
		//	if([userData valueForKey:key] != nil){
			if([key isEqualToString:@"ID"])
				[contact setObject:[userData valueForKey:key] forKey:[key lowercaseString]];
			if([key isEqualToString:@"GID"])
				[contact setObject:[userData valueForKey:key] forKey:[key lowercaseString]];
			if([key isEqualToString:@"SIDUPDATED"])
				[contact setObject:[userData valueForKey:key] forKey:[key lowercaseString]];
		//	}
		}
		if(numIvars > 0)free(ivars);
		[varpool release];
		[contactList addObject:contact];
		[contact release];
	}	
	
	NSMutableArray* paramArray = [NSMutableArray array];
		
	rpdict = [NSDictionary dictionaryWithObjectsAndKeys:
			  selGroup.ID, @"gid",						//selectgid
			  nil];
	
	[paramArray addObject:rpdict];
	
	contactDic = [NSDictionary dictionaryWithObjectsAndKeys: 
				  contactList,  @"contact",
				  nil];
	
	[paramArray addObject:contactDic];
	// JSON 라이브러리 생성
	SBJSON *json = [[SBJSON alloc]init];
	[json setHumanReadable:YES];
	// 변환
	listbody = [json stringWithObject:paramArray error:nil];
	
	NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:
								[[self appDelegate] getSvcIdx],@"svcidx",
								listbody, @"param",
								nil];
	
	// 변환
//	body = [json stringWithObject:bodyObject error:nil];
	//	DebugLog(@"%@",listbody);
//	DebugLog(@"%@",body);	//선택된 그룹아이디 넣기
	[json release];
	USayHttpData *data = [[[USayHttpData alloc]initWithRequestData:@"updateListContact" andWithDictionary:bodyObject timeout:10]autorelease];
//	assert(data != nil);		
	[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
	return YES;
}

-(USayAppAppDelegate *) appDelegate
{
	return (USayAppAppDelegate *)[[UIApplication sharedApplication] delegate];
}

-(void)updateListContact:(NSNotification *)notification {
	
	USayHttpData *data = (USayHttpData*)[notification object];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateListContact" object:nil];
	[moveGroupBlock dismissAlertView];
	[moveGroupBlock release];
	if (data == nil) {
		
		// 200 이외의 에러
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" 
															message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0012)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
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
//		NSString *count = [dic objectForKey:@"count"];		
		if([rtType isEqualToString:@"list"]){			
			// Key and Dictionary as its value type
			NSArray* userArray = [dic objectForKey:@"list"];

			[self syncDataSaveDB:userArray];
					
		}
		
	} else if ([rtcode isEqualToString:@"-9010"]) {
		// TODO: 데이터를 찾을 수 없음
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"업데이트 실패" 
								message:@"수정하려는 데이터를\n찾지 못하였습니다.(-9010)" 
								delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
//		[moveGroupBlock dismissAlertView];
//		[moveGroupBlock release];
	} else if ([rtcode isEqualToString:@"-9020"]) {
		// TODO: 잘못된 인자가 넘어옴
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"업데이트 실패" 
															message:@"수정하려는 데이터에\n맞지 않는 데이터가 들어 있습니다.(-9020)" 
														   delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
//		[moveGroupBlock dismissAlertView];
//		[moveGroupBlock release];
	} else if ([rtcode isEqualToString:@"-9030"]) {
		// TODO: 처리 오류
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"업데이트 실패" 
															message:@"데이터 처리중\n오류가 발생하였습니다.(-9030)" 
														   delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		
//		[moveGroupBlock dismissAlertView];
//		[moveGroupBlock release];
	} else {
		// TODO: 기타오류 예외처리 필요
		NSString* alertStr = [NSString stringWithFormat:@"오류 발생으로 데이터를 처리하지 못하였습니다.(%@)",rtcode];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"업데이트 실패" 
															message:alertStr 
														   delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		
//		[moveGroupBlock dismissAlertView];
//		[moveGroupBlock release];
	}
	
}

#pragma mark -
#pragma mark sync data base Method
- (void)syncDataSaveDB:(NSArray*)moveUserData {
//	UITableViewCell* cell = [self.customTableView cellForRowAtIndexPath:[self.selectedGroup objectAtIndex:0]];
//	UILabel* cellTitleLable = (UILabel*)[cell viewWithTag:kTitleLabel];
	
	NSUInteger selRow = [[self.selectedGroup objectAtIndex:0] row];
	DebugLog(@"selRow = %i", selRow);
	GroupInfo* dataItem = [list objectAtIndex:selRow];
	
	
	//mezzo 20101010 그룹명(숫자)로 바뀌면서 바꿔줘야 함
	
	for(GroupInfo* checkedGroup in self.list){
	//	if([checkedGroup.GROUPTITLE isEqualToString:cellTitleLable.text]){
		if([checkedGroup.GROUPTITLE isEqualToString:dataItem.GROUPTITLE]){
			NSString* strGroupId = nil;
			for(NSDictionary* groupDic in moveUserData){
				for(NSString* key in [groupDic allKeys]){
					if([key isEqualToString:@"gid"]){
						DebugLog(@"group move gid %@",[groupDic objectForKey:@"gid"]);
						strGroupId = [NSString stringWithFormat:@"%@",[groupDic objectForKey:@"gid"]];
						break;
					}
				}
			}
			
			for(NSDictionary* moveDic in moveUserData){
				
				NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
				NSLocale *locale = [NSLocale currentLocale];
				[formatter setLocale:locale];
				[formatter setDateFormat:@"yyyyMMddHHmmss"];
				NSDate *today = [NSDate date];
				NSString *modifydate = [[NSString alloc] initWithFormat:@"%@",[formatter stringFromDate:today]];
				
				
				
//				for(NSString* key in [moveDic allKeys]){
					if([moveDic objectForKey:@"id"]){
						DebugLog(@"group move id %@",[moveDic objectForKey:@"id"]);
						NSString* userid = [NSString stringWithFormat:@"%@",[moveDic objectForKey:@"id"]];
						//그룹이동시 수정일도 수정되게 변경. 2010.12.03
						NSString* sql = [NSString stringWithFormat:@"UPDATE %@ SET GID=?, OEMMODIFYDATE='%@' WHERE ID=?",[UserInfo tableName], modifydate];
						
						DebugLog(@"sql = %@", sql);
						
						[UserInfo findWithSqlWithParameters:sql,strGroupId, userid,nil];
					}
				
				
				[formatter release];
				[modifydate release];
//				}
			}
		}
	}
	[self.moveDelegate updateMovetoGroup];
//	if(moveGroupBlock && moveGroupBlock != nil){
//		[moveGroupBlock dismissAlertView];
//		[moveGroupBlock release];
//	}
	[self.navigationController popViewControllerAnimated:YES];
}

@end
