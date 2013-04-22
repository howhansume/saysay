//
//  nationalViewController.h
//  USayApp
//
//  Created by ku jung on 10. 10. 24..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CertificationViewController.h"

@interface nationalViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
	
	UITableView *nationalTableView;
	NSMutableArray *nationalDataArray;
	id parent;
	

}

@property(nonatomic, assign)id parent;


@end
