#import "ManagedObjectStringEditor.h"
#import "CheckPhoneNumber.h"
//#import "MyDeviceClass.h"			// sochae 2010.09.11 - UI Position

#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation ManagedObjectStringEditor
@synthesize list, labelList;
#pragma mark -
#pragma mark Table View methods
-(void)buddyEditCompleted {
	//입력 정보 저장 후, 저장이 완료 되면 popview 처리 추후 위치이동

  NSMutableArray* inputData = [NSMutableArray array];
	
	NSString* key = nil;
	NSString* value = nil;
	
	if(list != nil){
		for(int i = 0; i < [list count]; i++){
			NSMutableDictionary* cellData = [NSMutableDictionary dictionary];
			NSUInteger newPath[] = {0, i};
			NSIndexPath *cellIndexPath = [NSIndexPath indexPathWithIndexes:newPath length:2];
			UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:cellIndexPath];
			
			for(UIView* subView in [cell.contentView subviews]){
				if([subView isKindOfClass:[UILabel class]])
					key = ((UILabel*)subView).text;
				if([subView isKindOfClass:[UITextField class]])
					value = ((UITextField*)subView).text;
			}
			[cellData setObject:value forKey:key];
			[inputData addObject:cellData];
		}
		[self updateDataWithArray:inputData forkey:self.keypath];
	}else if(labelList != nil){
		//주소 추가 시 들어오는 부분
		for(int i = 0; i < [labelList count]; i++){
			NSMutableDictionary* cellData = [NSMutableDictionary dictionary];
			NSUInteger newPath[] = {0, i};
			NSIndexPath *cellIndexPath = [NSIndexPath indexPathWithIndexes:newPath length:2];
			UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:cellIndexPath];
			
			for(UIView* subView in [cell.contentView subviews]){
				if([subView isKindOfClass:[UILabel class]])
					key = ((UILabel*)subView).text;
				if([subView isKindOfClass:[UITextField class]]){
					value = ((UITextField*)subView).text;
					value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
					if([[self.keypath uppercaseString] rangeOfString:[NSString stringWithFormat:@"FORMATTED"]].location != NSNotFound){
						
						if ([self displayTextLength:value] > 40){//한글 20자
							UIAlertView* lengthAlert = [[UIAlertView alloc] initWithTitle:@"길이 제한" 
																				  message:@"이름은 최대 영문 40자(한글 20자)까지 입니다." delegate:nil 
																		cancelButtonTitle:@"확인" otherButtonTitles:nil];
							[lengthAlert show];
							[lengthAlert release];
							return;
						}
						if ([self displayTextLength:value] <= 0){//한글 20자
							UIAlertView* lengthAlert = [[UIAlertView alloc] initWithTitle:@"길이 제한" 
																				  message:@"이름은 최소\n 1자 이상 입력하셔야 합니다." delegate:nil 
																		cancelButtonTitle:@"확인" otherButtonTitles:nil];
							[lengthAlert show];
							[lengthAlert release];
							return;
						}
					}
				}
			}
			[cellData setObject:value forKey:key];
			[inputData addObject:cellData];
		}
		[self updateDataWithArray:inputData forkey:self.keypath];
	}else {
		//주소록 정보에서 수정하는 부분, 주소 추가시 핸드폰 번호 반환
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
		UITextField *textField = (UITextField *)[cell viewWithTag:kTextFieldTag];
		NSMutableString* returnValue = nil;
		NSString* fieldText = nil;
		if([[self.keypath uppercaseString] rangeOfString:[NSString stringWithFormat:@"NUMBER"]].location != NSNotFound){
			returnValue = (NSMutableString *)[textField.text stringByReplacingOccurrencesOfString:@"-" withString:@""];
		}else if([[self.keypath uppercaseString] rangeOfString:[NSString stringWithFormat:@"FORMATTED"]].location != NSNotFound){
			fieldText = textField.text;
			textField.text = [fieldText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			returnValue = [NSMutableString stringWithFormat:@"%@",textField.text];
			if ([self displayTextLength:returnValue] > 40){//한글 20자
				UIAlertView* lengthAlert = [[UIAlertView alloc] initWithTitle:@"길이 제한" 
											message:@"이름은 최대 영문 40자(한글 20자)까지 입니다." delegate:nil 
															cancelButtonTitle:@"확인" otherButtonTitles:nil];
				[lengthAlert show];
				[lengthAlert release];
				return;
			}
		}else if([[self.keypath uppercaseString] rangeOfString:[NSString stringWithFormat:@"ORGNAME"]].location != NSNotFound){
			fieldText = textField.text;
			textField.text = [fieldText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			returnValue = [NSMutableString stringWithFormat:@"%@",textField.text];
			if ([self displayTextLength:returnValue] > 30){//한글 15자
				UIAlertView* lengthAlert = [[UIAlertView alloc] initWithTitle:@"길이 제한" 
																	  message:@"소속은 최대 영문30자(한글 15자)까지 입니다." delegate:nil 
															cancelButtonTitle:@"확인" otherButtonTitles:nil];
				[lengthAlert show];
				[lengthAlert release];
				return;
			}
		}else if([[self.keypath uppercaseString] rangeOfString:[NSString stringWithFormat:@"NICKNAME"]].location != NSNotFound){
			fieldText = textField.text;
			textField.text = [fieldText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			returnValue = [NSMutableString stringWithFormat:@"%@",textField.text];
			if ([self displayTextLength:returnValue] > 20){ //한글 10자
				UIAlertView* lengthAlert = [[UIAlertView alloc] initWithTitle:@"길이 제한" 
																	  message:@"별명은 최대 영문 20자(한글 10자)까지 입니다." delegate:nil 
															cancelButtonTitle:@"확인" otherButtonTitles:nil];
				[lengthAlert show];
				[lengthAlert release];
				return;
			}
		}else if([[self.keypath uppercaseString] rangeOfString:[NSString stringWithFormat:@"NOTE"]].location != NSNotFound){
			fieldText = textField.text;
			textField.text = [fieldText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			returnValue = [NSMutableString stringWithFormat:@"%@",textField.text];
			if ([self displayTextLength:returnValue] > 260){ //한글 130자
				UIAlertView* lengthAlert = [[UIAlertView alloc] initWithTitle:@"길이 제한" 
																	  message:@"메모는 최대 영문 260자(한글 130자)까지 입니다." delegate:nil 
															cancelButtonTitle:@"확인" otherButtonTitles:nil];
				[lengthAlert show];
				[lengthAlert release];
				return;
			}
		}else if([[self.keypath uppercaseString] rangeOfString:[NSString stringWithFormat:@"URL"]].location != NSNotFound){
			fieldText = textField.text;
			textField.text = [fieldText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			returnValue = [NSMutableString stringWithFormat:@"%@",textField.text];
			if ([self displayTextLength:returnValue] > 100){ //한글 50자
				UIAlertView* lengthAlert = [[UIAlertView alloc] initWithTitle:@"길이 제한" 
																	  message:@"홈페이지는 최대 영문 100자(한글 50자)까지 입니다." delegate:nil 
															cancelButtonTitle:@"확인" otherButtonTitles:nil];
				[lengthAlert show];
				[lengthAlert release];
				return;
			}
		}else if([[self.keypath uppercaseString] rangeOfString:[NSString stringWithFormat:@"EMAIL"]].location != NSNotFound){
			fieldText = textField.text;
			textField.text = [fieldText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			returnValue = [NSMutableString stringWithFormat:@"%@",textField.text];
			if ([self displayTextLength:returnValue] > 30){//한글 15자
				UIAlertView* lengthAlert = [[UIAlertView alloc] initWithTitle:@"길이 제한" 
																	  message:@"이메일는 최대 영문 30자(한글 15자)까지 입니다." delegate:nil 
															cancelButtonTitle:@"확인" otherButtonTitles:nil];
				[lengthAlert show];
				[lengthAlert release];
				return;
			}
		}else{
			fieldText = textField.text;
			textField.text = [fieldText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			returnValue = [NSMutableString stringWithFormat:@"%@",textField.text];
			if ([self displayTextLength:returnValue] > 40){//한글 20자
				UIAlertView* lengthAlert = [[UIAlertView alloc] initWithTitle:@"길이 제한" 
																	  message:@"입력 값 기본은 최대 영문 40자(한글 20자)까지 입니다." delegate:nil 
															cancelButtonTitle:@"확인" otherButtonTitles:nil];
				[lengthAlert show];
				[lengthAlert release];
				return;
			}
		}
		[self updateDataValue:returnValue forkey:self.keypath];
	}
	
	[self.navigationController popViewControllerAnimated:YES];
}


-(void)updateDataValue:(NSString*)value forkey:(NSString*)key {
	[self.delegate updateDataValue:value forkey:key];
}
-(void)updateDataWithArray:(NSArray*)value forkey:(NSString*)key{
	[self.delegate updateDataWithArray:value forkey:key];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(labelList != nil)
		return [labelList count];
	return 1;
}
#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Relinquish ownership any cached data, images, etc that aren't in use.
}
#pragma mark -
#pragma mark controller Method
-(void)viewDidLoad {
	self.view.backgroundColor = ColorFromRGB(0xedeff2);
	[super viewDidLoad];
	UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 35.0)];
	customView.backgroundColor = [UIColor clearColor];

	// sochae 2010.09.11 - UI Position
	//CGRect rect = [MyDeviceClass deviceOrientation];
	CGRect rect = self.view.frame;
	// ~sochae
	
	if([[self.keypath uppercaseString] rangeOfString:[NSString stringWithFormat:@"NUMBER"]].location != NSNotFound){
		UIFont *informationFont = [UIFont systemFontOfSize:15];
		CGSize infoStringSize = [@"전화 번호를 입력해 주세요." sizeWithFont:informationFont constrainedToSize:(CGSizeMake(rect.size.width-30.0, 20.0f))];
		UILabel *informationLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 13, rect.size.width-40.0, infoStringSize.height)];
		[informationLabel setFont:informationFont];
		[informationLabel setTextColor:ColorFromRGB(0x313b48)];
		[informationLabel setBackgroundColor:[UIColor clearColor]];
		[informationLabel setText:@"전화 번호를 입력해 주세요."];
		[customView addSubview:informationLabel];
		[informationLabel release];
		
	}else if([[self.keypath uppercaseString] rangeOfString:[NSString stringWithFormat:@"FORMATTED"]].location != NSNotFound){
		UIFont *informationFont = [UIFont systemFontOfSize:15];
		CGSize infoStringSize = [@"이름을 입력해 주세요. 한글 최대 20자" sizeWithFont:informationFont constrainedToSize:(CGSizeMake(rect.size.width-30.0, 20.0f))];
		UILabel *informationLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 13, rect.size.width-40.0, infoStringSize.height)];
		[informationLabel setFont:informationFont];
		[informationLabel setTextColor:ColorFromRGB(0x313b48)];
		[informationLabel setBackgroundColor:[UIColor clearColor]];
		[informationLabel setText:@"이름을 입력해 주세요. 한글 최대 20자"];
		[customView addSubview:informationLabel];
		[informationLabel release];
		
	}else if([[self.keypath uppercaseString] rangeOfString:[NSString stringWithFormat:@"ORGNAME"]].location != NSNotFound){
		UIFont *informationFont = [UIFont systemFontOfSize:15];
		CGSize infoStringSize = [@"소속을 입력해 주세요. 한글 최대 15자" sizeWithFont:informationFont constrainedToSize:(CGSizeMake(rect.size.width-30.0, 20.0f))];
		UILabel *informationLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 13, rect.size.width-40.0, infoStringSize.height)];
		[informationLabel setFont:informationFont];
		[informationLabel setTextColor:ColorFromRGB(0x313b48)];
		[informationLabel setBackgroundColor:[UIColor clearColor]];
		[informationLabel setText:@"소속을 입력해 주세요. 한글 최대 15자"];
		[customView addSubview:informationLabel];
		[informationLabel release];
		
	}else if([[self.keypath uppercaseString] rangeOfString:[NSString stringWithFormat:@"NICKNAME"]].location != NSNotFound){
		UIFont *informationFont = [UIFont systemFontOfSize:15];
		CGSize infoStringSize = [@"별명을 입력해 주세요. 한글 최대 10자" sizeWithFont:informationFont constrainedToSize:(CGSizeMake(rect.size.width-30.0, 20.0f))];
		UILabel *informationLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 13, rect.size.width-40.0, infoStringSize.height)];
		[informationLabel setFont:informationFont];
		[informationLabel setTextColor:ColorFromRGB(0x313b48)];
		[informationLabel setBackgroundColor:[UIColor clearColor]];
		[informationLabel setText:@"별명을 입력해 주세요. 한글 최대 10자"];
		[customView addSubview:informationLabel];
		[informationLabel release];
		
	}else if([[self.keypath uppercaseString] rangeOfString:[NSString stringWithFormat:@"NOTE"]].location != NSNotFound){
		UIFont *informationFont = [UIFont systemFontOfSize:15];
		CGSize infoStringSize = [@"메모를 입력해 주세요. 한글 최대 130자" sizeWithFont:informationFont constrainedToSize:(CGSizeMake(rect.size.width-30.0, 20.0f))];
		UILabel *informationLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 13, rect.size.width-40.0, infoStringSize.height)];
		[informationLabel setFont:informationFont];
		[informationLabel setTextColor:ColorFromRGB(0x313b48)];
		[informationLabel setBackgroundColor:[UIColor clearColor]];
		[informationLabel setText:@"메모를 입력해 주세요. 한글 최대 130자"];
		[customView addSubview:informationLabel];
		[informationLabel release];
		
	}else if([[self.keypath uppercaseString] rangeOfString:[NSString stringWithFormat:@"URL"]].location != NSNotFound){
		UIFont *informationFont = [UIFont systemFontOfSize:15];
		CGSize infoStringSize = [@"홈페이지를 입력해 주세요. 한글 최대 50자" sizeWithFont:informationFont constrainedToSize:(CGSizeMake(rect.size.width-20.0, 20.0f))];
		UILabel *informationLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 13, rect.size.width-30.0, infoStringSize.height)];
		[informationLabel setFont:informationFont];
		[informationLabel setTextColor:ColorFromRGB(0x313b48)];
		[informationLabel setBackgroundColor:[UIColor clearColor]];
		[informationLabel setText:@"홈페이지를 입력해 주세요. 한글 최대 50자"];
		[customView addSubview:informationLabel];	
		[informationLabel release];
		
	}else if([[self.keypath uppercaseString] rangeOfString:[NSString stringWithFormat:@"EMAIL"]].location != NSNotFound){
		UIFont *informationFont = [UIFont systemFontOfSize:15];
		CGSize infoStringSize = [@"이메일을 입력해 주세요. 한글 최대 15자" sizeWithFont:informationFont constrainedToSize:(CGSizeMake(rect.size.width-30.0, 20.0f))];
		UILabel *informationLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 13, rect.size.width-40.0, infoStringSize.height)];
		[informationLabel setFont:informationFont];
		[informationLabel setTextColor:ColorFromRGB(0x313b48)];
		[informationLabel setBackgroundColor:[UIColor clearColor]];
		[informationLabel setText:@"이메일을 입력해 주세요. 한글 최대 15자"];
		[customView addSubview:informationLabel];
		[informationLabel release];
	}
	
	self.tableView.tableHeaderView = customView;
	[customView release];
	
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	
	
	UIImage* rightBarBtnImg = [[UIImage imageNamed:@"btn_top_complete.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	UIImage* rightBarBtnSelImg = [[UIImage imageNamed:@"btn_top_complete_focus.png"]stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[rightBarButton addTarget:self action:@selector(buddyEditCompleted) forControlEvents:UIControlEventTouchUpInside];
	[rightBarButton setImage:rightBarBtnImg forState:UIControlStateNormal];
	[rightBarButton setImage:rightBarBtnSelImg forState:UIControlStateSelected];
	rightBarButton.frame = CGRectMake(0.0, 0.0, rightBarBtnImg.size.width, rightBarBtnImg.size.height);
	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
	self.navigationItem.rightBarButtonItem = rightButton;
	[rightButton release];	
	
	self.tableView.scrollEnabled = NO;
	
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ManagedObjectStringEditorCell = @"ManagedObjectStringEditorCell";
    
	NSUInteger row = [indexPath row];
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ManagedObjectStringEditorCell];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:ManagedObjectStringEditorCell] autorelease];
        UILabel *label = nil;
		if(labelList != nil){
			UIFont *informationFont = [UIFont boldSystemFontOfSize:17.0];
			CGSize infoStringSize = [[labelList objectAtIndex:row] sizeWithFont:informationFont constrainedToSize:(CGSizeMake(80.0, 20.0))];
			label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, infoStringSize.width, 25)];
			label.textAlignment = UITextAlignmentLeft;
			label.tag = kLabelTag;
			label.textColor = ColorFromRGB(0x2284ac);
			[cell.contentView addSubview:label];
		}else{ 
			UIFont *informationFont = [UIFont boldSystemFontOfSize:17.0];
			CGSize infoStringSize = [labelString sizeWithFont:informationFont constrainedToSize:(CGSizeMake(80.0, 20.0))];
			label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, infoStringSize.width, 25)];
			label.textAlignment = UITextAlignmentLeft;
			label.tag = kLabelTag;
			label.textColor = ColorFromRGB(0x2284ac);
			[cell.contentView addSubview:label];
		}
		
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 80, 25)];
//        label.textAlignment = UITextAlignmentLeft;
//        label.tag = kLabelTag;
// //       UIFont *font = [UIFont boldSystemFontOfSize:17.0];
// //       label.textColor = kNonEditableTextColor;
// //       label.font = font;
//		label.textColor = ColorFromRGB(0x2284ac);
//		label.font = [UIFont boldSystemFontOfSize:17.0];
//        [cell.contentView addSubview:label];
		
        UITextField *theTextField = [[UITextField alloc] initWithFrame:CGRectMake(label.frame.size.width+20, 11, tableView.frame.size.width - 30 -(label.frame.size.width+20), 25)];
        
        [cell.contentView addSubview:theTextField];
        theTextField.tag = kTextFieldTag;
		theTextField.delegate = self;
		theTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
		theTextField.font = [UIFont systemFontOfSize:17.0];
		theTextField.textColor = ColorFromRGB(0x7c7c86);
		theTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		[label release];
        [theTextField release];
    }
	
