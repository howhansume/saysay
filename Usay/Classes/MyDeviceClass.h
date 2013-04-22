//
//  MyDeviceClass.h
//  USayApp
//
//  Created by 1team on 10. 8. 18..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <Foundation/Foundation.h>

enum DeviceResolutionType
{
	Type_320_480 = 0,
	Type_640_960,
	Type_768_1024
};

typedef enum DeviceResolutionType DeviceResolutionType;

@interface MyDeviceClass : NSObject {

}

+(void)initialize;

+(DeviceResolutionType)deviceResolution;

+(BOOL) screenIs2xResolution;
+(CGFloat) mainScreenScale;

+(BOOL) isIPhone4;
+(NSString *) platformCode;

+(CGRect)deviceOrientation;
//+(BOOL) isIPad;
@end
