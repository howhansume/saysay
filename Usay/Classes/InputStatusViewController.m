    //
//  InputStatusViewController.m
//  USayApp
//
//  Created by 1team on 10. 7. 19..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "InputStatusViewController.h"
#import "ProfileSettingViewController.h"
#import "USayHttpData.h"
#import "SayInputTextView.h"
#import "USayAppAppDelegate.h"
#import "MyDeviceClass.h"			// sochae 2010.09.10 - UI Position

#define ID_STATUSTEXTVIEW 7773
#define ID_BACKGROUNDIMAGEVIEW	7774

#define CurrentParentViewController [[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count] - 2]
#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
										green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
										blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation InputStatusViewController

@synthesize contentsView, statusTextView, preStatus, checkLengthLabel, clearBtn;

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	NSMutableString *beforeText = nil;
	if ([text isEqualToString:@"\n"]) {
		[self completedClicked];
		return NO;
	}
	
	beforeText = [NSString stringWithFormat:@"%@%@", textView.text, text];
	
	if ([self displayTextLength:beforeText] > 40) {
		return NO;
	}

	self.navigationItem.rightBarButtonItem.enabled = YES;
	
	return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{	
	NSRange range = [textView.text rangeOfString:@"\n"];
	if (range.location == NSNotFound) {
	} else {
		[statusTextView setText:[(NSMutableString*)textView.text stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
	}

	NSString	*prMsgLength = [NSString stringWithFormat:@"%i / 40 bytes", [self displayTextLength:textView.text]];
	
	UIFont *contentsFont = [UIFont boldSystemFontOfSize:13];
	CGSize contentsStringSize = [prMsgLength sizeWithFont:contentsFont constrainedToSize:(CGSizeMake(100, MAXFLOAT))];	
		
	[checkLengthLabel setText:prMsgLength];
	checkLengthLabel.frame = CGRectMake(self.view.frame.size.width - 15 - contentsStringSize.width, 5, contentsStringSize.width, contentsStringSize.height);
}


-(NSInteger) displayTextLength:(NSString*)text
{
	NSInteger textLength = [text length];
	NSInteger textLengthUTF8 = [text lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	//	NSLog(@"Counting Text Length : %d", textLength);
	NSInteger correntLength = (textLengthUTF8 - textLength)/2 + textLength;
	
	return correntLength;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	contentsView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	contentsView.backgroundColor = ColorFromRGB(0xedeff2);
	self.view = contentsView;
	[contentsView release];

	// sochae 2010.09.10 - UI Position
	//CGRect rect = [MyDeviceClass deviceOrientation];
	CGRect rect = [[UIScreen mainScreen] applicationFrame];
	// ~sochae
	
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
	[backgroundImageView setFrame:CGRectMake(10, 25, rect.size.width-20, 80)];
	[backgroundImageView release];
	
	statusTextView = [[SayInputTextView alloc] initWithFrame:CGRectMake(20, 29, rect.size.width-60, 72)];
	statusTextView.delegate = self;
	statusTextView.tag = ID_STATUSTEXTVIEW;
	statusTextView.backgroundColor = [UIColor clearColor];
	statusTextView.returnKeyType = UIReturnKeyDone;
	[statusTextView setFont:[UIFont systemFontOfSize:17]];
	statusTextView.contentInset = UIEdgeInsetsZero;
	statusTextView.showsHorizontalScrollIndicator = NO;
	statusTextView.scrollEnabled = NO;
	statusTextView.editable = YES;
	statusTextView.textColor = ColorFromRGB(0xaaacb0);
	statusTextView.contentInset = UIEdgeInsetsMake(-4, -4, 0, 0);
	statusTextView.autocapitalizationType = UITextAutocapitalizationTypeNone;
	[self.view addSubview:statusTextView];
	
	UIFont *contentsFont = [UIFont boldSystemFontOfSize:13];
	CGSize contentsStringSize = [[NSString stringWithString:@"0 / 40 bytes"] sizeWithFont:contentsFont constrainedToSize:(CGSizeMake(100, MAXFLOAT))];		

	checkLengthLabel = [[UILabel alloc] initWithFrame:CGRectMake(rect.size.width-15-contentsStringSize.width, 5, contentsStringSize.width, contentsStringSize.height)];
	[checkLengthLabel setFont:[UIFont systemFontOfSize:13]];
	[checkLengthLabel setText:@"0 / 40 bytes"];
	checkLengthLabel.backgroundColor = [UIColor clearColor];
	checkLengthLabel.textColor = [UIColor colorWithRed:40.0/255.0 green:95.0/255.0 blue:122.0/255.0 alpha:1.0f];
	[self.view addSubview:checkLengthLabel];
	
	clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[clearBtn setImage:[UIImage imageNamed:@"btn_textfield_clear.png"] forState:UIControlStateNormal];
	clearBtn.frame = CGRectMake(rect.size.width-42, 50, 30, 30);
	[clearBtn addTarget:self action:@selector(clearClicked:) forControlEvents:UIControlEventTouchUpInside];
	clearBtn.backgroundColor = [UIColor clearColor];
	[self.view addSubview:clearBtn];
}

-(void)backBarButtonClicked 
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)completedClicked
{
	if ([self displayTextLength:[statusTextView text]] > 40)
	{
		UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"오늘의 한마디 확인" message:@"오늘의 한마디는 최대 한글20자(영문40자) 입니다." delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		[statusTextView becomeFirstResponder];
		return;
	}
	
	self.navigationItem.rightBarButtonItem.enabled = NO;
	
	if ([preStatus isEqualToString:[statusTextView text]])
	{
		[self.navigationController popViewControllerAnimated:YES];
	}
	else
	{
		// 패킷전송
//		NSLog(@"completedClicked [statusTextView text] = %@", [statusTextView text]);
		NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
//		assert(bodyObject != nil);
		if ([[statusTextView text] length] > 0)
		{
			[bodyObject setObject:[statusTextView text] forKey:@"status"];
		}
		else
		{
			[bodyObject setObject:@"" forKey:@"status"];
		}
		[bodyObject setObject:[[self appDelegate] getSvcIdx] forKey:@"svcidx"];
		
		USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"updateStatus" andWithDictionary:bodyObject timeout:10] autorelease];
//		assert(data != nil);
		
		//죽는 부분 예외처리 mantis 0000172
		if(statusTextView != nil && statusTextView != NULL)
			[CurrentParentViewController insertPrMsg:[statusTextView text]];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
				
		[self.navigationController popViewControllerAnimated:YES];
	}
}

