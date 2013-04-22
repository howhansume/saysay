    //
//  LoginViewController.m
//  USayApp
//
//  Created by ku jung on 10. 11. 19..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "LoginViewController.h"
#import "WebViewController.h"
#import "USayHttpData.h"
#import "USayAppAppDelegate.h"
#import "SBJSON.h"
#import "synchronizationViewController.h"
#import "JYUtil.h"
#import "USayDefine.h"
#import "termsViewController.h"
#import "authOkViewController.h"

#include <CoreGraphics/CoreGraphics.h>
#include <QuartzCore/QuartzCore.h>


@implementation LoginViewController
@synthesize flag, ID, PASS;
@synthesize tab01, tab02;


#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

NSString *EMAIL = nil;
NSArray *mailDomain= nil;
NSString *selectDomain = nil;
UIPickerView *DomainPicker = nil;
UIToolbar *customBar = nil;




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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
	
}

- (USayAppAppDelegate *) appDelegate
{
	return (USayAppAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	if(textField.tag==11)
	{
		ID=textField.text;
	}
	else if(textField.tag==22)
	{
		PASS=textField.text;
	}
	else {
		EMAIL = textField.text;
	}
	 
}

//키보드 변경
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	DebugLog(@"textField.text %@", textField.text);
	
	if(textField.tag == 33)
	{
		return NO;
	}
	
	
	
	[DomainPicker removeFromSuperview];
	[customBar removeFromSuperview];
	
	
	if(textField.tag==11)
	{
		ID=@"";
		textField.text=@"";
	}
	else {
		textField.text=@"";
		textField.secureTextEntry=YES;
	}

	
	return YES;
}
-(void)pushSync
{
	synchronizationViewController *outputView =[[synchronizationViewController alloc] init];
	outputView.hidesBottomBarWhenPushed= YES;
	outputView.flag = 2;
	[self.navigationController pushViewController:outputView animated:YES];
	[outputView release];
	
}

-(void)back:(NSNotification *)notification
{
//	DebugLog(@"=== web login notify");
	
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
			
		//	DebugLog(@"loginDic = %@", [loginDic description]);
			
			
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
				
				
				
				
				
				
				
				
				if(flag == NO)
				{
					[NSThread detachNewThreadSelector:@selector(popToRoot) toTarget:self withObject:nil];
					
					
				}
				
				
				
				else {
					DebugLog(@"팝네비게이션.2222");
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
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" 
															message:@"아이디/비밀번호를 확인 후 이용 바랍니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		alertView.delegate=self;
		[alertView show];
		[alertView release];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		
		return;
		
	}
	
	
	
	
	
	
}
-(void)submit
{
	
	UITextField *idField =(UITextField*)[self.view viewWithTag:11];
	UITextField *passField =(UITextField*)[self.view viewWithTag:22];
	UITextField *emailField =(UITextField*)[self.view viewWithTag:33];
	
	DebugLog(@"id = %@", idField.text);
	DebugLog(@"pass = %@", passField.text);
	DebugLog(@"email = %@", emailField.text);
	
	
	
	
	if(idField.text == NULL || passField.text == NULL || emailField.text == NULL)
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"로그인" 
															message:@"아이디 또는 패스워드를 입력하세요" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return;
	}

	
	
	
	
	
	
	
	
	
	
	
	
	
	
//	self.navigationItem.leftBarButtonItem.enabled=NO;
	
	
	
//	UIButton *tmpButton =(UIButton*)[self.view viewWithTag:0];
//	tmpButton.enabled=NO;
	
	
	NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
	ID=[NSString stringWithFormat:@"%@%@",idField.text, emailField.text];
	PASS=[NSString stringWithFormat:@"%@", passField.text];
	
	
	[[NSUserDefaults standardUserDefaults] setObject:ID forKey:@"tmpID"];
	[[NSUserDefaults standardUserDefaults] setObject:PASS forKey:@"tmpPASS"];
	
	
	DebugLog(@"PASS = %@", passField.text);
	
	[bodyObject setObject:@"ucmbip" forKey:@"svcidx"];
	[bodyObject setObject:ID forKey:@"emailAddress"];
	[bodyObject setObject:PASS forKey:@"password"];
	
	DebugLog(@"ID = %@", ID);
	
	
