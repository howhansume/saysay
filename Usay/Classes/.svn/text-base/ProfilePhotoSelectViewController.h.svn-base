//
//  ProfilePhotoSelectViewController.h
//  USayApp
//
//  Created by 1team on 10. 7. 23..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <UIKit/UIKit.h>

@class USayAppAppDelegate;

@interface ProfilePhotoSelectViewController : UIViewController <UIScrollViewDelegate> {
	UIScrollView	*scrollView;
	NSMutableArray	*photoViewControllersArray;
	NSMutableArray	*photoUrlArray;
	NSInteger		currentPage;
	BOOL pageControlUsed;
}

-(USayAppAppDelegate *) appDelegate;
-(void)backBarButtonClicked;

@property (readwrite) NSInteger currentPage;

@end
