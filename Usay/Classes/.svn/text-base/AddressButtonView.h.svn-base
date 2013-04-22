//
//  AddressButtonCell.h
//  USayApp
//
//  Created by Jong-Sung Park on 10. 6. 29..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ApplicationCell;
@interface AddressButtonView : UIView {
	UIImageView* backgroundView;
	UIImageView* photoView;
	UIButton* msgButton;
	UIButton* smsButton;
	UIButton* callButton;
	
	id		parentDelegate;
	ApplicationCell* selfCell;
	BOOL	isBuddy;
	NSString *recid;
@private
	float touchBeganX, touchBeganY;
	float touchMovedX, touchMovedY;
	
	
	
}

-(UIImageView*)getPhotoView;
- (id)initFrame:(CGRect)frame falg:(int)number;
-(id)nullWithFrame:(CGRect)frame;


@property (nonatomic, retain) UIImageView* photoView;
@property (nonatomic, retain) UIButton* msgButton;
@property (nonatomic, retain) UIButton* smsButton;
@property (nonatomic, retain) UIButton* callButton;
@property (nonatomic, retain) NSString* recid;
@property (nonatomic, retain) UIImageView* backgroundView;
@property (nonatomic, assign) id parentDelegate;
@property (nonatomic, assign) ApplicationCell* selfCell;
@property (nonatomic, assign) BOOL isBuddy;

@end
