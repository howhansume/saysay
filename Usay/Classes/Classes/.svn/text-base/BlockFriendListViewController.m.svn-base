//
//  BlockFriendListViewController.m
//  USayApp
//
//  Created by 1team on 10. 6. 2..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "BlockFriendListViewController.h"
#import "json.h"
#import "USayAppAppDelegate.h"
#import "BlockUserTableCell.h"
#import "USayHttpData.h"
#import "CellUserData.h"
#import "UIImageView+WebCache.h"
//#import "MyDeviceClass.h"			// sochae 2010.09.11 - UI Position

#define kCustomRowHeight    58.0
#define kCustomRowCount     7
#define ID_TABLEHEADERVIEW  7773

#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
										green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
										blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation BlockFriendListViewController

@synthesize	listData;
//@synthesize imageDownloadsInProgress;
@synthesize isReceive;

-(id)init 
{
	self = [super init];
	
	if (self != nil) {
		listData = nil;
	}
	
	return self;
}

#pragma mark -
#pragma mark NSNotification getBlockedFriendsList, toggleCommStatus-BlockUserCancel response
-(void)getBlockedFriendsList:(NSNotification *)notification
{
	USayHttpData *data = (USayHttpData*)[notification object];
	if (data == nil) {
		// 200 이외의 에러
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0001)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
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
	
	self.isReceive = YES;
	if ([rtcode isEqualToString:@"0"]) {	// success
		NSString *rtType = [dic objectForKey:@"rttype"];
		if ([rtType isEqualToString:@"list"]) {
			// Key and Dictionary as its value type
			NSArray *listArray = [dic objectForKey:@"list"];
			assert(listArray != nil);
			for (int i=0; i < [listArray count]; i++) {
				NSDictionary *listDic = [listArray objectAtIndex:i];
				assert(listDic != nil);
				CellUserData *cellUserData = [[CellUserData alloc] init];
				assert(cellUserData != nil);
				cellUserData.pkey = [listDic objectForKey:@"pKey"];
				cellUserData.usay = [listDic objectForKey:@"usay"];
				cellUserData.familyName = [listDic objectForKey:@"familyName"];
				cellUserData.givenName = [listDic objectForKey:@"givenName"];
				cellUserData.formatted = [listDic objectForKey:@"formatted"];			// 이름
				cellUserData.nickName = [listDic objectForKey:@"nickName"];
				cellUserData.status = [listDic objectForKey:@"status"];
				cellUserData.representPhoto = [listDic objectForKey:@"representPhoto"]; // 대표사진
				[listData addObject:cellUserData];
				[cellUserData release];
			}
			if (listData && [listData count] > 0) {
				NSSortDescriptor *formattedSort = [[[NSSortDescriptor alloc] initWithKey:@"formatted" ascending:YES] autorelease];
				NSSortDescriptor *nickNameSort = [[[NSSortDescriptor alloc] initWithKey:@"nickName" ascending:YES] autorelease];
				if (formattedSort && nickNameSort) {
					[listData sortUsingDescriptors:[NSArray arrayWithObjects:formattedSort, nickNameSort, nil]];
				}
			}
		} else if ([rtType isEqualToString:@"only"]) {
	
		} else {
			// 예외처리
		}
	} else if ([rtcode isEqualToString:@"4040"]) {
		// 친구 정보를 찾을 수 없음
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e4040)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else if ([rtcode isEqualToString:@"-9030"]) {
		// 처리 오류
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-9030)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else if ([rtcode isEqualToString:@"-9020"]) {
		// 잘못된 인자가 넘어옴
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e-9020)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	} else {
		// 실패 예외처리 필요
		// fail (-8080 이외 기타오류)
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0002)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	}
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	int count = [listData count];
	
	if ([self appDelegate].connectionType == -1) {	// -1:offline mode  0:disconnect 1:Wi-Fi 2:3G
	} else if ([self appDelegate].connectionType == 0) {
	} else {
		if (count == 0 && self.isReceive == NO) {
			return 1;
		}
	}

	return count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"blockFriendListTableIndentifier";
    static NSString *PlaceholderCellIdentifier = @"PlaceholderCell";
    
    // add a placeholder cell while waiting on table data
    int nodeCount = [self.listData count];
	
	if (nodeCount == 0 && indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PlaceholderCellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
										   reuseIdentifier:PlaceholderCellIdentifier] autorelease];   
            cell.detailTextLabel.textAlignment = UITextAlignmentCenter;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
		
		cell.detailTextLabel.text = @"Loading…";
		
		return cell;
    }
    
    // Configure the cell...
	BlockUserTableCell *cell = (BlockUserTableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = (BlockUserTableCell *)[[[BlockUserTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	if (nodeCount > 0) {
		// Configure the cell...
		// Set up the cell...
        CellUserData *userData = [self.listData objectAtIndex:indexPath.row];
		cell.nickNameLabel.text = userData.nickName;
		cell.statusLabel.text = userData.status;
		cell.parentDelegate = self;
		cell.pKey = userData.pkey;
		[cell.clearButton addTarget:self action:@selector(clearAction:) forControlEvents:UIControlEventTouchUpInside];

		if (userData.representPhoto  && [userData.representPhoto length] >  0) {
			NSString *photoUrl = [NSString stringWithFormat:@"%@/011", userData.representPhoto];
			[cell.thumbnailImageView setImageWithURL:[NSURL URLWithString:photoUrl]
														placeholderImage:[UIImage imageNamed:@"img_default.png"]];
		} else {
			cell.thumbnailImageView.image = [UIImage imageNamed:@"img_default.png"];
		}

	}
	
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kCustomRowHeight;
}
#pragma mark -

-(USayAppAppDelegate *) appDelegate
{
	return [[UIApplication sharedApplication] delegate];
}

-(void)backBarButtonClicked 
{
	[self.navigationController popViewControllerAnimated:YES];
}

//*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
	UIFont *titleFont = [UIFont systemFontOfSize:20];
	CGSize titleStringSize = [@"차단친구 목록" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
	UILabel *naviTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
	[naviTitleLabel setFont:titleFont];
	naviTitleLabel.textAlignment = UITextAlignmentCenter;
	[naviTitleLabel setTextColor:ColorFromRGB(0x053844)];
	[naviTitleLabel setBackgroundColor:[UIColor clearColor]];
	[naviTitleLabel setText:@"차단친구 목록"];
	[titleView addSubview:naviTitleLabel];			
	[naviTitleLabel release];
	self.navigationItem.titleView = titleView;
	[titleView release];
	self.navigationItem.titleView.frame = CGRectMake((self.tableView.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);

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
	
	self.isReceive = NO;
	self.tableView.rowHeight = kCustomRowHeight;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	self.tableView.separatorColor = ColorFromRGB(0xc2c2c3);
		
	listData = [[NSMutableArray alloc] initWithCapacity:10];
	
	UIView* tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, 33)];
	tableHeaderView.tag = ID_TABLEHEADERVIEW;
	
	UIImageView *imageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"TableHeaderViewBG.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:0]];
	[tableHeaderView addSubview:imageView];
	[imageView setFrame:CGRectMake(0, 0, rect.size.width, 33)];
	[imageView release];
	
	UILabel *titleLabel = [[UILabel alloc] init];
	titleLabel.textColor = [UIColor colorWithRed:97.0/255.0 green:92.0/255.0 blue:92.0/255.0 alpha:1.0f];
	titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0f];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.text = @"차단된 친구와 대화/파일전송을 할 수 없습니다."; // @"차단된 친구와 대화/쪽지/파일전송을 할 수 없습니다.";
	titleLabel.textColor = ColorFromRGB(0x61615c);
	[tableHeaderView addSubview:titleLabel];
	titleLabel.frame = CGRectMake(12, 6, 292, 20);
	self.tableView.tableHeaderView = tableHeaderView;
	[titleLabel release];
	[tableHeaderView release];
	
	if ([self appDelegate].connectionType == -1) {	// -1:offline mode  0:disconnect 1:Wi-Fi 2:3G
	} else if ([self appDelegate].connectionType == 0) {
	} else {
		// 노티피케이션처리관련 등록..
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getBlockedFriendsList:) name:@"getBlockedFriendsList" object:nil];
		
		// 차단 친구 프로필 리스트 가져오기 프로토콜
		// value, key, value, key ...
		NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:
									[[self appDelegate] getSvcIdx], @"svcidx",
									nil];
		// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
		USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"getBlockedFriendsList" andWithDictionary:bodyObject timeout:10] autorelease];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
	}
	
	[super viewDidLoad];
}
//*/

