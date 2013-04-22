//
//  termsViewController.m
//  USayApp
//
//  Created by Yoon Sung Hwan on 11. 4. 2..
//  Copyright 2011 INAMASS.NET. All rights reserved.
//

#import "termsViewController.h"

#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@implementation termsViewController
@synthesize tab01, tab02, htmlView;

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
//*/


- (void)dealloc
{
    [htmlView release];

    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

- (void)selectTab:(UIButton *)sender
{
    //    NSLog(@"selectTab = %@", sender.tag);
    
    if (sender.tag  == 100) {
        [tab01 setBackgroundImage:[UIImage imageNamed:@"7_cond_1_1.png"] forState:UIControlStateNormal];
        [tab01 setTitleColor:ColorFromRGB(0x333333) forState:UIControlStateNormal];
        
 		[tab02 setBackgroundImage:[UIImage imageNamed:@"7_cond_1_2.png"] forState:UIControlStateNormal];
        [tab02 setTitleColor:ColorFromRGB(0x666666) forState:UIControlStateNormal];
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"m_app" ofType:@"html"];
        NSStringEncoding encoding;
        NSError* error;
        NSString* body = [NSString stringWithContentsOfFile:filePath usedEncoding:&encoding error:&error];
        
        [htmlView loadHTMLString:body baseURL:nil];
    }
    else if (sender.tag == 101) {
        [tab01 setBackgroundImage:[UIImage imageNamed:@"7_cond_2_1.png"] forState:UIControlStateNormal];
        [tab01 setTitleColor:ColorFromRGB(0x666666) forState:UIControlStateNormal];
        
 		[tab02 setBackgroundImage:[UIImage imageNamed:@"7_cond_2_2.png"] forState:UIControlStateNormal];
        [tab02 setTitleColor:ColorFromRGB(0x333333) forState:UIControlStateNormal];    
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"m_app_02" ofType:@"html"];
        NSStringEncoding encoding;
        NSError* error;
        NSString* body = [NSString stringWithContentsOfFile:filePath usedEncoding:&encoding error:&error];
        
        [htmlView loadHTMLString:body baseURL:nil];       
    }
    
}


//*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 44)];
    UIFont *titleFont = [UIFont systemFontOfSize:18];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 250, 44)];
    [titleLabel setFont:titleFont];
    titleLabel.textAlignment = UITextAlignmentCenter;
    [titleLabel setTextColor:ColorFromRGB(0x053844)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setText:@"Usay약관/개인정보취급방침"];
    
    
    [titleView addSubview:titleLabel];	
    [titleLabel release];
    self.navigationItem.titleView = titleView;
    [titleView release];
    
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
    [leftButton release];
    
    // 상단 탭 영역
    tab01  = [UIButton buttonWithType:UIButtonTypeCustom];
    tab01.tag=100;
    [tab01 setBackgroundImage:[UIImage imageNamed:@"7_cond_1_1.png"] forState:UIControlStateNormal];
    [tab01 addTarget:self action:@selector(selectTab:) forControlEvents:UIControlEventTouchUpInside];
    tab01.frame=CGRectMake(0, 0, 160, 39);        
    tab01.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
    tab01.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    [tab01 setTitle:@"서비스 이용약관" forState:UIControlStateNormal];
    [tab01.titleLabel setFont:[UIFont fontWithName:@"AppleGothic" size:14.0f]];
    [tab01 setTitleColor:ColorFromRGB(0x333333) forState:UIControlStateNormal];
    [tab01 setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 0.0f)];
    [self.view addSubview:tab01];
    
    
    tab02  = [UIButton buttonWithType:UIButtonTypeCustom];
    tab02.tag=101;
    [tab02 setBackgroundImage:[UIImage imageNamed:@"7_cond_1_2.png"] forState:UIControlStateNormal];
    [tab02 addTarget:self action:@selector(selectTab:) forControlEvents:UIControlEventTouchUpInside];
    tab02.frame=CGRectMake(160, 0, 160, 39);
    [tab02 setTitle:@"개인정보 취급 방침" forState:UIControlStateNormal];
    [tab02.titleLabel setFont:[UIFont fontWithName:@"AppleGothic" size:14.0f]];
    [tab02 setTitleColor:ColorFromRGB(0x666666) forState:UIControlStateNormal];
    [tab02 setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 12.0f)];
    [self.view addSubview:tab02];
    
    htmlView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 40, 320, 480-64-40)];

    htmlView.tag = 0;
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"m_app" ofType:@"html"];
	NSStringEncoding encoding;
	NSError* error;
	NSString* body = [NSString stringWithContentsOfFile:filePath usedEncoding:&encoding error:&error];
	
	[htmlView loadHTMLString:body baseURL:nil];
	[self.view addSubview:htmlView];
	[htmlView setBackgroundColor:ColorFromRGB(0xFFFFFF)];
	

}
//*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)backBarButtonClicked
{
	[self.navigationController popViewControllerAnimated:YES];
}


@end
