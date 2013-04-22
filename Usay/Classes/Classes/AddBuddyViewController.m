//
//  AddBuddyViewController.m
//  USayApp
//
//  Created by Jong-Sung Park on 10. 6. 20..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "AddBuddyViewController.h"
#import "NSArray-NestedArrays.h"
#import "ItemValueDisplay.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Helpers.h"
#import "USayHttpData.h"
#import "GroupInfo.h"
#import "UserInfo.h"
#import "HttpAgent.h"
#import "json.h"
#import <objc/runtime.h>
#import "UIImageView+WebCache.h"
#import "USayAppAppDelegate.h"
#import "blockView.h"
#import "CheckPhoneNumber.h"
//#import "MyDeviceClass.h"			// sochae 2010.09.11 - UI Position
#import "USayDefine.h"				// sochae 2010.09.09 - added


#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
										green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
										blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define kMaxResolution			800

@implementation AddBuddyViewController

@synthesize  parentController, photoImageView, addBuddyDic, addGroupInfo, addUserImage, saveUserData;
@synthesize  addDelegate, photoLibraryShown, revisionPointer, peopleInGroup;

#pragma mark -
#pragma mark Initialization
-(USayAppAppDelegate *)appDelegate
{
	return [[UIApplication sharedApplication] delegate];
}

- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
		self.view.backgroundColor = ColorFromRGB(0xedeff2);

//		tableHeaderView.backgroundColor = self.tableView.backgroundColor;
//		UILabel *titleLabel = [[UILabel alloc] init];
//		titleLabel.textColor = ColorFromRGB(0x23232a);
//		titleLabel.font = [UIFont systemFontOfSize:13.0f];
//		titleLabel.backgroundColor = [UIColor clearColor];
//		[tableHeaderView addSubview:titleLabel];
//		titleLabel.frame = CGRectMake(tableHeaderView.frame.origin.x, 7.0, tableHeaderView.frame.size.width, 20.0);
//		titleLabel.text = @"추가할 주소의 이름과 핸드폰 번호를 입력해주세요.";
//		self.tableView.tableHeaderView = tableHeaderView;
//		[titleLabel release];
//		[tableHeaderView release];
    }
    return self;
}

#pragma mark -
#pragma mark 사진 모댤부 커스텀


- (void) cancelModal
{
	UIImagePickerController *myPicker = (UIImagePickerController*)self.modalViewController;
	if(myPicker == NULL)
	{
		myPicker = (UIImagePickerController*)parentController.modalViewController;
	}
	[myPicker dismissModalViewControllerAnimated:YES];
}

-(void)backNavi
{
	UIImagePickerController *myPicker = (UIImagePickerController*)self.modalViewController;
	
	
	if(myPicker == NULL)
	{
		myPicker = (UIImagePickerController*)parentController.modalViewController;
	}
	[myPicker popViewControllerAnimated:YES];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	
	UIImagePickerController *myPicker = (UIImagePickerController*)self.modalViewController;
	
	
	NSString *tmpTitle =  navigationController.navigationBar.topItem.title;
	
	if([tmpTitle isEqualToString:@"새로운 메세지"])
	{
		
		
	}
	else {
		
		if(myPicker == NULL)
		{
			myPicker = (UIImagePickerController*)parentController.modalViewController;
		}
		myPicker.navigationBar.topItem.title=@"";
		myPicker.navigationBar.alpha=0.01;
		//	myPicker.navigationBar.topItem.titleView.alpha = 0.1;
		//	myPicker.navigationBar.tintColor = [UIColor clearColor];
		//	myPicker.navigationBar.topItem.rightBarButtonItem.enabled = NO;
		//	myPicker.navigationBar.barStyle = UIBarStyleBlackTranslucent;
		//	[myPicker.navigationBar.topItem.rightBarButtonItem setImage:[UIImage imageNamed:@"btn_searchbar_cancel.png"]];
		
	}
	
	
	
	
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	
	UIImagePickerController *myPicker = (UIImagePickerController*)self.modalViewController;
	
	
	NSString *tmpTitle =  navigationController.navigationBar.topItem.title;
	
	
	
	
	if([tmpTitle isEqualToString:@"사진 앨범"])
	{
		/*
		 UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(navigationController.navigationBar.topItem.titleView.frame.origin.x,
		 navigationController.navigationBar.topItem.titleView.frame.origin.y,
		 navigationController.navigationBar.topItem.titleView.frame.size.width,
		 navigationController.navigationBar.topItem.titleView.frame.size.height)];
		 [tmpLabel setText:@"ㅁㅁㅁㅁㅁ"];
		 navigationController.navigationBar.topItem.titleView=tmpLabel;
		 */
		
		UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectMake(95, 1, 200, 44)];
		[titleView setFont:[UIFont boldSystemFontOfSize:20]];
		[titleView setTextColor:ColorFromRGB(0x053844)];
		titleView.text = @"사진 앨범";
		titleView.backgroundColor = [UIColor clearColor];
		[titleView sizeToFit];
		navigationController.navigationBar.topItem.titleView = titleView;
		
		
		
		
		
		/*
		 UIButton *sendButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 53, 29)] autorelease];
		 [sendButton setBackgroundImage:[UIImage imageNamed:@"btn_send_bsend.png"] forState:UIControlStateNormal];
		 [sendButton setBackgroundImage:[UIImage imageNamed:@"btn_send_bsend_focus.png"] forState:UIControlStateHighlighted];
		 [sendButton addTarget:self action:@selector(sendMail) forControlEvents:UIControlEventTouchUpInside];
		 
		 UIBarButtonItem *rightButton = [[[UIBarButtonItem alloc] initWithCustomView:sendButton] autorelease];
		 
		 //	navigationController.navigationBar.topItem.rightBarButtonItem=rightButton;
		 */
		
		
		UIButton *cancelButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 47, 31)] autorelease];
		[cancelButton setBackgroundImage:[UIImage imageNamed:@"btn_searchbar_cancel.png"] forState:UIControlStateNormal];
		[cancelButton setBackgroundImage:[UIImage imageNamed:@"btn_searchbar_cancel_focus.png"] 
								forState:UIControlStateHighlighted];
		[cancelButton addTarget:self action:@selector(cancelModal) forControlEvents:UIControlEventTouchUpInside];
		
		UIBarButtonItem *leftButton = [[[UIBarButtonItem alloc] initWithCustomView:cancelButton] autorelease];
		navigationController.navigationBar.topItem.leftBarButtonItem = leftButton;
	}
	else
	{
		
		if(myPicker == NULL)
		{
			myPicker = (UIImagePickerController*)parentController.modalViewController;
		}
		
		
		// navi left button
		UIButton *preButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 52, 31)] autorelease];
		[preButton setBackgroundImage:[UIImage imageNamed:@"btn_top_left.png"] forState:UIControlStateNormal];
		[preButton setBackgroundImage:[UIImage imageNamed:@"btn_top_left_focus.png"] forState:UIControlStateHighlighted];
		[preButton addTarget:self action:@selector(backNavi) forControlEvents:UIControlEventTouchUpInside];
		
		UIBarButtonItem *backButton = [[[UIBarButtonItem alloc] initWithCustomView:preButton] autorelease];
		
		// navi right button
		UIButton *cancelButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 47, 31)] autorelease];
		[cancelButton setBackgroundImage:[UIImage imageNamed:@"btn_searchbar_cancel.png"] forState:UIControlStateNormal];
		[cancelButton setBackgroundImage:[UIImage imageNamed:@"btn_searchbar_cancel_focus.png"] 
								forState:UIControlStateHighlighted];
		[cancelButton addTarget:self action:@selector(cancelModal) forControlEvents:UIControlEventTouchUpInside];
		
		UIBarButtonItem *rightButton = [[[UIBarButtonItem alloc] initWithCustomView:cancelButton] autorelease];
		
		
		[myPicker.navigationBar.topItem.backBarButtonItem setImage:[UIImage imageNamed:@"btn_top_left.png"]];
		[myPicker.navigationBar.topItem.leftBarButtonItem setImage:[UIImage imageNamed:@"btn_top_left.png"]];
		myPicker.navigationBar.alpha=1.0;
		
		if(![myPicker.navigationBar.topItem.title isEqualToString:@""])
		{
			myPicker.navigationBar.topItem.leftBarButtonItem = backButton;		
		}
		
		myPicker.navigationBar.topItem.title=@"";
		myPicker.navigationBar.topItem.rightBarButtonItem = rightButton;
		
		// navi title
		if(myLabel == NULL)
		{
			myLabel = [[UILabel alloc] initWithFrame:CGRectMake(115, 0, 120, 44)];
			[myLabel setBackgroundColor:[UIColor clearColor]];
			[myLabel setText:@"사진 앨범"];
			[myLabel setFont:[UIFont systemFontOfSize:18]];
		}
		if(![myLabel superview])
			[myPicker.navigationBar addSubview:myLabel];
		
		//	myPicker.navigationBar.barStyle = UIBarStyleBlackOpaque; // Or whatever style.
		//	myPicker.navigationBar.tintColor = [UIColor blueColor];
		
		
	}
	
	
	
}



