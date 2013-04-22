//
//  ExtStrPacket.m
//  PacketLibrary
//
//  Created by 1team on 10. 5. 28..
//  Copyright 2010 Inamass.net. All rights reserved.
//

#import "ExtStrPacket.h"

#ifndef NSEUCKREncoding
	#define NSEUCKREncoding (-2147481280)
#endif

@implementation ExtStrPacket

- (id) init
{
	self = [super init];
	
	if(self != nil) {
		itemNodeDict = [[NSMutableDictionary alloc] init];
	}
	return self;
}

-(void) Finalize
{
	if (itemNodeDict) {
		
		for (id key in itemNodeDict) {
			[[itemNodeDict objectForKey:key] release];
		}
		 
		[itemNodeDict removeAllObjects];
		//[itemNodeDict release];
	}
}

-(BOOL) AddItemString:(NSString*)key Value:(NSString*)value IsReplace:(BOOL)isReplace
{
	if ([key length] == 0 || [value length] == 0) {
		return NO;
	}
	
	key = [key lowercaseString];
	
	if (isReplace) {
		[itemNodeDict removeObjectForKey:key];
	} else {
	//	NSString *tempValue = nil;
		if ([self LookupString:key]) {
			return YES;
		}
	}

	[itemNodeDict setObject:value forKey:key];
	
	return YES;
}

-(BOOL) AddItemNum:(NSString*)key Value:(NSInteger)value IsReplace:(BOOL)isReplace
{
	if ([key length] == 0) {
		return NO;
	}
	
	key = [key lowercaseString];
	
	if (isReplace) {
		[itemNodeDict removeObjectForKey:key];
	} else {
		//NSString *tempValue = nil;
		if ([self LookupString:key]) {
			return YES;
		}
	}
	NSString *strValue = [NSString stringWithFormat:@"%d", value];
	
	[itemNodeDict setObject:strValue forKey:key];
	
	return YES;
}

-(void) DelItem:(NSString*)key
{
	[itemNodeDict removeObjectForKey:key];
}

-(NSString*) LookupString:(NSString*)key
{
	if ([key length] == 0) {
		return nil;
	}
	
	return (NSString*)[itemNodeDict objectForKey:key];
}

// format : "keysize key valuesize value"
-(NSString*) ToString
{
	NSString *value = nil;
	NSMutableString *result = [[[NSMutableString alloc] init] autorelease];

	for (id key in itemNodeDict) {
		value = (NSString*)[itemNodeDict objectForKey:key];
		[result appendFormat:@"%d %@ %d %@ ", strlen([key cStringUsingEncoding:NSEUCKREncoding]), key, strlen([value cStringUsingEncoding:NSEUCKREncoding]), value];
    }

	return [result substringToIndex:[result length] - 1];
}

-(BOOL) FromString:(const char *)pszStr
{
	if (pszStr == nil || strlen(pszStr) == 0) {
		return NO;
	}
	
	return [self FromStream:pszStr BuffSize:strlen(pszStr)];
}

-(BOOL) ToStream:(Stream *)stream
{
	NSString *str = [self ToString];
	
	if(str && [str length] > 0) {
		if(stream) {
			if ([stream WriteBuff:[str cStringUsingEncoding:NSEUCKREncoding] Size:[str length]] && [stream SeekFromBegin:0]) {
				return YES;
			}
		}
	}

	return NO;
}

-(BOOL) FromStream:(const void *)pBuff BuffSize:(NSInteger)nBuffSize
{
	NSString *strPacket = [NSString stringWithCString:pBuff encoding:NSASCIIStringEncoding];
	NSString *strKey = nil, *strValue = nil, *strKeySize = nil, *strValueSize = nil;
	
	NSInteger nKeySize = 0, nValueSize = 0;
	NSRange findRange;
	
	if([strPacket length] <= 0) return NO;
	
	strPacket = [strPacket stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	[self Finalize];
	
	while (TRUE) {
	_checkKey:
		findRange = [strPacket rangeOfString:@" "];
		if(findRange.location != NSNotFound) {
			strKeySize = [strPacket substringToIndex:findRange.location];
			if([strKeySize length] > 0) {
				nKeySize = [strKeySize intValue];
				if (nKeySize >= 0 && nKeySize < 32767) {
					if ([strKeySize length] >= [strPacket length]) return NO;
					strPacket = [strPacket substringFromIndex:findRange.location+1];
					if([strPacket length] > 0) {
						strKey = [strPacket substringToIndex:nKeySize];
//						NSLog(@"key=%@", strKey);
						strPacket = [strPacket substringFromIndex:nKeySize+1];
						if([strPacket length] > 0) {
							findRange = [strPacket rangeOfString:@" "];
							if(findRange.location != NSNotFound) {
								strValueSize = [strPacket substringToIndex:findRange.location];
								if([strValueSize length] > 0) {
									nValueSize = [strValueSize intValue];
									if (nValueSize >= 0 && nValueSize < 32767) {
										if ([strValueSize length] >= [strPacket length]) return NO;
										strPacket = [strPacket substringFromIndex:findRange.location+1];
										if([strPacket length] > 0) {
											strValue = [strPacket substringToIndex:nValueSize];
//											NSLog(@"value=%@", strValue);
											// AddItemString
											[self AddItemString:strKey Value:strValue IsReplace:YES];
											if (nValueSize+1 > [strPacket length]) return YES;
											strPacket = [strPacket substringFromIndex:nValueSize+1];
											goto _checkKey;
										} else {
											return NO;
										}
									} else {
										return NO;
									}
								} else {
									return NO;
								}
							} else {
								break;
							}
						} else {
							return NO;
						}
					} else {
						return NO;
					}
				}
			} else {
				return NO;
			}
		} else {
			break;
		}
	}
	
	return YES;
}

- (void)dealloc
{
	if (itemNodeDict) {
		[itemNodeDict release];
	}
	[super dealloc];
}

@end
