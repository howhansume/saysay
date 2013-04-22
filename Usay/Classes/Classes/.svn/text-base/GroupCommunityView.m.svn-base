    //
//  ModalViewController.m
//  USayApp
//
//  Created by Jong-Sung Park on 10. 7. 6..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "GroupCommunityView.h"
#import <QuartzCore/QuartzCore.h>

#define ColorFromRGBAlpha(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:0.5]
#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
@implementation GroupCommunityView
@synthesize childView, groupID, groupTtitleLabel,evnetDelegate;
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
-(id)initWithFrame:(CGRect)frame{
    self =[super initWithFrame:frame];
	if(self != nil){
		self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.5];
		self.opaque = NO;
		
		UIView* contentView = [[UIView alloc]initWithFrame:CGRectMake(0.0, self.frame.size.height-119.0, self.frame.size.width, 119.0)];
		
		UIImageView* groupCommunity = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rollup_box.png"]];
		[contentView addSubview:groupCommunity];
		[groupCommunity release];
		
		UILabel* titleLable = [[UILabel alloc] 
									initWithFrame:CGRectMake(7.0, 14.0, contentView.frame.size.width-60.0, 15.0)];
		titleLable.backgroundColor = [UIColor clearColor];
		titleLable.textAlignment = UITextAlignmentLeft;
		titleLable.textColor = ColorFromRGB(0x313736);
		titleLable.font = [UIFont boldSystemFontOfSize:13.0];
		groupTtitleLabel = titleLable;
		[contentView addSubview:titleLable];
		[titleLable release];
		
		UIImage* exitNormalImg = [[UIImage imageNamed:@"rollup_x_normal.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
		UIImage* exitClickedImg = [[UIImage imageNamed:@"rollup_x_focus.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
		UIButton* exitButton = [[UIButton alloc] 
								initWithFrame:CGRectMake(contentView.frame.size.width-31.0, 8.0, 23.0, 23.0)];
		[exitButton addTarget:self action:@selector(selfViewEnd) forControlEvents:UIControlEventTouchUpInside];
		[exitButton setImage:exitNormalImg forState:UIControlStateNormal];
		[exitButton setImage:exitClickedImg forState:UIControlStateSelected];
		[contentView addSubview:exitButton];
		[exitButton release];
	
//		UIImage* sayNormalImg = [[UIImage imageNamed:@"rollup_talk_touch.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
		UIImage* sayClickedImg = [[UIImage imageNamed:@"rollup_talk_touch.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
		UIButton* groupSayButton = [[UIButton alloc] 
							   initWithFrame:CGRectMake(7.0, 51.0, 153.0, 57.0)];
		[groupSayButton addTarget:self action:@selector(groupSayButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//		[groupSayButton setImage:sayNormalImg forState:UIControlStateNormal];
		[groupSayButton setImage:sayClickedImg forState:UIControlStateHighlighted];
		groupSayButton.backgroundColor = [UIColor clearColor];
		
//		UIImage* smsNormalImg = [[UIImage imageNamed:@"rollup_sms_touch.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
		UIImage* smsClickedImg = [[UIImage imageNamed:@"rollup_sms_touch.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
		UIButton* groupSMSButton = [[UIButton alloc] 
							   initWithFrame:CGRectMake(160.0, 51.0, 153.0, 57.0)];
		[groupSMSButton addTarget:self action:@selector(groupSMSButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//		[groupSMSButton setImage:smsNormalImg forState:UIControlStateNormal];
		[groupSMSButton setImage:smsClickedImg forState:UIControlStateHighlighted];
		groupSMSButton.backgroundColor = [UIColor clearColor];
		
		[contentView addSubview:groupSayButton];
		[groupSayButton release];
		[contentView addSubview:groupSMSButton];
		[groupSMSButton release];
				
		self.childView = contentView;
		[contentView release];
	}
	return self;
}

-(void)showInView:(UIView*)parentView {
	CATransition *animation = [CATransition animation];
	[animation setDuration:0.2];
	[animation setType:kCATransitionPush];
	animation.delegate = self;
	[animation setSubtype:kCATransitionFromTop];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	CATransition *childAnimation = [CATransition animation];
	[childAnimation setDuration:0.6];
	[childAnimation setType:kCATransitionPush];
	childAnimation.delegate = self;
	[childAnimation setSubtype:kCATransitionFromTop];
	[childAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	//TODO:add view
	[parentView addSubview:self];
	[self addSubview:childView];
	
	[self.layer addAnimation:animation forKey:@"groupSlideUpView"];	
	[childView.layer addAnimation:childAnimation forKey:@"groupSlideUpChildView"];
}

-(void)selfViewEnd {
	CATransition *animation = [CATransition animation];
	[animation setDuration:0.2];
	[animation setType:kCATransitionPush];
	animation.delegate = self;
	
	//TODO:removeView
	[self removeFromSuperview];
	
	[animation setSubtype:kCATransitionFromTop];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[self.layer addAnimation:animation forKey:@"groupSlideDownView"];	
	
}

-(void) groupSayButtonClicked:(id)sender {
	[self.evnetDelegate groupSayButtonClicked:self];
}

-(void) groupSMSButtonClicked:(id)sender {
	[self.evnetDelegate groupSMSButtonClicked:self];
}

- (void)dealloc {
	if(childView)[childView release];
	if(groupID)[groupID release];
	if(groupTtitleLabel)[groupTtitleLabel release];
	if(evnetDelegate)[evnetDelegate release];
    [super dealloc];
}


@end
