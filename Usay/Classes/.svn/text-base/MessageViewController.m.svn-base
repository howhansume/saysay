//
//  MessageViewController.m
//  USayApp
//
//  Created by 1team on 10. 6. 14..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "MessageViewController.h"
#import "MessageTableCell.h"
#import "USayAppAppDelegate.h"
#import "SayViewController.h"
#import "CellMsgListData.h"
#import "CellMsgData.h"
#import "USayHttpData.h"
#import "json.h"
#import "HttpAgent.h"
#import "RoomInfo.h"				// 대화방 리스트 관리				_TROOMINFO
#import "MessageInfo.h"				// 대화내용 관리					_TMESSAGEINFO
#import "MessageUserInfo.h"			// 대봐방에 있는 버디 리스트 관리		_TMESSAGEUSERINFO
#import "InviteMsgViewController.h"
#import "UIImageView+WebCache.h"
#import "USayDefine.h"
#import "JYGanTracker.h"
#import "Reachability.h"
#import "SystemMessageTable.h"
#import "UserInfo.h"

#import <CommonCrypto/CommonDigest.h>



#define kCustomRowHeight		58.0
#define kCustomRowCount			6
#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
										green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
										blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define HANGUL_BEGIN_UNICODE	44032	// 가
#define HANGUL_END_UNICODE		55203	// 힣

#define degreesToRadians(x) (M_PI * (x) / 180.0)

@implementation MessageViewController

@synthesize	msgSearchArray,chosungNumArray;
@synthesize	chosungArray;
@synthesize	jungsungArray;
@synthesize	jongsungArray;

//extern int apns_noti_count;
extern BOOL LOGINSUCESS;
extern BOOL LOGINEND;
extern BOOL LOGINSTART;
extern BOOL CHKOFF;
BOOL searchMsg;
int selectIndex;
extern BOOL SMGSUCESS;
-(id)init 
{
	self = [super init];
	
	if(self != nil) {
		msgSearchArray = nil;
		chosungNumArray = nil;
		chosungArray = nil;
		jungsungArray = nil;
		jongsungArray = nil;
	}
	
	return self;
}

#pragma mark -
#pragma mark NSNotification response
#pragma mark <--- 채팅 리스트 갱신
-(void)reloadMsgList:(NSNotification *)notification
{
	[self.tableView reloadData];
}

-(void)refreshbadge:(NSNotification *)notification
{
	
	//뱃지 갯수 0 그리고 roomInfo 업데이트
	
	
	
	CellMsgListData *msgListData = nil;
	if(searchMsg == YES) //서치 테이블이면...
	{// Configure the cell...
		// Set up the cell...
		msgListData = [self.msgSearchArray objectAtIndex:selectIndex];
	} else {//서치가 아니면...
		msgListData = [[self appDelegate].msgListArray objectAtIndex:selectIndex];
	}
	NSString *badgeUpdate = [NSString stringWithFormat:@"update _TRoomInfo set newMsgCount='0' where CHATSESSION='%@'", msgListData.chatsession];
	NSLog(@"badgeUpdate = %@", badgeUpdate);
	[RoomInfo findWithSql:badgeUpdate];
	msgListData.newMsgCount = 0;
	NSInteger nNewMsgCount = [[self appDelegate] newMessageCount];
	if (nNewMsgCount == 0) {
		UITabBarItem *tbi = [[self appDelegate].rootController.tabBar.items objectAtIndex:2]; //기존 1->2로 
		if (tbi) {
			tbi.badgeValue = nil;
		}
		[[UIApplication sharedApplication] setApplicationIconBadgeNumber:nNewMsgCount];
	} else if (nNewMsgCount > 0) {
		UITabBarItem *tbi = [[self appDelegate].rootController.tabBar.items objectAtIndex:2];//기존 1->2로
		if (tbi) {
			tbi.badgeValue = [NSString stringWithFormat:@"%i", nNewMsgCount];
		}
		[[UIApplication sharedApplication] setApplicationIconBadgeNumber:nNewMsgCount];
	}
	
	[self.tableView reloadData];
	
	
	
}

-(void)quitFromChatSession:(NSNotification *)notification
{
	USayHttpData *data = (USayHttpData*)[notification object];
	if (data == nil) {
		// 200 이외의 에러
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0022)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
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
			NSString *sessionKey = [addressDic objectForKey:@"sessionKey"];
			if (sessionKey && [sessionKey length] > 0) {
				NSArray *checkRoomInfo = [RoomInfo findWithSqlWithParameters:@"select * from _TRoomInfo where CHATSESSION=?", sessionKey, nil];
				if (checkRoomInfo && [checkRoomInfo count] > 0) {
					[RoomInfo findWithSqlWithParameters:@"delete from _TRoomInfo where CHATSESSION=?", sessionKey, nil];
				}
				NSArray *checkMessageUserInfo = [MessageUserInfo findWithSqlWithParameters:@"select * from _TMessageUserInfo where CHATSESSION=?", sessionKey, nil];
				if (checkMessageUserInfo && [checkMessageUserInfo count] > 0) {
					[MessageUserInfo findWithSqlWithParameters:@"delete from _TMessageUserInfo where CHATSESSION=?", sessionKey, nil];
				}
				NSArray *checkMessageInfo = [MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where CHATSESSION=?", sessionKey, nil];
				if (checkMessageInfo && [checkMessageInfo count] > 0) {
					for (MessageInfo *messageInfo in checkMessageInfo) {
						if([messageInfo.MSGTYPE isEqualToString:@"P"]) {		// cache에 저장된 파일이 있으면 삭제 처리
							if (messageInfo.PHOTOFILEPATH && [messageInfo.PHOTOFILEPATH length] > 0) {
								NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
								NSString *cachesDirectory = [paths objectAtIndex:0];
								NSString *imagePath = [cachesDirectory stringByAppendingPathComponent:messageInfo.PHOTOFILEPATH];
								if (imagePath && [imagePath length] > 0) {
									if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath isDirectory:NO]) {
										NSError *error = nil;
										BOOL successed = [[NSFileManager defaultManager] removeItemAtPath:imagePath error:&error]; 
										if (!successed) {
											NSLog(@"error quitFromChatSession photo removeItemAtPath %@", [error localizedDescription]);
										}
									}
								}
							}
						} else if ([messageInfo.MSGTYPE isEqualToString:@"V"]) {// cache에 저장된 파일이 있으면 삭제 처리
							if (messageInfo.MOVIEFILEPATH && [messageInfo.MOVIEFILEPATH length] > 0) {
								NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
								NSString *cachesDirectory = [paths objectAtIndex:0];
								NSString *imagePath = [cachesDirectory stringByAppendingPathComponent:messageInfo.MOVIEFILEPATH];
								if (imagePath && [imagePath length] > 0) {
									if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath isDirectory:NO]) {
										NSError *error = nil;
										BOOL successed = [[NSFileManager defaultManager] removeItemAtPath:imagePath error:&error]; 
										if (!successed) {
											NSLog(@"error quitFromChatSession movie removeItemAtPath %@", [error localizedDescription]);
										}
									}
								}
							}
						} else {
							// skip
						}
					}
					[MessageInfo findWithSqlWithParameters:@"delete from _TMessageInfo where CHATSESSION=?", sessionKey, nil];
				}
			}

			// DB에서 읽어서 Badge표기
			NSInteger nNewMsgCount = [[self appDelegate] newMessageCount];
			if (nNewMsgCount == 0) {
				UITabBarItem *tbi = [[self appDelegate].rootController.tabBar.items objectAtIndex:2]; //기존 1->2로 
				if (tbi) {
					tbi.badgeValue = nil;
				}
				[[UIApplication sharedApplication] setApplicationIconBadgeNumber:nNewMsgCount];
			} else if (nNewMsgCount > 0) {
				UITabBarItem *tbi = [[self appDelegate].rootController.tabBar.items objectAtIndex:2];//기존 1->2로
				if (tbi) {
					tbi.badgeValue = [NSString stringWithFormat:@"%i", nNewMsgCount];
				}
				[[UIApplication sharedApplication] setApplicationIconBadgeNumber:nNewMsgCount];
			} else {
				
			}
			
			
		} else {
			// 예외처리
		}
	} else if ([rtcode isEqualToString:@"-8012"]) {
		// 처리 오류
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-8012)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else if ([rtcode isEqualToString:@"-9030"]) {
		// 처리 오류
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-9030)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else {
		// fail (-8080 이외 기타오류)
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0023)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	}
	[self.tableView reloadData];
}

