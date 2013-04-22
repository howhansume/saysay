//
//  InviteMsgViewController.m
//  USayApp
//
//  Created by 1team on 10. 7. 8..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "InviteMsgViewController.h"
#import "SayViewController.h"
#import "InviteMsgTableCell.h"
#import "UIImageView+WebCache.h"
#import "USayAppAppDelegate.h"
#import "GroupInfo.h"
#import "UserInfo.h"
#import "MessageInfo.h"
#import "InviteMsgSectionView.h"
#import "InviteMsgGroupInfo.h"
#import "InviteMsgUserInfo.h"
#import "CellMsgListData.h"
#import "CellMsgData.h"
#import "CheckPhoneNumber.h"
//#import "MyDeviceClass.h"		// sochae 2010.09.11 - UI Position
#import "AddressViewController.h"
#import "USayDefine.h"			// sochae 2010.10.08
//#import "Availability2.h"

#define CurrentParentViewController [[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count] - 2]
#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
										green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
										blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define kCustomSectionHeight	39.0
#define kCustomRowHeight		58.0
#define kCustomRowCount			7

#define ID_TABLEVIEW			1000

@implementation InviteMsgViewController

@synthesize addressTableView, addressGroupArray, addressBuddyArray, selectedAddrGroupUserArray, buddyListDictionary, alreadyJoinUserArray, cType, inviteType, selectedGroupId, navigationTitle;

-(id)initWithAlreadyUserInfo:(NSArray*)AlreadyUserInfoArray MsgType:(NSString*)messageCType
{
	
	NSLog(@"==========alll ready==============");
	sayFlag = TRUE;
	self = [super init];

	if (self != nil) {
		if (AlreadyUserInfoArray && [AlreadyUserInfoArray count] > 0) {
			alreadyJoinUserArray = [[NSMutableArray alloc] init];
			for (UserInfo *userInfo in AlreadyUserInfoArray) {
				InviteMsgUserInfo *msgUserInfo = [[InviteMsgUserInfo alloc] init];
				if (userInfo.FORMATTED && [userInfo.FORMATTED length] > 0) {
					msgUserInfo.nickName = userInfo.FORMATTED;
				} else if (userInfo.PROFILENICKNAME && [userInfo.PROFILENICKNAME length] > 0) {	
					msgUserInfo.nickName = userInfo.PROFILENICKNAME;
				} else {
					msgUserInfo.nickName = @"이름 없음";
				}
				msgUserInfo.photoUrl = userInfo.REPRESENTPHOTO;
				msgUserInfo.RPKey = userInfo.RPKEY;
				[alreadyJoinUserArray addObject:msgUserInfo];
				[msgUserInfo release];
			}
			self.cType = messageCType;		// 채팅세션 타입 P: 1:1  G: 그룹  nil:신규생성
			
			NSLog(@"InviteMsgViewController initWithAlreadyUserInfo self.cType = %@ alreadyJoinUserArray.count = %i", self.cType, [alreadyJoinUserArray count]);
			self.selectedAddrGroupUserArray = nil;
		} else {
			self.alreadyJoinUserArray = nil;
			self.cType = nil;
			self.selectedAddrGroupUserArray = nil;
		}
	}

	return self;
}

-(id)initWithAddressGroupSay:(NSArray*)selectedGroupUserInfoArray
{
	self = [super init];
	
	sayFlag = TRUE;
	
	NSLog(@"========group say==========");
	
	if (self != nil) {
		selectedGroupId = nil;
		if (selectedGroupUserInfoArray && [selectedGroupUserInfoArray count] > 0) {
			selectedAddrGroupUserArray = [[NSMutableArray alloc] init];
			for (UserInfo *userInfo in selectedGroupUserInfoArray) {
				[selectedAddrGroupUserArray addObject:userInfo.RPKEY];
				if (selectedGroupId == nil) {
					selectedGroupId = userInfo.GID;
					NSLog(@"GroupSay 선택된 그룹명 ID = %@", userInfo.GID);
				}
			}
			inviteType = AddressGroupSayType;
			self.alreadyJoinUserArray = nil;
		} else {
			self.alreadyJoinUserArray = nil;
			self.selectedAddrGroupUserArray = nil;
			self.cType = nil;
		}
	}
	return self;
}

-(id)initWithAddressGroupSMS:(NSArray*)selectedGroupUserInfoArray
{
	self = [super init];
	
	
	sayFlag = FALSE;
	if (self != nil) {
		selectedGroupId = nil;
		if (selectedGroupUserInfoArray && [selectedGroupUserInfoArray count] > 0) {
			selectedAddrGroupUserArray = [[NSMutableArray alloc] init];
			for (UserInfo *userInfo in selectedGroupUserInfoArray) {
				[selectedAddrGroupUserArray addObject:userInfo.ID];
				if (selectedGroupId == nil) {
					selectedGroupId = userInfo.GID;
					NSLog(@"GroupSMS 선택된 그룹명 ID = %@", userInfo.GID);
				}
			}
			self.alreadyJoinUserArray = nil;
		} else {
			self.alreadyJoinUserArray = nil;
			self.selectedAddrGroupUserArray = nil;
			self.cType = nil;
		}
		inviteType = AddressGroupSMSType;
	}
	return self;
}

