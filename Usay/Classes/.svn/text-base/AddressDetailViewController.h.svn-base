//
//  AddressDetailViewController.h
//  Nav
//
//  Created by Jong-Sung Park on 10. 6. 5..
//  Copyright 2010 inamass. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "BuddyPersonViewController.h"


@class UserInfo;

@protocol AddressDetailDelegate <NSObject>

-(void)updateProfileInfo:(UserInfo*)profileValue withBeforeGroupID:(NSString*)beforeGID;
-(void)blockBuddychange:(UserInfo*)profileValue;
-(void)updatePersonInfo:(UserInfo*)PersonValue;
-(void)deletePersonInfo:(UserInfo*)PersonValue;

@end

@class BuddyProfileViewController;
@class BuddyPersonViewController;
@interface AddressDetailViewController : UIViewController<MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, AddressPersonDelegate>
{
	NSString* userRPKey;
	NSString* userFormatted;
	UserInfo* passUserInfo;
	UISegmentedControl *profileChange;
	BuddyProfileViewController* selectedViewController;
	BuddyPersonViewController* personViewController;
//	BOOL	isMemoryWarning;//메모리 오버 여부.
	id<AddressDetailDelegate> dtlDelegate;
		
}

@property (nonatomic, retain) IBOutlet UISegmentedControl *profileChange;
@property (nonatomic, retain) IBOutlet BuddyProfileViewController* selectedViewController;
@property (nonatomic, retain) IBOutlet BuddyPersonViewController* personViewController;
@property (nonatomic, retain) NSString* userRPKey;
@property (nonatomic, retain) NSString* userFormatted;
@property (nonatomic, retain) UserInfo* passUserInfo;
@property (nonatomic, assign) id<AddressDetailDelegate> dtlDelegate;

-(IBAction)segmentedControl:(id)sender;
-(void)updateProfileInfo:(UserInfo*)profileValue withBeforeGroupID:(NSString*)beforeGID;
-(void)blockedfileInfo:(UserInfo*)profileValue;

-(void)updateBuddyCompleted;

@end

