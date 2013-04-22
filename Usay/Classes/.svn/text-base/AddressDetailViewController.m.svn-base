//
//  AddressDetailViewController.m
//  Nav
//
//  Created by Jong-Sung Park on 10. 6. 5..
//  Copyright 2010 inamass. All rights reserved.
//

#import "AddressDetailViewController.h"
#import "BuddyProfileViewController.h"
#import "USayDefine.h"			// sochae 2010.10.08

#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation AddressDetailViewController

@synthesize profileChange, selectedViewController, personViewController, userRPKey, userFormatted, passUserInfo;
@synthesize dtlDelegate;
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
-(void)backBarButtonClicked {
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
	NSLog(@"ADDRESSVIEW CONTROLLER");
	//[selectedViewController requestLoadSimpleProfile:self.userRPKey];
	[super viewWillAppear:animated];
}

- (void)viewDidLoad {
	
	
	NSLog(@"디테일 뷰 컨트롤러..");
	
//	if(isMemoryWarning == YES){
//		isMemoryWarning = NO;
//		[super viewDidLoad];
//		return;
//	}
//	isMemoryWarning = NO;
	//create custombutton navigationbarleftbutton
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
	
	CGRect segRect = profileChange.frame;
	segRect.size.height = 26.0f;
	segRect.size.width -= 5.0f;
	[profileChange setFrame:segRect];
	// TODO: 세그먼트 이미지 교체
	[profileChange setImage:[[UIImage imageNamed:@"btn_profile_focus.png"]stretchableImageWithLeftCapWidth:1.0 topCapHeight:0.0] forSegmentAtIndex:0];
	[profileChange setImage:[[UIImage imageNamed:@"btn_person_normal.png"]stretchableImageWithLeftCapWidth:1.0 topCapHeight:0.0] forSegmentAtIndex:1];
	[profileChange setBackgroundColor:[UIColor clearColor]];

	
//	[profileChange setTitle:@"프로필 정보" forSegmentAtIndex:0];
//	[profileChange setTitle:@"주소록 정보" forSegmentAtIndex:1];
	
	self.view.backgroundColor = ColorFromRGB(0xedeff2);

	[profileChange setSelectedSegmentIndex:0];
	[profileChange sendActionsForControlEvents:UIControlEventValueChanged];
//임시  심플프로파일..	[selectedViewController requestLoadSimpleProfile:self.userRPKey];
	[super viewDidLoad];
}

-(void)updateProfileInfo:(UserInfo*)profileValue withBeforeGroupID:(NSString*)beforeGID{
	[self.dtlDelegate updateProfileInfo:profileValue withBeforeGroupID:beforeGID];
}
-(void)blockedfileInfo:(UserInfo*)profileValue{
	[self.dtlDelegate blockBuddychange:profileValue];
}

-(void)updatePersonInfo:(UserInfo*)PersonValue{
	[self.dtlDelegate updatePersonInfo:PersonValue];
}
-(void)deletePersonInfo:(UserInfo*)PersonValue{
	[self.dtlDelegate deletePersonInfo:PersonValue];
}
 
-(void)updateBuddyCompleted {
	NSLog(@"parentView updateBuddyCompleted....");
	if(self.personViewController)
		[self.personViewController updateBuddyCompleted];
}