//	NSUInteger section = [indexPath section];
	
	
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:kLabelTag];
	if(labelList != nil)
		label.text = [labelList objectAtIndex:row];
	else 
		label.text = labelString;

    UITextField *textField = (UITextField *)[cell.contentView viewWithTag:kTextFieldTag];
	
//	NSString* compareString = [NSString stringWithFormat:@"NUMBER"];
	if([[self.keypath uppercaseString] rangeOfString:[NSString stringWithFormat:@"NUMBER"]].location != NSNotFound){
		textField.keyboardType = UIKeyboardTypeNumberPad;
	}else if([self.keypath rangeOfString:[NSString stringWithFormat:@"url"]].location != NSNotFound){
		textField.keyboardType = UIKeyboardTypeURL;
		textField.returnKeyType = UIReturnKeyDone;
	}else if([[self.keypath uppercaseString] rangeOfString:[NSString stringWithFormat:@"EMAIL"]].location != NSNotFound){
		textField.keyboardType = UIKeyboardTypeEmailAddress;
		textField.returnKeyType = UIReturnKeyDone;
	}else{
		textField.keyboardType = UIKeyboardTypeDefault;
		textField.returnKeyType = UIReturnKeyDone;
	}
	/*
	NSString *currentValue = nil;
	if(list != nil){
		if([list objectAtIndex:row] != [NSNull null])
			currentValue = [list objectAtIndex:row];
		else 
			currentValue = @"";
	}else{
		if([self.keypath isEqualToString:@"Name"]){
			if(section == 0)
				currentValue = [self.addValueDic valueForKey:@"formatted"];
		}else{
			currentValue = [self.addValueDic valueForKey:self.keypath];
		}
	}
*/
	if([[self.keypath uppercaseString] rangeOfString:[NSString stringWithFormat:@"NUMBER"]].location != NSNotFound){
		textField.text = [CheckPhoneNumber convertPhoneInsertHyphen:(NSMutableString*)self.passDefaultValue];
	}else {
		textField.text =  self.passDefaultValue;
	}

    [textField becomeFirstResponder];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark Text Field delegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
	
	if([[self.keypath uppercaseString] rangeOfString:[NSString stringWithFormat:@"NUMBER"]].location != NSNotFound){
		UITextField *phoneNumberTextField = (UITextField *)[self.view viewWithTag:kTextFieldTag];
		if(textField == phoneNumberTextField){	
			CheckPhoneNumber *checkNumber = [[CheckPhoneNumber alloc] initMaxLength:14];
			BOOL isCheck = [checkNumber checkTextFieldPhoneNumber:textField shouldChangeCharactersInRange:range replacementString:string];
			[checkNumber release];
			return isCheck;
		}
	}else {
		return YES;
	}

	return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	[self buddyEditCompleted];
	return NO;
}


#pragma mark -
#pragma mark text value check Method
-(NSInteger) displayTextLength:(NSString*)text
{
	NSInteger textLength = [text length];
	NSInteger textLengthUTF8 = [text lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	NSInteger correntLength = (textLengthUTF8 - textLength)/2 + textLength;
	
	return correntLength;
}

@end
