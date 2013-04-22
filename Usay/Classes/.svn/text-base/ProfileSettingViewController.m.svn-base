//
//  ProfileSettingViewController.m
//  USayApp
//
//  Created by 1team on 10. 6. 2..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "ProfileSettingViewController.h"
#import "MyInfoSettingViewController.h"
#import "InputNickNameViewController.h"
#import "InputStatusViewController.h"
#import "json.h"
#import "USayAppAppDelegate.h"
#import "USayHttpData.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"
#import "HttpAgent.h"
//#import "MyDeviceClass.h"			// sochae 2010.09.10 - UI Position
#import "USayDefine.h"				// sochae 2010.09.09 - added

#define ID_TABLEHEADERVIEW		8000
#define ID_MAINPHOTO			8001
#define ID_FIRSTPHOTO			8002
#define ID_SECONDPHOTO			8003
#define ID_THIRDPHOTO			8004
#define ID_FOURTHPHOTO			8005
#define ID_FIFTHPHOTO			8006

#define ID_NICKNAMELABEL		8007
#define ID_PRMSGLABEL			8008
#define ID_ORGANIZATIONLABEL	8009

#define ID_SUBNICKNAMELABEL		8110
#define ID_SUBPRMSGLABEL		8200

#define kMaxResolution			800

#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
										green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
										blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

enum ControlTableSections
{
	kStateSection = 0,
	kNickSection,
	kPrMsgSection,
	kMyProfileSection
};

@implementation ProfileSettingViewController

@synthesize settingTableView;
@synthesize preNickName;
@synthesize prePrMsg;
@synthesize representPhoto;
@synthesize representPhotoFilePath;
@synthesize subPhotosArray;
@synthesize photoLibraryShown;
//@synthesize compareRepresentPhoto;
@synthesize	preImStatus;
@synthesize isRequest;

-(id)init
{
	self = [super init];
	if (self != nil) {
		settingTableView = nil;
		preNickName = nil;
		prePrMsg = nil;
		representPhoto = nil;
		representPhotoFilePath = nil;
		subPhotosArray = nil;
		requestActIndicator = nil;
		photoLibraryShown = NO;
		isRequest = NO;
		timer = nil;
	}
	return self;
}

#pragma mark -
#pragma mark NSNotification  loadProfileOnMobile, updateNickName, updateStatus response

-(void)completeProfilePhoto:(NSNotification *)notification
{
	isRequest = NO;
	if (requestActIndicator) {
		[requestActIndicator stopAnimating]; 
	}
	
	self.navigationItem.leftBarButtonItem.enabled = YES;
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	if ([notification object] == nil) {
		NSString* imagePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithString:representPhotoFilePath]];
		if (imagePath && [imagePath length] > 0) {
			if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath isDirectory:NO]) {
				// not exist file
			} else {
				NSError *error = nil;
				BOOL successed = [[NSFileManager defaultManager] removeItemAtPath:imagePath error:&error]; 
				if (!successed) {
					DebugLog(@"error profile photo removeItemAtPath %@", [error localizedDescription]);
				}
			}
		}
		
		if ([[NSUserDefaults standardUserDefaults] objectForKey:@"representPhotoFilePath"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"representPhotoFilePath"] length] > 0) {
			if (representPhotoFilePath) {
				[representPhotoFilePath release];
				representPhotoFilePath = nil;
				representPhotoFilePath = [[NSMutableString alloc] initWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"representPhotoFilePath"]];
			} else {
				representPhotoFilePath = [[NSMutableString alloc] initWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"representPhotoFilePath"]];
			}
		} else {
			[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"representPhotoFilePath"];
			representPhotoFilePath = [[NSMutableString alloc] initWithString:@""];
		}

		if (representPhoto && [self.representPhoto length] > 0) {
			SDWebImageManager *manager = [SDWebImageManager sharedManager];
			
			UIImage *cachedImage = [manager imageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/012", self.representPhoto]]];
			
			if (cachedImage)
			{
				// Use the cached image immediatly
				UIButton *mainPhotoBtn = (UIButton *)[self.view viewWithTag:ID_MAINPHOTO];
				if(mainPhotoBtn) {
					[mainPhotoBtn setBackgroundImage:cachedImage forState:UIControlStateNormal];
				}
			}
			else
			{
				// Start an async download
				[manager downloadWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/012", self.representPhoto]] delegate:self];
			}
		} else {
			DebugLog(@"completeProfilePhoto FAIL representPhoto = %@", representPhoto);
			// Use the cached image immediatly
			UIButton *mainPhotoBtn = (UIButton *)[self.view viewWithTag:ID_MAINPHOTO];
			if(mainPhotoBtn) {
				[mainPhotoBtn setBackgroundImage:[UIImage imageNamed:@"img_default.png"] forState:UIControlStateNormal];
			}
		}
		return;
	}

	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"representPhotoFilePath"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"representPhotoFilePath"] length] > 0) {
		NSString* imagePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"representPhotoFilePath"]]];
		if (imagePath && [imagePath length] > 0) {
			if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath isDirectory:NO]) {
				// not exist file
			} else {
				NSError *error = nil;
				BOOL successed = [[NSFileManager defaultManager] removeItemAtPath:imagePath error:&error]; 
				if (!successed) {
					DebugLog(@"error profile photo removeItemAtPath %@", [error localizedDescription]);
				}
			}
		}
	}
	
	if (representPhoto) {
		[representPhoto release];
		representPhoto = nil;
		representPhoto = [[NSMutableString alloc] initWithString:notification.object];
	} else {
		representPhoto = [[NSMutableString alloc] initWithString:notification.object];
	}
	
	if (representPhoto && [self.representPhoto length] > 0) {
		SDWebImageManager *manager = [SDWebImageManager sharedManager];
		
		UIImage *cachedImage = [manager imageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/012", self.representPhoto]]];
		
		if (cachedImage)
		{
			// Use the cached image immediatly
			UIButton *mainPhotoBtn = (UIButton *)[self.view viewWithTag:ID_MAINPHOTO];
			if(mainPhotoBtn) {
				[mainPhotoBtn setBackgroundImage:cachedImage forState:UIControlStateNormal];
			}
		}
		else
		{
			// Start an async download
			[manager downloadWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/012", self.representPhoto]] delegate:self];
		}
	}

	[[NSUserDefaults standardUserDefaults] setObject:representPhotoFilePath forKey:@"representPhotoFilePath"];
	[[NSUserDefaults standardUserDefaults] setObject:representPhoto forKey:@"representPhoto"];	// url
	DebugLog(@"completeProfilePhoto OK representPhoto = %@", representPhoto);
}

-(void)completeImStatus:(NSNotification *)notification
{
	if ([notification object] == nil) {
	
		if (preImStatus) {
			[preImStatus release];
		}
		preImStatus = [[self appDelegate].myInfoDictionary objectForKey:@"imstatus"];
		
		[self.settingTableView reloadData];
		
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0033)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		
		return;
	}
}

-(void)completeNickName:(NSNotification *)notification
{
	isRequest = NO;
	if (requestActIndicator) {
		[requestActIndicator stopAnimating]; 
	}
	self.navigationItem.leftBarButtonItem.enabled = YES;
	if ([notification object] == nil) {
		UILabel *nickNameLabel = (UILabel *)[self.view viewWithTag:ID_NICKNAMELABEL];
		[nickNameLabel setText:preNickName];
		
		UILabel *subNickNameLabel = (UILabel *)[self.view viewWithTag:ID_SUBNICKNAMELABEL];
		if (subNickNameLabel) {
			[subNickNameLabel setText:preNickName];
		}
		return;
	}
	if (preNickName) {
		[preNickName release];
		preNickName = nil;
		preNickName = [[NSMutableString alloc] initWithString:notification.object];
	} else {
		preNickName = [[NSMutableString alloc] initWithString:notification.object];
	}
}

