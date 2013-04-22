//
//  AddBuddyViewController.h
//  USayApp
//
//  Created by Jong-Sung Park on 10. 6. 20..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ManagedObjectAttributeEditor.h"
#define kLabelTag       1
#define kTextFieldTag   2
@class UserInfo;
@class GroupInfo;
@class USayAppAppDelegate;
@class blockView;
@class UserInfo;
@class GroupInfo;
@protocol addBuddyDelegate <NSObject>

-(void)addUserInfoWithUserInfo:(UserInfo*)value withImage:(BOOL)exist;

@end


@interface AddBuddyViewController : UITableViewController<detailViewDataDelegate, UIImagePickerControllerDelegate, 
									UIActionSheetDelegate, UINavigationControllerDelegate> {

	UIViewController* parentController;
	UIButton* photoImageView;
	NSMutableDictionary* addBuddyDic;
	NSMutableArray*	addGroupInfo;
	UIImage*	addUserImage;
	NSString*   revisionPointer;
	UserInfo*	saveUserData;
										
	blockView* addUserBlockView;
	blockView* insertPhotoView;
	BOOL	photoLibraryShown;
										UILabel *myLabel;
	id<addBuddyDelegate> addDelegate;
										NSMutableDictionary* peopleInGroup;
										
//	BOOL    isMemoryWarning;
	
@private   
    NSArray         *sectionNames;
    NSArray         *rowLabels;
    NSArray         *rowKeys;
    NSArray         *rowControllers;
    NSArray         *rowArguments; 
}
@property (nonatomic, retain) UIViewController* parentController;
@property (nonatomic, retain) UIButton* photoImageView;
@property (nonatomic, retain) NSMutableDictionary* addBuddyDic;
@property (nonatomic, retain) NSMutableArray*	addGroupInfo;
@property (nonatomic, retain) NSString*   revisionPointer;
@property (nonatomic, retain) UIImage*	addUserImage;
@property (nonatomic, retain) UserInfo* saveUserData;
@property (nonatomic, assign) id<addBuddyDelegate> addDelegate;
@property (readwrite) BOOL photoLibraryShown;
@property (nonatomic, retain) NSMutableDictionary* peopleInGroup;

-(USayAppAppDelegate *) appDelegate;
-(BOOL)requestAddContact:(UserInfo*)addUserInfo;
-(void)syncDataSaveDB:(NSArray*)dataArray withRevisionPoint:(NSString *)revisionPoint;
-(void)syncImageDataSaveDB:(UserInfo*)ImageData;
-(void)selectedPhotoImage;
-(void)addedContactPhontUpload:(UserInfo*)userData;

-(UIImage*)resizeImage:(UIImage*)image scaleFlag:(BOOL)aFlag;
-(UIImage*)thumbNailImage:(UIImage*)image Size:(CGFloat)resizeSize;

@end
