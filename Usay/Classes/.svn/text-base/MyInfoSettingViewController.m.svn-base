//
//  MyInfoSettingViewController.m
//  USayApp
//
//  Created by 1team on 10. 6. 3..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "MyInfoSettingViewController.h"
#import "ProfileSettingViewController.h"
#import "InsertMyInfoSettingViewController.h"
#import "json.h"
#import "USayHttpData.h"
#import "USayAppAppDelegate.h"
#import "CheckPhoneNumber.h"
#import "RegexKitLite.h"
#import "USayDefine.h"
//#import "MyDeviceClass.h"		// sochae 2010.09.11 - UI Position

enum ControlTableSections
{
	kMyInfoSettingSection = 0
};

enum MyInfoTableCell
{
	kMobileTelephone = 0,
	kHomeTelephone,
	kOfficeTelephone,
	kOrganization,
	kHomePage,
	kEmail
};

#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
										green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
										blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define CurrentParentViewController [[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count] - 2]

#define ID_MOBILEPHONE	7411
#define ID_HOMEPHONE	7412
#define ID_OFFICEPHONE	7413
#define ID_BELONG		7414
#define ID_HOMEPAGE		7415
#define ID_EMAIL		7416

@implementation MyInfoSettingViewController

@synthesize myInfoSettingTableView;
@synthesize preHomeTel;
@synthesize preOfficeTel;
@synthesize preMobileTel;
@synthesize preOrganization;
@synthesize preHomePageURL;
@synthesize preEmail;
//@synthesize baseAlert;
@synthesize isRequest;

#pragma mark -
#pragma mark NSNotification loadSimpleProfileOnMobile, updateMyInfoOnMobile response

-(void)updateMyInfo:(NSNotification *)notification
{	
	self.navigationItem.leftBarButtonItem.enabled = YES;
	isRequest = NO;
	[requestActIndicator stopAnimating];
	USayHttpData *data = (USayHttpData*)[notification object];
	if (data == nil) {
		// 200 이외의 에러
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0004)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
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
			NSString *mobilePhoneNumber = [addressDic objectForKey:@"mobilePhoneNumber"];
			NSString *homePhoneNumber = [addressDic objectForKey:@"homePhoneNumber"];
			NSString *orgPhoneNumber = [addressDic objectForKey:@"orgPhoneNumber"];
			NSString *homePageURL = [addressDic objectForKey:@"homePageURL"];
			
			// mezzo 스트링 길이 0 허용
//			if (mobilePhoneNumber && [mobilePhoneNumber length] > 0) {
			if (mobilePhoneNumber) {
				UILabel *mobilePhoneLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_MOBILEPHONE];
				NSString *mobileTelString = (NSMutableString *)[[mobilePhoneLabel text] stringByReplacingOccurrencesOfString:@"-" withString:@""];
				[[NSUserDefaults standardUserDefaults] setObject:mobileTelString forKey:@"mobilePhoneNumber"];
				[mobilePhoneLabel setText:mobileTelString];
				if (preMobileTel) {
					[preMobileTel release];
					preMobileTel = nil;
				} else {
					preMobileTel = [[NSMutableString alloc] initWithString:mobileTelString];
				}
			}
			
			// mezzo 스트링 길이 0 허용
//			if (homePhoneNumber && [homePhoneNumber length] > 0) {
			if (homePhoneNumber) {
				UILabel *homePhoneLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_HOMEPHONE];
				NSString *homeTelString = (NSMutableString *)[[homePhoneLabel text] stringByReplacingOccurrencesOfString:@"-" withString:@""];
				[[NSUserDefaults standardUserDefaults] setObject:homeTelString forKey:@"homePhoneNumber"];
				[homePhoneLabel setText:homeTelString];
				if (preHomeTel) {
					[preHomeTel release];
					preHomeTel = nil;
				} else {
					preHomeTel = [[NSMutableString alloc] initWithString:homeTelString];
				}
			}
			
			// mezzo 스트링 길이 0 허용
//			if (orgPhoneNumber && [orgPhoneNumber length] > 0) {
			if (orgPhoneNumber) {
				UILabel *officePhoneLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_OFFICEPHONE];
				NSString *officeTelString = (NSMutableString *)[[officePhoneLabel text] stringByReplacingOccurrencesOfString:@"-" withString:@""];
				[[NSUserDefaults standardUserDefaults] setObject:officeTelString forKey:@"orgPhoneNumber"];
				[officePhoneLabel setText:officeTelString];
				if (preOfficeTel) {
					[preOfficeTel release];
					preOfficeTel = nil;
				} else {
					preOfficeTel = [[NSMutableString alloc] initWithString:officeTelString];
				}
			}
			
			// mezzo 스트링 길이 0 허용
//			if (homePageURL && [homePageURL length] > 0) {
			if (homePageURL) {
				UILabel *homePageLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_HOMEPAGE];
				NSString *homePageString = (NSMutableString *)[[homePageLabel text] stringByReplacingOccurrencesOfString:@"-" withString:@""];
				[[NSUserDefaults standardUserDefaults] setObject:homePageString forKey:@"homePageURL"];
				[homePageLabel setText:homePageString];
				if (preHomePageURL) {
					[preHomePageURL release];
					preHomePageURL = nil;
				} else {
					preHomePageURL = [[NSMutableString alloc] initWithString:homePageString];
				}
			}
			
			NSArray *organizationArray = [addressDic objectForKey:@"organization"];
			// mezzo 스트링 길이 0 허용
//			if (organizationArray && [organizationArray count] > 0) {
			if (organizationArray) {
				UILabel *organizationLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_BELONG];
				for (NSString *organization in organizationArray) {
					[[NSUserDefaults standardUserDefaults] setObject:organization forKey:@"organization"];
					[organizationLabel setText:organization];
					if (preOrganization) {
						[preOrganization release];
						preOrganization = nil;
					} else {
						preOrganization = [[NSMutableString alloc] initWithString:organization];
					}
					[CurrentParentViewController insertOrganization:organization];
					break;
				}
				
				if ([organizationArray count] == 0) {
					preOrganization = [[NSMutableString alloc] initWithString:@""];;
					[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"organization"];
				}
			}
			
			NSArray *emailArray = [addressDic objectForKey:@"emailAddress"];
			// mezzo 스트링 길이 0 허용
