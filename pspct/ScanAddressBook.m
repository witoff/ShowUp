//
//  ScanAddressBook.m
//  pspct
//
//  Created by Robert Witoff on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ScanAddressBook.h"
#import <AddressBook/AddressBook.h>
#import "Contact.h"
#import <Accelerate/Accelerate.h>


@interface ScanAddressBook (hidden)

- (Contact*)getContactWithRecord:(ABRecordRef)ref;

- (NSArray*) getAllContacts;

- (BOOL)doBidirectionalSubstringMatch:(NSString*)one andTwo:(NSString*)two;

- (NSArray*)matchesFirstName:(NSString*)searchString withContactPool:(NSArray*)contacts searchSubstrings:(BOOL)doSearchSubstrings;
- (NSArray*)matchesLastName:(NSString*)searchString withContactPool:(NSArray*)contacts searchSubstrings:(BOOL)doSearchSubstrings;

- (void) testSearch;

+ (NSArray*)allcontacts;
+ (void)setAllcontacts:(NSArray*)newContacts;

@end

static NSArray* allcontacts;


@implementation ScanAddressBook

+ (NSArray*)allcontacts {
    return allcontacts;
}

+ (void)setAllcontacts:(NSArray *)newContacts
{
    if (allcontacts != newContacts) {
        allcontacts = newContacts;
    }
}

+(void)invalidateContactList
{
    allcontacts = nil;
}

- (void) testSearch
{
    NSUInteger i;
    NSUInteger k;
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    NSArray *people = (__bridge_transfer NSArray *) ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    if ( people==nil )
    {
        NSLog(@"No address book entries");
        CFRelease(addressBook);
        return;
    }
    
    for ( i=0; i<[people count]; i++ )
    {
        
        ABRecordRef person = (__bridge_retained ABRecordRef)[people objectAtIndex:i];
        
        ABMutableMultiValueRef lastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
        CFIndex lastNameCount = ABMultiValueGetCount( lastName );
        
        for ( k=0; k<lastNameCount; k++ )
        {
            
            CFStringRef phoneNumberLabel = ABMultiValueCopyLabelAtIndex( lastName, k );
            CFStringRef phoneNumberValue = ABMultiValueCopyValueAtIndex( lastName, k );
            CFStringRef phoneNumberLocalizedLabel = ABAddressBookCopyLocalizedLabel( phoneNumberLabel );    // converts "_$!<Work>!$_" to "work" and "_$!<Mobile>!$_" to "mobile"
            
            // Find the ones you want here
            //
            NSLog(@"-----LAST NAME ENTRY -> %@ : %@", phoneNumberLocalizedLabel, phoneNumberValue );
            
            CFRelease(phoneNumberLocalizedLabel);
            CFRelease(phoneNumberLabel);
            CFRelease(phoneNumberValue);
        }
        
        //
        // Phone Numbers
        //
        ABMutableMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
        CFIndex phoneNumberCount = ABMultiValueGetCount( phoneNumbers );
        
        for ( k=0; k<phoneNumberCount; k++ )
        {
            CFStringRef phoneNumberLabel = ABMultiValueCopyLabelAtIndex( phoneNumbers, k );
            CFStringRef phoneNumberValue = ABMultiValueCopyValueAtIndex( phoneNumbers, k );
            CFStringRef phoneNumberLocalizedLabel = ABAddressBookCopyLocalizedLabel( phoneNumberLabel );    // converts "_$!<Work>!$_" to "work" and "_$!<Mobile>!$_" to "mobile"
            
            // Find the ones you want here
            //
            NSLog(@"-----PHONE ENTRY -> %@ : %@", phoneNumberLocalizedLabel, phoneNumberValue );
            
            CFRelease(phoneNumberLocalizedLabel);
            CFRelease(phoneNumberLabel);
            CFRelease(phoneNumberValue);
        }
    }
    
    CFRelease(addressBook);
}

#pragma mark - contact getters

