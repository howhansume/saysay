//
//  AddressButtonCell.m
//  USayApp
//
//  Created by Jong-Sung Park on 10. 6. 29..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "AddressButtonView.h"
#import <QuartzCore/QuartzCore.h>
#import "ApplicationCell.h"
#import "USayAppAppDelegate.h"
#import "AddressViewController.h"

#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation AddressButtonView
@synthesize msgButton, smsButton, callButton;
@synthesize photoView, parentDelegate, backgroundView, isBuddy, selfCell;



/*
-(void)changeImg
{
	
	NSLog(@"changeImg..................");
}
*/
/*
-(id)initFrame:(CGRect)frame
{
	NSLog(@"not nullll");
	
	
	self = [super initWithFrame:frame];
	if(self != nil) {
		
	UIImageView* thumbnail = [[UIImageView alloc] initWithFrame:CGRectZero];
	thumbnail.layer.masksToBounds = YES;
	[thumbnail.layer setCornerRadius:5.0];
	[thumbnail setClipsToBounds:YES];
	[thumbnail setImage:[UIImage imageNamed:@"img_default.png"]];
	self.photoView = thumbnail;
	
	
	UIImage* msgNormalImg = [[UIImage imageNamed:@"btn_say.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	UIImage* msgClickedImg = [[UIImage imageNamed:@"btn_say_focus.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	UIImage* msgClickdim = [[UIImage imageNamed:@"btn_say_dim.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	UIButton* communityButton = [[UIButton alloc] initWithFrame:CGRectZero];
	[communityButton addTarget:self.parentDelegate action:@selector(buddySayButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[communityButton setImage:msgNormalImg forState:UIControlStateNormal];
	[communityButton setImage:msgClickedImg forState:UIControlStateHighlighted];
	[communityButton setImage:msgClickdim forState:UIControlStateDisabled];
	self.msgButton = communityButton;
	[self addSubview:communityButton];
	[communityButton release];
	//TODO: 테스트 끝나면 주석 제거. 친구일경우에만 버튼 활성화
	if(self.isBuddy)
		self.msgButton.enabled = YES;
	else
		self.msgButton.enabled = NO;
	
	[self addSubview:thumbnail];
	[thumbnail release];
	
	
	UIImage* smsNormalImg = [[UIImage imageNamed:@"btn_sms.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	UIImage* smsClickedImg = [[UIImage imageNamed:@"btn_sms_focus.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
//	UIImage* smsClickdim = [[UIImage imageNamed:@"btn_sms_dim.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	UIButton* smsSendButton = [[UIButton alloc] initWithFrame:CGRectZero];
	
	
	
	
	
	[smsSendButton setImage:smsNormalImg forState:UIControlStateNormal];
	[smsSendButton setImage:smsClickedImg forState:UIControlStateHighlighted];
	[smsSendButton addTarget:self.parentDelegate action:@selector(buddySMSButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	//[smsSendButton setImage:smsClickdim forState:UIControlStateSelected];
	self.smsButton = smsSendButton;
	[self addSubview:smsSendButton];
	[smsSendButton release];		
	
	UIImage* callNormalImg = [[UIImage imageNamed:@"btn_tel.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	UIImage* callClickedImg = [[UIImage imageNamed:@"btn_tel_focus.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	//		UIImage* callClickdim = [[UIImage imageNamed:@"btn_tel_dim.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	UIButton* callSendButton = [[UIButton alloc] initWithFrame:CGRectZero];
	[callSendButton addTarget:self.parentDelegate action:@selector(buddyCallButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[callSendButton setImage:callNormalImg forState:UIControlStateNormal];
	[callSendButton setImage:callClickedImg forState:UIControlStateHighlighted];
	//		[callSendButton setImage:callClickdim forState:UIControlStateSelected];
	self.callButton = callSendButton;
	[self addSubview:callSendButton];
	[callSendButton release];
		return self;
	}
	
	return self;
	
}
*/



