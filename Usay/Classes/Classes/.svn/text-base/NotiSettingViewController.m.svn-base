//
//  NotiSettingViewController.m
//  USayApp
//
//  Created by 1team on 10. 6. 1..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "NotiSettingViewController.h"
#import "json.h"
#import "USayAppAppDelegate.h"
#import "USayHttpData.h"
//#import "MyDeviceClass.h"			// sochae 2010.09.11 - UI Position

enum ControlTableSections
{
	kSoundSection = 0,
	kVibrateSection,
	kPreviewContentsSection
};

#define	ID_NOTI_SOUND		7512
#define ID_NOTI_VIBRATE		7513
#define ID_PREVIEW_CONTENTS	7514

#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
										green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
										blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation NotiSettingViewController

#pragma mark -
#pragma mark NSNotification  response

#pragma mark -
#pragma mark - UITableView delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *kSoundCellIdentifier = @"SoundNotification";
	static NSString *kVibrateCellIdentifier = @"VibrateNotification";
	static NSString *kPreviewContentsCellIdentifier = @"PreviewContentsNotification";
    
	UITableViewCell *cell = nil;
	switch (indexPath.section)
	{
		case kSoundSection:
		{
			cell = [tableView dequeueReusableCellWithIdentifier:kSoundCellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSoundCellIdentifier] autorelease];
				cell.textLabel.text = @"소리 알림";
				cell.textLabel.textColor = ColorFromRGB(0x2284ac);
				cell.textLabel.font = [UIFont systemFontOfSize:17];
				
				UISwitch *soundSwitch = [[[UISwitch alloc] init] autorelease];
				[soundSwitch setOn:YES];	// default NO
				[soundSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
				soundSwitch.backgroundColor = [UIColor clearColor];
				soundSwitch.tag = ID_NOTI_SOUND;
				cell.accessoryView = soundSwitch;
				NSUInteger	notisound = [[NSUserDefaults standardUserDefaults] integerForKey:@"notisound"];	// 0: off  1: on
				if (notisound == 0) {
					[soundSwitch setOn:NO animated:NO];
				} else {
					[soundSwitch setOn:YES animated:NO];
				}
			}
			break;
		}
		case kVibrateSection:
		{
			cell = [tableView dequeueReusableCellWithIdentifier:kVibrateCellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kVibrateCellIdentifier] autorelease];
				cell.textLabel.text = @"진동 알림";
				cell.textLabel.textColor = ColorFromRGB(0x2284ac);
				cell.textLabel.font = [UIFont systemFontOfSize:17];
				
				UISwitch *vibrateSwitch = [[[UISwitch alloc] init] autorelease];
				[vibrateSwitch setOn:YES];	// default NO
				[vibrateSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
				vibrateSwitch.backgroundColor = [UIColor clearColor];
				vibrateSwitch.tag = ID_NOTI_VIBRATE;
				cell.accessoryView = vibrateSwitch;
				NSUInteger	notivibrate = [[NSUserDefaults standardUserDefaults] integerForKey:@"notivibrate"];	// 0: off  1: on
				if (notivibrate == 0) {
					[vibrateSwitch setOn:NO animated:NO];
				} else {
					[vibrateSwitch setOn:YES animated:NO];
				}
			}
			break;
		}
		case kPreviewContentsSection:
		{
			cell = [tableView dequeueReusableCellWithIdentifier:kPreviewContentsCellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kPreviewContentsCellIdentifier] autorelease];
				cell.textLabel.text = @"내용 미리보기";
				cell.textLabel.textColor = ColorFromRGB(0x2284ac);
				cell.textLabel.font = [UIFont systemFontOfSize:17];
				
				UISwitch *previewContentsSwitch = [[[UISwitch alloc] init] autorelease];
				[previewContentsSwitch setOn:YES];	// default NO
				[previewContentsSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
				previewContentsSwitch.backgroundColor = [UIColor clearColor];
				previewContentsSwitch.tag = ID_PREVIEW_CONTENTS;
				cell.accessoryView = previewContentsSwitch;
				NSUInteger	apnsonpreview = [[NSUserDefaults standardUserDefaults] integerForKey:@"apnsonpreview"];	// 0: off  1: on
				if (apnsonpreview == 0) {
					[previewContentsSwitch setOn:NO animated:NO];
				} else {
					[previewContentsSwitch setOn:YES animated:NO];
				}
			}
			break;
		}
		default:
			break;
	}
	
    // Configure the cell...
    // Set attributes common to all cell types.
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
#pragma mark -

