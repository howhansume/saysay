//
//  ManagedObjectAttributeEditor.m
//  USayApp
//
//  Created by Jong-Sung Park on 10. 6. 16..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "ManagedObjectAttributeEditor.h"

#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation ManagedObjectAttributeEditor
@synthesize keypath;
@synthesize labelString, passDefaultValue;
@synthesize addValueDic, delegate;

-(void)backBarButtonClicked {
	[self.navigationController popViewControllerAnimated:YES];
}
- (void)viewWillAppear:(BOOL)animated  {
	
	NSLog(@"appear will selectindex222222222");
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
	
	self.tableView.separatorColor = ColorFromRGB(0xc2c2c3);
	[super viewWillAppear:animated];
}

- (void)dealloc {
    [keypath release];
    [labelString release];
	[addValueDic release];
	[passDefaultValue release];
    [super dealloc];
}


@end

