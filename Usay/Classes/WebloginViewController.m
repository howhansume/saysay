    //
//  WebloginViewController.m
//  USayApp
//
//  Created by ku jung on 10. 11. 22..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "WebloginViewController.h"
#import "USayHttpData.h"
#import "SBJSON.h"
#import "synchronizationViewController.h"
#import "USayDefine.h"

#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation WebloginViewController
@synthesize ID, PASS, flag;


synchronizationViewController *outputView;


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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.


-(void)popToRoot
{
	
	
	NSAutoreleasePool *pool =[[NSAutoreleasePool alloc] init];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"back" object:nil];
	
	[self.navigationController popToRootViewControllerAnimated:YES];
	
	
	
	[pool release];
	
	
}
-(void)pushSyncTh
{
	NSAutoreleasePool *pool =[[NSAutoreleasePool alloc] init];

		
	
	[pool release];
}
-(void)pushSync
{
	
	//쓰레드로 안하면 푸쉬할때 꼬인다...
//	NSAutoreleasePool *pool =[[NSAutoreleasePool alloc] init];	
//	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"back" object:nil];
	outputView =[[synchronizationViewController alloc] init];
	outputView.hidesBottomBarWhenPushed= YES;
	outputView.flag = 2;
	[self.navigationController pushViewController:outputView animated:YES];
	[outputView release];

//			[NSThread detachNewThreadSelector:@selector(pushSyncTh) toTarget:self withObject:nil];
	

	

//	[pool release];
	
}
/*
-(void)popView
{
	NSAutoreleasePool *pool =[[NSAutoreleasePool alloc] init];	
	[self.navigationController popViewControllerAnimated:YES];
	[pool release];
	
	
}
*/
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"back" object:nil];
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)back:(NSNotification *)notification
{
	DebugLog(@"=== web login notify");
	
	USayHttpData *data = (USayHttpData*)[notification object];
	if (data == nil) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0047)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return;
	}
	
	//	NSString *api = data.api;
	NSString *resultData = data.responseData;
	// 1. Create BSJSON parser.
	SBJSON *jsonParser = [[SBJSON alloc] init];
	// 2. Get the result dictionary from the response string.
	NSDictionary *dic = (NSDictionary*)[jsonParser objectWithString:resultData error:NULL];
	[jsonParser release];
	// 3. Show response
	// key and value type
	NSString *rtcode = [dic objectForKey:@"rtcode"];
	if ([rtcode isEqualToString:@"0"]) {	// success
		//		NSString *count = [dic objectForKey:@"count"];
		NSString *rtType = [dic objectForKey:@"rttype"];
		
		if ([rtType isEqualToString:@"map"]) {
			// Key and Dictionary as its value type
			NSDictionary *loginDic = [dic objectForKey:@"map"];
			
			DebugLog(@"loginDic = %@", [loginDic description]);
			
			
			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
			
			//웹키가 내려오면 아이디 패스워드 저장..
			if([loginDic objectForKey:@"pKey"])
			{
				// Web pKey 저장..
				//[[NSUserDefaults standardUserDefaults] setObject:[loginDic objectForKey:@"pKey"] forKey:@"webKey"];
				[JYUtil saveToUserDefaults:[loginDic objectForKey:@"pKey"] forKey:@"webKey"];
				//아이디 패스워드 저장..
				[[NSUserDefaults standardUserDefaults] setObject:ID forKey:@"usayID"];
				[[NSUserDefaults standardUserDefaults] setObject:PASS forKey:@"usayPASS"];
				
				
				NSLog(@"id = %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"usayID"]);
				NSLog(@"pass = %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"usayPASS"]);
				
				
				
				
				
				
				
				if(flag == NO)
				{
					[NSThread detachNewThreadSelector:@selector(popToRoot) toTarget:self withObject:nil];
					
					
				}
				
				
				
				else {
					NSLog(@"팝네비게이션.2222");
					[self pushSync];
					//	[NSThread detachNewThreadSelector:@selector(pushSync) toTarget:self withObject:nil];
					}

			}
		}
		
	}
	else if([rtcode isEqualToString:@"-1010"])
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" 
															message:@"Usay.net에서 회원가입 후 이용 가능합니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		alertView.delegate=self;
		[alertView show];
		[alertView release];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		
	
		return;
	}
	else if([rtcode isEqualToString:@"-1020"])
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" 
															message:@"UserID를 찾을 수 없음" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		alertView.delegate=self;
		[alertView show];
		[alertView release];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
		return;
		
	}
	else if([rtcode isEqualToString:@"-1050"])
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" 
															message:@"비밀번호를 찾을 수 없음" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		alertView.delegate=self;
		[alertView show];
		[alertView release];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
		return;
		
	}
	else if([rtcode isEqualToString:@"-8022"])
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" 
															message:@"파란에 로그인 할수 없음" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		alertView.delegate=self;
		[alertView show];
		[alertView release];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		
		return;
		
	}
	
	
	
	
	
	
}

-(void)backBarButtonClicked
{
	[self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];

	
	
	
	
	
	
	UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 44)];
	UIFont *titleFont = [UIFont systemFontOfSize:20];
	UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 210, 44)];
	[titleLabel setFont:titleFont];
	titleLabel.textAlignment = UITextAlignmentCenter;
	[titleLabel setTextColor:ColorFromRGB(0x053844)];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	[titleLabel setText:@"Usay.net 웹과 동기화"];
	[titleView addSubview:titleLabel];	
	[titleLabel release];
	self.navigationItem.titleView = titleView;
	[titleView release];
	
	
	
	UIImage* leftBarBtnImg = [UIImage imageNamed:@"btn_top_left.png"];
	UIImage* leftBarBtnSelImg = [UIImage imageNamed:@"btn_top_left_focus.png"];
	UIButton* leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[leftBarButton addTarget:self action:@selector(backBarButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
	[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateSelected];
	[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateDisabled];
	leftBarButton.frame = CGRectMake(0.0, 0.0, leftBarBtnImg.size.width, leftBarBtnImg.size.height);
	UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
	self.navigationItem.leftBarButtonItem = leftButton;
	
	
	
	
	
	
	
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(back:) name:@"back" object:nil];
	
	
	UIImageView *logoImg = [[UIImageView alloc] init];
	logoImg.image=[UIImage imageNamed:@"id_logo.png"];
	
	logoImg.frame=CGRectMake(95, 200, 127, 57);
	[self.view addSubview:logoImg];
	[logoImg release];
	
	
	
	UILabel *loginLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 257+10, 320-60, 20)];
	
	loginLabel.text=@"로그인 중입니다. 잠시만 기다려 주십시오.";
	loginLabel.font=[UIFont systemFontOfSize:13];
	[self.view addSubview:loginLabel];
	loginLabel.textAlignment=UITextAlignmentCenter;
	[loginLabel release];
	
	
	
	
	
	
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
