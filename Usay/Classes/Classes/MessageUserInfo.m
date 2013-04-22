//
//  MessageUserInfo.m
//  USayApp
//
//  Created by 1team on 10. 7. 4..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "MessageUserInfo.h"

@implementation MessageUserInfo

@synthesize INDEXNO, CHATSESSION, PKEY, NICKNAME, PHOTOURL;

-(void)dealloc 
{
	if(INDEXNO) {
		[INDEXNO release];
	}
	if(CHATSESSION) {
		[CHATSESSION release];
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
	
	[super dealloc];
}

@end
