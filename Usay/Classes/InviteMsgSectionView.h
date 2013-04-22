//
//  InviteMsgSectionView.h
//  USayApp
//
//  Created by 1team on 10. 7. 8..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface InviteMsgSectionView : UIControl {
	UIImageView		*backgroundImageView;
	UIImageView		*openImageView;
	UILabel			*groupTitleLabel;			// 그룹 이름
	NSInteger		section;
}

@property (nonatomic, retain) UIImageView	*backgroundImageView;
@property (nonatomic, retain) UIImageView	*openImageView;
@property (nonatomic, retain) UILabel		*groupTitleLabel;
@property (nonatomic) NSInteger	section;

@end
