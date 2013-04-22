//
//  BlockUserTableCell.m
//  USayApp
//
//  Created by 1team on 10. 6. 22..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "BlockUserTableCell.h"
#import <QuartzCore/QuartzCore.h>
//#import "MyDeviceClass.h"		// sochae 2010.09.11 - UI Position

#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
												green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
												blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation BlockUserTableCell

@synthesize thumbnailImageView;
@synthesize nickNameLabel;
@synthesize statusLabel;
@synthesize clearButton;
@synthesize parentDelegate;
@synthesize pKey;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		thumbnailImageView = [[UIImageView alloc]initWithFrame: CGRectMake(10.0, 8.0, 41.0, 41.0)];
		[self.contentView addSubview:thumbnailImageView];
		thumbnailImageView.layer.masksToBounds = YES;
		thumbnailImageView.layer.cornerRadius = 5.0;
		
		nickNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(62.0, 9.0, self.frame.size.width - 58, 20.0)];
		[self.contentView addSubview:nickNameLabel];
		nickNameLabel.backgroundColor = [UIColor clearColor];
		nickNameLabel.opaque = NO;
		nickNameLabel.textColor = ColorFromRGB(0x23232a);
		nickNameLabel.highlightedTextColor = [UIColor whiteColor];
		nickNameLabel.font = [UIFont boldSystemFontOfSize:18.0];
		
		statusLabel = [[UILabel alloc]initWithFrame:CGRectMake(62.0, 33.0, 190.0, 15.0)];
		[self.contentView addSubview:statusLabel];
		statusLabel.backgroundColor = [UIColor clearColor];
		statusLabel.opaque = NO;
		statusLabel.textColor = ColorFromRGB(0x939b9f);
		statusLabel.font = [UIFont boldSystemFontOfSize:12.0];

		// sochae 2010.09.11 - UI Position
		//CGRect rect = [MyDeviceClass deviceOrientation];
		CGRect rect = [[UIScreen mainScreen] applicationFrame];
		// ~sochae
		
		clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[clearButton setImage:[UIImage imageNamed:@"btn_clear.png"] forState:UIControlStateNormal];
//		[clearButton setImage:[UIImage imageNamed:@"btn_clear_focus.png"] forState:UIControlStateHighlighted];
		clearButton.backgroundColor = [UIColor clearColor];
		[clearButton setFrame:CGRectMake(rect.size.width - 54.0, 12.0, 48.0, 33.0)];
		[self.contentView addSubview:clearButton];
		
		pKey = nil;
    }
	
    return self;
}

/*
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
//*/

-(void)layoutSubviews 
{
	thumbnailImageView.layer.masksToBounds = YES;
	thumbnailImageView.layer.cornerRadius = 5.0;
	thumbnailImageView.hidden = NO;

	if ([statusLabel.text length] == 0) {
		[nickNameLabel setFrame:CGRectMake(62.0, 16.0, 190.0, 25.0)]; 
		statusLabel.hidden = YES;
	} else {
		[nickNameLabel setFrame:CGRectMake(62.0, 9.0, 190.0, 23.0)]; 
		statusLabel.hidden = NO;
	}

	// sochae 2010.09.11 - UI Position
	//CGRect rect = [MyDeviceClass deviceOrientation];
	CGRect rect = [[UIScreen mainScreen] applicationFrame];
	// ~sochae
	
	clearButton.frame = CGRectMake(rect.size.width - 54.0, 12.0, 48.0, 33.0);

	[super layoutSubviews];
}

- (void)didTransitionToState:(UITableViewCellStateMask)state {
	if(state == UITableViewCellStateShowingDeleteConfirmationMask)
	{
//		CGRect clearbtnframe = CGRectMake(210.0, 9.0, 48.0, 33.0);
//		clearButton.frame = clearbtnframe;
	}
}

- (void)dealloc {
	if (self.pKey != nil) {
		[self.pKey release];
//		pKey = nil;
	}
	
	if(self.thumbnailImageView != nil)
		[self.thumbnailImageView release];
	if(self.nickNameLabel != nil)
		[self.nickNameLabel release];
	if(self.statusLabel != nil)
		[self.statusLabel release];
	if(self.parentDelegate != nil) //여기서 죽었다.. 왜지?
	//	[self.parentDelegate release];
 
    [super dealloc];
}


@end