-(void)completeStatus:(NSNotification *)notification
{
	isRequest = NO;
	if (requestActIndicator) {
		[requestActIndicator stopAnimating]; 
	}
	self.navigationItem.leftBarButtonItem.enabled = YES;
	
	if ([notification object] == nil) {
		UILabel *prMsgLabel = (UILabel *)[self.view viewWithTag:ID_PRMSGLABEL];
		[prMsgLabel setText:prePrMsg];
		
		UILabel *subPrMsgLabel = (UILabel *)[self.view viewWithTag:ID_SUBPRMSGLABEL];
		if (subPrMsgLabel) {
			if (prePrMsg && [prePrMsg length] > 0) {
				subPrMsgLabel.textColor = ColorFromRGB(0xaaacb0);
				[subPrMsgLabel setText:prePrMsg];
			} else {
				subPrMsgLabel.textColor = ColorFromRGB(0xaaacb0);
				[subPrMsgLabel setText:@"오늘의 한마디 한글 최대 20자"];
			}
		}
		return;
	} else {
	}

	if ([(NSString*)[notification object] isEqualToString:@""]) {
		if (prePrMsg) {
			[prePrMsg release];
			prePrMsg = nil;
			prePrMsg = [[NSMutableString alloc] initWithString:@""];
		} else {
			prePrMsg = [[NSMutableString alloc] initWithString:@""];
		}
	} else {
		if (prePrMsg) {
			[prePrMsg release];
			prePrMsg = nil;
			prePrMsg = [[NSMutableString alloc] initWithString:notification.object];
		} else {
			prePrMsg = [[NSMutableString alloc] initWithString:notification.object];
		}
	}
}

