    //
//  InputNickNameViewController.m
//  USayApp
//
//  Created by 1team on 10. 7. 19..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "InputNickNameViewController.h"
#import "ProfileSettingViewController.h"
#import "USayHttpData.h"
#import "USayAppAppDelegate.h"
//#import "MyDeviceClass.h"		// sochae 2010.09.10 - UI Position

#define ID_NICKNAMETEXTFIELD	7772
#define ID_BACKGROUNDIMAGEVIEW	7773
#define CurrentParentViewController [[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count] - 2]
#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
										green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
										blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation InputNickNameViewController

@synthesize contentsView, nickNameTextField, preNickName;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	NSString *nickName = [NSString stringWithString:[[textField text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
	
	if (nickName == nil) {
		UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"별명 확인" message:@"별명은 최소 영문1자 입니다." delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		[textField becomeFirstResponder];
		return NO;
	}

	if ([self displayTextLength:nickName] > 20) {
		UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"별명 확인" message:@"별명은 최대 한글10자(영문20자) 입니다." delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		[textField becomeFirstResponder];
		return NO;
	} else if ([self displayTextLength:nickName] == 0) {
		UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"별명 확인" message:@"별명은 최소 영문1자 입니다." delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		[textField becomeFirstResponder];
		return NO;
	}

	self.navigationItem.rightBarButtonItem.enabled = NO;
	
	if ([preNickName isEqualToString:[nickNameTextField text]]) {
		// skip
		[self.navigationController popViewControllerAnimated:YES];
	} else {
		// 팻킷 전송
		NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
		if ([[textField text] length] > 0) {
			[bodyObject setObject:nickName forKey:@"nickName"];
		} else {
			[bodyObject setObject:@"" forKey:@"nickName"];
		}
		[bodyObject setObject:[[self appDelegate] getSvcIdx] forKey:@"svcidx"];
		USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"updateNickName" andWithDictionary:bodyObject timeout:10] autorelease];
		
		[CurrentParentViewController insertNickName:nickName];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
		
		[self.navigationController popViewControllerAnimated:YES];
	}

	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	self.navigationItem.rightBarButtonItem.enabled = YES;
	
	return YES;
}

-(NSInteger) displayTextLength:(NSString*)text
{
	NSInteger textLength = [text length];
	NSInteger textLengthUTF8 = [text lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	NSInteger correntLength = (textLengthUTF8 - textLength)/2 + textLength;
	
	return correntLength;
}

//*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	
	// sochae 2010.09.10 - UI Position
	//CGRect rect = [MyDeviceClass deviceOrientation];
	CGRect rect = [[UIScreen mainScreen] applicationFrame];
	// ~sochae
	
	contentsView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	contentsView.backgroundColor = ColorFromRGB(0xedeff2);
	self.view = contentsView;
	[contentsView release];
	
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
	backgroundImageView.tag = ID_BACKGROUNDIMAGEVIEW;
	[self.view addSubview:backgroundImageView];
	[backgroundImageView setFrame:CGRectMake(10, 45, rect.size.width-20, 38)];
	[backgroundImageView release];
	
	nickNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 54, rect.size.width-36, 24)];
	[nickNameTextField setBorderStyle:UITextBorderStyleNone];
	nickNameTextField.delegate = self;
	nickNameTextField.tag = ID_NICKNAMETEXTFIELD;
	nickNameTextField.placeholder = @"별명 한글 최대 10자";
	nickNameTextField.returnKeyType = UIReturnKeyDone;
	nickNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
	nickNameTextField.backgroundColor = [UIColor clearColor];
	[nickNameTextField setFont:[UIFont systemFontOfSize:17]];
	nickNameTextField.textColor = ColorFromRGB(0xaaacb0);
	nickNameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	[self.view addSubview:nickNameTextField];
}