-(void)applicationWillTerminate:(NSNotification *)notification
{
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
#pragma mark UITableViewDelegate Protocol

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	
	selectIndex = indexPath.row;

	
	if(tableView.editing == YES) {
		NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
		[self.tableView deselectRowAtIndexPath:tableSelection animated:NO];
		return;
	} else {
	}
	CellMsgListData *msgListData = nil;
	if(tableView == self.searchDisplayController.searchResultsTableView) {
		// Configure the cell...
		// Set up the cell...
		msgListData = [self.msgSearchArray objectAtIndex:indexPath.row];
		
		searchMsg = YES;
	} else {
		msgListData = [[self appDelegate].msgListArray objectAtIndex:indexPath.row];
		searchMsg = NO;
	}
	
	// 기존 대화가 있으면 DB에서 메모리로 로드.
	[[self appDelegate].msgArray removeAllObjects];	
	if (msgListData.chatsession && [msgListData.chatsession length] > 0) { 
		//날짜순으로 정렬..
		NSArray *messageInfoDBArray = (NSMutableArray*)[MessageInfo findWithSqlWithParameters:@"select * from _TMessageInfo where CHATSESSION=? order by REGDATE", msgListData.chatsession, nil];
		if (messageInfoDBArray != nil && [messageInfoDBArray count] > 0) {
			for (MessageInfo *messageInfo in messageInfoDBArray) {
				CellMsgData *msgData = [[CellMsgData alloc] init];
				msgData.chatsession = msgListData.chatsession;
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
	NSMutableArray *buddyPkeyArray = [[[NSMutableArray alloc] init] autorelease];
	for (id key in msgListData.userDataDic) {
		if ([msgListData.userDataDic count] == 1) {
			MsgUserData *userInfo = (MsgUserData*)[msgListData.userDataDic objectForKey:key];
			title = userInfo.nickName;
		}
		[buddyPkeyArray addObject:key];
	}
	////////////////////////////////////
	DebugLog(@"buddyPkeyArray %@", buddyPkeyArray);
//	[[NSNotificationCenter defaultCenter] postNotificationName:@"refreshbadge" object:nil];
	SayViewController *sayViewController = [[SayViewController alloc] initWithNibNameBuddyListMsgType:@"SayViewController" chatSession:msgListData.chatsession type:msgListData.cType BuddyList:buddyPkeyArray bundle:nil];
	if(sayViewController != nil) {
		if ([msgListData.userDataDic count] > 1) {
			title = [NSString stringWithFormat:@"그룹채팅 (%i명)", [msgListData.userDataDic count] ]; //자기 자신은 포함 시키지 않음
		} else if ([msgListData.userDataDic count] == 1) {
			// 위에서 값 받아옴
		} else {
			title = @"대화자 없음";
		}

		CGRect rect = [[UIScreen mainScreen] applicationFrame];
		
		UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
		UIFont *titleFont = [UIFont systemFontOfSize:20];
		if (title == nil)
			title = @"";
		CGSize titleStringSize = [title sizeWithFont:titleFont constrainedToSize:(CGSizeMake(rect.size.width - 120.0, MAXFLOAT))];
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
		sayViewController.navigationItem.titleView.frame = CGRectMake((self.tableView.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, 20.0f);
		
		sayViewController.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:sayViewController animated:YES];
		[sayViewController release];
	}
}

#pragma mark -
#pragma mark UITableViewDataSource Protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	if(tableView == self.searchDisplayController.searchResultsTableView) {
		return 1;
	} else {
	}
	
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if(tableView == self.searchDisplayController.searchResultsTableView) {
		return [self.msgSearchArray count];
	} else {
	}
    return [[[self appDelegate] msgListArray] count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *msgListCellIdentifier = @"msgListTableIndentifier";

    MessageTableCell *cell = (MessageTableCell *)[tableView dequeueReusableCellWithIdentifier:msgListCellIdentifier];
    if (cell == nil) {
		cell = [[[MessageTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:msgListCellIdentifier] autorelease];
	}
	
	if(tableView == self.searchDisplayController.searchResultsTableView) {
		// Configure the cell...
		// Set up the cell...
		CellMsgListData *msgListData = [self.msgSearchArray objectAtIndex:indexPath.row];
		NSString *photoUrl = nil;
		NSMutableString *nickName = nil;
		if (msgListData.userDataDic && [msgListData.userDataDic count] > 0) {
			for (id key in msgListData.userDataDic) {
				MsgUserData *userData = [msgListData.userDataDic objectForKey:key];
				if (nickName != nil && [nickName length] > 0) {
					NSString *temp = [[NSString alloc ] initWithFormat:@",%@", userData.nickName];
					[nickName insertString:temp atIndex:[nickName length]];
					[temp release];
				} else {
					if (userData.nickName && [userData.nickName length] > 0) {
						nickName = [NSMutableString stringWithString:userData.nickName];
					} else {
						nickName = (NSMutableString*)@"이름 없음";
					}
				}
				if ([msgListData.userDataDic count] == 1) {
					if (userData.photoUrl != nil && [userData.photoUrl length] > 0) {
						photoUrl = [NSString stringWithFormat:@"%@/011", userData.photoUrl];
					}
				}
			}
			if ([msgListData.userDataDic count] == 1) {
				if (photoUrl != nil && [photoUrl length] > 0) {
					[cell.photoImageView setImageWithURL:[NSURL URLWithString:photoUrl] placeholderImage:[UIImage imageNamed:@"img_default.png"]];
				} else {
					cell.photoImageView.image = [UIImage imageNamed:@"img_default.png"];
				}
			} else if ([msgListData.userDataDic count] > 1) {
				cell.photoImageView.image = [UIImage imageNamed:@"img_group.png"];
			} else {
				// skip
			}
		} else {
			cell.photoImageView.image = [UIImage imageNamed:@"img_default.png"];
			nickName = (NSMutableString*)@"대화자 없음";
		}

		if (msgListData && msgListData.userDataDic && [msgListData.userDataDic count] > 1) {
			cell.totalCountLabel.text = [NSString stringWithFormat:@"(%i명)", [msgListData.userDataDic count]];
		} else {
			cell.totalCountLabel.text = @"";
		}

		cell.nickNameLabel.text = nickName;
		if ([msgListData.lastMsgType isEqualToString:@"T"]) {
			cell.lastMsgLabel.text = msgListData.lastMsg;
		} else if ([msgListData.lastMsgType isEqualToString:@"P"]) {
			cell.lastMsgLabel.text = @"이미지";
		} else if ([msgListData.lastMsgType isEqualToString:@"V"]) {
			cell.lastMsgLabel.text = @"동영상";
		} else {
			// skip
		}
		cell.lastDateLabel.text = [[self appDelegate] generateMsgListDateFromUnixTimeStampFromString:msgListData.lastMsgDate];
		[cell setNewMsgCount:[msgListData newMsgCount]];
	}
	else {
		// Configure the cell...
		// Set up the cell...
		CellMsgListData *msgListData = [[self appDelegate].msgListArray objectAtIndex:indexPath.row];
		NSString *photoUrl = nil;
		NSMutableString *nickName = nil;
		if (msgListData.userDataDic && [msgListData.userDataDic count] > 0) {
			
			
			NSLog(@"msgListData.userDataDic all key %@", [msgListData.userDataDic allKeys]);
				NSLog(@"msgListData.userDataDic all values %@", [msgListData.userDataDic allValues]);
			for (id key in msgListData.userDataDic) {
				MsgUserData *userData = [msgListData.userDataDic objectForKey:key];
				
				
				DebugLog(@"usrData pkey userfname, photo %@ %@ %@",userData.pKey, userData.nickName, userData.photoUrl);
				
				DebugLog(@"참여자 닉템 %@", userData.nickName);
				
				
				
				if (nickName != nil && [nickName length] > 0) {
					NSLog(@"nickname not nil = %@", nickName);
					NSString *temp = [[NSString alloc ] initWithFormat:@",%@", userData.nickName];
					[nickName insertString:temp atIndex:[nickName length]];
					[temp release];
				} else {
					if (userData.nickName && [userData.nickName length] > 0) {
						NSLog(@"nickname = %@", userData.nickName);
						nickName = [NSMutableString stringWithString:userData.nickName];
					} else {
						nickName = (NSMutableString*)@"이름 없음";
					}
				}
				if ([msgListData.userDataDic count] == 1) {
					if (userData.photoUrl != nil && [userData.photoUrl length] > 0) {
						photoUrl = [NSString stringWithFormat:@"%@/011", userData.photoUrl];
					}
				}
			}

			// 1:1 대화이면, 상대방 이미지 표시.
			if ([msgListData.userDataDic count] == 1) {
				if (photoUrl != nil && [photoUrl length] > 0) {
					[cell.photoImageView setImageWithURL:[NSURL URLWithString:photoUrl] placeholderImage:[UIImage imageNamed:@"img_default.png"]];
				} else {
					cell.photoImageView.image = [UIImage imageNamed:@"img_default.png"];
				}
				
			} else if ([msgListData.userDataDic count] > 1) {
				cell.photoImageView.image = [UIImage imageNamed:@"img_group.png"];
			} else {
				// skip
			}
		} else {
			cell.photoImageView.image = [UIImage imageNamed:@"img_default.png"];
			nickName = (NSMutableString*)@"대화자 없음";
		}

		// 그룹 대화자 표시.
		if (msgListData && msgListData.userDataDic && [msgListData.userDataDic count] > 1) {
			cell.totalCountLabel.text = [NSString stringWithFormat:@"(%i명)", [msgListData.userDataDic count]];
		} else {
			cell.totalCountLabel.text = @"";
		}
	
		cell.nickNameLabel.text = nickName;
	
		if ([msgListData.lastMsgType isEqualToString:@"T"]) {
			cell.lastMsgLabel.text = msgListData.lastMsg;
		} else if ([msgListData.lastMsgType isEqualToString:@"P"]) {
			cell.lastMsgLabel.text = @"이미지";
		} else if ([msgListData.lastMsgType isEqualToString:@"V"]) {
			cell.lastMsgLabel.text = @"동영상";
		} else {
			cell.lastMsgLabel.text = @"";
		}
		
		// 메시지 리스트에 날짜, 뱃지 표시.
		cell.lastDateLabel.text = [[self appDelegate] generateMsgListDateFromUnixTimeStampFromString:msgListData.lastMsgDate];
		[cell setNewMsgCount:[msgListData newMsgCount]];
		
		NSLog(@"newCnt  = %d", [msgListData newMsgCount]);
		
	}

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(tableView == self.searchDisplayController.searchResultsTableView) {
		return kCustomRowHeight;
	}
	
	return kCustomRowHeight;
}

-(BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{	
	return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([self appDelegate].connectionType == -1) {	// -1:offline mode 0:disconnect 1:Wi-Fi 2:3G
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"오프라인" message:@"현재 네트워크 연결이 불가능한 상태입니다.\nUsay의 모든 기능을 이용하기 위해서는 네트워크 연결이 필요합니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return;
	} else if ([self appDelegate].connectionType == 0) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"3G 또는 Wi-Fi 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0024)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return;
	}
	if(editingStyle == UITableViewCellEditingStyleDelete) {
		
		
		if(LOGINSUCESS != YES)
		{
			
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"로그인 중에는 삭제 할 수 없습니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
			[alertView show];
			[alertView release];
			return;
			
		}
		
		// TODO: 삭제
		// Delete the row from the data source 
		if(tableView == self.searchDisplayController.searchResultsTableView) {
			
			CellMsgListData *msgListData = [self.msgSearchArray objectAtIndex:indexPath.row];
			NSString *chatsession = msgListData.chatsession;
			NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
			[bodyObject setObject:[[self appDelegate] getSvcIdx] forKey:@"svcidx"];
			[bodyObject setObject:chatsession forKey:@"sessionKey"];
			
			// 서버 request 
			USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"quitFromChatSession" andWithDictionary:bodyObject timeout:10] autorelease];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];

			// 메모리에서 메시지 리스트 삭제
			int i = 0;
			for (CellMsgListData *msgData in [[self appDelegate] msgListArray]) {
				if ([chatsession isEqualToString:msgData.chatsession]) {
					[[[self appDelegate] msgListArray] removeObjectAtIndex:i];
					[self.tableView reloadData];
					break;
				}
				i++;
			}
			[self.msgSearchArray removeObjectAtIndex:indexPath.row];
			if ([self.msgSearchArray count] <= 0) {

				// sochae 2010.09.10 - UI Position
				//CGRect rect = [MyDeviceClass deviceOrientation];
				CGRect rect = [[UIScreen mainScreen] applicationFrame];
				// ~sochae

				//내비게이션 바 버튼 설정
				UIImage* leftBarBtnImg = nil;
				UIImage* leftBarBtnSelImg = nil;
				UIImage* rightBarBtnImg = nil;
				UIImage* rightBarBtnSelImg = nil;
				
				if (rect.size.width < rect.size.height) {	
					leftBarBtnImg = [UIImage imageNamed:@"btn_top_edit.png"];
					leftBarBtnSelImg = [UIImage imageNamed:@"btn_top_edit_focus.png"];
					rightBarBtnImg = [UIImage imageNamed:@"btn_top_group_add.png"];
					rightBarBtnSelImg = [UIImage imageNamed:@"btn_top_group_add_focus.png"];
				} else {
					leftBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_edit.png"];
					leftBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_edit_focus.png"];
					rightBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_group_add.png"];
					rightBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_group_add_focus.png"];
				}

				UIButton* leftBarButton = (UIButton*)[self.navigationItem.leftBarButtonItem customView];
				[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
				[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateSelected];
				leftBarButton = nil;
				
				UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
				[rightBarButton addTarget:self action:@selector(sayButtonClicked) forControlEvents:UIControlEventTouchUpInside];
				[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
				[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
				rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
				self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:rightBarButton] autorelease];
				
				[self.tableView setEditing:NO animated:YES];
			}
		} else {
			
			CellMsgListData *msgListData = [[[self appDelegate] msgListArray] objectAtIndex:indexPath.row];
			NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
			[bodyObject setObject:[[self appDelegate] getSvcIdx] forKey:@"svcidx"];
			[bodyObject setObject:msgListData.chatsession forKey:@"sessionKey"];
			// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
			USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"quitFromChatSession" andWithDictionary:bodyObject timeout:10] autorelease];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
			// 메모리에서 메시지 리스트 삭제
			[[[self appDelegate] msgListArray] removeObjectAtIndex:indexPath.row];
			
			if ([[self appDelegate].msgListArray count] <= 0) {

				// sochae 2010.09.10 - UI Position
				//CGRect rect = [MyDeviceClass deviceOrientation];
				CGRect rect = [[UIScreen mainScreen] applicationFrame];
				// ~sochae

				//내비게이션 바 버튼 설정
				UIImage* leftBarBtnImg = nil;
				UIImage* leftBarBtnSelImg = nil;
				UIImage* rightBarBtnImg = nil;
				UIImage* rightBarBtnSelImg = nil;
				
				if (rect.size.width < rect.size.height) {	
					leftBarBtnImg = [UIImage imageNamed:@"btn_top_edit.png"];
					leftBarBtnSelImg = [UIImage imageNamed:@"btn_top_edit_focus.png"];
					rightBarBtnImg = [UIImage imageNamed:@"btn_top_group_add.png"];
					rightBarBtnSelImg = [UIImage imageNamed:@"btn_top_group_add_focus.png"];
				} else {
					leftBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_edit.png"];
					leftBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_edit_focus.png"];
					rightBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_group_add.png"];
					rightBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_group_add_focus.png"];
				}
				
				UIButton* leftBarButton = (UIButton*)[self.navigationItem.leftBarButtonItem customView];
				[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
				[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateSelected];
				leftBarButton = nil;
				
				UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
				[rightBarButton addTarget:self action:@selector(sayButtonClicked) forControlEvents:UIControlEventTouchUpInside];
				[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
				[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
				rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
				self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:rightBarButton] autorelease];
				
				[self.tableView setEditing:NO animated:YES];
			}
		}
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
	} else if (editingStyle == UITableViewCellEditingStyleInsert) {
		// Create a new instance of the appropriate class, insert in into the array, and add a new row to the table view
//		[[[self appDelegate] msgListArray] addObject:[[NSMutableString alloc] initWithFormat:@"it's new"]];
//		[tableView reloadData];
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath
{
	return UITableViewCellEditingStyleDelete;
}

#pragma mark -
#pragma mark UISearchDisplayController delegate
-(BOOL) searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{	
	[self.msgSearchArray removeAllObjects];
	if ([searchString length] > 0) {
		int nSearchType = -1;
		NSInteger code = [searchString characterAtIndex:0];

		if (code >= HANGUL_BEGIN_UNICODE && code <= HANGUL_END_UNICODE) {
			nSearchType = 0;
		} else if ([self IsHangulChosung:code]) {
			nSearchType = 1;
		} else {
			nSearchType = 2;
		}
		for(CellMsgListData *msgListData in [[self appDelegate] msgListArray]) {
			NSMutableString *nickName = nil;
			for (id key in msgListData.userDataDic) {
				
				MsgUserData *userData = [msgListData.userDataDic objectForKey:key];
				if (nickName != nil && [nickName length] > 0) {
					NSString *temp = [[NSString alloc ] initWithFormat:@",%@", userData.nickName];
					[nickName insertString:temp atIndex:[nickName length]];
					[temp release];
				} else {
					nickName = [NSMutableString stringWithString:userData.nickName];
				}
			}
			
			NSString *searchChosungString = nil, *compareString = nil;
			if ( nickName != nil && [nickName length] < [searchString length]) {
				// skip
			} else {
				if (nSearchType == 0) {
					searchChosungString = [self GetUTF8String:searchString];
					compareString = [self GetUTF8String:nickName];
					NSRange range = [compareString rangeOfString:searchChosungString];
					if (range.location != NSNotFound) {
						[self.msgSearchArray addObject:msgListData];
					} else {
						// skip
					}
				} else if (nSearchType == 1) {
					searchChosungString = [self GetChosungUTF8StringSearchString:searchString];
					compareString = [self GetChosungUTF8String:nickName];
					NSRange range = [compareString rangeOfString:searchChosungString];
					if (range.location != NSNotFound) {
						[self.msgSearchArray addObject:msgListData];
					} else {
						// skip
					}
				} else if (nSearchType == 2) {
					
					//2011.01.11 메모리 릭
					
					// 110124 analyze
					NSRange range;// = NSNotFound;
					range.location = NSNotFound;
					if ([searchString length] > 0 && [nickName length] > 0) {
						range = [nickName rangeOfString:searchString];
					}
					
					if (range.location != NSNotFound) {
						[self.msgSearchArray addObject:msgListData];
					} else {
						// skip
					}
										
					
				} else {
					// skip
				}
			}
		}
	}

	return YES;
}

#pragma mark -
#pragma mark UISearchBarDelegate
// called when keyboard search button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
}

// called when cancel button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
	searchBar.showsCancelButton = YES;
	for(UIView *subView in searchBar.subviews){
		if([subView isKindOfClass:UIButton.class]){
			[(UIButton*)subView setImage:[UIImage imageNamed:@"btn_searchbar_cancel.png"] forState:UIControlStateNormal];
			[(UIButton*)subView setImage:[UIImage imageNamed:@"btn_searchbar_cancel_focus.png"] forState:UIControlStateHighlighted];
			break;
		}
	}
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
	searchBar.showsCancelButton = NO;
}

