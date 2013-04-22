//
//  ManagedObjectMultiSelectionListEditor.h
//  USayApp
//
//  Created by Jong-Sung Park on 10. 6. 22..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddGroupViewController.h"
@protocol editAddrAndGroupDelegate <NSObject>
-(void)updateMovetoGroup;
-(void)createGroupInMove;
@end

@class GroupInfo;
@class blockView;
@class USayAppAppDelegate;

@interface EditAddressGroupMultiSelectionViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, addGroupDelegate> {
	NSArray            *list;				//상위 controller에서 받아온 그룹 리스트 값
	NSString		*keypath;				//
	NSString		*labelString;
	UITableView		*customTableView;		
	NSArray			*userList;				//그룹 이동을 위해 선택된 유저 리스트
	NSMutableArray *selectedGroup;
	blockView*		moveGroupBlock;			// 그룹 이동시 다른 선택 차단 할 뷰
	
	NSMutableDictionary* peopleInGroup;
	id<editAddrAndGroupDelegate> moveDelegate;
    
@private
//mezzo    NSIndexPath        *lastIndexPath;
	UIToolbar*		buttonToolBar;
}
@property (nonatomic, retain) NSString *keypath;
@property (nonatomic, retain) NSString *labelString;
@property (nonatomic, retain) NSArray *list;
@property (nonatomic, retain) UITableView *customTableView;
@property (nonatomic, retain) NSArray	*userList;
@property (nonatomic, retain) NSMutableArray *selectedGroup;
@property (nonatomic, retain) id<editAddrAndGroupDelegate> moveDelegate;
@property (nonatomic, retain) NSMutableDictionary* peopleInGroup;


-(USayAppAppDelegate *) appDelegate;
-(void)backBarButtonClicked;
-(void)addCustomHeaderView;
-(void)addCustomFooterView;
-(void)addCustomBottomToolBarView;
-(void)createNewGroup;
-(BOOL)requestUpdateListContact:(NSArray *)dicData withGroup:(GroupInfo*)newGroup;
- (void)syncDataSaveDB:(NSArray*)moveUserData;
-(IBAction)leftButtonClicked:(id)sender;
-(IBAction)rightButtonClicked:(id)sender;
@end
