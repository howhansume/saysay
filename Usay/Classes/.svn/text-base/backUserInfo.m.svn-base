//
//  UserInfoItem.m
//  USayApp
//
//  Created by Jong-Sung Park on 10. 6. 27..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "backUserInfo.h"


@implementation backUserInfo

@synthesize INDEXNO, RECORDID, ID,  USERIMAGE, FORMATTED, ORGNAME, NICKNAME; //PKEY,
@synthesize HOMEEMAILADDRESS, ORGEMAILADDRESS, OTHEREMAILADDRESS, IMSTATUS; 
@synthesize MOBILEPHONENUMBER, IPHONENUMBER, HOMEPHONENUMBER, ORGPHONENUMBER, MAINPHONENUMBER, OTHERPHONENUMBER;
@synthesize HOMEFAXPHONENUMBER, ORGFAXPHONENUMBER, PARSERNUMBER;		
@synthesize HOMECITY, HOMEZIPCODE, HOMEADDRESSDETAIL, HOMESTATE, HOMEADDRESS;
@synthesize ORGCITY, ORGZIPCODE,ORGADDRESSDETAIL, ORGSTATE, ORGADDRESS;	
@synthesize THUMBNAILURL, URL1, URL2, NOTE, RPCREATED, RPDELETED, RPUPDATED;
@synthesize REPRESENTPHOTO, PROFILEFORMATTED, STATUS, ISFRIEND, ISTRASH, ISBLOCK, GID, RPKEY;				
@synthesize SIDCREATED, SIDUPDATED, SIDDELETED, PROFILENICKNAME, CHANGEDATE, CHANGEDATE2, OEMCREATEDATE, OEMMODIFYDATE, REPRESENTPHOTOSP, NICKNAMESP, STATUSSP;
//4개 항목 추가.. 
@synthesize JOBTITLE, DEPARTMENT, BIRTHDAY, ANNIVERSARY;


-(id)init
{
	self = [super init];
	
	if(self != nil)
	{
		self.ISBLOCK = @"N";
		self.IMSTATUS = @"0";
	}
	
	return self;
}

-(id)copyWithZone:(NSZone*)zone
{
	@synchronized(self) {
		backUserInfo *data = [[self class] allocWithZone:zone];
		if (data) {
			data.INDEXNO				= [self.INDEXNO					copyWithZone:zone];
			data.RECORDID				= [self.RECORDID				copyWithZone:zone];
			data.ID						= [self.ID						copyWithZone:zone];
			//			data.PKEY					= [self.PKEY					copyWithZone:zone];
			data.USERIMAGE				= [self.USERIMAGE				copyWithZone:zone];
			data.FORMATTED				= [self.FORMATTED				copyWithZone:zone];
			data.ORGNAME				= [self.ORGNAME					copyWithZone:zone];
			data.NICKNAME				= [self.NICKNAME				copyWithZone:zone];
			data.HOMEEMAILADDRESS		= [self.HOMEEMAILADDRESS		copyWithZone:zone];
			data.ORGEMAILADDRESS		= [self.ORGEMAILADDRESS			copyWithZone:zone];
			data.OTHEREMAILADDRESS		= [self.OTHEREMAILADDRESS		copyWithZone:zone];
			data.MOBILEPHONENUMBER		= [self.MOBILEPHONENUMBER		copyWithZone:zone];
			data.IPHONENUMBER			= [self.IPHONENUMBER			copyWithZone:zone];
			data.HOMEPHONENUMBER		= [self.HOMEPHONENUMBER			copyWithZone:zone];
			data.ORGPHONENUMBER			= [self.ORGPHONENUMBER			copyWithZone:zone];
			data.MAINPHONENUMBER		= [self.MAINPHONENUMBER			copyWithZone:zone];
			data.HOMEFAXPHONENUMBER		= [self.HOMEFAXPHONENUMBER		copyWithZone:zone];
			data.ORGFAXPHONENUMBER		= [self.ORGFAXPHONENUMBER		copyWithZone:zone];
			data.PARSERNUMBER			= [self.PARSERNUMBER			copyWithZone:zone];
			data.OTHERPHONENUMBER		= [self.OTHERPHONENUMBER		copyWithZone:zone];
			data.HOMECITY				= [self.HOMECITY				copyWithZone:zone];
			data.HOMEZIPCODE			= [self.HOMEZIPCODE				copyWithZone:zone];
			data.HOMEADDRESSDETAIL		= [self.HOMEADDRESSDETAIL		copyWithZone:zone];
			data.HOMESTATE				= [self.HOMESTATE				copyWithZone:zone];
			data.HOMEADDRESS			= [self.HOMEADDRESS				copyWithZone:zone];
			data.ORGCITY				= [self.ORGCITY					copyWithZone:zone];
			data.ORGZIPCODE				= [self.ORGZIPCODE				copyWithZone:zone];
			data.ORGADDRESSDETAIL		= [self.ORGADDRESSDETAIL		copyWithZone:zone];
			data.ORGSTATE				= [self.ORGSTATE				copyWithZone:zone];
			data.ORGADDRESS				= [self.ORGADDRESS				copyWithZone:zone];
			data.THUMBNAILURL			= [self.THUMBNAILURL			copyWithZone:zone];
			data.URL1					= [self.URL1					copyWithZone:zone];
			data.URL2					= [self.URL2					copyWithZone:zone];
			
			data.NOTE					= [self.NOTE					copyWithZone:zone];
			data.RPCREATED				= [self.RPCREATED				copyWithZone:zone];
			data.RPDELETED				= [self.RPDELETED				copyWithZone:zone];
			data.RPUPDATED				= [self.RPUPDATED				copyWithZone:zone];
			data.REPRESENTPHOTO			= [self.REPRESENTPHOTO			copyWithZone:zone];
			data.PROFILEFORMATTED		= [self.PROFILEFORMATTED		copyWithZone:zone];
			data.STATUS					= [self.STATUS					copyWithZone:zone];
			data.ISFRIEND				= [self.ISFRIEND				copyWithZone:zone];
			data.ISTRASH				= [self.ISTRASH					copyWithZone:zone];
			data.ISBLOCK				= [self.ISBLOCK					copyWithZone:zone];
			data.GID					= [self.GID						copyWithZone:zone];
			data.RPKEY					= [self.RPKEY					copyWithZone:zone];
			data.CHANGEDATE				= [self.CHANGEDATE				copyWithZone:zone];
			data.CHANGEDATE2				= [self.CHANGEDATE2				copyWithZone:zone];
			data.OEMCREATEDATE				= [self.OEMCREATEDATE				copyWithZone:zone];
			data.OEMMODIFYDATE				= [self.OEMMODIFYDATE				copyWithZone:zone];
			data.IMSTATUS				= [self.IMSTATUS				copyWithZone:zone];
			
			data.REPRESENTPHOTOSP		= [self.REPRESENTPHOTOSP		copyWithZone:zone];
			data.NICKNAMESP				= [self.NICKNAMESP				copyWithZone:zone];
			data.STATUSSP				= [self.STATUSSP				copyWithZone:zone];
			
			data.SIDCREATED				= [self.SIDCREATED				copyWithZone:zone];
			data.SIDUPDATED				= [self.SIDUPDATED				copyWithZone:zone];
			data.SIDDELETED				= [self.SIDDELETED				copyWithZone:zone];
			data.PROFILENICKNAME		= [self.PROFILENICKNAME			copyWithZone:zone];
			
			return data;
		}
	}
	
	return nil;
}