#pragma mark - Switch action handler
- (void)switchAction:(id)sender
{
	UISwitch *soundSwitch = (UISwitch*)[self.view viewWithTag:ID_NOTI_SOUND];
	UISwitch *vibrateSwitch = (UISwitch*)[self.view viewWithTag:ID_NOTI_VIBRATE];
	UISwitch *previewContentsSwitch = (UISwitch*)[self.view viewWithTag:ID_PREVIEW_CONTENTS];
	
	if (soundSwitch != nil || vibrateSwitch != nil || previewContentsSwitch != nil) {
		if (sender == soundSwitch) {
			if ([soundSwitch isOn]) {
				[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"notisound"];
			} else {
				[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"notisound"];
			}
		} else if (sender == vibrateSwitch) {
			if ([vibrateSwitch isOn]) {
				[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"notivibrate"];
			} else {
				[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"notivibrate"];
			}
		} else if (sender == previewContentsSwitch) {
			if ([self appDelegate].connectionType == -1) {	// -1:offline mode  0:disconnect 1:Wi-Fi 2:3G
				return;
			} else if ([self appDelegate].connectionType == 0) {
				return;
			}
			NSString *isOnPreview = nil;
			if ([previewContentsSwitch isOn]) {
				isOnPreview = @"Y";
			} else {
				isOnPreview = @"N";
			}
			// value, key, value, key ...
			NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:
										[[self appDelegate] getSvcIdx], @"svcidx",
										isOnPreview, @"isOnPreview",
										nil];
//			assert(bodyObject != nil);
			// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
			USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"setMessagePreviewOnMobile" andWithDictionary:bodyObject timeout:10] autorelease];
//			assert(data != nil);
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];

		} else {	
		}
	}
}
#pragma mark -

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
 // Custom initialization
 }
 return self;
 }
 */

-(USayAppAppDelegate *) appDelegate
{
	return [[UIApplication sharedApplication] delegate];
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

-(void)backBarButtonClicked 
{
	[self.navigationController popViewControllerAnimated:YES];
}

//*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
	UIFont *titleFont = [UIFont systemFontOfSize:20];
	CGSize titleStringSize = [@"알림 설정" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
	UILabel *naviTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
	[naviTitleLabel setFont:titleFont];
	naviTitleLabel.textAlignment = UITextAlignmentCenter;
	[naviTitleLabel setTextColor:ColorFromRGB(0x053844)];
	[naviTitleLabel setBackgroundColor:[UIColor clearColor]];
	[naviTitleLabel setText:@"알림 설정"];
	[titleView addSubview:naviTitleLabel];		
	[naviTitleLabel release];
	self.navigationItem.titleView = titleView;
	[titleView release];
	self.navigationItem.titleView.frame = CGRectMake((self.tableView.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);

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
	
	UIView* tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
	tableHeaderView.backgroundColor = [UIColor colorWithRed:237.0/255.0 green:239.0/255.0 blue:242.0/255.0 alpha:1.0f];
	
	UILabel *titleLabel = [[UILabel alloc] init];
	titleLabel.textColor = ColorFromRGB(0x313b48);
	titleLabel.font = [UIFont fontWithName:@"Helvetica" size:17.0f];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.text = @"메시지 도착 설정";
	[tableHeaderView addSubview:titleLabel];
	titleLabel.frame = CGRectMake(14, 15, 292, 20);
	self.tableView.tableHeaderView = tableHeaderView;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	
	[titleLabel release];
	[tableHeaderView release];
	
	self.tableView.backgroundColor = [UIColor colorWithRed:237.0/255.0 green:239.0/255.0 blue:242.0/255.0 alpha:1.0f];
	
	// 노티피케이션처리관련 등록..
	
	[super viewDidLoad];
}
//*/

- (void)viewDidDisappear:(BOOL)animated 
{
    [super viewDidDisappear:animated];
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
    [super dealloc];
}


@end
