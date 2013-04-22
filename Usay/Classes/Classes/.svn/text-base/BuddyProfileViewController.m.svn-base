//
//  BuddyProfileViewController.m
//  USayApp
//
//  Created by Jong-Sung Park on 10. 6. 13..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "BuddyProfileViewController.h"
#import "AddressDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "HttpAgent.h"
#import "json.h"
#import "USayHttpData.h"
#import "CheckPhoneNumber.h"
#import "NSArray-NestedArrays.h"
#import "ItemValueDisplay.h"
#import "GroupInfo.h"
#import "UserInfo.h"
#import "UIImageView+WebCache.h"
#import "ProfileInfo.h"
#import <objc/runtime.h>
#import "SayViewController.h"
#import "CellMsgListData.h"
#import "CellMsgData.h"
#import "USayAppAppDelegate.h"
#import "MessageInfo.h"
#import "openImgViewController.h"
//#import "MyDeviceClass.h"			// sochae 2010.09.11 - UI Position
#import "USayDefine.h"				// sochae 2010.10.08


#define kTagMainPhotoView		8101
#define kTagTitleLabel			8102
#define kTagSubTitleLabel		8103
#define kTagSubOrgLabel			8104
#define kTagSubImageView		8105
#define kTagSubPhotoview1		8106
#define kTagSubPhotoview2		8107
#define kTagSubPhotoview3		8108
#define kTagSubPhotoview4		8109
#define kTagSubPhotoview5		8110


#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation BuddyProfileViewController
@synthesize buddyTableView;
@synthesize parentController, profileUserData, beforeGroupID;
@synthesize  tableItem, tableArray, profileKey, userFormatted, userProfile;//cellTitleLabel, cellValueLabel,

#pragma mark -
#pragma mark View lifecycle
-(void)viewWillAppear:(BOOL)animated {
	NSLog(@"--------------------APPEAR----------------------");
	[parentController.navigationController.navigationBar setHidden:NO];
	[super viewWillAppear:animated];
}

- (void)viewDidLoad {
	NSLog(@"didLoad");
//	if(isMemoryWarning == YES){
//		isMemoryWarning = NO;
//		[super viewDidLoad];
//		return;
//	}
    [super viewDidLoad];
	
//	isMemoryWarning = NO;
	NSArray *section1 = [NSArray arrayWithObjects:@"그룹", nil];
	NSArray *section2 = [NSArray arrayWithObjects:@"핸드폰", @"이메일", nil];
	NSArray *section3 = [NSArray arrayWithObjects:@"친구차단", nil];
	self.tableItem = [NSDictionary dictionaryWithObjectsAndKeys: section1,@"section0",section2,@"section1",section3,@"section2",nil];

	self.userProfile = [[ProfileInfo alloc] init];	
	self.view.backgroundColor = ColorFromRGB(0xedeff2);
	
	[self createCustomHeaderView];
	[self addCustomFooterView];
	
	
	NSArray* currentUser = [UserInfo findByColumn:@"RPKEY" value:self.profileKey];
	self.profileUserData = [currentUser objectAtIndex:0];
	self.tableArray = [GroupInfo findByColumn:@"ID" value:self.profileUserData.GID];
	
	/*
	GroupInfo* cellGroupName = [self.tableArray objectAtIndex:0];
	
	NSLog(@"그룹명은 %@", cellGroupName.GROUPTITLE);
	*/
	
	self.buddyTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	

}


-(void)imgClick
{
	NSLog(@"imgClick");
	NSString *photoUrl = [NSString stringWithFormat:@"%@/008", profileUserData.REPRESENTPHOTO];
	
	
	UIImageView *mainImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
	[mainImageView setImageWithURL:[NSURL URLWithString:photoUrl]];
	
	
//	NSLog(@"photourl = %@", photoUrl);
	
	
	
	
	openImgViewController *pushView = [[openImgViewController alloc] init];
	
//	UIImage *tmpImg =[UIImage imageWithData:profileUserData.USERIMAGE];

	UIImage *tmpImg = mainImageView.image;
	[mainImageView release];
	
	if(tmpImg)
	{
	UIImageView *fullImg = [[UIImageView alloc] initWithImage:tmpImg];
	[fullImg setFrame:CGRectMake(0, 0, 320, 460)];
	[pushView.view addSubview:fullImg];
	[parentController.navigationController pushViewController:pushView animated:NO];
		[parentController.navigationController.navigationBar setHidden:YES];
		[fullImg release];
		
	}
	[pushView release];
	
}


-(void) createCustomHeaderView {
	
	
	NSLog(@"createCustomHeaderView");
	
	UIView *customHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 90.0f)];
	customHeaderView.backgroundColor = [UIColor clearColor];
	
	
	
	
	imgButton = [UIButton buttonWithType:UIButtonTypeCustom];
	imgButton.frame=CGRectMake(0, 0, 64, 64);
	
	UIImageView* representImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];

	
	if (profileUserData.REPRESENTPHOTO && [profileUserData.REPRESENTPHOTO length] > 0) {
		NSString *photoUrl = [NSString stringWithFormat:@"%@/012", profileUserData.REPRESENTPHOTO];
		
		NSLog(@"photo url= %@", photoUrl);
		
		NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:photoUrl]];
		
	
		[imgButton setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
		[imgButton setImage:[UIImage imageWithData:data] forState:UIControlStateHighlighted];
		[representImage release];
		
	}
	else {
	
			[imgButton setImage:[UIImage imageNamed:@"img_Addressbook_default.png"] forState:UIControlStateNormal];
			[imgButton setImage:[UIImage imageNamed:@"img_Addressbook_default.png"] forState:UIControlStateHighlighted];
		
	}
	
	[imgButton addTarget:self action:@selector(imgClick) forControlEvents:UIControlEventTouchUpInside];

	
	
	
