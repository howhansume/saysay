//
//  CustomNavigationBar.m
//  USayApp
//
//  Created by 1team on 10. 6. 20..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "CustomNavigationBar.h"

static BOOL isLandscape = NO;

@implementation UINavigationBar(CustomImage)

//Overrider to draw a custom image

//static NSMutableDictionary *navigationBarImages = NULL;
/*
+ (void)initImageDictionary
{
    if(navigationBarImages == nil){
        navigationBarImages =[[NSMutableDictionary alloc] init];
    }   
}
*/
- (void)drawRect:(CGRect)rect
{
//*
	UIImage *image = [[UIImage imageNamed: @"navigationbar.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
	[image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
	return;
//*/	
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];

	switch (orientation)  
    {  
        case UIDeviceOrientationPortrait:  
		{
			UIImage *image = [[UIImage imageNamed: @"navigationbar.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
			[image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
			isLandscape = NO;
		}
            break;  
        case UIDeviceOrientationLandscapeLeft:  
		{
			UIImage *image = [[UIImage imageNamed: @"landscape_navigationbar.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
			[image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
			isLandscape = YES;
		}
            break;  
        case UIDeviceOrientationLandscapeRight:  
		{
			UIImage *image = [[UIImage imageNamed: @"landscape_navigationbar.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
			[image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
			isLandscape = YES;
		}
            break;  
        case UIDeviceOrientationPortraitUpsideDown:  
		{
			UIImage *image = [[UIImage imageNamed: @"navigationbar.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
			[image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
			isLandscape = NO;
		}
            break;  
		case UIDeviceOrientationFaceUp:
		{
			if (isLandscape) {
				UIImage *image = [[UIImage imageNamed: @"landscape_navigationbar.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
				[image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
			} else {
				UIImage *image = [[UIImage imageNamed: @"navigationbar.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
				[image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
			}
		}
			break;
		case UIDeviceOrientationFaceDown:
		{
			if (isLandscape) {
				UIImage *image = [[UIImage imageNamed: @"landscape_navigationbar.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
				[image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
			} else {
				UIImage *image = [[UIImage imageNamed: @"navigationbar.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
				[image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
			}
		}
			break;
		case UIDeviceOrientationUnknown:
		{
			if (isLandscape) {                    
				UIImage *image = [[UIImage imageNamed: @"landscape_navigationbar.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
				[image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
			} else {
				UIImage *image = [[UIImage imageNamed: @"navigationbar.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
				[image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
			}
		}
			break;
        default:  
            break;  
    } 
	
//	UIView *titleView = [[UIView alloc] initWithFrame:self.topItem.titleView.bounds];
//	assert(titleView != nil);
//	UIFont *titleFont = [UIFont boldSystemFontOfSize:20];
//	CGSize titleStringSize = [self.topItem.title sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
//	assert(titleFont != nil);
//	UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
//	assert(titleLabel != nil);
//	[titleLabel setFont:titleFont];
//	titleLabel.textAlignment = UITextAlignmentCenter;
//	[titleLabel setTextColor:[UIColor blackColor]];
//	[titleLabel setBackgroundColor:[UIColor clearColor]];
//	[titleLabel setText:self.topItem.title];
//	//				titleLabel.shadowColor = [UIColor whiteColor];
//	[titleView addSubview:titleLabel];	
//	[titleLabel release];
//	self.topItem.titleView = titleView;
//	[titleView release];
//	self.topItem.titleView.frame = CGRectMake((self.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);				
	//	[self setTintColor:[UIColor colorWithRed:75.0/255.0 green:124.0/255.0 blue:148.0/255.0 alpha:1]];
/*	
	if([self.topItem.title length] > 0 && ![self.topItem.title isEqualToString:@"Back"]) {
		NSString *imageName=[navigationBarImages objectForKey:[NSValue valueWithNonretainedObject: self]];
		if (imageName == nil) {
			imageName=@"navigationbar.png";
		}
		[[UIImage imageNamed:imageName] drawInRect:rect];

		UIView *addTitleView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, rect.size.width, 40.0f)];
		CGRect frame = CGRectMake(0, 7, rect.size.width, 30);
		UILabel *label = [[[UILabel alloc] initWithFrame:frame] autorelease];
		[label setFont:[UIFont boldSystemFontOfSize:20.0]];
		[label setBackgroundColor:[UIColor clearColor]];
//		label.shadowColor = [UIColor colorWithWhite:0.0 alpha:1];
		label.textAlignment = UITextAlignmentCenter;
		[label setTextColor:[UIColor whiteColor]];
		label.text = self.topItem.title;
		[addTitleView addSubview:label];
		self.topItem.hidesBackButton = TRUE;
		self.topItem.titleView = addTitleView;
		[addTitleView release];
	} else {
		[[UIImage imageNamed:@"navigationbar.png"] drawInRect:rect];
		self.topItem.titleView = [[[UIView alloc] init] autorelease];
	}
 */
}

//Allow the setting of an image for the navigation bar
/*
- (void)setImage:(UIImage*)image
{
    [navigationBarImages setObject:image forKey:[NSValue valueWithNonretainedObject: self]];
}
*/
@end

@implementation CustomNavigationBar

//-(id) init
//{
//	self = [super init];
//
//	if(self != nil) {
//		[self setFrame:CGRectMake(0, 0, self.frame.size.width, 40)];
//	}
//	
//	return self;
//}

@end
