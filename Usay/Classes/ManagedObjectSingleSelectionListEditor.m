#import "ManagedObjectSingleSelectionListEditor.h"
//#import "MyDeviceClass.h"		// sochae 2010.09.11 - UI Position

#import "USayAppAppDelegate.h"
#import "AddressViewController.h"
#import "USayDefine.h"

#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
@implementation ManagedObjectSingleSelectionListEditor
@synthesize list, selectType, defaultValue, selectedGroup, selectedValue, peopleInGroup;

-(void)groupSelectCompleted {

	if([self.selectedGroup count] >0){
		NSIndexPath* oldIndexPath = [self.selectedGroup objectAtIndex:0];
//		oldRow = [oldIndexPath row];
		
	//	UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:oldIndexPath];
	//	NSString *newValue = selectedCell.textLabel.text;

		NSString *newValue = [list objectAtIndex:[oldIndexPath row]];
		DebugLog(@"newValue = %@ %d", newValue, [newValue length]);
		
		
	
		[self updateDataValue:newValue forkey:self.keypath];
	}
//	[self.tableView reloadData];
/*	
	USayAppAppDelegate *parentView = (USayAppAppDelegate*)[[UIApplication sharedApplication] delegate];
	UINavigationController *tmp = [parentView.rootController.viewControllers objectAtIndex:0];
	AddressViewController *tmpAdd = (AddressViewController*)[tmp.viewControllers objectAtIndex:0];
	[tmpAdd reloadAddressData];	
	[tmpAdd.currentTableView reloadData];
*/	
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)updateDataValue:(NSString*)value forkey:(NSString*)key {
	[self.delegate updateDataValue:value forkey:key];
}

-(void)updateDataWithArray:(NSArray*)value forkey:(NSString*)key{
	[self.delegate updateDataWithArray:value forkey:key];
}

