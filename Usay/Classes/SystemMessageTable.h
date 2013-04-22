//
//  SystemMessageTable.h
//  USayApp
//
//  Created by ku jung on 11. 2. 21..
//  Copyright 2011 INAMASS.NET. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataAccessObject.h"


@interface SystemMessageTable : DataAccessObject{
	
	NSNumber *PROCESSTIME;
	NSNumber *ISSUCESS;

}
@property (nonatomic,retain) NSNumber* PROCESSTIME;				
@property (nonatomic,retain) NSNumber* ISSUCESS;	

@end
