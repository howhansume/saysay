//
//  HttpAgent.m
//  HTTPAgent
//
//  Created by Kim Tae-Hyung on 10. 5. 19..
//  Copyright 2010 Inamass.net. All rights reserved.
//

#import "USayAppAppDelegate.h"
#import "HttpAgent.h"
#include <sys/socket.h>
#include <CFNetwork/CFNetwork.h>
#include <unistd.h>
#import "USayDefine.h"	// sochae 2010.09.09 - added

static NSString	*strCookieUCMC;
static NSString *strCookieUCCS;
static NSString *strCookieMC;
static NSString *strCookieCS;

enum {
    kPostBufferSize = 32768
};

static void CFStreamCreateBoundPairCompat(
										  CFAllocatorRef      alloc, 
										  CFReadStreamRef *   readStreamPtr, 
										  CFWriteStreamRef *  writeStreamPtr, 
										  CFIndex             transferBufferSize
										  )
// This is a drop-in replacement for CFStreamCreateBoundPair that is necessary 
// because the bound pairs are broken on iPhone OS up-to-and-including 
// version 3.0.1 <rdar://problem/7027394> <rdar://problem/7027406>.  It 
// emulates a bound pair by creating a pair of UNIX domain sockets and wrapper 
// each end in a CFSocketStream.  This won't give great performance, but 
// it doesn't crash!
{
#pragma unused(transferBufferSize)
    int                 err;
    Boolean             success;
    CFReadStreamRef     readStream;
    CFWriteStreamRef    writeStream;
    int                 fds[2];
    
    assert(readStreamPtr != NULL);
    assert(writeStreamPtr != NULL);
    
    readStream = NULL;
    writeStream = NULL;
    
    // Create the UNIX domain socket pair.
    
    err = socketpair(AF_UNIX, SOCK_STREAM, 0, fds);
    if (err == 0) {
        CFStreamCreatePairWithSocket(kCFAllocatorDefault, fds[0], &readStream,  NULL);
        CFStreamCreatePairWithSocket(kCFAllocatorDefault, fds[1], NULL, &writeStream);
        
        // If we failed to create one of the streams, ignore them both.
        
        if ( (readStream == NULL) || (writeStream == NULL) ) {
            if (readStream != NULL) {
                CFRelease(readStream);
                readStream = NULL;
            }
            if (writeStream != NULL) {
                CFRelease(writeStream);
                writeStream = NULL;
            }
        }
        assert( (readStream == NULL) == (writeStream == NULL) );
        
        // Make sure that the sockets get closed (by us in the case of an error, 
        // or by the stream if we managed to create them successfull).
        
        if (readStream == NULL) {
            err = close(fds[0]);
            assert(err == 0);
            err = close(fds[1]);
            assert(err == 0);
        } else {
            success = CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
            assert(success);
            success = CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
            assert(success);
        }
    }
    
    *readStreamPtr = readStream;
    *writeStreamPtr = writeStream;
}

// A category on NSStream that provides a nice, Objective-C friendly way to create 
// bound pairs of streams.

@implementation NSURLRequest(NSHTTPURLRequestFix)

+(BOOL)allowAnyHTTPSCertificatieForHost:(NSString*)host
{
	return YES;
}

@end


@interface NSStream (BoundPairAdditions)
+ (void)createBoundInputStream:(NSInputStream **)inputStreamPtr outputStream:(NSOutputStream **)outputStreamPtr bufferSize:(NSUInteger)bufferSize;
@end

@implementation NSStream (BoundPairAdditions)

+ (void)createBoundInputStream:(NSInputStream **)inputStreamPtr outputStream:(NSOutputStream **)outputStreamPtr bufferSize:(NSUInteger)bufferSize
{
    CFReadStreamRef     readStream;
    CFWriteStreamRef    writeStream;
	
    assert( (inputStreamPtr != NULL) || (outputStreamPtr != NULL) );
	
    readStream = NULL;
    writeStream = NULL;
	
    if (YES) {
        CFStreamCreateBoundPairCompat(
									  NULL, 
									  ((inputStreamPtr  != nil) ? &readStream : NULL),
									  ((outputStreamPtr != nil) ? &writeStream : NULL), 
									  (CFIndex) bufferSize
									  );
    } else {
        CFStreamCreateBoundPair(
								NULL, 
								((inputStreamPtr  != nil) ? &readStream : NULL),
								((outputStreamPtr != nil) ? &writeStream : NULL), 
								(CFIndex) bufferSize
								);
    }
    
    if (inputStreamPtr != NULL) {
		  *inputStreamPtr  = [NSMakeCollectable(readStream) autorelease];
    }
    if (outputStreamPtr != NULL) {
		  *outputStreamPtr = [NSMakeCollectable(writeStream) autorelease];
    }
}

@end

@implementation HttpAgentParameter

@synthesize requestApi;
@synthesize requestSubApi;		// 동일한 requestApi를 사용할때, 구분할수 있도록 추가
@synthesize uniqueId;
@synthesize filePath;
@synthesize cid;
@synthesize isRepresent;
@synthesize message;
@synthesize sessionKey;
@synthesize messageKey;
@synthesize mType;
@synthesize mediaData;

-(id)init
{
	self = [super init];
	
	if(self != nil) {
		requestApi = nil;
		requestSubApi = nil;
		uniqueId = nil;
		testUniqueId = nil;
		filePath = nil;
		cid = nil;
		isRepresent = nil;
		message = nil;
		sessionKey = nil;
		messageKey = nil;
		mType = nil;
		mediaData = nil;
	}

	return self;
}

-(void)dealloc
{
//	if (requestApi) {
//		[requestApi release];
//		requestApi = nil;
//	}
//	if (requestSubApi) {
//		[requestSubApi release];
//		requestSubApi = nil;
//	}
	if (uniqueId) {
		[uniqueId release];
		uniqueId = nil;
	}
//	if (filePath) {
//		[filePath release];
//		filePath = nil;
//	}
//	if (cid) {
//		[cid release];
//		cid = nil;
//	}
//	if (isRepresent) {
//		[isRepresent release];
//		isRepresent = nil;
//	}
//	if (message) {
//		[message release];
//		message = nil;
//	}
//	if (sessionKey) {
//		[sessionKey release];
//		sessionKey = nil;
//	}
//	if (messageKey) {
//		[messageKey release];
//		messageKey = nil;
//	}
//	if (mType) {
//		[mType release];
//		mType = nil;
//	}
//	if (mediaData) {
//		[mediaData release];
//		mediaData = nil;
//	}	
	
	[super dealloc];
}

@end


@interface NSString (HTTPExtensions)
- (BOOL)isHTTPContentType:(NSString *)prefixStr;
@end	// @interface NSString (HTTPExtensions)

@implementation NSString (HTTPExtensions)
- (BOOL)isHTTPContentType:(NSString *)prefixStr
{
    BOOL    result;
    NSRange foundRange;
    
    result = NO;
	
    foundRange = [self rangeOfString:prefixStr options:NSAnchoredSearch | NSCaseInsensitiveSearch];
    if (foundRange.location != NSNotFound) {
        assert(foundRange.location == 0);            // because it's anchored
        if (foundRange.length == self.length) {
            result = YES;
        } else {
            unichar nextChar;
            
            nextChar = [self characterAtIndex:foundRange.length];
            result = nextChar <= 32 || nextChar >= 127 || (strchr("()<>@,;:\\<>/[]?={}", nextChar) != NULL);
        }
		
		//		 From RFC 2616:
		//		 
		//		 token          = 1*<any CHAR except CTLs or separators>
		//		 separators     = "(" | ")" | "<" | ">" | "@"
		//						 | "," | ";" | ":" | "\" | <">
		//						 | "/" | "[" | "]" | "?" | "="
		//						 | "{" | "}" | SP | HT
		//		 media-type     = type "/" subtype *( ";" parameter )
		//		 type           = token
		//		 subtype        = token
    }
    return result;
}
@end	// @implementation NSString (HTTPExtensions)

@interface HttpAgent ()
// Properties that don't need to be seen by the outside world.
//@property (nonatomic, readonly) BOOL			 isRequest;
@property (nonatomic, retain)   NSURLConnection	*connection;
@property (nonatomic, retain)   NSInputStream	*fileInputStream;
@property (nonatomic, retain)   NSOutputStream	*fileOutputStream;
@property (nonatomic, retain)   NSInputStream	*consumerStream;

