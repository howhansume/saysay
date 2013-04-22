//
//  ApplicationCell.m
//  USayApp
//
//  Created by Jong-Sung Park on 10. 5. 21..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "ApplicationCell.h"
#import "AddressInfoView.h"
#import "AddressButtonView.h"
#import <QuartzCore/QuartzCore.h>

@implementation ApplicationCell

@synthesize addressView, buttonView, parentDelegate, checked, bButtonView, isBuddy;
@synthesize photoImage, statusImage, nameTitle, subTitle, PhotoImageView;
@synthesize cellDelegate;

- (id)initStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier number:(NSString*)phone number2:(NSString*)phone2 number3:(NSString*)phone3 number4:(NSString*)phone4 number5:(NSString*)phone5{
//	NSLog(@"number = %@", phone);
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if(self != nil){
		AddressInfoView* addrInfoView = [[AddressInfoView alloc] initWithFrame:self.frame];
		
		
		
		if([phone isEqualToString:@""])
		{
			phone = nil;
		}
		if([phone2 isEqualToString:@""])
		{
			phone2 = nil;
		}
		if([phone3 isEqualToString:@""])
		{
			phone3 = nil;
		}
		if([phone4 isEqualToString:@""])
		{
			phone4 = nil;
		}
		if([phone5 isEqualToString:@""])
		{
			phone5 = nil;
		}
		
	//	NSLog(@"phone =%@, phone=%@, phone3=%@ ", phone, phone2, phone3);
			
		self.addressView = addrInfoView;
		addressView.parentDelegate = self.parentDelegate;
		addressView.selfCell = self;
		[self.contentView addSubview:addrInfoView];
		[addrInfoView release];
		
		AddressButtonView* addrButtonView;
	//	AddressButtonView* addrButtonView =[[AddressButtonView alloc] init];
		
		//AddressButtonView* addrButtonView = [[AddressButtonView alloc]initWithFrame:self.frame];
		
		
		//휴대폰 메인전화 둘다 있을경우
		/*
		if(phone !=nil && phone2 != nil)
		{
		
			NSLog(@"111111111111111");
			addrButtonView = [[AddressButtonView alloc] initFrame:self.frame falg:1];
			// addrButtonView = [[AddressButtonView alloc] nullWithFrame:self.frame];
			
		}
		//휴대폰만 있을경우 
		else if(phone != nil && phone2 == nil)
		{
			NSLog(@"22222222222222222");
			addrButtonView = [[AddressButtonView alloc] initFrame:self.frame falg:2];
			
		}//메인전화만 있을경우
		else if(phone == nil && phone2 != nil)
		{
			NSLog(@"3333333333333");
			addrButtonView = [[AddressButtonView alloc] initFrame:self.frame falg:3];
			
		}
		else {//둘다 없을경우
			NSLog(@"44444444444");
			addrButtonView = [[AddressButtonView alloc] nullWithFrame:self.frame];
		}
		 */
		
		//휴대폰, 집, 회사 모두 없을 경우만 문자 비활성화
		if(phone == nil && phone2 == nil && phone3 ==nil && phone4 ==nil && phone5 == nil){
				addrButtonView = [[AddressButtonView alloc] nullWithFrame:self.frame];
			}
		else {
			addrButtonView = [[AddressButtonView alloc] initFrame:self.frame falg:1];
		}



		self.buttonView = addrButtonView;
		buttonView.parentDelegate = self.parentDelegate;
		buttonView.selfCell = self;
		buttonView.isBuddy = self.isBuddy;
		[addrButtonView release];
		
	//	NSLog(@"================END init number ==================");
		
		
		self.contentView.backgroundColor = [UIColor clearColor];
	}
	return self;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if(self != nil){
		AddressInfoView* addrInfoView = [[AddressInfoView alloc] initWithFrame:self.frame];
		self.addressView = addrInfoView;
		addressView.parentDelegate = self.parentDelegate;
		addressView.selfCell = self;
		[self.contentView addSubview:addrInfoView];
		[addrInfoView release];
		
		AddressButtonView* addrButtonView = [[AddressButtonView alloc]initWithFrame:self.frame];
		self.buttonView = addrButtonView;
		buttonView.parentDelegate = self.parentDelegate;
		buttonView.selfCell = self;
		buttonView.isBuddy = self.isBuddy;
		[addrButtonView release];
		
	
				
		self.contentView.backgroundColor = [UIColor clearColor];
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGRect contentRect = [self bounds];
	[self.contentView setFrame:contentRect];
	
	if(self.buttonView.superview == nil){ 
		self.addressView.frame = contentRect;
	}else{
		self.buttonView.frame = contentRect;
		self.buttonView.isBuddy = self.isBuddy;
	}
}

-(void)setPhotoImageView:(UIImageView *)newImageView {
	PhotoImageView = newImageView;
	self.addressView.photoView.image = newImageView.image;
	self.buttonView.photoView.image = newImageView.image;
	[self.addressView setNeedsLayout];
	[self.buttonView setNeedsLayout];
}
-(void)setPhotoImage:(UIImage *)newPhotoImage {
	photoImage = newPhotoImage;
	self.addressView.photoView.image = newPhotoImage;
	self.buttonView.photoView.image = newPhotoImage;
}

-(void)setStatusImage:(UIImage *)newStatusImage {
	statusImage = newStatusImage;
	self.addressView.statusView.image = newStatusImage;
}

-(void)setNameTitle:(NSString *)newName {
	nameTitle = newName;
	self.addressView.titleLabel.text = newName;
	[self.addressView setNeedsLayout];
}

-(void)setSubTitle:(NSString *)newSubTitle {
	subTitle = newSubTitle;
	self.addressView.subTitleLabel.text = newSubTitle;
	[self.addressView setNeedsLayout];
}
/*
-(void)ableImg
{
	[self.buttonView changeImg];
	
}
*/
-(void)selectViewChange:(BOOL)isBuddyOK {
//	if(checked == NO){
		CATransition *animation = [CATransition animation];
		[animation setDuration:0.1];
		[animation setType:kCATransitionPush];
		animation.delegate = self;
	
	
//	NSLog(@"isBuddy............");
//	[self.buttonView changeImg];
		
		if(self.buttonView.superview == nil) {
			self.buttonView.isBuddy = isBuddyOK;
			[addressView removeFromSuperview];
			[self.contentView addSubview:buttonView];
//			self.accessoryType = UITableViewCellAccessoryNone;
			[addressView setNeedsLayout];
			[animation setSubtype:kCATransitionFromLeft];
			self.bButtonView = YES;
		}else {
			[buttonView removeFromSuperview];
			[self.contentView addSubview:addressView];
			[animation setSubtype:kCATransitionFromRight];
			[buttonView setNeedsLayout];
			self.bButtonView = NO;
		}

		[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
		[[self.contentView layer] addAnimation:animation forKey:@"cellSwithView"];
//	}
}

-(void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
	if(self.buttonView.superview == nil) {
//		self.accessoryType = UITableViewCellAccessoryNone;
	}	
}

-(AddressInfoView*)getInfoView
{
	return self.addressView;
}

-(AddressButtonView*)getButtonView
{
	return self.buttonView;
}

- (void)dealloc {
	if(addressView)
		[addressView release];
	if(buttonView)
		[buttonView release];
//	if(PhotoImageView)
//		[PhotoImageView release];
//	if(photoImage)
//		[photoImage release];
//	if(statusImage)
//		[statusImage release];
//	if(nameTitle)
//		[nameTitle release];
//	if(subTitle)
//		[subTitle release];
//	if(parentDelegate)
//		[parentDelegate release];
    [super dealloc];
}

-(void)selectedImageView {
	[self.cellDelegate customCellDetailSelect:self];
}
/*
#pragma mark -
#pragma mark cell swipe event Method
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint pt;
	NSSet *allTouches = [event allTouches];
	if ([allTouches count] == 1)
	{
		UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
		if ([touch tapCount] == 1)
		{
			pt = [touch locationInView:self.contentView];
			touchBeganX = pt.x;
			touchBeganY = pt.y;
		}
	}
	[super touchesBegan:touches withEvent:event];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint pt;
	NSSet *allTouches = [event allTouches];
	if ([allTouches count] == 1)
	{
		UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
		if ([touch tapCount] == 1)
		{
			pt = [touch locationInView:self.contentView];
			touchMovedX = pt.x;
			touchMovedY = pt.y;
		}
	}
	[super touchesMoved:touches withEvent:event];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	NSSet *allTouches = [event allTouches];
	if ([allTouches count] == 1)
	{
		int diffX = touchMovedX - touchBeganX;
		int diffY = touchMovedY - touchBeganY;
		if (diffY >= -10 && diffY <= 10) 		
		{
 			if (diffX > 20)
			{
				NSLog(@"swipe right");
				// do something here
				if(self.buttonView.superview == nil) {
					[self selectViewChange];
				}
			}
			else if (diffX < -10 && diffX < -40 )
			{
				NSLog(@"swipe left");
				// do something else here
				if(self.addressView.superview == nil){
					[self selectViewChange];
				}
			}
		}
		else if(touchMovedY == 0 && touchMovedX == 0) {			
			NSLog(@"tap");
			// do something here
			[self selectViewChange];
		}

		
	}
	
	[super touchesEnded:touches withEvent:event];
}
*/
@end
