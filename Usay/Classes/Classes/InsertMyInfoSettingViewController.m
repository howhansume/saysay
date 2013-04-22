    //
//  InsertMyInfoSettingViewController.m
//  USayApp
//
//  Created by 1team on 10. 7. 21..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "InsertMyInfoSettingViewController.h"
#import "MyInfoSettingViewController.h"
#import "CheckPhoneNumber.h"
#import "RegexKitLite.h"
//#import "MyDeviceClass.h"			// sochae 2010.09.11 - UI Position

#define ID_CONTENTSTEXTFIELD	7779
#define ID_BACKGROUNDIMAGEVIEW	7780
#define CurrentParentViewController [[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count] - 2]
#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
										green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
										blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation InsertMyInfoSettingViewController

@synthesize contentsView, contentsTextField, preContents, inputType, navigationTitle;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
//	self.navigationItem.rightBarButtonItem.enabled = YES;
	return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
	if (![preContents isEqualToString:@""]) {
		self.navigationItem.rightBarButtonItem.enabled = YES;
	}

	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
//	self.navigationItem.rightBarButtonItem.enabled = YES;
	
	if (inputType == EmailType) {
		if ([[textField text] length] > 0) {
			// 공백 제거
			NSMutableString *pStrMail = (NSMutableString *)[[textField text] stringByReplacingOccurrencesOfString:@" " withString:@""];

			NSString *regexString = @"\\b([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})\\b";
			if ([pStrMail isMatchedByRegex:regexString]) {
				// success
			} else {
				UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"이메일 입력 확인" 
																   message:@"이메일을 다시 입력해 주세요." 
																  delegate:self 
														 cancelButtonTitle:@"확인" 
														 otherButtonTitles:nil];
				[alertView show];
				[alertView release];
				[textField becomeFirstResponder];
				return NO;
			}
		}
	}
	
	NSString *contents = [NSString stringWithString:[[textField text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
	
	if (inputType == OrganizationType) {
		if ([self displayTextLength:contents] > 20) {
			UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"소속명 확인" message:@"소속명은 최대 한글10자(영문20자) 입니다." delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
			[alertView show];
			[alertView release];
			[textField becomeFirstResponder];
			return NO;
		}
	}

	if ([preContents isEqualToString:contents]) {
		[self.navigationController popViewControllerAnimated:YES];
	} else {
		[CurrentParentViewController insertContents:contents insertType:inputType];
		[self.navigationController popViewControllerAnimated:YES];
	}
	
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	self.navigationItem.rightBarButtonItem.enabled = YES;
	
	if (inputType == MobilePhoneType || inputType == HomePhoneType || inputType == OfficePhoneType) {
		CheckPhoneNumber *checkNumber = [[[CheckPhoneNumber alloc] initMaxLength:14] autorelease];
		return [checkNumber checkTextFieldPhoneNumber:textField shouldChangeCharactersInRange:range replacementString:string];
	}

	return YES;
}

-(NSInteger) displayTextLength:(NSString*)text
{
	NSInteger textLength = [text length];
	NSInteger textLengthUTF8 = [text lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	NSInteger correntLength = (textLengthUTF8 - textLength)/2 + textLength;
	
	return correntLength;
}

-(void)backBarButtonClicked 
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)completedClicked
{
	NSString *contents = [NSString stringWithString:[[contentsTextField text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
	
	if (inputType == EmailType) {
		if ([contents length] > 0) {
			NSMutableString *pStrMail = (NSMutableString *)[[contentsTextField text] stringByReplacingOccurrencesOfString:@" " withString:@""];
			
			NSString *regexString = @"\\b([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})\\b";
			if ([pStrMail isMatchedByRegex:regexString]) {
				// success
			} else {
				UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"이메일 입력 확인" 
																   message:@"이메일을 다시 입력해 주세요." 
																  delegate:self 
														 cancelButtonTitle:@"확인" 
														 otherButtonTitles:nil];
				[alertView show];
				[alertView release];
				[contentsTextField becomeFirstResponder];
				return;
			}
		}
	} else if (inputType == OrganizationType) {
		if ([self displayTextLength:contents] > 20) {
			UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"소속명 확인" message:@"소속명은 최대 한글10자(영문20자) 입니다." delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
			[alertView show];
			[alertView release];
			[contentsTextField becomeFirstResponder];
			return;
		}
	}

	self.navigationItem.rightBarButtonItem.enabled = NO;
	
	if ([preContents isEqualToString:contents]) {
		[self.navigationController popViewControllerAnimated:YES];
	} else {
		[CurrentParentViewController insertContents:contents insertType:inputType];
		[self.navigationController popViewControllerAnimated:YES];
	}
}

//*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView 
{
	contentsView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	contentsView.backgroundColor = ColorFromRGB(0xedeff2);
	self.view = contentsView;
	[contentsView release];

	// sochae 2010.09.11 - UI Position
	//CGRect rect = [MyDeviceClass deviceOrientation];
	CGRect rect = self.view.frame;
	// ~sochae
	
	//내비게이션 바 버튼 설정
	if (rect.size.width < rect.size.height) {
		UIImage* leftBarBtnImg = [UIImage imageNamed:@"btn_top_left.png"];
		UIImage* leftBarBtnSelImg = [UIImage imageNamed:@"btn_top_left_focus.png"];
		UIButton* leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[leftBarButton addTarget:self action:@selector(backBarButtonClicked) forControlEvents:UIControlEventTouchUpInside];
		[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
		[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateHighlighted];
		leftBarButton.frame = CGRectMake(0.0, 0.0, leftBarBtnImg.size.width, leftBarBtnImg.size.height);	
		UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
		self.navigationItem.leftBarButtonItem = leftButton;
		[leftButton release];
		
		UIImage* rightBarBtnImg = [UIImage imageNamed:@"btn_top_complete.png"];
		UIImage* rightBarBtnSelImg = [UIImage imageNamed:@"btn_top_complete_focus.png"];
		UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[rightBarButton addTarget:self action:@selector(completedClicked) forControlEvents:UIControlEventTouchUpInside];
		[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
		[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
		rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
		UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
		self.navigationItem.rightBarButtonItem = rightButton;
		[rightButton release];
	} else {
		UIImage* leftBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_left.png"];
		UIImage* leftBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_left_focus.png"];
		UIButton* leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[leftBarButton addTarget:self action:@selector(backBarButtonClicked) forControlEvents:UIControlEventTouchUpInside];
		[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
		[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateSelected];
		leftBarButton.frame = CGRectMake(0.0, 0.0, leftBarBtnImg.size.width, leftBarBtnImg.size.height);	
		UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
		self.navigationItem.leftBarButtonItem = leftButton;
		[leftButton release];
		
		UIImage* rightBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_complete.png"];
		UIImage* rightBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_complete_focus.png"];
		UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[rightBarButton addTarget:self action:@selector(completedClicked) forControlEvents:UIControlEventTouchUpInside];
		[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
		[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
		rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
		UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
		self.navigationItem.rightBarButtonItem = rightButton;
		[rightButton release];
	}
	
	self.navigationItem.rightBarButtonItem.enabled = NO;
	
	UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"img_text_bg.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:20]];
//	assert(backgroundImageView != nil);
	backgroundImageView.tag = ID_BACKGROUNDIMAGEVIEW;
	[self.view addSubview:backgroundImageView];
	[backgroundImageView setFrame:CGRectMake(10, 45, rect.size.width-20, 38)];
	[backgroundImageView release];

	contentsTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 54, rect.size.width-36, 24)];
	[contentsTextField setBorderStyle:UITextBorderStyleNone];
	contentsTextField.delegate = self;
	contentsTextField.tag = ID_CONTENTSTEXTFIELD;
	contentsTextField.returnKeyType = UIReturnKeyDone;
	contentsTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
	contentsTextField.backgroundColor = [UIColor clearColor];
	[contentsTextField setFont:[UIFont systemFontOfSize:17]];
	contentsTextField.textColor = ColorFromRGB(0xaaacb0);
	contentsTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	[self.view addSubview:contentsTextField];
}
//*/

//*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
	UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
	UIFont *titleFont = [UIFont systemFontOfSize:20];
	CGSize titleStringSize = [navigationTitle sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
	UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
	[titleLabel setFont:titleFont];
	titleLabel.textAlignment = UITextAlignmentCenter;
	[titleLabel setTextColor:ColorFromRGB(0x053844)];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	[titleLabel setText:navigationTitle];
	[titleView addSubview:titleLabel];		
	[titleLabel release];
	self.navigationItem.titleView = titleView;
	[titleView release];
	self.navigationItem.titleView.frame = CGRectMake((self.view.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);
	
	if (preContents && [preContents length] > 0) {
		contentsTextField.text = preContents;
	} else {
	}

	NSString *informationString = nil;
	if (inputType == MobilePhoneType) {
		contentsTextField.keyboardType = UIKeyboardTypeNumberPad;
		informationString = @"핸드폰 번호를 입력해 주세요.";
	} else if (inputType == HomePhoneType) {
		contentsTextField.keyboardType = UIKeyboardTypeNumberPad;
		informationString = @"집전화 번호를 입력해 주세요.";
	} else if (inputType == OfficePhoneType) {
		contentsTextField.keyboardType = UIKeyboardTypeNumberPad;
		informationString = @"직장전화 번호를 입력해 주세요.";
	} else if (inputType == OrganizationType) {
		contentsTextField.keyboardType = UIKeyboardTypeDefault;
		informationString = @"소속을 입력해 주세요. 한글 최대 10자";
	} else if (inputType == HomePageUrlType) {
		contentsTextField.keyboardType = UIKeyboardTypeURL;
		informationString = @"홈페이지를 입력해 주세요.";
	} else if (inputType == EmailType) {
		contentsTextField.keyboardType = UIKeyboardTypeEmailAddress;
		informationString = @"이메일을 입력해 주세요.";
	} else {
		contentsTextField.keyboardType = UIKeyboardTypeDefault;
	}

	// sochae 2010.09.11 - UI Position
	//CGRect rect = [MyDeviceClass deviceOrientation];
	CGRect rect = self.view.frame;
	// ~sochae
	
	UIFont *informationFont = [UIFont systemFontOfSize:15];
	CGSize infoStringSize = [informationString sizeWithFont:informationFont constrainedToSize:(CGSizeMake(rect.size.width-30.0, 20.0f))];
	UILabel *informationLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 13, rect.size.width-40.0, infoStringSize.height)];
	[informationLabel setText:informationString];
	[informationLabel setFont:informationFont];
	[informationLabel setTextColor:ColorFromRGB(0x313b48)];
	[informationLabel setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview:informationLabel];
	[informationLabel release];
	
    [super viewDidLoad];
	
	[contentsTextField becomeFirstResponder];
}
//*/

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	switch (toInterfaceOrientation)  
    {  
        case UIDeviceOrientationPortrait: 
		{
			// sochae 2010.09.11 - UI Position
			//CGRect rect = [MyDeviceClass deviceOrientation];
			CGRect rect = [[UIScreen mainScreen] applicationFrame];
			// ~sochae
			
			UIImageView *backgroundImageView = (UIImageView *)[self.view viewWithTag:ID_BACKGROUNDIMAGEVIEW];
			if (backgroundImageView) {
				CGRect backgroundImageViewFrame = backgroundImageView.frame;
				backgroundImageViewFrame.size.width = rect.size.width - 20;
				backgroundImageView.frame = backgroundImageViewFrame;
			}
			CGRect contentsTextFieldFrame = contentsTextField.frame;
			contentsTextFieldFrame.size.width = rect.size.width - 36;
			contentsTextField.frame = contentsTextFieldFrame;
			
			//내비게이션 바 버튼 설정
			if (rect.size.width < rect.size.height)
			{
				UIImage* leftBarBtnImg = [UIImage imageNamed:@"btn_top_left.png"];
				UIImage* leftBarBtnSelImg = [UIImage imageNamed:@"btn_top_left_focus.png"];
				UIButton* leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
				[leftBarButton addTarget:self action:@selector(backBarButtonClicked) forControlEvents:UIControlEventTouchUpInside];
				[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
				[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateHighlighted];
				leftBarButton.frame = CGRectMake(0.0, 0.0, leftBarBtnImg.size.width, leftBarBtnImg.size.height);	
				UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
				self.navigationItem.leftBarButtonItem = leftButton;
				[leftButton release];
				
				UIImage* rightBarBtnImg = [UIImage imageNamed:@"btn_top_complete.png"];
				UIImage* rightBarBtnSelImg = [UIImage imageNamed:@"btn_top_complete_focus.png"];
				UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
				[rightBarButton addTarget:self action:@selector(completedClicked) forControlEvents:UIControlEventTouchUpInside];
				[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
				[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
				rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
				UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
				self.navigationItem.rightBarButtonItem = rightButton;
				[rightButton release];
				
				if ([preContents isEqualToString:[contentsTextField text]]) {
					self.navigationItem.rightBarButtonItem.enabled = NO;
				}
			} else {
				UIImage* leftBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_left.png"];
				UIImage* leftBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_left_focus.png"];
				UIButton* leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
				[leftBarButton addTarget:self action:@selector(backBarButtonClicked) forControlEvents:UIControlEventTouchUpInside];
				[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
				[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateSelected];
				leftBarButton.frame = CGRectMake(0.0, 0.0, leftBarBtnImg.size.width, leftBarBtnImg.size.height);	
				UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
				self.navigationItem.leftBarButtonItem = leftButton;
				[leftButton release];
				
				UIImage* rightBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_complete.png"];
				UIImage* rightBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_complete_focus.png"];
				UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
				[rightBarButton addTarget:self action:@selector(completedClicked) forControlEvents:UIControlEventTouchUpInside];
				[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
				[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
				rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
				UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
				self.navigationItem.rightBarButtonItem = rightButton;
				[rightButton release];
				
				if ([preContents isEqualToString:[contentsTextField text]]) {
					self.navigationItem.rightBarButtonItem.enabled = NO;
				}
			}
		}
            break;  
        case UIDeviceOrientationLandscapeLeft:
		{
			// sochae 2010.09.11 - UI Position
			//CGRect rect = [MyDeviceClass deviceOrientation];
			CGRect rect = [[UIScreen mainScreen] applicationFrame];
			// ~sochae

			UIImageView *backgroundImageView = (UIImageView *)[self.view viewWithTag:ID_BACKGROUNDIMAGEVIEW];
			if (backgroundImageView) {
				CGRect backgroundImageViewFrame = backgroundImageView.frame;
				backgroundImageViewFrame.size.width = rect.size.width - 20;
				backgroundImageView.frame = backgroundImageViewFrame;
			}
			CGRect contentsTextFieldFrame = contentsTextField.frame;
			contentsTextFieldFrame.size.width = rect.size.width - 36;
			contentsTextField.frame = contentsTextFieldFrame;
			
			//내비게이션 바 버튼 설정
			if (rect.size.width < rect.size.height) {
				UIImage* leftBarBtnImg = [UIImage imageNamed:@"btn_top_left.png"];
				UIImage* leftBarBtnSelImg = [UIImage imageNamed:@"btn_top_left_focus.png"];
				UIButton* leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
				[leftBarButton addTarget:self action:@selector(backBarButtonClicked) forControlEvents:UIControlEventTouchUpInside];
				[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
				[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateHighlighted];
				leftBarButton.frame = CGRectMake(0.0, 0.0, leftBarBtnImg.size.width, leftBarBtnImg.size.height);	
				UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
				self.navigationItem.leftBarButtonItem = leftButton;
				[leftButton release];
				
				UIImage* rightBarBtnImg = [UIImage imageNamed:@"btn_top_complete.png"];
				UIImage* rightBarBtnSelImg = [UIImage imageNamed:@"btn_top_complete_focus.png"];
				UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
				[rightBarButton addTarget:self action:@selector(completedClicked) forControlEvents:UIControlEventTouchUpInside];
				[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
				[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
				rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
				UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
				self.navigationItem.rightBarButtonItem = rightButton;
				[rightButton release];
				
				if ([preContents isEqualToString:[contentsTextField text]]) {
					self.navigationItem.rightBarButtonItem.enabled = NO;
				}
			} else {
				UIImage* leftBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_left.png"];
				UIImage* leftBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_left_focus.png"];
				UIButton* leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
				[leftBarButton addTarget:self action:@selector(backBarButtonClicked) forControlEvents:UIControlEventTouchUpInside];
				[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
				[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateSelected];
				leftBarButton.frame = CGRectMake(0.0, 0.0, leftBarBtnImg.size.width, leftBarBtnImg.size.height);	
				UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
				self.navigationItem.leftBarButtonItem = leftButton;
				[leftButton release];
				
				UIImage* rightBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_complete.png"];
				UIImage* rightBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_complete_focus.png"];
				UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
				[rightBarButton addTarget:self action:@selector(completedClicked) forControlEvents:UIControlEventTouchUpInside];
				[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
				[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
				rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
				UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
				self.navigationItem.rightBarButtonItem = rightButton;
				[rightButton release];
				
				if ([preContents isEqualToString:[contentsTextField text]]) {
					self.navigationItem.rightBarButtonItem.enabled = NO;
				}
			}
		}
            break;  
        case UIDeviceOrientationLandscapeRight:  
		{
			// sochae 2010.09.11 - UI Position
			//CGRect rect = [MyDeviceClass deviceOrientation];
			CGRect rect = [[UIScreen mainScreen] applicationFrame];
			// ~sochae

			UIImageView *backgroundImageView = (UIImageView *)[self.view viewWithTag:ID_BACKGROUNDIMAGEVIEW];
			if (backgroundImageView) {
				CGRect backgroundImageViewFrame = backgroundImageView.frame;
				backgroundImageViewFrame.size.width = rect.size.width - 20;
				backgroundImageView.frame = backgroundImageViewFrame;
			}
			CGRect contentsTextFieldFrame = contentsTextField.frame;
			contentsTextFieldFrame.size.width = rect.size.width - 36;
			contentsTextField.frame = contentsTextFieldFrame;
			
			//내비게이션 바 버튼 설정
			if (rect.size.width < rect.size.height) {
				UIImage* leftBarBtnImg = [UIImage imageNamed:@"btn_top_left.png"];
				UIImage* leftBarBtnSelImg = [UIImage imageNamed:@"btn_top_left_focus.png"];
				UIButton* leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
				[leftBarButton addTarget:self action:@selector(backBarButtonClicked) forControlEvents:UIControlEventTouchUpInside];
				[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
				[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateHighlighted];
				leftBarButton.frame = CGRectMake(0.0, 0.0, leftBarBtnImg.size.width, leftBarBtnImg.size.height);	
				UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
				self.navigationItem.leftBarButtonItem = leftButton;
				[leftButton release];
				
				UIImage* rightBarBtnImg = [UIImage imageNamed:@"btn_top_complete.png"];
				UIImage* rightBarBtnSelImg = [UIImage imageNamed:@"btn_top_complete_focus.png"];
				UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
				[rightBarButton addTarget:self action:@selector(completedClicked) forControlEvents:UIControlEventTouchUpInside];
				[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
				[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
				rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
				UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
				self.navigationItem.rightBarButtonItem = rightButton;
				[rightButton release];
				
				if ([preContents isEqualToString:[contentsTextField text]]) {
					self.navigationItem.rightBarButtonItem.enabled = NO;
				}
			} else {
				UIImage* leftBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_left.png"];
				UIImage* leftBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_left_focus.png"];
				UIButton* leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
				[leftBarButton addTarget:self action:@selector(backBarButtonClicked) forControlEvents:UIControlEventTouchUpInside];
				[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
				[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateSelected];
				leftBarButton.frame = CGRectMake(0.0, 0.0, leftBarBtnImg.size.width, leftBarBtnImg.size.height);	
				UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
				self.navigationItem.leftBarButtonItem = leftButton;
				[leftButton release];
				
				UIImage* rightBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_complete.png"];
				UIImage* rightBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_complete_focus.png"];
				UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
				[rightBarButton addTarget:self action:@selector(completedClicked) forControlEvents:UIControlEventTouchUpInside];
				[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
				[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
				rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
				UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
				self.navigationItem.rightBarButtonItem = rightButton;
				[rightButton release];
				
				if ([preContents isEqualToString:[contentsTextField text]]) {
					self.navigationItem.rightBarButtonItem.enabled = NO;
				}
			}
		}
            break;  
        case UIDeviceOrientationPortraitUpsideDown:  
		{
			// sochae 2010.09.11 - UI Position
			//CGRect rect = [MyDeviceClass deviceOrientation];
			CGRect rect = [[UIScreen mainScreen] applicationFrame];
			// ~sochae

			UIImageView *backgroundImageView = (UIImageView *)[self.view viewWithTag:ID_BACKGROUNDIMAGEVIEW];
			if (backgroundImageView) {
				CGRect backgroundImageViewFrame = backgroundImageView.frame;
				backgroundImageViewFrame.size.width = rect.size.width - 20;
				backgroundImageView.frame = backgroundImageViewFrame;
			}
			CGRect contentsTextFieldFrame = contentsTextField.frame;
			contentsTextFieldFrame.size.width = rect.size.width - 36;
			contentsTextField.frame = contentsTextFieldFrame;
			
			//내비게이션 바 버튼 설정
			if (rect.size.width < rect.size.height) {
				UIImage* leftBarBtnImg = [UIImage imageNamed:@"btn_top_left.png"];
				UIImage* leftBarBtnSelImg = [UIImage imageNamed:@"btn_top_left_focus.png"];
				UIButton* leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
				[leftBarButton addTarget:self action:@selector(backBarButtonClicked) forControlEvents:UIControlEventTouchUpInside];
				[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
				[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateHighlighted];
				leftBarButton.frame = CGRectMake(0.0, 0.0, leftBarBtnImg.size.width, leftBarBtnImg.size.height);	
				UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
				self.navigationItem.leftBarButtonItem = leftButton;
				[leftButton release];
				
				UIImage* rightBarBtnImg = [UIImage imageNamed:@"btn_top_complete.png"];
				UIImage* rightBarBtnSelImg = [UIImage imageNamed:@"btn_top_complete_focus.png"];
				UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
				[rightBarButton addTarget:self action:@selector(completedClicked) forControlEvents:UIControlEventTouchUpInside];
				[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
				[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
				rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
				UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
				self.navigationItem.rightBarButtonItem = rightButton;
				[rightButton release];
				
				if ([preContents isEqualToString:[contentsTextField text]]) {
					self.navigationItem.rightBarButtonItem.enabled = NO;
				}
			} else {
				UIImage* leftBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_left.png"];
				UIImage* leftBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_left_focus.png"];
				UIButton* leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
				[leftBarButton addTarget:self action:@selector(backBarButtonClicked) forControlEvents:UIControlEventTouchUpInside];
				[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
				[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateSelected];
				leftBarButton.frame = CGRectMake(0.0, 0.0, leftBarBtnImg.size.width, leftBarBtnImg.size.height);	
				UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
				self.navigationItem.leftBarButtonItem = leftButton;
				[leftButton release];
				
				UIImage* rightBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_complete.png"];
				UIImage* rightBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_complete_focus.png"];
				UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
				[rightBarButton addTarget:self action:@selector(completedClicked) forControlEvents:UIControlEventTouchUpInside];
				[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
				[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
				rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
				UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
				self.navigationItem.rightBarButtonItem = rightButton;
				[rightButton release];
				
				if ([preContents isEqualToString:[contentsTextField text]]) {
					self.navigationItem.rightBarButtonItem.enabled = NO;
				}
			}
		}
            break;  
		case UIDeviceOrientationFaceUp:
		{
			// sochae 2010.09.11 - UI Position
			//CGRect rect = [MyDeviceClass deviceOrientation];
			CGRect rect = [[UIScreen mainScreen] applicationFrame];
			// ~sochae

			UIImageView *backgroundImageView = (UIImageView *)[self.view viewWithTag:ID_BACKGROUNDIMAGEVIEW];
			if (backgroundImageView) {
				CGRect backgroundImageViewFrame = backgroundImageView.frame;
				backgroundImageViewFrame.size.width = rect.size.width - 20;
				backgroundImageView.frame = backgroundImageViewFrame;
			}
			CGRect contentsTextFieldFrame = contentsTextField.frame;
			contentsTextFieldFrame.size.width = rect.size.width - 36;
			contentsTextField.frame = contentsTextFieldFrame;
			
			//내비게이션 바 버튼 설정
			if (rect.size.width < rect.size.height) {
				UIImage* leftBarBtnImg = [UIImage imageNamed:@"btn_top_left.png"];
				UIImage* leftBarBtnSelImg = [UIImage imageNamed:@"btn_top_left_focus.png"];
				UIButton* leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
				[leftBarButton addTarget:self action:@selector(backBarButtonClicked) forControlEvents:UIControlEventTouchUpInside];
				[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
				[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateHighlighted];
				leftBarButton.frame = CGRectMake(0.0, 0.0, leftBarBtnImg.size.width, leftBarBtnImg.size.height);	
				UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
				self.navigationItem.leftBarButtonItem = leftButton;
				[leftButton release];
				
				UIImage* rightBarBtnImg = [UIImage imageNamed:@"btn_top_complete.png"];
				UIImage* rightBarBtnSelImg = [UIImage imageNamed:@"btn_top_complete_focus.png"];
				UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
				[rightBarButton addTarget:self action:@selector(completedClicked) forControlEvents:UIControlEventTouchUpInside];
				[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
				[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
				rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
				UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
				self.navigationItem.rightBarButtonItem = rightButton;
				[rightButton release];
				
				if ([preContents isEqualToString:[contentsTextField text]]) {
					self.navigationItem.rightBarButtonItem.enabled = NO;
				}
			} else {
				UIImage* leftBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_left.png"];
				UIImage* leftBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_left_focus.png"];
				UIButton* leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
				[leftBarButton addTarget:self action:@selector(backBarButtonClicked) forControlEvents:UIControlEventTouchUpInside];
				[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
				[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateSelected];
				leftBarButton.frame = CGRectMake(0.0, 0.0, leftBarBtnImg.size.width, leftBarBtnImg.size.height);	
				UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
				self.navigationItem.leftBarButtonItem = leftButton;
				[leftButton release];
				
				UIImage* rightBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_complete.png"];
				UIImage* rightBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_complete_focus.png"];
				UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
				[rightBarButton addTarget:self action:@selector(completedClicked) forControlEvents:UIControlEventTouchUpInside];
				[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
				[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
				rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
				UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
				self.navigationItem.rightBarButtonItem = rightButton;
				[rightButton release];
				
				if ([preContents isEqualToString:[contentsTextField text]]) {
					self.navigationItem.rightBarButtonItem.enabled = NO;
				}
			}
		}
            break;  
		case UIDeviceOrientationFaceDown:
		{
			// sochae 2010.09.11 - UI Position
			//CGRect rect = [MyDeviceClass deviceOrientation];
			CGRect rect = [[UIScreen mainScreen] applicationFrame];
			// ~sochae

			UIImageView *backgroundImageView = (UIImageView *)[self.view viewWithTag:ID_BACKGROUNDIMAGEVIEW];
			if (backgroundImageView) {
				CGRect backgroundImageViewFrame = backgroundImageView.frame;
				backgroundImageViewFrame.size.width = rect.size.width - 20;
				backgroundImageView.frame = backgroundImageViewFrame;
			}
			CGRect contentsTextFieldFrame = contentsTextField.frame;
			contentsTextFieldFrame.size.width = rect.size.width - 36;
			contentsTextField.frame = contentsTextFieldFrame;
			
			//내비게이션 바 버튼 설정
			if (rect.size.width < rect.size.height) {
				UIImage* leftBarBtnImg = [UIImage imageNamed:@"btn_top_left.png"];
				UIImage* leftBarBtnSelImg = [UIImage imageNamed:@"btn_top_left_focus.png"];
				UIButton* leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
				[leftBarButton addTarget:self action:@selector(backBarButtonClicked) forControlEvents:UIControlEventTouchUpInside];
				[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
				[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateHighlighted];
				leftBarButton.frame = CGRectMake(0.0, 0.0, leftBarBtnImg.size.width, leftBarBtnImg.size.height);	
				UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
				self.navigationItem.leftBarButtonItem = leftButton;
				[leftButton release];
				
				UIImage* rightBarBtnImg = [UIImage imageNamed:@"btn_top_complete.png"];
				UIImage* rightBarBtnSelImg = [UIImage imageNamed:@"btn_top_complete_focus.png"];
				UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
				[rightBarButton addTarget:self action:@selector(completedClicked) forControlEvents:UIControlEventTouchUpInside];
				[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
				[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
				rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
				UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
				self.navigationItem.rightBarButtonItem = rightButton;
				[rightButton release];
				
				if ([preContents isEqualToString:[contentsTextField text]]) {
					self.navigationItem.rightBarButtonItem.enabled = NO;
				}
			} else {
				UIImage* leftBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_left.png"];
				UIImage* leftBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_left_focus.png"];
				UIButton* leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
				[leftBarButton addTarget:self action:@selector(backBarButtonClicked) forControlEvents:UIControlEventTouchUpInside];
				[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
				[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateSelected];
				leftBarButton.frame = CGRectMake(0.0, 0.0, leftBarBtnImg.size.width, leftBarBtnImg.size.height);	
				UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
				self.navigationItem.leftBarButtonItem = leftButton;
				[leftButton release];
				
				UIImage* rightBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_complete.png"];
				UIImage* rightBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_complete_focus.png"];
				UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
				[rightBarButton addTarget:self action:@selector(completedClicked) forControlEvents:UIControlEventTouchUpInside];
				[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
				[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
				rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
				UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
				self.navigationItem.rightBarButtonItem = rightButton;
				[rightButton release];
				
				if ([preContents isEqualToString:[contentsTextField text]]) {
					self.navigationItem.rightBarButtonItem.enabled = NO;
				}
			}
		}
            break;  
		case UIDeviceOrientationUnknown:
		{
			// sochae 2010.09.11 - UI Position
			//CGRect rect = [MyDeviceClass deviceOrientation];
			CGRect rect = [[UIScreen mainScreen] applicationFrame];
			// ~sochae

			UIImageView *backgroundImageView = (UIImageView *)[self.view viewWithTag:ID_BACKGROUNDIMAGEVIEW];
			if (backgroundImageView) {
				CGRect backgroundImageViewFrame = backgroundImageView.frame;
				backgroundImageViewFrame.size.width = rect.size.width - 20;
				backgroundImageView.frame = backgroundImageViewFrame;
			}
			CGRect contentsTextFieldFrame = contentsTextField.frame;
			contentsTextFieldFrame.size.width = rect.size.width - 36;
			contentsTextField.frame = contentsTextFieldFrame;
			
			//내비게이션 바 버튼 설정
			if (rect.size.width < rect.size.height) {
				UIImage* leftBarBtnImg = [UIImage imageNamed:@"btn_top_left.png"];
				UIImage* leftBarBtnSelImg = [UIImage imageNamed:@"btn_top_left_focus.png"];
				UIButton* leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
				[leftBarButton addTarget:self action:@selector(backBarButtonClicked) forControlEvents:UIControlEventTouchUpInside];
				[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
				[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateHighlighted];
				leftBarButton.frame = CGRectMake(0.0, 0.0, leftBarBtnImg.size.width, leftBarBtnImg.size.height);	
				UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
				self.navigationItem.leftBarButtonItem = leftButton;
				[leftButton release];
				
				UIImage* rightBarBtnImg = [UIImage imageNamed:@"btn_top_complete.png"];
				UIImage* rightBarBtnSelImg = [UIImage imageNamed:@"btn_top_complete_focus.png"];
				UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
				[rightBarButton addTarget:self action:@selector(completedClicked) forControlEvents:UIControlEventTouchUpInside];
				[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
				[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
				rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
				UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
				self.navigationItem.rightBarButtonItem = rightButton;
				[rightButton release];
				
				if ([preContents isEqualToString:[contentsTextField text]]) {
					self.navigationItem.rightBarButtonItem.enabled = NO;
				}
			} else {
				UIImage* leftBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_left.png"];
				UIImage* leftBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_left_focus.png"];
				UIButton* leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
				[leftBarButton addTarget:self action:@selector(backBarButtonClicked) forControlEvents:UIControlEventTouchUpInside];
				[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
				[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateSelected];
				leftBarButton.frame = CGRectMake(0.0, 0.0, leftBarBtnImg.size.width, leftBarBtnImg.size.height);	
				UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
				self.navigationItem.leftBarButtonItem = leftButton;
				[leftButton release];
				
				UIImage* rightBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_complete.png"];
				UIImage* rightBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_complete_focus.png"];
				UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
				[rightBarButton addTarget:self action:@selector(completedClicked) forControlEvents:UIControlEventTouchUpInside];
				[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
				[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
				rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
				UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
				self.navigationItem.rightBarButtonItem = rightButton;
				[rightButton release];
				
				if ([preContents isEqualToString:[contentsTextField text]]) {
					self.navigationItem.rightBarButtonItem.enabled = NO;
				}
			}
		}
        default:  
            break;  
    }  
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	if (contentsTextField) {
		[contentsTextField release];
	}
	
    [super dealloc];
}


@end
