//
//  CheckPhoneNumber.m
//  USayApp
//
//  Created by Kim Tae-Hyung on 10. 5. 25..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "CheckPhoneNumber.h"

#define kLengthLimit 14

@implementation CheckPhoneNumber

@synthesize iMaxLength;

-(id)init{
	self = [super init];
	if(self != nil){
		//제한 글자수 초기값
		iMaxLength = kLengthLimit;
	}
	return self;
}

-(id)initMaxLength:(NSInteger)maxLength {
	self = [super init];
	if(self != nil) {
		//제한 할 글자 수
		iMaxLength = maxLength;
	}
	return self;
}

-(void)dealloc{
	[super dealloc];
}

-(BOOL) checkTextFieldPhoneNumber:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	//return NO하면 입력이 취소됨
	//return YES하면 입력이 허락됨
	//textField 이용해서 어느 텍스트필드인지 구분 가능
	
	//string은 현재 키보드에서 입력한 문자 한개를 의미한다.
	if(string && [string length] && ([textField.text length] >= iMaxLength)) {
		return NO;
	}
	
	NSString *candidateString = nil;
	NSNumber *candidateNumber = nil;
	
	//입력 들어온 값을 담아둔다
//mezzo	candidateString = [textField.text stringByReplacingCharactersInRange:range withString:string];
	
	//숫자여부 점검
	//length가 0보다 클 경우만 체크
	//0인 경우는 백스페이스의 경우이므로 체크하지 않아야 한다
	if ([string length] > 0) {
		//numberFormatter는 자주 사용할 예정이므로 아래 코드를 이용해서 생성해둬야함
		NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		
		//numberFormatter를 이용해서 NSNumber로 변환
		candidateNumber = [numberFormatter numberFromString:string];
		[numberFormatter release];
		
		//nil이면 숫자가 아니므로 NO 리턴해서 입력취소
		if(candidateNumber == nil) {
			return NO;
		}
		
		// 1588-1588 등등
		// 평생번호 0502 0505 0506 
		candidateString = [textField text];
		if ([candidateString length] == 2) {	// 02 ===> 02-1
			if([candidateString isEqualToString:@"02"]) {
				NSString *temp = [[NSString stringWithString:candidateString] stringByAppendingString:@"-"];
				[textField setText:temp];
			} else {
				// skip
			}
		} else if ([candidateString length] == 3) {	// 010 ===> 010-1
			NSString *firstString = [candidateString substringToIndex:2];
			if ([firstString isEqualToString:@"02"]) {
				// skip (서울지역번호)
			} else if ([[candidateString substringToIndex:3] isEqualToString:@"050"]) {	// 평생번호
				// skip (평생번호)
			} else if (  [firstString isEqualToString:@"15"] 
					   ||[firstString isEqualToString:@"16"] 
					   ||[firstString isEqualToString:@"17"] 
					   ||[firstString isEqualToString:@"18"] 
					   ||[firstString isEqualToString:@"19"] ) {
				// skip (1588 등등)
			} else {
				[textField setText:[candidateString stringByAppendingString:@"-"]];
			}
		} else if ([candidateString length] == 4) {	// 0505 ===> 0505-1    or    1588 ===> 1588-1
			NSString *firstString = [candidateString substringToIndex:2];
			if ([firstString isEqualToString:@"02"]) {
				// skip (서울지역번호)
			} else if ([[candidateString substringToIndex:3] isEqualToString:@"050"]) {	// 평생번호
				[textField setText:[candidateString stringByAppendingString:@"-"]];
			} else if (  [firstString isEqualToString:@"15"] 
					   ||[firstString isEqualToString:@"16"] 
					   ||[firstString isEqualToString:@"17"] 
					   ||[firstString isEqualToString:@"18"] 
					   ||[firstString isEqualToString:@"19"] ) {
				[textField setText:[candidateString stringByAppendingString:@"-"]];		
			} else {
				// skip
			}
		} else if ([candidateString length] == 6) { // 02-123 ===> 02-123-4
			NSString *firstString = [candidateString substringToIndex:2];
			if ([firstString isEqualToString:@"02"]) {
				NSString *temp = [[NSString stringWithString:candidateString] stringByAppendingString:@"-"];
				[textField setText:temp];
			} else if ([[candidateString substringToIndex:3] isEqualToString:@"050"]) {	// 평생번호
				// skip
			} else if (  [firstString isEqualToString:@"15"] 
					   ||[firstString isEqualToString:@"16"] 
					   ||[firstString isEqualToString:@"17"] 
					   ||[firstString isEqualToString:@"18"] 
					   ||[firstString isEqualToString:@"19"] ) {
				// skip
			} else {
				// skip
			}
		} else if ([candidateString length] == 7) {	// 010-123 ===> 010-123-4
			NSString *firstString = [candidateString substringToIndex:2];
			if ([firstString isEqualToString:@"02"]) {
				NSString *temp = [[NSString stringWithString:candidateString] stringByAppendingString:@"-"];
				[textField setText:temp];
			} else if ([[candidateString substringToIndex:3] isEqualToString:@"050"]) {	// 평생번호
				// skip
			} else if (  [firstString isEqualToString:@"15"] 
					   ||[firstString isEqualToString:@"16"] 
					   ||[firstString isEqualToString:@"17"] 
					   ||[firstString isEqualToString:@"18"] 
					   ||[firstString isEqualToString:@"19"] ) {
				// skip
			} else {
				[textField setText:[candidateString stringByAppendingString:@"-"]];
			}
		} else if ([candidateString length] == 8) { // 0505-123 ===> 0505-123-4
			NSString *firstString = [candidateString substringToIndex:2];
			if ([firstString isEqualToString:@"02"]) {
				// skip
			} else if ([[candidateString substringToIndex:3] isEqualToString:@"050"]) {	// 평생번호
				[textField setText:[candidateString stringByAppendingString:@"-"]];
			} else if (  [firstString isEqualToString:@"15"] 
					   ||[firstString isEqualToString:@"16"] 
					   ||[firstString isEqualToString:@"17"] 
					   ||[firstString isEqualToString:@"18"] 
					   ||[firstString isEqualToString:@"19"] ) {
				// skip
			} else {
				// skip
			}
		} else if ([candidateString length] == 11) {	// 02-123-4567  ===>  02-1234-5678 
			NSString *firstString = [candidateString substringToIndex:2];
			if ([firstString isEqualToString:@"02"]) {
				// skip
				NSString *temp1 = [candidateString substringToIndex:6];
				NSString *temp2 = [candidateString substringFromIndex:7];
				NSString *temp = [[[[NSString stringWithString:temp1] stringByAppendingString:[temp2 substringToIndex:1]] stringByAppendingString:@"-"] stringByAppendingString:[temp2 substringFromIndex:1]];
				[textField setText:temp];
			} else if ([[candidateString substringToIndex:3] isEqualToString:@"050"]) {	// 평생번호
				// skip
			} else if (  [firstString isEqualToString:@"15"] 
					   ||[firstString isEqualToString:@"16"] 
					   ||[firstString isEqualToString:@"17"] 
					   ||[firstString isEqualToString:@"18"] 
					   ||[firstString isEqualToString:@"19"] ) {
				// skip
			} else {
				// skip
			}
		} else if ([candidateString length] == 12) {	// 010-123-45678  ===>  010-1234-5678 
			NSString *firstString = [candidateString substringToIndex:2];
			if ([firstString isEqualToString:@"02"]) {
				// skip
			} else if ([[candidateString substringToIndex:3] isEqualToString:@"050"]) {	// 평생번호
				// skip
			} else if (  [firstString isEqualToString:@"15"] 
					   ||[firstString isEqualToString:@"16"] 
					   ||[firstString isEqualToString:@"17"] 
					   ||[firstString isEqualToString:@"18"] 
					   ||[firstString isEqualToString:@"19"] ) {
				// skip
			} else {
				NSString *temp1 = [candidateString substringToIndex:7];
				NSString *temp2 = [candidateString substringFromIndex:8];
				NSString *temp = [[[[NSString stringWithString:temp1] stringByAppendingString:[temp2 substringToIndex:1]] stringByAppendingString:@"-"] stringByAppendingString:[temp2 substringFromIndex:1]];
				[textField setText:temp];
			}
		} else if ([candidateString length] == 13) {	// 0505-123-45678  ===>  0505-1234-5678 
			NSString *firstString = [candidateString substringToIndex:2];
			if ([firstString isEqualToString:@"02"]) {
				// skip
			} else if ([[candidateString substringToIndex:3] isEqualToString:@"050"]) {	// 평생번호
				NSString *temp1 = [candidateString substringToIndex:8];
				NSString *temp2 = [candidateString substringFromIndex:9];
				NSString *temp = [[[[NSString stringWithString:temp1] stringByAppendingString:[temp2 substringToIndex:1]] stringByAppendingString:@"-"] stringByAppendingString:[temp2 substringFromIndex:1]];
				[textField setText:temp];
			} else if (  [firstString isEqualToString:@"15"] 
					   ||[firstString isEqualToString:@"16"] 
					   ||[firstString isEqualToString:@"17"] 
					   ||[firstString isEqualToString:@"18"] 
					   ||[firstString isEqualToString:@"19"] ) {
				// skip
			} else {
				// skip
			}
		} else {
			// skip
		}
		
	} else {
		// backspace시 처리
		candidateString = [textField text];
		if ([candidateString length] == 14) {	// 0505-1234-5678 ===> 0505-123-4567
			NSString *firstString = [candidateString substringToIndex:2];
			if ([firstString isEqualToString:@"02"]) {
				// skip
			} else if ([[candidateString substringToIndex:3] isEqualToString:@"050"]) {	// 평생번호
				NSString *temp1 = [candidateString substringToIndex:8];	// 0505-123
				NSString *temp2 = [[candidateString substringFromIndex:8] substringToIndex:1];	// 4
				NSString *temp3 = [[candidateString substringFromIndex:10] substringToIndex:4];	// 5678
				NSString *temp = [[[[NSString stringWithString:temp1] stringByAppendingString:@"-"] stringByAppendingString:temp2] stringByAppendingString:temp3];
				[textField setText:temp];
			} else if (  [firstString isEqualToString:@"15"] 
					   ||[firstString isEqualToString:@"16"] 
					   ||[firstString isEqualToString:@"17"] 
					   ||[firstString isEqualToString:@"18"] 
					   ||[firstString isEqualToString:@"19"] ) {
				// skip
			} else {
				// skip
			}
		} else if ([candidateString length] == 13) {	// 010-1234-5678 ===> 010-123-4567
			NSString *firstString = [candidateString substringToIndex:2];
			if ([[candidateString substringToIndex:2] isEqualToString:@"02"]) {
				// skip
			} else if ([[candidateString substringToIndex:3] isEqualToString:@"050"]) {	// 평생번호
				// skip
			} else if (  [firstString isEqualToString:@"15"] 
					   ||[firstString isEqualToString:@"16"] 
					   ||[firstString isEqualToString:@"17"] 
					   ||[firstString isEqualToString:@"18"] 
					   ||[firstString isEqualToString:@"19"] ) {
				// skip
			} else {
				NSString *temp1 = [candidateString substringToIndex:7];	// 010-123
				NSString *temp2 = [[candidateString substringFromIndex:7] substringToIndex:1];	// 4
				NSString *temp3 = [[candidateString substringFromIndex:9] substringToIndex:4];	// 5678
				NSString *temp = [[[[NSString stringWithString:temp1] stringByAppendingString:@"-"] stringByAppendingString:temp2] stringByAppendingString:temp3];
				[textField setText:temp];
			}
		} else if ([candidateString length] == 12) {	// 02-1234-5678 ===> 02-123-4567
			NSString *firstString = [candidateString substringToIndex:2];
			if ([firstString isEqualToString:@"02"]) {
				NSString *temp1 = [candidateString substringToIndex:6];	// 02-123
				NSString *temp2 = [[candidateString substringFromIndex:6] substringToIndex:1];	// 4
				NSString *temp3 = [[candidateString substringFromIndex:8] substringToIndex:4];	// 5678
				NSString *temp = [[[[NSString stringWithString:temp1] stringByAppendingString:@"-"] stringByAppendingString:temp2] stringByAppendingString:temp3];
				[textField setText:temp];
			} else if ([[candidateString substringToIndex:3] isEqualToString:@"050"]) {	// 평생번호
				// skip
			} else if (  [firstString isEqualToString:@"15"] 
					   ||[firstString isEqualToString:@"16"] 
					   ||[firstString isEqualToString:@"17"] 
					   ||[firstString isEqualToString:@"18"] 
					   ||[firstString isEqualToString:@"19"] ) {
				
				// skip
			} else {
				// skip
			}
		} else if ([candidateString length] == 10) {	// 0505-123-4 ===> 0505-123
			NSString *firstString = [candidateString substringToIndex:2];
			if ([[candidateString substringToIndex:2] isEqualToString:@"02"]) {
				// skip
			} else if ([[candidateString substringToIndex:3] isEqualToString:@"050"]) {	// 평생번호
				NSString *temp = [candidateString substringToIndex:9];	// 0505-123-
				[textField setText:temp];
			} else if (  [firstString isEqualToString:@"15"] 
					   ||[firstString isEqualToString:@"16"] 
					   ||[firstString isEqualToString:@"17"] 
					   ||[firstString isEqualToString:@"18"] 
					   ||[firstString isEqualToString:@"19"] ) {
				// skip
			} else {
				// skip
			}
		} else if ([candidateString length] == 9) {	// 010-123-4 ===> 010-123
			NSString *firstString = [candidateString substringToIndex:2];
			if ([firstString isEqualToString:@"02"]) {
				// skip
			} else if ([[candidateString substringToIndex:3] isEqualToString:@"050"]) {	// 평생번호
				// skip
			} else if (  [firstString isEqualToString:@"15"] 
					   ||[firstString isEqualToString:@"16"] 
					   ||[firstString isEqualToString:@"17"] 
					   ||[firstString isEqualToString:@"18"] 
					   ||[firstString isEqualToString:@"19"] ) {
				// skip
			} else {
				NSString *temp = [candidateString substringToIndex:8];	// 010-123-
				[textField setText:temp];
			}
		} else if ([candidateString length] == 8) {	// 02-123-4 ===> 02-123
			NSString *firstString = [candidateString substringToIndex:2];
			if ([firstString isEqualToString:@"02"]) {
				NSString *temp = [candidateString substringToIndex:7];	// 02-123-
				[textField setText:temp];
			} else if ([[candidateString substringToIndex:3] isEqualToString:@"050"]) {	// 평생번호
				// skip
			} else if (  [firstString isEqualToString:@"15"] 
					   ||[firstString isEqualToString:@"16"] 
					   ||[firstString isEqualToString:@"17"] 
					   ||[firstString isEqualToString:@"18"] 
					   ||[firstString isEqualToString:@"19"] ) {
				// skip
			} else {
				// skip
			}
		} else if ([candidateString length] == 6) {	// 0505-1 ===> 0505   or   1588-1 ===> 1588
			NSString *firstString = [candidateString substringToIndex:2];
			if ([firstString isEqualToString:@"02"]) {
				// skip
			} else if ([[candidateString substringToIndex:3] isEqualToString:@"050"]) {	// 평생번호
				NSString *temp = [candidateString substringToIndex:5];	// 0505-
				[textField setText:temp];
			} else if (  [firstString isEqualToString:@"15"] 
					   ||[firstString isEqualToString:@"16"] 
					   ||[firstString isEqualToString:@"17"] 
					   ||[firstString isEqualToString:@"18"] 
					   ||[firstString isEqualToString:@"19"] ) {
				NSString *temp = [candidateString substringToIndex:5];	// 1588-
				[textField setText:temp];
			} else {
				// skip
			}
		} else if ([candidateString length] == 5) {	// 010-1 ===> 010
			NSString *firstString = [candidateString substringToIndex:2];
			if ([firstString isEqualToString:@"02"]) {
				// skip
			} else if ([[candidateString substringToIndex:3] isEqualToString:@"050"]) {	// 평생번호
				// skip
			} else if (  [firstString isEqualToString:@"15"] 
					   ||[firstString isEqualToString:@"16"] 
					   ||[firstString isEqualToString:@"17"] 
					   ||[firstString isEqualToString:@"18"] 
					   ||[firstString isEqualToString:@"19"] ) {
				// skip
			} else {
				NSString *temp1 = [candidateString substringToIndex:3];	// 010
				NSString *temp = [[NSString stringWithString:temp1] stringByAppendingString:@"-"];
				[textField setText:temp];
			}
		} else if ([candidateString length] == 4) {	// 02-1 ===> 02
			NSString *firstString = [candidateString substringToIndex:2];
			if ([firstString isEqualToString:@"02"]) {
				NSString *temp = [candidateString substringToIndex:3];	// 02-
				[textField setText:temp];
			} else if ([[candidateString substringToIndex:3] isEqualToString:@"050"]) {	// 평생번호
				// skip
			} else if (  [firstString isEqualToString:@"15"] 
					   ||[firstString isEqualToString:@"16"] 
					   ||[firstString isEqualToString:@"17"] 
					   ||[firstString isEqualToString:@"18"] 
					   ||[firstString isEqualToString:@"19"] ) {
				// skip
			} else {
				// skip
			}
		} else {
			// skip
		}
		
	}

	return YES;
}