-(void)dealloc {
	if(INDEXNO			)	[INDEXNO			release];
	if(RECORDID			)	[RECORDID			release];
	if(ID				)	[ID					release];
	//	if(PKEY				)	[PKEY				release];
	if(USERIMAGE		)	[USERIMAGE			release];
	if(FORMATTED		)	[FORMATTED			release];
	if(ORGNAME			)	[ORGNAME			release];
	if(NICKNAME			)	[NICKNAME			release];
	if(HOMEEMAILADDRESS	)	[HOMEEMAILADDRESS	release];
	if(ORGEMAILADDRESS	)	[ORGEMAILADDRESS	release];
	if(OTHEREMAILADDRESS)	[OTHEREMAILADDRESS	release];
	if(MOBILEPHONENUMBER)	[MOBILEPHONENUMBER	release];
	if(IPHONENUMBER		)	[IPHONENUMBER		release];
	if(HOMEPHONENUMBER	)	[HOMEPHONENUMBER	release];
	if(ORGPHONENUMBER	)	[ORGPHONENUMBER		release];
	if(MAINPHONENUMBER	)	[MAINPHONENUMBER	release];
	if(HOMEFAXPHONENUMBER)	[HOMEFAXPHONENUMBER	release];
	if(ORGFAXPHONENUMBER)	[ORGFAXPHONENUMBER	release];
	if(PARSERNUMBER		)	[PARSERNUMBER		release];
	if(OTHERPHONENUMBER	)	[OTHERPHONENUMBER	release];
	if(HOMECITY			)	[HOMECITY			release];
	if(HOMEZIPCODE		)	[HOMEZIPCODE		release];
	if(HOMEADDRESSDETAIL)	[HOMEADDRESSDETAIL	release];
	if(HOMESTATE		)	[HOMESTATE			release];
	if(HOMEADDRESS		)	[HOMEADDRESS		release];
	if(ORGCITY			)	[ORGCITY			release];
	if(ORGZIPCODE		)	[ORGZIPCODE			release];
	if(ORGADDRESSDETAIL	)	[ORGADDRESSDETAIL	release];
	if(ORGSTATE			)	[ORGSTATE			release];
	if(ORGADDRESS		)	[ORGADDRESS			release];
	if(THUMBNAILURL		)	[THUMBNAILURL		release];
	if(URL1				)	[URL1				release];
	if(URL2				)	[URL2				release];
	if(NOTE				)	[NOTE				release];
	if(RPCREATED		)	[RPCREATED			release];
	if(RPDELETED		)	[RPDELETED			release];
	if(RPUPDATED		)	[RPUPDATED			release];
	if(REPRESENTPHOTO	)	[REPRESENTPHOTO		release];
	if(PROFILEFORMATTED	)	[PROFILEFORMATTED	release];
	if(STATUS			)	[STATUS				release];
	if(ISFRIEND			)	[ISFRIEND			release];
	if(ISTRASH			)	[ISTRASH			release];
	if(ISBLOCK			)	[ISBLOCK			release];
	if(GID				)	[GID				release];
	if(RPKEY			)	[RPKEY				release];
	if(PROFILENICKNAME	)	[PROFILENICKNAME	release];
	if(CHANGEDATE		)	[CHANGEDATE			release];
	if(CHANGEDATE2		)	[CHANGEDATE2			release];
	if(OEMCREATEDATE		)	[OEMCREATEDATE			release];
	if(OEMMODIFYDATE		)	[OEMMODIFYDATE			release];
	if(IMSTATUS			)	[IMSTATUS			release];
	
	if(REPRESENTPHOTOSP	)	[REPRESENTPHOTOSP	release];
	if(NICKNAMESP		)	[NICKNAMESP			release];
	if(STATUSSP			)	[STATUSSP			release];
	
	
	
	if(SIDCREATED		)	[SIDCREATED			release];
	if(SIDUPDATED		)	[SIDUPDATED			release];
	if(SIDDELETED		)	[SIDDELETED			release];
	
	[super dealloc];
}
@end
