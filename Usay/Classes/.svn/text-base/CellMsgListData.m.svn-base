//
//  CellMsgListData.m
//  USayApp
//
//  Created by 1team on 10. 6. 24..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "CellMsgListData.h"

@implementation MsgUserData

@synthesize nickName;
@synthesize photoUrl;
@synthesize pKey;


-(id)init
{
	self = [super init];
	
	if (self != nil) {
		self.pKey = nil;
		self.photoUrl = nil;
		self.nickName = nil;
	}
	
	return self;
}
-(void)dealloc
{
	[nickName release];
	[photoUrl release];
	[pKey release];
	[super dealloc];
}

@end


@implementation CellMsgListData

@synthesize representPhotoImage;
@synthesize chatsession;
@synthesize lastmessagekey;
@synthesize cType;
@synthesize lastMsg;
@synthesize lastMsgType;
@synthesize lastMsgDate;
@synthesize lastUpdateTime;
@synthesize userDataDic;
@synthesize newMsgCount;


-(id)init
{
	self = [super init];
	if(self != nil) {
		[self setNewMsgCount:0];
		self.userDataDic = [NSMutableDictionary dictionaryWithCapacity:10];
		self.representPhotoImage = nil;
		self.chatsession = nil;
		self.lastmessagekey = nil;
		self.cType = nil;
		self.lastMsg = nil;
		self.lastMsgType = nil;
		self.lastMsgDate = nil;
		self.lastUpdateTime = nil;
		self.newMsgCount = 0;
	}

	return self;
}

-(id)copyWithZone:(NSZone*)zone
{
	@synchronized(self) {
		CellMsgListData *data = [[self class] allocWithZone:zone];
		if (data) {
			data.chatsession = [self.chatsession copyWithZone:zone];
			data.lastmessagekey = [self.lastmessagekey copyWithZone:zone];
			data.cType = [self.cType copyWithZone:zone];
			data.lastMsg = [self.lastMsg copyWithZone:zone];
			data.lastMsgType = [self.lastMsgType copyWithZone:zone];
			data.lastMsgDate = [self.lastMsgDate copyWithZone:zone];
			data.lastUpdateTime = [self.lastUpdateTime copyWithZone:zone];
			data.userDataDic = [self.userDataDic copyWithZone:zone];
			data.newMsgCount = self.newMsgCount;
			UIImage *image = [[[UIImage allocWithZone:zone] initWithCGImage:self.representPhotoImage.CGImage] autorelease];
			data.representPhotoImage = image;
			[image release];

			return data;
		}
	}

	return nil;
}

- (void)dealloc
{
	if (representPhotoImage != nil) {
		[representPhotoImage release];
	}
	if (chatsession != nil) {
		[chatsession release];
	}
    if (lastmessagekey != nil) {
		[lastmessagekey release];
	}
	if (cType != nil) {
		[cType release];
	}
	if (lastMsg != nil) {
		[lastMsg release];
	}
	if (lastMsgType != nil) {
		[lastMsgType release];
	}
	if (lastMsgDate != nil) {
		[lastMsgDate release];
	}
	if (lastUpdateTime != nil) {
		[lastUpdateTime release];
	}
//	if (userDataDic != nil) {
//		[userDataDic release];
//	}
    [super dealloc];
}

@end