@property (nonatomic, copy)     NSData			*bodyUploadFileData;
@property (nonatomic, copy)     NSData			*bodyParamData;
@property (nonatomic, assign)   const uint8_t	*buffer;
@property (nonatomic, assign)   uint8_t			*bufferOnHeap;
@property (nonatomic, assign)   size_t            bufferOffset;
@property (nonatomic, assign)   size_t            bufferLimit;
@end	// @interface HttpAgent ()

@implementation HttpAgent

@synthesize receivedData;
@synthesize response;
@synthesize delegate			= _delegate;
@synthesize responseStatusCode	= _responseStatusCode;
@synthesize connection			= _connection;
@synthesize fileInputStream		= _fileInputStream;
@synthesize fileOutputStream	= _fileOutputStream;

@synthesize bodyUploadFileData	= _bodyUploadFileData;
@synthesize bodyParamData		= _bodyParamData;

@synthesize consumerStream		= _consumerStream;
@synthesize buffer				= _buffer;
@synthesize bufferOnHeap		= _bufferOnHeap;
@synthesize bufferOffset		= _bufferOffset;
@synthesize bufferLimit			= _bufferLimit;
@synthesize requstType;
@synthesize delegateParameter;
@synthesize expectedContentLength;
@synthesize uploadLength;

#pragma mark -
#pragma mark 쿠키 세팅 static function 
+ (void)setCookie:(NSString*)ucmc cookieUCCS:(NSString*)uccs cookieMC:(NSString*)mc cookieCS:(NSString*)cs
{
	if (strCookieUCMC != ucmc) {
		[strCookieUCMC release];
		strCookieUCMC = [ucmc copy];
	}
	if (strCookieUCCS != uccs) {
		[strCookieUCCS release];
		strCookieUCCS = [uccs copy];
	}
	if (strCookieMC != mc) {
		[strCookieMC release];
		strCookieMC = [mc copy];
	}
	if (strCookieCS != cs) {
		[strCookieCS release];
		strCookieCS = [cs copy];
	}
}

+ (NSString*)ucmc
{
	return strCookieUCMC;
}

+ (NSString*)uccs
{
	return strCookieUCCS;
}

+ (NSString*)mc
{
	return strCookieMC;
}

+ (NSString*)cs
{
	return strCookieCS;
}

#pragma mark -
#pragma mark Initialize
- (id) init 
{
	self = [super init];
	if(self != nil) {
		// TODO : initialize
		delegateParameter = [[HttpAgentParameter alloc] init];
	}

	return self;
}

#pragma mark -
#pragma mark Request Function
- (BOOL)requestUrl:(NSString *)url bodyObject:(NSDictionary *)bodyObject parent:(id)aDelegate timeout:(NSInteger)time
{
	self.delegate = aDelegate;
	[self setRequstType:HttpRequestUrlType];

    // URL Request 객체 생성
	NSLog(@"요청 대기 시간은 몇초인가..%i", time);
	
	
	
	
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy 
															timeoutInterval:time];
	
	
	

	
	
	
	
	assert(request != nil);
//* cookie 처리
	NSString *strUCMC = [HttpAgent ucmc];
	NSString *strUCCS = [HttpAgent uccs];
//	NSLog(@"strUCMC = %@", strUCMC);
//	NSLog(@"strUCCS = %@", strUCCS);
	if ([strUCMC length] > 0 && [strUCCS length] > 0) {
		NSString *strMC = [HttpAgent mc];
		NSString *strCS = [HttpAgent cs];
		if ([strMC length] > 0 && [strCS length] > 0) {
			NSDictionary *newCookieDict = [NSDictionary dictionaryWithObjectsAndKeys:strUCMC, @"UCMC", 
																				   strUCCS, @"UCCS", 
																				   strMC, @"MC", 
																				   strCS, @"CS", 
																				   nil];
			if (newCookieDict != nil) {
				NSHTTPCookie *newHttpCookieUCMC = [NSHTTPCookie cookieWithProperties:[NSDictionary dictionaryWithObjectsAndKeys:
																					  @"UCMC",		NSHTTPCookieName,
																					  strUCMC,	NSHTTPCookieValue,
																					  @"paran.com",	NSHTTPCookieDomain,
																					  @"\\",			NSHTTPCookiePath,
																					  nil]];
				NSHTTPCookie *newHttpCookieUCCS = [NSHTTPCookie cookieWithProperties:[NSDictionary dictionaryWithObjectsAndKeys:
																					  @"UCCS",		NSHTTPCookieName,
																					  strUCCS,	NSHTTPCookieValue,
																					  @"paran.com",	NSHTTPCookieDomain,
																					  @"\\",			NSHTTPCookiePath,
																					  nil]];
				NSHTTPCookie *newHttpCookieMC = [NSHTTPCookie cookieWithProperties:[NSDictionary dictionaryWithObjectsAndKeys:
																					@"MC",		NSHTTPCookieName,
																					strMC,	NSHTTPCookieValue,
																					@"paran.com",	NSHTTPCookieDomain,
																					@"\\",			NSHTTPCookiePath,
																					nil]];
				
				NSHTTPCookie *newHttpCookieCS = [NSHTTPCookie cookieWithProperties:[NSDictionary dictionaryWithObjectsAndKeys:
																					@"CS",		NSHTTPCookieName,
																					strCS,	NSHTTPCookieValue,
																					@"paran.com",	NSHTTPCookieDomain,
																					@"\\",			NSHTTPCookiePath,
																					nil]];
				assert(newHttpCookieUCMC != nil);
				assert(newHttpCookieUCCS != nil);
				assert(newHttpCookieMC != nil);
				assert(newHttpCookieCS != nil);
				
				NSArray *cookiesArray = [NSArray arrayWithObjects:newHttpCookieUCMC, newHttpCookieUCCS, newHttpCookieMC, newHttpCookieCS, nil];
				assert(cookiesArray != nil);
				NSDictionary *header = [NSHTTPCookie requestHeaderFieldsWithCookies:cookiesArray];
				assert(header != nil);
				[request setAllHTTPHeaderFields:header];
			}
		} else {
			NSDictionary *newCookieDict = [NSDictionary dictionaryWithObjectsAndKeys:strUCMC, @"UCMC", 
																				   strUCCS, @"UCCS", 
																				   nil];
			if (newCookieDict != nil) {
				NSHTTPCookie *newHttpCookieUCMC = [NSHTTPCookie cookieWithProperties:[NSDictionary dictionaryWithObjectsAndKeys:
																					  @"UCMC",		NSHTTPCookieName,
																					  strUCMC,	NSHTTPCookieValue,
																					  @"paran.com",	NSHTTPCookieDomain,
																					  @"\\",			NSHTTPCookiePath,
																					  nil]];
				
				NSHTTPCookie *newHttpCookieUCCS = [NSHTTPCookie cookieWithProperties:[NSDictionary dictionaryWithObjectsAndKeys:
																					  @"UCCS",		NSHTTPCookieName,
																					  strUCCS,	NSHTTPCookieValue,
																					  @"paran.com",	NSHTTPCookieDomain,
																					  @"\\",			NSHTTPCookiePath,
																					  nil]];
				assert(newHttpCookieUCMC != nil);
				assert(newHttpCookieUCCS != nil);
				
				NSArray *cookiesArray = [NSArray arrayWithObjects:newHttpCookieUCMC, newHttpCookieUCCS, nil];
				assert(cookiesArray != nil);
				NSDictionary *header = [NSHTTPCookie requestHeaderFieldsWithCookies:cookiesArray];
				assert(header != nil);
				[request setAllHTTPHeaderFields:header];
			}
		}
	}
