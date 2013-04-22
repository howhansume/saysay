//
//  .m
//  USayApp
//
//  Created by Jong-Sung Park on 10. 5. 18..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "ProposeUserViewController.h"
#import "json.h"
#import "USayAppAppDelegate.h"
#import "CustomCell.h"
#import "USayHttpData.h"
#import "CellUserData.h"
#import "UIImageView+WebCache.h"
#import "openImgViewController.h"
//#import "MyDeviceClass.h"			// sochae 2010.09.11 - UI Position

#define kCustomRowHeight    58.0
#define kCustomRowCount     6
#define ID_TABLEHEADERVIEW  7773

#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
										green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
										blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation ProposeUserViewController

#pragma mark -
#pragma mark View lifecycle

-(id)init 
{
	self = [super init];
	if (self != nil) {
//		exceptionError = NO;
	}
	
	return self;
}




-(void)showImage:(NSString*)cellImage
{
	openImgViewController *tmpImgView  =[[openImgViewController alloc] init];
	
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
	
	[imageView setImageWithURL:[NSURL URLWithString:cellImage]
							placeholderImage:[UIImage imageNamed:@"img_default.png"]];
	
	
	[tmpImgView.view addSubview:imageView];
	
	
	
	
	[self presentModalViewController:tmpImgView animated:NO];
	//[self.navigationController pushViewController:tmpImgView animated:NO];
}

-(USayAppAppDelegate *) appDelegate
{
	return [[UIApplication sharedApplication] delegate];
}

- (void)viewDidLoad {
	UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
	UIFont *titleFont = [UIFont systemFontOfSize:20];
	CGSize titleStringSize = [@"추천친구" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
	UILabel *naviTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
	[naviTitleLabel setFont:titleFont];
	naviTitleLabel.textAlignment = UITextAlignmentCenter;
	[naviTitleLabel setTextColor:ColorFromRGB(0x053844)];
	[naviTitleLabel setBackgroundColor:[UIColor clearColor]];
	[naviTitleLabel setText:@"추천친구"];
	[titleView addSubview:naviTitleLabel];	
	[naviTitleLabel release];
	self.navigationItem.titleView = titleView;
	[titleView release];
	self.navigationItem.titleView.frame = CGRectMake((self.tableView.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);
	
    [super viewDidLoad];

	self.tableView.rowHeight = kCustomRowHeight;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	self.tableView.separatorColor = ColorFromRGB(0xc2c2c3);

	// sochae 2010.09.11 - UI Position
	//CGRect rect = [MyDeviceClass deviceOrientation];
	CGRect rect = self.view.frame; 
	// ~sochae
	
	UIView* tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, 33)];
	tableHeaderView.tag = ID_TABLEHEADERVIEW;

	UIImageView *imageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"TableHeaderViewBG.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:0]];
	//	assert(imageView != nil);
	[tableHeaderView addSubview:imageView];
	[imageView setFrame:CGRectMake(0, 0, rect.size.width, 33)];
	[imageView release];
	
	UILabel *titleLabel = [[UILabel alloc] init];
	titleLabel.textColor = [UIColor colorWithRed:97.0/255.0 green:92.0/255.0 blue:92.0/255.0 alpha:1.0f];
	titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0f];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.textColor = ColorFromRGB(0x61615c);
	titleLabel.text = @"핸드폰 주소록에 등록한 친구들 입니다.";
	[tableHeaderView addSubview:titleLabel];
	titleLabel.frame = CGRectMake(12, 6, 292, 20);
	self.tableView.tableHeaderView = tableHeaderView;
	[titleLabel release];
	[tableHeaderView release];		
}

