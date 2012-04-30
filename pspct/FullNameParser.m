//
//  EventParticipantMatcher.m
//  perspect calendar
//
//  Created by Robert Witoff on 4/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FullNameParser.h"
#import <EventKit/EventKit.h>
#import "AbContact.h"

@interface FullNameParser (hidden)

-(void)parse;

@end

@implementation FullNameParser

@synthesize _firstname, _lastname, contact, raw_name;

-(id)initWithName:(NSString*)_name
{
    self = [super init];
    if (self)
    {
        self.raw_name = _name;
        isParsed = FALSE;
    }
    return self;
}

-(NSString*)getFirstname
{
    [self parse];
    return self._firstname;
}
-(NSString*)getLastname
{
    [self parse];
    return self._lastname;    
}

-(void)parse
{
    if (isParsed)
        return;
    
    isParsed = YES;
    
    NSMutableString *name = [[NSMutableString alloc] initWithString:self.raw_name];
    NSLog(@"name: %@", name);
    
    //Remove any notes referenced in the attendee name like "Rob (mystical unicorn)"
    NSError *error = nil;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"\\(.*\\)" options:0 error:&error];
    
    [regex replaceMatchesInString:name options:0 range:NSMakeRange(0, name.length) withTemplate:@""];
    NSLog(@"name: %@", name);
    
    //Remove any hyphenated prefix on the name like "FRIEND-Bob Sagget"
    error = nil;
    regex = [[NSRegularExpression alloc] initWithPattern:@"[A-Z][A-Z]*\\-" options:0 error:&error];
    
    [regex replaceMatchesInString:name options:0 range:NSMakeRange(0, name.length) withTemplate:@""];
    NSLog(@"name: %@", name);    
    
    //Split into first and lastname
    NSArray* components = [name componentsSeparatedByString:@","];
    if (components.count!=2)
    {
        NSLog(@"components !=1, skipping");
        return;
    }
    
    //Strip whitespace and assign
    self._firstname = [[components objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self._lastname = [[components objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    //Strip a trailing middle initial
    error = nil;
    regex = [[NSRegularExpression alloc] initWithPattern:@"\\s.*" options:0 error:&error];
    self._firstname = [regex stringByReplacingMatchesInString:self._firstname options:0 range:NSMakeRange(0, self._firstname.length) withTemplate:@""];
    
    NSLog(@"firstname: %@", self._firstname);
    NSLog(@"lastname: %@", self._lastname);
}


@end
