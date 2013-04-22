//
//  MessageInfoItem.m
//  USayApp
//
//  Created by Jong-Sung Park on 10. 6. 27..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "MessageInfo.h"

@implementation MessageInfo

@synthesize INDEXNO, CHATSESSION, MESSAGEKEY, MSG, MSGTYPE, REGDATE, PKEY, NICKNAME, PHOTOURL, ISSENDMSG, ISSUCCESS, PHOTOFILEPATH, MOVIEFILEPATH, READMARKCOUNT;

-(void)dealloc 
{
	if(INDEXNO) {
		[INDEXNO release];
	}
	if(CHATSESSION) {
		[CHATSESSION release];
	}
	if(MESSAGEKEY) {
		[MESSAGEKEY release];
	}
	if(MSG) {
		[MSG release];
	}
	if(MSGTYPE) {
		[MSGTYPE release];
	}
	if(PKEY) {
		[PKEY release];
	}
	if(NICKNAME) {
		[NICKNAME release];
	}
	if(PHOTOURL) {
		[PHOTOURL release];
	}
	if(ISSENDMSG) {
		[ISSENDMSG release];
	}
	if(ISSUCCESS) {
		[ISSUCCESS release];
	}
	if(PHOTOFILEPATH) {
		[PHOTOFILEPATH release];
	}
	if(MOVIEFILEPATH) {
		[MOVIEFILEPATH release];
	}
	if(REGDATE) {
		[REGDATE release];
	}
	if(READMARKCOUNT) {
		[READMARKCOUNT release];
	}

	[super dealloc];
}
@end