-(void)loadProfile:(NSNotification *)notification
{
	isRequest = NO;
	if (requestActIndicator) {
		[requestActIndicator stopAnimating]; 
	}
	self.navigationItem.leftBarButtonItem.enabled = YES;
//	NSLog(@"loadProfile response");
	USayHttpData *data = (USayHttpData*)[notification object];
	if (data == nil) {
		// 200 이외의 에러
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
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
	NSString *rtcode = nil;
	rtcode = [dic objectForKey:@"rtcode"];
	
	if ([rtcode isEqualToString:@"0"]) {	// success
		NSString *rtType = [dic objectForKey:@"rttype"];
		if ([rtType isEqualToString:@"map"]) {
			// Key and Dictionary as its value type
			NSDictionary *addressDic = [dic objectForKey:@"map"];
			NSString *formatted = [addressDic objectForKey:@"formatted"];
			[[NSUserDefaults standardUserDefaults] setObject:formatted forKey:@"formatted"];
			
			NSString *nickName = [addressDic objectForKey:@"nickName"];
			if (nickName && [nickName length] > 0)
			{
				// sochae 2010.10.12
				//[[NSUserDefaults standardUserDefaults] setObject:nickName forKey:@"nickName"];
				[JYUtil saveToUserDefaults:nickName forKey:kNickname];
				// ~sochae
				UILabel *nickNameLabel = (UILabel *)[self.view viewWithTag:ID_NICKNAMELABEL];
				[nickNameLabel setText:nickName];
				
				UILabel *subNickNameLabel = (UILabel *)[self.view viewWithTag:ID_SUBNICKNAMELABEL];
				if (subNickNameLabel) {
					[subNickNameLabel setText:nickName];
				}
				if (preNickName) {
					[preNickName release];
					preNickName = nil;
					preNickName = [[NSMutableString alloc] initWithString:(NSMutableString*)nickName];
				} else {
					preNickName = [[NSMutableString alloc] initWithString:(NSMutableString*)nickName];
				}
			} else {
				// error
				// sochae 2010.10.12
				//[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"nickName"];
				[JYUtil saveToUserDefaults:@"" forKey:kNickname];
				// ~sochae
				UILabel *nickNameLabel = (UILabel *)[self.view viewWithTag:ID_NICKNAMELABEL];
				[nickNameLabel setText:@""];

				UILabel *subNickNameLabel = (UILabel *)[self.view viewWithTag:ID_SUBNICKNAMELABEL];
				if (subNickNameLabel) {
					[subNickNameLabel setText:@""];
				}
				if (preNickName) {
					[preNickName release];
					preNickName = nil;
					preNickName = [[NSMutableString alloc] initWithString:(NSMutableString*)@""];
				} else {
					preNickName = [[NSMutableString alloc] initWithString:(NSMutableString*)@""];
				}
			}
			
			NSMutableString *homePhoneNumber = [addressDic objectForKey:@"homePhoneNumber"];
			if (homePhoneNumber && [homePhoneNumber length] > 0) {
				[[NSUserDefaults standardUserDefaults] setObject:homePhoneNumber forKey:@"homePhoneNumber"];
			} else {
				[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"homePhoneNumber"];
			}
		
			NSMutableString *officePhoneNumber = [addressDic objectForKey:@"orgPhoneNumber"];
			if (officePhoneNumber && [officePhoneNumber length] > 0) {
				[[NSUserDefaults standardUserDefaults] setObject:officePhoneNumber forKey:@"orgPhoneNumber"];
			} else {
				[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"orgPhoneNumber"];
			}
			
			NSMutableString *mobilePhoneNumber = [addressDic objectForKey:@"mobilePhoneNumber"];
			if (mobilePhoneNumber && [mobilePhoneNumber length] > 0) {
				[[NSUserDefaults standardUserDefaults] setObject:mobilePhoneNumber forKey:@"mobilePhoneNumber"];
			} else {
				[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"mobilePhoneNumber"];
			}
			
			NSString *homePageStr = [addressDic objectForKey:@"homePageURL"];
			if (homePageStr && [homePageStr length] > 0) {
				[[NSUserDefaults standardUserDefaults] setObject:homePageStr forKey:@"homePageURL"];
			} else {
				[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"homePageURL"];
			}

			NSString *status = [addressDic objectForKey:@"status"];				// 오늘의 한마디
			if (status && [status length] > 0) {
				[[NSUserDefaults standardUserDefaults] setObject:status forKey:@"status"];
				UILabel *prMsgLabel = (UILabel *)[self.view viewWithTag:ID_PRMSGLABEL];
				[prMsgLabel setText:status];
				
				UILabel *subPrMsgLabel = (UILabel *)[self.view viewWithTag:ID_SUBPRMSGLABEL];
				if (subPrMsgLabel) {
					subPrMsgLabel.textColor = ColorFromRGB(0xaaacb0);
					if (status && [status length] > 0) {
						[subPrMsgLabel setText:status];
					} else {
						[subPrMsgLabel setText:@"오늘의 한마디 한글 최대 20자"];
					}
				}
				if (prePrMsg) {
					[prePrMsg release];
					prePrMsg = nil;
					prePrMsg = [[NSMutableString alloc] initWithString:status];
				} else {
					prePrMsg = [[NSMutableString alloc] initWithString:status];
				}
			} else {
				[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"status"];
				UILabel *prMsgLabel = (UILabel *)[self.view viewWithTag:ID_PRMSGLABEL];
				[prMsgLabel setText:status];
				
				UILabel *subPrMsgLabel = (UILabel *)[self.view viewWithTag:ID_SUBPRMSGLABEL];
				if (subPrMsgLabel) {
					subPrMsgLabel.textColor = ColorFromRGB(0xaaacb0);
					if (status && [status length] > 0) {
						[subPrMsgLabel setText:status];
					} else {
						[subPrMsgLabel setText:@"오늘의 한마디 한글 최대 20자"];
					}
				}
				if (prePrMsg) {
					[prePrMsg release];
					prePrMsg = nil;
					prePrMsg = [[NSMutableString alloc] initWithString:@""];
				} else {
					prePrMsg = [[NSMutableString alloc] initWithString:@""];
				}
			}

			NSString *apnsonpreview = [addressDic objectForKey:@"isOnPreview"];	// APNS 내용 미리보기
			if (apnsonpreview && [apnsonpreview length] > 0) {
				if ([apnsonpreview isEqualToString:@"Y"]) {
					[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"apnsonpreview"];
				} else {
					[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"apnsonpreview"];
				}
			} else {
				[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"apnsonpreview"];
			}

			// 원본 : photoUrl + /008
			// 160*120 : photoUrl + /003
			// 400*300 : photoUrl + /004
			// 41*41 : photoUrl + /011
			// 64*64 : photoUrl + /012
			// 90*90 : photoUrl + /013
			
			// 대표 사진 정보
			NSString *representPhotoUrl = [addressDic objectForKey:@"representPhoto"];
			if (representPhotoUrl && [representPhotoUrl length] > 0) {
				if (representPhoto) {
					[representPhoto release];
					representPhoto = nil;
					
					representPhoto = [[NSMutableString alloc] initWithString:representPhotoUrl];
					DebugLog(@"loadProfile representPhoto = %@", representPhoto);
				} else {
					representPhoto = [[NSMutableString alloc] initWithString:representPhotoUrl];
					DebugLog(@"loadProfile representPhoto = %@", representPhoto);
				}
			} else {
				if (representPhoto) {
					[representPhoto release];
					representPhoto = nil;
					
					representPhoto = [[NSMutableString alloc] initWithString:@""];
					DebugLog(@"loadProfile representPhoto = %@", representPhoto);
				} else {
					representPhoto = [[NSMutableString alloc] initWithString:@""];
					DebugLog(@"loadProfile representPhoto = %@", representPhoto);
				}
			}

			// sub 사진 정보
			self.subPhotosArray = [addressDic objectForKey:@"photos"];

			if (representPhoto && [self.representPhoto length] > 0) {
				SDWebImageManager *manager = [SDWebImageManager sharedManager];
				
				UIImage *cachedImage = [manager imageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/012", self.representPhoto]]];
				
				if (cachedImage)
				{
					// Use the cached image immediatly
					UIButton *mainPhotoBtn = (UIButton *)[self.view viewWithTag:ID_MAINPHOTO];
					if(mainPhotoBtn) {
						[mainPhotoBtn setBackgroundImage:cachedImage forState:UIControlStateNormal];
					}
				}
				else
				{
					// Start an async download
					[manager downloadWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/012", self.representPhoto]] delegate:self];
				}
			}
			
			NSArray *organizationArray = [addressDic objectForKey:@"organization"];
			if (organizationArray && [organizationArray count] > 0) {
				for (NSString *organization in organizationArray) {
					if (organization && [organization length] > 0) {
						// organization 처리
						UILabel *organizationLabel = (UILabel *)[self.view viewWithTag:ID_ORGANIZATIONLABEL];
						[organizationLabel setText:organization];
						[[NSUserDefaults standardUserDefaults] setObject:organization forKey:@"organization"];
						break;
					} else {
						if ([organizationArray count] == 1) {
							[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"organization"];
						}
					}
				}
			} else {
				[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"organization"];
			}

			NSArray *emailArray = [addressDic objectForKey:@"emailAddress"];
			if (emailArray && [emailArray count] > 0) {
				for (NSString *email in emailArray) {
					if (email && [email length] > 0) {
						[[NSUserDefaults standardUserDefaults] setObject:email forKey:@"email"];
						break;
					} else {
						if ([emailArray count] == 1) {
							[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"email"];
						}
					}
				}
			} else {
				[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"email"];
			}

		} else {
			// 예외처리
		}
	} else if ([rtcode isEqualToString:@"-9030"]) {
		// 처리 오류
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-9030)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else if ([rtcode isEqualToString:@"-1090"]) {
		// 인증되지 않음
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-1090)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else if ([rtcode isEqualToString:@"-2010"]) {
		// 세션정보를 찾을 수 없음
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-2010)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else if ([rtcode isEqualToString:@"-8080"]) {
		// 기타 오류
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-8080)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else {
		// 실패 예외처리 필요
		// fail (-8080 이외 기타오류)
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0035)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	}
}

#pragma mark -
#pragma mark Table view callbacks

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
//	assert(tableView != nil);
	
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *title = nil;
	
//	assert(section <= kMyProfileSection);
	
	switch (section)
	{
		case kStateSection:
		{
			title = NSLocalizedString(@"상태 설정", @"");
			break;
		}
		case kNickSection:
		{
			title = NSLocalizedString(@"별명", @"");
			break;
		}
		case kPrMsgSection:
		{
			title = NSLocalizedString(@"오늘의 한마디", @"");
			break;
		}
		case kMyProfileSection:
		{
			title = NSLocalizedString(@"내 정보 설정", @"");
			break;
		}
		default:
		{
//			assert(NO);
			title = nil;
			break;
		}
	}
	return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger rowCount = 1;
	
	if (section == kStateSection) {
		rowCount = 4;
	} 

	return rowCount;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *kStateCellIdentifier = @"StateSetting";
	static NSString *kNickCellIdentifier = @"NickSetting";
	static NSString *kPrMsgCellIdentifier = @"PrMsgSetting";
	static NSString *kMyProfileCellIdentifier = @"MyProfileSetting";

	UITableViewCell *cell = nil;
	switch (indexPath.section)
	{
		case kStateSection:		// 0:offline  1:online  2:busy (바빠요)  8:곧 돌아옵니다.  16:다른용무중
		{
			cell = [tableView dequeueReusableCellWithIdentifier:kStateCellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kStateCellIdentifier] autorelease];
				switch (indexPath.row)
				{
					case 0:
					{
						cell.imageView.image = [UIImage imageNamed:@"state_on.png"];
						cell.textLabel.text = NSLocalizedString(@"온라인", @"");
						cell.textLabel.textColor = ColorFromRGB(0x2284ac);
						cell.textLabel.font = [UIFont systemFontOfSize:17];
						break;
					}
					case 1:
					{
						cell.imageView.image = [UIImage imageNamed:@"state_busy.png"];
						cell.textLabel.text = NSLocalizedString(@"바쁨", @"");
						cell.textLabel.textColor = ColorFromRGB(0x2284ac);
						cell.textLabel.font = [UIFont systemFontOfSize:17];
						break;
					}
					case 2:
					{
						cell.imageView.image = [UIImage imageNamed:@"state_time.png"];
						cell.textLabel.text = NSLocalizedString(@"자리비움", @"");
						cell.textLabel.textColor = ColorFromRGB(0x2284ac);
						cell.textLabel.font = [UIFont systemFontOfSize:17];
						break;
					}
					case 3:
					{
						cell.imageView.image = [UIImage imageNamed:@"state_do.png"];
						cell.textLabel.text = NSLocalizedString(@"다른 용무중", @"");
						cell.textLabel.textColor = ColorFromRGB(0x2284ac);
						cell.textLabel.font = [UIFont systemFontOfSize:17];
						break;
					}
				}

				// 0:offline  1:online  2:busy (바빠요)  8:곧 돌아옵니다.  16:다른용무중
				if ((indexPath.row == 0 && [self.preImStatus isEqualToString:@"1"])
					|| (indexPath.row == 1 && [self.preImStatus isEqualToString:@"2"])
					|| (indexPath.row == 2 && [self.preImStatus isEqualToString:@"8"])
					|| (indexPath.row == 3 && [self.preImStatus isEqualToString:@"16"])) {
					cell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CheckIcon.png"]] autorelease];
					cell.textLabel.textColor = ColorFromRGB(0xaaacb0);
				} else {
					cell.accessoryView = nil;
					cell.textLabel.textColor = ColorFromRGB(0x2284ac);
				}
			}
			break;
		}
		case kNickSection:
		{
			cell = [tableView dequeueReusableCellWithIdentifier:kNickCellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kNickCellIdentifier] autorelease];
				cell.textLabel.tag = ID_SUBNICKNAMELABEL;
				cell.textLabel.textColor = ColorFromRGB(0xaaacb0);
				// sochae 2010.10.12
				//cell.textLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"nickName"];
				cell.textLabel.text = (NSString *)[JYUtil loadFromUserDefaults:kNickname];
				// ~sochae
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				cell.textLabel.font = [UIFont systemFontOfSize:17];
			}
			break;
		}
		case kPrMsgSection:
		{
			cell = [tableView dequeueReusableCellWithIdentifier:kPrMsgCellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kPrMsgCellIdentifier] autorelease];
				cell.textLabel.tag = ID_SUBPRMSGLABEL;
				
				if ([[NSUserDefaults standardUserDefaults] objectForKey:@"status"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"status"] length] > 0) {
					cell.textLabel.textColor = ColorFromRGB(0xaaacb0);
					cell.textLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"status"];
				} else {
					cell.textLabel.textColor = ColorFromRGB(0xaaacb0);
					cell.textLabel.text = @"오늘의 한마디 한글 최대 20자";
				}
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				cell.textLabel.font = [UIFont systemFontOfSize:17];
			}
			break;
		}
		case kMyProfileSection:
		{
			cell = [tableView dequeueReusableCellWithIdentifier:kMyProfileCellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kMyProfileCellIdentifier] autorelease];
				cell.textLabel.textColor = ColorFromRGB(0xaaacb0);
				//cell.textLabel.textColor = ColorFromRGB();
				cell.textLabel.text = @"내 정보 설정";
				
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				cell.textLabel.font = [UIFont systemFontOfSize:17];
			}
			break;
		}
		default:
			break;
	}
	
    // Configure the cell...
    // Set attributes common to all cell types.
