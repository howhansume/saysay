//
//  ProfileSettingViewController.h
//  USayApp
//
//  Created by 1team on 10. 6. 2..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDWebImageManager.h"

@class USayAppAppDelegate;

@interface ProfileSettingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SDWebImageManagerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
	UITableView			*settingTableView;
	NSMutableString		*preNickName;
	NSMutableString		*prePrMsg;
	NSMutableString		*representPhoto;	// 대표사진
	NSMutableString		*representPhotoFilePath;
//	NSMutableString		*compareRepresentPhoto;
	NSMutableArray		*subPhotosArray;	// 서브사진
	
	NSMutableString		*preImStatus;		// 상태 정보
	
	UIActivityIndicatorView* requestActIndicator;
	
	NSTimer* timer;

	BOOL				keyboardShown;
	BOOL				photoLibraryShown;
	BOOL				isRequest;
	UILabel *myLabel;
}

-(USayAppAppDelegate *) appDelegate;
-(void) photoClicked;
-(void)backBarButtonClicked;

//-(void)photoUploadCheckStatus:(NSTimer *)timer;
//-(void)loadCheckStatus:(NSTimer *)timer;
-(void)insertNickName:(NSString*)nickName;
-(void)insertPrMsg:(NSString*)status;
-(void)insertOrganization:(NSString*)organization;
-(UIImage*)resizeImage:(UIImage*)image scaleFlag:(BOOL)aFlag;
-(UIImage*)thumbNailImage:(UIImage*)image Size:(CGFloat)resizeSize;

@property (nonatomic, retain) UITableView		*settingTableView;
@property (nonatomic, retain) NSMutableString	*preNickName;
@property (nonatomic, retain) NSMutableString	*prePrMsg;
@property (nonatomic, retain) NSMutableString	*representPhoto;
@property (nonatomic, retain) NSMutableString	*representPhotoFilePath;
//@property (nonatomic, retain) NSMutableString	*compareRepresentPhoto;
@property (nonatomic, retain) NSMutableArray	*subPhotosArray;
@property (nonatomic, retain) NSMutableString	*preImStatus;

@property (readwrite) BOOL photoLibraryShown;
@property (readwrite) BOOL isRequest;

@end
 