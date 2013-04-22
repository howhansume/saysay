//
//  SayInputTextView.m
//  USayApp
//
//  Created by 1team on 10. 7. 12..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "SayInputTextView.h"


@implementation SayInputTextView

-(void)setContentOffset:(CGPoint)point
{
	if(self.tracking || self.decelerating) {
		self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
	} else {
		
		float bottomOffset = (self.contentSize.height - self.frame.size.height + self.contentInset.bottom);
		if(point.y < bottomOffset && self.scrollEnabled) {
			self.contentInset = UIEdgeInsetsMake(0, 0, 8, 0);
		}
		
	}
	
	[super setContentOffset:point];
}

-(void)setContentInset:(UIEdgeInsets)inset
{
	UIEdgeInsets insets = inset;
	
	if(inset.bottom > 8) {
		insets.bottom = 0;
	}
	insets.top = 0;
	
	[super setContentInset:insets];
}


- (void)dealloc {
    [super dealloc];
}


@end