#pragma mark -
#pragma mark deltailView data update delegate Method
-(void)updateDataValue:(NSString*)value forkey:(NSString*)key{
	NSIndexPath* indexPath = [rowKeys indexOfNestedObjectForkey:key];
	UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
	
	if([key isEqualToString:@"FORMATTED"]){
		cell.textLabel.textColor = [UIColor blackColor];
		cell.textLabel.text = value;
	}else {
		cell.detailTextLabel.text = value;
	}
	
	[self.addBuddyDic setObject:value forKey:key];
	
	[self.tableView beginUpdates];
}

-(void)updateDataWithArray:(NSArray*)value forkey:(NSString*)key {
	NSIndexPath* indexPath = [rowKeys indexOfNestedObjectForkey:key];
	UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
	
	for(NSDictionary* cellData in value){
		for(NSString* dataKey in [cellData allKeys]){
			if([key isEqualToString:@"FORMATTED"]){
				cell.textLabel.text = [cellData valueForKey:@"이름"];
				[self.addBuddyDic setObject:[cellData valueForKey:@"이름"] forKey:key];
			}
		}
	}

//	[self.tableView reloadData];
	
}
#pragma mark -
#pragma mark navigation button event Method
-(void)addBuddyCompleted {

	
	
	/*
	for(int i = 0;i<[rowKeys count];i++){
		NSArray* rowInSecion = [rowKeys objectAtIndex:i];
		for(int j = 0;j<[rowInSecion count];j++){
			NSString* keyStr = [rowInSecion objectAtIndex:j];
			NSIndexPath* indexPath = [rowKeys indexOfNestedObjectForkey:keyStr];
			UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
			NSString* value = nil;
			if([keyStr isEqualToString:@"Name"]){
		//		value = cell.textLabel.text;
				NSLog(@"NAme = %@", value);
			}else{
	///			value = cell.detailTextLabel.text;
				NSLog(@"ELSE = %@", value);
			}
			
		//	[self.addBuddyDic setObject:value forKey:keyStr];
		}
	}
	*/
	// 모든 데이터를 검사하여 서버로 전송. 전송후 데이터베이스에 저장. 주소록 창으로 이동.
//mobilePhoneNumber, iphonenumber,homeemailaddress 가 같을 경우에 친구로 추가.
/*
	for(int i = 0;i<[rowKeys count];i++){
		NSArray* rowInSecion = [rowKeys objectAtIndex:i];
		for(int j = 0;j<[rowInSecion count];j++){
			NSString* keyStr = [rowInSecion objectAtIndex:j];
			NSIndexPath* indexPath = [rowKeys indexOfNestedObjectForkey:keyStr];
			UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
			NSString* value = nil;
			if([keyStr isEqualToString:@"Name"]){
				value = cell.textLabel.text;
			}else{
				value = cell.detailTextLabel.text;
			}
			
			[self.addBuddyDic setObject:value forKey:keyStr];
		}
	}
*/	
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
	
	UserInfo* userdata = [[[UserInfo alloc] init] autorelease];
	NSArray* keyArray = [self.addBuddyDic allKeys];
	userdata.SIDCREATED = @"mobile";
	for(NSString* addkey in keyArray) {
		
		
		if([addkey isEqualToString:@"FORMATTED"])
			userdata.FORMATTED = [self.addBuddyDic objectForKey:addkey];
		if([addkey isEqualToString:@"SELGROUP"]){
			for(GroupInfo* groupid in addGroupInfo){//그룹을 파악하기 위한 함수
				if([[self.addBuddyDic objectForKey:addkey] isEqualToString:groupid.GROUPTITLE]){
					userdata.GID  = groupid.ID;
					break;
				}
			}
		}
		if([addkey isEqualToString:@"MOBILEPHONENUMBER"])
			userdata.MOBILEPHONENUMBER  = [self.addBuddyDic objectForKey:addkey];
	}
	if(userdata.FORMATTED == nil || [userdata.FORMATTED length] <= 0){
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"입력 정보 확인" 
															message:@"이름을 입력하셔야 추가 하실 수 있습니다." 
														   delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		return;
	}else if(userdata.MOBILEPHONENUMBER == nil || [userdata.MOBILEPHONENUMBER length] <= 0){
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"입력 정보 확인" 
									message:@"전화번호를 입력하셔야 추가 하실수 있습니다." 
									delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		return;
		
	}else if([userdata.FORMATTED length] <= 0 && [userdata.MOBILEPHONENUMBER length] <= 0){
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"입력 정보 확인" 
															message:@"이름과 전화번호를 입력하셔야 추가 하실수 있습니다." 
														   delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		return;
	}else {
		
		NSString *MOBILEPHONENUMBER;
		NSString *IPHONENUMBER;
		NSString *HOMEPHONENUMBER;
		NSString *ORGPHONENUMBER;
		NSString *MAINPHONENUMBER;
		
		
		if(userdata.MOBILEPHONENUMBER == NULL)
		{
			MOBILEPHONENUMBER = @"isnull";
		}else {
			//	MOBILEPHONENUMBER = [[self propertyValues] objectAtIndex:9];
			MOBILEPHONENUMBER =[NSString stringWithFormat:@"='%@'", userdata.MOBILEPHONENUMBER];
		}
		
		if(userdata.IPHONENUMBER == NULL)
		{
			IPHONENUMBER = @"isnull";
		//	NSLog(@"nullllllllll");
		}else {
	//		NSLog(@"pro %d", [[[self propertyValues] objectAtIndex:10] length]);
			//IPHONENUMBER = [[self propertyValues] objectAtIndex:10];
			IPHONENUMBER =[NSString stringWithFormat:@"='%@'", userdata.IPHONENUMBER];
			
		}
		
		if(userdata.HOMEPHONENUMBER == NULL)
		{
			HOMEPHONENUMBER = @"isnull";
		}else {
			//HOMEPHONENUMBER = [[self propertyValues] objectAtIndex:11];
			HOMEPHONENUMBER =[NSString stringWithFormat:@"='%@'", userdata.HOMEPHONENUMBER];
			
		}
		if(userdata.ORGPHONENUMBER == NULL)
		{
			ORGPHONENUMBER = @"isnull";
		}else {
			ORGPHONENUMBER =[NSString stringWithFormat:@"='%@'", userdata.ORGPHONENUMBER];
			
			//	ORGPHONENUMBER = [[self propertyValues] objectAtIndex:12];
		}
		if(userdata.MAINPHONENUMBER == NULL)
		{
			MAINPHONENUMBER = @"isnull";
		}else {
			MAINPHONENUMBER =[NSString stringWithFormat:@"='%@'", userdata.MAINPHONENUMBER];
			
			//	MAINPHONENUMBER = [[self propertyValues] objectAtIndex:13];
		}
		
		
		//	NSString *selectQuery = [NSString stringWithFormat:@"select NICKNAME from _TUserInfo where MOBILEPHONENUMBER='%@' and FORMATTED ='%@'", userdata.MOBILEPHONENUMBER, userdata.FORMATTED];
		/*
		 NSString *selectQuery = [NSString stringWithFormat:@"select * from _TUserInfo where "
		 "MOBILEPHONENUMBER='%@' "
		 "AND IPHONENUMBER='%@' " 
		 "AND HOMEPHONENUMBER='%@' "
		 "AND ORGPHONENUMBER='%@' "
		 "AND MAINPHONENUMBER='%@' "
		 "and FORMATTED='%@'",
		 userdata.MOBILEPHONENUMBER,
		 userdata.IPHONENUMBER,
		 userdata.HOMEPHONENUMBER,
		 userdata.ORGPHONENUMBER,
		 userdata.MAINPHONENUMBER,
		 userdata.FORMATTED];
		 */
		/* sochae 2010.10.05
		NSString *selectQuery = [NSString stringWithFormat:@"select * from _TUserInfo where "
								 "MOBILEPHONENUMBER %@ "
								 "AND IPHONENUMBER %@ " 
								 "AND HOMEPHONENUMBER %@ "
								 "AND ORGPHONENUMBER %@ "
								 "AND MAINPHONENUMBER %@ "
								 "and FORMATTED = \'%@\' ",
								 MOBILEPHONENUMBER,
								 IPHONENUMBER,
								 HOMEPHONENUMBER,
								 ORGPHONENUMBER,
								 MAINPHONENUMBER,
								 userdata.FORMATTED];
		*/
		NSString *strTemp = [NSString stringWithFormat:@"%@", userdata.FORMATTED] ;
		strTemp = [strTemp stringByReplacingOccurrencesOfString:@"'" withString:@"''"];	// (' -> \\ ')
		DebugLog(@"formatted : %@", strTemp);

		NSString *selectQuery = [NSString stringWithFormat:@"select * from _TUserInfo where "
								 "MOBILEPHONENUMBER %@ "
								 "AND IPHONENUMBER %@ " 
								 "AND HOMEPHONENUMBER %@ "
								 "AND ORGPHONENUMBER %@ "
								 "AND MAINPHONENUMBER %@ "
								 "and FORMATTED = '%@' ",
								 MOBILEPHONENUMBER,
								 IPHONENUMBER,
								 HOMEPHONENUMBER,
								 ORGPHONENUMBER,
								 MAINPHONENUMBER,
								 strTemp];
		// ~sochae
		DebugLog(@"query = %@", selectQuery);
		
		NSArray *tmpArray = [UserInfo findWithSql:selectQuery];
		
		if(tmpArray == nil || tmpArray == NULL || [tmpArray count]<= 0)
		{
			NSLog(@"로컬디비에서 발견하지 못함");
		}
		else {
			UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"주소록 정보 확인" 
																message:@"이미 등록된 주소록 입니다." 
															   delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
			[alertView show];
			[alertView release];
			return;
			
			
			NSLog(@"로컬디비에서 발견함..");
		}
		
		
		
		
		[self requestAddContact:userdata];
	}
	
	
	

//	[userdata release];
	
}

