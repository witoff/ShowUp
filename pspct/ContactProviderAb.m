//
//  ScanAddressBook.m
//  pspct
//
//  Created by Robert Witoff on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import "AbContact.h"
#import <Accelerate/Accelerate.h>
#import "JSON.h"
#import "ContactProviderAb.h"

@implementation ContactProviderAb

static NSArray* allcontacts;

- (NSArray*) getAllContacts
{
    if (allcontacts)
        return allcontacts;
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    
    NSMutableArray *contactArray = [[NSMutableArray alloc] initWithCapacity:100];
    for( int i = 0 ; i < nPeople ; i++ )
    {
        
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i );
        AbContact *contact = [AbContact contactWithRecordRef:ref];
        [contactArray addObject:contact];
    }
    
    CFRelease(addressBook);
    CFRelease(allPeople);
    allcontacts = contactArray;
    return allcontacts;
}

+(void)invalidateContactList
{    
    allcontacts = nil;
}

+ (NSArray*)allcontacts {
    return allcontacts;
}

+ (void)setAllcontacts:(NSArray *)newContacts
{
    if (allcontacts != newContacts) {
        allcontacts = newContacts;
    }
}


@end