- (void)viewDidDisappear:(BOOL)animated 
{
    [super viewDidDisappear:animated];
}

-(void)clearAction:(id)sender
{
	if ([self appDelegate].connectionType == -1) {	// -1:offline mode  0:disconnect 1:Wi-Fi 2:3G
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"오프라인" message:@"현재 네트워크 연결이 불가능한 상태입니다.\nUsay의 모든 기능을 이용하기 위해서는 네트워크 연결이 필요합니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return;
	} else if ([self appDelegate].connectionType == 0) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"3G 또는 Wi-Fi 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0003)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return;
	}
	if ([sender isKindOfClass:[UIButton class]]) {
		UIButton *clearButton = (UIButton*)sender;
		if (clearButton) {
			id parentView = [clearButton superview];
			if (parentView) {
				id parentParentView = [parentView superview];
				if (parentParentView) {
					if ([parentParentView isKindOfClass:[BlockUserTableCell class]]) {
						BlockUserTableCell *cell = (BlockUserTableCell*)parentParentView;
						if (cell) {
							if (cell.pKey && [cell.pKey length] > 0) {
								NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:
															cell.pKey, @"fPkey",
															@"normal", @"commStatus",
															[[self appDelegate] getSvcIdx], @"svcidx",
															nil];
								// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
								USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"toggleCommStatus" andWithDictionary:bodyObject timeout:10] autorelease];
								data.subApi = @"BlockUserCancel";
								[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
								for (CellUserData *userData in listData) {
									if(userData && [userData.pkey isEqualToString:cell.pKey]) {
										[listData removeObject:userData];
										break;
									}
								}
								[self.tableView beginUpdates];
								[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[self.tableView indexPathForCell:cell]] withRowAnimation:YES];
								[self.tableView endUpdates];
								NSInteger nCount = [[self appDelegate].proposeUserArray count];
								if (nCount == 0) {
									UITabBarItem *tbi = [[self appDelegate].rootController.tabBar.items objectAtIndex:3]; //기존 2->3로
									if (tbi) {
										tbi.badgeValue = nil;
									}
								} else if (nCount > 0) {
									UITabBarItem *tbi = [[self appDelegate].rootController.tabBar.items objectAtIndex:3]; //기존 2->3로
									if (tbi) {
										tbi.badgeValue = [NSString stringWithFormat:@"%i", nCount];
									}
								} else {
									// skip
								}
							}
						}
					}
				}
			}
		}
	}
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

	// sochae 2010.09.11 - UI Position
	//CGRect rect = [MyDeviceClass deviceOrientation];
	CGRect rect = self.view.frame;
	// ~sochae
	
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
	
	UIView *tableHeaderView = (UIView *)[self.view viewWithTag:ID_TABLEHEADERVIEW];
	if (tableHeaderView) {
		CGRect tableHeaderViewFrame = tableHeaderView.frame;
		tableHeaderViewFrame.size.width = rect.size.width;
		tableHeaderView.frame = tableHeaderViewFrame;
		for (UIView *view in tableHeaderView.subviews) {
			if ( [view isKindOfClass:[UIImageView class]] ) {
				CGRect imageViewFrame = ((UIImageView*)view).frame;
				imageViewFrame.size.width = rect.size.width;
				((UIImageView*)view).frame = imageViewFrame;
				break;
			}
		}
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

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"getBlockedFriendsList" object:nil];
	if (listData) {
		[listData release];
		listData = nil;
	}
	
    [super dealloc];
}

@end