//			if (emailArray && [emailArray count] > 0) {
			if (emailArray) {
				UILabel *emailLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_EMAIL];
				for (NSString *email in emailArray) {
					[[NSUserDefaults standardUserDefaults] setObject:email forKey:@"email"];
					[emailLabel setText:email];
					if (preEmail) {
						[preEmail release];
						preEmail = nil;
					} else {
						preEmail = [[NSMutableString alloc] initWithString:email];
					}
					break;
				}
				
				if ([emailArray count] == 0) {
					preOrganization = [[NSMutableString alloc] initWithString:@""];
					[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"email"];
				}
				
			}
		} else {
			// TODO: 예외처리
		}
	} else if ([rtcode isEqualToString:@"-9030"] || [rtcode isEqualToString:@"-1090"] ) {	
		// -9030 : 처리시 오류가 발생했을 경우  -1090 : 인증되지 않음   -2010 : 세션정보를 찾을 수 없음  -8080 : 기타 오류
		// 실패 예외처리 필요
		UILabel *mobileTelLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_MOBILEPHONE];
		UILabel *homeTelLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_HOMEPHONE];
		UILabel *officeTelLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_OFFICEPHONE];
		UILabel *belongLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_BELONG];
		UILabel *homePageLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_HOMEPAGE];
		UILabel *emailLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_EMAIL];
		if (mobileTelLabel != nil && homeTelLabel != nil && officeTelLabel != nil && belongLabel != nil && homePageLabel != nil && emailLabel != nil) {
			if (preMobileTel && [preMobileTel length] > 0) {
				[mobileTelLabel setText:preMobileTel];
			} else {
				[mobileTelLabel setText:@""];
			}
			if (preHomeTel && [preHomeTel length] > 0) {
				[homeTelLabel setText:preHomeTel];
			} else {
				[homeTelLabel setText:@""];
			}
			if (preOfficeTel && [preOfficeTel length] > 0) {
				[officeTelLabel setText:preOfficeTel];
			} else {
				[officeTelLabel setText:@""];
			}
			if (preOrganization && [preOrganization length] > 0) {
				[belongLabel setText:preOrganization];
			} else {
				[belongLabel setText:@""];
			}
			if (preHomePageURL && [preHomePageURL length] > 0) {
				[homePageLabel setText:preHomePageURL];
			} else {
				[homePageLabel setText:@""];
			}
			if (preEmail && [preEmail length] > 0) {
				[emailLabel setText:preEmail];
			} else {
				[emailLabel setText:@""];
			}
		} 
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0005)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else {
		// 실패 예외처리 필요
		// fail (-8080 이외 기타오류)
		UILabel *mobileTelLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_MOBILEPHONE];
		UILabel *homeTelLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_HOMEPHONE];
		UILabel *officeTelLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_OFFICEPHONE];
		UILabel *belongLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_BELONG];
		UILabel *homePageLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_HOMEPAGE];
		UILabel *emailLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_EMAIL];
		if (mobileTelLabel != nil && homeTelLabel != nil && officeTelLabel != nil && belongLabel != nil && homePageLabel != nil && emailLabel != nil) {
			if (preMobileTel && [preMobileTel length] > 0) {
				[mobileTelLabel setText:preMobileTel];
			} else {
				[mobileTelLabel setText:@""];
			}
			if (preHomeTel && [preHomeTel length] > 0) {
				[homeTelLabel setText:preHomeTel];
			} else {
				[homeTelLabel setText:@""];
			}
			if (preOfficeTel && [preOfficeTel length] > 0) {
				[officeTelLabel setText:preOfficeTel];
			} else {
				[officeTelLabel setText:@""];
			}
			if (preOrganization && [preOrganization length] > 0) {
				[belongLabel setText:preOrganization];
			} else {
				[belongLabel setText:@""];
			}
			if (preHomePageURL && [preHomePageURL length] > 0) {
				[homePageLabel setText:preHomePageURL];
			} else {
				[homePageLabel setText:@""];
			}
			if (preEmail && [preEmail length] > 0) {
				[emailLabel setText:preEmail];
			} else {
				[emailLabel setText:@""];
			}
		} 
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0006)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	}
}

