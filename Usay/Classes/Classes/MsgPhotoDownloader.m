//
//  MsgPhotoDownloader.m
//  USayApp
//
//  Created by 1team on 10. 6. 30..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "MsgPhotoDownloader.h"
#import "CellMsgListData.h"

#define kAppIconHeight 41

@implementation MsgPhotoDownloader

@synthesize cellMsgListData;
@synthesize indexPathInTableView;
@synthesize key;
@synthesize delegate;
@synthesize activeDownload;
@synthesize imageConnection;

-(id)init
{
	self = [super init];
	if(self != nil) {
		self.indexPathInTableView = nil;
	}
	
	return self;
}


- (void)dealloc
{
    [cellMsgListData release];
	if (indexPathInTableView) {
		[indexPathInTableView release];
	}
    [key release];
	
    [activeDownload release];
    [imageConnection cancel];
    [imageConnection release];
    
    [super dealloc];
}

- (void)startDownload
{
    self.activeDownload = [NSMutableData data];
    // alloc+init and start an NSURLConnection; release on completion/failure
	
	NSString *photoUrl = nil;
	if ([cellMsgListData.userDataDic count] == 1) {
		for (id dicKey in cellMsgListData.userDataDic) {
			MsgUserData *userData = [cellMsgListData.userDataDic objectForKey:dicKey];
			photoUrl = (NSMutableString*)userData.photoUrl;
		}
	}

    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:
                             [NSURLRequest requestWithURL:
                              [NSURL URLWithString:photoUrl]] delegate:self];
    self.imageConnection = conn;
    [conn release];
}

- (void)cancelDownload
{
    [self.imageConnection cancel];
    self.imageConnection = nil;
    self.activeDownload = nil;
}


#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	// Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Set appIcon and clear temporary data/image
    UIImage *image = [[UIImage alloc] initWithData:self.activeDownload];
    
    if (image.size.width != kAppIconHeight && image.size.height != kAppIconHeight) {
        CGSize itemSize = CGSizeMake(kAppIconHeight, kAppIconHeight);
		UIGraphicsBeginImageContext(itemSize);
		CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
		[image drawInRect:imageRect];
		self.cellMsgListData.representPhotoImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
    }
    else
    {
        self.cellMsgListData.representPhotoImage = image;
    }

    self.activeDownload = nil;
    [image release];
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
	
    // call our delegate and tell it that our icon is ready for display
    [delegate appImageDidLoad:self.key];
}

@end