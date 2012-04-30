//
//  LocalScanner.m
//  perspect calendar
//
//  Created by Robert Witoff on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ContactProviderLocal.h"
#import "JSON.h"
#import "AbContact.h"

@implementation ContactProviderLocal

static NSArray* allcontacts;

- (NSArray*) getAllContacts
{
    if (allcontacts)
        return allcontacts;
    
    //Load from disk
    NSString *path = [[NSBundle mainBundle] pathForResource:@"allcontacts" ofType:@"json"];  
    NSString *raw = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray *data = [raw JSONValue];

    NSMutableArray *contactArray = [[NSMutableArray alloc] initWithCapacity:data.count];

    for (NSDictionary *entry in data) {
        
        AbContact *contact = [[AbContact alloc] init];
        contact.firstname = [entry valueForKey:@"f"];
        contact.lastname = [entry valueForKey:@"l"];
        contact.key = [entry valueForKey:@"key"];
        contact.linked_keys = [entry valueForKey:@"linked_ids"];
        [contactArray addObject:contact];
    }
    
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
