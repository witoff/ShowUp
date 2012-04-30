//
//  pspctTests.m
//  pspctTests
//
//  Created by Robert Witoff on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "pspctTests.h"
#import "EventAccessor.h"
#import "ContactProviderLocal.h"
#import <EventKit/EventKit.h>
#import "FullNameParser.h"
#import "JSON.h"
#import "ContactTextParser.h"
#import "ContactSearcher.h"

@interface pspctTests (hidden)

-(NSArray*)getUniqueEventAttendees;
-(NSArray*)getUniqueEventTitles;

@end

@implementation pspctTests

- (void)setUp
{
    [super setUp];
    [ContactProvider setDefaultProvider:[[ContactProviderLocal alloc] init]];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testExample
{
    //STFail(@"Unit tests are not implemented yet in pspctTests");    
}

-(NSArray*)getUniqueEventAttendees
{
    //Load from disk
    NSString *path = [[NSBundle mainBundle] pathForResource:@"unique_event_attendees.keyed" ofType:@"json"];  
    
    NSLog(@"loading: %@", path);
    NSString *raw = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    NSArray *data = [raw JSONValue];
    NSLog(@"loaded: %@", path);
    
    return data;
}

- (void)dtestMatchEventAttendees
{
    NSArray* attendees = [self getUniqueEventAttendees];
    //Like: [{'name': 'bob jobs', 'truth': 123}...]
    
    NSMutableArray *logSuccess = [[NSMutableArray alloc] initWithCapacity:attendees.count*3];
    NSMutableArray *logFailure = [[NSMutableArray alloc] initWithCapacity:attendees.count*3];
    
    for (NSDictionary* attendee in attendees) {
        //Remove (.*)
        FullNameParser* parser = [[FullNameParser alloc] initWithName:[attendee objectForKey:@"name"]];
        
        //TODO: breakup first and last name
        NSString *aFirstname = [parser getFirstname];
        NSString *aLastname = [parser getLastname];
        NSNumber *truth = [attendee objectForKey:@"truth"];
        if ([truth isEqual:[NSNull null]])
            truth = nil;
        
        //Search for contact in address book
        
        
        ContactSearcher *searcher = [[ContactSearcher alloc] initWithContactProvider:[ContactProvider defaultProvider] andFirstname:aFirstname andLastname:aLastname];
        AbContact* contact = [searcher getMatchingAbContact];
        
        if (!contact && !truth)
        {
            [logSuccess addObject:[NSString stringWithFormat: @"Matched attendee name: %@ to null", aFirstname]];
            continue;
        }
        else if (contact && truth)
        {
            NSLog(@"searchind for f: %@, l: %@, key: %@", contact.firstname, contact.lastname, contact.key);
            NSArray* ids = [contact getLinkedContactKeys];
            if ([ids containsObject:truth])
            {
                [logSuccess addObject:[NSString stringWithFormat: @"Matched attendee name: %@ to contact f: %@ l: %@", aFirstname, contact.firstname, contact.lastname]];
                continue;
            }
        }
        if (!truth && contact)
            [logFailure addObject:[NSString stringWithFormat:@"no match expected for f: %@, l: %@ but found f: %@, l: %@", aFirstname, aLastname, contact.firstname, contact.lastname]];
        else if (truth && !contact)
            [logFailure addObject:[NSString stringWithFormat:@"expecting match for f: %@, l: %@ but found nothing", aFirstname, aLastname]];
        else
            [logFailure addObject:[NSString stringWithFormat:@"invalid match for f: %@, l: %@ ..... found f: %@, l: %@", aFirstname, aLastname, contact.firstname, contact.lastname]];
    }
    
    for (NSString *s in logFailure) {
        NSLog(@"%@", s);
    }
    
    int n_success = logSuccess.count;
    int n_fail = logFailure.count;
    
    NSLog(@"success: %i", n_success);
    NSLog(@"fail: %i", n_fail);
    NSLog(@"total: %i", n_fail + n_success);
    NSLog(@"success percentage: %.2f%%", (100.0*n_success)/ (n_success + n_fail));
}

-(NSArray*)getUniqueEventTitles
{
    //Load from disk
    NSString *path = [[NSBundle mainBundle] pathForResource:@"eventtitles.keyed" ofType:@"json"];  
    
    NSLog(@"loading: %@", path);
    NSString *raw = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    NSArray *data = [raw JSONValue];
    NSLog(@"loaded: %@", path);
    
    return data;
}

- (void)testMatchEventTitles
{
    NSArray* titles = [self getUniqueEventTitles];
    
    NSMutableArray *logSuccess = [[NSMutableArray alloc] initWithCapacity:titles.count];
    NSMutableArray *logFail = [[NSMutableArray alloc] initWithCapacity:titles.count];
    
    for (NSDictionary *d in titles) {
        NSString *title = [d objectForKey:@"t"];
        NSArray *truth_attendees = [d objectForKey:@"a"];
        
        ContactTextParser *parser = [[ContactTextParser alloc] initWithText:title];
        NSArray* contacts = [parser getContacts];
        
        for (NSNumber *key in truth_attendees) {
            BOOL found = NO;
            for (AbContact *contact in contacts) {
                if ([contact.key isEqualToNumber:key]){
                    found = YES;
                    break;
                }
            }
            if (!found)
                [logFail addObject:[NSString stringWithFormat:@"key not found: %@", key]];
            else
                [logSuccess addObject:[NSString stringWithFormat:@"key found: %@", key]];
        }
        if (truth_attendees.count==0 && contacts.count==0)
            [logSuccess addObject:@"As expected, no objects were found"];
        else if (truth_attendees.count!=contacts.count)
            [logFail addObject:[NSString stringWithFormat: @"mismatched truth/found counts (%i/%i) for line: %@", truth_attendees.count, contacts.count, title]];
    }

    for (NSString *s in logFail) {
        NSLog(@"%@", s);
    }
    
    int n_success = logSuccess.count;
    int n_fail = logFail.count;
    
    NSLog(@"success: %i", n_success);
    NSLog(@"fail: %i", n_fail);
    NSLog(@"total: %i", n_fail + n_success);
    NSLog(@"success percentage: %.2f%%", (100.0*n_success)/ (n_success + n_fail));
    
}

@end
