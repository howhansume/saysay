//
//  BuddyPersonViewController.m
//  USayApp
//
//  Created by Jong-Sung Park on 10. 6. 15..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//


#import "BuddyPersonViewController.h"
#import "AddressDetailViewController.h"
#import "NSArray-NestedArrays.h"
#import "ItemValueDisplay.h"
#import "USayAppAppDelegate.h" 
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Helpers.h"
#import "UserInfo.h"
#import "GroupInfo.h"
#import "HttpAgent.h"
#import "json.h"
#import "USayHttpData.h"
#import <objc/runtime.h>
#import "UIImageView+WebCache.h"
#import "SDWebImageManager.h"
#import "blockView.h"
#import "CheckPhoneNumber.h"
#import "SayViewController.h"
#import "CellMsgListData.h"
#import "CellMsgData.h"
#import "MessageInfo.h"
//#import "MyDeviceClass.h"			// sochae 2010.09.11 - UI Position
#import "USayDefine.h"				// sochae 2010.09.09 - added
#import "openImgViewController.h" //kjh 2010.10.21 - add
#import <CommonCrypto/CommonDigest.h>


#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define kTitleLabel			8501
#define kDetailtitleLabel	8502
#define kMaxResolution		800
#define BUTTONTAG		9999
@implementation BuddyPersonViewController
@synthesize  parentController, photoImageView, buddyPKey, personInfo, isEdit, photoLibraryShown, addUserImage;
@synthesize personDelegate, mainPhotoView;

extern BOOL LOGINEND;
extern BOOL LOGINSUCESS;
extern BOOL CHKOFF;
extern BOOL LOGINSTART;



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


-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