//*/
	// 참고 : http://coderant.egloos.com/3706282 Content-Type 분석
	// x-www-form-urlencode와 multipart/form-data은 둘다 폼 형태이지만 
	// x-www-form-urlencode은 대용량 바이너리 데이터를 전송하기에 비능률적이기 때문에 
	// 대부분 첨부파일은 multipart/form-data를 사용.
	
	// Application의 타입  
	// Content-Type : application/x-www-form-urlencoded		// HTML Form 형태
	// Content-Type : multipart/form-data					// HTML Form 형태 (파일 첨부)
	[request addValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
	
	// 통신방식 정의 (POST, GET) : default = GET
	// 1. GET 방식
	//    [request setHTTPMethod:@"GET"];
	// 2. POST 방식
	//    [request setHTTPMethod:@"POST"]; // POST로 선언하고
	//    [request setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]]; // 전송할 데이터를 변수명=값&변수명=값 형태의 문자열로 등록
	// 참고
	// POST 방식의 요청은 GET 과 비슷하나 URL과 함께 key=value에 기반한 데이터도 함께 전송한다는 차이점이 있다.
	// POST 방식은 [request setHTTPMethod:@"POST"]; 로 초기화하고 [request setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];  
	// 으로 전송할 데이터를 입력하는데 전송할 데이터(여기서는 bodyString이라는 NSString)는 변수명=값&변수명=값 형태의 문자열로 구성해야한다. 
	// 물론 값은 기본적으로 urlencode 처리를 해야한다. 헤더는 [request setValue:value forHTTPHeaderField:key]; 와 같이 key에 대한 값을 필요한 개수만큼 
	// 추가하면 된다.
    [request setHTTPMethod:@"POST"];
	
    
	// 헤더  추가가 필요하면 아래 메소드를 이용
	// [request setValue:value forHTTPHeaderField:key];

    // bodyObject의 객체가 존재할 경우 QueryString형태로 변환
    if(bodyObject) {
        // 임시 변수 선언
        NSMutableArray *parts = [NSMutableArray array];
        NSString *part = nil;
        id key;
        id value;

        // 값을 하나하나 변환
        for(key in bodyObject) {
            value = [bodyObject objectForKey:key];
			if(value != [NSNull null]) {
				part = [NSString stringWithFormat:@"%@=%@", [self currentMessageUrlEncoded:(NSString*)key], [self currentMessageUrlEncoded:(NSString*)value]];
			} else {
				part = [NSString stringWithFormat:@"%@=%@", [self currentMessageUrlEncoded:(NSString*)key], @""];
			}
            [parts addObject:part];
        }
		if([delegateParameter.requestApi isEqualToString:@"addListContact"]) {
			DebugLog(@"addListContact");
			//	DebugLog(@"\n=====> httpRequest : %@ %@\n", delegateParameter.requestApi, delegateParameter.requestSubApi);
		} else {
		//	DebugLog(@"\n=====> httpRequest : %@ %@ %@\n", delegateParameter.requestApi, delegateParameter.requestSubApi, parts);
		}
        
        // 값들을 &로 연결하여 Body에 사용
		
		
		
		
		
		[request setHTTPBody:[[parts componentsJoinedByString:@"&"] dataUsingEncoding:NSUTF8StringEncoding]];
	
	
	//	NSLog(@"request %@", [[parts componentsJoinedByString:@"&"] dataUsingEncoding:NSUTF8StringEncoding]);
		
		
		
		

		
		
		
		
		
		
    } else {
		
	}
	
	
	
	
	
		
    
    // Request를 사용하여 실제 연결을 시도하는 NSURLConnection 인스턴스 생성
	// 메소드를 호출하면 비동기로 통신이 되기 때문에 접속만 이상이 없다면 호출 즉시 YES가 반환
	
//    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
//	NSURLConnection *connect = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
	
	
	NSLog(@"request %@", request);
	
	self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
	
	
	
	
	

	
	
	
	
//	[connect release];
    assert(self.connection != nil);
	
//	[bodyObject release];
    // 정상적으로 연결이 되었다면
    if(self.connection) {
		NSLog(@"sucess");
        // 데이터를 전송받을 멤버 변수 초기화
        receivedData = [[NSMutableData alloc] init];
        return YES;
    } else {
		NSLog(@"faild");
		// inform the user that the download could not be made
		// [todo] error
	}
    
    return NO;
}

-(NSString*)currentMessageUrlEncoded:(NSString *)currentMessage {
//	NSLog(@"currentMsg %@", currentMessage);
	CFStringRef encoded = CFURLCreateStringByAddingPercentEscapes(
																  kCFAllocatorDefault, 
																  (CFStringRef) currentMessage, 
																  nil, 
																  (CFStringRef) @"&#;+?=/~!", 
																  kCFStringEncodingUTF8);  
//	NSLog(@"encode = %@", encoded);
	return [((NSString*) encoded) autorelease];
}

- (BOOL)requestUploadUrl:(NSString *)url filePath:(NSString*)path parent:(id)aDelegate timeout:(NSInteger)time
{
	self.delegate = aDelegate;
	[self setRequstType:HttpRequestUploadUrlType]; //업로드..
	
	BOOL		success = NO;
	NSNumber	*contentLength = nil;
	NSURL		*nsurl;

	assert(path != nil);
    assert([[NSFileManager defaultManager] fileExistsAtPath:path]);
/*
 iPhone Supported video formats
	video H.264, MPEG-4 in .mp4, .m4v, .mov formats 
	
 iPhone Supported video/audio formats
	audio files in AAC, MP3, M4a
 
 iPhone Supported image formats
	Portable Network Graphic (PNG)			.png
	Tagged Image File Format (TIFF)			.tiff, .tif
	Joint Photographic Experts Group(JPEG)  .jpeg, .jpg
	Graphic Interchange Format (GIF)		.gif
	Windows Bitmap Format (DIB)				.bmp, .BMPf
	Windows Icon Format						.ico
	Windows Cursor							.cur
	XWindow bitmap							.xbm
 //*/
//mezzo	NSString *extension = path.pathExtension;
//mezzo	extension = [extension lowercaseString];

    assert(self.connection == nil);				// don't tap send twice in a row!
    assert(self.fileInputStream == nil);        // ditto

	// First get and check the URL.
	nsurl = [self smartURLForString:url];
	success = (nsurl != nil);

	if (success) {
        // Add the last the file name to the end of the URL to form the final 
        // URL that we're going to PUT to.
        nsurl = [NSMakeCollectable(CFURLCreateCopyAppendingPathComponent(NULL, (CFURLRef) nsurl, (CFStringRef) [path lastPathComponent], false)) autorelease];
        success = (url != nil);
    }
	
	// If the URL is bogus, let the user know.  Otherwise kick off the connection.

    if ( ! success) {
		// Invalid URL
		return NO;
	} else {
		// Open a stream for the file we're going to send.  We do not open this stream; 
		// NSURLConnection will do it for us.
		self.fileInputStream = [NSInputStream inputStreamWithFileAtPath:path]; //업로드할 경로의 스트림을 개방..
		assert(self.fileInputStream != nil); //반드시 스트림은 널이 아니어야 한다.
		
		// URL Request 객체 생성
		// Open a connection for the URL, configured to PUT the file.
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:nsurl 
															   cachePolicy:NSURLRequestUseProtocolCachePolicy 
																timeoutInterval:time];
		assert(request != nil);
		
		[request setHTTPMethod:@"PUT"];
		[request setHTTPBodyStream:self.fileInputStream];
		
		NSString *extension = path.pathExtension;
		extension = [extension lowercaseString]; //파일 확장자를 의미..
		
		if ( [extension isEqual:@"mp4"] ) {
            [request setValue:@"video/mp4" forHTTPHeaderField:@"Content-Type"];
		} else if ( [extension isEqual:@"m4v"] ) {
            [request setValue:@"video/m4v" forHTTPHeaderField:@"Content-Type"];
		} else if ( [extension isEqual:@"mov"] ) {
            [request setValue:@"video/mov" forHTTPHeaderField:@"Content-Type"];
		} else if ( [extension isEqual:@"png"] ) {
            [request setValue:@"image/png" forHTTPHeaderField:@"Content-Type"];
		} else if ( [extension isEqual:@"tiff"] ) {
            [request setValue:@"image/tiff" forHTTPHeaderField:@"Content-Type"];
		} else if ( [extension isEqual:@"tif"] ) {
            [request setValue:@"image/tif" forHTTPHeaderField:@"Content-Type"];
        } else if ( [extension isEqual:@"jpg"] || [extension isEqual:@"jpeg"]) {
            [request setValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
        } else if ( [extension isEqual:@"gif"] ) {
            [request setValue:@"image/gif" forHTTPHeaderField:@"Content-Type"];
		} else if ( [extension isEqual:@"bmp"] ) {
            [request setValue:@"image/bmp" forHTTPHeaderField:@"Content-Type"];
		} else if ( [extension isEqual:@"bmpf"] ) {
            [request setValue:@"image/BMPf" forHTTPHeaderField:@"Content-Type"];
		} else if ( [extension isEqual:@"ico"] ) {
            [request setValue:@"image/ico" forHTTPHeaderField:@"Content-Type"];
		} else if ( [extension isEqual:@"cur"] ) {
            [request setValue:@"image/cur" forHTTPHeaderField:@"Content-Type"];
		} else if ( [extension isEqual:@"xbm"] ) {
            [request setValue:@"image/xbm" forHTTPHeaderField:@"Content-Type"];
        } else {
            assert(NO);
			return NO;
        }

		contentLength = (NSNumber *) [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:NULL] objectForKey:NSFileSize];
        assert( [contentLength isKindOfClass:[NSNumber class]] );
        [request setValue:[contentLength description] forHTTPHeaderField:@"Content-Length"];
        
        self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
        assert(self.connection != nil);
		if (self.connection) {
			receivedData = [[NSMutableData alloc] init];
		}
		
		return YES;
	}
	
	return NO;
}