-(void)viewWillAppear:(BOOL)animated
{
	[self.tableView reloadData];
	[super viewWillAppear:animated];

	// sochae 2010.09.11 - UI Position
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
				imageViewFrame.size.width = rect.size.width;
				((UIImageView*)view).frame = imageViewFrame;
				break;
			}
		}
	}
	
	[self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated 
{
    [super viewDidDisappear:animated];
}

-(void)addAction:(id)sender
{
	if ([self appDelegate].connectionType == -1) {	// -1:offline mode  0:disconnect 1:Wi-Fi 2:3G
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"오프라인" message:@"현재 네트워크 연결이 불가능한 상태입니다.\nUsay의 모든 기능을 이용하기 위해서는 네트워크 연결이 필요합니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return;
	} else if ([self appDelegate].connectionType == 0) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"3G 또는 Wi-Fi 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0031)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return;
	}
	
	if ([sender isKindOfClass:[UIButton class]]) {
		UIButton *addButton = (UIButton*)sender;
		if (addButton) {
			id parentView = [addButton superview];
			if (parentView) {
				id parentParentView = [parentView superview];
				if (parentParentView) {
					if ([parentParentView isKindOfClass:[CustomCell class]]) {
						CustomCell *cell = (CustomCell*)parentParentView;
						if (cell) {
							if (cell.pKey && [cell.pKey length] > 0) {
								NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:
															cell.pKey, @"fPkey",
															[[self appDelegate] getSvcIdx], @"svcidx",
															nil];
								// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
								USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"setFriendFromRecommand" andWithDictionary:bodyObject timeout:10] autorelease];
								[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
								
								for ( CellUserData *userData in [self appDelegate].proposeUserArray ) {
									if(userData && [userData.pkey isEqualToString:cell.pKey]) {
										[[self appDelegate].proposeUserArray removeObject:userData];
										break;
									}
								}
								
								[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[self.tableView indexPathForCell:cell]] withRowAnimation:YES];
								
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
				imageViewFrame.size.width = rect.size.width;
				((UIImageView*)view).frame = imageViewFrame;
				break;
			}
		}
	}
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
	if ([self appDelegate].connectionType == -1) {	// -1:offline mode  0:disconnect 1:Wi-Fi 2:3G
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"오프라인" message:@"현재 네트워크 연결이 불가능한 상태입니다.\nUsay의 모든 기능을 이용하기 위해서는 네트워크 연결이 필요합니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return;
	} else if ([self appDelegate].connectionType == 0) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" message:@"3G 또는 Wi-Fi 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0032)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return;
	}
    if (editingStyle == UITableViewCellEditingStyleDelete) {
				
		@synchronized([self appDelegate].proposeUserArray) {
			// value, key, value, key ...
			NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:
										((CellUserData*)[[self appDelegate].proposeUserArray objectAtIndex:indexPath.row]).pkey, @"fPkey",
										[[self appDelegate] getSvcIdx], @"svcidx",
										nil];
			// 페이지 호출, 통신 완료 후 호출할 델리게이트 셀렉터 설정
			USayHttpData *data = [[[USayHttpData alloc] initWithRequestData:@"deleteRecommendFriend" andWithDictionary:bodyObject timeout:10] autorelease];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
			// Delete the row from the data source
			[[self appDelegate].proposeUserArray removeObjectAtIndex:indexPath.row];
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
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
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/
#pragma mark -
#pragma mark Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	int count = 0;
	@synchronized([self appDelegate].proposeUserArray) {
		count = [[self appDelegate].proposeUserArray count];
	}
	
	return count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"proposeTableIndentifier";
    static NSString *PlaceholderCellIdentifier = @"PlaceholderCell";
	
	// add a placeholder cell while waiting on table data
    NSInteger nodeCount = 0;
	
	@synchronized([self appDelegate].proposeUserArray) {
		nodeCount = (NSInteger)[[self appDelegate].proposeUserArray count];
		if ([[self appDelegate].proposeUserArray count] < indexPath.row) {
			if (nodeCount == 0 && indexPath.row == 0) {
				UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PlaceholderCellIdentifier];
				if (cell == nil) {
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
												   reuseIdentifier:PlaceholderCellIdentifier] autorelease];   
					cell.detailTextLabel.textAlignment = UITextAlignmentCenter;
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
				}
								
				return cell;
			}
		}
		
		
	}
	
    CustomCell *cell = (CustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = (CustomCell *)[[[CustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}

	
	if (nodeCount > 0) {
		// Configure the cell...
		// Set up the cell...
        CellUserData *userData = [[self appDelegate].proposeUserArray objectAtIndex:indexPath.row];
		cell.nickNameLabel.text = userData.nickName;
		cell.statusLabel.text = userData.status;	
		cell.pKey = userData.pkey;
		cell.parentDelegate = self;
		NSLog(@"userData.nickName = %@ pkey = %@", userData.nickName, userData.pkey);
		
		[cell.addButton addTarget:self action:@selector(addAction:) forControlEvents:UIControlEventTouchUpInside];

		if (userData.representPhoto && [userData.representPhoto length] >  0) {
			NSString *photoUrl = [NSString stringWithFormat:@"%@/011", userData.representPhoto];
			NSString *photoUrl2 = [NSString stringWithFormat:@"%@/008", userData.representPhoto];
			cell.photoUrl = photoUrl2;
			[cell.thumbnailImageView setImageWithURL:[NSURL URLWithString:photoUrl]
									placeholderImage:[UIImage imageNamed:@"img_default.png"]];
		} else {
			cell.thumbnailImageView.image = [UIImage imageNamed:@"img_default.png"];
		}
	}
	
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kCustomRowHeight;
}
#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc {
    [super dealloc];
}

@end

