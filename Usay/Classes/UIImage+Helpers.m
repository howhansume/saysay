//
//  UIImage+helper.m
//  USayApp
//
//  Created by Jong-Sung Park on 10. 6. 21..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "UIImage+Helpers.h"

@implementation UIImage (Helpers)
- (UIImage*)stretchableImageWithHorizontalCapWith:(CGFloat)horizontalCapWith verticalCapWith:(CGFloat)verticalCapWith 
{
	CGSize newSize = CGSizeMake(horizontalCapWith * 2.0 + 1.0, verticalCapWith * 2.0 + 1.0);
	
	UIGraphicsBeginImageContext(newSize);
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	// upper left cap + 1 px middle
	CGContextSaveGState(ctx);
	CGContextAddRect(ctx, CGRectMake(0, 0, horizontalCapWith + 1.0, verticalCapWith + 1.0));
	CGContextClip(ctx);
	[self drawInRect:CGRectMake(0,0,self.size.width,self.size.height)];
	CGContextRestoreGState(ctx);
	
	// lower left cap
	CGContextSaveGState(ctx);
	CGContextAddRect(ctx, CGRectMake(0, verticalCapWith + 1.0, horizontalCapWith + 1.0, verticalCapWith));
	CGContextClip(ctx);
	[self drawInRect:CGRectMake(0,newSize.height - self.size.height,self.size.width,self.size.height)];
	CGContextRestoreGState(ctx);
	
	// upper right cap
	CGContextSaveGState(ctx);
	CGContextAddRect(ctx, CGRectMake(horizontalCapWith + 1.0, 0, horizontalCapWith, verticalCapWith+1.0));
	CGContextClip(ctx);
	[self drawInRect:CGRectMake(newSize.width - self.size.width,0,self.size.width,self.size.height)];
	CGContextRestoreGState(ctx);
	
	// lower right cap
	CGContextSaveGState(ctx);
	CGContextAddRect(ctx, CGRectMake(horizontalCapWith + 1.0, verticalCapWith + 1.0, horizontalCapWith, verticalCapWith));
	CGContextClip(ctx);
	[self drawInRect:CGRectMake(newSize.width - self.size.width,newSize.height - self.size.height,self.size.width,self.size.height)];
	CGContextRestoreGState(ctx);
	
	// static image
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return [newImage stretchableImageWithLeftCapWidth:horizontalCapWith topCapHeight:verticalCapWith];
}

@end
