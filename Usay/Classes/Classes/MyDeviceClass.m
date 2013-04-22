//
//  MyDeviceClass.m
//  USayApp
//
//  Created by 1team on 10. 8. 18..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "MyDeviceClass.h"
#include <sys/types.h>
#include <sys/sysctl.h>

static CGRect deviceOrientationRect;

@implementation MyDeviceClass



+(void)initialize
{
	deviceOrientationRect = CGRectMake(0.0, 0.0, 0.0, 0.0);
}

+(DeviceResolutionType)deviceResolution
{
	if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 3.2) {
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			if ([MyDeviceClass screenIs2xResolution]) {
//				CGRect rect = [[UIScreen mainScreen] bounds];
//				NSLog(@"MyDeviceClass UIUserInterfaceIdiomPad screenIs2xResolution width=%f height=%f", rect.size.width, rect.size.height);
				return Type_768_1024;
			} else {
//				CGRect rect = [[UIScreen mainScreen] bounds];
//				NSLog(@"MyDeviceClass UIUserInterfaceIdiomPad screenIs1xResolution width=%f height=%f", rect.size.width, rect.size.height);
				return Type_768_1024;
			}
		} else {	// UIUserInterfaceIdiomPhone
			if ([MyDeviceClass isIPhone4]) {
//				CGRect rect = [[UIScreen mainScreen] bounds];
//				NSLog(@"MyDeviceClass UIUserInterfaceIdiomPhone isIPhone4 width=%f height=%f", rect.size.width, rect.size.height);
				return Type_640_960;
			} else {
//				CGRect rect = [[UIScreen mainScreen] bounds];
//				NSLog(@"MyDeviceClass UIUserInterfaceIdiomPhone isIPhone3 width=%f height=%f", rect.size.width, rect.size.height);
			}
		}
	} else {
//		CGRect rect = [[UIScreen mainScreen] bounds];
//		NSLog(@"MyDeviceClass iPhone 3.1x width=%f height=%f", rect.size.width, rect.size.height);
	}
	
	return Type_320_480;
}

+ (BOOL) isIPhone4 {
	return ([[MyDeviceClass platformCode] isEqualToString:@"iPhone3,1"]);
}

+ (NSString *) platformCode {
	size_t size;
	sysctlbyname("hw.machine", NULL, &size, NULL, 0);
	char *machine = malloc(size);
	sysctlbyname("hw.machine", machine, &size, NULL, 0);
	NSString *platform = [NSString stringWithCString:machine encoding:[NSString defaultCStringEncoding]];
	free(machine);
	
	return platform;
}

// iPhone1,1	아이폰 1세대
// iPhone1,2	아이폰 3G 모델
// iPhone2,1	아이폰 3GS 모델
// iPhone3,1	아이폰 4G 모델
// iPod1,1		아이팟 터치 1세대
// iPod2,1		아이팟 터치 2세대

+(BOOL) screenIs2xResolution {
	return 2.0 == [MyDeviceClass mainScreenScale];
}

+(CGFloat) mainScreenScale {
	CGFloat scale = 1.0;
	if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
		scale = [[UIScreen mainScreen] scale];
	}
	return scale;
}

//+(BOOL) isIPad {
//	BOOL isIPad=NO;
//	NSString* model = [UIDevice currentDevice].model;
//	if ([model rangeOfString:@"iPad"].location != NSNotFound) {
//		return YES;
//	}
//	return isIPad;
//}


/**
 statusbar, navigationbar 사이즈만 높이에서 뺐음.
 tabbar는 사용하는 view에서 처리해야함.
 */