//	UIImageView *mainPhotoView = [[UIImageView alloc] initWithFrame:CGRectMake(32.0f, 17.0f, 64.0f, 64.0f)];
	UIView *mainPhotoView = [[UIView alloc] initWithFrame:CGRectMake(32.0f, 17.0f, 64.0f, 64.0f)];

	[mainPhotoView setBackgroundColor:[UIColor clearColor]];
	
	
	
	mainPhotoView.contentMode = UIViewContentModeScaleAspectFit;
//	[mainPhotoView setBackgroundColor:[UIColor clearColor]];
//	[mainPhotoView setImage:[[UIImage imageNamed:@"img_Addressbook_default.png"] stretchableImageWithLeftCapWidth:5.0 topCapHeight:0.0]];
	mainPhotoView.layer.masksToBounds = YES;
//	mainPhotoView.layer.borderWidth = 1.0;
	[mainPhotoView.layer setCornerRadius:5.0];
	[mainPhotoView setClipsToBounds:YES];
	mainPhotoView.tag = kTagMainPhotoView;
	 
	 
	 
	
	
	[mainPhotoView addSubview:imgButton];
	
	[customHeaderView addSubview:mainPhotoView];
	[mainPhotoView release];
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//	assert(nameLabel != nil);
	[nameLabel setFont:[UIFont boldSystemFontOfSize:18.0]];
	[nameLabel setBackgroundColor:[UIColor clearColor]];
	[nameLabel setTextColor:ColorFromRGB(0x23232a)];
	nameLabel.tag = kTagTitleLabel;
	[customHeaderView addSubview:nameLabel];
	[nameLabel setFrame:CGRectMake(109.0f, 23.0f, 180.0f, 20.0f)];
	[nameLabel release];
	
	UILabel *prMsgLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//	assert(prMsgLabel != nil);
	[prMsgLabel setFont:[UIFont boldSystemFontOfSize:12.0]];
	[prMsgLabel setBackgroundColor:[UIColor clearColor]];
	[prMsgLabel setTextColor:ColorFromRGB(0x7c7c86)];
	prMsgLabel.tag = kTagSubTitleLabel;
	[customHeaderView addSubview:prMsgLabel];
	[prMsgLabel setFrame:CGRectMake(109.0f, 43.0f, 180.0f, 15.0f)];
	[prMsgLabel release];
	
	UILabel *organizationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//	assert(organizationLabel != nil);
	[organizationLabel setFont:[UIFont boldSystemFontOfSize:12.0]];
	[organizationLabel setBackgroundColor:[UIColor clearColor]];
	[organizationLabel setTextColor:ColorFromRGB(0x2284ac)];
	organizationLabel.tag = kTagSubOrgLabel;
	[customHeaderView addSubview:organizationLabel];
	[organizationLabel setFrame:CGRectMake(109.0f, 59.0f, 180.0f, 15.0f)];
	[organizationLabel release];

	 
	
	
