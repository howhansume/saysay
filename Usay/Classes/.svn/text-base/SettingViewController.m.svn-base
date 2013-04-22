//
//  SettingViewController.m
//  USayApp
//
//  Created by 1team on 10. 5. 31..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "SettingViewController.h"
#import "USayAppAppDelegate.h"
#import "ProfileSettingViewController.h"
#import "WebViewController.h"
#import "UseGuideViewController.h"
#import "NotiSettingViewController.h"
#import "BlockFriendListViewController.h"
#import "AboutViewController.h"
#import "synchronizationViewController.h"
//#import "MyDeviceClass.h"		// sochae 2010.09.10 - UI Position 
#import "JSON.h"
#import "HttpAgent.h"
#import "USayHttpData.h"
#import "LoginViewController.h"
#import "blockView.h"
#import "USayDefine.h"
#import "webjoinViewController.h"
//동기화 페이지 추가.. 2010.10.28
#import "synchronizationViewController.h"

//동기화 설명 페이지 추가 2010.01.25
#import "SyncExplanViewController.h"
#import "JYGanTracker.h"

#define kFilename @"usay.sqlite"
#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
										green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
										blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define ID_TABLEHEADERVIEW	7000

extern BOOL LOGINSUCESS;

@implementation SettingViewController

@synthesize settingSectionNameArray;
@synthesize settingSection1Array;
@synthesize settingSection2Array;
@synthesize settingSection3Array;
@synthesize settingSection4Array;
@synthesize settingSection5Array;
@synthesize flag;

#pragma mark -
#pragma mark Table view methods
//*


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [[self settingSectionNameArray] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (section == 0) {			// 프로필 설정
		return [[self settingSection1Array] count];
	} else if (section == 1) {	// 가이드 
		return [[self settingSection2Array] count];
	} else if (section == 2) {	// 알림 & 차단 목록
		return [[self settingSection3Array] count];
	} else if (section == 3) {	// 동기화
		return [[self settingSection4Array] count];
	} else if (section == 4) {	// 주소록 정보
		return [[self settingSection5Array] count];
	}
    return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	if (indexPath.section == 0) {
		cell.textLabel.text = [[self settingSection1Array] objectAtIndex:indexPath.row];
		cell.textLabel.textColor = ColorFromRGB(0x2284ac);
		cell.textLabel.font = [UIFont systemFontOfSize:17];
	} else if (indexPath.section == 1) {
		cell.textLabel.text = [[self settingSection2Array] objectAtIndex:indexPath.row];
		cell.textLabel.textColor = ColorFromRGB(0x2284ac);
		cell.textLabel.font = [UIFont systemFontOfSize:17];							
	} else if (indexPath.section == 2) {
		cell.textLabel.text = [[self settingSection3Array] objectAtIndex:indexPath.row];
		cell.textLabel.textColor = ColorFromRGB(0x2284ac);
		cell.textLabel.font = [UIFont systemFontOfSize:17];
	} else if (indexPath.section == 3) {
		cell.textLabel.text = [[self settingSection4Array] objectAtIndex:indexPath.row];
		cell.textLabel.textColor = ColorFromRGB(0x2284ac);
		cell.textLabel.font = [UIFont systemFontOfSize:17];
	}else if (indexPath.section == 4) {
		cell.textLabel.text = [[self settingSection5Array] objectAtIndex:indexPath.row];
		cell.textLabel.textColor = ColorFromRGB(0x2284ac);
		cell.textLabel.font = [UIFont systemFontOfSize:17];
	}
	
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;	// UITableViewCellAccessoryDetailDisclosureButton
	
	
	
	
	
    return cell;
}

