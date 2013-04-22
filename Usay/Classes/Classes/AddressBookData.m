//
//  AddressBookData.m
//  USayApp
//
//  Created by Jong-Sung Park on 10. 5. 28..
//  Copyright 2010 INAMASS.NET. All rights reserved.
//

#import "AddressBookData.h"
#import "UserInfo.h"
#import "GroupInfo.h"
#import "USayAppAppDelegate.h"
#import "USayDefine.h"

//key-value의 키 정의
#define RECORDID_STRING		@"RecordId"
#define FIRST_NAME_STRING	@"First Name"
#define MIDDLE_NAME_STRING	@"Middle Name"
#define LAST_NAME_STRING	@"Last Name"

#define PREFIX_STRING	@"Prefix"
#define SUFFIX_STRING	@"Suffix"
#define NICKNAME_STRING	@"Nickname"

#define PHONETIC_FIRST_STRING	@"Phonetic First Name"
#define PHONETIC_MIDDLE_STRING	@"Phonetic Middle Name"
#define PHONETIC_LAST_STRING	@"Phonetic Last Name"

#define ORGANIZATION_STRING	@"Organization"
#define JOBTITLE_STRING		@"Job Title"
#define DEPARTMENT_STRING	@"Department"

#define NOTE_STRING	@"Note"

#define BIRTHDAY_STRING				@"Birthday"
#define CREATION_DATE_STRING		@"Creation Date"
#define MODIFICATION_DATE_STRING	@"Modification Date"

#define KIND_STRING	@"Kind"

#define EMAIL_STRING	@"Email"
#define ADDRESS_STRING	@"Address"
#define DATE_STRING		@"Date"
#define PHONE_STRING	@"Phone"
#define SMS_STRING		@"Instant Message"
#define URL_STRING		@"URL"
#define RELATED_STRING	@"Related Name"

#define IMAGE_STRING	@"Image"

@implementation AddressBookData

//@synthesize allAddrs, values, keys;
////singlevalue
//@synthesize firstname, lastname, middlename, prefix, suffix, nickname, firstnamephonetic, lastnamephonetic;
//@synthesize middlenamephonetic, organization, jobtitle, department, note;
////date
//@synthesize birthday,creationDate, modificationDate;
////mutivalue
//@synthesize emailArray, phoneArray, relatedNameArray, urlArray;
//@synthesize dateArray, addressArray, smsArray;
//@synthesize emailaddresses, phonenumbers, urls,image;
-(USayAppAppDelegate *) appDelegate
{
	return [[UIApplication sharedApplication] delegate];
}

-(NSArray *)arrayForMultiValue :(ABRecordRef)theRecord propertyIDOfArray:(ABPropertyID) propertyId {
	ABMultiValueRef theProperty = ABRecordCopyValue(theRecord, propertyId);
	//	NSArray *items = (NSArray *)ABMultiValueCopyArrayOfAllValues(theProperty);
	NSMutableArray *itemArray = [NSMutableArray array];
	if(ABMultiValueGetCount(theProperty) != 0){
		for(CFIndex i = 0;i<ABMultiValueGetCount(theProperty);i++){
			NSString *propertyValue = (NSString *)ABMultiValueCopyValueAtIndex(theProperty, i);
			NSString *propertyLabel = (NSString *)ABMultiValueCopyLabelAtIndex(theProperty, i);
			NSMutableDictionary *itemDic = [NSMutableDictionary dictionary];
			if(propertyValue != nil)
			[itemDic setObject:propertyValue forKey:@"value"];
			if(propertyLabel != nil)
			[itemDic setObject:propertyLabel forKey:@"label"];
			[itemArray addObject:itemDic];
			[propertyValue release];
			[propertyLabel release];
		}
		CFRelease(theProperty);
	}else {
		
		CFRelease(theProperty);
	}

	
	return (NSArray *)itemArray;
}

