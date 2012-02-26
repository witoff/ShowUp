//
//  ScanAddressBook.m
//  pspct
//
//  Created by Robert Witoff on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AbScanner.h"
#import <AddressBook/AddressBook.h>
#import "AbContact.h"
#import <Accelerate/Accelerate.h>


@interface AbScanner (hidden)

- (NSArray*) getAllContacts;

- (BOOL)doBidirectionalSubstringMatch:(NSString*)one andTwo:(NSString*)two;

- (NSArray*)matchesFirstName:(NSString*)searchString withContacts:(NSArray*)contacts doSubstrings:(BOOL)doSubstrings;
- (NSArray*)matchesLastName:(NSString*)searchString withContacts:(NSArray*)contacts doSubstrings:(BOOL)doSubstrings;

- (void) testSearch;

+ (NSArray*)allcontacts;
+ (void)setAllcontacts:(NSArray*)newContacts;

@end

static NSArray* allcontacts;


@implementation AbScanner

@synthesize fbContact;

#pragma mark - init

- (id)initWithFbContact:(FbContact*)contact
{
    self = [super init];
    if (self)
    {
        self.fbContact = contact;
    }
    return self;
}

#pragma mark - class methods

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
    
    NSMutableArray *contactArray = [[NSMutableArray alloc] initWithCapacity:100];
    for( int i = 0 ; i < nPeople ; i++ )
    {
        
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i );
        AbContact *contact = [AbContact contactWithRecordRef:ref];
        CFRelease(ref);
        
        [contactArray addObject:contact];
    }
    
    CFRelease(addressBook);
    //CFRelease(allPeople);
    allcontacts = contactArray;
    return allcontacts;
}



#pragma mark - searching

- (AbContact*)simpleSearch
{
    NSString* fbFirstname = [fbContact.firstname lowercaseString];
    NSString* fbLastname = [fbContact.lastname lowercaseString];
    
    NSLog(@"simpleSearch");
    fbFirstname = [fbFirstname lowercaseString];
    fbLastname = [fbLastname lowercaseString];
    
    NSLog(@"searching for last name: '%@'", fbLastname);
    
    for (AbContact *abContact in [self getAllContacts]) {
        NSString* abFirstname = [abContact.firstname lowercaseString];
        NSString* abLastname = [abContact.lastname lowercaseString];
        
        if (fbLastname && fbLastname.length>0)
        {
            
            if ([abLastname isEqualToString:fbLastname])
            {
                NSLog(@"last names are equal");
                if (!fbFirstname)
                    return abContact;
                if ([self doBidirectionalSubstringMatch:fbFirstname andTwo:abFirstname])
                    return abContact;
                if (abLastname.length==0 && [self doBidirectionalSubstringMatch:fbFirstname andTwo:abFirstname])
                    return abContact;
                NSLog(@"no last name match");
            }
            else if (abLastname.length==0 && [self doBidirectionalSubstringMatch:abFirstname andTwo:fbLastname])
                return abContact;
            
        }
        else if ([self doBidirectionalSubstringMatch:fbFirstname andTwo:abFirstname])
            return abContact;
        //Conditional needed to see if it's a common first name
        if (abLastname.length==0 && [self doBidirectionalSubstringMatch:fbFirstname andTwo:abFirstname])
            return abContact;
        
        //
        
    }
    NSLog(@"no match for:\nfirstname: %@\nlastname: %@", fbFirstname, fbLastname);
    return nil;
}

