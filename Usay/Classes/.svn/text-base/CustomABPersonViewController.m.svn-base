//
//  CustomABPersonViewController.m
//  USayApp
//
//  Created by ku jung on 11. 3. 24..
//  Copyright 2011 INAMASS.NET. All rights reserved.
//

#import "CustomABPersonViewController.h"

#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation CustomABPersonViewController

@synthesize record;




/*
-(void)setEditing:(BOOL)flag animated:(BOOL)animated
{
	[super setEditing:flag animated:animated];
	if (flag == YES) {
		[[self navigationController] setEditing:YES animated:NO];
	}
	else {
		[[self navigationController] setEditing:NO animated:NO];
	}

}
 */


#pragma mark ABPeoplePickerNavigationControllerDelegate methods
// Displays the information of a selected person
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
	NSLog(@"AAA");
	return YES;
}
- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person 
					property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue
{
	NSLog(@"필드를 선택했을 때 나옴");
	return NO;
}


// Does not allow users to perform default actions such as dialing a phone number, when they select a person property.
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person 
								property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
	NSLog(@"BBBBBB");
	return NO;
}


// Dismisses the people picker and shows the application when users tap Cancel. 
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker;
{
	NSLog(@"CCCC");
	[self dismissModalViewControllerAnimated:YES];
}


-(void)backBarButtonClicked
{

//	[self setEditing:YES];
	//[self setEditing:YES animated:NO];
	
//	[self peoplePickerNavigationController:self shouldContinueAfterSelectingPerson:self.record];
	
	[self.navigationController popViewControllerAnimated:YES];
}
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	NSLog(@"네비게이션 쇼 ");
}

-(void)editButtonAction
{
	[self setEditing:YES];
}

-(void)makeLeftButton
{
	
	UIView *titleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds];
	assert(titleView != nil);
	UIFont *titleFont = [UIFont systemFontOfSize:20];
	CGSize titleStringSize = CGSizeZero; //2010.01.11
	titleStringSize = [@"주소록 정보" sizeWithFont:titleFont constrainedToSize:(CGSizeMake(200.0f, 20.0f))];
	
	assert(titleFont != nil);
	UILabel *naviTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleStringSize.width, titleStringSize.height)];
	assert(naviTitleLabel != nil);
	[naviTitleLabel setFont:titleFont];
	naviTitleLabel.textAlignment = UITextAlignmentCenter;
	[naviTitleLabel setTextColor:ColorFromRGB(0x053844)];
	[naviTitleLabel setBackgroundColor:[UIColor clearColor]];
	[naviTitleLabel setText:@"주소록 정보"];
	[titleView addSubview:naviTitleLabel];	
	[naviTitleLabel release];
	self.navigationItem.titleView = titleView;
	[titleView release];
	self.navigationItem.titleView.frame = CGRectMake((self.view.frame.size.width-titleStringSize.width)/2.0, 12.0, titleStringSize.width, titleStringSize.height);
	
	
	
	
	UIImage* leftBarBtnImg = [UIImage imageNamed:@"btn_top_left.png"];
	UIImage* leftBarBtnSelImg = [UIImage imageNamed:@"btn_top_left_focus.png"];
	UIButton* leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[leftBarButton addTarget:self action:@selector(backBarButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	[leftBarButton setImage:leftBarBtnImg forState:UIControlStateNormal];
	[leftBarButton setImage:leftBarBtnSelImg forState:UIControlStateSelected];
	[leftBarButton setImage:[UIImage imageNamed:@"empty"] forState:UIControlStateDisabled];
	leftBarButton.frame = CGRectMake(0.0, 0.0, leftBarBtnImg.size.width, leftBarBtnImg.size.height);
	UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
	self.navigationItem.backBarButtonItem=nil;
	self.navigationItem.leftBarButtonItem = leftButton;
	
	
	UIImage* rightBarBtnImg = [[UIImage imageNamed:@"btn_top_add.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	UIImage* rightBarBtnSelImg = [[UIImage imageNamed:@"btn_top_add.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	
	
	UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[rightBarButton addTarget:self action:@selector(editButtonAction) forControlEvents:UIControlEventTouchUpInside];
	[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
	[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateHighlighted];
	rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
	self.navigationItem.rightBarButtonItem = rightButton;
	[rightButton release];
	
	
	super.title=@"이전";
	
}
-(id)initWithButton
{
	self = [super init];
	if (self != nil) {
		super.title=@"이전";
	}
	return self;
}
-(void)viewDidLoad
{
	[self makeLeftButton];
}

@end
