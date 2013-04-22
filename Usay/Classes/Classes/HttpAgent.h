//
//  HttpAgent.h
//  HTTPAgent
//
//  Created by Kim Tae-Hyung on 10. 5. 19..
//  Copyright 2010 Inamass.net. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HttpAgentParameter : NSObject
{
	NSString *requestApi;
	NSString *requestSubApi;		// 동일한 requestApi를 사용할때, 구분할수 있도록 추가
	
	NSString *uniqueId;
	NSString *testUniqueId;
	
	NSString *filePath;
	
	// 주소록 사진 등록시 필요. 주소록 unique 값
	NSString *cid;
	
	// 프로필 사진 등록시 대표사진 등록 여부 값
	NSString *isRepresent;
	
	// 대화시 사진/동영상 보내기시 parameter
	NSString *message;
	NSString *sessionKey;
	NSString *messageKey;
	NSString *mType;		// messageType
	
	NSData	 *mediaData; //
}

@property (nonatomic, assign) NSString *requestApi;
@property (nonatomic, assign) NSString *requestSubApi;
@property (nonatomic, retain) NSString *uniqueId;
@property (nonatomic, assign) NSString *filePath;
@property (nonatomic, assign) NSString *cid;
@property (nonatomic, assign) NSString *isRepresent;
@property (nonatomic, assign) NSString *message;
@property (nonatomic, assign) NSString *sessionKey;
@property (nonatomic, assign) NSString *messageKey;
@property (nonatomic, assign) NSString *mType;
@property (nonatomic, assign) NSData   *mediaData;

@end


@class HttpAgent;

enum HttpRequestType
{
	HttpRequestUrlType = 0,
	HttpRequestUploadUrlType,
	HttpRequestDownloadUrlType,
	HttpRequestUploadUrlMultipartFormType
};

typedef enum HttpRequestType HttpRequestType;

@interface NSObject (HttpAgentDelegate)
/**
 * Response 처리 
 **/
- (void)connectionDidFinish:(HttpAgent*)aHttpAgent;

/**
 * fail 처리 
 **/
- (void)connectionDidFail:(HttpAgent*)aHttpAgent;

/**
 * error일 경우 statusCode 200 번대 이외일 경우 에러 리턴
 **/
- (void)request:(HttpAgent*)aHttpAgent hadStatusCodeErrorWithResponse:(NSURLResponse *)aResponse;

/**
 * download/upload 시 progress 처리
 **/
- (void)reloadProgress:(HttpAgent*)aHttpAgent Persent:(CGFloat)persent;
@end

@interface HttpAgent : NSObject <NSStreamDelegate> {
	NSMutableData		*receivedData;
    NSURLResponse		*response;
	
	NSURLConnection		*_connection;
	NSInputStream		*_fileInputStream;
	NSOutputStream		*_fileOutputStream;
	NSInputStream		*_consumerStream;
	
	NSInteger			_responseStatusCode;
	id					_delegate;
	HttpRequestType		requstType;
	
	HttpAgentParameter	*delegateParameter;	// delegate에서 호출시 필요한 정보 저장 
											// 프로필 사진 설정시 (대표사진 등록 여부, 0 or 1(설정)), 
											// 주소록 사진 설정시 (cid 값)
											// 대화 사진 보내기 (sessionKey, mType, message)
	long				expectedContentLength;
	long				uploadLength;
	
	NSData				*_bodyUploadFileData;
	NSData				*_bodyParamData;		// pKey, albumNo, uuid, transParam 합침
	
	const uint8_t		*_buffer;				// uploadFile Buffer
    uint8_t				*_bufferOnHeap;
    size_t				_bufferOffset;
    size_t				_bufferLimit;
}

+ (void)setCookie:(NSString*)ucmc cookieUCCS:(NSString*)uccs cookieMC:(NSString*)mc cookieCS:(NSString*)cs;
+ (NSString*)ucmc;
+ (NSString*)uccs;
+ (NSString*)mc;
+ (NSString*)cs;

// time : second
- (BOOL)requestUrl:(NSString *)url bodyObject:(NSDictionary *)bodyObject parent:(id)aDelegate timeout:(NSInteger)time;
- (BOOL)requestUploadUrl:(NSString *)url filePath:(NSString*)path parent:(id)aDelegate timeout:(NSInteger)time;
- (BOOL)requestDownloadUrl:(NSString *)url filePath:(NSString*)path parent:(id)aDelegate timeout:(NSInteger)time;
- (BOOL)requestUploadUrlMultipartForm:(NSString *)url bodyObject:(NSDictionary *)bodyObject parent:(id)aDelegate timeout:(NSInteger)time;

- (NSString *)_generateBoundaryString;
- (NSURL *)smartURLForString:(NSString *)str;
-(NSString*)currentMessageUrlEncoded:(NSString *)currentMessage;
- (void) cancelRequest;
- (BOOL) isRequest;

@property (nonatomic, retain) NSMutableData			*receivedData;
@property (nonatomic, retain) NSURLResponse			*response;
@property (nonatomic, assign) id					delegate;
@property (nonatomic, readonly) NSInteger			responseStatusCode;
@property (nonatomic, assign) HttpRequestType		requstType;
@property (nonatomic, readonly) HttpAgentParameter	*delegateParameter;


// Downloading, Uploading
@property (nonatomic, assign) long expectedContentLength;
@property (nonatomic, assign) long uploadLength;

@end