- (NSArray*)matchesLastName:(NSString*)searchString withContacts:(NSArray*)contacts doSubstrings:(BOOL)doSubstrings
{
    NSMutableArray *matches = [[NSMutableArray alloc] initWithCapacity:5];
    
    for (AbContact *contact in contacts) {
        NSString* abSearchString = [contact.lastname lowercaseString];
        
        if (doSubstrings)
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
- (NSArray*)matchesFirstName:(NSString*)searchString withContacts:(NSArray*)contacts doSubstrings:(BOOL)doSubstrings
{
    NSMutableArray *matches = [[NSMutableArray alloc] initWithCapacity:5];
    
    for (AbContact *contact in contacts) {
        NSString* abSearchString = [contact.firstname lowercaseString];
        
        if (doSubstrings)
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


- (AbContact*)getMatchingAbContact
{
    NSString *fbFirstname = fbContact.firstname;
    NSString *fbLastname = fbContact.lastname;
    
    NSLog(@"simpleSearch");
    
    if (fbFirstname.length == 0)
        fbFirstname = nil;
    if (fbLastname.length == 0)
        fbLastname = nil;
    
    if (fbFirstname)
        fbFirstname = [fbFirstname lowercaseString];
    if (fbLastname)
        fbLastname = [fbLastname lowercaseString];
    
    NSLog(@"searching for last name: '%@'", fbLastname);
    
    
    
    //
    // LAST NAME MATCHING
    //
    if (fbLastname)
    {
        NSArray *matchesLastName = [self matchesLastName:fbLastname withContacts:[self getAllContacts] doSubstrings:NO];
        
        if (matchesLastName.count>0)
        {
            NSLog(@"lastname matched");
            if (!fbFirstname)
            {     
                AbContact* contact = [matchesLastName objectAtIndex:0];
                contact.matchConfidence = [NSNumber numberWithDouble: .9 /exp(matchesLastName.count-2)];
                return contact;                
            }
            else
            {
                NSLog(@"lastname matched: %i. and a firstname was provided", matchesLastName.count);
                NSArray *matchesLastAndFirst = [self matchesFirstName:fbFirstname withContacts:matchesLastName doSubstrings:NO];
                if (matchesLastAndFirst.count>0)
                {
                    AbContact* contact = [matchesLastAndFirst objectAtIndex:0];
                    contact.matchConfidence = [NSNumber numberWithDouble: .99 /exp(matchesLastName.count-2)];
                    return contact;
                }
                else
                {
                    matchesLastAndFirst = [self matchesFirstName:fbFirstname withContacts:matchesLastName doSubstrings:YES];
                    if (matchesLastAndFirst.count>0)
                    {
                        AbContact* contact = [matchesLastAndFirst objectAtIndex:0];
                        contact.matchConfidence = [NSNumber numberWithDouble: .80 /exp(matchesLastName.count-2)];
                        return contact;
                    }
                }
                
                
            }
        }
        
        //flexible lastname
        matchesLastName = [self matchesLastName:fbLastname withContacts:[self getAllContacts] doSubstrings:YES];
        
        if (matchesLastName.count>0)
        {
            NSLog(@"flexible lastname found");
            if (!fbFirstname)
            {     
                AbContact* contact = [matchesLastName objectAtIndex:0];
                contact.matchConfidence = [NSNumber numberWithDouble: .9 /exp(matchesLastName.count-1)];
                return contact;                
            }
            else
            {
                NSLog(@"lastname matched: %i. and a firstname was provided", matchesLastName.count);
                NSArray *matchesLastAndFirst = [self matchesFirstName:fbFirstname withContacts:matchesLastName doSubstrings:NO];
                if (matchesLastAndFirst.count>0)
                {
                    AbContact* contact = [matchesLastAndFirst objectAtIndex:0];
                    contact.matchConfidence = [NSNumber numberWithDouble: .99 /exp(matchesLastName.count-1)];
                    return contact;
                }
                else
                {
                    matchesLastAndFirst = [self matchesFirstName:fbFirstname withContacts:matchesLastName doSubstrings:YES];
                    if (matchesLastAndFirst.count>0)
                    {
                        AbContact* contact = [matchesLastAndFirst objectAtIndex:0];
                        contact.matchConfidence = [NSNumber numberWithDouble: .80 /exp(matchesLastName.count-1)];
                        return contact;
                    }
                }
                
                
            }
        }
        
        //lastname in firstname
        matchesLastName = [self matchesFirstName:fbLastname withContacts:[self getAllContacts] doSubstrings:NO];
        
        if (matchesLastName.count>0)
        {
            NSLog(@"lastname found in first");
            if (!fbFirstname)
            {     
                AbContact* contact = [matchesLastName objectAtIndex:0];
                contact.matchConfidence = [NSNumber numberWithDouble: .9 /exp(matchesLastName.count-1)];
                return contact;                
            }
            else
            {
                AbContact* contact = [matchesLastName objectAtIndex:0];
                contact.matchConfidence = [NSNumber numberWithDouble: .70 /exp(matchesLastName.count-1)];
                return contact;
                
            }
        }
        
        //flexible lastname in firstname
        matchesLastName = [self matchesFirstName:fbLastname withContacts:[self getAllContacts] doSubstrings:YES];
        
        if (matchesLastName.count>0)
        {
            NSLog(@"lastname found in first");
            if (!fbFirstname)
            {     
                AbContact* contact = [matchesLastName objectAtIndex:0];
                contact.matchConfidence = [NSNumber numberWithDouble: .9 /exp(matchesLastName.count-1)];
                return contact;                
            }
            else
            {
                NSArray *matchesLastAndFirst = [self matchesFirstName:fbFirstname withContacts:matchesLastName doSubstrings:YES];
                if (matchesLastAndFirst.count>0)
                {
                    AbContact* contact = [matchesLastAndFirst objectAtIndex:0];
                    contact.matchConfidence = [NSNumber numberWithDouble: .85 /exp(matchesLastName.count-1)];
                    return contact;
                }
                else
                {
                    AbContact* contact = [matchesLastName objectAtIndex:0];
                    contact.matchConfidence = [NSNumber numberWithDouble: .70 /exp(matchesLastName.count-1)];
                    return contact;
                }
                
                
            }
        }
        
        
        
    }
    
    //todo: look for only one of a kind (e.g. only one bogdan in the book
    else if (fbFirstname)
    {
        //only a firstname is defined
        
        //exact match
        NSArray *matchesFirstname = [self matchesFirstName:fbFirstname withContacts:[self getAllContacts] doSubstrings:NO];
        if (matchesFirstname.count>0)
        {
            NSLog(@"exact firstname substring match found");
            AbContact* contact = [matchesFirstname objectAtIndex:0];
            contact.matchConfidence = [NSNumber numberWithDouble: .80 /exp(matchesFirstname.count-1)];
            return contact;
        }
        
        //non-exact match
        matchesFirstname = [self matchesFirstName:fbFirstname withContacts:[self getAllContacts] doSubstrings:YES];
        if (matchesFirstname.count>0)
        {
            NSLog(@"non-exact firstname substring match found");
            AbContact* contact = [matchesFirstname objectAtIndex:0];
            contact.matchConfidence = [NSNumber numberWithDouble: .75 /exp(matchesFirstname.count-1)];
            return contact;
        }
        
    }
    
    //exact match
    NSArray *matchesFirstname = [self matchesFirstName:fbFirstname withContacts:[self getAllContacts] doSubstrings:NO];
    NSLog(@"fbfirst: %@, count: %i", fbFirstname, matchesFirstname.count);
    if (matchesFirstname.count==1)
    {
        NSLog(@"exact firstname substring match found");
        AbContact* contact = [matchesFirstname objectAtIndex:0];
        contact.matchConfidence = [NSNumber numberWithDouble: .80 /exp(matchesFirstname.count-1)];
        return contact;
    }
    
    //non-exact match
    matchesFirstname = [self matchesFirstName:fbFirstname withContacts:[self getAllContacts] doSubstrings:YES];
    NSLog(@"count: %i", matchesFirstname.count);
    if (matchesFirstname.count==1)
    {
        NSLog(@"non-exact firstname substring match found");
        AbContact* contact = [matchesFirstname objectAtIndex:0];
        contact.matchConfidence = [NSNumber numberWithDouble: .75 /exp(matchesFirstname.count-1)];
        return contact;
    }
    
    
    //todo: lastname and 2 characters of first
    
    NSLog(@"no match for:\nfirstname: %@\nlastname: %@", fbFirstname, fbLastname);
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
