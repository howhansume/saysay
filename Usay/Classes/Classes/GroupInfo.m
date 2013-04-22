//
//  GroupInfoItem.m
//  USayApp
//
//  Created by Jong-Sung Park on 10. 6. 27..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "GroupInfo.h"


@implementation GroupInfo
@synthesize INDEXNO, ID, GROUPTITLE, RPCREATED, RPUPDATED, RPDELETED, SIDCREATED, SIDUPDATED, SIDDELETED, CONTACTCOUNT, PKEY, RECORDID;

-(void)dealloc {
	[INDEXNO release];
	[RECORDID release];
	[ID release];
	[GROUPTITLE release];
	[RPCREATED release];
	[RPUPDATED release];
	[RPDELETED release];
	[SIDCREATED release];
	[SIDUPDATED release];
	[SIDDELETED release];
	[PKEY release];
	[CONTACTCOUNT release];
	[super dealloc];
}

@end
