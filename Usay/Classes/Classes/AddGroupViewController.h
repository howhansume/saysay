//
//  AddGroupViewController.h
//  USayApp
//
//  Created by Jong-Sung Park on 10. 6. 20..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ManagedObjectAttributeEditor.h"

@class GroupInfo;
@class blockView;
@class USayAppAppDelegate;

@protocol addGroupDelegate <NSObject>

-(void)updateGroupWithGroupInfo:(GroupInfo*)value;

@end

@interface AddGroupViewController : UITableViewController<UITextFieldDelegate, detailViewDataDelegate> {
	GroupInfo* groupChanged;  //그룹 편집시 그룹 정보를 전달 받는다.
	NSArray			*userList;				//그룹 이동을 위해 선택된 유저 리스트
	blockView*		addGroupBlock;			// 그룹 생성시 다른 선택 차단 할 뷰
	id<addGroupDelegate> addDelegate;
}
@property (nonatomic, retain) GroupInfo* groupChanged;
@property (nonatomic, retain) NSArray	*userList;
@property (nonatomic, assign) id<addGroupDelegate> addDelegate;

-(USayAppAppDelegate *) appDelegate;
-(void)completedClicked;
-(BOOL)requestAddGroup:(GroupInfo*)addGroupData;
-(BOOL)requestUpdateGroup:(GroupInfo*)GroupData;
-(NSInteger) displayTextLength:(NSString*)text;
-(void)syncDataSaveDB:(NSArray*)dataArray withRevisionPoint:(NSString *)revisionPoint;
@end
