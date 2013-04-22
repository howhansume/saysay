//
//  CheckPhoneNumber.h
//  USayApp
//
//  Created by Kim Tae-Hyung on 10. 5. 25..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CheckPhoneNumber : NSObject {

	int iMaxLength;
}
@property int iMaxLength;

-(id)initMaxLength:(NSInteger)maxLength;
-(BOOL) checkTextFieldPhoneNumber:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
+(NSString*)convertPhoneInsertHyphen:(NSMutableString*)source;

@end
