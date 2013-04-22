#import <UIKit/UIKit.h>
#import "ManagedObjectAttributeEditor.h"

#define kLabelTag       1
#define kTextFieldTag   2

@interface ManagedObjectStringEditor : ManagedObjectAttributeEditor<UITextFieldDelegate> {
	NSArray            *list;
	NSArray			 *labelList;
	


}
@property (nonatomic, retain) NSArray *list;
@property (nonatomic, retain) NSArray *labelList;


-(void)updateDataValue:(NSString*)value forkey:(NSString*)key;
-(void)updateDataWithArray:(NSArray*)value forkey:(NSString*)key;
-(void)buddyEditCompleted;
-(NSInteger) displayTextLength:(NSString*)text;
@end
