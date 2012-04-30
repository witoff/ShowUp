//
//  ModelFbUser.m
//  perspect
//
//  Created by Robert Witoff on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ModelFbUser.h"
#import "ModelAbkContactMatch.h"
#import "ModelGroupUserEntry.h"
#import "PspctAppDelegate.h"
#import "ContactProviderAb.h"
#import "ContactSearcher.h"

@implementation ModelFbUser

@dynamic abk_confidence;
@dynamic birthday;
@dynamic fb_key;
@dynamic firstname;
@dynamic lastname;
@dynamic name;
@dynamic adbk_match;
@dynamic groups;


/*
 +(NSArray*)getAll
 {
 return [ModelFbUser getAllWithPredicate:nil];
 }
 
 +(NSArray*)getAllVisible
 {
 NSPredicate *pred = [NSPredicate predicateWithFormat:@"is_visible == %@", [NSNumber numberWithBool:YES]];
 return [ModelFbUser getAllWithPredicate:pred];
 }*/

+(ModelFbUser*)getUserWithFbKey:(NSString*)key
{
    if (!key || key.length==0)
        return nil;
    

    //Get Context
    PspctAppDelegate *delegate = (PspctAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    //Get Entity
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"FbUser" inManagedObjectContext:context];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"fb_key like %@", key];
    request.predicate = pred;
    
    NSError *error;
    NSArray *matching_objects = [context executeFetchRequest:request error:&error]; ;
    if (error)
    {
        NSLog(@"There was an error returning all users: %@", [error description]);
        return nil;
    }
    
    if (matching_objects.count==0)
        return nil;
    
    if (matching_objects.count>1)
        NSLog(@"WARNING: multiple FB users found for key: %@.  There should never be more than 1", key);
    
    return [matching_objects objectAtIndex:0];
}

/** Set firstname and lastname fields from othe generic 'name' field **/
-(void)parseName
{
    NSArray *components = [self.name componentsSeparatedByString:@" "];
    
    if (components.count>1)
        self.lastname = [components objectAtIndex:components.count-1];
    self.firstname = [components objectAtIndex:0];
}

+(ModelFbUser*)insertNewObject
{
    PspctAppDelegate *delegate = (PspctAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    ModelFbUser *user = [NSEntityDescription insertNewObjectForEntityForName:@"FbUser" inManagedObjectContext:context];
    return user;
}

+(ModelFbUser*)insertUserFromFbBlob:(NSDictionary*)blob
{
    ModelFbUser *user = [ModelFbUser insertNewObject];
    user.fb_key = [blob objectForKey:@"id"];
    user.name = [blob objectForKey:@"name"];
    [user parseName];
    
    [user addAbkContactMatch];
    
    return user;
}

+(NSArray*)getAllUsers
{
    
    //Get Context
    PspctAppDelegate *delegate = (PspctAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    //Get Entity
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"FbUser" inManagedObjectContext:context]];
    
    NSError *error;
    NSArray *matching_objects = [context executeFetchRequest:request error:&error]; ;
    if (error)
    {
        NSLog(@"There was an error returning all model groups: %@", [error description]);
        return [[NSArray alloc] init];
    }
    
    return matching_objects;
}

-(void)addAbkContactMatch
{    
    ContactSearcher *searcher = [[ContactSearcher alloc] initWithContactProvider:[ContactProvider defaultProvider] andFbUser:self];
    AbContact *match = [searcher getMatchingAbContact];
    
    if (match)
    {
        ModelAbkContactMatch* modelMatch = [ModelAbkContactMatch insertNewMatch];
        
        modelMatch.ref_key = [match.key stringValue];
        [modelMatch addFb_matchObject:self];
        
        self.adbk_match = modelMatch;
    }
}
@end
