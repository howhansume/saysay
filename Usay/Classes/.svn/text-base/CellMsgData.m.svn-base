//
//  CellMsgData.m
//  USayApp
//
//  Created by 1team on 10. 7. 1..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "CellMsgData.h"

@implementation CellMsgData

@synthesize photoImage;
@synthesize mediaImage;
@synthesize pKey;
@synthesize nickName;
@synthesize photoUrl;
@synthesize regTime;
@synthesize contentsMsg;
@synthesize messagekey;
@synthesize chatsession;
@synthesize msgType;
@synthesize sendMsgSuccess;
@synthesize photoFilePath;
@synthesize movieFilePath;
@synthesize readMarkCount;
@synthesize isSend;
@synthesize mediaProgressPos;

-(id)init
{
	self = [super init];
	
	if (self != nil) {
		self.sendMsgSuccess = @"0";
		self.mediaProgressPos = 0.0f;
		self.mediaImage = nil;
		self.photoImage = nil;
	}
	return self;
}

-(void)dealloc
{
	if (self.photoImage != nil) {
		[self.photoImage release];
	}
	if (self.mediaImage != nil) {
		[self.mediaImage release];
	}
	if (self.pKey != nil) {
		[self.pKey release];
	}
	if (self.nickName != nil) {
		[self.nickName release];
	}
	if (self.photoUrl != nil) {
		[self.photoUrl release];
	}
	if (self.regTime != nil) {
		[self.regTime release];
	}
	if (self.contentsMsg != nil) {
		[self.contentsMsg release];
	}
	if (self.messagekey != nil) {
		[self.messagekey release];
	}
	if (self.chatsession != nil) {
		[self.chatsession release];
	}
	if (self.msgType != nil) {
		[self.msgType release];
	}
	if (self.sendMsgSuccess != nil) {
		[self.sendMsgSuccess release];
	}
	if (self.photoFilePath != nil) {
		[self.photoFilePath release];
	}
	if (self.movieFilePath != nil) {
		[self.movieFilePath release];
	}
	
	[super dealloc];
}

@end