#pragma mark UITableViewDelegate Protocol
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSArray		*groupSectionArray = nil;
	BOOL		isChecked = NO;
	InviteMsgUserInfo	*userInfo = nil;
	
	if (self.alreadyJoinUserArray && [self.alreadyJoinUserArray count] > 0) {
		if (indexPath.section == 0) {
			[tableView deselectRowAtIndexPath:indexPath animated:NO];
		} else {
			InviteMsgGroupInfo *groupInfo = [addressGroupArray objectAtIndex:indexPath.section-1];
			if (groupInfo) {
				groupSectionArray = [buddyListDictionary objectForKey:groupInfo.groupTitle];
				if (groupSectionArray && [groupSectionArray count] > 0) {
					InviteMsgTableCell* inviteMsgTableCell = (InviteMsgTableCell*)[tableView cellForRowAtIndexPath:indexPath];
					[inviteMsgTableCell checkAction:nil];
					userInfo = [groupSectionArray objectAtIndex:indexPath.row];
					userInfo.checked = !userInfo.checked;
					
				}
			}
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
		}

		if (buddyListDictionary && [buddyListDictionary count] > 0) {
			for (id key in buddyListDictionary) {
				NSArray *userInfoArray = [buddyListDictionary objectForKey:key];
				if (userInfoArray && [userInfoArray count] > 0) {
					for (InviteMsgUserInfo *userInfo in userInfoArray) {
						if (userInfo.checked) {
							isChecked = YES;
							break;
						}
					}
					if (isChecked) {
						break;
					}
				}
			}
			self.navigationItem.rightBarButtonItem.enabled = isChecked;
		}

	} else {
		InviteMsgGroupInfo *groupInfo = [addressGroupArray objectAtIndex:indexPath.section];
		if (groupInfo) {
			groupSectionArray = [buddyListDictionary objectForKey:groupInfo.groupTitle];
			if (groupSectionArray && [groupSectionArray count] > 0) {
				if(inviteType == AddressGroupSMSType){
					userInfo = [groupSectionArray objectAtIndex:indexPath.row];
					if(userInfo.phoneNum != nil && [userInfo.phoneNum length] > 0){
						InviteMsgTableCell* inviteMsgTableCell = (InviteMsgTableCell*)[tableView cellForRowAtIndexPath:indexPath];
						[inviteMsgTableCell checkAction:nil];
						userInfo = [groupSectionArray objectAtIndex:indexPath.row];
						userInfo.checked = !userInfo.checked;
					}else {
						NSString* disableSelUser = nil;
						if(userInfo.formatted != nil && [userInfo.formatted length] > 0){
							disableSelUser = [[NSString alloc] initWithFormat:@"%@ 님은 sms를 보낼 수 있는 전화번호가 없습니다.",userInfo.formatted];
						}else if(userInfo.nickName != nil && [userInfo.nickName length] > 0){
							disableSelUser = [[NSString alloc] initWithFormat:@"%@ 님은 sms를 보낼 수 있는 전화번호가 없습니다.",userInfo.nickName];
						}else{
							disableSelUser = [[NSString alloc] initWithFormat:@"이름없음 님은 sms를 보낼 수 있는 전화번호가 없습니다."];
						}
						UIAlertView* smsSelAlert = [[UIAlertView alloc] initWithTitle:@"그룹 SMS" 
																			  message:disableSelUser delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil ];
						[disableSelUser release];
						[smsSelAlert show];
						[smsSelAlert release];
						[tableView deselectRowAtIndexPath:indexPath animated:YES];
						return;
					}

				}else{
					InviteMsgTableCell* inviteMsgTableCell = (InviteMsgTableCell*)[tableView cellForRowAtIndexPath:indexPath];
					[inviteMsgTableCell checkAction:nil];
					userInfo = [groupSectionArray objectAtIndex:indexPath.row];
					userInfo.checked = !userInfo.checked;
				}
				
			}
		}
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		
		if (buddyListDictionary && [buddyListDictionary count] > 0) {
			for (id key in buddyListDictionary) {
				NSArray *userInfoArray = [buddyListDictionary objectForKey:key];
				if (userInfoArray && [userInfoArray count] > 0) {
					for (InviteMsgUserInfo *userInfo in userInfoArray) {
						if (userInfo.checked) {
							isChecked = YES;
							break;
						}
					}
					if (isChecked) {
						break;
					}
				}
			}
			self.navigationItem.rightBarButtonItem.enabled = isChecked;
		}
		
	}
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return kCustomSectionHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section 
{
	
	
	
	
	
	
	
	
	
	
//	NSLog(@"fdsafdsafdsfdsafds");
	InviteMsgSectionView *inviteMsgSectionView = [[[InviteMsgSectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.addressTableView.frame.size.width, kCustomSectionHeight)] autorelease];

	NSArray		*groupSectionArray = nil;
	if (section == 0) {
		if (self.alreadyJoinUserArray && [self.alreadyJoinUserArray count] > 0) {
			inviteMsgSectionView.groupTitleLabel.text = [NSString stringWithFormat:@"%@ (%i명)",@"참여중인 대화상대", [self.alreadyJoinUserArray count]];
		} else {
			InviteMsgGroupInfo *groupInfo = [addressGroupArray objectAtIndex:section];
			if (groupInfo) {
				groupSectionArray = [buddyListDictionary objectForKey:groupInfo.groupTitle];
				
				
				
					
				if (groupInfo.opened == NO) {
					inviteMsgSectionView.openImageView.image = [UIImage imageNamed:@"btn_close.png"];
				} else {
					inviteMsgSectionView.openImageView.image = [UIImage imageNamed:@"btn_open.png"];
				}
				inviteMsgSectionView.section = section;
				NSInteger nOnlineBuddy = 0;
				for(InviteMsgUserInfo *userInfo in groupSectionArray) {
					if (userInfo.imStatus) {
						if (![userInfo.imStatus isEqualToString:@"-1"] && ![userInfo.imStatus isEqualToString:@"0"]) {
							nOnlineBuddy++;
						}
					}
				}
				if (inviteType == AddressGroupSMSType) {
				inviteMsgSectionView.groupTitleLabel.text = [NSString stringWithFormat:@"%@ (%i/%i)",groupInfo.groupTitle, nOnlineBuddy, [groupSectionArray count]];
				} else {
					inviteMsgSectionView.groupTitleLabel.text = [NSString stringWithFormat:@"%@ (%i)",groupInfo.groupTitle, [groupSectionArray count]];
				}

				[inviteMsgSectionView addTarget:self action:@selector(sectionTouchDown:) forControlEvents:UIControlEventTouchDown];
			}
		}
	} else {
		if (self.alreadyJoinUserArray && [self.alreadyJoinUserArray count] > 0) {
			InviteMsgGroupInfo *groupInfo = [addressGroupArray objectAtIndex:section-1];
			if (groupInfo) {
				groupSectionArray = [buddyListDictionary objectForKey:groupInfo.groupTitle];
				
				
				
				
							
				
				
				
				
				
				
				
				
				inviteMsgSectionView.openImageView.image = [UIImage imageNamed:@"btn_open.png"];
				if (groupInfo.opened == NO) {
					inviteMsgSectionView.openImageView.image = [UIImage imageNamed:@"btn_close.png"];
				} else {
					inviteMsgSectionView.openImageView.image = [UIImage imageNamed:@"btn_open.png"];
				}
				inviteMsgSectionView.section = section-1;
				
				NSInteger nOnlineBuddy = 0;
				
				for(InviteMsgUserInfo *userInfo in groupSectionArray) {
					if (userInfo.imStatus) {
						if (![userInfo.imStatus isEqualToString:@"-1"] && ![userInfo.imStatus isEqualToString:@"0"]) {
							nOnlineBuddy++;
						}
					}
				}
				if (inviteType == AddressGroupSMSType) {	
					inviteMsgSectionView.groupTitleLabel.text = [NSString stringWithFormat:@"%@ (%i/%i)",groupInfo.groupTitle, nOnlineBuddy, [groupSectionArray count]];
				} else {
					inviteMsgSectionView.groupTitleLabel.text = [NSString stringWithFormat:@"%@ (%i)",groupInfo.groupTitle, [groupSectionArray count]];
				}

				[inviteMsgSectionView addTarget:self action:@selector(sectionTouchDown:) forControlEvents:UIControlEventTouchDown];
			}
		} else {
			InviteMsgGroupInfo *groupInfo = [addressGroupArray objectAtIndex:section];
			if (groupInfo) {
				groupSectionArray = [buddyListDictionary objectForKey:groupInfo.groupTitle];
				
				
				
				
				
				
				inviteMsgSectionView.openImageView.image = [UIImage imageNamed:@"btn_open.png"];
				if (groupInfo.opened == NO) {
					inviteMsgSectionView.openImageView.image = [UIImage imageNamed:@"btn_close.png"];
				} else {
					inviteMsgSectionView.openImageView.image = [UIImage imageNamed:@"btn_open.png"];
				}
				inviteMsgSectionView.section = section;
				
				NSInteger nOnlineBuddy = 0;
				
				for(InviteMsgUserInfo *userInfo in groupSectionArray) {
					if (userInfo.imStatus) {
						if (![userInfo.imStatus isEqualToString:@"-1"] && ![userInfo.imStatus isEqualToString:@"0"]) {
							nOnlineBuddy++;
						}
					}
				}
				if (inviteType == AddressGroupSMSType) {
				inviteMsgSectionView.groupTitleLabel.text = [NSString stringWithFormat:@"%@ (%i/%i)",groupInfo.groupTitle, nOnlineBuddy, [groupSectionArray count]];
				} else {
					inviteMsgSectionView.groupTitleLabel.text = [NSString stringWithFormat:@"%@ (%i)",groupInfo.groupTitle, [groupSectionArray count]];
				}

				[inviteMsgSectionView addTarget:self action:@selector(sectionTouchDown:) forControlEvents:UIControlEventTouchDown];
			}
		}
	}
	
	return inviteMsgSectionView;
}