//OEM주소록의 전체 데이터 가져 오기
-(NSDictionary *)readFullOEMContacts{
	ABAddressBookRef addressBook = ABAddressBookCreate();

	CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
	CFArrayRef groups = ABAddressBookCopyArrayOfAllGroups(addressBook);
	CFIndex personCount = ABAddressBookGetPersonCount(addressBook);
	CFIndex groupCount = ABAddressBookGetGroupCount(addressBook);
	
	NSMutableArray *arrayGroups = [NSMutableArray array];
	NSMutableArray *arrayContacts = [NSMutableArray array];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	NSLocale *locale = [NSLocale currentLocale];
	[formatter setLocale:locale];
	[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
	
	//그룹이 있는 지 확인하는 그룹이 존재하면 배열에 인서트 한다.
	for(CFIndex g = 0;g<groupCount;g++){
		GroupInfo* abGroup = [[GroupInfo alloc] init];
		
		ABRecordRef gRecord = CFArrayGetValueAtIndex(groups,g);
		
		abGroup.RECORDID = [NSString stringWithFormat:@"%i", ABRecordGetRecordID(gRecord)*-1]; 
		abGroup.GROUPTITLE = [(NSString*)ABRecordCopyValue(gRecord, kABGroupNameProperty) autorelease];
		
		if(abGroup.GROUPTITLE != nil && [abGroup.GROUPTITLE length] > 0)
			[arrayGroups addObject:abGroup];
		
		[abGroup release];
	}	
	
	for(CFIndex i = 0;i<personCount;i++){
		UserInfo* abUser = [[UserInfo alloc] init];
		
		ABRecordRef aRecord = CFArrayGetValueAtIndex(people, i);
		
//		NSInteger aRecordID = ABRecordGetRecordID(aRecord);
		abUser.RECORDID = [NSString stringWithFormat:@"%i", ABRecordGetRecordID(aRecord)];
		DebugLog(@"RECORDID = %i", abUser.RECORDID);
		
		
		//사용자의 그룹아이디를 구해서 배열에 저장
		for(CFIndex g = 0;g<groupCount;g++){
			ABRecordRef gRecord = CFArrayGetValueAtIndex(groups, g);
			NSArray* groupContacts = (NSArray*)ABGroupCopyArrayOfAllMembers(gRecord);
			if([groupContacts count] > 0){
				for(id person in groupContacts){
					
					if((NSUInteger) ABRecordGetRecordID(person) == (NSUInteger)ABRecordGetRecordID(aRecord))
						abUser.GID = [NSString stringWithFormat:@"%i", ABRecordGetRecordID(gRecord)*-1];
				}				
			}else {
			//mezzo	[groupContacts release];
			}

			[groupContacts release];
		}
		
		//single-line string
		NSString* firstname = [(NSString *)ABRecordCopyValue(aRecord,kABPersonFirstNameProperty) autorelease];
		NSString* lastname = [(NSString *)ABRecordCopyValue(aRecord,kABPersonLastNameProperty) autorelease];
		//사용자 이름
		abUser.FORMATTED = [NSString stringWithFormat:@"%@%@",lastname?lastname:@"",firstname?firstname:@""];
/*		middlename = (NSString *)ABRecordCopyValue(aRecord,kABPersonMiddleNameProperty);
		if(middlename) abUser.MIDDLENAME = middlename;
		prefix = (NSString *)ABRecordCopyValue(aRecord,kABPersonPrefixProperty);
		if(prefix) abUser.FAMILYNAME = prefix;										//경칭
		suffix = (NSString *)ABRecordCopyValue(aRecord,kABPersonSuffixProperty);
		if(suffix) abUser.GIVENNAME = suffix;										//이름 접미사, 호칭
*/		
		NSString* nickname = [(NSString *)ABRecordCopyValue(aRecord,kABPersonNicknameProperty) autorelease];
		if(nickname) abUser.NICKNAME = nickname;
		
/*		firstnamephonetic = (NSString *)ABRecordCopyValue(aRecord,kABPersonFirstNamePhoneticProperty);
		if(firstnamephonetic) abUser.PHONETICNAME = firstnamephonetic;		
		lastnamephonetic = (NSString *)ABRecordCopyValue(aRecord,kABPersonLastNamePhoneticProperty);
		if(lastnamephonetic) [arrayContact setObject:lastnamephonetic forKey:PHONETIC_LAST_STRING];
		middlenamephonetic = (NSString *)ABRecordCopyValue(aRecord,kABPersonMiddleNamePhoneticProperty);
		if(middlenamephonetic) [arrayContact setObject:middlenamephonetic forKey:PHONETIC_MIDDLE_STRING];
*/
		NSString* organization = [(NSString *)ABRecordCopyValue(aRecord,kABPersonOrganizationProperty) autorelease];
		if(organization) abUser.ORGNAME = organization;
//		jobtitle = (NSString *)ABRecordCopyValue(aRecord,kABPersonJobTitleProperty);
//		if(jobtitle) abUser.JOBTITLE = jobtitle;
//		department = (NSString *)ABRecordCopyValue(aRecord,kABPersonDepartmentProperty);
//		if(department) abUser.DEPARTMENT = department;
		NSString* note = [(NSString *)ABRecordCopyValue(aRecord,kABPersonNoteProperty) autorelease];
		if(note) abUser.NOTE = note;
		//Date
//		birthday = (NSDate *)ABRecordCopyValue(aRecord,kABPersonBirthdayProperty);
//		if(birthday) abUser.BIRTHDAY = [formatter stringFromDate:birthday];
	
		//multyValue property;
		NSArray* lEmailArray = [self arrayForMultiValue:aRecord propertyIDOfArray:kABPersonEmailProperty];
		if(lEmailArray != nil){
			// Generic labels // kABWorkLabel, kABHomeLabel, kABOtherLabel
			for(NSDictionary* item in lEmailArray) {
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABHomeLabel])
					abUser.HOMEEMAILADDRESS = [item valueForKey:@"value"];
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABWorkLabel])
					abUser.ORGEMAILADDRESS = [item valueForKey:@"value"];
//				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABOtherLabel])
//					abUser.OTHEREMAILADDRESS = [item valueForKey:@"value"];
			}
		}
