//
//  ModelGroup.m
//  perspect
//
//  Created by Robert Witoff on 3/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ModelGroup.h"
#import "ModelFbUser.h"
#import "PspctAppDelegate.h"

@implementation ModelGroup

@dynamic is_visible;
@dynamic name;
@dynamic order;
@dynamic fb_id;
@dynamic users;


+(NSArray*)getAll
{
    return [ModelGroup getAllWithPredicate:nil];
}

+(NSArray*)getAllVisible
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"is_visible == %@", [NSNumber numberWithBool:YES]];
    return [ModelGroup getAllWithPredicate:pred];
}

+(NSArray*)getAllWithPredicate:(NSPredicate*)predicate
{
    NSLog(@"ModelGroup");
    //Get Context
    PspctAppDelegate *delegate = (PspctAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    //Get Entity
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"ModelGroup" inManagedObjectContext:context]];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sort]];

    if (predicate)
        [request setPredicate: predicate];
    
    NSError *error;
    NSArray *matching_objects = [context executeFetchRequest:request error:&error]; ;
    if (error)
    {
        NSLog(@"There was an error returning all model groups: %@", [error description]);
        return [[NSArray alloc] init];
    }
    return matching_objects;
}

+(ModelGroup*)groupFromFbBlob:(NSDictionary*)blob
{
    NSLog(@"Blob available on base class");
    return nil;
}

@end
