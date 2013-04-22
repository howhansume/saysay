//
//  RotatingTabBarController.m
//  USayApp
//
//  Created by 1team on 10. 8. 17..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "RotatingTabBarController.h"
#import "USayAppAppDelegate.h"
#import "SayViewController.h"
#import "USayDefine.h"

@implementation RotatingTabBarController

/*
 Just override this single method to return YES when we want it to.
 */


- (USayAppAppDelegate *)appDelegate
{
	return (USayAppAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
	DebugLog(@"tab.select = %i", self.selectedIndex);
	
	if(self.selectedIndex > 4)
		return (interfaceOrientation == UIInterfaceOrientationPortrait);
	
	

	
    // Always returning YES means the view will rotate to accomodate any orientation.
//	NSLog(@"self.navi %d", self.selectedIndex);
  	//  USayAppAppDelegate *UsayDelegate = [self appDelegate];

	UINavigationController* tmpNavi = [[self appDelegate].rootController.viewControllers objectAtIndex:self.selectedIndex];
	  if (tmpNavi) {
	  
	  
		  DebugLog(@"tmpNavi  = %@", tmpNavi.viewControllers);
		  
	  }
	

	BOOL find = NO; //2010.01.11 초기화
	for (SayViewController *view in tmpNavi.viewControllers) {
		find = NO;
		if ([view isKindOfClass:[SayViewController class]] ) {
			
				find = YES;
			}
	}
	
	
	  
	  DebugLog(@"title = %@", self.tabBarController);
	  
	  DebugLog(@"tmpNavi = %d", [tmpNavi.viewControllers count]);
	
	
	if(find == YES)
	{
	  if([tmpNavi.viewControllers count] == 2)
		  return YES;
	  else {
		  return (interfaceOrientation == UIInterfaceOrientationPortrait);
	  }

	}
	else {
			  return (interfaceOrientation == UIInterfaceOrientationPortrait);	
	}

  
	

//	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
