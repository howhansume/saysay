//
//  IDRegistrationViewController.m
//  USayApp
//
//  Created by 1team on 10. 6. 1..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "IDRegistrationViewController.h"
#import "RegexKitLite.h"

@implementation IDRegistrationViewController

@synthesize titleLabel, middleLabel, mailTextField, passwdTextField, scrollView, mainView, indicator;
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
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"아이디 등록";
	mailTextField.returnKeyType = UIReturnKeyNext;
	passwdTextField.returnKeyType = UIReturnKeyDone;
	titleLabel.numberOfLines = 7;
	titleLabel.text = @"Usay.net 사이트에서 생성한 아이디를 등록해주세요.\n아이디 등록을 하시면 폰 번호가 변경 되더라도 기존 주소록 데이터를 계속사용 가능하며, PC와 모바일주소록 동기화를 통해 주소록을 쉽고 편리하게 이용 가능합니다.";
	middleLabel.numberOfLines = 2;
	middleLabel.text = @"Usay 아이디가 없는 경우 아래\n회원가입을 통해서 생성 가능합니다.";
	
	indicator.hidesWhenStopped = YES;
	
	scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	scrollView.clipsToBounds = YES;		// default is NO, we want to restrict drawing within our scrollview
	scrollView.scrollEnabled = NO;
	scrollView.pagingEnabled = NO;
	[scrollView setContentSize:CGSizeMake(320, 480)];
	[scrollView addSubview:mainView];

	[self registerForKeyboardNotifications];

	// titleLabel.textColor = [UIColor whiteColor];	// font color
	// titleLabel.textAlignment = UITextAlignmentCenter; // 정렬
	// [titleLabel setFont:[UIFont boldSystemFontOfSize:12.0]];	// 서체크기 pointSize = 10.0
	
}
//*/

- (void)viewDidDisappear:(BOOL)animated 
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

-(IBAction) clicked:(id)sender
{
	if(sender == registrationBtn) {
		[mailTextField resignFirstResponder];
		[passwdTextField resignFirstResponder];
		if (mailTextField.text.length == 0) {
			UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"USay" 
															   message:@"이메일 주소를 입력하십시오." 
															  delegate:self 
													 cancelButtonTitle:@"OK" 
													 otherButtonTitles:nil];
			[alertView show];
			[alertView release];
			[mailTextField becomeFirstResponder];
			return;
		}
		
		if (passwdTextField.text.length == 0) {
			UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"USay" 
															   message:@"비밀번호를 입력하십시오." 
															  delegate:self 
													 cancelButtonTitle:@"OK" 
													 otherButtonTitles:nil];
			[alertView show];
			[alertView release];
			[passwdTextField becomeFirstResponder];
			return;
		}

		NSMutableString *mailText = [[[NSString alloc] initWithFormat:@"%@", mailTextField.text] autorelease];
		NSMutableString *passwdText = [[[NSString alloc] initWithFormat:@"%@", passwdTextField.text] autorelease];
		assert(mailText != nil);
		assert(passwdText != nil);
		
		// 공백 제거
		NSMutableString *pStrMail = (NSMutableString *)[mailText stringByReplacingOccurrencesOfString:@" " withString:@""];
		NSMutableString *pStrPasswd = (NSMutableString *)[passwdText stringByReplacingOccurrencesOfString:@" " withString:@""];
		assert(pStrMail != nil);
		assert(pStrPasswd != nil);
		
		NSString *regexString = @"\\b([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})\\b";
		if ([pStrMail isMatchedByRegex:regexString]) {
//			NSLog(@"Mail Success!");
		} else {
			UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"USay" 
															   message:@"이메일 주소를 다시 입력하여주십시오." 
															  delegate:self 
													 cancelButtonTitle:@"OK" 
													 otherButtonTitles:nil];
			[alertView show];
			[alertView release];
			[mailTextField becomeFirstResponder];
			return;
		}

		[indicator startAnimating];
//		[indicator stopAnimating];
	} else if(sender == idMakeBtn) {
		NSURL *url = [[NSURL alloc]initWithString:@"http://www.gmail.com"];
		[[UIApplication sharedApplication] openURL:url];
		[url release];
	} else {
		
	}
}