#pragma mark -
#pragma mark Table view Callback

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger rowCount = 1;
	
	if (section == kMyInfoSettingSection) {
		rowCount = 6;
	} 
	
	return rowCount;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *kMyInfoSettingCellIdentifier = @"MyInfoSetting";
    	
	UITableViewCell *cell = nil;
	
	switch (indexPath.section)
	{
		case kMyInfoSettingSection:
		{
			cell = [tableView dequeueReusableCellWithIdentifier:kMyInfoSettingCellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kMyInfoSettingCellIdentifier] autorelease];
			}

			switch (indexPath.row)
			{
				case kMobileTelephone:
				{
					UILabel *preMobileTelLabel = (UILabel *)[cell viewWithTag:ID_MOBILEPHONE];
					
					cell.textLabel.text = NSLocalizedString(@"핸드폰", @"");
					cell.textLabel.textColor = ColorFromRGB(0x2284ac);
					cell.textLabel.font = [UIFont systemFontOfSize:17];
					UILabel *mobileTelLabel = [[[UILabel alloc] initWithFrame:CGRectMake(100, 5, 180, 30)] autorelease];
					
					if (preMobileTelLabel) {
						if (preMobileTelLabel.text && [preMobileTelLabel.text length] > 0) {
							mobileTelLabel.textColor = ColorFromRGB(0xaaacb0);
							NSMutableString *temp = (NSMutableString*)preMobileTelLabel.text;
							temp = (NSMutableString *)[temp stringByReplacingOccurrencesOfString:@"-" withString:@""];
							mobileTelLabel.text = [CheckPhoneNumber convertPhoneInsertHyphen:temp];
						} else {
						}
					} else {
						if (preMobileTel && [preMobileTel length] > 0) {
							mobileTelLabel.textColor = ColorFromRGB(0xaaacb0);
							NSMutableString *temp = preMobileTel;
							temp = (NSMutableString *)[temp stringByReplacingOccurrencesOfString:@"-" withString:@""];
							mobileTelLabel.text = [CheckPhoneNumber convertPhoneInsertHyphen:temp];
						} else {
						}
					}
					mobileTelLabel.font = [UIFont systemFontOfSize:17];
					mobileTelLabel.tag = ID_MOBILEPHONE;
					[cell.contentView addSubview:mobileTelLabel];
					break;
				}
				case kHomeTelephone:
				{
					UILabel *preHomeTelLabel = (UILabel *)[cell viewWithTag:ID_HOMEPHONE];
					
					cell.textLabel.text = NSLocalizedString(@"집전화", @"");
					cell.textLabel.textColor = ColorFromRGB(0x2284ac);
					cell.textLabel.font = [UIFont systemFontOfSize:17];
					UILabel *homeTelLabel = [[[UILabel alloc] initWithFrame:CGRectMake(100, 5, 180, 30)] autorelease];
					
					if (preHomeTelLabel) {
						if (preHomeTelLabel.text && [preHomeTelLabel.text length] > 0) {
							homeTelLabel.textColor = ColorFromRGB(0xaaacb0);
							NSMutableString *temp = (NSMutableString*)preHomeTelLabel.text;
							temp = (NSMutableString *)[temp stringByReplacingOccurrencesOfString:@"-" withString:@""];
							DebugLog(@"MyInfoSttting cellForRowAtIndexPath HomeTel1 temp=%@", temp);
							homeTelLabel.text = [CheckPhoneNumber convertPhoneInsertHyphen:temp];
						} else {
						}
					} else {
						if (preHomeTel && [preHomeTel length] > 0) {
							homeTelLabel.textColor = ColorFromRGB(0xaaacb0);
							NSMutableString *temp = preHomeTel;
							temp = (NSMutableString *)[temp stringByReplacingOccurrencesOfString:@"-" withString:@""];
							homeTelLabel.text = [CheckPhoneNumber convertPhoneInsertHyphen:temp];
						} else {
						}
					}
					homeTelLabel.font = [UIFont systemFontOfSize:17];
					homeTelLabel.tag = ID_HOMEPHONE;
					[cell.contentView addSubview:homeTelLabel];
					break;
				}
				case kOfficeTelephone:
				{
					UILabel *preOfficeTelLabel = (UILabel *)[cell viewWithTag:ID_OFFICEPHONE];
					
					cell.textLabel.text = NSLocalizedString(@"직장전화", @"");
					cell.textLabel.textColor = ColorFromRGB(0x2284ac);
					cell.textLabel.font = [UIFont systemFontOfSize:17];
					UILabel *officeTelLabel = [[[UILabel alloc] initWithFrame:CGRectMake(100, 5, 180, 30)] autorelease];
					
					if (preOfficeTelLabel) {
						if (preOfficeTelLabel.text && [preOfficeTelLabel.text length] > 0) {
							officeTelLabel.textColor = ColorFromRGB(0xaaacb0);
							NSMutableString *temp = (NSMutableString*)preOfficeTelLabel.text;
							temp = (NSMutableString *)[temp stringByReplacingOccurrencesOfString:@"-" withString:@""];
							officeTelLabel.text = [CheckPhoneNumber convertPhoneInsertHyphen:temp];
						} else {
						}
					} else {
						if (preOfficeTel && [preOfficeTel length] > 0) {
							officeTelLabel.textColor = ColorFromRGB(0xaaacb0);
							NSMutableString *temp = preOfficeTel;
							temp = (NSMutableString *)[temp stringByReplacingOccurrencesOfString:@"-" withString:@""];
							officeTelLabel.text = [CheckPhoneNumber convertPhoneInsertHyphen:temp];
						} else {
						}
					}
					officeTelLabel.font = [UIFont systemFontOfSize:17];
					officeTelLabel.tag = ID_OFFICEPHONE;
					[cell.contentView addSubview:officeTelLabel];
					break;
				}
				case kOrganization:
				{
					UILabel *preBelongLabel = (UILabel *)[cell viewWithTag:ID_BELONG];
					
					cell.textLabel.text = NSLocalizedString(@"소속", @"");
					cell.textLabel.textColor = ColorFromRGB(0x2284ac);
					cell.textLabel.font = [UIFont systemFontOfSize:17];
					
					UILabel *oranizationLabel = [[[UILabel alloc] initWithFrame:CGRectMake(100, 5, 180, 30)] autorelease];
					
					if (preBelongLabel) {
						if (preBelongLabel.text && [preBelongLabel.text length] > 0) {
							oranizationLabel.textColor = ColorFromRGB(0xaaacb0);
							oranizationLabel.text = preBelongLabel.text;
						} else {
						}
					} else {
						if (preOrganization && [preOrganization length] > 0) {
							oranizationLabel.textColor = ColorFromRGB(0xaaacb0);
							oranizationLabel.text = preOrganization;
						} else {
						}
					}
					oranizationLabel.font = [UIFont systemFontOfSize:17];
					oranizationLabel.tag = ID_BELONG;
					[cell.contentView addSubview:oranizationLabel];
					break;
				}
				case kHomePage:
				{
					UILabel *preHomePageLabel = (UILabel *)[cell viewWithTag:ID_HOMEPAGE];
					
					cell.textLabel.text = NSLocalizedString(@"홈페이지", @"");
					cell.textLabel.textColor = ColorFromRGB(0x2284ac);
					cell.textLabel.font = [UIFont systemFontOfSize:17];
					
					UILabel *homepageLabel = [[[UILabel alloc] initWithFrame:CGRectMake(100, 5, 180, 30)] autorelease];
					
					if (preHomePageLabel) {
						if (preHomePageLabel.text && [preHomePageLabel.text length] > 0) {
							homepageLabel.textColor = ColorFromRGB(0xaaacb0);
							homepageLabel.text = preHomePageLabel.text;
						} else {
						}
					} else {
						if (preHomePageURL && [preHomePageURL length] > 0) {
							homepageLabel.textColor = ColorFromRGB(0xaaacb0);
							homepageLabel.text = preHomePageURL;
						} else {
						}
					}
					homepageLabel.font = [UIFont systemFontOfSize:17];
					homepageLabel.tag = ID_HOMEPAGE;
					[cell.contentView addSubview:homepageLabel];
					break;
				}
				case kEmail:
				{
					UILabel *preEmailLabel = (UILabel *)[cell viewWithTag:ID_EMAIL];
					
					cell.textLabel.text = NSLocalizedString(@"이메일", @"");
					cell.textLabel.textColor = ColorFromRGB(0x2284ac);
					cell.textLabel.font = [UIFont systemFontOfSize:17];
					
					UILabel *emailLabel = [[[UILabel alloc] initWithFrame:CGRectMake(100, 5, 180, 30)] autorelease];
					
					if (preEmailLabel) {
						if (preEmailLabel.text && [preEmailLabel.text length] > 0) {
							emailLabel.textColor = ColorFromRGB(0xaaacb0);
							emailLabel.text = preEmailLabel.text;
							emailLabel.font = [UIFont systemFontOfSize:17];
						} else {
						}
					} else {
						
						if (preEmail && [preEmail length] > 0) {
							emailLabel.textColor = ColorFromRGB(0xaaacb0);
							emailLabel.text = preEmail;
							emailLabel.font = [UIFont systemFontOfSize:17];
						} else {
						}
					}
					
					emailLabel.tag = ID_EMAIL;
					[cell.contentView addSubview:emailLabel];
					break;
				}
			}
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			break;
		}
		default:
		{
			break;
		}
	}

    // Configure the cell...
    return cell;
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
//	return 30;
	
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *title = nil;
		
	switch (section)
	{
		case kMyInfoSettingSection:
		{
			break;
		}
		default:
		{
			title = nil;
			break;
		}
	}
	return title;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if (isRequest) {
		return;
	}
	UILabel *mobileTelLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_MOBILEPHONE];
	UILabel *homeTelLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_HOMEPHONE];
	UILabel *officeTelLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_OFFICEPHONE];
	UILabel *belongLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_BELONG];
	UILabel *homePageLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_HOMEPAGE];
	UILabel *emailLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_EMAIL];
	if (homeTelLabel != nil && officeTelLabel != nil && belongLabel != nil && homePageLabel != nil && emailLabel != nil) {
		//*	셀 선택시 처리
		switch (indexPath.section)
		{
			case kMyInfoSettingSection:
			{
				
				switch (indexPath.row) {
					case kMobileTelephone:
					{
						InsertMyInfoSettingViewController *inputMyInfoSettingViewController = [[InsertMyInfoSettingViewController alloc] init];
						NSMutableString *temp = (NSMutableString*)mobileTelLabel.text;
						temp = (NSMutableString *)[temp stringByReplacingOccurrencesOfString:@"-" withString:@""];
						inputMyInfoSettingViewController.preContents= [CheckPhoneNumber convertPhoneInsertHyphen:temp];
						inputMyInfoSettingViewController.inputType = MobilePhoneType;
						inputMyInfoSettingViewController.navigationTitle = @"핸드폰";
						[self.navigationController pushViewController:inputMyInfoSettingViewController animated:YES];
						[inputMyInfoSettingViewController release];
						break;
					}
					case kHomeTelephone:
					{
						InsertMyInfoSettingViewController *inputMyInfoSettingViewController = [[InsertMyInfoSettingViewController alloc] init];
						NSMutableString *temp = (NSMutableString*)homeTelLabel.text;
						temp = (NSMutableString *)[temp stringByReplacingOccurrencesOfString:@"-" withString:@""];
						inputMyInfoSettingViewController.preContents= [CheckPhoneNumber convertPhoneInsertHyphen:temp];
						inputMyInfoSettingViewController.inputType = HomePhoneType;
						inputMyInfoSettingViewController.navigationTitle = @"집전화";
						[self.navigationController pushViewController:inputMyInfoSettingViewController animated:YES];
						[inputMyInfoSettingViewController release];
						break;
					}
					case kOfficeTelephone:
					{
						InsertMyInfoSettingViewController *inputMyInfoSettingViewController = [[InsertMyInfoSettingViewController alloc] init];
						NSMutableString *temp = (NSMutableString*)officeTelLabel.text;
						temp = (NSMutableString *)[temp stringByReplacingOccurrencesOfString:@"-" withString:@""];
						inputMyInfoSettingViewController.preContents= [CheckPhoneNumber convertPhoneInsertHyphen:temp];
						inputMyInfoSettingViewController.inputType = OfficePhoneType;
						inputMyInfoSettingViewController.navigationTitle = @"직장전화";
						[self.navigationController pushViewController:inputMyInfoSettingViewController animated:YES];
						[inputMyInfoSettingViewController release];
						break;
					}
					
					case kOrganization:
					{
						InsertMyInfoSettingViewController *inputMyInfoSettingViewController = [[InsertMyInfoSettingViewController alloc] init];
						inputMyInfoSettingViewController.preContents= belongLabel.text;
						inputMyInfoSettingViewController.inputType = OrganizationType;
						inputMyInfoSettingViewController.navigationTitle = @"소속";
						[self.navigationController pushViewController:inputMyInfoSettingViewController animated:YES];
						[inputMyInfoSettingViewController release];
						break;
					}
					case kHomePage:
					{
						InsertMyInfoSettingViewController *inputMyInfoSettingViewController = [[InsertMyInfoSettingViewController alloc] init];
						inputMyInfoSettingViewController.preContents= homePageLabel.text;
						inputMyInfoSettingViewController.inputType = HomePageUrlType;
						inputMyInfoSettingViewController.navigationTitle = @"홈페이지";
						[self.navigationController pushViewController:inputMyInfoSettingViewController animated:YES];
						[inputMyInfoSettingViewController release];
						break;
					}
					case kEmail:
					{
						InsertMyInfoSettingViewController *inputMyInfoSettingViewController = [[InsertMyInfoSettingViewController alloc] init];
						inputMyInfoSettingViewController.preContents= emailLabel.text;
						inputMyInfoSettingViewController.inputType = EmailType;
						inputMyInfoSettingViewController.navigationTitle = @"이메일";
						[self.navigationController pushViewController:inputMyInfoSettingViewController animated:YES];
						[inputMyInfoSettingViewController release];
						break;
					}
					default:
						break;	
				}
			}
			default:
				break;
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

-(NSInteger) displayTextLength:(NSString*)text
{
	NSInteger textLength = [text length];
	NSInteger textLengthUTF8 = [text lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	NSInteger correntLength = (textLengthUTF8 - textLength)/2 + textLength;
	
	return correntLength;
}

- (void)saveMyInfo
{
	NSMutableString *mobileTelString = nil;
	NSMutableString *homeTelString = nil;
	NSMutableString *officeTelString = nil;
	NSString *belongString = nil;
	NSString *homePageString = nil;
	NSMutableString *emailString = nil;
	
	UILabel *mobileTelLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_MOBILEPHONE];
	UILabel *homeTelLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_HOMEPHONE];
	UILabel *officeTelLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_OFFICEPHONE];
	UILabel *belongLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_BELONG];
	UILabel *homePageLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_HOMEPAGE];
	UILabel *emailLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_EMAIL];
	
	mobileTelString = (NSMutableString*)[mobileTelLabel text];
	homeTelString = (NSMutableString*)[homeTelLabel text];
	officeTelString = (NSMutableString*)[officeTelLabel text];
	
	belongString = [belongLabel text];
	homePageString = [homePageLabel text];
	// '-' 제거
	mobileTelString = (NSMutableString *)[mobileTelString stringByReplacingOccurrencesOfString:@"-" withString:@""];
	homeTelString = (NSMutableString *)[homeTelString stringByReplacingOccurrencesOfString:@"-" withString:@""];
	officeTelString = (NSMutableString *)[officeTelString stringByReplacingOccurrencesOfString:@"-" withString:@""];
		
	if ([self displayTextLength:belongString] > 20) {
		UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"소속명 확인" message:@"소속명은 최대 한글10자(영문20자) 입니다." delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		[belongLabel becomeFirstResponder];
		return;
	}

	if (emailLabel) {
		if ([[emailLabel text] length] > 0) {
			emailString = (NSMutableString *)[emailLabel text];
		} else {
			emailString = (NSMutableString *)@"";
		}

	}

	// value, key, value, key ...
	NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
	if (self.preMobileTel) {
		if ([self.preMobileTel length] == 0) {
			if ([mobileTelString length] > 0) {
				[bodyObject setObject:mobileTelString forKey:@"mobilePhoneNumber"];
			} else {
			}
		} else {
			if (mobileTelString && [mobileTelString length] > 0) {
				if ([self.preMobileTel isEqualToString:mobileTelString]) {
					// skip
				} else {
					[bodyObject setObject:mobileTelString forKey:@"mobilePhoneNumber"];
				}
			} else {
				[bodyObject setObject:@"" forKey:@"mobilePhoneNumber"];
			}
		}
	} else {
		if ([mobileTelString length] > 0) {
			[bodyObject setObject:mobileTelString forKey:@"mobilePhoneNumber"];
		} else {
		}
	}

	if (self.preHomeTel) {
		if ([self.preHomeTel length] == 0) {
			if ([homeTelString length] > 0) {
				[bodyObject setObject:homeTelString forKey:@"homePhoneNumber"];
			} else {
			}
		} else {
			if (homeTelString && [homeTelString length] > 0) {
				if ([self.preHomeTel isEqualToString:homeTelString]) {
					// skip
				} else {
					[bodyObject setObject:homeTelString forKey:@"homePhoneNumber"];
				}
			} else {
				[bodyObject setObject:@"" forKey:@"homePhoneNumber"];
			}
		}
	} else {
		if ([homeTelString length] > 0) {
			[bodyObject setObject:homeTelString forKey:@"homePhoneNumber"];
		} else {
		}
	}
	
	if (self.preOfficeTel) {
		if ([self.preOfficeTel length] == 0) {
			if ([officeTelString length] > 0) {
				[bodyObject setObject:officeTelString forKey:@"orgPhoneNumber"];
			} else {
			}
		} else {
			if (officeTelString && [officeTelString length] > 0) {
				if ([self.preOfficeTel isEqualToString:officeTelString]) {
					// skip
				} else {
					[bodyObject setObject:officeTelString forKey:@"orgPhoneNumber"];
				}
			} else {
				[bodyObject setObject:@"" forKey:@"orgPhoneNumber"];
			}
		}
	} else {
		if ([officeTelString length] > 0) {
			[bodyObject setObject:officeTelString forKey:@"orgPhoneNumber"];
		} else {
		}
	}
	
	if (self.preHomePageURL) {
		if ([self.preHomePageURL length] == 0) {
			if ([homePageString length] > 0) {
				[bodyObject setObject:homePageString forKey:@"homePageURL"];
			} else {
			}
		} else {
			if (homePageString && [homePageString length] > 0) {
				if ([self.preHomePageURL isEqualToString:homePageString]) {
					// skip
				} else {
					[bodyObject setObject:homePageString forKey:@"homePageURL"];
				}
			} else {
				[bodyObject setObject:@"" forKey:@"homePageURL"];
			}
		}
	} else {
		if ([homePageString length] > 0) {
			[bodyObject setObject:homePageString forKey:@"homePageURL"];
		} else {
		}
	}
	
	NSString* organization = nil;
	if (self.preOrganization) {
		DebugLog(@"preOrganization = %@", preOrganization);
		
		if ([self.preOrganization length] == 0) {
			if (belongString && [belongString length] > 0) {
				organization = [NSString stringWithFormat:@"I%@", belongString];
			} else {
			}
		} else {
			if (belongString && [belongString length] > 0) {
//			if (belongString) {
				if ([preOrganization isEqualToString:belongString]) {
					// skip
				} else {
					organization = [NSString stringWithFormat:@"U%@=%@", self.preOrganization, belongString];
				}

			} else {
				[belongLabel setText:@""];
				organization = [NSString stringWithFormat:@"D%@", self.preOrganization];
			}

		}
	} else {
		if (belongString && [belongString length] > 0) {
			organization = [NSString stringWithFormat:@"I%@", belongString];
		} else {
		}
	}
	if (organization && [organization length] > 0) {
		[bodyObject setObject:organization forKey:@"organization"];
	} else {
	}
	
	NSString* email = nil;
	if (self.preEmail) {
		if ([self.preEmail length] == 0) {
			if (emailString && [emailString length] > 0) {
				email = [NSString stringWithFormat:@"I%@", emailString];
			} else {
			}
		} else {
			if (emailString && [emailString length] > 0) {
//			if (emailString) {
				if ([self.preEmail isEqualToString:emailString]) {
					// skip
				} else {
					email = [NSString stringWithFormat:@"U%@=%@", self.preEmail, emailString];
				}
				
			} else {
				[emailLabel setText:@""];
				email = [NSString stringWithFormat:@"D%@", self.preEmail];
			}
			
		}
	} else {
		if (emailString && [emailString length] > 0) {
			email = [NSString stringWithFormat:@"I%@", emailString];	
		} else {
		}
	}
	if (email && [email length] > 0) {
		[bodyObject setObject:email forKey:@"emailAddress"];
	} else {
	}
	
	if ([bodyObject count] > 0) {
		[bodyObject setObject:[[self appDelegate] getSvcIdx] forKey:@"svcidx"];
		
		// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
		USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"updateMyInfo" andWithDictionary:bodyObject timeout:10] autorelease];
		
		[requestActIndicator startAnimating];
		isRequest = YES;
		self.navigationItem.leftBarButtonItem.enabled = NO;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
		
		self.navigationItem.rightBarButtonItem.enabled = NO;
	} else {
		// error
		self.navigationItem.rightBarButtonItem.enabled = NO;
	}
}

