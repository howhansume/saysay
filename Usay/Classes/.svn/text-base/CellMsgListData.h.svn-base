//
//  CellMsgListData.h
//  USayApp
//
//  Created by 1team on 10. 6. 24..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MsgUserData : NSObject
{
	NSString	*nickName;
	NSString	*photoUrl;
	NSString	*pKey;
}

@property (nonatomic, retain) NSString *nickName;
@property (nonatomic, retain) NSString *photoUrl;
@property (nonatomic, retain) NSString *pKey;

@end

@interface CellMsgListData : NSObject <NSCopying> {
	UIImage				*representPhotoImage;	// 사진이미지
	NSString			*chatsession;			// chatsession
	NSString			*lastmessagekey;			// lastMsgKey
	NSString			*cType;					// 채팅세션 타입 P: 1:1  G: 그룹
	NSString			*lastMsg;				// lastmsg
	NSString			*lastMsgType;			// lastMsgType	T:text P:photo V:movie
	
	NSString			*lastMsgDate;			// lastMsgDate	// unix timestamp
	NSNumber			*lastUpdateTime;		// lastUpdateTime	대화방이 변경된 마지막 시간	// unix timestamp
	
	NSMutableDictionary	*userDataDic;			// nickNameDictionary	key:pkey	value:msgUserData class
	NSInteger			newMsgCount;			// 메시지리스트 newCount. BadgeNumber 처리시 필요
}

-(id)copyWithZone:(NSZone*)zone;

@property (nonatomic, retain) UIImage				*representPhotoImage;
@property (nonatomic, retain) NSString				*chatsession;
@property (nonatomic, retain) NSString				*lastmessagekey;	// lastMsgKey
@property (nonatomic, retain) NSString				*cType;			
@property (nonatomic, retain) NSString				*lastMsg;
@property (nonatomic, retain) NSString				*lastMsgType;
@property (nonatomic, retain) NSString				*lastMsgDate;
@property (nonatomic, retain) NSNumber				*lastUpdateTime;
@property (nonatomic, retain) NSMutableDictionary	*userDataDic;
@property (nonatomic)		  NSInteger				newMsgCount;

@end
