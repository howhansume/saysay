//
//  blockView.h
//  USayApp
//
//  Created by Jong-Sung Park on 10. 7. 7..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface blockView : UIAlertView {

	UIView *indicator;
	UILabel *alertLabel;
	UILabel *alertDetailsLabel;
	NSTimer *startTimer;

@private
	CGRect blockFrame;
}
@property(readwrite, retain) NSString *alertText;
@property(readwrite, retain) NSString *alertDetailText;
@property (nonatomic, retain) NSTimer *startTimer;
-(void)endBlockView:(NSTimer *)timecall;

+ (void) setBackgroundColor:(UIColor *) background withStrokeColor:(UIColor *) stroke;
-(void) dismissAlertView;
@end
