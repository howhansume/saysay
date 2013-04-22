//
//  ExtStrPacket.h
//  PacketLibrary
//
//  Created by 1team on 10. 5. 28..
//  Copyright 2010 Inamass.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Stream.h"

@interface ExtStrPacket : NSObject {
	NSMutableDictionary *itemNodeDict;
}
-(void) Finalize;
-(BOOL) AddItemString:(NSString*)key Value:(NSString*)value IsReplace:(BOOL)isReplace;
-(BOOL) AddItemNum:(NSString*)key Value:(NSInteger)value IsReplace:(BOOL)isReplace;
-(void) DelItem:(NSString*)key;
-(NSString*) LookupString:(NSString*)key;
-(NSString*) ToString;
-(BOOL) FromString:(const char *)pszStr;
-(BOOL) ToStream:(Stream *)stream;
-(BOOL) FromStream:(const void *)pBuff BuffSize:(NSInteger)nBuffSize;

@end
