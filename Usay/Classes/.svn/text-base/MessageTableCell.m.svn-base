//
//  MessageTableCell.m
//  USayApp
//
//  Created by 1team on 10. 6. 23..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "MessageTableCell.h"
#import <QuartzCore/QuartzCore.h>
//#import "MyDeviceClass.h"			// sochae 2010.09.11 - UI Position

#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
										green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
										blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation MessageTableCell

@synthesize photoImageView;
@synthesize photoImage;
@synthesize nickNameLabel;
@synthesize lastMsgLabel;
@synthesize lastDateLabel;
@synthesize totalCountLabel;
@synthesize newMsgCountImageView;

-(id)init 
{
	self = [super init];
	if (self != nil) {
		photoImageView = nil;
		nickNameLabel = nil;
		lastMsgLabel = nil;
		totalCountLabel = nil;
		lastDateLabel = nil;
		newMsgCountImageView = nil;
	}
	return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code

		photoImageView = [[UIImageView alloc]initWithFrame: CGRectMake(10.0, 8.0, 41.0, 41.0)];
		[self.contentView addSubview:photoImageView];
		photoImageView.layer.masksToBounds = YES;
		photoImageView.layer.cornerRadius = 5.0;

		nickNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(62.0, 9.0, 140.0, 20.0)];
		[self.contentView addSubview:nickNameLabel];
		nickNameLabel.backgroundColor = [UIColor clearColor];
		nickNameLabel.opaque = NO;
		nickNameLabel.textColor = ColorFromRGB(0x23232a);
		nickNameLabel.font = [UIFont boldSystemFontOfSize:18.0];
		
		lastMsgLabel = [[UILabel alloc]initWithFrame:CGRectMake(62.0, 32.0, 190.0, 15.0)];
		[self.contentView addSubview:lastMsgLabel];
		lastMsgLabel.backgroundColor = [UIColor clearColor];
		lastMsgLabel.opaque = NO;
		lastMsgLabel.textColor = ColorFromRGB(0x939b9f);
		lastMsgLabel.font = [UIFont boldSystemFontOfSize:12.0];
		
		totalCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(204, 10.0, 40, 13.0)];
		[self.contentView addSubview:totalCountLabel];
		totalCountLabel.backgroundColor = [UIColor clearColor];
		totalCountLabel.textAlignment = UITextAlignmentRight;
		totalCountLabel.opaque = NO;
		totalCountLabel.textColor = ColorFromRGB(0x23232a);
		totalCountLabel.font = [UIFont systemFontOfSize:13.0];
				
		UIView *customAccessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 64, 37)];
		[customAccessoryView setBackgroundColor:[UIColor clearColor]];
		
		lastDateLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 64, 13.0)];
		[customAccessoryView addSubview:lastDateLabel];
		lastDateLabel.backgroundColor = [UIColor clearColor];
		lastDateLabel.textAlignment = UITextAlignmentRight;
		lastDateLabel.opaque = NO;
		lastDateLabel.textColor = ColorFromRGB(0xbcbfc4);
		lastDateLabel.font = [UIFont systemFontOfSize:13.0];
		
		// 간격 맞추기 위해서 넣음.
		UILabel *blankLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 11, 64, 8.0)];
		[customAccessoryView addSubview:blankLabel];
		blankLabel.backgroundColor = [UIColor clearColor];
		blankLabel.textAlignment = UITextAlignmentRight;
		blankLabel.opaque = NO;
		blankLabel.textColor = ColorFromRGB(0xbcbfc4);
		blankLabel.font = [UIFont systemFontOfSize:13.0];
		[blankLabel release];
		
		newMsgCountImageView = [[UIImageView alloc]initWithFrame: CGRectMake(27, 20.0, 27.0, 16.0)];
		[customAccessoryView addSubview:newMsgCountImageView];
		newMsgCountImageView.image = [[UIImage imageNamed:@"img_newMsgCount.png"] stretchableImageWithLeftCapWidth:8 topCapHeight:0];
		newMsgCountImageView.hidden = YES;
		
		self.accessoryView = customAccessoryView;
		self.accessoryView.backgroundColor = [UIColor clearColor];
		[customAccessoryView release];
		
		UILabel *newCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 1, 1)];
		newCountLabel.backgroundColor = [UIColor clearColor];
		newCountLabel.textAlignment = UITextAlignmentRight;
		newCountLabel.opaque = NO;
		newCountLabel.textColor = [UIColor whiteColor];
		newCountLabel.font = [UIFont boldSystemFontOfSize:12.0];
		[newMsgCountImageView addSubview:newCountLabel];
		[newCountLabel release];
		
		[self setNewMsgCount:0];
		photoImage = nil;
	}
    return self;
}

