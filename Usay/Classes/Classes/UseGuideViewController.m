    //
//  UseGuideViewController.m
//  USayApp
//
//  Created by 1team on 10. 7. 21..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "UseGuideViewController.h"
#import "USayAppAppDelegate.h"
#import "CustomNavigationBar.h"
//#import "MyDeviceClass.h"		// sochae 2010.09.11 - UI Position

#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
										green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
										blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define ID_NAVIGATIONBAR	6000

@implementation UseGuideViewController

@synthesize isSetting;

-(id)init
{
	self = [super init];
	if (self != nil) {
		isSetting = NO;
	}
	
	return self;
}
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

//*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {

	contentsView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	contentsView.backgroundColor = [UIColor whiteColor];
	self.view = contentsView;
	
//	self.title = @"이용 가이드";
}
//*/
-(void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];

}

-(void)backBarButtonClicked 
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)serviceStart
{
	[[self appDelegate] goMain:self];
}

- (USayAppAppDelegate *)appDelegate {
	return [[UIApplication sharedApplication] delegate];
}

//*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	// sochae 2010.09.11 - UI Position
	//CGRect rect = [MyDeviceClass deviceOrientation];
	CGRect rect = [[UIScreen mainScreen] applicationFrame];
	// ~sochae

	self.view.backgroundColor = ColorFromRGB(0x8fcad9);

	if (isSetting == YES)
	{
		NSLog(@"userGudie isSetting");
		UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
		UIFont *titleFont = [UIFont systemFontOfSize:20];
		CGSize titleStringSize = [@"이용 가이드" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(rect.size.width - 120.0, 20.0f))];
		UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
		[titleLabel setFont:titleFont];
		titleLabel.textAlignment = UITextAlignmentCenter;
		[titleLabel setTextColor:ColorFromRGB(0x053844)];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[titleLabel setText:@"이용 가이드"];
		[titleView addSubview:titleLabel];		
		[titleLabel release];
		self.navigationItem.titleView = titleView;
		[titleView release];
		self.navigationItem.titleView.frame = CGRectMake((rect.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);

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
		self.navigationItem.rightBarButtonItem = nil;

		imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_useguide.png"]];
		scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
		scrollView.backgroundColor = ColorFromRGB(0xedeff2);
		// sochae 2010.09.11 - UI Position
		//scrollView.contentSize = CGSizeMake(rect.size.width, imageView.frame.size.height);	// imageView.frame.size;	// 
		scrollView.contentSize = CGSizeMake(rect.size.width, imageView.frame.size.height + 44);	// imageView.frame.size;	// 
		// ~sochae
		[scrollView addSubview:imageView];
		CGRect imageViewFrame = imageView.frame;
		imageViewFrame.origin.x = (rect.size.width-320.0)/2.0;
		imageView.frame = imageViewFrame;
		[contentsView addSubview:scrollView];
		[contentsView release];
	} else {
		NSLog(@"userGudie");
		[[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"userguide"];
		
		
		
		UINavigationBar *naviBar = nil;
		
		imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_useguide.png"]];
		scrollView.backgroundColor = ColorFromRGB(0xedeff2);
		
		naviBar = [[[CustomNavigationBar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 44.0)] autorelease];
		
		scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 44.0, self.view.frame.size.width, self.view.frame.size.height-44.0)];
		scrollView.contentSize = CGSizeMake(self.view.frame.size.width, imageView.frame.size.height);

		naviBar.tag = ID_NAVIGATIONBAR;
		
		[self.view addSubview:naviBar];

		[scrollView addSubview:imageView];
		[contentsView addSubview:scrollView];
		[contentsView release];
		contentsView = nil;
		
		UINavigationItem *naviItem = [[UINavigationItem alloc] initWithTitle:@"이용 가이드"];

		UIFont *titleFont = [UIFont systemFontOfSize:20];
		CGSize titleStringSize = [@"이용 가이드" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
		UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
		UILabel *naviTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
		[naviTitleLabel setFont:titleFont];
		naviTitleLabel.textAlignment = UITextAlignmentCenter;
		[naviTitleLabel setTextColor:ColorFromRGB(0x053844)];
		[naviTitleLabel setBackgroundColor:[UIColor clearColor]];
		[naviTitleLabel setText:@"이용 가이드"];
		[titleView addSubview:naviTitleLabel];	
		[naviTitleLabel release];
		naviItem.titleView = titleView;
		[titleView release];
		
		naviItem.titleView.frame = CGRectMake((self.view.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);
		
		[naviBar pushNavigationItem:naviItem animated:NO];

		UIImage* rightBarBtnImg = nil;
		UIImage* rightBarBtnSelImg = nil;
		
		rightBarBtnImg = [UIImage imageNamed:@"btn_servicestart.png"];
		rightBarBtnSelImg = [UIImage imageNamed:@"btn_servicestart_focus.png"];

		UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[rightBarButton addTarget:self action:@selector(serviceStart) forControlEvents:UIControlEventTouchUpInside];
		[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
		[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
		rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
		UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
		naviItem.rightBarButtonItem = rightButton;
		naviItem.leftBarButtonItem = nil;
		[rightButton release];	
		
		[naviItem release];
	}

    [super viewDidLoad];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	if (isSetting == YES) {
		return YES;
	} else {
		
	}

    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)wilRotation
{
	// sochae 2010.09.11 - UI Position
	//CGRect rect = [MyDeviceClass deviceOrientation];
	CGRect rect = [[UIScreen mainScreen] applicationFrame];
	// ~sochae
	
	//내비게이션 바 버튼 설정
	if (isSetting == YES) {
		
		CGRect scrollViewFrame = scrollView.frame;
		scrollViewFrame.size.width = rect.size.width;
		scrollViewFrame.size.height = rect.size.height;
		scrollView.frame = scrollViewFrame;
		scrollView.contentSize = CGSizeMake(rect.size.width, imageView.frame.size.height);
		
		CGRect imageViewFrame = imageView.frame;
		imageViewFrame.origin.x = (rect.size.width-320.0)/2.0;
		imageView.frame = imageViewFrame;
		
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
	} else {
		
		CustomNavigationBar *naviBar = (CustomNavigationBar *)[self.view viewWithTag:ID_NAVIGATIONBAR];
		
		CGRect scrollViewFrame = scrollView.frame;

		CGRect imageViewFrame = imageView.frame;
		imageViewFrame.origin.x = (rect.size.width-320.0)/2.0;
		imageView.frame = imageViewFrame;
		
		UIFont *titleFont = [UIFont systemFontOfSize:20];
		CGSize titleStringSize = [@"이용 가이드" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f)) lineBreakMode:UILineBreakModeTailTruncation];
		
		[naviBar topItem].titleView.frame = CGRectMake((rect.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);

		if (rect.size.width < rect.size.height) {

			scrollViewFrame.origin.y = 44.0;
			scrollViewFrame.size.width = rect.size.width;
			scrollViewFrame.size.height = rect.size.height;
			scrollView.frame = scrollViewFrame;
			scrollView.contentSize = CGSizeMake(rect.size.width, imageView.frame.size.height);

			UIImage* rightBarBtnImg = [UIImage imageNamed:@"btn_servicestart.png"];
			UIImage* rightBarBtnSelImg = [UIImage imageNamed:@"btn_servicestart_focus.png"];
			UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
			[rightBarButton addTarget:self action:@selector(serviceStart) forControlEvents:UIControlEventTouchUpInside];
			[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
			[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
			rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
			UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
			[naviBar topItem].rightBarButtonItem = rightButton;
			[naviBar topItem].leftBarButtonItem = nil;
			[rightButton release];	
			
			CGRect navigationBarFrame = naviBar.frame;
			navigationBarFrame.size.width = rect.size.width;
			navigationBarFrame.size.height = 44.0;
			naviBar.frame = navigationBarFrame;

		} else {
			scrollViewFrame.origin.y = 32.0;
			scrollViewFrame.size.width = rect.size.width;
			scrollViewFrame.size.height = rect.size.height;
			scrollView.frame = scrollViewFrame;
			scrollView.contentSize = CGSizeMake(rect.size.width, imageView.frame.size.height);

			UIImage* rightBarBtnImg = [UIImage imageNamed:@"landscape_btn_servicestart.png"];
			UIImage* rightBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_servicestart_focus.png"];
			UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
			[rightBarButton addTarget:self action:@selector(serviceStart) forControlEvents:UIControlEventTouchUpInside];
			[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
			[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
			rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
			UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
			[naviBar topItem].rightBarButtonItem = rightButton;
			[naviBar topItem].leftBarButtonItem = nil;
			[rightButton release];

			CGRect navigationBarFrame = naviBar.frame;
			navigationBarFrame.size.width = rect.size.width;
			navigationBarFrame.size.height = 32.0;
			naviBar.frame = navigationBarFrame;
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
	if (imageView) {
		[imageView release];
	}
	if (scrollView) {
		[scrollView release];
	}
    [super dealloc];
}


@end
