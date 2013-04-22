//
//  MessageInfoItem.h
//  USayApp
//
//  Created by Jong-Sung Park on 10. 6. 27..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataAccessObject.h"

@interface MessageInfo : DataAccessObject {
	NSNumber* INDEXNO;			// PRIMARY KEY
	
	NSString* CHATSESSION;		// 대화방 고유 키
	NSString* MESSAGEKEY;		// 대화 고유 키
	NSString* MSG;				// 대화 내용
	NSString* MSGTYPE;			// 내용 타입. T:text, P:image, V:movie, J:입장, Q:퇴장, D:날짜+요일
	NSString* PKEY;				// 보낸사람의 PKEY
	NSString* NICKNAME;			// 버디 Nick			(상대방 정보만 있음)
	NSString* PHOTOURL;			// 버디 사진 URL		(상대방 정보만 있음)
	NSString* ISSENDMSG;		// 1 : 발송 메시지   0 : 수신 메시지
	NSString* ISSUCCESS;		// 발송 성공?		-1:실패  0:기본  1:성공
	NSString* PHOTOFILEPATH;	// 업로드/다운로드 사진 파일경로	// ISSENDMSG값이 1 일때 : 업로드한 파일 경로 (Document)   
															// ISSENDMSG값이 0 일때 : 다운로드한 파일 경로(Document)
	NSString* MOVIEFILEPATH;	// 업로드/다운로드 영상 파일경로	// 영상은 모두 다운받아서 실행. (업로드한 영상도 실제 서버에서 다운받아서 실행 해야 함. 로컬에 없음)
															// ISSENDMSG값이 1 일때 : 다운로드한 파일 경로
															// ISSENDMSG값이 0 일때 : 다운로드한 파일 경로

	NSNumber* REGDATE;			// 등록 일자.	unix timestamp
	NSNumber* READMARKCOUNT;	// 읽음 처리 Count
}

@property (nonatomic, retain) NSNumber* INDEXNO;

@property (nonatomic, retain) NSString* CHATSESSION;
@property (nonatomic, retain) NSString* MESSAGEKEY;
@property (nonatomic, retain) NSString* MSG;
@property (nonatomic, retain) NSString* MSGTYPE;
@property (nonatomic, retain) NSString* PKEY;
@property (nonatomic, retain) NSString* NICKNAME;
@property (nonatomic, retain) NSString* PHOTOURL;
@property (nonatomic, retain) NSString* ISSENDMSG;
@property (nonatomic, retain) NSString* ISSUCCESS;
@property (nonatomic, retain) NSString* PHOTOFILEPATH;
@property (nonatomic, retain) NSString* MOVIEFILEPATH;

@property (nonatomic, retain) NSNumber* REGDATE;
@property (nonatomic, retain) NSNumber* READMARKCOUNT;

@end