/*		addressArray = [self arrayForMultiValue:aRecord propertyIDOfArray:kABPersonAddressProperty];
		if(addressArray) {
			// kABPersonAddressStreetKey, kABPersonAddressCityKey, kABPersonAddressStateKey
			// kABPersonAddressZIPKey, kABPersonAddressCountryKey, kABPersonAddressCountryCodeKey
			for(NSDictionary* item in addressArray) {
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonAddressCityKey])
					abUser.HOMECITY = [item valueForKey:@"value"];
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonAddressZIPKey])
					abUser.HOMEZIPCODE = [item valueForKey:@"value"];
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonAddressStreetKey])
					abUser.HOMEADDRESSDETAIL = [item valueForKey:@"value"];
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonAddressCountryKey])
					abUser.HOMESTATE = [item valueForKey:@"value"];
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonAddressStateKey])
					abUser.HOMEADDRESS = [item valueForKey:@"value"];
				
			}
		}*/
//		dateArray = [self arrayForMultiValue:aRecord propertyIDOfArray:kABPersonDateProperty];
/*		if(dateArray) {
			//kABPersonAnniversaryLabel
			for(NSDictionary* item in dateArray) {
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonAnniversaryLabel])
					abUser.ANNIVERSARY = [item valueForKey:@"value"];
			}			
		}
*/		
		NSArray* lPhoneArray = [self arrayForMultiValue:aRecord propertyIDOfArray:kABPersonPhoneProperty];
		if(lPhoneArray != nil) {
			// kABWorkLabel, kABHomeLabel, kABOtherLabel
			// kABPersonPhoneMobileLabel, kABPersonPhoneIPhoneLabel, kABPersonPhoneMainLabel
			// kABPersonPhoneHomeFAXLabel, kABPersonPhoneWorkFAXLabel, kABPersonPhonePagerLabel
			for(NSDictionary* item in lPhoneArray) {
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneMobileLabel]){  //mobilephone
					abUser.MOBILEPHONENUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
					abUser.MOBILEPHONENUMBER = [abUser.MOBILEPHONENUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				}
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneIPhoneLabel]){  //iphone
					abUser.IPHONENUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
					abUser.IPHONENUMBER = [abUser.IPHONENUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				}
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneMainLabel]){		//mainphone
					abUser.MAINPHONENUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
					abUser.MAINPHONENUMBER = [abUser.MAINPHONENUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				}
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABHomeLabel]){				//homephone
					abUser.HOMEPHONENUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
					abUser.HOMEPHONENUMBER = [abUser.HOMEPHONENUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				}
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABWorkLabel]){				//orgphone
					abUser.ORGPHONENUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
					abUser.ORGPHONENUMBER = [abUser.ORGPHONENUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				}
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABOtherLabel]){				//otherphone
					abUser.OTHERPHONENUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
					abUser.OTHERPHONENUMBER = [abUser.OTHERPHONENUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				}
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhonePagerLabel]){  //phonepaser
					abUser.PARSERNUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
					abUser.PARSERNUMBER = [abUser.PARSERNUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				}
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneHomeFAXLabel]){ //homefax
					abUser.HOMEFAXPHONENUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
					abUser.HOMEFAXPHONENUMBER = [abUser.HOMEFAXPHONENUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				}
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneWorkFAXLabel]){ //orgfax
					abUser.ORGFAXPHONENUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
					abUser.ORGFAXPHONENUMBER = [abUser.ORGFAXPHONENUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
				}
			}
			
		}
