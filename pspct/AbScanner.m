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
- (BOOL)areAllContactsLinked:(NSArray*)contacts;

- (NSArray*)matchesFirstName:(NSString*)searchString withContacts:(NSArray*)contacts doSubstrings:(BOOL)doSubstrings;
- (NSArray*)matchesLastName:(NSString*)searchString withContacts:(NSArray*)contacts doSubstrings:(BOOL)doSubstrings;

- (void) testSearch;

+ (NSArray*)allcontacts;
+ (void)setAllcontacts:(NSArray*)newContacts;

@end

static NSArray* allcontacts;


@implementation AbScanner

@synthesize fbUser;

#pragma mark - init

- (id)initWithFbUser:(ModelFbUser*)user
{
    self = [super init];
    if (self)
    {
        self.fbUser = user;
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
        CFRelease(lastName);
        
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
        CFRelease(phoneNumbers);
        CFRelease(person);
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
        //CFRelease(ref);
        
        [contactArray addObject:contact];
    }
    
    CFRelease(addressBook);
    CFRelease(allPeople);
    allcontacts = contactArray;
    return allcontacts;
}



#pragma mark - searching

- (AbContact*)simpleSearch
{
    NSString* fbFirstname = [self.fbUser.firstname lowercaseString];
    NSString* fbLastname = [self.fbUser.lastname lowercaseString];
    
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
    NSString *fbFirstname = self.fbUser.firstname;
    NSString *fbLastname = self.fbUser.lastname;
    
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
    
    if (fbLastname)
    {
        NSArray *lnMatches = [self matchesLastName:fbLastname withContacts:[self getAllContacts] doSubstrings:NO];
        
        //1. Exact Matches
        // Matches "Chris Shaffer" to "Chris Shaffer"
        NSArray *lnAndFnMatches = [self matchesFirstName:fbFirstname withContacts:lnMatches doSubstrings:NO];
        
        if (lnAndFnMatches.count>0)
        {
            AbContact* contact = [lnAndFnMatches objectAtIndex:0];
            contact.matchConfidence = [NSNumber numberWithDouble: .95 /exp(lnAndFnMatches.count-1)];
            return contact;                
        }
        
        //2. FB.ln = Abk.Fn, Abk has no last name
        // Matches "Daniel Zayas" to "Zayas"
        NSArray *lnMatchesFn = [self matchesFirstName:fbLastname withContacts:[self getAllContacts] doSubstrings:NO];
        NSMutableArray *hasNoLastName = [[NSMutableArray alloc] initWithCapacity:5];
        for (AbContact *contact in lnMatchesFn) {
            if (contact.lastname || contact.lastname.length>0)
            {
                [hasNoLastName addObject:contact];
            }
        }
        if (hasNoLastName.count>0)
        {
            AbContact* contact = [hasNoLastName objectAtIndex:0];
            contact.matchConfidence = [NSNumber numberWithDouble: .85 /exp(hasNoLastName.count-1)];
            return contact;                
        }
        
        //3. FB.ln = Abk.ln, Abk.Fn[0,2]==FB.fn[0,2]
        // Matches FB"Daniel Zayas" to Abk"Dan Zayas"
        if (fbFirstname.length>1)
        {
            NSString* fbFnShort = [fbFirstname substringToIndex:2];
            
            NSMutableArray *fnStartMatch = [[NSMutableArray alloc] initWithCapacity:5];
            for (AbContact *contact in lnMatches) {
                if (contact.firstname.length<2)
                    continue;
                NSString* abkFnShort= [[contact.firstname substringToIndex:2] lowercaseString];
                if ([fbFnShort isEqualToString:abkFnShort])
                    [fnStartMatch addObject:contact];
                
            }
            if (fnStartMatch.count>0)
            {
                AbContact* contact = [fnStartMatch objectAtIndex:0];
                contact.matchConfidence = [NSNumber numberWithDouble: .80 /exp(hasNoLastName.count-1)];
                return contact;                
            }
        }
        
        
        //4. FB.ln is in Abk.Fn, Abk has no last name
        // Matches Fb"Kevin Greene" to Abk"The Greene Machine"
        if (fbLastname.length>4)
        {
            lnMatchesFn = [self matchesFirstName:fbLastname withContacts:[self getAllContacts] doSubstrings:YES];
            hasNoLastName = [[NSMutableArray alloc] initWithCapacity:5];
            for (AbContact *contact in lnMatchesFn) {
                if (contact.lastname || contact.lastname.length>0)
                    continue;
                if (contact.firstname.length>4)
                    [hasNoLastName addObject:contact];
                
            }
            if (hasNoLastName.count>0)
            {
                AbContact* contact = [hasNoLastName objectAtIndex:0];
                contact.matchConfidence = [NSNumber numberWithDouble: .85 /exp(hasNoLastName.count-1)];
                return contact;                
            }
        }
    }
    else if (fbFirstname)
    {
        //only a firstname is defined
        
        //matches Fb."Mom", "" to "Mom"
        NSArray *matchesFirstname = [self matchesFirstName:fbFirstname withContacts:[self getAllContacts] doSubstrings:NO];
        if (matchesFirstname.count>0)
        {
            NSLog(@"exact firstname substring match found");
            AbContact* contact = [matchesFirstname objectAtIndex:0];
            contact.matchConfidence = [NSNumber numberWithDouble: .75 /exp(matchesFirstname.count-1)];
            return contact;
        }
        
        //non-exact match
        // matches Fb."Brother" "" to "Brother Ben"
        matchesFirstname = [self matchesFirstName:fbFirstname withContacts:[self getAllContacts] doSubstrings:YES];
        if (matchesFirstname.count>0)
        {
            NSLog(@"non-exact firstname substring match found");
            AbContact* contact = [matchesFirstname objectAtIndex:0];
            contact.matchConfidence = [NSNumber numberWithDouble: .65 /exp(matchesFirstname.count-1)];
            return contact;
        }
        
    }
    
    //exact match
    NSArray *matchesFirstname = [self matchesFirstName:fbFirstname withContacts:[self getAllContacts] doSubstrings:NO];
    
    NSLog(@"fbfirst: %@, count: %i", fbFirstname, matchesFirstname.count);
    // Matches "Ellen Witoff" to "Ellen" if there is only one Abk named Ellen
    
    if ([self areAllContactsLinked:matchesFirstname])
        matchesFirstname = [NSArray arrayWithObject:[matchesFirstname objectAtIndex:0]];
    
    if (matchesFirstname.count==1)
    {
        NSLog(@"exact firstname substring match found");
        AbContact* contact = [matchesFirstname objectAtIndex:0];
        contact.matchConfidence = [NSNumber numberWithDouble: .80 /exp(matchesFirstname.count-1)];
        if (contact.lastname && fbLastname)
        {
            if ([self doBidirectionalSubstringMatch:contact.lastname andTwo:fbLastname])
                return contact;
        }   
        else
            return contact;
    }
    else if (matchesFirstname==0)
    {
        if (fbLastname.length>3)
        {
            // Matches "Maryam Goober" to "Maryam the Conquerer" if there is only one Abk named Maryam
            matchesFirstname = [self matchesFirstName:fbFirstname withContacts:[self getAllContacts] doSubstrings:YES];
            
            if ([self areAllContactsLinked:matchesFirstname])
                matchesFirstname = [NSArray arrayWithObject:[matchesFirstname objectAtIndex:0]];
            
            NSLog(@"count: %i", matchesFirstname.count);
            if (matchesFirstname.count==1)
            {
                NSLog(@"non-exact firstname substring match found");
                AbContact* contact = [matchesFirstname objectAtIndex:0];
                contact.matchConfidence = [NSNumber numberWithDouble: .75 /exp(matchesFirstname.count-1)];
                if (contact.firstname.length>3)
                {
                    if (contact.lastname && fbLastname)
                    {
                        if ([self doBidirectionalSubstringMatch:contact.lastname andTwo:fbLastname])
                            return contact;
                    }   
                    else
                        return contact;
                }
            }
        }
    }
    
    NSLog(@"no match for:\nfirstname: %@\nlastname: %@", fbFirstname, fbLastname);
    return nil;
}


-(BOOL)areAllContactsLinked:(NSArray*)contacts
{
    if (!contacts || contacts.count==0)
        return NO;
    
    // are all matches the same person, just linked?
    for (int i=1; i<contacts.count; i++) {
        AbContact *lastC = [contacts objectAtIndex:i-1];
        AbContact *c = [contacts objectAtIndex:i];
        if (lastC.firstname || c.firstname)
        {
            if(![[lastC.firstname lowercaseString] isEqualToString:[c.firstname lowercaseString]])
                return NO;
        }
        if (lastC.lastname || c.lastname)
        {
            if(![[lastC.lastname lowercaseString] isEqualToString:[c.lastname lowercaseString]])
                return NO;
        }
        
        if(lastC.numbers && lastC.numbers>0 && c.numbers && c.numbers>0)
        {
            if (![[[lastC.numbers objectAtIndex:0] valueForKey:@"number"] isEqualToString:[[c.numbers objectAtIndex:0] valueForKey:@"number"]])
                return NO;
        }
    }
    return YES;
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
