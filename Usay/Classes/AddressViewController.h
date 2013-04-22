//
//  AddressViewController.h
//  USayApp
//
//  Created by Jong-Sung Park on 10. 5. 18..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import "GroupCommunityView.h"
#import <MessageUI/MessageUI.h>
#import "EditAddressViewController.h"
#import "AddressDetailViewController.h"
#import "AddBuddyViewController.h"
#import "AddGroupViewController.h"
#import "BuddyPersonViewController.h"
#import "ApplicationCell.h"
#import <AddressBookUI/AddressBookUI.h>



//#import <AddressBookUI/AddressBookUI.h>
#import <sqlite3.h>


@class USayAppAppDelegate;
@class ProfileInfo;
@class ApplicationCell;
@interface AddressViewController : UITableViewController<UIActionSheetDelegate, UIScrollViewDelegate, editAddressDelegate,
														CommuniteViewDelegate, MFMessageComposeViewControllerDelegate, ApplicationCellDelegate,
														AddressDetailDelegate, addBuddyDelegate, addGroupDelegate, AddressPersonDelegate,
														UINavigationControllerDelegate, ABPersonViewControllerDelegate,ABPeoplePickerNavigationControllerDelegate,ABNewPersonViewControllerDelegate> 
{

	NSMutableArray* allNames;
	NSMutableArray* allGroups;
	NSMutableDictionary* peopleInGroup;		// 전체 주소록
	NSMutableDictionary* peopleInBuddy;		// 친구 주소록
	NSMutableDictionary* filteredHistory;
	NSMutableArray*	searchArray;
	NSMutableDictionary* statusGroup;
	UITableView		*currentTableView;

	NSMutableArray* selectedPerson;
	ProfileInfo*  profileUser;
	
	BOOL viewList;//전체보기 친구보기 토글기능을 위해.
	BOOL checkSelectImage;
//	BOOL	isMemoryWarning;//메모리 오버 여부.
	
	NSMutableArray	*msgSearchArray;
	NSMutableArray	*chosungNumArray;
	NSArray			*chosungArray;
	NSArray			*jungsungArray;
	NSArray			*jongsungArray;
															
	UILabel			*myLabel;
	
	UIView *pickerTitleView;
	UILabel *pickerTitleLabel;
	
	
	NSMutableArray*			oemGroupArray;
	NSMutableDictionary*	groupcntDic;
	
	
//	BOOL smsflag;
					
		
	
@private
    NSIndexPath        *lastIndexPath;
}

@property (nonatomic, retain) NSMutableArray* allNames;
@property (nonatomic, retain) NSMutableArray* allGroups;
@property (nonatomic, retain) NSMutableDictionary* filteredHistory;
@property (nonatomic, retain) NSMutableDictionary*	groupcntDic;
@property (nonatomic, retain) NSMutableDictionary* peopleInGroup;
@property (nonatomic, retain) NSMutableArray*	searchArray;
@property (nonatomic, retain) NSMutableDictionary* statusGroup;
@property (nonatomic, retain) NSMutableDictionary* peopleInBuddy;
@property (nonatomic, retain) UITableView		*currentTableView;
@property (nonatomic, retain) NSMutableArray* selectedPerson;
@property (nonatomic, retain) ProfileInfo*  profileUser;

@property (nonatomic, retain) NSMutableArray	*msgSearchArray;
@property (nonatomic, retain) NSMutableArray	*chosungNumArray;
@property (nonatomic, retain) NSArray			*chosungArray;
@property (nonatomic, retain) NSArray			*jungsungArray;
@property (nonatomic, retain) NSArray			*jongsungArray;

//@property (nonatomic) NSInteger indexSection;
@property  BOOL viewList;
@property  BOOL checkSelectImage;
//@property (nonatomic) BOOL folded;

-(USayAppAppDelegate *) appDelegate;
//-(void)applicationWillTerminate : (NSNotification *)notification;
-(void)headerEvent :(id)sender;
-(void)groupEditEvent:(id)sender;

-(void) buddyKindButtonClicked;
-(void)addressEditButtonClicked;

-(BOOL)convertBoolValue:(NSString *)boolString;

-(BOOL)IsHangulChosung:(NSInteger)code;
-(NSString *)GetUTF8String:(NSString *)str;
-(NSString *)GetChosungUTF8String:(NSString *)str;
-(NSString *)GetChosungUTF8StringSearchString:(NSString *)str;

-(void)buddySayButtonClicked:(id)sender;
-(void)buddySMSButtonClicked:(id)sender;
-(void)buddySMSButtonCheck;
-(void)buddyCallButtonClicked:(id)sender;
-(void)groupSayButtonClicked:(id)sender;
-(void)groupSMSButtonClicked:(id)sender;
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
-(void)reloadAddressData;
-(void)syncDataBuddyChangeInfo:(NSArray*)profileArray;
-(void) changedProfileInfoSyncMemory:(UserInfo *)profileData;
-(void)onlyFriend;
-(void)movetabBar;
-(void)showEdit;
-(void)showProfile;
-(void)setDisabled;

-(void)setEnabledAdd;

// sochae 2010.10.08
- (void) cancelModal;
- (void) sendSMSwitRecipient:(NSString *)recipient;
// ~sochae


@end