//	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (isRequest == YES) {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		return;
	}
	if ([self appDelegate].connectionType == -1) {	// -1:offline mode  0:disconnect 1:Wi-Fi 2:3G
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		return;
	} else if ([self appDelegate].connectionType == 0) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"3G 또는 Wi-Fi 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0036)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return;
	}
	NSUInteger          section = indexPath.section;
    NSUInteger          row = indexPath.row;
	UITableViewCell *   cellToClear = nil;
    UITableViewCell *   cellToSet = nil;

	//*	셀 선택시 처리
	switch (section) {
		case kStateSection:
		{
			if ([self appDelegate].connectionType == -1) {	// -1:offline mode  0:disconnect 1:Wi-Fi 2:3G
				[tableView deselectRowAtIndexPath:indexPath animated:YES];
				break;
			} else if ([self appDelegate].connectionType == 0) {
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"3G 또는 Wi-Fi 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0037)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
				[alertView show];
				[alertView release];
				[tableView deselectRowAtIndexPath:indexPath animated:YES];
				break;
			}
			
			if ((row == 0 && [preImStatus isEqualToString:@"1"])
				|| (row == 1 && [preImStatus isEqualToString:@"2"])
				|| (row == 2 && [preImStatus isEqualToString:@"8"])
				|| (row == 3 && [preImStatus isEqualToString:@"16"]) ) {
				[tableView deselectRowAtIndexPath:indexPath animated:YES];
				break;
			}

			// 0:offline  1:online  2:busy (바빠요)  8:곧 돌아옵니다.  16:다른용무중
			for (int i = 0; i<4; i++) {
				cellToClear = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:section]];
				cellToClear.accessoryView = nil;
				cellToClear.textLabel.textColor = ColorFromRGB(0x2284ac);
			}
			
			cellToSet = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
			cellToSet.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CheckIcon.png"]] autorelease];
			cellToSet.textLabel.textColor = ColorFromRGB(0xaaacb0);
			// 내 상태 정보값 서버에 패킷 전송
			// 변경할 상태 정보
			if (row == 0) {			// online
				preImStatus = (NSMutableString*)@"1";
			} else if (row == 1) {
				preImStatus = (NSMutableString*)@"2";
			} else if (row == 2) {
				preImStatus = (NSMutableString*)@"8";
			} else if (row == 3) {
				preImStatus = (NSMutableString*)@"16";
			} else {
				// skip
				break;
			}
			[[self appDelegate] updatePresence:preImStatus];
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			break;
		}
		case kNickSection:
		{
			if (indexPath.row == 0) {
				InputNickNameViewController *inputNickNameViewController = [[InputNickNameViewController alloc] init];
				// sochae 2010.10.12
				//inputNickNameViewController.preNickName = [[NSUserDefaults standardUserDefaults] objectForKey:@"nickName"];
				inputNickNameViewController.preNickName = (NSString *)[JYUtil loadFromUserDefaults:kNickname];
				// ~sochae
				[self.navigationController pushViewController:inputNickNameViewController animated:YES];
				[inputNickNameViewController release];
			}
			break;
		}
		case kPrMsgSection:
		{
			if (indexPath.row == 0) {
				InputStatusViewController *inputStatusViewController = [[InputStatusViewController alloc] init];
				inputStatusViewController.preStatus = [[NSUserDefaults standardUserDefaults] objectForKey:@"status"];
				[self.navigationController pushViewController:inputStatusViewController animated:YES];
				[inputStatusViewController release];
			}
			break;
		}
		case kMyProfileSection:
		{
			if (indexPath.row == 0) {
				MyInfoSettingViewController *myInfoSettingViewController = [[MyInfoSettingViewController alloc] initWithNibName:@"MyInfoSettingViewController" bundle:nil];
				[self.navigationController pushViewController:myInfoSettingViewController animated:YES];
				[myInfoSettingViewController release];
			}
			break;
		}
		default:
			break;
	}
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

-(void)cancleModal
{
	UIImagePickerController *myPicker = (UIImagePickerController*)self.modalViewController;
	[myPicker dismissModalViewControllerAnimated:YES];
	
}

-(void)backNavi
{
	UIImagePickerController *myPicker = (UIImagePickerController*)self.modalViewController;
	[myPicker popViewControllerAnimated:YES];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	UIImagePickerController *myPicker = (UIImagePickerController*)self.modalViewController;
	myPicker.navigationBar.topItem.title=@"";
	DebugLog(@"1");
	myPicker.navigationBar.alpha=0.0001;
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	
	UIImagePickerController *myPicker = (UIImagePickerController*)self.modalViewController;
	
	UIButton *preButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 52, 31)] autorelease];
	[preButton setBackgroundImage:[UIImage imageNamed:@"btn_top_left.png"] forState:UIControlStateNormal];
	[preButton setBackgroundImage:[UIImage imageNamed:@"btn_top_left_focus"] forState:UIControlStateHighlighted];
	[preButton addTarget:self action:@selector(backNavi) forControlEvents:UIControlEventTouchUpInside];
	

	UIBarButtonItem *backButton = [[[UIBarButtonItem alloc] initWithCustomView:preButton] autorelease];

	
	
									 
	
	UIButton *cancleButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 47, 31)] autorelease];
	[cancleButton setBackgroundImage:[UIImage imageNamed:@"btn_searchbar_cancel.png"] forState:UIControlStateNormal];
	[cancleButton setBackgroundImage:[UIImage imageNamed:@"btn_searchbar_cancel_focus.png"] forState:UIControlStateHighlighted];
	[cancleButton addTarget:self action:@selector(cancleModal) forControlEvents:UIControlEventTouchUpInside];
	
	UIBarButtonItem *rightButton = [[[UIBarButtonItem alloc] initWithCustomView:cancleButton] autorelease];
	
	
	
	
	[myPicker.navigationBar.topItem.backBarButtonItem setImage:[UIImage imageNamed:@"btn_top_left.png"]];
	myPicker.navigationBar.alpha=1;
	DebugLog(@"title = %@", myPicker.navigationBar.topItem.title);
	if(![myPicker.navigationBar.topItem.title isEqualToString:@""])
	{
		myPicker.navigationBar.topItem.leftBarButtonItem = backButton;
		
	}
	
	
	myPicker.navigationBar.topItem.title=@"";
	myPicker.navigationBar.topItem.rightBarButtonItem = rightButton;
	if(myLabel == NULL)
	{
		myLabel = [[UILabel alloc] initWithFrame:CGRectMake(115, 0, 120, 44)];
		[myLabel setBackgroundColor:[UIColor clearColor]];
		[myLabel setText:@"사진 앨범"];
		[myLabel setFont:[UIFont systemFontOfSize:18]];
	}
	if(![myLabel superview])
		[myPicker.navigationBar addSubview:myLabel];
}


#pragma mark -
#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	DebugLog(@"User Pressed Button %i", buttonIndex);
	
	if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		// 카메라 사용 못함.
		if (buttonIndex == 0) {	// album 사진, 동영상
			if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
				photoLibraryShown = YES;
				UIImagePickerController *picker = [[UIImagePickerController alloc] init];
				picker.delegate = self;
				picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
				picker.allowsEditing = YES;
				picker.mediaTypes = [NSArray arrayWithObjects:@"public.image", nil];
				[self presentModalViewController:picker animated:YES];
				[picker release];
			} else {
				// skip
			}
		} else if (buttonIndex == 1) {	// cancel

		} else {
			// skip
		}
	} else {
		if (buttonIndex == 0) {			// 사진 촬영
			photoLibraryShown = YES;
			UIImagePickerController *picker = [[UIImagePickerController alloc] init];
			picker.delegate = self;
			picker.sourceType = UIImagePickerControllerSourceTypeCamera;
			picker.allowsEditing = YES;
			picker.mediaTypes = [NSArray arrayWithObjects:@"public.image", nil];
			[self presentModalViewController:picker animated:YES];
			[picker release];
		} else if (buttonIndex == 1) {	// album 사진, 동영상
			if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
				photoLibraryShown = YES;
				UIImagePickerController *picker = [[UIImagePickerController alloc] init];
				picker.delegate = self;
				picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
				picker.allowsEditing = YES;
				picker.mediaTypes = [NSArray arrayWithObjects:@"public.image", nil];
				[self presentModalViewController:picker animated:YES];
				
				picker.navigationBar.topItem.title=@" ";
				
				
				
		//		[picker.navigationBar.topItem setTextColor:[UIColor blackColor]];
		
			/*	
				UILabel *titleLabel  = [[[UILabel alloc] initWithFrame:CGRectMake(115, 9, 320, 44)] autorelease];
				[titleLabel setText:@"사진 앨범"];
				[titleLabel setBackgroundColor:[UIColor colorWithRed:140.0/255.0 green:209.0/255.0 blue:225.0/255.0 alpha:1]];
				[titleLabel setTextColor:[UIColor blackColor]];
				[titleLabel setFont:[UIFont systemFontOfSize:20]];
				[titleLabel sizeToFit];
		//		[picker.navigationBar.topItem setTitle:@" "];
				[picker.navigationBar addSubview:titleLabel];
				 
			*/	
				[picker release];
			} else {
				// skip
			}
		} else if (buttonIndex == 2) {	// cancel
			
		} else {
			// skip
		}
	}
	
//[actionSheet release];
}