//*/
#pragma mark -
#pragma mark Table view delegate
// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
/*
	 DetailViewController *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
//*	셀 선택시 처리
	if (indexPath.section == 0)		// 프로필 설정
	{
	
		[self.tableView reloadData];
		if(LOGINSUCESS != YES)
		{
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"네트워크 연결상태가 좋지 않습니다.\n 3G 또는 Wi-Fi의 접속상태를 확인후 \n Usay주소록을 다시 실행해주세요" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
			[alertView show];
			[alertView release];
			return;
		}
		
		ProfileSettingViewController *profileSettingViewController = [[ProfileSettingViewController alloc] initWithNibName:@"ProfileSettingViewController" bundle:nil];
		if(profileSettingViewController != nil) {
			profileSettingViewController.hidesBottomBarWhenPushed = YES;
			[self.navigationController pushViewController:profileSettingViewController animated:YES];
			[profileSettingViewController release];
		}
	}
	else if (indexPath.section == 1 && indexPath.row == 0)	// 공지사항
	{
		// 공지사항
		WebViewController *webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
		if(webViewController != nil) {
			webViewController.hidesBottomBarWhenPushed = YES;
			NSMutableString *url = [[NSMutableString alloc] initWithString:@"http://211.113.17.71/iphone/notice.html"];
			NSMutableString *noti = [[NSMutableString alloc] initWithString:@"공지사항"];
			webViewController.strUrl = url;
			webViewController.strTitle = noti;
			[url release];
			[noti release];
			[self.navigationController pushViewController:webViewController animated:YES];
			[webViewController release];
		}
	}
	else if (indexPath.section == 1 && indexPath.row == 1)	// 도움말
	{
		// 도움말
		WebViewController *webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
		if(webViewController != nil) {
			webViewController.hidesBottomBarWhenPushed = YES;
			NSMutableString *url = [[NSMutableString alloc] initWithString:@"http://211.113.17.71/iphone/list.html"];
			NSMutableString *help = [[NSMutableString alloc] initWithString:@"도움말"];
			webViewController.strUrl = url;
			webViewController.strTitle = help;
			[url release];
			[help release];
			[self.navigationController pushViewController:webViewController animated:YES];
			[webViewController release];
		}
	}
	else if (indexPath.section == 1 && indexPath.row == 2)	// 이용 가이드
	{
//		이용 가이드
		UseGuideViewController *useGuideViewController = [[UseGuideViewController alloc] init];
		if(useGuideViewController != nil) {
			useGuideViewController.hidesBottomBarWhenPushed = YES;
			useGuideViewController.isSetting = YES;
			[self.navigationController pushViewController:useGuideViewController animated:YES];
			[useGuideViewController release];
		}
	}
	else if (indexPath.section == 1 && indexPath.row == 3)	// KTH 다른 App 보기
	{
//		KTH의 다른 Apps 보기
		UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"알림" 
														   message:@"Usay주소록을 종료하고 선택하신 페이지를 보시겠습니까?" 
														  delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"확인", nil];
		[alertView show];
		[alertView release];
	}
	else if (indexPath.section == 2 && indexPath.row == 0)	// 알림 설정
	{
/*		
		NSString *usayID = [[NSUserDefaults standardUserDefaults] objectForKey:@"usayID"];
		NSString *usayPASS = [[NSUserDefaults standardUserDefaults] objectForKey:@"usayPASS"];
		NSString *webKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"webKey"];
		// 아이디 연동
		
		if(usayID && usayPASS && webKey)
		{
		WebViewController *webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
		if(webViewController != nil) {
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
	
		else {
			LoginViewController *loginMain = [[LoginViewController alloc] init];
			loginMain.hidesBottomBarWhenPushed=YES;
			[self.navigationController pushViewController:loginMain animated:YES];	
			[loginMain release];
		}

		
		
		
		
		
	} else if (indexPath.section == 2 && indexPath.row == 1) {
*/		// 알림 설정
		NotiSettingViewController *notiSettingViewController = [[NotiSettingViewController alloc] initWithNibName:@"NotiSettingViewController" bundle:nil];
		if(notiSettingViewController != nil) {
			notiSettingViewController.hidesBottomBarWhenPushed = YES;
			[self.navigationController pushViewController:notiSettingViewController animated:YES];
			[notiSettingViewController release];
		}
	}
	else if (indexPath.section == 2 && indexPath.row == 1)	// 차단친구 목록
	{
		
		[self.tableView reloadData]; 
		if(LOGINSUCESS != YES)
		{
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"네트워크 연결상태가 좋지 않습니다.\n 3G 또는 Wi-Fi의 접속상태를 확인후 \n Usay주소록을 다시 실행해주세요" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
			[alertView show];
			[alertView release];
			return;
		}
		
		// 차단친구 목록
		BlockFriendListViewController *blockFriendListViewController = [[BlockFriendListViewController alloc] initWithNibName:@"BlockFriendListViewController" bundle:nil];
		if(blockFriendListViewController != nil) {
			blockFriendListViewController.hidesBottomBarWhenPushed = YES;
			[self.navigationController pushViewController:blockFriendListViewController animated:YES];
			[blockFriendListViewController release];
		}
	}
	else if(indexPath.section == 3 && indexPath.row == 0)	// Usay 주소록 내보내기
	{
		synchronizationViewController *outputView =[[synchronizationViewController alloc] init];
		outputView.hidesBottomBarWhenPushed= YES;
		outputView.flag = 1;
		[self.navigationController pushViewController:outputView animated:YES];
		[outputView release];
	}
	else if(indexPath.section == 3 && indexPath.row == 1)	// 웹과 동기화