-(id)nullWithFrame:(CGRect)frame
{
	
	
	NSLog(@"nullll");
	
	
	self = [super initWithFrame:frame];
	if(self != nil) {
	
//	UIImageView* thumbnail = [[UIImageView alloc] initWithFrame:CGRectZero];
		UIImageView* thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];

	thumbnail.layer.masksToBounds = YES;
	[thumbnail.layer setCornerRadius:5.0];
	[thumbnail setClipsToBounds:YES];
	[thumbnail setImage:[UIImage imageNamed:@"img_default.png"]];
	self.photoView = thumbnail;
	
	
	UIImage* msgNormalImg = [[UIImage imageNamed:@"btn_say.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	UIImage* msgClickedImg = [[UIImage imageNamed:@"btn_say_focus.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	UIImage* msgClickdim = [[UIImage imageNamed:@"btn_say_dim.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	UIButton* communityButton = [[UIButton alloc] initWithFrame:CGRectZero];
	[communityButton addTarget:self.parentDelegate action:@selector(buddySayButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[communityButton setImage:msgNormalImg forState:UIControlStateNormal];
	[communityButton setImage:msgClickedImg forState:UIControlStateHighlighted];
	[communityButton setImage:msgClickdim forState:UIControlStateDisabled];
	self.msgButton = communityButton;
	[self addSubview:communityButton];
	[communityButton release];
	//TODO: 테스트 끝나면 주석 제거. 친구일경우에만 버튼 활성화
	if(self.isBuddy)
		self.msgButton.enabled = YES;
	else
		self.msgButton.enabled = NO;
	
	[self addSubview:thumbnail];
	[thumbnail release];
	
	
	
	
	UIImage* smsNormalImg = [[UIImage imageNamed:@"btn_sms_dim.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];	// sochae 2010.09.08 - (png) miss
	//UIImage* smsClickedImg = [[UIImage imageNamed:@"btn_sms_dim.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	//		UIImage* smsClickdim = [[UIImage imageNamed:@"btn_sms_dim.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	UIButton* smsSendButton = [[UIButton alloc] initWithFrame:CGRectZero];
	
	
	
	
	
	[smsSendButton setImage:smsNormalImg forState:UIControlStateDisabled];
		[smsSendButton setEnabled:NO];
		

		//[smsSendButton setImage:smsClickedImg forState:UIControlStateHighlighted];
	//[smsSendButton addTarget:self.parentDelegate action:@selector(buddySMSButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	//		[smsSendButton setImage:smsClickdim forState:UIControlStateSelected];
	self.smsButton = smsSendButton;
	[self addSubview:smsSendButton];
	[smsSendButton release];		
	
	UIImage* callNormalImg = [[UIImage imageNamed:@"btn_tel.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	UIImage* callClickedImg = [[UIImage imageNamed:@"btn_tel_focus.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	UIImage* callClickdim = [[UIImage imageNamed:@"btn_tel_dim.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	UIButton* callSendButton = [[UIButton alloc] initWithFrame:CGRectZero];
	[callSendButton addTarget:self.parentDelegate action:@selector(buddyCallButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[callSendButton setImage:callNormalImg forState:UIControlStateNormal];
	[callSendButton setImage:callClickedImg forState:UIControlStateHighlighted];
			[callSendButton setImage:callClickdim forState:UIControlStateDisabled];
	self.callButton = callSendButton;
	[self addSubview:callSendButton];
		
		[callSendButton setEnabled:NO];
	[callSendButton release];
		
		NSLog(@"======================END=========================");
	
		return self;
	}
	
	return self;
	
}



- (id)initFrame:(CGRect)frame falg:(int)number {
	self = [super initWithFrame:frame];
	if(self != nil) {
		
//		UIImage* bgImage = [[UIImage imageNamed:@"bg_addresscell.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
//		UIImageView* bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 57, 55)];
//		bgView.image = bgImage;
//		self.backgroundView = bgView;
//		[self  addSubview:bgView];
//		[bgView release];
		
		UIImageView* thumbnail = [[UIImageView alloc] initWithFrame:CGRectZero];
//		[self.photoView.layer setBorderColor:[UIColor colorWithWhite:0 alpha:0.5].CGColor];
//		[self.photoView.layer setBorderWidth:1.0];
		thumbnail.layer.masksToBounds = YES;
		[thumbnail.layer setCornerRadius:5.0];
		[thumbnail setClipsToBounds:YES];
		[thumbnail setImage:[UIImage imageNamed:@"img_default.png"]];
		self.photoView = thumbnail;
		
		
		UIImage* msgNormalImg = [[UIImage imageNamed:@"btn_say.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
		UIImage* msgClickedImg = [[UIImage imageNamed:@"btn_say_focus.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
		UIImage* msgClickdim = [[UIImage imageNamed:@"btn_say_dim.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
		
		
		
		
		UIButton* communityButton = [[UIButton alloc] initWithFrame:CGRectZero];
		[communityButton addTarget:self.parentDelegate action:@selector(buddySayButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
		[communityButton setImage:msgNormalImg forState:UIControlStateNormal];
		[communityButton setImage:msgClickedImg forState:UIControlStateHighlighted];
		[communityButton setImage:msgClickdim forState:UIControlStateDisabled];
		self.msgButton = communityButton;
		[self addSubview:communityButton];
		[communityButton release];
		//TODO: 테스트 끝나면 주석 제거. 친구일경우에만 버튼 활성화
		if(self.isBuddy)
			self.msgButton.enabled = YES;
		else
			self.msgButton.enabled = NO;
		
		[self addSubview:thumbnail];
		[thumbnail release];
		
		
		USayAppAppDelegate *parentView = (USayAppAppDelegate*)[[UIApplication sharedApplication] delegate];
			
	//	NSLog(@"fdsaf = %@", [parentView.rootController.viewControllers objectAtIndex:0]);
		
		UINavigationController *tmp = [parentView.rootController.viewControllers objectAtIndex:0];
		
	//	NSLog(@"abba= %@", [tmp.viewControllers objectAtIndex:0]) ;
		
		
		AddressViewController *tmpAdd = (AddressViewController*)[tmp.viewControllers objectAtIndex:0];
		[tmpAdd buddySMSButtonCheck];
		
	//	[parentView buddySMSButtonCheck];
		
		
		//AddressViewController *tmpView = [parentView.window.subviews]
	//	[tmpView buddySMSButtonCheck];
		
		
		
		

		UIImage* smsNormalImg = [[UIImage imageNamed:@"btn_sms.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
		UIImage* smsClickedImg = [[UIImage imageNamed:@"btn_sms_focus.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
		UIImage* smsClickdim = [[UIImage imageNamed:@"btn_sms_dim.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
		UIButton* smsSendButton = [[UIButton alloc] initWithFrame:CGRectZero];
		
		
		
		
		
		[smsSendButton setImage:smsNormalImg forState:UIControlStateNormal];
		[smsSendButton setImage:smsClickedImg forState:UIControlStateHighlighted];
		[smsSendButton addTarget:self.parentDelegate action:@selector(buddySMSButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
		[smsSendButton setImage:smsClickdim forState:UIControlStateDisabled];
		self.smsButton = smsSendButton;
		[self addSubview:smsSendButton];
		
		
		
		if(number ==3)
		{
			[smsSendButton setEnabled:NO];
		}
		
		
		
		[smsSendButton release];		
		
		UIImage* callNormalImg = [[UIImage imageNamed:@"btn_tel.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
		UIImage* callClickedImg = [[UIImage imageNamed:@"btn_tel_focus.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
		UIImage* callClickdim = [[UIImage imageNamed:@"btn_tel_dim.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];

		
		
		
		
		
		
		//		UIImage* callClickdim = [[UIImage imageNamed:@"btn_tel_dim.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
		UIButton* callSendButton = [[UIButton alloc] initWithFrame:CGRectZero];
		
		
		
		
		[callSendButton addTarget:self.parentDelegate action:@selector(buddyCallButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
		[callSendButton setImage:callNormalImg forState:UIControlStateNormal];
		[callSendButton setImage:callClickedImg forState:UIControlStateHighlighted];
		[callSendButton setImage:callClickdim forState:UIControlStateDisabled];
		self.callButton = callSendButton;
		[self addSubview:callSendButton];
		[callSendButton release];
		
	}
	return self;
}

-(void)layoutSubviews 
{
	CGRect contentRect = [self bounds];
	self.backgroundView.frame = contentRect;
	self.photoView.frame = CGRectMake(10.0, 8.0, 41.0, 41.0);
	self.msgButton.frame = CGRectMake(0.0, 0.0, 139.0, 58.0);
	self.smsButton.frame = CGRectMake(139, 0.0, 91.0, 58.0);
	self.callButton.frame = CGRectMake(230, 0.0, 90.0, 58.0);
	if(self.isBuddy)
		self.msgButton.enabled = YES;
	else
		self.msgButton.enabled = NO;
	
	[super layoutSubviews];
}

-(UIImageView*)getPhotoView
{
	return self.photoView;
}

-(void)dealloc {
	if(photoView)[photoView release];
	if(msgButton)[msgButton release];
	if(smsButton)[smsButton release];
	if(callButton)[callButton release];
//	if(backgroundView)[backgroundView release];
//	if(parentDelegate)[parentDelegate release];
	[super dealloc];
}

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
			pt = [touch locationInView:self.selfCell.contentView];
			touchBeganX = pt.x;
			touchBeganY = pt.y;
			
			
		//	NSLog(@"touch = %f %f", touchBeganX, touchBeganY);
			if(touchBeganX >= 0.0 && touchBeganX <= 49.0+30 && touchBeganY >=0.0 && touchBeganY <=59.0){
				[self.selfCell selectedImageView];
			}
			else {
				[super touchesBegan:touches withEvent:event];
			}

		}else {
			[super touchesBegan:touches withEvent:event];
		}

	}else{
		[super touchesBegan:touches withEvent:event];
	}
	
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint pt;
	NSSet *allTouches = [event allTouches];
	if ([allTouches count] == 1)
	{
		UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
		if ([touch tapCount] == 1)
		{
			pt = [touch locationInView:self.selfCell.contentView];
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
//		if(touchBeganX >= 10.0 && touchBeganX <= 51.0 && touchBeganY >=8.0 && touchBeganY <=49.0){
//			if((touchMovedX + touchBeganX) <= 51 && (touchMovedY+touchMovedY) <= 49){
//	//			self.selfCell.checked = YES;
//				[self.selfCell selectedImageView];
//			}
//		}else {
//	//		self.selfCell.checked = NO;
//		}
	}
	
	[super touchesEnded:touches withEvent:event];
}


@end
