//
//  CellMsgData.h
//  USayApp
//
//  Created by 1team on 10. 7. 1..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CellMsgData : NSObject {
	UIImage		*photoImage;
	UIImage		*mediaImage;
	NSString	*pKey;
	NSString	*nickName;
	NSString	*photoUrl;
	NSString	*contentsMsg;
	NSString	*messagekey;
	NSString	*chatsession;
	NSString	*msgType;			// T:text, P:image, V:movie, J:입장, Q:퇴장, D:날짜+요일
	NSString	*sendMsgSuccess;	// 발송 성공?		-1:실패  0:기본  1:성공 
	NSString	*photoFilePath;		// 
	NSString	*movieFilePath;		//

	NSNumber	*regTime;			// 발송/수신 시간		unix timestamp
	
	CGFloat		mediaProgressPos;	// 업로드 포지션 0.0 ~ 1.0 까지
	NSInteger	readMarkCount;
	BOOL		isSend;				// 보낸메시지, 받은메시지
}

@property (nonatomic, retain) UIImage	*photoImage;
@property (nonatomic, retain) UIImage	*mediaImage;

@property (nonatomic, retain) NSString	*pKey;
@property (nonatomic, retain) NSString	*nickName;
@property (nonatomic, retain) NSString	*photoUrl;
@property (nonatomic, retain) NSString	*contentsMsg;
@property (nonatomic, retain) NSString	*messagekey;
@property (nonatomic, retain) NSString	*chatsession;
@property (nonatomic, retain) NSString	*msgType;
@property (nonatomic, retain) NSString	*sendMsgSuccess;
@property (nonatomic, retain) NSString	*photoFilePath;
@property (nonatomic, retain) NSString	*movieFilePath;

@property (nonatomic, retain) NSNumber	*regTime;

@property (nonatomic) NSInteger	readMarkCount;
@property (nonatomic) BOOL	isSend;
@property (nonatomic) CGFloat	mediaProgressPos;


@end
