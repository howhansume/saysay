//
//  InsertMyInfoSettingViewController.h
//  USayApp
//
//  Created by 1team on 10. 7. 21..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <UIKit/UIKit.h>

enum InsertMySettingType
{
	MobilePhoneType = 0,
	HomePhoneType,
	OfficePhoneType,
	OrganizationType,
	HomePageUrlType,
	EmailType
};

typedef enum InsertMySettingType InsertMySettingType;

@interface InsertMyInfoSettingViewController : UIViewController <UITextFieldDelegate> {
	UIView			*contentsView;
	UITextField		*contentsTextField;
	NSString		*preContents;
	NSString		*navigationTitle;
	InsertMySettingType	inputType;
}

-(void)backBarButtonClicked;
-(void)completedClicked;
-(NSInteger) displayTextLength:(NSString*)text;

@property(nonatomic, retain)  UIView		*contentsView;
@property(nonatomic, retain)  UITextField	*contentsTextField;
@property(nonatomic, retain)  NSString		*preContents;
@property(readwrite)  InsertMySettingType	inputType;
@property(nonatomic, assign) NSString		*navigationTitle;

@end
