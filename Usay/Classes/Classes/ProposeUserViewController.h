//
//  ProposeUserViewController.h
//  USayApp
//
//  Created by Jong-Sung Park on 10. 5. 18..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <UIKit/UIKit.h>

@class USayAppAppDelegate;

@interface ProposeUserViewController : UITableViewController {
}

-(USayAppAppDelegate *) appDelegate;
-(void)addAction:(id)sender;
-(void)showImage:(NSString*)cellImage;
@end