/*	{
		synchronizationViewController *outputView =[[synchronizationViewController alloc] init];
		outputView.hidesBottomBarWhenPushed= YES;
		outputView.flag = 0;
		[self.navigationController pushViewController:outputView animated:YES];
		[outputView release];
	}
	else if(indexPath.section == 4 && indexPath.row == 2)
*/	{
	
	
		
	
	
		NSString *ID =  [[NSUserDefaults standardUserDefaults] objectForKey:@"usayID"];
		NSString *PASS =	[[NSUserDefaults standardUserDefaults] objectForKey:@"usayPASS"];
		
	NSString	*check =	[[NSUserDefaults standardUserDefaults] objectForKey:@"SERVERLOGIN"];
	
		
	
	
	DebugLog(@"ID = %@ PASS = %@", ID, PASS);
	
		if(ID == NULL || PASS == NULL)
		{
			
			
			// 설명 페이지를 보여주고 로그인 페이지로 이동한다..
			SyncExplanViewController *explainView =[[SyncExplanViewController alloc] init];
			explainView.hidesBottomBarWhenPushed =YES;
			
			
			[self.navigationController pushViewController:explainView animated:YES];
			
			// 110126 analyze
			[explainView release];
			
			/* tmp
			LoginViewController *loginMain = [[LoginViewController alloc] init];
			loginMain.hidesBottomBarWhenPushed=YES;
			loginMain.flag=YES;
			[self.navigationController pushViewController:loginMain animated:YES];	
			
			[loginMain release];
			
			
			return;
			*/
			
			/*
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"동기화 오류" 
																message:@"아이디 등록 부터 실행해 주세요" 
															   delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
			[alertView show];
			[alertView release];
			return;
			 */
		}
		else {
			
			
			
			[self.tableView reloadData];
			if(LOGINSUCESS != YES)
			{
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"네트워크 연결상태가 좋지 않습니다.\n 3G 또는 Wi-Fi의 접속상태를 확인후 \n Usay주소록을 다시 실행해주세요" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
				[alertView show];
				[alertView release];
				return;
			}
			
			
			
			if(check != NULL && check != nil)
			{
				/*
				synchronizationViewController *outputView =[[synchronizationViewController alloc] init];
				outputView.hidesBottomBarWhenPushed= YES;
				outputView.flag = 2;
				[self.navigationController pushViewController:outputView animated:YES];
				[outputView release];
				*/
				
				DebugLog(@"이미 연동되어 있다.");
				
			webjoinViewController *alreadyJoinView = [[[webjoinViewController alloc] init] autorelease]; //2010.12.16
			alreadyJoinView.hidesBottomBarWhenPushed=YES;
			[self.navigationController pushViewController:alreadyJoinView animated:YES];
			}
			else {
					
				
				 synchronizationViewController *outputView =[[synchronizationViewController alloc] init];
				 outputView.hidesBottomBarWhenPushed= YES;
				 outputView.flag = 2;
				 [self.navigationController pushViewController:outputView animated:YES];
				 [outputView release];
				 
			}

			
		
		}

		
	}
	else if (indexPath.section == 4 && indexPath.row == 0)	// Usay 주소록 정보
	{
		// Usay 주소록 정보
		AboutViewController *aboutViewController = [[AboutViewController alloc] init];
		if(aboutViewController != nil) {
			aboutViewController.hidesBottomBarWhenPushed = YES;
			[self.navigationController pushViewController:aboutViewController animated:YES];
			[aboutViewController release];
		}
	}
	else
	{
	}