/*원래 소스
	UIView *customHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 90.0f)];
	customHeaderView.backgroundColor = [UIColor clearColor];
	
	UIImageView *mainPhotoView = [[UIImageView alloc] initWithFrame:CGRectMake(32.0f, 17.0f, 64.0f, 64.0f)];
	mainPhotoView.contentMode = UIViewContentModeScaleAspectFit;
	[mainPhotoView setBackgroundColor:[UIColor clearColor]];
	[mainPhotoView setImage:[[UIImage imageNamed:@"img_Addressbook_default.png"] stretchableImageWithLeftCapWidth:5.0 topCapHeight:0.0]];
	mainPhotoView.layer.masksToBounds = YES;
	//	mainPhotoView.layer.borderWidth = 1.0;
	[mainPhotoView.layer setCornerRadius:5.0];
	[mainPhotoView setClipsToBounds:YES];
	mainPhotoView.tag = kTagMainPhotoView;
	
	[customHeaderView addSubview:mainPhotoView];
	[mainPhotoView release];
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	//	assert(nameLabel != nil);
	[nameLabel setFont:[UIFont boldSystemFontOfSize:18.0]];
	[nameLabel setBackgroundColor:[UIColor clearColor]];
	[nameLabel setTextColor:ColorFromRGB(0x23232a)];
	nameLabel.tag = kTagTitleLabel;
	[customHeaderView addSubview:nameLabel];
	[nameLabel setFrame:CGRectMake(109.0f, 23.0f, 180.0f, 20.0f)];
	[nameLabel release];
	
	UILabel *prMsgLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	//	assert(prMsgLabel != nil);
	[prMsgLabel setFont:[UIFont boldSystemFontOfSize:12.0]];
	[prMsgLabel setBackgroundColor:[UIColor clearColor]];
	[prMsgLabel setTextColor:ColorFromRGB(0x7c7c86)];
	prMsgLabel.tag = kTagSubTitleLabel;
	[customHeaderView addSubview:prMsgLabel];
	[prMsgLabel setFrame:CGRectMake(109.0f, 43.0f, 180.0f, 15.0f)];
	[prMsgLabel release];
	
	UILabel *organizationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	//	assert(organizationLabel != nil);
	[organizationLabel setFont:[UIFont boldSystemFontOfSize:12.0]];
	[organizationLabel setBackgroundColor:[UIColor clearColor]];
	[organizationLabel setTextColor:ColorFromRGB(0x2284ac)];
	organizationLabel.tag = kTagSubOrgLabel;
	[customHeaderView addSubview:organizationLabel];
	[organizationLabel setFrame:CGRectMake(109.0f, 59.0f, 180.0f, 15.0f)];
	[organizationLabel release];
	*/		 
	
	 /*		 
	UIImage *seperatorImage = [[UIImage imageNamed:@"profileSeperator.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
	UIImageView *seperatorImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
	[seperatorImageView initWithImage:seperatorImage];
	[seperatorImageView setFrame:CGRectMake(32.0f, 91, self.view.frame.size.width-64.0f, 2)];
	[customHeaderView addSubview:seperatorImageView];
	[seperatorImageView release];
		 
	UIView *subImageView =[[UIView alloc] initWithFrame:CGRectMake(0, 94.0f, self.view.frame.size.width, 62.0f)];
	[subImageView setBackgroundColor:[UIColor clearColor]];
	 subImageView.tag = kTagSubImageView;
	 
	UIImageView *subPhotoView1 = [[UIImageView alloc]initWithFrame:CGRectMake(32.0f, 7.0f, 41.0f, 41.0f)];
	 [subPhotoView1.layer setBorderColor:[UIColor colorWithWhite:3 alpha:0.5].CGColor];
	 [subPhotoView1.layer setCornerRadius:5.0];
	 [subPhotoView1 setClipsToBounds:YES];
	 subPhotoView1.image = [UIImage imageNamed:@"img_default.png"];
	 subPhotoView1.tag = kTagSubPhotoview1;
	 
	 [subImageView addSubview:subPhotoView1];
	 [subPhotoView1 release];
	 	 
	 UIImageView *subPhotoView2 = [[UIImageView alloc]initWithFrame:CGRectMake(86.0f, 7.0f, 41.0f, 41.0f)];
	 [subPhotoView2.layer setBorderColor:[UIColor colorWithWhite:3 alpha:0.5].CGColor];
	 [subPhotoView2.layer setCornerRadius:5.0];
	 [subPhotoView2 setClipsToBounds:YES];
	 subPhotoView2.image = [UIImage imageNamed:@"img_default.png"];
	 subPhotoView2.tag = kTagSubPhotoview2;
	 
	 [subImageView addSubview:subPhotoView2];
	 [subPhotoView2 release];
	 
	 UIImageView *subPhotoView3 = [[UIImageView alloc]initWithFrame:CGRectMake(140.0f, 7.0f, 41.0f, 41.0f)];
	 [subPhotoView3.layer setBorderColor:[UIColor colorWithWhite:3 alpha:0.5].CGColor];
	 [subPhotoView3.layer setCornerRadius:5.0];
	 [subPhotoView3 setClipsToBounds:YES];
	 subPhotoView3.image = [UIImage imageNamed:@"img_default.png"];
	 subPhotoView3.tag = kTagSubPhotoview3;
	 
	 [subImageView addSubview:subPhotoView3];
	 [subPhotoView3 release];
	 
	 UIImageView *subPhotoView4 = [[UIImageView alloc]initWithFrame:CGRectMake(194.0f, 7.0f, 41.0f, 41.0f)];
	 [subPhotoView4.layer setBorderColor:[UIColor colorWithWhite:3 alpha:0.5].CGColor];
	 [subPhotoView4.layer setCornerRadius:5.0];
	 [subPhotoView4 setClipsToBounds:YES];
	 subPhotoView4.image = [UIImage imageNamed:@"img_default.png"];
	 subPhotoView4.tag = kTagSubPhotoview4;
	 
	 [subImageView addSubview:subPhotoView4];
	 [subPhotoView4 release];
	 
	 UIImageView *subPhotoView5 = [[UIImageView alloc]initWithFrame:CGRectMake(248.0f, 7.0f, 41.0f, 41.0f)];
	 [subPhotoView5.layer setBorderColor:[UIColor colorWithWhite:3 alpha:0.5].CGColor];
	 [subPhotoView5.layer setCornerRadius:5.0];
	 [subPhotoView5 setClipsToBounds:YES];
	 subPhotoView5.image = [UIImage imageNamed:@"img_default.png"];
	 subPhotoView5.tag = kTagSubPhotoview5;
	 
	 [subImageView addSubview:subPhotoView5];
	 [subPhotoView5 release];
	
	 [customHeaderView addSubview:subImageView];
	 [subImageView release];
	*/  
	 self.buddyTableView.tableHeaderView = customHeaderView;
	 [customHeaderView release];
	 
}



