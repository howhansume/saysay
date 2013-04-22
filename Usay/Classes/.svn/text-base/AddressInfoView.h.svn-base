//
//  AddressInfoView.h
//  USayApp
//
//  Created by Jong-Sung Park on 10. 6. 29..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ApplicationCell;
@interface AddressInfoView : UIView {
	UIImageView* photoView;
	UIImageView* statusView;
	UILabel*	 titleLabel;
	UILabel*	 subTitleLabel;
	
	id		parentDelegate;
	ApplicationCell* selfCell;
@private
	float touchBeganX, touchBeganY;
	float touchMovedX, touchMovedY;
}

-(UIImageView*)getPhotoView;

@property (nonatomic, retain) UIImageView* photoView;
@property (nonatomic, retain) UIImageView* statusView;
@property (nonatomic, retain) UILabel*	 titleLabel;
@property (nonatomic, retain) UILabel*	 subTitleLabel;
@property (nonatomic, assign) id parentDelegate;
@property (nonatomic, assign) ApplicationCell* selfCell;


@end