-(void)backBarButtonClicked {
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated {	
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated 
{
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad {
//	self.title = @"주소 추가";
	
//	if(isMemoryWarning == YES){
//		isMemoryWarning = NO;
//		[super viewDidLoad];
//		return;
//	}
	
	UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
//	assert(titleView != nil);
	UIFont *titleFont = [UIFont systemFontOfSize:20];
	CGSize titleStringSize = [@"새 주소 추가" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
//	assert(titleFont != nil);
	UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
//	assert(titleLabel != nil);
	[titleLabel setFont:titleFont];
	titleLabel.textAlignment = UITextAlignmentCenter;
	[titleLabel setTextColor:ColorFromRGB(0x053844)];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	[titleLabel setText:@"새 주소 추가"];
//	titleLabel.shadowColor = [UIColor whiteColor];
	[titleView addSubview:titleLabel];	
	[titleLabel release];
	self.navigationItem.titleView = titleView;
	[titleView release];
	self.navigationItem.titleView.frame = CGRectMake((self.tableView.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);
	
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
	
	UIImage* rightBarBtnImg = [[UIImage imageNamed:@"btn_top_complete.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	UIImage* rightBarBtnSelImg = [[UIImage imageNamed:@"btn_top_complete_focus.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[rightBarButton addTarget:self action:@selector(addBuddyCompleted) forControlEvents:UIControlEventTouchUpInside];
	[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
	[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
	rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
	self.navigationItem.rightBarButtonItem = rightButton;
	[rightButton release];
	
	UIView* tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0, self.tableView.frame.size.width, 33.0)];
//	UIImageView* HeaderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5.0, self.view.frame.size.width, 32)];
//	HeaderImageView.image = [[UIImage imageNamed:@"text_add_address.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
//	[tableHeaderView addSubview:HeaderImageView];
//	[HeaderImageView release];
	// sochae 2010.09.11 - UI Position
	//CGRect rect = [MyDeviceClass deviceOrientation];
	CGRect rect = self.view.frame;
	// ~sochae
	UIFont *informationFont = [UIFont systemFontOfSize:13];
	CGSize infoStringSize = [@"추가할 주소의 이름과 핸드폰 번호를 입력해주세요." sizeWithFont:informationFont constrainedToSize:(CGSizeMake(rect.size.width-10.0, 20.0f))];
	UILabel *informationLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 13, rect.size.width-20.0, infoStringSize.height)];
	[informationLabel setFont:informationFont];
	[informationLabel setTextColor:ColorFromRGB(0x313b48)];
	[informationLabel setBackgroundColor:[UIColor clearColor]];
	[informationLabel setText:@"추가할 주소의 이름과 핸드폰 번호를 입력해주세요."];
	[tableHeaderView addSubview:informationLabel];
	[informationLabel release];
	self.tableView.tableHeaderView = tableHeaderView;
	[tableHeaderView release];
	if(addBuddyDic != nil)
		[addBuddyDic release];
	
	addBuddyDic = [[NSMutableDictionary alloc] initWithCapacity:0];
	
	NSMutableArray* groupList = [NSMutableArray array];
	
	if(self.addGroupInfo != nil)
		[self.addGroupInfo release];
	
	self.addGroupInfo = [NSMutableArray arrayWithArray:[GroupInfo findAll]];
	
	NSSortDescriptor *groupNameSort = [[NSSortDescriptor alloc] initWithKey:@"GROUPTITLE" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
	[self.addGroupInfo sortUsingDescriptors:[NSArray arrayWithObject:groupNameSort]];
	[groupNameSort release];
	for(int g=0;g<[self.addGroupInfo count];g++){
		GroupInfo* tempGroup = [self.addGroupInfo objectAtIndex:g];
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
			[self.addGroupInfo removeObject:tempGroup];
			[self.addGroupInfo insertObject:instGroup atIndex:0];
			[instGroup release];
			break;
		}else {
			[instGroup release];
		}
		
	}		
	
	for(GroupInfo* item in self.addGroupInfo){
		if(item.GROUPTITLE != nil){
			if([item.ID isEqualToString:@"0"])
			   [self.addBuddyDic setObject:item.GROUPTITLE forKey:@"SELGROUP"];
			
			[groupList addObject:item.GROUPTITLE];
		}
	}
	//
	if(sectionNames != nil)
		[sectionNames release];
	sectionNames = [[NSArray alloc] initWithObjects: [NSNull null], [NSNull null], nil];
    
	if(rowLabels != nil)
		[rowLabels release];
	rowLabels = [[NSArray alloc] initWithObjects:
                 // Section 1
                 [NSArray arrayWithObjects:@"이름", nil],
                 // Section 2
                 [NSArray arrayWithObjects:@"그룹", @"핸드폰", nil],
				// Sentinel
                 nil];
	
	if(rowKeys != nil)
		[rowKeys release];
	
    rowKeys = [[NSArray alloc] initWithObjects:
               // Section 1
               [NSArray arrayWithObjects:@"FORMATTED", nil],
               // Section 2
               [NSArray arrayWithObjects:@"SELGROUP", @"MOBILEPHONENUMBER", nil],
               // Sentinel
               nil];
    if(rowControllers != nil)
		[rowControllers release];
	rowControllers = [[NSArray alloc] initWithObjects:
                      // Section 1
                      [NSArray arrayWithObject:@"ManagedObjectStringEditor"],
                      // Section 2
                      [NSArray arrayWithObjects:@"ManagedObjectSingleSelectionListEditor", @"ManagedObjectStringEditor", nil],
					 // Sentinel
                      nil];

	if(rowArguments != nil)
		[rowArguments release];
    rowArguments = [[NSArray alloc] initWithObjects:
                    // Section 1
                    [NSArray arrayWithObjects:
					 [NSDictionary dictionaryWithObject:[NSArray arrayWithObjects:@"이름", nil] forKey:@"labelList"], nil],
                    // Section 2,
                    [NSArray arrayWithObjects:
                     [NSDictionary dictionaryWithObject:groupList forKey:@"list"], nil],
					[NSNull null],
                    // Sentinel
                    nil];
	
	if(photoImageView != nil)
		[photoImageView release];
	photoImageView = [[UIButton alloc] initWithFrame:CGRectMake(9.0, 0, 64.0, 64.0)];
	photoImageView.imageView.contentMode = UIViewContentModeScaleAspectFit;
	photoImageView.imageView.bounds = CGRectMake(0, 0,64, 64);
//	[photoImageView.layer setBorderColor:[UIColor colorWithWhite:0 alpha:0.5].CGColor];
//	[photoImageView.layer setBorderWidth:1.0];
	[photoImageView.layer setCornerRadius:5.0];
	[photoImageView setClipsToBounds:YES];
	[photoImageView setBackgroundImage:[UIImage imageNamed:@"img_Addressbook_default.png"] forState:UIControlStateNormal];
	photoImageView.backgroundColor = [UIColor whiteColor];
	photoImageView.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	photoImageView.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	[photoImageView addTarget:self action:@selector(selectedPhotoImage) forControlEvents:UIControlEventTouchUpInside];

	// sochae 2010.09.15 - "사진 설정" label 추가
	UILabel *overLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	[overLabel setFrame:CGRectMake(0.0f, photoImageView.frame.size.height - 23.0f, photoImageView.frame.size.width, 23.0f)];
	[overLabel setFont:[UIFont boldSystemFontOfSize:13.0]];
	[overLabel setBackgroundColor:[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.5f]];
	[overLabel setTextColor:[UIColor whiteColor]];
	overLabel.textAlignment = UITextAlignmentCenter;
	overLabel.text = @"사진설정";
	[photoImageView addSubview:overLabel];
	[overLabel release];
	// ~sochae
	self.tableView.scrollEnabled = NO;
	
	
    [super viewDidLoad];

}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [sectionNames count];;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [rowLabels countOfNestedArray:section];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	
	NSInteger sectionIndex = [indexPath section];
	static NSString *NameCellIdentifier = @"addBuddyNameCellIdentifier";
	static NSString *NormalCellIdentifier = @"addBuddyInfoCellIdentifier";
	NSString *cellIdentifier = nil;
	UITableViewCellStyle cellStyle;
	if(sectionIndex == 0){
		cellIdentifier = NameCellIdentifier;
		cellStyle = UITableViewCellStyleSubtitle;
	}else{
		cellIdentifier = NormalCellIdentifier;
		cellStyle = UITableViewCellStyleValue2;
	}
	
    UITableViewCell *cell = nil;
	if(sectionIndex == 0){
		cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:cellStyle reuseIdentifier:cellIdentifier] autorelease];
			//indent the contentView sufficiently
			cell.indentationLevel = 1;
			cell.indentationWidth = 74.0;
			
			//add the photo to the tableView`s content
			CGRect frame = cell.frame;
			photoImageView.frame = CGRectMake(frame.origin.x-1.0, frame.origin.y-1.0, 64.0, 64.0);
			[cell.contentView addSubview:photoImageView];
			
			cell.textLabel.textColor = ColorFromRGB(0x23232a);
			cell.textLabel.font = [UIFont boldSystemFontOfSize:18.0];
//			cell.textLabel.adjustsFontSizeToFitWidth = YES;
			cell.detailTextLabel.textColor = ColorFromRGB(0x2284ac);
			cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:14.0];
//			cell.textLabel.adjustsFontSizeToFitWidth = YES;
			
			
		}
		[cell.contentView insertSubview:photoImageView atIndex:0];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}else{
		cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:cellStyle reuseIdentifier:cellIdentifier] autorelease];
		}
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		cell.textLabel.textColor = ColorFromRGB(0x2284ac);
		cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0];
		cell.textLabel.textAlignment = UITextAlignmentLeft;
		
		cell.detailTextLabel.textColor = ColorFromRGB(0x7c7c86);
		cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:17.0];
    }
	
	NSString *rowKey = [rowKeys nestedObjectAtIndexPath:indexPath];
    NSString *rowLabel = [rowLabels nestedObjectAtIndexPath:indexPath];
    
	
  if([rowKey isEqualToString:@"FORMATTED"]) {
		cell.textLabel.textColor = ColorFromRGB(0x7c7c86);
		if([self.addBuddyDic valueForKey:rowKey] != nil)
			cell.textLabel.text = [self.addBuddyDic valueForKey:rowKey];
		else 
			cell.textLabel.text = @"이름 입력";
	//	cell.detailTextLabel.text = [self.addBuddyDic valueForKey:@"todays"];
	}else{
		cell.textLabel.text = rowLabel;
		if([rowKey isEqualToString:@"MOBILEPHONENUMBER"]){
			cell.detailTextLabel.text = [CheckPhoneNumber convertPhoneInsertHyphen:(NSMutableString*)[self.addBuddyDic valueForKey:rowKey]];
		}else {
			cell.detailTextLabel.text = [self.addBuddyDic valueForKey:rowKey];
		}

		
	}
	

	
	
	return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == 0){
		if([cell.backgroundView class] != [UIView class]) {
			UIGraphicsBeginImageContext(cell.backgroundView.bounds.size);
			[cell.backgroundView.layer renderInContext:UIGraphicsGetCurrentContext()];
			UIImage* backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();
			UIImage *shrunkenBackgroundImage = [backgroundImage stretchableImageWithHorizontalCapWith:20.0 verticalCapWith:round((backgroundImage.size.height - 1.0)/2.0)];
			UIView *replacementBackgroundView = [[UIView alloc] initWithFrame:cell.backgroundView.frame];
			replacementBackgroundView.autoresizesSubviews;
			
			UIImageView *indentedView = [[UIImageView alloc] initWithFrame:CGRectMake(74.0, 0, replacementBackgroundView.bounds.size.width - 74.0,  replacementBackgroundView.bounds.size.height)];
			indentedView.image = shrunkenBackgroundImage;
			indentedView.contentMode = UIViewContentModeRedraw;
			indentedView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
			indentedView.contentStretch = CGRectMake(0.2, 0, 0.5, 1);
			[replacementBackgroundView addSubview:indentedView];
			[indentedView release];
			
			cell.backgroundView = replacementBackgroundView;
		}
		
		if ([cell.selectedBackgroundView class] != [UIView class])
		{
			UIGraphicsBeginImageContext(cell.selectedBackgroundView.bounds.size);
			[cell.selectedBackgroundView.layer renderInContext:UIGraphicsGetCurrentContext()];
			UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();
			UIImage *shrunkenBackgroundImage = [backgroundImage stretchableImageWithHorizontalCapWith:20.0 verticalCapWith:round((backgroundImage.size.height - 1.0)/2.0)];
			
			UIView *replacementBackgroundView = [[UIView alloc] initWithFrame:cell.backgroundView.frame];
			replacementBackgroundView.autoresizesSubviews;
			
			UIImageView *indentedView = [[UIImageView alloc] initWithFrame:CGRectMake(74.0, 0, replacementBackgroundView.bounds.size.width - 74.0,  replacementBackgroundView.bounds.size.height)];
			indentedView.image = shrunkenBackgroundImage;
			indentedView.contentMode = UIViewContentModeRedraw;
			indentedView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
			indentedView.contentStretch = CGRectMake(0.2, 0, 0.5, 1);
			[replacementBackgroundView addSubview:indentedView];
			[indentedView release];
			
			cell.selectedBackgroundView = replacementBackgroundView;
		}
	}
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
	// Navigation logic may go here. Create and push another view controller.
	NSString *controllerClassName = [rowControllers nestedObjectAtIndexPath:indexPath];
	
	
	
	DebugLog(@"classname = %@", controllerClassName);
    NSString *rowLabel = [rowLabels nestedObjectAtIndexPath:indexPath]!=[NSNull null]?[rowLabels nestedObjectAtIndexPath:indexPath]:@"";
    NSString *rowKey = [rowKeys nestedObjectAtIndexPath:indexPath];
    Class controllerClass = NSClassFromString(controllerClassName);
	
   
		ManagedObjectAttributeEditor *controller = [[controllerClass alloc] initWithStyle:UITableViewStyleGrouped] ;

	
	UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
	
	controller.keypath = rowKey;
	controller.labelString = rowLabel;
