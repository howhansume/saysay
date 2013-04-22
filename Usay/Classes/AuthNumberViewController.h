//
//  AuthNumberViewController.h
//  USayApp
//
//  Created by Jong-Sung Park on 10. 6. 28..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <UIKit/UIKit.h>

@class USayAppAppDelegate;
@class blockView;
@interface AuthNumberViewController : UITableViewController<UITextFieldDelegate> {
	blockView* authBlockView;
}
-(USayAppAppDelegate *) appDelegate;
-(void)addCustomFooterView;
@end
