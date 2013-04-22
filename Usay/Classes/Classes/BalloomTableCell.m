//
//  BalloomTableCell.m
//  USayApp
//
//  Created by 1team on 10. 6. 17..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "BalloomTableCell.h"
#import <QuartzCore/QuartzCore.h>
//#import "MyDeviceClass.h"			// sochae 2010.09.11 - UI Position
#import "openImgViewController.h"

#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
										green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
										blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define SIZE_MEDIA_CX			90
#define SIZE_MEDIA_CY			90

@implementation BalloomTableCell

@synthesize photoImageView, photoUrl;
@synthesize contentsImageView;
//@synthesize contentsTextView;
@synthesize progressView;

@synthesize contentsLabel;

@synthesize contentsMsgUIControl;
//@synthesize contentsMediaBtn;
@synthesize contentsUIControl;
@synthesize contentsMediaImageView;

@synthesize failSendContentsUIControl;
@synthesize failSendContentsImageView;

@synthesize nickNameLabel;
@synthesize timeLabel;
@synthesize readMarkLabel;
@synthesize nickName;
@synthesize time;
@synthesize contentsMsg;
@synthesize msgType;
@synthesize parentDelegate;
@synthesize sendMsgSuccess;
@synthesize isSend;
@synthesize readMarkCount;
@synthesize progressPosition;






-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch =[touches anyObject];
	CGPoint location =[touch locationInView:self];
	NSLog(@"location x %f %f", location.x, location.y);
	NSLog(@"touch");
	NSLog(@"self parent = %@", self.parentDelegate);
	
	
	
	if([self.photoUrl isEqualToString:@"/008"])
	{
		[self.parentDelegate hiddenKeyboard];
		return;
	}
	
	
	if(location.x <=50 && location.y <= 40)
	[self.parentDelegate showImage:self.photoUrl];
	else {
		[self.parentDelegate hiddenKeyboard];
		return;
	}

}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		// Initialization code
	
		photoImageView = [[UIImageView alloc]initWithFrame: CGRectMake(7.0, 4.0, 41.0, 41.0)];
		[self.contentView addSubview:photoImageView];
		photoImageView.image = [UIImage imageNamed:@"img_default.png"];
		photoImageView.layer.masksToBounds = YES;
		photoImageView.layer.cornerRadius = 5.0;
		photoImageView.hidden = YES;
		
		contentsImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
		[self.contentView addSubview:contentsImageView];
		contentsImageView.hidden = YES;
		
		contentsMsgUIControl = [[UIControl alloc]initWithFrame: CGRectZero];
		[self.contentView addSubview:contentsMsgUIControl];
		contentsMsgUIControl.layer.masksToBounds = YES;
		[contentsMsgUIControl addTarget:self.parentDelegate action:@selector(balloomAction:) forControlEvents:UIControlEventTouchUpInside];
		contentsMsgUIControl.hidden = YES;
		
		UIFont *Font12 = [UIFont systemFontOfSize:12];	// boldSystemFontOfSize
		UIFont *Font10 = [UIFont systemFontOfSize:10];		
	//	UIFont *FontBold15 = [UIFont boldSystemFontOfSize:15];
		UIFont *FontBold15 = [UIFont systemFontOfSize:15];
		
		nickNameLabel = [[UILabel alloc]initWithFrame:CGRectZero];
		[nickNameLabel setFont:Font12];
		[nickNameLabel setBackgroundColor:[UIColor clearColor]];
		nickNameLabel.hidden = YES;
		[self.contentsImageView addSubview:nickNameLabel];
		
		timeLabel = [[UILabel alloc]initWithFrame:CGRectZero];
		[timeLabel setFont:Font10];
		[timeLabel setBackgroundColor:[UIColor clearColor]];
		timeLabel.hidden = YES;
		[self.contentsImageView addSubview:timeLabel];
		
		readMarkLabel = [[UILabel alloc]initWithFrame:CGRectZero];
		[readMarkLabel setFont:Font12];
		[readMarkLabel setBackgroundColor:[UIColor clearColor]];
		readMarkLabel.hidden = YES;
		[self.contentsImageView addSubview:readMarkLabel];
		
		contentsLabel = [[UILabel alloc]initWithFrame:CGRectZero];
		[contentsLabel setFont:FontBold15];
		[contentsLabel setBackgroundColor:[UIColor clearColor]];
		contentsLabel.hidden = YES;
		[self.contentView addSubview:contentsLabel];
		
		contentsUIControl = [[UIControl alloc]initWithFrame: CGRectZero];
		[self.contentView addSubview:contentsUIControl];
		contentsUIControl.layer.masksToBounds = YES;
		contentsUIControl.layer.cornerRadius = 5.0;
		[contentsUIControl addTarget:self.parentDelegate action:@selector(mediaViewAction:) forControlEvents:UIControlEventTouchUpInside];
		contentsUIControl.hidden = YES;
		
		contentsMediaImageView = [[UIImageView alloc]initWithFrame: CGRectZero];
		[self.contentView addSubview:contentsMediaImageView];

		contentsMediaImageView.layer.masksToBounds = YES;
		contentsMediaImageView.layer.cornerRadius = 5.0;
		contentsMediaImageView.hidden = YES;
		
		failSendContentsUIControl = [[UIControl alloc]initWithFrame: CGRectZero];
		[self.contentView addSubview:failSendContentsUIControl];
		failSendContentsUIControl.layer.masksToBounds = YES;
		failSendContentsUIControl.layer.cornerRadius = 5.0;
		[failSendContentsUIControl addTarget:self.parentDelegate action:@selector(reSendContentsAction:) forControlEvents:UIControlEventTouchUpInside];
		failSendContentsUIControl.hidden = YES;
		
		failSendContentsImageView = [[UIImageView alloc]initWithFrame: CGRectMake(0, 0, 23, 23)];
		[self.contentView addSubview:failSendContentsImageView];
		failSendContentsImageView.image = [UIImage imageNamed:@"btn_FailSendMessage.png"];
		failSendContentsImageView.layer.masksToBounds = YES;
		failSendContentsImageView.layer.cornerRadius = 5.0;
		failSendContentsImageView.hidden = YES;
		
	//	progressView = [[UIProgressView alloc] initWithFrame:CGRectZero];
		
		progressView = [[PDColoredProgressView alloc] initWithFrame:CGRectZero];
		[progressView setTintColor:ColorFromRGB(0x86ff52)];
		
		
		[progressView setProgressViewStyle:UIProgressViewStyleDefault];
		[progressView setProgress:0.0f];
	//mezzo	progressView.frame = CGRectZero;