#pragma mark -
#pragma mark UITableViewDataSource Protocol
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.

	if (self.alreadyJoinUserArray && [self.alreadyJoinUserArray count] > 0) {
		// 그룹정보 + 참여중인 대화상대
		return [buddyListDictionary count] + 1;
	} else {
		// 그룹정보
		return [buddyListDictionary count];
	}

    return [buddyListDictionary count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	
	NSArray		*groupSectionArray = nil;
	// 폴더를 접었을때는 0으로 표시
	
	/*
	USayAppAppDelegate *parentView = (USayAppAppDelegate*) [[UIApplication sharedApplication] delegate];
	//	NSLog(@"=======================parent =============================\n %@", [parentView.rootController.viewControllers objectAtIndex:0]);
	UINavigationController *tmp = [parentView.rootController.viewControllers objectAtIndex:0];
	AddressViewController *tmpAdd = (AddressViewController*)[tmp.viewControllers objectAtIndex:0];
	//	NSLog(@"=======================OBJECT =============================\n %@", tmpAdd);
	NSArray* sections = nil;
	GroupInfo *groupInfo = [tmpAdd.allGroups objectAtIndex:section];
	NSDictionary* viewTypeDic = nil;
	viewTypeDic = tmpAdd.peopleInGroup;
	sections = [viewTypeDic objectForKey:groupInfo.GROUPTITLE];
	
	
	NSLog(@"Sec Count =%d", [sections count]);
	
	*/
	
	/*
	// Configure the cell...
	UserInfo *dataItem = [sections objectAtIndex:indexPath.row]; 
	*/
	//InviteMsgUserInfo	*userInfo = nil;
	
	NSLog(@"all = %d", [self.alreadyJoinUserArray count]);	
	if (section == 0) {
		if (self.alreadyJoinUserArray && [self.alreadyJoinUserArray count] > 0) {
			return [self.alreadyJoinUserArray count];
		} else {
			InviteMsgGroupInfo *groupInfo = [addressGroupArray objectAtIndex:section];
			if (groupInfo) {	
				groupSectionArray = [buddyListDictionary objectForKey:groupInfo.groupTitle];
				
				
				
				if (groupInfo.opened == NO) {
					return 0;
				}
			}
		}
	} else {
		if (self.alreadyJoinUserArray && [self.alreadyJoinUserArray count] > 0) {
			InviteMsgGroupInfo *groupInfo = [addressGroupArray objectAtIndex:section-1];
			if (groupInfo) {
				groupSectionArray = [buddyListDictionary objectForKey:groupInfo.groupTitle];
				if (groupInfo.opened == NO) {
					return 0;
				}
			}
		} else {
			InviteMsgGroupInfo *groupInfo = [addressGroupArray objectAtIndex:section];
			if (groupInfo) {
				groupSectionArray = [buddyListDictionary objectForKey:groupInfo.groupTitle];
				NSLog(@"gropSecCnt = %d", [groupSectionArray count]);
			 if (groupInfo.opened == NO) {
					return 0;
				}
				
			}
		}
	}


    return [groupSectionArray count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *inviteMsgCellIdentifier = @"inviteMsgTableIndentifier";
	
    InviteMsgTableCell *cell = (InviteMsgTableCell *)[tableView dequeueReusableCellWithIdentifier:inviteMsgCellIdentifier];
    if (cell == nil) {
		cell = [[[InviteMsgTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:inviteMsgCellIdentifier] autorelease];
	//mezzo	cell = [[[InviteMsgTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
	}
	
	NSArray		*groupSectionArray = nil;
	InviteMsgUserInfo	*userInfo = nil;
	
	if (indexPath.section == 0) {
		if (self.alreadyJoinUserArray && [self.alreadyJoinUserArray count] > 0) {
			userInfo = [self.alreadyJoinUserArray objectAtIndex:indexPath.row];
		} else {
			InviteMsgGroupInfo *groupInfo = [addressGroupArray objectAtIndex:indexPath.section];
			if (groupInfo) {
				groupSectionArray = [buddyListDictionary objectForKey:groupInfo.groupTitle];
				userInfo = [groupSectionArray objectAtIndex:indexPath.row];
			}
		}
	} else {
		if (self.alreadyJoinUserArray && [self.alreadyJoinUserArray count] > 0) {
			InviteMsgGroupInfo *groupInfo = [addressGroupArray objectAtIndex:indexPath.section-1];
			if (groupInfo) {
				groupSectionArray = [buddyListDictionary objectForKey:groupInfo.groupTitle];
				userInfo = [groupSectionArray objectAtIndex:indexPath.row];
			}
		} else {
			InviteMsgGroupInfo *groupInfo = [addressGroupArray objectAtIndex:indexPath.section];
			if (groupInfo) {
				groupSectionArray = [buddyListDictionary objectForKey:groupInfo.groupTitle];
				userInfo = [groupSectionArray objectAtIndex:indexPath.row];
			}
		}
	}

	if (userInfo) {
		// Configure the cell...
		if (userInfo.RPKey && [userInfo.RPKey length] > 0) {
			if (userInfo.photoUrl && [userInfo.photoUrl length] > 0) {
				NSString *photoUrl = [NSString stringWithFormat:@"%@/011", userInfo.photoUrl];
				[cell.photoImageView setImageWithURL:[NSURL URLWithString:photoUrl]
									placeholderImage:[UIImage imageNamed:@"img_default.png"]];
			} else {
				cell.photoImageView.image = [UIImage imageNamed:@"img_default.png"];
			}
		} else {
			if (userInfo.photoUrl && [userInfo.photoUrl length] > 0) {
				NSString *photoUrl = [NSString stringWithFormat:@"%@/011", userInfo.photoUrl];
				[cell.photoImageView setImageWithURL:[NSURL URLWithString:photoUrl]
									placeholderImage:[UIImage imageNamed:@"img_default.png"]];
			} else {
				cell.photoImageView.image = [UIImage imageNamed:@"img_default.png"];
			}
		}

		
		if (inviteType == AddressGroupSMSType) {
			if(userInfo.formatted != nil && [userInfo.formatted length]>0){
				cell.nameTitleLabel.text = userInfo.formatted;
			}else if(userInfo.nickName != nil && [userInfo.nickName length]>0){
				cell.nameTitleLabel.text = userInfo.nickName;
			}else {
				cell.nameTitleLabel.text = @"이름 없음";
			}
			cell.subTitleLabel.text = userInfo.phoneNum;
		} else {
			cell.nameTitleLabel.text = userInfo.nickName;
			cell.subTitleLabel.text = userInfo.status;
		}
		cell.imstatus = userInfo.imStatus;
				
		
	
	
			if (indexPath.section == 0 && self.alreadyJoinUserArray && [self.alreadyJoinUserArray count] > 0) {
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
			//여기에서 가져오면 될텐데..
			
			
			
			
			
			
			cell.checked = YES;
		} else {
			cell.checked = userInfo.checked;
		}
	}
	
	/*
	//단체 문자 체크 관련 항목 YES면 체크다..
	USayAppAppDelegate *parentView = (USayAppAppDelegate*) [[UIApplication sharedApplication] delegate];
//	NSLog(@"=======================parent =============================\n %@", [parentView.rootController.viewControllers objectAtIndex:0]);
	UINavigationController *tmp = [parentView.rootController.viewControllers objectAtIndex:0];
	AddressViewController *tmpAdd = (AddressViewController*)[tmp.viewControllers objectAtIndex:0];
//	NSLog(@"=======================OBJECT =============================\n %@", tmpAdd);
	NSArray* sections = nil;
	GroupInfo *groupInfo = [tmpAdd.allGroups objectAtIndex:indexPath.section];
	NSDictionary* viewTypeDic = nil;
	viewTypeDic = tmpAdd.peopleInGroup;
	sections = [viewTypeDic objectForKey:groupInfo.GROUPTITLE];
	// Configure the cell...
	UserInfo *dataItem = [sections objectAtIndex:indexPath.row]; 
	NSLog(@"MOBILE= %@, HOME = %@, ORG = %@", dataItem.MOBILEPHONENUMBER, dataItem.HOMEPHONENUMBER, dataItem.ORGPHONENUMBER);
	
	if(dataItem.MOBILEPHONENUMBER == nil || [dataItem.MOBILEPHONENUMBER length]<=0 )
		dataItem.MOBILEPHONENUMBER = NULL;
	if(dataItem.HOMEPHONENUMBER == nil || [dataItem.HOMEPHONENUMBER length]<=0)
		dataItem.HOMEPHONENUMBER = NULL;
	if(dataItem.ORGPHONENUMBER == nil || [dataItem.ORGPHONENUMBER length]<=0)
		dataItem.ORGPHONENUMBER = NULL;
	
	
	if(dataItem.MOBILEPHONENUMBER == NULL && dataItem.HOMEPHONENUMBER == NULL && dataItem.ORGPHONENUMBER == NULL)
	{
		NSLog(@"NONONONONONNONONONONONOO");
		cell.checked = NO;
	}
	else {
		cell.checked = YES;
		NSLog(@"YESYESYES");
	}
*/
	
	
	
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kCustomRowHeight;
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

-(void)sectionTouchDown:(id)sender
{
	UIView *view = (UIView *)sender;
	if ([view isKindOfClass:[InviteMsgSectionView class]]) {
		InviteMsgSectionView* sectionView = (InviteMsgSectionView *)sender;
		
		NSArray		*groupSectionArray = nil;
		if (self.alreadyJoinUserArray && [self.alreadyJoinUserArray count] > 0) {
			InviteMsgGroupInfo *groupInfo = [addressGroupArray objectAtIndex:sectionView.section];
			if (groupInfo) {
				groupSectionArray = [buddyListDictionary objectForKey:groupInfo.groupTitle];
				if (groupSectionArray && [groupSectionArray count] > 0) {
					groupInfo.opened = !groupInfo.opened;
				}
			}
		} else {
			InviteMsgGroupInfo *groupInfo = [addressGroupArray objectAtIndex:sectionView.section];
			if (groupInfo) {
				groupSectionArray = [buddyListDictionary objectForKey:groupInfo.groupTitle];
				if (groupSectionArray && [groupSectionArray count] > 0) {
					groupInfo.opened = !groupInfo.opened;
				}
			}
		}

		[self.addressTableView reloadData];
	}
}

-(USayAppAppDelegate *)appDelegate
{
	return [[UIApplication sharedApplication] delegate];
}

-(void)backBarButtonClicked 
{
	[self.navigationController popViewControllerAnimated:NO];
}

-(void)completedClicked
{
	// 조건 1 : 선택된 값이 없을때는 popView
	// 조건 2 : 대화리스트에서 들어왔을때는 대화창 새로 생성
	// 조건 3 : 1:1 대화창에서 들어왔을때는 대화창을 새로 생성
	// 조건 4 : 그룹대화에서 들어왔을때는 기존 대화창 재사용 (기존창으로)
	
	NSMutableArray *inviteBuddyArray = nil;	// pKey 값으로 구성

	// 대화창에서 초대하기 기능 실행되었을 때. (기존 유저 존재)
	if (alreadyJoinUserArray && [alreadyJoinUserArray count] > 0) {
		// 기존 대화방의 msgType에 따라 신규개설/기존대화방 재사용 결정.
		if(addressBuddyArray && [addressBuddyArray count] > 0) {
			inviteBuddyArray = [NSMutableArray array];
			if (buddyListDictionary && [buddyListDictionary count] > 0) {
				for (id key in buddyListDictionary) {
					NSArray *userInfoArray = [buddyListDictionary objectForKey:key];
					if (userInfoArray && [userInfoArray count] > 0) {
						for (InviteMsgUserInfo *userInfo in userInfoArray) {
							if (userInfo.checked) {
								[inviteBuddyArray addObject:userInfo.RPKey];
							}
						}
					}
				}
			}
		} else {
			// 기존 유저 이외 선택된 유저가 없을 경우는 취소
			[self.navigationController popViewControllerAnimated:NO];
			return;
		}

		if (inviteBuddyArray && [inviteBuddyArray count] > 0) {
			if ([alreadyJoinUserArray count] + [inviteBuddyArray count] > 19) {	// 본인 포함 20명까지
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Usay" message:@"20명까지 대화가 가능합니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
				[alertView show];
				[alertView release];
				return;
			}
			// msgType 채팅세션 타입   P: 1:1   G: 그룹   nil:신규생성
			if ([cType isEqualToString:@"P"]) {
				for (InviteMsgUserInfo *userInfo in alreadyJoinUserArray) {
					[inviteBuddyArray addObject:userInfo.RPKey];
				}
				// chatSession 의 해당 대화방 생성 or inviteUserArray에 있는 Users의 pKey값으로 신규로 대화방 생성
				[CurrentParentViewController createJoinChatSession:inviteBuddyArray];
				[self.navigationController popViewControllerAnimated:NO];

			} else if ([cType isEqualToString:@"G"]) {
				// TODO: 선택된 User만 초대 하기 (joinToChatSession)
				[CurrentParentViewController inviteJoinChatSession:inviteBuddyArray];
				[self.navigationController popViewControllerAnimated:NO];
			} else {
				// error
			}
		} else {
			// 기존 유저 이외 선택된 유저가 없을 경우는 취소
			[self.navigationController popViewControllerAnimated:NO];
		}
	} 
	else // 주소록 그룹 SMS / 주소록 그룹대화 / 채팅 대기실에서 초대하기 기능 실행되었을 때. (기존 유저 없음)
	{
		if (inviteType == AddressGroupSMSType) {
			if(addressBuddyArray && [addressBuddyArray count] > 0) {
				inviteBuddyArray = [NSMutableArray array];
				if (buddyListDictionary && [buddyListDictionary count] > 0) {
					for (id key in buddyListDictionary) {
						NSArray *userInfoArray = [buddyListDictionary objectForKey:key];
						if (userInfoArray && [userInfoArray count] > 0) {
							for (InviteMsgUserInfo *userInfo in userInfoArray) {
								if (userInfo.checked) {
									if(userInfo.phoneNum != nil && [userInfo.phoneNum length] > 0){
										[inviteBuddyArray addObject:userInfo.phoneNum];
									}else{
									   //폰번호가 없는 유저를 알려 줘야 하는지? 여러명일경우 alert창이 계속 뜰수 있음.
									}
								}
							}
						}
					}
				}
				if ([inviteBuddyArray count] > 20) {		// 20명까지 SMS 가능
					UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Usay" message:@"그룹 SMS는 20명까지 발송 가능합니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
					[alertView show];
					[alertView release];
					return;
				}
				// inviteUserArray으로 그룹 SMS 발송 코드 추가 / 창 자동으로 닫도록 처리
				if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 4.0)
				{
					Class smsClass = (NSClassFromString(@"MFMessageComposeViewController"));
					if (smsClass != nil && [MFMessageComposeViewController canSendText])
					{
						MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
						controller.body = nil;
						controller.recipients = inviteBuddyArray;	// your recipient number or self for testing
						controller.messageComposeDelegate = self;
						
						[self.navigationController presentModalViewController:controller animated:YES];
						[controller release];              
					}
					else
					{
						[JYUtil alertWithType:ALERT_SMS_ERROR delegate:nil];
/*						UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"SMS 보내기" 
																		   message:@"SMS 기능을 사용 하실 수 없는 \n기기 입니다." 
																		  delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
						[alertView show];
						[alertView release];
*/						
					}
				}		
				else
				{
/*					UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"SMS 보내기" 
																	   message:@"SMS 기능을 사용 하실 수 없는 \n기기 입니다." 
																	  delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
					[alertView show];
					[alertView release];
 */					[JYUtil alertWithType:ALERT_SMS_ERROR_GRUOP delegate:nil];
				}
			} else {
				// 선택된 user 없음.
			}
			
		} else {
			inviteBuddyArray = [NSMutableArray array];
			if(addressBuddyArray && [addressBuddyArray count] > 0) {

				if (buddyListDictionary && [buddyListDictionary count] > 0) {
					for (id key in buddyListDictionary) {
						NSArray *userInfoArray = [buddyListDictionary objectForKey:key];
						if (userInfoArray && [userInfoArray count] > 0) {
							for (InviteMsgUserInfo *userInfo in userInfoArray) {
								if (userInfo.checked) {
									[inviteBuddyArray addObject:userInfo.RPKey];
								}
							}
						}
					}
				}
				if (inviteBuddyArray && [inviteBuddyArray count] > 0) {
					if ([inviteBuddyArray count] > 19) {		// 본인 포함 20명까지
						UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Usay" message:@"20명까지 대화가 가능합니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
						[alertView show];
						[alertView release];
						return;
					}

					NSString *chatSession = [[self appDelegate] chatSessionFrompKey:inviteBuddyArray];
					if (chatSession && [chatSession length] > 0) {
						// 채팅 대기실에 선택한 Users의 대화방 존재
						// chatSession 의 해당 대화방 생성 해야함.
						NSString *messageCType = nil;
						@synchronized([self appDelegate].msgArray) {
							[[self appDelegate].msgArray removeAllObjects];
							NSArray *msgArray = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where CHATSESSION=?", chatSession, nil];
							if (msgArray && [msgArray count] > 0) {
								for (MessageInfo *messageInfo in msgArray) {
									CellMsgData *msgData = [[CellMsgData alloc] init];
									msgData.chatsession = messageInfo.CHATSESSION;
									msgData.contentsMsg = messageInfo.MSG;
									if ([messageInfo.ISSENDMSG isEqualToString:@"1"]) {
										msgData.isSend = YES;
									} else {
										msgData.isSend = NO;
									}
									msgData.messagekey = messageInfo.MESSAGEKEY;
									msgData.movieFilePath = messageInfo.MOVIEFILEPATH;
									msgData.msgType = messageInfo.MSGTYPE;
									msgData.nickName = messageInfo.NICKNAME;
									msgData.photoFilePath = messageInfo.PHOTOFILEPATH;
									msgData.photoUrl = messageInfo.PHOTOURL;
									msgData.pKey = messageInfo.PKEY;
									msgData.readMarkCount = [messageInfo.READMARKCOUNT intValue];
									msgData.regTime = messageInfo.REGDATE;
									msgData.sendMsgSuccess = messageInfo.ISSUCCESS;
									[[self appDelegate].msgArray addObject:msgData];
									[msgData release];
								}
							}
						}
						NSString *title = nil;
						@synchronized([self appDelegate].msgListArray) {
							if ([self appDelegate].msgListArray && [[self appDelegate].msgListArray count] > 0) {
								for (CellMsgListData *msgListData in [self appDelegate].msgListArray) {
									if ([msgListData.chatsession isEqualToString:chatSession]) {
										messageCType = msgListData.cType;
										if (msgListData.userDataDic && [msgListData.userDataDic count] > 0) {
											if ([msgListData.userDataDic count] == 1) {
												for (id key in msgListData.userDataDic) {
													MsgUserData *userData = (MsgUserData*)[msgListData.userDataDic objectForKey:key];
													if (userData) {
														title = userData.nickName;
														break;
													} else {
														// error
														title = @"친구";
														break;
													}
												}
											} else if ([msgListData.userDataDic count] > 1) {
												title = [NSString stringWithFormat:@"그룹채팅 (%i명)", [msgListData.userDataDic count] + 1];
											} else {
												title = @"친구";
											}
										}
										break;
									}
								}
							}
						}
						// 기존 대화방으로 입장. joinToChatSession(초대) 메시지 보내지 않아도 됨.
						SayViewController *sayViewController = [[SayViewController alloc] initWithNibNameBuddyListMsgType:@"SayViewController" chatSession:chatSession type:messageCType BuddyList:nil bundle:nil];
						if(sayViewController != nil) {
							UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
							UIFont *titleFont = [UIFont systemFontOfSize:20];

							// sochae 2010.09.11 - UI Position
							//CGRect rect = [MyDeviceClass deviceOrientation];
							CGRect rect = self.view.frame;
							// ~sochae
							
							CGSize titleStringSize = [title sizeWithFont:titleFont constrainedToSize:(CGSizeMake(rect.size.width-120.0, MAXFLOAT))];
							UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, 20.0f)];
							[titleLabel setFont:titleFont];
							titleLabel.textAlignment = UITextAlignmentCenter;
							[titleLabel setTextColor:ColorFromRGB(0x053844)];
							[titleLabel setBackgroundColor:[UIColor clearColor]];
							[titleLabel setText:title];
							[titleView addSubview:titleLabel];
							[titleLabel release];
							sayViewController.navigationItem.titleView = titleView;
							[titleView release];
							sayViewController.navigationItem.titleView.frame = CGRectMake((self.addressTableView.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, 20.0f);				
							
							sayViewController.hidesBottomBarWhenPushed = YES;
							
							UINavigationController* naviController = self.navigationController;
							[naviController popToRootViewControllerAnimated:NO];
							
							[naviController pushViewController:sayViewController animated:YES];
							[sayViewController release];
						}
					} else {
						// inviteUserArray에 있는 Users의 pKey값으로 신규 대화방 개설
						SayViewController *sayViewController = [[SayViewController alloc] initWithNibNameBuddyListMsgType:@"SayViewController" chatSession:nil type:nil BuddyList:inviteBuddyArray bundle:nil];
						if(sayViewController != nil) {
							NSString *sayTitle = nil;
							if ([inviteBuddyArray count] > 0) {
								if ([inviteBuddyArray count] > 1) {
									sayTitle = [NSString stringWithFormat:@"그룹채팅 (%i명)", [inviteBuddyArray count]+1];	// 본인 포함
								} else {
									// 1:1
									for (NSString *RPKEY in inviteBuddyArray) {
										if (buddyListDictionary && [buddyListDictionary count] > 0) {
											for (id key in buddyListDictionary) {
												NSArray *userInfoArray = [buddyListDictionary objectForKey:key];
												if (userInfoArray && [userInfoArray count] > 0) {
													for (InviteMsgUserInfo *userInfo in userInfoArray) {
														if ([RPKEY isEqualToString:userInfo.RPKey]) {
															sayTitle = userInfo.nickName;
															break;
														}
													}
												}
												if (sayTitle && [sayTitle length] > 0) {
													break;
												}
											}
										}
										break;
									}
								}
							}
							UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
							UIFont *titleFont = [UIFont systemFontOfSize:20];
							// sochae 2010.09.11 - UI Position
							//CGRect rect = [MyDeviceClass deviceOrientation];
							CGRect rect = self.view.frame;
							// ~sochae
							
							CGSize titleStringSize = [sayTitle sizeWithFont:titleFont constrainedToSize:(CGSizeMake(rect.size.width-120.0, MAXFLOAT))];
							UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, 20.0f)];
							[titleLabel setFont:titleFont];
							titleLabel.textAlignment = UITextAlignmentCenter;
							[titleLabel setTextColor:ColorFromRGB(0x053844)];
							[titleLabel setBackgroundColor:[UIColor clearColor]];
							[titleLabel setText:sayTitle];
							[titleView addSubview:titleLabel];	
							[titleLabel release];
							sayViewController.navigationItem.titleView = titleView;
							[titleView release];
							sayViewController.navigationItem.titleView.frame = CGRectMake((self.addressTableView.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, 20.0f);				
							
							sayViewController.hidesBottomBarWhenPushed = YES;
							
							UINavigationController* naviController = self.navigationController;
							[naviController popToRootViewControllerAnimated:NO];
							
							[naviController pushViewController:sayViewController animated:YES];
							[sayViewController release];
						}
					}
				} else {
					// 선택된 유저가 없을 경우는 취소
					[self.navigationController popViewControllerAnimated:NO];
				}
			} else {
				// 선택된 유저가 없을 경우는 취소
				[self.navigationController popViewControllerAnimated:NO];
			}
		}
	}
}

