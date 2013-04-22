//
//  UserInfoItem.h
//  USayApp
//
//  Created by Jong-Sung Park on 10. 6. 27..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataAccessObject.h"

@interface UserInfo : DataAccessObject <NSCopying> {
	NSNumber* INDEXNO;					// primary key
	NSString* RECORDID;					// 주소록에서의 번호 (매칭해줄수 있는 값이 없음)
	NSString* ID;						// 주소 고유 번호. 
//	NSString* PKEY;						// 사용자 정보 pkey
	NSData*   USERIMAGE;				// 이미지 데이터
	
	NSString* FORMATTED;				// 성+이름. 없을시 "이름 없음"
	NSString* ORGNAME;					// 직장명
	NSString* NICKNAME;					// 별명
	NSString* HOMEEMAILADDRESS;			// 홈 이메일 주소
	NSString* ORGEMAILADDRESS;			// 회사 이메일 주소
	NSString* OTHEREMAILADDRESS;		// 기타 이메일 주소
	NSString* MOBILEPHONENUMBER;		// 폰 번호
	NSString* IPHONENUMBER;				// 아이폰 번호
	NSString* HOMEPHONENUMBER;			// 집 전화
	NSString* ORGPHONENUMBER;			// 회사 전화
	NSString* MAINPHONENUMBER;			// 메인 전화
	NSString* HOMEFAXPHONENUMBER;		// 집 fax번호
	NSString* ORGFAXPHONENUMBER;		// 회사 fax번호
	NSString* PARSERNUMBER;				// 호출기
	NSString* OTHERPHONENUMBER;			// 기타 전화 번호
	NSString* HOMECITY;					// 도시 (집)
	NSString* HOMEZIPCODE;				// 우편번호 (집)
	NSString* HOMEADDRESSDETAIL;		// 번지 (집)
	NSString* HOMESTATE;				// 나라 (집)
	NSString* HOMEADDRESS;				// 도(또는 주) (집)
	NSString* ORGCITY;					// 회사 도시
	NSString* ORGZIPCODE;				// 회사 우편 번호
	NSString* ORGADDRESSDETAIL;			// 회사 번지
	NSString* ORGSTATE;					// 회사 나라
	NSString* ORGADDRESS;				// 회사 도(또는 주)
	NSString* THUMBNAILURL;				// 주소 대표사진 url
	NSString* URL1;						// 홈페이지 주소 1
	NSString* URL2;						// 홈페이지 주소 2
	NSString* NOTE;						// 메모
	
	NSString* RPCREATED;				// 생성시 REVISION POINT
	NSString* RPDELETED;				// 삭제시 REVISION POINT
	NSString* RPUPDATED;				// 수정시 REVISION POINT
	NSString* REPRESENTPHOTO;			// 프로필 대표 사진 URL
	NSString* REPRESENTPHOTOSP;			// 프로필 사진 변경 버전
	NSString* PROFILEFORMATTED;			// 프로필 이름. 친구일경우
	NSString* PROFILENICKNAME;			// 프로필 닉네임. 친구일경우
	NSString* NICKNAMESP;				// 닉네임 버전
	NSString* STATUS;					// 오늘의 한마디. 친구 일경우(status)
	NSString* STATUSSP;					// 오늘의 한마디 버전
	NSString* ISFRIEND;					// 친구 여부 S:서로 친구, A: 한쪽만 친구, N: 친구 아님
	NSString* ISTRASH;					// 휴지통 여부 Y/N
	NSString* ISBLOCK;					// 차단여부 Y/N
	NSString* GID;						// 그룹 아이디(로컬 DB 매핑용)
	NSString* RPKEY;					// 친구의 고유키
	NSString* IMSTATUS;					// 친구의 상태
	NSString* CHANGEDATE;				// 생성및 수정이 발생시 날자 입력.
	NSString* CHANGEDATE2;				// 생성및 수정이 발생시 날자 입력. 20101012
	NSString* OEMCREATEDATE;				// 생성및 수정이 발생시 날자 입력. 20101012
	NSString* OEMMODIFYDATE;	
	NSString* SIDCREATED;				// 생성 device
	NSString* SIDUPDATED;				// 수정 device
	NSString* SIDDELETED;				// 삭제 device
}