-(USayAppAppDelegate *)appDelegate
{
	return (USayAppAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidDisappear:(BOOL)animated 
{
    [super viewDidDisappear:animated];
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	DebugLog(@"touch...");
}


-(void)reLoadMemory
{
	//리로드...
	DebugLog(@"편집 버튼 액션");
	NSMutableArray* groupInfo = [NSMutableArray arrayWithArray:[GroupInfo findAll]];
	NSSortDescriptor *groupNameSort = [[NSSortDescriptor alloc] initWithKey:@"GROUPTITLE" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
	[groupInfo sortUsingDescriptors:[NSArray arrayWithObject:groupNameSort]];
	[groupNameSort release];
	for(int g=0;g<[groupInfo count];g++){
		GroupInfo* tempGroup = [groupInfo objectAtIndex:g];
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
			[groupInfo removeObject:tempGroup];
			[groupInfo insertObject:instGroup atIndex:0];
			[instGroup release];
			break;
		}else {
			[instGroup release];
		}
		
	}
	NSMutableArray* groupList = [NSMutableArray array];
	for(GroupInfo* item in groupInfo){
		if(item.GROUPTITLE != nil)
			[groupList addObject:item.GROUPTITLE];
	}
		
}


-(void)createRightButton
{
	DebugLog(@"Create Right Button");
	
	UIImage* editBarBtnImg;
	UIImage* editBarBtnSelImg;
	
	if(!isEdit)
	{
		editBarBtnImg = [[UIImage imageNamed:@"btn_top_edit.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
		editBarBtnSelImg = [[UIImage imageNamed:@"btn_top_edit_focus.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	}
	else
	{
		editBarBtnImg = [[UIImage imageNamed:@"btn_top_complete.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
		editBarBtnSelImg = [[UIImage imageNamed:@"btn_top_complete_focus.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	}

	UIButton* editBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[editBarButton addTarget:self action:@selector(updateBuddyCompleted) forControlEvents:UIControlEventTouchUpInside];
	[editBarButton setImage:editBarBtnImg forState:UIControlStateNormal];
	[editBarButton setImage:editBarBtnSelImg forState:UIControlStateSelected];
	editBarButton.frame = CGRectMake(0.0, 0.0, editBarBtnImg.size.width, editBarBtnImg.size.height);
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithCustomView:editBarButton];
	if(parentController != nil){
		parentController.navigationItem.rightBarButtonItem = editButton;
	}else {
		self.navigationItem.rightBarButtonItem = editButton;
	}
	if([self appDelegate].connectionType == -1)
		editButton.enabled  = NO;
	[editButton release];

	
	//리로드...
	/*
		NSLog(@"편집 버튼 액션");
		NSMutableArray* groupInfo = [NSMutableArray arrayWithArray:[GroupInfo findAll]];
		NSSortDescriptor *groupNameSort = [[NSSortDescriptor alloc] initWithKey:@"GROUPTITLE" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
		[groupInfo sortUsingDescriptors:[NSArray arrayWithObject:groupNameSort]];
		[groupNameSort release];
		for(int g=0;g<[groupInfo count];g++){
			GroupInfo* tempGroup = [groupInfo objectAtIndex:g];
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
				[groupInfo removeObject:tempGroup];
				[groupInfo insertObject:instGroup atIndex:0];
				[instGroup release];
				break;
			}else {
				[instGroup release];
			}
			
		}
		NSMutableArray* groupList = [NSMutableArray array];
		for(GroupInfo* item in groupInfo){
			if(item.GROUPTITLE != nil)
				[groupList addObject:item.GROUPTITLE];
		}
		
		//	NSMutableArray* mobileLabel = [NSMutableArray array];
		//	NSMutableArray* mobilekey = [NSMutableArray array];
		//	NSMutableArray* mobileController = [NSMutableArray array];
	 */
	[self.tableView reloadData];

	return;
	
	
		
		
	
	

}


- (void)viewDidLoad {
	
	DebugLog(@"주소록 정보 로드...");
	
//	if(isMemoryWarning == YES){
//		isMemoryWarning = NO;
//		[super viewDidLoad];
//		return;
//	}
//	
//	isMemoryWarning = NO;
	
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
	

	isEdit = NO;
	
	
	
	UIImage* editBarBtnImg = [[UIImage imageNamed:@"btn_top_edit.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	UIImage* editBarBtnSelImg = [[UIImage imageNamed:@"btn_top_edit_focus.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	UIButton* editBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[editBarButton addTarget:self action:@selector(updateBuddyCompleted) forControlEvents:UIControlEventTouchUpInside];
	[editBarButton setImage:editBarBtnImg forState:UIControlStateNormal];
	[editBarButton setImage:editBarBtnSelImg forState:UIControlStateSelected];
	editBarButton.frame = CGRectMake(0.0, 0.0, editBarBtnImg.size.width, editBarBtnImg.size.height);
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithCustomView:editBarButton];
	
	
	
	
//	if(parentController != nil){
//		[editBarButton addTarget:parentController action:@selector(updateBuddyCompleted) forControlEvents:UIControlEventTouchUpInside];
//	}else {
		
//	}

	
	if(parentController != nil){
		parentController.navigationItem.rightBarButtonItem = editButton;
	}else {
		self.navigationItem.rightBarButtonItem = editButton;
	}

	if([self appDelegate].connectionType == -1)
		editButton.enabled  = NO;
	
	[editButton release];
	
	photoImageView = [[UIButton alloc] initWithFrame:CGRectMake(9.0, 0, 64.0, 64.0)];
	photoImageView.imageView.contentMode = UIViewContentModeScaleAspectFit;
	photoImageView.imageView.bounds = CGRectMake(0, 0,64, 64);
//	[photoImageView.layer setBorderColor:[UIColor colorWithWhite:0 alpha:0.5].CGColor];
//	[photoImageView.layer setBorderWidth:1.0];
	[photoImageView.layer setCornerRadius:5.0];
	[photoImageView setClipsToBounds:YES];
	[photoImageView setBackgroundImage:[UIImage imageNamed:@"img_Addressbook_default.png"] forState:UIControlStateNormal];
	photoImageView.backgroundColor = [UIColor clearColor];
	photoImageView.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	photoImageView.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	[photoImageView addTarget:self action:@selector(imageSelect) forControlEvents:UIControlEventTouchUpInside];
	
	
	//
	
	//버튼 수정 소스
	/*
	mainPhotoView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64.0f, 64.0f)];
	mainPhotoView.imageView.contentMode = UIViewContentModeScaleAspectFit;
	mainPhotoView.imageView.bounds = CGRectMake(0, 0,64, 64);
	[mainPhotoView.layer setCornerRadius:5.0];
	[mainPhotoView setClipsToBounds:YES];
	[mainPhotoView setImage:[UIImage imageNamed:@"img_Addressbook_default.png"] forState:UIControlStateNormal];
	mainPhotoView.backgroundColor = [UIColor clearColor];
	mainPhotoView.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	mainPhotoView.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	[mainPhotoView addTarget:self action:@selector(imgClick) forControlEvents:UIControlEventTouchUpInside];
	mainPhotoView.tag = BUTTONTAG;
	*/
	
	
	
	
	//원래소스. 
	 mainPhotoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 64.0f, 64.0f)];
	mainPhotoView.contentMode = UIViewContentModeScaleAspectFit;
	[mainPhotoView setBackgroundColor:[UIColor clearColor]];
	// sochae 2011.01.04 - 여기 왜 늘리지? (이것 때문에 추천친구의 주소록 정보 변경 후 업데이트 하면 주소록 정보 이미지 찌그러짐)
	//[mainPhotoView setImage:[[UIImage imageNamed:@"img_Addressbook_default.png"] stretchableImageWithLeftCapWidth:5.0 topCapHeight:0.0]];
	[mainPhotoView setImage:[UIImage imageNamed:@"img_Addressbook_default.png"]];
	// ~sochae
	mainPhotoView.layer.masksToBounds = YES;
	mainPhotoView.layer.cornerRadius = 5.0;
//	mainPhotoView.layer.borderWidth = 1.0;
	mainPhotoView.clipsToBounds = YES;
	
	
	
	
	
	
	
	
	
	NSArray* currentUser = [UserInfo findByColumn:@"ID" value:personInfo.ID];
	self.personInfo = [currentUser objectAtIndex:0];
	
	DebugLog(@"person info = %@", personInfo.THUMBNAILURL);
		
	[self normalInterFaceConfig];
	
	self.view.backgroundColor = ColorFromRGB(0xedeff2);
	self.tableView.sectionHeaderHeight = 5.0;
	self.tableView.sectionFooterHeight = 5.0;
    [super viewDidLoad];
	
}

-(void)normalInterFaceConfig {
	
	DebugLog(@"노말 인터페이스");
	
	NSArray* groupInfo = [GroupInfo findAll];
	NSMutableArray* groupList = [NSMutableArray array];
	for(GroupInfo* item in groupInfo){
		if(item.GROUPTITLE != nil)
			[groupList addObject:item.GROUPTITLE];
	}
	
//	NSMutableArray* mobileLabel = [NSMutableArray array];
//	NSMutableArray* mobilekey = [NSMutableArray array];

	NSMutableArray* secondLabel = [NSMutableArray array];
	NSMutableArray* secondkey = [NSMutableArray array];

	if(personInfo.MOBILEPHONENUMBER != nil && [personInfo.MOBILEPHONENUMBER length] > 0){
//		[mobilekey addObject:[NSString stringWithFormat:@"MOBILEPHONENUMBER"]];
//		[mobileLabel addObject:[NSString stringWithFormat:@"핸드폰"]];
		[secondkey addObject:[NSString stringWithFormat:@"MOBILEPHONENUMBER"]];
		[secondLabel addObject:[NSString stringWithFormat:@"핸드폰"]];
	}
	if(personInfo.IPHONENUMBER != nil && [personInfo.IPHONENUMBER length] > 0){
//		[mobilekey addObject:[NSString stringWithFormat:@"IPHONENUMBER"]];
//		[mobileLabel addObject:[NSString stringWithFormat:@"핸드폰2"]];
		[secondkey addObject:[NSString stringWithFormat:@"IPHONENUMBER"]];
		[secondLabel addObject:[NSString stringWithFormat:@"핸드폰2"]];
	}
	if(personInfo.HOMEPHONENUMBER != nil && [personInfo.HOMEPHONENUMBER length] > 0){
		[secondkey addObject:[NSString stringWithFormat:@"homePhoneNumber"]];
		[secondLabel addObject:[NSString stringWithFormat:@"집전화"]];
	}
	
	if(personInfo.ORGPHONENUMBER != nil && [personInfo.ORGPHONENUMBER length] > 0){
		[secondkey addObject:[NSString stringWithFormat:@"orgPhoneNumber"]];
		[secondLabel addObject:[NSString stringWithFormat:@"직장전화"]];
	}
	
//	NSMutableArray* emailLabel = [NSMutableArray array];
//	NSMutableArray* emailkey = [NSMutableArray array];
	if(personInfo.HOMEEMAILADDRESS != nil && [personInfo.HOMEEMAILADDRESS length] > 0){
//		[emailkey addObject:[NSString stringWithFormat:@"HOMEEMAILADDRESS"]];
//		[emailLabel addObject:[NSString stringWithFormat:@"이메일"]];
		[secondkey addObject:[NSString stringWithFormat:@"HOMEEMAILADDRESS"]];
		[secondLabel addObject:[NSString stringWithFormat:@"이메일"]];
	}
	if(personInfo.ORGEMAILADDRESS != nil && [personInfo.ORGEMAILADDRESS length] > 0){
//		[emailkey addObject:[NSString stringWithFormat:@"ORGEMAILADDRESS"]];
//		[emailLabel addObject:[NSString stringWithFormat:@"이메일2"]];
		[secondkey addObject:[NSString stringWithFormat:@"ORGEMAILADDRESS"]];
		[secondLabel addObject:[NSString stringWithFormat:@"이메일2"]];
	}
	if(personInfo.ORGNAME != nil && [personInfo.ORGNAME length] > 0){
		[secondkey addObject:[NSString stringWithFormat:@"orgname"]];
		[secondLabel addObject:[NSString stringWithFormat:@"소속"]];
	}
	if(personInfo.NICKNAME != nil && [personInfo.NICKNAME length] > 0){
		[secondkey addObject:[NSString stringWithFormat:@"nickname"]];
		[secondLabel addObject:[NSString stringWithFormat:@"별명"]];
	}
	
	if(personInfo.URL1 != nil && [personInfo.URL1 length] > 0){
		[secondkey addObject:[NSString stringWithFormat:@"url1"]];
		[secondLabel addObject:[NSString stringWithFormat:@"홈페이지"]];
	}
	
	if(personInfo.NOTE != nil && [personInfo.NOTE length] > 0) {
		[secondkey addObject:[NSString stringWithFormat:@"note"]];
		[secondLabel addObject:[NSString stringWithFormat:@"메모"]];
	}
	
	if(sectionNames != nil )
		[sectionNames release];
	
	sectionNames = [[NSArray alloc] initWithObjects: [NSNull null], [NSNull null], [NSNull null], nil];
	
	if(rowLabels != nil)
		[rowLabels release];
	
    rowLabels = [[NSArray alloc] initWithObjects:
                 // Section 1
                 [NSArray arrayWithObjects:@"formatted", nil],
				 // Section 2
                 [NSArray arrayWithObjects:@"그룹", nil],
				 // Section 3
				 secondLabel,
//				 mobileLabel,
				 //   [NSArray arrayWithObjects:@"핸드폰", nil],				 
				 // Section 4
 //                [NSArray arrayWithObjects:@"집전화", nil],
				 // Section 5
  //               [NSArray arrayWithObjects:@"직장전화", nil],
				 // Section 6
//				 emailLabel,
				 //     [NSArray arrayWithObjects:@"이메일", nil],
                 // Sentinel
                 nil];
	if(rowKeys != nil)
		[rowKeys release];
    rowKeys = [[NSArray alloc] initWithObjects:
			   // Section 1
			   [NSArray arrayWithObjects:@"formatted", nil],
			   // Section 2
			   [NSArray arrayWithObjects:@"group", nil],

			   // Section 3
			   secondkey,
//			   mobilekey,
			   //	   [NSArray arrayWithObjects:@"phoneNumber", nil],
			   // Section 4
//			   [NSArray arrayWithObjects:@"homePhoneNumber", nil],
			   // Section 5
//			   [NSArray arrayWithObjects:@"orgPhoneNumber", nil],
			   // Section 6
//			   emailkey,
			   //		   [NSArray arrayWithObjects:@"Email", nil],
			   // Sentinel
               nil];
    
	
	//여기에서 죽는다??? 예외처리하자
	if(self.tableView.tableFooterView)
	{
		self.tableView.tableFooterView = nil;
	}
		[self addCustomFooterView];
	self.tableView.editing = NO;
    self.tableView.allowsSelectionDuringEditing = NO;
	
}
//
-(void)editInterFaceConfig {
	DebugLog(@"편집 버튼 액션");
	NSMutableArray* groupInfo = [NSMutableArray arrayWithArray:[GroupInfo findAll]];
	NSSortDescriptor *groupNameSort = [[NSSortDescriptor alloc] initWithKey:@"GROUPTITLE" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
	[groupInfo sortUsingDescriptors:[NSArray arrayWithObject:groupNameSort]];
	[groupNameSort release];
	for(int g=0;g<[groupInfo count];g++){
		GroupInfo* tempGroup = [groupInfo objectAtIndex:g];
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
			[groupInfo removeObject:tempGroup];
			[groupInfo insertObject:instGroup atIndex:0];
			[instGroup release];
			break;
		}else {
			[instGroup release];
		}
		
	}
	NSMutableArray* groupList = [NSMutableArray array];
	for(GroupInfo* item in groupInfo){
		if(item.GROUPTITLE != nil)
			[groupList addObject:item.GROUPTITLE];
	}
	
//	NSMutableArray* mobileLabel = [NSMutableArray array];
//	NSMutableArray* mobilekey = [NSMutableArray array];
//	NSMutableArray* mobileController = [NSMutableArray array];
	NSMutableArray* secondLabel = [NSMutableArray array];
	NSMutableArray* secondkey = [NSMutableArray array];
	NSMutableArray* secondController = [NSMutableArray array];

	/*
	if(personInfo.MOBILEPHONENUMBER != nil && [personInfo.MOBILEPHONENUMBER length] > 0){
//		[mobilekey addObject:[NSString stringWithFormat:@"MOBILEPHONENUMBER"]];
//		[mobileLabel addObject:[NSString stringWithFormat:@"핸드폰"]];
//		[mobileController addObject:[NSString stringWithFormat:@"ManagedObjectStringEditor"]];
		[secondkey addObject:[NSString stringWithFormat:@"MOBILEPHONENUMBER"]];
		[secondLabel addObject:[NSString stringWithFormat:@"핸드폰"]];
		NSLog(@"수정 핸드폰 있다.");
		[secondController addObject:[NSString stringWithFormat:@"ManagedObjectStringEditor"]];
		
	}
	 */
	
	//아이폰은 필드에 있을 경우만 수정 가능하게 한다...
	if(personInfo.IPHONENUMBER != nil && [personInfo.IPHONENUMBER length] > 0){
//		[mobilekey addObject:[NSString stringWithFormat:@"IPHONENUMBER"]];
//		[mobileLabel addObject:[NSString stringWithFormat:@"핸드폰2"]];
//		[mobileController addObject:[NSString stringWithFormat:@"ManagedObjectStringEditor"]];
		[secondkey addObject:[NSString stringWithFormat:@"IPHONENUMBER"]];
		[secondLabel addObject:[NSString stringWithFormat:@"핸드폰2"]];
		DebugLog(@"수정 아이폰 있다.");
		[secondController addObject:[NSString stringWithFormat:@"ManagedObjectStringEditor"]];
	}
/*	
	if([personInfo.MOBILEPHONENUMBER length] <= 0 && [personInfo.IPHONENUMBER length] <= 0) {
//		[mobilekey addObject:[NSString stringWithFormat:@"MOBILEPHONENUMBER"]];
//		[mobileLabel addObject:[NSString stringWithFormat:@"핸드폰"]];
//		[mobileController addObject:[NSString stringWithFormat:@"ManagedObjectStringEditor"]];
		[secondkey addObject:[NSString stringWithFormat:@"MOBILEPHONENUMBER"]];
		[secondLabel addObject:[NSString stringWithFormat:@"핸드폰"]];
		NSLog(@"수정 모바일폰 있다.");
		[secondController addObject:[NSString stringWithFormat:@"ManagedObjectStringEditor"]];
	}
*/	
	
	//모바일 폰, 집전화 직장전화 이메일은 항상 수정 가능하게...
	[secondkey addObject:[NSString stringWithFormat:@"MOBILEPHONENUMBER"]];
	[secondLabel addObject:[NSString stringWithFormat:@"핸드폰"]];
	DebugLog(@"수정 모바일폰 있다.");
	[secondController addObject:[NSString stringWithFormat:@"ManagedObjectStringEditor"]];
	
	
	
	
	
	[secondkey addObject:[NSString stringWithFormat:@"homePhoneNumber"]];
	[secondLabel addObject:[NSString stringWithFormat:@"집전화"]];
	[secondController addObject:[NSString stringWithFormat:@"ManagedObjectStringEditor"]];
	[secondkey addObject:[NSString stringWithFormat:@"orgPhoneNumber"]];
	[secondLabel addObject:[NSString stringWithFormat:@"직장전화"]];
	[secondController addObject:[NSString stringWithFormat:@"ManagedObjectStringEditor"]];
	
	
	[secondkey addObject:[NSString stringWithFormat:@"HOMEEMAILADDRESS"]];
	[secondLabel addObject:[NSString stringWithFormat:@"이메일"]];
	DebugLog(@"수정 이메일 있다.");
	[secondController addObject:[NSString stringWithFormat:@"ManagedObjectStringEditor"]];
	

	
	
//	NSMutableArray* emailLabel = [NSMutableArray array];
//	NSMutableArray* emailkey = [NSMutableArray array];
//	NSMutableArray* emailController = [NSMutableArray array];
	/*
	if(personInfo.HOMEEMAILADDRESS != nil && [personInfo.HOMEEMAILADDRESS length] > 0){
//		[emailkey addObject:[NSString stringWithFormat:@"HOMEEMAILADDRESS"]];
//		[emailLabel addObject:[NSString stringWithFormat:@"이메일"]];
//		[emailController addObject:[NSString stringWithFormat:@"ManagedObjectStringEditor"]];
		[secondkey addObject:[NSString stringWithFormat:@"HOMEEMAILADDRESS"]];
		[secondLabel addObject:[NSString stringWithFormat:@"이메일"]];
		NSLog(@"수정 이메일 있다.");
		[secondController addObject:[NSString stringWithFormat:@"ManagedObjectStringEditor"]];
	}
	 */
	 if(personInfo.ORGEMAILADDRESS != nil && [personInfo.ORGEMAILADDRESS length] > 0){
//		[emailkey addObject:[NSString stringWithFormat:@"ORGEMAILADDRESS"]];
//		[emailLabel addObject:[NSString stringWithFormat:@"이메일2"]];
		
		[secondkey addObject:[NSString stringWithFormat:@"ORGEMAILADDRESS"]];
		[secondLabel addObject:[NSString stringWithFormat:@"이메일2"]];
		[secondController addObject:[NSString stringWithFormat:@"ManagedObjectStringEditor"]];
		
	}
	/*
	if([personInfo.HOMEEMAILADDRESS length] <= 0 && [personInfo.ORGEMAILADDRESS length] <= 0) {
//		[emailkey addObject:[NSString stringWithFormat:@"HOMEEMAILADDRESS"]];
//		[emailLabel addObject:[NSString stringWithFormat:@"이메일"]];
//		[emailController addObject:[NSString stringWithFormat:@"ManagedObjectStringEditor"]];
		[secondkey addObject:[NSString stringWithFormat:@"HOMEEMAILADDRESS"]];
		[secondLabel addObject:[NSString stringWithFormat:@"이메일"]];
		[secondController addObject:[NSString stringWithFormat:@"ManagedObjectStringEditor"]];
	}
	 */
	
	[secondkey addObject:[NSString stringWithFormat:@"orgname"]];
	[secondLabel addObject:[NSString stringWithFormat:@"소속"]];
	[secondController addObject:[NSString stringWithFormat:@"ManagedObjectStringEditor"]];
	
	[secondkey addObject:[NSString stringWithFormat:@"nickname"]];
	[secondLabel addObject:[NSString stringWithFormat:@"별명"]];
	DebugLog(@"수정 별명 있다.");
	[secondController addObject:[NSString stringWithFormat:@"ManagedObjectStringEditor"]];
	
	
	[secondkey addObject:[NSString stringWithFormat:@"url1"]];
	[secondLabel addObject:[NSString stringWithFormat:@"홈페이지"]];
	[secondController addObject:[NSString stringWithFormat:@"ManagedObjectStringEditor"]];
	
	[secondkey addObject:[NSString stringWithFormat:@"note"]];
	[secondLabel addObject:[NSString stringWithFormat:@"메모"]];
	[secondController addObject:[NSString stringWithFormat:@"ManagedObjectStringEditor"]];
	
	
	/*
	if(personInfo.ORGNAME != nil && [personInfo.ORGNAME length] > 0){
		[secondkey addObject:[NSString stringWithFormat:@"orgname"]];
		[secondLabel addObject:[NSString stringWithFormat:@"소속"]];
		[secondController addObject:[NSString stringWithFormat:@"ManagedObjectStringEditor"]];
	}
	if(personInfo.NICKNAME != nil && [personInfo.NICKNAME length] > 0){
		[secondkey addObject:[NSString stringWithFormat:@"nickname"]];
		[secondLabel addObject:[NSString stringWithFormat:@"별명"]];
		[secondController addObject:[NSString stringWithFormat:@"ManagedObjectStringEditor"]];
	}
	if(personInfo.URL1 != nil && [personInfo.URL1 length] > 0){
		[secondkey addObject:[NSString stringWithFormat:@"url1"]];
		[secondLabel addObject:[NSString stringWithFormat:@"홈페이지"]];
		[secondController addObject:[NSString stringWithFormat:@"ManagedObjectStringEditor"]];
	}
	
	if(personInfo.NOTE != nil && [personInfo.NOTE length] > 0) {
		[secondkey addObject:[NSString stringWithFormat:@"note"]];
		[secondLabel addObject:[NSString stringWithFormat:@"메모"]];
		[secondController addObject:[NSString stringWithFormat:@"ManagedObjectStringEditor"]];
	}
	
	*/
	if(sectionNames != nil)
		[sectionNames release];
	sectionNames = [[NSArray alloc] initWithObjects: [NSNull null], [NSNull null], [NSNull null], nil];
	if(rowLabels != nil)
		[rowLabels release];
    rowLabels = [[NSArray alloc] initWithObjects:
                 // Section 1
                 [NSArray arrayWithObjects:@"이름", nil],
				 // Section 2
                 [NSArray arrayWithObjects:@"그룹", nil],
                 // Section 3
				 secondLabel,
//				 mobileLabel,
//              //   [NSArray arrayWithObjects:@"핸드폰", nil],
//				 // Section 4
//                 [NSArray arrayWithObjects:@"집전화", nil],
//				 // Section 5
//                 [NSArray arrayWithObjects:@"직장전화", nil],
//				 // Section 6
//				 emailLabel,
//            //     [NSArray arrayWithObjects:@"이메일", nil],
//				 //section 7
//				 [NSArray arrayWithObjects:@"소속", nil],
//				 //section 8
//				 [NSArray arrayWithObjects:@"별명", nil],
//				 //section 9
//				 [NSArray arrayWithObjects:@"홈페이지", nil],
//				 //section 10
//				 [NSArray arrayWithObjects:@"메모", nil],
                 // Sentinel
                 nil];
	if(rowKeys != nil)
		[rowKeys release];
    rowKeys = [[NSArray alloc] initWithObjects:
			   // Section 1
			   [NSArray arrayWithObjects:@"formatted", nil],
			   // Section 2
			   [NSArray arrayWithObjects:@"group", nil],
			   // Section 3
			   secondkey,
//			   mobilekey,
//		//	   [NSArray arrayWithObjects:@"phoneNumber", nil],
//			   // Section 4
//			   [NSArray arrayWithObjects:@"homePhoneNumber", nil],
//			   // Section 5
//			   [NSArray arrayWithObjects:@"orgPhoneNumber", nil],
//			   // Section 6
//			   emailkey,
//	//		   [NSArray arrayWithObjects:@"Email", nil],
//			   //section 7
//			   [NSArray arrayWithObjects:@"orgname", nil],
//			   //section 8
//			   [NSArray arrayWithObjects:@"nickname", nil],
//			   //section 9
//			   [NSArray arrayWithObjects:@"url1", nil],
//			   //section 10
//			   [NSArray arrayWithObjects:@"note", nil],			   
			   // Sentinel
               nil];
    if(rowControllers != nil)
		[rowControllers release];
	rowControllers = [[NSArray alloc] initWithObjects:
                      // Section 1
                      [NSArray arrayWithObject:@"ManagedObjectStringEditor"],
					  // Section 2
                      [NSArray arrayWithObject:@"ManagedObjectSingleSelectionListEditor"],
					  // Section 3
					  secondController,
                //      [NSArray arrayWithObject:@"ManagedObjectStringEditor"],
					  // Section 4
//                      [NSArray arrayWithObject:@"ManagedObjectStringEditor"],
//					  // Section 5
//                      [NSArray arrayWithObject:@"ManagedObjectStringEditor"],
					  // Section 6
//					  emailController,
               //       [NSArray arrayWithObject:@"ManagedObjectStringEditor"],
					  // Section 7
//                      [NSArray arrayWithObject:@"ManagedObjectStringEditor"],
//					  // Section 8
//                      [NSArray arrayWithObject:@"ManagedObjectStringEditor"],
//					  // Section 9
//                      [NSArray arrayWithObject:@"ManagedObjectStringEditor"],
//					  // Section 10
//                      [NSArray arrayWithObject:@"ManagedObjectStringEditor"],
					  // Sentinel
                      nil];
	if(rowArguments != nil)
		[rowArguments release];
    rowArguments = [[NSArray alloc] initWithObjects:
                    // Section 1
                    [NSNull null],
					// Section 2
					[NSArray arrayWithObjects:
					 [NSDictionary dictionaryWithObject:groupList forKey:@"list"], nil],
					//section 3
					[NSNull null],
	//				//section 4
//					[NSNull null],
//					//section 5
//					[NSNull null],
//					//section 6
//					[NSNull null],
//					//section 7
//					[NSNull null],
//					//section 8
//					[NSNull null],
//					//section 9
//					[NSNull null],
//					//section 10
//					[NSNull null],
                    // Sentinel
                    nil];
	
	[self addCustomFooterView];
	self.tableView.editing = YES;
    self.tableView.allowsSelectionDuringEditing = YES;
	
}

-(void)addCustomFooterView {
	
	
	DebugLog(@"addCUSTOM");
	
	if(isEdit){
		UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(5.0, 0.0, self.tableView.frame.size.width-10, 60.0)];
		customView.backgroundColor = [UIColor clearColor];
		
		UIImage *btnImageNormal = [[UIImage imageNamed:@"btn_addressbook_del.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
		UIImage *btnImageFocus = [[UIImage imageNamed:@"btn_addressbook_del_focus.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
		
		//create the button
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	//	[button setBackgroundImage:image forState:UIControlStateNormal];
		[button setImage:btnImageNormal forState:UIControlStateNormal];
		[button setImage:btnImageFocus forState:UIControlStateSelected];
		//the button should be as big as a table view cell
		[button setFrame:CGRectMake(4.0, 5.0, 302, 38.0)];
		
	//	[button.layer setBorderColor:[UIColor colorWithWhite:0 alpha:0.5].CGColor];
	//	[button.layer setBorderWidth:0.5];
	//	[button.layer setCornerRadius:5.0];
	//	[button setClipsToBounds:YES];
		
		//set title, font size and font color
	//	[button setTitle:@"주소록 삭제" forState:UIControlStateNormal];
	//	[button.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
		[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
		
		//set action of the button
//		if(parentController != nil){
//			[button addTarget:self.parentController action:@selector(deleteBuddyAction) forControlEvents:UIControlEventTouchUpInside];
//		}else {
			[button addTarget:self action:@selector(deleteBuddyAction) forControlEvents:UIControlEventTouchUpInside];
//		}

		//add the button to the view
		[customView addSubview:button];
		self.tableView.tableFooterView = customView;
		[customView release];
		
		
		
		if(modifyLabel==NULL)
		{
		modifyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		[modifyLabel setFont:[UIFont boldSystemFontOfSize:13.0]];
		[modifyLabel setBackgroundColor:[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.5f]];
		[modifyLabel setTextColor:[UIColor whiteColor]];
		modifyLabel.textAlignment = UITextAlignmentCenter;
		modifyLabel.text = @"사진변경";
		[photoImageView addSubview:modifyLabel];
		[modifyLabel setFrame:CGRectMake(0.0f, mainPhotoView.frame.size.height - 23.0f, mainPhotoView.frame.size.width, 23.0f)];
	//	[modifyLabel release];
		}
		//[tableHeaderView addSubview:mainPhotoView];
		//[mainPhotoView release];
		
		
		
	}else {
		
		if(modifyLabel)
		{
			[modifyLabel removeFromSuperview];
			[modifyLabel release];
			modifyLabel = nil;
		}
		
		
		// 문자 대화 버튼 추가
		UIView* customFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 60.0)];
		customFooterView.backgroundColor = [UIColor clearColor];
		
		UIImageView* buttonBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile_smstalk_normal.png"]];
		buttonBg.frame = CGRectMake((customFooterView.frame.size.width - buttonBg.frame.size.width)/2, 10.0, 302.0, 38.0);
		[customFooterView addSubview:buttonBg];
		[buttonBg release];
		
		
		UIImage *btnSayImageNormal = [[UIImage imageNamed:@"btn_profile_talk.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
		UIImage *btnSayImageFocus = [[UIImage imageNamed:@"btn_profile_talk_touch.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
		UIImage *btnSayImageDisable = [[UIImage imageNamed:@"btn_profile_talk_dim.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
		
		
		UIImage *btnSMSImageNormal = [[UIImage imageNamed:@"btn_profile_sms.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
		UIImage *btnSMSImageFocus = [[UIImage imageNamed:@"btn_profile_sms_touch.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
		UIImage *btnSMSImageDisable = [[UIImage imageNamed:@"btn_profile_sms_dim.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
		
		
		
		//create the button
		UIButton *sayButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[sayButton setImage:btnSayImageNormal forState:UIControlStateNormal];
		[sayButton setImage:btnSayImageFocus forState:UIControlStateHighlighted];
		[sayButton setImage:btnSayImageDisable forState:UIControlStateDisabled];
		
		
		
		[sayButton setFrame:
		 CGRectMake(customFooterView.frame.size.width/2 - btnSayImageFocus.size.width , 10.0, 
					btnSayImageFocus.size.width, btnSayImageFocus.size.height)];
		[sayButton.layer setBorderColor:[UIColor colorWithWhite:0 alpha:0.5].CGColor];
		[sayButton.layer setBorderWidth:0.5];
		[sayButton.layer setCornerRadius:5.0];
		[sayButton setClipsToBounds:YES];	
		[sayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		sayButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		sayButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
		//set action of the button
		[sayButton addTarget:self action:@selector(addressSayButtonClicked) forControlEvents:UIControlEventTouchUpInside];
		//add the button to the view
		[customFooterView addSubview:sayButton];
		
		UIButton *smsbutton = [UIButton buttonWithType:UIButtonTypeCustom];
		[smsbutton setImage:btnSMSImageNormal forState:UIControlStateNormal];
		[smsbutton setImage:btnSMSImageFocus forState:UIControlStateHighlighted];
		[smsbutton setImage:btnSMSImageDisable forState:UIControlStateDisabled];
		
		[smsbutton setFrame:
		 CGRectMake(customFooterView.frame.size.width/2, 10.0, 
					btnSMSImageFocus.size.width, btnSMSImageFocus.size.height)];
		[smsbutton.layer setBorderColor:[UIColor colorWithWhite:0 alpha:0.5].CGColor];
		[smsbutton.layer setBorderWidth:0.5];
		[smsbutton.layer setCornerRadius:5.0];
		[smsbutton setClipsToBounds:YES];	
		[smsbutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		smsbutton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		smsbutton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
		//set action of the button
		[smsbutton addTarget:self action:@selector(addressSMSButtonClicked) forControlEvents:UIControlEventTouchUpInside];
		//add the button to the view
		[customFooterView addSubview:smsbutton];
		self.tableView.tableFooterView = customFooterView;

		
		
		
	//NSLog(@"Disable aaaaa %d", [personInfo.MOBILEPHONENUMBER length]);
				
		 /*
		 if(personInfo.MOBILEPHONENUMBER == nil || [personInfo.MOBILEPHONENUMBER length] <= 0)
		 {
			 
	//		 NSLog(@"Disable aaaaa %@ %@", personInfo.MOBILEPHONENUMBER);
			 [smsbutton setEnabled:NO];
		 }
		  */
		
	//	NSLog(@"Disable  a=%@ b=%@ c=%@", personInfo.MOBILEPHONENUMBER, personInfo.HOMEPHONENUMBER, personInfo.ORGPHONENUMBER);
		
		
		if(personInfo.MOBILEPHONENUMBER == nil || [personInfo.MOBILEPHONENUMBER length]<0)
			personInfo.MOBILEPHONENUMBER = NULL;
		if(personInfo.HOMEPHONENUMBER == nil || [personInfo.HOMEPHONENUMBER length]<0)
			personInfo.HOMEPHONENUMBER =NULL;
		if(personInfo.IPHONENUMBER == nil || [personInfo.IPHONENUMBER length]<0)
			personInfo.IPHONENUMBER =NULL;
		if(personInfo.ORGPHONENUMBER == nil || [personInfo.ORGPHONENUMBER length]<0)
			personInfo.ORGPHONENUMBER = NULL;
		
		
		NSLog(@"a b c %@ %@ %@", personInfo.MOBILEPHONENUMBER, personInfo.IPHONENUMBER, personInfo.HOMEPHONENUMBER);
		
		if(personInfo.MOBILEPHONENUMBER == NULL && personInfo.IPHONENUMBER == NULL && personInfo.HOMEPHONENUMBER == NULL)
		{
			NSLog(@"문자 비활성..");
			[smsbutton setEnabled:NO];
		}
		else {
			[smsbutton setEnabled:YES];
		}

		// sochae 2010.10.01
		//if(personInfo.RPKEY == nil && [personInfo.RPKEY length] <= 0)
		
		
		
		if(!(personInfo.ISFRIEND && ([personInfo.ISFRIEND isEqualToString:@"S"] || [personInfo.ISFRIEND isEqualToString:@"A"] )))
		// ~sochae
		{
			[sayButton setEnabled:NO];
		}
		
		
		[customFooterView release];
		
	}
	
}

#pragma mark -
#pragma mark say/sms button event Method
-(void)addressSayButtonClicked {
	NSString* rPKey = nil;
	if (personInfo.RPKEY != nil && [personInfo.RPKEY length] > 0)
	{
		rPKey = [NSString stringWithFormat:@"%@",personInfo.RPKEY];
	
		NSString* sayBuddyrpKey = [NSString stringWithFormat:@"%@",rPKey];		
		NSMutableArray *selectUserPKeyArray = [NSMutableArray arrayWithObjects:sayBuddyrpKey, nil];
		if (selectUserPKeyArray && [selectUserPKeyArray count] > 0) {
			NSString *chatSession = [[self appDelegate] chatSessionFrompKey:selectUserPKeyArray];
			if (chatSession && [chatSession length] > 0) {
				// 채팅 대기실에 선택한 Users의 대화방 존재
				CellMsgListData *msgListData = [[self appDelegate] MsgListDataFromChatSession:chatSession];
//				assert(msgListData != nil);
				@synchronized([self appDelegate].msgArray)
				{
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
				
				NSString *title = nil;
				@synchronized([self appDelegate].msgListArray)
				{
					if ([self appDelegate].msgListArray && [[self appDelegate].msgListArray count] > 0) {
						for (CellMsgListData *msgListData in [self appDelegate].msgListArray) {
							if ([msgListData.chatsession isEqualToString:chatSession]) {
								if (msgListData.userDataDic && [msgListData.userDataDic count] > 0) {
									if ([msgListData.userDataDic count] == 1) {
										for (id key in msgListData.userDataDic) {
											MsgUserData *userData = (MsgUserData*)[msgListData.userDataDic objectForKey:key];
											if (userData) {
												title = userData.nickName;
												break;
											} else {
												// error
												title = @"이름 없음";
												break;
											}
										}
									} else if ([msgListData.userDataDic count] > 1) {
										title = [NSString stringWithFormat:@"그룹채팅 (%i명)", [msgListData.userDataDic count] + 1];
									} else {
										title = @"이름 없음";
									}
								}
							}
						}
					}
				}
				
				SayViewController *sayViewController = [[SayViewController alloc] initWithNibNameBuddyListMsgType:@"SayViewController" chatSession:chatSession type:msgListData.cType BuddyList:nil bundle:nil];
				if(sayViewController != nil)
				{
					//				sayViewController.title = title;
					
					UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
//					assert(titleView != nil);
					UIFont *titleFont = [UIFont systemFontOfSize:20];

					// sochae 2010.09.11 - UI Position
					//CGRect rect = [MyDeviceClass deviceOrientation];
					CGRect rect = self.view.frame; 
					// ~sochae
					if (title == nil)
						title = @"";
					CGSize titleStringSize = [title sizeWithFont:titleFont constrainedToSize:(CGSizeMake(rect.size.width-120.0, MAXFLOAT))]; //mezzo title
//					assert(titleFont != nil);
					UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, 20.0f)];
//					assert(titleLabel != nil);
					[titleLabel setFont:titleFont];
					titleLabel.textAlignment = UITextAlignmentCenter;
					[titleLabel setTextColor:ColorFromRGB(0x053844)];
					[titleLabel setBackgroundColor:[UIColor clearColor]];
					[titleLabel setText:title];
					//				titleLabel.shadowColor = [UIColor whiteColor];
					[titleView addSubview:titleLabel];	
					[titleLabel release];
					sayViewController.navigationItem.titleView = titleView;
					[titleView release];
					sayViewController.navigationItem.titleView.frame = CGRectMake((self.tableView.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, 20.0f);				
					
					
					sayViewController.hidesBottomBarWhenPushed = YES;
					UINavigationController* naviController = nil;
					if(self.parentController != nil){
						naviController = self.parentController.navigationController;
					}else {
						naviController = self.navigationController;
					}

					[naviController popToRootViewControllerAnimated:NO];
					
					[naviController pushViewController:sayViewController animated:YES];
					[sayViewController release];
				}
			} else {
				// 현재 대화방리스트에 존재 하지 않음.
				// 새로 대화방 생성해야함.
				UINavigationController* naviController = nil;
				if(self.parentController != nil){
					naviController = self.parentController.navigationController;
				}else {
					naviController = self.navigationController;
				}

				SayViewController *sayViewController = [[SayViewController alloc] initWithNibNameBuddyListMsgType:@"SayViewController" chatSession:nil type:nil BuddyList:selectUserPKeyArray bundle:nil];
				if(sayViewController != nil) {
					NSString *sayTitle = nil;
					if (personInfo.FORMATTED && [personInfo.FORMATTED length] > 0) { //for
						sayTitle = personInfo.FORMATTED;
					} else if (personInfo.NICKNAME && [personInfo.NICKNAME length] > 0) {
						sayTitle = personInfo.NICKNAME;
					}
					else if (personInfo.PROFILENICKNAME && [personInfo.PROFILENICKNAME length] > 0) {
						sayTitle = personInfo.PROFILENICKNAME;
					} else {
						sayTitle = @"이름 없음";
					}
					UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
//					assert(titleView != nil);
					UIFont *titleFont = [UIFont systemFontOfSize:20];

					// sochae 2010.09.11 - UI Position
					//CGRect rect = [MyDeviceClass deviceOrientation];
					CGRect rect = self.view.frame;
					// ~sochae
					
					CGSize titleStringSize = [sayTitle sizeWithFont:titleFont constrainedToSize:(CGSizeMake(rect.size.width-120.0, MAXFLOAT))];
//					assert(titleFont != nil);
					UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, 20.0f)];
//					assert(titleLabel != nil);
					[titleLabel setFont:titleFont];
					titleLabel.textAlignment = UITextAlignmentCenter;
					[titleLabel setTextColor:ColorFromRGB(0x053844)];
					[titleLabel setBackgroundColor:[UIColor clearColor]];
					[titleLabel setText:sayTitle];
					//				titleLabel.shadowColor = [UIColor whiteColor];
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
	}else {
		UIAlertView* sayAlert = [[UIAlertView alloc] initWithTitle:@"대화 하기" 
							message:@"Usay친구와만 대화를 하실 수 있습니다." delegate:nil 
												 cancelButtonTitle:@"확인" otherButtonTitles:nil];
		[sayAlert show];
		[sayAlert release];
	}

}

// 주소록 친구 > 주소록 정보 > [SMS 보내기] 버튼 선택 시
-(void)addressSMSButtonClicked
{
	DebugLog(@"===== addressSMSButtonClicked CALLED. =====");
	// 휴대폰 번호로만 sms 전송. mobilephonenumber/iphonenumber 만 사용.
	NSString* phoneNumber = nil;

	//휴대폰, 집전화, 회사전화로 바꿈
	if (personInfo.MOBILEPHONENUMBER != nil && [personInfo.MOBILEPHONENUMBER length] > 0) {
		phoneNumber = [NSString stringWithFormat:@"%@", personInfo.MOBILEPHONENUMBER];
	} else if(personInfo.IPHONENUMBER && [personInfo.IPHONENUMBER length] > 0) {
		phoneNumber = [NSString stringWithFormat:@"%@",personInfo.IPHONENUMBER];
	} else if (personInfo.HOMEPHONENUMBER && [personInfo.HOMEPHONENUMBER length] > 0) {
		phoneNumber = [NSString stringWithFormat:@"%@",personInfo.HOMEPHONENUMBER];	
	} else if (personInfo.ORGPHONENUMBER && [personInfo.ORGPHONENUMBER length] >0) {
		phoneNumber = [NSString stringWithFormat:@"%@",personInfo.ORGPHONENUMBER];	
	}

	if (phoneNumber != nil && [phoneNumber length] > 0)
	{
		BOOL bSMSSend = YES;

		if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 4.0)
		{
			Class smsClass = (NSClassFromString(@"MFMessageComposeViewController"));
			if (smsClass != nil && [MFMessageComposeViewController canSendText])
			{
				MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
				controller.body = nil;
				controller.recipients = [NSArray arrayWithObject:phoneNumber];	// your recipient number or self for testing

				if(self.parentController != nil)
				{
					controller.messageComposeDelegate = self.parentController;
					[self.parentController.navigationController presentModalViewController:controller animated:YES];
				}
				else
				{
					controller.messageComposeDelegate = self;
					[self.navigationController presentModalViewController:controller animated:YES];
				}
				[controller release];              
			}
			else
			{
				bSMSSend = NO;
			}
		}
		else
		{
			NSString* telno = [[NSString stringWithFormat:@"sms:%@",phoneNumber]
							   stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			//		NSString* telno = [[NSString stringWithString:@"sms:010-3231-0142"] 
			//						   stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			bSMSSend = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telno]];
/*			BOOL open = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telno]];
			if(open == NO){
				UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"SMS 보내기" 
																   message:@"전화 기능을 사용 하실 수 없는 \n기기 입니다." 
																  delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
			//	NSLog(@"aaaa");
				[alertView show];
				[alertView release];
			}
*/		}

		if (bSMSSend == NO)	// SMS 보내기 실패한 경우 alert 보이기.
		{
			[JYUtil alertWithType:ALERT_SMS_ERROR delegate:nil];
		}
	} // phoneNumber	
}

#pragma mark -
#pragma mark MFMessageUI delegate Method
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

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
	//	message.hidden = NO;
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			//			message.text = @"Result: canceled";
			break;
		case MFMailComposeResultSaved:
			//			message.text = @"Result: saved";
			break;
		case MFMailComposeResultSent:
			//			message.text = @"Result: sent";
			break;
		case MFMailComposeResultFailed:
			//			message.text = @"Result: failed";
			break;
		default:
			//			message.text = @"Result: not sent";
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
}
#pragma mark -
#pragma mark deltailView data update delegate Method

-(void)updateDataValue:(NSString*)value forkey:(NSString*)key{
	NSIndexPath* indexPath = [rowKeys indexOfNestedObjectForkey:key];
	UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
	
	if([key isEqualToString:@"formatted"]){ //format
		cell.textLabel.textColor = [UIColor blackColor];
		cell.textLabel.text = value;
		personInfo.FORMATTED = value; //format
	}else{
		UILabel* detailLabel = (UILabel*)[cell.contentView viewWithTag:kDetailtitleLabel];
		
		if([key isEqualToString:@"MOBILEPHONENUMBER"]){
			detailLabel.text = value;
			personInfo.MOBILEPHONENUMBER = value;
		}else if([key isEqualToString:@"IPHONENUMBER"]){
			detailLabel.text = value;
			personInfo.IPHONENUMBER = value;
		}else if([key isEqualToString:@"homePhoneNumber"]){
			detailLabel.text = value;
			personInfo.HOMEPHONENUMBER = value;
		}else if([key isEqualToString:@"orgPhoneNumber"]){
			detailLabel.text = value;
			personInfo.ORGPHONENUMBER = value;
		}else if([key isEqualToString:@"HOMEEMAILADDRESS"]){
			detailLabel.text = value;
			personInfo.HOMEEMAILADDRESS = value;
		}else if([key isEqualToString:@"ORGEMAILADDRESS"]){
			detailLabel.text = value;
			personInfo.ORGEMAILADDRESS = value;
		}else if([key isEqualToString:@"orgname"]){
			detailLabel.text = value;
			personInfo.ORGNAME = value;
		}else if([key isEqualToString:@"nickname"]){
			detailLabel.text = value;
			personInfo.NICKNAME = value;
		}else if([key isEqualToString:@"url1"]){
			detailLabel.text = value;
			personInfo.URL1 = value;
		}else if([key isEqualToString:@"note"]){
			detailLabel.text = value;
			personInfo.NOTE = value;
		}else if([key isEqualToString:@"group"]) {
			detailLabel.text = value;
			NSArray* groupArray = [GroupInfo findByColumn:@"GROUPTITLE" value:value];
			GroupInfo* nameForGroup = [groupArray objectAtIndex:0];
			personInfo.GID = nameForGroup.ID;
		}
	}

	if(isEdit)
		[self editInterFaceConfig];
NSLog(@"업데이트 밸류....");	
[self.tableView reloadData];
}

-(void)updateDataWithArray:(NSArray*)value forkey:(NSString*)key {
	//배열 정보로 넘어오면 안된다.
}
#pragma mark -
#pragma mark image Method
-(void)imageSelect {
//	NSLog(@"imageSelect");
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

#pragma mark -
#pragma mark navigationController 
	// sochae 2010.09.17 - 사진 앨범 NavigationController 수정. 

/* sochae 2010.12.29 - cLang
-(void)sendMail
{
	MFMailComposeViewController *tmpMail = (MFMailComposeViewController*)self.modalViewController;
	if(tmpMail == NULL)
	{
		tmpMail =(MFMailComposeViewController*)parentController.modalViewController;
	}
}
*/

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
	
	
	
	
	if([tmpTitle isEqualToString:@"새로운 메세지"])
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
		titleView.text = @"새로운 메시지";
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
// ~sochae

#pragma mark UIActionSheet delegate Method
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
	{
		//카메라 사용 못함.
		if (buttonIndex == 0) {	// album 사진
			if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
			{
				UIImagePickerController *picker = [[UIImagePickerController alloc] init];
				picker.delegate = self;
				picker.allowsEditing = YES;
				picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
				picker.mediaTypes = [NSArray arrayWithObjects:@"public.image", nil];
				if(self.parentController != nil){
					[self.parentController presentModalViewController:picker animated:YES];
				}else {
					[self presentModalViewController:picker animated:YES];
				}
				picker.navigationItem.title=@" ";
				[picker release];
			}
		}
	}else {
		if (buttonIndex == 0) {			// 사진 
			photoLibraryShown = YES;
			UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//			assert(picker != nil);
			picker.delegate = self;
			picker.allowsEditing = YES;
			picker.sourceType = UIImagePickerControllerSourceTypeCamera;
			picker.mediaTypes = [NSArray arrayWithObjects:@"public.image", nil];
			if(self.parentController != nil){
				[self.parentController presentModalViewController:picker animated:YES];
			}else {
				[self presentModalViewController:picker animated:YES];
			}
			
			[picker release];
		}else if(buttonIndex == 1) { //album 사진
			photoLibraryShown = YES;
			if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
				UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//				assert(picker != nil);
				picker.delegate = self;
				picker.allowsEditing = YES;
				picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
				picker.mediaTypes = [NSArray arrayWithObjects:@"public.image", nil];
				if(self.parentController != nil){
					[self.parentController presentModalViewController:picker animated:YES];
				}else {
					[self presentModalViewController:picker animated:YES];
				}
				
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
            [NSException raise:NSInternalInconsistencyException format:@"buddyperson Invalid image orientation"];
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
			UIImage *resizeImage = [self resizeImage:image scaleFlag:YES];
			if (!resizeImage) {
				[picker dismissModalViewControllerAnimated:TRUE];
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"이미지파일 오류" message:@"잘못된 이미지 파일입니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
				[alertView show];
				[alertView release];
				return;
			}
			NSLog(@"resizeImg %@", resizeImage);
		//	[photoImageView setBackgroundImage:[self thumbNailImage:resizeImage Size:64.0f] forState:UIControlStateNormal];
			[photoImageView setImage:[self thumbNailImage:resizeImage Size:64.0f] forState:UIControlStateNormal];
			
			self.addUserImage = resizeImage;
			personInfo.USERIMAGE =  UIImageJPEGRepresentation(self.addUserImage, 1.0f);
			
			
		} else {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"이미지파일 오류" message:@"잘못된 이미지 파일입니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
			[alertView show];
			[alertView release];
		}
	}
	//[self.tableView reloadData];
	[picker dismissModalViewControllerAnimated:YES];
}





- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[picker dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark navigation button event Method
-(void)updateBuddyCompleted {
	isEdit = !isEdit;
	if(isEdit){
		compareInfo = [[UserInfo alloc] init];
		[self copyUserInfo];
		
		UIImage* completeBarBtnImg = [[UIImage imageNamed:@"btn_top_complete.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
		UIImage* completeBarBtnSelImg = [[UIImage imageNamed:@"btn_top_complete_focus.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
		UIButton* completeBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[completeBarButton addTarget:self action:@selector(updateBuddyCompleted) forControlEvents:UIControlEventTouchUpInside];
		[completeBarButton setImage:completeBarBtnImg forState:UIControlStateNormal];
		[completeBarButton setImage:completeBarBtnSelImg forState:UIControlStateSelected];
		completeBarButton.frame = CGRectMake(0.0, 0.0, completeBarBtnImg.size.width, completeBarBtnImg.size.height);
		UIBarButtonItem *completeButton = [[UIBarButtonItem alloc] initWithCustomView:completeBarButton];
		if(parentController != nil){
			parentController.navigationItem.rightBarButtonItem = completeButton;
		}else {
			self.navigationItem.rightBarButtonItem = completeButton;
		}

		[completeButton release];
		[self editInterFaceConfig];
		NSLog(@"업데이트 버디 리로드..");
		[self.tableView reloadData];
		
	}else {
		DebugLog(@"완료 버튼 누를때");

		BOOL fieldCheckOk = YES;
		if([self existChangeValue]){
		
			DebugLog(@"데이터 변경 있으면");
			
			
			
			
			
			//오프라인 시 못하게..
			[[self appDelegate] checkoffline];
			
			
			//오프라인, 로그인 상태, 주소록 싱크 상태 체크
			if([self appDelegate].connectionType == -1){
				UIAlertView* offlineAlert = [[UIAlertView alloc] initWithTitle:@"오프라인"
																	   message:@"현재 네트워크 연결이 불가능한 상태 입니다.\nUsay의 모든 기능을 이용하기 위해서는 네트워크 연결이 필요합니다." 
																	  delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
				[offlineAlert show];
				[offlineAlert release];
				return;
				
			}//로그인 중인지 점검
			else if(LOGINEND != YES)
			{
				UIAlertView* offlineAlert = [[UIAlertView alloc] initWithTitle:@""
																	   message:@"로그인 중입니다 잠시만 기다려 주세요" 
																	  delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
				[offlineAlert show];
				[offlineAlert release];
				return;
			} //로그인이 노티가 왔지만 실패를 했고 또 다시 로그인을 시도 하지 않았을 경우
			else if(LOGINSUCESS != YES && LOGINSTART != YES)
			{
				UIAlertView* offlineAlert = [[UIAlertView alloc] initWithTitle:@"로그인 실패"
																	   message:@"재로그인 하시겠습니까?" 
																	  delegate:nil cancelButtonTitle:@"취소" otherButtonTitles:@"확인", nil];
				
				offlineAlert.delegate =self;
				[offlineAlert show];
				[offlineAlert release];
				
				return;
				
			}//동기화 중인지 점검
			else if(CHKOFF == YES)
			{
				UIAlertView* offlineAlert = [[UIAlertView alloc] initWithTitle:@""
																	   message:@"동기화 중에는 사용할 수 없습니다 잠시후에 이용해 주세요" 
																	  delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
				[offlineAlert show];
				[offlineAlert release];
				return;
			}
			
			
			
			
			
			NSString* revisionPoint = [[NSUserDefaults standardUserDefaults] objectForKey:@"RevisionPoints"];
			NSDictionary *bodyObject2 = [NSDictionary dictionaryWithObjectsAndKeys:
										 [[self appDelegate] getSvcIdx],@"svcidx",
										 (revisionPoint == nil) ? @"0" : revisionPoint, @"RP",
										 nil];
			USayHttpData *data2 = [[[USayHttpData alloc]initWithRequestData:@"getLastAfterRP" andWithDictionary:bodyObject2 timeout:10] autorelease];	
			//	assert(data != nil);		
			[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data2];
			//변경된 값을 서버로 전송.
			fieldCheckOk = [self requestUpdateContact];
		
		}
		if(fieldCheckOk == YES){
			//버튼 설정
			DebugLog(@"field check ok");
			[compareInfo release];
			UIImage* editBarBtnImg = [[UIImage imageNamed:@"btn_top_edit.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
			UIImage* editBarBtnSelImg = [[UIImage imageNamed:@"btn_top_edit_focus.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
			UIButton* editBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
			[editBarButton addTarget:self action:@selector(updateBuddyCompleted) forControlEvents:UIControlEventTouchUpInside];
			[editBarButton setImage:editBarBtnImg forState:UIControlStateNormal];
			[editBarButton setImage:editBarBtnSelImg forState:UIControlStateSelected];
			editBarButton.frame = CGRectMake(0.0, 0.0, editBarBtnImg.size.width, editBarBtnImg.size.height);
			UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithCustomView:editBarButton];
			if(parentController != nil){
				parentController.navigationItem.rightBarButtonItem = editButton;
			}else {
				self.navigationItem.rightBarButtonItem = editButton;
			}

			[editButton release];
			[self normalInterFaceConfig]; //데이터를 다시 입력받는다..
			[self.tableView reloadData]; //테이블 리로드..
		}else {
			
			isEdit = YES;
		}

	}	
}

-(void) copyUserInfo{
	NSAutoreleasePool* varpool = [[NSAutoreleasePool alloc] init];
	unsigned int numIvars = 0;
	Ivar* ivars = class_copyIvarList([personInfo class], &numIvars);
	for(int i = 0; i < numIvars; i++) {
		Ivar thisIvar = ivars[i];
		NSString * key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
		[compareInfo setValue:[personInfo valueForKey:key] forKey:key];
	}
	if(numIvars > 0)free(ivars);
	[varpool release];
	
}
-(BOOL) existChangeValue {
	NSAutoreleasePool* varpool = [[NSAutoreleasePool alloc] init];
	unsigned int numIvars = 0;
	Ivar* ivars = class_copyIvarList([compareInfo class], &numIvars);
	for(int i = 0; i < numIvars; i++) {
		Ivar thisIvar = ivars[i];
		NSString * key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
		NSString * type = [NSString stringWithUTF8String:ivar_getTypeEncoding(thisIvar)];
		NSString * class = nil;
		if ([type length] > 3) {
			class = [type substringWithRange:NSMakeRange(2, [type length]-3)];
		}
		Class typeClass = NSClassFromString(class);
		if([personInfo valueForKey:key]){
			if([typeClass isEqual:[NSString class]]){
				if(![[compareInfo valueForKey:key] isEqualToString:[personInfo valueForKey:key]]){
					if(numIvars > 0)free(ivars);
					[varpool release];
					return YES;
				}
			}else if([typeClass isEqual:[NSData class]]){
				if(![[compareInfo valueForKey:key] isEqualToData:[personInfo valueForKey:key]]){
					if(numIvars > 0)free(ivars);
					[varpool release];
					return YES;
				}
			}else if([typeClass isEqual:[NSNumber class]]){	
				if(![[compareInfo valueForKey:key] isEqualToNumber:[personInfo valueForKey:key]]){
					if(numIvars > 0)free(ivars);
					[varpool release];
					return YES;
				}
			}
		}
	}
	if(numIvars > 0)free(ivars);
	[varpool release];
	return NO;
	
}

-(void)backBarButtonClicked {
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)deleteBuddyAction {
#if TARGET_IPHONE_SIMULATOR
	NSLog(@"주소록 삭제");
#endif
	UIAlertView* deleteAlert = [[UIAlertView alloc] initWithTitle:@"주소록 삭제" 
								message:@"주소록 정보에서 삭제 됩니다.\n삭제 하시겠습니까?" 
								delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"확인", nil];
	
	[deleteAlert show];
	[deleteAlert release];
}

#pragma mark -
#pragma mark Memory management
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
//	isMemoryWarning = YES;
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}
-(void)viewDidUnload{
	[super viewDidUnload];
}

- (void)dealloc {
	if(parentController != nil)
		[parentController release];
    [sectionNames release];
    [rowLabels release];
    [rowKeys release];
    [rowControllers release];
	[rowArguments release];
	[photoImageView release];
	[mainPhotoView release];
	

	
	
	
	
	[buddyPKey release];
	[personInfo release];
	
	
	[modifyLabel release];
	[myLabel release];		// sochae 2010.09.17
    [super dealloc];
}

#pragma mark -
#pragma mark Table View Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [sectionNames count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [rowLabels countOfNestedArray:section];
}



-(void)imgClick
{
	
	NSLog(@"imgClick");
	
	
	if(!self.personInfo.THUMBNAILURL)
		return;
	
	openImgViewController *pushView = [[openImgViewController alloc] init];
	NSString *photoUrl = [NSString stringWithFormat:@"%@/008", self.personInfo.THUMBNAILURL];
	UIImageView* representImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
	
	
	NSString *newImgPath = [NSString stringWithFormat:@"%@", [self md5:photoUrl]];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *cachesDirectory =  [NSString stringWithFormat:@"%@/ImageCache",[paths objectAtIndex:0]];
	NSString *imagePath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", newImgPath]];
	NSLog(@"imagePath = %@", imagePath);
	
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath isDirectory:NO]) {
		[representImage setImageWithURL:[NSURL URLWithString:photoUrl]
			placeholderImage:self.photoImageView.imageView.image];	  
		 //placeholderImage:[UIImage imageNamed:@"img_default.png"]];
		
		// not exist file
		NSLog(@"imagePath not exist file");
	}
	else {
		NSData *data =[[NSData alloc] initWithContentsOfFile:imagePath];
		[representImage setImage:[UIImage imageWithData:data]];
		//release 2010.12.28
		[data release];
		
		NSLog(@"img ok");
	}
	
	
	if(representImage.image)
	{
		
		NSLog(@"img size = %f %f", representImage.image.size.width, representImage.image.size.height);
		/*
		if(representImage.image.size.width == 41)
			return;
		*/
		[pushView.view addSubview:representImage];
		if(parentController)
		{
			[parentController.navigationController pushViewController:pushView animated:NO];
			[parentController.navigationController.navigationBar setHidden:YES];
		}
		else {
			[self.navigationController pushViewController:pushView animated:NO];
			[self.navigationController.navigationBar setHidden:YES];
		}

		
	}
	//release 2010.12.28
	[representImage release];
	[pushView release];
	
}


- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	
	//20101012 사진변경안될경우 찾아서 수정하자 mezzo
	
	NSString *rowKey = [rowKeys nestedObjectAtIndexPath:indexPath];
	

	/* 사용 안하므로 주석처리
	for(int i=0; i<[rowKeys count]; i++)
	{
	//NSLog(@"rowkey  %d= %@",i, [rowKeys objectAtIndex:i]);
	}*/
	DebugLog(@"rowkey = %@", rowKey);
    NSString *rowLabel = [rowLabels nestedObjectAtIndexPath:indexPath];
	
	static NSString *NameCellIdentifier = @"PersonNameIdentifier";
	static NSString *NormalCellIdentifier = @"buddyPersonIdentifier";
	static NSString *editNameCellIdentifier = @"editPersonNameIdentifier";
	static NSString *editNormalCellIdentifier = @"editBuddyPersonIdentifier";
	
	NSString *cellIdentifier = nil;
	UITableViewCellStyle cellStyle;
	if([rowKey isEqualToString:@"formatted"]){ //
		if(!isEdit){
			cellIdentifier = NameCellIdentifier;
			photoImageView.enabled = NO;
		}else{
			cellIdentifier = editNameCellIdentifier;
			photoImageView.enabled = YES;
		}
		
		
		cellStyle = UITableViewCellStyleSubtitle;
	}else{
		if(!isEdit){
			cellIdentifier = NormalCellIdentifier;
		}else{
			cellIdentifier = editNormalCellIdentifier;
		}
		
		cellStyle = UITableViewCellStyleValue2;
	}
	
	
	DebugLog(@"indexpath = %d", indexPath.row);
	
	UITableViewCell *cell = nil;
	if([rowKey isEqualToString:@"formatted"]){ //formated
		
		DebugLog(@"nick name");
		cell = [theTableView dequeueReusableCellWithIdentifier:cellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:cellStyle reuseIdentifier:cellIdentifier] autorelease];
			//indent the contentView sufficiently
			cell.indentationLevel = 1;
			cell.indentationWidth = 74.0;
			//add the photo to the tableView`s content
			CGRect frame = cell.frame;
			if(isEdit){
				DebugLog(@"여기로 들ㅇ오면 포토이미지");
				photoImageView.frame = CGRectMake(frame.origin.x-1.0, frame.origin.y-1.0, 64.0, 64.0);
				[cell.contentView addSubview:photoImageView];
			}else{
				

				
				mainPhotoView.frame = CGRectMake(frame.origin.x-1.0, frame.origin.y-1.0, 64.0, 64.0);
				
				DebugLog(@"photo y =%f", mainPhotoView.frame.origin.y);
				DebugLog(@"여기로 들어오면 메인이미지");
				
				
				
				
				[cell.contentView addSubview:mainPhotoView];
				
				
				
				//이미지클릭버튼 추가
				UIButton* hiddenImgButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64.0f, 64.0f)] autorelease];
				hiddenImgButton.contentMode = UIViewContentModeScaleAspectFit;
				[hiddenImgButton setBackgroundColor:[UIColor clearColor]];
				hiddenImgButton.layer.masksToBounds = YES;
				hiddenImgButton.layer.cornerRadius = 5.0;
				hiddenImgButton.clipsToBounds = YES;
				//[hiddenImgButton setImage:[UIImage imageNamed:@"img_Addressbook_default.png"] forState:UIControlStateNormal];
				[hiddenImgButton addTarget:self action:@selector(imgClick) forControlEvents:UIControlEventTouchUpInside];
				hiddenImgButton.alpha=0.1;
				
				[cell.contentView addSubview:hiddenImgButton];
				
				
				
					

			}
			
			

			
			
			
		}
//		[cell.contentView insertSubview:photoImageView atIndex:0];
		cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}else{
		cell = [theTableView dequeueReusableCellWithIdentifier:cellIdentifier];
		DebugLog(@"cell %@", cell);
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:cellStyle reuseIdentifier:cellIdentifier] autorelease];
			CGRect frame = CGRectMake(10, (55.0 - 28.0)/2 , 68.0, 28.0);
			UILabel* titleLabel = [[UILabel alloc] initWithFrame:frame];
			CGRect detailframe = CGRectMake(82.0, (55.0 - 28.0)/2, 160.0, 28.0);
			UILabel* detailTitleLabel = [[UILabel alloc] initWithFrame:detailframe];
			titleLabel.tag = kTitleLabel;
			detailTitleLabel.tag = kDetailtitleLabel;
			[cell.contentView addSubview:titleLabel];
			[cell.contentView addSubview:detailTitleLabel];
			titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
			titleLabel.textAlignment = UITextAlignmentLeft;
			titleLabel.textColor = ColorFromRGB(0x2284ac);
			detailTitleLabel.textColor = ColorFromRGB(0x7c7c86);
			detailTitleLabel.font = [UIFont boldSystemFontOfSize:17.0];
			detailTitleLabel.textAlignment = UITextAlignmentLeft;
			cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
			[titleLabel release];
			[detailTitleLabel release];
		}
    }
	
	if(!isEdit){
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}

	
    if([rowKey isEqualToString:@"formatted"]) { //for
		
		
		//순서 포맷->닉넴->프로파일..
		cell.textLabel.text = self.personInfo.FORMATTED; //for
		
		
		/* sochae - 이름 없으면 그냥 비워 둔다.
		if([cell.textLabel.text length] <=0)
		{
			cell.textLabel.text = self.personInfo.NICKNAME;
		}
		
		NSLog(@"nickname = %@", cell.textLabel.text);
		*/
		
		CGRect frame = cell.textLabel.frame;
		frame.size.height += cell.detailTextLabel.frame.size.height;
		cell.textLabel.frame = frame;
		cell.textLabel.textColor = ColorFromRGB(0x23232a);
		cell.textLabel.adjustsFontSizeToFitWidth = YES;
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		[cell.textLabel setBackgroundColor:[UIColor clearColor]];
		
		if (self.personInfo.THUMBNAILURL && [self.personInfo.THUMBNAILURL length] > 0) {
//			SDWebImageManager *manager = [SDWebImageManager sharedManager];	
			NSString *photoUrl = [NSString stringWithFormat:@"%@/012", self.personInfo.THUMBNAILURL];
			NSLog(@"photoUrl >>> %@", photoUrl);
			
			
			
			
			
			
			
			//수정소스
			/*
			if (photoUrl && [photoUrl length] > 0) {
				
				
				
				UIImageView* representImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
				[representImage setImageWithURL:[NSURL URLWithString:photoUrl] placeholderImage:[UIImage imageNamed:@"img_Addressbook_default.png"]];
				
				//임시 이미지 저장소..
				data3 = [NSData dataWithContentsOfURL:[NSURL URLWithString:photoUrl]];
				
				//수정 모드 일경우...
				if(isEdit){
					if(representImage.image != nil){
						[photoImageView setImage:representImage.image forState:UIControlStateNormal];
					}
					else {
						//기존이미지로 그대로 보여줌..
						DebugLog(@"nil...");
					}
					[representImage release];
				}else {
					//완료 모드 일경우..
					if(representImage.image	!= nil){
						NSLog(@"not nil");
					//	[mainPhotoView setBackgroundImage:representImage.image forState:UIControlStateNormal];
						[mainPhotoView setImage:representImage.image forState:UIControlStateNormal];
						
					
						
					}
					else {
						NSLog(@"nilll...");
					}
					//이미지를 디렉토리에 저장..
					personInfo.USERIMAGE = UIImageJPEGRepresentation(representImage.image, 1.0);
					[representImage release];
					
				}
			}
			
			
			else {
				//웹에서 아무런 이미지를 발견 못하면 디폴트 이미지를 보여준다..
				if(isEdit){
					[photoImageView setImage:[UIImage imageNamed:@"img_Addressbook_default.png"] forState:UIControlStateNormal];
				} else {
					[mainPhotoView setImage:[UIImage imageNamed:@"img_Addressbook_default.png"] forState:UIControlStateNormal];
				}
			}
		}else { //아예 설정이 안된경우..
			if(self.addUserImage)
				//이미지 피커에서 가져온경우..
				[photoImageView setImage:self.addUserImage forState:UIControlStateNormal];
			else//없으면 기본 이미지..
				[photoImageView setImage:[UIImage imageNamed:@"img_Addressbook_default.png"]
								forState:UIControlStateNormal];
			
			}

	}else{ *///닉네임 끝..*/
			//원본 소스
			if (photoUrl && [photoUrl length] > 0) {
				
				UIImageView* representImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
				NSString *newImgPath = [NSString stringWithFormat:@"%@", [self md5:photoUrl]];
				NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
				NSString *cachesDirectory =  [NSString stringWithFormat:@"%@/ImageCache",[paths objectAtIndex:0]];
				NSString *imagePath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", newImgPath]];
				NSLog(@"imagePath = %@", imagePath);
				if(isEdit){
					if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath isDirectory:NO]) 
					{
					
					/*
						[representImage setImageWithURL:[NSURL URLWithString:photoUrl]
									   placeholderImage:[UIImage imageNamed:@"img_default.png"]];
					
					*/	
						
						
						
						// not exist file
						NSLog(@"imagePath not exist file");
						
					}
					else {
						
						NSData *data =[[NSData alloc] initWithContentsOfFile:imagePath];
						[mainPhotoView setImage:[UIImage imageWithData:data]];
						[photoImageView setBackgroundImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
						 
						//release 2010.12.28
						[data release];
						
						
						
						 
						/* 일단주석
						NSData *data =[[NSData alloc] initWithContentsOfFile:imagePath];
						[representImage setImage:[UIImage imageWithData:data]];
						NSLog(@"img ok");
						 */
					}
					if(mainPhotoView.image != nil){
						NSLog(@"이미지가 존재한다.");
						//	[mainPhotoView setImage:representImage.image];
						//[photoImageView setBackgroundImage:representImage.image forState:UIControlStateNormal];
					}
					else {
						NSLog(@"이미지가 닐이다..");
					}

					
				}else 
				{
					if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath isDirectory:NO]) {
						
						
						
						[mainPhotoView setImageWithURL:[NSURL URLWithString:photoUrl]
									   placeholderImage:[UIImage imageNamed:@"img_default.png"]];
						
						// not exist file
						NSLog(@"편집 상태가 아님.. magePath not exist file");
						
					}
					else {
						NSData *data =[[NSData alloc] initWithContentsOfFile:imagePath];
						[mainPhotoView setImage:[UIImage imageWithData:data]];
						[photoImageView setBackgroundImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
						NSLog(@"img ok");
						//release 2010.12.28
						[data release];
					}
					personInfo.USERIMAGE = UIImageJPEGRepresentation(mainPhotoView.image, 1.0);
				}
				//release 2010.12.28
				[representImage release];
			} 
			else {
				if(isEdit){
						[photoImageView setBackgroundImage:[UIImage imageNamed:@"img_Addressbook_default.png"] forState:UIControlStateNormal];
				} else {
					mainPhotoView.image = [UIImage imageNamed:@"img_Addressbook_default.png"];
				}
			}
		}else {
			if(isEdit){
				if(self.addUserImage)
					[photoImageView setBackgroundImage:self.addUserImage forState:UIControlStateNormal];
				else
					[photoImageView setBackgroundImage:[UIImage imageNamed:@"img_Addressbook_default.png"]
											  forState:UIControlStateNormal];
			}else {
				if(self.addUserImage){
					[mainPhotoView setImage:self.addUserImage];
				}else{
					[mainPhotoView setImage:[UIImage imageNamed:@"img_Addressbook_default.png"]];
				}
			}
			
		}
		
	}
	else{ //수정 버전..
		UILabel* titleLabel = (UILabel*)[cell.contentView viewWithTag:kTitleLabel];
		UILabel* detailTitleLabel = (UILabel*)[cell.contentView viewWithTag:kDetailtitleLabel];
		
		
		
		
		if([rowKey isEqualToString:@"MOBILEPHONENUMBER"]){
			detailTitleLabel.text = [CheckPhoneNumber convertPhoneInsertHyphen:(NSMutableString*)self.personInfo.MOBILEPHONENUMBER];
			titleLabel.text = rowLabel;
		}else if([rowKey isEqualToString:@"IPHONENUMBER"]){
			detailTitleLabel.text = [CheckPhoneNumber convertPhoneInsertHyphen:(NSMutableString*)self.personInfo.IPHONENUMBER];
			titleLabel.text = rowLabel;
		}else if([rowKey isEqualToString:@"homePhoneNumber"]){
			detailTitleLabel.text = [CheckPhoneNumber convertPhoneInsertHyphen:(NSMutableString*)self.personInfo.HOMEPHONENUMBER];
			titleLabel.text = rowLabel;
		}else if([rowKey isEqualToString:@"orgPhoneNumber"]){
			DebugLog(@"직장전화 = %@", [CheckPhoneNumber convertPhoneInsertHyphen:(NSMutableString*)self.personInfo.ORGPHONENUMBER]);
			detailTitleLabel.text = [CheckPhoneNumber convertPhoneInsertHyphen:(NSMutableString*)self.personInfo.ORGPHONENUMBER];
			titleLabel.text = rowLabel;
		}else if([rowKey isEqualToString:@"HOMEEMAILADDRESS"]){
			detailTitleLabel.text = self.personInfo.HOMEEMAILADDRESS;
			titleLabel.text = rowLabel;
		}else if([rowKey isEqualToString:@"ORGEMAILADDRESS"]){
			detailTitleLabel.text = self.personInfo.ORGEMAILADDRESS;
			titleLabel.text = rowLabel;
		}else if([rowKey isEqualToString:@"PROFILENICKNAME"]){
			detailTitleLabel.text = self.personInfo.PROFILENICKNAME;
			titleLabel.text = rowLabel;}
		else if([rowKey isEqualToString:@"orgname"]){
			detailTitleLabel.text = self.personInfo.ORGNAME;
			titleLabel.text = rowLabel;
		}else if([rowKey isEqualToString:@"nickname"]){
			detailTitleLabel.text = self.personInfo.NICKNAME;
			titleLabel.text = rowLabel;
		}else if([rowKey isEqualToString:@"url1"]){
			detailTitleLabel.text = self.personInfo.URL1;
			titleLabel.text = rowLabel;
		}else if([rowKey isEqualToString:@"note"]){
			detailTitleLabel.text = self.personInfo.NOTE;
			titleLabel.text = rowLabel;
		}else if([rowKey isEqualToString:@"group"]) {
			NSArray* groupArray = [GroupInfo findByColumn:@"ID" value:self.personInfo.GID];
			GroupInfo* nameForGroup = nil;
			if([groupArray count] == 0){
				NSArray* defaultArray = [GroupInfo findByColumn:@"ID" value:@"0"];
				nameForGroup = [defaultArray objectAtIndex:0];
			} else {
				nameForGroup = [groupArray objectAtIndex:0];
			}
			detailTitleLabel.text = nameForGroup.GROUPTITLE;
			titleLabel.text = rowLabel;
		}
		
		DebugLog(@"titleLabel = %@", detailTitleLabel.text);


	}
		
	DebugLog(@"cELLL END");
	
	return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	
	
	
	

		
	
	
	if(indexPath.section == 0){
		/*
		if(indexPath.row == 0)
		{
			NSLog(@"0x0");
		}
		
		
		
		UIImage *tmpImg = [UIImage imageWithData:data3];
		
		
		if(!tmpImg)
		{
			NSLog(@"tmp image..."); 
		}
			
		UIButton *tmpButton = (UIButton*)[cell.contentView viewWithTag:BUTTONTAG];
//		[mainPhotoView setImage:tmpImg forState:UIControlStateNormal];
		[tmpButton setImage:tmpImg forState:UIControlStateNormal];
		*/
		
		DebugLog(@"display");
		if([cell.backgroundView class] != [UIView class]) {
			DebugLog(@"aaaaa");
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
			
			DebugLog(@"selectView");
			
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	
	
	
	if(!isEdit){
			
		
		/*
		DebugLog(@"index path = %d", indexPath.row);
		if(indexPath.row == 0)
		{
			DebugLog(@"photo...");
			
		}
		*/
		
		
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		 NSString *eventrowKey = [rowKeys nestedObjectAtIndexPath:indexPath];
		UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
		UILabel* detailTitleLabel = (UILabel*)[cell.contentView viewWithTag:kDetailtitleLabel];
		if([[eventrowKey uppercaseString] rangeOfString:[NSString stringWithFormat:@"NUMBER"]].location != NSNotFound){
			NSString* phoneNumber = nil;
			if([eventrowKey isEqualToString:@"MOBILEPHONENUMBER"]){
				if([detailTitleLabel.text length] > 0)
					phoneNumber = detailTitleLabel.text;
			}else if([eventrowKey isEqualToString:@"IPHONENUMBER"]){
				if([detailTitleLabel.text length] > 0)
					phoneNumber = detailTitleLabel.text;
			}else if([eventrowKey isEqualToString:@"homePhoneNumber"]){
				if([detailTitleLabel.text length] > 0)
					phoneNumber = detailTitleLabel.text;
			}else if([eventrowKey isEqualToString:@"orgPhoneNumber"]){
				if([detailTitleLabel.text length] > 0)
					phoneNumber = detailTitleLabel.text;
			}
			if(phoneNumber != nil && [phoneNumber length] > 0){
				NSString* telno = [[NSString stringWithFormat:@"tel:%@",phoneNumber] 
								   stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				
				BOOL open = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telno]];
				if(open == NO){
					UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"전화하기" 
																	   message:@"전화 기능을 사용 하실 수 없는 \n기기 입니다." 
																	  delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
					[alertView show];
					[alertView release];
				}
			}
		}else if([[eventrowKey uppercaseString] rangeOfString:[NSString stringWithFormat:@"EMAILADDRESS"]].location != NSNotFound){
			NSString* emailAddress = nil;
			if([eventrowKey isEqualToString:@"HOMEEMAILADDRESS"]){
				if([detailTitleLabel.text length] > 0)
					emailAddress = detailTitleLabel.text;
			}else if([eventrowKey isEqualToString:@"ORGEMAILADDRESS"]){
				if([detailTitleLabel.text length] > 0)
					emailAddress = detailTitleLabel.text;
			}
			
			if(emailAddress != nil && [emailAddress length] > 0){
				Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
				if (mailClass != nil){
					if([mailClass canSendMail]){
						MFMailComposeViewController* mailController = [[MFMailComposeViewController alloc] init];
						[mailController setToRecipients:[NSArray arrayWithObject:emailAddress]];
						if(self.parentController != nil){
							mailController.mailComposeDelegate = self.parentController;
							mailController.delegate=self;
							[mailController setSubject:@"새로운 메세지"];
							[self.parentController presentModalViewController:mailController animated:YES];
												}else {
							mailController.mailComposeDelegate = self;
							[mailController setSubject:@"새로운 메세지"];
													mailController.delegate=self;
													[self presentModalViewController:mailController animated:YES];
													
							}
		

						[mailController release];
					}else {
						NSString* emailAddrStr = [[NSString stringWithFormat:@"mailto:%@",emailAddress] 
												  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
						
						BOOL open = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:emailAddrStr]];
						if(open == NO){
							UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"메일 전송" 
																			   message:@"메일 전송 기능을 사용 하실 수 없는 \n기기 입니다." 
																			  delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
							[alertView show];
							[alertView release];
						}
						
					}
					
				}
			}
		}
		
		return;
	}
	
    NSString *controllerClassName = [rowControllers nestedObjectAtIndexPath:indexPath];
    NSString *rowLabel = [rowLabels nestedObjectAtIndexPath:indexPath];
    NSString *rowKey = [rowKeys nestedObjectAtIndexPath:indexPath];
    Class controllerClass = NSClassFromString(controllerClassName);
    ManagedObjectAttributeEditor *controller = [[controllerClass alloc] initWithStyle:UITableViewStyleGrouped] ;
	
    controller.keypath = rowKey;
    controller.labelString = rowLabel;
//    controller.title = rowLabel;
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
	controller.delegate = self;
	if([rowKey isEqualToString:@"group"]){
		NSArray* groupArray = [GroupInfo findByColumn:@"ID" value:self.personInfo.GID];
		GroupInfo* nameForGroup = nil;
		if([groupArray count] == 0){
			NSArray* defaultArray = [GroupInfo findByColumn:@"ID" value:@"0"];
			nameForGroup = [defaultArray objectAtIndex:0];
		} else {
			nameForGroup = [groupArray objectAtIndex:0];
		}
		[controller setValue:nameForGroup.GROUPTITLE forKey:@"selectedValue"];
	}else{
		//2010.10.26 이름입력부분 포맷/별명/프로필 순으로 변경..
		controller.passDefaultValue = [personInfo valueForKey:[rowKey uppercaseString]];
		
		
		//이름 변경시에만 다음 과 같이 변경.. 2010.10.26
		/* sochae - 주소록 화면은 주소록 이름만으로 표시.
		
		if([rowKey isEqualToString:@"formatted"])
		{
			if(controller.passDefaultValue == NULL)
			{
				if([personInfo.NICKNAME length] >0)
					controller.passDefaultValue = personInfo.NICKNAME;
				else
					controller.passDefaultValue = personInfo.PROFILENICKNAME;
			}
		}
		*/
		DebugLog(@"controller  defatult =%@", controller.passDefaultValue);
	}
	
    NSDictionary *args = [rowArguments nestedObjectAtIndexPath:indexPath];
    if ([args isKindOfClass:[NSDictionary class]]) {
        if (args != nil) {
            for (NSString *oneKey in args) {
                id oneArg = [args objectForKey:oneKey];
                [controller setValue:oneArg forKey:oneKey];
            }
        }
    }

	
	

//	[self reLoadMemory];
//	[self normalInterFaceConfig];
	
	
	NSLog(@"labelstringg= %@", rowLabel);
	NSLog(@"labelstringg= %@", rowKey);
	
	if(parentController != nil){
	 	[parentController.navigationController pushViewController:controller animated:YES];
	}else {
		[self.navigationController pushViewController:controller animated:YES];
	}

    [controller release];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView 
		   editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
//	NSInteger sectionGroup = [indexPath section];
//	NSInteger rowGroup	=	[indexPath row];
	
	NSString *rowLabel = [rowLabels nestedObjectAtIndexPath:indexPath];
	
//	NSIndexPath* cellIndexPath = [NSIndexPath indexPathForRow:rowGroup inSection:sectionGroup];
	
//	NSLog(@"%@",cell.detailTextLabel.text);
	if([rowLabel isEqualToString:@"핸드폰"] ){
		if(personInfo.MOBILEPHONENUMBER != nil && [personInfo.MOBILEPHONENUMBER length] > 0 &&
		   personInfo.IPHONENUMBER != nil && [personInfo.IPHONENUMBER length] > 0)
			return UITableViewCellEditingStyleNone;
		else
			return UITableViewCellEditingStyleInsert;
	}
	
	if([rowLabel isEqualToString:@"이메일"]){
		if(personInfo.HOMEEMAILADDRESS != nil && [personInfo.HOMEEMAILADDRESS length] > 0 &&
		   personInfo.ORGEMAILADDRESS != nil && [personInfo.ORGEMAILADDRESS length] > 0)
			return UITableViewCellEditingStyleNone;
		else
			return UITableViewCellEditingStyleInsert;
	}
	
	if([rowLabel isEqualToString:@"핸드폰2"] ){
		if(personInfo.MOBILEPHONENUMBER != nil && [personInfo.MOBILEPHONENUMBER length] > 0)
			return UITableViewCellEditingStyleDelete;
		if([personInfo.MOBILEPHONENUMBER length]<= 0)
			return UITableViewCellEditingStyleInsert;
	}
	
	if([rowLabel isEqualToString:@"이메일2"]){
		if(personInfo.HOMEEMAILADDRESS != nil && [personInfo.HOMEEMAILADDRESS length] > 0)
			return UITableViewCellEditingStyleDelete;
		if([personInfo.HOMEEMAILADDRESS length]<= 0)
			return UITableViewCellEditingStyleInsert;
	}
	
	return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger sectionGroup = [indexPath section];
	if(sectionGroup == 0 || sectionGroup == 1)
		return NO;
	
	return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (editingStyle == UITableViewCellEditingStyleInsert){
		NSString *valueRowKey = [rowKeys nestedObjectAtIndexPath:indexPath];
		if([personInfo valueForKey:valueRowKey] == nil && [[personInfo valueForKey:valueRowKey] length] <= 0){
			[self tableView:tableView didSelectRowAtIndexPath:indexPath];
			return;
		}
		
		NSString *controllerClassName = [rowControllers nestedObjectAtIndexPath:indexPath];
		NSString *rowKey = [rowKeys nestedObjectAtIndexPath:indexPath];
		NSString *rowLabel = [rowLabels nestedObjectAtIndexPath:indexPath];
		Class controllerClass = NSClassFromString(controllerClassName);
		ManagedObjectAttributeEditor *controller = [[controllerClass alloc] initWithStyle:UITableViewStyleGrouped] ;
		
		if([rowKey isEqualToString:@"MOBILEPHONENUMBER"])
			rowKey = [NSString stringWithFormat:@"IPHONENUMBER"];
		else if([rowKey isEqualToString:@"IPHONENUMBER"])
			rowKey = [NSString stringWithFormat:@"MOBILEPHONENUMBER"];
		else if([rowKey isEqualToString:@"HOMEEMAILADDRESS"])
			rowKey = [NSString stringWithFormat:@"ORGEMAILADDRESS"];
		else if([rowKey isEqualToString:@"ORGEMAILADDRESS"])
			rowKey = [NSString stringWithFormat:@"HOMEEMAILADDRESS"];
		
		if([rowLabel isEqualToString:@"핸드폰"])
			rowLabel = [NSString stringWithFormat:@"핸드폰2"];
		else if([rowLabel isEqualToString:@"핸드폰2"])
			rowLabel = [NSString stringWithFormat:@"핸드폰"];
		else if([rowLabel isEqualToString:@"이메일"])
			rowLabel = [NSString stringWithFormat:@"이메일2"];
		else if([rowLabel isEqualToString:@"이메일2"])
			rowLabel = [NSString stringWithFormat:@"이메일"];
		
		controller.keypath = rowKey;
		controller.labelString = rowLabel;
//		controller.title = rowLabel;
		controller.delegate = self;
		////////// 타이틀 색 지정 //////////
		UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
//		assert(titleView != nil);
		UIFont *titleFont = [UIFont systemFontOfSize:20];
		CGSize titleStringSize = [rowLabel sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
//		assert(titleFont != nil);
		UILabel *naviTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
//		assert(naviTitleLabel != nil);
		[naviTitleLabel setFont:titleFont];
		naviTitleLabel.textAlignment = UITextAlignmentCenter;
		[naviTitleLabel setTextColor:ColorFromRGB(0x053844)];
		[naviTitleLabel setBackgroundColor:[UIColor clearColor]];
		[naviTitleLabel setText:rowLabel];
//		naviTitleLabel.shadowColor = [UIColor whiteColor];
		[titleView addSubview:naviTitleLabel];	
		[naviTitleLabel release];
		controller.navigationItem.titleView = titleView;
		[titleView release];
		controller.navigationItem.titleView.frame = CGRectMake((controller.tableView.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);
		/////////////////////////////////
		NSDictionary *args = [rowArguments nestedObjectAtIndexPath:indexPath];
		if ([args isKindOfClass:[NSDictionary class]]) {
			if (args != nil) {
				for (NSString *oneKey in args) {
					id oneArg = [args objectForKey:oneKey];
					[controller setValue:oneArg forKey:oneKey];
				}
			}
		}
		
		
		if(parentController != nil){
			[parentController.navigationController pushViewController:controller animated:YES];
		}else {
			[self.navigationController pushViewController:controller animated:YES];
		}

		[controller release];
	}
	else if (editingStyle == UITableViewCellEditingStyleDelete){
		NSString *rowKey = [rowKeys nestedObjectAtIndexPath:indexPath];
		[personInfo setValue:@"" forKey:rowKey];
		[self.tableView beginUpdates];
		[self editInterFaceConfig];
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:NO];
		NSLog(@"delete row");
		[self.tableView reloadData];
		[self.tableView endUpdates];
	}
}
/*
- (NSString *)tableView:(UITableView *)tableView 
titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
	return @"삭제";
}
*/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if([indexPath section] ==  0 && [indexPath row] == 0){
		return 64.0;
	}
	return 55.0;
}

#pragma mark -
#pragma mark delete contact network Method

-(void)requestDeleteContact{
	//사용자 정보 저장
// sochae 2010.12.29 - cLang	NSString	*body = nil;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteContact:) name:@"deleteContact" object:nil];
	
	NSLog(@"주소 삭제");
	updateBlock = [[blockView alloc] initWithFrame:CGRectMake(0.0, 0.0, 250.0, 150.0)];
	updateBlock.alertText = @"주소 삭제 중..";
	updateBlock.alertDetailText = @"잠시만 기다려 주세요.";
	[updateBlock show];	
	
	NSMutableDictionary* userDic = [NSMutableDictionary dictionary];
	NSAutoreleasePool* varpool = [[NSAutoreleasePool alloc] init];
	unsigned int numIvars = 0;
	Ivar* ivars = class_copyIvarList([personInfo class], &numIvars);
	for(int i = 0; i < numIvars; i++) {
		Ivar thisIvar = ivars[i];
		NSString * key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
		if([personInfo valueForKey:key] != nil){
			if([key isEqualToString:@"ID"]){
				[userDic setObject:[personInfo valueForKey:key] forKey:@"id"];
			}else if([key isEqualToString:@"GID"]){
				[userDic setObject:[personInfo valueForKey:key] forKey:@"gid"];
//			}else if([key isEqualToString:@"ISFRIEND"]){
//				[userDic setObject:[personInfo valueForKey:key] forKey:@"isFriend"];
//			}else if([key isEqualToString:@"RPKEY"]){
//				[userDic setObject:[personInfo valueForKey:key] forKey:@"rPKey"];
//			}else if([key isEqualToString:@"MOBILEPHONENUMBER"]){
//				[userDic setObject:[personInfo valueForKey:key] forKey:@"mobilePhoneNumber"];	
//			}else if([key isEqualToString:@"HOMEEMAILADDRESS"]){
//				[userDic setObject:[personInfo valueForKey:key] forKey:@"homeEmailAddress"];
//			}else if([key isEqualToString:@"IPHONENUMBER"]){
//				[userDic setObject:[personInfo valueForKey:key] forKey:@"iphoneNumber"];
//			}else if([key isEqualToString:@"ORGEMAILADDRESS"]){
//				[userDic setObject:[personInfo valueForKey:key] forKey:@"orgEmailAddress"];	
			}else {
				continue;
			}
		}
	}
	if(numIvars > 0)free(ivars);
	[varpool release];
	
	[userDic setObject:@"mobile" forKey:@"sidDeleted"];
	[userDic setObject:@"Y" forKey:@"toTrash"];
	[userDic setObject:[[self appDelegate] getSvcIdx] forKey:@"svcidx"];

	NSDictionary *bodyObject = [NSDictionary dictionaryWithDictionary:userDic];
	
	SBJSON *json = [[SBJSON alloc]init];
	[json setHumanReadable:YES];
	// 변환
//	body = [json stringWithObject:bodyObject error:nil];
	[json release];
//	NSLog(@"%@",body);
	
	USayHttpData *data = [[[USayHttpData alloc]initWithRequestData:@"deleteContact" andWithDictionary:bodyObject timeout:10]autorelease];
//	assert(data != nil);		
	[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
	
}

-(void)deleteContact:(NSNotification *)notification {
	
	USayHttpData *data = (USayHttpData*)[notification object];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"deleteContact" object:nil];
	[updateBlock dismissAlertView];
	[updateBlock release];
	updateBlock=nil;
	if (data == nil) {
		// 200 이외의 에러
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" 
															message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0019)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
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
		NSString *RP = [dic objectForKey:@"RP"];
		if([rtType isEqualToString:@"map"]){
			// 처리완료 로직
			NSDictionary *addressDic = [dic objectForKey:@"map"];
			
			NSString* userId = [addressDic objectForKey:@"id"];
			
			[self syncDataDeleteDB:userId withRevisionPoint:RP];
		}
		
	} else if ([rtcode isEqualToString:@"-9010"]) {
		// TODO: 데이터를 찾을 수 없음

	} else if ([rtcode isEqualToString:@"-9020"]) {
		// TODO: 잘못된 인자가 넘어옴
	} else if ([rtcode isEqualToString:@"-9030"]) {
		// TODO: 처리 오류

	} else {
		// TODO: 기타오류 예외처리 필요
	}
	return;
}

#pragma mark -
#pragma mark address data update Method
-(BOOL)requestUpdateContact{
//	NSString	*body = nil;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateContact:) name:@"updateContact" object:nil];
	// TODO: blockView 사용
	
	
	DebugLog(@"주소 업데이트");
	
	updateBlock = [[blockView alloc] initWithFrame:CGRectMake(0.0, 0.0, 250.0, 150.0)];
	updateBlock.alertText = @"주소 업데이트 중..";
	updateBlock.alertDetailText = @"잠시만 기다려 주세요.";
	[updateBlock show];	
	
	 NSMutableDictionary* userDic = [NSMutableDictionary dictionary];
	NSAutoreleasePool* varpool = [[NSAutoreleasePool alloc] init];
	unsigned int numIvars = 0;
	Ivar* ivars = class_copyIvarList([personInfo class], &numIvars);
	for(int i = 0; i < numIvars; i++) {
		Ivar thisIvar = ivars[i];
		NSString * key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
	//	NSLog(@"key is %@", key);
	
		//서버로 전송할 값 셋팅..
		if([personInfo valueForKey:key]){
			if([key isEqualToString:@"ID"]){
				[userDic setObject:[personInfo valueForKey:key] forKey:@"id"];
			}else if([key isEqualToString:@"FORMATTED"]){
				/* sochae 2010.12.29 - cLang
				NSString *tmpFormatted = [personInfo valueForKey:key];
				NSLog(@"tmpFormatted = %@", tmpFormatted);
				*/
				
			//	tmpFormatted = [NSString stringWithFormat:@""
			//	tmpFormatted = [tmpFormatted stringByReplacingOccurrencesOfString:@"'" withString:@"`"];
			//	tmpFormatted = [tmpFormatted stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
				
		//		[userDic setObject:tmpFormatted forKey:@"formatted"];	
				[userDic setObject:[personInfo valueForKey:key] forKey:@"formatted"];
			}else if([key isEqualToString:@"GID"]){
				[userDic setObject:[personInfo valueForKey:key] forKey:@"gid"];
	//		}else if([key isEqualToString:@"ISFRIEND"]){
	//			[userDic setObject:[personInfo valueForKey:key] forKey:@"isFriend"];
	//		}else if([key isEqualToString:@"RPKEY"]){
	//			[userDic setObject:[personInfo valueForKey:key] forKey:@"rPKey"];
			}else if([key isEqualToString:@"ORGNAME"]){
				NSString *tmpFormatted = [personInfo valueForKey:key];
		//		tmpFormatted = [tmpFormatted stringByReplacingOccurrencesOfString:@"'" withString:@"`"];
				[userDic setObject:tmpFormatted forKey:@"orgName"];
				//[userDic setObject:[personInfo valueForKey:key] forKey:@"orgName"];
			}else if([key isEqualToString:@"NICKNAME"]){
				NSString *tmpFormatted = [personInfo valueForKey:key];
			//	tmpFormatted = [tmpFormatted stringByReplacingOccurrencesOfString:@"'" withString:@"`"];
				[userDic setObject:tmpFormatted forKey:@"nickName"];
				
				//[userDic setObject:[personInfo valueForKey:key] forKey:@"nickName"];
			}else if([key isEqualToString:@"HOMEEMAILADDRESS"]){
				NSString *tmpFormatted = [personInfo valueForKey:key];
			//	tmpFormatted = [tmpFormatted stringByReplacingOccurrencesOfString:@"'" withString:@"`"];
				[userDic setObject:tmpFormatted forKey:@"homeEmailAddress"];
				//[userDic setObject:[personInfo valueForKey:key] forKey:@"homeEmailAddress"];
			}else if([key isEqualToString:@"ORGEMAILADDRESS"]){
				NSString *tmpFormatted = [personInfo valueForKey:key];
		//		tmpFormatted = [tmpFormatted stringByReplacingOccurrencesOfString:@"'" withString:@"`"];
				[userDic setObject:tmpFormatted forKey:@"orgEmailAddress"];
				
				//[userDic setObject:[personInfo valueForKey:key] forKey:@"orgEmailAddress"];
//			}else if([key isEqualToString:@"OTHEREMAILADDRESS"]){
//				[userDic setObject:[personInfo valueForKey:key] forKey:@"otherMailAddress"];
			}else if([key isEqualToString:@"MOBILEPHONENUMBER"]){
				[userDic setObject:[personInfo valueForKey:key] forKey:@"mobilePhoneNumber"];
			}else if([key isEqualToString:@"IPHONENUMBER"]){
				[userDic setObject:[personInfo valueForKey:key] forKey:@"iphoneNumber"];
			}else if([key isEqualToString:@"HOMEPHONENUMBER"]){
				[userDic setObject:[personInfo valueForKey:key] forKey:@"homePhoneNumber"];
			}else if([key isEqualToString:@"ORGPHONENUMBER"]){
				[userDic setObject:[personInfo valueForKey:key] forKey:@"orgPhoneNumber"];
//			}else if([key isEqualToString:@"MAINPHONENUMBER"]){
//				[userDic setObject:[personInfo valueForKey:key] forKey:@"mainPhoneNumber"];
//			}else if([key isEqualToString:@"HOMEFAXPHONENUMBER"]){
//				[userDic setObject:[personInfo valueForKey:key] forKey:@"homeFaxPhoneNumber"];
//			}else if([key isEqualToString:@"ORGFAXPHONENUMBER"]){
//				[userDic setObject:[personInfo valueForKey:key] forKey:@"orgFaxPhoneNumber"];
//			}else if([key isEqualToString:@"PARSERNUMBER"]){
//				[userDic setObject:[personInfo valueForKey:key] forKey:@"parserNumber"];
//			}else if([key isEqualToString:@"OTHERPHONENUMBER"]){
//				[userDic setObject:[personInfo valueForKey:key] forKey:@"otherPhoneNumber"];
//			}else if([key isEqualToString:@"HOMECITY"]){
//				[userDic setObject:[personInfo valueForKey:key] forKey:@"homeCity"];
			}else if([key isEqualToString:@"HOMEZIPCODE"]){
				[userDic setObject:[personInfo valueForKey:key] forKey:@"homeZipCode"];
//			}else if([key isEqualToString:@"HOMEADDRESSDETAIL"]){
//				[userDic setObject:[personInfo valueForKey:key] forKey:@"homeAddressDetail"];
//			}else if([key isEqualToString:@"HOMESTATE"]){
//				[userDic setObject:[personInfo valueForKey:key] forKey:@"homeState"];
			}else if([key isEqualToString:@"HOMEADDRESS"]){
				[userDic setObject:[personInfo valueForKey:key] forKey:@"homeAddress"];
//			}else if([key isEqualToString:@"ORGCITY"]){
//				[userDic setObject:[personInfo valueForKey:key] forKey:@"orgCity"];
//			}else if([key isEqualToString:@"ORGZIPCODE"]){
//				[userDic setObject:[personInfo valueForKey:key] forKey:@"orgZipCode"];
//			}else if([key isEqualToString:@"ORGSTATE"]){
//				[userDic setObject:[personInfo valueForKey:key] forKey:@"orgState"];
//			}else if([key isEqualToString:@"ORGADDRESS"]){
//				[userDic setObject:[personInfo valueForKey:key] forKey:@"orgAddress"];
			}else if([key isEqualToString:@"THUMBNAILURL"]){
				[userDic setObject:[personInfo valueForKey:key] forKey:@"thumbnailUrl"];
			}else if([key isEqualToString:@"URL1"]){
				[userDic setObject:[personInfo valueForKey:key] forKey:key];
//			}else if([key isEqualToString:@"URL2"]){
//				[userDic setObject:[personInfo valueForKey:key] forKey:key];
			}else if([key isEqualToString:@"NOTE"]){
				[userDic setObject:[personInfo valueForKey:key] forKey:@"note"];
			}
			//2010.10.26 RPKEY insert
			/*
			else if([key isEqualToString:@"RPKEY"]){
				[userDic setObject:[personInfo valueForKey:key] forKey:@"RPKEY"];
			}*/else {
				continue;
			}
		}
	}
	if(numIvars > 0)free(ivars);
	[varpool release];
	[userDic setObject:@"mobile" forKey:@"sidUpdated"];
	[userDic setObject:[[self appDelegate] getSvcIdx] forKey:@"svcidx"];

	NSDictionary *bodyObject = [NSDictionary dictionaryWithDictionary:userDic];
	
	
	DebugLog(@"주소록 정보 업데이트 내용 %@", bodyObject);
	
	
	SBJSON *json = [[SBJSON alloc]init];
	[json setHumanReadable:YES];
	// 변환
//	body = [json stringWithObject:bodyObject error:nil];
	[json release];
//	NSLog(@"%@",body);
	
	USayHttpData *data = [[[USayHttpData alloc]initWithRequestData:@"updateContact" andWithDictionary:bodyObject timeout:10]autorelease];
//	assert(data != nil);		
	[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];

	
	return YES;
}

-(void)updateContact:(NSNotification *)notification {
	
	USayHttpData *data = (USayHttpData*)[notification object];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateContact" object:nil];
	
	

	// TODO: blockview 제거
	/*
	if(updateBlock)
	{
		[updateBlock dismissAlertView];
		[updateBlock release];
		updateBlock=nil;
		NSLog(@"==============UPDATECONTACT 블록 존재함================");	

	}
	else {
		NSLog(@"==============UPDATECONTACT 블록 존재 안함================");	
	}
*/
	if (data == nil) {
				
		// 200 이외의 에러
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" 
															message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return;
	}
	
	//	NSString *api = data.api;	
	NSString *resultData = data.responseData;
	
	NSLog(@"data.res %@", data.responseData);
	
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
						
						
					//	NSLog(@"버디퍼슨 클래식키 %@", classkey);
						
						if([classkey isEqualToString:@"RECORDID"])
							continue;
						
						
						
					//	NSLog(@"클래식 키 %@", classkey);
						
						if([[resultkey uppercaseString] isEqualToString:classkey])
						{
								[userData  setValue:[addressDic objectForKey:resultkey] forKey:classkey];
						}
					}	
					if(numIvars > 0)free(ivars);
					[varpool release];
				}
				[serverData addObject:userData];
				[userData release];
			}
			
			[self syncDataSaveDB:serverData withRevisionPoint:RP];
			
			
			
			
		} else if ([rtcode isEqualToString:@"-9010"]) {
			// TODO: 데이터를 찾을 수 없음
		} else if ([rtcode isEqualToString:@"-9020"]) {
			// TODO: 잘못된 인자가 넘어옴
		} else if ([rtcode isEqualToString:@"-9030"]) {
			// TODO: 처리 오류
		} else {
			// TODO: 기타오류 예외처리 필요
		}
	}
}
-(void)syncDataSaveDB:(NSArray*)dataArray withRevisionPoint:(NSString *)revisionPoint{
	
	NSLog(@"싱크데이터 맞춘다..");
	
	if(dataArray != nil && [dataArray count] == 1){
		NSLog(@"데이터가 있다..");
		
		UserInfo* userData = [dataArray objectAtIndex:0];
		NSAutoreleasePool* varpool = [[NSAutoreleasePool alloc] init];
		unsigned int numIvars = 0;
		Ivar* ivars = class_copyIvarList([personInfo class], &numIvars);
		for(int i = 0; i < numIvars; i++) {
			Ivar thisIvar = ivars[i];
			NSString * classkey = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
			
			
			
			
			if([userData valueForKey:classkey] != nil && [[userData valueForKey:classkey] length] > 0)
				[personInfo  setValue:[userData valueForKey:classkey] forKey:classkey];
		}
		
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		NSLocale *locale = [NSLocale currentLocale];
		[formatter setLocale:locale];
		[formatter setDateFormat:@"yyyyMMddHHmmss"];
		NSDate *today = [NSDate date];
		NSString *lastSyncDate = [[NSString alloc] initWithFormat:@"%@",[formatter stringFromDate:today]];
		NSLog(@"저장한다. %@", lastSyncDate);
		[personInfo  setValue:lastSyncDate forKey:@"OEMMODIFYDATE"];
		
		[formatter release];
		[lastSyncDate release];
		
		
		
		
		if(numIvars > 0)free(ivars);
		[varpool release];
		[personInfo setPrimaryKey:[personInfo.INDEXNO integerValue]];
		
		
		//NSLog(@"RPKEY = %@", personInfo.RPKEY);
		//로컬 디비에 업데이트...
		
		
		
		
		[personInfo update];
		//주소록 이름이 바뀌었을경우 대화방의 이름도 주소록 이름으로 바꿔줘야 한다.. 딜리게이트의 메세지 리스트도 갱신해준다..
		
		
		NSString *newName = [personInfo.FORMATTED stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
		
		
		NSString *updateMessage = [NSString stringWithFormat:@"update _TMessageInfo set NICKNAME='%@' where PKEY='%@'"
								   ,newName
								   ,personInfo.RPKEY];
		
		NSString *updateMessageUser = [NSString stringWithFormat:@"update _TMessageUserInfo set NICKNAME='%@' where PKEY='%@'"
									   ,newName
									   ,personInfo.RPKEY];
		
		
	//	NSLog(@"updateMessage = %@", updateMessage);
	//	NSLog(@"updateMessageUser = %@", updateMessageUser);
		
		[MessageInfo findWithSql:updateMessage];
		[MessageInfo findWithSql:updateMessageUser];
		
		
		
		USayAppAppDelegate *parentDelegate = [self appDelegate];
		
		for (int i=0; i<[parentDelegate.msgListArray count]; i++) {
			BOOL flag = NO; //flag갑시 초기화 2010.01.11
			CellMsgListData *msgListData = [parentDelegate.msgListArray objectAtIndex:i];
			NSArray *tmpArray = [msgListData.userDataDic allKeys];
		//	NSLog(@"key = %@", tmpArray);
			for(int z=0; z<[tmpArray count]; z++)
			{
				if ([personInfo.RPKEY isEqualToString:[tmpArray objectAtIndex:z]]) {
					
			//		NSLog(@"keySame = %@", personInfo.RPKEY);
					MsgUserData *userData = [msgListData.userDataDic objectForKey:[tmpArray objectAtIndex:z]];
					userData.nickName = personInfo.FORMATTED;
					flag = YES;
					break;
				}
			}
			if(flag == YES)
				break;
			//NSLog(@"formatted %@",[msgListData.userDataDic objectForKey:@"nickName"] ); 
		}
				
		
		
		
		
		
		
		
	}
	
	if(self.addUserImage){
		NSLog(@"업로드ㅏ.. 한다.");
		[self addedContactPhontUpload:personInfo];
	}else if(self.addUserImage == nil){
		
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
		
		
		NSLog(@"add imageuser nill....");
		[self.personDelegate updatePersonInfo:personInfo];
		
		
		if(updateBlock)
		{
			[updateBlock dismissAlertView];
			[updateBlock release];
			updateBlock = nil;
		}
	
		NSLog(@"싱크 리로드..");
		[self.tableView reloadData];
//		[self.navigationController popViewControllerAnimated:YES];
	}
	
}
#pragma mark -
#pragma alertViewmark UIAlertView delegate Method
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
//	NSLog(@"buttonIndex %i",buttonIndex);
	if(buttonIndex == 1){
		[self requestDeleteContact];
	}
}

#pragma mark -
#pragma mark 주소록 사진 올리기 샘플

//사진 업로드가 너무 느리다...
-(void)addedContactPhontUpload:(UserInfo*)userData {
	
	
	
	if(updateBlock)
	{
		NSLog(@"updateBlock 가 존재하네.. %@", updateBlock);
//		[updateBlock dismissAlertView];
//		[updateBlock release];
	}
	else {
		NSLog(@"updateBlock 가 존재 안함");
	}
	
	NSLog(@"업로드..");

//	updateBlock = [[blockView alloc] initWithFrame:CGRectMake(0, 0, 250.0, 150.0)];
	updateBlock.alertText = @"    사진 등록 중..";
	updateBlock.alertDetailText = @"잠시만 기다려 주세요.";
	
//		[updateBlock show];	
		//[self.view addSubview:updateBlock];
		
			NSLog(@"block %@", updateBlock);
//	NSLog(@"addedContactPhontUpload");
	if (self.addUserImage) {
		//노티피케이션 설정
		
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
		
		//20101011 처리함..
		if (![imageData writeToFile:imagePath atomically:YES]) {
			NSLog(@"imagePath writeToFile error");
			// TODO: blockview 제거
	//		[updateBlock dismigssAlertView];
			[updateBlock dismissAlertView];
			[updateBlock release];
			updateBlock=nil;
		}
		
	//	NSLog(@"imagePath = %@", imagePath);
		if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath isDirectory:NO]) {
			// not exist file
			NSLog(@"imagePath not exist file");
			// TODO: blockview 제거
			[updateBlock dismissAlertView];
			[updateBlock release];
			updateBlock=nil;
			return;
		}
		NSString *pkey = [[self appDelegate].myInfoDictionary objectForKey:@"pkey"]; // userData.RPKEY;//[ objectForKey:@"pkey"];
		
		NSString *transParam = nil;
		if (userData.THUMBNAILURL && [userData.THUMBNAILURL length] > 0) {
			
			NSLog(@"기존꺼 업데이트 ");
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateContactPhoto:) name:@"updateContactPhoto" object:nil];
			
			if ([HttpAgent mc] == nil || [HttpAgent cs] == nil) {
#ifdef DEVEL_MODE	// sochae 2010.09.09 - dev server				
				transParam = [[NSString alloc ] initWithFormat:@"https://social.paran.com/KTH/updateContactPhoto.json?pKey=%@&UCMC=%@&UCCS=%@&originUrl=%@&svcidx=%@&cid=%@&mediaType=1", 
#else
				transParam = [[NSString alloc ] initWithFormat:@"https://dev.usay.net/KTH/updateContactPhoto.json?pKey=%@&UCMC=%@&UCCS=%@&originUrl=%@&svcidx=%@&cid=%@&mediaType=1", 
#endif // #ifdef DEVEL_MODE
							  pkey, 
							  [HttpAgent ucmc], [HttpAgent uccs], userData.THUMBNAILURL, [[self appDelegate] getSvcIdx], userData.ID];
			} else {
#ifdef DEVEL_MODE	// sochae 2010.09.09 - dev server
				transParam = [[NSString alloc ] initWithFormat:@"https://social.paran.com/KTH/updateContactPhoto.json?pKey=%@&MC=%@&CS=%@&UCMC=%@&UCCS=%@&originUrl=%@&svcidx=%@&cid=%@&mediaType=1", 
#else
				transParam = [[NSString alloc ] initWithFormat:@"https://dev.usay.net/KTH/updateContactPhoto.json?pKey=%@&MC=%@&CS=%@&UCMC=%@&UCCS=%@&originUrl=%@&svcidx=%@&cid=%@&mediaType=1", 
#endif // #ifdef DEVEL_MODE
							  pkey, [HttpAgent mc], [HttpAgent cs],
							  [HttpAgent ucmc], [HttpAgent uccs], userData.THUMBNAILURL, [[self appDelegate] getSvcIdx], userData.ID];
			}
		}else {
			
			
			NSLog(@"나중에꺼 업데이트 ");
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(insertContactPhoto:) name:@"insertContactPhoto" object:nil];
			
			if ([HttpAgent mc] == nil || [HttpAgent cs] == nil) {
#ifdef DEVEL_MODE	// sochae 2010.09.09 - dev server
				transParam = [[NSString alloc ] initWithFormat:@"https://social.paran.com/KTH/insertContactPhoto.json?pKey=%@&UCMC=%@&UCCS=%@&svcidx=%@&cid=%@", 
#else
				transParam = [[NSString alloc ] initWithFormat:@"https://dev.usay.net/KTH/insertContactPhoto.json?pKey=%@&UCMC=%@&UCCS=%@&svcidx=%@&cid=%@", 
#endif // #ifdef DEVEL_MODE
							  pkey, 
							  [HttpAgent ucmc], [HttpAgent uccs], [[self appDelegate] getSvcIdx], userData.ID];
			} else {
#ifdef DEVEL_MODE	// sochae 2010.09.09 - dev server
				transParam = [[NSString alloc ] initWithFormat:@"https://social.paran.com/KTH/insertContactPhoto.json?pKey=%@&MC=%@&CS=%@&UCMC=%@&UCCS=%@&svcidx=%@&cid=%@", 
#else
				transParam = [[NSString alloc ] initWithFormat:@"https://dev.usay.net/KTH/insertContactPhoto.json?pKey=%@&MC=%@&CS=%@&UCMC=%@&UCCS=%@&svcidx=%@&cid=%@", 
#endif // #ifdef DEVEL_MODE
							  pkey, [HttpAgent mc], [HttpAgent cs],
							  [HttpAgent ucmc], [HttpAgent uccs], [[self appDelegate] getSvcIdx], userData.ID];
			}
			
		}
		DebugLog(@"=== KTH : transParam = %@", transParam);
		
		NSString *uuid = [[self appDelegate] generateUUIDString];
//		assert(uuid != nil);
		NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
//		assert(bodyObject != nil);
		[bodyObject setObject:@"1" forKey:@"mediaType"];		// 0: video  1: photo
		[bodyObject setObject:uuid forKey:@"uuid"];
		[bodyObject setObject:[NSNull null] forKey:@"uploadFile"];
		[bodyObject setObject:transParam forKey:@"transParam"];
		[transParam release];
		// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
		
		USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"albumUpload" andWithDictionary:bodyObject timeout:30]autorelease];
		
//		assert(data != nil);
		if (userData.THUMBNAILURL && [userData.THUMBNAILURL length] > 0)
			data.subApi = @"updateContactPhoto";
		else
			data.subApi = @"insertContactPhoto";
		
		data.filePath = imagePath;
		data.uniqueId = uuid;
		data.mType = @"P";
		
							  
							  
							  
							  
		[[NSNotificationCenter defaultCenter] postNotificationName:@"requestUploadUrlMultipartForm" object:data];
		
	}else {
		// TODO: blockview 제거
		[updateBlock dismissAlertView];
		[updateBlock release];
		updateBlock=nil;
		NSLog(@"프로필 사진 추가 오류 - 이미지파일 오류. 잘못된 이미지 파일입니다.");
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
	NSLog(@"insertContactPhoto");
	USayHttpData *data = (USayHttpData*)[notification object];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"insertContactPhoto" object:nil];
	// TODO: blockview 제거
	
	NSLog(@"블록을 제거 한다.");
		[updateBlock dismissAlertView];
		[updateBlock release];
	updateBlock=nil;

	if (data == nil) {
		// 200 이외의 에러
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" 
															message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0021)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
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
			NSMutableArray* serverData = [NSMutableArray array];
			if(addressDic != nil){
				id userData = [NSMutableDictionary dictionary];
				NSArray* keyArray = [addressDic allKeys];
				for(NSString* resultkey in keyArray) {
					if([resultkey isEqualToString:@"photoUrl"]){
						[userData  setValue:[addressDic objectForKey:resultkey] forKey:@"THUMBNAILURL"];
//						NSLog(@"thumbnail %@", [addressDic objectForKey:resultkey]);
					}
//					else if([resultkey isEqualToString:@"pKey"]){
//						[userData  setValue:[addressDic objectForKey:resultkey] forKey:@"PKEY"];
//					}
				}
				[serverData addObject:userData];
			}
			
			[self syncImageDataSaveDB:serverData];
		}else {
			//error
		}
		
	} else if ([rtcode isEqualToString:@"-9010"]) {
			// TODO: 데이터를 찾을 수 없음
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"사진 등록 실패" 
																message:@"정보를 찾을 수 없어 사진 등록에 실패하였습니다.(-9010)" delegate:nil 
													  cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
			[alertView show];
			[alertView release];
			return;
			
	} else if ([rtcode isEqualToString:@"-9020"]) {
			// TODO: 잘못된 인자가 넘어옴
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"사진 등록 실패" 
																message:@"사진 등록에 실패하였습니다.(-9020)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
			[alertView show];
			[alertView release];
			return;
			
	} else if ([rtcode isEqualToString:@"-9030"]) {
			// TODO: 처리 오류
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"사진 등록 실패" 
																message:@"사진 등록 처리중 오류가 발생하여 사진 등록에 실패 하였습니다.(-9030)" 
															   delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
			[alertView show];
			[alertView release];
			return;
			
	} else {
			// TODO: 기타오류 예외처리 필요
			NSString* arrormsg = [NSString stringWithFormat:@"%@",rtcode];
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"사진 등록 실패" 
																message:[NSString stringWithFormat:@"%@", arrormsg]
															   delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
			[alertView show];
			[alertView release];
			return;
	}
	
}
-(void)updateContactPhoto:(NSNotification *)notification{
	NSLog(@"updateContactPhoto 노티피케이션");
	USayHttpData *data = (USayHttpData*)[notification object];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateContactPhoto" object:nil];
	// TODO: blockview 제거
	[updateBlock dismissAlertView];
	[updateBlock release];
	updateBlock=nil;
	if (data == nil) {
		// 200 이외의 에러
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 에러" 
															message:@"네트워크 오류로 정상적인 값을 받아오기 못했습니다.(200이외)" 
														   delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
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
			NSMutableArray* serverData = [NSMutableArray array];
			if(addressDic != nil){
				id userData = [NSMutableDictionary dictionary];
				NSArray* keyArray = [addressDic allKeys];
				for(NSString* resultkey in keyArray) {
					if([resultkey isEqualToString:@"photoUrl"]){
						NSLog(@"thumbnail %@", [addressDic objectForKey:resultkey]);
						[userData  setValue:[addressDic objectForKey:resultkey] forKey:@"THUMBNAILURL"];
					}
//					else if([resultkey isEqualToString:@"pKey"]){
//						[userData  setValue:[addressDic objectForKey:resultkey] forKey:@"PKEY"];
//					}
				}
				[serverData addObject:userData];
			}
			
			[self syncImageDataSaveDB:serverData];
			NSLog(@"이미지 싱크 리로드..");
			[self.tableView reloadData];
		} else if ([rtcode isEqualToString:@"-9010"]) {
			// TODO: 데이터를 찾을 수 없음
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"사진 등록 실패" 
																message:@"정보를 찾을 수 없어 사진 등록에 실패하였습니다.(-9010)" delegate:nil 
													  cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
			[alertView show];
			[alertView release];
			return;
			
		} else if ([rtcode isEqualToString:@"-9020"]) {
			// TODO: 잘못된 인자가 넘어옴
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"사진 등록 실패" 
																message:@"사진 등록에 실패하였습니다.(-9020)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
			[alertView show];
			[alertView release];
			return;
			
		} else if ([rtcode isEqualToString:@"-9030"]) {
			// TODO: 처리 오류
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"사진 등록 실패" 
																message:@"사진 등록 처리중 오류가 발생하여 사진 등록에 실패 하였습니다.(-9030)" 
															   delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
			[alertView show];
			[alertView release];
			return;
			
		} else {
			// TODO: 기타오류 예외처리 필요
			NSString* arrormsg = [NSString stringWithFormat:@"%@",rtcode];
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"사진 등록 실패" 
																message:[NSString stringWithFormat:@"%@", arrormsg]
															   delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
			[alertView show];
			[alertView release];
			return;
		}
	}
	
}

							  
							  

							  
							  
-(void)syncImageDataSaveDB:(NSArray*)ImageDataArray {
	for(NSDictionary* usersaveData in ImageDataArray){
//		self.personInfo.USERIMAGE =  UIImageJPEGRepresentation(self.addUserImage, 1.0f);
		[self.personInfo setValue:[usersaveData objectForKey:@"THUMBNAILURL"] forKey:@"THUMBNAILURL"];
//		if([usersaveData objectForKey:@"RPKEY"] != nil)
//			[self.saveUserData setValue:[usersaveData objectForKey:@"RPKEY"] forKey:@"RPKEY"];
//		NSLog(@"thumbnail %@", [usersaveData objectForKey:@"THUMBNAILURL"]);
		NSString* sql = [NSString stringWithFormat:@"UPDATE %@ SET THUMBNAILURL = ? WHERE ID = ?",[UserInfo tableName]];
		
		NSLog(@"syncImg");
		
		[UserInfo findWithSqlWithParameters:sql, personInfo.THUMBNAILURL,personInfo.ID, nil];
	}
	[[UserInfo database] commit];
	
	[self.personDelegate updatePersonInfo:personInfo];
	

//20101022	[self.tableView reloadData];
//	[self.navigationController popViewControllerAnimated:YES];
}

-(void)syncDataDeleteDB:(NSString*)userID withRevisionPoint:(NSString *)revisionPoint{
	
	NSString* sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE ID = ?",[UserInfo tableName]];
	
	[UserInfo findWithSqlWithParameters:sql, userID, nil];
	
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
	
	[self.personDelegate deletePersonInfo:personInfo];
	if(self.parentController != nil){
		[self.parentController.navigationController popViewControllerAnimated:YES];
	}else {
		[self.navigationController popViewControllerAnimated:YES];
	}

}



@end