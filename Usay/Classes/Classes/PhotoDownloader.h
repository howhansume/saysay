//
//  PhotoDownloader.h
//  USayApp
//
//  Created by 1team on 10. 6. 22..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CellUserData;
@class ProposeUserViewController;

@protocol PhotoDownloaderDelegate;

@interface PhotoDownloader : NSObject {
	CellUserData	*cellUserData;
	NSIndexPath		*indexPathInTableView;
	NSString		*key;
	id <PhotoDownloaderDelegate> delegate;
	
	NSMutableData	*activeDownload;
	NSURLConnection *imageConnection;
}

@property (nonatomic, retain) CellUserData		*cellUserData;
@property (nonatomic, retain) NSIndexPath		*indexPathInTableView;
@property (nonatomic, retain) NSString			*key;
@property (nonatomic, assign) id <PhotoDownloaderDelegate> delegate;

@property (nonatomic, retain) NSMutableData		*activeDownload;
@property (nonatomic, retain) NSURLConnection	*imageConnection;

- (void)startDownload;
- (void)cancelDownload;

@end

@protocol PhotoDownloaderDelegate 

- (void)appImageDidLoad:(NSString *)indexPath;

@end