- (NSArray*) getAllContacts
{
    if (allcontacts)
        return allcontacts;
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    
    NSMutableDictionary *dicContact;
    NSMutableArray *contactArray = [[NSMutableArray alloc] initWithCapacity:100];
    for( int i = 0 ; i < nPeople ; i++ )
    {
        
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i );
        Contact *contact = [self getContactWithRecord:ref];      
        CFRelease(ref);
        
        [contactArray addObject:contact];
    }
    
    CFRelease(addressBook);
    //CFRelease(allPeople);
    allcontacts = contactArray;
    return allcontacts;
}

- (Contact*)getContactWithRecord:(ABRecordRef)ref
{
    
    Contact *contact = [[Contact alloc] init];
    
    
    //id
    ABRecordID record_id = ABRecordGetRecordID(ref);
    NSNumber *identifier = [NSNumber numberWithInt:record_id];
    contact.identifier = identifier;
    
    //firstname
    if(ABRecordCopyValue(ref, kABPersonFirstNameProperty) != nil || 
       [[NSString stringWithFormat:@"%@",ABRecordCopyValue(ref, kABPersonFirstNameProperty)] length] == 0)
        contact.firstname = [NSString stringWithFormat:@"%@",ABRecordCopyValue(ref, kABPersonFirstNameProperty)];
    
    //lastname
    if(ABRecordCopyValue(ref, kABPersonLastNameProperty) != nil || [[NSString stringWithFormat:@"%@",ABRecordCopyValue(ref, kABPersonLastNameProperty)] length] == 0)
        contact.lastname = [NSString stringWithFormat:@"%@",ABRecordCopyValue(ref, kABPersonLastNameProperty)];
    
    //image
    NSData *imgData = (__bridge_transfer NSData *) ABPersonCopyImageData(ref);
    contact.image = [UIImage imageWithData:imgData];
    
    //all phone numbers
    ABMutableMultiValueRef phoneNumbers = ABRecordCopyValue(ref, kABPersonPhoneProperty);
    CFIndex phoneNumberCount = ABMultiValueGetCount( phoneNumbers );
    
    for (int i=0; i<phoneNumberCount; i++ )
    {
        CFStringRef cfLabel = ABMultiValueCopyLabelAtIndex( phoneNumbers, i );
        CFStringRef cfNumber = ABMultiValueCopyValueAtIndex( phoneNumbers, i );
        
        // converts "_$!<Work>!$_" to "work" and "_$!<Mobile>!$_" to "mobile"
        CFStringRef cfLocalized = ABAddressBookCopyLocalizedLabel( cfLabel );   
        
        NSString *label = (__bridge NSString *)cfLocalized;
        NSString *number = (__bridge NSString *)cfNumber;
        
        NSDictionary *dicNumber = [[NSDictionary alloc] initWithObjectsAndKeys:label, @"label", number, @"number", nil];
        
        [contact.numbers addObject:dicNumber];
        
        CFRelease(cfLocalized);
        CFRelease(cfLabel);
        CFRelease(cfNumber);
    }
    
    //email
    CFTypeRef multival = ABRecordCopyValue(ref, kABPersonEmailProperty);
    NSArray *arrayEmail = (__bridge_transfer NSArray *)ABMultiValueCopyArrayOfAllValues(multival);
    contact.email = [arrayEmail objectAtIndex:0];
    
    CFRelease(multival);
    
    return contact;
    
}

- (Contact*)getContactWithId:(NSNumber*)identifier
{
    ABAddressBookRef addressBook = ABAddressBookCreate();
    ABRecordID recordId = [identifier integerValue];
    
    ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBook, recordId);
    Contact *contact = [self getContactWithRecord:person];
    
    CFRelease(addressBook);
    CFRelease(person);
    
    return contact;
}

#pragma mark - searching

