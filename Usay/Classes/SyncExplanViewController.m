    //
//  SyncExplanViewController.m
//  USayApp
//
//  Created by ku jung on 11. 1. 25..
//  Copyright 2011 INAMASS.NET. All rights reserved.
//

#import "SyncExplanViewController.h"
#import "LoginViewController.h"
#import "USayAppAppDelegate.h"


@implementation SyncExplanViewController

extern BOOL LOGINSUCESS;



#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

-(USayAppAppDelegate *)appDelegate
{
	return (USayAppAppDelegate *)[[UIApplication sharedApplication] delegate];
}

-(void)goLogin
{

	
	if(LOGINSUCESS != YES)
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"네트워크 연결상태가 좋지 않습니다.\n 3G 또는 Wi-Fi의 접속상태를 확인후 \n Usay주소록을 다시 실행해주세요" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return;
	}
	
	LoginViewController *loginMain = [[LoginViewController alloc] init];
	loginMain.hidesBottomBarWhenPushed=YES;
	loginMain.flag=YES;
	[self.navigationController pushViewController:loginMain animated:YES];	
	[loginMain release];
}
-(void)backBarButtonClicked
{
	[self.navigationController popViewControllerAnimated:YES];
}
-(void)makeTitle
{
	UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
	UIFont *titleFont = [UIFont systemFontOfSize:20];
	CGSize titleStringSize;
	titleStringSize  = [@"Usay.net주소록" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
	UILabel *naviTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
	[naviTitleLabel setFont:titleFont];
	naviTitleLabel.textAlignment = UITextAlignmentCenter;
	[naviTitleLabel setTextColor:ColorFromRGB(0x053844)];
	[naviTitleLabel setBackgroundColor:[UIColor clearColor]];
	[naviTitleLabel setText:@"Usay.net주소록"];

	[titleView addSubview:naviTitleLabel];	
	[naviTitleLabel release];
	self.navigationItem.titleView = titleView;
	[titleView release];
	self.navigationItem.titleView.frame = CGRectMake((320-titleStringSize.width-96)/2, 12.0, titleStringSize.width, titleStringSize.height);
	
	
	
}
-(void)makeLeftButton
{
	UIImage* leftBarBtnImg = [UIImage imageNamed:@"btn_top_left.png"];
	UIImage* leftBarBtnSelImg = [UIImage imageNamed:@"btn_top_left_focus.png"];
	UIButton* leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[leftBarButton addTarget:self action:@selector(backBarButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
	[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateSelected];
	[leftBarButton setImage:[UIImage imageNamed:@"empty"] forState:UIControlStateDisabled];
	leftBarButton.frame = CGRectMake(0.0, 0.0, leftBarBtnImg.size.width, leftBarBtnImg.size.height);
	UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
	self.navigationItem.backBarButtonItem=nil;
	self.navigationItem.leftBarButtonItem = leftButton;
}

-(void)makeRightButton
{
	UIImage* RightBarBtnImg = [UIImage imageNamed:@"btn_servicestart.png"];
	UIButton* RightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[RightBarButton addTarget:self action:@selector(goLogin) forControlEvents:UIControlEventTouchUpInside];
	[RightBarButton setImage:RightBarBtnImg forState:UIControlStateNormal];
	RightBarButton.frame = CGRectMake(0.0, 0.0, RightBarBtnImg.size.width, RightBarBtnImg.size.height);
	UIBarButtonItem *RightButton = [[UIBarButtonItem alloc] initWithCustomView:RightBarButton];
	self.navigationItem.rightBarButtonItem = RightButton;
	
	
	if([self appDelegate].connectionType == -1)
	{
		[RightButton setEnabled:NO];
	}
	else {
		[RightButton setEnabled:YES];
	}

	
	[RightButton release];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	//[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"sync_bg.png"]]];
	
	UIImageView *BackGroundImg =[[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 535)] autorelease];
	UIScrollView *BackScrollView =[[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 480-20-44)] autorelease];
	BackScrollView.contentSize=CGSizeMake(320, 535);
	[BackGroundImg setImage:[UIImage imageNamed:@"sync_bg.png"]];
	[BackScrollView addSubview:BackGroundImg];
	[self.view addSubview:BackScrollView];
	
	
	UILabel *firstLabel =[[[UILabel alloc] initWithFrame:CGRectMake(21, 353, 278, 48)] autorelease];
	firstLabel.font=[UIFont systemFontOfSize:12.0f];
	firstLabel.text= @"Usay.net에 백업한 주소록은 넓은 PC 화면으로\n확인 및 관리를 편리하게 이용하실 수 있습니다.";
	[firstLabel setBackgroundColor:[UIColor clearColor]];
	firstLabel.lineBreakMode=YES;
	firstLabel.numberOfLines=2;
	firstLabel.textColor=ColorFromRGB(0x666666);
	[BackScrollView addSubview:firstLabel];
	
	
	
	UILabel *secodLabel =[[[UILabel alloc] initWithFrame:CGRectMake(21, 445, 290, 72)] autorelease];
	secodLabel.font=[UIFont systemFontOfSize:12.0f];
	secodLabel.text=@"휴대폰을 잃어버리거나 실수로 주소록데이터를 모두\n삭제했어도, Usay.net에 백업이 되어 있다면 주소록을\n언제든지 복구하여 사용하실 수 있습니다.";
	[secodLabel setBackgroundColor:[UIColor clearColor]];
	secodLabel.lineBreakMode=YES;
	secodLabel.numberOfLines=3;
	secodLabel.textColor=ColorFromRGB(0x666666);
	[BackScrollView addSubview:secodLabel];
	
	//배그라운드 컬러 설정.
	self.view.backgroundColor=ColorFromRGB(0xF1F3F5);	
	
	
								 
	[self makeTitle];
	[self makeRightButton];
	[self makeLeftButton];
	
	
	



}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
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
