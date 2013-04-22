//
//  ShowMediaViewController.h
//  USayApp
//
//  Created by 1team on 10. 7. 10..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDWebImageManager.h"

@class USayAppAppDelegate;
@class HttpAgent;

@interface ShowMediaViewController : UIViewController <UIActionSheetDelegate, UIAlertViewDelegate, SDWebImageManagerDelegate> {
	UIImageView	*imageView;
	UIImage		*thumbnailImage;
	NSTimer		*delayTimer;
	
	HttpAgent	*httpAgent;
	
	UIActionSheet	*downloadActionSheet;
	UIProgressView  *downloadProgressView;
	
	NSMutableString	*originalPhotoPath;
	NSMutableString	*originalMoviePath;

	NSMutableString	*originalPhotoUrl;	// 정보가 없을 경우에는 thumbnailImage 이미지로 show
	NSMutableString	*originalMovieUrl;	// 동영상은 다운로드 처리. 다운로드후 db, 메모리에 값 넣기.

	NSString	*chatSession;		// 대화방 정보
	NSString	*messageKey;		// 메시지세션 정보

	BOOL		isPhotoView;
	BOOL		isExit;
}

-(USayAppAppDelegate *) appDelegate;

-(void)originalImageShow:(NSTimer *)timecall;				// 원본 사진이 클 경우 썸네일 이미지 먼저 보여주고 원본사진 보여주기
- (void) doMoviePlayer:(NSString *)filePath;				// 동영상 재생 

@property(nonatomic, retain) UIImage		*thumbnailImage;
@property(nonatomic, retain) UIImageView	*imageView;
@property(nonatomic, retain) NSTimer		*delayTimer;
@property(nonatomic, retain) HttpAgent		*httpAgent;

@property(nonatomic, retain) UIProgressView *downloadProgressView;
 
@property(nonatomic, retain) NSMutableString		*originalPhotoPath;
@property(nonatomic, retain) NSMutableString		*originalMoviePath;
@property(nonatomic, retain) NSMutableString		*originalPhotoUrl;
@property(nonatomic, retain) NSMutableString		*originalMovieUrl;
@property(nonatomic, assign) NSString				*chatSession;
@property(nonatomic, assign) NSString				*messageKey;

@property(nonatomic) BOOL	isPhotoView;
@property(nonatomic) BOOL	isExit;

-(void)showImage:(NSString*)cellImage;

@end

/*
 파일은 NSCachesDirectory에 저장.  
 <Application_Home>/Library/Caches 에 저장
 caches 디렉토리는 어플리케이션의 실행때마다 지속적으로 사용해야 하는 파일을 읽고 쓰기 위해 사용.
 개발한 어플은 일반적으로 이곳에 파일을 추가/삭제 해야 한다.
 iTunes는 전체 복원시에 이 디렉토리의 내용을 모두 제거한다.
 어플은 필요할때 마다 이곳의 파일을 생성해 낼수 있어야 한다.
 iPhone OS 2.2 혹은 이후 버전은 iTunes에서 이 디렉토리를 백업하지 않음.
 
1. 사진
 - 본인이 보낸 이미지 : 로컬에서 가져와 show 처리 (썸네일, 원본)
					 없을 경우 UIImage로 받아서 처음에 그려주고
					 백그라운드에서 원본이미지 url 다운로드후 show. (파일path field 메시지 history DB, 메모리 변경) ===> chatSession, messageKey 값 필요
   친구가 보낸 이미지 : 다운받은 파일이 존재 하면 다운받은 파일로 show.
                     없으면 대화창에서 UIImage 받아서 처음에 그려주고 
					 백그라운드에서 원본이미지 url 다운로드후 show. (파일path field 메시지 history DB, 메모리 변경) ===> chatSession, messageKey 값 필요

2. 동영상
 - 본인이 보낸 동영상 : 다운로드 받은 파일이 존재 하면 다운받은 파일로 show
                     없으면 url로 다운받아서 로컬에 저장후 show. (파일path field 메시지 history DB, 메모리 변경) ===> chatSession, messageKey 값 필요
 - 친구가 보낸 동영상 : 다운로드 받은 파일이 존재 하면 다운받은 파일로 show
                     없으면 url로 다운받아서 로컬에 저장후 show. (파일path field 메시지 history DB, 메모리 변경) ===> chatSession, messageKey 값 필요
//*/