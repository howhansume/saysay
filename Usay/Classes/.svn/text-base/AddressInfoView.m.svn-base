//
//  AddressInfoView.m
//  USayApp
//
//  Created by Jong-Sung Park on 10. 6. 29..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "AddressInfoView.h"
#import <QuartzCore/QuartzCore.h>
#import "ApplicationCell.h"

#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation AddressInfoView

@synthesize photoView, statusView, titleLabel, subTitleLabel, parentDelegate, selfCell;

-(id)initWithFrame:(CGRect)frame {
	self =[super initWithFrame:frame];
	if(self != nil) {
		UIImageView* photoImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
		photoImageView.layer.masksToBounds = YES;
		[photoImageView.layer setCornerRadius:5.0];
		[photoImageView setClipsToBounds:YES];
		[photoImageView setImage:[UIImage imageNamed:@"img_default.png"]];
		self.photoView = photoImageView;
		[self addSubview:photoImageView];
		[photoImageView release];
//		[self.photoView.layer setBorderColor:[UIColor colorWithWhite:0 alpha:0.5].CGColor];
//		[self.photoView.layer setBorderWidth:1.0];
				
		UIImageView* statusImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
		self.statusView = statusImageView;
		[statusImageView release];
		self.statusView.backgroundColor = [UIColor clearColor];
		self.statusView.image = [UIImage imageNamed:@"state_off.png"];
		[self addSubview:self.statusView];
		
		UILabel* titleTextLbl = [[UILabel alloc] initWithFrame:CGRectZero];
		self.titleLabel = titleTextLbl;
		[titleTextLbl release];
		self.titleLabel.backgroundColor = [UIColor clearColor];
	//	self.titleLabel.text = @"이름이나 별명이 없습니다.";
		self.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
		self.titleLabel.textColor = ColorFromRGB(0x23232a);
		[self addSubview:self.titleLabel];
		
		UILabel* subLable = [[UILabel alloc] initWithFrame:CGRectZero];
		self.subTitleLabel = subLable;
		[subLable release];
		self.subTitleLabel.backgroundColor = [UIColor clearColor];
	//	self.subTitleLabel.text = @"오늘의 한마디를 적어 주세요.";
		self.subTitleLabel.font = [UIFont systemFontOfSize:12.0];
		self.subTitleLabel.textColor = ColorFromRGB(0x939b9f);
		[self addSubview:self.subTitleLabel];
		
	}
	return self;
}

- (void)layoutSubviews {
	
	
//	CGRect contentRect = [self bounds];
	self.photoView.frame = CGRectMake(10.0, 8.0, 41.0, 41.0);
	self.statusView.frame = CGRectMake(10.0 + 41.0 + 9.0, 16.0, 26.0, 26.0);
	
	if (self.subTitleLabel != nil && [self.subTitleLabel.text length] > 0) {
		[titleLabel setFrame:CGRectMake(10.0 + 41.0 + 9.0 + 26.0 + 7.0, 11.0, 190.0, 18.0)];
		[subTitleLabel setFrame:CGRectMake(10.0 + 41.0 + 9.0 + 26.0 + 7.0+2.0, 35.0, 190.0, 12.0)]; 
	} else {
		[titleLabel setFrame:CGRectMake(10.0 + 41.0 + 9.0 + 26.0 + 7.0, 18.0, 190.0, 18.0)];
		[subTitleLabel setFrame:CGRectZero];
	}
	
	self.backgroundColor = [UIColor clearColor];
	[super layoutSubviews];
}

-(UIImageView*)getPhotoView
{
	return self.photoView;
}

- (void)dealloc {
	if(photoView)[photoView release];
	if(statusView)[statusView release];
	if(titleLabel)[titleLabel release];
	if(subTitleLabel)[subTitleLabel release];
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
			
			NSLog(@"touch =%f %f", touchBeganX, touchBeganY);
			
			if(touchBeganX >= 0.0 && touchBeganX <= 49+30.0 && touchBeganY >=0.0 && touchBeganY <=59.0){
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
//				self.selfCell.checked = YES;
//				[self.selfCell selectedImageView];
//			}
//		}else {
//			self.selfCell.checked = NO;
//		}		
	}
	
	[super touchesEnded:touches withEvent:event];
}

@end
