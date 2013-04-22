//
//  TransPacket.h
//  PacketLibrary
//
//  Created by 1team on 10. 5. 28..
//  Copyright 2010 Inamass.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExtStrPacket.h"
#import "Stream.h"

@interface TransPacket : NSObject {
	char		*pPacket;
	NSInteger	nPacketSize;
}

+(BOOL) ConvertEndian:(void*)dest source:(const void*)src Size:(NSInteger)size;
+(NSInteger) TestPacket:(const void*)pBuff BuffSize:(NSInteger)buffsize;

-(void) Finalize;

-(BOOL) SetPacket:(const void*)pHead HeadSize:(NSInteger)headsize Body:(const void*)pBody BodySize:(NSInteger)bodysize;
-(BOOL) SetPacketExtHead:(ExtStrPacket*)pHead;
-(BOOL) SetPacketExt:(ExtStrPacket*)pHead ExtBody:(ExtStrPacket*)pBody;
-(BOOL) SetPacketExtHeadBuffBody:(ExtStrPacket*)pHead Body:(const void*)pBody BodySize:(NSInteger)bodysize;

-(BOOL) GetHeadPacketExt:(ExtStrPacket*)pHead;
-(BOOL) GetBodyPacketExt:(ExtStrPacket*)pBody;
-(Stream*) GetBodyPacketStream;

-(NSInteger) FromStream:(const void *)pBuff BuffSize:(NSInteger)buffsize;
-(const void*) GetPacketPtr;
-(NSInteger) GetPacketSize;
-(const void*) GetHeadPtr;
-(NSInteger) GetHeadSize;
-(const void*) GetBodyPtr;
-(NSInteger) GetBodySize;

@end
