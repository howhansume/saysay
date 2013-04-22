//
//  USayHttpData.m
//  USayApp
//
//  Created by 1team on 10. 6. 18..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "USayHttpData.h"


@implementation USayHttpData

@synthesize api;
@synthesize subApi;
@synthesize bodyObjectDic;
@synthesize timeout;
@synthesize	filePath;
@synthesize uniqueId;
@synthesize isRepresent;
@synthesize cid;
@synthesize message;
@synthesize sessionKey;
@synthesize messageKey;
@synthesize mType;
@synthesize responseData;
@synthesize mediaData;

-(id)initWithRequestData:(NSString*)pApi andWithDictionary:(NSDictionary*)pBodyObjectDic timeout:(NSInteger)time
{
	self = [super init];
	
	if (self != nil) {
		api = pApi;
		bodyObjectDic = pBodyObjectDic;
//		[bodyObjectDic setDictionary:pBodyObjectDic];
		timeout = time;
		subApi = nil;
		filePath = nil;
		uniqueId = nil;
		isRepresent = nil;
		cid = nil;
		message = nil;
		sessionKey = nil;
		messageKey = nil;
		mType = nil;
		responseData = nil;
		mediaData = nil;
	}

	return self;
}

-(id)initWithResponseData:(NSString*)pApi andWithString:(NSString*)pResponseData
{
	self = [super init];
	
	if (self != nil) {
		api = pApi;
		responseData = pResponseData;
		bodyObjectDic = nil;
		subApi = nil;
		filePath = nil;
		uniqueId = nil;
		isRepresent = nil;
		cid = nil;
		message = nil;
		sessionKey = nil;
		messageKey = nil;
		mType = nil;
		mediaData = nil;
	}
	
	return self;
}

- (void)dealloc {
//	if (api && [api retainCount] > 0) {
//		[api release];
//		api = nil;
//	}
//	if (subApi && [subApi retainCount] > 0) {
//		[subApi release];
//		subApi = nil;
//	}
//	if (bodyObjectDic && [bodyObjectDic retainCount] > 0) {
//		[bodyObjectDic release];
//		bodyObjectDic = nil;
//	}
//	if (filePath && [filePath retainCount] > 0) {
//		[filePath release];
//		filePath = nil;
//	}
	if (uniqueId && [uniqueId retainCount] > 0) {
		[uniqueId release];
		uniqueId = nil;
	}
//	if (isRepresent && [isRepresent retainCount] > 0) {
//		[isRepresent release];
//		isRepresent = nil;
//	}
//	if (cid && [cid retainCount] > 0) {
//		[cid release];
//		cid = nil;
//	}
//	if (message && [message retainCount] > 0) {
//		[message release];
//		message = nil;
//	}
//	if (sessionKey && [sessionKey retainCount] > 0) {
//		[sessionKey release];
//		sessionKey = nil;
//	}
//	if (messageKey && [messageKey retainCount] > 0) {
//		[messageKey release];
//		messageKey = nil;
//	}
//	if (mType && [mType retainCount] > 0) {
//		[mType release];
//		mType = nil;
//	}
//	if (responseData && [responseData retainCount] > 0) {
//		[responseData release];
//		responseData = nil;
//	}
//	if (mediaData) {
//		[mediaData release];
//	}

	[super dealloc];
}

@end
