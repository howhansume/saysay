//
//  CertificationViewController.h
//  USayApp
//
//  Created by Jong-Sung Park on 10. 5. 24..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <UIKit/UIKit.h>

@class USayAppAppDelegate;
@class blockView;
@interface CertificationViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIAlertViewDelegate> {
	NSString* phoneNumber;
	blockView* certiblockView;
	UIButton *nationalCode;
	UIButton *national;
}
@property (nonatomic, retain) UIButton *nationalCode, *national;
@property (nonatomic, retain) NSString* phoneNumber;
-(USayAppAppDelegate *) appDelegate;
-(void)codeName:(NSString*)name codeNum:(NSString*)number;
//-(NSInteger) displayTextLength:(NSString*)text;
@end