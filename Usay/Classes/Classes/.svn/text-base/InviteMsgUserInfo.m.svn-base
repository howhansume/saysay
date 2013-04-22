//
//  InviteMsgUserInfo.m
//  USayApp
//
//  Created by 1team on 10. 7. 9..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "InviteMsgUserInfo.h"


@implementation InviteMsgUserInfo

@synthesize RPKey, ID, nickName, formatted, photoUrl, status, groupId, imStatus, phoneNum, checked;

-(id)init
{
	self = [super init];
	
	if(self != nil) {
		checked = NO;
	}
	
	return self;
}

-(void)dealloc
{
	if (RPKey) {
		[RPKey release];
	}
	if (ID) {
		[ID release];
	}
	if (nickName) {
		[nickName release];
	}
	if (formatted) {
		[formatted release];
	}
	if (photoUrl) {
		[photoUrl release];
	}
	if (status) {
		[status release];
	}
	if (groupId) {
		[groupId release];
	}
	if (imStatus) {
		[imStatus release];
	}
	if (phoneNum) {
		[phoneNum release];
	}
	[super dealloc];
}

@end