//	ID=idField.text;
	
	
	USayHttpData *data = [[[USayHttpData alloc] 
							initWithRequestData:@"loginOnWeb" 
							andWithDictionary:bodyObject timeout:10] autorelease];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
	
	
	
	/*
	
	loginView = [[WebloginViewController alloc] init];
	loginView.ID = ID;
	loginView.PASS = PASS;
	loginView.flag = flag;
	
	*/
	
	
	
	//푸쉬를 두번하면 안됨...
//	[self.navigationController pushViewController:loginView animated:YES];
	
	
	
	
	
	
	
}


-(void)goWeb
{
	WebViewController *webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
	if(webViewController != nil) {
		NSString *webKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"webKey"];
		
		
		webViewController.hidesBottomBarWhenPushed = YES;
		NSString *linkIdUrl = [[self appDelegate] protocolUrl:@"linkIdUrl"];
		NSMutableString *url = [[NSMutableString alloc] initWithFormat:@"%@?pKey=%@&svcidx=%@", linkIdUrl, webKey, [[self appDelegate] getSvcIdx]];
		NSMutableString *naviTitle = [[NSMutableString alloc] initWithString:@"아이디 연동"];
		webViewController.strUrl = url;
		webViewController.strTitle = naviTitle;
		[url release];
		[naviTitle release];
		[self.navigationController pushViewController:webViewController animated:YES];
		[webViewController release];
	}
	
	
}
-(void)popToRoot
{
	
	
	NSAutoreleasePool *pool =[[NSAutoreleasePool alloc] init];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"back" object:nil];
	
	[self.navigationController popToRootViewControllerAnimated:YES];
	
	
	
	[pool release];
	
	
}