//*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {	
	
	
	
	
	
	
	
	
		
	
		
	
	
	
	
	
	
	
	
	
	
	///모든 그룹
//	self.allGroups = [NSMutableArray arrayWithArray:[GroupInfo findAll]];
	
	
	
	UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
	UIFont *titleFont = [UIFont systemFontOfSize:20];
	CGSize titleStringSize = [navigationTitle sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
	UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
	[titleLabel setFont:titleFont];
	titleLabel.textAlignment = UITextAlignmentCenter;
	[titleLabel setTextColor:ColorFromRGB(0x053844)];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	[titleLabel setText:navigationTitle];
	[titleView addSubview:titleLabel];	
	[titleLabel release];
	self.navigationItem.titleView = titleView;
	[titleView release];
	self.navigationItem.titleView.frame = CGRectMake((self.addressTableView.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);

	// sochae 2010.09.11 - UI Position
	//CGRect rect = [MyDeviceClass deviceOrientation];
	CGRect rect = self.view.frame;
	// ~sochae
		
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
	
	addressTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
	[addressTableView setBackgroundColor:[UIColor whiteColor]];
	addressTableView.delegate = self;
	addressTableView.dataSource = self;
	addressTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	addressTableView.separatorColor = ColorFromRGB(0xc2c2c3);
	addressTableView.rowHeight = kCustomRowHeight;
	addressTableView.tag = ID_TABLEVIEW;
	[self.view addSubview:addressTableView];
	
	self.view.backgroundColor = ColorFromRGB(0x8fcad9);

	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	NSArray *groupDBArray = [GroupInfo findAll];
	
	if (groupDBArray != nil && [groupDBArray count] > 0) {
		addressGroupArray = [[NSMutableArray alloc] init];
		for (GroupInfo *groupDBInfo in groupDBArray) {
			InviteMsgGroupInfo *groupInfo = [[InviteMsgGroupInfo alloc] init];
			groupInfo.groupId = groupDBInfo.ID;
			if(groupDBInfo.GROUPTITLE == nil || [groupDBInfo.GROUPTITLE length] == 0) {
				groupInfo.groupTitle = @"이름없는 그룹";
			} else {
				groupInfo.groupTitle = groupDBInfo.GROUPTITLE;
			}
			if (selectedGroupId && [selectedGroupId length] > 0) {
				if ([selectedGroupId isEqualToString:groupInfo.groupId]) {
					NSLog(@"opened title = %@,  selectedGroupId=%@  groupInfo.groupId = %@", groupDBInfo.GROUPTITLE, selectedGroupId, groupInfo.groupId);
					groupInfo.opened = YES;
				} else {
					groupInfo.opened = NO;
				}
			} else {
				groupInfo.opened = NO;
			}

			[addressGroupArray addObject:groupInfo];
			[groupInfo release];
		}
		
		
			
		
		

/**
 * 그룹을 이름 순으로 정렬. 새로등록한 주소 그룹은 최상위에 두고, 나머진 그룹 이름순으로 정렬
 */
		NSSortDescriptor *groupNameSort = [[NSSortDescriptor alloc] initWithKey:@"groupTitle" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
		[addressGroupArray sortUsingDescriptors:[NSArray arrayWithObject:groupNameSort]];
		[groupNameSort release];
		for(int i = 0;i<[addressGroupArray count];i++){
			InviteMsgGroupInfo* groupInfo = [addressGroupArray objectAtIndex:i];
			
			if([groupInfo.groupId isEqualToString:@"0"]){
				InviteMsgGroupInfo *tempGroup = [[InviteMsgGroupInfo alloc] init];
				tempGroup.groupId = groupInfo.groupId;
				if(groupInfo.groupTitle == nil || [groupInfo.groupTitle length] == 0) {
					tempGroup.groupTitle = @"이름없는 그룹";
				} else {
					tempGroup.groupTitle = groupInfo.groupTitle;
				}
				if (selectedGroupId && [selectedGroupId length] > 0) {
					if ([selectedGroupId isEqualToString:tempGroup.groupId]) {
						NSLog(@"opened title = %@,  selectedGroupId=%@  groupInfo.groupId = %@", groupInfo.groupId, selectedGroupId, tempGroup.groupId);
						tempGroup.opened = YES;
					} else {
						tempGroup.opened = NO;
					}
				} else {
					tempGroup.opened = NO;
				}
				
				[addressGroupArray removeObject:groupInfo];
				[addressGroupArray insertObject:tempGroup atIndex:0];
				[tempGroup release];
				break;
			}
		}
		
		
			
		
		
		
	}
		
	NSArray *buddyDBArray = nil;
	if (alreadyJoinUserArray && [alreadyJoinUserArray count] > 0) {
		NSMutableArray *parameterList = [NSMutableArray array];
		NSMutableArray *parameterValueList = [NSMutableArray array];
		
		[parameterValueList addObject:@"S"];
		[parameterValueList addObject:@"Y"];
		
		for (InviteMsgUserInfo *userInfo in alreadyJoinUserArray) {
			[parameterList addObject: @"?"];
			[parameterValueList addObject:userInfo.RPKey];
			if (userInfo.RPKey && [userInfo.RPKey length] > 0) {
				NSString *imstatus = [[self appDelegate] getImStatus:userInfo.RPKey];
				if (imstatus == nil) {
					userInfo.imStatus = @"0";
				} else {
					userInfo.imStatus = imstatus;
				}
			} else {
				userInfo.imStatus = @"-1";
			}
		}

		///////////////////////////////////////////////////////////////////////////////////////////
		// 자기 자신은 제외
		[parameterList addObject:@"?"];
		[parameterValueList addObject:[[[self appDelegate] myInfoDictionary] objectForKey:@"pkey"]];
		///////////////////////////////////////////////////////////////////////////////////////////
		
		NSString *sql = [NSString stringWithFormat:@"select * from _TUserInfo where ISFRIEND=? and ISBLOCK<>? and RPKEY not in (%@)", [parameterList componentsJoinedByString:@","]];
		buddyDBArray = [UserInfo findWithSql:sql withParameters:parameterValueList];	//  and PKEY is not null
	} else {
		if (inviteType == AddressGroupSMSType) {
			buddyDBArray = [UserInfo findWithSqlWithParameters:@"select * from _TUserInfo where ISBLOCK<>? and (IPHONENUMBER is not null or MOBILEPHONENUMBER is not null)", @"Y", nil];
		} else {
			if ([[[self appDelegate] myInfoDictionary] objectForKey:@"pkey"] && [[[[self appDelegate] myInfoDictionary] objectForKey:@"pkey"] length] > 0) {
				buddyDBArray = [UserInfo findWithSqlWithParameters:@"select * from _TUserInfo where ISFRIEND=? and ISBLOCK<>? and RPKEY <> ?", @"S", @"Y", [[[self appDelegate] myInfoDictionary] objectForKey:@"pkey"], nil];
			} else {
				// skip
			}
		}		
	}

	if (buddyDBArray != nil && [buddyDBArray count] > 0) {
		addressBuddyArray = [[NSMutableArray alloc] init];
		for (UserInfo *buddyDBInfo in buddyDBArray) {
			InviteMsgUserInfo *userInfo = [[InviteMsgUserInfo alloc] init];

			if (buddyDBInfo.RPKEY && [buddyDBInfo.RPKEY length] > 0) {	// 버디타입
				if (buddyDBInfo.REPRESENTPHOTO && [buddyDBInfo.REPRESENTPHOTO length] > 0) {
					userInfo.photoUrl = buddyDBInfo.REPRESENTPHOTO;
				} else if (buddyDBInfo.THUMBNAILURL && [buddyDBInfo.THUMBNAILURL length] > 0) {
					userInfo.photoUrl = buddyDBInfo.THUMBNAILURL;
				} else {
					userInfo.photoUrl = @"";
				}
			} else {	// 주소록 타입
				if (buddyDBInfo.THUMBNAILURL && [buddyDBInfo.THUMBNAILURL length] > 0) {
					userInfo.photoUrl = buddyDBInfo.THUMBNAILURL;
				} else {
					userInfo.photoUrl = @"";
				}
			}

			if (inviteType == AddressGroupSMSType) {
				userInfo.ID = buddyDBInfo.ID;
				if (buddyDBInfo.FORMATTED && [buddyDBInfo.FORMATTED length] > 0) {
					userInfo.nickName = buddyDBInfo.FORMATTED;
				} else if (buddyDBInfo.PROFILENICKNAME && [buddyDBInfo.PROFILENICKNAME length] > 0) {
					userInfo.nickName = buddyDBInfo.PROFILENICKNAME;
				} else {
					userInfo.nickName = @"이름 없음";
				}
				
				if ([buddyDBInfo.ISFRIEND isEqualToString:@"S"] && buddyDBInfo.RPKEY && [buddyDBInfo.RPKEY length] > 0) {
					NSString *imstatus = [[self appDelegate] getImStatus:buddyDBInfo.RPKEY];
					if (imstatus == nil) {
						userInfo.imStatus = @"0";
					} else {
						userInfo.imStatus = imstatus;
					}
				} else {
					userInfo.imStatus = @"-1";
				}

				userInfo.nickName = buddyDBInfo.FORMATTED;
				if (buddyDBInfo.IPHONENUMBER && [buddyDBInfo.IPHONENUMBER length] > 0) {
					userInfo.phoneNum = (NSString*)[CheckPhoneNumber convertPhoneInsertHyphen:(NSMutableString*)buddyDBInfo.IPHONENUMBER];
				} else if (buddyDBInfo.MOBILEPHONENUMBER && [buddyDBInfo.MOBILEPHONENUMBER length] > 0) {
					userInfo.phoneNum = (NSString*)[CheckPhoneNumber convertPhoneInsertHyphen:(NSMutableString*)buddyDBInfo.MOBILEPHONENUMBER];
				} else {
					// error
				}
				if (selectedAddrGroupUserArray && [selectedAddrGroupUserArray count] > 0) {
					for (NSString *ID in selectedAddrGroupUserArray) {
						if ([userInfo.ID isEqualToString:ID]) {
							userInfo.checked = YES;
							break;
						}
					}
				} else {
					userInfo.checked = NO;
				}
			} else if (inviteType == AddressGroupSayType) {
				userInfo.RPKey = buddyDBInfo.RPKEY;
				if (buddyDBInfo.FORMATTED && [buddyDBInfo.FORMATTED length] > 0) {
					userInfo.nickName = buddyDBInfo.FORMATTED;
				} else if (buddyDBInfo.PROFILENICKNAME && [buddyDBInfo.PROFILENICKNAME length] > 0) {
					userInfo.nickName = buddyDBInfo.PROFILENICKNAME;
				} else {
					userInfo.nickName = @"이름 없음";
				}
				
				if (buddyDBInfo.RPKEY && [buddyDBInfo.RPKEY length] > 0) {
					NSString *imstatus = [[self appDelegate] getImStatus:buddyDBInfo.RPKEY];
					if (imstatus == nil) {
						userInfo.imStatus = @"0";
					} else {
						userInfo.imStatus = imstatus;
					}
				} else {
					// error
				}
				
				userInfo.status = buddyDBInfo.STATUS;
				if (selectedAddrGroupUserArray && [selectedAddrGroupUserArray count] > 0) {
					for (NSString *pKey in selectedAddrGroupUserArray) {
						if ([userInfo.RPKey isEqualToString:pKey]) {
							userInfo.checked = YES;
							break;
						}
					}
				} else {
					userInfo.checked = NO;
				}
			} else {
				userInfo.RPKey = buddyDBInfo.RPKEY;
				if (buddyDBInfo.FORMATTED && [buddyDBInfo.FORMATTED length] > 0) {
					userInfo.nickName = buddyDBInfo.FORMATTED;
				} else if (buddyDBInfo.PROFILENICKNAME && [buddyDBInfo.PROFILENICKNAME length] > 0) {
					userInfo.nickName = buddyDBInfo.PROFILENICKNAME;
				} else {
					userInfo.nickName = @"이름 없음";
				}
				if (buddyDBInfo.RPKEY && [buddyDBInfo.RPKEY length] > 0) {
					NSString *imstatus = [[self appDelegate] getImStatus:buddyDBInfo.RPKEY];
					if (imstatus == nil) {
						userInfo.imStatus = @"0";
					} else {
						userInfo.imStatus = imstatus;
					}
				} else {
					// error
				}
				
				userInfo.status = buddyDBInfo.STATUS;
				userInfo.checked = NO;
			}

			userInfo.groupId = buddyDBInfo.GID;
			
			[addressBuddyArray addObject:userInfo];
			[userInfo release];
		}
	}
	
	buddyListDictionary = [[NSMutableDictionary alloc] init];
	for(InviteMsgGroupInfo* groupInfo in addressGroupArray){
		NSMutableArray* buddyArray = [NSMutableArray array];
		for(InviteMsgUserInfo* userInfo in addressBuddyArray){
			if([userInfo.groupId isEqualToString:groupInfo.groupId]) {
				
			//mezzo 전화번호 없는애들은 컨티뉴... 그룹 sms에서는 모바일 번호 있는 애들만 문자 보내지기로 한다.
				
				NSLog(@"userinfo = %@", userInfo);
				
				if (sayFlag == FALSE) {
				
					if(userInfo.phoneNum == NULL || userInfo.phoneNum == nil || [userInfo.phoneNum isEqualToString:@""])
						continue;
				}
				
				NSLog(@"userinfo = %@", userInfo.nickName);
				[buddyArray addObject:userInfo];
			} else {
			}
		}
		NSSortDescriptor *nickNameSort = [[NSSortDescriptor alloc] initWithKey:@"nickName" ascending:YES];
		[buddyArray sortUsingDescriptors:[NSArray arrayWithObject:nickNameSort]];
		[nickNameSort release];
		
	
		
		[buddyListDictionary setObject:buddyArray forKey:groupInfo.groupTitle];

		
		
		
		
	}

	if (inviteType == AddressGroupSayType || inviteType == AddressGroupSMSType) {
		if (selectedAddrGroupUserArray && [selectedAddrGroupUserArray count] > 0) {
			self.navigationItem.rightBarButtonItem.enabled = YES;
		}
	}

	[pool release];

    [super viewDidLoad];
}
//*/

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	//	message.hidden = NO;
	switch (result)
	{
		case MessageComposeResultCancelled:
			//		message.text = @"Result: canceled";
			NSLog(@"Result: canceled");
			break;
		case MessageComposeResultSent:
			//	message.text = @"Result: sent";
			NSLog(@"Result: sent");
			break;
		case MessageComposeResultFailed:
			//	message.text = @"Result: failed";
			NSLog(@"Result: failed");
			break;
		default:
			//	message.text = @"Result: not sent";
			NSLog(@"Result: not sent");
			break;
	}
	
	[self dismissModalViewControllerAnimated:YES];
	if(result == MessageComposeResultSent)
		[self.navigationController popViewControllerAnimated:NO];
	
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

- (void)willRotate
{
	// sochae 2010.09.11 - UI Position
	//CGRect rect = [MyDeviceClass deviceOrientation];
	CGRect rect = self.view.frame;
	// ~sochae
	
	CGRect addressTableViewFrame = addressTableView.frame;
	
	addressTableViewFrame.size.width = rect.size.width;
	addressTableViewFrame.size.height = rect.size.height;
	
	addressTableView.frame = addressTableViewFrame;
	
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
	[addressTableView reloadData];
	BOOL		isChecked = NO;
	
	if (buddyListDictionary && [buddyListDictionary count] > 0) {
		for (id key in buddyListDictionary) {
			NSArray *userInfoArray = [buddyListDictionary objectForKey:key];
			if (userInfoArray && [userInfoArray count] > 0) {
				for (InviteMsgUserInfo *userInfo in userInfoArray) {
					if (userInfo.checked) {
						isChecked = YES;
						break;
					}
				}
				if (isChecked) {
					break;
				}
			}
		}
		self.navigationItem.rightBarButtonItem.enabled = isChecked;
	}
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	switch (toInterfaceOrientation)  
    {  
        case UIDeviceOrientationPortrait: 
		{
			[self willRotate];
		}
            break;  
        case UIDeviceOrientationLandscapeLeft:
		{
			[self willRotate];
		}
            break;  
        case UIDeviceOrientationLandscapeRight:  
		{
			[self willRotate];
		}
            break;  
        case UIDeviceOrientationPortraitUpsideDown:  
		{
			[self willRotate];
		}
            break;  
		case UIDeviceOrientationFaceUp:
		{
			[self willRotate];
		}
            break;  
		case UIDeviceOrientationFaceDown:
		{
			[self willRotate];
		}
            break;  
		case UIDeviceOrientationUnknown:
		{
			[self willRotate];
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
	NSLog(@"InviteMsgViewController dealloc");
	
	if(addressTableView) {
		[addressTableView release];
	}
//	if(searchBuddyArray) {
//		[searchBuddyArray release];
//	}
	if (addressGroupArray) {
		[addressGroupArray release];
		addressGroupArray = nil;
	}
	if(addressBuddyArray) {
		[addressBuddyArray release];
		addressBuddyArray = nil;
	}
	if (selectedAddrGroupUserArray) {
		[selectedAddrGroupUserArray release];
		selectedAddrGroupUserArray = nil;
	}
	if(buddyListDictionary) {
		[buddyListDictionary release];
		buddyListDictionary = nil;
	}
	if(alreadyJoinUserArray) {
		[alreadyJoinUserArray release];
		alreadyJoinUserArray = nil;
	}

    [super dealloc];
}


@end