-(void)addCustomFooterView {
	
	
	NSLog(@"addCustomFooterView");
	
	UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.buddyTableView.frame.size.width, 60.0)];
	customView.backgroundColor = [UIColor clearColor];
	
	UIImageView* buttonBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile_smstalk_normal.png"]];
	buttonBg.frame = CGRectMake((customView.frame.size.width - buttonBg.frame.size.width)/2, 10.0, 302.0, 38.0);
	[customView addSubview:buttonBg];
	[buttonBg release];
	
	UIImage *btnSayImageNormal = [[UIImage imageNamed:@"btn_profile_talk.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
	UIImage *btnSayImageFocus = [[UIImage imageNamed:@"btn_profile_talk_touch.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];

	UIImage *btnSMSImageNormal = [[UIImage imageNamed:@"btn_profile_sms.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
	UIImage *btnSMSImageFocus = [[UIImage imageNamed:@"btn_profile_sms_touch.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
	UIImage *btnSMSImageDisable = [[UIImage imageNamed:@"btn_profile_sms_dim.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];	// sochae 2010.10.04

	//create the button
	UIButton *sayButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[sayButton setImage:btnSayImageNormal forState:UIControlStateNormal];
	[sayButton setImage:btnSayImageFocus forState:UIControlStateHighlighted];
	[sayButton setFrame:
	 CGRectMake(customView.frame.size.width/2 - btnSayImageFocus.size.width , 10.0, 
				btnSayImageFocus.size.width, btnSayImageFocus.size.height)];
	[sayButton.layer setBorderColor:[UIColor colorWithWhite:0 alpha:0.5].CGColor];
	[sayButton.layer setBorderWidth:0.5];
	[sayButton.layer setCornerRadius:5.0];
	[sayButton setClipsToBounds:YES];	
	[sayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	sayButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	sayButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	//set action of the button
	[sayButton addTarget:self action:@selector(profileSayRequestClicked) forControlEvents:UIControlEventTouchUpInside];
	//add the button to the view
	[customView addSubview:sayButton];
	
	UIButton *smsbutton = [UIButton buttonWithType:UIButtonTypeCustom];
	[smsbutton setImage:btnSMSImageNormal forState:UIControlStateNormal];
	[smsbutton setImage:btnSMSImageFocus forState:UIControlStateHighlighted];
	[smsbutton setImage:btnSMSImageDisable forState:UIControlStateDisabled];	// sochae 2010.10.04

	[smsbutton setFrame:
	 CGRectMake(customView.frame.size.width/2, 10.0, 
				btnSMSImageFocus.size.width, btnSMSImageFocus.size.height)];
	[smsbutton.layer setBorderColor:[UIColor colorWithWhite:0 alpha:0.5].CGColor];
	[smsbutton.layer setBorderWidth:0.5];
	[smsbutton.layer setCornerRadius:5.0];
	[smsbutton setClipsToBounds:YES];	
	[smsbutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	smsbutton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	smsbutton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	//set action of the button
	[smsbutton addTarget:self action:@selector(profileSMSSendClicked) forControlEvents:UIControlEventTouchUpInside];
	//add the button to the view
	[customView addSubview:smsbutton];
	self.buddyTableView.tableFooterView = customView;

	// sochae 2010.10.04 - 버디 프로필 중 phone number 없으면 sms button disable
	if([profileUserData.MOBILEPHONENUMBER length]<=0 && [profileUserData.HOMEPHONENUMBER length]<=0 && [profileUserData.ORGPHONENUMBER length]<=0)
	{
		[smsbutton setEnabled:NO];
	}
	// ~sochae
	[customView release];
	
}

// Usay친구 > 프로필 정보 > sms 보내기 버튼 선택 시
-(void)profileSMSSendClicked
{
	NSLog(@"profileSms");
	NSString* phoneNumber = nil;
	
	if (profileUserData.IPHONENUMBER != nil && [profileUserData.IPHONENUMBER length] > 0) {
		phoneNumber = [NSString stringWithFormat:@"%@", profileUserData.IPHONENUMBER];
	} else if (profileUserData.MOBILEPHONENUMBER && [profileUserData.MOBILEPHONENUMBER length] > 0) {
		phoneNumber = [NSString stringWithFormat:@"%@",profileUserData.MOBILEPHONENUMBER];
	}
/*	else {
		UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"SMS 보내기" 
														   message:@"SMS 기능을 사용 하실 수 없는 \n기기 입니다." 
														  delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
		[alertView show];
		[alertView release];

		return;
		
	}
*/
	if (phoneNumber != nil && [phoneNumber length] > 0)
	{
		BOOL bSMSSend = YES;

		Class smsClass = (NSClassFromString(@"MFMessageComposeViewController"));
		if (smsClass != nil && [MFMessageComposeViewController canSendText])
		{
			MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
			controller.body = nil;
			controller.recipients = [NSArray arrayWithObject:phoneNumber];	// your recipient number or self for testing
			controller.messageComposeDelegate = self.parentController;
			
			[self.parentController.navigationController presentModalViewController:controller animated:YES];

			[controller release];              
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
				NSString* telno = [[NSString stringWithFormat:@"sms:%@", phoneNumber] 
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
	} // phoneNumber
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

-(USayAppAppDelegate *)appDelegate {
		return [[UIApplication sharedApplication] delegate];
}


-(void)profileSayRequestClicked{
	
	NSString* rPKey = nil;
	if(profileUserData.RPKEY != nil && [profileUserData.RPKEY length] > 0)
		rPKey = [NSString stringWithFormat:@"%@",profileUserData.RPKEY];
	
	NSString* sayBuddyrpKey = [NSString stringWithFormat:@"%@",rPKey];		
	NSMutableArray *selectUserPKeyArray = [NSMutableArray arrayWithObjects:sayBuddyrpKey, nil];
	if (selectUserPKeyArray && [selectUserPKeyArray count] > 0) {
		NSString *chatSession = [[self appDelegate] chatSessionFrompKey:selectUserPKeyArray];
		if (chatSession && [chatSession length] > 0) {
			// 채팅 대기실에 선택한 Users의 대화방 존재
			CellMsgListData *msgListData = [[self appDelegate] MsgListDataFromChatSession:chatSession];
//			assert(msgListData != nil);
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
			NSString *title = nil;
			@synchronized([self appDelegate].msgListArray) {
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
			if(sayViewController != nil) {
//				sayViewController.title = title;
				
				UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
//				assert(titleView != nil);
				UIFont *titleFont = [UIFont systemFontOfSize:20];

				// sochae 2010.09.11 - UI Position
				//CGRect rect = [MyDeviceClass deviceOrientation];
				CGRect rect = self.view.frame; 
				// ~sochae
				
				CGSize titleStringSize = [title sizeWithFont:titleFont constrainedToSize:(CGSizeMake(rect.size.width-120.0, MAXFLOAT))];
				NSLog(@"size x y = %f, %f", titleStringSize.width, titleStringSize.height);
//				assert(titleFont != nil);
				UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, 20.0f)];
//				assert(titleLabel != nil);
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
				sayViewController.navigationItem.titleView.frame = CGRectMake((self.buddyTableView.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, 20.0f);				
				
				
				sayViewController.hidesBottomBarWhenPushed = YES;
				UINavigationController* naviController = self.parentController.navigationController;
				[naviController popToRootViewControllerAnimated:NO];
				
				[naviController pushViewController:sayViewController animated:YES];
				[sayViewController release];
			}
		} else {
			// 현재 대화방리스트에 존재 하지 않음.
			// 새로 대화방 생성해야함.
			UINavigationController* naviController = self.parentController.navigationController;
			
			SayViewController *sayViewController = [[SayViewController alloc] initWithNibNameBuddyListMsgType:@"SayViewController" chatSession:nil type:nil BuddyList:selectUserPKeyArray bundle:nil];
			if(sayViewController != nil) {
				NSString *sayTitle = nil;
				if (profileUserData.FORMATTED && [profileUserData.FORMATTED length] > 0) {
					sayTitle = profileUserData.FORMATTED;
				} else if (profileUserData.PROFILENICKNAME && [profileUserData.PROFILENICKNAME length] > 0) {
					sayTitle = profileUserData.PROFILENICKNAME;
				} else {
					sayTitle = @"이름 없음";
				}
				UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
//				assert(titleView != nil);
				UIFont *titleFont = [UIFont systemFontOfSize:20];

				// sochae 2010.09.11 - UI Position
				//CGRect rect = [MyDeviceClass deviceOrientation];
				CGRect rect = self.view.frame;
				// ~sochae
				
				CGSize titleStringSize = [sayTitle sizeWithFont:titleFont constrainedToSize:(CGSizeMake(rect.size.width-120.0, MAXFLOAT))];
//				assert(titleFont != nil);
				UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, 20.0f)];
//				assert(titleLabel != nil);
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
				sayViewController.navigationItem.titleView.frame = CGRectMake((self.buddyTableView.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, 20.0f);				

				self.tabBarController.selectedIndex = 1;
				sayViewController.hidesBottomBarWhenPushed = YES;
				[naviController pushViewController:sayViewController animated:YES]; 
				[sayViewController release];
			}
		}
	} else {
		// 선택한 user 없음 
	}
}

- (void)viewDidDisappear:(BOOL)animated 
{
	NSLog(@"didDisAppear");
    [super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	
	NSLog(@"sectioncount %i",[tableItem count]);
	
	tableView.backgroundColor = ColorFromRGB(0xedeff2);
#if TARGET_IPHONE_SIMULATOR	
	NSLog(@"sectioncount %i",[tableItem count]);
#endif	
    return [tableItem count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSString *key = [NSString stringWithFormat:@"section%i",section];
#if TARGET_IPHONE_SIMULATOR	
	NSLog(@"section%i rowcount %i",section,[[tableItem objectForKey:key] count]);
#endif
		NSLog(@"section%i rowcount %i",section,[[tableItem objectForKey:key] count]);
	return [[tableItem objectForKey:key] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"detailViewIdentifier";
	NSLog(@"return cell.....");
	
	
	
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier]autorelease];
		cell.textLabel.textColor = ColorFromRGB(0x2284ac);
		cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0];
		cell.textLabel.textAlignment = UITextAlignmentLeft;
		
		cell.detailTextLabel.textColor = ColorFromRGB(0x7c7c86);
		cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:17.0];
		cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
		
	}
	
	NSString *key = [NSString stringWithFormat:@"section%i",[indexPath section]];
	NSArray *item = [self.tableItem objectForKey:key];
	
	if([key isEqualToString:@"section1"]){
		if([[item objectAtIndex:[indexPath row]] isEqualToString:@"핸드폰"]){
			if(self.userProfile.IPHONENUMBER != nil && [self.userProfile.IPHONENUMBER length] > 0)
				cell.detailTextLabel.text = [CheckPhoneNumber convertPhoneInsertHyphen:(NSMutableString*)self.userProfile.IPHONENUMBER];
			else if(self.userProfile.MOBILEPHONENUMBER != nil && [self.userProfile.MOBILEPHONENUMBER length] > 0)
				cell.detailTextLabel.text = [CheckPhoneNumber convertPhoneInsertHyphen:(NSMutableString*)self.userProfile.MOBILEPHONENUMBER];
			else {
				cell.detailTextLabel.text = @"";
			}

			cell.textLabel.text = [item objectAtIndex:[indexPath row]];
		}else if([[item objectAtIndex:[indexPath row]] isEqualToString:@"이메일"]){
			if(self.userProfile.EMAILADDRESS != nil && [self.userProfile.EMAILADDRESS count] > 0){
				cell.detailTextLabel.text = [self.userProfile.EMAILADDRESS objectAtIndex:0];
			}
			cell.textLabel.text = [item objectAtIndex:[indexPath row]];
			
		}
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}else if([key isEqualToString:@"section0"]){
		GroupInfo* cellGroupName = [self.tableArray objectAtIndex:0];
		cell.detailTextLabel.text = cellGroupName.GROUPTITLE;
		cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
		cell.textLabel.text = [item objectAtIndex:[indexPath row]];
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	}else if([key isEqualToString:@"section2"]){
		cell.detailTextLabel.text = [item objectAtIndex:[indexPath row]];
		UISwitch* blockSwitch = [[[UISwitch alloc] initWithFrame:CGRectMake(170.0, 5.0, 0.0, 0.0)] autorelease];
		[blockSwitch addTarget:self action:@selector(switchStatusChanged:) forControlEvents:UIControlEventValueChanged];
		[cell setAccessoryView:blockSwitch];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
//
	return cell;
}

#pragma mark -
#pragma mark UITableView delegate Method
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 56.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	
	DebugLog(@"cell row = %d", indexPath.row);
	
    // Navigation logic may go here. Create and push another view controller.
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	NSInteger section = [indexPath section];
	NSInteger row = [indexPath row];
	UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
	if(section == 1){
		NSString *key = [NSString stringWithFormat:@"section%i",[indexPath section]];
		NSArray *item = [self.tableItem objectForKey:key];
		NSString* phoneNumber = nil;
		if([[item objectAtIndex:row] isEqualToString:@"핸드폰"]){
			if([cell.detailTextLabel.text length] > 0)
				phoneNumber = cell.detailTextLabel.text;
			
			if(phoneNumber != nil && [phoneNumber length] > 0){
				NSString* telno = [[NSString stringWithFormat:@"tel:%@",phoneNumber] 
								   stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				
				BOOL open = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telno]];
				if(open == NO){
					UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"전화 걸기" 
																	   message:@"전화 기능을 사용 하실 수 없는 \n기기 입니다." 
																	  delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
					[alertView show];
					[alertView release];
				}
			}
		}else if([[item objectAtIndex:row] isEqualToString:@"이메일"]){
			NSString* emailAddr = nil;
			if([cell.detailTextLabel.text length] > 0)
				emailAddr = cell.detailTextLabel.text;
			
			if(emailAddr != nil && [emailAddr length] > 0){
				Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
				if (mailClass != nil){
					if([mailClass canSendMail]){
						MFMailComposeViewController* mailController = [[MFMailComposeViewController alloc] init];
						mailController.mailComposeDelegate = self.parentController;
						[mailController setToRecipients:[NSArray arrayWithObject:emailAddr]];
						[self.parentController presentModalViewController:mailController animated:YES];
						[mailController release];
					}else {
						NSString* emailAddress = [[NSString stringWithFormat:@"mailto:%@",emailAddr] 
										   stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
						
						BOOL open = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:emailAddress]];
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
	}
	if(section == 0){
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

		NSString *controllerClassName = [NSString stringWithFormat:@"ManagedObjectSingleSelectionListEditor"];
		NSString *rowLabel = NSLocalizedString(@"이동할 주소선택", @"이동할 주소선택");
		NSString *rowKey = @"moveGroup";
		NSArray  *rowArguments = [[[NSArray alloc] initWithObjects:
								  // Section 1,
								  [NSArray arrayWithObjects:
								   [NSDictionary dictionaryWithObject:groupList
															   forKey:@"list"], nil],
								  // Section 2
								  [NSNull null],
								  
								  [NSNull null],
								  // Sentinel
								  nil] autorelease];
		
		Class controllerClass = NSClassFromString(controllerClassName);
		ManagedObjectAttributeEditor *controller = [[controllerClass alloc] initWithStyle:UITableViewStyleGrouped] ;
		
		UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
		controller.keypath = rowKey;
		controller.labelString = rowLabel;
//		controller.title = rowLabel;
		controller.delegate = self;
		[controller setValue:cell.detailTextLabel.text forKey:@"selectedValue"];
		
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
		[parentController.navigationController pushViewController:controller animated:YES];
		[controller release];
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
	
	NSLog(@"updateDataValue");
	// 그룹 수정. 통신 루틴 타게 처리
	NSIndexPath* index = [NSIndexPath indexPathForRow:0 inSection:0];
	UITableViewCell* cell = [self.buddyTableView cellForRowAtIndexPath:index];
	cell.detailTextLabel.text = value;
	NSArray* groupArr = [GroupInfo findByColumn:@"GROUPTITLE" value:value];
	GroupInfo* profileGroup = [groupArr objectAtIndex:0];
	[self requestProfileUpdateContact:profileGroup.ID];
}

-(void)updateDataWithArray:(NSArray*)value forkey:(NSString*)key {

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
	self.buddyTableView = nil;

	[super viewDidUnload];
	
}


- (void)dealloc {
	[tableItem release];
	[tableArray release];
	[buddyTableView release];
	[parentController release];
	[profileKey release];
	[userProfile release];
	[userFormatted release];
	[profileUserData release];
    [super dealloc];
}

#pragma mark -
#pragma mark profile Info obtain Method
-(void)requestLoadSimpleProfile:(NSString*)profilerKey {
	
	NSLog(@"requestLoadSimple");
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadSimpleProfile:) name:@"loadSimpleProfile" object:nil];
	
	NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:
								profilerKey, @"fPkey",
								[[self appDelegate] getSvcIdx], @"svcidx",
								nil];
//	assert(bodyObject != nil);
	SBJSON *json = [[SBJSON alloc]init];
	[json setHumanReadable:YES];
	NSString* temp = [json stringWithObject:bodyObject error:nil];
	[json release];
	NSLog(@"%@",temp);
	// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
	USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"loadSimpleProfile" andWithDictionary:bodyObject timeout:10]autorelease];
//	assert(data != nil);
	[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
}

-(void)loadSimpleProfile:(NSNotification *)notification {
	
	
	NSLog(@"loadSimpleProfile noti");
	
	USayHttpData *data = (USayHttpData*)[notification object];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"loadSimpleProfile" object:nil];
	if (data == nil) {
		// 200 이외의 에러
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"실패" message:@"네트워크 문제로 \n데이터를 불로오는데 실패하였습니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
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
	rtcode = [dic objectForKey:@"rtcode"];
	if ([rtcode isEqualToString:@"0"]) {			// success
		NSString *rtType = [dic objectForKey:@"rttype"];
		if ([rtType isEqualToString:@"map"]) {
			// Key and Dictionary as its value type
			NSDictionary *addressDic = [dic objectForKey:@"map"];
			NSArray* keyArray = [addressDic allKeys];
			
			
			for(NSString* keyStr in keyArray){
				NSAutoreleasePool* varpool = [[NSAutoreleasePool alloc] init];
				unsigned int numIvars = 0;
				Ivar* ivars = class_copyIvarList([self.userProfile class], &numIvars);
				for(int i = 0; i < numIvars; i++) {
					Ivar thisIvar = ivars[i];
					NSString * classkey = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
					if([classkey isEqualToString:[keyStr uppercaseString]]){
						if([addressDic objectForKey:keyStr] != nil)
							[self.userProfile setValue:[addressDic objectForKey:keyStr] forKey:classkey];
					}
					
				}
				if(numIvars > 0)free(ivars);
				[varpool release];
			}
			
			
			[self syncLoadSimpleProfile];
		} else {
			// 예외처리
		}
	} else if ([rtcode isEqualToString:@"4040"]) {	// 친구 정보를 찾을 수 없음
		//alert 처리후에 다시 스위치를 off상태로 변경
	} else if ([rtcode isEqualToString:@"-9020"]) {	// 잘못 된 인자가 넘어
		//예외 처리후 스위치 off상태로 변경
	} else if ([rtcode isEqualToString:@"-9030"]) {	// 처리 오류
		//예외 처리후 스위치 off상태로 변경
	} else {
		// TODO: 실패 예외처리 필요
		// fail (-8080 이외 기타오류)
		//예외 처리후 스위치 off상태로 변경
	}
	
		
}

-(void) syncLoadSimpleProfile {
	
	self.tableArray = [GroupInfo findByColumn:@"ID" value:self.profileUserData.GID];
	
	NSLog(@"==========================================심플 프로파일..========================");
	
	NSString *photoUrl = [NSString stringWithFormat:@"%@", self.userProfile.REPRESENTPHOTO];
//	UIView *mainImageView = (UIView *)[self.view viewWithTag:kTagMainPhotoView];
//	assert(mainImageView != nil);
	
	NSLog(@"pre url =%@", photoUrl);
	
	
//	NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:photoUrl]];

	UIImageView *mainImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
	[mainImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/012", photoUrl]]
			  placeholderImage:[UIImage imageNamed:@"img_Addressbook_default.png"]];
	
	
	
	
	[imgButton setBackgroundImage:mainImageView.image forState:UIControlStateNormal];
//	[imgButton setBackgroundImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
	

	
	
	
	
	

	
	if(photoUrl != nil && [photoUrl length] > 0) {
		profileUserData.REPRESENTPHOTO = [NSString stringWithFormat:@"%@",photoUrl];
	}
	
/*	int cnt = 0;
	for(NSString* photourl in self.userProfile.PHOTOS){
		UIImageView *imageView = (UIImageView *)[self.view viewWithTag:kTagSubPhotoview1+cnt];
//		assert(imageView != nil);
		[imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/011", photoUrl]]
				  placeholderImage:[UIImage imageNamed:@"img_default.png"]];
		cnt++;
	}
*/	
	if(self.profileUserData.FORMATTED != nil && [self.profileUserData.FORMATTED length] > 0){
		UILabel *titleLabel = (UILabel *)[self.view viewWithTag:kTagTitleLabel];
		titleLabel.text = self.profileUserData.FORMATTED;
	}else if(self.userProfile.NICKNAME != nil && [self.userProfile.NICKNAME length] > 0){
		UILabel *titleLabel = (UILabel *)[self.view viewWithTag:kTagTitleLabel];
		titleLabel.text = self.userProfile.NICKNAME;
		profileUserData.PROFILENICKNAME = [NSString stringWithFormat:@"%@",self.userProfile.NICKNAME];
	}else {
		UILabel *titleLabel = (UILabel *)[self.view viewWithTag:kTagTitleLabel];
		titleLabel.text = @"이름 없음";
	}
	
	UILabel *subTitleLabel = (UILabel *)[self.view viewWithTag:kTagSubTitleLabel];
	subTitleLabel.text = self.userProfile.STATUS;
	
	NSLog(@"subtitle = %@", subTitleLabel.text);
	
	profileUserData.STATUS = self.userProfile.STATUS;
	
	int nCount = [self.userProfile.ORGANIZATION count];
	
	if (nCount > 0) {
		if(self.userProfile.ORGANIZATION != nil && [self.userProfile.ORGANIZATION count] > 0){
			UILabel *organizationLabel = (UILabel *)[self.view viewWithTag:kTagSubOrgLabel];
			organizationLabel.text = [self.userProfile.ORGANIZATION objectAtIndex:0];
		}
	}
	
	[profileUserData saveData];
	[self.buddyTableView reloadData];	
}
#pragma mark -
#pragma mark switch control event Method
-(void)switchStatusChanged:(id)sender {
	
	NSLog(@"switchStatus Change");
	
	UISwitch *control = (UISwitch*)sender;
	BOOL switchon = control.on;
	if(switchon == NO){
		control.on = YES;
		return;
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(BlockUserOk:) name:@"BlockUserOk" object:nil];
	// value, key, value, key ...
	NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:
								self.profileKey, @"fPkey",
								@"block", @"commStatus",
								[[self appDelegate] getSvcIdx], @"svcidx",
								nil];
//	assert(bodyObject != nil);
	// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
	USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"toggleCommStatus" andWithDictionary:bodyObject timeout:10]autorelease];
//	assert(data != nil);
	data.subApi = @"BlockUserOk";
	[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
}

-(void)BlockUserOk:(NSNotification *)notification {
	NSLog(@"차단노티");
	USayHttpData *data = (USayHttpData*)[notification object];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"BlockUserOk" object:nil];
	if (data == nil) {
		// 200 이외의 에러
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"실패" message:@"네트워크 문제로 \n차단하는데 실패하였습니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
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
	rtcode = [dic objectForKey:@"rtcode"];
	if ([rtcode isEqualToString:@"0"]) {			// success
		NSString *rtType = [dic objectForKey:@"rttype"];
		if ([rtType isEqualToString:@"map"]) {
			// Key and Dictionary as its value type
			NSDictionary *addressDic = [dic objectForKey:@"map"];
//			assert(addressDic != nil);
			NSString *commStatus = [addressDic objectForKey:@"commStatus"];	// commStatus  normal:차단해제   block:차단
//			assert(commStatus != nil);
			if ([commStatus isEqualToString:@"block"]) {
				//차단 처리됨
				NSString *rPkey = [addressDic objectForKey:@"fPkey"];
				[self syncUpdateProfile:rPkey];
			}
		} else {
			// 예외처리
		}
	} else if ([rtcode isEqualToString:@"4040"]) {	// 친구 정보를 찾을 수 없음
		//alert 처리후에 다시 스위치를 off상태로 변경
	} else if ([rtcode isEqualToString:@"-9020"]) {	// 잘못 된 인자가 넘어
		//예외 처리후 스위치 off상태로 변경
	} else if ([rtcode isEqualToString:@"-9030"]) {	// 처리 오류
		//예외 처리후 스위치 off상태로 변경
	} else {
		// TODO: 실패 예외처리 필요
		// fail (-8080 이외 기타오류)
		//예외 처리후 스위치 off상태로 변경
	}
}

-(void) syncUpdateProfile:(NSString*)userPkey {
	
	NSLog(@"syncUpdateProfile");
	
	NSArray* userArray = [UserInfo findByColumn:@"RPKEY" value:userPkey];
	for(UserInfo* updateUser in userArray){
		updateUser.ISBLOCK = [NSString stringWithFormat:@"Y"];
		[updateUser saveData];
		[self.parentController blockedfileInfo:updateUser];
	}

	[parentController.navigationController popViewControllerAnimated:YES];
}
#pragma mark -
#pragma mark address data update Method
-(void)requestProfileUpdateContact:(NSString*)groupID{
	
	NSLog(@"requestProfileUpdateContace");
	
	//사용자 정보 저장
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateContact:) name:@"updateContact" object:nil];
	
	NSString	*body = nil;
	
	NSArray* currentUser = [UserInfo findByColumn:@"RPKEY" value:self.profileKey];
	UserInfo* willUpUserInfo = [currentUser objectAtIndex:0];
	self.beforeGroupID = [NSString stringWithFormat:@"%@", willUpUserInfo.GID];
	NSMutableDictionary* userDic = [NSMutableDictionary dictionary];
	NSAutoreleasePool* varpool = [[NSAutoreleasePool alloc] init];
	unsigned int numIvars = 0;
	Ivar* ivars = class_copyIvarList([willUpUserInfo class], &numIvars);
	for(int i = 0; i < numIvars; i++) {
		Ivar thisIvar = ivars[i];
		NSString * key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
		if([willUpUserInfo valueForKey:key]){
			if([key isEqualToString:@"ID"]){
				[userDic setObject:[willUpUserInfo valueForKey:key] forKey:@"id"];
			}else if([key isEqualToString:@"GID"]){
				[userDic setObject:groupID forKey:@"gid"];
			}else {
				continue;
			}
		}
	}
	if(numIvars > 0)free(ivars);
	[varpool release];
	
	[userDic setObject:@"mobile" forKey:@"sidUpdated"];
	[userDic setObject:[[self appDelegate] getSvcIdx] forKey:@"svcidx"];
	
	NSDictionary *bodyObject = [NSDictionary dictionaryWithDictionary:userDic];
	
	SBJSON *json = [[SBJSON alloc]init];
	[json setHumanReadable:YES];
	// 변환
	body = [json stringWithObject:bodyObject error:nil];
	[json release];
	NSLog(@"%@",body);
	
	USayHttpData *data = [[[USayHttpData alloc]initWithRequestData:@"updateContact" andWithDictionary:bodyObject timeout:10]autorelease];
//	assert(data != nil);		
	[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
}

-(void)updateContact:(NSNotification *)notification {
	
	
	
	
	NSLog(@"updateContact");
	
	
	USayHttpData *data = (USayHttpData*)[notification object];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateContact" object:nil];
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
						
						if([[resultkey uppercaseString] isEqualToString:classkey]){
							[userData  setValue:[addressDic objectForKey:resultkey] forKey:classkey];
							[profileUserData setValue:[addressDic objectForKey:resultkey] forKey:classkey];
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
	
	NSLog(@"syncDataSaveDb");
	
	NSString* revisionPoints = nil;
	if(dataArray != nil){
		for(UserInfo* userData in dataArray){
			if(revisionPoint != nil)
				revisionPoints = revisionPoint;
			else
				revisionPoints = userData.RPCREATED;
			
			[userData saveData];
			
		}
	}
	
	if(revisionPoints != nil){
		[[NSUserDefaults standardUserDefaults] setObject:revisionPoints forKey:@"RevisionPoints"];
	}
	
	[self.parentController updateProfileInfo:[dataArray objectAtIndex:0] withBeforeGroupID:self.beforeGroupID];

}

@end