-(void)loginMain:(NSNotification *)notification
{
	
	
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	self.navigationItem.leftBarButtonItem.enabled=YES;
	UIButton *tmpButton =(UIButton*)[self.view viewWithTag:0];
	tmpButton.enabled=YES;
	
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
			
			//	DebugLog(@"loginDic = %@", [loginDic description]);
			
			
			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
			
			//웹키가 내려오면 아이디 패스워드 저장..
			if([loginDic objectForKey:@"pKey"])
			{
				// Web pKey 저장..
				//[[NSUserDefaults standardUserDefaults] setObject:[loginDic objectForKey:@"pKey"] forKey:@"webKey"];
				[JYUtil saveToUserDefaults:[loginDic objectForKey:@"pKey"] forKey:@"webKey"];
				//아이디 패스워드 저장..
				
				/*
				NSString *tmpID = [loginDic objectForKey:@"emailAddress"];
				NSString *tmpPass =[loginDic objectForKey:@"password"];
				*/
				
				
				NSString *tmpID = [[NSUserDefaults standardUserDefaults] objectForKey:@"tmpID"];
				NSString *tmpPass = [[NSUserDefaults standardUserDefaults] objectForKey:@"tmpPASS"];
				
				
				
				
				 
								
				
				
				
				//아이디만 안되는 이유가 뭐냐...???
				
				
				
				
				
				
				
				
				[[NSUserDefaults standardUserDefaults] setObject:tmpID forKey:@"usayID"];
				[[NSUserDefaults standardUserDefaults] setObject:tmpPass forKey:@"usayPASS"];
				
				
				
				
				
				
				
				
				if(flag == NO)
				{
					[NSThread detachNewThreadSelector:@selector(popToRoot) toTarget:self withObject:nil];
					
					
				}
				
				
				
				else {
					DebugLog(@"팝네비게이션.2222");
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
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" 
															message:@"아이디/비밀번호를 확인 후 이용 바랍니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
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
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" 
															message:@"아이디/비밀번호를 확인 후 이용 바랍니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		alertView.delegate=self;
		[alertView show];
		[alertView release];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		
		return;
		
	}
	
	
	
	
	
	
	
	
//	[[NSNotificationCenter defaultCenter] postNotificationName:@"back" object:data];
	
		
	
}


-(void)backBarButtonClicked
{
	[self.navigationController popViewControllerAnimated:YES];
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return	[mailDomain count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	return [mailDomain objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	DebugLog(@"didSelect = %@ %d", [mailDomain objectAtIndex:row], component);
	selectDomain = [mailDomain objectAtIndex:row];
	EMAIL = selectDomain;
	
}
-(void)complete
{

	if(selectDomain == NULL)
		selectDomain=@"paran.com";
	
	
	[customBar removeFromSuperview];
	
	
	
	UITextField *emailField =(UITextField*)[self.view viewWithTag:33];
	emailField.text=[NSString stringWithFormat:@"@%@", selectDomain];

	/*
	UITextField *idField =(UITextField*)[self.view viewWithTag:11];
	if(ID == NULL)
		ID=@"";
	
	 */
	
	


//	NSString *id = [NSString stringWithFormat:@"%@@%@", ID,selectDomain];
//	idField.text=id;
//	DebugLog(@"id = %@", id);
	
	[DomainPicker removeFromSuperview];

		
}

-(void)segmentedAction:(id)sender
{
	DebugLog(@"seket = %d",[sender selectedSegmentIndex]);
	
	NSInteger selectIndex = [sender selectedSegmentIndex];
	
	
	
	if(selectIndex == 0)
	{
	}
	else {
		
	}

	
	
}



-(void)mailAction
{
	DebugLog(@"mail");
	
	UITextField *idField =(UITextField*)[self.view viewWithTag:11];
	[idField resignFirstResponder];	

	
	//아이디 필드가 에디팅 중이면 실행하지 않는다..
	UITextField *passField =(UITextField*)[self.view viewWithTag:22];
	[passField resignFirstResponder];
	
	
	if(mailDomain ==nil || mailDomain == NULL)
	{
		mailDomain = [[NSArray alloc] initWithObjects:@"paran.com",@"hanmir.com",@"hitel.net",@"twelvesky.co.kr",@"tiniwini.com", nil];
	}

	if(customBar ==nil || customBar ==NULL)
	{
	customBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 98+39+20, 320, 44)];
	customBar.tintColor=[UIColor blackColor];
	customBar.barStyle=UIBarStyleBlackOpaque;
	}
	
	UIBarButtonItem *completeButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(complete)];
	UIBarButtonItem *fixBtn =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
	
	
	
	
	/*
	UISegmentedControl *segmentButton =[[UISegmentedControl alloc] initWithItems:[NSArray array]];
	segmentButton.segmentedControlStyle=UISegmentedControlStyleBar;
	[segmentButton insertSegmentWithTitle:@"이전" atIndex:0 animated:NO];
	[segmentButton insertSegmentWithTitle:@"다음" atIndex:1 animated:NO];
	[segmentButton addTarget:self action:@selector(segmentedAction:) forControlEvents:UIControlEventValueChanged]; 
	UIBarButtonItem *segmentBtn =[[UIBarButtonItem alloc] initWithCustomView:segmentButton];
	*/
	NSArray *itemArray =[[NSArray alloc] initWithObjects:fixBtn,completeButton, nil];
	
	
	customBar.items =itemArray;
	
	//release 2010.12.28
	[completeButton release];
	[fixBtn release];
	
	
	
//	[customBar addSubview:Button];
	[self.view addSubview:customBar];
	
	if(DomainPicker == nil || DomainPicker == NULL)
	{
		DomainPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 98+39+44+20, 320, 0)];
		DomainPicker.delegate =self;
		DomainPicker.dataSource =self;
		DomainPicker.showsSelectionIndicator=YES;
	}

	[self.view addSubview:DomainPicker];
}




-(void)keyboardWillAppear:(NSNotification*)noti
{
	[self.view setFrame:CGRectMake(0, -30, self.view.frame.size.width, self.view.frame.size.height)];

}
-(void)keyboardDisappear:(NSNotification*)noti
{
	[self.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];

}


