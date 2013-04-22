//
//  MyInfoSettingViewController.h
//  USayApp
//
//  Created by 1team on 10. 6. 3..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <UIKit/UIKit.h>

@class USayAppAppDelegate;

@interface MyInfoSettingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	UITableView		*myInfoSettingTableView;
	NSMutableString	*preHomeTel;
	NSMutableString	*preOfficeTel;
	NSMutableString	*preMobileTel;
	NSMutableString	*preOrganization;
	NSMutableString	*preHomePageURL;
	NSMutableString	*preEmail;
	
	UIActivityIndicatorView* requestActIndicator;
	
	BOOL				isRequest;
}

-(void) saveMyInfo;
-(USayAppAppDelegate *) appDelegate;
-(void)backBarButtonClicked;
-(NSInteger) displayTextLength:(NSString*)text;
//-(void)timer:(NSTimer *)timecall;
-(void)insertContents:(NSString*)contents insertType:(NSInteger)type;
-(void)wilRotation;

@property (nonatomic, retain) UITableView		*myInfoSettingTableView;
@property (nonatomic, retain) NSMutableString	*preHomeTel;
@property (nonatomic, retain) NSMutableString	*preOfficeTel;
@property (nonatomic, retain) NSMutableString	*preMobileTel;
@property (nonatomic, retain) NSMutableString	*preOrganization;
@property (nonatomic, retain) NSMutableString	*preHomePageURL;
@property (nonatomic, retain) NSMutableString	*preEmail;
@property (readwrite) BOOL isRequest;


@end
