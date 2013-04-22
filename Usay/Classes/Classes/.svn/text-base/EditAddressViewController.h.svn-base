//
//  EditAddressViewController.h
//  USayApp
//
//  Created by Jong-Sung Park on 10. 6. 20..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditAddressGroupMultiSelectionViewController.h"
#import "EditGroupViewController.h"
#import "AddGroupViewController.h"
#import "blockView.h"

@protocol editAddressDelegate <NSObject>

-(void)deleteUserListWithArray:(NSArray*)value;
-(void)editCompleteAddressInfo;

@end

@class USayAppAppDelegate;
@class blockView;
@interface EditAddressViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,
UIActionSheetDelegate, UIAlertViewDelegate, editAddrAndGroupDelegate, editGroupInfoDelegate, addGroupDelegate> {
	
	NSMutableArray* allNames;
	NSMutableArray* allGroups;
	NSMutableDictionary* peopleInGroup;
	NSMutableDictionary* statusGroup;
	NSMutableArray* selectedPerson;
	UISegmentedControl *editAddrChange;
	UIToolbar*		buttonToolBar;
	UITableView*	customPlanTableView;
	UITableView*	customGroupTableView;
	blockView*		editBlockView;
	id<editAddressDelegate> editDelegate;
	NSInteger numberofEdit;
	NSInteger btnIndex;
	EditGroupViewController* Editcontroller;
	blockView*		editGroupBlock;
@private   
	
//mezzo	NSArray         *rowArguments; 
	
}

@property (nonatomic, retain) IBOutlet UISegmentedControl* editAddrChange;
@property (nonatomic, retain) IBOutlet UIToolbar* buttonToolBar;
@property (nonatomic, retain) UITableView* customPlanTableView;
@property (nonatomic, retain) UITableView* customGroupTableView;
@property (nonatomic, retain) NSMutableArray* allNames;
@property (nonatomic, retain) NSMutableArray* allGroups;
@property (nonatomic, retain) NSMutableDictionary* peopleInGroup;
@property (nonatomic, retain) NSMutableDictionary* statusGroup;
@property (nonatomic, retain) NSMutableArray* selectedPerson;
@property (nonatomic, assign) id<editAddressDelegate> editDelegate;

-(USayAppAppDelegate *) appDelegate;
-(BOOL)convertBoolValue:(NSString *)boolString;

-(IBAction)segmentedControl:(id)sender;
-(IBAction)leftButtonClicked:(id)sender;
-(IBAction)rightButtonClicked:(id)sender;

//-(void)groupEditEvent;
-(void)editheaderEvent :(id)sender;
-(void)createNewGroup;
-(void)createArgumentDetailController;
-(void)addCustomFooterView;
-(void)editGroupClicked:(id)Sender;
-(BOOL)requestDeleteListContact:(NSArray *)dicData;
-(void)syncDatabaseDelete:(NSArray*)userArray withRevisionPoint:(NSString*)revisionPoint;
-(NSArray*)sortIndexPathArray:(NSMutableArray*)sortArray;
-(void)editNumber:(NSInteger)index;
-(void)editData:(NSInteger)sender;
-(void)editGroupClicked2:(NSInteger)sender;
-(void)reloadAddressData;

@end