- (void)selectTab:(UIButton *)sender
{
//    NSLog(@"selectTab = %@", sender.tag);
    
    if (sender.tag  == 100) {
        [tab01 setBackgroundImage:[UIImage imageNamed:@"7_id_tab_1_1.png"] forState:UIControlStateNormal];
        [tab01 setTitleColor:ColorFromRGB(0x333333) forState:UIControlStateNormal];

 		[tab02 setBackgroundImage:[UIImage imageNamed:@"7_id_tab_1_2.png"] forState:UIControlStateNormal];
        [tab02 setTitleColor:ColorFromRGB(0x666666) forState:UIControlStateNormal];
       
        UITextField *idField =(UITextField*)[self.view viewWithTag:11];
        idField.frame = CGRectMake(54-28+5, 98+50+5, 96+33+10, 36);
        
        UITextField *emailField = (UITextField*)[self.view viewWithTag:33];
        emailField.frame = CGRectMake(54+96+20, 98+50+5, 110, 36);

//		UIButton *selectBtn = [[UIButton alloc] initWithFrame:CGRectMake(54+186+20, 112+30+5, 50, 50)]; //11,7
// 		[selectBtn addTarget:self action:@selector(mailAction) forControlEvents:UIControlEventTouchUpInside];
//		[selectBtn setImage:[UIImage imageNamed:@"7_arrow_down.png"] forState:UIControlStateNormal];
//        selectBtn.tag = 13;
        
//        [self.view addSubview:selectBtn];
//		[selectBtn release];
        UIButton *selectBtn =(UIButton*)[self.view viewWithTag:12];
        selectBtn.frame = CGRectMake(54+186+20, 112+30+5, 50, 50);
        
        UIButton *selectBtn2 =(UIButton*)[self.view viewWithTag:13];
        selectBtn2.frame = CGRectMake(186-30, 112+30+5, 80+54, 50);

    }
    else if (sender.tag == 101) {
        [tab01 setBackgroundImage:[UIImage imageNamed:@"7_id_tab_2_1.png"] forState:UIControlStateNormal];
        [tab01 setTitleColor:ColorFromRGB(0x666666) forState:UIControlStateNormal];
        
 		[tab02 setBackgroundImage:[UIImage imageNamed:@"7_id_tab_2_2.png"] forState:UIControlStateNormal];
        [tab02 setTitleColor:ColorFromRGB(0x333333) forState:UIControlStateNormal];    
 
        UITextField *idField =(UITextField*)[self.view viewWithTag:11];
        idField.frame = CGRectMake(54-28+5, 98+50+5, 96+33+10+125, 36);

        UITextField *emailField = (UITextField*)[self.view viewWithTag:33];
        emailField.frame = CGRectMake(54+96+20, 98+50+5, 0, 0);

        UIButton *selectBtn =(UIButton*)[self.view viewWithTag:12];
        selectBtn.frame = CGRectMake(54+186+20, 112+30+5, 0, 0);
 
        UIButton *selectBtn2 =(UIButton*)[self.view viewWithTag:13];
        selectBtn2.frame = CGRectMake(186-30, 112+30+5, 0, 0);

    }
        
}

- (void)helpClick
{
    NSLog(@"helpClick");
    
    termsViewController *termsView =[[termsViewController alloc] init];
	termsView.hidesBottomBarWhenPushed= YES;
	
	[self.navigationController pushViewController:termsView animated:YES];
	[termsView release];
}

- (void)TwitterClick
{
    NSLog(@"TwitterClick");

    authOkViewController *authOkView =[[authOkViewController alloc] init];
	authOkView.hidesBottomBarWhenPushed= YES;
	
	[self.navigationController pushViewController:authOkView animated:YES];
	[authOkView release];
}

- (void)FaceBookClick
{
    NSLog(@"FaceBookClick");
    
}

- (void)FindIDClick
{
    NSLog(@"FindIDClick");
    
}

- (void)FindPWClick
{
    NSLog(@"FindPWClick");
    
}

- (void)JoinClick
{
    NSLog(@"JoinClick");
    
}