-(void)deleteBuddyAction {
	if(self.personViewController)
		[self.personViewController deleteBuddyAction];
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
//	isMemoryWarning = YES;
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
//	self.selectedViewController = nil;
//	self.personViewController = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[profileChange release];
	if(selectedViewController != nil)
		[selectedViewController release];
	if(personViewController != nil)
		[personViewController release];
	if(userRPKey) [userRPKey release];
	if(userFormatted)[userFormatted release];
	if(passUserInfo) [passUserInfo release];
    [super dealloc];
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result 
{
	DebugLog(@"messageComposeViewController : sms 결과? ");
	[self dismissModalViewControllerAnimated:YES];
	
	switch (result)
	{
		case MessageComposeResultCancelled:
			DebugLog(@"Result: SMS canceled");
			break;
		case MessageComposeResultSent:
			DebugLog(@"Result: SMS sent !!!");
			[JYUtil alertWithType:ALERT_SMS_SEND delegate:self];
			break;
		case MessageComposeResultFailed:
			DebugLog(@"Result: SMS failed");
			break;
		default:
			DebugLog(@"Result: SMS not sent");
			break;
	}
}

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


-(IBAction)segmentedControl:(id)sender
{
	CGRect viewBounds = [[UIScreen mainScreen]applicationFrame];
	viewBounds.origin.y = 44.0;
	
	if([sender selectedSegmentIndex] == 0)
	{
		// 프로필 정보 보기.
		viewBounds.size.height -= 86.0;
		[profileChange setImage:[[UIImage imageNamed:@"btn_profile_focus.png"]stretchableImageWithLeftCapWidth:1.0 topCapHeight:0.0] forSegmentAtIndex:0];
		[profileChange setImage:[[UIImage imageNamed:@"btn_person_normal.png"]stretchableImageWithLeftCapWidth:1.0 topCapHeight:0.0] forSegmentAtIndex:1];
		UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
		UIFont *titleFont = [UIFont systemFontOfSize:20];
		CGSize titleStringSize = [@"프로필 정보" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
		UILabel *naviTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
		[naviTitleLabel setFont:titleFont];
		naviTitleLabel.textAlignment = UITextAlignmentCenter;
		[naviTitleLabel setTextColor:ColorFromRGB(0x053844)];
		[naviTitleLabel setBackgroundColor:[UIColor clearColor]];
		[naviTitleLabel setText:@"프로필 정보"];
		[titleView addSubview:naviTitleLabel];	
		[naviTitleLabel release];
		self.navigationItem.titleView = titleView;
		[titleView release];
		self.navigationItem.titleView.frame = CGRectMake((self.view.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);
		//맨처음이면..
		if(!selectedViewController.parentController)
		{
			selectedViewController.parentController = self;
			selectedViewController.profileKey = [NSString stringWithFormat:@"%@",self.userRPKey];
			selectedViewController.userFormatted = [NSString stringWithFormat:@"%@",self.userFormatted];
			selectedViewController.profileUserData = passUserInfo;
		}//주소록 정보와 프로필 정보 데이터를 공유하기 위한 작업
		else {
			selectedViewController.profileUserData = personViewController.personInfo;
		}
		NSLog(@"프로필 정보 세팅 (RPKEY = %@)...", self.userRPKey);
		//주소록 정보뷰를 삭제한다..
		[personViewController.view removeFromSuperview];
		[self.view addSubview:selectedViewController.view];
		[selectedViewController.view setFrame:viewBounds];
	
		//클릭할때마다 프로파일을 로드한다.. 여기에서 네트워크 상황에 따라 보여지는게 느려지는듯.. 일단 쓰레드로 처리한다. 2011.02.07
		
	//	[NSThread detachNewThreadSelector:@selector(requestLoadSimpleProfileThread:) toTarget:self withObject:self.userRPKey];
		
		
		[selectedViewController requestLoadSimpleProfile:self.userRPKey];
		self.navigationItem.rightBarButtonItem = nil;
	}
	else
	{
		// 주소록 정보 보기
		[profileChange setImage:[UIImage imageNamed:@"btn_profile_normal.png"] forSegmentAtIndex:0];
		[profileChange setImage:[UIImage imageNamed:@"btn_person_focus.png"] forSegmentAtIndex:1];
		UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
		UIFont *titleFont = [UIFont systemFontOfSize:20];
		CGSize titleStringSize = [@"주소록 정보" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
		UILabel *naviTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
		[naviTitleLabel setFont:titleFont];
		naviTitleLabel.textAlignment = UITextAlignmentCenter;
		[naviTitleLabel setTextColor:ColorFromRGB(0x053844)];
		[naviTitleLabel setBackgroundColor:[UIColor clearColor]];
		[naviTitleLabel setText:@"주소록 정보"];
		[titleView addSubview:naviTitleLabel];	
		[naviTitleLabel release];
		self.navigationItem.titleView = titleView;
		[titleView release];
		self.navigationItem.titleView.frame = CGRectMake((self.view.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);
		viewBounds.size.height -= 86.0;
		//맨 처음 들어오는 거라면.
		if(!personViewController)
		{
			personViewController = [[BuddyPersonViewController alloc] initWithStyle:UITableViewStyleGrouped];
			personViewController.parentController = self;
			personViewController.personDelegate = self;
			personViewController.personInfo = self.passUserInfo;
		}
		else {
		//	personViewController.personInfo = selectedViewController.profileUserData;
			[personViewController createRightButton];
		}
		[selectedViewController.view removeFromSuperview];
		[self.view addSubview:personViewController.view];
		[personViewController.tableView setFrame:viewBounds];
	}
	
}

@end