-(UIImage*)resizeImage:(UIImage*)image scaleFlag:(BOOL)aFlag
{
	UIImage *originImage = [image retain];
    CGImageRef imgRef = originImage.CGImage;
	
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
	
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
	
    if (aFlag) {
		if (width > kMaxResolution || height > kMaxResolution) {
			CGFloat ratio = width / height;
			if (ratio > 1) {
				bounds.size.width = kMaxResolution;
				bounds.size.height = bounds.size.width / ratio;
			} else {
				bounds.size.width = bounds.size.height * ratio;
				bounds.size.height = kMaxResolution;
			}
		} else {
		}
    }
	
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
	
    switch (orient) {
        case UIImageOrientationUp: 
            transform = CGAffineTransformIdentity;
            break;
			
        case UIImageOrientationUpMirrored: 
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
			
        case UIImageOrientationDown: 
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
			
        case UIImageOrientationDownMirrored: 
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
			
        case UIImageOrientationLeftMirrored: 
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
			
        case UIImageOrientationLeft: 
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
			
        case UIImageOrientationRightMirrored: 
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
			
        case UIImageOrientationRight: 
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
			
        default:
            [NSException raise:NSInternalInconsistencyException format:@"ProfileSettingViewController Invalid image orientation"];
    }
	
    UIGraphicsBeginImageContext(bounds.size);
	
    CGContextRef context = UIGraphicsGetCurrentContext();
	
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    } else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
	
    CGContextConcatCTM(context, transform);
	
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
	[originImage release];
	
    return imageCopy;
}

-(UIImage*)thumbNailImage:(UIImage*)image Size:(CGFloat)resizeSize
{
	UIImage *originImage = [image retain];
	UIGraphicsBeginImageContext(CGSizeMake(resizeSize, resizeSize));
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, 0.0, resizeSize);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	CGContextDrawImage(context, CGRectMake(0.0, 0.0, resizeSize, resizeSize), [originImage CGImage]);
	UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	[originImage release];
	return scaledImage;
}


#pragma mark -
#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
	if ([mediaType isEqualToString:@"public.image"]) {			// 사진
		UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
		if (image) {
			
			UIImage *resizeImage = [self resizeImage:image scaleFlag:YES];
			if (!resizeImage) {
				[picker dismissModalViewControllerAnimated:TRUE];
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"이미지파일 오류" message:@"잘못된 이미지 파일입니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
				[alertView show];
				[alertView release];
				return;
			}
			
			UIButton *mainPhotoBtn = (UIButton *)[self.view viewWithTag:ID_MAINPHOTO];
			if(mainPhotoBtn) {
				[mainPhotoBtn setBackgroundImage:[self thumbNailImage:resizeImage Size:64.0f] forState:UIControlStateNormal];
			}

			NSData *imageData = nil;
			CGImageRef imgRef = image.CGImage;
			CGFloat width = CGImageGetWidth(imgRef);
			CGFloat height = CGImageGetHeight(imgRef);
			if (width > kMaxResolution || height > kMaxResolution) {
				imageData = UIImageJPEGRepresentation(resizeImage, 0.9f);
			} else {
				imageData = UIImageJPEGRepresentation(resizeImage, 1.0f);
			}
			if (!imageData) {
				[picker dismissModalViewControllerAnimated:TRUE];
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"이미지파일 오류" message:@"잘못된 이미지 파일입니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
				[alertView show];
				[alertView release];
				return;
			}
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *documentsDirectory = [paths objectAtIndex:0];
			
			if (representPhotoFilePath) {
				[representPhotoFilePath release];
				representPhotoFilePath = nil;
				representPhotoFilePath = [[NSMutableString alloc] initWithFormat:@"%@.jpg", [[self appDelegate] generateUUIDString]];
			} else {
				representPhotoFilePath = [[NSMutableString alloc] initWithFormat:@"%@.jpg", [[self appDelegate] generateUUIDString]];
			}
			NSString* imagePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithString:representPhotoFilePath]];
			
			
			if (![imageData writeToFile:imagePath atomically:YES]) {
				DebugLog(@"imagePath writeToFile error");
			}

			if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath isDirectory:NO]) {
				// not exist file
				[picker dismissModalViewControllerAnimated:YES];
				return;
			}
			NSString *pkey = [[self appDelegate].myInfoDictionary objectForKey:@"pkey"];
			NSString *isRepresent = @"1";
			
			NSString *transParam = nil;
			
			if (representPhoto && [representPhoto length] > 0) {
				if ([HttpAgent mc] == nil || [HttpAgent cs] == nil) {
#ifdef DEVEL_MODE	// sochae 2010.09.09 - dev server
					transParam = [[NSString alloc ] initWithFormat:@"https://social.paran.com/KTH/updateProfilePhoto.json?pKey=%@&UCMC=%@&UCCS=%@&svcidx=%@&isRepresent=%@&originUrl=%@", 
#else
					transParam = [[NSString alloc ] initWithFormat:@"https://dev.usay.net/KTH/updateProfilePhoto.json?pKey=%@&UCMC=%@&UCCS=%@&svcidx=%@&isRepresent=%@&originUrl=%@", 
#endif // #ifdef DEVEL_MODE
								  pkey,
								  [HttpAgent ucmc], [HttpAgent uccs], [[self appDelegate] getSvcIdx], isRepresent, representPhoto];
				} else {
#ifdef DEVEL_MODE	// sochae 2010.09.09 - dev server
					transParam = [[NSString alloc ] initWithFormat:@"https://social.paran.com/KTH/updateProfilePhoto.json?pKey=%@&MC=%@&CS=%@&UCMC=%@&UCCS=%@&svcidx=%@&isRepresent=%@&originUrl=%@", 
#else
					transParam = [[NSString alloc ] initWithFormat:@"https://dev.usay.net/KTH/updateProfilePhoto.json?pKey=%@&MC=%@&CS=%@&UCMC=%@&UCCS=%@&svcidx=%@&isRepresent=%@&originUrl=%@", 
#endif // #ifdef DEVEL_MODE
								  pkey, [HttpAgent mc], [HttpAgent cs],
								  [HttpAgent ucmc], [HttpAgent uccs], [[self appDelegate] getSvcIdx], isRepresent, representPhoto];
				}
			} else {
				if ([HttpAgent mc] == nil || [HttpAgent cs] == nil) {
#ifdef DEVEL_MODE	// sochae 2010.09.09 - dev server
					transParam = [[NSString alloc ] initWithFormat:@"https://social.paran.com/KTH/insertProfilePhoto.json?pKey=%@&UCMC=%@&UCCS=%@&svcidx=%@&isRepresent=%@", 
#else
					transParam = [[NSString alloc ] initWithFormat:@"https://dev.usay.net/KTH/insertProfilePhoto.json?pKey=%@&UCMC=%@&UCCS=%@&svcidx=%@&isRepresent=%@", 
#endif // #ifdef DEVEL_MODE
								  pkey,
								  [HttpAgent ucmc], [HttpAgent uccs], [[self appDelegate] getSvcIdx], isRepresent];
				} else {
#ifdef DEVEL_MODE	// sochae 2010.09.09 - dev server
					transParam = [[NSString alloc ] initWithFormat:@"https://social.paran.com/KTH/insertProfilePhoto.json?pKey=%@&MC=%@&CS=%@&UCMC=%@&UCCS=%@&svcidx=%@&isRepresent=%@", 
#else
					transParam = [[NSString alloc ] initWithFormat:@"https://dev.usay.net/KTH/insertProfilePhoto.json?pKey=%@&MC=%@&CS=%@&UCMC=%@&UCCS=%@&svcidx=%@&isRepresent=%@", 
#endif // #ifdef DEVEL_MODE
								  pkey, [HttpAgent mc], [HttpAgent cs],
								  [HttpAgent ucmc], [HttpAgent uccs], [[self appDelegate] getSvcIdx], isRepresent];
				}
			}
			DebugLog(@"=== KTH : transParam = %@", transParam);
			
			NSString *uuid = [NSString stringWithString:[[self appDelegate] generateUUIDString]];
			
			NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
			[bodyObject setObject:@"1" forKey:@"mediaType"];		// 0: video  1: photo
			[bodyObject setObject:uuid forKey:@"uuid"];
			[bodyObject setObject:[NSNull null] forKey:@"uploadFile"];
			[bodyObject setObject:transParam forKey:@"transParam"];
			
			// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
			USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"albumUpload" andWithDictionary:bodyObject timeout:30] autorelease];
			if (representPhoto && [representPhoto length] > 0) {
				data.subApi = @"updateProfilePhoto";
			} else {
				data.subApi = @"insertProfilePhoto";
			}

			data.filePath = imagePath;
			data.uniqueId = [NSString stringWithString:uuid];
			data.isRepresent = isRepresent;
			[transParam release];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"requestUploadUrlMultipartForm" object:data];
		} else {
			if (photoLibraryShown == YES) {
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"이미지파일 오류" message:@"잘못된 이미지 파일입니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
				[alertView show];
				[alertView release];
			}
		}

	} else if ([mediaType isEqualToString:@"public.movie"]) {	// 동영상 MOV 확장자로 생성
	}
	
	[picker dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[picker dismissModalViewControllerAnimated:YES];
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
	UIButton *mainPhotoBtn = (UIButton *)[self.view viewWithTag:ID_MAINPHOTO];
	if(mainPhotoBtn) {
		[mainPhotoBtn setBackgroundImage:image forState:UIControlStateNormal];
	}
}

