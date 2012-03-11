//
//  FbContact.m
//  pspct
//
//  Created by Robert Witoff on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FbContact.h"
#import "AbContact.h"
#import "AbScanner.h"

@interface FbContact (hidden)

-(void)parseName;

@end

@implementation FbContact

@synthesize key, name, hasSearchedForAbMatch, abContactMatch, abContactMatchKey;


/*
 The child addressbook contact with the highest confidence
 */

-(AbContact*)getBestAbContact
{
    if (self.abContactMatch)
        return self.abContactMatch;
    
    if (self.abContactMatchKey && !self.hasSearchedForAbMatch)
        return [AbContact contactWithAbContactKey:self.abContactMatchKey];
    
    if (!self.abContactMatchKey && (!hasSearchedForAbMatch || !hasSearchedForAbMatch.boolValue))
    {
        /*
        AbScanner *scanner = [[AbScanner alloc] initWithFbContact:self];
        AbContact *match = [scanner getMatchingAbContact];
        self.hasSearchedForAbMatch = [NSNumber numberWithBool:YES];
        
        self.abContactMatch = match;
        self.abContactMatchKey = match.key;
        
        return match;
         */
    }
    return nil;
    
    /*
     if (!self.abContactMatches || self.abContactMatches.count==0)
     return nil;
     
     AbContact *bestMatch = nil;
     
     for (AbContact* match in self.abContactMatches) {
     if (!bestMatch)
     bestMatch = match;
     else if (match.matchConfidence > bestMatch.matchConfidence)
     bestMatch = match;
     }
     
     return bestMatch;
     */
}


-(NSString*)firstname
{
    if (!_firstname)
        [self parseName];
    return _firstname;        
}

-(NSString*)lastname
{
    if (!_lastname)
        [self parseName];
    return _lastname;        
}

-(void)parseName
{
    NSArray *components = [self.name componentsSeparatedByString:@" "];
    
    if (components.count>1)
        _lastname = [components objectAtIndex:components.count-1];
    _firstname = [components objectAtIndex:0];
}


@end
