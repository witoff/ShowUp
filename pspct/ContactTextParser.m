//
//  ContactTextParser.m
//  perspect calendar
//
//  Created by Robert Witoff on 4/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ContactTextParser.h"

#import "FullNameParser.h"
#import <EventKit/EventKit.h>
#import "AbContact.h"
#import "ContactSearcher.h"
#import "ContactProviderAb.h"
#import "JSON.h"

@interface ContactTextParser (hidden)

-(void)indexContacts;
-(void)insertString:(NSString*)string forContact:(AbContact*)contact;

@end

@implementation ContactTextParser

@synthesize _contacts, raw_text;

-(id)initWithText:(NSString *)text
{
    return [self initWithText:text andContactProvider:[ContactProvider defaultProvider]];
}

-(id)initWithText:(NSString*)text andContactProvider:(ContactProvider *)provider
{
    self = [super init];
    if (self)
    {
        self.raw_text = text;
        isParsed = NO;
    }
    return self;
    
}

-(NSArray*)getContacts
{
    if (self._contacts)
        return self._contacts;
    [self indexContacts];
    
    self._contacts = [[NSMutableArray alloc] initWithCapacity:3];
    
    //Try to match every word in the title
    NSArray* components = [self.raw_text componentsSeparatedByString:@" "];
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"\\'s" options:0 error:nil];
    
    if ([self.raw_text containsString:@"Dinner with Armin"])
        NSLog(@"Dinner with Armin");
    
    for (NSString* str in components) {
        
        //remove " 's and strip"
        NSString *trimmed = [regex stringByReplacingMatchesInString:str options:0 range:NSMakeRange(0, str.length) withTemplate:@""];
        trimmed = [trimmed.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];;
        
        NSArray* matches = [_contact_index objectForKey:trimmed];
        
        if (matches && matches.count==1)
        {
            [self._contacts addObject:[matches objectAtIndex:0]];
            continue;
        }
    }
    
    return self._contacts;
}

-(void)insertString:(NSString*)string forContact:(AbContact*)contact
{
    if(!string)
        return;
    string = string.lowercaseString;
    NSMutableArray* match = [_contact_index objectForKey: string];
    if (!match)
    {
        match = [[NSMutableArray alloc] initWithCapacity:5];
        [_contact_index setObject:match forKey:string];
    }
    
    for (AbContact* c in match) {
        if ([[c getLinkedContactKeys] containsObject:contact.key])
            return;
    }
    [match addObject:contact];
}

static NSMutableDictionary* _contact_index;

-(void)indexContacts
{
    if (_contact_index)
        return;
    
    isParsed = YES;
    
    //bin all contact names
    ContactProvider* provider = [ContactProvider defaultProvider];
    NSArray* contacts = [provider getAllContacts];
    _contact_index = [[NSMutableDictionary alloc] initWithCapacity:contacts.count*2];
    
    for (AbContact *c in contacts) {
        [self insertString:c.firstname forContact:c];
        [self insertString:c.lastname forContact:c];
    }
}


@end
