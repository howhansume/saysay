//
//  InviteMsgTableCell.h
//  USayApp
//
//  Created by 1team on 10. 7. 8..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface InviteMsgTableCell : UITableViewCell {
	UIImageView *radioImageView;
	UIImageView *photoImageView;
	UIImageView *statusImageView;
	UILabel		*nameTitleLabel;
	UILabel		*subTitleLabel;
	NSString	*imstatus;			// -1:주소록 타입  0:offline  1:online  2:busy (바빠요)  8:곧 돌아옵니다.  16:다른용무중
	
	BOOL		checked;
	BOOL		isDisabled;		// 본인이면 선택 되지 않도록 처리
	
}

@property (nonatomic, retain) UIImageView* radioImageView;
@property (nonatomic, retain) UIImageView* photoImageView;
@property (nonatomic, retain) UIImageView* statusImageView;
@property (nonatomic, retain) UILabel*		nameTitleLabel;
@property (nonatomic, retain) UILabel*		subTitleLabel;
@property (nonatomic, retain) NSString*		imstatus;
@property (nonatomic, assign) BOOL			checked;
@property (nonatomic, assign) BOOL			isDisabled;

- (void)checkAction:(id)sender;

@end
