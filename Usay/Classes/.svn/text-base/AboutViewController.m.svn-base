    //
//  AboutViewController.m
//  USayApp
//
//  Created by 1team on 10. 8. 5..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "AboutViewController.h"
#import "MyDeviceClass.h"
#import <CommonCrypto/CommonDigest.h>

#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
								green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
								blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define ID_LOGOIMAGEVIEW	6000
#define ID_LINEIMAGEVIEW	6001
#define ID_VERSION			6002
#define ID_HELP				6003
#define ID_COMPANY			6004
#define ID_HELPBTN			6005

@implementation AboutViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

-(NSString*) md5:(NSString *)str
{
	const char *cStr = [str UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	
	CC_MD5(cStr, strlen(cStr), result);
	
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
						  result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];
	
//    return [diskCachePath stringByAppendingPathComponent:filename];
}

- (NSString*)md5HexDigest:(NSString*)input {
	const char* str = [input UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5(str, strlen(str), result);
	
	NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
	for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
		[ret appendFormat:@"%02x",result[i]];
	}
	return ret;
}

-(void)backBarButtonClicked 
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)helpBtnClicked:(id)sender
{
	UIActionSheet *menu = nil;
	if ( [[[UIDevice currentDevice] model] isEqualToString:@"iPhone"] ) {
		menu = [[[UIActionSheet alloc] initWithTitle:@"문의" 
										   delegate:self
								  cancelButtonTitle:@"취소"
							 destructiveButtonTitle:nil
								  otherButtonTitles:@"Usay@paran.com", @"1588-5668", nil] autorelease];
	} else {
		menu = [[[UIActionSheet alloc] initWithTitle:@"문의" 
										   delegate:self
								  cancelButtonTitle:@"취소"
							 destructiveButtonTitle:nil
								  otherButtonTitles:@"Usay@paran.com", nil] autorelease];
	}

	[menu showInView:self.view];
}

//*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {

	// sochae 2010.09.11 - UI Position
	//CGRect rect = [MyDeviceClass deviceOrientation];
	CGRect rect = [[UIScreen mainScreen] applicationFrame];
	// ~sochae
	
	//내비게이션 바 버튼 설정
	if (rect.size.width < rect.size.height) {
		UIImage* leftBarBtnImg = [UIImage imageNamed:@"btn_top_left.png"];
		UIImage* leftBarBtnSelImg = [UIImage imageNamed:@"btn_top_left_focus.png"];
		UIButton* leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[leftBarButton addTarget:self action:@selector(backBarButtonClicked) forControlEvents:UIControlEventTouchUpInside];
		[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
		[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateSelected];
		leftBarButton.frame = CGRectMake(0.0, 0.0, leftBarBtnImg.size.width, leftBarBtnImg.size.height);	
		UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
		self.navigationItem.leftBarButtonItem = leftButton;
		[leftButton release];
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
	}

	UIView *contentsView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	contentsView.backgroundColor = ColorFromRGB(0xedeff2);
	self.view = contentsView;
	[contentsView release];
}
//*/