//UIView에서만 되네...
- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
    CGContextSetLineWidth(context, 1.0);
    CGContextMoveToPoint(context, 0, 442-71);
    CGContextAddLineToPoint(context, 320, 442-71);
    CGContextStrokePath(context);
    CGContextSetLineWidth(context, 1.0);   
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(back:) name:@"back" object:nil];
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:self.view.window
	 ];

	[[NSNotificationCenter defaultCenter] 
	 addObserver:self selector:@selector(keyboardDisappear:) name:UIKeyboardWillHideNotification object:self.view.window
	 ];	
	
	


	NSString *usayID = [[NSUserDefaults standardUserDefaults] objectForKey:@"usayID"];
	NSString *usayPASS = [[NSUserDefaults standardUserDefaults] objectForKey:@"usayPASS"];
	NSString *webKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"webKey"];
	
	
	
	if(usayID && usayPASS && webKey)
	{
		[self goWeb];
	}
	else {
		
		//로그인 인증 확인.
		
		
		
		
		UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 44)];
		UIFont *titleFont = [UIFont systemFontOfSize:20];
		UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 250, 44)];
		[titleLabel setFont:titleFont];
		titleLabel.textAlignment = UITextAlignmentCenter;
		[titleLabel setTextColor:ColorFromRGB(0x053844)];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[titleLabel setText:@"웹과 동기화(Usay.net)"];
		
		
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
		
		
//        UIImageView	 *logoImg = [[UIImageView alloc] initWithFrame:CGRectMake(95, 75-44-20, 127, 57)];
        UIImageView	 *logoImg = [[UIImageView alloc] initWithFrame:CGRectMake(105, 88-64, 111, 41)];
		logoImg.image=[UIImage imageNamed:@"7_logo_1.png"];
		[self.view addSubview:logoImg];
		[logoImg release];
        

/*        
		UILabel *loginLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 59+10, 320, 35)];
		loginLabel.textColor=ColorFromRGB(0x23232a);
		loginLabel.textAlignment=UITextAlignmentCenter;
		loginLabel.font=[UIFont systemFontOfSize:14];
        //	loginLabel.text=@"Usay.net 아이디로 로그인하세요.";
		loginLabel.text=@"웹과 동기화 기능을 이용하시려면\nUsay.net 웹 회원 아이디가 필요합니다.";
		loginLabel.numberOfLines=3;
		loginLabel.lineBreakMode=YES;
		[loginLabel setBackgroundColor:[UIColor clearColor]];
		[self.view addSubview:loginLabel];
		[loginLabel release];
//*/		

        UILabel *loginLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(50, 148-64-5, 220, 20)];
		loginLabel2.textColor=ColorFromRGB(0x23232a);
		loginLabel2.textAlignment=UITextAlignmentCenter;
		loginLabel2.font=[UIFont systemFontOfSize:14];
		loginLabel2.text=@"Usay.net 아이디로 로그인하세요.";
		loginLabel2.numberOfLines=3;
		loginLabel2.lineBreakMode=YES;
		[loginLabel2 setBackgroundColor:[UIColor clearColor]];
		[self.view addSubview:loginLabel2];
		[loginLabel2 release];

        
        // 상단 탭 영역
        tab01  = [UIButton buttonWithType:UIButtonTypeCustom];
		tab01.tag=100;
		[tab01 setBackgroundImage:[UIImage imageNamed:@"7_id_tab_1_1.png"] forState:UIControlStateNormal];
		[tab01 addTarget:self action:@selector(selectTab:) forControlEvents:UIControlEventTouchUpInside];
        tab01.frame=CGRectMake(0, 169-64, 160, 39);        
        tab01.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
        tab01.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
        [tab01 setTitle:@"아이디" forState:UIControlStateNormal];
//        [tab01 setFont:[UIFont boldSystemFontOfSize:14.0f]];
        [tab01.titleLabel setFont:[UIFont fontWithName:@"AppleGothic" size:14.0f]];
        [tab01 setTitleColor:ColorFromRGB(0x333333) forState:UIControlStateNormal];
        [tab01 setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 22.0f, 0.0f, 0.0f)];
        [self.view addSubview:tab01];
//        [tab01 release];

        
        tab02  = [UIButton buttonWithType:UIButtonTypeCustom];
		tab02.tag=101;
		[tab02 setBackgroundImage:[UIImage imageNamed:@"7_id_tab_1_2.png"] forState:UIControlStateNormal];
		[tab02 addTarget:self action:@selector(selectTab:) forControlEvents:UIControlEventTouchUpInside];
  		tab02.frame=CGRectMake(160, 169-64, 160, 39);
        [tab02 setTitle:@"이메일아이디" forState:UIControlStateNormal];
//        [tab02 setFont:[UIFont boldSystemFontOfSize:14.0f]];
        [tab02.titleLabel setFont:[UIFont fontWithName:@"AppleGothic" size:14.0f]];
        [tab02 setTitleColor:ColorFromRGB(0x666666) forState:UIControlStateNormal];
        [tab02 setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 20.0f)];
        [self.view addSubview:tab02];
