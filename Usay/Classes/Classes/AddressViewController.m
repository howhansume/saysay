//
//  AddressViewController.m
//  USayApp
//

//  Created by Jong-Sung Park on 10. 5. 18..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "AddressViewController.h"
#import "USayAppAppDelegate.h"
#import "CustomHeaderView.h"
#import "ApplicationCell.h"
#import "UserInfo.h"
#import "GroupInfo.h"
#import "MessageInfo.h"
#import "MessageUserInfo.h"
#import "CellMsgListData.h"
#import "CellMsgData.h"
#import "NSArray-NestedArrays.h"
#import "SayViewController.h"
#import "MessageViewController.h"
#import "InviteMsgViewController.h"
#import "UIImageView+WebCache.h"
#import "json.h"
#import "USayHttpData.h"
#import "HttpAgent.h"
#import <objc/runtime.h>
#import "AddrUserInfo.h"
#import "ProfileInfo.h"
#import "AddressInfoView.h"
#import "AddressButtonView.h"
#import "USayDefine.h"
//#import "MyDeviceClass.h"			// sochae 2010.09.11 - UI Position

#define HANGUL_BEGIN_UNICODE	44032	// 가
#define HANGUL_END_UNICODE		55203	// 힣
/*
 Predefined colors to alternate the background color of each cell row by row (see tableView:cellForRowAtIndexPath: and tableView:willDisplayCell:forRowAtIndexPath:).
 */
#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
								green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
								blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation AddressViewController
@synthesize filteredHistory, viewList, peopleInGroup, searchArray, allGroups, allNames; //
@synthesize statusGroup, peopleInBuddy, currentTableView, selectedPerson, profileUser, checkSelectImage;

@synthesize	msgSearchArray,chosungNumArray;
@synthesize	chosungArray;
@synthesize	jungsungArray;
@synthesize	jongsungArray;

#pragma mark -
#pragma mark View lifecycle
-(BOOL)convertBoolValue:(NSString *)boolString {
	if(boolString != nil){
		if([boolString isEqualToString:@"YES"])
			return YES;
		else
			return NO;
	}
	return NO;
}

-(USayAppAppDelegate *)appDelegate
{
	return [[UIApplication sharedApplication] delegate];
}
-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	
	
	
	
	
	//탭번호는 뷰가 나타난후에 적용된다.
	NSInteger tabItemSelected = self.tabBarController.selectedIndex;
	NSLog(@"tab select didappear = %i", tabItemSelected);
	
	//탭 시간을 알아내자..
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	NSLocale *locale = [NSLocale currentLocale];
	[formatter setLocale:locale];
	[formatter setDateFormat:@"yyyyMMddHHmmss"];
	NSDate *today = [NSDate date];
	NSString *lastSyncDate = [[NSString alloc] initWithFormat:@"%@",[formatter stringFromDate:today]];
	

	if (tabItemSelected == 1) {
		UITabBarItem *tbi = [[self appDelegate].rootController.tabBar.items objectAtIndex:1];
		tbi.badgeValue = nil;
		
			
	
		
		[[NSUserDefaults standardUserDefaults] setValue:lastSyncDate forKey:@"myDate"];
		
	
		//뷰가 나타나면 업데이트를 무조건 널값으로 바꾼다 
			NSString* newsql = [NSString stringWithFormat:@"UPDATE %@ SET CHANGEDATE2 =?",[UserInfo tableName]];
			[UserInfo findWithSqlWithParameters:newsql,[NSNull null],nil];
		
		
		
		
	
	}
	if(![[NSUserDefaults standardUserDefaults] objectForKey:@"myDate"])
	{
		NSLog(@"없으면 새로 만드..");
		[[NSUserDefaults standardUserDefaults] setValue:lastSyncDate forKey:@"myDate"];
		
		
	}
	
	
	
	
	
	[self reloadAddressData];
	[self.currentTableView reloadData];
	
	
}
	
	
	
	
	
-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	NSLog(@"===================VIEWWILL APPEAR %@ ======================", self.currentTableView);
		if([self appDelegate].inEnterBackGround){
		NSLog(@"=============>RELOAD ADRESS DATA===========");
	//	[self reloadAddressData];
		[self appDelegate].inEnterBackGround = NO;
	}
	//mezzo 뱃지 삭제
		
	

}



-(void)keyboardDidShow:(NSNotification *)notif
{
	
//	NSLog(@"keyboard");
	MFMessageComposeViewController *myPicker = (MFMessageComposeViewController*)self.modalViewController;
	if(![myPicker.navigationBar.topItem.title isEqualToString:@"새로운 메세지"])
	{

//	[myPicker dismissModalViewControllerAnimated:YES];
	myPicker.navigationBar.topItem.title=@"";
//		myPicker.navigationBar.alpha=1;
//	myPicker.navigationBar.alpha=1;	myPicker.navigationBar.alpha=1;
	}
	
}

-(void)keyboardDisappear:(NSNotification *)notif
{
	
	
	NSLog(@"keyboard");
	MFMessageComposeViewController *myPicker = (MFMessageComposeViewController*)self.modalViewController;
	if(![myPicker.navigationBar.topItem.title isEqualToString:@"새로운 메세지"])
	{

//	myPicker.navigationBar.alpha=0.001;
	
	//	[myPicker dismissModalViewControllerAnimated:YES];
	myPicker.navigationBar.topItem.title=@"";
	}
}


-(void)keyboardWillAppear:(NSNotification *)notif
{
	
	

//	NSLog(@"===================keyboardWillAppear==================");
	
	MFMessageComposeViewController *myPicker = (MFMessageComposeViewController*)self.modalViewController;

	if(![myPicker.navigationBar.topItem.title isEqualToString:@"새로운 메세지"])
	{
		myPicker.navigationBar.topItem.title=@"";
		if(pickerTitleView == NULL)
		{
			pickerTitleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
		}

		UIFont *titleFont = [UIFont systemFontOfSize:20];
		// sochae 2010.09.11 - UI Position
		//CGRect rect = [MyDeviceClass deviceOrientation];
		CGRect rect = self.view.frame;
		// ~sochae
	#ifdef MEZZO_DEBUG
		NSLog(@"rect = %f %f", myPicker.navigationBar.frame.size.width, self.view.frame.size.width);
	#endif
		CGSize titleStringSize = [self.title sizeWithFont:titleFont constrainedToSize:(CGSizeMake(rect.size.width-120.0, MAXFLOAT))];
	#ifdef MEZZO_DEBUG
		NSLog(@"size x y = %f, %f", titleStringSize.width, titleStringSize.height);
	#endif
		
		
		
		if([pickerTitleLabel subviews])
			[pickerTitleLabel removeFromSuperview];
		
		
		if([pickerTitleView superview])
			[pickerTitleView removeFromSuperview];

		
		if(pickerTitleLabel == NULL)
		{
			pickerTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 44.0f)];
		}
		

		
		if(myPicker.navigationBar.frame.size.width == 320.0f)
		{
			[pickerTitleLabel setFrame:CGRectMake(0, 0, 320, 44)];
		}
		else {
			[pickerTitleLabel setFrame:CGRectMake(0, 0, 480, 30)];
		}
		[pickerTitleLabel setFont:titleFont];
		pickerTitleLabel.textAlignment = UITextAlignmentCenter;
		[pickerTitleLabel setTextColor:ColorFromRGB(0x053844)];
		[pickerTitleLabel setBackgroundColor:[UIColor clearColor]];
		[pickerTitleLabel setText:@"새로운 메시지"];
		[pickerTitleView addSubview:pickerTitleLabel];	
	//	[titleLabel release];
		[myPicker.navigationBar addSubview:pickerTitleView];
	/*
		MFMessageComposeViewController *myPicker = (MFMessageComposeViewController*)self.modalViewController;
		//	[myPicker dismissModalViewControllerAnimated:YES];
		myPicker.navigationBar.topItem.title=@"";

	*/	
		
		UIButton *cancelButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 47, 31)]autorelease];
		[cancelButton setBackgroundImage:[UIImage imageNamed:@"btn_searchbar_cancel.png"] forState:UIControlStateNormal];
		[cancelButton setBackgroundImage:[UIImage imageNamed:@"btn_searchbar_cancel_focus.png"] forState:UIControlStateHighlighted];
		[cancelButton addTarget:self action:@selector(cancelModal) forControlEvents:UIControlEventTouchUpInside];
		UIBarButtonItem *rightButton = [[[UIBarButtonItem alloc] initWithCustomView:cancelButton] autorelease];
		
		myPicker.navigationBar.topItem.rightBarButtonItem=rightButton;
	}
	
}

-(void)movetabBar
{
	
	//이동 후 대화 초대까지 //20101006
	self.tabBarController.selectedIndex=2;
	//[[self appDelegate].rootController.tabBarController.navigationController
	NSLog(@"tab = %@", [[self appDelegate].rootController.viewControllers objectAtIndex:2]);
	
	
	UINavigationController* tmpNavi = [[self appDelegate].rootController.viewControllers objectAtIndex:2];
	if (tmpNavi) {
	
		
		MessageViewController* MsgView = (MessageViewController*)[tmpNavi.viewControllers objectAtIndex:0];
		[MsgView sayButtonClicked];
		
		/*
		if (proposeUserViewController ) {
			NSLog(@"here come");
			
			
			//	[((MessageViewController*)proposeUserNaviController) sayButtonClicked];
		}
	 */
	}
	
	/*
	UINavigationController *tmpNavi = [[self appDelegate].rootController.viewControllers objectAtIndex:2];
	NSLog(@"ffsdad =%@", tmpNavi.tabBarController.navigationController);
	MessageViewController *tmpMsgViewController = (MessageViewController*)[tmpNavi.tabBarController.navigationController.viewControllers objectAtIndex:0];
	NSLog(@"tmpMsg = %@", tmpMsgViewController);
	[tmpMsgViewController sayButtonClicked];
	*/
	
	
}

-(void)showEdit
{
	
	
	UIActionSheet* editMenu = [[UIActionSheet alloc] initWithTitle:@"" 
														  delegate:self
												 cancelButtonTitle:@"취소" 
											destructiveButtonTitle:nil 
												 otherButtonTitles:@"주소 이동",
							   @"주소 삭제",
							   @"그룹명 변경",
							   @"그룹 삭제",
							   nil];
	//@"주소록 편집하기", nil];
	
	editMenu.actionSheetStyle = UIActionSheetStyleDefault;
	//tabBar 컨트롤러의 하위 뷰일경우, actionsheet의 cancel버튼이 먹질 않는다. 
	//tabbarcontroller뷰의 상단에 보이게 한다.
	[editMenu showInView:self.tabBarController.view];
	[editMenu release];
	
	
	
	
/*탭을 하나하나 다 바꾸자....
 
	EditAddressViewController* editAddrController = [[EditAddressViewController alloc] init];
	editAddrController.peopleInGroup = self.peopleInGroup;
	editAddrController.editDelegate = self;
	editAddrController.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:editAddrController animated:YES];
	[editAddrController release];
	*/
	
	
}


