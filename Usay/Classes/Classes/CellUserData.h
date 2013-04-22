//
//  CellUserData.h
//  USayApp
//
//  Created by 1team on 10. 6. 22..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CellUserData : NSObject {
	NSString	*pkey;					// uniquekey
	NSString	*usay;					// 상태 정보 (온라인, 다른용무중 등등)
	NSString	*familyName;			// 성
	NSString	*givenName;				// 이름
	NSString	*formatted;				// 성+이름
	NSString	*nickName;				// 별명
	NSString	*status;				// 오늘의 한마디
	NSString	*representPhoto;		// 사진url
	UIImage		*representPhotoImage;	// 사진이미지
}

@property (nonatomic, retain) NSString	*pkey;
@property (nonatomic, retain) NSString	*usay;
@property (nonatomic, retain) NSString	*familyName;
@property (nonatomic, retain) NSString	*givenName;
@property (nonatomic, retain) NSString	*formatted;
@property (nonatomic, retain) NSString	*nickName;
@property (nonatomic, retain) NSString	*status;
@property (nonatomic, retain) NSString	*representPhoto;
@property (nonatomic, retain) UIImage	*representPhotoImage;

@end