//*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	//여러번 와따갔다 하면 죽는다 강제로 숫자 박아줘야함..
//	UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
	UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
	UIFont *titleFont = [UIFont systemFontOfSize:20];
	CGSize titleStringSize = [@"Usay 주소록 정보" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
	UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
	[titleLabel setFont:titleFont];
	titleLabel.textAlignment = UITextAlignmentCenter;
	[titleLabel setTextColor:ColorFromRGB(0x053844)];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	[titleLabel setText:@"Usay 주소록 정보"];
	[titleView addSubview:titleLabel];	
	[titleLabel release];
	self.navigationItem.titleView = titleView;
	[titleView release];
	self.navigationItem.titleView.frame = CGRectMake((self.view.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);

	// sochae 2010.09.11 - UI Position
	//CGRect rect = [MyDeviceClass deviceOrientation];
	CGRect rect = self.view.frame;
	// ~sochae
	
	if (rect.size.width < rect.size.height)	
	{
		// 세로보기
		UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_about.png"]];
		logoImageView.backgroundColor = [UIColor clearColor];
		logoImageView.frame = CGRectMake((rect.size.width-180.0)/2.0, 44.0, 180.0, 72.0);
		logoImageView.tag = ID_LOGOIMAGEVIEW;
		[self.view addSubview:logoImageView];
		[logoImageView release];
		
		UIImageView *lineImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"img_aboutline_bg.png"] stretchableImageWithLeftCapWidth:8 topCapHeight:52]];
		lineImageView.backgroundColor = [UIColor clearColor];
		lineImageView.frame = CGRectMake(38, 152.0, rect.size.width-76.0, 192.0);
		lineImageView.tag = ID_LINEIMAGEVIEW;
		[self.view addSubview:lineImageView];
		[lineImageView release];
		
		UILabel *versionLabel = [[UILabel alloc] init];
		versionLabel.backgroundColor = [UIColor clearColor];
		UIFont *versionFont = [UIFont fontWithName:@"Helvetica" size:15.0f];	//[UIFont systemFontOfSize:15];
		CGSize versionStringSize = [[NSString stringWithFormat:@"Ver %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]] sizeWithFont:versionFont constrainedToSize:(CGSizeMake(100.0f, 20.0f))];
		versionLabel.font = versionFont;
		versionLabel.tag = ID_VERSION;
		versionLabel.frame = CGRectMake((rect.size.width-versionStringSize.width)/2.0, 170.0, versionStringSize.width, versionStringSize.height);
		versionLabel.textColor = ColorFromRGB(0x313b48);
		versionLabel.text = [NSString stringWithFormat:@"Ver %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
		[self.view addSubview:versionLabel];
		[versionLabel release];
		
		UIImageView *helpImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"text_help.png"]];
		helpImageView.backgroundColor = [UIColor clearColor];
		// sochae 2010.09.11 - UI Position
		//helpImageView.frame = CGRectMake((rect.size.width-168.0)/2.0, rect.size.height - 162.0, 168.0, 33.0);
		helpImageView.frame = CGRectMake((rect.size.width-168.0)/2.0, rect.size.height - 202.0, 168.0, 33.0);
		// ~sochae
		helpImageView.tag = ID_HELP;
		[self.view addSubview:helpImageView];
		[helpImageView release];
		
		UIButton *helpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		[helpBtn addTarget:self action:@selector(helpBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
		[helpBtn setBackgroundColor:[UIColor clearColor]];
		// sochae 2010.09.11 - 이미지와 버튼을 동일하게...
		//helpBtn.frame = CGRectMake((rect.size.width-168.0)/2.0, rect.size.height - 162.0, 168.0, 33.0);
		[helpBtn setFrame:helpImageView.frame];
		// ~sochae
		[self.view addSubview:helpBtn];
		helpBtn.tag = ID_HELPBTN;
		
		UIImageView *companyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"text_company.png"]];
		companyImageView.backgroundColor = [UIColor clearColor];
		// sochae 2010.09.11 - UI Position
		//companyImageView.frame = CGRectMake((rect.size.width-50.0)/2.0, rect.size.height - 44.0, 50.0, 10.0);
		companyImageView.frame = CGRectMake((rect.size.width-50.0)/2.0, self.view.frame.size.height - 80.0, 50.0, 10.0);
		// ~sochae
		companyImageView.tag = ID_COMPANY;
		[self.view addSubview:companyImageView];
		[companyImageView release];
	}
	else
	{
		// 가로보기
		UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_about.png"]];
		logoImageView.backgroundColor = [UIColor clearColor];
		logoImageView.frame = CGRectMake((rect.size.width-180.0)/2.0, 10.0, 180.0, 72.0);
		logoImageView.tag = ID_LOGOIMAGEVIEW;
		[self.view addSubview:logoImageView];
		[logoImageView release];

		UIImageView *lineImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"img_aboutline_bg.png"] stretchableImageWithLeftCapWidth:8 topCapHeight:52]];
		lineImageView.backgroundColor = [UIColor clearColor];
		lineImageView.frame = CGRectMake(38, rect.origin.y + 100.0, rect.size.width-76.0, 125.0);
		lineImageView.tag = ID_LINEIMAGEVIEW;
		[self.view addSubview:lineImageView];
		[lineImageView release];
		
		UILabel *versionLabel = [[UILabel alloc] init];
		versionLabel.backgroundColor = [UIColor clearColor];
		UIFont *versionFont = [UIFont fontWithName:@"Helvetica" size:15.0f];	//[UIFont systemFontOfSize:15];
		CGSize versionStringSize = [[NSString stringWithFormat:@"Ver %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]] sizeWithFont:versionFont constrainedToSize:(CGSizeMake(100.0f, 20.0f))];
		versionLabel.font = versionFont;
		versionLabel.frame = CGRectMake((rect.size.width-versionStringSize.width)/2.0, rect.origin.y + 118.0, versionStringSize.width, versionStringSize.height);
		versionLabel.tag = ID_VERSION;
		versionLabel.textColor = ColorFromRGB(0x313b48);
		versionLabel.text = [NSString stringWithFormat:@"Ver %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
		[self.view addSubview:versionLabel];
		[versionLabel release];
							 
		UIImageView *helpImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"text_help.png"]];
		helpImageView.backgroundColor = [UIColor clearColor];
		helpImageView.frame = CGRectMake((rect.size.width-168.0)/2.0, rect.origin.y + 170.0, 168.0, 33.0);
		helpImageView.tag = ID_HELP;
		[self.view addSubview:helpImageView];
		[helpImageView release];
		
		UIButton *helpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		[helpBtn addTarget:self action:@selector(helpBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
		[helpBtn setBackgroundColor:[UIColor clearColor]];
		// sochae 2010.09.11 - 이미지와 버튼의 좌표 동일하게...
		//helpBtn.frame = CGRectMake((rect.size.width-168.0)/2.0, rect.origin.y + 170.0, 168.0, 33.0);
		[helpBtn setFrame:helpImageView.frame];
		// ~sochae
		[self.view addSubview:helpBtn];
		helpBtn.tag = ID_HELPBTN;
		
		UIImageView *companyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"text_company.png"]];
		companyImageView.backgroundColor = [UIColor clearColor];
		companyImageView.frame = CGRectMake((rect.size.width-50.0)/2.0, rect.size.height - 25.0, 50.0, 10.0);
		companyImageView.tag = ID_COMPANY;
		[self.view addSubview:companyImageView];
		[companyImageView release];
	}
	
