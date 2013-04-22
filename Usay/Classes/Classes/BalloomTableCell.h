//
//  BalloomTableCell.h
//  USayApp
//
//  Created by 1team on 10. 6. 17..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <Foundation/Foundation.h>
//mezzo 프로그래스 색상 변경
#import "PDColoredProgressView.h"

@interface BalloomTableCell : UITableViewCell {
	UIImageView		*photoImageView;
	UIImageView		*contentsImageView;
	
	UIControl		*contentsMsgUIControl;
	
	UIControl		*contentsUIControl;
	UIImageView		*contentsMediaImageView;
	
	UIControl		*failSendContentsUIControl;
	UIImageView		*failSendContentsImageView;
	
//mezzo	UIProgressView	*progressView;
	PDColoredProgressView *progressView;
	UILabel			*contentsLabel;
	UILabel			*nickNameLabel;
	UILabel			*timeLabel;
	UILabel			*readMarkLabel;
	
	CGFloat			progressPosition;
	
	NSString		*nickName;
	NSString		*time;
	NSString		*contentsMsg;
	NSString		*msgType;			// T:text, P:image, V:movie, J:입장, Q:퇴장, D:날짜+요일
	NSInteger		readMarkCount;
	BOOL			isSend;				// 보낸메시지, 받은메시지
	
	NSString		*sendMsgSuccess;			// -1 실패, 0 기본  1 성공
	
	id				parentDelegate;
	NSString		*photoUrl;
}

// text, photo, movie
@property (nonatomic, retain) NSString		*photoUrl;
@property (nonatomic, retain) UIImageView	*photoImageView;
@property (nonatomic, retain) UIImageView	*contentsImageView;
//mezzo @property (nonatomic, retain) UIProgressView *progressView;
@property (nonatomic, retain) PDColoredProgressView *progressView;

@property (nonatomic, retain) UIControl		*contentsMsgUIControl;

@property (nonatomic, retain) UIControl		*contentsUIControl;
@property (nonatomic, retain) UIImageView	*contentsMediaImageView;

@property (nonatomic, retain) UIControl		*failSendContentsUIControl;
@property (nonatomic, retain) UIImageView	*failSendContentsImageView;

@property (nonatomic, retain) UILabel		*contentsLabel;
@property (nonatomic, retain) UILabel		*nickNameLabel;
@property (nonatomic, retain) UILabel		*timeLabel;
@property (nonatomic, retain) UILabel		*readMarkLabel;

@property (nonatomic, retain) NSString		*nickName;
@property (nonatomic, retain) NSString		*time;
@property (nonatomic, retain) NSString		*contentsMsg;
@property (nonatomic, retain) NSString		*msgType;

@property (nonatomic, retain) NSString		*sendMsgSuccess;
@property (nonatomic, assign) id parentDelegate;
@property (nonatomic)		BOOL	isSend;
@property (nonatomic)		NSInteger readMarkCount;
@property (nonatomic)		CGFloat progressPosition;



@end
