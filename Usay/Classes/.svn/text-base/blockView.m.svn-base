//
//  blockView.m
//  USayApp
//
//  Created by Jong-Sung Park on 10. 7. 7..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "blockView.h"
#import "USayDefine.h"

@interface blockView (Private)

- (void) drawRoundedRect:(CGRect) rect inContext:(CGContextRef) context withRadius:(CGFloat) radius;

@end

static UIColor *fillColor = nil;
static UIColor *borderColor = nil;

@implementation blockView

@synthesize alertText, alertDetailText;
@synthesize		startTimer;

+ (void) setBackgroundColor:(UIColor *) background withStrokeColor:(UIColor *) stroke
{
    if(fillColor != nil)
    {
        [fillColor release];
        [borderColor release];
    }
	
    fillColor = [background retain];
    borderColor = [stroke retain];
}

- (id)initWithFrame:(CGRect)frame
{
    if((self = [super initWithFrame:frame]))
    {
        if(fillColor == nil)
        {
            fillColor = [[UIColor blackColor] retain];
            borderColor = [[UIColor colorWithHue:0.625 saturation:0.0 brightness:0.5 alpha:0.7] retain];
        }
		blockFrame = frame;
		
//		NSLog(@"blockFrame = %f", blockFrame.size.height);
		
		
		alertLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		alertLabel.textColor = [UIColor whiteColor];
		alertLabel.backgroundColor = [UIColor clearColor];
		alertLabel.font = [UIFont boldSystemFontOfSize:20.0];
		[self addSubview:alertLabel];
		
		alertDetailsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		alertDetailsLabel.textColor = [UIColor whiteColor];
		alertDetailsLabel.backgroundColor = [UIColor clearColor];
		alertDetailsLabel.font = [UIFont boldSystemFontOfSize:16.0];
		[self addSubview:alertDetailsLabel];
		
		self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		
		
		indicator = [[UIView alloc] initWithFrame:CGRectZero];
		indicator.backgroundColor = [UIColor clearColor];
		
		UIActivityIndicatorView *activateView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		activateView.center = CGPointMake(indicator.bounds.size.width / 2, indicator.bounds.size.height/2);
		
		[activateView startAnimating];
		[indicator addSubview:activateView];
		[activateView release];
		
		[self addSubview:indicator];
		
		
    }

    return self;
}

- (void) setAlertText:(NSString *)text {
	alertLabel.text = text;
}

- (NSString *) alertText {
	return alertLabel.text;
}

- (void) setAlertDetailText:(NSString *)text {
	alertDetailsLabel.text = text;
}

- (NSString *) alertDetailText {
	return alertDetailsLabel.text;
}

- (void) layoutSubviews {
	// sochae 2010.12.03 -
	for (UIView *sub in [self subviews])
	{
		if([sub class] == [UIImageView class] && sub.tag == 0)
		{
			// The alert background UIImageView tag is 0, 
			// if you are adding your own UIImageView's 
			// make sure your tags != 0 or this fix 
			// will remove your UIImageView's as well!
			[sub removeFromSuperview];
			break;
		}
	}
	// ~sochae
	
//	alertLabel.transform = CGAffineTransformIdentity;
	[alertLabel sizeToFit];
	
	CGRect textRect = alertLabel.frame;
	
//	NSLog(@"TTTTTTTTTTTTTTTT %f", textRect.size.height);
	textRect.origin.x = (CGRectGetWidth(self.bounds) - CGRectGetWidth(textRect))/2;
	textRect.origin.y = ((CGRectGetHeight(self.bounds) - CGRectGetHeight(textRect))/2) - 
							((blockFrame.size.height - CGRectGetHeight(textRect))/2);
	textRect.origin.y += 10.0;
	
	alertLabel.frame = textRect;
//	alertLabel.transform = CGAffineTransformMakeRotation(- M_PI * .08);
	[alertDetailsLabel sizeToFit];
	
	CGRect textDetailRect = alertDetailsLabel.frame;
	
//	NSLog(@"BBBBBBBBBBBBBBB %f", textDetailRect.size.height);
	
	
	textDetailRect.origin.x = (CGRectGetWidth(self.bounds) - CGRectGetWidth(textDetailRect))/2;
	textDetailRect.origin.y = ((CGRectGetHeight(self.bounds) - CGRectGetHeight(textDetailRect))/2) - 
	((blockFrame.size.height - CGRectGetHeight(textRect))/2);
	textDetailRect.origin.y += 40.0;
	
	alertDetailsLabel.frame = textDetailRect;
	
	CGRect indiframe = indicator.frame;
	indiframe.origin.x = (CGRectGetWidth(self.bounds) - CGRectGetWidth(indiframe))/2;
	indiframe.origin.y = ((CGRectGetHeight(self.bounds) - CGRectGetHeight(indiframe))/2)+
	((blockFrame.size.height - CGRectGetHeight(indiframe))/2);
	indiframe.origin.y -= 50.0; 
	
	
//	NSLog(@"CCCCCCCCC %@", blockFrame.size.height);
	
	indicator.frame = indiframe;
}

