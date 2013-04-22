#import <Foundation/Foundation.h>

@protocol ItemValueDisplay
- (NSString *)itemValueDisplay;
@end

@interface NSString (ItemValueDisplay) <ItemValueDisplay>
- (NSString *)itemValueDisplay;
@end

@interface NSDate (ItemValueDisplay) <ItemValueDisplay>
- (NSString *)itemValueDisplay;
@end

@interface NSNumber (ItemValueDisplay) <ItemValueDisplay>
- (NSString *)itemValueDisplay;
@end

@interface NSDecimalNumber (ItemValueDisplay) <ItemValueDisplay>
- (NSString *)itemValueDisplay;
@end
