//
//  TransPacket.m
//  PacketLibrary
//
//  Created by 1team on 10. 5. 28..
//  Copyright 2010 Inamass.net. All rights reserved.
//

#import "TransPacket.h"

// Magickey
static const unsigned char g_transPacketUniqueCode[4] = {(unsigned char)0x01, (unsigned char)0x31, (unsigned char)0xF4, (unsigned char)0x42};


@implementation TransPacket

+(BOOL) ConvertEndian:(void*)dest source:(const void*)src Size:(NSInteger)size
{
	const unsigned char *s;
	unsigned char *d;
	int i = 0;
	
	if(src && dest) {
		s = (const unsigned char *)src;
		d = (unsigned char *)dest;
		for(i = 0; i < (int)size; i++) {
			d[i] = s[size - 1 - i];
		}
		return YES;
	}
	
	return NO;
}

+(NSInteger) TestPacket:(const void*)pBuff BuffSize:(NSInteger)buffsize
{
	int nTotalSize = 0, nHeadSize = 0, nBodySize = 0;
	char * pPtr = NULL;
	
	if(pBuff == NULL || buffsize < 1) return 0;
	if(buffsize < 16) return 0;
	
	pPtr = (char *)pBuff;
	
	if(memcmp(pPtr, g_transPacketUniqueCode, 4) != 0) return -1;
	
	[TransPacket ConvertEndian:&nTotalSize source:pPtr+4 Size:4];
//	NSLog(@"TestPacket %d totalSize ===> buffsize = %d\n", nTotalSize, buffsize);
	
	if(nTotalSize < 1) return -1;
	[TransPacket ConvertEndian:&nHeadSize source:pPtr+4+4 Size:4];
//	NSLog(@"TestPacket %d headSize ===> buffsize = %d\n", nHeadSize, buffsize);
	
	if(nHeadSize < 1) return -1;
	if(nHeadSize + 4 + 4 > nTotalSize || nHeadSize == 0) return -1;
	if(nTotalSize + 4 + 4 > buffsize) return 0;
	
	[TransPacket ConvertEndian:&nBodySize source:pPtr+4+4+4+nHeadSize Size:4];
//	NSLog(@"TestPacket %d bodySize ===> buffsize = %d\n", nBodySize, buffsize);
	
	if(nBodySize < 0) return -1;
	if(4 + nHeadSize + 4  + nBodySize != nTotalSize) return -1;
	
	return nTotalSize + 4 + 4;
}

-(void) Finalize
{
	if(pPacket) {
		free(pPacket);
		pPacket = NULL;
	}
	nPacketSize = 0;
}

- (void)dealloc
{
	[self Finalize];
	[super dealloc];
}

-(BOOL) SetPacket:(const void*)pHead HeadSize:(NSInteger)headsize Body:(const void*)pBody BodySize:(NSInteger)bodysize
{
	int nTotalSize = 0;
	[self Finalize];
	
	if(pHead == NULL || headsize < 1 || bodysize < 0) return NO;
	
	nTotalSize = 4 + headsize + 4 + bodysize;
	
	pPacket = (char*)malloc(4+4+nTotalSize);

	if(pPacket == NULL) return NO;
	
	nPacketSize = 4 + 4 + nTotalSize;
	
	memcpy(pPacket, g_transPacketUniqueCode, 4);
	[TransPacket ConvertEndian:pPacket+4 source:&nTotalSize Size:4];
	[TransPacket ConvertEndian:pPacket+4+4 source:&headsize Size:4];
	
	memcpy(pPacket+4+4+4, pHead, headsize);
	[TransPacket ConvertEndian:pPacket+4+4+4+headsize source:&bodysize Size:4];

	if(bodysize > 0) {
		memcpy(pPacket+4+4+4+headsize+4, pBody, bodysize);
	}
	
	return YES;
}

-(BOOL) SetPacketExtHead:(ExtStrPacket*)pHead
{
	Stream *pHeadStream = nil;
	if ([pHead ToStream:pHeadStream]) {
		return [self SetPacket:[pHeadStream GetPtr] HeadSize:[pHeadStream GetSize] Body:nil BodySize:0];
	}
	
	return NO;
}

-(BOOL) SetPacketExt:(ExtStrPacket*)pHead ExtBody:(ExtStrPacket*)pBody
{
	Stream *pHeadStream = nil, *pBodyStream = nil;
	
	// packet 추가시 직접 추가 할것.
//	[pHead AddItemString:@"bodytype" Value:@"1" IsReplace:YES];
	
	if ([pHead ToStream:pHeadStream] && [pBody ToStream:pBodyStream]) {
		return [self SetPacket:[pHeadStream GetPtr] HeadSize:[pHeadStream GetSize] Body:[pBodyStream GetPtr] BodySize:[pBodyStream GetSize]];
	}
	
	return NO;
}

-(BOOL) SetPacketExtHeadBuffBody:(ExtStrPacket*)pHead Body:(const void*)pBody BodySize:(NSInteger)bodysize
{
	Stream *pHeadStream = [[[Stream alloc] init] autorelease];
	
	if ([pHead ToStream:pHeadStream]) {
		return [self SetPacket:[pHeadStream GetPtr] HeadSize:[pHeadStream GetSize] Body:pBody BodySize:bodysize];
	}
	
	return NO;
}


