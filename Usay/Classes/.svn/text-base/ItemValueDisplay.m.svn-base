#import "ItemValueDisplay.h"

@implementation NSString (ItemValueDisplay)
- (NSString *)itemValueDisplay {
	return self;
}
@end

@implementation NSDate (ItemValueDisplay)
- (NSString *)itemValueDisplay {
    
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle:NSDateFormatterMediumStyle];
	NSString *ret = [formatter stringFromDate:self];
	[formatter release];
	return ret;
}
@end

@implementation NSNumber (ItemValueDisplay) 
- (NSString *)itemValueDisplay {
    return [self descriptionWithLocale:[NSLocale currentLocale]];
}
@end

@implementation NSDecimalNumber (ItemValueDisplay) 
- (NSString *)itemValueDisplay {
    return [self descriptionWithLocale:[NSLocale currentLocale]];
}
@end
