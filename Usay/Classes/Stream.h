//
//  Stream.h
//  PacketLibrary
//
//  Created by 1team on 10. 5. 31..
//  Copyright 2010 Inamass.net. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Stream : NSObject {
	char *pPtr;
	NSInteger nSize;
	NSInteger nActSize;
	NSInteger nPos;
}

- (id)initPtr:(NSInteger)size;
- (void)Clear;
- (BOOL)EnsureFreeSize:(NSInteger)size;
- (BOOL)SeekFromBegin:(NSInteger)offset;
- (BOOL)SeekFromEnd:(NSInteger)offset;
- (BOOL)Seek:(NSInteger)offset;
- (BOOL)WriteBuff:(const void*)buff Size:(NSInteger)size;
- (BOOL)ReadBuff:(void*)buff Size:(NSInteger)size;
- (BOOL)Read:(Stream*)stream Size:(NSInteger)size;
- (BOOL)ReadAsString:(NSString*)str Size:(NSInteger)size;
- (BOOL)ReadTokenAsChar:(char**)buff Char:(char)ch;

// 110124 analyze
// 사용 안함...
//- (BOOL)ReadTokenAsString:(NSString*)str Char:(char)ch;

- (NSString*) ReadTokenAsNSString:(char)ch;
- (BOOL)CanRead;
- (void*)GetPtr;
- (NSInteger)GetSize;

@end
