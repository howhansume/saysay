//
//  NSData-AES.m
//
//  Created by Kim Tae-Hyung on 10. 5. 17..
//  Copyright Inamass.net 2010. All rights reserved.
//

#import "NSData-AES.h"

@implementation NSData (NSDataExtension)

- (NSData *)AESEncryptWithKey:(NSString *)key InitializationVector:(NSString *)iv 
{
	int keyLength = [key length];
	if(keyLength != kCCKeySizeAES128 && keyLength != kCCKeySizeAES192 && keyLength != kCCKeySizeAES256) {
		NSLog(@"%s %s %d key length is not 128/192/256 bits", __FILE__, __FUNCTION__, __LINE__);
		return nil;
	}
	// 'key' should be 16/24/32 bytes for AES128/AES192/AES256, will be null-padded otherwise
	char keyPtr[keyLength + 1];		// room for terminator (unused)
	bzero(keyPtr, sizeof(keyPtr));	// fill with zeroes (for padding)
	[key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];	// fetch key data

	char ivPtr[keyLength + 1];		// room for terminator (unused)
	bzero(ivPtr, sizeof(ivPtr));	// fill with zeroes (for padding)
	[iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];	// fetch key data
	
	//See the doc: For block ciphers, the output size will always be less than or 
	//equal to the input size plus the size of one block.
	//That's why we need to add the size of one block here
	size_t bufferSize = [self length] + kCCBlockSizeAES128;
//	size_t bufferSize = [self length];
	void *buffer = malloc(bufferSize);
	memset((void *)buffer, 0x0, bufferSize);	// Zero out buffer.

	size_t numBytesEncrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, 
										  (iv == nil ? kCCOptionECBMode|kCCOptionPKCS7Padding : kCCOptionPKCS7Padding),	// default : CBC (when initial vector is supplied)
										  keyPtr, keyLength,
										  ivPtr,						// initialization vector (optional)
										  [self bytes], [self length],	// input 
										  buffer, bufferSize,			// output 
										  &numBytesEncrypted);
//	NSLog(@"CCCrypt kCCEncrypt cryptStatus = %d", cryptStatus);

	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
	}
	
	free(buffer); //free the buffer;
	return nil;
}

- (NSData *)AESDecryptWithKey:(NSString *)key InitializationVector:(NSString *)iv
{
	int keyLength = [key length];
	if(keyLength != kCCKeySizeAES128 && keyLength != kCCKeySizeAES192 && keyLength != kCCKeySizeAES256) {
		NSLog(@"%s %s %d key length is not 128/192/256 bits", __FILE__, __FUNCTION__, __LINE__);
		return nil;
	}
	// 'key' should be 16/24/32 bytes for AES128/AES192/AES256, will be null-padded otherwise
	char keyPtr[kCCKeySizeAES128 + 1];		// room for terminator (unused)
	bzero(keyPtr, sizeof(keyPtr));	// fill with zeroes (for padding)
	[key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];	// fetch key data
	
	char ivPtr[kCCKeySizeAES128 + 1];		// room for terminator (unused)
	bzero(ivPtr, sizeof(ivPtr));	// fill with zeroes (for padding)
	[iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];	// fetch key data
	
	//See the doc: For block ciphers, the output size will always be less than or 
	//equal to the input size plus the size of one block.
	//That's why we need to add the size of one block here
	size_t bufferSize = [self length] + kCCKeySizeAES128;
	void *buffer = malloc(bufferSize);
	memset((void *)buffer, 0x0, bufferSize);	// Zero out buffer.

	size_t numBytesDecrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
										  (iv == nil ? kCCOptionECBMode|kCCOptionPKCS7Padding : kCCOptionPKCS7Padding),	// default : CBC (when initial vector is supplied)
										  keyPtr, kCCKeySizeAES128,
										  ivPtr,						// initialization vector (optional)
										  [self bytes], [self length],  // input
										  buffer, bufferSize,			// output
										  &numBytesDecrypted);
	
//	NSLog(@"CCCrypt kCCDecrypt cryptStatus = %d", cryptStatus);
	
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
	}
	
	free(buffer); //free the buffer;

	return nil;
}
@end


/*
 CCCryptorStatus
 enum {
	kCCSuccess			= 0,
	kCCParamError		= -4300,	// Operation completed normally.
	kCCBufferTooSmall	= -4301,	// Illegal parameter value.
	kCCMemoryFailure	= -4302,	// Insufficent buffer provided for specified operation.
	kCCAlignmentError	= -4303,	// Memory allocation failure. 
	kCCDecodeError		= -4304,	// Input size was not aligned properly. 
	kCCUnimplemented	= -4305		// Function not implemented for the current algorithm.
 };
 typedef int32_t CCCryptorStatus;
 
 CCCryptorStatus CCCrypt(
						CCOperation op,			// kCCEncrypt, etc.
						CCAlgorithm alg,		// kCCAlgorithmAES128, etc.
						CCOptions options,		// kCCOptionPKCS7Padding, etc.
						const void *key,
						size_t keyLength,
						const void *iv,			// optional initialization vector
						const void *dataIn,		// optional per op and alg
						size_t dataInLength,
						void *dataOut,			// data RETURNED here
						size_t dataOutAvailable,
						size_t *dataOutMoved)
 
 //*/