//	controller.title = rowLabel;
	controller.delegate = self;
	
	////////// 타이틀 색 지정 //////////
	UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
//	assert(titleView != nil);
	UIFont *titleFont = [UIFont systemFontOfSize:20];
	CGSize titleStringSize = [rowLabel sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
//	assert(titleFont != nil);
	UILabel *naviTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
//	assert(naviTitleLabel != nil);
	[naviTitleLabel setFont:titleFont];
	naviTitleLabel.textAlignment = UITextAlignmentCenter;
	[naviTitleLabel setTextColor:ColorFromRGB(0x053844)];
	[naviTitleLabel setBackgroundColor:[UIColor clearColor]];
	[naviTitleLabel setText:rowLabel];
//	naviTitleLabel.shadowColor = [UIColor whiteColor];
	[titleView addSubview:naviTitleLabel];	
	[naviTitleLabel release];
	controller.navigationItem.titleView = titleView;
	[titleView release];
	controller.navigationItem.titleView.frame = CGRectMake((controller.tableView.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);
	/////////////////////////////////
	
	
	if([rowKey isEqualToString:@"SELGROUP"])
		[controller setValue:cell.detailTextLabel.text forKey:@"selectedValue"];
	
	controller.passDefaultValue = ([self.addBuddyDic valueForKey:rowKey]!=nil)?[self.addBuddyDic valueForKey:rowKey]:[NSString stringWithFormat:@""];
	
	NSDictionary *args = [rowArguments nestedObjectAtIndexPath:indexPath];
	if ([args isKindOfClass:[NSDictionary class]]) {
		if (args != nil) {
			for (NSString *oneKey in args) {
				id oneArg = [args objectForKey:oneKey];
				[controller setValue:oneArg forKey:oneKey];
			}
		}
	}
	[self.navigationController pushViewController:controller animated:YES];	
	[controller release];
	
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if([indexPath section] ==  0 && [indexPath row] == 0){
		return 64.0;
	}
	return tableView.rowHeight;
}

#pragma mark -
#pragma mark image upload Method
-(void)selectedPhotoImage {
	if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
		UIActionSheet* imageAction = [[UIActionSheet alloc] initWithTitle:nil 
																 delegate:self
														cancelButtonTitle:@"취소"
												   destructiveButtonTitle:nil
														otherButtonTitles:@"앨범에서 사진 선택", nil];
		
		[imageAction showInView:self.view];
		[imageAction release];
	}else{
		UIActionSheet* imageAction = [[UIActionSheet alloc] initWithTitle:nil 
																 delegate:self
														cancelButtonTitle:@"취소"
												   destructiveButtonTitle:nil
														otherButtonTitles:@"사진 촬영", @"앨범에서 사진 선택", nil];
		
		[imageAction showInView:self.view];
		[imageAction release];
	}
	
}

