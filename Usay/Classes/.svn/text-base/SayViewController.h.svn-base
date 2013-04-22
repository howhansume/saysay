//
//  SayViewController.h
//  USayApp
//
//  Created by 1team on 10. 6. 14..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BalloomTableCell.h"

@class SayInputTextView;
@class USayAppAppDelegate;

@interface SayViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
	UITableView			*sayTableView;
	UIView				*inputView;
	SayInputTextView	*inputTextView;
	UIButton			*addBtn;
	UIButton			*sendBtn;
	
	NSMutableString		*sessionKey;
	NSArray				*buddyArray;
	NSInteger			keyboardHeight;
	NSTimer				*startTimer;
	NSTimer				*keyboardUpTimer;
	
	NSInteger			reSendCellRow;
	
	BOOL				keyboardShown;
	BOOL				alreadySession;			// 기존 대화방 ? 
	BOOL				photoLibraryShown;
	
	int minHeight;
	int maxHeight;
	
	int maxNumberOfLines;
	int minNumberOfLines;
	
	BOOL animateHeightChange;
	BOOL viewDidLoadSuccess;
	
	NSMutableDictionary *sourceMovie;
	UILabel *myLabel;
	
	UIActionSheet *menu;
	
	NSMutableArray		*sayMsgArr;
	int					nViewStart;
	int					nViewEnd;
	int					fullCount;
    BOOL                bFirstLoadTable;
    BOOL                baddItemFinish;
    
    int                 nScrollPos;
    
//    Boolean updateFlag;
	
//	UITableViewCell* firstCell; //첫번째 셀 저장
	
	NSTimer* loadingTimer;

}

-(id)initWithNibNameBuddyListMsgType:(NSString*)nibName chatSession:(NSString*)chatsession type:(NSString*)msgCType BuddyList:(NSArray*)buddyList bundle:(NSBundle *)nibBundle;
-(USayAppAppDelegate *) appDelegate;
-(void)registerForKeyboardNotifications;
-(void)keyboardWillShown:(NSNotification*)aNotification;
-(void)keyboardWillHidden:(NSNotification*)aNotification;

-(IBAction) clicked:(id)sender;
-(void)inviteButtonClicked;
-(void)backBarButtonClicked;
-(void)mediaViewAction:(id)sender;
-(void)reSendContentsAction:(id)sender;
-(void)balloomAction:(id)sender;

-(void)setMaxNumberOfLines:(int)n;
-(void)setMinNumberOfLines:(int)m;

-(void)willChangeHeight:(float)newSizeHeight;

-(void)createJoinChatSession:(NSArray*)newBuddyArray;
-(void)inviteJoinChatSession:(NSArray*)inviteBuddyArray;
-(void)getReadMark;
-(void)getRetrieveSessionMessage;
-(void)hiddenKeyboard;
-(void)showImage:(NSString*)cellImage cell:(BalloomTableCell*)nowcell;

-(UIImage*)resizeImage:(UIImage*)image scaleFlag:(BOOL)aFlag;
-(UIImage*)thumbNailImage:(UIImage*)image Size:(CGFloat)resizeSize;

@property (nonatomic, retain) UITableView			*sayTableView;
@property (nonatomic, retain) UIView				*inputView;
@property (nonatomic, retain) SayInputTextView		*inputTextView;
@property (nonatomic, retain) UIButton				*addBtn;
@property (nonatomic, retain) UIButton				*sendBtn;

@property (nonatomic, retain) NSMutableString		*sessionKey;
@property (nonatomic, retain) NSArray				*buddyArray;
@property (nonatomic, assign) NSInteger				keyboardHeight;
@property (readwrite)		  BOOL					alreadySession;
@property (readwrite)		  BOOL					viewDidLoadSuccess;
@property (readwrite)		  BOOL					photoLibraryShown;

@property (readwrite)		  NSInteger				reSendCellRow;

@property (nonatomic, retain) UIActionSheet			*menu;

@property (nonatomic, retain) NSMutableArray		*sayMsgArr;

@property int maxNumberOfLines;
@property int minNumberOfLines;
@property BOOL animateHeightChange;

@end