//		progressView.frame=CGRectMake(0, 0, 100, 5);
		progressView.hidden = YES;
		[self.contentView addSubview:progressView];
		
		
		progressPosition = 0.0f;

		sendMsgSuccess = @"0";
		msgType = nil;
		contentsMsg = nil;
		time = nil;
		nickName = nil;
	}
	return self;
}

-(void)layoutSubviews 
{
	// sochae 2010.09.11 - UI Position
	//CGRect rect = [MyDeviceClass deviceOrientation];
	CGRect rect = [[UIScreen mainScreen] applicationFrame];
	// ~sochae

	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	if ([self.msgType isEqualToString:@"T"]) {
		if (isSend == YES) {	// 발송 메시지
			UIFont *nickNameFont = [UIFont systemFontOfSize:12];		// boldSystemFontOfSize
			CGSize nickNameStringSize = [self.nickName sizeWithFont:nickNameFont constrainedToSize:(CGSizeMake(120.0f, MAXFLOAT))];
			UIFont *timeFont = [UIFont systemFontOfSize:10];
			CGSize timeStringSize = [self.time sizeWithFont:timeFont];
			UIFont *readMarkFont = [UIFont systemFontOfSize:12];
			CGSize readMarkStringSize = CGSizeZero;
			if (readMarkCount > 0) {
				readMarkStringSize = [[NSString stringWithFormat:@"%i",readMarkCount] sizeWithFont:readMarkFont];
			}
			UIFont *contentsFont = [UIFont boldSystemFontOfSize:15];
			CGSize contentsStringSize = [self.contentsMsg sizeWithFont:contentsFont constrainedToSize:(CGSizeMake(193.0f, MAXFLOAT))];
			UIImage *stretchImage = [[UIImage imageNamed:@"Balloon_Green.png"] stretchableImageWithLeftCapWidth:12 topCapHeight:35];
			CGSize size = [stretchImage size];
			
			int nWidth = 0;
			
			if ((nickNameStringSize.width + timeStringSize.width + 30) > contentsStringSize.width) {
				nWidth = nickNameStringSize.width + timeStringSize.width + 30;
			} else {
				nWidth = contentsStringSize.width;
			}

			
			CGRect bound = [self.contentView bounds];
			
			self.contentsImageView.image = stretchImage;
			self.contentsImageView.frame = CGRectMake(bound.size.width - (size.width + nWidth) - 4, 4, size.width + nWidth - 2, size.height + contentsStringSize.height - 16);
			self.contentsImageView.hidden = NO;

			self.contentsMsgUIControl.frame = CGRectMake(bound.size.width - (size.width + nWidth) - 4, 4, size.width + nWidth - 2, size.height + contentsStringSize.height - 16);
			self.contentsMsgUIControl.hidden = NO;
			
			contentsUIControl.hidden = YES;
			progressView.hidden = YES;
			contentsMediaImageView.hidden = YES;
			photoImageView.hidden = YES;
			
			if ([sendMsgSuccess isEqualToString:@"0"]) {
				failSendContentsUIControl.hidden = YES;
				failSendContentsImageView.hidden = YES;
			} else if ([sendMsgSuccess isEqualToString:@"1"]) {
				// success
				failSendContentsUIControl.hidden = YES;
				failSendContentsImageView.hidden = YES;
			} else {
				// fail
				failSendContentsUIControl.frame = CGRectMake(bound.size.width - (size.width + nWidth) - 34, (self.frame.size.height - 27), 23, 23);
				failSendContentsImageView.frame = CGRectMake(bound.size.width - (size.width + nWidth) - 34, (self.frame.size.height - 27), 23, 23);
				failSendContentsUIControl.hidden = NO;
				failSendContentsImageView.hidden = NO;
			}
			
			contentsLabel.numberOfLines = (contentsStringSize.height/19) + 1;
			contentsLabel.frame = CGRectMake(bound.size.width - (size.width + nWidth) + 9, 15.0+14, nWidth, contentsStringSize.height);
			contentsLabel.hidden = NO;
			[contentsLabel setTextColor:ColorFromRGB(0x23232a)];

			nickNameLabel.numberOfLines = 1;
			self.nickNameLabel.frame = CGRectMake(15, 6, nickNameStringSize.width, 15.0);
			[self.nickNameLabel setTextColor:ColorFromRGB(0x466a00)];
			[self.nickNameLabel setFont:nickNameFont];
			self.nickNameLabel.hidden = NO;
			
			self.timeLabel.frame = CGRectMake(nickNameStringSize.width+22, 8, timeStringSize.width, timeStringSize.height);
			self.timeLabel.text = self.time;
			[self.timeLabel setTextColor:ColorFromRGB(0x466a00)];
			self.timeLabel.hidden = NO;

			if (readMarkStringSize.width > 0) {
				self.readMarkLabel.frame = CGRectMake(size.width + nWidth - 27 - readMarkStringSize.width, 6, readMarkStringSize.width, readMarkStringSize.height);
				[self.readMarkLabel setText:[NSString stringWithFormat:@"%i",readMarkCount]];
				[self.readMarkLabel setTextColor:ColorFromRGB(0x1fa20d)];
				self.readMarkLabel.hidden = NO;
			} else {
				self.readMarkLabel.hidden = YES;
			}
					
		} else {					// 수신 메시지
			UIFont *nickNameFont = [UIFont systemFontOfSize:12];		// boldSystemFontOfSize
			CGSize nickNameStringSize = [self.nickName sizeWithFont:nickNameFont constrainedToSize:(CGSizeMake(120.0f, MAXFLOAT))];
			UIFont *timeFont = [UIFont systemFontOfSize:10];
			CGSize timeStringSize = [self.time sizeWithFont:timeFont];
			UIFont *contentsFont = [UIFont boldSystemFontOfSize:15];
			CGSize contentsStringSize = [self.contentsMsg sizeWithFont:contentsFont constrainedToSize:(CGSizeMake(193.0f, MAXFLOAT))];
			
			UIImage *stretchImage = [[UIImage imageNamed:@"Balloon_White.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:36];
			CGSize size = [stretchImage size];
			
			int nWidth = 0;
			
			if ((nickNameStringSize.width + 4 + timeStringSize.width + 10) > contentsStringSize.width) {
				nWidth = nickNameStringSize.width + 4 + timeStringSize.width + 10;
			} else {
				nWidth = contentsStringSize.width;
			}

			photoImageView.hidden = NO;

			self.contentsImageView.image = stretchImage;
			self.contentsImageView.frame = CGRectMake(54, 4, size.width + nWidth -7, size.height + contentsStringSize.height - 16);
			self.contentsImageView.hidden = NO;
			
			self.contentsMsgUIControl.frame = CGRectMake(54, 4, size.width + nWidth -7, size.height + contentsStringSize.height - 16);
			self.contentsMsgUIControl.hidden = NO;
			
			contentsUIControl.hidden = YES;
			progressView.hidden = YES;
			contentsMediaImageView.hidden = YES;
			failSendContentsUIControl.hidden = YES;
			failSendContentsImageView.hidden = YES;
			
			contentsLabel.numberOfLines = (contentsStringSize.height/19) + 1;
			contentsLabel.frame = CGRectMake(76, 15.0+14, nWidth, contentsStringSize.height);
			contentsLabel.hidden = NO;
			[contentsLabel setTextColor:ColorFromRGB(0x23232a)];
			
			nickNameLabel.numberOfLines = 1;
			self.nickNameLabel.frame = CGRectMake(23, 6, nickNameStringSize.width, 15.0);
			[self.nickNameLabel setTextColor:ColorFromRGB(0x666666)];
			[self.nickNameLabel setFont:nickNameFont];
			self.nickNameLabel.hidden = NO;
			
			self.timeLabel.frame = CGRectMake(nickNameStringSize.width+26, 8, timeStringSize.width, timeStringSize.height);
			self.timeLabel.text = self.time;
			[self.timeLabel setTextColor:ColorFromRGB(0x666666)];
			self.timeLabel.hidden = NO;
			
			self.readMarkLabel.hidden = YES;
		}
	} else if ([self.msgType isEqualToString:@"P"]) {
		if (isSend == YES) {	// 발송 사진 메시지
			UIFont *nickNameFont = [UIFont systemFontOfSize:12];		// boldSystemFontOfSize
			CGSize nickNameStringSize = [self.nickName sizeWithFont:nickNameFont constrainedToSize:(CGSizeMake(120.0f, MAXFLOAT))];
			UIFont *timeFont = [UIFont systemFontOfSize:10];
			CGSize timeStringSize = [self.time sizeWithFont:timeFont];
			UIFont *readMarkFont = [UIFont systemFontOfSize:12];
			CGSize readMarkStringSize = CGSizeZero;
			if (readMarkCount > 0) {
				readMarkStringSize = [[NSString stringWithFormat:@"%i",readMarkCount] sizeWithFont:readMarkFont];
			}
			UIImage *stretchImage = [[UIImage imageNamed:@"Balloon_Green.png"] stretchableImageWithLeftCapWidth:12 topCapHeight:35];
			CGSize size = [stretchImage size];

			NSInteger nWidth = 0;
			if ((nickNameStringSize.width + timeStringSize.width + 34) > 99) {
				nWidth = nickNameStringSize.width + timeStringSize.width + 34;
			} else {
				nWidth = 99;
			}
			
			photoImageView.hidden = YES;
			
			CGRect bound = [self.contentView bounds];
			
			self.contentsImageView.image = stretchImage;
			self.contentsImageView.frame = CGRectMake(bound.size.width - (size.width + nWidth) + 1, 4, size.width + nWidth - 7, 117);
			self.contentsImageView.hidden = NO;
			
			self.contentsMsgUIControl.frame = CGRectMake(bound.size.width - (size.width + nWidth) + 1, 4, size.width + nWidth - 7, 117);
			self.contentsMsgUIControl.hidden = NO;
			
			contentsUIControl.frame = CGRectMake(bound.size.width - (size.width + nWidth) + 1 + (size.width + nWidth - 81)/2, 15.0+20, 64, 64);
			contentsUIControl.hidden = NO;
			
			contentsMediaImageView.frame = CGRectMake(bound.size.width - (size.width + nWidth) + 1 + (size.width + nWidth - 81)/2, 15.0+20, 64, 64);
			contentsMediaImageView.hidden = NO;

			if ([sendMsgSuccess isEqualToString:@"0"]) {
				NSLog(@"===================>sendMsgSuccess 0<====================");
				progressView.frame = CGRectMake(bound.size.width - (size.width + nWidth) - 81, (self.frame.size.height - 27), 70, 9);//mezzo 기존 20을 10으로
				progressView.hidden = NO;
				[progressView setProgress:progressPosition];
				failSendContentsUIControl.hidden = YES;
				failSendContentsImageView.hidden = YES;
			} else if ([sendMsgSuccess isEqualToString:@"1"]) {
				NSLog(@"===================>sendMsgSuccess 1<====================");
				progressView.hidden = YES;
				failSendContentsUIControl.hidden = YES;
				failSendContentsImageView.hidden = YES;
				// success
			} else {
				NSLog(@"sendMsgSuccess = %@", sendMsgSuccess);
				progressView.hidden = YES;
				// fail
				failSendContentsUIControl.frame = CGRectMake(bound.size.width - (size.width + nWidth) - 34, (self.frame.size.height - 27), 23, 23);
				failSendContentsImageView.frame = CGRectMake(bound.size.width - (size.width + nWidth) - 34, (self.frame.size.height - 27), 23, 23);
				failSendContentsUIControl.hidden = NO;
				failSendContentsImageView.hidden = NO;
			}
			
			contentsLabel.hidden = YES;
			
			nickNameLabel.numberOfLines = 1;
			self.nickNameLabel.frame = CGRectMake(15, 6, nickNameStringSize.width, 15.0);
			[self.nickNameLabel setTextColor:ColorFromRGB(0x466a00)];
			[self.nickNameLabel setFont:nickNameFont];
			self.nickNameLabel.hidden = NO;
			
			self.timeLabel.frame = CGRectMake(nickNameStringSize.width+22, 8, timeStringSize.width, timeStringSize.height);
			self.timeLabel.text = self.time;
			[self.timeLabel setTextColor:ColorFromRGB(0x466a00)];
			self.timeLabel.hidden = NO;
			
			if (readMarkStringSize.width > 0) {
				self.readMarkLabel.frame = CGRectMake(size.width + nWidth - 27 - readMarkStringSize.width, 6, readMarkStringSize.width, readMarkStringSize.height);
				[self.readMarkLabel setText:[NSString stringWithFormat:@"%i",readMarkCount]];
				[self.readMarkLabel setTextColor:ColorFromRGB(0x1fa20d)];
				self.readMarkLabel.hidden = NO;
			} else {
				self.readMarkLabel.hidden = YES;
			}
		} else {				// 수신 사진 메시지
			UIFont *nickNameFont = [UIFont systemFontOfSize:12];		// boldSystemFontOfSize
			CGSize nickNameStringSize = [self.nickName sizeWithFont:nickNameFont constrainedToSize:(CGSizeMake(120.0f, 15.0))];
			UIFont *timeFont = [UIFont systemFontOfSize:10];
			CGSize timeStringSize = [self.time sizeWithFont:timeFont];
			
			UIImage *stretchImage = [[UIImage imageNamed:@"Balloon_White.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:36];
			CGSize size = [stretchImage size];
			
			int nWidth = 0;
		//mezzo	nWidth = nickNameStringSize.width + 7 + timeStringSize.width + 20;
			if ((nickNameStringSize.width + 7 + timeStringSize.width + 20) > 99) {
				nWidth = nickNameStringSize.width + 7 + timeStringSize.width + 20;
			} else {
				nWidth = 99;
			}

			photoImageView.hidden = NO;

			self.contentsImageView.image = stretchImage;
			self.contentsImageView.frame = CGRectMake(54.0, 4.0, size.width + nWidth - 25.0, 117.0);
			self.contentsImageView.hidden = NO;
			
			self.contentsMsgUIControl.frame = CGRectMake(54.0, 4.0, size.width + nWidth - 25.0, 117.0);
			self.contentsMsgUIControl.hidden = NO;
			
			contentsUIControl.frame = CGRectMake(31+nWidth/2.0, 20.0+15.0, 64.0, 64.0);
			contentsUIControl.hidden = NO;
			
			contentsMediaImageView.frame = CGRectMake(31+nWidth/2.0, 20.0+15.0, 64.0, 64.0);
			contentsMediaImageView.hidden = NO;
			
			failSendContentsUIControl.hidden = YES;
			failSendContentsImageView.hidden = YES;
			
			progressView.hidden = YES;
			contentsLabel.hidden = YES;
			
		
			
			
			nickNameLabel.numberOfLines = 1;
			self.nickNameLabel.frame = CGRectMake(23, 6, nickNameStringSize.width, 15.0);
			[self.nickNameLabel setTextColor:ColorFromRGB(0x666666)];
			[self.nickNameLabel setFont:nickNameFont];
			self.nickNameLabel.hidden = NO;
			
			self.timeLabel.frame = CGRectMake(nickNameStringSize.width+27, 8, timeStringSize.width, timeStringSize.height);
			self.timeLabel.text = self.time;
			[self.timeLabel setTextColor:ColorFromRGB(0x666666)];
			self.timeLabel.hidden = NO;
			
			self.readMarkLabel.hidden = YES;
		}
	} else if ([self.msgType isEqualToString:@"V"]) {
		if (isSend == YES) {	// 발송 영상 메시지
			UIFont *nickNameFont = [UIFont systemFontOfSize:12];		// boldSystemFontOfSize
			CGSize nickNameStringSize = [self.nickName sizeWithFont:nickNameFont constrainedToSize:(CGSizeMake(120.0f, MAXFLOAT))];
			UIFont *timeFont = [UIFont systemFontOfSize:10];
			CGSize timeStringSize = [self.time sizeWithFont:timeFont];
			UIFont *readMarkFont = [UIFont systemFontOfSize:12];
			CGSize readMarkStringSize = CGSizeZero;
			if (readMarkCount > 0) {
				readMarkStringSize = [[NSString stringWithFormat:@"%i",readMarkCount] sizeWithFont:readMarkFont];
			}
			UIImage *stretchImage = [[UIImage imageNamed:@"Balloon_Green.png"] stretchableImageWithLeftCapWidth:12 topCapHeight:35];
			CGSize size = [stretchImage size];
			
			NSInteger nWidth = 0;
			if ((nickNameStringSize.width + timeStringSize.width + 34) > 99) {
				nWidth = nickNameStringSize.width + timeStringSize.width + 34;
			} else {
				nWidth = 99;
			}
			
			photoImageView.hidden = YES;
			
			CGRect bound = [self.contentView bounds];
			
			self.contentsImageView.image = stretchImage;
			self.contentsImageView.frame = CGRectMake(bound.size.width - (size.width + nWidth) + 1, 4, size.width + nWidth - 7, 117);
			self.contentsImageView.hidden = NO;
			
			self.contentsMsgUIControl.frame = CGRectMake(bound.size.width - (size.width + nWidth) + 1, 4, size.width + nWidth - 7, 117);
			self.contentsMsgUIControl.hidden = NO;
			
			contentsUIControl.frame = CGRectMake(bound.size.width - (size.width + nWidth) + 1 + (size.width + nWidth - 81)/2, 15.0+20, 64, 64);
			contentsUIControl.hidden = NO;

			contentsMediaImageView.frame = CGRectMake(bound.size.width - (size.width + nWidth) + 1 + (size.width + nWidth - 81)/2, 15.0+20, 64, 64);
			contentsMediaImageView.hidden = NO;
			
			if ([sendMsgSuccess isEqualToString:@"0"]) {
				NSLog(@"===================>sendMsgSuccess 0<====================");
				progressView.frame = CGRectMake(bound.size.width - (size.width + nWidth) - 81, (self.frame.size.height - 27), 70, 9); //mezzo
				[progressView setProgress:progressPosition];
				progressView.hidden = NO;
				failSendContentsUIControl.hidden = YES;
				failSendContentsImageView.hidden = YES;
			} else if ([sendMsgSuccess isEqualToString:@"1"]) {
				progressView.hidden = YES;
				failSendContentsUIControl.hidden = YES;
				failSendContentsImageView.hidden = YES;
				// success
			} else {
				failSendContentsUIControl.frame = CGRectMake(bound.size.width - (size.width + nWidth) - 34, (self.frame.size.height - 27), 23, 23);
				failSendContentsImageView.frame = CGRectMake(bound.size.width - (size.width + nWidth) - 34, (self.frame.size.height - 27), 23, 23);
				failSendContentsUIControl.hidden = NO;
				failSendContentsImageView.hidden = NO;
				progressView.hidden = YES;
				// fail
			}

			contentsLabel.hidden = YES;
			
			nickNameLabel.numberOfLines = 1;
			self.nickNameLabel.frame = CGRectMake(15, 6, nickNameStringSize.width, 15.0);
			[self.nickNameLabel setTextColor:ColorFromRGB(0x466a00)];
			[self.nickNameLabel setFont:nickNameFont];
			self.nickNameLabel.hidden = NO;
			
			self.timeLabel.frame = CGRectMake(nickNameStringSize.width+22, 8, timeStringSize.width, timeStringSize.height);
			self.timeLabel.text = self.time;
			[self.timeLabel setTextColor:ColorFromRGB(0x466a00)];
			self.timeLabel.hidden = NO;
			
			if (readMarkStringSize.width > 0) {
				self.readMarkLabel.frame = CGRectMake(size.width + nWidth - 27 - readMarkStringSize.width, 6, readMarkStringSize.width, readMarkStringSize.height);
				[self.readMarkLabel setText:[NSString stringWithFormat:@"%i",readMarkCount]];
				[self.readMarkLabel setTextColor:ColorFromRGB(0x1fa20d)];
				self.readMarkLabel.hidden = NO;
			} else {
				self.readMarkLabel.hidden = YES;
			}
		} else {				// 수신 영상 메시지
			UIFont *nickNameFont = [UIFont systemFontOfSize:12];		// boldSystemFontOfSize
			CGSize nickNameStringSize = [self.nickName sizeWithFont:nickNameFont constrainedToSize:(CGSizeMake(120.0f, MAXFLOAT))];
			UIFont *timeFont = [UIFont systemFontOfSize:10];
			CGSize timeStringSize = [self.time sizeWithFont:timeFont];
			
			UIImage *stretchImage = [[UIImage imageNamed:@"Balloon_White.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:36];
			CGSize size = [stretchImage size];
			
			int nWidth = 0;
		//mezzo	nWidth = nickNameStringSize.width + 7 + timeStringSize.width + 20;
			if ((nickNameStringSize.width + 7 + timeStringSize.width + 20) > 99) {
				nWidth = nickNameStringSize.width + 7 + timeStringSize.width + 20;
			} else {
				nWidth = 99;
			}
			
			photoImageView.hidden = NO;
			
			self.contentsImageView.image = stretchImage;
			self.contentsImageView.frame = CGRectMake(54, 4, size.width + nWidth - 25, 117);
			self.contentsImageView.hidden = NO;
			
			self.contentsMsgUIControl.frame = CGRectMake(54, 4, size.width + nWidth - 25, 117);
			self.contentsMsgUIControl.hidden = NO;
			
			contentsUIControl.frame = CGRectMake(31+nWidth/2, 20+15.0, 64, 64);
			contentsUIControl.hidden = NO;
			
			contentsMediaImageView.frame = CGRectMake(31+nWidth/2, 20+15.0, 64, 64);
			contentsMediaImageView.hidden = NO;

			progressView.hidden = YES;
			
			contentsLabel.hidden = YES;
			
			nickNameLabel.numberOfLines = 1;
			self.nickNameLabel.frame = CGRectMake(24, 6, nickNameStringSize.width, 15.0);
			[self.nickNameLabel setTextColor:ColorFromRGB(0x666666)];
			[self.nickNameLabel setFont:nickNameFont];
			self.nickNameLabel.hidden = NO;
			
			self.timeLabel.frame = CGRectMake(nickNameStringSize.width+27, 8, timeStringSize.width, timeStringSize.height);
			self.timeLabel.text = self.time;
			[self.timeLabel setTextColor:ColorFromRGB(0x666666)];
			self.timeLabel.hidden = NO;
			
			self.readMarkLabel.hidden = YES;
		}
	} else if ([self.msgType isEqualToString:@"J"]) {
		UIImage *stretchImage = [[UIImage imageNamed:@"img_msg_date.png"] stretchableImageWithLeftCapWidth:2 topCapHeight:5];
		UIFont *contentsFont = [UIFont boldSystemFontOfSize:13];
		CGSize contentsStringSize = [self.contentsMsg sizeWithFont:contentsFont constrainedToSize:(CGSizeMake(rect.size.width - 34, MAXFLOAT))];
		
		photoImageView.hidden = YES;
		
		self.contentsImageView.image = stretchImage;
		self.contentsImageView.frame = CGRectMake(7, 4, rect.size.width - 14, 8 + contentsStringSize.height);
		self.contentsImageView.hidden = NO;
		
		self.contentsMsgUIControl.hidden = YES;
		
		contentsUIControl.hidden = YES;
		progressView.hidden = YES;
		contentsLabel.hidden = YES;
		contentsMediaImageView.hidden = YES;
		failSendContentsUIControl.hidden = YES;
		failSendContentsImageView.hidden = YES;
		
		nickNameLabel.numberOfLines = (contentsStringSize.height/17) + 1;
		self.nickNameLabel.frame = CGRectMake(10, 4, self.contentsImageView.frame.size.width - 20, self.contentsImageView.frame.size.height - 8);
		self.nickNameLabel.textAlignment = UITextAlignmentCenter;
		[self.nickNameLabel setFont:[UIFont systemFontOfSize:13]];
		[self.nickNameLabel setTextColor:ColorFromRGB(0x313b48)];
		self.nickNameLabel.hidden = NO;
		
		self.timeLabel.hidden = YES;
		
		self.readMarkLabel.hidden = YES;
	} else if ([self.msgType isEqualToString:@"Q"]) {
		UIImage *stretchImage = [[UIImage imageNamed:@"img_msg_date.png"] stretchableImageWithLeftCapWidth:2 topCapHeight:0];
		UIFont *contentsFont = [UIFont boldSystemFontOfSize:13];
		CGSize contentsStringSize = [self.contentsMsg sizeWithFont:contentsFont constrainedToSize:(CGSizeMake(rect.size.width - 34, MAXFLOAT))];
		
		photoImageView.hidden = YES;
		
		self.contentsImageView.image = stretchImage;
		self.contentsImageView.frame = CGRectMake(7, 4, rect.size.width - 14, 20);
		self.contentsImageView.hidden = NO;
		
		self.contentsMsgUIControl.hidden = YES;
		
		contentsUIControl.hidden = YES;
		progressView.hidden = YES;
		contentsLabel.hidden = YES;
		contentsMediaImageView.hidden = YES;
		failSendContentsUIControl.hidden = YES;
		failSendContentsImageView.hidden = YES;
		
		nickNameLabel.numberOfLines = (contentsStringSize.height/17) + 1;
		self.nickNameLabel.frame = CGRectMake(10, 4, self.contentsImageView.frame.size.width - 20, self.contentsImageView.frame.size.height - 8);
		self.nickNameLabel.textAlignment = UITextAlignmentCenter;
		[self.nickNameLabel setFont:[UIFont systemFontOfSize:13]];
		[self.nickNameLabel setTextColor:ColorFromRGB(0x313b48)];
		self.nickNameLabel.hidden = NO;
		
		self.timeLabel.hidden = YES;
		
		self.readMarkLabel.hidden = YES;
	} else if ([self.msgType isEqualToString:@"D"]) {
		UIImage *stretchImage = [[UIImage imageNamed:@"img_msg_date.png"] stretchableImageWithLeftCapWidth:2 topCapHeight:0];

		photoImageView.hidden = YES;
		
		self.contentsImageView.image = stretchImage;
		self.contentsImageView.frame = CGRectMake(7, 4, rect.size.width - 14, 20);
		self.contentsImageView.hidden = NO;
				
		self.contentsMsgUIControl.hidden = YES;
		
		contentsUIControl.hidden = YES;
		progressView.hidden = YES;
		contentsLabel.hidden = YES;
		contentsMediaImageView.hidden = YES;
		failSendContentsUIControl.hidden = YES;
		failSendContentsImageView.hidden = YES;
		
		self.nickNameLabel.frame = CGRectMake(10, 4, self.contentsImageView.frame.size.width - 20, self.contentsImageView.frame.size.height - 8);
		self.nickNameLabel.textAlignment = UITextAlignmentCenter;
		[self.nickNameLabel setFont:[UIFont systemFontOfSize:13]];
		[self.nickNameLabel setTextColor:ColorFromRGB(0x313b48)];
		self.nickNameLabel.hidden = NO;
		
		self.timeLabel.hidden = YES;
		
		self.readMarkLabel.hidden = YES;
	} else {
		
	}
	[pool release];
	[super layoutSubviews];
}

-(void)didTransitionToState:(UITableViewCellStateMask)state {
	if(state == UITableViewCellStateShowingDeleteConfirmationMask) {
	}
}

-(void)dealloc
{
	if(self.contentsImageView != nil) {
		[self.contentsImageView release];
	}
	if(self.photoImageView != nil) {
		[self.photoImageView release];
	}
	if (self.contentsMsgUIControl != nil) {
		[self.contentsMsgUIControl release];
	}
	if (self.contentsUIControl != nil) {
		[self.contentsUIControl release];
	}
	if (self.contentsMediaImageView != nil) {
		[self.contentsMediaImageView release];
	}
	if (self.failSendContentsUIControl != nil) {
		[self.failSendContentsUIControl release];
	}
	if (self.failSendContentsImageView != nil) {
		[self.failSendContentsImageView release];
	}
	if (self.progressView != nil) {
		[self.progressView release];
	}
	if(self.contentsLabel != nil) {
		[self.contentsLabel release];
	}
	if(self.nickNameLabel != nil) {
		[self.nickNameLabel release];
	}
	if(self.timeLabel != nil) {
		[self.timeLabel release];
	}
	if(self.readMarkLabel != nil) {
		[self.readMarkLabel release];
	}
	if(self.sendMsgSuccess != nil) {
		[self.sendMsgSuccess release];
	}
	if(self.nickName != nil) {
		[self.nickName release];
	}
	if(self.time != nil) {
		[self.time release];
	}
	if(self.contentsMsg != nil) {
		[self.contentsMsg release];
	}
	if(self.msgType != nil) {
		[self.msgType release];
	}
	[super dealloc];
}

@end