#pragma mark UIActionSheet delegate Method
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		//카메라 사용 못함.
		if (buttonIndex == 0) {	// album 사진
			if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
				photoLibraryShown = YES;
				UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//				assert(picker != nil);
				picker.delegate = self;
				picker.allowsEditing = YES;
				picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
				picker.mediaTypes = [NSArray arrayWithObjects:@"public.image", nil];
				[self presentModalViewController:picker animated:YES];
				[picker release];
			}
		}
	}else {
		if (buttonIndex == 0) {			// 사진 
			photoLibraryShown = YES;
			UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//			assert(picker != nil);
			picker.delegate = self;
			picker.sourceType = UIImagePickerControllerSourceTypeCamera;
			picker.allowsEditing = YES;
			picker.mediaTypes = [NSArray arrayWithObjects:@"public.image", nil];
			[self presentModalViewController:picker animated:YES];
			[picker release];
		}else if(buttonIndex == 1) { //album 사진
			photoLibraryShown = YES;
			if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
				UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//				assert(picker != nil);
				picker.delegate = self;
				picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
				picker.allowsEditing = YES;
				picker.mediaTypes = [NSArray arrayWithObjects:@"public.image", nil];
				[self presentModalViewController:picker animated:YES];
				
				picker.navigationItem.title=@" ";
				[picker release];
			}
		}
	}
}