+(NSString*)convertPhoneInsertHyphen:(NSMutableString*)source
{
	NSMutableString *target = nil;
	// - 제거
	source = (NSMutableString *)[source stringByReplacingOccurrencesOfString:@"-" withString:@""];
	// 02
	// 지역번호 3자리, 010, 011, 016, 017, 018, 019
	// 1588~
	// 0505 평생번호
	
	if ([source length] <= 2) {
		return source;
	}
	
	NSString *first = nil, *temp = nil;
	temp = [source substringToIndex:1];
	if ([temp isEqualToString:@"0"]) {
		first = [source substringToIndex:2];
		NSInteger length = [source length];
		if([first isEqualToString:@"02"]) {
			if (length >= 3 && length <= 5) {			// 02 123
				target = [NSString stringWithFormat:@"02-%@", [[source substringFromIndex:2] substringToIndex:[source length] - 2]];
			} else if (length > 5 && length <= 9) {		// 02 123 4567
				target = [NSString stringWithFormat:@"02-%@-%@", 
						  [[source substringFromIndex:2] substringToIndex:3], 
						  [[source substringFromIndex:5] substringToIndex:([source length] - 5)]
						  ];
			} else if (length >= 10) {					// 02 1234 5678
				target = [NSString stringWithFormat:@"02-%@-%@", 
						  [[source substringFromIndex:2] substringToIndex:4], 
						  [[source substringFromIndex:6] substringToIndex:([source length] - 6)]
						  ];
			} else {
				// skip
			}
			
		} else {
			if (length == 3) {
				return source;
			} else {
				temp = [source substringToIndex:3];
				if ([temp isEqualToString:@"050"]) {	// 평생번호
					if (length > 3 && length < 8) {				// 0505 123
						target = [NSString stringWithFormat:@"%@-%@", [source substringToIndex:4], [[source substringFromIndex:4] substringToIndex:[source length] - 4]];
					} else if (length >= 8 && length <= 11) {	// 0505 123 4567
						target = [NSString stringWithFormat:@"%@-%@-%@", [source substringToIndex:4], [[source substringFromIndex:4] substringToIndex:3],  [[source substringFromIndex:7] substringToIndex:[source length] - 7]];
					} else {	// 0505 1234 5678...
						target = [NSString stringWithFormat:@"%@-%@-%@", [source substringToIndex:4], [[source substringFromIndex:4] substringToIndex:4],  [[source substringFromIndex:8] substringToIndex:[source length] - 8]];
					}
				} else {
					if (length > 3 && length < 7) {				// 012 345
						target = [NSString stringWithFormat:@"%@-%@", [source substringToIndex:3], [[source substringFromIndex:3] substringToIndex:[source length] - 3]];
					} else if (length >= 7 && length <= 10) {	// 012 345 6789
						target = [NSString stringWithFormat:@"%@-%@-%@", [source substringToIndex:3], [[source substringFromIndex:3] substringToIndex:3],  [[source substringFromIndex:6] substringToIndex:[source length] - 6]];
					} else {	// 012 3456 7890...
						target = [NSString stringWithFormat:@"%@-%@-%@", [source substringToIndex:3], [[source substringFromIndex:3] substringToIndex:4],  [[source substringFromIndex:7] substringToIndex:[source length] - 7]];
					}
				}
			}
		}
	} else if ([temp isEqualToString:@"1"]) {
		int length = [source length];
		if (length >= 3 && length <= 4) {
			return source;
		} else {
			target = [NSString stringWithFormat:@"%@-%@", [source substringToIndex:4], [[source substringFromIndex:4] substringToIndex:[source length] - 4]];
		}
	} else {
		int length = [source length];
		if (length == 3) {
			target = source;
		} else if (length > 3 && length < 7) {				// 234 567
			target = [NSString stringWithFormat:@"%@-%@", [source substringToIndex:3], [[source substringFromIndex:3] substringToIndex:[source length] - 3]];
		} else if (length >= 7 && length <= 10) {	// 234 567 890
			target = [NSString stringWithFormat:@"%@-%@-%@", [source substringToIndex:3], [[source substringFromIndex:3] substringToIndex:3],  [[source substringFromIndex:6] substringToIndex:[source length]-6]];
		} else {	// 234 5678 9012...
			target = [NSString stringWithFormat:@"%@-%@-%@", [source substringToIndex:3], [[source substringFromIndex:3] substringToIndex:4],  [[source substringFromIndex:7] substringToIndex:[source length] - 7]];
		}
	}
	
//	NSLog(@"string = %@", target);
	
	return target;
}

@end
