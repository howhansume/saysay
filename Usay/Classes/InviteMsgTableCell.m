//
//  InviteMsgTableCell.m
//  USayApp
//
//  Created by 1team on 10. 7. 8..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "InviteMsgTableCell.h"
#import <QuartzCore/QuartzCore.h>

#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation InviteMsgTableCell

@synthesize radioImageView;
@synthesize photoImageView;
@synthesize statusImageView;
@synthesize nameTitleLabel;
@synthesize phonenumber;
@synthesize subTitleLabel;
@synthesize imstatus;
@synthesize checked;
@synthesize isDisabled;
@synthesize recid;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
		
		radioImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
		radioImageView.backgroundColor = [UIColor clearColor];
		radioImageView.image = [UIImage imageNamed:@"img_unchecked_green.png"];
		radioImageView.frame = CGRectMake(self.contentView.frame.origin.x+7.0, (self.contentView.frame.size.height-29.0)/2+2, 25.0, 25.0);
		[self.contentView addSubview:radioImageView];
		
		photoImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
		photoImageView.layer.masksToBounds = YES;
		photoImageView.layer.cornerRadius = 5.0;
		//		[self.photoImageView.layer setBorderColor:[UIColor colorWithWhite:0 alpha:0.5].CGColor];
		//		[self.photoImageView.layer setBorderWidth:1.0];
		photoImageView.backgroundColor = [UIColor clearColor];
		[photoImageView setImage:[UIImage imageNamed:@"img_default.png"]];
		[self.contentView addSubview:photoImageView];
		
		statusImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
		statusImageView.backgroundColor = [UIColor clearColor];
		statusImageView.image = [UIImage imageNamed:@"state_off.png"];
		[self.contentView addSubview:statusImageView];
		
		nameTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		nameTitleLabel.backgroundColor = [UIColor clearColor];
		nameTitleLabel.font = [UIFont boldSystemFontOfSize:18.0];
		nameTitleLabel.textColor = ColorFromRGB(0x23232a);
		[self.contentView addSubview:nameTitleLabel];
		
		subTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		subTitleLabel.backgroundColor = [UIColor clearColor];
		subTitleLabel.font = [UIFont systemFontOfSize:12.0];
		subTitleLabel.textColor = ColorFromRGB(0x939b9f);
		[self.contentView addSubview:subTitleLabel];
		
		imstatus = @"-1";
		isDisabled = NO;
		
    }
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGRect contentRect = [self.contentView bounds];
	
	if (isDisabled) {	// 자기 자신
		[self.contentView setBackgroundColor:ColorFromRGB(0xCFD1D2)];
	} else {	
		if (self.checked) {
			[self.contentView setBackgroundColor:[UIColor whiteColor]];	// [self.contentView setBackgroundColor:ColorFromRGB(0xECF7FF)];
		} else {
			[self.contentView setBackgroundColor:[UIColor whiteColor]];
		}
	}
	
	self.radioImageView.frame = CGRectMake(contentRect.origin.x+7.0, (contentRect.size.height-29.0)/2+2, 25.0, 25.0);
	self.photoImageView.frame = CGRectMake(self.radioImageView.frame.origin.x + self.radioImageView.frame.size.width + 7.0, 
										   (contentRect.size.height-41.0)/2, 
										   41.0, 41.0);
	self.statusImageView.frame = CGRectMake(self.photoImageView.frame.origin.x + self.photoImageView.frame.size.width + 9.0, 
											(contentRect.size.height-26.0)/2, 
											26.0, 26.0);
	
	// -1:주소록 타입  0:offline  1:online  2:busy (바빠요)  8:곧 돌아옵니다.  16:다른용무중
	
	
	
	
	
	
	if ([imstatus isEqualToString:@"-1"]) {
		self.statusImageView.image = [UIImage imageNamed:@"state_public.png"];
	} else if ([imstatus isEqualToString:@"0"]) {
		self.statusImageView.image = [UIImage imageNamed:@"state_off.png"];
	} else if ([imstatus isEqualToString:@"1"]) {
		self.statusImageView.image = [UIImage imageNamed:@"state_on.png"];
	} else if ([imstatus isEqualToString:@"2"]) {
		self.statusImageView.image = [UIImage imageNamed:@"state_busy.png"];
	} else if ([imstatus isEqualToString:@"8"]) {
		self.statusImageView.image = [UIImage imageNamed:@"state_time.png"];
	} else if ([imstatus isEqualToString:@"16"]) {
		self.statusImageView.image = [UIImage imageNamed:@"state_do.png"];
	} else {
		// skip
		self.statusImageView.image = [UIImage imageNamed:@"state_public.png"];
	}
	
	if (self.subTitleLabel.text != nil && [self.subTitleLabel.text length] > 0) {
		self.nameTitleLabel.frame = CGRectMake(self.statusImageView.frame.origin.x + self.statusImageView.frame.size.width + 9.0, 10.0, 180.0, 20.0);
		self.subTitleLabel.frame = CGRectMake(self.statusImageView.frame.origin.x + self.statusImageView.frame.size.width + 9.0, 32.0, 180.0, 15.0);
		self.subTitleLabel.hidden = NO;
	} else {
		self.nameTitleLabel.frame = CGRectMake(self.statusImageView.frame.origin.x + self.statusImageView.frame.size.width + 9.0, 19.0, 180.0, 20.0);
		self.subTitleLabel.frame = CGRectMake(self.statusImageView.frame.origin.x + self.statusImageView.frame.size.width + 9.0, 32.0, 180.0, 15.0);
		self.subTitleLabel.hidden = YES;
	}
	if (self.checked == YES) {
		NSLog(@"CHECKED == YES");
		[self.radioImageView setImage:[UIImage imageNamed:@"img_checked_green.png"]];
	} else {
		NSLog(@"CHECKED == NO");
		[self.radioImageView setImage:[UIImage imageNamed:@"img_unchecked_green.png"]];
	}
}

// called when the checkmark button is touched 
- (void)checkAction:(id)sender
{
	// note: we don't use 'sender' because this action method can be called separate from the button (i.e. from table selection)
	self.checked = !self.checked;
	UIImage *checkImage = (self.checked) ? [UIImage imageNamed:@"img_checked_green.png"] : [UIImage imageNamed:@"img_unchecked_green.png"];
	
	if (self.checked) {
		[self.contentView setBackgroundColor:[UIColor whiteColor]];	// [self.contentView setBackgroundColor:ColorFromRGB(0xECF7FF)];
	} else {
		[self.contentView setBackgroundColor:[UIColor whiteColor]];
	}
	
	[self.radioImageView setImage:checkImage];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
    [super setSelected:selected animated:animated];
	
    // Configure the view for the selected state
}

- (void)dealloc {
	if (radioImageView) {
		[radioImageView release];
	}
	if (photoImageView) {
		[photoImageView release];
		photoImageView = nil;
	}
	if (statusImageView) {
		[statusImageView release];
		statusImageView = nil;
	}
	if (nameTitleLabel) {
		[nameTitleLabel release];
		nameTitleLabel = nil;
	}
	if (subTitleLabel) {
		[subTitleLabel release];
		subTitleLabel = nil;
	}
	if (imstatus) {
		[imstatus release];
		imstatus = nil;
	}
    [super dealloc];
}

@end
