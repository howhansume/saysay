//
//  USayHttpData.h
//  USayApp
//
//  Created by 1team on 10. 6. 18..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface USayHttpData : NSObject {
	NSString			*api;
	NSString			*subApi;		// 동일한 api를 사용할때, 구분할수 있도록 추가
	NSDictionary		*bodyObjectDic;
	NSInteger			timeout;		// second
	
//////////////////////////////////////////////////
// 사진 보내기시 필요한 parameter	
	NSString			*filePath;		// Upload file (사진 보내기시 파일 경로)
	NSString			*uniqueId;		// Upload uuid
	
	NSString			*isRepresent;	// 프로필 사진 설정시 (대표사진 등록 여부, 0 or 1(설정)),
	
	NSString			*cid;			// 주소록 사진 설정시 (cid 값)
	
	NSString			*message;		// 대화 사진 보내기 (message)
	NSString			*sessionKey;	// 대화 사진 보내기 (대화창 key값)
	NSString			*mType;			// 대화 사진 보내기 (메시지 타입. P:사진 V:동영상)
	
	NSData				*mediaData;		// 미디어 데이터
//////////////////////////////////////////////////
	
	NSString			*messageKey;
	// 결과값
	NSString			*responseData;
}

@property (nonatomic, assign) NSString		*api;
@property (nonatomic, assign) NSString		*subApi;
@property (nonatomic, assign) NSDictionary	*bodyObjectDic;
@property (nonatomic, assign) NSString		*filePath;
@property (nonatomic, retain) NSString		*uniqueId;
@property (nonatomic, assign) NSString		*isRepresent;
@property (nonatomic, assign) NSString		*cid;
@property (nonatomic, assign) NSString		*message;
@property (nonatomic, assign) NSString		*sessionKey;
@property (nonatomic, assign) NSString		*messageKey;
@property (nonatomic, assign) NSString		*mType;
@property (nonatomic, assign) NSString		*responseData;
@property (nonatomic, assign) NSData		*mediaData;
@property (readwrite)		  NSInteger		timeout;

-(id)initWithRequestData:(NSString*)pApi andWithDictionary:(NSDictionary*)pBodyObjectDic timeout:(NSInteger)time;
-(id)initWithResponseData:(NSString*)pApi andWithString:(NSString*)pResponseData;

@end
