//
//  IDRegistrationViewController.h
//  USayApp
//
//  Created by 1team on 10. 6. 1..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface IDRegistrationViewController : UIViewController <UITextFieldDelegate> {
	UILabel				*titleLabel;
	UILabel				*middleLabel;
	UITextField			*mailTextField;
	UITextField			*passwdTextField;
	UITextField			*activeField;
	
	UIView				*mainView;
	UIScrollView		*scrollView;
	UIActivityIndicatorView	*indicator;	
	IBOutlet UIButton	*registrationBtn;
	IBOutlet UIButton	*idMakeBtn;
	
	BOOL				keyboardShown;
}

-(IBAction) clicked:(id)sender;
-(IBAction) backgroundClicked:(id)sender;

- (void)registerForKeyboardNotifications;
- (void)keyboardWasShown:(NSNotification*)aNotification;
- (void)keyboardWasHidden:(NSNotification*)aNotification;

@property (nonatomic, retain) IBOutlet UILabel		*titleLabel;
@property (nonatomic, retain) IBOutlet UILabel		*middleLabel;
@property (nonatomic, retain) IBOutlet UITextField	*mailTextField;
@property (nonatomic, retain) IBOutlet UITextField	*passwdTextField;
@property (nonatomic, retain) IBOutlet UIScrollView	*scrollView;
@property (nonatomic, retain) IBOutlet UIView		*mainView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView	*indicator;

@end