+(CGRect)deviceOrientation
{
//*
	DeviceResolutionType resolutionType = [MyDeviceClass deviceResolution];
	if (resolutionType == Type_320_480) {			// ipod, iphone 3g, 3gs
		deviceOrientationRect.size.width = 320.0;
		deviceOrientationRect.size.height = 480.0 - 64.0;
	} else if (resolutionType == Type_640_960) {	// iphone 4g
		deviceOrientationRect.size.width = 640.0;
		deviceOrientationRect.size.height = 960.0 - 64.0;
	} else if (resolutionType == Type_768_1024) {	// ipad
		deviceOrientationRect.size.width = 768.0;
		deviceOrientationRect.size.height = 1024.0 - 64.0;
	} else {
		
	}
	
	return deviceOrientationRect;
//*/
	
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	
	switch (orientation)  
    {  
        case UIDeviceOrientationPortrait:  
		{
			DeviceResolutionType resolutionType = [MyDeviceClass deviceResolution];
			if (resolutionType == Type_320_480) {			// ipod, iphone 3g, 3gs
				deviceOrientationRect.size.width = 320.0;
				deviceOrientationRect.size.height = 480.0 - 64.0;
			} else if (resolutionType == Type_640_960) {	// iphone 4g
				deviceOrientationRect.size.width = 640.0;
				deviceOrientationRect.size.height = 960.0 - 64.0;
			} else if (resolutionType == Type_768_1024) {	// ipad
				deviceOrientationRect.size.width = 768.0;
				deviceOrientationRect.size.height = 1024.0 - 64.0;
			} else {
				
			}
		}
            break;  
        case UIDeviceOrientationLandscapeLeft:  
		{
			DeviceResolutionType resolutionType = [MyDeviceClass deviceResolution];
			if (resolutionType == Type_320_480) {			// ipod, iphone 3g, 3gs
				deviceOrientationRect.size.width = 480.0;
				deviceOrientationRect.size.height = 320.0 - 52.0;
			} else if (resolutionType == Type_640_960) {	// iphone 4g
				deviceOrientationRect.size.width = 960.0;
				deviceOrientationRect.size.height = 640.0 - 52.0;
			} else if (resolutionType == Type_768_1024) {	// ipad
				deviceOrientationRect.size.width = 1024.0;
				deviceOrientationRect.size.height = 768.0 - 52.0;
			} else {
				
			}
		}
            break;  
        case UIDeviceOrientationLandscapeRight:  
		{
			DeviceResolutionType resolutionType = [MyDeviceClass deviceResolution];
			if (resolutionType == Type_320_480) {			// ipod, iphone 3g, 3gs
				deviceOrientationRect.size.width = 480.0;
				deviceOrientationRect.size.height = 320.0 - 52.0;
			} else if (resolutionType == Type_640_960) {	// iphone 4g
				deviceOrientationRect.size.width = 960.0;
				deviceOrientationRect.size.height = 640.0 - 52.0;
			} else if (resolutionType == Type_768_1024) {	// ipad
				deviceOrientationRect.size.width = 1024.0;
				deviceOrientationRect.size.height = 768.0 - 52.0;
			} else {
				
			}
		}
            break;  
        case UIDeviceOrientationPortraitUpsideDown:  
		{
			DeviceResolutionType resolutionType = [MyDeviceClass deviceResolution];
			if (resolutionType == Type_320_480) {			// ipod, iphone 3g, 3gs
				deviceOrientationRect.size.width = 320.0;
				deviceOrientationRect.size.height = 480.0 - 64.0;
			} else if (resolutionType == Type_640_960) {	// iphone 4g
				deviceOrientationRect.size.width = 640.0;
				deviceOrientationRect.size.height = 960.0 - 64.0;
			} else if (resolutionType == Type_768_1024) {	// ipad
				deviceOrientationRect.size.width = 768.0;
				deviceOrientationRect.size.height = 1024.0 - 64.0;
			} else {
				
			}
		}
            break;  
		case UIDeviceOrientationFaceUp:
		{
			if (deviceOrientationRect.size.width == 0.0) {
				DeviceResolutionType resolutionType = [MyDeviceClass deviceResolution];
				if (resolutionType == Type_320_480) {			// ipod, iphone 3g, 3gs
					deviceOrientationRect.size.width = 320.0;
					deviceOrientationRect.size.height = 480.0 - 64.0;
				} else if (resolutionType == Type_640_960) {	// iphone 4g
					deviceOrientationRect.size.width = 640.0;
					deviceOrientationRect.size.height = 960.0 - 64.0;
				} else if (resolutionType == Type_768_1024) {	// ipad
					deviceOrientationRect.size.width = 768.0;
					deviceOrientationRect.size.height = 1024.0 - 64.0;
				} else {
					
				}
			} else {
				return deviceOrientationRect;
			}
		}
            break;  
		case UIDeviceOrientationFaceDown:
		{
			if (deviceOrientationRect.size.width == 0.0) {
				DeviceResolutionType resolutionType = [MyDeviceClass deviceResolution];
				if (resolutionType == Type_320_480) {			// ipod, iphone 3g, 3gs
					deviceOrientationRect.size.width = 320.0;
					deviceOrientationRect.size.height = 480.0 - 64.0;
				} else if (resolutionType == Type_640_960) {	// iphone 4g
					deviceOrientationRect.size.width = 640.0;
					deviceOrientationRect.size.height = 960.0 - 64.0;
				} else if (resolutionType == Type_768_1024) {	// ipad
					deviceOrientationRect.size.width = 768.0;
					deviceOrientationRect.size.height = 1024.0 - 64.0;
				} else {
					
				}
			} else {
				return deviceOrientationRect;
			}
		}
            break;  
		case UIDeviceOrientationUnknown:
		{
			if (deviceOrientationRect.size.width == 0.0) {
				DeviceResolutionType resolutionType = [MyDeviceClass deviceResolution];
				if (resolutionType == Type_320_480) {			// ipod, iphone 3g, 3gs
					deviceOrientationRect.size.width = 320.0;
					deviceOrientationRect.size.height = 480.0 - 64.0;
				} else if (resolutionType == Type_640_960) {	// iphone 4g
					deviceOrientationRect.size.width = 640.0;
					deviceOrientationRect.size.height = 960.0 - 64.0;
				} else if (resolutionType == Type_768_1024) {	// ipad
					deviceOrientationRect.size.width = 768.0;
					deviceOrientationRect.size.height = 1024.0 - 64.0;
				} else {
					
				}
			} else {
				return deviceOrientationRect;
			}
		}
			break;
        default:  
            break;  
    } 
	
	return deviceOrientationRect;
}

- (void)dealloc {
	[super dealloc];
}

@end