- (Contact*)simpleSearch:(NSString*)firstname andLastName:(NSString*)lastname;
{
    NSLog(@"simpleSearch");
    if (firstname)
        firstname = [firstname lowercaseString];
    if (lastname)
        lastname = [lastname lowercaseString];
    
    NSLog(@"searching for last name: '%@'", lastname);
    
    for (Contact *contact in [self getAllContacts]) {
        NSString* abFirstname = [contact.firstname lowercaseString];
        NSString* abLastname = [contact.lastname lowercaseString];
        
        if (lastname && lastname.length>0)
        {
            
            if ([abLastname isEqualToString:lastname])
            {
                NSLog(@"last names are equal");
                if (!firstname)
                    return contact;
                if ([self doBidirectionalSubstringMatch:firstname andTwo:abFirstname])
                    return contact;
                if (abLastname.length==0 && [self doBidirectionalSubstringMatch:firstname andTwo:abFirstname])
                    return contact;
                NSLog(@"no last name match");
            }
            else if (abLastname.length==0 && [self doBidirectionalSubstringMatch:abFirstname andTwo:lastname])
                return contact;
            
        }
        else if ([self doBidirectionalSubstringMatch:firstname andTwo:abFirstname])
            return contact;
        //Conditional needed to see if it's a common first name
        if (abLastname.length==0 && [self doBidirectionalSubstringMatch:firstname andTwo:abFirstname])
            return contact;
        
        //
        
    }
    NSLog(@"no match for:\nfirstname: %@\nlastname: %@", firstname, lastname);
    return nil;
}

- (NSArray*)matchesLastName:(NSString*)searchString withContactPool:(NSArray*)contacts searchSubstrings:(BOOL)doSearchSubstrings
{
    NSMutableArray *matches = [[NSMutableArray alloc] initWithCapacity:5];
    
    for (Contact *contact in contacts) {
        NSString* abSearchString = [contact.lastname lowercaseString];
        
        if (doSearchSubstrings)
        {
            if ([self doBidirectionalSubstringMatch:abSearchString andTwo:searchString])
                [matches addObject:contact];
        }
        else 
        {
            if ([abSearchString isEqualToString:searchString])
            {
                [matches addObject:contact];
            }
        }
    }
    return matches;
}
- (NSArray*)matchesFirstName:(NSString*)searchString withContactPool:(NSArray*)contacts searchSubstrings:(BOOL)doSearchSubstrings
{
    NSMutableArray *matches = [[NSMutableArray alloc] initWithCapacity:5];
    
    for (Contact *contact in contacts) {
        NSString* abSearchString = [contact.firstname lowercaseString];
        
        if (doSearchSubstrings)
        {
            if ([self doBidirectionalSubstringMatch:abSearchString andTwo:searchString])
                [matches addObject:contact];
        }
        else 
        {
            if ([abSearchString isEqualToString:searchString])
            {
                [matches addObject:contact];
            }
        }
    }
    return matches;
}