-(void)backBarButtonClicked 
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)completedClicked
{
	NSString *nickName = [NSString stringWithString:[[nickNameTextField text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];

	if (nickName == nil) {
		UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"별명 확인" message:@"별명은 최소 영문1자 입니다." delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		[nickNameTextField becomeFirstResponder];
		return;
	}
	if ([self displayTextLength:nickName] > 20) {
		UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"별명 확인" message:@"별명은 최대 한글10자(영문20자) 입니다." delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		[nickNameTextField becomeFirstResponder];
		return;
	} else if ([self displayTextLength:nickName] == 0) {
		UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"별명 확인" message:@"별명은 최소 영문1자 입니다." delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		[nickNameTextField becomeFirstResponder];
		return;
	}
	
	self.navigationItem.rightBarButtonItem.enabled = NO;
	
	
	if ([preNickName isEqualToString:nickName]) {
		[self.navigationController popViewControllerAnimated:YES];
	} else {
		// 팻킷 전송
		NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
		if ([nickName length] > 0) {
			[bodyObject setObject:nickName forKey:@"nickName"];
		} else {
			[bodyObject setObject:@"" forKey:@"nickName"];
		}
		[bodyObject setObject:[[self appDelegate] getSvcIdx] forKey:@"svcidx"];
		USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"updateNickName" andWithDictionary:bodyObject timeout:10] autorelease];
		
		[CurrentParentViewController insertNickName:nickName];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];

		[self.navigationController popViewControllerAnimated:YES];
	}
}

- (USayAppAppDelegate *) appDelegate
{
	return (USayAppAppDelegate *)[[UIApplication sharedApplication] delegate];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {	
	// sochae 2010.09.10 - UI Position
	//CGRect rect = [MyDeviceClass deviceOrientation];
	CGRect rect = [[UIScreen mainScreen] applicationFrame];
	// ~sochae
	
	UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
	UIFont *titleFont = [UIFont systemFontOfSize:20];
	CGSize titleStringSize = [@"별명" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
	UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
	[titleLabel setFont:titleFont];
	titleLabel.textAlignment = UITextAlignmentCenter;
	[titleLabel setTextColor:ColorFromRGB(0x053844)];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	[titleLabel setText:@"별명"];
	[titleView addSubview:titleLabel];	
	[titleLabel release];
	self.navigationItem.titleView = titleView;
	[titleView release];
	self.navigationItem.titleView.frame = CGRectMake((self.view.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);
	
	UIFont *informationFont = [UIFont systemFontOfSize:15];
	CGSize infoStringSize = [@"별명을 입력해 주세요. 한글 최대 10자" sizeWithFont:informationFont constrainedToSize:(CGSizeMake(rect.size.width-30.0, 20.0f))];
	UILabel *informationLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 13, rect.size.width-40.0, infoStringSize.height)];
	[informationLabel setFont:informationFont];
	[informationLabel setTextColor:ColorFromRGB(0x313b48)];
	[informationLabel setBackgroundColor:[UIColor clearColor]];
	[informationLabel setText:@"별명을 입력해 주세요. 한글 최대 10자"];
	[self.view addSubview:informationLabel];
	[informationLabel release];
	[super viewDidLoad];
	
	if (preNickName && [preNickName length] > 0) {
		nickNameTextField.text = preNickName;
	}
    
	[nickNameTextField becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
}

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

		}
            break;  
        case UIDeviceOrientationLandscapeLeft:
		{
			
		}
            break;  
        case UIDeviceOrientationLandscapeRight:  
		{
			
		}
            break;  
        case UIDeviceOrientationPortraitUpsideDown:  
		{
			
		}
            break;  
		case UIDeviceOrientationFaceUp:
		{
			
		}
            break;  
		case UIDeviceOrientationFaceDown:
		{
			
		}
            break;  
		case UIDeviceOrientationUnknown:
		{
			
		}
        default:  
            break;  
    }  

	// sochae 2010.09.10 - UI Position
	//CGRect rect = [MyDeviceClass deviceOrientation];
	CGRect rect = [[UIScreen mainScreen] applicationFrame];
	// ~sochae
	
	UIImageView *backgroundImageView = (UIImageView *)[self.view viewWithTag:ID_BACKGROUNDIMAGEVIEW];
	if (backgroundImageView) {
		CGRect backgroundImageViewFrame = backgroundImageView.frame;
		backgroundImageViewFrame.size.width = rect.size.width - 20;
		backgroundImageView.frame = backgroundImageViewFrame;
	}
	CGRect nickNameTextFieldFrame = nickNameTextField.frame;
	nickNameTextFieldFrame.size.width = rect.size.width - 36;
	nickNameTextField.frame = nickNameTextFieldFrame;
	
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
		
		if ([preNickName isEqualToString:[nickNameTextField text]]) {
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
		
		if ([preNickName isEqualToString:[nickNameTextField text]]) {
			self.navigationItem.rightBarButtonItem.enabled = NO;
		}
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
	if (nickNameTextField) {
		[nickNameTextField release];
	}
	if (preNickName) {
		[preNickName release];
	}
    [super dealloc];
}


@end
