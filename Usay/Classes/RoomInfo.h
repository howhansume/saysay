//
//  RoomInfo.h
//  USayApp
//
//  Created by Jong-Sung Park on 10. 7. 1..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataAccessObject.h"

@interface RoomInfo : DataAccessObject {
	NSNumber* INDEXNO;					// PRIMARY KEY
	
	NSString* CHATSESSION;				// 대화방 키
	NSString* LASTMESSAGEKEY;			// 마지막 대화 세션키
	NSString* CTYPE;					// 채팅세션 타입 P: 1:1  G: 그룹
	NSString* LASTMSG;					// 마지막 메시지
	NSString* LASTMSGTYPE;				// 마지막 메시지 타입	T:text P:photo V:movie
	
	NSNumber* LASTMSGDATE;				// 마지막 메시지 온 시간		// unix timestamp	13자리
	NSNumber* LASTUPDATETIME;			// 대화방이 변경된 마지막 시간	// unix timestamp	13자리
	NSNumber* NEWMSGCOUNT;				// 신규 메시지 수. tabBar BadgeNumber, app BadgeNumber 처리시 필요

	NSNumber* ISSUCESS;					// 서버 API 수신 성공여부
	NSNumber* PROCESSTIME;				// 서버 기준 시간 (api transaction 관리용)
	// 참고사항 : 대화방 안에 있는 버디 리스트는 MessageUserInfo에서 관리
}

@property (nonatomic, retain) NSNumber* INDEXNO;

@property (nonatomic, retain) NSString* CHATSESSION;
@property (nonatomic, retain) NSString* LASTMESSAGEKEY;
@property (nonatomic, retain) NSString* CTYPE;
@property (nonatomic, retain) NSString* LASTMSG;
@property (nonatomic, retain) NSString* LASTMSGTYPE;


@property (nonatomic, retain) NSNumber* LASTMSGDATE;
@property (nonatomic, retain) NSNumber* LASTUPDATETIME;
@property (nonatomic, retain) NSNumber* NEWMSGCOUNT;

@property (nonatomic, retain) NSNumber* ISSUCESS;
@property (nonatomic, retain) NSNumber* PROCESSTIME;

 @end
