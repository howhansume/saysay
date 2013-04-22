//
//  BlockFriendListViewController.h
//  USayApp
//
//  Created by 1team on 10. 6. 2..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <UIKit/UIKit.h>

@class USayAppAppDelegate;

@interface BlockFriendListViewController : UITableViewController { 
	NSMutableArray	*listData;
	BOOL			isReceive;
}

-(USayAppAppDelegate *) appDelegate;
-(void)clearAction:(id)sender;
-(void)backBarButtonClicked;

@property (nonatomic, retain) NSMutableArray* listData;
@property (nonatomic, assign) BOOL isReceive;
@end
