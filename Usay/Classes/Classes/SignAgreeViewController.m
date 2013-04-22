    //
//  SignAgreeViewController.m
//  USayApp
//
//  Created by ku jung on 10. 9. 7..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "SignAgreeViewController.h"
#import "CertificationViewController.h"
#import "SetNickNameViewController.h"

#define HEIGHT 460-44-80

#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation SignAgreeViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


-(void)Agree
{
	if (flag == FALSE) {
		UIAlertView *agreeAlert = [[UIAlertView alloc] initWithTitle:@"가입 동의" message:@"개인정보 수집 및 이용에\n동의해주세요."
															delegate:self cancelButtonTitle:@"확인"
													 otherButtonTitles:nil, nil];
		[agreeAlert show];
		[agreeAlert release];
	}
	else
	{
		CertificationViewController *AuthViewController =[[CertificationViewController alloc] init];
		[self.navigationController pushViewController:AuthViewController animated:YES];
		//AuthViewController.navigationItem.backBarButtonItem=nil;
		self.title=@"";
		[AuthViewController release];	
	}
}

-(void)switchStatusChanged:(id)sender {
	UISwitch *control = (UISwitch*)sender;
	
	
	if(control.on == YES)
	{
		flag = TRUE;
	}
	else{
		flag = FALSE;
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	flag =FALSE;
	
	
	UIWebView *htmlView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, HEIGHT)];
//	NSString *body = @"hihihihih";
	
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"m_app" ofType:@"html"];
	NSStringEncoding encoding;
	NSError* error;
	NSString* body = [NSString stringWithContentsOfFile:filePath usedEncoding:&encoding error:&error];
	
	
	[htmlView loadHTMLString:body baseURL:nil];
//	[htmlView release];
	
	
	UISwitch *agreeSwitch =[[UISwitch alloc] initWithFrame:CGRectMake(206, HEIGHT+30, 120, 120)];
	
	
	[agreeSwitch addTarget:self action:@selector(switchStatusChanged:) forControlEvents:UIControlEventValueChanged];
	
	
	
//	self.title=@"개인정보의 수집 및 이용";
	NSLog(@"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
	
	UIImage* rightBarBtnImg = [[UIImage imageNamed:@"btn_top_next.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	UIImage* rightBarBtnSelImg = [[UIImage imageNamed:@"btn_top_next_focus.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[rightBarButton addTarget:self action:@selector(Agree) forControlEvents:UIControlEventTouchUpInside];
	[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
	[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
	rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
	self.navigationItem.rightBarButtonItem = rightButton;
	[rightButton release];
	
	
	
	UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 44)];
//	[titleView setBackgroundColor:[UIColor grayColor]];
	UIFont *titleFont = [UIFont systemFontOfSize:20];
	//CGSize titleStringSize = [@"개인정보의 수집 및 이용" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
	UILabel *naviTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 270, 44)];
	[naviTitleLabel setFont:titleFont];
	naviTitleLabel.textAlignment = UITextAlignmentCenter;
	[naviTitleLabel setTextColor:ColorFromRGB(0x053844)];
	[naviTitleLabel setBackgroundColor:[UIColor clearColor]];
	[naviTitleLabel setText:@"개인정보의 수집 및 이용"];
	[titleView addSubview:naviTitleLabel];	
	[naviTitleLabel release];
//	[naviTitleLabel sizeToFit];
	self.navigationItem.titleView = titleView;
	[titleView release];
//	[naviTitleLabel release];
	
	
	
	UILabel *agreeTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, HEIGHT+30, 150, 30)];
	
	[agreeTitle setTextColor:ColorFromRGB(0x2284ac)];
	[agreeTitle setBackgroundColor:[UIColor clearColor]];
	[agreeTitle setText:@"동의합니다"];
	[agreeTitle setFont:[UIFont systemFontOfSize:20]];
	
	
	[self.view addSubview:htmlView];
	[self.view addSubview:agreeSwitch];
	[self.view addSubview:agreeTitle];
	
	
	[self.view setBackgroundColor:ColorFromRGB(0xEDEFF2)];
	[htmlView setBackgroundColor:ColorFromRGB(0xFFFFFF)];
	
	[htmlView release];
	[agreeSwitch release];
	[agreeTitle release];
	
	
	NSInteger authInteger =[[NSUserDefaults standardUserDefaults] integerForKey:@"CertificationStatus"];
	
	
	NSLog(@"authInteger %d", authInteger);

	if(authInteger == 3)
	{
		SetNickNameViewController* nickNameController = [[SetNickNameViewController alloc] initWithStyle:UITableViewStyleGrouped];
		
		
		UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
		//		assert(titleView != nil);
		UIFont *titleFont = [UIFont systemFontOfSize:20];
		CGSize titleStringSize = [@"회원 가입 인증" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
		//		assert(titleFont != nil);
		UILabel *naviTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
		//		assert(naviTitleLabel != nil);
		[naviTitleLabel setFont:titleFont];
		naviTitleLabel.textAlignment = UITextAlignmentCenter;
		[naviTitleLabel setTextColor:ColorFromRGB(0x053844)];
		[naviTitleLabel setBackgroundColor:[UIColor clearColor]];
		[naviTitleLabel setText:@"회원 가입 인증"];
		//		naviTitleLabel.shadowColor = [UIColor whiteColor];
		[titleView addSubview:naviTitleLabel];	
		[naviTitleLabel release];
		nickNameController.navigationItem.titleView = titleView;
		[titleView release];
		nickNameController.navigationItem.titleView.frame = CGRectMake((self.view.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);
		
		
																		
																		
																		
		[self.navigationController pushViewController:nickNameController animated:NO];
		[nickNameController release];
		
	}
	
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