//        [tab02 release];
		
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginMain:) name:@"loginMain" object:nil];
		
		UITextField *idField = [[UITextField alloc] initWithFrame:CGRectMake(54-28+5, 98+50+5, 96+33+10, 36)];
		idField.borderStyle=UITextBorderStyleNone;
		idField.tag=11;
		idField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		idField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		
		
		//idField.keyboardType=UIReturnKeyDone;
		[idField setReturnKeyType:UIReturnKeyDone];
		
		
		
		UITextField *emailField = [[UITextField alloc] initWithFrame:CGRectMake(54+96+20, 98+50+5, 110, 36)];
		emailField.borderStyle=UITextBorderStyleNone;
		emailField.tag=33;
		emailField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		
		
		UITextField *passField = [[UITextField alloc] initWithFrame:CGRectMake(54-28+5, 98+36+50+5, 96+33+10+125, 35)];
		passField.borderStyle=UITextBorderStyleNone;
		passField.tag=22;
		passField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		passField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		
		idField.text=@"아이디";
		emailField.text=@"@paran.com";
		passField.text=@"비밀번호";
		idField.textColor=ColorFromRGB(0x9c9ca8);
		passField.textColor=ColorFromRGB(0x9c9ca8);
		emailField.textColor=ColorFromRGB(0x9c9ca8);
		
		
		idField.delegate=self;
		passField.delegate=self;
		emailField.delegate = self;
		
		//passField.keyboardType=UIReturnKeyDone;
		
		[passField setReturnKeyType:UIReturnKeyDone];
		
		idField.backgroundColor =[UIColor clearColor];
		/*
		idField.backgroundColor=[UIColor colorWithPatternImage: [UIImage imageNamed:@"5_login_bg_1.png"]];
		passField.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"5_login_bg_3.png"]];
		emailField.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"5_login_bg_2.png"]];
		*/
		
		
		//메일 선택 녹색 화살표
		UIButton *selectBtn = [[UIButton alloc] initWithFrame:CGRectMake(54+186+20, 112+30+5, 50, 50)]; //11,7
	//		UIButton *selectBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
		
		//메일 피커 나오게 하는 빈 버튼
		UIButton *selectBtn2 = [[UIButton alloc] initWithFrame:CGRectMake(186-30, 112+30+5, 80+54, 50)];
		[selectBtn2 addTarget:self action:@selector(mailAction) forControlEvents:UIControlEventTouchUpInside];
		selectBtn2.tag = 13;
		
		
		
		[selectBtn addTarget:self action:@selector(mailAction) forControlEvents:UIControlEventTouchUpInside];
		[selectBtn setImage:[UIImage imageNamed:@"7_arrow_down.png"] forState:UIControlStateNormal];
	//	[selectBtn setBackgroundColor:[UIColor blueColor]];
        selectBtn.tag = 12;
		 
		 
		 
		 
		 
		
		
		
		//로그인 이미지
		UIButton *subButton  =[UIButton buttonWithType:UIButtonTypeCustom];
		subButton.tag=0;
		[subButton setImage:[UIImage imageNamed:@"7_login_button.PNG"] forState:UIControlStateNormal];
		[subButton addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
		subButton.frame=CGRectMake(21, 206+30, 279, 39);
		
		
/*		
		UITextView *explainView =[[UITextView alloc] initWithFrame:CGRectMake(0, 272, 320, 100)];
		explainView.delegate=self;
		explainView.dataDetectorTypes=UIDataDetectorTypeAll;
		explainView.backgroundColor=[UIColor clearColor];
		explainView.scrollEnabled=NO;
		explainView.font=[UIFont systemFontOfSize:14];
		explainView.textAlignment=UITextAlignmentCenter;
		explainView.textColor=ColorFromRGB(0x23232a);
		explainView.editable=NO;
		
		
		
		explainView.text=@"회원 가입 및 아이디, 패스워드 찾기는\nwww.usay.net 에서 하실 수 있습니다.";
		
		[self.view addSubview:explainView];
		[explainView release];	
//*/		
		
		/*
		UIView *explainView =[[UIView alloc] initWithFrame:CGRectMake(0, 316-44-20, 320, 460-(316-44))];
		explainView.backgroundColor=ColorFromRGB(0xEEEEEE);
		[self.view addSubview:explainView];
		
		
		
		
		
		//원래 35인듯..
		UILabel *explain =[[UILabel alloc] initWithFrame:CGRectMake(14, -5, 320-28, 460-(316-44+45))];
		
		explain.textColor=ColorFromRGB(0x23232a);
		explain.numberOfLines = 7;
		explain.lineBreakMode = YES;
		explain.font = [UIFont systemFontOfSize:14];
	//	explain.text=@"웹(Usay.net)과 동기화하여 편리하게 주소록을\n관리하세요. Usay주소록 App과 Web을\n동기화하시면 주소록 데이터가 연동되어\n자동으로 업데이트 됩니다.\n\n회원가입 및 아이디/비밀번호는\n웹사이트에서 이용하실 수 있습니다.";
		explain.text=@"회원 가입 및 아이디, 패스워드 찾기는\nwww.usay.net에서 하실 수 있습니다.";
		explain.backgroundColor=[UIColor clearColor];

		[explainView addSubview:explain];
		
		 */
		
		 
/*		// 하단 url text
		UILabel *urlLabel =[[UILabel alloc] initWithFrame:CGRectMake(0, 460-44-20, 320, 20)];
		urlLabel.backgroundColor = [UIColor clearColor];
		urlLabel.textColor = ColorFromRGB(0x16acc2);
		urlLabel.textAlignment = UITextAlignmentCenter;
		urlLabel.font = [UIFont systemFontOfSize:12];
		urlLabel.text = @"www.usay.net";
		[self.view addSubview:urlLabel];
		[urlLabel release];
//*/		
		
		
		//로그인 테두리 이미지..
        
        UIImageView *backImgView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"7_login_id_bg.png"] stretchableImageWithLeftCapWidth:8 topCapHeight:52]];
		backImgView.backgroundColor = [UIColor clearColor];
		backImgView.frame=CGRectMake(21, 118+30+5, 320-42, 74);
        
        
