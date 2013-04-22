//
//  NSArray-NestedArrays.m
//  USayApp
//
//  Created by Jong-Sung Park on 10. 6. 17..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "NSArray-NestedArrays.h"


@implementation NSArray(NestedArrays)

- (id)nestedObjectAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];
	NSUInteger section = [indexPath section];
	NSArray *subArray = [self objectAtIndex:section];
	
	if (![subArray isKindOfClass:[NSArray class]])
		return nil;
	
	if (row >= [subArray count])
		return nil;
	
	return [subArray objectAtIndex:row];
}

-(NSIndexPath*)indexOfNestedObjectForkey:(NSString*)key{
	int section = 0;
	int row = 0;
	BOOL isEndLoop = NO;
	for(int i = 0;i < [self count];i++) {
		if(isEndLoop)
			break;
		NSArray *subArray = [self objectAtIndex:i];
		if (![subArray isKindOfClass:[NSArray class]])
			return nil;
		
		for(int j= 0;j < [subArray count];j++) {
			if([(NSString*)[subArray objectAtIndex:j] isEqualToString:key]){
				section = i;
				row = j;
				isEndLoop = YES;
				break;
			}
		}
	}
		
	NSUInteger newPath[] = {section, row};
	NSIndexPath *rowIndexPath = [NSIndexPath indexPathWithIndexes:newPath length:2];
	
	return rowIndexPath;
}

- (NSInteger)countOfNestedArray:(NSUInteger)section {
	NSArray *subArray = [self objectAtIndex:section];
	return [subArray count];
}

@end