- (void)viewDidLoad {
//	self.title = @"주소록";
//	if(isMemoryWarning == YES){
//		isMemoryWarning = NO;
//		[super viewDidLoad];
//		return;
//	}
//		
//	isMemoryWarning = NO;
	
	
#ifdef MEZZO_DEBUG
	NSLog(@"self tab %d", self.tabBarController.selectedIndex);
#endif
	
	//탭바 번호로 주소록인지 유세이친구란인지 구별한다. 20101004
	NSInteger tabItemSelected = self.tabBarController.selectedIndex;
	
	
	//키보드 감시
	
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:self.view.window
	 ];
	
	
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:self.view.window
	 ];
	
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self selector:@selector(keyboardDisappear:) name:UIKeyboardWillHideNotification object:self.view.window
	 ];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAddressData) name:@"reloadAddressData" object:nil];
	
	
	
	
	UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
	assert(titleView != nil);
	UIFont *titleFont = [UIFont systemFontOfSize:20];
	CGSize titleStringSize;
	if(tabItemSelected == 0)
		titleStringSize = [@"주소록" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
	else  if(tabItemSelected == 1){
		titleStringSize = [@"Usay친구" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
	}

	assert(titleFont != nil);
	UILabel *naviTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
	assert(naviTitleLabel != nil);
	[naviTitleLabel setFont:titleFont];
	naviTitleLabel.textAlignment = UITextAlignmentCenter;
	[naviTitleLabel setTextColor:ColorFromRGB(0x053844)];
	[naviTitleLabel setBackgroundColor:[UIColor clearColor]];
	if(tabItemSelected == 0)
	[naviTitleLabel setText:@"주소록"];
	else if(tabItemSelected == 1){
	[naviTitleLabel setText:@"Usay친구"];	
	}

//	naviTitleLabel.shadowColor = [UIColor whiteColor];
	[titleView addSubview:naviTitleLabel];	
	[naviTitleLabel release];
	self.navigationItem.titleView = titleView;
	[titleView release];
	self.navigationItem.titleView.frame = CGRectMake((self.tableView.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);
	
	
	
	
	if(self.currentTableView == nil)
		currentTableView = self.tableView;
	
//	self.searchDisplayController.searchBar.tintColor = [[self appDelegate] getColor:@"7ebccc"];
	
	UIView* segment = [self.searchDisplayController.searchBar.subviews objectAtIndex:0];
	if (segment) {
		segment.hidden = YES;
	}

	self.searchDisplayController.searchBar.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 45);
	
	UIImage *image = [[UIImage imageNamed: @"img_searchbar.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
    UIImageView *v = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
    [v setImage:image];
    NSArray *subs = self.searchDisplayController.searchBar.subviews;
    for (int i = 0; i < [subs count]; i++) {
        id subv = [self.searchDisplayController.searchBar.subviews objectAtIndex:i];
        if ([subv isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
            [v setFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 45)];
            [self.searchDisplayController.searchBar insertSubview:v atIndex:i];
        }
    }
    [v setNeedsDisplay];
    [v setNeedsLayout];
	
	//내비게이션 바 버튼 설정
	
	if (tabItemSelected == 0) {
		UIImage* leftBarBtnImg = [[UIImage imageNamed:@"kwanri.PNG"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
		UIImage* leftBarBtnSelImg = [[UIImage imageNamed:@"kwanri.PNG"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
		UIButton* leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[leftBarButton addTarget:self action:@selector(showEdit) forControlEvents:UIControlEventTouchUpInside];
		[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
		[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateHighlighted];
		leftBarButton.frame = CGRectMake(0.0, 0.0, leftBarBtnImg.size.width, leftBarBtnImg.size.height);	
		UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
		self.navigationItem.leftBarButtonItem = leftButton;
		[leftButton release];
		
	}
	/*
	else {
		UIImage* leftBarBtnImg = [[UIImage imageNamed:@"top_all_normal.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
		UIImage* leftBarBtnSelImg = [[UIImage imageNamed:@"top_all_focus.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	}
*/
	
	 
	
	if (tabItemSelected == 0) {
		
		UIImage* rightBarBtnImg = [[UIImage imageNamed:@"plus.PNG"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
		UIImage* rightBarBtnSelImg = [[UIImage imageNamed:@"plus.PNG"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
		
	
UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[rightBarButton addTarget:self action:@selector(addressEditButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
	[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateHighlighted];
	rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
	self.navigationItem.rightBarButtonItem = rightButton;
	[rightButton release];
		self.viewList = NO;
		
	}
	else if(tabItemSelected == 1){
		UIImage* rightBarBtnImg = [[UIImage imageNamed:@"btn_top_group_add.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
		UIImage* rightBarBtnSelImg = [[UIImage imageNamed:@"btn_top_group_add_focus.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
		UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[rightBarButton addTarget:self action:@selector(movetabBar) forControlEvents:UIControlEventTouchUpInside];
		[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
		[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateHighlighted];
		rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
		UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
		self.navigationItem.rightBarButtonItem = rightButton;
		[rightButton release];
		self.viewList = YES;
		
	}

	
	
	if([self appDelegate].connectionType == -1){
		UIButton* rightButton = (UIButton*)self.navigationItem.rightBarButtonItem;
		rightButton.enabled = NO;
	}

	self.peopleInGroup = [[NSMutableDictionary alloc] init];
	self.peopleInBuddy = [[NSMutableDictionary alloc] init];
	self.selectedPerson = [[NSMutableArray alloc] init];
	
	self.filteredHistory = [[NSMutableDictionary alloc] init];
	self.searchArray = [[NSMutableArray alloc] init];
	
	self.statusGroup = [[NSMutableDictionary alloc] init];

	self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
//	self.tableView.separatorColor=ColorFromRGB(0x8fcad9);
	
	
//	self.view.backgroundColor=ColorFromRGB(0x8fcad9);
//mezzo	self.tableView.separatorColor = ColorFromRGB(0xc2c2c3);
//	self.tableView.separatorColor = ColorFromRGB(0x86becc);
	
	self.searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	self.searchDisplayController.searchResultsTableView.separatorColor = ColorFromRGB(0xc2c2c3);
//	self.searchDisplayController.searchResultsTableView.separatorColor = ColorFromRGB(0x86BECC);

	self.tableView.rowHeight = 58.0;
	self.searchDisplayController.searchResultsTableView.rowHeight = 58.0;
////////////////////////////////////////////////////////////////////////	
	// 로컬 메모리 초기화. 데이터 베이스로 부터 모든 정보를 가져온다.
	
	
	
	[self.allNames removeAllObjects];
	[self.allGroups removeAllObjects];
	self.allNames = [NSMutableArray arrayWithArray:[UserInfo findAll]];
	self.allGroups = [NSMutableArray arrayWithArray:[GroupInfo findAll]];

	
	
	
	NSSortDescriptor *groupNameSort = [[NSSortDescriptor alloc] initWithKey:@"GROUPTITLE" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
	[self.allGroups sortUsingDescriptors:[NSArray arrayWithObject:groupNameSort]];
	[groupNameSort release];
	for(int g=0;g<[self.allGroups count];g++){
		GroupInfo* tempGroup = [self.allGroups objectAtIndex:g];
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
			[self.allGroups removeObject:tempGroup];
			[self.allGroups insertObject:instGroup atIndex:0];
			[instGroup release];
			break;
		}else {
			[instGroup release];
		}
		
	}	
	
	//이거 왜하냐????
	
	[self.peopleInGroup removeAllObjects];
	
	
	
	for(int i = 0;i < [self.allGroups count]; i++){
		GroupInfo* group = [self.allGroups objectAtIndex:i];
		[self.statusGroup setValue:@"YES" forKey:[NSString stringWithFormat:@"%i",i]];
//		NSLog(@"grouptitle %@",group.GROUPTITLE);
		NSMutableArray* arrayGroup = [NSMutableArray array];
		//여기 임시 주석 20101008
		for(UserInfo* person in allNames){
//trimleft 처리 필요			
//			NSMutableString* replace = [NSMutableString stringWithFormat:@"%@",person.STATUS];
//			person.STATUS = [replace stringByReplacingOccurrencesOfString:@" " withString:@""];
			
			if([person.GID isEqualToString:group.ID] && [person.ISBLOCK isEqualToString:@"N"]) {
				[arrayGroup addObject:person];
				if([person.ISFRIEND isEqualToString:@"S"] && person.CHANGEDATE != nil && [person.CHANGEDATE length] > 0){
				//	NSString* newsql = [NSString stringWithFormat:@"UPDATE %@ SET CHANGEDATE =? WHERE ID = ?",[UserInfo tableName]];
				//	[UserInfo findWithSqlWithParameters:newsql,[NSNull null], person.ID ,nil];
				}
//				NSLog(@"changedate %@",person.CHANGEDATE);
			}
		}
		
		 
		NSSortDescriptor *formattedSort = [[NSSortDescriptor alloc] initWithKey:@"FORMATTED" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
		NSSortDescriptor *nickNameSort = [[NSSortDescriptor alloc] initWithKey:@"PROFILENICKNAME" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
		[arrayGroup sortUsingDescriptors:[NSArray arrayWithObjects:formattedSort,nickNameSort, nil]];
		[nickNameSort release];
		[formattedSort release];
		
		[self.peopleInGroup setObject:arrayGroup forKey:group.GROUPTITLE];
	}
	
	
////////// 검색 관련 초기화 ////////////	
	self.searchDisplayController.searchBar.placeholder = @"초성검색, 전화번호 검색";
	self.msgSearchArray = [[NSMutableArray alloc] init];
	assert(self.msgSearchArray != nil);
	
	self.chosungNumArray = [[NSMutableArray alloc] init];
	assert(chosungNumArray != nil);
	[self.chosungNumArray addObject:[NSNumber numberWithInt:12593]];
	[self.chosungNumArray addObject:[NSNumber numberWithInt:12594]];
	[self.chosungNumArray addObject:[NSNumber numberWithInt:12596]];
	[self.chosungNumArray addObject:[NSNumber numberWithInt:12599]];
	[self.chosungNumArray addObject:[NSNumber numberWithInt:12600]];
	[self.chosungNumArray addObject:[NSNumber numberWithInt:12601]];
	[self.chosungNumArray addObject:[NSNumber numberWithInt:12609]];
	[self.chosungNumArray addObject:[NSNumber numberWithInt:12610]];
	[self.chosungNumArray addObject:[NSNumber numberWithInt:12611]];
	[self.chosungNumArray addObject:[NSNumber numberWithInt:12613]];
	[self.chosungNumArray addObject:[NSNumber numberWithInt:12614]];
	[self.chosungNumArray addObject:[NSNumber numberWithInt:12615]];
	[self.chosungNumArray addObject:[NSNumber numberWithInt:12616]];
	[self.chosungNumArray addObject:[NSNumber numberWithInt:12617]];
	[self.chosungNumArray addObject:[NSNumber numberWithInt:12618]];
	[self.chosungNumArray addObject:[NSNumber numberWithInt:12619]];
	[self.chosungNumArray addObject:[NSNumber numberWithInt:12620]];
	[self.chosungNumArray addObject:[NSNumber numberWithInt:12621]];
	[self.chosungNumArray addObject:[NSNumber numberWithInt:12622]];
	
	self.chosungArray = [[NSArray alloc] initWithObjects:@"ㄱ",@"ㄲ",@"ㄴ",@"ㄷ",@"ㄸ",@"ㄹ",@"ㅁ",@"ㅂ",@"ㅃ",@"ㅅ",@"ㅆ",@"ㅇ",@"ㅈ",@"ㅉ",@"ㅊ",@"ㅋ",@"ㅌ",@"ㅍ",@"ㅎ",nil];	
	self.jungsungArray = [[NSArray alloc] initWithObjects:@"ㅏ",@"ㅐ",@"ㅑ",@"ㅒ",@"ㅓ",@"ㅔ",@"ㅕ",@"ㅖ",@"ㅗ",@"ㅘ",@" ㅙ",@"ㅚ",@"ㅛ",@"ㅜ",@"ㅝ",@"ㅞ",@"ㅟ",@"ㅠ",@"ㅡ",@"ㅢ",@"ㅣ",nil];
	self.jongsungArray = [[NSArray alloc] initWithObjects:@"",@"ㄱ",@"ㄲ",@"ㄳ",@"ㄴ",@"ㄵ",@"ㄶ",@"ㄷ",@"ㄹ",@"ㄺ",@"ㄻ",@"ㄼ",@"ㄽ",@"ㄾ",@"ㄿ",@"ㅀ",@"ㅁ",@"ㅂ",@"ㅄ",@"ㅅ",@"ㅆ",@"ㅇ",@"ㅈ",@"ㅊ",@"ㅋ",@" ㅌ",@"ㅍ",@"ㅎ",nil];
////////////////////////////////
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getBuddyImstatus:) name:@"getBuddyImstatus" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(buddyPresenceChange:) name:@"buddyPresenceChange" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newFriendIncome:) name:@"newFriendIncome" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(buddyBlockCancel:) name:@"buddyBlockCancel" object:nil];	
	[[self appDelegate] getOnBuddyStatus]; // 버디의 상태 정보를 요청한다.
	
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	NSLocale *locale = [NSLocale currentLocale];
	[formatter setLocale:locale];
	[formatter setDateFormat:@"yyyyMMddHHmmss"];
	NSDate *today = [NSDate date];
	NSString *lastSyncDate = [[NSString alloc] initWithFormat:@"%@",[formatter stringFromDate:today]];
	
	int changecnt = 0;
	
	
	
	
	
	//메모리에서 변경된 값이 잇는지 검사한다..
	
	
	
	if(tabItemSelected == 0)
	{
		
		[[NSUserDefaults standardUserDefaults] setValue:@"2" forKey:@"userguide"];
		
		
		NSLog(@"didLoad 의 라스트 싱크 데이터 %@", lastSyncDate);
		
		
		for(int i = 0;i< [[peopleInGroup allKeys] count] ;i++){
			NSString* groupedkey = [[peopleInGroup allKeys] objectAtIndex:i];
			NSArray* groupedarray = [peopleInGroup objectForKey:groupedkey];
			for(UserInfo* changeuser in groupedarray){
				DebugLog(@"didLoad 유저의 의 라스트 싱크 데이터 %@", changeuser.CHANGEDATE);
				
				if([[changeuser.CHANGEDATE2 substringToIndex:8] isEqualToString:[lastSyncDate substringToIndex:8]])
					changecnt++;
			}
		}
		
		//	NSInteger nCount = [changePerson count];
		NSInteger nCount = changecnt;
		if (nCount == 0) {
			UITabBarItem *tbi = [[self appDelegate].rootController.tabBar.items objectAtIndex:1];
			if (tbi) {//할필요가 없다..
				tbi.badgeValue = nil;
			}
		} else if (nCount > 0) {
			UITabBarItem *tbi = [[self appDelegate].rootController.tabBar.items objectAtIndex:1];
			if (tbi) {
				NSLog(@"tbi 뱃지 값 = %@", tbi.badgeValue);
				tbi.badgeValue = [NSString stringWithFormat:@"%i", nCount];
			}
			[[self appDelegate] playSystemSoundIDSound];
			[[self appDelegate] playSystemSoundIDVibrate];
		} else {
			// skip
		}
	}
	[lastSyncDate release];
	[formatter release];

	//왜 주석처리 되어있나..? 해보면 알듯 ㅎㅎ
	//self.view.backgroundColor = ColorFromRGB(0x8fcad9);
	//self.searchDisplayController.searchResultsTableView.backgroundColor = ColorFromRGB(0x8fcad9);
	NSLog(@"startGetChangedProfileInfo inViewDidLoad");
	[self startGetChangedProfileInfo];
	
	
	
	
	//임시로 테이블에 1000개의 개인정보를 넣는다
	/*
	
	NSString *selectQuery = @"select * from _TUserInfo order by rpcreated desc limit 1";
	
	NSArray *resultArray = [UserInfo findWithSql:selectQuery];
	NSString *rpCreatedID;
	for(UserInfo* tmpUserInfo in resultArray)
	{
		rpCreatedID = tmpUserInfo.RPCREATED;
	}
	NSInteger rpInteger;
	rpInteger =[rpCreatedID intValue];
	
	for(int i=0; i<1000; i++)
	{
		rpInteger++;
		NSString *newRp = [NSString stringWithFormat:@"%i", rpInteger];
		NSString *mobilePhone = [NSString stringWithFormat:@"000%d", i];
		NSString *tmpName = [NSString stringWithFormat:@"mezzo%@", mobilePhone];
		
		
		NSString *insertQuery =[NSString stringWithFormat:@"insert into _TUserInfo (formatted, mobilephonenumber, rpcreated, isFriend,isTrash,isBlock,gid,imstatus)values('%@','%@','%@','N', 'N','N','0','0')", tmpName, mobilePhone, newRp];
		
		NSLog(@"insert Log = %@", insertQuery);
	
		[[UserInfo database] executeSql:insertQuery];
		

		
	}
	
	[[UserInfo database] commit];
	 
	 */
	
	
	if(tabItemSelected == 1)
	{
		NSLog(@"여긴 유세이 친구");
		
		
		
		
		
	//	[self onlyFriend];		
		
				
	
	}
	else {
		[[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"DATABASE"];
		
	}

	
	
	NSLog(@"viewdidload last = %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"lastSyncDate"]);
	
	[super viewDidLoad];
	
}

-(void)getBuddyImstatus:(NSNotification*)notification {
	NSArray* imstatusArray = (NSArray*)[notification object];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"getBuddyImstatus" object:nil];
	
	NSString *pkey = nil;					// 친구 pkey
	NSString *imstatus = nil;				// 0:offline  1:online  2:busy (바빠요)  8:곧 돌아옵니다.  16:다른용무중
	NSString *status = nil;					// 오늘의 한마디
	NSString *representphoto = nil;			// 대표사진 url
	
	if(imstatusArray != nil && [imstatusArray count] > 0){
		for (int i=0; i < [imstatusArray count]; i++) {
//			NSLog(@"====> getBuddyImstatus start<==========");
			NSDictionary *listDic = [imstatusArray objectAtIndex:i];
			assert(listDic != nil);
			
			pkey = [listDic objectForKey:@"pkey"];					
			imstatus = [listDic objectForKey:@"imstatus"];			
			status = [listDic objectForKey:@"status"];				
			representphoto = [listDic objectForKey:@"representphoto"];
			
			NSString* sql=nil;
//			NSMutableString* parameters = [NSMutableString string];
			
			if(imstatus != nil && [imstatus length] > 0){
	//			sql = [NSString stringWithFormat:@"UPDATE %@ SET IMSTATUS=? WHERE RPKEY=?",[UserInfo tableName]];
	//			[UserInfo findWithSqlWithParameters:sql,imstatus,pkey ,nil];
			}
			
			if(status != nil && [status length] > 0){
				sql = [NSString stringWithFormat:@"UPDATE %@ SET STATUS=? WHERE RPKEY=?",[UserInfo tableName]];
				[UserInfo findWithSqlWithParameters:sql,status,pkey ,nil];
			}
			
			if(representphoto != nil && [representphoto length] > 0){
				sql = [NSString stringWithFormat:@"UPDATE %@ SET REPRESENTPHOTO=? WHERE RPKEY=?",[UserInfo tableName]];
				[UserInfo findWithSqlWithParameters:sql,representphoto,pkey ,nil];
			}
			
	//		NSLog(@"====> getBuddyImstatus end<==========");
		}
	}
//	NSString* key = nil;
	NSMutableArray* sections = nil;
	for(int section = 0; section < [[peopleInGroup allKeys] count] ; section++){ //기본 메모리 정보 수정
		NSString *mainkey = [[self.peopleInGroup allKeys] objectAtIndex:section];
		NSMutableArray* mainsections = [self.peopleInGroup objectForKey:mainkey];
		for(int i = 0;i<[mainsections count];i++){
			UserInfo* updateUser = [mainsections objectAtIndex:i];
			if([pkey isEqualToString:updateUser.RPKEY]){
				if(imstatus!=nil && [imstatus length] > 0)
					updateUser.IMSTATUS = imstatus;
				if(status!=nil && [status length] > 0)
					updateUser.STATUS = status;
				if(representphoto!=nil && [representphoto length] > 0)
					updateUser.REPRESENTPHOTO = representphoto;
			}
				
		}
		
		if(self.currentTableView == self.searchDisplayController.searchResultsTableView){//검색 일경우
//			key = [[self.filteredHistory allKeys] objectAtIndex:section];
			sections = [self.filteredHistory objectForKey:mainkey];
		}else if(self.currentTableView == self.tableView){ //일반일경우
			if(self.viewList){//친구만.
//				key = [[self.peopleInBuddy allKeys] objectAtIndex:section];
				sections = [self.peopleInBuddy objectForKey:mainkey];
			}
		}
		
		if(sections != nil && [sections count] > 0){
			for(int i = 0;i<[sections count];i++){
				UserInfo* updateUser = [sections objectAtIndex:i];
				if([pkey isEqualToString:updateUser.RPKEY]){
					if(imstatus!=nil && [imstatus length] > 0)
						updateUser.IMSTATUS = imstatus;
					if(status!=nil && [status length] > 0)
						updateUser.STATUS = status;
					if(representphoto!=nil && [representphoto length] > 0)
						updateUser.REPRESENTPHOTO = representphoto;
				}
			}
		}
	}
	
//	[self.currentTableView reloadData];
}
-(void)startGetChangedProfileInfo {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateChangedProfileInfo:) name:@"updateChangedProfileInfo" object:nil];
	[[self appDelegate] requestGetChangedProfileInfo];
}

-(void)updateChangedProfileInfo:(NSNotification *)notification {
	NSArray* userArray = (NSArray*)[notification object];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateChangedProfileInfo" object:nil];
	[self syncDataBuddyChangeInfo:userArray];
}

-(void)syncDataBuddyChangeInfo:(NSArray*)profileArray {
	
	NSLog(@"싱크 디비");
	
	
	for(NSDictionary* userData in profileArray) {
		UserInfo* profileInfo = [[UserInfo alloc] init];
		if([userData objectForKey:@"id"] && [[userData objectForKey:@"id"] length] > 0){
			profileInfo.ID = [userData objectForKey:@"id"];
			if([userData objectForKey:@"nickName"] && [[userData objectForKey:@"nickName"] length] > 0){
				profileInfo.PROFILENICKNAME = [userData objectForKey:@"nickName"];
			}
			if([userData objectForKey:@"nickNameSP"] && [[userData objectForKey:@"nickNameSP"] length] > 0){
				profileInfo.NICKNAMESP  = [userData objectForKey:@"nickNameSP"];
			}
			if([userData objectForKey:@"status"] && [[userData objectForKey:@"status"] length] > 0){
				profileInfo.STATUS = [userData objectForKey:@"status"];
			}
			if([userData objectForKey:@"statusSP"] && [[userData objectForKey:@"statusSP"] length] > 0){
				profileInfo.STATUSSP = [userData objectForKey:@"statusSP"];
			}
			if([userData objectForKey:@"representPhoto"] && [[userData objectForKey:@"representPhoto"] length] > 0){
				profileInfo.REPRESENTPHOTO = [userData objectForKey:@"representPhoto"];
			}
			if([userData objectForKey:@"representPhotoSP"] && [[userData objectForKey:@"representPhotoSP"] length] > 0){
				profileInfo.REPRESENTPHOTOSP = [userData objectForKey:@"representPhotoSP"];
			}
		}
		for (int i=0; i<[userData count]; i++) {
			NSLog(@"allkeys = %@", [[userData allKeys] objectAtIndex:i]);
			
		}
		DebugLog(@"SAVE DATA++++++ blocked = %@", [userData objectForKey:@"isBlock"]);
		[profileInfo saveData];
		[self changedProfileInfoSyncMemory:profileInfo];
		[profileInfo release];
	}
//	[self.currentTableView reloadData];
}

-(void) changedProfileInfoSyncMemory:(UserInfo *)profileData {
	
	for(int section = 0; section < [[peopleInGroup allKeys] count] ; section++){ //기본 메모리 정보 수정
		NSString *mainkey = [[self.peopleInGroup allKeys] objectAtIndex:section];
		NSMutableArray* mainsections = [self.peopleInGroup objectForKey:mainkey];
		for(int i = 0;i<[mainsections count];i++){
			UserInfo* updateUser = [mainsections objectAtIndex:i];
			if([profileData.ID isEqualToString:updateUser.ID]){
				if(profileData.PROFILENICKNAME != nil && [profileData.PROFILENICKNAME length] > 0){
					updateUser.PROFILENICKNAME = [NSString stringWithFormat:@"%@", profileData.PROFILENICKNAME];
				}
				if(profileData.NICKNAMESP != nil && [profileData.NICKNAMESP length] > 0){
					updateUser.NICKNAMESP = [NSString stringWithFormat:@"%@", profileData.NICKNAMESP];
				}
				if(profileData.PROFILENICKNAME != nil && [profileData.PROFILENICKNAME length] > 0){
					updateUser.PROFILENICKNAME = [NSString stringWithFormat:@"%@", profileData.PROFILENICKNAME];
				}
				if(profileData.STATUS != nil && [profileData.STATUS length] > 0){
					updateUser.STATUS = [NSString stringWithFormat:@"%@", profileData.STATUS];
				}
				if(profileData.STATUSSP != nil && [profileData.STATUSSP length] > 0){
					updateUser.STATUSSP = [NSString stringWithFormat:@"%@", profileData.STATUSSP];
				}
				if(profileData.REPRESENTPHOTO != nil && [profileData.REPRESENTPHOTO length] > 0){
					updateUser.REPRESENTPHOTO = [NSString stringWithFormat:@"%@", profileData.REPRESENTPHOTO];
				}
				if(profileData.REPRESENTPHOTOSP != nil && [profileData.REPRESENTPHOTOSP length] > 0){
					updateUser.REPRESENTPHOTOSP = [NSString stringWithFormat:@"%@", profileData.REPRESENTPHOTOSP];
				}
				break;
			}
		}
		
//		NSString* key = nil;
		NSArray* sections = nil;
		if(self.currentTableView == self.searchDisplayController.searchResultsTableView){//검색 일경우
//			key = [[self.filteredHistory allKeys] objectAtIndex:section];
			sections = [self.filteredHistory objectForKey:mainkey];
		}else if(self.currentTableView == self.tableView){ //일반일경우
			if(self.viewList){//친구만.
//				key = [[self.peopleInBuddy allKeys] objectAtIndex:section];
				sections = [self.peopleInBuddy objectForKey:mainkey];
			}
		}
		
		if(sections != nil && [sections count] > 0){
			for(int i = 0;i<[sections count];i++){
				UserInfo* updateUser = [sections objectAtIndex:i];
				if([profileData.ID isEqualToString:updateUser.ID]){
					if(profileData.PROFILENICKNAME != nil && [profileData.PROFILENICKNAME length] > 0){
						updateUser.PROFILENICKNAME = [NSString stringWithFormat:@"%@", profileData.PROFILENICKNAME];
					}
					if(profileData.NICKNAMESP != nil && [profileData.NICKNAMESP length] > 0){
						updateUser.NICKNAMESP = [NSString stringWithFormat:@"%@", profileData.NICKNAMESP];
					}
					if(profileData.PROFILENICKNAME != nil && [profileData.PROFILENICKNAME length] > 0){
						updateUser.PROFILENICKNAME = [NSString stringWithFormat:@"%@", profileData.PROFILENICKNAME];
					}
					if(profileData.STATUS != nil && [profileData.STATUS length] > 0){
						updateUser.STATUS = [NSString stringWithFormat:@"%@", profileData.STATUS];
					}
					if(profileData.STATUSSP != nil && [profileData.STATUSSP length] > 0){
						updateUser.STATUSSP = [NSString stringWithFormat:@"%@", profileData.STATUSSP];
					}
					if(profileData.REPRESENTPHOTO != nil && [profileData.REPRESENTPHOTO length] > 0){
						updateUser.REPRESENTPHOTO = [NSString stringWithFormat:@"%@", profileData.REPRESENTPHOTO];
					}
					if(profileData.REPRESENTPHOTOSP != nil && [profileData.REPRESENTPHOTOSP length] > 0){
						updateUser.REPRESENTPHOTOSP = [NSString stringWithFormat:@"%@", profileData.REPRESENTPHOTOSP];
					}
					break;
				}
			}
		}
	}
	
}
#pragma mark -
#pragma mark session noti Method
-(void)buddyPresenceChange:(NSNotification *)notification {
	// 0:offline  1:online  2:busy (바빠요)  8:곧 돌아옵니다.  16:다른용무중
	//[loginDic objectForKey:@"presencestatus"];	
	NSDictionary* userDic = (NSDictionary*)[notification object];
//	NSString *key = nil;
	NSMutableArray* sections = nil;
	profileUser = [[ProfileInfo alloc] init];
	NSArray* keyArray = [userDic allKeys];
	NSLog(@"keyArray = %@", keyArray);
	NSLog(@"allvalue = %@", [userDic allValues]);
	for(NSString* key in keyArray) {
		if([userDic valueForKey:key] != nil){
			if([key isEqualToString:@"senderPkey"]){
				[profileUser setValue:[userDic valueForKey:key] forKey:@"PKEY"];
			} 
			if([key isEqualToString:@"imstatus"]){
				[profileUser setValue:[userDic valueForKey:key] forKey:@"IMSTATUS"];
			}
			if([key isEqualToString:@"representPhoto"]){
				[profileUser setValue:[userDic valueForKey:key] forKey:@"REPRESENTPHOTO"];
			}
			if([key isEqualToString:@"representPhotoSP"]){
				[profileUser setValue:[userDic valueForKey:key] forKey:@"REPRESENTPHOTOSP"];
			}
			if([key isEqualToString:@"nickName"]){
				[profileUser setValue:[userDic valueForKey:key] forKey:@"NICKNAME"];
			//	NSLog(@"nickNAme = %@", [userDic valueForKey:key]);
			}
			if([key isEqualToString:@"nickNameSP"]){
				[profileUser setValue:[userDic valueForKey:key] forKey:@"NICKNAMESP"];
			}
			if([key isEqualToString:@"status"]){
				[profileUser setValue:[userDic valueForKey:key] forKey:@"STATUS"];
			}
			if([key isEqualToString:@"statusSP"]){
				[profileUser setValue:[userDic valueForKey:key] forKey:@"STATUSSP"];
			}
		}
		
	}
	
	
	for(int section = 0;section < [[self.peopleInGroup allKeys] count];section++){
		
		NSString* mainkey = [[self.peopleInGroup allKeys] objectAtIndex:section];
		NSMutableArray* mainsections = [self.peopleInGroup objectForKey:mainkey];
		for(int row = 0;row < [mainsections count] ;row++){//전체 일경우 무조건 넣어준다. 기본 메모리 임
			UserInfo* userPresence = [mainsections objectAtIndex:row];
			if([userPresence.RPKEY isEqualToString:[profileUser valueForKey:@"PKEY"]]){

				NSString* sql = nil;
				if([profileUser valueForKey:@"PKEY"]){
					[userPresence setValue:[profileUser valueForKey:@"PKEY"] forKey:@"RPKEY"];
				}
				if([profileUser valueForKey:@"IMSTATUS"]){
					[userPresence setValue:[profileUser valueForKey:@"IMSTATUS"] forKey:@"IMSTATUS"];
					sql = [NSString stringWithFormat:@"UPDATE %@ SET IMSTATUS=? WHERE RPKEY=?",[UserInfo tableName]];
					[UserInfo findWithSqlWithParameters:sql,[profileUser valueForKey:@"IMSTATUS"],[profileUser valueForKey:@"PKEY"] ,nil];
					
				} 
				if([profileUser valueForKey:@"REPRESENTPHOTO"]){
					[userPresence setValue:[profileUser valueForKey:@"REPRESENTPHOTO"] forKey:@"REPRESENTPHOTO"];
					sql = [NSString stringWithFormat:@"UPDATE %@ SET REPRESENTPHOTO=? WHERE RPKEY=?",[UserInfo tableName]];
					[UserInfo findWithSqlWithParameters:sql,[profileUser valueForKey:@"REPRESENTPHOTO"],[profileUser valueForKey:@"PKEY"] ,nil];
				
				}
				if([profileUser valueForKey:@"STATUS"]){
					[userPresence setValue:[profileUser valueForKey:@"STATUS"] forKey:@"STATUS"];
					sql = [NSString stringWithFormat:@"UPDATE %@ SET STATUS=? WHERE RPKEY=?",[UserInfo tableName]];
					[UserInfo findWithSqlWithParameters:sql,[profileUser valueForKey:@"STATUS"],[profileUser valueForKey:@"PKEY"] ,nil];
				}
				if([profileUser valueForKey:@"NICKNAME"]){
					[userPresence setValue:[profileUser valueForKey:@"NICKNAME"] forKey:@"NICKNAME"];
					sql = [NSString stringWithFormat:@"UPDATE %@ SET NICKNAME=? WHERE RPKEY=?",[UserInfo tableName]];
					[UserInfo findWithSqlWithParameters:sql,[profileUser valueForKey:@"NICKNAME"],[profileUser valueForKey:@"PKEY"] ,nil];
				}
				
				break;
			}
		}
		
		if(self.currentTableView == self.searchDisplayController.searchResultsTableView){//검색 일경우
//			key = [[self.filteredHistory allKeys] objectAtIndex:section];
			sections = [self.filteredHistory objectForKey:mainkey];
		}else if(self.currentTableView == self.tableView){ //일반일경우
			if(self.viewList){//친구만.
//				key = [[self.peopleInBuddy allKeys] objectAtIndex:section];
				sections = [self.peopleInBuddy objectForKey:mainkey];
			}
		}
		
		if(sections != nil && [sections count] > 0){
			for(int row = 0;row < [sections count] ;row++){
				UserInfo* userPresence = [sections objectAtIndex:row];
				if([userPresence.RPKEY isEqualToString:[profileUser valueForKey:@"PKEY"]]){
					if([profileUser valueForKey:@"PKEY"]){
						[userPresence setValue:[profileUser valueForKey:@"PKEY"] forKey:@"RPKEY"];
					}
					if([profileUser valueForKey:@"IMSTATUS"]){
						[userPresence setValue:[profileUser valueForKey:@"IMSTATUS"] forKey:@"IMSTATUS"];
					}
					if([profileUser valueForKey:@"REPRESENTPHOTO"]){
						[userPresence setValue:[profileUser valueForKey:@"REPRESENTPHOTO"] forKey:@"REPRESENTPHOTO"];
					}
					if([profileUser valueForKey:@"STATUS"]){
						[userPresence setValue:[profileUser valueForKey:@"STATUS"] forKey:@"STATUS"];
					}				
					break;
				}
			}
		}
	}
	[profileUser release];
	NSLog(@"==PRE==");
	if(currentTableView == nil || currentTableView == NULL)
	{
#ifdef MEZZO_DEBUG
		NSLog(@">>>>>>>TABLE NULL<<<<<<<<<<<");
#endif
	}
	else {
		//채팅도중 여기로 드러와서 죽는데 왜 그러냐......
#ifdef MEZZO_DEBUG
//		NSLog(@"currenttable = %@", currentTableView);
#endif
	}

	// mezzo 0930 죽는 문제가 있어서 임시 처리.
	if ([sections count] > 0) {
		[self.currentTableView reloadData];
	}
	
#ifdef MEZZO_DEBUG
	NSLog(@"===AFTER===");
#endif
		
}

-(void)newFriendIncome:(NSNotification *)notification {
	NSLog(@"newFriendIncome");
	NSDictionary* userDic = (NSDictionary*)[notification object];
	
	NSString *RP = [userDic objectForKey:@"RP"];
//	NSMutableArray* paramarray = [NSMutableArray array];
	UserInfo* newFriend = [[UserInfo alloc] init];
	if([userDic valueForKey:@"imstatus"] != nil && [[userDic valueForKey:@"imstatus"] length] > 0){
		[newFriend setValue:[userDic valueForKey:@"imstatus"] forKey:@"IMSTATUS"];
//		[paramarray addObject:[userDic valueForKey:@"imstatus"]];
	}else {
//		[paramarray addObject:[NSNull null]];
	}
/* 20100930 빠짐
	if([userDic valueForKey:@"formatted"] != nil && [[userDic valueForKey:@"formatted"] length] > 0){
		[newFriend setValue:[userDic valueForKey:@"formatted"] forKey:@"FORMATTED"];
//		[paramarray addObject:[userDic valueForKey:@"formatted"]];
 */
	if([userDic valueForKey:@"nickname"] != nil && [[userDic valueForKey:@"nickname"] length] > 0){
		[newFriend setValue:[userDic valueForKey:@"nickname"] forKey:@"NICKNAME"];
	//		[paramarray addObject:[userDic valueForKey:@"formatted"]];
	}else {
//		[paramarray addObject:[NSNull null]];
	}
	if([userDic valueForKey:@"representPhoto"] != nil && [[userDic valueForKey:@"representPhoto"] length] > 0){
		[newFriend setValue:[userDic valueForKey:@"representPhoto"] forKey:@"REPRESENTPHOTO"];
///		[paramarray addObject:[userDic valueForKey:@"representPhoto"]];
	}else {
//		[paramarray addObject:[NSNull null]];
	}
	if([userDic valueForKey:@"status"] != nil && [[userDic valueForKey:@"status"] length] > 0){
		[newFriend setValue:[userDic valueForKey:@"status"] forKey:@"STATUS"];
//		[paramarray addObject:[userDic valueForKey:@"status"]];
	}else {
//		[paramarray addObject:[NSNull null]];
	}
	if([userDic valueForKey:@"rPCreated"] != nil && [[userDic valueForKey:@"rPCreated"] length] > 0){
		[newFriend setValue:[userDic valueForKey:@"rPCreated"] forKey:@"RPCREATED"];
//		[paramarray addObject:[userDic valueForKey:@"rPCreated"]];
	}else {
//		[paramarray addObject:[NSNull null]];
	}
	if([userDic valueForKey:@"sidUpdated"] != nil && [[userDic valueForKey:@"sidUpdated"] length] > 0)
		[newFriend setValue:[userDic valueForKey:@"sidUpdated"] forKey:@"SIDUPDATED"];
		
	if([userDic valueForKey:@"mobilePhoneNumber"] != nil && [[userDic valueForKey:@"mobilePhoneNumber"] length] > 0){
		[newFriend setValue:[userDic valueForKey:@"mobilePhoneNumber"] forKey:@"MOBILEPHONENUMBER"];
//		[paramarray addObject:[userDic valueForKey:@"mobilePhoneNumber"]];
	}else {
//		[paramarray addObject:[NSNull null]];
	}
	if([userDic valueForKey:@"id"] != nil && [[userDic valueForKey:@"id"] length] > 0)
		[newFriend setValue:[userDic valueForKey:@"id"] forKey:@"ID"];

	if([userDic valueForKey:@"sidCreated"] != nil && [[userDic valueForKey:@"sidCreated"] length] > 0)
		[newFriend setValue:[userDic valueForKey:@"sidCreated"] forKey:@"SIDCREATED"];
	
	if([userDic valueForKey:@"isFriend"] != nil && [[userDic valueForKey:@"isFriend"] length] > 0){
		[newFriend setValue:[userDic valueForKey:@"isFriend"] forKey:@"ISFRIEND"];
//		[paramarray addObject:[userDic valueForKey:@"isFriend"]];
	}else {
//		[paramarray addObject:[NSNull null]];
	}
	if([userDic valueForKey:@"rPKey"] != nil && [[userDic valueForKey:@"rPKey"] length] > 0){
		[newFriend setValue:[userDic valueForKey:@"rPKey"] forKey:@"RPKEY"];
//		[paramarray addObject:[userDic valueForKey:@"rPKey"]];
	}else {
//		[paramarray addObject:[NSNull null]];
	}
	if([userDic valueForKey:@"gid"] != nil && [[userDic valueForKey:@"gid"] length] > 0){
		[newFriend setValue:[userDic valueForKey:@"gid"] forKey:@"GID"];
//		[paramarray addObject:[userDic valueForKey:@"gid"]];
	}else {
//		[paramarray addObject:[NSNull null]];
	}
	if([userDic valueForKey:@"isTrash"] != nil && [[userDic valueForKey:@"isTrash"] length] > 0){
		[newFriend setValue:[userDic valueForKey:@"isTrash"] forKey:@"ISTRASH"];
//		[paramarray addObject:[userDic valueForKey:@"isTrash"]];
	}else {
//		[paramarray addObject:[NSNull null]];
	}
	if([userDic valueForKey:@"profileNickName"] != nil && [[userDic valueForKey:@"profileNickName"] length] > 0){
		[newFriend setValue:[userDic valueForKey:@"profileNickName"] forKey:@"PROFILENICKNAME"];
//		[paramarray addObject:[userDic valueForKey:@"profileNickName"]];
	}else {
//		[paramarray addObject:[NSNull null]];
	}
	
	
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	NSLocale *locale = [NSLocale currentLocale];
	[formatter setLocale:locale];
	[formatter setDateFormat:@"yyyyMMddHHmmss"];
	NSDate *today = [NSDate date];
	NSString *lastSyncDate = [[NSString alloc] initWithFormat:@"%@",[formatter stringFromDate:today]];
	
	
	//현재 시간으로 업데이트 한다.
	newFriend.CHANGEDATE = lastSyncDate;
	newFriend.CHANGEDATE2 = lastSyncDate;
	
	[newFriend saveData]; //디비에 인서트

	NSLog(@"CHANGEDATA %@",newFriend.CHANGEDATE);
//	[paramarray addObject:[newFriend valueForKey:@"CHANGEDATE"]];
//	[paramarray addObject:[userDic valueForKey:@"id"]];
	
//	NSString* newsql = [NSString stringWithFormat:@"UPDATE %@ SET IMSTATUS=?, FORMATTED=?, REPRESENTPHOTO=?, STATUS = ?, RPCREATED=?, MOBILEPHONENUMBER=?, ISFRIEND=?, RPKEY=?, GID=?, ISTRASH = ?, PROFILENICKNAME = ?, CHANGEDATE = ? WHERE ID = ? ",[UserInfo tableName]];
//	[[UserInfo database] executeSql:newsql withParameters:(NSArray*)paramarray];
	
	//데이터 베이스에 저장후 마지막 동기화 포인트 저장
	if(RP != nil){
		NSString* revisionPoints = [[NSString alloc] initWithFormat:@"%@",RP];
		[[NSUserDefaults standardUserDefaults] setObject:revisionPoints forKey:@"RevisionPoints"];
		[revisionPoints release];
	}
	
	if(newFriend != nil){
		[[NSUserDefaults standardUserDefaults] setObject:lastSyncDate forKey:@"lastSyncDate"]; //동기화 싱크 포인트
	}
	
	NSSortDescriptor *groupNameSort = [[NSSortDescriptor alloc] initWithKey:@"GROUPTITLE" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
	[self.allGroups sortUsingDescriptors:[NSArray arrayWithObject:groupNameSort]];
	[groupNameSort release];
	for(int g=0;g<[self.allGroups count];g++){
		GroupInfo* tempGroup = [self.allGroups objectAtIndex:g];
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
			[self.allGroups removeObject:tempGroup];
			[self.allGroups insertObject:instGroup atIndex:0];
			[instGroup release];
			break;
		}else {
			[instGroup release];
		}
		
	}	
	
	NSString *key = nil;
	NSMutableArray* sections = nil;
	for(GroupInfo* newFriendGroup in self.allGroups){
		if([newFriendGroup.ID isEqualToString:newFriend.GID]){
			key = [NSString stringWithFormat:@"%@",newFriendGroup.GROUPTITLE];
		}
	}
	
	NSMutableArray* mainsections = [self.peopleInGroup objectForKey:key];
	[mainsections addObject:newFriend];
	NSSortDescriptor *formattedSort = [[NSSortDescriptor alloc] initWithKey:@"FORMATTED" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
	NSSortDescriptor *nickNameSort = [[NSSortDescriptor alloc] initWithKey:@"PROFILENICKNAME" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
	[mainsections sortUsingDescriptors:[NSArray arrayWithObjects:formattedSort,nickNameSort, nil]];
	[nickNameSort release];
	[formattedSort release];
				
	if(self.currentTableView == self.searchDisplayController.searchResultsTableView){//검색 일경우
		sections = [self.filteredHistory objectForKey:key];
	}else if(self.currentTableView == self.tableView){ //일반일경우
		if(self.viewList){//친구만.
			sections = [self.peopleInBuddy objectForKey:key];
		}
	}
	
	if(sections != nil)
		[sections addObject:newFriend];
		
	[newFriend release];
	
	NSSortDescriptor *reformattedSort = [[NSSortDescriptor alloc] initWithKey:@"FORMATTED" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
	NSSortDescriptor *renickNameSort = [[NSSortDescriptor alloc] initWithKey:@"PROFILENICKNAME" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
	[sections sortUsingDescriptors:[NSArray arrayWithObjects:reformattedSort,renickNameSort, nil]];
	[renickNameSort release];
	[reformattedSort release];
	
	
	NSString *oldDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"myDate"];
	NSLog(@"oldDateAAAAAAAAAAAAAAA %@", oldDate);
	
	int changecnt = 0;
	
	//새친구가 들어올댄 탭 날자랑 비교해서 날자보다 크면 뱃지를 카운트
	for(int i = 0;i< [[peopleInGroup allKeys] count] ;i++){
		NSString* groupedkey = [[peopleInGroup allKeys] objectAtIndex:i];
		NSArray* groupedarray = [peopleInGroup objectForKey:groupedkey];
		for(UserInfo* changeuser in groupedarray){
		//	NSLog(@"history = %d %@",[changeuser.CHANGEDATE intValue], [changeuser.NICKNAME]);
			NSLog(@"history = %@", changeuser.CHANGEDATE);
			NSLog(@"oldDate %@", oldDate);
		
			if([[changeuser.CHANGEDATE2 substringToIndex:8] isEqualToString:[lastSyncDate substringToIndex:8]])
		//	if([oldDate compare:changeuser.CHANGEDATE] < 0)
			{
				NSLog(@"증가한다");
				changecnt++;
			}
			else {
				NSLog(@"아니다.");
			}

			/*
			if(oldDate < changeuser.CHANGEDATE)
			{
				changecnt++;
			}
			*/
			/*기존꺼
			if([[changeuser.CHANGEDATE substringToIndex:8] isEqualToString:[lastSyncDate substringToIndex:8]])
				changecnt++;
			 */
		}
	}

	[lastSyncDate release];
	[formatter release];

	//	NSInteger nCount = [changePerson count];
	NSInteger nCount = changecnt;
	NSLog(@"newFriend nConutn = %i", nCount);
	if (nCount == 0) {
		UITabBarItem *tbi = [[self appDelegate].rootController.tabBar.items objectAtIndex:1];
		if (tbi) {
			tbi.badgeValue = nil;
		}
	} else if (nCount > 0) {
		UITabBarItem *tbi = [[self appDelegate].rootController.tabBar.items objectAtIndex:1];
		if (tbi) {
			//nCount = [tbi.badgeValue intValue]+1;
			NSLog(@"badge = %@", tbi.badgeValue);
			NSLog(@"nCnt = %i", nCount);
			
			tbi.badgeValue = [NSString stringWithFormat:@"%i", nCount];
		}
		[[self appDelegate] playSystemSoundIDSound];
		[[self appDelegate] playSystemSoundIDVibrate];
		
		
		
	//	[self reloadAddressData];
		
		
		
		
		
	} else {
		// skip
	}
	
	
	//어차피 뷰어피어에 들어오면 리로드 하기 때문에 안해도 될꺼 같다..
//	[self.currentTableView reloadData];
	
	/*
	USayAppAppDelegate *parentView = (USayAppAppDelegate*) [[UIApplication sharedApplication] delegate];
	UINavigationController *tmp = [parentView.rootController.viewControllers objectAtIndex:1];
	AddressViewController *tmpAdd = (AddressViewController*)[tmp.viewControllers objectAtIndex:1];
	[tmpAdd.currentTableView reloadData];
	*/
}

-(void)buddyBlockCancel:(NSNotification *)notification {
	
	NSLog(@"차단친구 해제할때");
//	NSLog(@"buddyBlockCancel");
	NSDictionary *data = (NSDictionary*)[notification object];
//	NSMutableArray* cancelarray = [NSMutableArray array];
//	NSMutableArray* paramArray = [NSMutableArray array];
	NSString* RP = nil;
	UserInfo* cancelBlockUser = nil;
	NSArray* cancelUserData = [UserInfo findByColumn:@"RPKEY" value:[data objectForKey:@"fPkey"]];
	if(cancelUserData != nil && [cancelUserData count] > 0){
		cancelBlockUser = [cancelUserData objectAtIndex:0];
		if([data objectForKey:@"imstatus"]){
			[cancelBlockUser setValue:[data objectForKey:@"imstatus"] forKey:@"IMSTATUS"];
		}
		if([data objectForKey:@"representPhoto"]){
			[cancelBlockUser setValue:[data objectForKey:@"representPhoto"] forKey:@"REPRESENTPHOTO"];
		}
		if([data objectForKey:@"nickName"]){
			[cancelBlockUser setValue:[data objectForKey:@"nickName"] forKey:@"NICKNAME"];
		}
		if([data objectForKey:@"status"]){
			[cancelBlockUser setValue:[data objectForKey:@"status"] forKey:@"STATUS"];
		}
		[cancelBlockUser setValue:@"N" forKey:@"ISBLOCK"];

		RP = [data objectForKey:@"RP"];
		
	//	NSLog(@"%@", cancelarray);
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		NSLocale *locale = [NSLocale currentLocale];
		[formatter setLocale:locale];
		[formatter setDateFormat:@"yyyyMMddHHmmss"];
		NSDate *today = [NSDate date];
		NSString *lastSyncDate = [[NSString alloc] initWithFormat:@"%@",[formatter stringFromDate:today]];
		
		cancelBlockUser.CHANGEDATE = lastSyncDate;
		cancelBlockUser.CHANGEDATE2 = lastSyncDate;
		
		[cancelBlockUser saveData];
		
		//데이터 베이스에 저장후 마지막 동기화 포인트 저장
		if(RP != nil){
			NSString* revisionPoints = [[NSString alloc] initWithFormat:@"%@",RP];
			[[NSUserDefaults standardUserDefaults] setObject:revisionPoints forKey:@"RevisionPoints"];
			[revisionPoints release];
		}
		
		if(cancelBlockUser != nil){
			[[NSUserDefaults standardUserDefaults] setObject:lastSyncDate forKey:@"lastSyncDate"];
		}
		
		NSSortDescriptor *groupNameSort = [[NSSortDescriptor alloc] initWithKey:@"GROUPTITLE" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
		[self.allGroups sortUsingDescriptors:[NSArray arrayWithObject:groupNameSort]];
		[groupNameSort release];
		for(int g=0;g<[self.allGroups count];g++){
			GroupInfo* tempGroup = [self.allGroups objectAtIndex:g];
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
				[self.allGroups removeObject:tempGroup];
				[self.allGroups insertObject:instGroup atIndex:0];
				[instGroup release];
				break;
			}else {
				[instGroup release];
			}
			
		}		
		
		NSString *key = nil;
		NSMutableArray* sections = nil;
		for(GroupInfo* newFriendGroup in self.allGroups){
			if([newFriendGroup.ID isEqualToString:cancelBlockUser.GID]){
				key = [NSString stringWithFormat:@"%@",newFriendGroup.GROUPTITLE];
			}
		}
		
		NSMutableArray* mainsections = [self.peopleInGroup objectForKey:key];
		[mainsections addObject:cancelBlockUser];
		
		NSSortDescriptor *formattedSort = [[NSSortDescriptor alloc] initWithKey:@"FORMATTED" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
		NSSortDescriptor *nickNameSort = [[NSSortDescriptor alloc] initWithKey:@"PROFILENICKNAME" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
		[mainsections sortUsingDescriptors:[NSArray arrayWithObjects:formattedSort,nickNameSort, nil]];
		[nickNameSort release];
		[formattedSort release];
		
		if(self.currentTableView == self.searchDisplayController.searchResultsTableView){//검색 일경우
			sections = [self.filteredHistory objectForKey:key];
		}else if(self.currentTableView == self.tableView){ //일반일경우
			if(self.viewList){//친구만.
				sections = [self.peopleInBuddy objectForKey:key];
			}
		}
		
		if(sections != nil){
			[sections addObject:cancelBlockUser];
			NSSortDescriptor *formattedSort = [[NSSortDescriptor alloc] initWithKey:@"FORMATTED" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
			NSSortDescriptor *nickNameSort = [[NSSortDescriptor alloc] initWithKey:@"PROFILENICKNAME" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
			[sections sortUsingDescriptors:[NSArray arrayWithObjects:formattedSort,nickNameSort, nil]];
			[nickNameSort release];
			[formattedSort release];
		}
		
		//차단 해제 할경우도 탭정보를 받아서 뱃지 보여준다..
		
	//	NSString *oldDate =[[NSUserDefaults standardUserDefaults] objectForKey:@"myDate"];
		int changecnt = 0;
		for(int i = 0;i< [[peopleInGroup allKeys] count] ;i++){
			NSString* groupedkey = [[peopleInGroup allKeys] objectAtIndex:i];
			NSArray* groupedarray = [peopleInGroup objectForKey:groupedkey];
			for(UserInfo* changeuser in groupedarray){
				
				/*
				if([oldDate compare:changeuser.CHANGEDATE] < 0)
				{
					changecnt++;
				}
				 */
				
				if([[changeuser.CHANGEDATE2 substringToIndex:8] isEqualToString:[lastSyncDate substringToIndex:8]])
					changecnt++;
				 
			}
		}
		
		[lastSyncDate release];
		[formatter release];
		
		
//		NSInteger nCount = [changePerson count];
		NSInteger nCount = changecnt;
		if (nCount == 0) {
			UITabBarItem *tbi = [[self appDelegate].rootController.tabBar.items objectAtIndex:1];
			if (tbi) {
				tbi.badgeValue = nil;
			}
		} else if (nCount > 0) {
			UITabBarItem *tbi = [[self appDelegate].rootController.tabBar.items objectAtIndex:1];
			if (tbi) {
				tbi.badgeValue = [NSString stringWithFormat:@"%i", nCount];
			}
			[[self appDelegate] playSystemSoundIDSound];
			[[self appDelegate] playSystemSoundIDVibrate];
		} else {
			// skip
		}
	//	[self reloadAddressData];
	//	[self.currentTableView reloadData];
		/*
		USayAppAppDelegate *parentView = (USayAppAppDelegate*) [[UIApplication sharedApplication] delegate];
		UINavigationController *tmp = [parentView.rootController.viewControllers objectAtIndex:1];
		AddressViewController *tmpAdd = (AddressViewController*)[tmp.viewControllers objectAtIndex:1];
		[tmpAdd.currentTableView reloadData];
		 */
	}else {
		UIAlertView* blockUserAlert = [[UIAlertView alloc] initWithTitle:@"차단 해제" message:@"저장된 친구 정보가 없습니다." 
																delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
		[blockUserAlert show];
		[blockUserAlert release];
	}

	
}

/*
-(void)getLastAfterRP:(NSNotification *)notification {
	
	USayHttpData *data = (USayHttpData*)[notification object];
	if (data == nil) {
		// 200 이외의 에러
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 오류" message:@"서버와의 통신에 실패하였습니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
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
		NSString *count = [dic objectForKey:@"count"]; //리스트 개수
		NSString *RP = [dic objectForKey:@"RP"];  //마지막 동기화 RP
		if ([rtType isEqualToString:@"list"]) {
			// Key and Dictionary as its value type
			NSMutableArray* userArray = [NSMutableArray array];
			int nCount = 0;
			for(NSDictionary *addressDic in [dic objectForKey:@"list"]) {
				id userData = (NSMutableDictionary*)[[UserInfo alloc] init];
				NSArray* keyArray = [addressDic allKeys];
				for(NSString* key in keyArray) {
					//유저 정보
					unsigned int numIvars = 0;
					Ivar* ivars = class_copyIvarList([userData class], &numIvars);
					for(int i = 0; i < numIvars; i++) {
						Ivar thisIvar = ivars[i];
						NSString * classkey = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
						if([[key uppercaseString] isEqualToString:classkey])
							[userData  setValue:[addressDic objectForKey:key] forKey:classkey];
					}
					free(ivars);
				}				
				if([userData valueForKey:@"ID"]){
					[userArray addObject:userData];
				}
				if(userData)[userData release];
				
				nCount++;
			}
			
			//내려 받은 개수와 리스트를 파싱한 개수가 같을 경우에 저장.
			if([count isEqualToString:[NSString stringWithFormat:@"%i",nCount]])
				[self syncDatabase:userArray withGroupinfo:nil saveRevisionPoint:RP withChangeKind:@"newFriend"];
			
		} else if([rtType isEqualToString:@"only"] ) {
			[self syncDatabase:nil withGroupinfo:nil saveRevisionPoint:nil withChangeKind:nil];
			// TODO: 예외처리
		} else {
			//TODO: 예외처리
		}
		
	} else if ([rtcode isEqualToString:@"-9010"]) {
		// TODO: 데이터를 찾을 수 없음.
		[self syncDatabase:nil withGroupinfo:nil saveRevisionPoint:nil withChangeKind:nil];
	} else if ([rtcode isEqualToString:@"-9020"]) {
		// TODO: 잘못된 인자가 넘어옴
	} else if ([rtcode isEqualToString:@"-9030"]) {
		// TODO: 서버상의 처리 오류. 예외처리 필요
	} else {
		// TODO: 기타오류 예외처리 필요
	}
	
}
*/
#pragma mark -
#pragma mark navigationBar button Method

-(void) onlyFriend{
	
	if([self.selectedPerson count] > 0){
		NSIndexPath* oldIndexPath = [self.selectedPerson objectAtIndex:0];
		ApplicationCell* cell = (ApplicationCell*)[self.currentTableView cellForRowAtIndexPath:oldIndexPath];
		if(cell.bButtonView){
			[cell selectViewChange:cell.isBuddy];
		}
		[self.selectedPerson removeObjectAtIndex:[self.selectedPerson indexOfObject:oldIndexPath]];
	}
	
		
	
	//self.viewList = !self.viewList; //이게 뭔말이지???
	
	/*
	if(self.viewList) {
		//		[self.navigationItem.leftBarButtonItem setTitle:@"친구"];
		//내비게이션 바 버튼 설정
		self.navigationItem.leftBarButtonItem = nil;
		for(int i = 0; i < [[peopleInGroup allKeys] count];i++){
			for(NSString* groupKey in [peopleInGroup allKeys]){
				NSMutableArray* groupUser = [NSMutableArray array];
				for(UserInfo* buddyUser in [peopleInGroup objectForKey:groupKey]){
					if([buddyUser.ISFRIEND isEqualToString:@"S"]){
						[groupUser addObject:buddyUser];
					}
				}
				NSSortDescriptor *formattedSort = [[NSSortDescriptor alloc] initWithKey:@"FORMATTED" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
				NSSortDescriptor *nickNameSort = [[NSSortDescriptor alloc] initWithKey:@"PROFILENICKNAME" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
				[groupUser sortUsingDescriptors:[NSArray arrayWithObjects:formattedSort,nickNameSort, nil]];
				[nickNameSort release];
				[formattedSort release];
				[self.peopleInBuddy setObject:groupUser forKey:groupKey];
			}
		}
		//		self.title = @"Usay친구";
		UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
		assert(titleView != nil);
		UIFont *titleFont = [UIFont systemFontOfSize:20];
		CGSize titleStringSize = [@"Usay친구" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
		assert(titleFont != nil);
		UILabel *naviTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
		assert(naviTitleLabel != nil);
		[naviTitleLabel setFont:titleFont];
		naviTitleLabel.textAlignment = UITextAlignmentCenter;
		[naviTitleLabel setTextColor:ColorFromRGB(0x053844)];
		[naviTitleLabel setBackgroundColor:[UIColor clearColor]];
		[naviTitleLabel setText:@"Usay친구"];
		//		naviTitleLabel.shadowColor = [UIColor whiteColor];
		[titleView addSubview:naviTitleLabel];	
		[naviTitleLabel release];
		self.navigationItem.titleView = titleView;
		[titleView release];
		self.navigationItem.titleView.frame = CGRectMake((self.tableView.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);
	//뷰에서 하니 안해도 될꺼 같다..	[self.currentTableView reloadData];
	
	}
	 */
	
}

-(void) buddyKindButtonClicked{
	
	if([self.selectedPerson count] > 0){
		NSIndexPath* oldIndexPath = [self.selectedPerson objectAtIndex:0];
		ApplicationCell* cell = (ApplicationCell*)[self.currentTableView cellForRowAtIndexPath:oldIndexPath];
		if(cell.bButtonView){
			[cell selectViewChange:cell.isBuddy];
		}
		[self.selectedPerson removeObjectAtIndex:[self.selectedPerson indexOfObject:oldIndexPath]];
	}
	
	self.viewList = !self.viewList;
	if(self.viewList) {
//		[self.navigationItem.leftBarButtonItem setTitle:@"친구"];
		//내비게이션 바 버튼 설정
		self.navigationItem.leftBarButtonItem = nil;
		UIImage* leftBarBtnImg = [[UIImage imageNamed:@"top_all_normal.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
		UIImage* leftBarBtnSelImg = [[UIImage imageNamed:@"top_all_focus.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
		UIButton* leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[leftBarButton addTarget:self action:@selector(buddyKindButtonClicked) forControlEvents:UIControlEventTouchUpInside];
		[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
		[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateHighlighted];
		leftBarButton.frame = CGRectMake(0.0, 0.0, leftBarBtnImg.size.width, leftBarBtnImg.size.height);	
		UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
		self.navigationItem.leftBarButtonItem = leftButton;
		[leftButton release];
		for(int i = 0; i < [[peopleInGroup allKeys] count];i++){
			for(NSString* groupKey in [peopleInGroup allKeys]){
				NSMutableArray* groupUser = [NSMutableArray array];
				for(UserInfo* buddyUser in [peopleInGroup objectForKey:groupKey]){
					if([buddyUser.ISFRIEND isEqualToString:@"S"]){
						[groupUser addObject:buddyUser];
					}
				}
				NSSortDescriptor *formattedSort = [[NSSortDescriptor alloc] initWithKey:@"FORMATTED" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
				NSSortDescriptor *nickNameSort = [[NSSortDescriptor alloc] initWithKey:@"PROFILENICKNAME" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
				[groupUser sortUsingDescriptors:[NSArray arrayWithObjects:formattedSort,nickNameSort, nil]];
				[nickNameSort release];
				[formattedSort release];
				[self.peopleInBuddy setObject:groupUser forKey:groupKey];
			}
		}
//		self.title = @"Usay친구";
		UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
		assert(titleView != nil);
		UIFont *titleFont = [UIFont systemFontOfSize:20];
		CGSize titleStringSize = [@"Usay친구" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
		assert(titleFont != nil);
		UILabel *naviTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
		assert(naviTitleLabel != nil);
		[naviTitleLabel setFont:titleFont];
		naviTitleLabel.textAlignment = UITextAlignmentCenter;
		[naviTitleLabel setTextColor:ColorFromRGB(0x053844)];
		[naviTitleLabel setBackgroundColor:[UIColor clearColor]];
		[naviTitleLabel setText:@"Usay친구"];
//		naviTitleLabel.shadowColor = [UIColor whiteColor];
		[titleView addSubview:naviTitleLabel];	
		[naviTitleLabel release];
		self.navigationItem.titleView = titleView;
		[titleView release];
		self.navigationItem.titleView.frame = CGRectMake((self.tableView.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);
//20101015		[self.currentTableView reloadData];
		/*
		USayAppAppDelegate *parentView = (USayAppAppDelegate*) [[UIApplication sharedApplication] delegate];
		UINavigationController *tmp = [parentView.rootController.viewControllers objectAtIndex:1];
		AddressViewController *tmpAdd = (AddressViewController*)[tmp.viewControllers objectAtIndex:1];
		[tmpAdd.currentTableView reloadData];
		*/

	}else{
//		[self.navigationItem.leftBarButtonItem setTitle:@"전체"];
		self.navigationItem.leftBarButtonItem = nil;
		UIImage* leftBarBtnImg = [[UIImage imageNamed:@"top_buddy_normal.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
		UIImage* leftBarBtnSelImg = [[UIImage imageNamed:@"top_buddy_focus.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
		UIButton* leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[leftBarButton addTarget:self action:@selector(buddyKindButtonClicked) forControlEvents:UIControlEventTouchUpInside];
		[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
		[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateHighlighted];
		leftBarButton.frame = CGRectMake(0.0, 0.0, leftBarBtnImg.size.width, leftBarBtnImg.size.height);	
		UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
		self.navigationItem.leftBarButtonItem = leftButton;
		[leftButton release];
		
		[self.peopleInBuddy removeAllObjects];
//		self.title = @"주소록";
		UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
		assert(titleView != nil);
		UIFont *titleFont = [UIFont systemFontOfSize:20];
		CGSize titleStringSize = [@"주소록" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
		assert(titleFont != nil);
		UILabel *naviTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
		assert(naviTitleLabel != nil);
		[naviTitleLabel setFont:titleFont];
		naviTitleLabel.textAlignment = UITextAlignmentCenter;
		[naviTitleLabel setTextColor:ColorFromRGB(0x053844)];
		[naviTitleLabel setBackgroundColor:[UIColor clearColor]];
		[naviTitleLabel setText:@"주소록"];
//		naviTitleLabel.shadowColor = [UIColor whiteColor];
		[titleView addSubview:naviTitleLabel];	
		[naviTitleLabel release];
		self.navigationItem.titleView = titleView;
		[titleView release];
		self.navigationItem.titleView.frame = CGRectMake((self.tableView.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);
		[self.currentTableView reloadData];
		/*
		USayAppAppDelegate *parentView = (USayAppAppDelegate*) [[UIApplication sharedApplication] delegate];
		UINavigationController *tmp = [parentView.rootController.viewControllers objectAtIndex:1];
		AddressViewController *tmpAdd = (AddressViewController*)[tmp.viewControllers objectAtIndex:1];
		[tmpAdd.currentTableView reloadData];
*/
	}
}
-(void)addressEditButtonClicked{
	
	if([self.selectedPerson count] > 0){
		NSIndexPath* oldIndexPath = [self.selectedPerson objectAtIndex:0];
		ApplicationCell* cell = (ApplicationCell*)[self.currentTableView cellForRowAtIndexPath:oldIndexPath];
		if(cell.bButtonView){
			[cell selectViewChange:cell.isBuddy];
		}
		[self.selectedPerson removeObjectAtIndex:[self.selectedPerson indexOfObject:oldIndexPath]];
	}
	
	if([self appDelegate].connectionType == -1){
		UIButton* rightButton = (UIButton*)self.navigationItem.rightBarButtonItem;
		rightButton.enabled = NO;
		UIAlertView* offlineAlert = [[UIAlertView alloc] initWithTitle:@"오프라인"
															   message:@"현재 네트워크 연결이 불가능한 상태 입니다.\nUsay의 모든 기능을 이용하기 위해서는 네트워크 연결이 필요합니다." 
															  delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
		[offlineAlert show];
		[offlineAlert release];
		return;
		
	}
	
	UIActionSheet* editMenu = [[UIActionSheet alloc] initWithTitle:@"" 
											delegate:self
												 cancelButtonTitle:@"취소" 
											destructiveButtonTitle:nil 
												 otherButtonTitles:@"새 주소 추가하기",
							   @"새 그룹 추가하기", nil];
																	//@"주소록 편집하기", nil];
 
	editMenu.actionSheetStyle = UIActionSheetStyleDefault;
	//tabBar 컨트롤러의 하위 뷰일경우, actionsheet의 cancel버튼이 먹질 않는다. 
	//tabbarcontroller뷰의 상단에 보이게 한다.
	[editMenu showInView:self.tabBarController.view];
	[editMenu release];
}
#pragma mark -
#pragma mark UISearchDisplayController delegate
/*
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
	//	UISearchBar *addrSearchBar = self.searchDisplayController.searchBar;
	for(UIView* findView in searchBar.subviews){
		if([findView isKindOfClass:[NSClassFromString(@"UINavigationButton") class]]){
			[(UIBarItem *)findView setTitle:@"취소"];
		}
	}
	return YES;
}
*/
- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {

	if([self.selectedPerson count] > 0){
		NSIndexPath* oldIndexPath = [self.selectedPerson objectAtIndex:0];
		ApplicationCell* cell = (ApplicationCell*)[self.currentTableView cellForRowAtIndexPath:oldIndexPath];
		if(cell.bButtonView){
			[cell selectViewChange:cell.isBuddy];
		}
		[self.selectedPerson removeObjectAtIndex:[self.selectedPerson indexOfObject:oldIndexPath]];
	}
	
	currentTableView = self.searchDisplayController.searchResultsTableView;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
	
	if([self.selectedPerson count] > 0){
		NSIndexPath* oldIndexPath = [self.selectedPerson objectAtIndex:0];
		ApplicationCell* cell = (ApplicationCell*)[self.currentTableView cellForRowAtIndexPath:oldIndexPath];
		if(cell.bButtonView){
			[cell selectViewChange:cell.isBuddy];
		}
		[self.selectedPerson removeObjectAtIndex:[self.selectedPerson indexOfObject:oldIndexPath]];
	}
	
	currentTableView = self.tableView;
	
}
-(BOOL) searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
	[filteredHistory removeAllObjects];
	[searchArray removeAllObjects];

	if ([searchString length] > 0) {
#if TARGET_IPHONE_SIMULATOR	
//	NSLog(@"%@",[self.peopleInGroup allValues]);
#endif
		int nSearchType = -1;
		NSInteger code = [searchString characterAtIndex:0];
		
		if (code >= HANGUL_BEGIN_UNICODE && code <= HANGUL_END_UNICODE) {
			nSearchType = 0;
		} else if ([self IsHangulChosung:code]) {
			nSearchType = 1;
		} else {
			nSearchType = 2;
		}
		
		NSDictionary* viewTypeDic = nil;
		if(!self.viewList){
			viewTypeDic = self.peopleInGroup;
		}else {
			viewTypeDic = self.peopleInBuddy;
		}
		
		for(int i = 0; i < [viewTypeDic count];i++) {
			NSMutableArray* filetArray = [NSMutableArray array];
			for(UserInfo* item in [viewTypeDic objectForKey:[[viewTypeDic allKeys] objectAtIndex:i]]) {
#if TARGET_IPHONE_SIMULATOR	
//				NSLog(@"%@",item.FORMATTED);
#endif

				NSString *searchChosungString = nil; 
				NSString *compareNameString = nil;
//				NSString *comparePhoneNumString = nil;
//				NSString *compareEmailString = nil;
				NSString *buddyname = nil;
				
				if (item.FORMATTED && [item.FORMATTED length] > 0) {
					buddyname = item.FORMATTED;
				} else if (item.PROFILENICKNAME && [item.PROFILENICKNAME length] > 0) {
					buddyname = item.PROFILENICKNAME;
				} else if(item.NICKNAME != nil && [item.NICKNAME length] > 0) {
					buddyname = item.NICKNAME;
				} else {
					buddyname = @"이름 없음";
				}

				NSString *iPhoneNum = item.IPHONENUMBER;
				NSString *phoneNum = item.MOBILEPHONENUMBER;
				
//				NSLog(@"name=%@  email=%@  email=%@  email=%@", buddyname, email, item.ORGEMAILADDRESS, item.OTHEREMAILADDRESS);
				if (nSearchType == 0) {
					searchChosungString = [self GetUTF8String:searchString];
					if (buddyname && [buddyname length] > 0) {
						compareNameString = [self GetUTF8String:buddyname];
						NSRange rBuddyname = [compareNameString rangeOfString:searchChosungString];
						if (rBuddyname.location != NSNotFound) {
							[filetArray addObject:item];
							continue;
						} else {
							// skip
						}
					}
					if (phoneNum && [phoneNum length] > 0) {
						phoneNum = (NSMutableString *)[phoneNum stringByReplacingOccurrencesOfString:@"-" withString:@""];
						NSRange rPhoneNum = [phoneNum rangeOfString:searchString];
						if (rPhoneNum.location != NSNotFound) {
							[filetArray addObject:item];
							continue;
						} else {
							// skip
						}
					}
					if (iPhoneNum && [iPhoneNum length] > 0) {
						iPhoneNum = (NSMutableString *)[iPhoneNum stringByReplacingOccurrencesOfString:@"-" withString:@""];
						NSRange rPhoneNum = [iPhoneNum rangeOfString:searchString];
						if (rPhoneNum.location != NSNotFound) {
							[filetArray addObject:item];
							continue;
						} else {
							// skip
						}
					}
				} else if (nSearchType == 1) {
					searchChosungString = [self GetChosungUTF8StringSearchString:searchString];
					if (buddyname && [buddyname length] > 0) {
						compareNameString = [self GetChosungUTF8String:buddyname];
						NSRange rBuddyname = [compareNameString rangeOfString:searchChosungString];
						if (rBuddyname.location != NSNotFound) {
							[filetArray addObject:item];
							continue;
						} else {
							// skip
						}
					}
					if (phoneNum && [phoneNum length] > 0) {
						phoneNum = (NSMutableString *)[phoneNum stringByReplacingOccurrencesOfString:@"-" withString:@""];
						NSRange rPhoneNum = [phoneNum rangeOfString:searchString];
						if (rPhoneNum.location != NSNotFound) {
							[filetArray addObject:item];
							continue;
						} else {
							// skip
						}
					}
					if (iPhoneNum && [iPhoneNum length] > 0) {
						iPhoneNum = (NSMutableString *)[iPhoneNum stringByReplacingOccurrencesOfString:@"-" withString:@""];
						NSRange rPhoneNum = [iPhoneNum rangeOfString:searchString];
						if (rPhoneNum.location != NSNotFound) {
							[filetArray addObject:item];
							continue;
						} else {
							// skip
						}
					}
				} else if (nSearchType == 2) {
					if (buddyname && [buddyname length] > 0) {
						compareNameString = [self GetChosungUTF8String:buddyname];
						NSRange rBuddyname = [compareNameString rangeOfString:searchString];
						if (rBuddyname.location != NSNotFound) {
							[filetArray addObject:item];
							continue;
						} else {
							// skip
						}
					}
					if (phoneNum && [phoneNum length] > 0) {
						phoneNum = (NSMutableString *)[phoneNum stringByReplacingOccurrencesOfString:@"-" withString:@""];
						NSRange rPhoneNum = [phoneNum rangeOfString:searchString];
						if (rPhoneNum.location != NSNotFound) {
							[filetArray addObject:item];
							continue;
						} else {
							// skip
						}
					}
					if (iPhoneNum && [iPhoneNum length] > 0) {
						iPhoneNum = (NSMutableString *)[iPhoneNum stringByReplacingOccurrencesOfString:@"-" withString:@""];
						NSRange rPhoneNum = [iPhoneNum rangeOfString:searchString];
						if (rPhoneNum.location != NSNotFound) {
							[filetArray addObject:item];
							continue;
						} else {
							// skip
						}
					}
				} else {
					// skip
				}
			}
			NSSortDescriptor *formattedSort = [[NSSortDescriptor alloc] initWithKey:@"FORMATTED" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
			NSSortDescriptor *nickNameSort = [[NSSortDescriptor alloc] initWithKey:@"PROFILENICKNAME" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
			[filetArray sortUsingDescriptors:[NSArray arrayWithObjects:formattedSort,nickNameSort, nil]];
			[nickNameSort release];
			[formattedSort release];
			[filteredHistory setObject:filetArray forKey:[[viewTypeDic allKeys] objectAtIndex:i]];
		}
		[statusGroup removeAllObjects];
	}
	
	return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
	searchBar.showsCancelButton = YES;
	for(UIView *subView in searchBar.subviews){
		if([subView isKindOfClass:UIButton.class]){
			[(UIButton*)subView setImage:[UIImage imageNamed:@"btn_searchbar_cancel.png"] forState:UIControlStateNormal];
			[(UIButton*)subView setImage:[UIImage imageNamed:@"btn_searchbar_cancel_focus.png"] forState:UIControlStateHighlighted];
			break;
		}
	}
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
	searchBar.showsCancelButton = NO;
}

#pragma mark -
#pragma mark Table view data source




- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	
	NSLog(@"===============rotate=============");
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	//가로 모드시 죽는 현상 막는 함수
	MFMessageComposeViewController *myPicker = (MFMessageComposeViewController*)self.modalViewController;
	
#ifdef MEZZO_DEBUG
	NSLog(@"==================> NUm of TableView <===================");
    // Return the number of sections.
#endif	
	
	if(myPicker == NULL || myPicker == nil)
	{
		if(tableView == self.searchDisplayController.searchResultsTableView){
			currentTableView = self.searchDisplayController.searchResultsTableView;
			int count = 0;
			for(int i = 0;i < [[self.filteredHistory allKeys] count];i++){
				for(UserInfo* searching in [self.filteredHistory objectForKey:[[self.filteredHistory allKeys] objectAtIndex:i]]){
					count++;	
				}
			}
			if(count == 0)
				return count;
			
			return [self.filteredHistory count];
		}
		if(tableView == self.tableView){
			currentTableView = self.tableView;
			if(self.viewList)
				return [self.peopleInBuddy count];
			else
				return [self.peopleInGroup count];
		}
	
	}
	else {
		if(tableView == self.tableView){
			currentTableView = self.tableView;
			if(self.viewList)
				return [self.peopleInBuddy count];
			else
				return [self.peopleInGroup count];
		}
	}

		return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
//	NSString *key = nil;
	NSArray *nameSection = nil;
	
	GroupInfo* keygroup = [self.allGroups objectAtIndex:section];
	if(tableView == self.searchDisplayController.searchResultsTableView){ //검색 일경우
//		key = [[self.filteredHistory allKeys] objectAtIndex:section];
		nameSection = [self.filteredHistory objectForKey:keygroup.GROUPTITLE];
	}else if(tableView == self.tableView){ //일반 주소록
		NSDictionary* viewTypeDic = nil;
		if(!self.viewList){//전체 주소록
			viewTypeDic = self.peopleInGroup;
		}else {// 친구만..
			viewTypeDic = self.peopleInBuddy;
		}

//		key = [[viewTypeDic allKeys] objectAtIndex:section];
		nameSection = [viewTypeDic objectForKey:keygroup.GROUPTITLE];
	}
	
	if([self convertBoolValue:[self.statusGroup valueForKey:[NSString stringWithFormat:@"%i",section]]])
		return 0;
	/*
	if ([nameSection count] == 0) {
		return 1;
	 
	}
	 */
    return [nameSection count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];
	
    static NSString *CellIdentifier = @"AddressCellIdentifier";
//	NSString *key = nil;
	NSArray* sections = nil;
	GroupInfo *groupInfo = [self.allGroups objectAtIndex:indexPath.section];
	if(tableView == self.searchDisplayController.searchResultsTableView){ // 검색일경우
	//	key = [[self.filteredHistory allKeys] objectAtIndex:section];
		sections = [self.filteredHistory objectForKey:groupInfo.GROUPTITLE];
	}else if(tableView == self.tableView){//일반 주소록 일경우
		NSDictionary* viewTypeDic = nil;
		if(!self.viewList){// 전체 주소록
			viewTypeDic = self.peopleInGroup;
		}else {// 친구만..
			viewTypeDic = self.peopleInBuddy;
		}
		
//		key = [[viewTypeDic allKeys] objectAtIndex:section];
		sections = [viewTypeDic objectForKey:groupInfo.GROUPTITLE];
	}

    // Configure the cell...
	UserInfo *dataItem = [sections objectAtIndex:row]; // 현재 indexPath에 맞는 메모리 데이터 가져오기	
	
	
	ApplicationCell *cell = (ApplicationCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		
	
		//모바일, 집전화, 직장전화
		
        cell = [[[ApplicationCell alloc] initStyle:UITableViewCellStyleDefault reuseIdentifier:nil
											number:dataItem.MOBILEPHONENUMBER
										   number2:dataItem.HOMEPHONENUMBER
										   number3:dataItem.ORGPHONENUMBER
										   number4:dataItem.IPHONENUMBER
										   number5:dataItem.MAINPHONENUMBER] autorelease];
		cell.cellDelegate = self;
    }
	//  cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
//	NSLog(@"%@ `s %@ len -> %i",dataItem.FORMATTED, dataItem.STATUS, [dataItem.STATUS length]);
	if (dataItem.ISFRIEND && [dataItem.ISFRIEND isEqualToString:@"S"]) {
		if (dataItem.REPRESENTPHOTO && [dataItem.REPRESENTPHOTO length] > 0) {
			NSString *photoUrl = [NSString stringWithFormat:@"%@/011", dataItem.REPRESENTPHOTO];
//			NSLog(@"%@ `s photourl %@",dataItem.FORMATTED, photoUrl);
//					[cell.PhotoImageView setImageWithURL:[NSURL URLWithString:photoUrl] 
//														 placeholderImage:[UIImage imageNamed:@"img_default.png"]];
			[[[cell getInfoView] getPhotoView] setImageWithURL:[NSURL URLWithString:photoUrl]
											  placeholderImage:[UIImage imageNamed:@"img_default.png"]];
			[[[cell getButtonView] getPhotoView] setImageWithURL:[NSURL URLWithString:photoUrl]
												placeholderImage:[UIImage imageNamed:@"img_default.png"]];
		} else if (dataItem.THUMBNAILURL && [dataItem.THUMBNAILURL length] > 0) {
			NSString *photoUrl = [NSString stringWithFormat:@"%@/011", dataItem.THUMBNAILURL];
//			NSLog(@"%@ `s photourl %@",dataItem.FORMATTED, photoUrl);
//					[cell.PhotoImageView setImageWithURL:[NSURL URLWithString:photoUrl] 
//														 placeholderImage:[UIImage imageNamed:@"img_default.png"]];
			[[[cell getInfoView] getPhotoView] setImageWithURL:[NSURL URLWithString:photoUrl]
											  placeholderImage:[UIImage imageNamed:@"img_default.png"]];
			[[[cell getButtonView] getPhotoView] setImageWithURL:[NSURL URLWithString:photoUrl]
												placeholderImage:[UIImage imageNamed:@"img_default.png"]];
		} else {
			cell.photoImage = [UIImage imageNamed:@"img_default.png"];
		}
	} else if (dataItem.ISFRIEND && [dataItem.ISFRIEND isEqualToString:@"A"]) {
//		if(dataItem.REPRESENTPHOTO && [dataItem.REPRESENTPHOTO length] > 0){
//			NSString *photoUrl = [NSString stringWithFormat:@"%@/011", dataItem.REPRESENTPHOTO];
////			[cell.PhotoImageView setImageWithURL:[NSURL URLWithString:photoUrl] 
////								placeholderImage:[UIImage imageNamed:@"img_default.png"]];	
//			[[[cell getInfoView] getPhotoView] setImageWithURL:[NSURL URLWithString:photoUrl]
//											  placeholderImage:[UIImage imageNamed:@"img_default.png"]];
//			[[[cell getButtonView] getPhotoView] setImageWithURL:[NSURL URLWithString:photoUrl]
//												placeholderImage:[UIImage imageNamed:@"img_default.png"]];
//			
//		}else 
		if (dataItem.THUMBNAILURL && [dataItem.THUMBNAILURL length] > 0) {
			NSString *photoUrl = [NSString stringWithFormat:@"%@/011", dataItem.THUMBNAILURL];
//			NSLog(@"%@ `s photourl %@",dataItem.FORMATTED, photoUrl);
//					[cell.PhotoImageView setImageWithURL:[NSURL URLWithString:photoUrl] 
//														 placeholderImage:[UIImage imageNamed:@"img_default.png"]];
			[[[cell getInfoView] getPhotoView] setImageWithURL:[NSURL URLWithString:photoUrl]
											  placeholderImage:[UIImage imageNamed:@"img_default.png"]];
			[[[cell getButtonView] getPhotoView] setImageWithURL:[NSURL URLWithString:photoUrl]
												placeholderImage:[UIImage imageNamed:@"img_default.png"]];
		} else {
			cell.photoImage = [UIImage imageNamed:@"img_default.png"];
		}
	} else if (dataItem.ISFRIEND && [dataItem.ISFRIEND isEqualToString:@"N"]) {
		if (dataItem.THUMBNAILURL && [dataItem.THUMBNAILURL length] > 0) {
			NSString *photoUrl = [NSString stringWithFormat:@"%@/011", dataItem.THUMBNAILURL];
//			NSLog(@"%@ `s photourl %@",dataItem.FORMATTED, photoUrl);
			//		[cell.PhotoImageView setImageWithURL:[NSURL URLWithString:photoUrl] 
			//											 placeholderImage:[UIImage imageNamed:@"img_default.png"]];
			[[[cell getInfoView] getPhotoView] setImageWithURL:[NSURL URLWithString:photoUrl]
											  placeholderImage:[UIImage imageNamed:@"img_default.png"]];
			[[[cell getButtonView] getPhotoView] setImageWithURL:[NSURL URLWithString:photoUrl]
												placeholderImage:[UIImage imageNamed:@"img_default.png"]];
		} else {
			cell.photoImage = [UIImage imageNamed:@"img_default.png"];
		}
	} else {
		// error
	}

//	if([allNames count] < 100)
//		NSLog(@"formatted %@ friendstat %@ RPKey %@",dataItem.FORMATTED, dataItem.ISFRIEND, dataItem.RPKEY);
	
	if([dataItem.ISFRIEND isEqualToString:@"S"]){// 친구일경우 접속 상태 정보 표시 // 0:offline  1:online  2:busy (바빠요)  8:곧 돌아옵니다.  16:다른용무중
		if([dataItem.IMSTATUS intValue] == 0)
			dataItem.IMSTATUS = [NSString stringWithFormat:@"1"];
		switch ([dataItem.IMSTATUS intValue]) {
			case 0:
				cell.statusImage = [UIImage imageNamed:@"state_off.png"];
				break;
			case 1:
				cell.statusImage = [UIImage imageNamed:@"state_on.png"];
				break;
			case 2:
				cell.statusImage = [UIImage imageNamed:@"state_busy.png"];
				break;
			case 8:
				cell.statusImage = [UIImage imageNamed:@"state_time.png"];
				break;
			case 16:
				cell.statusImage = [UIImage imageNamed:@"state_do.png"];
				break;
			default:
				break;
		}
	}else{
		cell.statusImage = [UIImage imageNamed:@"state_public.png"];
		
	}
	
	
	
	if(dataItem.FORMATTED != nil && [dataItem.FORMATTED length] > 0) {
		cell.nameTitle = [NSString stringWithFormat:@"%@", dataItem.FORMATTED];
	} else if(dataItem.PROFILENICKNAME != nil && [dataItem.PROFILENICKNAME length] > 0) {
				cell.nameTitle = [NSString stringWithFormat:@"%@", dataItem.PROFILENICKNAME];
	} else if(dataItem.NICKNAME != nil && [dataItem.NICKNAME length] > 0) {
				cell.nameTitle = [NSString stringWithFormat:@"%@", dataItem.NICKNAME];
	} else {
		cell.nameTitle = @"이름 없음";
	}
	
#ifdef MEZZO_DEBUG
	DebugLog(@"profile = %@", dataItem.PROFILENICKNAME);
	DebugLog(@"nickname = %@", dataItem.NICKNAME);
	DebugLog(@"formate = %@", dataItem.FORMATTED);
#endif

	/*
	if(dataItem.FORMATTED != nil && [dataItem.FORMATTED length] > 0) {
		cell.nameTitle = [NSString stringWithFormat:@"%@", dataItem.FORMATTED];
	} else if(dataItem.PROFILENICKNAME != nil && [dataItem.PROFILENICKNAME length] > 0) {
		cell.nameTitle = [NSString stringWithFormat:@"%@", dataItem.PROFILENICKNAME];
	} else if(dataItem.NICKNAME != nil && [dataItem.NICKNAME length] > 0) {
		cell.nameTitle = [NSString stringWithFormat:@"%@", dataItem.NICKNAME];
	} else {
		cell.nameTitle = @"이름 없음";
	}
	 */
	if(dataItem.STATUS != nil && [dataItem.STATUS length] > 0){
		NSLog(@"dataItem subtitle =%@", dataItem.STATUS);
		cell.subTitle = [NSString stringWithFormat:@"%@", dataItem.STATUS];
		
	}else{
		cell.subTitle = @"";
	}
//	NSLog(@"whois = %@ subTitle = %@",dataItem.FORMATTED, dataItem.STATUS);
	if([[dataItem.ISFRIEND uppercaseString] isEqualToString:@"S"])
		cell.isBuddy = YES;
	else
		cell.isBuddy = NO;
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	NSLocale *locale = [NSLocale currentLocale];
	[formatter setLocale:locale];
	[formatter setDateFormat:@"yyyyMMdd"];
	NSDate *today = [NSDate date];
	NSString *dateOftoday = [[NSString alloc] initWithFormat:@"%@",[formatter stringFromDate:today]];
	
//	DebugLog(@"dataItem = %@",dataItem.CHANGEDATE);

	if(dataItem.CHANGEDATE != nil && [dataItem.CHANGEDATE length] > 0){
		
//		NSLog(@"추가 하거나 업데이트??");
		
		
		
		if([[dataItem.CHANGEDATE substringToIndex:8] isEqualToString:dateOftoday]){//변경된 일자가 오늘일경우
			if([[dataItem.ISFRIEND uppercaseString] isEqualToString:@"S"]){//서로 친구일경우
				cell.contentView.backgroundColor = ColorFromRGB(0xfffbb5);
			}else {// 한쪽만 친구 이거나, 친구가 아닐경우
				cell.contentView.backgroundColor = ColorFromRGB(0xfffbb5);//(무조건 추가하면 바꿈)
				//cell.contentView.backgroundColor = [UIColor whiteColor];
			}
		}else {//변경된 일자가 오늘이 아닐경우
			cell.contentView.backgroundColor = [UIColor whiteColor];
		}
	}else{
		cell.contentView.backgroundColor = [UIColor whiteColor];
	}
	[dateOftoday release];
	[formatter release];
	
	if([self appDelegate].connectionType == -1)
		cell.isBuddy = NO;
	
	if(cell.bButtonView) //버튼이미지로 있을 경우.
		[cell selectViewChange:cell.isBuddy];

	[cell setNeedsLayout];//셀 이미지 갱신.
	
//	key = nil;
	sections = nil;
	
//	NSLog(@"================ADDRESSView Controller CELL=========================");
	
    return cell;
}

#pragma mark -
#pragma mark Buddy and Group community button Method
-(void) customCellDetailSelect:(ApplicationCell*)senderCell{
	
	NSLog(@"detail select");
	
	if([self.selectedPerson count] > 0){
		NSIndexPath* oldIndexPath = [self.selectedPerson objectAtIndex:0];
		ApplicationCell* cell = (ApplicationCell*)[self.currentTableView cellForRowAtIndexPath:oldIndexPath];
		if(cell.bButtonView){
			[cell selectViewChange:cell.isBuddy];
		}
		[self.selectedPerson removeObjectAtIndex:[self.selectedPerson indexOfObject:oldIndexPath]];
	}
	
	NSIndexPath* selectedIndexPath = [self.currentTableView indexPathForCell:senderCell];
	//	NSUInteger section = [indexPath section];
	NSUInteger row = [selectedIndexPath row];
	//	NSString *key = nil;
	NSArray* sections = nil;
	GroupInfo *groupInfo = [self.allGroups objectAtIndex:selectedIndexPath.section];
	if(self.currentTableView == self.searchDisplayController.searchResultsTableView){
		//		key = [[self.filteredHistory allKeys] objectAtIndex:section];
		sections = [self.filteredHistory objectForKey:groupInfo.GROUPTITLE];
	}else if(self.currentTableView == self.tableView){
		NSDictionary* viewTypeDic = nil;
		if(!self.viewList){
			viewTypeDic = self.peopleInGroup;
		}else {
			viewTypeDic = self.peopleInBuddy;
		}
		//		key = [[viewTypeDic allKeys] objectAtIndex:section];
		sections = [viewTypeDic objectForKey:groupInfo.GROUPTITLE];
	}
	
	UserInfo *userInfo = [sections objectAtIndex:row];
	
	
	
	
	
	if([userInfo.ISFRIEND isEqualToString:@"S"]){
		if([self appDelegate].connectionType == -1){
			BuddyPersonViewController* personViewController = [[[BuddyPersonViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
			personViewController.hidesBottomBarWhenPushed = YES;  //탭바 안보이게 하기
			// 내비게이션 컨트롤 관계상 self를 사용할수 없기 때문에 자신의 컨트롤을 넣어둠.
//			personViewController.parentController = personViewController; 
			personViewController.personDelegate = self;
			personViewController.personInfo = [userInfo copy];
			[personViewController.view setFrame:self.view.frame];
			
//			personViewController.title=@"주소록 정보";
			UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
			assert(titleView != nil);
			UIFont *titleFont = [UIFont systemFontOfSize:20];
			CGSize titleStringSize = [@"주소록 정보" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
			assert(titleFont != nil);
			UILabel *naviTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
			assert(naviTitleLabel != nil);
			[naviTitleLabel setFont:titleFont];
			naviTitleLabel.textAlignment = UITextAlignmentCenter;
			[naviTitleLabel setTextColor:ColorFromRGB(0x053844)];
			[naviTitleLabel setBackgroundColor:[UIColor clearColor]];
			[naviTitleLabel setText:@"주소록 정보"];
//			naviTitleLabel.shadowColor = [UIColor whiteColor];
			[titleView addSubview:naviTitleLabel];	
			[naviTitleLabel release];
			personViewController.navigationItem.titleView = titleView;
			[titleView release];
			personViewController.navigationItem.titleView.frame = CGRectMake((personViewController.tableView.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);
			[self.navigationController pushViewController:personViewController animated:YES];
			
		}else {
			AddressDetailViewController* addrDetailInfoController = [[AddressDetailViewController alloc] initWithNibName:@"AddressDetailViewController" bundle:nil];
			addrDetailInfoController.userRPKey = userInfo.RPKEY;
			addrDetailInfoController.userFormatted = userInfo.FORMATTED;
			
			NSLog(@"useInfo Pre = %@", userInfo.THUMBNAILURL);
			
			
			//addrDetailInfoController.passUserInfo = [userInfo copy];
			
			addrDetailInfoController.passUserInfo = userInfo;
			addrDetailInfoController.dtlDelegate = self;
			addrDetailInfoController.hidesBottomBarWhenPushed = YES;  //탭바 안보이게 하기
			[self.navigationController pushViewController:addrDetailInfoController animated:YES];
			[addrDetailInfoController release];
		}
		
	}else {
		//일반 유저의 주소록
		BuddyPersonViewController* personViewController = [[[BuddyPersonViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
		personViewController.hidesBottomBarWhenPushed = YES;  //탭바 안보이게 하기
		// 내비게이션 컨트롤 관계상 self를 사용할수 없기 때문에 자신의 컨트롤을 넣어둠.
//		personViewController.parentController = personViewController; 
		personViewController.personDelegate = self;
		personViewController.personInfo = userInfo;
		
//		personViewController.title=@"주소록 정보";
		UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
		assert(titleView != nil);
		UIFont *titleFont = [UIFont systemFontOfSize:20];
		CGSize titleStringSize = [@"주소록 정보" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
		assert(titleFont != nil);
		UILabel *naviTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
		assert(naviTitleLabel != nil);
		[naviTitleLabel setFont:titleFont];
		naviTitleLabel.textAlignment = UITextAlignmentCenter;
		[naviTitleLabel setTextColor:ColorFromRGB(0x053844)];
		[naviTitleLabel setBackgroundColor:[UIColor clearColor]];
		[naviTitleLabel setText:@"주소록 정보"];
//		naviTitleLabel.shadowColor = [UIColor whiteColor];
		[titleView addSubview:naviTitleLabel];	
		[naviTitleLabel release];
		personViewController.navigationItem.titleView = titleView;
		[titleView release];
		personViewController.navigationItem.titleView.frame = CGRectMake((personViewController.tableView.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);
		
		[personViewController.view setFrame:self.view.frame];
		[self.navigationController pushViewController:personViewController animated:YES];
		
	}
	
}
#pragma mark -
#pragma mark Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //메뉴 셀로 변환 또는 메뉴 셀을 추가
//	NSUInteger newSection = [indexPath section];
	NSUInteger newRow = [indexPath row];

	UITableView* cellTableView = nil;
	if(tableView == self.tableView)
		cellTableView = self.tableView;
	if(tableView == self.searchDisplayController.searchResultsTableView)
		cellTableView = self.searchDisplayController.searchResultsTableView;
	
//	ApplicationCell* cell = (ApplicationCell*)[cellTableView cellForRowAtIndexPath:indexPath];
	
//	NSString *key = nil;
	NSArray* sections = nil;
	GroupInfo *groupInfo = [self.allGroups objectAtIndex:indexPath.section];
	if(tableView == self.searchDisplayController.searchResultsTableView){
	//	key = [[self.filteredHistory allKeys] objectAtIndex:newSection];
		sections = [self.filteredHistory objectForKey:groupInfo.GROUPTITLE];
	}else if(tableView == self.tableView) {
		NSDictionary* viewTypeDic = nil;
		if(!self.viewList){
			viewTypeDic = self.peopleInGroup;
		}else {
			viewTypeDic = self.peopleInBuddy;
		}
		
//		key = [[viewTypeDic allKeys] objectAtIndex:newSection];
		sections = [viewTypeDic objectForKey:groupInfo.GROUPTITLE];
	}
	UserInfo *dataItem = [sections objectAtIndex:newRow];
	NSLog(@"num = %@", dataItem.MOBILEPHONENUMBER);
	
	
	
	
	
	//int flag=0;
	
		if([self.selectedPerson count] > 0){//버튼 셀인 셀이 있는지 확인
			
					
			
		NSIndexPath* oldIndexPath = [self.selectedPerson objectAtIndex:0];
		if([oldIndexPath compare:indexPath] == NSOrderedSame){
			ApplicationCell* oldCell = (ApplicationCell*)[cellTableView cellForRowAtIndexPath:oldIndexPath];
//			CGRect frame = oldCell.contentView.frame;
//			frame.size.height = 58.0;
//			oldCell.contentView.frame = frame;
			if(oldCell.bButtonView)
			{
				[oldCell selectViewChange:oldCell.isBuddy];
			
			}
			
			[self.selectedPerson removeObjectAtIndex:[self.selectedPerson indexOfObject:oldIndexPath]];
		}else{
			ApplicationCell* oldCell = (ApplicationCell*)[cellTableView cellForRowAtIndexPath:oldIndexPath];
//			CGRect oldframe = oldCell.contentView.frame;
//			oldframe.size.height = 58.0;
//			oldCell.contentView.frame = oldframe;
			
			if(oldCell.bButtonView)
			{
				[oldCell selectViewChange:oldCell.isBuddy];
				
				
				
			}
			
			[self.selectedPerson removeObjectAtIndex:[self.selectedPerson indexOfObject:oldIndexPath]];
			
			ApplicationCell* currentCell = (ApplicationCell*)[cellTableView cellForRowAtIndexPath:indexPath];
			if([[dataItem.ISFRIEND uppercaseString] isEqualToString:@"S"])
				currentCell.isBuddy = YES;
			else
				currentCell.isBuddy = NO;
			
//			CGRect frame = currentCell.contentView.frame;
//			frame.size.height = 59.0;
//			currentCell.contentView.frame = frame;
			
			[currentCell selectViewChange:currentCell.isBuddy];

			
			
			[self.selectedPerson addObject:indexPath];
		}
		
		
	}else {
		ApplicationCell* currentCell = (ApplicationCell*)[cellTableView cellForRowAtIndexPath:indexPath];
		if([[dataItem.ISFRIEND uppercaseString] isEqualToString:@"S"])
			currentCell.isBuddy = YES;
		else
			currentCell.isBuddy = NO;
		
		[currentCell selectViewChange:currentCell.isBuddy];
		
		[self.selectedPerson addObject:indexPath];
	}
	
//[self.selectedPerson addObject:indexPath];
	
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	CustomHeaderView* customHeaderView = [[[CustomHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.currentTableView.tableHeaderView.frame.size.width, 39.0)]autorelease];

	if([self convertBoolValue:[self.statusGroup valueForKey:[NSString stringWithFormat:@"%i",section]]]){

		customHeaderView.groupFold.image = [UIImage imageNamed:@"btn_close.png"];
	}else{

		customHeaderView.groupFold.image = [UIImage imageNamed:@"btn_open.png"];
	}

	//section별 그룹인원 구하기
//	NSString *key = nil;
	NSArray *nameSection = nil;
	GroupInfo* keygroup = [self.allGroups objectAtIndex:section];
	if(tableView == self.searchDisplayController.searchResultsTableView){
//		key = [[self.filteredHistory allKeys] objectAtIndex:section];
		nameSection = [self.filteredHistory objectForKey:keygroup.GROUPTITLE];
		int oncount = 0;
		for(UserInfo* OnOffuser in nameSection){
			if([OnOffuser.ISFRIEND isEqualToString:@"S"]){
//				if([OnOffuser.IMSTATUS intValue] != 0)
					oncount++;
			}
		}
		

		
		if(self.viewList) {//친구 보기 모드에서 검색일 경우 친구의 수만 표시 
//			customHeaderView.groupName.text = [NSString stringWithFormat:@"%@ (%i)",[[filteredHistory allKeys] objectAtIndex:section], oncount];
			customHeaderView.groupName.text = [NSString stringWithFormat:@"%@ (%i)",keygroup.GROUPTITLE, oncount];
		}else{ // 전체 보기 모드에서 검색일 경우, 검색된 해당그룹의 전체 인원과 버디인원 표시
//			customHeaderView.groupName.text = [NSString stringWithFormat:@"%@ (%i/%i)",[[filteredHistory allKeys] objectAtIndex:section], oncount,[nameSection count]];
			customHeaderView.groupName.text = [NSString stringWithFormat:@"%@ (%i/%i)",keygroup.GROUPTITLE, oncount,[nameSection count]];
		}
	//	for(GroupInfo* filgrp in self.allGroups){
	//		if([filgrp.GROUPTITLE isEqualToString:keygroup.GROUPTITLE])
				customHeaderView.groupID = keygroup.ID;
	//	}
//		customHeaderView.isSearch = YES;
		
		
		
	}
	else if(tableView == self.tableView)
	{
		[customHeaderView.groupEdit setImage:[UIImage imageNamed:@"btn_group_msg.png"] forState:UIControlStateNormal];
		[customHeaderView.groupEdit setImage:[UIImage imageNamed:@"btn_group_msg_focus.png"] forState:UIControlStateHighlighted];
		[customHeaderView.groupEdit setImage:[UIImage imageNamed:@"btn_group_msg_dim.png"] forState:UIControlStateDisabled];
		
		NSDictionary* viewTypeDic = nil;
		if(!self.viewList){
			viewTypeDic = self.peopleInGroup;
		}else {
			viewTypeDic = self.peopleInBuddy;
		}
//		key = [[viewTypeDic allKeys] objectAtIndex:section];
		nameSection = [viewTypeDic objectForKey:keygroup.GROUPTITLE];
		int oncount = 0;
		for(UserInfo* OnOffuser in nameSection){
			if([OnOffuser.ISFRIEND isEqualToString:@"S"]){
//				if([OnOffuser.IMSTATUS intValue] != 0)
					oncount++;
			}
		}
		if(self.viewList){//친구 보기 일경우. 해당 그룹의 버디 인원만 표시
//			customHeaderView.groupName.text = [NSString stringWithFormat:@"%@ (%i)",[[viewTypeDic allKeys] objectAtIndex:section], oncount];
			customHeaderView.groupName.text = [NSString stringWithFormat:@"%@ (%i)",keygroup.GROUPTITLE, oncount];
		}else{//전체보기 일경우 해당 그룹의 전체 인원과 버디 인원 표시
//			customHeaderView.groupName.text = [NSString stringWithFormat:@"%@ (%i/%i)",[[viewTypeDic allKeys] objectAtIndex:section], oncount,[nameSection count]];
			customHeaderView.groupName.text = [NSString stringWithFormat:@"%@ (%i/%i)",keygroup.GROUPTITLE, oncount,[nameSection count]];
		}		
		
//		for(GroupInfo* normgrp in self.allGroups){
//			if([normgrp.GROUPTITLE isEqualToString:[[viewTypeDic allKeys] objectAtIndex:section]])
				customHeaderView.groupID = keygroup.ID;
		//		}
//		customHeaderView.isSearch = NO;
	
		if([nameSection count] != 0)
		{
		[customHeaderView.groupEdit addTarget:self action:@selector(groupEditEvent:) forControlEvents:UIControlEventTouchUpInside];
		}
		else {//이미지만 변경하면 끗.
			
			[customHeaderView.groupEdit setEnabled:NO];
			
			/*
			[customHeaderView.groupEdit setImage:[UIImage imageNamed:@"group_message_normal.png"] forState:UIControlStateNormal];
			[customHeaderView.groupEdit setImage:[UIImage imageNamed:@"group_message_normal.png"] forState:UIControlStateHighlighted];
			*/
		}

	}
//	key = nil;
	
	customHeaderView.section = section;
	customHeaderView.folded = [self convertBoolValue:[self.statusGroup valueForKey:[NSString stringWithFormat:@"%i",section]]];
	[customHeaderView addTarget:self action:@selector(headerEvent:) forControlEvents:UIControlEventTouchUpInside];
	
	[self.statusGroup setValue:customHeaderView.folded?@"YES":@"NO" forKey:[NSString stringWithFormat:@"%i",section]];
	
	

	return customHeaderView;
}

-(void)groupEditEvent:(id)sender{
	if([self.selectedPerson count] > 0){
		NSIndexPath* oldIndexPath = [self.selectedPerson objectAtIndex:0];
		ApplicationCell* cell = (ApplicationCell*)[self.currentTableView cellForRowAtIndexPath:oldIndexPath];
		if(cell.bButtonView){
			[cell selectViewChange:cell.isBuddy];
		}
		[self.selectedPerson removeObjectAtIndex:[self.selectedPerson indexOfObject:oldIndexPath]];
	}
#if TARGET_IPHONE_SIMULATOR	
//	NSLog(@"groupEditEvent");
#endif

	UIButton* recieveButton = (UIButton*)sender;
	
	CustomHeaderView* selHeaderView = (CustomHeaderView*)[recieveButton superview];
	
	NSString* viewTitle =  selHeaderView.groupName.text;
	NSString* groupIdentity = selHeaderView.groupID;
	
	
//	CGRect viewBounds = [[UIScreen mainScreen] applicationFrame]; 
	CGRect viewBounds = [[UIScreen mainScreen] bounds]; //상태바를 포함하는 화면 전체크기 반환
	GroupCommunityView* groupView = [[GroupCommunityView alloc] initWithFrame:viewBounds];	

	UIWindow* mainWindow = [self appDelegate].window;
	
	groupView.groupTtitleLabel.text = viewTitle;
	groupView.groupID = groupIdentity;
	groupView.evnetDelegate = self;
	[groupView showInView:mainWindow];
	[groupView release];
}

-(void)headerEvent :(id)sender{
//	NSLog(@"headerEvent");
	// mezzo 검색 중일때는 그룹 닫지 않도록 처리
	if(self.currentTableView == self.searchDisplayController.searchResultsTableView){
		//	key = [[self.filteredHistory allKeys] objectAtIndex:newSection];
		return;
	}
	
	if([self.selectedPerson count] > 0){
		NSIndexPath* oldIndexPath = [self.selectedPerson objectAtIndex:0];
		ApplicationCell* cell = (ApplicationCell*)[self.currentTableView cellForRowAtIndexPath:oldIndexPath];
		if(cell.bButtonView){
			[cell selectViewChange:cell.isBuddy];
		}
		[self.selectedPerson removeObjectAtIndex:[self.selectedPerson indexOfObject:oldIndexPath]];
	}
	
	CustomHeaderView* addrHeaderView = (CustomHeaderView *)sender;
	addrHeaderView.folded = !addrHeaderView.folded;

	[self.statusGroup setValue:addrHeaderView.folded?@"YES":@"NO" forKey:[NSString stringWithFormat:@"%i",addrHeaderView.section]];

	[self.currentTableView reloadData];//검색창, 친구, 일반의 tableView
	/*
	USayAppAppDelegate *parentView = (USayAppAppDelegate*) [[UIApplication sharedApplication] delegate];
	UINavigationController *tmp = [parentView.rootController.viewControllers objectAtIndex:1];
	AddressViewController *tmpAdd = (AddressViewController*)[tmp.viewControllers objectAtIndex:1];
	[tmpAdd.currentTableView reloadData];
*/
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(tableView == self.searchDisplayController.searchResultsTableView)
		return 58.0;
	return 58.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 39.0;
}
/*
-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {

	if([self.selectedPerson count] > 0){
		NSIndexPath* oldIndexPath = [self.selectedPerson objectAtIndex:0];
		ApplicationCell* cell = (ApplicationCell*)[self.currentTableView cellForRowAtIndexPath:oldIndexPath];
		if(cell.bButtonView){
			[cell selectViewChange];
		}
		[self.selectedPerson removeObjectAtIndex:[self.selectedPerson indexOfObject:oldIndexPath]];
	}
	
//	NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];
//	NSString *key = nil;
	NSArray* sections = nil;
	GroupInfo *groupInfo = [self.allGroups objectAtIndex:indexPath.section];
	if(tableView == self.searchDisplayController.searchResultsTableView){
//		key = [[self.filteredHistory allKeys] objectAtIndex:section];
		sections = [self.filteredHistory objectForKey:groupInfo.GROUPTITLE];
	}else if(tableView == self.tableView){
		NSDictionary* viewTypeDic = nil;
		if(!self.viewList){
			viewTypeDic = self.peopleInGroup;
		}else {
			viewTypeDic = self.peopleInBuddy;
		}
//		key = [[viewTypeDic allKeys] objectAtIndex:section];
		sections = [viewTypeDic objectForKey:groupInfo.GROUPTITLE];
	}
	
	UserInfo *userInfo = [sections objectAtIndex:row];
	if([userInfo.ISFRIEND isEqualToString:@"S"]){
		if([self appDelegate].connectionType == -1){
			BuddyPersonViewController* personViewController = [[BuddyPersonViewController alloc] initWithStyle:UITableViewStyleGrouped];
			personViewController.hidesBottomBarWhenPushed = YES;  //탭바 안보이게 하기
			// 내비게이션 컨트롤 관계상 self를 사용할수 없기 때문에 자신의 컨트롤을 넣어둠.
	//		personViewController.parentController = personViewController; 
			personViewController.personDelegate = self;
			personViewController.personInfo = [userInfo copy];
			[personViewController.view setFrame:self.view.frame];
			[self.navigationController pushViewController:personViewController animated:YES];
			self.title=@"주소록 정보";
		}else {
			AddressDetailViewController* addrDetailInfoController = [[AddressDetailViewController alloc] initWithNibName:@"AddressDetailViewController" bundle:nil];
			addrDetailInfoController.userRPKey = userInfo.RPKEY;
			addrDetailInfoController.userFormatted = userInfo.FORMATTED;
			addrDetailInfoController.passUserInfo = [userInfo copy];
			addrDetailInfoController.dtlDelegate = self;
			addrDetailInfoController.hidesBottomBarWhenPushed = YES;  //탭바 안보이게 하기
			[self.navigationController pushViewController:addrDetailInfoController animated:YES];
			[addrDetailInfoController release];
		}
		
	}else {
		//일반 유저의 주소록
		BuddyPersonViewController* personViewController = [[BuddyPersonViewController alloc] initWithStyle:UITableViewStyleGrouped];
		personViewController.hidesBottomBarWhenPushed = YES;  //탭바 안보이게 하기
		// 내비게이션 컨트롤 관계상 self를 사용할수 없기 때문에 자신의 컨트롤을 넣어둠.
	//	personViewController.parentController = personViewController; 
		personViewController.personDelegate = self;
		personViewController.personInfo = [userInfo copy];
		[personViewController.view setFrame:self.view.frame];
		[self.navigationController pushViewController:personViewController animated:YES];
		self.title=@"주소록 정보";
		
	}

	
}*/
#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
//	isMemoryWarning = YES;
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}





-(void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	[super viewDidUnload];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"buddyPresenceChange" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"newFriendIncome" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"buddyBlockCancel" object:nil];
}

- (void)dealloc {
	if(msgSearchArray)[msgSearchArray release];
	if(chosungNumArray)[chosungNumArray release];
	if(chosungArray)[chosungArray release];
	if(jungsungArray)[jungsungArray release];
	if(jongsungArray)[jongsungArray release];
	
	if(allNames)[allNames release];
	if(allGroups)[allGroups release];
	if(peopleInGroup)[peopleInGroup release];
	if(filteredHistory)[filteredHistory release];
	if(searchArray)[searchArray release];
	if(statusGroup)[statusGroup release];
	if(lastIndexPath)[lastIndexPath release];
	if(peopleInBuddy)[peopleInBuddy release];
	if(currentTableView)[currentTableView release];
	if(selectedPerson)[selectedPerson release];
	if(profileUser) [profileUser release];
	if(myLabel)
		[myLabel release];
	if(pickerTitleView)
		[pickerTitleView release];
	if(pickerTitleLabel)
		[pickerTitleLabel release];
	[super dealloc];
}


#pragma mark -
#pragma mark 네비게이션

- (void) cancelModal
{
	MFMessageComposeViewController *myPicker = (MFMessageComposeViewController*)self.modalViewController;
	[myPicker dismissModalViewControllerAnimated:YES];

	if([pickerTitleLabel superview])
	{
		[pickerTitleLabel removeFromSuperview];
	}
	if([pickerTitleView superview])
		[pickerTitleView removeFromSuperview];
}
/*
-(void)backNavi
{
	MFMessageComposeViewController *myPicker = (MFMessageComposeViewController*)self.modalViewController;
	[myPicker popViewControllerAnimated:YES];
}
*/
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	MFMessageComposeViewController *myPicker = (MFMessageComposeViewController*)self.modalViewController;

	
	
	NSLog(@"msg title = %@", myPicker.title);
NSLog(@"msg bar = %@", myPicker.navigationBar);
	NSLog(@"msg top = %@", myPicker.navigationBar.topItem);
	myPicker.navigationBar.topItem.title=@"";
//	myPicker.navigationBar.alpha=0.0001;
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	
	MFMessageComposeViewController *myPicker = (MFMessageComposeViewController*)self.modalViewController;
	
	UIButton *preButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 52, 31)] autorelease];
	[preButton setBackgroundImage:[UIImage imageNamed:@"btn_top_left.png"] forState:UIControlStateNormal];
	[preButton setBackgroundImage:[UIImage imageNamed:@"btn_top_left_focus"] forState:UIControlStateHighlighted];
	[preButton addTarget:self action:@selector(backNavi) forControlEvents:UIControlEventTouchUpInside];
	
	
//	UIBarButtonItem *backButton = [[[UIBarButtonItem alloc] initWithCustomView:preButton] autorelease];
	
	
	
	
	
	UIButton *cancelButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 47, 31)] autorelease];
	[cancelButton setBackgroundImage:[UIImage imageNamed:@"btn_searchbar_cancel.png"] forState:UIControlStateNormal];
	[cancelButton setBackgroundImage:[UIImage imageNamed:@"btn_searchbar_cancel_focus.png"] forState:UIControlStateHighlighted];
	[cancelButton addTarget:self action:@selector(cancelModal) forControlEvents:UIControlEventTouchUpInside];
    
	UIBarButtonItem *rightButton = [[[UIBarButtonItem alloc] initWithCustomView:cancelButton] autorelease];
	
	
	[myPicker.navigationBar.topItem.backBarButtonItem setImage:[UIImage imageNamed:@"btn_top_left.png"]];
	myPicker.navigationBar.alpha=1;
	NSLog(@"title = %@", myPicker.navigationBar.topItem.title);
	myPicker.navigationBar.topItem.title=@"";
	/*
	if(![myPicker.navigationBar.topItem.title isEqualToString:@""])
	{
		myPicker.navigationBar.topItem.leftBarButtonItem = backButton;
		
	}
	*/
	
	
	
	
//	myPicker.navigationBar.topItem.title=@"";
	myPicker.navigationBar.topItem.rightBarButtonItem = rightButton;
	/*
	if(myLabel == NULL)
	{
		myLabel = [[UILabel alloc] initWithFrame:CGRectMake(105, 0, 120, 44)];
		[myLabel setBackgroundColor:[UIColor clearColor]];
		[myLabel setText:@"새로운 메시지"];
		[myLabel setFont:[UIFont systemFontOfSize:20]];
	}
		[myPicker.navigationBar addSubview:myLabel];
*/
	
	
	
	
	

	//		controller.navigationItem.titleView.frame = CGRectMake((self.buddyTableView.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, 20.0f);				
	
	
	
	
	
}

#pragma mark -
#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	
	[actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
	NSString* selectedButtonTitle = nil;
	if (buttonIndex != [actionSheet cancelButtonIndex])  
    {  
         selectedButtonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];  
		
	} else {
		// cancel
		
		return;
	}
	if([selectedButtonTitle isEqualToString:@"주소 이동"])
	{
		EditAddressViewController* editAddrController = [[EditAddressViewController alloc] init];
		
		
		[editAddrController editNumber:0];
		
		editAddrController.peopleInGroup = self.peopleInGroup;
		editAddrController.editDelegate = self;
		editAddrController.hidesBottomBarWhenPushed = YES;
		
		
		[self.navigationController pushViewController:editAddrController animated:YES];
	//	[editAddrController reloadAddressData];
		 [editAddrController release];
		
	}
	else if([selectedButtonTitle isEqualToString:@"주소 삭제"])
	{
	
		EditAddressViewController* editAddrController = [[EditAddressViewController alloc] init];
		[editAddrController editNumber:1];
		
		editAddrController.peopleInGroup = self.peopleInGroup;
		editAddrController.editDelegate = self;
		editAddrController.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:editAddrController animated:YES];
		[editAddrController release];
		
	}
	else if([selectedButtonTitle isEqualToString:@"그룹명 변경"])
	{
		EditAddressViewController* editAddrController = [[EditAddressViewController alloc] init];
		[editAddrController editNumber:2];
		
		editAddrController.peopleInGroup = self.peopleInGroup;
		editAddrController.editDelegate = self;
		editAddrController.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:editAddrController animated:YES];
		[editAddrController release];
		
		
	}
	else if([selectedButtonTitle isEqualToString:@"그룹 삭제"]){
	
		EditAddressViewController* editAddrController = [[EditAddressViewController alloc] init];
		[editAddrController editNumber:3];
		
		editAddrController.peopleInGroup = self.peopleInGroup;
		editAddrController.editDelegate = self;
		editAddrController.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:editAddrController animated:YES];
		[editAddrController release];
		
		
	}
	else if([selectedButtonTitle isEqualToString:@"새 주소 추가하기"]){
		
		AddBuddyViewController* addBuddyController = [[AddBuddyViewController alloc] initWithStyle:UITableViewStyleGrouped];
		addBuddyController.hidesBottomBarWhenPushed = YES;
		addBuddyController.addDelegate = self;
		[self.navigationController pushViewController:addBuddyController animated:YES];
		addBuddyController.peopleInGroup = self.peopleInGroup;
		[addBuddyController release];
		
	}else if([selectedButtonTitle isEqualToString:@"새 그룹 추가하기"]){
		
		AddGroupViewController* addGroupController = [[AddGroupViewController alloc] initWithStyle:UITableViewStyleGrouped];
		addGroupController.hidesBottomBarWhenPushed = YES;
		addGroupController.title = @"새 그룹 추가";
		addGroupController.addDelegate = self;
		////////// 타이틀 색 지정 //////////
		UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
		assert(titleView != nil);
		UIFont *titleFont = [UIFont systemFontOfSize:20];
		CGSize titleStringSize = [@"새 그룹 추가" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
		assert(titleFont != nil);
		UILabel *naviTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
		assert(naviTitleLabel != nil);
		[naviTitleLabel setFont:titleFont];
		naviTitleLabel.textAlignment = UITextAlignmentCenter;
		[naviTitleLabel setTextColor:ColorFromRGB(0x053844)];
		[naviTitleLabel setBackgroundColor:[UIColor clearColor]];
		[naviTitleLabel setText:@"새 그룹 추가"];
//		naviTitleLabel.shadowColor = [UIColor whiteColor];
		[titleView addSubview:naviTitleLabel];	
		[naviTitleLabel release];
		addGroupController.navigationItem.titleView = titleView;
		[titleView release];
		addGroupController.navigationItem.titleView.frame = CGRectMake((addGroupController.tableView.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);
		/////////////////////////////////
		
		[self.navigationController pushViewController:addGroupController animated:YES];
		[addGroupController release];
		
	}else if([selectedButtonTitle isEqualToString:@"주소록 편집하기"]){

		EditAddressViewController* editAddrController = [[EditAddressViewController alloc] init];
		editAddrController.peopleInGroup = self.peopleInGroup;
		editAddrController.editDelegate = self;
		editAddrController.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:editAddrController animated:YES];
		[editAddrController release];
		
	}
	else
	{
		if([actionSheet.title isEqualToString:@"sms 보내기"])
		{
			[self sendSMSwitRecipient:selectedButtonTitle];	// sochae 2010.10.08
#if 0
			if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 4.0)	// sochae 2010.10.05 - 4.0이상 사용 가능한 기능
			{	
				Class smsClass = (NSClassFromString(@"MFMessageComposeViewController"));
				if (smsClass != nil && [MFMessageComposeViewController canSendText]) {
					
					
									MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
					assert(controller != nil);
					controller.body = nil;
					controller.recipients = [NSArray arrayWithObject:selectedButtonTitle];	// your recipient number or self for testing
					controller.messageComposeDelegate = self;
					controller.delegate=self;
					
	
					
					/*
					UILabel *titleLabel  = [[[UILabel alloc] initWithFrame:CGRectMake(95, 9, 320, 44)] autorelease];
					[titleLabel setText:@"새로운 메시지"];
					[titleLabel setBackgroundColor:[UIColor clearColor]];
					[titleLabel setTextColor:[UIColor blackColor]];
					[titleLabel setFont:[UIFont systemFontOfSize:20]];
					[titleLabel sizeToFit];
					 */
				//	controller.navigationBar.topItem.title=@"";
				/*
					NSLog(@"msgModal = %@", controller.title);
					NSLog(@"msgModal2 = %@", controller.navigationBar.topItem.title);
				*/	
					
		
					[self presentModalViewController:controller animated:YES];
				
				//	NSLog(@"msgModal2 = %@", controller.navigationBar.topItem.rightBarButtonItem);
					controller.navigationBar.topItem.rightBarButtonItem=nil;
					controller.navigationBar.topItem.title=@"";
				//	controller.navigationBar.alpha=0.001;
					
					
					UIButton *cancelButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 47, 31)] autorelease];
					[cancelButton setBackgroundImage:[UIImage imageNamed:@"btn_searchbar_cancel.png"] forState:UIControlStateNormal];
					[cancelButton setBackgroundImage:[UIImage imageNamed:@"btn_searchbar_cancel_focus.png"] forState:UIControlStateHighlighted];
					[cancelButton addTarget:self action:@selector(cancelModal) forControlEvents:UIControlEventTouchUpInside];
					UIBarButtonItem *rightButton = [[[UIBarButtonItem alloc] initWithCustomView:cancelButton] autorelease];
					
					controller.navigationBar.topItem.rightBarButtonItem=rightButton;
				
					
		//			[controller.navigationBar.topItem setTitle:@" "];
			//		[controller.navigationBar addSubview:titleLabel];
					
					//NSLog(@"navi = %@", [controller ]);
					[controller release];              
				}else {
					UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"SMS 보내기" 
																	   message:@"SMS 기능을 사용 하실 수 없는 \n기기 입니다." 
																	  delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
					[alertView show];
					[alertView release];
					
				}

			}else{
				NSString* telno = [[NSString stringWithFormat:@"sms:%@",selectedButtonTitle]
								   stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				//		NSString* telno = [[NSString stringWithString:@"sms:010-3231-0142"] 
				//						   stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				BOOL open = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telno]];
				if(open == NO){
					UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"SMS 보내기" 
																	   message:@"SMS 기능을 사용 하실 수 없는 \n기기 입니다." 
																	  delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
					[alertView show];
					[alertView release];
				}
			}
#endif //if 0
		}
		else if([actionSheet.title isEqualToString:@"전화 걸기"])
		{
			NSString* telno = [[NSString stringWithFormat:@"tel:%@",selectedButtonTitle] 
							   stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

			BOOL open = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telno]];
			if(open == NO){
				UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"전화 걸기" 
																   message:@"전화 기능을 사용 하실 수 없는 \n기기 입니다." 
																  delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
				[alertView show];
				[alertView release];
			}
			
		}
	}
}

#pragma mark -
#pragma mark Buddy and Group community button Method
-(void)buddySayButtonClicked:(id)sender {
	// 대화 버튼
//	NSLog(@"buddySayButtonClicked");
//	UIButton* sayButton = (UIButton*)sender;
	
	if([self.selectedPerson count] > 0){
		NSIndexPath* oldIndexPath = [self.selectedPerson objectAtIndex:0];
//		ApplicationCell* cell = (ApplicationCell*)[self.currentTableView cellForRowAtIndexPath:oldIndexPath];
	
		NSInteger buttonSection = [oldIndexPath section];
		NSInteger buttonRow =[ oldIndexPath row];
		
//mezzo		NSString* sayBuddyrpKey = nil;
//		NSString* nickname = nil;
		GroupInfo* keygroup = [self.allGroups objectAtIndex:buttonSection];
		NSDictionary* viewTypeDic = nil;
		if(self.currentTableView == self.searchDisplayController.searchResultsTableView){
			viewTypeDic = self.filteredHistory;
		}else if(self.currentTableView == self.tableView){
			if(!self.viewList){
				viewTypeDic = self.peopleInGroup;
			}else {
				viewTypeDic = self.peopleInBuddy;
			}
		}

//		NSString *key = nil;
		NSArray* sections = nil;
		
		if (viewTypeDic && [viewTypeDic count] > 0) {
//			key = [[viewTypeDic allKeys] objectAtIndex:buttonSection];
			sections = [viewTypeDic objectForKey:keygroup.GROUPTITLE];							
			
			if (sections && [sections count] > 0) {
				UserInfo* buddyInfo = [sections objectAtIndex:buttonRow];
				//		NSLog(@"%@",buddyInfo.FORMATTED);
				if ([buddyInfo.RPKEY isEqualToString:[[[self appDelegate] myInfoDictionary] objectForKey:@"pkey"]]) {
					UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"대화 신청 불가" message:@"자기 자신과 대화를 하실수 없습니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
					[alertView show];
					[alertView release];
					return;
				}
				
				if([[buddyInfo.ISFRIEND uppercaseString] isEqualToString:@"S"]){
				//mezzo	sayBuddyrpKey = [NSString stringWithFormat:@"%@",buddyInfo.RPKEY];		
					NSMutableArray *selectUserPKeyArray = [NSMutableArray arrayWithObjects:buddyInfo.RPKEY, nil];
					if (selectUserPKeyArray && [selectUserPKeyArray count] > 0) {
						NSString *chatSession = [[self appDelegate] chatSessionFrompKey:selectUserPKeyArray];
						if (chatSession && [chatSession length] > 0) {
							// 채팅 대기실에 선택한 Users의 대화방 존재
							CellMsgListData *msgListData = [[self appDelegate] MsgListDataFromChatSession:chatSession];
							assert(msgListData != nil);
							@synchronized([self appDelegate].msgArray) {
								[[self appDelegate].msgArray removeAllObjects];
								NSArray *msgArray = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where CHATSESSION=?", chatSession, nil];
								if (msgArray && [msgArray count] > 0) {
									for (MessageInfo *messageInfo in msgArray) {
										CellMsgData *msgData = [[CellMsgData alloc] init];
										msgData.chatsession = messageInfo.CHATSESSION;
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
										[[self appDelegate].msgArray addObject:msgData];
										[msgData release];
									}
								}
							}
							NSString *sayTitle = nil;
							@synchronized([self appDelegate].msgListArray) {
								if ([self appDelegate].msgListArray && [[self appDelegate].msgListArray count] > 0) {
									for (CellMsgListData *msgListData in [self appDelegate].msgListArray) {
										if ([msgListData.chatsession isEqualToString:chatSession]) {
											if (msgListData.userDataDic && [msgListData.userDataDic count] > 0) {
												if ([msgListData.userDataDic count] == 1) {
													for (id key in msgListData.userDataDic) {
														MsgUserData *userData = (MsgUserData*)[msgListData.userDataDic objectForKey:key];
														if (userData) {
															sayTitle = userData.nickName;
															break;
														} else {
															// error
															sayTitle = @"이름 없음";
															break;
														}
													}
												} else if ([msgListData.userDataDic count] > 1) {
													sayTitle = [NSString stringWithFormat:@"그룹채팅 (%i명)", [msgListData.userDataDic count] + 1];
												} else {
													sayTitle = @"이름 없음";
												}
											}
										}
									}
								}
							}
							SayViewController *sayViewController = [[SayViewController alloc] initWithNibNameBuddyListMsgType:@"SayViewController" chatSession:chatSession type:msgListData.cType BuddyList:nil bundle:nil];
							if(sayViewController != nil) {
								UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
								assert(titleView != nil);
								UIFont *titleFont = [UIFont systemFontOfSize:20];

								// sochae 2010.09.11 - UI Position
								//CGRect rect = [MyDeviceClass deviceOrientation];
								CGRect rect = self.view.frame;
								// ~sochae
								
								CGSize titleStringSize = [sayTitle sizeWithFont:titleFont constrainedToSize:(CGSizeMake(rect.size.width-120.0, MAXFLOAT))];
								assert(titleFont != nil);
								UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, 20.0f)];
								assert(titleLabel != nil);
								[titleLabel setFont:titleFont];
								titleLabel.adjustsFontSizeToFitWidth =  YES;
								titleLabel.textAlignment = UITextAlignmentCenter;
								[titleLabel setTextColor:ColorFromRGB(0x053844)];
								[titleLabel setBackgroundColor:[UIColor clearColor]];
								[titleLabel setText:sayTitle];
//								titleLabel.shadowColor = [UIColor whiteColor];
								[titleView addSubview:titleLabel];	
								[titleLabel release];
								sayViewController.navigationItem.titleView = titleView;
								[titleView release];
								sayViewController.navigationItem.titleView.frame = CGRectMake((self.tableView.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, 20.0f);				
								
//								sayViewController.title = title;
								sayViewController.hidesBottomBarWhenPushed = YES;
								
								UINavigationController* naviController = self.navigationController;
								[naviController popToRootViewControllerAnimated:NO];
								
								[naviController pushViewController:sayViewController animated:YES];
								[sayViewController release];
							}
						} else {
							// 현해 대화방리스트에 존재 하지 않음.
							// 새로 대화방 생성해야함.
							UINavigationController* naviController = [self.tabBarController.viewControllers objectAtIndex:1];
							
							SayViewController *sayViewController = [[SayViewController alloc] initWithNibNameBuddyListMsgType:@"SayViewController" chatSession:nil type:nil BuddyList:selectUserPKeyArray bundle:nil];
							if(sayViewController != nil) {
								NSString *sayTitle = nil;
								if (buddyInfo.FORMATTED && [buddyInfo.FORMATTED length] > 0) {
									sayTitle = buddyInfo.FORMATTED;
								} else if (buddyInfo.PROFILENICKNAME && [buddyInfo.PROFILENICKNAME length] > 0) {
									sayTitle = buddyInfo.PROFILENICKNAME;
								} else {
									sayTitle = @"이름 없음";
								}
								
								UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
								assert(titleView != nil);
								UIFont *titleFont = [UIFont systemFontOfSize:20];

								// sochae 2010.09.11 - UI Position
								//CGRect rect = [MyDeviceClass deviceOrientation];
								CGRect rect = self.view.frame;
								// ~sochae
								
								CGSize titleStringSize = [sayTitle sizeWithFont:titleFont constrainedToSize:(CGSizeMake(rect.size.width-120.0, MAXFLOAT))];
								assert(titleFont != nil);
								UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, 20.0f)];
								assert(titleLabel != nil);
								[titleLabel setFont:titleFont];
								titleLabel.textAlignment = UITextAlignmentCenter;
								[titleLabel setTextColor:ColorFromRGB(0x053844)];
								[titleLabel setBackgroundColor:[UIColor clearColor]];
								[titleLabel setText:sayTitle];
//								titleLabel.shadowColor = [UIColor whiteColor];
								[titleView addSubview:titleLabel];	
								[titleLabel release];
								sayViewController.navigationItem.titleView = titleView;
								[titleView release];
								sayViewController.navigationItem.titleView.frame = CGRectMake((self.tableView.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, 20.0f);				
								
								self.tabBarController.selectedIndex = 1;
								sayViewController.hidesBottomBarWhenPushed = YES;
								[naviController pushViewController:sayViewController animated:YES]; 
								[sayViewController release];
							}
						}
					} else {
						// 선택한 user 없음 
					}
					
				} else {
					// 대화할 권한이 없음
					// 혹시 이런 경우는 버그. 선택하지 못하도록 disable 처리 해야힘.
					UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"대화 신청 불가" message:@"친구로 등록되어 있지 않습니다. 대화를 하실수 없습니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
					[alertView show];
					[alertView release];
				}
			}
		}	
	}
}



-(void)buddySMSButtonCheck {
	//NSLog(@"fdsafdsafasfsd");
	
	/*
		NSIndexPath* oldIndexPath = [self.selectedPerson objectAtIndex:0];
		ApplicationCell* cell = (ApplicationCell*)[self.currentTableView cellForRowAtIndexPath:oldIndexPath];
		NSInteger buttonSection = [oldIndexPath section];
		NSInteger buttonRow =[ oldIndexPath row];
	*/	
	/*
		GroupInfo* keygroup = [self.allGroups objectAtIndex:buttonSection];
		
		if(cell.bButtonView){
			NSDictionary* viewTypeDic = nil;
			if(self.currentTableView == self.searchDisplayController.searchResultsTableView){
				viewTypeDic = self.filteredHistory;
			}else if(self.currentTableView == self.tableView){
				if(!self.viewList){
					viewTypeDic = self.peopleInGroup;
				}else {
					viewTypeDic = self.peopleInBuddy;
				}
			}
			
			if (viewTypeDic && [viewTypeDic count] > 0) {
				//			NSString* key = [[viewTypeDic allKeys] objectAtIndex:buttonSection];
				NSArray* userArr = [viewTypeDic objectForKey:keygroup.GROUPTITLE];
				if (userArr && [userArr count] > 0) {
					UserInfo *dataItem = [userArr objectAtIndex:buttonRow];
					if (dataItem) {
						//			NSLog(@"%@",dataItem.FORMATTED);
						//						NSString* phoneNumber = nil;
						NSMutableArray* phoneArray = [NSMutableArray array];
						
						if(dataItem.MOBILEPHONENUMBER != nil && [dataItem.MOBILEPHONENUMBER length]>0)
							[phoneArray addObject:[NSString stringWithFormat:@"%@",dataItem.MOBILEPHONENUMBER]];
						if(dataItem.IPHONENUMBER != nil && [dataItem.IPHONENUMBER length]>0)
							[phoneArray addObject:[NSString stringWithFormat:@"%@",dataItem.IPHONENUMBER]];
						if(dataItem.HOMEPHONENUMBER != nil && [dataItem.HOMEPHONENUMBER length]>0)
							[phoneArray addObject:[NSString stringWithFormat:@"%@",dataItem.HOMEPHONENUMBER]];
						if(dataItem.ORGPHONENUMBER != nil && [dataItem.ORGPHONENUMBER length]>0)
							[phoneArray addObject:[NSString stringWithFormat:@"%@",dataItem.ORGPHONENUMBER]];
						
						if([phoneArray count] <= 0){
							
							NSLog(@"phone not found");
							return;
							
						}
					}
				}
			}
		}
	
	*/					
}


-(void)buddySMSButtonClicked:(id)sender {
	//SMS 버튼
//	NSLog(@"buddySMSButtonClicked");
	NSLog(@"buddySMSButtonClicked %d", [self.selectedPerson count]);

	
	
	
	
	
	if([self.selectedPerson count] > 0){
		NSIndexPath* oldIndexPath = [self.selectedPerson objectAtIndex:0];
		NSLog(@"oldindexpath = %@", oldIndexPath);
		
		NSLog(@"uitableView = %@", self.currentTableView);
		ApplicationCell* cell = (ApplicationCell*)[self.currentTableView cellForRowAtIndexPath:oldIndexPath];
		NSInteger buttonSection = [oldIndexPath section];
		NSInteger buttonRow =[ oldIndexPath row];
		
		GroupInfo* keygroup = [self.allGroups objectAtIndex:buttonSection];
		
		NSLog(@"cell = %@", cell);
		if(cell.bButtonView){
			NSDictionary* viewTypeDic = nil;
			if(self.currentTableView == self.searchDisplayController.searchResultsTableView){
				viewTypeDic = self.filteredHistory;
			}else if(self.currentTableView == self.tableView){
				if(!self.viewList){
					viewTypeDic = self.peopleInGroup;
				}else {
					viewTypeDic = self.peopleInBuddy;
				}
			}

			NSLog(@"viewTypeDic = %d, cnt = %d", viewTypeDic, [viewTypeDic count]);
			if (viewTypeDic && [viewTypeDic count] > 0) {
	//			NSString* key = [[viewTypeDic allKeys] objectAtIndex:buttonSection];
				NSArray* userArr = [viewTypeDic objectForKey:keygroup.GROUPTITLE];
				if (userArr && [userArr count] > 0) {
					UserInfo *dataItem = [userArr objectAtIndex:buttonRow];
					if (dataItem) {
						//			NSLog(@"%@",dataItem.FORMATTED);
//						NSString* phoneNumber = nil;
						NSMutableArray* phoneArray = [NSMutableArray array];
						
						if(dataItem.MOBILEPHONENUMBER != nil && [dataItem.MOBILEPHONENUMBER length]>0)
							[phoneArray addObject:[NSString stringWithFormat:@"%@",dataItem.MOBILEPHONENUMBER]];
						if(dataItem.IPHONENUMBER != nil && [dataItem.IPHONENUMBER length]>0)
							[phoneArray addObject:[NSString stringWithFormat:@"%@",dataItem.IPHONENUMBER]];
						if(dataItem.HOMEPHONENUMBER != nil && [dataItem.HOMEPHONENUMBER length]>0)
							[phoneArray addObject:[NSString stringWithFormat:@"%@",dataItem.HOMEPHONENUMBER]];
						if(dataItem.ORGPHONENUMBER != nil && [dataItem.ORGPHONENUMBER length]>0)
							[phoneArray addObject:[NSString stringWithFormat:@"%@",dataItem.ORGPHONENUMBER]];
						
						
						NSLog(@"phoneArray count = %d",[phoneArray count]);
						
						if([phoneArray count] <= 0){
							UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"sms 보내기" 
																			   message:@"sms를 보낼 전화 번호가 없습니다." 
																			  delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
							[alertView show];
							[alertView release];
							return;
							
						}
						UIActionSheet* selectNumber = nil;
						
						if ([phoneArray count] == 4) {
							selectNumber = [[UIActionSheet alloc] initWithTitle:@"sms 보내기" 
																	   delegate:self
															  cancelButtonTitle:@"취소" 
														 destructiveButtonTitle:nil 
															  otherButtonTitles:[phoneArray objectAtIndex:0],
											[phoneArray objectAtIndex:1],
											[phoneArray objectAtIndex:2],
											[phoneArray objectAtIndex:3],nil];	
						} else if ([phoneArray count] == 3) {
							selectNumber = [[UIActionSheet alloc] initWithTitle:@"sms 보내기" 
																	   delegate:self
															  cancelButtonTitle:@"취소" 
														 destructiveButtonTitle:nil 
															  otherButtonTitles:[phoneArray objectAtIndex:0],
											[phoneArray objectAtIndex:1],
											[phoneArray objectAtIndex:2],nil];
						} else if ([phoneArray count] == 2) {
							selectNumber = [[UIActionSheet alloc] initWithTitle:@"sms 보내기" 
																	   delegate:self
															  cancelButtonTitle:@"취소" 
														 destructiveButtonTitle:nil 
															  otherButtonTitles:[phoneArray objectAtIndex:0],
											[phoneArray objectAtIndex:1],nil];
						} else if ([phoneArray count] == 1) {
							selectNumber = [[UIActionSheet alloc] initWithTitle:@"sms 보내기" 
																	   delegate:self
															  cancelButtonTitle:@"취소" 
														 destructiveButtonTitle:nil 
															  otherButtonTitles:[phoneArray objectAtIndex:0],nil];
							
						} else {
							// error
						}
						
						
						selectNumber.actionSheetStyle = UIActionSheetStyleDefault;
						//tabBar 컨트롤러의 하위 뷰일경우, actionsheet의 cancel버튼이 먹질 않는다. 
						//tabbarcontroller뷰의 상단에 보이게 한다.
						[selectNumber showInView:self.tabBarController.view];
						[selectNumber release];
						
						//			if(dataItem.MOBILEPHONENUMBER !=nil && dataItem.IPHONENUMBER != nil){
						//				phoneNumber = [NSString stringWithString:dataItem.IPHONENUMBER];
						//			}else if(dataItem.MOBILEPHONENUMBER != nil && dataItem.IPHONENUMBER == nil){
						//				phoneNumber = [NSString stringWithString:dataItem.MOBILEPHONENUMBER];
						//			}else if(dataItem.MOBILEPHONENUMBER == nil && dataItem.IPHONENUMBER != nil){
						//				phoneNumber = [NSString stringWithString:dataItem.IPHONENUMBER];
						//			}else if(dataItem.MOBILEPHONENUMBER == nil && dataItem.IPHONENUMBER == nil) {
						//				UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"sms 보내기" 
						//																   message:@"아이폰 번호나 핸드폰 번호가 없습니다." 
						//																  delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
						//				[alertView show];
						//				[alertView release];
						//				return;
						//			}
					}
				}
			}
		}
	}
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
	DebugLog(@"messageComposeViewController : sms 결과? ");
	[self dismissModalViewControllerAnimated:YES];
	
	switch (result)
	{
		case MessageComposeResultCancelled:
			DebugLog(@"Result: SMS canceled");
			break;
		case MessageComposeResultSent:
			DebugLog(@"Result: SMS sent !!!");
			[JYUtil alertWithType:ALERT_SMS_SEND delegate:self];
			break;
		case MessageComposeResultFailed:
			DebugLog(@"Result: SMS failed");
			break;
		default:
			DebugLog(@"Result: SMS not sent");
			break;
	}
}

-(void)buddyCallButtonClicked:(id)sender {
	//전화 버튼
//	NSLog(@"buddyCallButtonClicked");
	
	if([self.selectedPerson count] > 0){
		NSIndexPath* oldIndexPath = [self.selectedPerson objectAtIndex:0];
		ApplicationCell* cell = (ApplicationCell*)[self.currentTableView cellForRowAtIndexPath:oldIndexPath];
		NSInteger buttonSection = [oldIndexPath section];
		NSInteger buttonRow =[ oldIndexPath row];
		
		GroupInfo* keygroup = [self.allGroups objectAtIndex:buttonSection];
		
		if(cell.bButtonView){
			NSDictionary* viewTypeDic = nil;
			if(self.currentTableView == self.searchDisplayController.searchResultsTableView){
				viewTypeDic = self.filteredHistory;
			}else if(self.currentTableView == self.tableView){
				if(!self.viewList){
					viewTypeDic = self.peopleInGroup;
				}else {
					viewTypeDic = self.peopleInBuddy;
				}
			}
			
			if (viewTypeDic && [viewTypeDic count] > 0) {
//				NSString* key = [[viewTypeDic allKeys] objectAtIndex:buttonSection];
				NSArray* userArr = [viewTypeDic objectForKey:keygroup.GROUPTITLE];
				
				if (userArr && [userArr count] > 0) {
					UserInfo *dataItem = [userArr objectAtIndex:buttonRow];
//					NSString* phoneNumber = nil;
					if (dataItem) {
						//			NSLog(@"%@",dataItem.FORMATTED);
						
						//			if(dataItem.MOBILEPHONENUMBER !=nil && dataItem.IPHONENUMBER != nil){
						//				phoneNumber = [NSString stringWithString:dataItem.IPHONENUMBER];
						//			}else if(dataItem.MOBILEPHONENUMBER != nil && dataItem.IPHONENUMBER == nil){
						//				phoneNumber = [NSString stringWithString:dataItem.MOBILEPHONENUMBER];
						//			}else if(dataItem.MOBILEPHONENUMBER == nil && dataItem.IPHONENUMBER != nil){
						//				phoneNumber = [NSString stringWithString:dataItem.IPHONENUMBER];
						//			}else if(dataItem.MOBILEPHONENUMBER == nil && dataItem.IPHONENUMBER == nil) {
						//				UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"전화 걸기" 
						//										message:@"핸드폰 번호나 아이폰 번호가 없습니다." 
						//										delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
						//				[alertView show];
						//				[alertView release];
						//				return;
						//			}
						
						NSMutableArray* phoneArray = [NSMutableArray array];
						
						if(dataItem.MOBILEPHONENUMBER != nil && [dataItem.MOBILEPHONENUMBER length]>0)
							[phoneArray addObject:[NSString stringWithFormat:@"%@",dataItem.MOBILEPHONENUMBER]];
						if(dataItem.IPHONENUMBER != nil && [dataItem.IPHONENUMBER length]>0)
							[phoneArray addObject:[NSString stringWithFormat:@"%@",dataItem.IPHONENUMBER]];
						if(dataItem.HOMEPHONENUMBER != nil && [dataItem.HOMEPHONENUMBER length]>0)
							[phoneArray addObject:[NSString stringWithFormat:@"%@",dataItem.HOMEPHONENUMBER]];
						if(dataItem.ORGPHONENUMBER != nil && [dataItem.ORGPHONENUMBER length]>0)
							[phoneArray addObject:[NSString stringWithFormat:@"%@",dataItem.ORGPHONENUMBER]];
						
						
						if([phoneArray count] <= 0){
							UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"전화 걸기" 
																			   message:@"전화 번호가 없습니다." 
																			  delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
							[alertView show];
							[alertView release];
							return;
							
						}
						
						UIActionSheet* selectNumber = nil;
						if ([phoneArray count] == 4) {
							selectNumber = [[UIActionSheet alloc] initWithTitle:@"전화 걸기" 
																	   delegate:self
															  cancelButtonTitle:@"취소" 
														 destructiveButtonTitle:nil 
															  otherButtonTitles:[phoneArray objectAtIndex:0],
											[phoneArray objectAtIndex:1],
											[phoneArray objectAtIndex:2],
											[phoneArray objectAtIndex:3],nil];	
						} else if ([phoneArray count] == 3) {
							selectNumber = [[UIActionSheet alloc] initWithTitle:@"전화 걸기" 
																	   delegate:self
															  cancelButtonTitle:@"취소" 
														 destructiveButtonTitle:nil 
															  otherButtonTitles:[phoneArray objectAtIndex:0],
											[phoneArray objectAtIndex:1],
											[phoneArray objectAtIndex:2],nil];
						} else if ([phoneArray count] == 2) {
							selectNumber = [[UIActionSheet alloc] initWithTitle:@"전화 걸기" 
																	   delegate:self
															  cancelButtonTitle:@"취소" 
														 destructiveButtonTitle:nil 
															  otherButtonTitles:[phoneArray objectAtIndex:0],
											[phoneArray objectAtIndex:1],nil];
						} else if ([phoneArray count] == 1) {
							selectNumber = [[UIActionSheet alloc] initWithTitle:@"전화 걸기" 
																	   delegate:self
															  cancelButtonTitle:@"취소" 
														 destructiveButtonTitle:nil 
															  otherButtonTitles:[phoneArray objectAtIndex:0],nil];
							
						} else {
							// error
						}
						selectNumber.actionSheetStyle = UIActionSheetStyleDefault;
						//tabBar 컨트롤러의 하위 뷰일경우, actionsheet의 cancel버튼이 먹질 않는다. 
						//tabbarcontroller뷰의 상단에 보이게 한다.
						[selectNumber showInView:self.tabBarController.view];
						[selectNumber release];
					}
				}
			}
		}
	}
}

-(void)groupSayButtonClicked:(id)sender {

	if([self appDelegate].connectionType == -1){
		UIAlertView* offlineAlert = [[UIAlertView alloc] initWithTitle:@"오프라인"
															   message:@"현재 네트워크 연결이 불가능한 상태 입니다.\nUsay의 모든 기능을 이용하기 위해서는 네트워크 연결이 필요합니다." 
															  delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
		[offlineAlert show];
		[offlineAlert release];
		return;
	}
	GroupCommunityView* groupCommView = (GroupCommunityView*)sender;
	[groupCommView selfViewEnd];
//	NSLog(@"%@",groupCommView.groupID);
	NSMutableArray* communitiUserList = [NSMutableArray array];   // 선택된 그룹중에 친구인 유저 구하기
//	NSString* sayGroupName = nil;
	
	if(self.currentTableView == self.tableView){
		for(GroupInfo* sayGroup in self.allGroups){
			if([groupCommView.groupID isEqualToString:sayGroup.ID]){
				//NSLog(@"%@",sayGroup.GROUPTITLE);
//				if([[self.peopleInBuddy objectForKey:sayGroup.GROUPTITLE] count] == 0)
//					communitiUserList = nil;
//				else
//					communitiUserList = [self.peopleInBuddy objectForKey:sayGroup.GROUPTITLE];
				for(UserInfo* buddyUser in [self.peopleInGroup objectForKey:sayGroup.GROUPTITLE]){
					if([buddyUser.ISFRIEND isEqualToString:@"S"]){
						if([buddyUser.ISBLOCK isEqualToString:@"N"]){
							[communitiUserList addObject:buddyUser];
						}
						
					}
				}
			}			
		}
		if(communitiUserList == nil && [communitiUserList count] <= 0){
			communitiUserList = nil;
		}
	}else if(self.currentTableView == self.searchDisplayController.searchResultsTableView) {
		for(GroupInfo* sayGroup in self.allGroups){
			if([groupCommView.groupID isEqualToString:sayGroup.ID]){
				//NSLog(@"%@",sayGroup.GROUPTITLE);
//				if([[self.filteredHistory objectForKey:sayGroup.GROUPTITLE] count] == 0){
//					communitiUserList = nil;
//				}else{
//					
//					for(UserInfo* searchBuddy in [self.filteredHistory objectForKey:sayGroup.GROUPTITLE]){
//						if(![searchBuddy.ISFRIEND isEqualToString:@"N"])
//							[communitiUserList addObject:searchBuddy];
//					}
//				}
				
				for(UserInfo* searchBuddy in [self.filteredHistory objectForKey:sayGroup.GROUPTITLE]){
					if([searchBuddy.ISFRIEND isEqualToString:@"S"]){
						if([searchBuddy.ISBLOCK isEqualToString:@"N"]){
							[communitiUserList addObject:searchBuddy];
						}
					}
				}
			}			
		}
		if(communitiUserList == nil && [communitiUserList count] <= 0){
			communitiUserList = nil;
		}
	}	
	
	
	UINavigationController* naviController = [self.tabBarController.viewControllers objectAtIndex:1];
	InviteMsgViewController *inviteMsgViewController = [[InviteMsgViewController alloc] initWithAddressGroupSay:communitiUserList];
	inviteMsgViewController.hidesBottomBarWhenPushed = YES;
	inviteMsgViewController.navigationTitle = @"대화 초대";
	self.tabBarController.selectedIndex = 1;
	[naviController pushViewController:inviteMsgViewController animated:YES]; 
	[inviteMsgViewController release];
	
}

-(void)groupSMSButtonClicked:(id)sender {
	//device 이름 얻어오기
/*  UIDevice *device = [UIDevice currentDevice];
	 NSString* deviceName = [NSString stringWithFormat:@"name:%@, systemname:%@, systemVersion:%@ model:%@",
	 [device name],[device systemName],[device systemVersion],[device model]];
	 NSLog(@"deviceInfo >> %@",deviceName);
*/
	GroupCommunityView* groupCommView = (GroupCommunityView*)sender;
	[groupCommView selfViewEnd];

	if ([[[UIDevice currentDevice] systemVersion] doubleValue] < 4.0) 
	{
/*		UIAlertView* limitAlert = [[UIAlertView alloc] initWithTitle:@"그룹 SMS" 
													message:@"iPhone OS 4.0 이후 부터 사용 가능 합니다." 
															delegate:nil 
												   cancelButtonTitle:@"확인" otherButtonTitles:nil];
		
		[limitAlert show];
		[limitAlert release];
		return;
*/
		[JYUtil alertWithType:ALERT_SMS_ERROR_GRUOP delegate:nil];		
	}
	else 
	{
		NSMutableArray* communitiUserList = [NSMutableArray array];   // 선택된 그룹중에 친구인 유저 구하기
	//	NSString* sayGroupName = nil;
		
		if(self.currentTableView == self.tableView){
			for(GroupInfo* sayGroup in self.allGroups){
				if([groupCommView.groupID isEqualToString:sayGroup.ID]){
	//				NSLog(@"%@",sayGroup.GROUPTITLE);
					if([[self.peopleInGroup objectForKey:sayGroup.GROUPTITLE] count] == 0)
						communitiUserList = nil;
					else{
						for(UserInfo* existPhoneNum in [self.peopleInGroup objectForKey:sayGroup.GROUPTITLE]){
							if(existPhoneNum.IPHONENUMBER && [existPhoneNum.IPHONENUMBER length] > 0) {
								[communitiUserList addObject:existPhoneNum];
								continue;
							}else if(existPhoneNum.MOBILEPHONENUMBER && [existPhoneNum.MOBILEPHONENUMBER length] > 0 ){
								[communitiUserList addObject:existPhoneNum];
								continue;
							}
						}
					}
				}			
			}
		}else if(self.currentTableView == self.searchDisplayController.searchResultsTableView) {
			for(GroupInfo* sayGroup in self.allGroups){
				if([groupCommView.groupID isEqualToString:sayGroup.ID]){
	//				NSLog(@"%@",sayGroup.GROUPTITLE);
					if([[self.filteredHistory objectForKey:sayGroup.GROUPTITLE] count] == 0)
						communitiUserList = nil;
					else{
						for(UserInfo* existPhoneNum in [self.filteredHistory objectForKey:sayGroup.GROUPTITLE]){
							if(existPhoneNum.IPHONENUMBER && [existPhoneNum.IPHONENUMBER length] > 0) {
								[communitiUserList addObject:existPhoneNum];
								continue;
							}else if(existPhoneNum.MOBILEPHONENUMBER && [existPhoneNum.MOBILEPHONENUMBER length] > 0 ){
								[communitiUserList addObject:existPhoneNum];
								continue;
							}
						}
					}
				}	
			}
		}	
		
		if([communitiUserList count] == 0)
			communitiUserList = nil;
		
		
		InviteMsgViewController *inviteMsgViewController = [[InviteMsgViewController alloc] initWithAddressGroupSMS:communitiUserList];
		inviteMsgViewController.hidesBottomBarWhenPushed = YES;
		inviteMsgViewController.navigationTitle = @"그룹 SMS";
		[self.navigationController pushViewController:inviteMsgViewController animated:YES]; 
		[inviteMsgViewController release];
	}
}

#pragma mark -
#pragma mark UIScrollView delegate Method
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {

	if([self.selectedPerson count] > 0){
		NSIndexPath* oldIndexPath = [self.selectedPerson objectAtIndex:0];
		ApplicationCell* cell = (ApplicationCell*)[self.currentTableView cellForRowAtIndexPath:oldIndexPath];
		if(cell.bButtonView){
			[cell selectViewChange:cell.isBuddy];
		}
		[self.selectedPerson removeObjectAtIndex:[self.selectedPerson indexOfObject:oldIndexPath]];
	}
}

-(BOOL)IsHangulChosung:(NSInteger)code
{
	for (int i = 0; i < [self.chosungNumArray count]; i++) {
		int nChosungUniCode = [[self.chosungNumArray objectAtIndex:i] intValue];
		if (nChosungUniCode  == code) {
			return YES;
		}
	}
	return NO;
}

-(NSString *)GetUTF8String:(NSString *)str 
{	
	NSString *returnText = @"";
	NSString *choText = @"";
	NSString *jongText = @"";
	
	for (int i=0;i<[str length];i++) {
		
		NSInteger code = [str characterAtIndex:i];
		
		if (code >= HANGUL_BEGIN_UNICODE && code <= HANGUL_END_UNICODE) {
			
			NSInteger baseUniCode = code - HANGUL_BEGIN_UNICODE;
			NSInteger choIndex = (baseUniCode / 21 / 28) % 19;
			
			if (choIndex == 1) {			
				choText = @"ㄱㄱ"; 
			} else if (choIndex == 4) {		
				choText = @"ㄷㄷ";
			} else if (choIndex == 8) {		
				choText = @"ㅂㅂ";
			} else if (choIndex == 10) {	
				choText = @"ㅅㅅ";
			} else if (choIndex == 13) {	
				choText = @"ㅈㅈ";
			} else {
				choText = [self.chosungArray objectAtIndex:choIndex];
			}
			
			NSInteger jungIndex = (baseUniCode / 28) % 21;
			NSInteger jongIndex = baseUniCode % 28;
			if (jongIndex == 2) {			
				jongText = @"ㄱㄱ"; 
			} else if (jongIndex == 3) {	
				jongText = @"ㄱㅅ";
			} else if (jongIndex == 5) {	
				jongText = @"ㄴㅈ";
			} else if (jongIndex == 6) {	
				jongText = @"ㄴㅎ";
			} else if (jongIndex == 9) {	
				jongText = @"ㄹㄱ";
			} else if (jongIndex == 10) {	
				jongText = @"ㄹㅁ";
			} else if (jongIndex == 11) {	
				jongText = @"ㄹㅂ";
			} else if (jongIndex == 12) {	
				jongText = @"ㄹㅅ";
			} else if (jongIndex == 13) {	
				jongText = @"ㄹㅌ";
			} else if (jongIndex == 14) {	
				jongText = @"ㄹㅍ";
			} else if (jongIndex == 15) {	
				jongText = @"ㄹㅎ";
			} else if (jongIndex == 18) {	
				jongText = @"ㅂㅅ";
			} else if (jongIndex == 20) {	
				jongText = @"ㅅㅅ";
			} else {
				jongText = [self.jongsungArray objectAtIndex:jongIndex];
			}
			returnText = [NSString stringWithFormat:@"%@%@%@%@", returnText, choText, [self.jungsungArray objectAtIndex:jungIndex], jongText];
		} else {
			returnText = [NSString stringWithFormat:@"%@%@", returnText, [[str substringFromIndex:i] substringToIndex:1]];
		}
	}
	
	return returnText;
}

-(NSString *)GetChosungUTF8String:(NSString *)str
{
	NSString *returnText = @"";
	NSString *choText = @"";
	
	for (int i=0;i<[str length];i++) {
		
		NSInteger code = [str characterAtIndex:i];
		
		if (code >= HANGUL_BEGIN_UNICODE && code <= HANGUL_END_UNICODE) {
			NSInteger baseUniCode = code - HANGUL_BEGIN_UNICODE;
			NSInteger choIndex = (baseUniCode / 21 / 28) % 19;
			if (choIndex == 1) {		
				choText = @"ㄱㄱ"; 
			} else if (choIndex == 4) {	
				choText = @"ㄷㄷ";
			} else if (choIndex == 8) {	
				choText = @"ㅂㅂ";
			} else if (choIndex == 10) {
				choText = @"ㅅㅅ";
			} else if (choIndex == 13) {
				choText = @"ㅈㅈ";
			} else {
				choText = [self.chosungArray objectAtIndex:choIndex];
			}
			returnText = [NSString stringWithFormat:@"%@%@", returnText, choText];
		} else if ([self IsHangulChosung:code]) {
			if (code == 12594) {		
				choText = @"ㄱㄱ"; 
			} else if (code == 12600) {	
				choText = @"ㄷㄷ";
			} else if (code == 12611) {	
				choText = @"ㅂㅂ";
			} else if (code == 12614) {	
				choText = @"ㅅㅅ";
			} else if (code == 12617) {	
				choText = @"ㅈㅈ";
			} else {
				for (int i = 0; i < [self.chosungNumArray count]; i++) {
					int nChosungUniCode = [[self.chosungNumArray objectAtIndex:i] intValue];
					if (nChosungUniCode == code) {
						choText = [self.chosungArray objectAtIndex:i];
						break;
					}
				}
			}
			returnText = [NSString stringWithFormat:@"%@%@", returnText, choText];
		} else {
			returnText = [NSString stringWithFormat:@"%@%@", returnText, [[str substringFromIndex:i] substringToIndex:1]];
		}
	}
	
	return returnText;
}

-(NSString *)GetChosungUTF8StringSearchString:(NSString *)str
{
	NSString *returnText = @"";
	NSString *choText = @"";
	
	for (int i=0;i<[str length];i++) {
		
		NSInteger code = [str characterAtIndex:i];
		
		if ([self IsHangulChosung:code]) {
			if (code == 12594) {		
				choText = @"ㄱㄱ"; 
			} else if (code == 12600) {	
				choText = @"ㄷㄷ";
			} else if (code == 12611) {	
				choText = @"ㅂㅂ";
			} else if (code == 12614) {	
				choText = @"ㅅㅅ";
			} else if (code == 12617) {	
				choText = @"ㅈㅈ";
			} else {
				for (int i = 0; i < [self.chosungNumArray count]; i++) {
					int nChosungUniCode = [[self.chosungNumArray objectAtIndex:i] intValue];
					if (nChosungUniCode == code) {
						choText = [self.chosungArray objectAtIndex:i];
						break;
					}
				}
			}
			returnText = [NSString stringWithFormat:@"%@%@", returnText, choText];
		} else {
			returnText = [NSString stringWithFormat:@"%@%@", returnText, [[str substringFromIndex:i] substringToIndex:1]];
		}
	}
	
	return returnText;
}
#pragma mark -
#pragma mark sync database Method
// TODO: syncDatabase 사용 되지 않음
-(void)syncDatabase:(NSArray*)userData withGroupinfo:(NSArray*)groupData saveRevisionPoint:(NSString*)revisionPoint withChangeKind:(NSString*)changed {
	//	[self appDelegate].database	= [[[SQLiteDatabase alloc] initWithCreateSQLite]autorelease];
	
	//오늘 일자를 구해 NSUserDefaults로 app 사용자 값에 저장한다.
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	NSLocale *locale = [NSLocale currentLocale];
	[formatter setLocale:locale];
	[formatter setDateFormat:@"yyyyMMddHHmmss"];
	NSDate *today = [NSDate date];
	NSString *lastSyncDate = [[NSString alloc] initWithFormat:@"%@",[formatter stringFromDate:today]];
		
	if(userData != nil){
		for(UserInfo* userInfo in userData) {
			if(userInfo.RPCREATED || userInfo.RPUPDATED ){
				[userInfo saveData];
				if(changed != nil && [changed length] > 0 && [changed isEqualToString:@"newFriend"] == YES)
					userInfo.CHANGEDATE = lastSyncDate;
				userInfo.CHANGEDATE2 = lastSyncDate;
				
			}else if(userInfo.RPDELETED){
				[userInfo deleteData];
			}
		}
	}
	
	if(groupData != nil){
		for(GroupInfo* groupInfo in groupData){
			if(groupInfo.RPCREATED || groupInfo.RPUPDATED)
				[groupInfo saveData];
			else if(groupInfo.RPDELETED)
				[groupInfo deleteData];
		}
	}
	
	
	//데이터 베이스에 저장후 마지막 동기화 포인트 저장
	if(revisionPoint != nil){
		NSString* revisionPoints = [[NSString alloc] initWithFormat:@"%@",revisionPoint];
		[[NSUserDefaults standardUserDefaults] setObject:revisionPoints forKey:@"RevisionPoints"];
		[revisionPoints release];
	}
	
	if(userData != nil || groupData != nil){
		[[NSUserDefaults standardUserDefaults] setObject:lastSyncDate forKey:@"lastSyncDate"];
	}
	
	[lastSyncDate release];
	[formatter release];
	
	if(userData != nil || groupData != nil)
	{
		[self reloadAddressData];
		[self.tableView reloadData];
		
	}	
}

-(void)reloadAddressData {
	NSLog(@"reload memory");
	[self.allNames removeAllObjects];
	[self.allGroups removeAllObjects];
	
	self.allNames = [NSMutableArray arrayWithArray:[UserInfo findAll]];
	self.allGroups = [NSMutableArray arrayWithArray:[GroupInfo findAll]];
	
	BOOL	bFindUser = FALSE;
	
	NSSortDescriptor *groupNameSort = [[NSSortDescriptor alloc] initWithKey:@"GROUPTITLE" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
	[self.allGroups sortUsingDescriptors:[NSArray arrayWithObject:groupNameSort]];
	[groupNameSort release];
	for(int g=0;g<[self.allGroups count];g++){
		GroupInfo* tempGroup = [self.allGroups objectAtIndex:g];
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
			[self.allGroups removeObject:tempGroup];
			[self.allGroups insertObject:instGroup atIndex:0];
			[instGroup release];
			break;
		}else {
			[instGroup release];
		}
		
	}
	
	//전체 데이터 베이스를 다시 메모리로 로드 한다.
	[self.peopleInGroup removeAllObjects];
	for(GroupInfo* group in self.allGroups){//전체 보기 일 경우
		NSMutableArray* arrayGroup = [NSMutableArray array];
		for(UserInfo* person in allNames){
			if([person.GID isEqualToString:group.ID] && [person.ISBLOCK isEqualToString:@"N"]) {
				[arrayGroup addObject:person];
				bFindUser = TRUE;
			}
		}
		NSSortDescriptor *formattedSort = [[NSSortDescriptor alloc] initWithKey:@"FORMATTED" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
		NSSortDescriptor *nickNameSort = [[NSSortDescriptor alloc] initWithKey:@"PROFILENICKNAME" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
		[arrayGroup sortUsingDescriptors:[NSArray arrayWithObjects:formattedSort,nickNameSort, nil]];
		[nickNameSort release];
		[formattedSort release];
		[self.peopleInGroup setObject:arrayGroup forKey:group.GROUPTITLE];
	}
	
	if(self.viewList){//친구 보기 일 경우 친구 보기 메모리를 재설정한.
		[self.peopleInBuddy removeAllObjects];
		for(int i = 0; i < [[self.peopleInGroup allKeys] count];i++){
			for(NSString* groupKey in [peopleInGroup allKeys]){
				NSMutableArray* groupUser = [NSMutableArray array];
				for(UserInfo* buddyUser in [peopleInGroup objectForKey:groupKey]){
					if([buddyUser.ISFRIEND isEqualToString:@"S"]){
						[groupUser addObject:buddyUser];
						bFindUser = TRUE;
					}
				}
				NSSortDescriptor *formattedSort = [[NSSortDescriptor alloc] initWithKey:@"FORMATTED" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
				NSSortDescriptor *nickNameSort = [[NSSortDescriptor alloc] initWithKey:@"PROFILENICKNAME" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
				[groupUser sortUsingDescriptors:[NSArray arrayWithObjects:formattedSort,nickNameSort, nil]];
				[self.peopleInBuddy setObject:groupUser forKey:groupKey];
				[nickNameSort release];
				[formattedSort release];
			}
		}
	}
	
	if(self.currentTableView == self.searchDisplayController.searchResultsTableView){// 검색 화면일경우
		NSMutableDictionary* changeFiltered = [NSMutableDictionary dictionary];
		[changeFiltered setDictionary:self.filteredHistory];
		[self.filteredHistory removeAllObjects];
		
		for(NSString* searchkey in [self.peopleInGroup allKeys]){
			NSMutableArray* changeUserArray = [NSMutableArray array];
			
			for(UserInfo* searchuser in [changeFiltered valueForKey:searchkey]){
				for(UserInfo* userNormal in [self.peopleInGroup objectForKey:searchkey]){
					if([userNormal.ID isEqualToString:searchuser.ID]){
						[changeUserArray addObject:userNormal];
						bFindUser = TRUE;
					}
				}
			}
			if([changeUserArray count] > 0){
				NSSortDescriptor *formattedSort = [[NSSortDescriptor alloc] initWithKey:@"FORMATTED" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
				NSSortDescriptor *nickNameSort = [[NSSortDescriptor alloc] initWithKey:@"PROFILENICKNAME" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
				[changeUserArray sortUsingDescriptors:[NSArray arrayWithObjects:formattedSort,nickNameSort, nil]];
				[nickNameSort release];
				[formattedSort release];
				[self.filteredHistory setObject:changeUserArray forKey:searchkey];

			}
		}
	}
	
	
	//여기로 들어올 이유가 없어야 한다. 
	if (bFindUser && (self.currentTableView == self.searchDisplayController.searchResultsTableView || 
					  self.currentTableView == self.tableView)) {
		NSLog(@"리로드 하나ㅑ....");
	//임시	[self.currentTableView reloadData];
		/*
		USayAppAppDelegate *parentView = (USayAppAppDelegate*) [[UIApplication sharedApplication] delegate];
		UINavigationController *tmp = [parentView.rootController.viewControllers objectAtIndex:1];
		AddressViewController *tmpAdd = (AddressViewController*)[tmp.viewControllers objectAtIndex:1];
		[tmpAdd.currentTableView reloadData];
	*/
	}
	
}
#pragma mark -
#pragma mark user status Method
#pragma mark -
#pragma mark edit Address protocol Method
-(void)deleteUserListWithArray:(NSArray*)value{
//	NSString *key = nil;
	NSMutableArray* sections = nil;
	
	for(int section = 0; section < [[peopleInGroup allKeys] count] ; section++){
		NSString *mainkey = [[self.peopleInGroup allKeys] objectAtIndex:section];
		NSMutableArray* mainsections = [self.peopleInGroup objectForKey:mainkey];
		for(UserInfo* deleteUser in value){
			for(int mn = [mainsections count]-1;mn>=0;mn--){
				UserInfo* removeUser = [mainsections objectAtIndex:mn];
				if([deleteUser.ID isEqualToString:removeUser.ID]){
					[mainsections removeObject:removeUser];
				}
			}
		}
		
		if(self.currentTableView == self.searchDisplayController.searchResultsTableView){//검색 일경우
//			key = [[self.filteredHistory allKeys] objectAtIndex:section];
			sections = [self.filteredHistory objectForKey:mainkey];
		}else if(self.currentTableView == self.tableView){ //일반일경우
			if(self.viewList){//친구만.
//				key = [[self.peopleInBuddy allKeys] objectAtIndex:section];
				sections = [self.peopleInBuddy objectForKey:mainkey];
			}
		}
		
		if(sections != nil && [sections count] > 0){
			for(UserInfo* deleteUser in value){
				for(int rm = [sections count]-1; rm >=0 ;rm--){
					UserInfo* removeUser = [sections objectAtIndex:rm];
					if([deleteUser.ID isEqualToString:removeUser.ID]){
						[sections removeObject:removeUser];
					}
				}
			}
		}
	}
}

#pragma mark -
#pragma mark Addres Detail protocol Method
-(void)updateProfileInfo:(UserInfo*)profileValue withBeforeGroupID:(NSString*)beforeGID{
	
	NSLog(@"업데이트 프로파일 인포");
	
	
//	NSMutableArray *otherSections = nil;
//	NSMutableArray* sections = nil;
	
	for(UserInfo* beforeUser in self.allNames){
		if([profileValue.ID isEqualToString:beforeUser.ID]){
			NSAutoreleasePool* varpool = [[NSAutoreleasePool alloc] init];
			unsigned int numIvars = 0;
			Ivar* ivars = class_copyIvarList([profileValue class], &numIvars);
			for(int i = 0; i < numIvars; i++) {
				Ivar thisIvar = ivars[i];
				NSString * classkey = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
				if([profileValue valueForKey:classkey])
					[beforeUser setValue:[profileValue valueForKey:classkey] forKey:classkey];
			}
			if(numIvars > 0)free(ivars);
			[varpool release];
			
		}
	}
	[self.peopleInGroup removeAllObjects];
	for(GroupInfo* group in self.allGroups){//전체 보기 일 경우
		NSMutableArray* arrayGroup = [NSMutableArray array];
		for(UserInfo* person in allNames){
			if([person.GID isEqualToString:group.ID] && [person.ISBLOCK isEqualToString:@"N"]) {
				[arrayGroup addObject:person];
			}
		}
		NSSortDescriptor *formattedSort = [[NSSortDescriptor alloc] initWithKey:@"FORMATTED" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
		NSSortDescriptor *nickNameSort = [[NSSortDescriptor alloc] initWithKey:@"PROFILENICKNAME" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
		[arrayGroup sortUsingDescriptors:[NSArray arrayWithObjects:formattedSort,nickNameSort, nil]];
		[nickNameSort release];
		[formattedSort release];
		[self.peopleInGroup setObject:arrayGroup forKey:group.GROUPTITLE];
	}
	
	if(self.viewList){//친구 보기 일 경우 친구 보기 메모리를 재설정한.
		[self.peopleInBuddy removeAllObjects];
		for(int i = 0; i < [[self.peopleInGroup allKeys] count];i++){
			for(NSString* groupKey in [peopleInGroup allKeys]){
				NSMutableArray* groupUser = [NSMutableArray array];
				for(UserInfo* buddyUser in [peopleInGroup objectForKey:groupKey]){
					if([buddyUser.ISFRIEND isEqualToString:@"S"]){
						[groupUser addObject:buddyUser];
					}
				}
				NSSortDescriptor *formattedSort = [[NSSortDescriptor alloc] initWithKey:@"FORMATTED" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
				NSSortDescriptor *nickNameSort = [[NSSortDescriptor alloc] initWithKey:@"PROFILENICKNAME" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
				[groupUser sortUsingDescriptors:[NSArray arrayWithObjects:formattedSort,nickNameSort, nil]];
				[self.peopleInBuddy setObject:groupUser forKey:groupKey];
				[nickNameSort release];
				[formattedSort release];
			}
		}
	}
	
	
	if(self.currentTableView == self.searchDisplayController.searchResultsTableView){// 검색 화면일경우
		NSMutableDictionary* changeFiltered = [NSMutableDictionary dictionary];
		[changeFiltered setDictionary:self.filteredHistory];
		[self.filteredHistory removeAllObjects];
		
		for(NSString* searchkey in [self.peopleInGroup allKeys]){
			NSMutableArray* changeUserArray = [NSMutableArray array];
			for(UserInfo* searchuser in [changeFiltered valueForKey:searchkey]){
				for(UserInfo* userNormal in [self.peopleInGroup objectForKey:searchkey]){
					if([userNormal.ID isEqualToString:searchuser.ID]){
						[changeUserArray addObject:userNormal];
					}
				}
			}
			if([changeUserArray count] > 0){
				NSSortDescriptor *formattedSort = [[NSSortDescriptor alloc] initWithKey:@"FORMATTED" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
				NSSortDescriptor *nickNameSort = [[NSSortDescriptor alloc] initWithKey:@"PROFILENICKNAME" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
				[changeUserArray sortUsingDescriptors:[NSArray arrayWithObjects:formattedSort,nickNameSort, nil]];
				[nickNameSort release];
				[formattedSort release];
				[self.filteredHistory setObject:changeUserArray forKey:searchkey];
				
			}
		}
	}
}

-(void)blockBuddychange:(UserInfo*)profileValue{
//	NSString *key = nil;
	NSMutableArray* sections = nil;
	
	for(int section = 0; section < [[peopleInGroup allKeys] count] ; section++){
		
		NSString *mainKey = [[self.peopleInGroup allKeys] objectAtIndex:section];
		NSMutableArray* mainSections = [self.peopleInGroup objectForKey:mainKey];
		int count = 0;
		for(int ix = 0;ix < [mainSections count];ix++){
			UserInfo* removeAtUser = [mainSections objectAtIndex:ix];
			if([profileValue.ID isEqualToString:removeAtUser.ID]){
				[mainSections removeObjectAtIndex:count];
			}
			count++;
		}
		
		if(self.currentTableView == self.searchDisplayController.searchResultsTableView){//검색 일경우
//			key = [[self.filteredHistory allKeys] objectAtIndex:section];
			sections = [self.filteredHistory objectForKey:mainKey];
		}else if(self.currentTableView == self.tableView){ //일반일경우
			if(self.viewList){//친구만.
//				key = [[self.peopleInBuddy allKeys] objectAtIndex:section];
				sections = [self.peopleInBuddy objectForKey:mainKey];
			}
		}
		
		if(sections != nil && [sections count] > 0){
			int cnt = 0;
			for(int idx = 0;idx < [sections count];idx++){
				UserInfo* removeUser = [sections objectAtIndex:idx];
				if([profileValue.ID isEqualToString:removeUser.ID]){
					[sections removeObjectAtIndex:cnt];
				}
				cnt++;
			}
		}
		
	}
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	NSLocale *locale = [NSLocale currentLocale];
	[formatter setLocale:locale];
	[formatter setDateFormat:@"yyyyMMddHHmmss"];
	NSDate *today = [NSDate date];
	NSString *lastSyncDate = [[NSString alloc] initWithFormat:@"%@",[formatter stringFromDate:today]];
	
//	NSString* sql = [NSString stringWithFormat:@"SELECT * FROM _TUserInfo WHERE SUBSTR(CHANGEDATE,0,8) = ? AND ISBLOCK='N' AND ISFRIEND='S'"];
//	NSArray* changePerson = [UserInfo findWithSqlWithParameters:sql, [lastSyncDate substringToIndex:8],nil];
	/*
	NSString* sql = [NSString stringWithFormat:@"select * from _TUserInfo"];
	NSArray* result = [UserInfo findWithSqlWithParameters:sql];
	
	NSLog(@"==========RESULT = %@============", result);
	*/
	
//	NSString *oldDate =[[NSUserDefaults standardUserDefaults] objectForKey:@"myDate"];
	//	NSLog(@"오늘 일자 %@",[lastSyncDate substringToIndex:8]);
	int changecnt = 0;
	for(int i = 0;i< [[peopleInGroup allKeys] count] ;i++){
		NSString* groupedkey = [[peopleInGroup allKeys] objectAtIndex:i];
		NSArray* groupedarray = [peopleInGroup objectForKey:groupedkey];
		for(UserInfo* changeuser in groupedarray){
			if([[changeuser.CHANGEDATE2 substringToIndex:8] isEqualToString:[lastSyncDate substringToIndex:8]]){

			//	if([oldDate compare:changeuser.CHANGEDATE] < 0)
				changecnt++;
		}
	}
	
//	NSInteger nCount = [changePerson count];
	NSInteger nCount = changecnt;
	NSLog(@"번디 블록 체인지 changeCnt = %i", nCount);
	
		if (nCount == 0) {
			UITabBarItem *tbi = [[self appDelegate].rootController.tabBar.items objectAtIndex:1];
			if (tbi) {
				tbi.badgeValue = nil;
			}
		} else if (nCount > 0) {
			UITabBarItem *tbi = [[self appDelegate].rootController.tabBar.items objectAtIndex:1];
			if (tbi) {
				//	NSInteger newValue = [tbi.badgeValue intValue]-1;
				tbi.badgeValue = [NSString stringWithFormat:@"%i", nCount];
				/*
				if(newValue <= 0)
					tbi.badgeValue = nil;
				else {
				tbi.badgeValue = [NSString stringWithFormat:@"%i", newValue];	
					[[self appDelegate] playSystemSoundIDSound];
					[[self appDelegate] playSystemSoundIDVibrate];
					
				}
				 */

			}
		} else {
			// skip
		}
	

	

	}
	
	//	[self reloadAddressData];
	[lastSyncDate release];
	[formatter release];
}

-(void)addUserInfoWithUserInfo:(UserInfo*)value withImage:(BOOL)exist{
	
	NSMutableArray* sections = nil;
	
	NSSortDescriptor *groupNameSort = [[NSSortDescriptor alloc] initWithKey:@"GROUPTITLE" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
	[self.allGroups sortUsingDescriptors:[NSArray arrayWithObject:groupNameSort]];
	[groupNameSort release];
	for(int g=0;g<[self.allGroups count];g++){
		GroupInfo* tempGroup = [self.allGroups objectAtIndex:g];
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
			[self.allGroups removeObject:tempGroup];
			[self.allGroups insertObject:instGroup atIndex:0];
			[instGroup release];
			break;
		}else {
			[instGroup release];
		}
		
	}
	
//	if(!exist){
	for(GroupInfo* addUserGroup in self.allGroups){
		if([value.GID isEqualToString:addUserGroup.ID]){
				
			NSMutableArray* mainSections = [self.peopleInGroup objectForKey:addUserGroup.GROUPTITLE];
			[mainSections addObject:value];
			NSSortDescriptor *formattedSort = [[NSSortDescriptor alloc] initWithKey:@"FORMATTED" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
			NSSortDescriptor *nickNameSort = [[NSSortDescriptor alloc] initWithKey:@"PROFILENICKNAME" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
			[mainSections sortUsingDescriptors:[NSArray arrayWithObjects:formattedSort,nickNameSort, nil]];
			[nickNameSort release];
			[formattedSort release];	
			
			if(self.viewList){//친구만.
				sections = [self.peopleInBuddy objectForKey:addUserGroup.GROUPTITLE];
				if([value.ISFRIEND isEqualToString:@"S"]){
					[sections addObject:value];
					NSSortDescriptor *formattedSort = [[NSSortDescriptor alloc] initWithKey:@"FORMATTED" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
					NSSortDescriptor *nickNameSort = [[NSSortDescriptor alloc] initWithKey:@"PROFILENICKNAME" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
					[sections sortUsingDescriptors:[NSArray arrayWithObjects:formattedSort,nickNameSort, nil]];
					[nickNameSort release];
					[formattedSort release];
				}
			}
			
//			if(self.currentTableView == self.searchDisplayController.searchResultsTableView){//검색 일경우
//				sections = [self.filteredHistory objectForKey:addUserGroup.GROUPTITLE];
//				[sections addObject:value];
//				NSSortDescriptor *formattedSort = [[NSSortDescriptor alloc] initWithKey:@"FORMATTED" ascending:YES];
//				NSSortDescriptor *nickNameSort = [[NSSortDescriptor alloc] initWithKey:@"PROFILENICKNAME" ascending:YES];
//				[sections sortUsingDescriptors:[NSArray arrayWithObjects:formattedSort,nickNameSort, nil]];
//				[nickNameSort release];
//				[formattedSort release];
//			}else if(self.currentTableView == self.tableView){ //일반일경우
//			}
		}
	}
//	[self.currentTableView reloadData];		
}

-(void)updatePersonInfo:(UserInfo*)PersonValue{
	// 해당 유저의 정보를 수정해준다.
	
	NSLog(@"update 유저");
	
	NSString *key = nil;
	NSMutableArray* sections = nil;
	
	NSArray* groupArray = [GroupInfo findAll];
	NSString* groupTitle = nil;
	
	for(GroupInfo* group in groupArray){
		if([PersonValue.GID isEqualToString:group.ID]){
			groupTitle = [NSString stringWithFormat:@"%@",group.GROUPTITLE];
		}
	}
	
	BOOL isThisGroup = NO;
	if(groupTitle != nil && [groupTitle length] > 0){//기본 메모리 정보 수정
		NSMutableArray* mainsections = [self.peopleInGroup objectForKey:groupTitle];
		for(int i = 0;i<[mainsections count];i++){
			UserInfo* updateUser = [mainsections objectAtIndex:i];
			if([PersonValue.ID isEqualToString:updateUser.ID]){
				[mainsections replaceObjectAtIndex:i withObject:PersonValue];
				isThisGroup = YES;
			}
		}
		if(isThisGroup == NO){
			[mainsections addObject:PersonValue];
			NSSortDescriptor *formattedSort = [[NSSortDescriptor alloc] initWithKey:@"FORMATTED" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
			NSSortDescriptor *nickNameSort = [[NSSortDescriptor alloc] initWithKey:@"PROFILENICKNAME" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
			[mainsections sortUsingDescriptors:[NSArray arrayWithObjects:formattedSort,nickNameSort, nil]];
			[nickNameSort release];
			[formattedSort release];
		}
	}
	
	for(int section = 0; section < [[peopleInGroup allKeys] count] ; section++){ //기본 메모리 정보 수정
		NSString *mainkey = [[self.peopleInGroup allKeys] objectAtIndex:section];
		NSMutableArray* mainsections = [self.peopleInGroup objectForKey:mainkey];
		for(int i = 0;i<[mainsections count];i++){
			UserInfo* updateUser = [mainsections objectAtIndex:i];
			if([PersonValue.ID isEqualToString:updateUser.ID]){
				if(![groupTitle isEqualToString:mainkey]){
					[mainsections removeObject:updateUser];
				}
			}
			
		}
	}
	
	
	if(self.currentTableView == self.searchDisplayController.searchResultsTableView){//검색 일경우
		sections = [self.filteredHistory objectForKey:groupTitle];
	}else if(self.currentTableView == self.tableView){ //일반일경우
		if(self.viewList){//친구만.
			sections = [self.peopleInBuddy objectForKey:groupTitle];
		}
	}
	
	if(sections != nil && [sections count] > 0){
		for(int i = 0;i<[sections count];i++){
			UserInfo* updateUser = [sections objectAtIndex:i];
			if([PersonValue.ID isEqualToString:updateUser.ID]){
				[sections replaceObjectAtIndex:i withObject:PersonValue];
				isThisGroup = YES;
				break;
			}
		}
		if(isThisGroup == NO){
			[sections addObject:PersonValue];
			NSSortDescriptor *formattedSort = [[NSSortDescriptor alloc] initWithKey:@"FORMATTED" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
			NSSortDescriptor *nickNameSort = [[NSSortDescriptor alloc] initWithKey:@"PROFILENICKNAME" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
			[sections sortUsingDescriptors:[NSArray arrayWithObjects:formattedSort,nickNameSort, nil]];
			[nickNameSort release];
			[formattedSort release];
		}
	}

	
	for(int section = 0;section < [groupArray count];section++){
		if(self.currentTableView == self.searchDisplayController.searchResultsTableView){//검색 일경우
			
			//20101012 죽는거 예외처리
			if([self.filteredHistory count] <=0)
			{
				NSLog(@"프로필 도중 예외 상황 발생함");
				break;
			}
			
			key = [[self.filteredHistory allKeys] objectAtIndex:section];
			sections = [self.filteredHistory objectForKey:key];
		}else if(self.currentTableView == self.tableView){ //일반일경우
			if(self.viewList){//친구만.
				
				if([[self.peopleInBuddy allKeys] count] >0 )
				{
				
				key = [[self.peopleInBuddy allKeys] objectAtIndex:section];
				sections = [self.peopleInBuddy objectForKey:key];
				}
				else {
					NSLog(@"카운트가 없다..");
					return;
					
				}

			}
		}
		
		if(sections != nil && [sections count] > 0){
			for(int i = 0;i<[sections count];i++){
				UserInfo* updateUser = [sections objectAtIndex:i];
				if([PersonValue.ID isEqualToString:updateUser.ID]){
					if(![groupTitle isEqualToString:key])
						[sections removeObject:updateUser];
					break;
				}
			}
		}
	}
	
	
	NSLog(@"perInfo  = %@", PersonValue.THUMBNAILURL);
	
	
	
	if(self.currentTableView)
	{
		if(self.currentTableView ==  self.tableView)
			NSLog(@"메모리 리로드... 한다...");
	//		[self reloadAddressData];
	//	[self.currentTableView reloadData];
		
	}
	
}

-(void)deletePersonInfo:(UserInfo*)PersonValue{
//	NSString *key = nil;
	NSMutableArray* sections = nil;
	
	for(int section = 0; section < [[peopleInGroup allKeys] count] ; section++){ //기본 메모리 정보 수정
		NSString *mainkey = [[self.peopleInGroup allKeys] objectAtIndex:section];
		NSMutableArray* mainsections = [self.peopleInGroup objectForKey:mainkey];
		for(int i = 0;i<[mainsections count];i++){
			UserInfo* updateUser = [mainsections objectAtIndex:i];
			if([PersonValue.ID isEqualToString:updateUser.ID]){
				[mainsections removeObject:updateUser];
				break;
			}
		}
		
		
		if(self.currentTableView == self.searchDisplayController.searchResultsTableView){//검색 일경우
//			key = [[self.filteredHistory allKeys] objectAtIndex:section];
			sections = [self.filteredHistory objectForKey:mainkey];
		}else if(self.currentTableView == self.tableView){ //일반일경우
			if(self.viewList){//친구만.
//				key = [[self.peopleInBuddy allKeys] objectAtIndex:section];
				sections = [self.peopleInBuddy objectForKey:mainkey];
			}
		}
		
		if(sections != nil && [sections count] > 0){
			for(int i = 0;i<[sections count];i++){
				UserInfo* updateUser = [sections objectAtIndex:i];
				if([PersonValue.ID isEqualToString:updateUser.ID]){
					[sections removeObject:updateUser];
					break;
				}
			}
		}
	}
	[self.currentTableView reloadData];
	/*
	USayAppAppDelegate *parentView = (USayAppAppDelegate*) [[UIApplication sharedApplication] delegate];
	UINavigationController *tmp = [parentView.rootController.viewControllers objectAtIndex:1];
	AddressViewController *tmpAdd = (AddressViewController*)[tmp.viewControllers objectAtIndex:1];
	[tmpAdd.currentTableView reloadData];
	 */
}

-(void)updateGroupWithGroupInfo:(GroupInfo*)value {

	BOOL isFind = NO;
	NSMutableDictionary* copyPeopleInGroup = [[NSMutableDictionary alloc] initWithCapacity:0];
	for(GroupInfo* currentGroup in self.allGroups) {
		if([value.ID isEqualToString:currentGroup.ID]){
			NSArray* changeArray = [self.peopleInGroup objectForKey:currentGroup.GROUPTITLE];
			[copyPeopleInGroup setObject:changeArray forKey:value.GROUPTITLE];
			currentGroup.GROUPTITLE = value.GROUPTITLE;
			isFind = YES;
		}
	}

	if(isFind == NO)
		[self.allGroups addObject:value];
	
	NSSortDescriptor *groupNameSort = [[NSSortDescriptor alloc] initWithKey:@"GROUPTITLE" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
	[self.allGroups sortUsingDescriptors:[NSArray arrayWithObject:groupNameSort]];
	[groupNameSort release];
	for(int g=0;g<[self.allGroups count];g++){
		GroupInfo* tempGroup = [self.allGroups objectAtIndex:g];
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
			[self.allGroups removeObject:tempGroup];
			[self.allGroups insertObject:instGroup atIndex:0];
			[instGroup release];
			break;
		}else {
			[instGroup release];
		}

	}
	
	for(int i = 0;i < [self.allGroups count]; i++){
		GroupInfo* group = [self.allGroups objectAtIndex:i];
		NSMutableArray* arrayGroup = [NSMutableArray array];
		for(int j = 0 ; j < [self.allNames count];j++){
			UserInfo* person = [self.allNames objectAtIndex:j];
			//trimleft 처리 필요			
			//			NSMutableString* replace = [NSMutableString stringWithFormat:@"%@",person.STATUS];
			//			person.STATUS = [replace stringByReplacingOccurrencesOfString:@" " withString:@""];
			if([person.GID isEqualToString:group.ID] && [person.ISBLOCK isEqualToString:@"N"]) {
				[arrayGroup addObject:person];
			}
		}
		NSSortDescriptor *formattedSort = [[NSSortDescriptor alloc] initWithKey:@"FORMATTED" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
		NSSortDescriptor *nickNameSort = [[NSSortDescriptor alloc] initWithKey:@"PROFILENICKNAME" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
		[arrayGroup sortUsingDescriptors:[NSArray arrayWithObjects:formattedSort,nickNameSort, nil]];
		[nickNameSort release];
		[formattedSort release];
		
		[copyPeopleInGroup setObject:arrayGroup forKey:group.GROUPTITLE];
	}
	
	[self.peopleInGroup removeAllObjects];
	[self.peopleInGroup addEntriesFromDictionary:copyPeopleInGroup];
	[copyPeopleInGroup release];

	if(self.viewList){//친구 보기 일 경우 친구 보기 메모리를 재설정한다.
		[self.peopleInBuddy removeAllObjects];
		for(NSString* groupKey in [peopleInGroup allKeys]){
			NSMutableArray* groupUser = [NSMutableArray array];
			for(UserInfo* buddyUser in [peopleInGroup objectForKey:groupKey]){
				if([buddyUser.ISFRIEND isEqualToString:@"S"]){
					[groupUser addObject:buddyUser];
				}
			}
			NSSortDescriptor *formattedSort = [[NSSortDescriptor alloc] initWithKey:@"FORMATTED" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
			NSSortDescriptor *nickNameSort = [[NSSortDescriptor alloc] initWithKey:@"PROFILENICKNAME" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
			[groupUser sortUsingDescriptors:[NSArray arrayWithObjects:formattedSort,nickNameSort, nil]];
			[nickNameSort release];
			[formattedSort release];
			[self.peopleInBuddy setObject:groupUser forKey:groupKey];
		}
	}

//	[self.currentTableView reloadData];
	
}

-(void)editCompleteAddressInfo { // 주소록 편집 종료시. 주소 삭제, 그룹이동, 그룹만
	
	NSLog(@"edit Complete");
	[self.allNames removeAllObjects];
	[self.allGroups removeAllObjects];
	
	self.allNames = [NSMutableArray arrayWithArray:[UserInfo findAll]];
	self.allGroups = [NSMutableArray arrayWithArray:[GroupInfo findAll]];
	
	NSSortDescriptor *groupNameSort = [[NSSortDescriptor alloc] initWithKey:@"GROUPTITLE" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
	[self.allGroups sortUsingDescriptors:[NSArray arrayWithObject:groupNameSort]];
	[groupNameSort release];
	for(int g=0;g<[self.allGroups count];g++){
		GroupInfo* tempGroup = [self.allGroups objectAtIndex:g];
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
			[self.allGroups removeObject:tempGroup];
			[self.allGroups insertObject:instGroup atIndex:0];
			[instGroup release];
			break;
		}else {
			[instGroup release];
		}
		
	}
	
	NSMutableDictionary* refreshData = [[NSMutableDictionary alloc] initWithCapacity:0];
	
	NSMutableArray* allmemUser = [NSMutableArray array];
	for(int section = 0; section < [[peopleInGroup allKeys] count] ; section++){ //기본 메모리 정보 수정
		NSString *mainkey = [[self.peopleInGroup allKeys] objectAtIndex:section];
		NSMutableArray* mainsections = [self.peopleInGroup objectForKey:mainkey];
		for(int i = 0;i<[mainsections count];i++){
			UserInfo* defaultMemUser = [mainsections objectAtIndex:i];
			[allmemUser addObject:defaultMemUser];
		}
	}
		
	//전체 데이터 베이스를 다시 기본 유지 메모리로 로드 한다.
	for(GroupInfo* group in self.allGroups){
		NSMutableArray* arrayGroup = [NSMutableArray array];
//		NSArray* memUser = [self.peopleInGroup objectForKey:group.GROUPTITLE];
		
		for(UserInfo* person in self.allNames){
			if([person.GID isEqualToString:group.ID] && [person.ISBLOCK isEqualToString:@"N"]) {
				for(UserInfo* compUser in allmemUser){
					if([person.ID isEqualToString:compUser.ID]){
						person.IMSTATUS = compUser.IMSTATUS;
						person.CHANGEDATE = compUser.CHANGEDATE;
						person.CHANGEDATE2 = compUser.CHANGEDATE2;
						
						break;
					}
				}
				[arrayGroup addObject:person];
			}
		}
	
		NSSortDescriptor *formattedSort = [[NSSortDescriptor alloc] initWithKey:@"FORMATTED" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
		NSSortDescriptor *nickNameSort = [[NSSortDescriptor alloc] initWithKey:@"PROFILENICKNAME" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
		[arrayGroup sortUsingDescriptors:[NSArray arrayWithObjects:formattedSort,nickNameSort, nil]];
		[nickNameSort release];
		[formattedSort release];
		[refreshData setObject:arrayGroup forKey:group.GROUPTITLE];
	}
	[self.peopleInGroup removeAllObjects];
	[self.peopleInGroup addEntriesFromDictionary:refreshData];
	[refreshData release];
	
	if(self.viewList){//친구 보기 일 경우 친구 보기 메모리를 재설정한다.
		[self.peopleInBuddy removeAllObjects];
		for(NSString* groupKey in [peopleInGroup allKeys]){
			NSMutableArray* groupUser = [NSMutableArray array];
			for(UserInfo* buddyUser in [peopleInGroup objectForKey:groupKey]){
				if([buddyUser.ISFRIEND isEqualToString:@"S"]){
					[groupUser addObject:buddyUser];
				}
			}
			NSSortDescriptor *formattedSort = [[NSSortDescriptor alloc] initWithKey:@"FORMATTED" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
			NSSortDescriptor *nickNameSort = [[NSSortDescriptor alloc] initWithKey:@"PROFILENICKNAME" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
			[groupUser sortUsingDescriptors:[NSArray arrayWithObjects:formattedSort,nickNameSort, nil]];
			[nickNameSort release];
			[formattedSort release];
			[self.peopleInBuddy setObject:groupUser forKey:groupKey];
		}
	}
	
//	if(self.currentTableView == self.searchDisplayController.searchResultsTableView){// 검색 화면일경우
//		NSMutableDictionary* changeFiltered = [NSMutableDictionary dictionary];
//		[changeFiltered addEntriesFromDictionary:self.filteredHistory];
//		[self.filteredHistory removeAllObjects];
//		
//		for(NSString* searchkey in [self.peopleInGroup allKeys]){
//			NSMutableArray* changeUserArray = [NSMutableArray array];
//			for(UserInfo* searchuser in [changeFiltered valueForKey:searchkey]){
//				for(UserInfo* userNormal in [self.peopleInGroup objectForKey:searchkey]){
//					if([userNormal.ID isEqualToString:searchuser.ID]){
//						[changeUserArray addObject:userNormal];
//					}
//				}
//			}
//			if([changeUserArray count] > 0)
//				[self.filteredHistory setObject:changeUserArray forKey:searchkey];
//		}
//	}
	
	
	//20101012 여기 서도 죽는다..
	if(self.currentTableView == self.searchDisplayController.searchResultsTableView){//검색 일경우
		
		NSLog(@"검색화면");
		
	}
	else {
	//	NSLog(@"self currentt = %@", self.currentTableView);
	//	NSLog(@"검색 화면이 아니다.");
	//	[self.currentTableView reloadData]; //일단 주석 20101015 리로드 안해도 될꺼같다..
		
	}

	
}
/*
 if(groupData != nil && [groupData count] > 0){//그룹 정보가 있을 경우
 NSMutableArray* changeGroup = [NSMutableArray arrayWithArray:self.allGroups];
 
 if(userData != nil && [userData count] > 0){// 그룹 정보와 유저 정보 업데이트
 
 
 }else {//그룹 정보만 업데이트
 for(GroupInfo* addGroup in groupData){ //바뀐 데이터 확인
 for(GroupInfo* curGroup in changeGroup){
 if([curGroup.ID isEqualToString:addGroup.ID]){
 }
 }
 [changeGroup addObject:addGroup];
 }
 }
 
 }else if(userData != nil && [userData count] > 0){// 유저 데이터만 있을 경우
 
 }
 */


/*
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Always returning YES means the view will rotate to accomodate any orientation.
	NSLog(@"여기라도 들어갑시다..");
	NSLog(@"self.title = %@", self.navigationItem.title);
  	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

// sochae 2010.10.08
- (void) sendSMSwitRecipient:(NSString *)recipient
{
	DebugLog(@"========== sendSMSwitRecipient CALLED. ==========");
	BOOL bSMSSend = YES;

	if (NSClassFromString(@"MFMessageComposeViewController") && [MFMessageComposeViewController canSendText])
	{
		MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
		picker.body = nil;
		picker.recipients = [NSArray arrayWithObject:recipient];
		picker.messageComposeDelegate = self;
		picker.delegate = self;
		
		[self presentModalViewController:picker animated:YES];

		picker.navigationBar.topItem.rightBarButtonItem = nil;
		picker.navigationBar.topItem.title = @"";
		
		UIButton *cancelButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 47, 31)] autorelease];
		[cancelButton setBackgroundImage:[UIImage imageNamed:@"btn_searchbar_cancel.png"] forState:UIControlStateNormal];
		[cancelButton setBackgroundImage:[UIImage imageNamed:@"btn_searchbar_cancel_focus.png"] forState:UIControlStateHighlighted];
		[cancelButton addTarget:self action:@selector(cancelModal) forControlEvents:UIControlEventTouchUpInside];
		
		UIBarButtonItem *rightButton = [[[UIBarButtonItem alloc] initWithCustomView:cancelButton] autorelease];
		picker.navigationBar.topItem.rightBarButtonItem = rightButton;
		
		[picker release];		
	}
	else 
	{
		float os_version_num = [[[UIDevice currentDevice] systemVersion] floatValue];

		if( os_version_num >= 4.0 )	// if iPhone OS version >= 4.0
		{
			// iOS 4.0 이상일 때
			bSMSSend = NO;
			DebugLog(@"@@@@@ 4.0이상이지만 sms는 사용 못해");
		}
		else
		{
			// iOS 4.0 이하일 때
			NSString* telno = [[NSString stringWithFormat:@"sms:%@", recipient] 
							   stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			DebugLog(@"@@@@@ 4.0이하여서 sms 어플 invoke");
			bSMSSend = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telno]];
			DebugLog(@"@@@@@ 여기도 처리하나?");
		}
	}

	if (bSMSSend == NO)	// sms 보내기 실패한 경우 alert 보이기.
	{
		[JYUtil alertWithType:ALERT_SMS_ERROR delegate:nil];
	}
}
// ~sochae

@end
