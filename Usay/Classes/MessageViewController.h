//
//  MessageViewController.h
//  USayApp
//
//  Created by 1team on 10. 6. 14..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <UIKit/UIKit.h>

@class USayAppAppDelegate;

@interface MessageViewController : UITableViewController {
	NSMutableArray		*msgSearchArray;
	NSMutableArray		*chosungNumArray;
	NSArray				*chosungArray;
	NSArray				*jungsungArray;
	NSArray				*jongsungArray;
}

-(USayAppAppDelegate *) appDelegate;
-(void)modifyButtonClicked;
-(void)sayButtonClicked;
-(BOOL)IsHangulChosung:(NSInteger)code;
-(NSString *)GetUTF8String:(NSString *)str;
-(NSString *)GetChosungUTF8String:(NSString *)str;
-(NSString *)GetChosungUTF8StringSearchString:(NSString *)str;
-(UIImage*)thumbNailImage:(UIImage*)image Size:(CGFloat)resizeSize;

@property (nonatomic, retain) NSMutableArray	*msgSearchArray;
@property (nonatomic, retain) NSMutableArray	*chosungNumArray;
@property (nonatomic, retain) NSArray			*chosungArray;
@property (nonatomic, retain) NSArray			*jungsungArray;
@property (nonatomic, retain) NSArray			*jongsungArray;
@end
