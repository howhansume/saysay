//
//  EditAddressViewController.m
//  USayApp
//
//  Created by Jong-Sung Park on 10. 6. 20..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "EditAddressViewController.h"
#import "USayAppAppDelegate.h"
#import "EditAddressCustomCell.h"
#import "NSArray-NestedArrays.h"
#import "ItemValueDisplay.h"
#import "json.h"
#import "UserInfo.h"
#import "GroupInfo.h"
#import <objc/runtime.h>
#import "USayHttpData.h"
#import "UIImageView+WebCache.h"
#import "CustomHeaderView.h"
#import "blockView.h"
#import "USayDefine.h"

@implementation UIToolbar (CustomImage)
- (void)drawRect:(CGRect)rect {
    UIImage *image = [UIImage imageNamed: @"moveaddr_bg_toolbar.png"];
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}
@end
#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
@implementation EditAddressViewController
@synthesize editAddrChange, buttonToolBar, customPlanTableView, customGroupTableView, allNames, allGroups;
@synthesize statusGroup, peopleInGroup, selectedPerson, editDelegate;

//navigationbar left button event


//메모리 재설정
-(void)reloadAddressData {
	NSLog(@"reload memory");
	[self.allNames removeAllObjects];
	[self.allGroups removeAllObjects];
	
	self.allNames = [NSMutableArray arrayWithArray:[UserInfo findAll]];
	self.allGroups = [NSMutableArray arrayWithArray:[GroupInfo findAll]];
	
	BOOL	bFindUser = FALSE;
	
	NSSortDescriptor *groupNameSort = [[NSSortDescriptor alloc] initWithKey:@"GROUPTITLE" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
	[self.allGroups sortUsingDescriptors:[NSArray arrayWithObject:groupNameSort]];
	[groupNameSort release];
	for(int g=0;g<[self.allGroups count];g++){
		GroupInfo* tempGroup = [self.allGroups objectAtIndex:g];
		GroupInfo* instGroup = [[GroupInfo alloc] init];
		NSAutoreleasePool* varpool = [[NSAutoreleasePool alloc] init];
		unsigned int numIvars = 0;
		Ivar* ivars = class_copyIvarList([instGroup class], &numIvars);
		for(int i = 0; i < numIvars; i++) {
			Ivar thisIvar = ivars[i];
			NSString * classkey = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
			if([tempGroup valueForKey:classkey] && [tempGroup valueForKey:classkey] != nil)
				[instGroup  setValue:[tempGroup valueForKey:classkey] forKey:classkey];
		}
		if(numIvars > 0)free(ivars);
		[varpool release];
		if([tempGroup.ID isEqualToString:@"0"]){
			[self.allGroups removeObject:tempGroup];
			[self.allGroups insertObject:instGroup atIndex:0];
			[instGroup release];
			break;
		}else {
			[instGroup release];
		}
		
	}
	
	//전체 데이터 베이스를 다시 메모리로 로드 한다.
	[self.peopleInGroup removeAllObjects];
	for(GroupInfo* group in self.allGroups){//전체 보기 일 경우
		NSMutableArray* arrayGroup = [NSMutableArray array];
		for(UserInfo* person in allNames){
			if([person.GID isEqualToString:group.ID] && [person.ISBLOCK isEqualToString:@"N"]) {
				[arrayGroup addObject:person];
				bFindUser = TRUE;
			}
		}
		NSSortDescriptor *formattedSort = [[NSSortDescriptor alloc] initWithKey:@"FORMATTED" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
		NSSortDescriptor *nickNameSort = [[NSSortDescriptor alloc] initWithKey:@"PROFILENICKNAME" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
		[arrayGroup sortUsingDescriptors:[NSArray arrayWithObjects:formattedSort,nickNameSort, nil]];
		[nickNameSort release];
		[formattedSort release];
		[self.peopleInGroup setObject:arrayGroup forKey:group.GROUPTITLE];
	}
	
	
	if(self.customPlanTableView.superview != nil)
		[self.customPlanTableView reloadData];
	if(self.customGroupTableView.superview != nil)
		[self.customGroupTableView reloadData];
	
}
	


// index:0 ==> 주소이동 index:1 ==> 주소삭제 index:2 ==> 그룹명 변경 index:3 ==> 그룹 삭제
-(void)editNumber:(NSInteger)index
{
	numberofEdit = index;
	NSLog(@"editumber = %d", numberofEdit);

}

-(void)backBarButtonClicked {
	[self.editDelegate editCompleteAddressInfo];
	[self.navigationController popViewControllerAnimated:YES];
}

-(BOOL)convertBoolValue:(NSString *)boolString {
	if(boolString != nil){
		if([boolString isEqualToString:@"YES"])
			return YES;
		else
			return NO;
	}
	return NO;
}

-(USayAppAppDelegate *)appDelegate
{
	return [[UIApplication sharedApplication] delegate];
}
#pragma mark -
#pragma mark EditAddressGroupMultiSelection delegate Method
-(void)updateMovetoGroup {
	[self.allNames removeAllObjects];
	[self.allGroups removeAllObjects];
	self.allNames = [NSMutableArray arrayWithArray:[UserInfo findAll]];
	self.allGroups = [NSMutableArray arrayWithArray:[GroupInfo findAll]];
	
	NSSortDescriptor *groupNameSort = [[NSSortDescriptor alloc] initWithKey:@"GROUPTITLE" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
	[self.allGroups sortUsingDescriptors:[NSArray arrayWithObject:groupNameSort]];
	[groupNameSort release];
	for(int g=0;g<[self.allGroups count];g++){
		GroupInfo* tempGroup = [self.allGroups objectAtIndex:g];
		GroupInfo* instGroup = [[GroupInfo alloc] init];
		NSAutoreleasePool* varpool = [[NSAutoreleasePool alloc] init];
		unsigned int numIvars = 0;
		Ivar* ivars = class_copyIvarList([instGroup class], &numIvars);
		for(int i = 0; i < numIvars; i++) {
			Ivar thisIvar = ivars[i];
			NSString * classkey = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
			if([tempGroup valueForKey:classkey] && [tempGroup valueForKey:classkey] != nil)
				[instGroup  setValue:[tempGroup valueForKey:classkey] forKey:classkey];
		}
		if(numIvars > 0)free(ivars);
		[varpool release];
		if([tempGroup.ID isEqualToString:@"0"]){
			[self.allGroups removeObject:tempGroup];
			[self.allGroups insertObject:instGroup atIndex:0];
			[instGroup release];
			break;
		}else {
			[instGroup release];
		}
		
	}
	
	[self.peopleInGroup removeAllObjects];
	for(GroupInfo* group in self.allGroups){
		NSMutableArray* arrayGroup = [NSMutableArray array];
		for(UserInfo* person in self.allNames){
			if([person.GID isEqualToString:group.ID]) {
				[arrayGroup addObject:person];
			}
		}
		if(group.GROUPTITLE != nil){
			NSSortDescriptor *formattedSort = [[NSSortDescriptor alloc] initWithKey:@"FORMATTED" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
			NSSortDescriptor *nickNameSort = [[NSSortDescriptor alloc] initWithKey:@"PROFILENICKNAME" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
			[arrayGroup sortUsingDescriptors:[NSArray arrayWithObjects:formattedSort,nickNameSort, nil]];
			[nickNameSort release];
			[formattedSort release];
			[peopleInGroup setObject:arrayGroup forKey:group.GROUPTITLE];
		}
	}
	
}

-(void)createGroupInMove {
	[self.allNames removeAllObjects];
	[self.allGroups removeAllObjects];
	self.allNames = [NSMutableArray arrayWithArray:[UserInfo findAll]];
	self.allGroups = [NSMutableArray arrayWithArray:[GroupInfo findAll]];
	
	NSSortDescriptor *groupNameSort = [[NSSortDescriptor alloc] initWithKey:@"GROUPTITLE" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
	[self.allGroups sortUsingDescriptors:[NSArray arrayWithObject:groupNameSort]];
	[groupNameSort release];
	for(int g=0;g<[self.allGroups count];g++){
		GroupInfo* tempGroup = [self.allGroups objectAtIndex:g];
		GroupInfo* instGroup = [[GroupInfo alloc] init];
		NSAutoreleasePool* varpool = [[NSAutoreleasePool alloc] init];
		unsigned int numIvars = 0;
		Ivar* ivars = class_copyIvarList([instGroup class], &numIvars);
		for(int i = 0; i < numIvars; i++) {
			Ivar thisIvar = ivars[i];
			NSString * classkey = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
			if([tempGroup valueForKey:classkey] && [tempGroup valueForKey:classkey] != nil)
				[instGroup  setValue:[tempGroup valueForKey:classkey] forKey:classkey];
		}
		if(numIvars > 0)free(ivars);
		[varpool release];
		if([tempGroup.ID isEqualToString:@"0"]){
			[self.allGroups removeObject:tempGroup];
			[self.allGroups insertObject:instGroup atIndex:0];
			[instGroup release];
			break;
		}else {
			[instGroup release];
		}
		
	}
	
	[self.peopleInGroup removeAllObjects];
	for(GroupInfo* group in self.allGroups){
		NSMutableArray* arrayGroup = [NSMutableArray array];
		for(UserInfo* person in self.allNames){
			if([person.GID isEqualToString:group.ID]) {
				[arrayGroup addObject:person];
			}
		}
		if(group.GROUPTITLE != nil){
			NSSortDescriptor *formattedSort = [[NSSortDescriptor alloc] initWithKey:@"FORMATTED" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
			NSSortDescriptor *nickNameSort = [[NSSortDescriptor alloc] initWithKey:@"PROFILENICKNAME" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
			[arrayGroup sortUsingDescriptors:[NSArray arrayWithObjects:formattedSort,nickNameSort, nil]];
			[nickNameSort release];
			[formattedSort release];
			[peopleInGroup setObject:arrayGroup forKey:group.GROUPTITLE];
		}
	}
	
}

-(void)editGroupDataInfo {
	[self.allNames removeAllObjects];
	[self.allGroups removeAllObjects];
	self.allNames = [NSMutableArray arrayWithArray:[UserInfo findAll]];
	self.allGroups = [NSMutableArray arrayWithArray:[GroupInfo findAll]];	
	NSSortDescriptor *groupNameSort = [[NSSortDescriptor alloc] initWithKey:@"GROUPTITLE" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
	[self.allGroups sortUsingDescriptors:[NSArray arrayWithObject:groupNameSort]];
	[groupNameSort release];
	for(int g=0;g<[self.allGroups count];g++){
		GroupInfo* tempGroup = [self.allGroups objectAtIndex:g];
		GroupInfo* instGroup = [[GroupInfo alloc] init];
		NSAutoreleasePool* varpool = [[NSAutoreleasePool alloc] init];
		unsigned int numIvars = 0;
		Ivar* ivars = class_copyIvarList([instGroup class], &numIvars);
		for(int i = 0; i < numIvars; i++) {
			Ivar thisIvar = ivars[i];
			NSString * classkey = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
			if([tempGroup valueForKey:classkey] && [tempGroup valueForKey:classkey] != nil)
				[instGroup  setValue:[tempGroup valueForKey:classkey] forKey:classkey];
		}
		if(numIvars > 0)free(ivars);
		[varpool release];
		if([tempGroup.ID isEqualToString:@"0"]){
			[self.allGroups removeObject:tempGroup];
			[self.allGroups insertObject:instGroup atIndex:0];
			[instGroup release];
			break;
		}else {
			[instGroup release];
		}
		
	}
	
	
	[self.peopleInGroup removeAllObjects];
	for(GroupInfo* group in self.allGroups){
		NSMutableArray* arrayGroup = [NSMutableArray array];
		for(UserInfo* person in self.allNames){
			if([person.GID isEqualToString:group.ID]) {
				[arrayGroup addObject:person];
			}
		}
		if(group.GROUPTITLE != nil){
			NSSortDescriptor *formattedSort = [[NSSortDescriptor alloc] initWithKey:@"FORMATTED" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
			NSSortDescriptor *nickNameSort = [[NSSortDescriptor alloc] initWithKey:@"PROFILENICKNAME" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
			[arrayGroup sortUsingDescriptors:[NSArray arrayWithObjects:formattedSort,nickNameSort, nil]];
			[nickNameSort release];
			[formattedSort release];
			[peopleInGroup setObject:arrayGroup forKey:group.GROUPTITLE];
			
		}
	}
	
}
-(void)updateGroupWithGroupInfo:(GroupInfo*)value {
//	self.allNames = nil;
//	self.allGroups = nil;
	[self.allGroups removeAllObjects];
	[self.allNames removeAllObjects];
	self.allNames = [NSMutableArray arrayWithArray:[UserInfo findAll]];
	self.allGroups = [NSMutableArray arrayWithArray:[GroupInfo findAll]];
	
	NSSortDescriptor *groupNameSort = [[NSSortDescriptor alloc] initWithKey:@"GROUPTITLE" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
	[self.allGroups sortUsingDescriptors:[NSArray arrayWithObject:groupNameSort]];
	[groupNameSort release];
	for(int g=0;g<[self.allGroups count];g++){
		GroupInfo* tempGroup = [self.allGroups objectAtIndex:g];
		GroupInfo* instGroup = [[GroupInfo alloc] init];
		NSAutoreleasePool* varpool = [[NSAutoreleasePool alloc] init];
		unsigned int numIvars = 0;
		Ivar* ivars = class_copyIvarList([instGroup class], &numIvars);
		for(int i = 0; i < numIvars; i++) {
			Ivar thisIvar = ivars[i];
			NSString * classkey = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
			if([tempGroup valueForKey:classkey] && [tempGroup valueForKey:classkey] != nil)
				[instGroup  setValue:[tempGroup valueForKey:classkey] forKey:classkey];
		}
		if(numIvars > 0)free(ivars);
		[varpool release];
		if([tempGroup.ID isEqualToString:@"0"]){
			[self.allGroups removeObject:tempGroup];
			[self.allGroups insertObject:instGroup atIndex:0];
			[instGroup release];
			break;
		}else {
			[instGroup release];
		}
		
	}
	
	[self.peopleInGroup removeAllObjects];
	for(GroupInfo* group in self.allGroups){
		NSMutableArray* arrayGroup = [NSMutableArray array];
		for(UserInfo* person in self.allNames){
			if([person.GID isEqualToString:group.ID]) {
				[arrayGroup addObject:person];
			}
		}
		if(group.GROUPTITLE != nil){
			NSSortDescriptor *formattedSort = [[NSSortDescriptor alloc] initWithKey:@"FORMATTED" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
			NSSortDescriptor *nickNameSort = [[NSSortDescriptor alloc] initWithKey:@"PROFILENICKNAME" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
			[arrayGroup sortUsingDescriptors:[NSArray arrayWithObjects:formattedSort,nickNameSort, nil]];
			[nickNameSort release];
			[formattedSort release];
			[peopleInGroup setObject:arrayGroup forKey:group.GROUPTITLE];
		}
	}
	
}
#pragma mark -
-(void)viewWillAppear:(BOOL)animated{
	
	[self.selectedPerson removeAllObjects];
	/*
	if(self.customPlanTableView.superview != nil)
		[self.customPlanTableView reloadData];
	if(self.customGroupTableView.superview != nil)
		[self.customGroupTableView reloadData];
	
	[super viewWillAppear:animated];
	 */
	[self reloadAddressData];
}

- (void)viewDidLoad {
//	self.title = @"주소 편집";
	
	UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
//	assert(titleView != nil);
	UIFont *titleFont = [UIFont systemFontOfSize:20];
	
	CGSize titleStringSize;
	NSLog(@"didload edit number = %d", numberofEdit);
	if(numberofEdit	 == 0)
	{
		titleStringSize = [@"이동할 주소선택" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
	}
	else if(numberofEdit == 1)
	{
	titleStringSize = [@"주소삭제" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];	
	}
	else if(numberofEdit == 2)
	{
		titleStringSize = [@"그룹 변경" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
	}
	else if(numberofEdit == 3)
	{
		titleStringSize = [@"그룹 삭제" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
	}

		//	assert(titleFont != nil);
	UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
//	assert(titleLabel != nil);
	[titleLabel setFont:titleFont];
	titleLabel.textAlignment = UITextAlignmentCenter;
	[titleLabel setTextColor:ColorFromRGB(0x053844)];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	[titleLabel setText:@"주소 편집"];
//	titleLabel.shadowColor = [UIColor whiteColor];
	[titleView addSubview:titleLabel];	
	[titleLabel release];
	self.navigationItem.titleView = titleView;
	[titleView release];
	self.navigationItem.titleView.frame = CGRectMake((self.view.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);
	
	
    [super viewDidLoad];
	//create custombutton navigationbarleftbutton
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
	
	
	// size up the toolbar and set its frame
	self.buttonToolBar = [UIToolbar new];
	self.buttonToolBar.barStyle = UIBarStyleDefault;
	
	// size up the toolbar and set its frame
	[self.buttonToolBar sizeToFit];
	CGFloat toolbarHeight = (CGFloat)46.0;
	CGRect mainViewBounds = self.view.bounds;
	[self.buttonToolBar setFrame:CGRectMake(CGRectGetMinX(mainViewBounds),
											CGRectGetMinY(mainViewBounds) + CGRectGetHeight(mainViewBounds) - (toolbarHeight * 2.0) + 2.0,
											CGRectGetWidth(mainViewBounds),
											toolbarHeight)];
	self.buttonToolBar.tintColor = [UIColor darkGrayColor];
	[self.view addSubview:self.buttonToolBar];
	
	//버튼생성
	UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			  target:nil
																			  action:nil];
	
	// create a special tab bar item with a custom image and title
	// Create a final modal view controller
	
	/*
	UIImage* leftImage = [UIImage imageNamed:@"btn_del.png"];
	UIImage* leftfocusImage = [UIImage imageNamed:@"btn_del_focus.png"];
	*/
	
	UIImage* leftImage = [UIImage imageNamed:@"del.PNG"];
	UIImage* leftfocusImage = [UIImage imageNamed:@"del.PNG"];
	
	
	UIButton* modalleftViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[modalleftViewButton addTarget:self action:@selector(leftButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[modalleftViewButton setImage:[leftImage stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] forState:UIControlStateNormal];
	[modalleftViewButton setImage:[leftfocusImage stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
	modalleftViewButton.frame = CGRectMake(0.0, 0.0, leftImage.size.width, leftImage.size.height);	
	UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:modalleftViewButton];
	
	// create a bordered style button with custom title
	/*
	UIImage* rightImage = [UIImage imageNamed:@"btn_move.png"];
	UIImage* rightfocusImage = [UIImage imageNamed:@"btn_move_focus.png"];
	*/
	
	UIImage* rightImage = [UIImage imageNamed:@"move.png"];
	UIImage* rightfocusImage = [UIImage imageNamed:@"move.png"];
	
	UIButton* modalrightViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[modalrightViewButton addTarget:self action:@selector(rightButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[modalrightViewButton setImage:[rightImage stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] forState:UIControlStateNormal];
	[modalrightViewButton setImage:[rightfocusImage stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
	modalrightViewButton.frame = CGRectMake(0.0, 0.0, rightImage.size.width, rightImage.size.height);	
	UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:modalrightViewButton];
	
	
	NSArray *items;
	if(numberofEdit == 0)
	{
		items= [NSArray arrayWithObjects:flexItem, /*leftButtonItem,*/ rightButtonItem,flexItem,  nil];
		[self.buttonToolBar setItems:items animated:NO];
		
	}
		else if(numberofEdit == 1)
		{
			items= [NSArray arrayWithObjects:flexItem, leftButtonItem,flexItem,  nil];
			[self.buttonToolBar setItems:items animated:NO];
			
		}
	
//	[modalleftViewButton release];
//	[modalrightViewButton release];
	[flexItem release];
	[leftButtonItem release];
	[rightButtonItem release];
	
	[self createArgumentDetailController];
	self.peopleInGroup = [[NSMutableDictionary alloc] init];
	self.selectedPerson = [[NSMutableArray alloc] init];
	self.statusGroup = [[NSMutableDictionary alloc] init];
	
//	[self.editAddrChange setTitle:@"주소 편집" forSegmentAtIndex:0];
//	[self.editAddrChange setTitle:@"그룹 편집" forSegmentAtIndex:1];
	// TODO: 세그먼트 이미지  설정
	CGRect segRect = self.editAddrChange.frame;
	segRect.size.height = 26.0f;
	segRect.size.width -= 10.0f;
	[self.editAddrChange setFrame:segRect];
	[self.editAddrChange setImage:[[UIImage imageNamed:@"btn_addr_edit_focus.png"]stretchableImageWithLeftCapWidth:1.0 topCapHeight:0.0] forSegmentAtIndex:0];
	[self.editAddrChange setImage:[[UIImage imageNamed:@"btn_group_edit_normal.png"]stretchableImageWithLeftCapWidth:1.0 topCapHeight:0.0] forSegmentAtIndex:1];
	
	[self.editAddrChange addTarget:self action:@selector(segmentedControl:) forControlEvents:UIControlEventValueChanged];
	[self editData:numberofEdit];
	//[self.editAddrChange sendActionsForControlEvents:UIControlEventValueChanged];

//	[self.editAddrChange setSelectedSegmentIndex:0];
//	[self.editAddrChange sendActionsForControlEvents:UIControlEventValueChanged];
	
	
	[self.view setBackgroundColor:ColorFromRGB(0xedeff2)];
	
	
}

-(void)createArgumentDetailController {
/*	
    rowArguments = [[NSArray alloc] initWithObjects:
                    [NSArray arrayWithObjects:
					 [NSDictionary dictionaryWithObject:self.allGroups forKey:@"list"], nil],
					nil];
*/	
	
}



-(void)editData:(NSInteger)sender
{

		CGRect viewBounds = [[UIScreen mainScreen]applicationFrame];
		viewBounds.origin.y = 44.0;
		
		//if([sender selectedSegmentIndex] == 0){
		if(sender == 0){
			self.title=@"주소 편집";
			// TODO: 세그먼크 이미지 교체
			[self.editAddrChange setImage:[[UIImage imageNamed:@"btn_addr_edit_focus.png"]stretchableImageWithLeftCapWidth:1.0 topCapHeight:0.0] forSegmentAtIndex:0];
			[self.editAddrChange setImage:[[UIImage imageNamed:@"btn_group_edit_normal.png"]stretchableImageWithLeftCapWidth:1.0 topCapHeight:0.0] forSegmentAtIndex:1];
			
			UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
			//		assert(titleView != nil);
			UIFont *titleFont = [UIFont systemFontOfSize:20];
			CGSize titleStringSize = [@"이동할 주소선택" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
			//		assert(titleFont != nil);
			UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
			//		assert(titleLabel != nil);
			[titleLabel setFont:titleFont];
			titleLabel.textAlignment = UITextAlignmentCenter;
			[titleLabel setTextColor:ColorFromRGB(0x053844)];
			[titleLabel setBackgroundColor:[UIColor clearColor]];
			[titleLabel setText:@"이동할 주소선택"];
			//		titleLabel.shadowColor = [UIColor whiteColor];
			[titleView addSubview:titleLabel];	
			[titleLabel release];
			self.navigationItem.titleView = titleView;
			[titleView release];
			self.navigationItem.titleView.frame = CGRectMake((self.view.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);
			
			
			if(self.customPlanTableView == nil){
				viewBounds.size.height -= 134.0-44;
				viewBounds.origin.y -= 44; //테이블 사이즈.
				UITableView *planTableView = [[UITableView alloc] 
											  initWithFrame:viewBounds style:UITableViewStylePlain];//UITableViewStylePlain, UITableViewStyleGrouped
				
				planTableView.delegate = self;
				planTableView.dataSource = self;
				
				self.customPlanTableView = planTableView;
				self.customPlanTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
				self.customPlanTableView.rowHeight = 55.0;
				[planTableView release];
			}
			
			[self.customGroupTableView removeFromSuperview];
			[self.view addSubview:self.customPlanTableView];
			
			[self.allNames removeAllObjects];
			[self.allGroups removeAllObjects];
			self.allNames = [NSMutableArray arrayWithArray:[UserInfo findAll]];
			self.allGroups = [NSMutableArray arrayWithArray:[GroupInfo findAll]];
			
			NSSortDescriptor *groupNameSort = [[NSSortDescriptor alloc] initWithKey:@"GROUPTITLE" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
			[self.allGroups sortUsingDescriptors:[NSArray arrayWithObject:groupNameSort]];
			[groupNameSort release];
			for(int g=0;g<[self.allGroups count];g++){
				GroupInfo* tempGroup = [self.allGroups objectAtIndex:g];
				GroupInfo* instGroup = [[GroupInfo alloc] init];
				NSAutoreleasePool* varpool = [[NSAutoreleasePool alloc] init];
				unsigned int numIvars = 0;
				Ivar* ivars = class_copyIvarList([instGroup class], &numIvars);
				for(int i = 0; i < numIvars; i++) {
					Ivar thisIvar = ivars[i];
					NSString * classkey = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
					if([tempGroup valueForKey:classkey] && [tempGroup valueForKey:classkey] != nil)
						[instGroup  setValue:[tempGroup valueForKey:classkey] forKey:classkey];
				}
				if(numIvars > 0)free(ivars);
				[varpool release];
				if([tempGroup.ID isEqualToString:@"0"]){
					[self.allGroups removeObject:tempGroup];
					[self.allGroups insertObject:instGroup atIndex:0];
					[instGroup release];
					break;
				}else {
					[instGroup release];
				}
				
			}
			
			for(GroupInfo* group in self.allGroups){
				NSMutableArray* arrayGroup = [NSMutableArray array];
				for(UserInfo* person in self.allNames){
					if([person.GID isEqualToString:group.ID]) {
						[arrayGroup addObject:person];
					}
				}
				if(group.GROUPTITLE != nil){
					NSSortDescriptor *formattedSort = [[NSSortDescriptor alloc] initWithKey:@"FORMATTED" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
					NSSortDescriptor *nickNameSort = [[NSSortDescriptor alloc] initWithKey:@"PROFILENICKNAME" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
					[arrayGroup sortUsingDescriptors:[NSArray arrayWithObjects:formattedSort,nickNameSort, nil]];
					[nickNameSort release];
					[formattedSort release];
					[peopleInGroup setObject:arrayGroup forKey:group.GROUPTITLE];
				}
			}
			
			[self.customPlanTableView reloadData];
			
			self.buttonToolBar.hidden = NO;
		}
		else if(sender == 1){
		self.title=@"주소 삭제";
		// TODO: 세그먼크 이미지 교체
		[self.editAddrChange setImage:[[UIImage imageNamed:@"btn_addr_edit_focus.png"]stretchableImageWithLeftCapWidth:1.0 topCapHeight:0.0] forSegmentAtIndex:0];
		[self.editAddrChange setImage:[[UIImage imageNamed:@"btn_group_edit_normal.png"]stretchableImageWithLeftCapWidth:1.0 topCapHeight:0.0] forSegmentAtIndex:1];
		
		UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
		//		assert(titleView != nil);
		UIFont *titleFont = [UIFont systemFontOfSize:20];
		CGSize titleStringSize = [@"주소 삭제" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
		//		assert(titleFont != nil);
		UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
		//		assert(titleLabel != nil);
		[titleLabel setFont:titleFont];
		titleLabel.textAlignment = UITextAlignmentCenter;
		[titleLabel setTextColor:ColorFromRGB(0x053844)];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[titleLabel setText:@"주소 삭제"];
		//		titleLabel.shadowColor = [UIColor whiteColor];
		[titleView addSubview:titleLabel];	
		[titleLabel release];
		self.navigationItem.titleView = titleView;
		[titleView release];
		self.navigationItem.titleView.frame = CGRectMake((self.view.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);
		
		
		if(self.customPlanTableView == nil){
			viewBounds.size.height -= 134.0-44;
			viewBounds.origin.y	-=44;
			UITableView *planTableView = [[UITableView alloc] 
										  initWithFrame:viewBounds style:UITableViewStylePlain];//UITableViewStylePlain, UITableViewStyleGrouped
			
			planTableView.delegate = self;
			planTableView.dataSource = self;
			
			self.customPlanTableView = planTableView;
			self.customPlanTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
			self.customPlanTableView.rowHeight = 55.0;
			[planTableView release];
		}
		
		[self.customGroupTableView removeFromSuperview];
		[self.view addSubview:self.customPlanTableView];
		
		[self.allNames removeAllObjects];
		[self.allGroups removeAllObjects];
		self.allNames = [NSMutableArray arrayWithArray:[UserInfo findAll]];
		self.allGroups = [NSMutableArray arrayWithArray:[GroupInfo findAll]];
		
		NSSortDescriptor *groupNameSort = [[NSSortDescriptor alloc] initWithKey:@"GROUPTITLE" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
		[self.allGroups sortUsingDescriptors:[NSArray arrayWithObject:groupNameSort]];
		[groupNameSort release];
		for(int g=0;g<[self.allGroups count];g++){
			GroupInfo* tempGroup = [self.allGroups objectAtIndex:g];
			GroupInfo* instGroup = [[GroupInfo alloc] init];
			NSAutoreleasePool* varpool = [[NSAutoreleasePool alloc] init];
			unsigned int numIvars = 0;
			Ivar* ivars = class_copyIvarList([instGroup class], &numIvars);
			for(int i = 0; i < numIvars; i++) {
				Ivar thisIvar = ivars[i];
				NSString * classkey = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
				if([tempGroup valueForKey:classkey] && [tempGroup valueForKey:classkey] != nil)
					[instGroup  setValue:[tempGroup valueForKey:classkey] forKey:classkey];
			}
			if(numIvars > 0)free(ivars);
			[varpool release];
			if([tempGroup.ID isEqualToString:@"0"]){
				[self.allGroups removeObject:tempGroup];
				[self.allGroups insertObject:instGroup atIndex:0];
				[instGroup release];
				break;
			}else {
				[instGroup release];
			}
			
		}
		
		for(GroupInfo* group in self.allGroups){
			NSMutableArray* arrayGroup = [NSMutableArray array];
			for(UserInfo* person in self.allNames){
				if([person.GID isEqualToString:group.ID]) {
					[arrayGroup addObject:person];
				}
			}
			if(group.GROUPTITLE != nil){
				NSSortDescriptor *formattedSort = [[NSSortDescriptor alloc] initWithKey:@"FORMATTED" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
				NSSortDescriptor *nickNameSort = [[NSSortDescriptor alloc] initWithKey:@"PROFILENICKNAME" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
				[arrayGroup sortUsingDescriptors:[NSArray arrayWithObjects:formattedSort,nickNameSort, nil]];
				[nickNameSort release];
				[formattedSort release];
				[peopleInGroup setObject:arrayGroup forKey:group.GROUPTITLE];
			}
		}
		
		[self.customPlanTableView reloadData];
		
		self.buttonToolBar.hidden = NO;
	}else if(sender == 2){
			//		self.title=@"그룹 편집";
			// TODO: 세그먼트 버튼 이미지 교체
			[self.editAddrChange setImage:[[UIImage imageNamed:@"btn_addr_edit_normal.png"]stretchableImageWithLeftCapWidth:1.0 topCapHeight:0.0] forSegmentAtIndex:0];
			[self.editAddrChange setImage:[[UIImage imageNamed:@"btn_group_edit_focus.png"]stretchableImageWithLeftCapWidth:1.0 topCapHeight:0.0] forSegmentAtIndex:1];
			
			UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
			//		assert(titleView != nil);
			UIFont *titleFont = [UIFont systemFontOfSize:20];
			CGSize titleStringSize = [@"그룹명 변경" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
			//		assert(titleFont != nil);
			UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
			//		assert(titleLabel != nil);
			[titleLabel setFont:titleFont];
			titleLabel.textAlignment = UITextAlignmentCenter;
			[titleLabel setTextColor:ColorFromRGB(0x053844)];
			[titleLabel setBackgroundColor:[UIColor clearColor]];
			[titleLabel setText:@"그룹명 변경"];
			//		titleLabel.shadowColor = [UIColor whiteColor];
			[titleView addSubview:titleLabel];	
			[titleLabel release];
			self.navigationItem.titleView = titleView;
			[titleView release];
			self.navigationItem.titleView.frame = CGRectMake((self.view.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);
			
			if(self.customGroupTableView == nil){
				/*f
				 UITextField *newTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
				 newTextField.textAlignment=UITextAlignmentLeft;
				 newTextField.text=@"새로 등록한 주소";
				 [newTextField setEnabled:NO];
				 
				 [self.view addSubview:newTextField];
				 */
				
				
				UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
				[tmpLabel setTextColor:ColorFromRGB(0x313b48)];
				[tmpLabel setText:@"'새로 등록한 주소'는 이름을 변경 할 수 없습니다."];
				[tmpLabel setFont:[UIFont systemFontOfSize:13]];
				[tmpLabel setTextAlignment:UITextAlignmentCenter];
				[tmpLabel setBackgroundColor:ColorFromRGB(0xedeff2)];
				[self.view addSubview:tmpLabel];
				
				
				[tmpLabel release];
				
				
				
				NSLog(@"view height y= %f %f", viewBounds.size.height, viewBounds.origin.y);
				viewBounds.size.height -= 78.0;
				viewBounds.origin.y -= 10.0;
				UITableView *groupTableView = [[UITableView alloc] 
											   initWithFrame:viewBounds style:UITableViewStyleGrouped];//UITableViewStylePlain, UITableViewStyleGrouped
				
				groupTableView.delegate = self;
				groupTableView.dataSource = self;
				
				self.customGroupTableView = groupTableView;
				self.customGroupTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
				self.customGroupTableView.rowHeight = 50.0;
				self.customGroupTableView.backgroundColor = ColorFromRGB(0xedeff2);
				[groupTableView release];
			}
			
			[self.customPlanTableView removeFromSuperview];
			[self.view addSubview:self.customGroupTableView];
			
			
			
			
			[self.allNames removeAllObjects];
			[self.allGroups removeAllObjects];
			self.allNames = [NSMutableArray arrayWithArray:[UserInfo findAll]];
			self.allGroups = [NSMutableArray arrayWithArray:[GroupInfo findAll]];
			
			
			
			
			
			NSSortDescriptor *groupNameSort = [[NSSortDescriptor alloc] initWithKey:@"GROUPTITLE" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
			[self.allGroups sortUsingDescriptors:[NSArray arrayWithObject:groupNameSort]];
			[groupNameSort release];
			for(int g=0;g<[self.allGroups count];g++){
				GroupInfo* tempGroup = [self.allGroups objectAtIndex:g];
				GroupInfo* instGroup = [[GroupInfo alloc] init];
				NSAutoreleasePool* varpool = [[NSAutoreleasePool alloc] init];
				unsigned int numIvars = 0;
				Ivar* ivars = class_copyIvarList([instGroup class], &numIvars);
				for(int i = 0; i < numIvars; i++) {
					Ivar thisIvar = ivars[i];
					NSString * classkey = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
					if([tempGroup valueForKey:classkey] && [tempGroup valueForKey:classkey] != nil)
						[instGroup  setValue:[tempGroup valueForKey:classkey] forKey:classkey];
				}
				if(numIvars > 0)free(ivars);
				[varpool release];
				if([tempGroup.ID isEqualToString:@"0"]){
					[self.allGroups removeObject:tempGroup];
					[self.allGroups insertObject:instGroup atIndex:0];
					[instGroup release];
					break;
				}else {
					[instGroup release];
				}
				
			}
			
			for(GroupInfo* group in self.allGroups){
				NSMutableArray* arrayGroup = [NSMutableArray array];
				for(UserInfo* person in self.allNames){
					if([person.GID isEqualToString:group.ID]) {
						[arrayGroup addObject:person];
					}
				}
				if(group.GROUPTITLE != nil){
					NSSortDescriptor *formattedSort = [[NSSortDescriptor alloc] initWithKey:@"FORMATTED" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
					NSSortDescriptor *nickNameSort = [[NSSortDescriptor alloc] initWithKey:@"PROFILENICKNAME" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
					[arrayGroup sortUsingDescriptors:[NSArray arrayWithObjects:formattedSort,nickNameSort, nil]];
					[nickNameSort release];
					[formattedSort release];
					[peopleInGroup setObject:arrayGroup forKey:group.GROUPTITLE];
				}
			}
			
			
			
			
			
			//	[self addCustomFooterView];
			
			self.buttonToolBar.hidden = YES;
			
			[self.customGroupTableView reloadData];
			
			
			
		}
		else if(sender == 3){
			//		self.title=@"그룹 편집";
			// TODO: 세그먼트 버튼 이미지 교체
			[self.editAddrChange setImage:[[UIImage imageNamed:@"btn_addr_edit_normal.png"]stretchableImageWithLeftCapWidth:1.0 topCapHeight:0.0] forSegmentAtIndex:0];
			[self.editAddrChange setImage:[[UIImage imageNamed:@"btn_group_edit_focus.png"]stretchableImageWithLeftCapWidth:1.0 topCapHeight:0.0] forSegmentAtIndex:1];
			
			UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
			//		assert(titleView != nil);
			UIFont *titleFont = [UIFont systemFontOfSize:20];
			CGSize titleStringSize = [@"그룹 삭제" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
			//		assert(titleFont != nil);
			UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
			//		assert(titleLabel != nil);
			[titleLabel setFont:titleFont];
			titleLabel.textAlignment = UITextAlignmentCenter;
			[titleLabel setTextColor:ColorFromRGB(0x053844)];
			[titleLabel setBackgroundColor:[UIColor clearColor]];
			[titleLabel setText:@"그룹 삭제"];
			//		titleLabel.shadowColor = [UIColor whiteColor];
			[titleView addSubview:titleLabel];	
			[titleLabel release];
			self.navigationItem.titleView = titleView;
			[titleView release];
			self.navigationItem.titleView.frame = CGRectMake((self.view.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);
			
			if(self.customGroupTableView == nil){
				/*f
				 UITextField *newTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
				 newTextField.textAlignment=UITextAlignmentLeft;
				 newTextField.text=@"새로 등록한 주소";
				 [newTextField setEnabled:NO];
				 
				 [self.view addSubview:newTextField];
				 */
				
				
				UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 320, 44)];
				[tmpLabel setTextColor:ColorFromRGB(0x313b48)];
				[tmpLabel setText:@"'새로 등록한 주소'는 삭제할 수 없습니다."];
				[tmpLabel setFont:[UIFont systemFontOfSize:13]];
				[tmpLabel setTextAlignment:UITextAlignmentLeft];
				[tmpLabel setBackgroundColor:ColorFromRGB(0xedeff2)];
				[self.view addSubview:tmpLabel];
				
				
				[tmpLabel release];
				
				
				
				
				
				NSLog(@"view height y= %f %f", viewBounds.size.height, viewBounds.origin.y);
				viewBounds.size.height -= 78.0;
				viewBounds.origin.y -= 16.0;
				UITableView *groupTableView = [[UITableView alloc] 
											   initWithFrame:viewBounds style:UITableViewStyleGrouped];//UITableViewStylePlain, UITableViewStyleGrouped
				
				groupTableView.delegate = self;
				groupTableView.dataSource = self;
				
				self.customGroupTableView = groupTableView;
				self.customGroupTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
				self.customGroupTableView.rowHeight = 50.0;
				self.customGroupTableView.backgroundColor = ColorFromRGB(0xedeff2);
				[groupTableView release];
			}
			
			[self.customPlanTableView removeFromSuperview];
			[self.view addSubview:self.customGroupTableView];
			
			
			
			
			[self.allNames removeAllObjects];
			[self.allGroups removeAllObjects];
			self.allNames = [NSMutableArray arrayWithArray:[UserInfo findAll]];
			self.allGroups = [NSMutableArray arrayWithArray:[GroupInfo findAll]];
			
			
			
			
			
			NSSortDescriptor *groupNameSort = [[NSSortDescriptor alloc] initWithKey:@"GROUPTITLE" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
			[self.allGroups sortUsingDescriptors:[NSArray arrayWithObject:groupNameSort]];
			[groupNameSort release];
			for(int g=0;g<[self.allGroups count];g++){
				GroupInfo* tempGroup = [self.allGroups objectAtIndex:g];
				GroupInfo* instGroup = [[GroupInfo alloc] init];
				NSAutoreleasePool* varpool = [[NSAutoreleasePool alloc] init];
				unsigned int numIvars = 0;
				Ivar* ivars = class_copyIvarList([instGroup class], &numIvars);
				for(int i = 0; i < numIvars; i++) {
					Ivar thisIvar = ivars[i];
					NSString * classkey = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
					if([tempGroup valueForKey:classkey] && [tempGroup valueForKey:classkey] != nil)
						[instGroup  setValue:[tempGroup valueForKey:classkey] forKey:classkey];
				}
				if(numIvars > 0)free(ivars);
				[varpool release];
				if([tempGroup.ID isEqualToString:@"0"]){
					[self.allGroups removeObject:tempGroup];
					[self.allGroups insertObject:instGroup atIndex:0];
					[instGroup release];
					break;
				}else {
					[instGroup release];
				}
				
			}
			
			for(GroupInfo* group in self.allGroups){
				NSMutableArray* arrayGroup = [NSMutableArray array];
				for(UserInfo* person in self.allNames){
					if([person.GID isEqualToString:group.ID]) {
						[arrayGroup addObject:person];
					}
				}
				if(group.GROUPTITLE != nil){
					NSSortDescriptor *formattedSort = [[NSSortDescriptor alloc] initWithKey:@"FORMATTED" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
					NSSortDescriptor *nickNameSort = [[NSSortDescriptor alloc] initWithKey:@"PROFILENICKNAME" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
					[arrayGroup sortUsingDescriptors:[NSArray arrayWithObjects:formattedSort,nickNameSort, nil]];
					[nickNameSort release];
					[formattedSort release];
					[peopleInGroup setObject:arrayGroup forKey:group.GROUPTITLE];
				}
			}
			
			
			
			
			
			//	[self addCustomFooterView];
			
			self.buttonToolBar.hidden = YES;
			
			[self.customGroupTableView reloadData];
			
			
			
		}
	
}

-(IBAction)segmentedControl:(id)sender {
	CGRect viewBounds = [[UIScreen mainScreen]applicationFrame];
	viewBounds.origin.y = 44.0;
	
	//if([sender selectedSegmentIndex] == 0){
	if(sender == 0){
		self.title=@"주소 편집";
		// TODO: 세그먼크 이미지 교체
		[self.editAddrChange setImage:[[UIImage imageNamed:@"btn_addr_edit_focus.png"]stretchableImageWithLeftCapWidth:1.0 topCapHeight:0.0] forSegmentAtIndex:0];
		[self.editAddrChange setImage:[[UIImage imageNamed:@"btn_group_edit_normal.png"]stretchableImageWithLeftCapWidth:1.0 topCapHeight:0.0] forSegmentAtIndex:1];
		
		UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
//		assert(titleView != nil);
		UIFont *titleFont = [UIFont systemFontOfSize:20];
		CGSize titleStringSize = [@"이동할 그룹선택" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
//		assert(titleFont != nil);
		UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
//		assert(titleLabel != nil);
		[titleLabel setFont:titleFont];
		titleLabel.textAlignment = UITextAlignmentCenter;
		[titleLabel setTextColor:ColorFromRGB(0x053844)];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[titleLabel setText:@"이동할 그룹선택"];
//		titleLabel.shadowColor = [UIColor whiteColor];
		[titleView addSubview:titleLabel];	
		[titleLabel release];
		self.navigationItem.titleView = titleView;
		[titleView release];
		self.navigationItem.titleView.frame = CGRectMake((self.view.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);
		
		
		if(self.customPlanTableView == nil){
			viewBounds.size.height -= 134.0;
			UITableView *planTableView = [[UITableView alloc] 
										  initWithFrame:viewBounds style:UITableViewStylePlain];//UITableViewStylePlain, UITableViewStyleGrouped
			
			planTableView.delegate = self;
			planTableView.dataSource = self;
			
			self.customPlanTableView = planTableView;
			self.customPlanTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
			self.customPlanTableView.rowHeight = 55.0;
			[planTableView release];
		}
		
		[self.customGroupTableView removeFromSuperview];
		[self.view addSubview:self.customPlanTableView];
		
		[self.allNames removeAllObjects];
		[self.allGroups removeAllObjects];
		self.allNames = [NSMutableArray arrayWithArray:[UserInfo findAll]];
		self.allGroups = [NSMutableArray arrayWithArray:[GroupInfo findAll]];
		
		NSSortDescriptor *groupNameSort = [[NSSortDescriptor alloc] initWithKey:@"GROUPTITLE" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
		[self.allGroups sortUsingDescriptors:[NSArray arrayWithObject:groupNameSort]];
		[groupNameSort release];
		for(int g=0;g<[self.allGroups count];g++){
			GroupInfo* tempGroup = [self.allGroups objectAtIndex:g];
			GroupInfo* instGroup = [[GroupInfo alloc] init];
			NSAutoreleasePool* varpool = [[NSAutoreleasePool alloc] init];
			unsigned int numIvars = 0;
			Ivar* ivars = class_copyIvarList([instGroup class], &numIvars);
			for(int i = 0; i < numIvars; i++) {
				Ivar thisIvar = ivars[i];
				NSString * classkey = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
				if([tempGroup valueForKey:classkey] && [tempGroup valueForKey:classkey] != nil)
					[instGroup  setValue:[tempGroup valueForKey:classkey] forKey:classkey];
			}
			if(numIvars > 0)free(ivars);
			[varpool release];
			if([tempGroup.ID isEqualToString:@"0"]){
				[self.allGroups removeObject:tempGroup];
				[self.allGroups insertObject:instGroup atIndex:0];
				[instGroup release];
				break;
			}else {
				[instGroup release];
			}
			
		}
		
		for(GroupInfo* group in self.allGroups){
			NSMutableArray* arrayGroup = [NSMutableArray array];
			for(UserInfo* person in self.allNames){
				if([person.GID isEqualToString:group.ID]) {
					[arrayGroup addObject:person];
				}
			}
			if(group.GROUPTITLE != nil){
				NSSortDescriptor *formattedSort = [[NSSortDescriptor alloc] initWithKey:@"FORMATTED" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
				NSSortDescriptor *nickNameSort = [[NSSortDescriptor alloc] initWithKey:@"PROFILENICKNAME" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
				[arrayGroup sortUsingDescriptors:[NSArray arrayWithObjects:formattedSort,nickNameSort, nil]];
				[nickNameSort release];
				[formattedSort release];
				[peopleInGroup setObject:arrayGroup forKey:group.GROUPTITLE];
			}
		}
		
		[self.customPlanTableView reloadData];
		
		self.buttonToolBar.hidden = NO;
	}else {
//		self.title=@"그룹 편집";
		// TODO: 세그먼트 버튼 이미지 교체
		[self.editAddrChange setImage:[[UIImage imageNamed:@"btn_addr_edit_normal.png"]stretchableImageWithLeftCapWidth:1.0 topCapHeight:0.0] forSegmentAtIndex:0];
		[self.editAddrChange setImage:[[UIImage imageNamed:@"btn_group_edit_focus.png"]stretchableImageWithLeftCapWidth:1.0 topCapHeight:0.0] forSegmentAtIndex:1];
	
		UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
//		assert(titleView != nil);
		UIFont *titleFont = [UIFont systemFontOfSize:20];
		CGSize titleStringSize = [@"그룹명 변경" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
//		assert(titleFont != nil);
		UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
//		assert(titleLabel != nil);
		[titleLabel setFont:titleFont];
		titleLabel.textAlignment = UITextAlignmentCenter;
		[titleLabel setTextColor:ColorFromRGB(0x053844)];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[titleLabel setText:@"그룹명 변경"];
//		titleLabel.shadowColor = [UIColor whiteColor];
		[titleView addSubview:titleLabel];	
		[titleLabel release];
		self.navigationItem.titleView = titleView;
		[titleView release];
		self.navigationItem.titleView.frame = CGRectMake((self.view.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);
		
		if(self.customGroupTableView == nil){
			viewBounds.size.height -= 88.0;
			UITableView *groupTableView = [[UITableView alloc] 
										   initWithFrame:viewBounds style:UITableViewStyleGrouped];//UITableViewStylePlain, UITableViewStyleGrouped
			
			groupTableView.delegate = self;
			groupTableView.dataSource = self;
			
			self.customGroupTableView = groupTableView;
			self.customGroupTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
			self.customGroupTableView.rowHeight = 50.0;
			self.customGroupTableView.backgroundColor = ColorFromRGB(0xedeff2);
			[groupTableView release];
		}
		
		[self.customPlanTableView removeFromSuperview];
		[self.view addSubview:self.customGroupTableView];
		
		
		
		
		[self.allNames removeAllObjects];
		[self.allGroups removeAllObjects];
		self.allNames = [NSMutableArray arrayWithArray:[UserInfo findAll]];
		self.allGroups = [NSMutableArray arrayWithArray:[GroupInfo findAll]];
		
		
		
		
		
		NSSortDescriptor *groupNameSort = [[NSSortDescriptor alloc] initWithKey:@"GROUPTITLE" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
		[self.allGroups sortUsingDescriptors:[NSArray arrayWithObject:groupNameSort]];
		[groupNameSort release];
		for(int g=0;g<[self.allGroups count];g++){
			GroupInfo* tempGroup = [self.allGroups objectAtIndex:g];
			GroupInfo* instGroup = [[GroupInfo alloc] init];
			NSAutoreleasePool* varpool = [[NSAutoreleasePool alloc] init];
			unsigned int numIvars = 0;
			Ivar* ivars = class_copyIvarList([instGroup class], &numIvars);
			for(int i = 0; i < numIvars; i++) {
				Ivar thisIvar = ivars[i];
				NSString * classkey = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
				if([tempGroup valueForKey:classkey] && [tempGroup valueForKey:classkey] != nil)
					[instGroup  setValue:[tempGroup valueForKey:classkey] forKey:classkey];
			}
			if(numIvars > 0)free(ivars);
			[varpool release];
			if([tempGroup.ID isEqualToString:@"0"]){
				[self.allGroups removeObject:tempGroup];
				[self.allGroups insertObject:instGroup atIndex:0];
				[instGroup release];
				break;
			}else {
				[instGroup release];
			}
			
		}
		
		for(GroupInfo* group in self.allGroups){
			NSMutableArray* arrayGroup = [NSMutableArray array];
			for(UserInfo* person in self.allNames){
				if([person.GID isEqualToString:group.ID]) {
					[arrayGroup addObject:person];
				}
			}
			if(group.GROUPTITLE != nil){
				NSSortDescriptor *formattedSort = [[NSSortDescriptor alloc] initWithKey:@"FORMATTED" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
				NSSortDescriptor *nickNameSort = [[NSSortDescriptor alloc] initWithKey:@"PROFILENICKNAME" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
				[arrayGroup sortUsingDescriptors:[NSArray arrayWithObjects:formattedSort,nickNameSort, nil]];
				[nickNameSort release];
				[formattedSort release];
				[peopleInGroup setObject:arrayGroup forKey:group.GROUPTITLE];
			}
		}
		
		
		
		
		
	//	[self addCustomFooterView];
		
		self.buttonToolBar.hidden = YES;
		
		[self.customGroupTableView reloadData];
		
		
		
	}
}
-(void)createNewGroup {
	AddGroupViewController* addGroupController = [[AddGroupViewController alloc] initWithStyle:UITableViewStyleGrouped];
	addGroupController.hidesBottomBarWhenPushed = YES;
	addGroupController.title = @"새그룹 생성";
	addGroupController.addDelegate = self;
	
	////////// 타이틀 색 지정 //////////
	UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
//	assert(titleView != nil);
	UIFont *titleFont = [UIFont systemFontOfSize:20];
	CGSize titleStringSize = [@"새그룹 생성" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
//	assert(titleFont != nil);
	UILabel *naviTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
//	assert(naviTitleLabel != nil);
	[naviTitleLabel setFont:titleFont];
	naviTitleLabel.textAlignment = UITextAlignmentCenter;
	[naviTitleLabel setTextColor:ColorFromRGB(0x053844)];
	[naviTitleLabel setBackgroundColor:[UIColor clearColor]];
	[naviTitleLabel setText:@"새그룹 생성"];
//	naviTitleLabel.shadowColor = [UIColor whiteColor];
	[titleView addSubview:naviTitleLabel];	
	[naviTitleLabel release];
	addGroupController.navigationItem.titleView = titleView;
	[titleView release];
	addGroupController.navigationItem.titleView.frame = CGRectMake((addGroupController.view.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);
	/////////////////////////////////
	
	[self.navigationController pushViewController:addGroupController animated:YES];
	[addGroupController release];
}

-(void)addCustomFooterView {
	UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.customGroupTableView.frame.size.width, 46.0)];
	customView.backgroundColor = [UIColor clearColor];
	
	UIImage* normalImage = [UIImage imageNamed:@"btn_newgroup.png"];
	UIImage* clickedImage = [UIImage imageNamed:@"btn_newgroup_over.png"];
	UIButton* customImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[customImageButton addTarget:self action:@selector(createNewGroup) forControlEvents:UIControlEventTouchUpInside];
	[customImageButton setImage:[normalImage stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] forState:UIControlStateNormal];
	[customImageButton setImage:[clickedImage stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] forState:UIControlStateSelected];
	customImageButton.frame = customView.frame;	
	[customView addSubview:customImageButton];
	self.customGroupTableView.tableFooterView = customView;
	[customView release];
}


-(IBAction)leftButtonClicked:(id)sender{
	if([self appDelegate].connectionType == -1){
		UIAlertView* offlineAlert = [[UIAlertView alloc] initWithTitle:@"오프라인"
															   message:@"현재 네트워크 연결이 불가능한 상태 입니다.\nUsay의 모든 기능을 이용하기 위해서는 네트워크 연결이 필요합니다." 
															  delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
		[offlineAlert show];
		[offlineAlert release];
		return;
		
	}
	
	if([self.selectedPerson count] > 0){
		UIActionSheet* editMenu = [[UIActionSheet alloc] initWithTitle:@"주소를 삭제 하시겠습니까?" 
															  delegate:self
													 cancelButtonTitle:@"취소" 
												destructiveButtonTitle:@"삭제하기" 
													 otherButtonTitles:nil];
		editMenu.actionSheetStyle = UIActionSheetStyleDefault;
		//tabBar 컨트롤러의 하위 뷰일경우, actionsheet의 cancel버튼이 먹질 않는다. 
		//tabbarcontroller뷰의 상단에 보이게 한다.
		[editMenu showInView:self.view];
		[editMenu release];
	}else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"주소록 삭제" 
												message:@"주소록을 선택해 주세요." 
											   delegate:self 
												  cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	}

}

-(IBAction)rightButtonClicked:(id)sender {
	
	if([self.selectedPerson count] > 0){
		// 그룹 리스트 선택 으로 전환
		NSString *controllerClassName = @"EditAddressGroupMultiSelectionViewController";
		NSString *rowLabel = NSLocalizedString(@"이동할 그룹선택", @"이동할 그룹선택");
		NSString *rowKey = @"moveGroup";
		Class controllerClass = NSClassFromString(controllerClassName);
		EditAddressGroupMultiSelectionViewController *controller = [[controllerClass alloc] init] ;
		
		controller.keypath = rowKey;
		controller.labelString = rowLabel;
//		controller.title = rowLabel;
		controller.moveDelegate = self;
		
		
		////////// 타이틀 색 지정 //////////
		UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
//		assert(titleView != nil);
		UIFont *titleFont = [UIFont systemFontOfSize:20];
		CGSize titleStringSize = [rowLabel sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
//		assert(titleFont != nil);
		UILabel *naviTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
//		assert(naviTitleLabel != nil);
		[naviTitleLabel setFont:titleFont];
		naviTitleLabel.textAlignment = UITextAlignmentCenter;
		[naviTitleLabel setTextColor:ColorFromRGB(0x053844)];
		[naviTitleLabel setBackgroundColor:[UIColor clearColor]];
		[naviTitleLabel setText:rowLabel];
//		naviTitleLabel.shadowColor = [UIColor whiteColor];
		[titleView addSubview:naviTitleLabel];	
		[naviTitleLabel release];
		controller.navigationItem.titleView = titleView;
		[titleView release];
		controller.navigationItem.titleView.frame = CGRectMake((controller.view.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);
		/////////////////////////////////
		/*
		NSUInteger newPath[] = {0, 0};
		NSIndexPath *row0IndexPath = [NSIndexPath indexPathWithIndexes:newPath length:2];
		
		NSDictionary *args = [rowArguments nestedObjectAtIndexPath:row0IndexPath];
		if ([args isKindOfClass:[NSDictionary class]]) {
			if (args != nil) {
				for (NSString *oneKey in args) {
					id oneArg = [args objectForKey:oneKey];
					[controller setValue:oneArg forKey:oneKey];
				}
			}
		}
		*/
		[controller setValue:self.allGroups forKey:@"list"];
		
		//cell에서 선택된 유저들을 검출하여 배열로 만든다.
		NSMutableArray* checkedUserList = [NSMutableArray array];
		
		for(NSIndexPath* indexPath in self.selectedPerson){
			GroupInfo* keygroup = [self.allGroups objectAtIndex:indexPath.section];
	//		NSString *key = [[self.peopleInGroup allKeys] objectAtIndex:[indexPath section]];
			NSArray *nameSection = [self.peopleInGroup objectForKey:keygroup.GROUPTITLE];
			UserInfo* checkedUser = [nameSection objectAtIndex:[indexPath row]];
			[checkedUserList addObject:checkedUser];
		}
		
		controller.userList = checkedUserList;
		
		[self.navigationController pushViewController:controller animated:YES];
		
		controller.peopleInGroup = self.peopleInGroup;
		
		
		[controller release];
	}else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"주소 이동" 
															message:@"주소록을 선택해 주세요." 
														   delegate:self 
												  cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
	}

}





#pragma mark 그룹편집의 편집버튼 이벤트
-(void)editGroupClicked2:(NSInteger)sender {
	
	NSInteger buttonRow = sender;
	
	
	buttonRow +=1;
	
	btnIndex = buttonRow;
	GroupInfo* limitGroup = [self.allGroups objectAtIndex:buttonRow];
	//	int groupId = [limitGroup.ID intValue];
	if(buttonRow < 1){
		NSString* alertStr = [NSString stringWithFormat:@"%@ 는 기본 그룹입니다. \n편집/삭제를 하실 수 없습니다.",limitGroup.GROUPTITLE];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"삭제 제한" message:alertStr delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return ;
	}
	
	
	NSLog(@"number of edit =%d", numberofEdit);
	
	if(numberofEdit == 2) {
		
		/*
		 임시주석
		EditGroupViewController* controller = [[EditGroupViewController alloc]initWithStyle:UITableViewStyleGrouped];
		controller.editGroupInfo = [self.allGroups objectAtIndex:buttonRow];
		controller.editGroupDelegate = self;
		controller.title = @"그룹명 변경";
		////////// 타이틀 색 지정 //////////
		UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
		//	assert(titleView != nil);
		UIFont *titleFont = [UIFont systemFontOfSize:20];
		CGSize titleStringSize = [@"그룹명 변경" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
		//	assert(titleFont != nil);
		UILabel *naviTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
		//	assert(naviTitleLabel != nil);
		[naviTitleLabel setFont:titleFont];
		naviTitleLabel.textAlignment = UITextAlignmentCenter;
		[naviTitleLabel setTextColor:ColorFromRGB(0x053844)];
		[naviTitleLabel setBackgroundColor:[UIColor clearColor]];
		[naviTitleLabel setText:@"그룹명 변경"];
		//	naviTitleLabel.shadowColor = [UIColor whiteColor];
		[titleView addSubview:naviTitleLabel];	
		[naviTitleLabel release];
		controller.navigationItem.titleView = titleView;
		[titleView release];
		controller.navigationItem.titleView.frame = CGRectMake((controller.tableView.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);
		/////////////////////////////////
		
		
		[self.navigationController pushViewController:controller animated:YES];
		[controller release];
		
		 //20101014 바로 수정 하도록 수정
		 
		*/
		
		
		
		AddGroupViewController* addGroupController = [[AddGroupViewController alloc] initWithStyle:UITableViewStyleGrouped];
		//	addGroupController.hidesBottomBarWhenPushed = YES;
		addGroupController.groupChanged = [self.allGroups objectAtIndex:buttonRow];
		//	addGroupController.title = @"그룹명 변경";
		addGroupController.addDelegate = self;
		
		UIView *titleView2 = [[UIView alloc] initWithFrame:addGroupController.navigationItem.titleView.bounds];
		//	assert(titleView != nil);
		UIFont *titleFont2 = [UIFont systemFontOfSize:20];
		CGSize titleStringSize2 = [@"그룹명 변경" sizeWithFont:titleFont2 constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
		//	assert(titleFont != nil);
		UILabel *naviTitleLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize2.width, titleStringSize2.height)];
		//	assert(naviTitleLabel != nil);
		[naviTitleLabel2 setFont:titleFont2];
		naviTitleLabel2.textAlignment = UITextAlignmentCenter;
		[naviTitleLabel2 setTextColor:ColorFromRGB(0x053844)];
		[naviTitleLabel2 setBackgroundColor:[UIColor clearColor]];
		[naviTitleLabel2 setText:@"그룹명 변경"];
		//	naviTitleLabel.shadowColor = [UIColor whiteColor];
		[titleView2 addSubview:naviTitleLabel2];	
		[naviTitleLabel2 release];
		addGroupController.navigationItem.titleView = titleView2;
		[titleView2 release];
		addGroupController.navigationItem.titleView.frame = CGRectMake((addGroupController.tableView.frame.size.width-titleStringSize2.width)/2.0, 12.0, titleStringSize2.width, titleStringSize2.height);
		
		
		[self.navigationController pushViewController:addGroupController animated:YES];
		[addGroupController release];
	//	[tableView deselectRowAtIndexPath:indexPath animated:YES];
		
		
		
		
		
		
	}
	
	else if(numberofEdit == 3)
	{
		
		UIActionSheet* editMenu = [[UIActionSheet alloc] initWithTitle:@"그룹 삭제" 
															  delegate:self
													 cancelButtonTitle:@"취소" 
												destructiveButtonTitle:nil
													 otherButtonTitles:@"그룹만 삭제",@"그룹과 주소 모두 삭제", nil];
		editMenu.actionSheetStyle = UIActionSheetStyleDefault;
		//tabBar 컨트롤러의 하위 뷰일경우, actionsheet의 cancel버튼이 먹질 않는다. 
		//tabbarcontroller뷰의 상단에 보이게 한다.
		[editMenu showInView:self.view];
		[editMenu release];
		
	}
	
	
	
	
	
	
}
-(void)editGroupClicked:(id)Sender {
	
	UIButton* clickBtn = (UIButton*)Sender;
	EditAddressCustomCell *cell = (EditAddressCustomCell*)[clickBtn superview];
//	NSInteger buttonSection = [[self.customGroupTableView indexPathForCell:cell] section];
	NSInteger buttonRow = [[self.customGroupTableView indexPathForCell:cell] row];

	
	buttonRow +=1;
	
	btnIndex = buttonRow;
	GroupInfo* limitGroup = [self.allGroups objectAtIndex:buttonRow];
//	int groupId = [limitGroup.ID intValue];
	if(buttonRow < 1){
		NSString* alertStr = [NSString stringWithFormat:@"%@ 는 기본 그룹입니다. \n편집/삭제를 하실 수 없습니다.",limitGroup.GROUPTITLE];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"삭제 제한" message:alertStr delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		[alertView show];
		[alertView release];
		return ;
	}
	
	
	NSLog(@"number of edit =%d", numberofEdit);
	
	if(numberofEdit == 2) {
		
	 
		 EditGroupViewController* controller = [[EditGroupViewController alloc]initWithStyle:UITableViewStyleGrouped];
		 controller.editGroupInfo = [self.allGroups objectAtIndex:buttonRow];
		 controller.editGroupDelegate = self;
		 controller.title = @"그룹명 변경";
		 ////////// 타이틀 색 지정 //////////
		 UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
		 //	assert(titleView != nil);
		 UIFont *titleFont = [UIFont systemFontOfSize:20];
		 CGSize titleStringSize = [@"그룹명 변경" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
		 //	assert(titleFont != nil);
		 UILabel *naviTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
		 //	assert(naviTitleLabel != nil);
		 [naviTitleLabel setFont:titleFont];
		 naviTitleLabel.textAlignment = UITextAlignmentCenter;
		 [naviTitleLabel setTextColor:ColorFromRGB(0x053844)];
		 [naviTitleLabel setBackgroundColor:[UIColor clearColor]];
		 [naviTitleLabel setText:@"그룹명 변경"];
		 //	naviTitleLabel.shadowColor = [UIColor whiteColor];
		 [titleView addSubview:naviTitleLabel];	
		 [naviTitleLabel release];
		 controller.navigationItem.titleView = titleView;
		 [titleView release];
		 controller.navigationItem.titleView.frame = CGRectMake((controller.tableView.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);
		 /////////////////////////////////
		 
		 
		 [self.navigationController pushViewController:controller animated:YES];
		 [controller release];
		
	}
	
	else if(numberofEdit == 3)
	{
		
		UIActionSheet* editMenu = [[UIActionSheet alloc] initWithTitle:@"그룹 삭제" 
															  delegate:self
													 cancelButtonTitle:@"취소" 
												destructiveButtonTitle:nil
													 otherButtonTitles:@"그룹만 삭제",@"그룹과 주소 모두 삭제", nil];
		editMenu.actionSheetStyle = UIActionSheetStyleDefault;
		//tabBar 컨트롤러의 하위 뷰일경우, actionsheet의 cancel버튼이 먹질 않는다. 
		//tabbarcontroller뷰의 상단에 보이게 한다.
		[editMenu showInView:self.view];
		[editMenu release];
		
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
	self.editAddrChange = nil;
	self.buttonToolBar = nil;
	self.customPlanTableView = nil;
	self.customGroupTableView = nil;
	self.selectedPerson = nil;
}

- (void)dealloc {
//	[editAddrChange release];
	if(buttonToolBar != nil)
		[buttonToolBar release];
	if(customPlanTableView != nil)
		[customPlanTableView release];
	if(customGroupTableView != nil)
		[customGroupTableView release];
	if(selectedPerson != nil)
		[selectedPerson release];
	if(peopleInGroup != nil)
		[peopleInGroup release];
	if(statusGroup != nil)
		[statusGroup release];
	if(Editcontroller != nil)
		[Editcontroller release];

    [super dealloc];
}

#pragma mark -
#pragma mark tableView Data Source Method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if(tableView == self.customPlanTableView)
		return [self.peopleInGroup count];
	if(tableView == self.customGroupTableView)
		return 2;
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section  {
//	NSString *key = nil;
	NSArray *nameSection = nil;
	
	if(tableView == self.customPlanTableView){
		GroupInfo* keygroup = [self.allGroups objectAtIndex:section];
	//	key = [[self.peopleInGroup allKeys] objectAtIndex:section];
		nameSection = [self.peopleInGroup objectForKey:keygroup.GROUPTITLE];
	
		if([self convertBoolValue:[self.statusGroup valueForKey:[NSString stringWithFormat:@"%i",section]]])
			return 0;
		
		return [nameSection count];
	}if(tableView == self.customGroupTableView){
		if (section == 1) {
			return [self.allGroups count]-1;	
		}
		else {
			return 1;	
		}

		
	}
	
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//	NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];
	
	
	if(tableView == self.customPlanTableView){
		GroupInfo *groupInfo = [self.allGroups objectAtIndex:indexPath.section];
		static NSString *CellIdentifier = @"EditAddressIdentifier";
		
		EditAddressCustomCell* cell = (EditAddressCustomCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil)
		{
			cell = [[[EditAddressCustomCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
			
		}
//		NSString *key = nil;
		NSArray* sections = nil;
//		NSArray* keyArray = [self.peopleInGroup allKeys];
		
//		key = [keyArray objectAtIndex:section];
		sections = [self.peopleInGroup objectForKey:groupInfo.GROUPTITLE];
		
		UserInfo *dataItem = [sections objectAtIndex:row];
		if (dataItem.ISFRIEND && [dataItem.ISFRIEND isEqualToString:@"S"]) {
			if (dataItem.REPRESENTPHOTO && [dataItem.REPRESENTPHOTO length] > 0) {
				NSString *photoUrl = [NSString stringWithFormat:@"%@/011", dataItem.REPRESENTPHOTO];
				[cell.photoView setImageWithURL:[NSURL URLWithString:photoUrl]
							   placeholderImage:[UIImage imageNamed:@"img_default.png"]];
			} else if (dataItem.THUMBNAILURL && [dataItem.THUMBNAILURL length] > 0) {
				NSString *photoUrl = [NSString stringWithFormat:@"%@/011", dataItem.THUMBNAILURL];
				[cell.photoView setImageWithURL:[NSURL URLWithString:photoUrl]
							   placeholderImage:[UIImage imageNamed:@"img_default.png"]];
			} else {
				cell.photoView.image = [UIImage imageNamed:@"img_default.png"];
			}
		} else if (dataItem.ISFRIEND && [dataItem.ISFRIEND isEqualToString:@"A"]) {
			if (dataItem.THUMBNAILURL && [dataItem.THUMBNAILURL length] > 0) {
				NSString *photoUrl = [NSString stringWithFormat:@"%@/011", dataItem.THUMBNAILURL];
				[cell.photoView setImageWithURL:[NSURL URLWithString:photoUrl]
							   placeholderImage:[UIImage imageNamed:@"img_default.png"]];
			} else {
				cell.photoView.image = [UIImage imageNamed:@"img_default.png"];
			}
		} else if (dataItem.ISFRIEND && [dataItem.ISFRIEND isEqualToString:@"N"]) {
			if (dataItem.THUMBNAILURL && [dataItem.THUMBNAILURL length] > 0) {
				NSString *photoUrl = [NSString stringWithFormat:@"%@/011", dataItem.THUMBNAILURL];
				[cell.photoView setImageWithURL:[NSURL URLWithString:photoUrl]
													placeholderImage:[UIImage imageNamed:@"img_default.png"]];
			} else {
				cell.photoView.image = [UIImage imageNamed:@"img_default.png"];
			}
		} else {
			// error
		}
		
		if (dataItem.REPRESENTPHOTO && [dataItem.REPRESENTPHOTO length] > 0) {
			NSString *photoUrl = [NSString stringWithFormat:@"%@/011", dataItem.REPRESENTPHOTO];
			[cell.photoView setImageWithURL:[NSURL URLWithString:photoUrl]
								placeholderImage:[UIImage imageNamed:@"img_default.png"]];
		} else {
			cell.photoView.image = [UIImage imageNamed:@"img_default.png"];
		}
		
		if([dataItem.ISFRIEND isEqualToString:@"S"]){// 친구일경우 접속 상태 정보 표시 // 0:offline  1:online  2:busy (바빠요)  8:곧 돌아옵니다.  16:다른용무중
			if([dataItem.IMSTATUS intValue] == 0)
				dataItem.IMSTATUS = [NSString stringWithFormat:@"1"];
			switch ([dataItem.IMSTATUS intValue]) {
				case 0:
					cell.statusView.image = [UIImage imageNamed:@"state_off.png"];
					break;
				case 1:
					cell.statusView.image = [UIImage imageNamed:@"state_on.png"];
					break;
				case 2:
					cell.statusView.image = [UIImage imageNamed:@"state_busy.png"];
					break;
				case 8:
					cell.statusView.image = [UIImage imageNamed:@"state_time.png"];
					break;
				case 16:
					cell.statusView.image = [UIImage imageNamed:@"state_do.png"];
					break;
				default:
					break;
			}
		
		}else{
			cell.statusView.image = [UIImage imageNamed:@"state_public.png"];			
		}
		
		if(dataItem.FORMATTED != nil && [dataItem.FORMATTED length]>0){
			cell.titleLabel.text =  dataItem.FORMATTED;
		}else if(dataItem.PROFILENICKNAME != nil && [dataItem.PROFILENICKNAME length] > 0){
			cell.titleLabel.text = dataItem.PROFILENICKNAME;
		}else {
			cell.titleLabel.text = @"이름 없음";
		}
		
		if(dataItem.STATUS != nil && [dataItem.STATUS length] > 0){
			cell.subTitleLabel.text = dataItem.STATUS;
		}else {
			cell.subTitleLabel.text = @"";
		}

		if([self.selectedPerson indexOfObject:indexPath] != NSNotFound)
			cell.checked = YES;
		else
			cell.checked = NO;
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		NSLocale *locale = [NSLocale currentLocale];
		[formatter setLocale:locale];
		[formatter setDateFormat:@"yyyyMMdd"];
		NSDate *today = [NSDate date];
		NSString *dateOftoday = [[NSString alloc] initWithFormat:@"%@",[formatter stringFromDate:today]];
		
		if(dataItem.CHANGEDATE != nil && [dataItem.CHANGEDATE length] > 0){
			if([[dataItem.CHANGEDATE substringToIndex:8] isEqualToString:dateOftoday]){//변경된 일자가 오늘일경우
				if([[dataItem.ISFRIEND uppercaseString] isEqualToString:@"S"]){//서로 친구일경우
					cell.contentView.backgroundColor = ColorFromRGB(0xfffbb5);
	//				cell.contentView.alpha = 0.9f;
	//				cell.contentView.opaque = NO;
				}else {// 한쪽만 친구 이거나, 친구가 아닐경우
					cell.contentView.backgroundColor = [UIColor clearColor];
	//				cell.contentView.alpha = 1.0f;
	//				cell.contentView.opaque = YES;
				}
			}else {//변경된 일자가 오늘이 아닐경우
				cell.contentView.backgroundColor = [UIColor clearColor];
	//			cell.contentView.alpha = 1.0f;
	//			cell.contentView.opaque = YES;
			}
		}else{
			cell.contentView.backgroundColor = [UIColor clearColor];
	//		cell.contentView.alpha = 1.0f;
	//		cell.contentView.opaque = YES;
		}
		[dateOftoday release];
		[formatter release];
		
		return cell;
    }
	
	if(tableView == self.customGroupTableView){
		static NSString *CellIdentifier = @"EditGroupIdentifier";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if(cell == nil){
			cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
			
		}
		
		UIImage* btnBGNormal = [[UIImage imageNamed:@"btn_modify.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
		UIImage* btnBGSelected = [[UIImage imageNamed:@"btn_modify_over.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	
		
		
		UIButton* editButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[editButton setFrame:CGRectMake(0.0, 0.0, 48, 33)];
		[editButton setImage:btnBGNormal forState:UIControlStateNormal];
		[editButton setImage:btnBGSelected forState:UIControlStateSelected];
		[editButton addTarget:self action:@selector(editGroupClicked:) forControlEvents:UIControlEventTouchUpInside];
		
		 
		 
		CGRect lbRect = CGRectMake(10.0f, 18.0f, 180.0f, 20.0f);
		UILabel* titleLabel = [[UILabel alloc] initWithFrame:lbRect];
		titleLabel.frame = lbRect;
		titleLabel.textColor = ColorFromRGB(0x285f7a);
		titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
		titleLabel.textAlignment = UITextAlignmentLeft;
		
		[cell.contentView addSubview:titleLabel];

	//	cell.accessoryView = editButton;
		
		
		GroupInfo* GroupBtnCheck;
		
		if([indexPath section] == 0)
		{
			GroupBtnCheck	= [self.allGroups objectAtIndex:[indexPath row]];
			
		}
		else {
			GroupBtnCheck	= [self.allGroups objectAtIndex:[indexPath row]+1];
			
		}

		int groupid = [GroupBtnCheck.ID intValue];
		if(groupid < 1)
			editButton.enabled = NO;
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		GroupInfo* cellGroup;
		
		NSLog(@"index section = %d", [indexPath section]);
		if([indexPath section] == 0)
		{
			cellGroup = [self.allGroups objectAtIndex:[indexPath row]];
			//		
			
		}
		else {
			cellGroup = [self.allGroups objectAtIndex:[indexPath row]+1];
			//		
			
		}

		
		//		cell.textLabel.text = cellGroup.GROUPTITLE;
	//	titleLabel.text = cellGroup.GROUPTITLE;
		
		NSArray *nameSection = [self.peopleInGroup objectForKey:cellGroup.GROUPTITLE];
			[titleLabel setText:[NSString stringWithFormat:@"%@(%i)", cellGroup.GROUPTITLE ,[nameSection count]]];
		[titleLabel release];
		return cell;
	}
	
	return nil;
}



#pragma mark -
#pragma mark tableView delegate Method

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if(tableView == self.customPlanTableView){
	
		EditAddressCustomCell* customCell = (EditAddressCustomCell*)[tableView cellForRowAtIndexPath:indexPath];
		[customCell checkAction:nil];
//#if TARGET_IPHONE_SIMULATOR		
		NSLog(@"select indexno %i",[indexPath row]);
		NSLog(@"select section %i",[indexPath section]);
//#endif
		
		if(customCell.checked){
			[self.selectedPerson addObject:indexPath];
		}else{
	//		if([self.selectedPerson indexOfObject:indexPath])
			[self.selectedPerson removeObjectAtIndex:[self.selectedPerson indexOfObject:indexPath]];
		}
		
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
	
	if(tableView == self.customGroupTableView) {
		
		
		if([indexPath section] == 0)
		{
			return;
		}
		[self editGroupClicked2:indexPath.row];
		
		
		
		
		
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 58.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 39.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if(tableView == self.customPlanTableView){
		GroupInfo *groupInfo = [self.allGroups objectAtIndex:section];
		
		CustomHeaderView* customHeaderView = [[[CustomHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.customPlanTableView.frame.size.width, 30.0)]autorelease];
		
		if([self convertBoolValue:[self.statusGroup valueForKey:[NSString stringWithFormat:@"%i",section]]])
			customHeaderView.groupFold.image = [UIImage imageNamed:@"btn_close.png"];
		else
			customHeaderView.groupFold.image = [UIImage imageNamed:@"btn_open.png"];
		
		
//		[customHeaderView.groupEdit setImage:[UIImage imageNamed:@"btn_group_community.png"] forState:UIControlStateNormal];
		//section별 그룹인원 구하기
		NSString *key = nil;
		NSArray* nameSection = nil;
//		key = [[self.peopleInGroup allKeys] objectAtIndex:section];
		nameSection = [self.peopleInGroup objectForKey:groupInfo.GROUPTITLE];
		int oncount = 0;
		for(UserInfo* OnOffuser in nameSection){
			if([OnOffuser.ISFRIEND isEqualToString:@"S"]){
				//				if([OnOffuser.IMSTATUS intValue] != 0)
				oncount++;
			}
		}
		
		customHeaderView.groupName.text = [NSString stringWithFormat:@"%@ (%i/%i)",groupInfo.GROUPTITLE, oncount,[nameSection count]];
		
//		customHeaderView.isSearch = NO;
		
		key = nil;
		
		customHeaderView.section = section;
		customHeaderView.folded = [self convertBoolValue:[self.statusGroup valueForKey:[NSString stringWithFormat:@"%i",section]]];
//		[customHeaderView.groupEdit addTarget:self action:@selector(groupEditEvent) forControlEvents:UIControlEventTouchUpInside];
		[customHeaderView addTarget:self action:@selector(editheaderEvent:) forControlEvents:UIControlEventTouchUpInside];
		
		[self.statusGroup setValue:customHeaderView.folded?@"YES":@"NO" forKey:[NSString stringWithFormat:@"%i",section]];
		return customHeaderView;
	}
	return tableView.tableHeaderView;
}
/*
-(void)groupEditEvent{

//	ModalViewController* modalController = [[ModalViewController alloc] init];
	
}*/

-(void)editheaderEvent :(id)sender{
	//	NSLog(@"headerEvent");
	if(self.customPlanTableView.superview != nil){
	CustomHeaderView* addrHeaderView = (CustomHeaderView *)sender;
	addrHeaderView.folded = !addrHeaderView.folded;
	
	//	NSInteger arrayCount = [peopleInGroup count];
	
	//	self.indexSection = addrHeaderView.section;
	//	self.folded = addrHeaderView.folded;
	
	[self.statusGroup setValue:addrHeaderView.folded?@"YES":@"NO" forKey:[NSString stringWithFormat:@"%i",addrHeaderView.section]];
	//	if(addrHeaderView.isSearch){
	//		[self.searchDisplayController.searchResultsTableView reloadData];
	//	}else{
	[self.customPlanTableView reloadData];
	//	}
	}
}




-(void)requestDeleteGroup:(NSString*)include withGroupId:(NSString*)gid{
	
	
	
	
	NSString* revisionPoint = [[NSUserDefaults standardUserDefaults] objectForKey:@"RevisionPoints"];
	
	NSDictionary *bodyObject2 = [NSDictionary dictionaryWithObjectsAndKeys:
								[[self appDelegate] getSvcIdx],@"svcidx",
								(revisionPoint == nil) ? @"0" : revisionPoint, @"RP",
								nil];
	USayHttpData *data2 = [[[USayHttpData alloc]initWithRequestData:@"getLastAfterRP" andWithDictionary:bodyObject2 timeout:10] autorelease];	
	//	assert(data != nil);		
	[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data2];
	
	NSLog(@"gid =  %@", gid);
	
	// TODO: blockView 사용
	editGroupBlock = [[blockView alloc] initWithFrame:CGRectMake(0.0, 0.0, 250.0, 150.0)];
	editGroupBlock.alertText = @"그룹 데이터 통신 중...";
	editGroupBlock.alertDetailText = @"잠시만 기다려 주세요.";
	[editGroupBlock show];
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteGroup:) name:@"deleteGroup" object:nil];
	
	NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:
								[[self appDelegate] getSvcIdx],@"svcidx",
								gid, @"id",
								@"mobile", @"sidDeleted",
								include, @"include",
								nil];
	
	SBJSON *json = [[SBJSON alloc] init];
	[json setHumanReadable:YES];
	NSLog(@"body = %@", bodyObject);
	NSLog(@"deleteGroup >> %@",[json stringWithObject:bodyObject error:nil]);
	[json release];
	USayHttpData *data = [[[USayHttpData alloc]initWithRequestData:@"deleteGroup" andWithDictionary:bodyObject timeout:10]autorelease];	
	//	assert(data != nil);		
	[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
}

-(void)deleteGroup:(NSNotification *)notification {
	NSLog(@"딜리트그룹 노티 왜 안들어오냐??");
	USayHttpData *data = (USayHttpData*)[notification object];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"deleteGroup" object:nil];
	// TODO : blockView제거
	[editGroupBlock dismissAlertView];
	[editGroupBlock release];
	if (data == nil) {
		// 200 이외의 에러
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" 
															message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0009)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
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
	rtcode = [dic objectForKey:@"rtcode"];	// 프로토콜문서에는 result로 되어 있는것을 rtcode로 변경
	if ([rtcode isEqualToString:@"0"]) {	// success
		NSString *rtType = [dic objectForKey:@"rttype"];
		//		NSString *count = [dic objectForKey:@"count"];
		NSString *RP = [dic objectForKey:@"RP"];
		if([rtType isEqualToString:@"list"]){			
			// Key and Dictionary as its value type
			NSArray* userArray = [dic objectForKey:@"list"];
			
			[Editcontroller syncDataBase:userArray withRevisionPoint:RP];
			
		}
		
	} else if ([rtcode isEqualToString:@"-9010"]) {
		// TODO: 데이터를 찾을 수 없음
		//		[editGroupBlock dismissAlertView];
		//		[editGroupBlock release];
	} else if ([rtcode isEqualToString:@"-9020"]) {
		// TODO: 잘못된 인자가 넘어옴
		//		[editGroupBlock dismissAlertView];
		//		[editGroupBlock release];
	} else if ([rtcode isEqualToString:@"-9030"]) {
		// TODO: 처리 오류
		//		[editGroupBlock dismissAlertView];
		//		[editGroupBlock release];
	} else {
		// TODO: 기타오류 예외처리 필요
		//		[editGroupBlock dismissAlertView];
		//		[editGroupBlock release];
	}
	//20101012 빈그룹 삭제시 문제 해결
	[self reloadAddressData];
	//[self.customGroupTableView reloadData];
}


#pragma mark -
#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
    // Change the navigation bar style, also make the status bar match with it
	
	
	NSString *selectedButtonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];  
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteGroup:) name:@"deleteGroup" object:nil];
	
	
	if(Editcontroller == nil || Editcontroller == NULL)
	{
	Editcontroller = [[EditGroupViewController alloc]initWithStyle:UITableViewStyleGrouped];
	Editcontroller.editGroupDelegate = self;
	}
	
	Editcontroller.editGroupInfo = [self.allGroups objectAtIndex:btnIndex];

	
	
	NSLog(@"editGroup = %@", [self.allGroups objectAtIndex:btnIndex]);
	
	NSLog(@"action title = %@", selectedButtonTitle);
	if([selectedButtonTitle isEqualToString:@"그룹만 삭제"])
	{
		Editcontroller.groupDelKind = [NSString stringWithFormat:@"groupDelete"];
		[self requestDeleteGroup:@"N" withGroupId:Editcontroller.editGroupInfo.ID];
	}
	else if([selectedButtonTitle isEqualToString:@"그룹과 주소 모두 삭제"]){
		Editcontroller.groupDelKind = [NSString stringWithFormat:@"allDelete"];
		[self requestDeleteGroup:@"Y" withGroupId:Editcontroller.editGroupInfo.ID];
	}
	else if([selectedButtonTitle isEqualToString:@"삭제하기"])
	{
	
	
	
	//button index 0 : 삭제하기, 1: 취소
	if(buttonIndex == 0){
			
		//cell에서 선택된 유저들을 검출하여 배열로 만든다.
		NSMutableArray* checkedUserList = [NSMutableArray array];
		
		for(NSIndexPath* indexPath in self.selectedPerson){
			GroupInfo *groupInfo = [self.allGroups objectAtIndex:indexPath.section];	
//			NSLog(@"select indexno %i",[indexPath row]);
//			NSLog(@"select section %i",[indexPath section]);
//			NSString *key = [[self.peopleInGroup allKeys] objectAtIndex:[indexPath section]];
			NSArray *nameSection = [self.peopleInGroup objectForKey:groupInfo.GROUPTITLE];
			UserInfo* checkedUser = [nameSection objectAtIndex:[indexPath row]];
			[checkedUserList addObject:checkedUser];
		}
		
		//20101017 
		
		NSString* revisionPoint = [[NSUserDefaults standardUserDefaults] objectForKey:@"RevisionPoints"];
		
		NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:
									[[self appDelegate] getSvcIdx],@"svcidx",
									(revisionPoint == nil) ? @"0" : revisionPoint, @"RP",
									nil];
		USayHttpData *data = [[[USayHttpData alloc]initWithRequestData:@"getLastAfterRP" andWithDictionary:bodyObject timeout:10] autorelease];	
		//	assert(data != nil);		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
		
		
		
		
		
		[self requestDeleteListContact:checkedUserList];
		
	}
	}
}

#pragma mark -
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	
	
	//	NSLog(@"alert button index %i", buttonIndex);
	
//	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark nework Method

 -(BOOL)requestDeleteListContact:(NSArray *)dicData{
 //사용자 정보 저장
	 NSDictionary *rpdict = nil, *contactDic = nil;//, *contactCnt = nil
	 NSString	*body = nil;
	 NSString	*listbody = nil;
	 
	 // TODO: blockView 사용
	 editBlockView = [[blockView alloc] initWithFrame:CGRectMake(0.0, 0.0, 250.0, 150.0)];
	 editBlockView.alertText = @"주소 삭제 중...";
	 editBlockView.alertDetailText = @"잠시만 기다려 주세요.";
	 [editBlockView show];
	 
	 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteListContact:) name:@"deleteListContact" object:nil];
	 
	 NSMutableArray* contactList = [NSMutableArray array];
	 
	 for(UserInfo *userData in dicData){
		 NSMutableDictionary *contact = [NSMutableDictionary dictionary];
		 userData.SIDDELETED = @"mobile";
		 NSAutoreleasePool* varpool = [[NSAutoreleasePool alloc] init];
		 unsigned int numIvars = 0;
		 Ivar* ivars = class_copyIvarList([userData class], &numIvars);
		 for(int i = 0; i < numIvars; i++) {
			 Ivar thisIvar = ivars[i];
			 NSString * key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
	//		 id value = nil;
						 
			if([userData valueForKey:key] != nil){
				if([key isEqualToString:@"ID"] || [key isEqualToString:@"GID"] || 
//				   [key isEqualToString:@"ISFRIEND"] || [key isEqualToString:@"RPKEY"] || 
				   [key isEqualToString:@"SIDDELETED"]){
						[contact setObject:[userData valueForKey:key] forKey:[key lowercaseString]];
					
//				   [key isEqualToString:@"MOBILEPHONENUMBER"] ||
//				   [key isEqualToString:@"HOMEEMAILADDRESS"] || 
//				   [key isEqualToString:@"IPHONENUMBER"] || 
//				   [key isEqualToString:@"ORGEMAILADDRESS"]
				}else {
					continue;
				}
				
			}
		 }
		 if(numIvars > 0)free(ivars);
		 [varpool release];
		 [contactList addObject:contact];
	 }
	 
	 NSMutableArray* paramArray = [NSMutableArray array];

	 rpdict = [NSDictionary dictionaryWithObjectsAndKeys:
			   @"Y", @"toTrash",
			   nil];
	 
	 [paramArray addObject:rpdict];
	 
	 contactDic = [NSDictionary dictionaryWithObjectsAndKeys: 
				   contactList,  @"contact",
				   nil];
	 
	 [paramArray addObject:contactDic];
	 // JSON 라이브러리 생성
	 SBJSON *json = [[SBJSON alloc]init];
	 [json setHumanReadable:YES];
	 // 변환
	 listbody = [json stringWithObject:paramArray error:nil];
	 
	 NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:
								 [[self appDelegate] getSvcIdx],@"svcidx",
								 listbody, @"param",
								 nil];
	 
	 // 변환
	 body = [json stringWithObject:bodyObject error:nil];
	 NSLog(@"%@",body);
	 [json release];
	 USayHttpData *data = [[[USayHttpData alloc]initWithRequestData:@"deleteListContact" andWithDictionary:bodyObject timeout:10]autorelease];	
//	 assert(data != nil);		
	 [[NSNotificationCenter defaultCenter] postNotificationName:@"requestHttp" object:data];
	 return YES;
 }
 
 -(BOOL)deleteListContact:(NSNotification *)notification {
	 
	 USayHttpData *data = (USayHttpData*)[notification object];
	 [[NSNotificationCenter defaultCenter] removeObserver:self name:@"deleteListContact" object:nil];
	 //blockview 제거
	 [editBlockView dismissAlertView];
	 [editBlockView release];
	 if (data == nil) {

		 // 200 이외의 에러
		 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"네트워크 접속 에러" 
															 message:@"Wi-Fi 또는 3G 연결상태가 좋지 않습니다. 연결 상태를 확인해 주세요.(e0018)" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
		 [alertView show];
		 [alertView release];
		 return NO;
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
	 rtcode = [dic objectForKey:@"rtcode"];	// 프로토콜문서에는 result로 되어 있는것을 rtcode로 변경
	 if ([rtcode isEqualToString:@"0"]) {	// success
		 NSString *rtType = [dic objectForKey:@"rttype"];
//		 NSString *count = [dic objectForKey:@"count"];
		 NSString *RP = [dic objectForKey:@"RP"];
		 if([rtType isEqualToString:@"list"]){			
			 // Key and Dictionary as its value type
			 NSArray* userArray = [dic objectForKey:@"list"];
			 
			 [self syncDatabaseDelete:userArray withRevisionPoint:RP];
			 
		 }
		 
		 if([rtType isEqualToString:@"only"]){
			 if([dic objectForKey:@"RP"] != nil){
				 // 처리완료 로직
				 NSString *revisionPoints = [dic objectForKey:@"RP"];  //마지막 동기화 RP
				 [[NSUserDefaults standardUserDefaults] setObject:revisionPoints forKey:@"RevisionPoints"];
			 }
			
		 }
		 
	 } else if ([rtcode isEqualToString:@"-9010"]) {
	 // TODO: 데이터를 찾을 수 없음
//		 [editBlockView dismissAlertView];
//		 [editBlockView release];
	 } else if ([rtcode isEqualToString:@"-9020"]) {
	 // TODO: 잘못된 인자가 넘어옴
//		 [editBlockView dismissAlertView];
//		 [editBlockView release];
	 } else if ([rtcode isEqualToString:@"-9030"]) {
	 // TODO: 처리 오류
//		 [editBlockView dismissAlertView];
//		 [editBlockView release];
	 } else {
	 // TODO: 기타오류 예외처리 필요
//		 [editBlockView dismissAlertView];
//		 [editBlockView release];
	 }
	 return YES;
 }
 
#pragma mark -
#pragma mark  sync database Method

NSInteger IndexPathSort(id object1, id object2, void *reverse)
{
    if ((NSInteger *)reverse == NO) {
        return [object2 compare:object1];
    }
    return [object1 compare:object2];
}

-(NSArray*)sortIndexPathArray:(NSMutableArray*)sortArray {
	NSArray* sortedArray = [NSArray array];
/*	
	NSSet *set = [NSSet setWithArray:sortArray];
//	[array release];
	NSMutableArray *sortedArray =
	[[NSMutableArray alloc] initWithCapacity:[set count]];
	for(NSIndexPath *num in set)
		[sortedArray addObject:num];
	[sortedArray sortedArrayUsingComparator:@selector(compare:)];
	NSLog(@"%@",[set description]);
	NSLog(@"%@",[sortedArray description]);
//	[marray release];
*/
	int reverseSort = NO;
	sortedArray = [sortArray sortedArrayUsingFunction:IndexPathSort context:&reverseSort];
	
	return sortedArray;
}


-(void)syncDatabaseDelete:(NSArray*)userArray withRevisionPoint:(NSString*)revisionPoint {
	
	
	for(NSDictionary* delItem in userArray){
		if([[delItem objectForKey:@"id"] length]>0){// 해당 아이디 삭제
			NSString* UserId = [delItem objectForKey:@"id"];
			NSString* sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE ID=?",[UserInfo tableName]];
			DebugLog(@"delete sql = %@", sql);
			[UserInfo findWithSqlWithParameters:sql, UserId, nil];
		}
	}

	//cell에서 선택된 유저들을 검출하여 배열로 만든다.
	NSMutableArray* deleteUserList = [NSMutableArray array];
	 
	NSMutableArray* deleteIndexPath = [NSMutableArray array];
	 NSArray* selectedIndexPath = [self sortIndexPathArray:self.selectedPerson];
	BOOL existVisibleCell = NO;
	if(self.customPlanTableView.superview != nil){
		for(int i = [selectedIndexPath count]-1;i >= 0 ;i--){
			NSIndexPath* indexPath = [selectedIndexPath objectAtIndex:i];
			GroupInfo *groupInfo = [self.allGroups objectAtIndex:indexPath.section];
	//		NSString *key = [[self.peopleInGroup allKeys] objectAtIndex:[indexPath section]];
			NSMutableArray *nameSection = [self.peopleInGroup objectForKey:groupInfo.GROUPTITLE];
//			NSLog(@"key %@ syncDelete %i namesection 카운트 %i",groupInfo.GROUPTITLE, [indexPath row], [nameSection count]);
			for(UserInfo* userList in nameSection){
				[deleteUserList addObject:[nameSection objectAtIndex:[indexPath row]]];
			}
			[nameSection removeObjectAtIndex:[indexPath row]];
			
			EditAddressCustomCell* cell = (EditAddressCustomCell*)[self.customPlanTableView cellForRowAtIndexPath:indexPath];
			if(cell != nil){
				existVisibleCell = YES;
				[deleteIndexPath addObject:indexPath];
			}
		}
		if(existVisibleCell){
//			[self.customPlanTableView beginUpdates];
//			[self.customPlanTableView deleteRowsAtIndexPaths:(NSArray*)deleteIndexPath withRowAnimation:NO];
//			[self.customPlanTableView endUpdates];	
		}
	}
	
	[self.selectedPerson removeAllObjects];
	//데이터 베이스에 저장후 마지막 동기화 포인트 저장
	if(revisionPoint != nil && [revisionPoint length] > 0){
		if([revisionPoint intValue] > [[[NSUserDefaults standardUserDefaults] objectForKey:@"RevisionPoints"] intValue]){
			NSString* revisionPoints = [[NSString alloc] initWithFormat:@"%@",revisionPoint];
			[[NSUserDefaults standardUserDefaults] setObject:revisionPoints forKey:@"RevisionPoints"];
			[revisionPoints release];
		}
		
	}
	
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	NSLocale *locale = [NSLocale currentLocale];
	[formatter setLocale:locale];
	[formatter setDateFormat:@"yyyyMMddHHmmss"];
	NSDate *today = [NSDate date];
	NSString *lastSyncDate = [[NSString alloc] initWithFormat:@"%@",[formatter stringFromDate:today]];
	
	if(revisionPoint != nil && [revisionPoint length] > 0){
		[[NSUserDefaults standardUserDefaults] setObject:lastSyncDate forKey:@"lastSyncDate"];
	}
	
	[lastSyncDate release];
	[formatter release];
	
	[self.customPlanTableView reloadData];
	// TODO : blockview 삭제
//	[editBlockView dismissAlertView];
//	[editBlockView release];
//	[self.editDelegate deleteUserListWithArray:deleteUserList];
}

@end