-(IBAction) backgroundClicked:(id)sender
{
	[mailTextField resignFirstResponder];
	[passwdTextField resignFirstResponder];
}

- (void)registerForKeyboardNotifications
{
//	NSLog(@"registerForKeyboardNotifications");
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWasShown:)
												 name:UIKeyboardDidShowNotification object:nil];
	
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWasHidden:)
												 name:UIKeyboardDidHideNotification object:nil];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
	if(keyboardShown) return;
	
	NSDictionary *info = [aNotification userInfo];
	CGSize kbSize = [[info objectForKey:UIKeyboardBoundsUserInfoKey] CGRectValue].size;
	
	CGRect bkgnRect = activeField.superview.frame;
	bkgnRect.size.height += kbSize.height;
	[activeField.superview setFrame:bkgnRect];
	[scrollView setContentOffset:CGPointMake(0.0, activeField.frame.origin.y) animated:YES];
	
	keyboardShown = YES;
/*
    if (keyboardShown)
        return;
	NSLog(@"keyboardWasShown");
    NSDictionary* info = [aNotification userInfo];
	
    // Get the size of the keyboard.
    NSValue* aValue = [info objectForKey:UIKeyboardBoundsUserInfoKey];
    CGSize keyboardSize = [aValue CGRectValue].size;
	
    // Resize the scroll view (which is the root view of the window)
    CGRect viewFrame = [scrollView frame];
    viewFrame.size.height -= keyboardSize.height;
	
    scrollView.frame = viewFrame;
	
    // Scroll the active text field into view.
    CGRect textFieldRect = [activeField frame];
    [scrollView scrollRectToVisible:textFieldRect animated:YES];
	
    keyboardShown = YES;
//*/
}

// Called when the UIKeyboardDidHideNotification is sent
- (void)keyboardWasHidden:(NSNotification*)aNotification
{
//*
    NSDictionary* info = [aNotification userInfo];
	
    // Get the size of the keyboard.
    NSValue* aValue = [info objectForKey:UIKeyboardBoundsUserInfoKey];
    CGSize keyboardSize = [aValue CGRectValue].size;
	
    // Reset the height of the scroll view to its original value
    CGRect viewFrame = [scrollView frame];
	
    viewFrame.size.height += keyboardSize.height;
	
    scrollView.frame = viewFrame;
	
    keyboardShown = NO;
//*/
/*
	NSDictionary* info = [aNotification userInfo];
	
    // Get the size of the keyboard.
    NSValue* aValue = [info objectForKey:UIKeyboardBoundsUserInfoKey];
    CGSize keyboardSize = [aValue CGRectValue].size;
	
    // Reset the height of the scroll view to its original value
    CGRect viewFrame = [scrollView frame];
    viewFrame.size.height += keyboardSize.height;
    scrollView.frame = viewFrame;
	[scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    keyboardShown = NO;
//*/	
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == mailTextField) {
		[passwdTextField becomeFirstResponder];
	} else if (textField == passwdTextField) {
		[textField resignFirstResponder];
	} else {
		
	}

	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
//	activeField = textField;
	activeField = mailTextField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	activeField = nil;
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
    NSLog(@"dealloc titleLabel RetainCount = %i", [titleLabel retainCount]);
	[titleLabel release];
	
	NSLog(@"dealloc middleLabel RetainCount = %i", [middleLabel retainCount]);
	[middleLabel release];
	
	NSLog(@"dealloc mailTextField RetainCount = %i", [mailTextField retainCount]);
	[mailTextField release];
	
	NSLog(@"dealloc passwdTextField RetainCount = %i", [passwdTextField retainCount]);
	[passwdTextField release];
	
	NSLog(@"dealloc registrationBtn RetainCount = %i", [registrationBtn retainCount]);
	[registrationBtn release];
	
	NSLog(@"dealloc idMakeBtn RetainCount = %i", [idMakeBtn retainCount]);
	[idMakeBtn release];
	
	NSLog(@"dealloc indicator RetainCount = %i", [indicator retainCount]);
	[indicator release];
	
	NSLog(@"dealloc scrollView RetainCount = %i", [scrollView retainCount]);
	[scrollView release];
	
	NSLog(@"dealloc mainView RetainCount = %i", [mainView retainCount]);
	[mainView release];
	
	[super dealloc];
}


@end