//		UIImage *backImg = [UIImage imageNamed:@"7_login_id_bg.png"];
//		UIImageView *backImgView =[[UIImageView alloc] initWithImage:backImg];
//		backImgView.frame=CGRectMake(46, 118+30, 229, 74);
		
		
		[self.view addSubview:backImgView];
		//release 2010.12.28
		[backImgView release];
		
		
		// 다른방법으로 로그인
        UILabel *defferentLabel = [[UILabel alloc] initWithFrame:CGRectMake(21, 369-64, 160, 20)];
		defferentLabel.textColor=ColorFromRGB(0x333333);
		defferentLabel.textAlignment=UITextAlignmentLeft;
		defferentLabel.font=[UIFont systemFontOfSize:13];
		defferentLabel.text=@"다른 방법으로 로그인";
		defferentLabel.numberOfLines=3;
		defferentLabel.lineBreakMode=YES;
		[defferentLabel setBackgroundColor:[UIColor clearColor]];
		[self.view addSubview:defferentLabel];
		[defferentLabel release];	
		
        
        UIButton *btnHelp  = [UIButton buttonWithType:UIButtonTypeCustom];
		btnHelp.tag=102;
        [btnHelp setBackgroundImage:[UIImage imageNamed:@"helpBtn.png"] forState:UIControlStateNormal];
        btnHelp.backgroundColor = [UIColor whiteColor];
        [btnHelp addTarget:self action:@selector(helpClick) forControlEvents:UIControlEventTouchUpInside];
        [btnHelp setTitle:@"도움말" forState:UIControlStateNormal];
        [btnHelp.titleLabel setFont:[UIFont fontWithName:@"AppleGothic" size:12.0f]];
        [btnHelp setTitleColor:ColorFromRGB(0x9c9ca8) forState:UIControlStateNormal];
        btnHelp.frame=CGRectMake(150, 369-64-4, 50, 32);
        [self.view addSubview:btnHelp];
  
        
        UIButton *btnTwitter  = [UIButton buttonWithType:UIButtonTypeCustom];
		btnTwitter.tag=103;
		[btnTwitter setImage:[UIImage imageNamed:@"7_twfb_1.png"] forState:UIControlStateNormal];
		[btnTwitter addTarget:self action:@selector(TwitterClick) forControlEvents:UIControlEventTouchUpInside];
  		btnTwitter.frame=CGRectMake(21, 391-64, 140, 33);
        [self.view addSubview:btnTwitter];
 
        
        UIButton *btnFacebook  = [UIButton buttonWithType:UIButtonTypeCustom];
		btnFacebook.tag=104;
		[btnFacebook setImage:[UIImage imageNamed:@"7_twfb_2.png"] forState:UIControlStateNormal];
		[btnFacebook addTarget:self action:@selector(FaceBookClick) forControlEvents:UIControlEventTouchUpInside];
  		btnFacebook.frame=CGRectMake(160, 391-64, 140, 33);
        [self.view addSubview:btnFacebook];