- (BOOL)requestDownloadUrl:(NSString *)url filePath:(NSString*)path parent:(id)aDelegate timeout:(NSInteger)time
{
	self.delegate = aDelegate;
	[self setRequstType:HttpRequestDownloadUrlType];
	
	BOOL         success = NO;
	NSURL		*nsurl = nil;
	
	assert(self.connection == nil);
	assert(path != nil);

	NSString *filePath = [NSString stringWithString:path];
	NSString *extension = filePath.pathExtension;
	extension = [extension lowercaseString];
	
	assert( [extension isEqual:@"mp4"] || [extension isEqual:@"m4v"] || [extension isEqual:@"mov"] 
		   || [extension isEqual:@"png"] || [extension isEqual:@"tiff"]  || [extension isEqual:@"tif"]
		   || [extension isEqual:@"jpg"] || [extension isEqual:@"jpeg"]  || [extension isEqual:@"gif"]
		   || [extension isEqual:@"bmp"] || [extension isEqual:@"bmpf"]  || [extension isEqual:@"ico"]
		   || [extension isEqual:@"cur"] || [extension isEqual:@"xbm"]);
	
    assert(self.fileOutputStream == nil);        // ditto
	
	// First get and check the URL.
	nsurl = [self smartURLForString:url];
	success = (nsurl != nil);
	
	if (!success) {
		// TODO: Invalid URL (예외처리 필요)
		return NO;
	} else {
		self.fileOutputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
        assert(self.fileOutputStream != nil);
		
		 [self.fileOutputStream open];
		
		// URL Request 객체 생성
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:nsurl
															   cachePolicy:NSURLRequestUseProtocolCachePolicy 
														   timeoutInterval:time];
		
		assert(request != nil);
		
		self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
		assert(self.connection != nil);
		
		if (self.connection) {
			receivedData = [[NSMutableData alloc] init];
		}

		return YES;
	}
		
	return NO;
}