-(BOOL) GetHeadPacketExt:(ExtStrPacket*)pHead
{
	[pHead Finalize];
	
	return [pHead FromStream:[self GetHeadPtr] BuffSize:[self GetHeadSize]];
}

-(BOOL) GetBodyPacketExt:(ExtStrPacket*)pBody
{
	[pBody Finalize];
	return [pBody FromStream:[self GetBodyPtr] BuffSize:[self GetBodySize]];
}

-(Stream*) GetBodyPacketStream
{
	Stream *pBody = [[[Stream alloc] initPtr:[self GetBodySize]] autorelease];
	if(pBody) {
		if([pBody WriteBuff:[self GetBodyPtr] Size:[self GetBodySize]]) {
			return pBody;
		}
	}
	
	return nil;
}


-(NSInteger) FromStream:(const void *)pBuff BuffSize:(NSInteger)buffsize
{
	int nRet = 0;
	[self Finalize];
	
	nRet = [TransPacket TestPacket:pBuff BuffSize:buffsize];
	if(nRet > 0) {
		pPacket = (char*)malloc(nRet);
		if(pPacket == NULL) return -1;
		memcpy(pPacket, pBuff, nRet);
		nPacketSize = nRet;
	}
	
	return nRet;
}

-(const void*) GetPacketPtr
{
	return pPacket;
}

-(NSInteger) GetPacketSize
{
	return nPacketSize;
}

-(const void*) GetHeadPtr
{
	if(pPacket) {
		return pPacket + 4 + 4 + 4;
	}
	
	return NULL;
}

-(NSInteger) GetHeadSize
{
	int nHeadSize = 0;
	
	if(pPacket) {
		[TransPacket ConvertEndian:&nHeadSize source:pPacket+4+4 Size:4];
	}
	
	return nHeadSize;
}

-(const void*) GetBodyPtr
{
	if(pPacket && [self GetBodySize] > 0) {
		return pPacket + 4 + 4 + 4 + [self GetHeadSize] + 4;
	}
	
	return NULL;
}

-(NSInteger) GetBodySize
{
	int nBodySize = 0;
	
	if(pPacket) {
		[TransPacket ConvertEndian:&nBodySize source:pPacket+4+4+4+[self GetHeadSize] Size:4];
	}
	
	return nBodySize;
}


@end

/*
// JSON, ExStrPacket, Stream, TransPacket 클래스 사용법
//	head : ExStrPacket
//	body : JSON
//  packet : head와 body와 매직키를 넣어서 TransPacket 으로 생성
 
	ExtStrPacket *head = nil;
	NSString *body = nil;

	head = [[[ExtStrPacket alloc] init] autorelease];
	if(head) {
		if ([head AddItemString:@"from" Value:@"im11/01" IsReplace:YES]) {
			NSLog(@"AddItemString success!");
		} else {
			NSLog(@"AddItemString fail!");
		}
		[head AddItemString:@"bodytype" Value:@"5" IsReplace:YES];
		[head AddItemString:@"svc" Value:@"presence" IsReplace:YES];
		[head AddItemString:@"pkey" Value:@"uu1234" IsReplace:YES];
		NSString *str = [head ToString];
		NSLog(@"head Packet = %@", str);
		
		NSDictionary *dict, *mapData;
		NSString *key;
		
		mapData = [NSDictionary dictionaryWithObjectsAndKeys:
				   @"us0123456789", @"pkey",
				   @"123456789012", @"userno",
				   @"test@paran.com", @"userid",
				   @"홍길동", @"nick",
				   @"118.67.188.2", @"exip",
				   [self deviceIPAdress], @"inip",	// IPAddress.c, IPAddress.h 참고
				   @"1", @"imstatus",
				   [[self appDelegate] getSvcIdx], @"svcidx",
				   @"132BAS28", @"ssk",
				   @"abcd1234", @"devtoken",
				   @"mobile", @"device",
				   [[UIDevice currentDevice] systemVersion], @"version",
				   [[UIDevice currentDevice] systemName], @"os",
				   @"1", @"exclusive",
				   nil];
		// JSON 문법으로 변환할 데이터 생성
		dict = [NSDictionary dictionaryWithObjectsAndKeys:
				@"map", @"rqtype",
				@"LOGIN", @"cmd",
				mapData, @"map",
				nil];
		
		mapData = nil;
		
		// JSON 라이브러리 생성
		SBJSON *json = [[SBJSON alloc] init];
		[json setHumanReadable:YES];
		// 변환
		body = [json stringWithObject:dict error:nil];
		[json release];
		//			NSLog(@"converted data :\n%@", body);
		//
		//			// 이전데이터를 소거함을 증명
		//			dict = nil;
		//
		//			// JSON 문자열을 객체로 변환
		//			dict = [json objectWithString:body error:nil];
		//
		//			// 결과 출력
		//			for (key in dict) {
		//				NSLog(@"Key: %@, Value: %@", key, [dict valueForKey:key]);
		//			}
		TransPacket *transPacket = nil;
		transPacket = [[TransPacket alloc] init];
		if(transPacket) {
			if([transPacket SetPacketExtHeadBuffBody:head Body:[body cStringUsingEncoding:NSEUCKREncoding] BodySize:strlen([body cStringUsingEncoding:NSEUCKREncoding])]) {
				const void *pPacket = [transPacket GetPacketPtr];
				NSLog(@"TestBtn!");
			}
		}
	}
//*/