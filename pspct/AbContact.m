//
//  Contact.m
//  pspct
//
//  Created by Robert Witoff on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AbContact.h"
#import <AddressBook/AddressBook.h>

@implementation AbContact

@synthesize key, lastname, firstname, image, numbers, email, matchConfidence, linked_keys;

#pragma mark - init
-(id)init
{
    self = [super init];
    if (self)
    {
        self.numbers= [[NSMutableArray alloc] initWithCapacity:5];
    }
    return self;
}

#pragma mark - class getters

+(AbContact*)contactWithAbContactKey:(NSNumber*)key
{        
    ABAddressBookRef addressBook = ABAddressBookCreate();
    ABRecordID recordId = [key integerValue];
    
    ABRecordRef ref = ABAddressBookGetPersonWithRecordID(addressBook, recordId);
    AbContact *contact = [AbContact contactWithRecordRef:ref];
    CFRelease(addressBook);
    //CFRelease(ref);    
    
    return contact;
}

+ (AbContact*)contactWithRecordRef:(ABRecordRef)ref
{
    AbContact *contact = [[AbContact alloc] init];
    
    //id
    ABRecordID record_id = ABRecordGetRecordID(ref);
    NSNumber *identifier = [NSNumber numberWithInt:record_id];
    contact.key = identifier;
    
    //firstname
    CFTypeRef firstname = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
    if(firstname != nil)
    {
        contact.firstname = [NSString stringWithFormat:@"%@",firstname];
        CFRelease(firstname);
    }
    
    //lastname
    CFTypeRef lastname = ABRecordCopyValue(ref, kABPersonLastNameProperty);
    if(lastname != nil)
    {
        contact.lastname = [NSString stringWithFormat:@"%@",lastname];
        CFRelease(lastname);
    }
    
    //image
    NSData *imgData = (__bridge_transfer NSData *) ABPersonCopyImageData(ref);
    contact.image = [UIImage imageWithData:imgData];
    
    //Misc Phone numbers
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
    CFRelease(phoneNumbers);
    
    //email
    CFTypeRef multival = ABRecordCopyValue(ref, kABPersonEmailProperty);
    NSArray *arrayEmail = (__bridge_transfer NSArray *)ABMultiValueCopyArrayOfAllValues(multival);
    contact.email = [arrayEmail objectAtIndex:0];
    
    CFRelease(multival);
    
    return contact;
    
}

#pragma mark - helpers

/** Many contacts on your phone are identical across multiple address books and are therefore 'linked' by iOS.  
 
 This returns all contact IDs (includeing this AbContact) that are linked.
 
 **/


-(NSArray*)getLinkedContactKeys
{
    if (self.linked_keys)
        return self.linked_keys;
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    ABRecordID recordId = [self.key integerValue];
    ABRecordRef ref = ABAddressBookGetPersonWithRecordID(addressBook, recordId);
    
    CFArrayRef cfContacts = ABPersonCopyArrayOfAllLinkedPeople(ref);
    
    NSArray *linkedContacts = [NSArray arrayWithArray:(__bridge NSArray*) cfContacts];
    
    NSMutableArray *linkedIds = [[NSMutableArray alloc] initWithCapacity:linkedContacts.count+1];
    
    for (id linkedRef in linkedContacts) {
        ABRecordID record_id = ABRecordGetRecordID((__bridge ABRecordRef)linkedRef);
        NSNumber *identifier = [NSNumber numberWithInt:record_id];
        [linkedIds addObject:identifier];
    }
    
    CFRelease(addressBook);    
    CFRelease(cfContacts);
    
    if (!linkedIds)
        self.linked_keys = [[NSArray alloc] init];
    else 
        self.linked_keys = linkedIds;
    
    return self.linked_keys;
}

-(NSString*)getBestNumber
{
    NSLog(@"getBestNumber for: %@, length: %i", self.firstname, self.numbers.count);
    
    if (self.numbers == nil)
        return nil;
    if (self.numbers.count==0)
        return nil;
    
    NSString *bestNumber = nil;
    NSString *bestLabel = nil;
    for (NSDictionary *numberPair in self.numbers) {
        NSString *label = [[numberPair objectForKey:@"label"] lowercaseString];
        NSString *number = [numberPair objectForKey:@"number"] ; 
        
        //favor iphone
        if ([label isEqualToString:@"iphone"])
        {
            bestLabel = label;
            bestNumber = number;
            break;
        }
        
        if ([label isEqualToString:@"mobile"])
        {
            bestLabel = label;
            bestNumber = number;
        }
        else if ([label isEqualToString:@"home"] && ![bestLabel isEqualToString:@"mobile"])
        {
            bestLabel = label;
            bestNumber = number;
        }
        else if (!bestLabel)
        {
            bestLabel = label;
            bestNumber = number;
        }
        
    }
    NSLog(@"best number: %@ for label: %@", bestNumber, bestLabel);
    
    return bestNumber;
    
}

-(NSString*)getFullname
{
    if (firstname && lastname)
        return [NSString stringWithFormat:@"%@ %@", firstname, lastname];
    return @"";
}

@end