//*/
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
	return 0;
}

#pragma mark -
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		DebugLog(@"alert title %@", alertView.title);
		
		
		
		
		
		
		if([alertView.title isEqualToString:@"회원탈퇴 완료"])
		{
			
		//	NSString *Query;
			if ([HttpAgent mc] == nil || [HttpAgent cs] == nil) {
				
				/*
				Query = [[NSString alloc ] 
						 initWithFormat:@"https://dev.usay.net/KTH/withdrawal.json?svcidx=ucmbip"];
				
				*/
				/*
				NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
				
				[bodyObject setObject:@"ucmbip" forKey:@"svcidx"];
				
				USayHttpData *data = [[[USayHttpData alloc] 
									   initWithRequestData:@"withdrawal" 
									   andWithDictionary:bodyObject timeout:10] autorelease];
				
				[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
				
				//plist 삭제
				
				
				
				[[NSUserDefaults standardUserDefaults] setPersistentDomain:[NSDictionary dictionary]
																   forName:[[NSBundle mainBundle] bundleIdentifier]];

				//*/
			//	NSFileManager *fm =[NSFileManager defaultManager];
				
				
			//	[fm	removeItemAtPath:[self filePath] error:nil];
			//	[fm removeItemAtPath:kFilename error:nil];

				
				
				/*
				if([fm fileExistsAtPath:[self filePath]] == YES)
				{
					NSLog(@"file on");
					
					[fm removeItemAtURL:[self filePath] error:nil];
				}
				
				 */
				
				/*
				// mezzo 로컬 sql 파일 삭제
				NSString *appSqlPath;// = [[NSBundle mainBundle] resourcePath];
				NSFileManager *fileManager = [NSFileManager defaultManager];
				NSString *subFolder = [NSString stringWithFormat:@"Documents/%@", @"usay.sqlite"] ;
				
				appSqlPath = [NSHomeDirectory() stringByAppendingPathComponent:subFolder];
				
				NSLog(@"App sql file is : %@", appSqlPath);
				
				BOOL            result;
				
				result = [fileManager removeItemAtPath:appSqlPath error:nil];
				if (result == YES) {
					NSLog(@"usay.sqlite delete success!!");
				}	
				//*/
				
			}
			
			
			exit(0);
			//여기에서 탈퇴 완료 후 종료.
		}
		NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
		[self.tableView deselectRowAtIndexPath:tableSelection animated:NO];
	} else if (buttonIndex == 1) {	// ok
		NSString* url = [[NSString stringWithFormat:@"%@", [[self appDelegate] protocolUrl:@"otherKTHAppUrl"]]
						 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		if (url && [url length] > 0) {
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
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
		for (UIView *view in tableHeaderView.subviews) {
			if ( [view isKindOfClass:[UIImageView class]] ) {
				CGRect imageViewFrame = ((UIImageView*)view).frame;
				imageViewFrame.origin.x = (rect.size.width-320.0)/2.0;
				((UIImageView*)view).frame = imageViewFrame;
				break;
			}
		}
	}
}

- (USayAppAppDelegate *)appDelegate {
	return (USayAppAppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewWillAppear:(BOOL)animated
{
	
	
	
	[JYGanTracker trackPageView:PAGE_TAB_OPTION];
	
	// sochae 2010.09.10 - UI Position
	//CGRect rect = [MyDeviceClass deviceOrientation];
	CGRect rect = self.view.frame;
	// ~sochae
	
	
	
	
	UIView *tableHeaderView = (UIView *)[self.view viewWithTag:ID_TABLEHEADERVIEW];
	if (tableHeaderView) {
		CGRect tableHeaderViewFrame = tableHeaderView.frame;
		tableHeaderViewFrame.size.width = rect.size.width;
		tableHeaderView.frame = tableHeaderViewFrame;
		for (UIView *view in tableHeaderView.subviews) {
			if ( [view isKindOfClass:[UIImageView class]] ) {
				CGRect imageViewFrame = ((UIImageView*)view).frame;
				imageViewFrame.origin.x = (rect.size.width-320.0)/2.0;
				((UIImageView*)view).frame = imageViewFrame;
				break;
			}
		}
	}

	NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
	[self.tableView deselectRowAtIndexPath:tableSelection animated:NO];
	
	
	
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	DebugLog(@"btn index =%d", buttonIndex);
	
	[[self appDelegate] checkoffline];
	if([self appDelegate].connectionType == -1 || [self appDelegate].connectionType == -2)
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"네트워크 활성 후 실행 해 주세요" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return;
	}
	

	
	
	if(buttonIndex == 0)
	{
		if ([HttpAgent mc] == nil || [HttpAgent cs] == nil) {
			
			/*
			 Query = [[NSString alloc ] 
			 initWithFormat:@"https://dev.usay.net/KTH/withdrawal.json?svcidx=ucmbip"];
			 
			 */
			NSMutableDictionary *bodyObject = [[[NSMutableDictionary alloc] init] autorelease];
			
			[bodyObject setObject:@"ucmbip" forKey:@"svcidx"];
			
			
			
			USayHttpData *data = [[[USayHttpData alloc] 
								   initWithRequestData:@"withdrawal" 
								   andWithDictionary:bodyObject timeout:10] autorelease];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
			
			// TODO: blockView 사용
			settingBlockView = [[blockView alloc] initWithFrame:CGRectMake(0.0, 0.0, 250.0, 150.0)];
			settingBlockView.alertText = @"회원 탈퇴 중...";
			settingBlockView.alertDetailText = @"잠시만 기다려 주세요.";
			[settingBlockView show];
		}
/*		
		UIAlertView *myAlert =[[UIAlertView alloc] 
							   initWithTitle:@"회원탈퇴 완료" 
							   message:@"회원탈퇴 되었습니다. Usay주소록을\n종료합니다." 
							   delegate:self 
							   cancelButtonTitle:@"확인" 
							   otherButtonTitles:nil];
		[myAlert show];
		[myAlert release];
//*/
	}
	
}


// mezzo 회원 탈퇴
-(void)responseWithdrawal:(NSNotification *)notification
{
	NSLog(@"SettingViewController :: responseWithdrawal");
	
	[settingBlockView dismissAlertView];
	[settingBlockView release];

	
	NSString *data = (NSString*)[notification object];
	
	//타임아웃 에러
	if([data isEqualToString:@"-9999"])
	{
		UIAlertView *myAlert =[[UIAlertView alloc] 
							   initWithTitle:@"네트워크 에러" 
							   message:@"네트워크 타임아웃 시간을 \n초과하였습니다.\n3G나 wifi 연결 상태를 \n확인 해주세요." 
							   delegate:self 
							   cancelButtonTitle:@"확인" 
							   otherButtonTitles:nil];
		[myAlert show];
		[myAlert release];
		return;
		
		
	}
	
	if ([data isEqualToString:@"0"]) {			// success
		
		
		//plist 삭제
		[[NSUserDefaults standardUserDefaults] setPersistentDomain:[NSDictionary dictionary]
														   forName:[[NSBundle mainBundle] bundleIdentifier]];
		
		// mezzo 로컬 sql 파일 삭제
		NSString *appSqlPath;// = [[NSBundle mainBundle] resourcePath];
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSString *subFolder = [NSString stringWithFormat:@"Documents/%@", @"usay.sqlite"] ;
		appSqlPath = [NSHomeDirectory() stringByAppendingPathComponent:subFolder];
		DebugLog(@"App sql file is : %@", appSqlPath);
		
		BOOL            result;
		
		result = [fileManager removeItemAtPath:appSqlPath error:nil];
		if (result == YES) {
			DebugLog(@"usay.sqlite delete success!!");
		}	
		
		UIAlertView *myAlert =[[UIAlertView alloc] 
							   initWithTitle:@"회원탈퇴 완료" 
							   message:@"회원탈퇴 되었습니다. Usay주소록을\n종료합니다." 
							   delegate:self 
							   cancelButtonTitle:@"확인" 
							   otherButtonTitles:nil];
		[myAlert show];
		[myAlert release];
		
		//여기에서 탈퇴 완료후 종료.
//		exit(0);
	}
	else {
		UIAlertView *myAlert =[[UIAlertView alloc] 
							   initWithTitle:@"회원탈퇴 실패" 
							   message:@"회원탈퇴를 실패 하였습니다. \n잠시후 다시 이용해 주세요." 
							   delegate:self 
							   cancelButtonTitle:@"확인" 
							   otherButtonTitles:nil];
		[myAlert show];
		[myAlert release];
	}
	
	
	
}

//회원탈퇴
-(void)outAction
{
	
	if(LOGINSUCESS != YES)
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"네트워크 연결상태가 좋지 않습니다.\n 3G 또는 Wi-Fi의 접속상태를 확인후 \n Usay주소록을 다시 실행해주세요" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return;
		
		
	}
	
	UIActionSheet *mySheet = [[UIActionSheet alloc] 
							  initWithTitle:@"회원탈퇴를 하시면 주소록/대화\n데이터가 삭제됩니다."
							  delegate:self
							  cancelButtonTitle:@"취소"
							  destructiveButtonTitle:@"회원탈퇴"
							  otherButtonTitles:nil];
	
	mySheet.actionSheetStyle = UIActionSheetStyleDefault;
	//tabBar 컨트롤러의 하위 뷰일경우, actionsheet의 cancel버튼이 먹질 않는다. 
	//tabbarcontroller뷰의 상단에 보이게 한다.
	[mySheet showInView:self.tabBarController.view];
	[mySheet release];
	
//	mySheet.actionSheetStyle=UIActionSheetStyleAutomatic;
//	[mySheet showInView:self.tableView];
//	[mySheet release];
}

-(void)synchronization
{
	
	synchronizationViewController *_synchronizationViewController = [[[synchronizationViewController alloc] init] autorelease]; //2010.12.16 release
	[self.navigationController pushViewController:_synchronizationViewController animated:YES];
	
		
}

//*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
	UIFont *titleFont = [UIFont systemFontOfSize:20];
	CGSize titleStringSize = [@"설정" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
	UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
	[titleLabel setFont:titleFont];
	titleLabel.textAlignment = UITextAlignmentCenter;
	[titleLabel setTextColor:ColorFromRGB(0x053844)];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	[titleLabel setText:@"설정"];
	[titleView addSubview:titleLabel];	
	[titleLabel release];
	self.navigationItem.titleView = titleView;
	[titleView release];
	self.navigationItem.titleView.frame = CGRectMake((self.tableView.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);
	
	self.view.backgroundColor = ColorFromRGB(0x8fcad9);

	// sochae 2010.09.10 - UI Position
	//CGRect rect = [MyDeviceClass deviceOrientation];
	CGRect rect = self.view.frame;
	// ~sochae

	// Create and set the table header view.

	UIView *tempTableHeaderView = (UIView *)[self.view viewWithTag:ID_TABLEHEADERVIEW];
//	UIView *tempTableFooterView = (UIView *)[self.view viewWithTag:ID_TABLEHEADERVIEW];
		

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseWithdrawal:) name:@"responseWithdrawal" object:nil];
	
	if (tempTableHeaderView == nil) {
		UIView* tableHeaderView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, 70)] autorelease];
		UIView* tableFooterView = [[[UIView alloc] initWithFrame:CGRectMake(0, 25, rect.size.width, 140)] autorelease]; //mezzo 원래 170		
		tableHeaderView.backgroundColor = ColorFromRGB(0xedeff2);
		tableHeaderView.tag = ID_TABLEHEADERVIEW;
		
	
		tableFooterView.backgroundColor = ColorFromRGB(0xedeff2);
		tableFooterView.tag = ID_TABLEHEADERVIEW;
		
		UILabel *outLabel =[[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 60)] autorelease];
		[outLabel setBackgroundColor:[UIColor clearColor]];
		[outLabel setText:@"회원 탈퇴를 하시면 주소록/대화\n데이터가 삭제됩니다."];
		outLabel.textColor=ColorFromRGB(0x656570);
		
		[outLabel setTextAlignment:UITextAlignmentCenter];
	//	[outLabel sizeToFit];
		outLabel.numberOfLines=2;
		
		
		
		UIButton *outButton = [[[UIButton alloc] initWithFrame:CGRectMake((320-148)/2, 60, 148, 38)] autorelease];
		[outButton setImage:[UIImage imageNamed:@"btn_setting_withdrawal.png"] forState:UIControlStateNormal];
		[outButton setImage:[UIImage imageNamed:@"taloff.PNG"] forState:UIControlStateHighlighted];
		[outButton addTarget:self action:@selector(outAction) forControlEvents:UIControlEventTouchUpInside];
		outButton.tag=55;
		
	
		
		[tableFooterView addSubview:outLabel];
		[tableFooterView addSubview:outButton];
		
		
		
		
		
		UIImageView *logoImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_setting.png"]];
		[tableHeaderView addSubview:logoImage];