//		smsArray = [self arrayForMultiValue:aRecord propertyIDOfArray:kABPersonInstantMessageProperty];
/*		if(smsArray) {
			// kABWorkLabel, kABHomeLabel, kABOtherLabel, 
			// kABPersonInstantMessageServiceKey, kABPersonInstantMessageUsernameKey
			// kABPersonInstantMessageServiceYahoo, kABPersonInstantMessageServiceJabber
			// kABPersonInstantMessageServiceMSN, kABPersonInstantMessageServiceICQ
			// kABPersonInstantMessageServiceAIM
			for(NSDictionary* item in smsArray) {
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABHomeLabel])
					abUser.IMS1 = [item valueForKey:@"value"];
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABWorkLabel])
					abUser.IMS2 = [item valueForKey:@"value"];
			}		
		}
*/
		NSArray* lUrlArray = [self arrayForMultiValue:aRecord propertyIDOfArray:kABPersonURLProperty];
		if(lUrlArray != nil) {
			// kABWorkLabel, kABHomeLabel, kABOtherLabel
			// kABPersonHomePageLabel
			for(NSDictionary* item in lUrlArray) {
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonHomePageLabel])
					abUser.URL1 = [item valueForKey:@"value"];
				if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABHomeLabel])
					abUser.URL2 = [item valueForKey:@"value"];
			}
		}
	
		if (ABPersonHasImageData(aRecord)) {
			CFDataRef imageData = ABPersonCopyImageData(aRecord);
//			UIImage *abimage = [UIImage imageWithData:(NSData *) imageData];
			CFRelease(imageData);
		}
		
		[arrayContacts addObject:abUser];
		[abUser release];
		
	}
	[formatter release];
	CFRelease(people);
	CFRelease(groups);
	CFRelease(addressBook);	
	
	
	NSMutableDictionary* fullAddressBook = [NSMutableDictionary dictionary];

	[fullAddressBook setObject:arrayGroups forKey:@"GROUP"];
	[fullAddressBook setObject:arrayContacts forKey:@"PERSON"];
	
	return fullAddressBook;
	
}

