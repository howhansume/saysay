    //
//  webjoinViewController.m
//  USayApp
//
//  Created by ku jung on 10. 12. 7..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "webjoinViewController.h"


#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation webjoinViewController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

-(void)backBarButtonClicked
{
	[self.navigationController popToRootViewControllerAnimated:YES];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	
	UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 44)];
	UIFont *titleFont = [UIFont systemFontOfSize:20];
	//	CGSize titleStringSize = [@"주소록 동기화" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
	UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 210, 44)];
	[titleLabel setFont:titleFont];
	titleLabel.textAlignment = UITextAlignmentCenter;
	[titleLabel setTextColor:ColorFromRGB(0x053844)];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	[titleLabel setText:@"Web과 동기화"];
	
	
	
	UIImage* leftBarBtnImg = [UIImage imageNamed:@"btn_top_left.png"];
	UIImage* leftBarBtnSelImg = [UIImage imageNamed:@"btn_top_left_focus.png"];
	UIButton* leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[leftBarButton addTarget:self action:@selector(backBarButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
	[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateSelected];
	[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateDisabled];
	leftBarButton.frame = CGRectMake(0.0, 0.0, leftBarBtnImg.size.width, leftBarBtnImg.size.height);
	UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
	self.navigationItem.leftBarButtonItem = leftButton;
	
	
	
	[titleView addSubview:titleLabel];	
	[titleLabel release];
	self.navigationItem.titleView = titleView;
	[titleView release];
	
	UIButton *roundButton =[UIButton buttonWithType:UIButtonTypeRoundedRect];
	NSString *ID =  [[NSUserDefaults standardUserDefaults] objectForKey:@"usayID"];
	roundButton.frame=CGRectMake(15, 10, 290, 40);
	//[roundButton setTitle:ID forState:UIControlStateDisabled];
	
	
	
	roundButton.titleLabel.textAlignment=UITextAlignmentLeft;
	
	UILabel *idLabel =[[UILabel alloc] initWithFrame:CGRectMake(20, 10, 200, 40)];
	[idLabel setBackgroundColor:[UIColor clearColor]];
	idLabel.textAlignment=UITextAlignmentLeft;
	idLabel.text=ID;
	idLabel.font=[UIFont systemFontOfSize:14];
	UILabel *connectLabel =[[UILabel alloc] initWithFrame:CGRectMake(200+20, 10, 50+50, 40)];
	connectLabel.textAlignment=UITextAlignmentCenter;
	connectLabel.text=@"연결됨";
	connectLabel.textColor=[UIColor redColor];
	connectLabel.backgroundColor=[UIColor clearColor];
	
	
	
	
	
	
	
	
	
	
	
	roundButton.enabled = NO;
	
	[self.view addSubview:roundButton];
	[self.view addSubview:idLabel];
	[idLabel release];
	[self.view addSubview:connectLabel];
	
	//release 2010.12.28
	[connectLabel release];
	
	//	[roundButton release];

	
	UILabel *explanLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10+40, 290, 40)];
	
	explanLabel.textAlignment=UITextAlignmentCenter;
	
	explanLabel.text=@"위의 아이디로 Usay.net과 연동되었습니다.";
	explanLabel.font=[UIFont systemFontOfSize:13];
	
	
	explanLabel.backgroundColor=[UIColor clearColor];
	
	
	[self.view addSubview:explanLabel];
	[explanLabel release];
	
	
	
	
	self.view.backgroundColor = ColorFromRGB(0xedeff2);	
	
	
	
	
	
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
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