-(void)insertContents:(NSString*)contents insertType:(NSInteger)type
{
	UILabel *mobileTelLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_MOBILEPHONE];
	UILabel *homeTelLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_HOMEPHONE];
	UILabel *officeTelLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_OFFICEPHONE];
	UILabel *belongLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_BELONG];
	UILabel *homePageLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_HOMEPAGE];
	UILabel *emailLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_EMAIL];
	
	self.navigationItem.rightBarButtonItem.enabled = NO;
	
	if (mobileTelLabel != nil && homeTelLabel != nil && officeTelLabel != nil && belongLabel != nil && homePageLabel != nil && emailLabel != nil) {
		if (type == MobilePhoneType) {
			if (preMobileTel) {
				if (contents && [contents length] > 0) {
					if ([preMobileTel isEqualToString:[(NSMutableString*)(contents) stringByReplacingOccurrencesOfString:@"-" withString:@""]]) {
					} else {
						self.navigationItem.rightBarButtonItem.enabled = YES;
					}
				} else {
					if ([preMobileTel isEqualToString:@""]) {
					} else {
						self.navigationItem.rightBarButtonItem.enabled = YES;
					}
				}
			} else {
				if (contents == nil) {
				} else if ([contents isEqualToString:@""]) {
				} else {
					self.navigationItem.rightBarButtonItem.enabled = YES;
				}
			}
			if (contents) {
				if ([contents length] > 0) {
					[mobileTelLabel setText:contents];
				} else {
					[mobileTelLabel setText:@""];
				}
			} else {
				[officeTelLabel setText:@""];
			}
		} else if(type == HomePhoneType) {
			if (preHomeTel) {
				if (contents && [contents length] > 0) {
					if ([preHomeTel isEqualToString:[(NSMutableString*)(contents) stringByReplacingOccurrencesOfString:@"-" withString:@""]]) {
					} else {
						self.navigationItem.rightBarButtonItem.enabled = YES;
					}
				} else {
					if ([preHomeTel isEqualToString:@""]) {
					} else {
						self.navigationItem.rightBarButtonItem.enabled = YES;
					}
				}
			} else {
				if (contents == nil) {
				} else if ([contents isEqualToString:@""]) {
				} else {
					self.navigationItem.rightBarButtonItem.enabled = YES;
				}
			}
			if (contents) {
				if ([contents length] > 0) {
					[homeTelLabel setText:contents];
				} else {
					[homeTelLabel setText:@""];
				}
			} else {
				[homeTelLabel setText:@""];
			}
		} else if (type == OfficePhoneType) {
			if (preOfficeTel) {
				if (contents && [contents length] > 0) {
					if ([preOfficeTel isEqualToString:[(NSMutableString*)(contents) stringByReplacingOccurrencesOfString:@"-" withString:@""]]) {
					} else {
						self.navigationItem.rightBarButtonItem.enabled = YES;
					}
				} else {
					if ([preOfficeTel isEqualToString:@""]) {
					} else {
						self.navigationItem.rightBarButtonItem.enabled = YES;
					}
				}
			} else {
				if (contents == nil) {
				} else if ([contents isEqualToString:@""]) {
				} else {
					self.navigationItem.rightBarButtonItem.enabled = YES;
				}
			}
			if (contents) {
				if ([contents length] > 0) {
					[officeTelLabel setText:contents];
				} else {
					[officeTelLabel setText:@""];
				}
			} else {
				[officeTelLabel setText:@""];
			}
		} else if (type == OrganizationType) {
			if (preOrganization) {
				if (contents && [contents length] > 0) {
					if ([preOrganization isEqualToString:contents]) {
					} else {
						self.navigationItem.rightBarButtonItem.enabled = YES;
					}
				} else {
					if ([preOrganization isEqualToString:@""]) {
					} else {
						self.navigationItem.rightBarButtonItem.enabled = YES;
					}
				}
			} else {
				if (contents == nil) {
				} else if ([contents isEqualToString:@""]) {
				} else {
					self.navigationItem.rightBarButtonItem.enabled = YES;
				}
			}
			if (contents) {
				if ([contents length] > 0) {
					[belongLabel setText:contents];
				} else {
					[belongLabel setText:@""];
				}
			} else {
				[belongLabel setText:@""];
			}
		} else if (type == HomePageUrlType) {
			if (preHomePageURL) {
				if (contents && [contents length] > 0) {
					if ([preHomePageURL isEqualToString:contents]) {
					} else {
						self.navigationItem.rightBarButtonItem.enabled = YES;
					}
				} else {
					if ([preHomePageURL isEqualToString:@""]) {
					} else {
						self.navigationItem.rightBarButtonItem.enabled = YES;
					}
				}
			} else {
				if (contents == nil) {
				} else if ([contents isEqualToString:@""]) {
				} else {
					self.navigationItem.rightBarButtonItem.enabled = YES;
				}
			}
			if (contents) {
				if ([contents length] > 0) {
					[homePageLabel setText:contents];
				} else {
					[homePageLabel setText:@""];
				}
			} else {
				[homePageLabel setText:@""];
			}
		} else if (type == EmailType) {
			if (preEmail) {
				if (contents && [contents length] > 0) {
					if ([preEmail isEqualToString:contents]) {
					} else {
						self.navigationItem.rightBarButtonItem.enabled = YES;
					}
				} else {
					if ([preEmail isEqualToString:@""]) {
					} else {
						self.navigationItem.rightBarButtonItem.enabled = YES;
					}
				}
			} else {
				if (contents == nil) {
				} else if ([contents isEqualToString:@""]) {
				} else {
					self.navigationItem.rightBarButtonItem.enabled = YES;
				}
			}
			if (contents) {
				if ([contents length] > 0) {
					[emailLabel setText:contents];
				} else {
					[emailLabel setText:@""];
				}
			} else {
				[emailLabel setText:@""];
			}
		} else {
			
		}
		
		[self.myInfoSettingTableView reloadData];
	}
}

