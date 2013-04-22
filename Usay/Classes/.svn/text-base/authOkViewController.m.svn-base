//
//  authOkViewController.m
//  USayApp
//
//  Created by Yoon Sung Hwan on 11. 4. 2..
//  Copyright 2011 INAMASS.NET. All rights reserved.
//

#import "authOkViewController.h"
#import "synchronizationViewController.h"
#import "termsViewController.h"

#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@implementation authOkViewController
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

-(void)StartClick
{
    if (flag == FALSE) {
		UIAlertView *agreeAlert = [[UIAlertView alloc] initWithTitle:@"약관 동의" message:@"약관 및 개인정보 취급방침에\n동의해주세요."
															delegate:self cancelButtonTitle:@"확인"
                                                   otherButtonTitles:nil, nil];
		[agreeAlert show];
		[agreeAlert release];
	}
	else
	{
		// 폰 번호 인증.
        synchronizationViewController *outputView =[[synchronizationViewController alloc] init];
        outputView.hidesBottomBarWhenPushed= YES;
        
        [self.navigationController pushViewController:outputView animated:YES];
        [outputView release];
	}
}

-(void) TermsClick
{
    termsViewController *termsView =[[termsViewController alloc] init];
	termsView.hidesBottomBarWhenPushed= YES;
	
	[self.navigationController pushViewController:termsView animated:YES];
	[termsView release];
}

//*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    flag =FALSE;
    
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 44)];
    UIFont *titleFont = [UIFont systemFontOfSize:20];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 250, 44)];
    [titleLabel setFont:titleFont];
    titleLabel.textAlignment = UITextAlignmentCenter;
    [titleLabel setTextColor:ColorFromRGB(0x053844)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setText:@"Usay 주소록 시작"];
    
    
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

    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    bgView.backgroundColor = ColorFromRGB(0xffffbb5);
    [self.view addSubview:bgView];
    [bgView release];

    UIImageView *lineView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"line_img.png"] stretchableImageWithLeftCapWidth:3 topCapHeight:1]];
    lineView.backgroundColor = [UIColor clearColor];
    lineView.frame=CGRectMake(0, 44, 320, 1);
    
    [self.view addSubview:lineView];
    [lineView release];

    UILabel *Label01 = [[UILabel alloc] initWithFrame:CGRectMake(21, 12, 320-42, 20)];
    Label01.textColor=ColorFromRGB(0x616152);
    Label01.textAlignment=UITextAlignmentCenter;
    Label01.font=[UIFont systemFontOfSize:14];
    Label01.text=@"파란 회원 가입이 완료되었습니다!";
    Label01.numberOfLines=1;
    Label01.lineBreakMode=YES;
    [Label01 setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:Label01];
    [Label01 release];	
    
    UIImageView	 *logoImg = [[UIImageView alloc] initWithFrame:CGRectMake(105, 88, 111, 41)];
    logoImg.image=[UIImage imageNamed:@"7_logo_1.png"];
    [self.view addSubview:logoImg];
    [logoImg release];
    
    UILabel *Label02 = [[UILabel alloc] initWithFrame:CGRectMake(26, 184-20, 320-42, 20)];
    Label02.textColor=ColorFromRGB(0x616152);
    Label02.textAlignment=UITextAlignmentLeft;
    Label02.font=[UIFont systemFontOfSize:11];
    Label02.text=@"약관/개인정보취급 동의 후 서비스 이용이 가능합니다.";
    Label02.numberOfLines=1;
    Label02.lineBreakMode=YES;
    [Label02 setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:Label02];
    [Label02 release];	
    
    UIImageView *boxView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"7_com_bg.PNG"] stretchableImageWithLeftCapWidth:17 topCapHeight:0]];
    boxView.backgroundColor = [UIColor clearColor];
    boxView.frame=CGRectMake(9, 210-15, 302, 163);
    [self.view addSubview:boxView];
    [boxView release];
    
    UILabel *Label03 = [[UILabel alloc] initWithFrame:CGRectMake(36, 255, 30, 20)];
    Label03.textColor=ColorFromRGB(0x616152);
    Label03.textAlignment=UITextAlignmentLeft;
    Label03.font=[UIFont systemFontOfSize:14];
    Label03.text=@"동의함";
    Label03.numberOfLines=1;
    Label03.lineBreakMode=YES;
    [Label03 setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:Label03];
    [Label03 release];	
    
    
    UISwitch *agreeSwitch =[[UISwitch alloc] initWithFrame:CGRectMake(207, 251, 120, 120)];
	[agreeSwitch addTarget:self action:@selector(switchStatusChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:agreeSwitch];
    [agreeSwitch release];
    
    UIImage *btnImage = [UIImage imageNamed:@"termsBtn.png"]; 
    UIImage *ButtonImage = [btnImage stretchableImageWithLeftCapWidth:6 topCapHeight:0];
    UIButton *btnTerms  = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnTerms setBackgroundImage:ButtonImage forState:UIControlStateNormal];
    [btnTerms setTitle:@"Usay약관/개인정보 취급방침                    " forState:UIControlStateNormal];
    [btnTerms.titleLabel setFont:[UIFont fontWithName:@"AppleGothic" size:14.0f]];
    [btnTerms setTitleColor:ColorFromRGB(0x333333) forState:UIControlStateNormal];
    [btnTerms addTarget:self action:@selector(TermsClick) forControlEvents:UIControlEventTouchUpInside];
    btnTerms.frame=CGRectMake(20, 210-3, 320-40, 33);
    [self.view addSubview:btnTerms];
    
    UIImageView *arrowImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"7_arrow.png"]];
    arrowImg.backgroundColor = [UIColor clearColor];
    arrowImg.frame=CGRectMake(320-40, 210-3+10, 7, 12);
    [self.view addSubview:arrowImg];
    [arrowImg release];
    
    UIButton *btnStart  = [UIButton buttonWithType:UIButtonTypeCustom];
    btnStart.tag=100;
    [btnStart setImage:[UIImage imageNamed:@"7_start_button.png"] forState:UIControlStateNormal];
    [btnStart addTarget:self action:@selector(StartClick) forControlEvents:UIControlEventTouchUpInside];
    btnStart.frame=CGRectMake(21, 305, 279, 39);
    [self.view addSubview:btnStart];
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

-(void)switchStatusChanged:(id)sender {
	UISwitch *control = (UISwitch*)sender;
	
	
	if(control.on == YES)
	{
		flag = TRUE;
	}
	else{
		flag = FALSE;
	}
}
    
-(void)backBarButtonClicked
{
	[self.navigationController popViewControllerAnimated:YES];
}



@end