- (BOOL)requestUploadUrlMultipartForm:(NSString *)url bodyObject:(NSDictionary *)bodyObject parent:(id)aDelegate timeout:(NSInteger)time
{
	self.delegate = aDelegate;
	[self setRequstType:HttpRequestUploadUrlMultipartFormType];
	uploadLength = 0;
	
	BOOL		success = NO;
	NSURL		*nsurl = nil;
	NSString	*contentType = nil;
	self.bufferOffset = 0;
	self.bufferLimit  = 0;
	
	assert(delegateParameter.filePath != nil);
    assert([[NSFileManager defaultManager] fileExistsAtPath:delegateParameter.filePath]);

    assert(self.connection == nil);				// don't tap send twice in a row!
    assert(self.fileInputStream == nil);
	assert(self.fileOutputStream == nil);
	assert(self.consumerStream == nil);
	
	assert(self.bodyUploadFileData == nil);
	assert(self.bodyParamData == nil);
	
	assert(self.buffer == NULL);
    assert(self.bufferOnHeap == NULL);
	
	// First get and check the URL.
	nsurl = [self smartURLForString:url];
	success = (nsurl != nil);
	
	// If the URL is bogus, let the user know.  Otherwise kick off the connection.
    if ( ! success) {
		// Invalid URL
		return NO;
	} else {
		// URL Request 객체 생성
		// Open a connection for the URL, configured to POST the file.
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
															   cachePolicy:NSURLRequestUseProtocolCachePolicy 
														   timeoutInterval:time];
		assert(request != nil);

		NSString *extension = delegateParameter.filePath.pathExtension;
		extension = [extension lowercaseString];
		if ( [extension isEqual:@"mp4"] ) {
			contentType = @"video/mp4";
		} else if ( [extension isEqual:@"m4v"] ) {
			contentType = @"video/m4v";
		} else if ( [extension isEqual:@"mov"] ) {
			contentType = @"video/mov";
		} else if ( [extension isEqual:@"png"] ) {
			contentType = @"image/png";
		} else if ( [extension isEqual:@"tiff"] ) {
			contentType = @"image/tiff";
		} else if ( [extension isEqual:@"tif"] ) {
			contentType = @"image/tif";
        } else if ( [extension isEqual:@"jpg"] || [extension isEqual:@"jpeg"]) {
			contentType = @"image/jpeg";
        } else if ( [extension isEqual:@"gif"] ) {
			contentType = @"image/gif";
		} else if ( [extension isEqual:@"bmp"] ) {
			contentType = @"image/bmp";
		} else if ( [extension isEqual:@"bmpf"] ) {
			contentType = @"image/BMPf";
		} else if ( [extension isEqual:@"ico"] ) {
			contentType = @"image/ico";
		} else if ( [extension isEqual:@"cur"] ) {
			contentType = @"image/cur";
		} else if ( [extension isEqual:@"xbm"] ) {
			contentType = @"image/xbm";
        } else {
			//2011.02.08 kjh
			NSLog(@"assert NO %@", extension);
	//		assert(NO);
			contentType = nil;
			return NO; //2011.02.08 kjh
        }

		//* cookie 처리
		NSString *strUCMC = [HttpAgent ucmc];
		NSString *strUCCS = [HttpAgent uccs];
		if ([strUCMC length] > 0 && [strUCCS length] > 0) {
			NSString *strMC = [HttpAgent mc];
			NSString *strCS = [HttpAgent cs];
			if ([strMC length] > 0 && [strCS length] > 0) {
				NSDictionary *newCookieDict = [NSDictionary dictionaryWithObjectsAndKeys:strUCMC, @"UCMC", 
											   strUCCS, @"UCCS", 
											   strMC, @"MC", 
											   strCS, @"CS", 
											   nil];
				if (newCookieDict != nil) {
					NSHTTPCookie *newHttpCookieUCMC = [NSHTTPCookie cookieWithProperties:[NSDictionary dictionaryWithObjectsAndKeys:
																						  @"UCMC",		NSHTTPCookieName,
																						  strUCMC,	NSHTTPCookieValue,
																						  @"paran.com",	NSHTTPCookieDomain,
																						  @"\\",			NSHTTPCookiePath,
																						  nil]];
					NSHTTPCookie *newHttpCookieUCCS = [NSHTTPCookie cookieWithProperties:[NSDictionary dictionaryWithObjectsAndKeys:
																						  @"UCCS",		NSHTTPCookieName,
																						  strUCCS,	NSHTTPCookieValue,
																						  @"paran.com",	NSHTTPCookieDomain,
																						  @"\\",			NSHTTPCookiePath,
																						  nil]];
					NSHTTPCookie *newHttpCookieMC = [NSHTTPCookie cookieWithProperties:[NSDictionary dictionaryWithObjectsAndKeys:
																						@"MC",		NSHTTPCookieName,
																						strMC,	NSHTTPCookieValue,
																						@"paran.com",	NSHTTPCookieDomain,
																						@"\\",			NSHTTPCookiePath,
																						nil]];
					
					NSHTTPCookie *newHttpCookieCS = [NSHTTPCookie cookieWithProperties:[NSDictionary dictionaryWithObjectsAndKeys:
																						@"CS",		NSHTTPCookieName,
																						strCS,	NSHTTPCookieValue,
																						@"paran.com",	NSHTTPCookieDomain,
																						@"\\",			NSHTTPCookiePath,
																						nil]];
					assert(newHttpCookieUCMC != nil);
					assert(newHttpCookieUCCS != nil);
					assert(newHttpCookieMC != nil);
					assert(newHttpCookieCS != nil);
					
					NSArray *cookiesArray = [NSArray arrayWithObjects:newHttpCookieUCMC, newHttpCookieUCCS, newHttpCookieMC, newHttpCookieCS, nil];
					assert(cookiesArray != nil);
					NSDictionary *header = [NSHTTPCookie requestHeaderFieldsWithCookies:cookiesArray];
					assert(header != nil);
					[request setAllHTTPHeaderFields:header];
				}
			} else {
				NSDictionary *newCookieDict = [NSDictionary dictionaryWithObjectsAndKeys:strUCMC, @"UCMC", 
											   strUCCS, @"UCCS", 
											   nil];
				if (newCookieDict != nil) {
					NSHTTPCookie *newHttpCookieUCMC = [NSHTTPCookie cookieWithProperties:[NSDictionary dictionaryWithObjectsAndKeys:
																						  @"UCMC",		NSHTTPCookieName,
																						  strUCMC,	NSHTTPCookieValue,
																						  @"paran.com",	NSHTTPCookieDomain,
																						  @"\\",			NSHTTPCookiePath,
																						  nil]];
					
					NSHTTPCookie *newHttpCookieUCCS = [NSHTTPCookie cookieWithProperties:[NSDictionary dictionaryWithObjectsAndKeys:
																						  @"UCCS",		NSHTTPCookieName,
																						  strUCCS,	NSHTTPCookieValue,
																						  @"paran.com",	NSHTTPCookieDomain,
																						  @"\\",			NSHTTPCookiePath,
																						  nil]];
					assert(newHttpCookieUCMC != nil);
					assert(newHttpCookieUCCS != nil);
					
					NSArray *cookiesArray = [NSArray arrayWithObjects:newHttpCookieUCMC, newHttpCookieUCCS, nil];
					assert(cookiesArray != nil);
					NSDictionary *header = [NSHTTPCookie requestHeaderFieldsWithCookies:cookiesArray];
					assert(header != nil);
					[request setAllHTTPHeaderFields:header];
				}
			}
		}

//		NSString *contentType = @"application/octet-stream;";	
		// Calculate the multipart/form-data body.  For more information about the 
        // format of the prefix and suffix, see:
        //
        // o HTML 4.01 Specification
        //   Forms
        //   <http://www.w3.org/TR/html401/interact/forms.html#h-17.13.4>
        //
        // o RFC 2388 "Returning Values from Forms: multipart/form-data"
        //   <http://www.ietf.org/rfc/rfc2388.txt>
		
		NSString *boundaryStr = [self _generateBoundaryString];
		assert(boundaryStr != nil);
		NSString *bodyUploadFileStr = nil;
		NSString *bodyMediaTypeStr = nil;
		NSString *bodyUUIDStr = nil;
		NSString *bodyTransParamStr = nil;
		unsigned long long bodyLength = 0;
		
		// bodyObject의 객체가 존재할 경우 QueryString형태로 변환
		if(bodyObject) {
			// 임시 변수 선언
			id key;
			id value;

			// 값을 하나하나 변환
			for(key in bodyObject) {
				value = [bodyObject objectForKey:key];
				if ([(NSString*)key isEqualToString:@"uploadFile"]) {
					bodyUploadFileStr = [NSString stringWithFormat:
										 @
										 // empty preamble
										 "\r\n"
										 "--%@\r\n"
										 "Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n"
										 "Content-Type: %@\r\n"
										 "Content-Type: application/octet-stream\r\n\r\n",
										 boundaryStr,
										 key,
										 [delegateParameter.filePath lastPathComponent],       // +++ very broken for non-ASCII
										 contentType
										 ];
				} else if ([(NSString*)key isEqualToString:@"mediaType"]) {
					bodyMediaTypeStr = [NSString stringWithFormat:
								   @
								   "\r\n"
								   "--%@\r\n"
								   "Content-Disposition: form-data; name=\"%@\"\r\n"
								   "\r\n"
								   "%@"							   
								   ,
								   boundaryStr, 
								   key, 
								   value
								   ];
				} else if ([(NSString*)key isEqualToString:@"uuid"]) {
					bodyUUIDStr = [NSString stringWithFormat:
								   @
								   "\r\n"
								   "--%@\r\n"
								   "Content-Disposition: form-data; name=\"%@\"\r\n"
								   "\r\n"
								   "%@"
								   ,
								   boundaryStr, 
								   key, 
								   value
								   ];
				} else if ([(NSString*)key isEqualToString:@"transParam"]) {
					bodyTransParamStr = [NSString stringWithFormat:
										 @
										 "\r\n"
										 "--%@\r\n"
										 "Content-Disposition: form-data; name=\"%@\"\r\n"
										 "\r\n"
										 "%@\r\n"
										 "--%@--\r\n" 
										 "\r\n"
										 ,
										 boundaryStr, 
										 key, 
										 value,
										 boundaryStr
										 ];

				} else {
					// skip
				}
			}
			assert(bodyUploadFileStr != nil);
			assert(bodyMediaTypeStr != nil);
			assert(bodyUUIDStr != nil);
			assert(bodyTransParamStr != nil);
			
			NSString *bodyParamStr = [NSString stringWithFormat:@"%@%@%@", bodyMediaTypeStr, bodyUUIDStr, bodyTransParamStr];
			assert(bodyParamStr != nil);
			NSLog(@"httpMultiPartFormRequest %@ %@ %@, %@", delegateParameter.requestApi,  delegateParameter.requestSubApi, bodyUploadFileStr, bodyParamStr);
			self.bodyUploadFileData = [bodyUploadFileStr dataUsingEncoding:NSASCIIStringEncoding];
			assert(self.bodyUploadFileData != nil);
			self.bodyParamData = [bodyParamStr dataUsingEncoding:NSASCIIStringEncoding];
			assert(self.bodyParamData != nil);
//
			NSNumber *fileLengthNum = (NSNumber *) [[[NSFileManager defaultManager] attributesOfItemAtPath:delegateParameter.filePath error:NULL] objectForKey:NSFileSize];
//			NSLog(@"fileSize = %i", [fileLengthNum unsignedIntValue]);
			assert( [fileLengthNum isKindOfClass:[NSNumber class]] );
//			
			bodyLength = (unsigned long long) [self.bodyUploadFileData length]
						+ [fileLengthNum unsignedLongLongValue]
						+ (unsigned long long) [self.bodyParamData length];
//			NSLog(@"bodyLength = %i", bodyLength);
//
			if(delegateParameter.mediaData) {
				NSLog(@"fileInputStream mediaData start");
				self.fileInputStream = [NSInputStream inputStreamWithData:delegateParameter.mediaData];
				NSLog(@"fileInputStream mediaData end");
			} else {
				NSLog(@"fileInputStream filePath start");
				self.fileInputStream = [NSInputStream inputStreamWithFileAtPath:delegateParameter.filePath];
				NSLog(@"fileInputStream filePath end");
			}
			assert(self.fileInputStream != nil);

			[self.fileInputStream open];
		}

		// Open OutputStream/consumer streams.  We open the fileOutputStream straight 
		// away.  We leave the consumerStream alone; NSURLConnection will deal 
		// with it.

		[NSStream createBoundInputStream:&self->_consumerStream outputStream:&self->_fileOutputStream bufferSize:32768];
        [self->_consumerStream retain];
        [self->_fileOutputStream retain];
        assert(self.consumerStream != nil);
        assert(self.fileOutputStream != nil);
        
        self.fileOutputStream.delegate = self;
        [self.fileOutputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.fileOutputStream open];
		
		// Set up our state to send the body prefix first.
        self.buffer      = [self.bodyUploadFileData bytes];
        self.bufferLimit = [self.bodyUploadFileData length];
		[request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=\"%@\"", boundaryStr] forHTTPHeaderField:@"content-Type"];
		
		expectedContentLength = bodyLength;
		
		[request setHTTPMethod:@"POST"];
		[request setHTTPBodyStream:self.consumerStream];
		
		[request setValue:[NSString stringWithFormat:@"%llu", bodyLength] forHTTPHeaderField:@"Content-Length"];

		self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