-(void)viewDidLoad{
	self.view.backgroundColor = ColorFromRGB(0xedeff2);
	
	USayAppAppDelegate *parentView = (USayAppAppDelegate*)[[UIApplication sharedApplication] delegate];
	
	
	UINavigationController *tmp = [parentView.rootController.viewControllers objectAtIndex:0];
	
		
	
	AddressViewController *tmpAdd = (AddressViewController*)[tmp.viewControllers objectAtIndex:0];
	[tmpAdd reloadAddressData];
	
	
	
	peopleInGroup = tmpAdd.peopleInGroup;
	
//	DebugLog(@"people %@", peopleInGroup);
	
	
	
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated 
{
	DebugLog(@"appear will selectindex");
	
	

	UIImage* rightBarBtnImg = [[UIImage imageNamed:@"btn_top_complete.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	UIImage* rightBarBtnSelImg = [[UIImage imageNamed:@"btn_top_complete_focus.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[rightBarButton addTarget:self action:@selector(groupSelectCompleted) forControlEvents:UIControlEventTouchUpInside];
	[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
	[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
	rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
	self.navigationItem.rightBarButtonItem = rightButton;
	[rightButton release];

	// sochae 2010.09.05 - memory leak
	if( self.selectedGroup != nil)
		[self.selectedGroup release];
	// ~sochae
	self.selectedGroup = [[NSMutableArray alloc] init];
	
	NSString *currentValue = nil;
	if(selectedValue != nil && [selectedValue length] > 0)
		currentValue = selectedValue;
	else
	currentValue = @"그룹미지정";//	currentValue = @"새로 등록한 주소";
	
    for (NSString *oneItem in list) {
        if ([oneItem isEqualToString:currentValue]) {
            NSUInteger newIndex[] = {0, [list indexOfObject:oneItem]};
            NSIndexPath *newPath = [[NSIndexPath alloc] initWithIndexes:newIndex length:2];
			[self.selectedGroup addObject:newPath];
			[newPath release];//mezzo
			break;
        }
    }
	
	UIView* customView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 
																  self.tableView.frame.size.width, 35.0)] autorelease];
//	customView.backgroundColor = [UIColor clearColor];
//	UIImageView* customImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"text_sel_group.png"]];
//	customImageView.frame = CGRectMake(0.0, 5.0, 
//									   self.tableView.frame.size.width, 33.0);
	// sochae 2010.09.11 - UI Position
	//CGRect rect = [MyDeviceClass deviceOrientation];
	CGRect rect = self.view.frame;
	// ~sochae
	UIFont *informationFont = [UIFont systemFontOfSize:15];
	CGSize infoStringSize = [@"그룹을 선택해 주세요." sizeWithFont:informationFont constrainedToSize:(CGSizeMake(rect.size.width-30.0, 20.0f))];
	UILabel *informationLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 13, rect.size.width-40.0, infoStringSize.height)];
	[informationLabel setFont:informationFont];
	[informationLabel setTextColor:ColorFromRGB(0x313b48)];
	[informationLabel setBackgroundColor:[UIColor clearColor]];
	[informationLabel setText:@"그룹을 선택해 주세요."];
	[customView addSubview:informationLabel];
	[informationLabel release];
	
//	[customView addSubview:customImageView];
	self.tableView.tableHeaderView = customView;
//mezzo	[customView release];
	
	
    [super viewWillAppear:animated];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Relinquish ownership any cached data, images, etc that aren't in use.
}
- (void)dealloc {
    [list release];
	[selectType release];
	[defaultValue release];
	[selectedGroup release];
    [super dealloc];
}
#pragma mark -
#pragma mark Table View Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [list count];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSUInteger row = [indexPath row];
	if([self.selectedGroup count] > 0){
		NSIndexPath* oldIndexPath = [self.selectedGroup objectAtIndex:0];
		if(row != [oldIndexPath row]){
			UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
			oldCell.accessoryType = UITableViewCellAccessoryNone;
			oldCell.accessoryView = nil;
			oldCell.textLabel.textColor = ColorFromRGB(0x285f7a);
			[self.selectedGroup removeObjectAtIndex:[self.selectedGroup indexOfObject:oldIndexPath]];
			
			UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
			newCell.accessoryType = UITableViewCellAccessoryCheckmark;
			newCell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CheckIcon.png"]]autorelease];
			newCell.textLabel.textColor = ColorFromRGB(0x7c7c86);
			[self.selectedGroup addObject:indexPath];
		}
	}else {
		UITableViewCell *beginCell = [tableView cellForRowAtIndexPath:indexPath];
		beginCell.accessoryType = UITableViewCellAccessoryCheckmark;
		beginCell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CheckIcon.png"]]autorelease];
		beginCell.textLabel.textColor = ColorFromRGB(0x7c7c86);
		[self.selectedGroup addObject:indexPath];
	}
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *GenericManagedObjectListSelectorCell = @"GenericManagedObjectListSelectorCell";

    NSIndexPath* oldIndexPath = [self.selectedGroup objectAtIndex:0];
	NSUInteger row = [indexPath row];
    NSUInteger oldRow = [oldIndexPath row];
	
    UITableViewCell *cell = [tableView 
                             dequeueReusableCellWithIdentifier:GenericManagedObjectListSelectorCell];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:GenericManagedObjectListSelectorCell] autorelease];
		if([self.passDefaultValue isEqualToString:[list objectAtIndex:row]]){
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
			cell.textLabel.textColor = ColorFromRGB(0x7c7c86);
			cell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CheckIcon.png"]]autorelease];

		}
    }
    
	
	
	NSArray *nameSection = [self.peopleInGroup objectForKey:[list objectAtIndex:row]];
	DebugLog(@"namesection %d", [nameSection count]);
	
	
//    cell.textLabel.text = [list objectAtIndex:row];
	cell.textLabel.text = [NSString stringWithFormat:@"%@(%i)", [list objectAtIndex:row], [nameSection count]];

	// sochae 2010.10.15 - 원래 주석되어 있던 부분이 맞는데, 왜 주석처리 했는지... 주석 해지.
//	DebugLog(@"그룹 명은? %@", [list objectAtIndex:row]);
 //   cell.textLabel.text = [list objectAtIndex:row];
//	cell.textLabel.text = [NSString stringWithFormat:@"%i", [list objectAtIndex:row], [nameSection count]];
	// ~sochae
//>>>>>>> .r412
	cell.textLabel.textColor = ColorFromRGB(0x285f7a);
//	if([selectType isEqualToString:@"single"])
	if(row == oldRow){
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		cell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CheckIcon.png"]]autorelease];
	}else{
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.accessoryView = nil;
	}
    
	return cell;
}
@end
