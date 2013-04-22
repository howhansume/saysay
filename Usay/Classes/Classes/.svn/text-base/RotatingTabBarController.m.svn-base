//
//  RotatingTabBarController.m
//  USayApp
//
//  Created by 1team on 10. 8. 17..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "RotatingTabBarController.h"
#import "USayAppAppDelegate.h"

@implementation RotatingTabBarController

/*
 Just override this single method to return YES when we want it to.
 */


-(USayAppAppDelegate *)appDelegate
{
	return [[UIApplication sharedApplication] delegate];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Always returning YES means the view will rotate to accomodate any orientation.
//	NSLog(@"self.navi %d", self.selectedIndex);
  if(self.selectedIndex == 2)
  {
	//  USayAppAppDelegate *UsayDelegate = [self appDelegate];
	  UINavigationController* tmpNavi = [[self appDelegate].rootController.viewControllers objectAtIndex:2];
	  if (tmpNavi) {
	  
	  
		  NSLog(@"tmpNavi  = %@", tmpNavi.viewControllers);
		  
	  }

	  
	  NSLog(@"title = %@", self.tabBarController);
	
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
