//
//  ScanAddressBook.m
//  pspct
//
//  Created by Robert Witoff on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ScanAddressBook.h"
#import <AddressBook/AddressBook.h>

@implementation ScanAddressBook

@synthesize contacts;

- (void) search
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

- (NSArray*) getContacts
{
    if (self.contacts != nil)
        return self.contacts;
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    NSMutableDictionary *dicContact;
    CFTypeRef multival;
    NSMutableArray *contactArray = [[NSMutableArray alloc] initWithCapacity:100];
    for( int i = 0 ; i < nPeople ; i++ )
    {
        
        dicContact = [[NSMutableDictionary alloc] init];
        
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i );
        
        if(ABRecordCopyValue(ref, kABPersonFirstNameProperty) != nil || [[NSString stringWithFormat:@"%@",ABRecordCopyValue(ref, kABPersonFirstNameProperty)] length] == 0)
            [dicContact setValue:[NSString stringWithFormat:@"%@",ABRecordCopyValue(ref, kABPersonFirstNameProperty)] forKey:@"firstname"];
        else
            [dicContact setValue:@"" forKey:@"firstname"];
        
        if(ABRecordCopyValue(ref, kABPersonLastNameProperty) != nil || [[NSString stringWithFormat:@"%@",ABRecordCopyValue(ref, kABPersonLastNameProperty)] length] == 0)   
        {
            NSString *personLastName = [NSString stringWithFormat:@"%@",ABRecordCopyValue(ref, kABPersonLastNameProperty)];
            [dicContact setValue: personLastName forKey:@"lastname"];
        }
        else
            [dicContact setValue:@"" forKey:@"lastname"];
        
        if(ABRecordCopyValue(ref, kABPersonOrganizationProperty) != nil || [[NSString stringWithFormat:@"%@",ABRecordCopyValue(ref, kABPersonOrganizationProperty)] length] == 0)   
            [dicContact setValue:[NSString stringWithFormat:@"%@",ABRecordCopyValue(ref, kABPersonOrganizationProperty)] forKey:@"name"];
        else
            [dicContact setValue:[NSString stringWithFormat:@"%@ %@",[dicContact valueForKey:@"firstname"],[dicContact valueForKey:@"lastname"]] forKey:@"name"];
        
        NSData *data1 = (__bridge_transfer NSData *) ABPersonCopyImageData(ref);
        
        if(data1 == nil)
            [dicContact setObject:@"" forKey:@"image"];
        else
            [dicContact setObject:data1 forKey:@"image"];
        
        multival = ABRecordCopyValue(ref, kABPersonAddressProperty);
        NSArray *arrayAddress = (__bridge_transfer NSArray *)ABMultiValueCopyArrayOfAllValues(multival);
        if([arrayAddress count] > 0)
        {
            if([[arrayAddress objectAtIndex:0] valueForKey:@"City"] != nil)
                [dicContact setValue:[[arrayAddress objectAtIndex:0] valueForKey:@"City"] forKey:@"city"];
            else
                [dicContact setValue:@"" forKey:@"city"];
            
            if([[arrayAddress objectAtIndex:0] valueForKey:@"State"] != nil)
                [dicContact setValue:[[arrayAddress objectAtIndex:0] valueForKey:@"State"] forKey:@"state"];
            
            else
                [dicContact setValue:@"" forKey:@"state"];
            
            if([[arrayAddress objectAtIndex:0] valueForKey:@"Street"] != nil)
                [dicContact setValue:[[arrayAddress objectAtIndex:0] valueForKey:@"Street"] forKey:@"address1"];
            else
                [dicContact setValue:@"" forKey:@"address1"];
            
            if([[arrayAddress objectAtIndex:0] valueForKey:@"ZIP"] != nil)
                [dicContact setValue:[[arrayAddress objectAtIndex:0] valueForKey:@"ZIP"] forKey:@"postcode"];
            else
                [dicContact setValue:@"" forKey:@"postcode"];
         }
        else
        {
            [dicContact setValue:@"" forKey:@"city"];
            [dicContact setValue:@"" forKey:@"address1"];
            [dicContact setValue:@"" forKey:@"state"];
            [dicContact setValue:@"" forKey:@"postcode"];
        }
        
        multival = ABRecordCopyValue(ref, kABPersonPhoneProperty);
        NSArray *arrayPhone = (__bridge_transfer NSArray *)ABMultiValueCopyArrayOfAllValues(multival);
        if([arrayPhone count] > 0)
            [dicContact setValue:[arrayPhone objectAtIndex:0] forKey:@"telephone"];
        else
            [dicContact setValue:@"" forKey:@"telephone"];
        
        multival = ABRecordCopyValue(ref, kABPersonEmailProperty);
        NSArray *arrayEmail = (__bridge_transfer NSArray *)ABMultiValueCopyArrayOfAllValues(multival);
        if([arrayEmail count])
            [dicContact setValue:[arrayEmail objectAtIndex:0] forKey:@"email"];
        else
            [dicContact setValue:@"" forKey:@"email"];
        
        multival = ABRecordCopyValue(ref, kABPersonURLProperty);
        NSArray *arrayURL = (__bridge_transfer NSArray *)ABMultiValueCopyArrayOfAllValues(multival);
        if([arrayURL count])
            [dicContact setValue:[arrayURL objectAtIndex:0] forKey:@"website"];
        else
            [dicContact setValue:@"" forKey:@"website"];
        
        [dicContact setValue:@"" forKey:@"address2"];
        [dicContact setValue:@"" forKey:@"mobile"];
        [dicContact setValue:@"" forKey:@"fax"];
        [dicContact setValue:@"1.000000,1.000000,0.000000,0.000000" forKey:@"color"];
        
        [contactArray addObject:dicContact];
        //[dicContact release];
    }
    
    CFRelease(addressBook);
    CFRelease(allPeople);
    self.contacts = contactArray;
    return self.contacts;
}

- (NSString*) simpleSearch:(NSString*)firstname andLastName:(NSString*)lastname;
{
    //TODO: Replace this with a smart dynamic programming best fit model
    if (firstname)
        firstname = [firstname lowercaseString];
    if (lastname)
        lastname = [lastname lowercaseString];
    
    for (NSDictionary *person in [self getContacts]) {
        NSString* personFirstname = [[person objectForKey:@"firstname"] lowercaseString];
        NSString* personLastname = [[person objectForKey:@"lastname"] lowercaseString];

        if (lastname && lastname.length>0 && personLastname.length>0)
        {
            if ([lastname isEqualToString:personLastname])
            {
                if (!firstname)
                    return [person objectForKey:@"telephone"];
                if ([self doBidirectionalSubstringMatch:firstname andTwo:personFirstname])
                    return [person objectForKey:@"telephone"];
            }
        }
        else if ([self doBidirectionalSubstringMatch:firstname andTwo:personFirstname])
            return [person objectForKey:@"telephone"];                    
            
    }
    NSLog(@"no match for:\nfirstname: %@\nlastname: %@", firstname, lastname);
    return nil;
}

-(BOOL)doBidirectionalSubstringMatch:(NSString*)one andTwo:(NSString*)two
{
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
