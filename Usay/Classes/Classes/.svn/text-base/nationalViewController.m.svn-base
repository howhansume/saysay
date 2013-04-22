    //
//  nationalViewController.m
//  USayApp
//
//  Created by ku jung on 10. 10. 24..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "nationalViewController.h"
#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@implementation nationalViewController
@synthesize parent;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
	NSLog(@"cont  = %d",[nationalDataArray count]);
	//return 5;
		return [nationalDataArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"addGroupCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
	cell.textLabel.text=[[nationalDataArray objectAtIndex:indexPath.row] objectForKey:@"national"];
	
	cell.textLabel.font=[UIFont systemFontOfSize:15];
	
	UILabel *codeLabel = [[UILabel alloc] initWithFrame:CGRectMake(320-80, 5, 70, 44-10)];
	codeLabel.text=[[nationalDataArray objectAtIndex:indexPath.row] objectForKey:@"code"];
	[cell addSubview:codeLabel];
	
	
	codeLabel.font =[UIFont systemFontOfSize:15];
	codeLabel.textColor=[UIColor colorWithRed:40.0/255.0 green:95.0/255.0 blue:122.0/255.0 alpha:1.0f];
	codeLabel.textAlignment =UITextAlignmentRight;
	[codeLabel release];
	
	
	
	
	
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
	NSLog(@"parent = %@", parent);

	[parent codeName:[[nationalDataArray objectAtIndex:indexPath.row] objectForKey:@"national"]
			 codeNum:[[nationalDataArray objectAtIndex:indexPath.row] objectForKey:@"code"]];
	[self.navigationController popViewControllerAnimated:YES];
	
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
//	UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
	UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];

	UIFont *titleFont = [UIFont systemFontOfSize:20];
	UILabel *naviTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(-20, 0, 320-65, 44)];
	[naviTitleLabel setFont:titleFont];
	naviTitleLabel.textAlignment = UITextAlignmentCenter;
	[naviTitleLabel setTextColor:ColorFromRGB(0x053844)];
	[naviTitleLabel setBackgroundColor:[UIColor clearColor]];
	[naviTitleLabel setText:@"국가 번호 선택"];
	[titleView addSubview:naviTitleLabel];
	self.navigationItem.titleView=titleView;
	[titleView release];
	[naviTitleLabel release];
	
	
	nationalTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 460) style:UITableViewStylePlain];
	[self.view addSubview:nationalTableView];
	nationalDataArray = [[NSMutableArray alloc] init];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"082", @"code",
								  @"대한민국", @"national",
								  nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"002", @"code",
								  @"일본", @"national",
								  nil]];
	
	
	
	NSLog(@"cont  = %d",[nationalDataArray count]);

	NSLog(@"aaa");
	
	nationalTableView.dataSource=self;
	nationalTableView.delegate=self;
	
	[self.view addSubview:nationalTableView];
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
}


- (void)dealloc {
    [super dealloc];
}


@end