-(void)layoutSubviews 
{
	// sochae 2010.09.11 - UI Position
	//CGRect rect = [MyDeviceClass deviceOrientation];
	CGRect rect = [[UIScreen mainScreen] applicationFrame];
	// ~sochae
	
	if (nickNameLabel && nickNameLabel.text && [nickNameLabel.text length] > 0 ) {
		nickNameLabel.hidden = NO;
	} else {
		nickNameLabel.hidden = YES;
	}
	if (totalCountLabel && totalCountLabel.text && [totalCountLabel.text length] > 0 ) {
		totalCountLabel.hidden = NO;
		CGRect nickNameLabelFrame = nickNameLabel.frame;
		if (rect.size.width < rect.size.height) {	// 세로보기
			nickNameLabelFrame.size.width = rect.size.width - 180;	// 320 => 140
			nickNameLabel.frame = nickNameLabelFrame;
		} else {
			nickNameLabelFrame.size.width = rect.size.width - 180;	// 320 => 140
			nickNameLabel.frame = nickNameLabelFrame;
		}
		
		CGRect totalCountLabelFrame = totalCountLabel.frame;
		totalCountLabelFrame.origin.x =	rect.size.width - 116;		// 320 => 204
		totalCountLabel.frame = totalCountLabelFrame;
	} else {
		totalCountLabel.hidden = YES;
		CGRect nickNameLabelFrame = nickNameLabel.frame;
		if (rect.size.width < rect.size.height) {	// 세로보기
			nickNameLabelFrame.size.width = rect.size.width - 140;	// 320 => 180
			nickNameLabel.frame = nickNameLabelFrame;
		} else {
			nickNameLabelFrame.size.width = rect.size.width - 140;	// 320 => 180
			nickNameLabel.frame = nickNameLabelFrame;
		}
		CGRect totalCountLabelFrame = totalCountLabel.frame;
		totalCountLabelFrame.origin.x =	rect.size.width - 116;		// 320 => 204
		totalCountLabel.frame = totalCountLabelFrame;
	}
	if (lastMsgLabel && lastMsgLabel.text && [lastMsgLabel.text length] > 0 ) {
		lastMsgLabel.hidden = NO;
	} else {
		lastMsgLabel.hidden = YES;
	}
	CGRect lastMsgLabelFrame = lastMsgLabel.frame;
	if (rect.size.width < rect.size.height) {	// 세로보기
		lastMsgLabelFrame.size.width = rect.size.width - 130;	// 320 => 190
		lastMsgLabel.frame = lastMsgLabelFrame;
	} else {
		lastMsgLabelFrame.size.width = rect.size.width - 130;	// 320 => 190
		lastMsgLabel.frame = lastMsgLabelFrame;
	}
	
	if (lastDateLabel && lastDateLabel.text && [lastDateLabel.text length] > 0 ) {
		lastDateLabel.hidden = NO;
	} else {
		lastDateLabel.hidden = YES;
	}
		
	if ([self newMsgCount] > 0) {
		UIFont *newCountFont = [UIFont boldSystemFontOfSize:12];
		CGSize newCountStringSize = [[NSString stringWithFormat:@"%i", [self newMsgCount]] sizeWithFont:newCountFont constrainedToSize:(CGSizeMake(27.0f, 16.0f))];
		self.newMsgCountImageView.frame = CGRectMake(self.accessoryView.frame.size.width-16-newCountStringSize.width, 20, 16+newCountStringSize.width, 16);
		for (UIView *view in self.newMsgCountImageView.subviews) {
			if ( [view isKindOfClass:[UILabel class]] ) {
				[((UILabel*)view) setText:[NSString stringWithFormat:@"%i", [self newMsgCount]]];
				((UILabel*)view).frame = CGRectMake((self.newMsgCountImageView.frame.size.width - newCountStringSize.width)/2, 0, newCountStringSize.width, newCountStringSize.height);
				break;
			}
		}
		self.newMsgCountImageView.hidden = NO;	
	} else {
		self.newMsgCountImageView.hidden = YES;
	}

	[super layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setNewMsgCount:(NSInteger)count
{
	newMsgCount = count;
}

-(NSInteger)newMsgCount;
{
	return newMsgCount;
}

- (void)dealloc {

	if (self.photoImageView != nil) {
		[self.photoImageView release];
		photoImageView = nil;
	}

	if (self.nickNameLabel != nil) {
		[self.nickNameLabel release];
		nickNameLabel = nil;
	}
	if (self.lastMsgLabel != nil) {
		[self.lastMsgLabel release];
		lastMsgLabel = nil;
	}
	if (self.lastDateLabel != nil) {
		[self.lastDateLabel release];
		lastDateLabel = nil;
	}
	if (self.totalCountLabel != nil) {
		[self.totalCountLabel release];
		totalCountLabel = nil;
	}
	if (self.newMsgCountImageView != nil) {
		[self.newMsgCountImageView release];
		newMsgCountImageView = nil;
	}

    [super dealloc];
}


@end
