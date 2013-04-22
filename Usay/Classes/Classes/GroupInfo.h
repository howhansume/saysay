//
//  GroupInfoItem.h
//  USayApp
//
//  Created by Jong-Sung Park on 10. 6. 27..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataAccessObject.h"

@interface GroupInfo : DataAccessObject {
	NSNumber* INDEXNO;
	NSString* RECORDID;
	NSString* ID;
	NSString* PKEY;
	NSString* GROUPTITLE;
	NSString* RPCREATED;
	NSString* RPUPDATED;
	NSString* RPDELETED;
	NSString* SIDCREATED;
	NSString* SIDUPDATED;
	NSString* SIDDELETED;
	NSString* CONTACTCOUNT;
}

@property (nonatomic, retain) NSNumber* INDEXNO;
@property (nonatomic, retain) NSString* RECORDID;
@property (nonatomic, retain) NSString* ID;
@property (nonatomic, retain) NSString* PKEY;
@property (nonatomic, retain) NSString* GROUPTITLE;
@property (nonatomic, retain) NSString* RPCREATED;
@property (nonatomic, retain) NSString* RPUPDATED;
@property (nonatomic, retain) NSString* RPDELETED;
@property (nonatomic, retain) NSString* SIDCREATED;
@property (nonatomic, retain) NSString* SIDUPDATED;
@property (nonatomic, retain) NSString* SIDDELETED;
@property (nonatomic, retain) NSString* CONTACTCOUNT;
@end