//		logoImage.frame = CGRectMake((rect.size.width-320.0)/2.0, 0, 320, 70);  // sochae 2010.09.10 - UI Position
		[logoImage release];
		self.tableView.tableHeaderView = tableHeaderView;
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
		self.tableView.separatorColor = ColorFromRGB(0xc2c2c3); 
		self.tableView.backgroundColor = ColorFromRGB(0xedeff2);
		self.tableView.tableFooterView = tableFooterView;
		
		self.settingSectionNameArray = [NSArray arrayWithObjects:@"section1", @"section2", @"section3", @"section4", @"section5", nil];
		self.settingSection1Array = [NSArray arrayWithObjects:@"프로필 설정", nil];
		self.settingSection2Array = [NSArray arrayWithObjects:@"공지사항", @"도움말", @"이용 가이드", @"KTH의 다른 Apps 보기", nil];
		self.settingSection3Array = [NSArray arrayWithObjects:@"알림 설정", @"차단친구 목록", nil];
		self.settingSection4Array = [NSArray arrayWithObjects:DEF_MENU_SYNC,@"웹과 동기화(Usay.net)", nil];
		self.settingSection5Array = [NSArray arrayWithObjects:@"Usay 주소록 정보", nil];
		
		
		
	}
	
	
	
	//임시 동기화 버튼 추가.
	
	/*
	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"동기화" style:UIBarButtonItemStylePlain target:self action:@selector(synchronization)];
	
	self.navigationItem.rightBarButtonItem=rightButton;
	*/
	
	
    [super viewDidLoad];
}
//*/

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {	
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"responseWithdrawal" object:nil];

    [super dealloc];
}

@end