//
//  CustomCell.m
//  USayApp
//
//  Created by Jong-Sung Park on 10. 6. 11..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "CustomCell.h"
#import <QuartzCore/QuartzCore.h>
//#import "MyDeviceClass.h"			// sochae 2010.09.11 - UI Position

#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
										green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
										blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
@implementation CustomCell

@synthesize thumbnailImageView, nickNameLabel, statusLabel;
@synthesize delButton, addButton;
@synthesize parentDelegate, photoUrl;
@synthesize pKey;





-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch =[touches anyObject];
	CGPoint location =[touch locationInView:self];
	NSLog(@"cell = %@", self.thumbnailImageView.image);
	NSLog(@"location %f %f", location.x, location.y);
	NSLog(@"photourl = %@", photoUrl);
	
	[self.parentDelegate showImage:photoUrl];
	
	
	
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
/*
		UIImageView *_thumbnailImageView = [[UIImageView alloc]initWithFrame: CGRectMake(10.0, 8.0, 41.0, 41.0)];
		[self.contentView addSubview:_thumbnailImageView];
		_thumbnailImageView.layer.masksToBounds = YES;
		_thumbnailImageView.layer.cornerRadius = 5.0;
		thumbnailImageView = _thumbnailImageView;
		[_thumbnailImageView release];
//		[thumbnailImageView.layer setBorderColor:[UIColor colorWithWhite:0 alpha:0.5].CGColor];
//		[thumbnailImageView.layer setBorderWidth:1.0];
		
		UILabel *_nickNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(62.0, 9.0, 190.0, 20.0)];
		[self.contentView addSubview:_nickNameLabel];
		_nickNameLabel.backgroundColor = self.backgroundColor;
		_nickNameLabel.opaque = NO;
		_nickNameLabel.textColor = ColorFromRGB(0x23232a);
		_nickNameLabel.highlightedTextColor = [UIColor whiteColor];
		_nickNameLabel.font = [UIFont boldSystemFontOfSize:18.0];
		nickNameLabel = _nickNameLabel;
		[_nickNameLabel release];
		
		UILabel *_statusLabel = [[UILabel alloc]initWithFrame:CGRectMake(62.0, 33.0, 190.0, 15.0)];
		[self.contentView addSubview:_statusLabel];
		_statusLabel.backgroundColor = self.backgroundColor;
		_statusLabel.opaque = NO;
		_statusLabel.textColor = ColorFromRGB(0x939b9f);
		_statusLabel.highlightedTextColor = [UIColor whiteColor];
		_statusLabel.font = [UIFont boldSystemFontOfSize:12.0];
		statusLabel = _statusLabel;
		[_statusLabel release];
//*/
		thumbnailImageView = [[UIImageView alloc]initWithFrame: CGRectMake(10.0, 8.0, 41.0, 41.0)];
		[self.contentView addSubview:thumbnailImageView];
		thumbnailImageView.layer.masksToBounds = YES;
		thumbnailImageView.layer.cornerRadius = 5.0;
		//		[thumbnailImageView.layer setBorderColor:[UIColor colorWithWhite:0 alpha:0.5].CGColor];
		//		[thumbnailImageView.layer setBorderWidth:1.0];
		
		nickNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(62.0, 9.0, 190.0, 20.0)];
		[self.contentView addSubview:nickNameLabel];
		nickNameLabel.backgroundColor = self.backgroundColor;
		nickNameLabel.opaque = NO;
		nickNameLabel.textColor = ColorFromRGB(0x23232a);
		nickNameLabel.highlightedTextColor = [UIColor whiteColor];
		nickNameLabel.font = [UIFont boldSystemFontOfSize:18.0];
		
		statusLabel = [[UILabel alloc]initWithFrame:CGRectMake(62.0, 33.0, 190.0, 15.0)];
		[self.contentView addSubview:statusLabel];
		statusLabel.backgroundColor = self.backgroundColor;
		statusLabel.opaque = NO;
		statusLabel.textColor = ColorFromRGB(0x939b9f);
		statusLabel.highlightedTextColor = [UIColor whiteColor];
		statusLabel.font = [UIFont boldSystemFontOfSize:12.0];
		
//		UIView *customAccessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48.0, 33.0)];
//		assert(customAccessoryView != nil);
//		[customAccessoryView setBackgroundColor:[UIColor blueColor]];

		// sochae 2010.09.11 - UI Position
		//CGRect rect = [MyDeviceClass deviceOrientation];
		CGRect rect = [[UIScreen mainScreen] applicationFrame];
		// ~sochae
		
		addButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		[addButton addTarget:self.parentDelegate action:@selector(addAction:) forControlEvents:UIControlEventTouchUpInside];
		addButton.backgroundColor = self.backgroundColor;
		[addButton setImage:[UIImage imageNamed:@"btn_addfriend.png"] forState:UIControlStateNormal];
		[addButton setImage:[UIImage imageNamed:@"btn_addfriend_focus.png"] forState:UIControlStateHighlighted];
		[addButton setFrame:CGRectMake(rect.size.width - 54.0, 12.0, 48.0, 33.0)];
		[self.contentView addSubview:addButton];
//		[customAccessoryView addSubview:addButton];
//		self.accessoryView = customAccessoryView;
//		[customAccessoryView release];
		
		pKey = nil;
    }
    return self;
}

-(void)layoutSubviews 
{
//	CGRect contentRect = [self.contentView bounds];
	thumbnailImageView.layer.masksToBounds = YES;
	thumbnailImageView.layer.cornerRadius = 5.0;

	if ([statusLabel.text length] == 0) {
		[nickNameLabel setFrame:CGRectMake(62.0, 16.0, 190.0, 25.0)]; 
		statusLabel.hidden = YES;
	} else {
		[nickNameLabel setFrame:CGRectMake(62.0, 9.0, 190.0, 25.0)]; 
		statusLabel.hidden = NO;
	}

	// sochae 2010.09.11 - UI Position
	//CGRect rect = [MyDeviceClass deviceOrientation];
	CGRect rect = [[UIScreen mainScreen] applicationFrame];
	// ~sochae
	
	addButton.frame = CGRectMake(rect.size.width - 54.0, 12.0, 48.0, 33.0);
//	UIImage *aastretchableButtonImageNormal = [[UIImage imageNamed:@"btn_addfriend.png"] stretchableImageWithLeftCapWidth:12 topCapHeight:0];
//	[addButton setBackgroundImage:aastretchableButtonImageNormal forState:UIControlStateNormal];
//	[addButton setImage:aastretchableButtonImageNormal forState:UIControlStateNormal];
	[super layoutSubviews];
}

- (void)didTransitionToState:(UITableViewCellStateMask)state {

	if(state == UITableViewCellStateShowingDeleteConfirmationMask)
	{
	}
}

- (void)dealloc {
	NSLog(@"Propose CustomCell dealloc start");
	if (pKey) {
		[pKey release];
		pKey = nil;
	}
	if (thumbnailImageView) {
		[thumbnailImageView release];
	}
	if (nickNameLabel) {
		[nickNameLabel release];
	}
	if (statusLabel) {
		[statusLabel release];
	}
	NSLog(@"Propose CustomCell dealloc end");
    [super dealloc];
}


@end
