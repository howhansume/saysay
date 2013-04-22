//
//  EditGroupViewController.h
//  USayApp
//
//  Created by Jong-Sung Park on 10. 6. 24..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddGroupViewController.h"

@class GroupInfo;
@class blockView;
@class USayAppAppDelegate;
@protocol editGroupInfoDelegate <NSObject>

-(void)editGroupDataInfo;

@end

@interface EditGroupViewController : UITableViewController<addGroupDelegate, UIAlertViewDelegate> {
	GroupInfo* editGroupInfo;
	NSString*  groupDelKind;
	id<editGroupInfoDelegate> editGroupDelegate;
	blockView*		editGroupBlock;			// 그룹 삭제, 그룹 전체 삭제 시 
}

@property (nonatomic, retain) GroupInfo* editGroupInfo;
@property (nonatomic, retain) NSString*  groupDelKind;
@property (nonatomic, retain) id<editGroupInfoDelegate> editGroupDelegate;

-(USayAppAppDelegate *) appDelegate;
-(void)addCustomFooterView;
-(void)delOnlyGroup;
-(void)delAllInGroup;
-(void) syncDataBase:(NSArray*)delArray withRevisionPoint:(NSString*)revision;
-(void)requestDeleteGroup:(NSString*)include withGroupId:(NSString*)gid;
@end