- (Contact*) search:(NSString*)firstname andLastName:(NSString*)lastname
{
    NSLog(@"simpleSearch");
    
    if (firstname.length == 0)
        firstname = nil;
    if (lastname.length == 0)
        lastname = nil;
    
    if (firstname)
        firstname = [firstname lowercaseString];
    if (lastname)
        lastname = [lastname lowercaseString];
    
    NSLog(@"searching for last name: '%@'", lastname);
    
    
    
    //
    // LAST NAME MATCHING
    //
    if (lastname)
    {
        NSArray *matchesLastName = [self matchesLastName:lastname withContactPool:[self getAllContacts] searchSubstrings:NO];
        
        if (matchesLastName.count>0)
        {
            NSLog(@"lastname matched");
            if (!firstname)
            {     
                Contact* contact = [matchesLastName objectAtIndex:0];
                contact.matchConfidence = [NSNumber numberWithDouble: .9 /exp(matchesLastName.count-2)];
                return contact;                
            }
            else
            {
                NSLog(@"lastname matched: %i. and a firstname was provided", matchesLastName.count);
                NSArray *matchesLastAndFirst = [self matchesFirstName:firstname withContactPool:matchesLastName searchSubstrings:NO];
                if (matchesLastAndFirst.count>0)
                {
                    Contact* contact = [matchesLastAndFirst objectAtIndex:0];
                    contact.matchConfidence = [NSNumber numberWithDouble: .99 /exp(matchesLastName.count-2)];
                    return contact;
                }
                else
                {
                    matchesLastAndFirst = [self matchesFirstName:firstname withContactPool:matchesLastName searchSubstrings:YES];
                    if (matchesLastAndFirst.count>0)
                    {
                        Contact* contact = [matchesLastAndFirst objectAtIndex:0];
                        contact.matchConfidence = [NSNumber numberWithDouble: .80 /exp(matchesLastName.count-2)];
                        return contact;
                    }
                }
                
                
            }
        }
        
        //flexible lastname
        matchesLastName = [self matchesLastName:lastname withContactPool:[self getAllContacts] searchSubstrings:YES];
        
        if (matchesLastName.count>0)
        {
            NSLog(@"flexible lastname found");
            if (!firstname)
            {     
                Contact* contact = [matchesLastName objectAtIndex:0];
                contact.matchConfidence = [NSNumber numberWithDouble: .9 /exp(matchesLastName.count-1)];
                return contact;                
            }
            else
            {
                NSLog(@"lastname matched: %i. and a firstname was provided", matchesLastName.count);
                NSArray *matchesLastAndFirst = [self matchesFirstName:firstname withContactPool:matchesLastName searchSubstrings:NO];
                if (matchesLastAndFirst.count>0)
                {
                    Contact* contact = [matchesLastAndFirst objectAtIndex:0];
                    contact.matchConfidence = [NSNumber numberWithDouble: .99 /exp(matchesLastName.count-1)];
                    return contact;
                }
                else
                {
                    matchesLastAndFirst = [self matchesFirstName:firstname withContactPool:matchesLastName searchSubstrings:YES];
                    if (matchesLastAndFirst.count>0)
                    {
                        Contact* contact = [matchesLastAndFirst objectAtIndex:0];
                        contact.matchConfidence = [NSNumber numberWithDouble: .80 /exp(matchesLastName.count-1)];
                        return contact;
                    }
                }
                
                
            }
        }
        
        //lastname in firstname
        matchesLastName = [self matchesFirstName:lastname withContactPool:[self getAllContacts] searchSubstrings:NO];
        
        if (matchesLastName.count>0)
        {
            NSLog(@"lastname found in first");
            if (!firstname)
            {     
                Contact* contact = [matchesLastName objectAtIndex:0];
                contact.matchConfidence = [NSNumber numberWithDouble: .9 /exp(matchesLastName.count-1)];
                return contact;                
            }
            else
            {
                Contact* contact = [matchesLastName objectAtIndex:0];
                contact.matchConfidence = [NSNumber numberWithDouble: .70 /exp(matchesLastName.count-1)];
                return contact;
                
            }
        }
        
        //flexible lastname in firstname
        matchesLastName = [self matchesFirstName:lastname withContactPool:[self getAllContacts] searchSubstrings:YES];
        
        if (matchesLastName.count>0)
        {
            NSLog(@"lastname found in first");
            if (!firstname)
            {     
                Contact* contact = [matchesLastName objectAtIndex:0];
                contact.matchConfidence = [NSNumber numberWithDouble: .9 /exp(matchesLastName.count-1)];
                return contact;                
            }
            else
            {
                NSArray *matchesLastAndFirst = [self matchesFirstName:firstname withContactPool:matchesLastName searchSubstrings:YES];
                if (matchesLastAndFirst.count>0)
                {
                    Contact* contact = [matchesLastAndFirst objectAtIndex:0];
                    contact.matchConfidence = [NSNumber numberWithDouble: .85 /exp(matchesLastName.count-1)];
                    return contact;
                }
                else
                {
                    Contact* contact = [matchesLastName objectAtIndex:0];
                    contact.matchConfidence = [NSNumber numberWithDouble: .70 /exp(matchesLastName.count-1)];
                    return contact;
                }
                
                
            }
        }
        
        
        
    }
    
    
    NSLog(@"no match for:\nfirstname: %@\nlastname: %@", firstname, lastname);
    return nil;
}


-(BOOL)doBidirectionalSubstringMatch:(NSString*)one andTwo:(NSString*)two
{
    if (!one || !two)
        return NO;
    
    //Account for shortened/nicknames
    if (one.length < two.length)
    {
        if ([two rangeOfString:one].location ==  NSNotFound)
            return NO;
    }
    else if ([one rangeOfString:two].location == NSNotFound)
        return NO;
    return YES;
}

@end