#pragma mark -

-(USayAppAppDelegate *) appDelegate
{
	return (USayAppAppDelegate *)[[UIApplication sharedApplication] delegate];
}

-(NSInteger) displayTextLength:(NSString*)text
{
	NSInteger textLength = [text length];
	NSInteger textLengthUTF8 = [text lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	NSInteger correntLength = (textLengthUTF8 - textLength)/2 + textLength;
	
	return correntLength;
}

- (void) photoClicked
{
	if ([self appDelegate].connectionType == -1) {	// -1:offline mode  0:disconnect 1:Wi-Fi 2:3G
		return;
	} else if ([self appDelegate].connectionType == 0) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"3G 또는 Wi-Fi 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0038)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return;
	}
	if (isRequest == YES) {
		return;
	}
	UIActionSheet *menu = nil;
	if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		// 카메라 사용 못함.
		menu = [[UIActionSheet alloc] initWithTitle:nil 
										   delegate:self
								  cancelButtonTitle:@"취소"
							 destructiveButtonTitle:nil
								  otherButtonTitles:@"앨범에서 사진 선택", nil];
	} else {
		menu = [[UIActionSheet alloc] initWithTitle:nil 
										   delegate:self
								  cancelButtonTitle:@"취소"
							 destructiveButtonTitle:nil
								  otherButtonTitles:@"사진 촬영", @"앨범에서 사진 선택", nil];
	}
	[menu showInView:self.view];
	[menu release];
}

-(void)backBarButtonClicked 
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)insertNickName:(NSString*)nickName
{
	isRequest = YES;
	self.navigationItem.leftBarButtonItem.enabled = NO;
	timer = [NSTimer scheduledTimerWithTimeInterval:0.001 target:self 
													   selector:@selector(startActIndecatorPlay:) 
													   userInfo:nil repeats:NO];
	
	UILabel *nickNameLabel = (UILabel *)[self.view viewWithTag:ID_NICKNAMELABEL];
	[nickNameLabel setText:nickName];
	
	UILabel *subNickNameLabel = (UILabel *)[self.view viewWithTag:ID_SUBNICKNAMELABEL];
	[subNickNameLabel setText:nickName];
}

-(void)insertPrMsg:(NSString*)status
{
	isRequest = YES;
	self.navigationItem.leftBarButtonItem.enabled = NO;
	timer = [NSTimer scheduledTimerWithTimeInterval:0.001 target:self 
													   selector:@selector(startActIndecatorPlay:) 
													userInfo:nil repeats:NO];
	UILabel *prMsgLabel = (UILabel *)[self.view viewWithTag:ID_PRMSGLABEL];
	[prMsgLabel setText:status];
	
	UILabel *subPrMsgLabel = (UILabel *)[self.view viewWithTag:ID_SUBPRMSGLABEL];
	if (subPrMsgLabel) {
		if (status && [status length] > 0) {
			subPrMsgLabel.textColor = ColorFromRGB(0xaaacb0);
			[subPrMsgLabel setText:status];
		} else {
			subPrMsgLabel.textColor = ColorFromRGB(0xaaacb0);
			[subPrMsgLabel setText:@"오늘의 한마디 한글 최대 20자"];
		}
	}	
}

-(void)insertOrganization:(NSString*)organization
{
	UILabel *orgLabel = (UILabel *)[self.view viewWithTag:ID_ORGANIZATIONLABEL];
	if(orgLabel && organization) {
		[orgLabel setText:organization];
	}
}

-(void) startActIndecatorPlay:(NSTimer *)theTimer {
	if (timer) {
		[timer invalidate];
	}
	if (requestActIndicator) {
		[requestActIndicator startAnimating];
	}
}

//*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}
//*/

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
			break;
        default:  
            break;  
    }  
	
	// sochae 2010.09.10 - UI Position
	//CGRect rect = [MyDeviceClass deviceOrientation];
	CGRect rect = self.view.frame;
	// ~sochae

	UIView *tableHeaderView = (UIView *)[self.view viewWithTag:ID_TABLEHEADERVIEW];
	if (tableHeaderView) {
		CGRect tableHeaderViewFrame = tableHeaderView.frame;
		tableHeaderViewFrame.size.width = rect.size.width;
		tableHeaderView.frame = tableHeaderViewFrame;
	}
	
	if (settingTableView) {
		CGRect tableViewFrame = settingTableView.frame;
		tableViewFrame.size.width = rect.size.width;
		tableViewFrame.size.height = rect.size.height;
		settingTableView.frame = tableViewFrame;
	}
	
	UILabel *statusLabel = (UILabel *)[self.view viewWithTag:ID_PRMSGLABEL];
	if (statusLabel) {
		CGRect statusLabelFrame = statusLabel.frame;
		statusLabelFrame.size.width = rect.size.width - 108.0 - 10;
		statusLabel.frame = statusLabelFrame;
	}
	
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
	CGRect requestActIndicatorFrame = requestActIndicator.frame;
	requestActIndicatorFrame.origin.x = (rect.size.width - 30.0)/2.0;
	requestActIndicatorFrame.origin.y = (rect.size.height - 30.0)/2.0 - 15.0;
	requestActIndicator.frame = requestActIndicatorFrame;
}

