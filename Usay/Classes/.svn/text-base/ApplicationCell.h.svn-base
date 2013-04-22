//
//  ApplicationCell.h
//  USayApp
//
//  Created by Jong-Sung Park on 10. 5. 21..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ApplicationCell;
@protocol ApplicationCellDelegate <NSObject>

-(void)customCellDetailSelect:(ApplicationCell*)senderCell;

@end

@class AddressInfoView;
@class AddressButtonView;
@interface ApplicationCell : UITableViewCell {
	AddressInfoView*		 addressView;
	AddressButtonView*		 buttonView;
	UIImageView*			 PhotoImageView;
	UIImage*				 photoImage;
	UIImage*				 statusImage;
	NSString*				 nameTitle;
	NSString*				 subTitle;
	NSString*				 recid;
	id						 parentDelegate;
	id<ApplicationCellDelegate> cellDelegate;
	BOOL	checked;
	BOOL	bButtonView;
	BOOL	isBuddy;
	
@private //mezzo
	//	int touchBeganX, touchBeganY;
	//	int touchMovedX, touchMovedY;
}

-(AddressInfoView*)getInfoView;
-(AddressButtonView*)getButtonView;

@property (nonatomic, retain) AddressInfoView* addressView;
@property (nonatomic, retain) AddressButtonView* buttonView;
@property (nonatomic, retain) UIImage* photoImage;
@property (nonatomic, retain) UIImage* statusImage;
@property (nonatomic, retain) NSString* nameTitle;
@property (nonatomic, retain) NSString* subTitle;
@property (nonatomic, retain) NSString* recid;
@property (nonatomic, assign) id parentDelegate;
@property (nonatomic, retain) UIImageView*	PhotoImageView;

@property (nonatomic, assign) BOOL checked;
@property (nonatomic, assign) BOOL bButtonView;
@property (nonatomic, assign) BOOL isBuddy;

@property (nonatomic, assign) id<ApplicationCellDelegate> cellDelegate;

- (id)initStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier number:(NSString*)phone number2:(NSString*)phone2 number3:(NSString*)phone3 number4:(NSString*)phone4 number5:(NSString*)phone5;
-(void)selectViewChange:(BOOL)isBuddyOK;
-(void)selectedImageView;
//-(void)ableImg;
@end
