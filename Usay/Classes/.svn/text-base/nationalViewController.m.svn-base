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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
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

-(void)backBarButtonClicked
{
	[self.navigationController popViewControllerAnimated:YES];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	
	
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
	
	
	nationalTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height-44) style:UITableViewStylePlain];
	[self.view addSubview:nationalTableView];
	nationalDataArray = [[NSMutableArray alloc] init];
	
	
	/*
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"082", @"code",
								  @"대한민국", @"national",
								  nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"002", @"code",
								  @"일본", @"national",
								  nil]];
	
	*/
	
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"93",@"code",@"Afghanistan", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"355",@"code",@"Albania", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"213",@"code",@"Algeria", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1684",@"code",@"American Samoa", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"376",@"code",@"Andorra", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"244",@"code",@"Angola", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1264",@"code",@"Anguilla", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"672",@"code",@"Antarctica", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1268",@"code",@"Antigua and Barbuda", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"54",@"code",@"Argentina", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"374",@"code",@"Armenia", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"297",@"code",@"Aruba", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"61",@"code",@"Australia", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"43",@"code",@"Austria", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"994",@"code",@"Azerbaijan", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1242",@"code",@"Bahamas", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"973",@"code",@"Bahrain", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"880",@"code",@"Bangladesh", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1246",@"code",@"Barbados", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"375",@"code",@"Belarus", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"32",@"code",@"Belgium", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"501",@"code",@"Belize", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"229",@"code",@"Benin", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1441",@"code",@"Bermuda", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"975",@"code",@"Bhutan", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"591",@"code",@"Bolivia", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"387",@"code",@"Bosnia and Herzegovina", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"267",@"code",@"Botswana", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"55",@"code",@"Brazil", @"national", nil]];
	
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1284",@"code",@"British Virgin Islands", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"673",@"code",@"Brunei", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"359",@"code",@"Bulgaria", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"226",@"code",@"Burkina Faso", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"95",@"code",@"Burma (Myanmar)", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"257",@"code",@"Burundi", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"855",@"code",@"Cambodia", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"237",@"code",@"Cameroon", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1",@"code",@"Canada", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"238",@"code",@"Cape Verde", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1345",@"code",@"Cayman Islands", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"236",@"code",@"Central African Republic", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"235",@"code",@"Chad", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"56",@"code",@"Chile", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"86",@"code",@"China", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"61",@"code",@"Christmas Island", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"61",@"code",@"Cocos (Keeling) Islands", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"57",@"code",@"Colombia", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"269",@"code",@"Comoros", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"682",@"code",@"Cook Islands", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"506",@"code",@"Costa Rica", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"385",@"code",@"Croatia", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"53",@"code",@"Cuba", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"357",@"code",@"Cyprus", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"420",@"code",@"Czech Republic", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"243",@"code",@"Democratic Republic of the Congo", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"45",@"code",@"Denmark", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"253",@"code",@"Djibouti", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1767",@"code",@"Dominica", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1809",@"code",@"Dominican Republic", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"593",@"code",@"Ecuador", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"20",@"code",@"Egypt", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"503",@"code",@"El Salvador", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"240",@"code",@"Equatorial Guinea", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"291",@"code",@"Eritrea", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"372",@"code",@"Estonia", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"251",@"code",@"Ethiopia", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"500",@"code",@"Falkland Islands", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"298",@"code",@"Faroe Islands", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"679",@"code",@"Fiji", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"358",@"code",@"Finland", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"33",@"code",@"France", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"689",@"code",@"French Polynesia", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"241",@"code",@"Gabon", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"220",@"code",@"Gambia", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"970",@"code",@"Gaza Strip", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"995",@"code",@"Georgia", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"49",@"code",@"Germany", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"233",@"code",@"Ghana", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"350",@"code",@"Gibraltar", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"30",@"code",@"Greece", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"299",@"code",@"Greenland", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1473",@"code",@"Grenada", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1671",@"code",@"Guam", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"502",@"code",@"Guatemala", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"224",@"code",@"Guinea", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"245",@"code",@"Guinea-Bissau", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"592",@"code",@"Guyana", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"509",@"code",@"Haiti", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"39",@"code",@"Holy See (Vatican City)", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"504",@"code",@"Honduras", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"852",@"code",@"Hong Kong", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"36",@"code",@"Hungary", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"354",@"code",@"Iceland", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"91",@"code",@"India", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"62",@"code",@"Indonesia", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"98",@"code",@"Iran", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"964",@"code",@"Iraq", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"353",@"code",@"Ireland", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"44",@"code",@"Isle of Man", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"972",@"code",@"Israel", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"39",@"code",@"Italy", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"225",@"code",@"Ivory Coast", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1876",@"code",@"Jamaica", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"81",@"code",@"Japan", @"national", nil]];

	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"962",@"code",@"Jordan", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"7",@"code",@"Kazakhstan", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"254",@"code",@"Kenya", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"686",@"code",@"Kiribati", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"381",@"code",@"Kosovo", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"965",@"code",@"Kuwait", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"996",@"code",@"Kyrgyzstan", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"856",@"code",@"Laos", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"371",@"code",@"Latvia", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"961",@"code",@"Lebanon", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"266",@"code",@"Lesotho", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"231",@"code",@"Liberia", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"218",@"code",@"Libya", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"423",@"code",@"Liechtenstein", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"370",@"code",@"Lithuania", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"352",@"code",@"Luxembourg", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"853",@"code",@"Macau", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"389",@"code",@"Macedonia", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"261",@"code",@"Madagascar", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"265",@"code",@"Malawi", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"60",@"code",@"Malaysia", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"960",@"code",@"Maldives", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"223",@"code",@"Mali", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"356",@"code",@"Malta", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"692",@"code",@"Marshall Islands", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"222",@"code",@"Mauritania", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"230",@"code",@"Mauritius", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"262",@"code",@"Mayotte", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"52",@"code",@"Mexico", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"691",@"code",@"Micronesia", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"373",@"code",@"Moldova", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"377",@"code",@"Monaco", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"976",@"code",@"Mongolia", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"382",@"code",@"Montenegro", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1664",@"code",@"Montserrat", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"212",@"code",@"Morocco", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"258",@"code",@"Mozambique", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"264",@"code",@"Namibia", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"674",@"code",@"Nauru", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"977",@"code",@"Nepal", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"31",@"code",@"Netherlands", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"599",@"code",@"Netherlands Antilles", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"687",@"code",@"New Caledonia", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"64",@"code",@"New Zealand", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"505",@"code",@"Nicaragua", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"227",@"code",@"Niger", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"234",@"code",@"Nigeria", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"683",@"code",@"Niue", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"672",@"code",@"Norfolk Island", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"850",@"code",@"North Korea", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1670",@"code",@"Northern Mariana Islands", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"47",@"code",@"Norway", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"968",@"code",@"Oman", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"92",@"code",@"Pakistan", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"680",@"code",@"Palau", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"507",@"code",@"Panama", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"675",@"code",@"Papua New Guinea", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"595",@"code",@"Paraguay", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"51",@"code",@"Peru", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"63",@"code",@"Philippines", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"870",@"code",@"Pitcairn Islands", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"48",@"code",@"Poland", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"351",@"code",@"Portugal", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1",@"code",@"Puerto Rico", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"974",@"code",@"Qatar", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"242",@"code",@"Republic of the Congo", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"40",@"code",@"Romania", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"7",@"code",@"Russia", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"250",@"code",@"Rwanda", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"590",@"code",@"Saint Barthelemy", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"290",@"code",@"Saint Helena", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1869",@"code",@"Saint Kitts and Nevis", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1758",@"code",@"Saint Lucia", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1599",@"code",@"Saint Martin", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"508",@"code",@"Saint Pierre and Miquelon", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1784",@"code",@"Saint Vincent and the Grenadines", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"685",@"code",@"Samoa", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"378",@"code",@"San Marino", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"239",@"code",@"Sao Tome and Principe", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"966",@"code",@"Saudi Arabia", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"221",@"code",@"Senegal", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"381",@"code",@"Serbia", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"248",@"code",@"Seychelles", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"232",@"code",@"Sierra Leone", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"65",@"code",@"Singapore", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"421",@"code",@"Slovakia", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"386",@"code",@"Slovenia", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"677",@"code",@"Solomon Islands", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"252",@"code",@"Somalia", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"27",@"code",@"South Africa", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"82",@"code",@"South Korea", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"34",@"code",@"Spain", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"94",@"code",@"Sri Lanka", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"249",@"code",@"Sudan", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"597",@"code",@"Suriname", @"national", nil]];
	
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"268",@"code",@"Swaziland", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"46",@"code",@"Sweden", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"41",@"code",@"Switzerland", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"963",@"code",@"Syria", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"886",@"code",@"Taiwan", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"992",@"code",@"Tajikistan", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"255",@"code",@"Tanzania", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"66",@"code",@"Thailand", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"670",@"code",@"Timor-Leste", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"228",@"code",@"Togo", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"690",@"code",@"Tokelau", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"676",@"code",@"Tonga", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1868",@"code",@"Trinidad and Tobago", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"216",@"code",@"Tunisia", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"90",@"code",@"Turkey", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"993",@"code",@"Turkmenistan", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1649",@"code",@"Turks and Caicos Islands", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"688",@"code",@"Tuvalu", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"256",@"code",@"Uganda", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"380",@"code",@"Ukraine", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"971",@"code",@"United Arab Emirates", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"44",@"code",@"United Kingdom", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1",@"code",@"United States", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"598",@"code",@"Uruguay", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1340",@"code",@"US Virgin Islands", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"998",@"code",@"Uzbekistan", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"678",@"code",@"Vanuatu", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"58",@"code",@"Venezuela", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"84",@"code",@"Vietnam", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"681",@"code",@"Wallis and Futuna", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"970",@"code",@"West Bank", @"national", nil]];
	
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"967",@"code",@"Yemen", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"260",@"code",@"Zambia", @"national", nil]];
	[nationalDataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"263",@"code",@"Zimbabwe", @"national", nil]];
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
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