//OEM주소록에 추가된 데이터만 가져오기
-(NSDictionary *)readOEMContactsAlterData{
	//저장되어 있는 날짜 데이터를 읽어온다.테스트로 하드코딩 했으며 저장되는 날짜 스트링 형식은 하드코딩된 날짜 스트링대로 저장 되게 한다.
	NSString *lastSyncDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastSyncDate"];
	if(lastSyncDate == nil)
	   lastSyncDate = [[[NSString alloc]initWithFormat:@"20100101183001"] autorelease];
	
	//주소록
	ABAddressBookRef addressBook = ABAddressBookCreate();
	CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
	CFArrayRef groups = ABAddressBookCopyArrayOfAllGroups(addressBook);
	CFIndex personCount = ABAddressBookGetPersonCount(addressBook);
	CFIndex groupCount = ABAddressBookGetGroupCount(addressBook);
	
	NSLog(@"personCount = %d", personCount);
	
	NSMutableArray *arrayContacts = [NSMutableArray array];
	NSMutableArray *arrayGroups = [NSMutableArray array];
	//날짜 형식을 맞추기
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyyMMddHHmmss"];
	NSDate *basisDate = [formatter dateFromString:lastSyncDate];
	
//			NSArray* maxGroup = [GroupInfo findWithSql:@"SELECT * FROM _TGroupInfo ORDER BY ID DESC LIMIT 1;"];
//			GroupInfo* group = nil;
//			if([maxGroup objectAtIndex:0])
//				mxgroup = [maxGroup objectAtIndex:0];
	//날짜 역순 이다 
// mezzo	for(CFIndex i = 0;i<personCount;i++){
//	NSLog(@"personCount = %d", personCount);
	for(CFIndex i =personCount-1; i>=0; i--){
	//	NSLog(@"person number = %d", i);
		ABRecordRef aRecord = CFArrayGetValueAtIndex(people ,i);
		UserInfo* abUser = [[UserInfo alloc] init];
		
		NSDate* cdate = [(NSDate *)ABRecordCopyValue(aRecord,kABPersonCreationDateProperty) autorelease];
		//날자 비교. 년-월-일 시:분:초 로 초다위 까지 비교 하는 것이고, basisDate가 비교 하려는 날짜 보다 빠른지 검사.
		// NSOrderedAscending, NSOrderedSame, NSOrderedDescending관련 참조.
		//즉 나중 데이터면
		if([basisDate compare:cdate] ==  NSOrderedAscending)
		{
		//	NSLog(@"있다");
	//		NSInteger aRecordID = ABRecordGetRecordID(aRecord);
			abUser.RECORDID = [NSString stringWithFormat:@"%i", ABRecordGetRecordID(aRecord)]; 
		
			DebugLog(@"추가 데이터 날짜 레코드 %@", abUser.RECORDID);
			
		//	NSLog(@"RECORDID = %i", ABRecordGetRecordID(aRecord));
			
			for(CFIndex g = 0;g<groupCount;g++){
				
				ABRecordRef gRecord = CFArrayGetValueAtIndex(groups ,g);
				NSArray* groupContacts = (NSArray*)ABGroupCopyArrayOfAllMembers(gRecord);
				if([groupContacts count] > 0){
					for(id person in groupContacts){
						
						if((NSUInteger) ABRecordGetRecordID(person) == (NSUInteger)ABRecordGetRecordID(aRecord))
							abUser.GID = [NSString stringWithFormat:@"%i", ABRecordGetRecordID(gRecord)*-1];
					}
					
				}else {
			//mezzo		[groupContacts release];
				}
				
				[groupContacts release];				
			}
			
			//single-line string
			NSString* firstname = [(NSString *)ABRecordCopyValue(aRecord,kABPersonFirstNameProperty) autorelease];
			NSString* lastname = [(NSString *)ABRecordCopyValue(aRecord,kABPersonLastNameProperty) autorelease];
			abUser.FORMATTED = [NSString stringWithFormat:@"%@%@",lastname?lastname:@"",firstname?firstname:@""];
/*
			middlename = (NSString *)ABRecordCopyValue(aRecord,kABPersonMiddleNameProperty);
			if(middlename) abUser.MIDDLENAME = middlename;
			prefix = (NSString *)ABRecordCopyValue(aRecord,kABPersonPrefixProperty);
			if(prefix) abUser.FAMILYNAME = prefix;										//경칭
			suffix = (NSString *)ABRecordCopyValue(aRecord,kABPersonSuffixProperty);
			if(suffix) abUser.GIVENNAME = suffix;										//이름 접미사, 호칭
*/
			NSString* nickname = [(NSString *)ABRecordCopyValue(aRecord,kABPersonNicknameProperty) autorelease];
			if(nickname) abUser.NICKNAME = nickname;
/*			
			firstnamephonetic = (NSString *)ABRecordCopyValue(aRecord,kABPersonFirstNamePhoneticProperty);
			if(firstnamephonetic) abUser.PHONETICNAME = firstnamephonetic;
			
			 lastnamephonetic = (NSString *)ABRecordCopyValue(aRecord,kABPersonLastNamePhoneticProperty);
			 if(lastnamephonetic) [arrayContact setObject:lastnamephonetic forKey:PHONETIC_LAST_STRING];
			 middlenamephonetic = (NSString *)ABRecordCopyValue(aRecord,kABPersonMiddleNamePhoneticProperty);
			 if(middlenamephonetic) [arrayContact setObject:middlenamephonetic forKey:PHONETIC_MIDDLE_STRING];
			 */
			NSString* organization = [(NSString *)ABRecordCopyValue(aRecord,kABPersonOrganizationProperty) autorelease];
			if(organization) abUser.ORGNAME = organization;
//			NSString* jobtitle = [(NSString *)ABRecordCopyValue(aRecord,kABPersonJobTitleProperty) autorelease];
//			if(jobtitle) abUser.JOBTITLE = jobtitle;
//			department = [(NSString *)ABRecordCopyValue(aRecord,kABPersonDepartmentProperty) autorelease];
//			if(department) abUser.DEPARTMENT = department;
			NSString* note = [(NSString *)ABRecordCopyValue(aRecord,kABPersonNoteProperty) autorelease];
			if(note) abUser.NOTE = note;
			//Date
//			birthday = (NSDate *)ABRecordCopyValue(aRecord,kABPersonBirthdayProperty);
//			if(birthday) abUser.BIRTHDAY = [formatter stringFromDate:birthday];
			
			//multyValue property;
			NSArray* emailArray = [self arrayForMultiValue:aRecord propertyIDOfArray:kABPersonEmailProperty];
			if(emailArray != nil){
				// Generic labels // kABWorkLabel, kABHomeLabel, kABOtherLabel
				for(NSDictionary* item in emailArray) {
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABHomeLabel])
						abUser.HOMEEMAILADDRESS = [item valueForKey:@"value"];
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABWorkLabel])
						abUser.ORGEMAILADDRESS = [item valueForKey:@"value"];
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABOtherLabel])
						abUser.OTHEREMAILADDRESS = [item valueForKey:@"value"];
				}
			}
