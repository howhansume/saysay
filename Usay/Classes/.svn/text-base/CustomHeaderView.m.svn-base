//
//  CustomHeaderView.m
//  USayApp
//
//  Created by Jong-Sung Park on 10. 6. 7..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "CustomHeaderView.h"
//#import <QuartzCore/QuartzCore.h>

#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define ColorFromRGBAlpha(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:0.7]

@implementation CustomHeaderView

@synthesize groupFold, groupEdit, groupName, section, folded,  groupID; //isSearch,

-(id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if(self != nil){
//		[self.layer setBorderWidth:0.2];
//        [self.layer setCornerRadius:1.0];
//        [self.layer setBorderColor:[[UIColor colorWithWhite:0.3 alpha:0.7] CGColor]];

//		self.backgroundColor = ColorFromRGBAlpha(0xaadbff);
		UIImage* strechImage = [[UIImage imageNamed:@"img_invitemsgsection.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
//		UIImageView* backgroundImageView = [[UIImageView alloc] initWithFrame:frame];
//		backgroundImageView.image = strechImage;
//		[self addSubview:backgroundImageView];
//		[backgroundImageView release];
//		[self setBackgroundImage:[UIImage imageNamed:@"bg_address_header.png"] forState:UIControlStateNormal];
//		[self setImage:[UIImage imageNamed:@"bg_address_header.png"] forState:UIControlStateHighlighted];
		
		[self setBackgroundImage:strechImage forState:UIControlStateNormal];
		[self setBackgroundImage:strechImage forState:UIControlStateHighlighted];
		
//		[self contentRectForBounds:self.bounds];
		groupFold = [[UIImageView alloc] initWithFrame:CGRectMake(11.0, 15.0, 13.0, 13.0)];
		groupFold.backgroundColor = [UIColor clearColor];
		[self addSubview:groupFold];
		
		groupName = [[UILabel alloc]initWithFrame:CGRectMake(24.0, 13.0, 200.0, 15.0)];
		groupName.textColor = ColorFromRGB(0x313736);
		groupName.font = [UIFont boldSystemFontOfSize:13.0];
		groupName.backgroundColor = [UIColor clearColor];
		[self addSubview:groupName];
		
		groupEdit = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-80.0, 5.0, 72.0, 28.0)];
		groupEdit.backgroundColor = [UIColor clearColor]; 
		[self addSubview:groupEdit];
		
	}
	return self;
}

-(void)setSection:(NSInteger)newSection {
	section = newSection;
}

-(void)dealloc{
	if(groupFold)[groupFold release];
	if(groupEdit)[groupEdit release]; 
	if(groupName)[groupName release];
	if(groupID)[groupID release];
	[super dealloc];
}
@end
