//
//  UseGuideViewController.h
//  USayApp
//
//  Created by 1team on 10. 7. 21..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <UIKit/UIKit.h>

@class USayAppAppDelegate;

@interface UseGuideViewController : UIViewController {
	UIView			*contentsView;
	UIScrollView	*scrollView;
	UIImageView		*imageView;
	BOOL			isSetting;
}

-(USayAppAppDelegate *) appDelegate;
-(void)backBarButtonClicked;
-(void)serviceStart;

@property (readwrite) BOOL	isSetting;

@end