#pragma mark -
#pragma mark Property
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

-(USayAppAppDelegate *)appDelegate
{
	return (USayAppAppDelegate *)[[UIApplication sharedApplication] delegate];
}



-(void)modifyButtonClicked
{	
	if ([self appDelegate].connectionType == -1) {	// -1:offline mode 0:disconnect 1:Wi-Fi 2:3G
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"오프라인" message:@"현재 네트워크 연결이 불가능한 상태입니다.\nUsay의 모든 기능을 이용하기 위해서는 네트워크 연결이 필요합니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return;
	} else if ([self appDelegate].connectionType == 0) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"3G 또는 Wi-Fi 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0025)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return;
	}
	
	@synchronized([self appDelegate].msgListArray) {
		if ([[self appDelegate].msgListArray count] <= 0) {
			return;
		}
	}

	// sochae 2010.09.10 - UI Position
	//CGRect rect = [MyDeviceClass deviceOrientation];
	CGRect rect = [[UIScreen mainScreen] applicationFrame];
	// ~sochae

	if(self.tableView.editing == NO) {
		UIImage* leftBarBtnImg = nil;
		UIImage* leftBarBtnSelImg = nil;
		
		if (rect.size.width < rect.size.height) {
			leftBarBtnImg = [UIImage imageNamed:@"btn_top_complete.png"];
			leftBarBtnSelImg = [UIImage imageNamed:@"btn_top_complete_focus.png"];
		} else {
			leftBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_complete.png"];
			leftBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_complete_focus.png"];
		}
		
		self.navigationItem.rightBarButtonItem = NULL;
		
		UIButton* leftBarButton = (UIButton*)[self.navigationItem.leftBarButtonItem customView];
		[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
		[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateSelected];
		leftBarButton = nil;
		
		[self.tableView setEditing:YES animated:YES];
	} else {
		UIImage* leftBarBtnImg = nil;
		UIImage* leftBarBtnSelImg = nil;
		UIImage* rightBarBtnImg = nil;
		UIImage* rightBarBtnSelImg = nil;
		
		if (rect.size.width < rect.size.height) {
			leftBarBtnImg = [UIImage imageNamed:@"btn_top_edit.png"];
			leftBarBtnSelImg = [UIImage imageNamed:@"btn_top_edit_focus.png"];
			rightBarBtnImg = [UIImage imageNamed:@"btn_top_group_add.png"];
			rightBarBtnSelImg = [UIImage imageNamed:@"btn_top_group_add_focus.png"];
		} else {
			leftBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_edit.png"];
			leftBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_edit_focus.png"];
			rightBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_group_add.png"];
			rightBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_group_add_focus.png"];
		}
		
		UIButton* leftBarButton = (UIButton*)[self.navigationItem.leftBarButtonItem customView];
		[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
		[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateSelected];
		leftBarButton = nil;
		
		UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[rightBarButton addTarget:self action:@selector(sayButtonClicked) forControlEvents:UIControlEventTouchUpInside];
		[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
		[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
		rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
		
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:rightBarButton] autorelease];		
		[self.tableView setEditing:NO animated:YES];
	}
}
//

-(NSString*) md5:(NSString *)str
{
	const char *cStr = [str UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	
	CC_MD5(cStr, strlen(cStr), result);
	
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
			result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];
	
	//    return [diskCachePath stringByAppendingPathComponent:filename];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	//로그인 시작
	NSLog(@"index = %i", buttonIndex);
	if (buttonIndex == 1) {
		if(LOGINSTART != YES)
		{
			LOGINEND = NO;
			LOGINSTART = YES;
			[[self appDelegate] reLogin];
		}
	}
}
	

-(void)sayButtonClicked
{
	

	[[self appDelegate] checkoffline];
	
	
	//오프라인, 로그인 상태, 주소록 싱크 상태 체크
	if([self appDelegate].connectionType == -1){
		UIAlertView* offlineAlert = [[UIAlertView alloc] initWithTitle:@"오프라인"
															   message:@"현재 네트워크 연결이 불가능한 상태 입니다.\nUsay의 모든 기능을 이용하기 위해서는 네트워크 연결이 필요합니다." 
															  delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
		[offlineAlert show];
		[offlineAlert release];
		return;
		
	}//로그인 중인지 점검
	else if(LOGINEND != YES)
	{
		UIAlertView* offlineAlert = [[UIAlertView alloc] initWithTitle:@""
															   message:@"로그인 중입니다 잠시만 기다려 주세요" 
															  delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
		[offlineAlert show];
		[offlineAlert release];
		return;
	} //로그인이 노티가 왔지만 실패를 했고 또 다시 로그인을 시도 하지 않았을 경우
	else if(LOGINSUCESS != YES && LOGINSTART != YES)
	{
		UIAlertView* offlineAlert = [[UIAlertView alloc] initWithTitle:@"로그인 실패"
															   message:@"재로그인 하시겠습니까?" 
															  delegate:nil cancelButtonTitle:@"취소" otherButtonTitles:@"확인", nil];
		
		offlineAlert.delegate =self;
		[offlineAlert show];
		[offlineAlert release];
		
		return;
		
	}//동기화 중인지 점검
	else if(CHKOFF == YES)
	{
		UIAlertView* offlineAlert = [[UIAlertView alloc] initWithTitle:@""
															   message:@"동기화 중에는 사용할 수 없습니다 잠시후에 이용해 주세요" 
															  delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
		[offlineAlert show];
		[offlineAlert release];
		return;
	}	
	

	
	InviteMsgViewController *inviteMsgViewController = [[InviteMsgViewController alloc] initWithAlreadyUserInfo:nil MsgType:nil];
	inviteMsgViewController.navigationTitle = @"대화 초대";
	inviteMsgViewController.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:inviteMsgViewController animated:NO];
	[inviteMsgViewController release];
}

-(BOOL)IsHangulChosung:(NSInteger)code
{
	for (int i = 0; i < [self.chosungNumArray count]; i++) {
		int nChosungUniCode = [[self.chosungNumArray objectAtIndex:i] intValue];
		if (nChosungUniCode  == code) {
			return YES;
		}
	}
	return NO;
}

-(NSString *)GetUTF8String:(NSString *)str 
{	
	NSString *returnText = @"";
	NSString *choText = @"";
	NSString *jongText = @"";
	
	for (int i=0;i<[str length];i++) {
		
		NSInteger code = [str characterAtIndex:i];
		
		if (code >= HANGUL_BEGIN_UNICODE && code <= HANGUL_END_UNICODE) {
			
			NSInteger baseUniCode = code - HANGUL_BEGIN_UNICODE;
			NSInteger choIndex = (baseUniCode / 21 / 28) % 19;

			if (choIndex == 1) {
				choText = @"ㄱㄱ"; 
			} else if (choIndex == 4) {
				choText = @"ㄷㄷ";
			} else if (choIndex == 8) {
				choText = @"ㅂㅂ";
			} else if (choIndex == 10) {
				choText = @"ㅅㅅ";
			} else if (choIndex == 13) {
				choText = @"ㅈㅈ";
			} else {
				choText = [self.chosungArray objectAtIndex:choIndex];
			}

			NSInteger jungIndex = (baseUniCode / 28) % 21;
			NSInteger jongIndex = baseUniCode % 28;
			if (jongIndex == 2) {			
				jongText = @"ㄱㄱ"; 
			} else if (jongIndex == 3) {	
				jongText = @"ㄱㅅ";
			} else if (jongIndex == 5) {	
				jongText = @"ㄴㅈ";
			} else if (jongIndex == 6) {	
				jongText = @"ㄴㅎ";
			} else if (jongIndex == 9) {	
				jongText = @"ㄹㄱ";
			} else if (jongIndex == 10) {	
				jongText = @"ㄹㅁ";
			} else if (jongIndex == 11) {	
				jongText = @"ㄹㅂ";
			} else if (jongIndex == 12) {	
				jongText = @"ㄹㅅ";
			} else if (jongIndex == 13) {	
				jongText = @"ㄹㅌ";
			} else if (jongIndex == 14) {	
				jongText = @"ㄹㅍ";
			} else if (jongIndex == 15) {	
				jongText = @"ㄹㅎ";
			} else if (jongIndex == 18) {	
				jongText = @"ㅂㅅ";
			} else if (jongIndex == 20) {	
				jongText = @"ㅅㅅ";
			} else {
				jongText = [self.jongsungArray objectAtIndex:jongIndex];
			}
			returnText = [NSString stringWithFormat:@"%@%@%@%@", returnText, choText, [self.jungsungArray objectAtIndex:jungIndex], jongText];
		} else {
			returnText = [NSString stringWithFormat:@"%@%@", returnText, [[str substringFromIndex:i] substringToIndex:1]];
		}
	}

	return returnText;
}

-(NSString *)GetChosungUTF8String:(NSString *)str
{
	NSString *returnText = @"";
	NSString *choText = @"";
	
	for (int i=0;i<[str length];i++) {
		
		NSInteger code = [str characterAtIndex:i];
		
		if (code >= HANGUL_BEGIN_UNICODE && code <= HANGUL_END_UNICODE) {
			NSInteger baseUniCode = code - HANGUL_BEGIN_UNICODE;
			NSInteger choIndex = (baseUniCode / 21 / 28) % 19;
			if (choIndex == 1) {		
				choText = @"ㄱㄱ"; 
			} else if (choIndex == 4) {	
				choText = @"ㄷㄷ";
			} else if (choIndex == 8) {	
				choText = @"ㅂㅂ";
			} else if (choIndex == 10) {
				choText = @"ㅅㅅ";
			} else if (choIndex == 13) {
				choText = @"ㅈㅈ";
			} else {
				choText = [self.chosungArray objectAtIndex:choIndex];
			}
			returnText = [NSString stringWithFormat:@"%@%@", returnText, choText];
		} else if ([self IsHangulChosung:code]) {
			if (code == 12594) {		
				choText = @"ㄱㄱ"; 
			} else if (code == 12600) {	
				choText = @"ㄷㄷ";
			} else if (code == 12611) {	
				choText = @"ㅂㅂ";
			} else if (code == 12614) {	
				choText = @"ㅅㅅ";
			} else if (code == 12617) {	
				choText = @"ㅈㅈ";
			} else {
				for (int i = 0; i < [self.chosungNumArray count]; i++) {
					int nChosungUniCode = [[self.chosungNumArray objectAtIndex:i] intValue];
					if (nChosungUniCode == code) {
						choText = [self.chosungArray objectAtIndex:i];
						break;
					}
				}
			}
			returnText = [NSString stringWithFormat:@"%@%@", returnText, choText];
		} else {
			returnText = [NSString stringWithFormat:@"%@%@", returnText, [[str substringFromIndex:i] substringToIndex:1]];
		}
	}

	return returnText;
}

-(NSString *)GetChosungUTF8StringSearchString:(NSString *)str
{
	NSString *returnText = @"";
	NSString *choText = @"";
	
	for (int i=0;i<[str length];i++) {
		
		NSInteger code = [str characterAtIndex:i];
		
		if ([self IsHangulChosung:code]) {
			if (code == 12594) {		
				choText = @"ㄱㄱ"; 
			} else if (code == 12600) {	
				choText = @"ㄷㄷ";
			} else if (code == 12611) {	
				choText = @"ㅂㅂ";
			} else if (code == 12614) {	
				choText = @"ㅅㅅ";
			} else if (code == 12617) {	
				choText = @"ㅈㅈ";
			} else {
				for (int i = 0; i < [self.chosungNumArray count]; i++) {
					int nChosungUniCode = [[self.chosungNumArray objectAtIndex:i] intValue];
					if (nChosungUniCode == code) {
						choText = [self.chosungArray objectAtIndex:i];
						break;
					}
				}
			}
			returnText = [NSString stringWithFormat:@"%@%@", returnText, choText];
		} else {
			returnText = [NSString stringWithFormat:@"%@%@", returnText, [[str substringFromIndex:i] substringToIndex:1]];
		}
	}
	
	return returnText;
}

#pragma mark -
#pragma mark Initialize

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
 //   return (interfaceOrientation == UIInterfaceOrientationPortrait);
//	NSLog(@"MessageViewController shouldAutorotateToInterfaceOrientation");
	return NO;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	NSLog(@"fadfas");
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

	// sochae 2010.09.10 - UI Position
	//CGRect rect = [MyDeviceClass deviceOrientation];
	CGRect rect = [[UIScreen mainScreen] applicationFrame];
	// ~sochae
	
	if(self.tableView.editing == YES) {
				
		//내비게이션 바 버튼 설정
		UIImage* leftBarBtnImg = nil;
		UIImage* leftBarBtnSelImg = nil;
		
		if (rect.size.width < rect.size.height) {
			leftBarBtnImg = [UIImage imageNamed:@"btn_top_complete.png"];
			leftBarBtnSelImg = [UIImage imageNamed:@"btn_top_complete_focus.png"];
		} else {
			leftBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_complete.png"];
			leftBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_complete_focus.png"];
		}
		UIButton* leftBarButton = (UIButton*)[self.navigationItem.leftBarButtonItem customView];
		[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
		[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateSelected];
		leftBarButton = nil;

		self.navigationItem.rightBarButtonItem = nil;
		
	} else {
		UIImage* leftBarBtnImg = nil;
		UIImage* leftBarBtnSelImg = nil;
		UIImage* rightBarBtnImg = nil;
		UIImage* rightBarBtnSelImg = nil;
		
		if (rect.size.width < rect.size.height) {
			leftBarBtnImg = [UIImage imageNamed:@"btn_top_edit.png"];
			leftBarBtnSelImg = [UIImage imageNamed:@"btn_top_edit_focus.png"];
			rightBarBtnImg = [UIImage imageNamed:@"btn_top_group_add.png"];
			rightBarBtnSelImg = [UIImage imageNamed:@"btn_top_group_add_focus.png"];
		} else {
			leftBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_edit.png"];
			leftBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_edit_focus.png"];
			rightBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_group_add.png"];
			rightBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_group_add_focus.png"];
		}
		UIButton* leftBarButton = (UIButton*)[self.navigationItem.leftBarButtonItem customView];
		[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
		[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateSelected];
		leftBarButton = nil;
		
		UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[rightBarButton addTarget:self action:@selector(sayButtonClicked) forControlEvents:UIControlEventTouchUpInside];
		[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
		[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
		rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:rightBarButton] autorelease];
	}

	self.searchDisplayController.searchBar.frame = CGRectMake(0, 0, rect.size.width, 45);
	
	UIImage *image = [[UIImage imageNamed: @"img_searchbar.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
    UIImageView *v = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
    [v setImage:image];
    NSArray *subs = self.searchDisplayController.searchBar.subviews;
    for (int i = 0; i < [subs count]; i++) {
        id subv = [self.searchDisplayController.searchBar.subviews objectAtIndex:i];
        if ([subv isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
            [v setFrame:CGRectMake(0, 0, rect.size.width, 45)];
            [self.searchDisplayController.searchBar insertSubview:v atIndex:i];
        }
    }
    [v setNeedsDisplay];
    [v setNeedsLayout];	
	
	[self.tableView reloadData];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
}

//*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	DebugLog(@"\n========== 대화 목록 화면 load ==========>");
	CGRect rect = [[UIScreen mainScreen] applicationFrame];
	
	UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
	UIFont *titleFont = [UIFont systemFontOfSize:20];
	CGSize titleStringSize = [@"대화" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
	UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
	[titleLabel setFont:titleFont];
	titleLabel.textAlignment = UITextAlignmentCenter;
	[titleLabel setTextColor:ColorFromRGB(0x053844)];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	[titleLabel setText:@"대화"];
	[titleView addSubview:titleLabel];
	[titleLabel release];
	self.navigationItem.titleView = titleView;
	[titleView release];
	self.navigationItem.titleView.frame = CGRectMake((self.tableView.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);
	
	//내비게이션 바 버튼 설정
	UIImage* leftBarBtnImg = nil;
	UIImage* leftBarBtnSelImg = nil;
	UIImage* rightBarBtnImg = nil;
	UIImage* rightBarBtnSelImg = nil;
	
	if (rect.size.width < rect.size.height) {
		leftBarBtnImg = [UIImage imageNamed:@"btn_top_edit.png"];
		leftBarBtnSelImg = [UIImage imageNamed:@"btn_top_edit_focus.png"];
		rightBarBtnImg = [UIImage imageNamed:@"btn_top_group_add.png"];
		rightBarBtnSelImg = [UIImage imageNamed:@"btn_top_group_add_focus.png"];
	} else {
		leftBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_edit.png"];
		leftBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_edit_focus.png"];
		rightBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_group_add.png"];
		rightBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_group_add_focus.png"];
	}

	UIButton* leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[leftBarButton addTarget:self action:@selector(modifyButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
	[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateSelected];
	leftBarButton.frame = CGRectMake(0.0, 0.0, leftBarBtnImg.size.width, leftBarBtnImg.size.height);	
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:leftBarButton] autorelease];	
	
	UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[rightBarButton addTarget:self action:@selector(sayButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
	[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
	rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:rightBarButton] autorelease];	

	self.tableView.rowHeight = kCustomRowHeight;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	self.tableView.separatorColor = ColorFromRGB(0xc2c2c3);
	
	self.searchDisplayController.searchResultsTableView.rowHeight = kCustomRowHeight;
	
	self.searchDisplayController.searchBar.placeholder = @"초성 검색";
	
	self.searchDisplayController.searchBar.frame = CGRectMake(0, 0, rect.size.width, 45);
	
	UIImage *image = [[UIImage imageNamed: @"img_searchbar.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
    UIImageView *v = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
    [v setImage:image];
    NSArray *subs = self.searchDisplayController.searchBar.subviews;
    for (int i = 0; i < [subs count]; i++) {
        id subv = [self.searchDisplayController.searchBar.subviews objectAtIndex:i];
        if ([subv isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
            [v setFrame:CGRectMake(0, 0, rect.size.width, 45)];
            [self.searchDisplayController.searchBar insertSubview:v atIndex:i];
        }
    }
    [v setNeedsDisplay];
    [v setNeedsLayout];	
	
	self.msgSearchArray = [[NSMutableArray alloc] init];
	
	self.chosungNumArray = [[NSMutableArray alloc] init];
	[self.chosungNumArray addObject:[NSNumber numberWithInt:12593]];
	[self.chosungNumArray addObject:[NSNumber numberWithInt:12594]];
	[self.chosungNumArray addObject:[NSNumber numberWithInt:12596]];
	[self.chosungNumArray addObject:[NSNumber numberWithInt:12599]];
	[self.chosungNumArray addObject:[NSNumber numberWithInt:12600]];
	[self.chosungNumArray addObject:[NSNumber numberWithInt:12601]];
	[self.chosungNumArray addObject:[NSNumber numberWithInt:12609]];
	[self.chosungNumArray addObject:[NSNumber numberWithInt:12610]];
	[self.chosungNumArray addObject:[NSNumber numberWithInt:12611]];
	[self.chosungNumArray addObject:[NSNumber numberWithInt:12613]];
	[self.chosungNumArray addObject:[NSNumber numberWithInt:12614]];
	[self.chosungNumArray addObject:[NSNumber numberWithInt:12615]];
	[self.chosungNumArray addObject:[NSNumber numberWithInt:12616]];
	[self.chosungNumArray addObject:[NSNumber numberWithInt:12617]];
	[self.chosungNumArray addObject:[NSNumber numberWithInt:12618]];
	[self.chosungNumArray addObject:[NSNumber numberWithInt:12619]];
	[self.chosungNumArray addObject:[NSNumber numberWithInt:12620]];
	[self.chosungNumArray addObject:[NSNumber numberWithInt:12621]];
	[self.chosungNumArray addObject:[NSNumber numberWithInt:12622]];
	
	self.chosungArray = [[NSArray alloc] initWithObjects:@"ㄱ",@"ㄲ",@"ㄴ",@"ㄷ",@"ㄸ",@"ㄹ",@"ㅁ",@"ㅂ",@"ㅃ",@"ㅅ",@"ㅆ",@"ㅇ",@"ㅈ",@"ㅉ",@"ㅊ",@"ㅋ",@"ㅌ",@"ㅍ",@"ㅎ",nil];	
	self.jungsungArray = [[NSArray alloc] initWithObjects:@"ㅏ",@"ㅐ",@"ㅑ",@"ㅒ",@"ㅓ",@"ㅔ",@"ㅕ",@"ㅖ",@"ㅗ",@"ㅘ",@" ㅙ",@"ㅚ",@"ㅛ",@"ㅜ",@"ㅝ",@"ㅞ",@"ㅟ",@"ㅠ",@"ㅡ",@"ㅢ",@"ㅣ",nil];
	self.jongsungArray = [[NSArray alloc] initWithObjects:@"",@"ㄱ",@"ㄲ",@"ㄳ",@"ㄴ",@"ㄵ",@"ㄶ",@"ㄷ",@"ㄹ",@"ㄺ",@"ㄻ",@"ㄼ",@"ㄽ",@"ㄾ",@"ㄿ",@"ㅀ",@"ㅁ",@"ㅂ",@"ㅄ",@"ㅅ",@"ㅆ",@"ㅇ",@"ㅈ",@"ㅊ",@"ㅋ",@" ㅌ",@"ㅍ",@"ㅎ",nil];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMsgList:) name:@"reloadMsgList" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(quitFromChatSession:) name:@"quitFromChatSession" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:@"applicationWillTerminate" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshbadge:) name:@"refreshbadge" object:nil];
	
	
    [super viewDidLoad];
}
//*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.msgSearchArray = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
//	apns_noti_count = 0; 
//	apnsLog(@"[APNS] 테스트 노티 초기화 (%d)", apns_noti_count);
	/*
	if(SMGSUCESS == YES)
	{
		NSLog(@"시스템 메세지 호출 성공");
	}
	else {
		NSLog(@"시스템 메세지 호출 실패 ");
		//실패시 다시 시스템 메세지를 호출해야 하는데 마지막 세션키와 메세지 아이디를 넘긴다..
	}
	*/
	
	
	NSString *sucess = @"select ISSUCESS from _TSystemMessageTable where ISSUCESS=1";
	NSArray *tmp = [SystemMessageTable findWithSql:sucess];
	
	
	
	if([tmp count] > 0)
	{
		NSLog(@"시스템 메세지 호출 성공");
	}
	else
	{
		NSLog(@"시스템 메세지 호출 실패");
		if(LOGINSUCESS == YES)
		{
			NSLog(@"로그인이 성공한 상태에서만 호출해야 함");
			[[self appDelegate] callSysteMsg:5];
		}
	}
	
	
	DebugLog(@"\n========== 대화 목록 화면 view ==========>");
	[JYGanTracker trackPageView:PAGE_TAB_MSG];
	CGRect rect = [[UIScreen mainScreen] applicationFrame];
	
	if(self.tableView.editing == YES) {
		UIImage* leftBarBtnImg = nil;
		UIImage* leftBarBtnSelImg = nil;
		UIImage* rightBarBtnImg = nil;
		UIImage* rightBarBtnSelImg = nil;
		
		if (rect.size.width < rect.size.height) {
			leftBarBtnImg = [UIImage imageNamed:@"btn_top_edit.png"];
			leftBarBtnSelImg = [UIImage imageNamed:@"btn_top_edit_focus.png"];
			rightBarBtnImg = [UIImage imageNamed:@"btn_top_group_add.png"];
			rightBarBtnSelImg = [UIImage imageNamed:@"btn_top_group_add_focus.png"];
		} else {
			leftBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_edit.png"];
			leftBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_edit_focus.png"];
			rightBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_group_add.png"];
			rightBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_group_add_focus.png"];
		}
		UIButton* leftBarButton = (UIButton*)[self.navigationItem.leftBarButtonItem customView];
		[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
		[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateSelected];
		leftBarButton = nil;

		UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[rightBarButton addTarget:self action:@selector(sayButtonClicked) forControlEvents:UIControlEventTouchUpInside];
		[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
		[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
		rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:rightBarButton] autorelease];
		
		[self.tableView setEditing:NO animated:NO];
	} else {
		UIImage* leftBarBtnImg = nil;
		UIImage* leftBarBtnSelImg = nil;
		UIImage* rightBarBtnImg = nil;
		UIImage* rightBarBtnSelImg = nil;
		
		if (rect.size.width < rect.size.height) {
			leftBarBtnImg = [UIImage imageNamed:@"btn_top_edit.png"];
			leftBarBtnSelImg = [UIImage imageNamed:@"btn_top_edit_focus.png"];
			rightBarBtnImg = [UIImage imageNamed:@"btn_top_group_add.png"];
			rightBarBtnSelImg = [UIImage imageNamed:@"btn_top_group_add_focus.png"];
		} else {
			leftBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_edit.png"];
			leftBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_edit_focus.png"];
			rightBarBtnImg = [UIImage imageNamed:@"landscape_btn_top_group_add.png"];
			rightBarBtnSelImg = [UIImage imageNamed:@"landscape_btn_top_group_add_focus.png"];
		}
		UIButton* leftBarButton = (UIButton*)[self.navigationItem.leftBarButtonItem customView];
		[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
		[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateSelected];
		leftBarButton = nil;
		
		UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[rightBarButton addTarget:self action:@selector(sayButtonClicked) forControlEvents:UIControlEventTouchUpInside];
		[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
		[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
		rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:rightBarButton] autorelease];
	}
		
	self.searchDisplayController.searchBar.frame = CGRectMake(0, 0, rect.size.width, 45);
	
	UIImage *image = [[UIImage imageNamed: @"img_searchbar.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
    UIImageView *v = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
    [v setImage:image];
    NSArray *subs = self.searchDisplayController.searchBar.subviews;
    for (int i = 0; i < [subs count]; i++) {
        id subv = [self.searchDisplayController.searchBar.subviews objectAtIndex:i];
        if ([subv isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
            [v setFrame:CGRectMake(0, 0, rect.size.width, 45)];
            [self.searchDisplayController.searchBar insertSubview:v atIndex:i];
        }
    }
    [v setNeedsDisplay];
    [v setNeedsLayout];
	
	NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
	[self.tableView deselectRowAtIndexPath:tableSelection animated:NO];
	[self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{	
	[super viewDidAppear:animated];
}

#pragma mark -
#pragma mark Finalize
- (void)dealloc {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"reloadMsgList" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"quitFromChatSession" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"applicationWillTerminate" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshbadge" object:nil];
	
	
	[self.msgSearchArray release];
	[self.chosungNumArray release];
	[self.chosungArray release];
	[self.jungsungArray release];
	[self.jongsungArray release];
    [super dealloc];
}

@end