//		[bodyObject release];
		
		NSLog(@"multipartform 전송시작");
		// 정상적으로 연결이 되었다면
		if(self.connection) {
			// 데이터를 전송받을 멤버 변수 초기화
			receivedData = [[NSMutableData alloc] init];
			return YES;
		} else {
			// inform the user that the download could not be made
			// [todo] error
		}
		
		return YES;
	}
	
	return NO;
}

#pragma mark -
#pragma mark property
- (NSString *)_generateBoundaryString
{
    CFUUIDRef       uuid;
    CFStringRef     uuidStr;
    NSString *      result;
    
    uuid = CFUUIDCreate(NULL);
    assert(uuid != NULL);
    
    uuidStr = CFUUIDCreateString(NULL, uuid);
    assert(uuidStr != NULL);
    
    result = [NSString stringWithFormat:@"-%@", uuidStr];
    
    CFRelease(uuidStr);
    CFRelease(uuid);
    
    return result;
}

- (BOOL) isRequest
{
	return (self.connection != nil);
}

- (void) cancelRequest
{
	if (self.connection != nil) {
        [self.connection cancel];
        self.connection = nil;
    }
	if ([self requstType] == HttpRequestUploadUrlType) {
		if (self.fileInputStream != nil) {
			[self.fileInputStream close];
			self.fileInputStream = nil;
		}
	} else if ([self requstType] == HttpRequestDownloadUrlType) {
		if (self.fileOutputStream != nil) {
			[self.fileOutputStream close];
			self.fileOutputStream = nil;
		}
	} else if ([self requstType] == HttpRequestUploadUrlMultipartFormType) {
		if (self.bufferOnHeap) {
			free(self.bufferOnHeap);
			self.bufferOnHeap = NULL;
		}
		self.buffer = NULL;
		self.bufferOffset = 0;
		self.bufferLimit  = 0;
		self.consumerStream = nil;
		self.bodyUploadFileData = nil;
		self.bodyParamData = nil;

		if (self.fileInputStream != nil) {
			[self.fileInputStream close];
			self.fileInputStream = nil;
		}
		if (self.fileOutputStream != nil) {
			self.fileOutputStream.delegate = nil;
			[self.fileOutputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
			[self.fileOutputStream close];
			self.fileOutputStream = nil;
		}
	} else {
		// skip
	}
}

- (NSURL *)smartURLForString:(NSString *)str
{
    NSURL *     result;
    NSString *  trimmedStr;
    NSRange     schemeMarkerRange;
    NSString *  scheme;
    
    assert(str != nil);
	
    result = nil;
    
    trimmedStr = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ( (trimmedStr != nil) && (trimmedStr.length != 0) ) {
        schemeMarkerRange = [trimmedStr rangeOfString:@"://"];
        
        if (schemeMarkerRange.location == NSNotFound) {
            result = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", trimmedStr]];
        } else {
            scheme = [trimmedStr substringWithRange:NSMakeRange(0, schemeMarkerRange.location)];
            assert(scheme != nil);
            
            if ( ([scheme compare:@"http"  options:NSCaseInsensitiveSearch] == NSOrderedSame)
				|| ([scheme compare:@"https" options:NSCaseInsensitiveSearch] == NSOrderedSame) ) {
                result = [NSURL URLWithString:trimmedStr];
            } else {
                // It looks like this is some unsupported URL scheme.
            }
        }
    }
    
    return result;
}

#pragma mark -
#pragma mark delegate
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
// An NSStream delegate callback that's called when events happen on our 
// network stream.
{
#ifdef MEZZO_DEBUG
	NSLog(@"==========HANDLE===============");
#endif
	
	
	#pragma unused(aStream)
    assert(aStream == self.fileOutputStream);
	
    switch (eventCode) {
        case NSStreamEventOpenCompleted: {
		//	NSLog(@"========NSStreamEventOpenCompleted==================");
            // NSLog(@"producer stream opened");
        } break;
        case NSStreamEventHasBytesAvailable: {
		//	NSLog(@"========NSStreamEventHasBytesAvailable==================");
            assert(NO);     // should never happen for the output stream
        } break;
        case NSStreamEventHasSpaceAvailable: {
		//	NSLog(@"=================NSStreamEventHasSpaceAvailable======================");
            // Check to see if we've run off the end of our buffer.  If we have, 
            // work out the next buffer of data to send.
            
            if (self.bufferOffset == self.bufferLimit) {
				
                // See if we're transitioning from the prefix to the file data.
                // If so, allocate a file buffer.
                
                if (self.bodyUploadFileData != nil) {
                    self.bodyUploadFileData = nil;
					
                    assert(self.bufferOnHeap == NULL);
                    self.bufferOnHeap = malloc(kPostBufferSize);
                    assert(self.bufferOnHeap != NULL);
                    self.buffer = self.bufferOnHeap;
                    
                    self.bufferOffset = 0;
                    self.bufferLimit  = 0;
                }
                
                // If we still have file data to send, read the next chunk. 
                
                if (self.fileInputStream != nil) {
                    NSInteger   bytesRead = 0;
                    
                    bytesRead = [self.fileInputStream read:self.bufferOnHeap maxLength:kPostBufferSize];
                    
					
				//	NSLog(@"bytes = %d", bytesRead);
					
					
                    if (bytesRead == -1) {
                        // File read error
						// TODO: 예외처리
						NSLog(@"handleEvent byteRead == -1  File read error");
                    } else if (bytesRead != 0) {
//						NSLog(@"handleEvent byteRead = %i", bytesRead);
                        self.bufferOffset = 0;
                        self.bufferLimit  = bytesRead;
                    } else {
						NSLog(@"handleEvent byteRead = 0  end of the file");
                        // If we hit the end of the file, transition to sending the 
                        // suffix.
                        [self.fileInputStream close];
                        self.fileInputStream = nil;
                        
                        assert(self.bufferOnHeap != NULL);
                        free(self.bufferOnHeap);
                        self.bufferOnHeap = NULL;
                        self.buffer       = [self.bodyParamData bytes];
						
                        self.bufferOffset = 0;
                        self.bufferLimit  = [self.bodyParamData length];
					}
                }
                
                // If we've failed to produce any more data, we close the stream 
                // to indicate to NSURLConnection that we're all done.  We only do 
                // this if producerStream is still valid to avoid running it in the 
                // file read error case.

                if ( (self.bufferOffset == self.bufferLimit) && (self.fileOutputStream != nil) ) {
                    // We set our delegate callback to nil because we don't want to 
                    // be called anymore for this stream.  However, we can't 
                    // remove the stream from the runloop (doing so prevents the 
                    // URL from ever completing) and nor can we nil out our 
                    // stream reference (that causes all sorts of wacky crashes). 
                    //
                    // +++ Need bug numbers for these problems.
                    self.fileOutputStream.delegate = nil;
                    // [self.producerStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
                    [self.fileOutputStream close];
                    // self.producerStream = nil;
					
			//		NSLog(@"handleEvent 111");
                }
            }

            // Send the next chunk of data in our buffer.
            if (self.bufferOffset != self.bufferLimit) {
                NSInteger   bytesWritten = 0;
                bytesWritten = [self.fileOutputStream write:&self.buffer[self.bufferOffset] maxLength:self.bufferLimit - self.bufferOffset];
                if (bytesWritten <= 0) {
                    // Network write error
					// TODO: 예외처리
					NSLog(@"handleEvent bytesWritten <= 0  Network write error");
					
					
					
					
					
					
					
					
					// sochae 2010.09.30 issue - 채팅 화면에서 동영상 전송 중 오류 발생 지점. (전송 실패 되었으므로 재전송 마크 표시 해야 함)
                } else {
			//		NSLog(@"bytesWritten = %i", bytesWritten);
					self.bufferOffset += bytesWritten;
				//	NSLog(@"===================1=================");
					uploadLength += bytesWritten;
				//	NSLog(@"===================2=================");
					if(expectedContentLength != NSURLResponseUnknownLength) {
				//		NSLog(@"===================3=================");
						
						NSInteger fraction = (uploadLength/(CGFloat)expectedContentLength)*100;
				//		NSLog(@"===================4=================");
						
//						NSLog(@"NSStreamEventHasSpaceAvailable multipart-form Upload self.bufferOffset = %ld  totalsize = %ld progress = %d", uploadLength, expectedContentLength, fraction);
						// 델리게이트가 설정되어있다면 실행한다.
				//		NSLog(@"fraction = %f", (CGFloat)fraction);
						[self.delegate reloadProgress:self Persent:(CGFloat)fraction];
				//		NSLog(@"===================5=================");
						
//						if(self.delegate && [self.delegate respondsToSelector:@selector(reloadProgress:)]) {
//							[self.delegate reloadProgress:self Persent:fraction];
//						}
					}
				//	NSLog(@"===================RELoad Progress=================");
                }
            }
		//	NSLog(@"fdsafds");
        } break;
        case NSStreamEventErrorOccurred: {
            NSLog(@"producer stream error %@", [aStream streamError]);
        } break;
        case NSStreamEventEndEncountered: {
            assert(NO);     // should never happen for the output stream
        } break;
        default: {
            assert(NO);
        } break;
    }
}

// NSURLConnection 델리게이트 메소드
// 메소드가 호출되는 시점은 서버로의 요청에 대한 반응
- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)aResponse
{
    // 데이터를 전송받기 전에 호출되는 메서드, 우선 Response의 헤더만을 먼저 받아 온다.
	// 이 의미는 앞으로 가져오게 될 컨텐츠의 종류(mime type)과 문자셋(char-set)을 미리 확인하고 후에 데이터를 모두 받으면 적절한 디코딩(decode)을 할 수 있도록 하는 데 있다.
	// 수신되는 데이터는 NSMutableData인 receivedData에 넣게 되는데 여기서는 데이터를 수신받을 준비가 끝났으니 초기화하라는 의미
	assert(theConnection == self.connection);
	
	self.response = aResponse;
    [receivedData setLength:0];

	NSHTTPURLResponse	*httpResponse = (NSHTTPURLResponse*)aResponse;
	assert([httpResponse isKindOfClass:[NSHTTPURLResponse class]]);
	
	_responseStatusCode = [httpResponse statusCode];

	if ((httpResponse.statusCode / 100) != 2) {
		// Fail! 예외처리		
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:hadStatusCodeErrorWithResponse:)]) {
			[self.delegate request:self hadStatusCodeErrorWithResponse:httpResponse];
		}
	} else {
		// Response OK!
		NSDictionary *responseHeaderFields;
		// 받은 header들을 dictionary형태로 받고
		responseHeaderFields = [(NSHTTPURLResponse *)aResponse allHeaderFields];
		
		if(responseHeaderFields != nil) {

			NSString *contentTypeHeader = [httpResponse.allHeaderFields objectForKey:@"Content-Type"];
			if (contentTypeHeader == nil) {
				// No Content-Type!
			} else if (! [contentTypeHeader isHTTPContentType:@"video/mp4"] 
					   && ! [contentTypeHeader isHTTPContentType:@"video/m4v"] 
					   && ! [contentTypeHeader isHTTPContentType:@"video/mov"] 
					   && ! [contentTypeHeader isHTTPContentType:@"image/png"]
					   && ! [contentTypeHeader isHTTPContentType:@"image/tiff"]
					   && ! [contentTypeHeader isHTTPContentType:@"image/tif"]
					   && ! [contentTypeHeader isHTTPContentType:@"image/jpeg"] 
					   && ! [contentTypeHeader isHTTPContentType:@"image/gif"] 
					   && ! [contentTypeHeader isHTTPContentType:@"image/bmp"] 
					   && ! [contentTypeHeader isHTTPContentType:@"image/BMPf"] 
					   && ! [contentTypeHeader isHTTPContentType:@"image/ico"] 
					   && ! [contentTypeHeader isHTTPContentType:@"image/cur"] 
					   && ! [contentTypeHeader isHTTPContentType:@"image/xbm"]) {
				// Unsupported Content-Type
			} else {
				// Response OK!
			}

			// progress 구현시 파일 사이즈 처리
			if ([self requstType] == HttpRequestUploadUrlType) {
				
			} else if ([self requstType] == HttpRequestDownloadUrlType) {
				// Returns the receiver’s expected content length
				expectedContentLength = [httpResponse expectedContentLength];
//				NSLog(@"didReceiveResponse Download Totalsize = %ld", expectedContentLength);
			} else if ([self requstType] == HttpRequestUploadUrlMultipartFormType) {
//				NSLog(@"didReceiveResponse HttpRequestUploadUrlMultipartFormType Upload Totalsize = %ld", [httpResponse expectedContentLength]);
			} else {
				
			}

			// responseHeaderFields에 포함되어 있는 항목들 출력
//			for(NSString *key in responseHeaderFields) {
//				NSLog(@"Header: %@ = %@", key, [responseHeaderFields objectForKey:key]);
//			}
			
			// cookies에 포함되어 있는 항목들 출력
//			NSArray *cookies;
//			cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:responseHeaderFields forURL:[aResponse URL]];
//			
//			if(cookies != nil) {
//				for(NSHTTPCookie *a in cookies) {
//					NSLog(@"Cookie: %@ = %@", [a name], [a value]);
//				}
//			}
		}
	}
}

