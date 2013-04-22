//
//  NSData-AES.h
//
//  Created by Kim Tae-Hyung on 10. 5. 17..
//  Copyright Inamass.net 2010. All rights reserved.
//

#ifndef _NSDataExtension
#define _NSDataExtension

#import <Foundation/Foundation.h>		// OSX 에서 사용시에는 #import <Cocoa/Cocoa.h>
#import <CommonCrypto/CommonCryptor.h>

@interface NSData (NSDataExtension)
/*
 do AES encryption
 parameter:
 - key : blockkey
 - iv : InitializationVector (if not nil : CBC mode / nil : ECB mode)
 //*/
- (NSData *)AESEncryptWithKey:(NSString *)key InitializationVector:(NSString *)iv;

/*
 do AES decryption
 parameter:
 - key : blockkey
 - iv : InitializationVector (if not nil : CBC mode / nil : ECB mode)
 //*/
- (NSData *)AESDecryptWithKey:(NSString *)key InitializationVector:(NSString *)iv;
@end

#endif // _NSDataExtension