/*        
        CAShapeLayer *myLayer = nil;//[[[[self view] layer] sublayers] lastObject];
        
        myLayer = [CAShapeLayer layer];
        CGRect bounds = [[self view] bounds];
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, 0, 442-63);
        CGPathAddLineToPoint(path, NULL, 320, 442-63);
        [myLayer setPath:path];
        CGPathRelease(path);
        [myLayer setStrokeColor:[[UIColor colorWithRed:206.0/255.0 green:206.0/255.0 blue:206.0/255.0 alpha:0.0f] CGColor]];
        [myLayer setFrame:bounds];
        [[[self view] layer] addSublayer:myLayer];
//*/
        
        UIImageView *lineView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"line_img.png"] stretchableImageWithLeftCapWidth:3 topCapHeight:1]];
		lineView.backgroundColor = [UIColor clearColor];
		lineView.frame=CGRectMake(0, 442-71, 320, 1);
 
		[self.view addSubview:lineView];
		[lineView release];
        
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 442-70, 320, 44)];
        bgView.backgroundColor = ColorFromRGB(0xf5f5f6);
        [self.view addSubview:bgView];
        [bgView release];
        
        UIButton *btnFindID  = [UIButton buttonWithType:UIButtonTypeCustom];
		btnFindID.tag=105;
		[btnFindID setImage:[UIImage imageNamed:@"7_btn_btm_1.png"] forState:UIControlStateNormal];
		[btnFindID addTarget:self action:@selector(FindIDClick) forControlEvents:UIControlEventTouchUpInside];
  		btnFindID.frame=CGRectMake(0, 442-64, 87, 32);
        [self.view addSubview:btnFindID];

        
        UIButton *btnFindPW  = [UIButton buttonWithType:UIButtonTypeCustom];
		btnFindPW.tag=106;
		[btnFindPW setImage:[UIImage imageNamed:@"7_btn_btm_2.png"] forState:UIControlStateNormal];
		[btnFindPW addTarget:self action:@selector(FindPWClick) forControlEvents:UIControlEventTouchUpInside];
  		btnFindPW.frame=CGRectMake(87, 442-64, 83, 32);
        [self.view addSubview:btnFindPW];
        
        
        UIButton *btnJoin  = [UIButton buttonWithType:UIButtonTypeCustom];
		btnJoin.tag=107;
		[btnJoin setImage:[UIImage imageNamed:@"7_btn_btm_3.png"] forState:UIControlStateNormal];
		[btnJoin addTarget:self action:@selector(JoinClick) forControlEvents:UIControlEventTouchUpInside];
  		btnJoin.frame=CGRectMake(250, 442-64, 70, 32);
        [self.view addSubview:btnJoin];
        
       
		[self.view addSubview:idField];
		[idField release];    // sochae 2010.12.29 - cLang
		[self.view addSubview:emailField];
		[emailField release]; // sochae 2010.12.29 - cLang
		[self.view addSubview:passField];
		[passField release];  // sochae 2010.12.29 - cLang
		
		
		[self.view addSubview:subButton];
	//	[self.view addSubview:explain];
		
		
		[self.view addSubview:selectBtn2];
		//release 2010.12.28
		[selectBtn2 release];
		
		
		
		[self.view addSubview:selectBtn];
		[selectBtn release];
		
		
	//	[explain release];
		
		
		
	//	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		
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
	DomainPicker = nil;
	DomainPicker = NULL;
	[DomainPicker release];
	mailDomain = nil;
	mailDomain = NULL;
	[mailDomain release];
	[customBar release];
	customBar=nil;
	
	
	
}


@end
