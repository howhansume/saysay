    //
//  EditAddressCustomCell.m
//  USayApp
//
//  Created by Jong-Sung Park on 10. 6. 21..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "EditAddressCustomCell.h"
#import <QuartzCore/QuartzCore.h>

#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
@implementation EditAddressCustomCell

@synthesize radioView, photoView, statusView, titleLabel, subTitleLabel, checked;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if(self != nil){
		
		self.radioView = [[UIImageView alloc] initWithFrame:CGRectZero];
		self.radioView.backgroundColor = [UIColor clearColor];
		self.radioView.image = [UIImage imageNamed:@"btn_unchecked.png"];
		[self.contentView addSubview:self.radioView];
		
		self.photoView = [[UIImageView alloc] initWithFrame:CGRectZero];
//		[self.photoView.layer setBorderColor:[UIColor colorWithWhite:0 alpha:1.0].CGColor];
//		[self.photoView.layer setBorderWidth:0.5];
		[self.photoView.layer setCornerRadius:5.0];
		[self.photoView setClipsToBounds:YES];
		[self.photoView setImage:[UIImage imageNamed:@"img_default.png"]];
		[self.contentView addSubview:self.photoView];
		
		self.statusView = [[UIImageView alloc] initWithFrame:CGRectZero];
		self.statusView.backgroundColor = [UIColor clearColor];
		self.statusView.image = [UIImage imageNamed:@"state_off.png"];
		[self.contentView addSubview:self.statusView];
		
		self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		self.titleLabel.backgroundColor = [UIColor clearColor];
	//	self.titleLabel.text = @"titleLable";
		self.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
		self.titleLabel.textColor = ColorFromRGB(0x23232a);
		[self.contentView addSubview:self.titleLabel];
		
		self.subTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		self.subTitleLabel.backgroundColor = [UIColor clearColor];
	//	self.subTitleLabel.text = @"subTitleLabel";
		self.subTitleLabel.font = [UIFont systemFontOfSize:12.0];
		self.subTitleLabel.textColor = ColorFromRGB(0x3181a8);
		[self.contentView addSubview:self.subTitleLabel];
		
	}
	return self;
}

- (void)layoutSubviews {
//	[UIView beginAnimations:nil context:nil];
//	[UIView setAnimationBeginsFromCurrentState:YES];
	[super layoutSubviews];
	
	CGRect contentRect = [self.contentView bounds];
	
	self.radioView.frame = CGRectMake(8.0, 16.0, 29.0, 29.0);
	self.photoView.frame = CGRectMake(self.radioView.frame.origin.x + self.radioView.frame.size.width + 5.0, 
									  (contentRect.size.height-41.0)/2, 
								 41.0, 41.0);
	self.statusView.frame = CGRectMake(self.photoView.frame.origin.x + self.photoView.frame.size.width + 7.0, 
								  (contentRect.size.height-26.0)/2, 26.0, 26.0);
	
	if([self.subTitleLabel.text length] > 0){
		self.titleLabel.frame = CGRectMake(self.statusView.frame.origin.x + self.statusView.frame.size.width + 8.0, 11.0, 160.0, 18.0);
		self.subTitleLabel.frame = CGRectMake(self.statusView.frame.origin.x + self.statusView.frame.size.width + 8.0, 35.0, 160.0, 12.0);
	}else {
		self.titleLabel.frame = CGRectMake(self.statusView.frame.origin.x + self.statusView.frame.size.width + 8.0, 18.0, 160.0, 18.0);
		self.subTitleLabel.frame = CGRectZero;
	}
	UIImage *checkImage = (self.checked) ? [UIImage imageNamed:@"btn_checked.png"] : [UIImage imageNamed:@"btn_unchecked.png"];
	UIImage *newImage = [checkImage stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	[self.radioView setImage:newImage];
	
//	[UIView commitAnimations];
}
// called when the checkmark button is touched 
- (void)checkAction:(id)sender
{
	// note: we don't use 'sender' because this action method can be called separate from the button (i.e. from table selection)
	self.checked = !self.checked;
//	UIImage *checkImage = (self.checked) ? [UIImage imageNamed:@"btn_checked.png"] : [UIImage imageNamed:@"btn_unchecked.png"];
//	[self.radioView setImage:checkImage];
	[self setNeedsLayout];
}


- (void)dealloc {
	[radioView release];
	[photoView release];
	[statusView release];
	[titleLabel release];
	[subTitleLabel release];
    [super dealloc];
}


@end