-(UIImage*)resizeImage:(UIImage*)image scaleFlag:(BOOL)aFlag
{	
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
            [NSException raise:NSInternalInconsistencyException format:@"addbuddy Invalid image orientation"];
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
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
	if ([mediaType isEqualToString:@"public.image"]) {			// 사진
		
//		UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
		UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
		if (image) {
			photoLibraryShown = NO;
			UIImage *resizeImage = [self resizeImage:image scaleFlag:YES];
			if (!resizeImage) {
				[picker dismissModalViewControllerAnimated:TRUE];
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"이미지파일 오류" message:@"잘못된 이미지 파일입니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
				[alertView show];
				[alertView release];
				return;
			}
			[photoImageView setBackgroundImage:[self thumbNailImage:resizeImage Size:64.0f] forState:UIControlStateNormal];
			self.addUserImage = resizeImage;
		} else {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"이미지파일 오류" message:@"잘못된 이미지 파일입니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
			[alertView show];
			[alertView release];
		}
	}
	[picker dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[picker dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark network Method
-(BOOL)requestAddContact:(UserInfo*)addUserInfo{
	
	
	NSString* revisionPoint = [[NSUserDefaults standardUserDefaults] objectForKey:@"RevisionPoints"];
	
	NSDictionary *bodyObject2 = [NSDictionary dictionaryWithObjectsAndKeys:
								[[self appDelegate] getSvcIdx],@"svcidx",
								(revisionPoint == nil) ? @"0" : revisionPoint, @"RP",
								nil];
	USayHttpData *data2 = [[[USayHttpData alloc]initWithRequestData:@"getLastAfterRP" andWithDictionary:bodyObject2 timeout:10] autorelease];	
	//	assert(data != nil);		
	[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data2];
	
	// TODO: blockView 사용
	addUserBlockView = [[blockView alloc] initWithFrame:CGRectMake(0.0, 0.0, 250.0, 150.0)];
	addUserBlockView.alertText = @"주소 추가 중...";
	addUserBlockView.alertDetailText = @"잠시만 기다려 주세요.";
	[addUserBlockView show];
	
	//노티피케이션 설정
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addContact:) name:@"addContact" object:nil];

	NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:
								[[self appDelegate] getSvcIdx],@"svcidx",
								addUserInfo.FORMATTED, @"formatted",
								addUserInfo.SIDCREATED, @"sidCreated",
								addUserInfo.GID,@"gid",
								addUserInfo.MOBILEPHONENUMBER, @"mobilePhoneNumber",
								nil];
	
	
	
	SBJSON *json = [[SBJSON alloc]init];
	[json setHumanReadable:YES];
	NSLog(@"addContact >> %@",[json stringWithObject:bodyObject error:nil]);
	[json release];
	
	USayHttpData *data = [[[USayHttpData alloc]initWithRequestData:@"addContact" andWithDictionary:bodyObject timeout:10]autorelease];	
//	assert(data != nil);		
	[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
	return YES;
}
//서버 접속
-(void)addContact:(NSNotification *)notification {
	NSLog(@"noti addContact");
	
	USayHttpData *data = (USayHttpData*)[notification object];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"addContact" object:nil];
	if(self.addUserImage == nil){
	// TODO: blockview 제거
	[addUserBlockView dismissAlertView];
	[addUserBlockView release];
	}
	

	if (data == nil) {
	
		// 200 이외의 에러
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" 
															message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0016)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
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
				id userData = (NSMutableDictionary*)[[UserInfo alloc] init];
				NSArray* keyArray = [addressDic allKeys];
				for(NSString* resultkey in keyArray) {
					NSAutoreleasePool* varpool = [[NSAutoreleasePool alloc] init];
					unsigned int numIvars = 0;
					Ivar* ivars = class_copyIvarList([userData class], &numIvars);
					for(int i = 0; i < numIvars; i++) {
						Ivar thisIvar = ivars[i];
						NSString * classkey = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
						
						if([[resultkey uppercaseString] isEqualToString:classkey])
							[userData  setValue:[addressDic objectForKey:resultkey] forKey:classkey];
					}
					if(numIvars > 0)free(ivars);
					[varpool release];
				}
				NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
				NSLocale *locale = [NSLocale currentLocale];
				[formatter setLocale:locale];
				[formatter setDateFormat:@"yyyyMMddHHmmss"];
				NSDate *today = [NSDate date];
				NSString *lastSyncDate = [[NSString alloc] initWithFormat:@"%@",[formatter stringFromDate:today]];
			//	userData.CHANGEDATE = lastSyncDate;
				[userData setValue:lastSyncDate forKey:@"CHANGEDATE"];
				[serverData addObject:userData];
				[userData release];
			}
			
			[self syncDataSaveDB:serverData withRevisionPoint:RP];
		} else if ([rtcode isEqualToString:@"-9010"]) {
			// TODO: 데이터를 찾을 수 없음
			// TODO: blockview 제거
//			[addUserBlockView dismissAlertView];
//			[addUserBlockView release];
			UIAlertView* failAlert = [[UIAlertView alloc] initWithTitle:@"주소록 등록" 
																message:@"주소록 등록이 실패하였습니다.(-9010)" 
															   delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
			[failAlert show];
			[failAlert release];
		} else if ([rtcode isEqualToString:@"-9020"]) {
			// TODO: 잘못된 인자가 넘어옴
			// TODO: blockview 제거
//			[addUserBlockView dismissAlertView];
//			[addUserBlockView release];
			UIAlertView* failAlert = [[UIAlertView alloc] initWithTitle:@"주소록 등록" 
																message:@"주소록 등록이 실패하였습니다.(-9020)" 
															   delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
			[failAlert show];
			[failAlert release];
		} else if ([rtcode isEqualToString:@"-9030"]) {
			// TODO: 처리 오류
			// TODO: blockview 제거
//			[addUserBlockView dismissAlertView];
//			[addUserBlockView release];
			UIAlertView* failAlert = [[UIAlertView alloc] initWithTitle:@"주소록 등록" 
																message:@"주소록 등록이 실패하였습니다.(-9030)" 
															   delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
			[failAlert show];
			[failAlert release];
		} else {
			// TODO: 기타오류 예외처리 필요
			// TODO: blockview 제거
//			[addUserBlockView dismissAlertView];
//			[addUserBlockView release];
			NSString* errStr = [NSString stringWithFormat:@"주소록 등록이 실패하였습니다.(%@)",rtcode];
			UIAlertView* failAlert = [[UIAlertView alloc] initWithTitle:@"주소록 등록" 
																message:errStr 
															   delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
			[failAlert show];
			[failAlert release];
		}
	}
}

-(void)syncDataSaveDB:(NSArray*)dataArray withRevisionPoint:(NSString *)revisionPoint{
	
//	NSString* revisionPoints = nil;
	if(dataArray != nil){
		for(UserInfo* userData in dataArray){
	//		revisionPoints = userData.RPCREATED;
			[userData insert];
			self.saveUserData = userData;
		}
	}
	self.revisionPointer = [NSString stringWithFormat:@"%@",revisionPoint];
	
	if(self.addUserImage != nil){
		[self addedContactPhontUpload:self.saveUserData];
	}else{
		[self.addDelegate addUserInfoWithUserInfo:self.saveUserData withImage:NO];
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

		// TODO: blockview 제거
//		if(addUserBlockView != nil){
//			[addUserBlockView dismissAlertView];
//			[addUserBlockView release];
//		}
		
		[self.navigationController popViewControllerAnimated:YES];

	}

}
#pragma mark -
#pragma mark 주소록 사진 올리기 샘플
-(void)addedContactPhontUpload:(UserInfo*)userData {
	NSLog(@"addedContactPhontUpload");
	if (self.addUserImage) {
//		insertPhotoView = [[blockView alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, 100.0)];
		addUserBlockView.alertText = @"사진 전송 중...";
		addUserBlockView.alertDetailText = @"잠시만 기다려 주세요.";
//		[insertPhotoView show];
		//노티피케이션 설정
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(insertContactPhoto:) name:@"insertContactPhoto" object:nil];
		

		NSData *imageData = nil;
		CGImageRef imgRef = self.addUserImage.CGImage;
		CGFloat width = CGImageGetWidth(imgRef);
		CGFloat height = CGImageGetHeight(imgRef);
		if (width > kMaxResolution || height > kMaxResolution) {
			imageData = UIImageJPEGRepresentation(self.addUserImage, 0.9f);
		} else {
			imageData = UIImageJPEGRepresentation(self.addUserImage, 1.0f);
		}
//		assert(imageData != nil);
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", [[self appDelegate] generateUUIDString]]];

//		assert(imagePath != nil);

		if (![imageData writeToFile:imagePath atomically:YES]) {
		 NSLog(@"imagePath writeToFile error");
			// TODO: blockview 제거
			[addUserBlockView dismissAlertView];
			[addUserBlockView release];
		}

		NSLog(@"imagePath = %@", imagePath);
		if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath isDirectory:NO]) {
			// not exist file
			NSLog(@"imagePath not exist file");
			// TODO: blockview 제거
			[addUserBlockView dismissAlertView];
			[addUserBlockView release];
			return;
		}
		NSString *pkey = [[self appDelegate].myInfoDictionary objectForKey:@"pkey"]; // userData.RPKEY;//[ objectForKey:@"pkey"];
		
		NSString *transParam = nil;
		if ([HttpAgent mc] == nil || [HttpAgent cs] == nil) {
#ifdef DEVEL_MODE	// sochae 2010.09.09 - dev server
			transParam = [[NSString alloc ] initWithFormat: @"https://social.paran.com/KTH/insertContactPhoto.json?pKey=%@&UCMC=%@&UCCS=%@&cid=%@", 
#else
			transParam = [[NSString alloc ] initWithFormat:@"https://dev.usay.net/KTH/insertContactPhoto.json?pKey=%@&UCMC=%@&UCCS=%@&cid=%@", 
#endif // #ifdef DEVEL_MODE
						  pkey, 
						  [HttpAgent ucmc], [HttpAgent uccs], userData.ID];
		} else {
#ifdef DEVEL_MODE	// sochae 2010.09.09 - dev server
			transParam = [[NSString alloc ] initWithFormat: @"https://social.paran.com/KTH/insertContactPhoto.json?pKey=%@&MC=%@&CS=%@&UCMC=%@&UCCS=%@&cid=%@", 
#else
			transParam = [[NSString alloc ] initWithFormat:@"https://dev.usay.net/KTH/insertContactPhoto.json?pKey=%@&MC=%@&CS=%@&UCMC=%@&UCCS=%@&cid=%@", 
#endif // #ifdef DEVEL_MODE
						  pkey, [HttpAgent mc], [HttpAgent cs],
						  [HttpAgent ucmc], [HttpAgent uccs], userData.ID];
		}
		DebugLog(@"=== KTH : transParam = %@", transParam);
		
		NSString *uuid = [[self appDelegate] generateUUIDString];
//		assert(uuid != nil);
		NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init]autorelease];
//		assert(bodyObject != nil);
		[bodyObject setObject:@"1" forKey:@"mediaType"];		// 0: video  1: photo
		[bodyObject setObject:uuid forKey:@"uuid"];
		[bodyObject setObject:[NSNull null] forKey:@"uploadFile"];
		[bodyObject setObject:transParam forKey:@"transParam"];
		[transParam release];
		// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
		
		USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"albumUpload" andWithDictionary:bodyObject timeout:30]autorelease];
