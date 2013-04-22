//
//  InputNickNameViewController.h
//  USayApp
//
//  Created by 1team on 10. 7. 19..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <UIKit/UIKit.h>

@class USayAppAppDelegate;
@interface InputNickNameViewController : UIViewController <UITextFieldDelegate> {
	UIView			*contentsView;
	UITextField		*nickNameTextField;
	NSString		*preNickName;
}

-(USayAppAppDelegate *) appDelegate;
-(void)backBarButtonClicked;
-(void)completedClicked;
-(NSInteger) displayTextLength:(NSString*)text;

@property(nonatomic, retain)  UIView		*contentsView;
@property(nonatomic, retain)  UITextField	*nickNameTextField;
@property(nonatomic, retain)  NSString		*preNickName;


@end