// NSURLConnection 델리게이트 메소드
- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data
{
    // 데이터를 전송받는 도중에 호출되는 메서드, 여러번에 나누어 호출될 수 있으므로 appendData를 사용한다.
	// 네트워크 상의 데이터는 한 번에 모든 데이터가 전송됨을 보장받을 수 없다. 
	// 그래서 수신이 완료될 때까지 지속적으로 받아와야 하는 데, 이 메소드가 그 역할을 한다. 
	// 수신되는 데이터가 있을 때마다 receivedData에 추가하는 것이 그것이다.
	
	assert(theConnection == self.connection);
	

	
	//	[self.delegate performSelector:@selector(connectionDidStart:) withObject:self];
	
	
	
	// progress 구현시 파일 사이즈 처리
	if ([self requstType] == HttpRequestUploadUrlType) {
		
		
			[receivedData appendData:data];
		
		// Progress 처리
		NSUInteger bytesReceived = [receivedData length];

		if(expectedContentLength != NSURLResponseUnknownLength) {
			NSInteger fraction = (bytesReceived / (CGFloat) expectedContentLength) * 100;
			
//			NSLog(@"didReceiveData Upload bytesReceived = %ld  totalsize = %ld progress = %d", bytesReceived, expectedContentLength, fraction);
			// 델리게이트가 설정되어있다면 실행한다.
			if(self.delegate && [self.delegate respondsToSelector:@selector(reloadProgress:)]) {
				[self.delegate reloadProgress:self Persent:fraction];
			}
		}
	} else if ([self requstType] == HttpRequestDownloadUrlType) {

		NSInteger		dataLength;
		const uint8_t	*dataBytes;
		NSInteger		bytesWritten;
		NSInteger		bytesWrittenSoFar;

		dataLength = [data length];
		dataBytes = [data bytes];
		bytesWrittenSoFar = 0;
		
		do {
			bytesWritten = [self.fileOutputStream write:&dataBytes[bytesWrittenSoFar] maxLength:dataLength - bytesWrittenSoFar];
			assert(bytesWritten != 0);
			if (bytesWritten == -1) {
				// TODO: File write Error! 예외처리 필요
				break;
			} else {
				bytesWrittenSoFar += bytesWritten;
			}
		} while (bytesWrittenSoFar != dataLength);

		[receivedData appendData:data];
		// Progress 처리
		NSUInteger bytesReceived = [receivedData length];
		if(expectedContentLength != NSURLResponseUnknownLength) {
			NSInteger fraction = (bytesReceived/(CGFloat)expectedContentLength)*100;

			NSLog(@"didReceiveData Download bytesReceived = %ld  totalsize = %ld progress = %d", bytesReceived, expectedContentLength, fraction);
			// 델리게이트가 설정되어있다면 실행한다.
			[self.delegate reloadProgress:self Persent:fraction];
//			if(self.delegate && [self.delegate respondsToSelector:@selector(reloadProgress:)]) {
//				
//			}
		}
	} else if ([self requstType] == HttpRequestUploadUrlMultipartFormType) {
		// skip
		[receivedData appendData:data];
	} else {
		[receivedData appendData:data];
	}
}