-(void)backBarButtonClicked 
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
	// sochae 2010.09.11 - UI Position
	//CGRect rect = [MyDeviceClass deviceOrientation];
	CGRect rect = self.view.frame;
	// ~sochae
	
	if (myInfoSettingTableView) {
		CGRect myInfoSettingTableViewFrame = myInfoSettingTableView.frame;
		myInfoSettingTableViewFrame.size.width = rect.size.width;
		myInfoSettingTableViewFrame.size.height = rect.size.height;
		myInfoSettingTableView.frame = myInfoSettingTableViewFrame;
	}
	
	UILabel *mobileTelLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_MOBILEPHONE];
	UILabel *homeTelLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_HOMEPHONE];
	UILabel *officeTelLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_OFFICEPHONE];
	UILabel *belongLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_BELONG];
	UILabel *homePageLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_HOMEPAGE];
	UILabel *emailLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_EMAIL];
	
	if (mobileTelLabel != nil && homeTelLabel != nil && officeTelLabel != nil && belongLabel != nil && homePageLabel != nil && emailLabel != nil) {
		//내비게이션 바 버튼 설정
		UIImage* leftBarBtnImg = nil;
		UIImage* leftBarBtnSelImg = nil;
		UIImage* rightBarBtnImg = nil;
		UIImage* rightBarBtnSelImg = nil;
		//내비게이션 바 버튼 설정
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
		[rightBarButton addTarget:self action:@selector(saveMyInfo) forControlEvents:UIControlEventTouchUpInside];
		[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
		[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
		rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
		UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
		self.navigationItem.rightBarButtonItem = rightButton;
		[rightButton release];
		
		self.navigationItem.rightBarButtonItem.enabled = NO;
		
		if (preMobileTel) {
			if ([mobileTelLabel text]) {
				if ([preMobileTel isEqualToString:[(NSMutableString*)([mobileTelLabel text]) stringByReplacingOccurrencesOfString:@"-" withString:@""]]) {
				} else {
					self.navigationItem.rightBarButtonItem.enabled = YES;
					return;
				}
			} else {
				if ([preMobileTel isEqualToString:@""]) {
				} else {
					self.navigationItem.rightBarButtonItem.enabled = YES;
					return;
				}
			}
		} else {
			if ([mobileTelLabel text] == nil) {
			} else if ([[mobileTelLabel text] isEqualToString:@""]) {
			} else {
				self.navigationItem.rightBarButtonItem.enabled = YES;
				return;
			}
		}
		
		if (preHomeTel) {
			if ([homeTelLabel text]) {
				if ([preHomeTel isEqualToString:[(NSMutableString*)([homeTelLabel text]) stringByReplacingOccurrencesOfString:@"-" withString:@""]]) {
				} else {
					self.navigationItem.rightBarButtonItem.enabled = YES;
					return;
				}
			} else {
				if ([preHomeTel isEqualToString:@""]) {
				} else {
					self.navigationItem.rightBarButtonItem.enabled = YES;
					return;
				}
			}
		} else {
			if ([homeTelLabel text] == nil) {
			} else if ([[homeTelLabel text] isEqualToString:@""]) {
			} else {
				self.navigationItem.rightBarButtonItem.enabled = YES;
				return;
			}
		}
		if (preOfficeTel) {
			if ([officeTelLabel text]) {
				if ([preOfficeTel isEqualToString:[(NSMutableString*)([officeTelLabel text]) stringByReplacingOccurrencesOfString:@"-" withString:@""]]) {
				} else {
					self.navigationItem.rightBarButtonItem.enabled = YES;
					return;
				}
			} else {
				if ([preOfficeTel isEqualToString:@""]) {
				} else {
					self.navigationItem.rightBarButtonItem.enabled = YES;
					return;
				}
			}
		} else {
			if ([officeTelLabel text] == nil) {
			} else if ([[officeTelLabel text] isEqualToString:@""]) {
			} else {
				self.navigationItem.rightBarButtonItem.enabled = YES;
				return;
			}
		}
		if (preOrganization) {
			if ([belongLabel text]) {
				if ([preOrganization isEqualToString:[belongLabel text]]) {
				} else {
					self.navigationItem.rightBarButtonItem.enabled = YES;
					return;
				}
			} else {
				if ([preOrganization isEqualToString:@""]) {
				} else {
					self.navigationItem.rightBarButtonItem.enabled = YES;
					return;
				}
			}
		} else {
			if ([belongLabel text] == nil) {
			} else if ([[belongLabel text] isEqualToString:@""]) {
			} else {
				self.navigationItem.rightBarButtonItem.enabled = YES;
				return;
			}
		}
		if (preHomePageURL) {
			if ([homePageLabel text]) {
				if ([preHomePageURL isEqualToString:[homePageLabel text]]) {
				} else {
					self.navigationItem.rightBarButtonItem.enabled = YES;
					return;
				}
			} else {
				if ([preHomePageURL isEqualToString:@""]) {
				} else {
					self.navigationItem.rightBarButtonItem.enabled = YES;
					return;
				}
			}
		} else {
			if ([homePageLabel text] == nil) {
			} else if ([[homePageLabel text] isEqualToString:@""]) {
			} else {
				self.navigationItem.rightBarButtonItem.enabled = YES;
				return;
			}
		}
		if (preEmail) {
			if ([emailLabel text]) {
				if ([preEmail isEqualToString:[emailLabel text]]) {
				} else {
					self.navigationItem.rightBarButtonItem.enabled = YES;
					return;
				}
			} else {
				if ([preEmail isEqualToString:@""]) {
				} else {
					self.navigationItem.rightBarButtonItem.enabled = YES;
					return;
				}
			}
		} else {
			if ([emailLabel text] == nil) {
			} else if ([[emailLabel text] isEqualToString:@""]) {
			} else {
				self.navigationItem.rightBarButtonItem.enabled = YES;
				return;
			}
		}
	}
	
	[super viewWillAppear:animated];
}

//*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	// sochae 2010.09.11 - UI Position
	//CGRect rect = [MyDeviceClass deviceOrientation];
	CGRect rect = self.view.frame;
	// ~sochae
	
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
		
		UIImage* rightBarBtnImg = [UIImage imageNamed:@"btn_top_complete.png"];
		UIImage* rightBarBtnSelImg = [UIImage imageNamed:@"btn_top_complete_focus.png"];
		UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[rightBarButton addTarget:self action:@selector(saveMyInfo) forControlEvents:UIControlEventTouchUpInside];
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
		[rightBarButton addTarget:self action:@selector(saveMyInfo) forControlEvents:UIControlEventTouchUpInside];
		[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
		[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
		rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
		UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
		self.navigationItem.rightBarButtonItem = rightButton;
		[rightButton release];
	}
	
	self.navigationItem.rightBarButtonItem.enabled = NO;
	
	myInfoSettingTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height) style:UITableViewStyleGrouped];
	[myInfoSettingTableView setBackgroundColor:[UIColor clearColor]];
	myInfoSettingTableView.delegate = self;
	myInfoSettingTableView.dataSource = self;
	myInfoSettingTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	myInfoSettingTableView.separatorColor = ColorFromRGB(0xc2c2c3);
	[self.view addSubview:myInfoSettingTableView];
	
	self.myInfoSettingTableView.backgroundColor = ColorFromRGB(0xedeff2);
		
	UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
	UIFont *titleFont = [UIFont systemFontOfSize:20];
	CGSize titleStringSize = [@"내 정보 설정" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
	UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
	[titleLabel setFont:titleFont];
	titleLabel.textAlignment = UITextAlignmentCenter;
	[titleLabel setTextColor:ColorFromRGB(0x053844)];		// sochae 2010.09.15 - 글자색 변경 (0x939b9f -> 0x053844)
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	[titleLabel setText:@"내 정보 설정"];
	[titleView addSubview:titleLabel];	
	[titleLabel release];
	self.navigationItem.titleView = titleView;
	[titleView release];
	self.navigationItem.titleView.frame = CGRectMake((self.myInfoSettingTableView.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);
	
	// 노티피케이션처리관련 등록..
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMyInfo:) name:@"updateMyInfo" object:nil];
	
	
	
	//2011.01.24 크래쉬 리포트 에서 죽는거 처리
	
	if([[NSUserDefaults standardUserDefaults] objectForKey:@"mobilePhoneNumber"])
	{
		
		if (preMobileTel) {
			[preMobileTel release];
			preMobileTel = nil;
			preMobileTel = [[NSMutableString alloc] initWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"mobilePhoneNumber"]];
		} else {
			preMobileTel = [[NSMutableString alloc] initWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"mobilePhoneNumber"]]; //mezzo 여기에서 죽냐??
		}
	}
	if([[NSUserDefaults standardUserDefaults] objectForKey:@"homePhoneNumber"])
	{
		
		
		
		if (preHomeTel) {
			[preHomeTel release];
			preHomeTel = nil;
			preHomeTel = [[NSMutableString alloc] initWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"homePhoneNumber"]];
		} else {
			preHomeTel = [[NSMutableString alloc] initWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"homePhoneNumber"]];
		}
	}
	
	
	
	if([[NSUserDefaults standardUserDefaults] objectForKey:@"orgPhoneNumber"])
	{
		if (preOfficeTel) {
			[preOfficeTel release];
			preOfficeTel = nil;
			preOfficeTel = [[NSMutableString alloc] initWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"orgPhoneNumber"]];
		} else {
			preOfficeTel = [[NSMutableString alloc] initWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"orgPhoneNumber"]];
		}
	}
	
	//크래쉬 예외처리 함
	if([[NSUserDefaults standardUserDefaults] objectForKey:@"organization"])
	{
		if (preOrganization) {
			[preOrganization release];
			preOrganization = nil;
			preOrganization = [[NSMutableString alloc] initWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"organization"]];
		} else {
			preOrganization = [[NSMutableString alloc] initWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"organization"]];
		}
	}
	
	
	if([[NSUserDefaults standardUserDefaults] objectForKey:@"homePageURL"])
	{
		if (preHomePageURL) {
			[preHomePageURL release];
			preHomePageURL = nil;
			preHomePageURL = [[NSMutableString alloc] initWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"homePageURL"]];
		} else {
			preHomePageURL = [[NSMutableString alloc] initWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"homePageURL"]];
		}
	}
	
	
	if([[NSUserDefaults standardUserDefaults] objectForKey:@"email"])
	{
		if (preEmail) {
			[preEmail release];
			preEmail = nil;
			preEmail = [[NSMutableString alloc] initWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]];
		} else {
			preEmail = [[NSMutableString alloc] initWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]];
		}
	}
	
	
	requestActIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 30.0)/2.0, (self.view.frame.size.height - 30.0)/2.0 - 15.0, 30, 30)];
	requestActIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
	requestActIndicator.hidesWhenStopped = YES;
	[self.view addSubview:requestActIndicator];
	
	[super viewDidLoad];
}
//*/