// sochae 2010.12.29 - clang	NSString *str = [self md5:@"1234"];
//	NSString *str1 = [self md5HexDigest:str];
}
//*/



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

-(void)wilRotation
{
	UIImageView *logoImageView = (UIImageView *)[self.view viewWithTag:ID_LOGOIMAGEVIEW];
	UIImageView *lineImageView = (UIImageView *)[self.view viewWithTag:ID_LINEIMAGEVIEW];
	UILabel *versionLabel = (UILabel *)[self.view viewWithTag:ID_VERSION];
	UIImageView *helpImageView = (UIImageView *)[self.view viewWithTag:ID_HELP];
	UIImageView *companyImageView = (UIImageView *)[self.view viewWithTag:ID_COMPANY];
	UIButton *helpBtn = (UIButton *)[self.view viewWithTag:ID_HELPBTN];
	
	
	if (logoImageView != nil && lineImageView != nil && versionLabel != nil && helpImageView != nil && companyImageView != nil) {
		// sochae 2010.09.11 - UI Position
		//CGRect rect = [MyDeviceClass deviceOrientation];
		CGRect rect = [[UIScreen mainScreen] applicationFrame];
		// ~sochae

		//내비게이션 바 버튼 설정
		UIImage* leftBarBtnImg = nil;
		UIImage* leftBarBtnSelImg = nil;
		
		if (rect.size.width < rect.size.height) {
			leftBarBtnImg = [UIImage imageNamed:@"btn_top_left.png"];
			leftBarBtnSelImg = [UIImage imageNamed:@"btn_top_left_focus.png"];
		} else {
			leftBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_left.png"];
			leftBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_left_focus.png"];
		}
		
		UIButton* leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[leftBarButton addTarget:self action:@selector(backBarButtonClicked) forControlEvents:UIControlEventTouchUpInside];
		[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
		[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateSelected];
		leftBarButton.frame = CGRectMake(0.0, 0.0, leftBarBtnImg.size.width, leftBarBtnImg.size.height);	
		UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
		self.navigationItem.leftBarButtonItem = leftButton;
		[leftButton release];
		
		if (rect.size.width < rect.size.height) {	// 세로보기
			CGRect logoImageViewFrame = logoImageView.frame;
			logoImageViewFrame.origin.x = (rect.size.width-180.0)/2.0;
			logoImageViewFrame.origin.y = 44.0;
			logoImageView.frame = logoImageViewFrame;
			
			CGRect lineImageViewFrame = lineImageView.frame;
			lineImageViewFrame.origin.y = 152.0;
			lineImageViewFrame.size.width = rect.size.width-76.0;
			lineImageViewFrame.size.height = 192.0;
			lineImageView.frame = lineImageViewFrame;
			
			UIFont *versionFont = [UIFont fontWithName:@"Helvetica" size:15.0f];	//[UIFont systemFontOfSize:15];
			CGSize versionStringSize = [[NSString stringWithFormat:@"Ver %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]] sizeWithFont:versionFont constrainedToSize:(CGSizeMake(100.0f, 20.0f))];
			CGRect versionLabelFrame = versionLabel.frame;
			versionLabelFrame.origin.x = (rect.size.width-versionStringSize.width)/2.0;
			versionLabelFrame.origin.y = 170.0;
			versionLabel.frame = versionLabelFrame;
			
			CGRect helpImageViewFrame = helpImageView.frame;
			helpImageViewFrame.origin.x = (rect.size.width-168.0)/2.0;
			helpImageViewFrame.origin.y = rect.size.height - 162.0;
			helpImageView.frame = helpImageViewFrame;
			
			CGRect helpBtnFrame = helpBtn.frame;
			helpBtnFrame.origin.x = (rect.size.width-168.0)/2.0;
			helpBtnFrame.origin.y = rect.size.height - 162.0;
			helpBtn.frame = helpBtnFrame;
			
			CGRect companyImageViewFrame = companyImageView.frame;
			companyImageViewFrame.origin.x = (rect.size.width-50.0)/2.0;
			companyImageViewFrame.origin.y = rect.size.height - 44.0;
			companyImageView.frame = companyImageViewFrame;
		} else {
			CGRect logoImageViewFrame = logoImageView.frame;
			logoImageViewFrame.origin.x = (rect.size.width-180.0)/2.0;
			logoImageViewFrame.origin.y = 10.0;
			logoImageView.frame = logoImageViewFrame;
			
			CGRect lineImageViewFrame = lineImageView.frame;
			lineImageViewFrame.origin.y = rect.origin.y + 100.0;
			lineImageViewFrame.size.width = rect.size.width-76.0;
			lineImageViewFrame.size.height = 125.0;
			lineImageView.frame = lineImageViewFrame;
			
			UIFont *versionFont = [UIFont fontWithName:@"Helvetica" size:15.0f];	//[UIFont systemFontOfSize:15];
			CGSize versionStringSize = [[NSString stringWithFormat:@"Ver %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]] sizeWithFont:versionFont constrainedToSize:(CGSizeMake(100.0f, 20.0f))];
			CGRect versionLabelFrame = versionLabel.frame;
			versionLabelFrame.origin.x = (rect.size.width-versionStringSize.width)/2.0;
			versionLabelFrame.origin.y = rect.origin.y + 118.0;
			versionLabel.frame = versionLabelFrame;
			
			CGRect helpImageViewFrame = helpImageView.frame;
			helpImageViewFrame.origin.x = (rect.size.width-168.0)/2.0;
			helpImageViewFrame.origin.y = rect.origin.y + 170.0;
			helpImageView.frame = helpImageViewFrame;
			
			CGRect helpBtnFrame = helpBtn.frame;
			helpBtnFrame.origin.x = (rect.size.width-168.0)/2.0;
			helpBtnFrame.origin.y = rect.origin.y + 170.0;
			helpBtn.frame = helpBtnFrame;
			
			CGRect companyImageViewFrame = companyImageView.frame;
			companyImageViewFrame.origin.x = (rect.size.width-50.0)/2.0;
			companyImageViewFrame.origin.y = rect.size.height - 25.0;
			companyImageView.frame = companyImageViewFrame;
		}
	}
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	switch (toInterfaceOrientation)  
    {  
        case UIDeviceOrientationPortrait: 
		{
			[self wilRotation];
		}
            break;  
        case UIDeviceOrientationLandscapeLeft:
		{
			[self wilRotation];
		}
            break;  
        case UIDeviceOrientationLandscapeRight:  
		{
			[self wilRotation];
		}
            break;  
        case UIDeviceOrientationPortraitUpsideDown:  
		{
			[self wilRotation];
		}
            break;  
		case UIDeviceOrientationFaceUp:
		{
			[self wilRotation];
		}
            break;  
		case UIDeviceOrientationFaceDown:
		{
			[self wilRotation];
		}
            break;  
		case UIDeviceOrientationUnknown:
		{
			[self wilRotation];
		}
        default:  
            break;  
    }  
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
	//	message.hidden = NO;
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			//			message.text = @"Result: canceled";
			break;
		case MFMailComposeResultSaved:
			//			message.text = @"Result: saved";
			break;
		case MFMailComposeResultSent:
			//			message.text = @"Result: sent";
			break;
		case MFMailComposeResultFailed:
			//			message.text = @"Result: failed";
			break;
		default:
			//			message.text = @"Result: not sent";
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
}
#pragma mark -

// [MyDeviceClass platformCode]
// iPhone1,1	아이폰 1세대
// iPhone1,2	아이폰 3G 모델
// iPhone2,1	아이폰 3GS 모델
// iPhone3,1	아이폰 4G 모델
// iPod1,1		아이팟 터치 1세대
// iPod2,1		아이팟 터치 2세대
#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{	
	if ( [[[UIDevice currentDevice] model] isEqualToString:@"iPhone"] ) {
		if (buttonIndex == 0) {			// 메일 Usay@paran.com
			Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
			if (mailClass != nil){
				if([mailClass canSendMail]){
					NSMutableString *messageBody = [NSMutableString stringWithFormat:@"System:%@ %@\nModel:%@\nIdentifier:%@\nDevicetoken:%@\nUsay주소록 version:%@",
													 [UIDevice currentDevice].systemName,
													 [UIDevice currentDevice].systemVersion,
													 [MyDeviceClass platformCode],
													 [self md5:[UIDevice currentDevice].uniqueIdentifier],
													 [[NSUserDefaults standardUserDefaults] objectForKey:@"devicetoken"],
													 [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
					
					MFMailComposeViewController* mailController = [[MFMailComposeViewController alloc] init];
					[mailController setToRecipients:[NSArray arrayWithObject:@"Usay@paran.com"]];
					[mailController setSubject:@"Report from Usay주소록"];
					[mailController setMessageBody:messageBody isHTML:NO];
					mailController.mailComposeDelegate = self;
					[self presentModalViewController:mailController animated:YES];
					[mailController release];
				} else {
					NSString* emailAddrStr = [[NSString stringWithString:@"mailto:Usay@paran.com"] 
											  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

					BOOL open = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:emailAddrStr]];
					if(open == NO){
						UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"메일 전송" 
																		   message:@"메일 전송 기능을 사용 하실 수 없는 \n기기 입니다." 
																		  delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
						[alertView show];
						[alertView release];
					}
				}
			}
		} else if (buttonIndex == 1) {	// 전화 1588-5668
			NSString* telno = [[NSString stringWithString:@"tel:1588-5668"] 
							   stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			
			BOOL open = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telno]];
			if(open == NO){
				UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"전화하기" 
																   message:@"전화 기능을 사용 하실 수 없는 \n기기 입니다." 
																  delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
				[alertView show];
				[alertView release];
			}
		} else if (buttonIndex == 2) {	// cancel
			
		} else {
			// skip
		}
	} else {
		if (buttonIndex == 0) {			// 메일 Usay@paran.com
			Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
			if (mailClass != nil){
				if([mailClass canSendMail]){
					NSMutableString *messageBody = [NSMutableString stringWithFormat:@"System:%@ %@\nModel:%@\nIdentifier:%@\nDevicetoken:%@\nUsay주소록 version:%@",
													[UIDevice currentDevice].systemName,
													[UIDevice currentDevice].systemVersion,
													[MyDeviceClass platformCode],
													[self md5:[UIDevice currentDevice].uniqueIdentifier],
													[[NSUserDefaults standardUserDefaults] objectForKey:@"devicetoken"],
													[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
					
					MFMailComposeViewController* mailController = [[MFMailComposeViewController alloc] init];
					[mailController setToRecipients:[NSArray arrayWithObject:@"Usay@paran.com"]];
					[mailController setSubject:@"Report from Usay주소록"];
					[mailController setMessageBody:messageBody isHTML:NO];
					mailController.mailComposeDelegate = self;
					[self presentModalViewController:mailController animated:YES];
					[mailController release];
				} else {
					NSString* emailAddrStr = [[NSString stringWithString:@"mailto:Usay@paran.com"] 
											  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
					
					BOOL open = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:emailAddrStr]];
					if(open == NO){
						UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"메일 전송" 
																		   message:@"메일 전송 기능을 사용 하실 수 없는 \n기기 입니다." 
																		  delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
						[alertView show];
						[alertView release];
					}
				}
			}
		} else if (buttonIndex == 1) {	// cancel
						
		} else {
			// skip
		}
	}
	
	//[actionSheet release];	// sochae 2010.09.11 - 튕김현상 오류
}

#pragma mark -
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
    [super dealloc];
}


@end
