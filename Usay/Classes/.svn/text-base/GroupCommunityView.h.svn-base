//
//  ModalViewController.h
//  USayApp
//
//  Created by Jong-Sung Park on 10. 7. 6..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CommuniteViewDelegate <NSObject>
-(void) groupSayButtonClicked:(id)sender;
-(void) groupSMSButtonClicked:(id)sender;
@end


@interface GroupCommunityView : UIView {
	UIView* childView;
	NSString* groupID;
	UILabel* groupTtitleLabel;
	id<CommuniteViewDelegate> evnetDelegate;
}
@property (nonatomic, retain) UIView* childView;
@property (nonatomic, retain) NSString* groupID;
@property (nonatomic, retain) UILabel* groupTtitleLabel;
@property (nonatomic, retain) id<CommuniteViewDelegate> evnetDelegate;

-(void)showInView:(UIView*)parentView;
-(void)selfViewEnd ;
@end