//		assert(data != nil);
		data.subApi = @"insertContactPhoto";
		data.filePath = imagePath;
		data.uniqueId = uuid;
		data.mType = @"P";
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"requestUploadUrlMultipartForm" object:data];
	}else {
		NSLog(@"프로필 사진 추가 오류 - 이미지파일 오류. 잘못된 이미지 파일입니다.");
		// TODO: blockview 제거
		[addUserBlockView dismissAlertView];
		[addUserBlockView release];
		if (photoLibraryShown == YES) {
			photoLibraryShown = NO;
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"이미지파일 오류" message:@"잘못된 이미지 파일입니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
			[alertView show];
			[alertView release];
		}
		photoLibraryShown = NO;
	}
	
	
}
-(void)insertContactPhoto:(NSNotification *)notification{
	USayHttpData *data = (USayHttpData*)[notification object];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"insertContactPhoto" object:nil];
	// TODO: blockview 제거

	[addUserBlockView dismissAlertView];
	[addUserBlockView release];
	if (data == nil) {
		// 200 이외의 에러
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" 
															message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0017)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
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
		if ([rtType isEqualToString:@"map"]) {
			NSDictionary *addressDic = [dic objectForKey:@"map"];
			if(addressDic != nil){
				id userData = [NSMutableDictionary dictionary];
				NSArray* keyArray = [addressDic allKeys];
				for(NSString* resultkey in keyArray) {
					if([resultkey isEqualToString:@"photoUrl"]){
						[userData  setValue:[addressDic objectForKey:resultkey] forKey:@"THUMBNAILURL"];
					}
				}
				[self syncImageDataSaveDB:userData];
			}
		}	
	} else if ([rtcode isEqualToString:@"-9010"]) {
		// TODO: 데이터를 찾을 수 없음
		// TODO: blockview 제거
//			[addUserBlockView dismissAlertView];
//			[addUserBlockView release];
		UIAlertView* failAlert = [[UIAlertView alloc] initWithTitle:@"사진 등록" 
															message:@"사진 등록이 실패하였습니다.(-9010)" 
														   delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[failAlert show];
		[failAlert release];
	} else if ([rtcode isEqualToString:@"-9020"]) {
		// TODO: 잘못된 인자가 넘어옴
		// TODO: blockview 제거
//			[addUserBlockView dismissAlertView];
//			[addUserBlockView release];
		UIAlertView* failAlert = [[UIAlertView alloc] initWithTitle:@"사진 등록" 
															message:@"사진 등록이 실패하였습니다.(-9020)" 
														   delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[failAlert show];
		[failAlert release];
	} else if ([rtcode isEqualToString:@"-9030"]) {
		// TODO: 처리 오류
		// TODO: blockview 제거
//			[addUserBlockView dismissAlertView];
//			[addUserBlockView release];
		UIAlertView* failAlert = [[UIAlertView alloc] initWithTitle:@"사진 등록" 
															message:@"사진 등록이 실패하였습니다.(-9030)" 
														   delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[failAlert show];
		[failAlert release];
	} else {
		// TODO: 기타오류 예외처리 필요
		// TODO: blockview 제거
//			[addUserBlockView dismissAlertView];
//			[addUserBlockView release];
		NSString* errStr = [NSString stringWithFormat:@"사진 등록이 실패하였습니다.%@",rtcode];
		UIAlertView* failAlert = [[UIAlertView alloc] initWithTitle:@"사진 등록" 
															message:errStr 
														   delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[failAlert show];
		[failAlert release];
	}
	
	
}

-(void)syncImageDataSaveDB:(UserInfo*)ImageData {
	if(ImageData != nil){
//		self.saveUserData.USERIMAGE =  UIImageJPEGRepresentation(self.addUserImage, 1.0f);
		NSLog(@"imageUrl %@",[ImageData valueForKey:@"THUMBNAILURL"]);
		[self.saveUserData setValue:[ImageData valueForKey:@"THUMBNAILURL"] forKey:@"THUMBNAILURL"];

		[self.saveUserData saveData];

		[[NSUserDefaults standardUserDefaults] setObject:self.revisionPointer forKey:@"RevisionPoints"];
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		NSLocale *locale = [NSLocale currentLocale];
		[formatter setLocale:locale];
		[formatter setDateFormat:@"yyyyMMddHHmmss"];
		NSDate *today = [NSDate date];
		NSString *lastSyncDate = [[NSString alloc] initWithFormat:@"%@",[formatter stringFromDate:today]];
		[[NSUserDefaults standardUserDefaults] setObject:lastSyncDate forKey:@"lastSyncDate"];
		[lastSyncDate release];
		[formatter release];
		
		[self.addDelegate addUserInfoWithUserInfo:self.saveUserData withImage:YES];
		
//		// TODO: blockview 제거
//		[addUserBlockView dismissAlertView];
//		[addUserBlockView release];
		[self.navigationController popViewControllerAnimated:YES];
	}else {
//		// TODO: blockview 제거
//		[addUserBlockView dismissAlertView];
//		[addUserBlockView release];
		UIAlertView* failAlert = [[UIAlertView alloc] initWithTitle:@"사진 등록" 
													message:@"사진 등록이 실패하였습니다." 
													delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[failAlert show];
		[failAlert release];
	}


	
}
#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
//	isMemoryWarning = YES;
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
//	self.parentController = nil;
//	self.photoImageView = nil;
//	self.addGroupInfo = nil;
//	self.addBuddyDic = nil;
	self.addUserImage = nil;
	self.saveUserData = nil;
	[super viewDidUnload];
}


- (void)dealloc {
//	if(parentController)[parentController release];
    if(sectionNames)[sectionNames release];
    if(rowLabels)[rowLabels release];
    if(rowKeys)[rowKeys release];
    if(rowControllers)[rowControllers release];
	if(photoImageView)[photoImageView release];
	if(addGroupInfo) [addGroupInfo release];
	if(addBuddyDic) [addBuddyDic release];
//	if(addUserImage) [addUserImage release];
//	if(saveUserData) [saveUserData release];

    [super dealloc];
}


@end


