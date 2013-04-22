//
//  BuddyPersonViewController.h
//  USayApp
//
//  Created by Jong-Sung Park on 10. 6. 15..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import "ManagedObjectAttributeEditor.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@class USayAppAppDelegate;
@class UserInfo;

@protocol AddressPersonDelegate <NSObject>

-(void)updatePersonInfo:(UserInfo*)PersonValue;
-(void)deletePersonInfo:(UserInfo*)PersonValue;
@end

@class blockView;
@class AddressDetailViewController;
@interface BuddyPersonViewController : UITableViewController<detailViewDataDelegate, UIImagePickerControllerDelegate, MFMessageComposeViewControllerDelegate,
													UIAlertViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate> {
	AddressDetailViewController* parentController;
	UIButton* photoImageView;
	UIImageView* mainPhotoView;
//	UIButton* mainPhotoView;

														NSString* buddyPKey;
	UserInfo* personInfo;
	UserInfo* compareInfo;
	UIImage*	addUserImage;
	BOOL	photoLibraryShown;
	BOOL	  isEdit;
	blockView* updateBlock;
														NSData *data3;
														blockView *photoBlockView;
	id<AddressPersonDelegate> personDelegate;
//	BOOL	isMemoryWarning;//메모리 오버 여부.
																
@private   
    NSArray         *sectionNames;
    NSArray         *rowLabels;
    NSArray         *rowKeys;
    NSArray         *rowControllers;
    NSArray         *rowArguments; 
	UILabel *modifyLabel;
				

	UILabel *myLabel;		// sochae 2010.09.17 - modalViewController title
}
@property (nonatomic, retain) AddressDetailViewController* parentController;
@property (nonatomic, retain) UIButton* photoImageView;
//@property (nonatomic, retain) UIButton* mainPhotoView;
@property (nonatomic, retain) UIImageView* mainPhotoView;

@property (nonatomic, retain) NSString* buddyPKey;
@property (nonatomic, retain) UIImage*	addUserImage;
@property (nonatomic, retain) UserInfo* personInfo;
@property (nonatomic, assign) id<AddressPersonDelegate> personDelegate;

@property (nonatomic)		  BOOL isEdit;
@property (nonatomic)		  BOOL	photoLibraryShown;

-(USayAppAppDelegate *) appDelegate;
-(void)addCustomFooterView;
-(void)deleteBuddyAction;
-(void)updateBuddyCompleted;
-(void)backBarButtonClicked;
-(void)requestDeleteContact;
-(BOOL)requestUpdateContact;
-(void)imageSelect;
-(void)normalInterFaceConfig;
-(void)editInterFaceConfig;
-(void)syncImageDataSaveDB:(NSArray*)ImageDataArray;
-(BOOL) existChangeValue;
-(void) copyUserInfo;
-(void)syncDataSaveDB:(NSArray*)dataArray withRevisionPoint:(NSString *)revisionPoint;
-(void)syncDataDeleteDB:(NSString*)userID withRevisionPoint:(NSString *)revisionPoint;
//-(void)updatePersonInfo:(UserInfo*)PersonValue;
-(void)addedContactPhontUpload:(UserInfo*)userData;
-(void)addressSayButtonClicked;
-(void)addressSMSButtonClicked;

-(UIImage*)resizeImage:(UIImage*)image scaleFlag:(BOOL)aFlag;
-(UIImage*)thumbNailImage:(UIImage*)image Size:(CGFloat)resizeSize;

// sochae 2010.10.08
- (void) cancelModal;
// ~sochae
//kjh rightButtonCreate 2010.10.22
-(void)createRightButton;

@end
