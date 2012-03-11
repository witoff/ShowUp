//
//  ModelAbkContactMatch.m
//  perspect
//
//  Created by Robert Witoff on 3/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ModelAbkContactMatch.h"
#import "ModelFbUser.h"
#import "PspctAppDelegate.h"
#import "AbContact.h"

@implementation ModelAbkContactMatch

@synthesize contact;

@dynamic ref_key;
@dynamic fb_match;

+(ModelAbkContactMatch*)insertNewMatch
{
    PspctAppDelegate *delegate = (PspctAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    ModelAbkContactMatch *match = [NSEntityDescription insertNewObjectForEntityForName:@"AbkContactMatch" inManagedObjectContext:context];
    
    return match;
}

-(AbContact*)getAbContact
{
    if (!self.contact && !hasSearchedForContact)
    {
        NSNumber *key = [NSNumber numberWithInteger:self.ref_key.integerValue];
        AbContact *cnt = [AbContact contactWithAbContactKey:key];
        self.contact = cnt;
        hasSearchedForContact = YES;
    }
    
    return self.contact;
}


@end