// NSURLConnection 델리게이트 메소드
- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
{
    // 에러가 발생되었을 경우 호출되는 메서드
	// 자원을 해제하고 경고창을 띄운후 루틴을 종료하는 처리 필요
	NSLog(@"에러에러에러ㅏ.");

	assert(theConnection == self.connection);
	
    NSLog(@"didFailWithError Connection failed Error: %@", [error localizedDescription]);
	// 델리게이트가 설정되어있다면 실행한다.
    if(self.delegate && [self.delegate respondsToSelector:@selector(connectionDidFail:)]) {
		[self.delegate performSelector:@selector(connectionDidFail:) withObject:self];
    }
}

// NSURLConnection 델리게이트 메소드
- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
{
    // 데이터 전송이 끝났을 때 호출되는 메서드, 전송받은 데이터를 NSString형태로 변환한다.
	// didReceiveResponse 에서 확인후 문자셋 형태로 변환
	// 데이터를 모두 수신하게되면 이 메소드가 호출되는데 여기서는 수신한 NSMutableData를 적절한 형태의 데이터로 변환하면 된다. 
	// 여기서는 HTML 웹페이지를 수신하려 하므로 NSString으로 변환한다. 물론, 문자셋은 헤더로 부터 수신한 문자셋을 참조하여 변환하면 된다. 
	// 여기서는 UTF-8로 변환하게 되는데, 국내 사이트의 경우에는 대부분 EUC-KR 일 것이다. 그러나 Apple에서 제공하는 어떠한 문서를 찾아봐도 
	// EUC-KR 에 대한 상수값을 찾을 수 없었다. NSUTF8StringEncoding 대신 -2147481280 를 입력하면 국내 사이트도 정상적으로 볼 수 있을 것이다. 
	// 인코딩 상수값에 대한 테이블은 http://limechat.net/rubycocoa/wiki/?NSStringEncoding 여기를 참조
	
	
	NSLog(@"!!!!!!!!!!!!!!!!!!!");
	assert(theConnection == self.connection);
	
	if ([self requstType] == HttpRequestUrlType) {
		if (self.connection != nil) {
			[self.connection cancel];
			self.connection = nil;
		}
	} else if ([self requstType] == HttpRequestUploadUrlType) {
		if (self.fileInputStream != nil) {
			[self.fileInputStream close];
			self.fileInputStream = nil;
		}
		if (self.connection != nil) {
			[self.connection cancel];
			self.connection = nil;
		}
	} else if ([self requstType] == HttpRequestDownloadUrlType) {
		if (self.connection != nil) {
			[self.connection cancel];
			self.connection = nil;
		}
		if (self.fileOutputStream != nil) {
			[self.fileOutputStream close];
			self.fileOutputStream = nil;
		}
	} else if ([self requstType] == HttpRequestUploadUrlMultipartFormType) {
		if (self.bufferOnHeap) {
			free(self.bufferOnHeap);
			self.bufferOnHeap = NULL;
		}
		self.buffer = NULL;
		self.bufferOffset = 0;
		self.bufferLimit  = 0;
		if (self.connection != nil) {
			[self.connection cancel];
			self.connection = nil;
		}
		self.consumerStream = nil;
		
		
		self.bodyParamData = nil;
		if (self.fileOutputStream != nil) {
			self.fileOutputStream.delegate = nil;
			[self.fileOutputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
			[self.fileOutputStream close];
			self.fileOutputStream = nil;
		}
		if (self.fileInputStream != nil) {
			[self.fileInputStream close];
			self.fileInputStream = nil;
		}
		
		self.bodyUploadFileData = nil;
	} else {
		
	}

    // 델리게이트가 설정되어있다면 실행한다.
    if(self.delegate && [self.delegate respondsToSelector:@selector(connectionDidFinish:)]) {
		[self.delegate performSelector:@selector(connectionDidFinish:) withObject:self];
    }
}

#pragma mark -
#pragma mark finalize
- (void)dealloc
{
//	NSLog(@"HttpAgent dealloc start");
	
	if (self.connection != nil) {
		[self.connection cancel];
		self.connection = nil;
	}
	
	if(self->delegateParameter) {
		[self->delegateParameter release];
		self->delegateParameter = nil;
	}
	if(self->receivedData) {
		[self->receivedData release];
		self->receivedData = nil;
	}
	
	if(self->response) {
		[self->response release];
		self->response = nil;
	}
	
    [super dealloc];
//	NSLog(@"HttpAgent dealloc end");
}

@end	// @implementation HttpAgent

#pragma mark -
#pragma mark 참고사항
/*
 -(void)httpRequest:(NSString *)httpUrl ParameterInDictionary:(NSDictionary *)parameters{
 NSString *url = @"http://imbeta.paran.com:8081/usay/join_member.json";
 
 // POST로 전송할 데이터 설정
 // value, key, value, key ...
 //	NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:@"01032310142",@"mobileno",@"테스트팟", @"nick",@"deviceid123", @"mobilesn",@"uuid456789",@"devtoken", [[self appDelegate] getSvcIdx], @"svcidx", nil];
 NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys: nil];
 
 // 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
 [self requestUrl:url bodyObject:bodyObject parent:nil timeout:10];
 }
 
 -(void)httpsRequest{
 // 접속할 주소 설정
 NSString *url = @"https://user.paran.com/callAction.do";
 
 // POST로 전송할 데이터 설정
 // value, key, value, key ...
 // method=authParanUser&wbSvcid=mail&wbUserid=billgates74&wbDomain=paran.com&wbPasswd=xogudaudwls&wbTs=201005191625004&wbRemoteAddr=118.67.188.2
 NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:@"authParanUser", @"method", @"mail", @"wbSvcid",@"billgates74", @"wbUserid",@"paran.com", @"wbDomain",@"wnstjd0404!", @"wbPasswd",@"201005191625004", @"wbTs",@"118.67.188.2", @"wbRemoteAddr", nil];
 
 // 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
 [self requestUrl:url bodyObject:bodyObject parent:nil timeout:10];
 }
 
 -(void)jsonRequest{
 // 접속할 주소 설정
 NSString *url = @"http://alones.kr/iphone/test/test.html";
 
 // POST로 전송할 데이터 설정
 // value, key, value, key ...
 NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys: nil];
 
 // 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
 [self requestUrl:url bodyObject:bodyObject parent:nil timeout:10];
 
 //	 NSDictionary *dict;
 //	 NSString *key;
 //	 
 //	 // JSON 문법으로 변환할 데이터 생성
 //	 dict = [NSDictionary dictionaryWithObjectsAndKeys:
 //	 @"eye", @"name",
 //	 @"http://theeye.pe.kr", @"home",
 //	 @"27", @"age",
 //	 nil];
 //	 
 //	 // JSON 라이브러리 생성
 //	 SBJSON *json = [[SBJSON alloc] init];
 //	 [json setHumanReadable:YES];
 //	 
 //	 // 변환
 //	 NSString *result = [json stringWithObject:dict error:nil];
 //	 NSLog(@"converted data :\n%@", result);
 //	 [json release];
 //	 // 이전데이터를 소거함을 증명
 //	 dict = nil;
 //	 
 //	 // JSON 문자열을 객체로 변환
 //	 dict = [json objectWithString:result error:nil];
 //	 
 //	 // 결과 출력
 //	 for (key in dict) {
 //	 NSLog(@"Key: %@, Value: %@", key, [dict valueForKey:key]);
 //	 }
 }
 
1. HTTP with x/www-form-urlencoded
	[요청] 
	POST /some/resource HTTP/1.1
	Content-type: application/x-www-form-urlencoded
	0=example.getStateName&1=10023

	[응답]
	HTTP/1.1 200 OK
	Content-type: text/plain
	New York

2. HTTP with multipart/form-data 
	[요청]
	POST /some/resource HTTP/1.1
	Content-type: multipart/form-data, boundary=AaB03x
	--AaB03x
	content-disposition: form-data; name="field1"

	Joe Blow

	--AaB03x  
	content-disposition: form-data; name="pics"; filename="file1.gif"
	Content-type: image/gif
	Content-Transfer-Encoding: binary
	...contents of file1.gif...

	--AaB03x--

	[응답] 
	HTTP/1.0 200 OK
	Content-type: text/plain
	OK
//*/