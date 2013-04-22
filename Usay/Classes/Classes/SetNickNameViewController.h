//
//  SetNickNameViewController.h
//  USayApp
//
//  Created by Jong-Sung Park on 10. 6. 29..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <UIKit/UIKit.h>

@class USayAppAppDelegate;
@class blockView;
@interface SetNickNameViewController : UITableViewController<UITextFieldDelegate> {
	blockView* textBlockView;
}
-(USayAppAppDelegate *) appDelegate;
-(NSInteger) displayTextLength:(NSString*)text;
@end