/*			addressArray = [self arrayForMultiValue:aRecord propertyIDOfArray:kABPersonAddressProperty];
			if(addressArray) {
				// kABPersonAddressStreetKey, kABPersonAddressCityKey, kABPersonAddressStateKey
				// kABPersonAddressZIPKey, kABPersonAddressCountryKey, kABPersonAddressCountryCodeKey
				for(NSDictionary* item in addressArray) {
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonAddressCityKey])
						abUser.HOMECITY = [item valueForKey:@"value"];
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonAddressZIPKey])
						abUser.HOMEZIPCODE = [item valueForKey:@"value"];
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonAddressStreetKey])
						abUser.HOMEADDRESSDETAIL = [item valueForKey:@"value"];
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonAddressCountryKey])
						abUser.HOMESTATE = [item valueForKey:@"value"];
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonAddressStateKey])
						abUser.HOMEADDRESS = [item valueForKey:@"value"];
					
				}
			}*/
/*			dateArray = [self arrayForMultiValue:aRecord propertyIDOfArray:kABPersonDateProperty];
			if(dateArray) {
				//kABPersonAnniversaryLabel
				for(NSDictionary* item in dateArray) {
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonAnniversaryLabel])
						abUser.ANNIVERSARY = [item valueForKey:@"value"];
				}			
			}
	*/		
			NSArray* phoneArray = [self arrayForMultiValue:aRecord propertyIDOfArray:kABPersonPhoneProperty];
			if(phoneArray != nil) {
				// kABWorkLabel, kABHomeLabel, kABOtherLabel
				// kABPersonPhoneMobileLabel, kABPersonPhoneIPhoneLabel, kABPersonPhoneMainLabel
				// kABPersonPhoneHomeFAXLabel, kABPersonPhoneWorkFAXLabel, kABPersonPhonePagerLabel
				for(NSDictionary* item in phoneArray) {
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneMobileLabel]){  //mobilephone
						abUser.MOBILEPHONENUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
						abUser.MOBILEPHONENUMBER = [abUser.MOBILEPHONENUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
					}
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneIPhoneLabel]){  //iphone
						abUser.IPHONENUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
						abUser.IPHONENUMBER = [abUser.IPHONENUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
					}
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneMainLabel]){		//mainphone
						abUser.MAINPHONENUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
						abUser.MAINPHONENUMBER = [abUser.MAINPHONENUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
					}
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABHomeLabel]){				//homephone
						abUser.HOMEPHONENUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
						abUser.HOMEPHONENUMBER = [abUser.HOMEPHONENUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
					}
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABWorkLabel]){				//orgphone
						abUser.ORGPHONENUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
						abUser.ORGPHONENUMBER = [abUser.ORGPHONENUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
					}
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABOtherLabel]){				//otherphone
						abUser.OTHERPHONENUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
						abUser.OTHERPHONENUMBER = [abUser.OTHERPHONENUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
					}
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhonePagerLabel]){  //phonepaser
						abUser.PARSERNUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
						abUser.PARSERNUMBER = [abUser.PARSERNUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
					}
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneHomeFAXLabel]){ //homefax
						abUser.HOMEFAXPHONENUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
						abUser.HOMEFAXPHONENUMBER = [abUser.HOMEFAXPHONENUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
					}
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonPhoneWorkFAXLabel]){ //orgfax
						abUser.ORGFAXPHONENUMBER = [[item valueForKey:@"value"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
						abUser.ORGFAXPHONENUMBER = [abUser.ORGFAXPHONENUMBER stringByReplacingOccurrencesOfString:@"+82" withString:@""];
					}
				}
				
			}
	//		smsArray = [self arrayForMultiValue:aRecord propertyIDOfArray:kABPersonInstantMessageProperty];
	/*		if(smsArray) {
				// kABWorkLabel, kABHomeLabel, kABOtherLabel, 
				// kABPersonInstantMessageServiceKey, kABPersonInstantMessageUsernameKey
				// kABPersonInstantMessageServiceYahoo, kABPersonInstantMessageServiceJabber
				// kABPersonInstantMessageServiceMSN, kABPersonInstantMessageServiceICQ
				// kABPersonInstantMessageServiceAIM
				for(NSDictionary* item in smsArray) {
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABHomeLabel])
						abUser.IMS1 = [item valueForKey:@"value"];
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABWorkLabel])
						abUser.IMS2 = [item valueForKey:@"value"];
				}		
			}
	 */
			NSArray* urlArray = [self arrayForMultiValue:aRecord propertyIDOfArray:kABPersonURLProperty];
			if(urlArray != nil) {
				// kABWorkLabel, kABHomeLabel, kABOtherLabel
				// kABPersonHomePageLabel
				for(NSDictionary* item in urlArray) {
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABPersonHomePageLabel])
						abUser.URL1 = [item valueForKey:@"value"];
					if([[item valueForKey:@"label"] isEqualToString:(NSString *)kABHomeLabel])
						abUser.URL2 = [item valueForKey:@"value"];
				}
			}
			if (ABPersonHasImageData(aRecord)) {
//				CFDataRef imageData = ABPersonCopyImageData(aRecord);
//				UIImage *abimage = [UIImage imageWithData:(NSData *) imageData];
//				CFRelease(imageData);
			}
			
			[arrayContacts addObject:abUser];
			[abUser release];
		} else {
			[abUser release];
			break; //날짜순 정렬이다 다행히 ㅋㅋㅋㅋ //mezzo
		}
		
	}
	if([arrayContacts count] > 0){
		for(CFIndex g = 0;g<groupCount;g++){
			GroupInfo* abGroup = [[GroupInfo alloc] init];
			
			ABRecordRef gRecord = CFArrayGetValueAtIndex(groups,g);
			
			abGroup.RECORDID = [NSString stringWithFormat:@"%i", ABRecordGetRecordID(gRecord)*-1]; 
			abGroup.GROUPTITLE = [(NSString*)ABRecordCopyValue(gRecord, kABGroupNameProperty) autorelease];
			
			if(abGroup.GROUPTITLE != nil && [abGroup.GROUPTITLE length] > 0)
				[arrayGroups addObject:abGroup];
			
			[abGroup release];
		}
	}
	

	[formatter release];
	CFRelease(groups);
	CFRelease(people);
	CFRelease(addressBook);		
	
	NSMutableDictionary* fullAddressBook = [NSMutableDictionary dictionary];
	
	[fullAddressBook setObject:arrayGroups forKey:@"GROUP"];
	[fullAddressBook setObject:arrayContacts forKey:@"PERSON"];
	
	return fullAddressBook;
}

-(void)dealloc{
//	if(allAddrs)[allAddrs release];
//	if(values)[values release];
//	if(keys)[keys release];
	
	[super dealloc];
}
@end
