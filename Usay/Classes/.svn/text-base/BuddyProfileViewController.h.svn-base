//
//  BuddyProfileViewController.h
//  USayApp
//
//  Created by Jong-Sung Park on 10. 6. 13..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ManagedObjectAttributeEditor.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@class USayAppAppDelegate;
@class ProfileInfo;
@class UserInfo;
@class AddressDetailViewController;
@interface BuddyProfileViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, detailViewDataDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate> {
	UITableView* buddyTableView;
	NSArray *tableArray;
	NSDictionary	*tableItem;
	AddressDetailViewController* parentController;
	NSString*  profileKey;
	NSString* userFormatted;			// 프로필 별명 (PROFILENICKNAME)
	NSString* beforeGroupID;
	ProfileInfo* userProfile;
	UserInfo*    profileUserData;
	UIButton *imgButton;
//	BOOL	isMemoryWarning;//메모리 오버 여부.
	//
	
}
@property (nonatomic, retain) IBOutlet UITableView* buddyTableView;

//@property (nonatomic, retain) IBOutlet UILabel *cellTitleLabel;
//@property (nonatomic, retain) IBOutlet UILabel *cellValueLabel;
@property (nonatomic, retain) NSArray *tableArray;
@property (nonatomic, retain) NSDictionary	*tableItem;
@property (nonatomic, retain) AddressDetailViewController* parentController;
@property (nonatomic, retain) NSString*  profileKey;
@property (nonatomic, retain) NSString* userFormatted;
@property (nonatomic, retain) ProfileInfo* userProfile;
@property (nonatomic, retain) UserInfo*    profileUserData;
@property (nonatomic, retain) NSString* beforeGroupID;

-(USayAppAppDelegate *) appDelegate;
-(void) requestLoadSimpleProfile:(NSString*)profilerKey;
-(void) syncLoadSimpleProfile;
-(void) requestProfileUpdateContact:(NSString*)groupID;
-(void) syncDataSaveDB:(NSArray*)dataArray withRevisionPoint:(NSString *)revisionPoint;
-(void) syncUpdateProfile:(NSString*)userPkey;
-(void) createCustomHeaderView;
-(void) addCustomFooterView;
-(void)profileSMSSendClicked;
-(void)profileSayRequestClicked;
@end
