//
//  StartViewController.h
//  USayApp
//
//  Created by Jong-Sung Park on 10. 5. 28..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <UIKit/UIKit.h>

@class USayAppAppDelegate;

@interface StartViewController : UIViewController<UIAlertViewDelegate> {
	UIActivityIndicatorView	*indicator;
	NSTimer					*startTimer;
//	NSTimer					*logoImageAnimationTimer;
//	NSInteger				logoImageCount;
	NSMutableArray*			oemGroupArray;
}

//-(void)setLogoImageCount:(NSInteger)count;
//-(NSInteger)logoImageCount;
//-(void)logoImageAnimation:(NSTimer *)timecall;
//-(void)releaseLoadImageView;

-(USayAppAppDelegate *) appDelegate;
-(void)startControl:(NSTimer *)timecall;
-(BOOL)changeDataDictionary:(NSMutableDictionary *)dicData;
-(BOOL)requestContactsData;
-(void)syncOEMAddress;
-(void)syncDatabase:(NSArray*)userData withGroupinfo:(NSArray*)groupData saveRevisionPoint:(NSString*)revisionPoint;
-(void)migrationDatabase;

@property (nonatomic, retain) NSTimer *startTimer;

@end
