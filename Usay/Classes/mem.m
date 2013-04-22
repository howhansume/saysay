//
//  mem.m
//  bthree
//
//  Created by ku jung on 10. 11. 24..
//  Copyright 2010 mezzomedia. All rights reserved.
//

#import "mem.h"


@implementation mem

@synthesize  recordID, formatted, nickname, organization, orgemail, mobileNumber, homeNumber, iphoneNumber, orgNumber, mainNumber;
@synthesize homeMail;   // sochse 2010.12.29 - cLang
@synthesize homefaxNumber, orgfaxNumber, parseNumber, otherNumber, url1, url2, note, gid, mDate, cDate, birthDay;




-(void)initMember
{
	
	recordID=nil;
	formatted=nil;
	nickname=nil;
	organization=nil;
	homeMail=nil;
	orgemail=nil;
	mobileNumber=nil;
	iphoneNumber=nil;
	homeNumber=nil;
	orgNumber=nil;
	mainNumber=nil;
	homefaxNumber=nil;
	orgfaxNumber=nil;
	parseNumber=nil;
	otherNumber=nil;
	url1=nil;
	url2=nil;
	note=nil;
	gid=nil;
	mDate=nil;
	cDate=nil;
	birthDay=nil;
	
	//	NSLog(@"초기화");
}



@end
