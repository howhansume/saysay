//
//  synchronizationViewController.h
//  USayApp
//
//  Created by ku jung on 10. 10. 28..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "blockView.h"

@interface synchronizationViewController : UIViewController<UIAlertViewDelegate>{
	NSMutableArray *oemGroupArray;
	blockView *syncBlockView;

	UILabel *warningDetailText;
	UILabel *explainLabel;
	UIButton *sendButton, *sendButton2;
	NSInteger flag;
	UIBarButtonItem *leftButton;
	UIBarButtonItem *RightButton;
//	UIImageView *sendImg[10];
//	NSMutableArray *oemGroupArray;
	
	UILabel	*curCount;
	UILabel	*curCount2;
	NSInteger cur, tot;
	
	UIButton *groupCheckButton;    // 내보내기 시 그룹 삭제
	
	
	NSTimer	*timer;
}

@property NSInteger flag;
@property NSInteger cur;
@property NSInteger tot;
@property (nonatomic, retain) NSTimer *timer;


-(void)requestgetWebCnt;
-(void)weReadThread;
-(void)usaytoweb;
-(NSString*)dateFormat:(NSString *)date;
- (void)checkBoxClicked;
- (void)removeAllGroup;
- (void)startComplete;		// sochae 2010.12.29 - cLang
- (void)requestGetGroups;	// sochae 2010.12.29 - cLang
- (void)stopTimer; //kjh 2011.02.4
-(void) startComplete2; //kjh
@end
