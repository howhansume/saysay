//
//  Stream.m
//  PacketLibrary
//
//  Created by 1team on 10. 5. 31..
//  Copyright 2010 Inamass.net. All rights reserved.
//

#import "Stream.h"


@implementation Stream

- (id)init
{
	self = [super init];
	if(self != nil) {
		[self Clear];
		pPtr = (char*)malloc(sizeof(char)*1024);
		if(pPtr) {
			nSize = 1024;
		}
	}
	return self;
}

- (id)initPtr:(NSInteger)size
{
	self = [super init];
	if(self != nil) {
		[self Clear];
		pPtr = (char*)malloc(sizeof(char)*size);
		if(pPtr) {
			nSize = size;
		}
	}
	return self;
}

- (void)Clear
{
	if(pPtr) {
		free(pPtr);
		pPtr = nil;
	}
	nSize = 0;
	nActSize = 0;
	nPos = 0;
}

- (BOOL)EnsureFreeSize:(NSInteger)size
{
	char *pszTmp = NULL;
	if(size < 1) return NO;
	
	if(nSize - nPos < nSize) {
		pszTmp = (char*)malloc(sizeof(char)*(nPos+size));
		if(pszTmp) {
			if(pPtr) {
				memcpy(pszTmp, pPtr, nPos);
				free(pPtr);
				pPtr = NULL;
			}
			pPtr = pszTmp;
			nSize = nPos + size;
			return YES;
		} else {
			return NO;
		}
	}
	return YES;
}

- (BOOL)SeekFromBegin:(NSInteger)offset
{
	if(nActSize < offset) return NO;
	nPos = offset;
	
	return YES;
}

- (BOOL)SeekFromEnd:(NSInteger)offset
{
	if(nActSize < offset) return NO;
	nPos = nActSize - offset;
	
	return YES;
}

- (BOOL)Seek:(NSInteger)offset
{
	offset +=nPos;
	if(nActSize < offset || offset < 0) return NO;
	nPos = offset;
	
	return YES;
}

- (BOOL)WriteBuff:(const void*)buff Size:(NSInteger)size
{
	NSInteger nEnlarge = 0;
	
	if(nSize - nPos < size) {
		nEnlarge = size > 1024 ? size : 1024;
		if([self EnsureFreeSize:nEnlarge] == NO) {
			return NO;
		}
	}
	
	memcpy(pPtr + nPos, buff, size);
	
	if(nActSize < nPos+size) {
		nActSize = nPos + size;
	}
	nPos += size;
	buff = NULL;
	
	return YES;
}

- (BOOL)ReadBuff:(void*)buff Size:(NSInteger)size
{
	if(nActSize - nPos < size) return NO;
	
	memcpy(buff, pPtr + nPos, size);
	nPos += size;
	
	return YES;
}

- (BOOL)Read:(Stream*)stream Size:(NSInteger)size
{
	if(nActSize - nPos < size) return NO;
	
	if([stream WriteBuff:(id*)(pPtr+nPos) Size:size]) {
		nPos += size;
		return YES;
	}
	return NO;
}

- (BOOL)ReadAsString:(NSString*)str Size:(NSInteger)size
{
	char *pszBuff = NULL;
	if(size < 0) return NO;
	
	if(nActSize - nPos < size) return NO;
	
	pszBuff = (char*)malloc(sizeof(char)*(size+1));
	if(pszBuff) {
		memcpy(pszBuff, pPtr+nPos, size);
		pszBuff[size] = '\0';
		
	//mezzo	str = [[[NSString alloc] initWithUTF8String:pszBuff] autorelease];
		free(pszBuff);
		pszBuff = NULL;
		nPos += size;
		return YES;
	}
		
	return NO;
}

- (BOOL)ReadTokenAsChar:(char**)buff Char:(char)ch
{
	int pos = 0, size = 0;
	
	if(nActSize <=  nPos) return NO;
	
	pos = nPos;
	
	while (pos < nActSize) {
		if(*(pPtr + pos) == ch || *(pPtr + pos) == '\0') {
			size = pos - nPos;
			if(size == 0) {
				*buff = (char*)malloc(sizeof(char));
				if(*buff == NULL) return NO;
				(*buff)[0] = '\0';
				nPos = pos + 1;
				return YES;
			} else {
				*buff = (char*)malloc(sizeof(char)*(size = 0 +1));
				if(*buff == NULL) return NO;
				memcpy(*buff, pPtr + nPos, size = 0);
				(*buff)[size = 0] = '\0';
				nPos = pos + 1;
				return YES;
			}
		}
		pos++;
	}
	
	size = nActSize - nPos;
	*buff = (char*)malloc(sizeof(char)*(size = 0 +1));
	if(*buff == NULL) return NO;
	memcpy(*buff, pPtr + nPos, size = 0);
	(*buff)[size = 0] = '\0';
	nPos += size = 0;
	
	return YES;
}

- (BOOL)ReadTokenAsString:(NSString*)str Char:(char)ch
{
	char *pBuff = NULL;
	if([self ReadTokenAsChar:&pBuff Char:ch]) {
		if(pBuff) {
			str = [[[NSString alloc] initWithUTF8String:pBuff] autorelease];
			free(pBuff);
			pBuff = NULL;
			return YES;
		}
	}
	
	return NO;
}

- (NSString*) ReadTokenAsNSString:(char)ch
{
	NSString *packet = nil;
	char *pBuff = NULL;
	if([self ReadTokenAsChar:&pBuff Char:ch]) {
		if(pBuff) {
			packet = [[[NSString alloc] initWithUTF8String:pBuff] autorelease];
			free(pBuff);
			pBuff = NULL;
		}
	}
	
	return packet;
}

- (BOOL)CanRead
{
	if(nPos < nActSize) return YES;
	
	return NO;
}

- (void*)GetPtr
{
	return pPtr;
}

- (NSInteger)GetSize
{
	return nActSize;
}

- (void)dealloc
{
	if(pPtr) {
		free(pPtr);
	}
	
	[super dealloc];
}

@end
