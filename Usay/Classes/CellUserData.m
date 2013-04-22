//
//  CellUserData.m
//  USayApp
//
//  Created by 1team on 10. 6. 22..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "CellUserData.h"

@implementation CellUserData

@synthesize pkey;
@synthesize usay;
@synthesize familyName;
@synthesize givenName;
@synthesize formatted;
@synthesize	nickName;
@synthesize status;
@synthesize representPhoto;
@synthesize representPhotoImage;

- (void)dealloc
{
    [pkey release];
    [usay release];
	[familyName release];
	[givenName release];
    [formatted release];
	[nickName release];
	[status release];
    [representPhoto release];
	[representPhotoImage release];
    
    [super dealloc];
}

@end