- (void)drawRect:(CGRect)rect
{  
    CGContextRef context = UIGraphicsGetCurrentContext();
	
    CGContextClearRect(context, rect);
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetLineWidth(context, 0.0);
    CGContextSetAlpha(context, 0.8);
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [borderColor CGColor]);
    CGContextSetFillColorWithColor(context, [fillColor CGColor]);	

	
	
	
	//20101012 고정으로 바꿈 왜 바뀌는건가..
    // Draw background
    CGFloat backOffset = 2;
    CGRect backRect = CGRectMake(rect.origin.x + backOffset, rect.origin.y + backOffset, rect.size.width - backOffset*2, rect.size.height - backOffset*2);
	
	//CGRect backRect = CGRectMake(rect.origin.x + backOffset, rect.origin.y + backOffset, 248, 148);
	
	
	
//	NSLog(@"clip Frame = %f %f", backRect.origin.y, backRect.origin.x);
	
	
    [self drawRoundedRect:backRect inContext:context withRadius:8];
    CGContextDrawPath(context, kCGPathFillStroke);
	
    // Clip Context
    CGRect clipRect = CGRectMake(backRect.origin.x + backOffset-1, backRect.origin.y + backOffset-1, backRect.size.width - (backOffset-1)*2, backRect.size.height - (backOffset-1)*2);
    //CGRect clipRect = CGRectMake(backRect.origin.x + backOffset-1, backRect.origin.y + backOffset-1, 248, 148);
	
	
	
	
//	NSLog(@"clip Frame = %f %f", clipRect.origin.y, clipRect.origin.x);
	[self drawRoundedRect:clipRect inContext:context withRadius:8];
    CGContextClip (context);
	
    //Draw highlight
    CGGradientRef glossGradient;
    CGColorSpaceRef rgbColorspace;
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = { 1.0, 1.0, 1.0, 0.35, 1.0, 1.0, 1.0, 0.06 };
    rgbColorspace = CGColorSpaceCreateDeviceRGB();
    glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
	
    CGRect ovalRect = CGRectMake(-130, -115, (rect.size.width*2), rect.size.width/2);
	
    CGPoint start = CGPointMake(rect.origin.x, rect.origin.y);
    CGPoint end = CGPointMake(rect.origin.x, rect.size.height/5);
	
    CGContextSetAlpha(context, 0.8);
    CGContextAddEllipseInRect(context, ovalRect);
    CGContextClip (context);
	
    CGContextDrawLinearGradient(context, glossGradient, start, end, 0);
	
    CGGradientRelease(glossGradient);
    CGColorSpaceRelease(rgbColorspace);
	
}

- (void) drawRoundedRect:(CGRect) rrect inContext:(CGContextRef) context withRadius:(CGFloat) radius
{
    CGContextBeginPath (context);
	
    CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
	
    CGContextMoveToPoint(context, minx, midy);
	
//	NSLog(@"min = %f max = %f", maxx, maxy);
	

	
    CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
	 
	
    CGContextClosePath(context);
}


- (void) show {
	
	[super show];
	self.bounds = blockFrame;
	
//	DebugLog(@"===self bonds block = %f %f %f %f", self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
	
	
	self.startTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self 
													 selector:@selector(endBlockView:) 
													 userInfo:nil repeats:NO];
}

-(void) endBlockView:(NSTimer *)timecall{
	
	[self.startTimer invalidate];
	self.startTimer = nil;
	[self dismissAlertView];
	/* 알럿창이 이중으로 뜰필요가 없다.. 2011.02.07 kjh
	UIAlertView* netAlert = [[UIAlertView alloc] initWithTitle:@"시간초과" 
											message:@"네트워크 타임아웃 시간을 초과하였습니다.\n3G나 wifi 연결 상태를 확인 해주세요." 
											delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
	[netAlert show];
	[netAlert release];
	 */
}

-(void) dismissAlertView{
	if(self.startTimer != nil){
		[self.startTimer invalidate];
		self.startTimer = nil;
	}
	[self dismissWithClickedButtonIndex:0 animated:NO];
}

- (void)dealloc
{
	if(indicator)[indicator release];
	if(alertLabel)[alertLabel release];
	if(alertDetailsLabel)[alertDetailsLabel release];
    [super dealloc];
}


@end
