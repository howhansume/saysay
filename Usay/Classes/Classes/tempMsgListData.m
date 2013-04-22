//
//  tempMsgListData.m
//  USayApp
//
//  Created by 1team on 10. 7. 2..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "tempMsgListData.h"

@implementation TempMsgListData

@synthesize nCount;
@synthesize sType;
@synthesize pCount;
@synthesize cType;
@synthesize lastMsgType;
@synthesize lastMsg;
@synthesize lastMsgDate;
@synthesize lastUpdateTime;

-(void)dealloc
{
	[nCount release];
	[sType release];
	[pCount release];
	[cType release]; 
	[lastMsgType release];
	[lastMsg release];
	[lastMsgDate release];
	[lastUpdateTime release];
	
	[super dealloc];
}

@end