-(USayAppAppDelegate *) appDelegate
{
	return (USayAppAppDelegate *)[[UIApplication sharedApplication] delegate];
}

-(void)clearClicked:(id)sender
{
	if (statusTextView) {
		statusTextView.text = @"";
		
		if ([preStatus isEqualToString:@""]) {
			// 이전 데이터 값이 없었다면 완료버튼 현상태 그대로
		} else {
			self.navigationItem.rightBarButtonItem.enabled = YES;
		}
	}
}

//*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {	
	UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
	UIFont *titleFont = [UIFont systemFontOfSize:20];
	CGSize titleStringSize = [@"오늘의 한마디" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
	UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
	[titleLabel setFont:titleFont];
	titleLabel.textAlignment = UITextAlignmentCenter;
	[titleLabel setTextColor:ColorFromRGB(0x053844)];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	[titleLabel setText:@"오늘의 한마디"];
	[titleView addSubview:titleLabel];	
	[titleLabel release];
	self.navigationItem.titleView = titleView;
	[titleView release];
	self.navigationItem.titleView.frame = CGRectMake((self.view.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);
	
	[super viewDidLoad];

	// sochae 2010.09.10 - UI Position
	//CGRect rect = [MyDeviceClass deviceOrientation];
	CGRect rect = [[UIScreen mainScreen] applicationFrame];
	// ~sochae
	
	if (preStatus && [preStatus length] > 0) {
		statusTextView.text = preStatus;
		UIFont *contentsFont = [UIFont boldSystemFontOfSize:13];
		CGSize contentsStringSize = [[NSString stringWithFormat:@"%i / 40 bytes", [self displayTextLength:preStatus]] sizeWithFont:contentsFont constrainedToSize:(CGSizeMake(100, MAXFLOAT))];		
		[checkLengthLabel setText:[NSString stringWithFormat:@"%i / 40 bytes", [self displayTextLength:preStatus]]];
		
		checkLengthLabel.frame = CGRectMake(rect.size.width - 15 - contentsStringSize.width, 5, contentsStringSize.width, contentsStringSize.height);
	}
	 
	[statusTextView becomeFirstResponder];
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
	
	NSString *prMsgLength = [NSString stringWithFormat:@"%i / 40 bytes", [self displayTextLength:statusTextView.text]];
	UIFont *contentsFont = [UIFont boldSystemFontOfSize:13];
	CGSize contentsStringSize = [prMsgLength sizeWithFont:contentsFont constrainedToSize:(CGSizeMake(100, MAXFLOAT))];	
	
	CGRect checkLengthLabelFrame = checkLengthLabel.frame;
	checkLengthLabelFrame.origin.x = rect.size.width-15-contentsStringSize.width;
	checkLengthLabelFrame.size.width = contentsStringSize.width;
	checkLengthLabel.frame = checkLengthLabelFrame;
	
	UIImageView *backgroundImageView = (UIImageView *)[self.view viewWithTag:ID_BACKGROUNDIMAGEVIEW];
	if (backgroundImageView) {
		CGRect backgroundImageViewFrame = backgroundImageView.frame;
		backgroundImageViewFrame.size.width = rect.size.width - 20;
		backgroundImageView.frame = backgroundImageViewFrame;
	}
	
	CGRect clearBtnFrame = clearBtn.frame;
	clearBtnFrame.origin.x = rect.size.width-42;
	clearBtn.frame = clearBtnFrame;
	
	CGRect statusTextViewFrame = statusTextView.frame;
	statusTextViewFrame.size.width = rect.size.width-60;
	statusTextView.frame = statusTextViewFrame;
	
	UIImage* leftBarBtnImg = nil;
	UIImage* leftBarBtnSelImg = nil;
	UIImage* rightBarBtnImg = nil;
	UIImage* rightBarBtnSelImg = nil;
	if (rect.size.width < rect.size.height) {
		leftBarBtnImg = [UIImage imageNamed:@"btn_top_left.png"];
		leftBarBtnSelImg = [UIImage imageNamed:@"btn_top_left_focus.png"];
		rightBarBtnImg = [UIImage imageNamed:@"btn_top_complete.png"];
		rightBarBtnSelImg = [UIImage imageNamed:@"btn_top_complete_focus.png"];
	} else {
		leftBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_left.png"];
		leftBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_left_focus.png"];
		rightBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_complete.png"];
		rightBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_complete_focus.png"];
	}
	
	UIButton* leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[leftBarButton addTarget:self action:@selector(backBarButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
	[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateHighlighted];
	leftBarButton.frame = CGRectMake(0.0, 0.0, leftBarBtnImg.size.width, leftBarBtnImg.size.height);	
	UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
	self.navigationItem.leftBarButtonItem = leftButton;
	[leftButton release];
	
	UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[rightBarButton addTarget:self action:@selector(completedClicked) forControlEvents:UIControlEventTouchUpInside];
	[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
	[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
	rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
	self.navigationItem.rightBarButtonItem = rightButton;
	[rightButton release];
	
	if ([preStatus isEqualToString:[statusTextView text]]) {
		self.navigationItem.rightBarButtonItem.enabled = NO;
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
	if (statusTextView) {
		[statusTextView release];
	}
	if (preStatus) {
		[preStatus release];
	}
	
	if (checkLengthLabel) {
		[checkLengthLabel release];
	}
    [super dealloc];
}


@end
