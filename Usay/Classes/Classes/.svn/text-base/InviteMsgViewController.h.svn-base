//
//  InviteMsgViewController.h
//  USayApp
//
//  Created by 1team on 10. 7. 8..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

enum InviteType
{
	MsgListType = 0,		// 대기실에서 들어왔을때 (대화)
	MsgType,				// 대화창에서 들어왔을때 (대화)
	AddressGroupSayType,	// 주소록창에서 그룹대화로 들어왔을때 (대화)
	AddressGroupSMSType		// 주소록창에서 그룹SMS로 들어왔을때 (SMS)
};

typedef enum InviteType InviteType;

@class USayAppAppDelegate;

@interface InviteMsgViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate> {
	UITableView			*addressTableView;
	NSMutableArray		*addressGroupArray;
	NSMutableArray		*addressBuddyArray;
	
	NSMutableArray		*selectedAddrGroupUserArray;	// 그룹대화를 할 선택된 대화상대 : NSString class object array. pKey
														// 그룹대화는 PKey Array   그룹SMS는 ID Array
	NSMutableDictionary	*buddyListDictionary;
	
	NSMutableArray		*alreadyJoinUserArray;			// 참여중인 대화상대 : UserInfo class object array
	NSString			*cType;							// 채팅세션 타입 P: 1:1  G: 그룹  nil:신규생성
	
	NSString			*selectedGroupId;				// 그룹대화, 그룹SMS 실행시 선택된 그룹ID만 opened
	
	InviteType			inviteType;
	
	NSString			*navigationTitle;
//	NSMutableArray* allGroups;
	
	BOOL sayFlag;
}

-(id)initWithAlreadyUserInfo:(NSArray*)AlreadyUserInfoArray MsgType:(NSString*)messageCType;
-(id)initWithAddressGroupSay:(NSArray*)selectedGroupUserInfoArray;
-(id)initWithAddressGroupSMS:(NSArray*)selectedGroupUserInfoArray;

-(USayAppAppDelegate *)appDelegate;
- (void)willRotate;
//@property (nonatomic, retain) NSMutableArray* allGroups;
@property (nonatomic, retain) UITableView			*addressTableView;
@property (nonatomic, retain) NSMutableArray		*addressGroupArray;
@property (nonatomic, retain) NSMutableArray		*addressBuddyArray;

@property (nonatomic, retain) NSMutableArray		*selectedAddrGroupUserArray;

@property (nonatomic, retain) NSMutableDictionary	*buddyListDictionary;

@property (nonatomic, retain) NSMutableArray		*alreadyJoinUserArray;
@property (nonatomic, assign) NSString				*cType;
@property (nonatomic, assign) NSString				*selectedGroupId;
@property (nonatomic, assign) NSString				*navigationTitle;


@property (nonatomic) InviteType	inviteType;
@end
