//
//  ManagedObjectAttributeEditor.h
//  USayApp
//
//  Created by Jong-Sung Park on 10. 6. 16..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kNonEditableTextColor    [UIColor colorWithRed:.318 green:0.4 blue:.569 alpha:1.0]

@protocol detailViewDataDelegate <NSObject>

-(void)updateDataValue:(NSString*)value forkey:(NSString*)key;
-(void)updateDataWithArray:(NSArray*)value forkey:(NSString*)key;

@end

@interface ManagedObjectAttributeEditor : UITableViewController {
	NSString		*keypath;
	NSString		*labelString;
	NSString		*passDefaultValue;
	NSMutableDictionary* addValueDic;
	id<detailViewDataDelegate> delegate;

}

@property (nonatomic, retain) NSString *keypath;
@property (nonatomic, retain) NSString *labelString;
@property (nonatomic, retain) NSString	*passDefaultValue;
@property (nonatomic, retain) NSMutableDictionary* addValueDic;
@property (nonatomic, assign) id<detailViewDataDelegate> delegate;

@end
