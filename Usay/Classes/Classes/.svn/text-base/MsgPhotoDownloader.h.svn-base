//
//  MsgPhotoDownloader.h
//  USayApp
//
//  Created by 1team on 10. 6. 30..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CellMsgListData;
@class MessageViewController;

@protocol MsgPhotoDownloaderDelegate;

@interface MsgPhotoDownloader : NSObject {
	CellMsgListData	*cellMsgListData;
	NSIndexPath		*indexPathInTableView;
	NSString		*key;
	id <MsgPhotoDownloaderDelegate> delegate;
	
	NSMutableData	*activeDownload;
	NSURLConnection *imageConnection;
}
@property (nonatomic, retain) CellMsgListData	*cellMsgListData;
@property (nonatomic, retain) NSIndexPath		*indexPathInTableView;
@property (nonatomic, retain) NSString			*key;
@property (nonatomic, assign) id <MsgPhotoDownloaderDelegate> delegate;

@property (nonatomic, retain) NSMutableData		*activeDownload;
@property (nonatomic, retain) NSURLConnection	*imageConnection;

- (void)startDownload;
- (void)cancelDownload;

@end

@protocol MsgPhotoDownloaderDelegate 

- (void)appImageDidLoad:(NSString *)key;

@end