@property (nonatomic, retain) NSNumber* INDEXNO;				
@property (nonatomic, retain) NSString* RECORDID;				
@property (nonatomic, retain) NSString* ID;					
//@property (nonatomic, retain) NSString* PKEY;					
@property (nonatomic, retain) NSData*   USERIMAGE;				
@property (nonatomic, retain) NSString* FORMATTED;			
@property (nonatomic, retain) NSString* ORGNAME;				
@property (nonatomic, retain) NSString* NICKNAME;				
@property (nonatomic, retain) NSString* HOMEEMAILADDRESS;		
@property (nonatomic, retain) NSString* ORGEMAILADDRESS;		
@property (nonatomic, retain) NSString* OTHEREMAILADDRESS;	
@property (nonatomic, retain) NSString* MOBILEPHONENUMBER;	
@property (nonatomic, retain) NSString* IPHONENUMBER;			
@property (nonatomic, retain) NSString* HOMEPHONENUMBER;		
@property (nonatomic, retain) NSString* ORGPHONENUMBER;		
@property (nonatomic, retain) NSString* MAINPHONENUMBER;		
@property (nonatomic, retain) NSString* HOMEFAXPHONENUMBER;	
@property (nonatomic, retain) NSString* ORGFAXPHONENUMBER;	
@property (nonatomic, retain) NSString* PARSERNUMBER;			
@property (nonatomic, retain) NSString* OTHERPHONENUMBER;		
@property (nonatomic, retain) NSString* HOMECITY;				
@property (nonatomic, retain) NSString* HOMEZIPCODE;			
@property (nonatomic, retain) NSString* HOMEADDRESSDETAIL;	
@property (nonatomic, retain) NSString* HOMESTATE;			
@property (nonatomic, retain) NSString* HOMEADDRESS;			
@property (nonatomic, retain) NSString* ORGCITY;				
@property (nonatomic, retain) NSString* ORGZIPCODE;			
@property (nonatomic, retain) NSString* ORGADDRESSDETAIL;		
@property (nonatomic, retain) NSString* ORGSTATE;				
@property (nonatomic, retain) NSString* ORGADDRESS;			
@property (nonatomic, retain) NSString* THUMBNAILURL;			
@property (nonatomic, retain) NSString* URL1;					
@property (nonatomic, retain) NSString* URL2;					
@property (nonatomic, retain) NSString* NOTE;					
@property (nonatomic, retain) NSString* RPCREATED;			
@property (nonatomic, retain) NSString* RPDELETED;			
@property (nonatomic, retain) NSString* RPUPDATED;			
@property (nonatomic, retain) NSString* REPRESENTPHOTO;		
@property (nonatomic, retain) NSString* PROFILEFORMATTED;		
@property (nonatomic, retain) NSString* STATUS;				
@property (nonatomic, retain) NSString* ISFRIEND;				
@property (nonatomic, retain) NSString* ISTRASH;				
@property (nonatomic, retain) NSString* ISBLOCK;				
@property (nonatomic, retain) NSString* GID;
@property (nonatomic, retain) NSString* RPKEY;
@property (nonatomic, retain) NSString* PROFILENICKNAME;
@property (nonatomic, retain) NSString* CHANGEDATE;
@property (nonatomic, retain) NSString* CHANGEDATE2;



@property (nonatomic, retain) NSString* OEMCREATEDATE;
@property (nonatomic, retain) NSString* OEMMODIFYDATE;

@property (nonatomic, retain) NSString* IMSTATUS;
@property (nonatomic, retain) NSString* REPRESENTPHOTOSP;
@property (nonatomic, retain) NSString* NICKNAMESP;
@property (nonatomic, retain) NSString* STATUSSP;

@property (nonatomic, retain) NSString* SIDCREATED;				
@property (nonatomic, retain) NSString* SIDUPDATED;				
@property (nonatomic, retain) NSString* SIDDELETED;				


@end

//	NSString* MIDDLENAME;				// 중간이름
//	NSString* JOBTITLE;					// 직책
//	NSString* DEPARTMENT;				// 부서
//	NSString* BIRTHDAY;					// 생일
//	NSString* ANNIVERSARY;				// 기념일
//	NSString* FAMILYNAME;				// 경칭
//	NSString* GIVENNAME;				// 호칭
//	NSString* PHONETICNAME;				// 이름 발음
//	NSString* IMS1;						// 메신저1
//	NSString* IMS2;						// 메신저2