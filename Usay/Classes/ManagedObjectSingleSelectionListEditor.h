#import <UIKit/UIKit.h>
#import "ManagedObjectAttributeEditor.h"

@interface ManagedObjectSingleSelectionListEditor : ManagedObjectAttributeEditor {
    NSArray            *list;
	NSString		*selectType;
	NSArray			*defaultValue;
	NSMutableArray *selectedGroup;
	NSString		*selectedValue;
	NSMutableDictionary* peopleInGroup;    
@private
	// 110125 analyze 사용 안함..
//    NSIndexPath        *lastIndexPath;
}

@property (nonatomic, retain) NSArray *list;
@property (nonatomic, retain) NSString *selectType;
@property (nonatomic, retain) NSArray  *defaultValue;
@property (nonatomic, retain) NSMutableArray *selectedGroup;
@property (nonatomic, retain) NSString		*selectedValue;
@property (nonatomic, retain) NSMutableDictionary* peopleInGroup;


-(void)updateDataValue:(NSString*)value forkey:(NSString*)key;
-(void)updateDataWithArray:(NSArray*)value forkey:(NSString*)key;

@end
