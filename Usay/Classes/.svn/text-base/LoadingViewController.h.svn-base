//
//  LoadingViewController.h
//  USayApp
//
//  Created by Jong-Sung Park on 10. 5. 24..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <UIKit/UIKit.h>

@class USayAppAppDelegate;
@interface LoadingViewController : UIViewController {
	UIActivityIndicatorView* startActIndicator;
	NSTimer *startTimer;
	NSTimer *loadingImageTimer;
//	NSTimer *progressTimer;
	UIProgressView	*progressView;
	UIView*         syncView;
	
	NSInteger		loadingImageCount;
	NSMutableArray*		oemGroupArray;
	
	int		syncState;
	BOOL	startDBQueue;
	BOOL	endDBQueue;
//	BOOL	isMemoryWarning;
//	CGFloat	currentPersent;

}

-(USayAppAppDelegate *) appDelegate;
-(void)startControl:(NSTimer *)timecall;
-(void)loadingImageControl:(NSTimer *)timecall;
-(BOOL)changeDataDictionary:(NSDictionary *)dicData;
-(void)retrySyncAddress:(NSNumber*)hasError;
//-(void)progressControl:(NSTimer *)timecall;
//-(BOOL)requestContactsData;
-(void)requestGetGroups;
-(void)syncDatabase:(NSArray*)userData withGroupinfo:(NSArray*)groupData saveRevisionPoint:(NSString*)revisionPoint;


@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* startActIndicator;
@property (nonatomic, retain) NSTimer *startTimer;
@property (nonatomic, retain) NSTimer *loadingImageTimer;
//@property (nonatomic, retain) NSTimer *progressTimer;
@property (readwrite) NSInteger loadingImageCount;
@property (nonatomic) BOOL	startDBQueue;
@property (nonatomic) BOOL	endDBQueue;
//@property (nonatomic) BOOL	isMemoryWarning;
//@property (readwrite) CGFloat currentPersent;
@end
