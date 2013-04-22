//
//  InputStatusViewController.h
//  USayApp
//
//  Created by 1team on 10. 7. 19..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SayInputTextView;
@class USayAppAppDelegate;

@interface InputStatusViewController : UIViewController <UITextViewDelegate> {
	UIView				*contentsView;
	SayInputTextView	*statusTextView;
	NSString			*preStatus;
	
	UILabel				*checkLengthLabel;
	
	UIButton			*clearBtn;
}

-(void)backBarButtonClicked;
-(void)completedClicked;
-(void)clearClicked:(id)sender;
-(NSInteger) displayTextLength:(NSString*)text;
-(USayAppAppDelegate *) appDelegate;

@property(nonatomic, retain)  UIView			*contentsView;
@property(nonatomic, retain)  SayInputTextView	*statusTextView;
@property(nonatomic, retain)  NSString			*preStatus;
@property(nonatomic, retain)  UILabel			*checkLengthLabel;
@property(nonatomic, retain)  UIButton			*clearBtn;

@end