- (void)viewDidDisappear:(BOOL)animated 
{
    [super viewDidDisappear:animated];
}

-(USayAppAppDelegate *) appDelegate
{
	return (USayAppAppDelegate *)[[UIApplication sharedApplication] delegate];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

-(void)wilRotation
{
	UILabel *mobileTelLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_MOBILEPHONE];
	UILabel *homeTelLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_HOMEPHONE];
	UILabel *officeTelLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_OFFICEPHONE];
	UILabel *belongLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_BELONG];
	UILabel *homePageLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_HOMEPAGE];
	UILabel *emailLabel = (UILabel *)[self.myInfoSettingTableView viewWithTag:ID_EMAIL];
	
	if (mobileTelLabel != nil && homeTelLabel != nil && officeTelLabel != nil && belongLabel != nil && homePageLabel != nil && emailLabel != nil) {
		// sochae 2010.09.11 - UI Position
		//CGRect rect = [MyDeviceClass deviceOrientation];
		CGRect rect = self.view.frame;
		// ~sochae

		if (myInfoSettingTableView) {
			CGRect myInfoSettingTableViewFrame = myInfoSettingTableView.frame;
			myInfoSettingTableViewFrame.size.width = rect.size.width;
			myInfoSettingTableViewFrame.size.height = rect.size.height;
			myInfoSettingTableView.frame = myInfoSettingTableViewFrame;
		}
		
		UIImage* leftBarBtnImg = nil;
		UIImage* leftBarBtnSelImg = nil;
		UIImage* rightBarBtnImg = nil;
		UIImage* rightBarBtnSelImg = nil;
		//내비게이션 바 버튼 설정
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
		[rightBarButton addTarget:self action:@selector(saveMyInfo) forControlEvents:UIControlEventTouchUpInside];
		[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
		[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
		rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
		UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
		self.navigationItem.rightBarButtonItem = rightButton;
		[rightButton release];
		
		self.navigationItem.rightBarButtonItem.enabled = NO;
		
		if (preMobileTel) {
			if ([mobileTelLabel text]) {
				if ([preMobileTel isEqualToString:[(NSMutableString*)([mobileTelLabel text]) stringByReplacingOccurrencesOfString:@"-" withString:@""]]) {
				} else {
					self.navigationItem.rightBarButtonItem.enabled = YES;
					return;
				}
			} else {
				if ([preMobileTel isEqualToString:@""]) {
				} else {
					self.navigationItem.rightBarButtonItem.enabled = YES;
					return;
				}
			}
		} else {
			if ([mobileTelLabel text] == nil) {
			} else if ([[mobileTelLabel text] isEqualToString:@""]) {
			} else {
				self.navigationItem.rightBarButtonItem.enabled = YES;
				return;
			}
		}

		if (preHomeTel) {
			if ([homeTelLabel text]) {
				if ([preHomeTel isEqualToString:[(NSMutableString*)([homeTelLabel text]) stringByReplacingOccurrencesOfString:@"-" withString:@""]]) {
				} else {
					self.navigationItem.rightBarButtonItem.enabled = YES;
					return;
				}
			} else {
				if ([preHomeTel isEqualToString:@""]) {
				} else {
					self.navigationItem.rightBarButtonItem.enabled = YES;
					return;
				}
			}
		} else {
			if ([homeTelLabel text] == nil) {
			} else if ([[homeTelLabel text] isEqualToString:@""]) {
			} else {
				self.navigationItem.rightBarButtonItem.enabled = YES;
				return;
			}
		}
		if (preOfficeTel) {
			if ([officeTelLabel text]) {
				if ([preOfficeTel isEqualToString:[(NSMutableString*)([officeTelLabel text]) stringByReplacingOccurrencesOfString:@"-" withString:@""]]) {
				} else {
					self.navigationItem.rightBarButtonItem.enabled = YES;
					return;
				}
			} else {
				if ([preOfficeTel isEqualToString:@""]) {
				} else {
					self.navigationItem.rightBarButtonItem.enabled = YES;
					return;
				}
			}
		} else {
			if ([officeTelLabel text] == nil) {
			} else if ([[officeTelLabel text] isEqualToString:@""]) {
			} else {
				self.navigationItem.rightBarButtonItem.enabled = YES;
				return;
			}
		}
		if (preOrganization) {
			if ([belongLabel text]) {
				if ([preOrganization isEqualToString:[belongLabel text]]) {
				} else {
					self.navigationItem.rightBarButtonItem.enabled = YES;
					return;
				}
			} else {
				if ([preOrganization isEqualToString:@""]) {
				} else {
					self.navigationItem.rightBarButtonItem.enabled = YES;
					return;
				}
			}
		} else {
			if ([belongLabel text] == nil) {
			} else if ([[belongLabel text] isEqualToString:@""]) {
			} else {
				self.navigationItem.rightBarButtonItem.enabled = YES;
				return;
			}
		}
		if (preHomePageURL) {
			if ([homePageLabel text]) {
				if ([preHomePageURL isEqualToString:[homePageLabel text]]) {
				} else {
					self.navigationItem.rightBarButtonItem.enabled = YES;
					return;
				}
			} else {
				if ([preHomePageURL isEqualToString:@""]) {
				} else {
					self.navigationItem.rightBarButtonItem.enabled = YES;
					return;
				}
			}
		} else {
			if ([homePageLabel text] == nil) {
			} else if ([[homePageLabel text] isEqualToString:@""]) {
			} else {
				self.navigationItem.rightBarButtonItem.enabled = YES;
				return;
			}
		}
		if (preEmail) {
			if ([emailLabel text]) {
				if ([preEmail isEqualToString:[emailLabel text]]) {
				} else {
					self.navigationItem.rightBarButtonItem.enabled = YES;
					return;
				}
			} else {
				if ([preEmail isEqualToString:@""]) {
				} else {
					self.navigationItem.rightBarButtonItem.enabled = YES;
					return;
				}
			}
		} else {
			if ([emailLabel text] == nil) {
			} else if ([[emailLabel text] isEqualToString:@""]) {
			} else {
				self.navigationItem.rightBarButtonItem.enabled = YES;
				return;
			}
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
	if (myInfoSettingTableView) {
		[myInfoSettingTableView release];
	}
	if (requestActIndicator) {
		[requestActIndicator release];
		requestActIndicator = nil;
	}
	if (preMobileTel) {
		[preMobileTel release];
	}
	if (preHomeTel) {
		[preHomeTel release];
	}
	if (preOfficeTel) {
		[preOfficeTel release];
	}
	if (preOrganization) {
		[preOrganization release];
	}
	if (preHomePageURL) {
		[preHomePageURL release];
	}
	if (preEmail) {
		[preEmail release];
	}

	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateMyInfo" object:nil];

    [super dealloc];
}


@end