- (void)viewWillAppear:(BOOL)animated
{
	if (photoLibraryShown) {
		photoLibraryShown = NO;
	}
	else
	{
		// sochae 2010.09.10 - UI Position (iPhone4)
		//CGRect rect = [MyDeviceClass deviceOrientation];
		CGRect rect = self.view.frame;
		// ~sochae
		
		UIView *tableHeaderView = (UIView *)[self.view viewWithTag:ID_TABLEHEADERVIEW];
		if (tableHeaderView) {
			CGRect tableHeaderViewFrame = tableHeaderView.frame;
			tableHeaderViewFrame.size.width = rect.size.width;
			tableHeaderView.frame = tableHeaderViewFrame;
			if (settingTableView) {
				CGRect tableViewFrame = settingTableView.frame;
				tableViewFrame.size.width = rect.size.width;
				tableViewFrame.size.height = rect.size.height;
				
				settingTableView.frame = tableViewFrame;
			}
		}
		
		UILabel *statusLabel = (UILabel *)[self.view viewWithTag:ID_PRMSGLABEL];
		if (statusLabel) {
			CGRect statusLabelFrame = statusLabel.frame;
			statusLabelFrame.size.width = rect.size.width - 108.0 - 10;
			statusLabel.frame = statusLabelFrame;
		}
		
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
	
	NSIndexPath *tableSelection = [self.settingTableView indexPathForSelectedRow];
	[self.settingTableView deselectRowAtIndexPath:tableSelection animated:NO];
}
//*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.view.backgroundColor = ColorFromRGB(0x8fcad9);

	// sochae 2010.09.10 - UI Position
	//CGRect rect = [MyDeviceClass deviceOrientation];
	CGRect rect = self.view.frame;
	// ~sochae

	if (settingTableView == nil) {
		settingTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height) style:UITableViewStyleGrouped];
		[settingTableView setBackgroundColor:[UIColor clearColor]];
		settingTableView.delegate = self;
		settingTableView.dataSource = self;
		settingTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
		settingTableView.separatorColor = ColorFromRGB(0xc2c2c3);
		[self.view addSubview:settingTableView];
		
		self.settingTableView.backgroundColor = ColorFromRGB(0xedeff2);
	}
	
	UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
	UIFont *titleFont = [UIFont systemFontOfSize:20];
	CGSize titleStringSize = [@"프로필 설정" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
	UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
	[titleLabel setFont:titleFont];
	titleLabel.textAlignment = UITextAlignmentCenter;
	[titleLabel setTextColor:ColorFromRGB(0x053844)];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	[titleLabel setText:@"프로필 설정"];
	[titleView addSubview:titleLabel];	
	[titleLabel release];
	self.navigationItem.titleView = titleView;
	[titleView release];
	self.navigationItem.titleView.frame = CGRectMake((self.settingTableView.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);

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
//	
//	// Create and set the table header view.
//	UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 155)];
//	assert(tableHeaderView != nil);
//	[tableHeaderView setBackgroundColor:[UIColor colorWithRed:237.0/255.0 green:239.0/255.0 blue:242.0/255.0 alpha:1.0f]];
//	
//	UIView *mainPhotoView = [[UIView alloc] initWithFrame:CGRectMake(32.0f, 16.0f, 64.0f, 64.0f)];
//	assert(mainPhotoView != nil);
//	[mainPhotoView setBackgroundColor:[UIColor clearColor]];
//	mainPhotoView.layer.masksToBounds = YES;
//	mainPhotoView.layer.cornerRadius = 5.0;
//
//	UIButton *mainPhotoBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//	assert(mainPhotoBtn != nil);
//	[mainPhotoBtn addTarget:self action:@selector(photoClicked) forControlEvents:UIControlEventTouchUpInside];
//	mainPhotoBtn.hidden = NO;
//	mainPhotoBtn.alpha = 1.0f;
//	mainPhotoBtn.tag = ID_MAINPHOTO;
//	[mainPhotoBtn setBackgroundImage:[UIImage imageNamed:@"img_Addressbook_default.png"] forState:UIControlStateNormal];
//	[mainPhotoView addSubview:mainPhotoBtn];
//	[mainPhotoBtn setFrame:CGRectMake(0.0f, 0.0f, 64.0f, 64.0f)];
//
//	UILabel *modifyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//	assert(modifyLabel != nil);
//	[modifyLabel setFont:[UIFont boldSystemFontOfSize:13.0]];
//	[modifyLabel setBackgroundColor:[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.5f]];
//	[modifyLabel setTextColor:[UIColor whiteColor]];
//	modifyLabel.textAlignment = UITextAlignmentCenter;
//	modifyLabel.text = @"사진변경";
//	[mainPhotoView addSubview:modifyLabel];
//	[modifyLabel setFrame:CGRectMake(0.0f, mainPhotoView.frame.size.height - 23.0f, mainPhotoView.frame.size.width, 23.0f)];
//	[modifyLabel release];
//	
//	[tableHeaderView addSubview:mainPhotoView];
//	[mainPhotoView release];
//	
//	UIImageView *thumbnailImageView1 = [[UIImageView alloc]initWithFrame:CGRectZero];
//	assert(thumbnailImageView1 != nil);
//	[tableHeaderView addSubview:thumbnailImageView1];
//	thumbnailImageView1.layer.masksToBounds = YES;
//	thumbnailImageView1.layer.cornerRadius = 5.0;
//	thumbnailImageView1.tag = ID_FIRSTPHOTO;
//	[tableHeaderView addSubview:thumbnailImageView1];
//	[thumbnailImageView1 setFrame:CGRectMake(32.0f, 101.0f, 41.0f, 41.0f)];
//	thumbnailImageView1.image = [UIImage imageNamed:@"img_default.png"];
//	[thumbnailImageView1 release];
//	
//	UIImageView *thumbnailImageView2 = [[UIImageView alloc]initWithFrame: CGRectZero];
//	assert(thumbnailImageView2 != nil);
//	[tableHeaderView addSubview:thumbnailImageView2];
//	thumbnailImageView2.layer.masksToBounds = YES;
//	thumbnailImageView2.layer.cornerRadius = 5.0;
//	[thumbnailImageView2 setFrame:CGRectMake(86.0f, 101.0f, 41.0f, 41.0f)];
//	thumbnailImageView2.tag = ID_SECONDPHOTO;
//	thumbnailImageView2.image = [UIImage imageNamed:@"img_default.png"];	
//	[thumbnailImageView2 release];
//	
//	UIImageView *thumbnailImageView3 = [[UIImageView alloc]initWithFrame: CGRectZero];
//	assert(thumbnailImageView3 != nil);
//	[tableHeaderView addSubview:thumbnailImageView3];
//	thumbnailImageView3.layer.masksToBounds = YES;
//	thumbnailImageView3.layer.cornerRadius = 5.0;
//	[thumbnailImageView3 setFrame:CGRectMake(140.0f, 101.0f, 41.0f, 41.0f)];
//	thumbnailImageView3.tag = ID_THIRDPHOTO;
//	thumbnailImageView3.image = [UIImage imageNamed:@"img_default.png"];
//	[thumbnailImageView3 release];
//	
//	UIImageView *thumbnailImageView4 = [[UIImageView alloc]initWithFrame: CGRectZero];
//	assert(thumbnailImageView4 != nil);
//	[tableHeaderView addSubview:thumbnailImageView4];
//	thumbnailImageView4.layer.masksToBounds = YES;
//	thumbnailImageView4.layer.cornerRadius = 5.0;
//	[thumbnailImageView4 setFrame:CGRectMake(194.0f, 101.0f, 41.0f, 41.0f)];
//	thumbnailImageView4.tag = ID_FOURTHPHOTO;
//	thumbnailImageView4.image = [UIImage imageNamed:@"img_default.png"];
//	[thumbnailImageView4 release];
//	
//	UIImageView *thumbnailImageView5 = [[UIImageView alloc]initWithFrame: CGRectZero];
//	assert(thumbnailImageView5 != nil);
//	[tableHeaderView addSubview:thumbnailImageView5];
//	thumbnailImageView5.layer.masksToBounds = YES;
//	thumbnailImageView5.layer.cornerRadius = 5.0;
//	[thumbnailImageView5 setFrame:CGRectMake(248.0f, 101.0f, 41.0f, 41.0f)];
//	thumbnailImageView5.tag = ID_FIFTHPHOTO;
//	thumbnailImageView5.image = [UIImage imageNamed:@"img_default.png"];
//	[thumbnailImageView5 release];

	UIView *tempTableHeaderView = (UIView *)[self.view viewWithTag:ID_TABLEHEADERVIEW];
	

	
	if (tempTableHeaderView == nil) {
		// Create and set the table header view.
		UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, 90)];
		
		
		//	assert(tableHeaderView != nil);
		tableHeaderView.tag = ID_TABLEHEADERVIEW;
		[tableHeaderView setBackgroundColor:[UIColor colorWithRed:237.0/255.0 green:239.0/255.0 blue:242.0/255.0 alpha:1.0f]];
		
		UIView *mainPhotoView = [[UIView alloc] initWithFrame:CGRectMake(32.0f, 17.0f, 64.0f, 64.0f)];
		//	assert(mainPhotoView != nil);
		[mainPhotoView setBackgroundColor:[UIColor clearColor]];
		mainPhotoView.layer.masksToBounds = YES;
		mainPhotoView.layer.cornerRadius = 5.0;
		
		UIButton *mainPhotoBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		//	assert(mainPhotoBtn != nil);
		[mainPhotoBtn addTarget:self action:@selector(photoClicked) forControlEvents:UIControlEventTouchUpInside];
		//	[mainPhotoBtn.layer setBorderColor:[UIColor colorWithWhite:0 alpha:0.5].CGColor];
		//	[mainPhotoBtn.layer setBorderWidth:1.0];
		[mainPhotoBtn.layer setCornerRadius:5.0];
		mainPhotoBtn.hidden = NO;
		mainPhotoBtn.alpha = 1.0f;
		mainPhotoBtn.tag = ID_MAINPHOTO;
		[mainPhotoBtn setBackgroundImage:[UIImage imageNamed:@"img_Addressbook_default.png"] forState:UIControlStateNormal];
		[mainPhotoView addSubview:mainPhotoBtn];
		[mainPhotoBtn setFrame:CGRectMake(0.0f, 0.0f, 64.0f, 64.0f)];
		
		UILabel *modifyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		//	assert(modifyLabel != nil);
		[modifyLabel setFont:[UIFont boldSystemFontOfSize:13.0]];
		[modifyLabel setBackgroundColor:[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.5f]];
		[modifyLabel setTextColor:[UIColor whiteColor]];
		modifyLabel.textAlignment = UITextAlignmentCenter;
		modifyLabel.text = @"사진변경";
		[mainPhotoView addSubview:modifyLabel];
		[modifyLabel setFrame:CGRectMake(0.0f, mainPhotoView.frame.size.height - 23.0f, mainPhotoView.frame.size.width, 23.0f)];
		[modifyLabel release];
		
		[tableHeaderView addSubview:mainPhotoView];
		[mainPhotoView release];
		
		UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		//	assert(nameLabel != nil);
		[nameLabel setFont:[UIFont boldSystemFontOfSize:18.0]];
		[nameLabel setBackgroundColor:[UIColor clearColor]];
		[nameLabel setTextColor:ColorFromRGB(0x23232a)];
		// sochae 2010.10.12
		//nameLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"nickName"];
		nameLabel.text = (NSString *)[JYUtil loadFromUserDefaults:kNickname];
		// ~sochae
		nameLabel.tag = ID_NICKNAMELABEL;
		[tableHeaderView addSubview:nameLabel];
		[nameLabel setFrame:CGRectMake(108.0f, 23.0f, rect.size.width-108.0-10.0, 19.0f)];
		[nameLabel release];
		
		UILabel *prMsgLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		//	assert(prMsgLabel != nil);
		[prMsgLabel setFont:[UIFont boldSystemFontOfSize:12.0]];
		[prMsgLabel setBackgroundColor:[UIColor clearColor]];
		[prMsgLabel setTextColor:ColorFromRGB(0x7c7c86)];
		prMsgLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"status"];
		prMsgLabel.tag = ID_PRMSGLABEL;
		[tableHeaderView addSubview:prMsgLabel];
		[prMsgLabel setFrame:CGRectMake(108.0f, 45.0f, rect.size.width-108.0-10.0, 15.0f)];
		[prMsgLabel release];
		
		UILabel *organizationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		//	assert(organizationLabel != nil);
		[organizationLabel setFont:[UIFont boldSystemFontOfSize:12.0]];
		[organizationLabel setBackgroundColor:[UIColor clearColor]];
		[organizationLabel setTextColor:ColorFromRGB(0x2284ac)];
		organizationLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"organization"];
		organizationLabel.tag = ID_ORGANIZATIONLABEL;
		[tableHeaderView addSubview:organizationLabel];
		[organizationLabel setFrame:CGRectMake(108.0f, 65.0f, rect.size.width-108.0-10.0, 15.0f)];
		[organizationLabel release];
		
		//	UIImage *seperatorImage = [[UIImage imageNamed:@"profileSeperator.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
		//	UIImageView *seperatorImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
		//	[seperatorImageView initWithImage:seperatorImage];
		//	[tableHeaderView addSubview:seperatorImageView];
		//	[seperatorImageView setFrame:CGRectMake(32, 91, 258, 2)];
		//	[seperatorImageView release];
		
		if ([[NSUserDefaults standardUserDefaults] objectForKey:@"representPhoto"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"representPhoto"] length] > 0) {
			SDWebImageManager *manager = [SDWebImageManager sharedManager];
			
			UIImage *cachedImage = [manager imageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/012", [[NSUserDefaults standardUserDefaults] objectForKey:@"representPhoto"]]]];
			
			if (cachedImage)
			{
				// Use the cached image immediatly
				UIButton *mainPhotoBtn = (UIButton *)[self.view viewWithTag:ID_MAINPHOTO];
				if(mainPhotoBtn) {
					[mainPhotoBtn setBackgroundImage:cachedImage forState:UIControlStateNormal];
				}
			}
			else
			{
				// Start an async download
				[manager downloadWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/012", [[NSUserDefaults standardUserDefaults] objectForKey:@"representPhoto"]]] delegate:self];
			}
		}
		
		self.settingTableView.tableHeaderView = tableHeaderView;
		[tableHeaderView release];
		
		UIView* tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.settingTableView.frame.size.width, 15.0)];
		tableFooterView.backgroundColor = [UIColor clearColor];
		self.settingTableView.tableFooterView = tableFooterView;
		[tableFooterView release];
		
		if ([[NSUserDefaults standardUserDefaults] objectForKey:@"representPhotoFilePath"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"representPhotoFilePath"] length] > 0) {
			if (representPhotoFilePath) {
				[representPhotoFilePath release];
				representPhotoFilePath = nil;
				representPhotoFilePath = [[NSMutableString alloc] initWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"representPhotoFilePath"]];
			} else {
				representPhotoFilePath = [[NSMutableString alloc] initWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"representPhotoFilePath"]];
			}
		} else {
			[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"representPhotoFilePath"];
			representPhotoFilePath = [[NSMutableString alloc] initWithString:@""];
		}

		// sochae 2010.10.12
		NSString *nickName = (NSString *)[JYUtil loadFromUserDefaults:kNickname];
		if (nickName && [nickName length] > 0)
		{
			if (preNickName) {
				[preNickName release];
				preNickName = nil;
				preNickName = [[NSMutableString alloc] initWithString:nickName];
			} else {
				preNickName = [[NSMutableString alloc] initWithString:nickName];
			}
		}
		else 
		{
			[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"status"];
			prePrMsg = [[NSMutableString alloc] initWithString:@""];
		}
		/*
		if ([[NSUserDefaults standardUserDefaults] objectForKey:@"nickName"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"nickName"] length] > 0) {
			if (preNickName) {
				[preNickName release];
				preNickName = nil;
				preNickName = [[NSMutableString alloc] initWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"nickName"]];
			} else {
				preNickName = [[NSMutableString alloc] initWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"nickName"]];
			}
		} else {
			[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"status"];
			prePrMsg = [[NSMutableString alloc] initWithString:@""];
		}
		*/// ~sochae
		
		if ([[NSUserDefaults standardUserDefaults] objectForKey:@"status"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"status"] length] > 0) {
			if (prePrMsg) {
				[prePrMsg release];
				prePrMsg = nil;
				prePrMsg = [[NSMutableString alloc] initWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"status"]];
			} else {
				prePrMsg = [[NSMutableString alloc] initWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"status"]];
			}
		} else {
			[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"status"];
			prePrMsg = [[NSMutableString alloc] initWithString:@""];
		}
		
		preImStatus = [[self appDelegate].myInfoDictionary objectForKey:@"imstatus"];
		
		if (preImStatus && [preImStatus length] > 0) {
			if ([preImStatus isEqualToString:@"0"] || [preImStatus isEqualToString:@"1"] || [preImStatus isEqualToString:@"2"] || [preImStatus isEqualToString:@"8"] || [preImStatus isEqualToString:@"16"]) {
				// ok
			} else {
				preImStatus = (NSMutableString*)@"1";
			}
		} else {
			preImStatus = (NSMutableString*)@"1";
		}
		
		requestActIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((rect.size.width - 30.0)/2.0, (rect.size.height - 30.0)/2.0 - 15.0, 30, 30)];
		requestActIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
		requestActIndicator.hidesWhenStopped = YES;
		[self.view addSubview:requestActIndicator];
		
		// 노티피케이션처리관련 등록..
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadProfile:) name:@"loadProfile" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completeProfilePhoto:) name:@"completeProfilePhoto" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completeImStatus:) name:@"completeImStatus" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completeNickName:) name:@"completeNickName" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completeStatus:) name:@"completeStatus" object:nil];
		
		if ([self appDelegate].connectionType == -1) {	// -1:offline mode  0:disconnect 1:Wi-Fi 2:3G
		} else if ([self appDelegate].connectionType == 0) {
			
		} else {
			//		activityTimer = [[NSTimer scheduledTimerWithTimeInterval:0.01 target:self 
			//														 selector:@selector(startActIndecatorPlay:) 
			//														 userInfo:nil repeats:NO] retain];
			//		
			//		sleep(1);
			[requestActIndicator startAnimating];
			
			// 패킷전송
			NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
			//		assert(bodyObject != nil);
			[bodyObject setObject:[[self appDelegate] getSvcIdx] forKey:@"svcidx"];
			
			USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"loadProfile" andWithDictionary:bodyObject timeout:10] autorelease];
			//		assert(data != nil);
			
			isRequest = YES;
			self.navigationItem.leftBarButtonItem.enabled = NO;
			[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
		}
		photoLibraryShown = NO;
	}

	[super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
}
//*/

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
	if (requestActIndicator) {
		[requestActIndicator stopAnimating];
		[requestActIndicator release];
		requestActIndicator = nil;
	}

	if (settingTableView) {
		[settingTableView release];
		settingTableView = nil;
	}
	if (prePrMsg) {
		[prePrMsg release];
		prePrMsg = nil;
	}
	if (preNickName) {
		[preNickName release];
		preNickName = nil;
	}

	if (representPhoto) {
		[representPhoto release];
		representPhoto = nil;
	}
	if (representPhotoFilePath) {
		[representPhotoFilePath release];
		representPhotoFilePath = nil;
	}
	
////	[compareRepresentPhoto release];
//	[subPhotosArray release];
//	if (preImStatus) {
//		[preImStatus release];
//	}
	// 노티피케이션처리관련 해제..
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"loadProfile" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"completeProfilePhoto" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"completeImStatus" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"completeNickName" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"completeStatus" object:nil];

	[myLabel release];
	
	[super dealloc];
}


@end
