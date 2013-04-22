//
//  AddrUserInfo.m
//  USayApp
//
//  Created by Jong-Sung Park on 10. 7. 15..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "AddrUserInfo.h"


@implementation AddrUserInfo
@synthesize ID, FORMATTED, ORGNAME, NICKNAME, MOBILEPHONENUMBER, IPHONENUMBER, HOMEPHONENUMBER, ORGPHONENUMBER;	
@synthesize MAINPHONENUMBER, REPRESENTPHOTO, PROFILEFORMATTED, PROFILENICKNAME;	//RPCREATED, RPDELETED, RPUPDATED,
@synthesize STATUS, ISFRIEND, ISBLOCK, GID, RPKEY, CHANGEDATE, IMSTATUS, HOMEEMAILADDRESS;		


-(id)init
{
	self = [super init];
	
	if(self != nil)
	{
		self.ISBLOCK = @"N";
	}
	
	return self;
}


-(id)copyWithZone:(NSZone*)zone
{
	@synchronized(self) {
		AddrUserInfo *data = [[self class] allocWithZone:zone];
		if (data) {
			data.ID					=	[self.ID					copyWithZone:zone];			
			data.FORMATTED			=	[self.FORMATTED				copyWithZone:zone];		
			data.ORGNAME			=	[self.ORGNAME				copyWithZone:zone];			
			data.NICKNAME			=	[self.NICKNAME				copyWithZone:zone];			
			data.MOBILEPHONENUMBER	=	[self.MOBILEPHONENUMBER		copyWithZone:zone];
			data.IPHONENUMBER		=	[self.IPHONENUMBER			copyWithZone:zone];		
			data.HOMEPHONENUMBER	=	[self.HOMEPHONENUMBER		copyWithZone:zone];	
			data.ORGPHONENUMBER		=	[self.ORGPHONENUMBER		copyWithZone:zone];	
			data.MAINPHONENUMBER	=	[self.MAINPHONENUMBER		copyWithZone:zone];	
//			data.RPCREATED			=	[self.RPCREATED				copyWithZone:zone];		
//			data.RPDELETED			=	[self.RPDELETED				copyWithZone:zone];		
//			data.RPUPDATED			=	[self.RPUPDATED				copyWithZone:zone];		
			data.REPRESENTPHOTO		=	[self.REPRESENTPHOTO		copyWithZone:zone];	
			data.PROFILEFORMATTED	=	[self.PROFILEFORMATTED		copyWithZone:zone];	
			data.PROFILENICKNAME	=	[self.PROFILENICKNAME		copyWithZone:zone];	
			data.STATUS				=	[self.STATUS				copyWithZone:zone];			
			data.ISFRIEND			=	[self.ISFRIEND				copyWithZone:zone];			
			data.ISBLOCK			=	[self.ISBLOCK				copyWithZone:zone];			
			data.GID				=	[self.GID					copyWithZone:zone];				
			data.RPKEY				=	[self.RPKEY					copyWithZone:zone];			
			data.CHANGEDATE			=	[self.CHANGEDATE			copyWithZone:zone];		
			data.IMSTATUS 			=	[self.IMSTATUS				copyWithZone:zone];	
			data.HOMEEMAILADDRESS 	=	[self.HOMEEMAILADDRESS				copyWithZone:zone];	
			
			return data;
		}
	}
	
	return nil;
}

-(void)dealloc {
	if(ID					)	[ID					release];
	if(FORMATTED			)	[FORMATTED			release];
	if(ORGNAME				)	[ORGNAME			release];
	if(NICKNAME				)	[NICKNAME			release];
	if(MOBILEPHONENUMBER	)	[MOBILEPHONENUMBER	release];
	if(IPHONENUMBER			)	[IPHONENUMBER		release];
	if(HOMEPHONENUMBER		)	[HOMEPHONENUMBER	release];
	if(ORGPHONENUMBER		)	[ORGPHONENUMBER		release];
	if(MAINPHONENUMBER		)	[MAINPHONENUMBER	release];
//	if(RPCREATED			)	[RPCREATED			release];
//	if(RPDELETED			)	[RPDELETED			release];
//	if(RPUPDATED			)	[RPUPDATED			release];
	if(REPRESENTPHOTO		)	[REPRESENTPHOTO		release];
	if(PROFILEFORMATTED		)	[PROFILEFORMATTED	release];
	if(PROFILENICKNAME		)	[PROFILENICKNAME	release];
	if(STATUS				)	[STATUS				release];
	if(ISFRIEND				)	[ISFRIEND			release];
	if(ISBLOCK				)	[ISBLOCK			release];
	if(GID					)	[GID				release];
	if(RPKEY				)	[RPKEY				release];
	if(CHANGEDATE			)	[CHANGEDATE			release];
	if(IMSTATUS 			)	[IMSTATUS 			release];
	if(HOMEEMAILADDRESS 	)	[HOMEEMAILADDRESS 	release];	
	
	[super dealloc];
}


@end
