//
//  ModelFbGroup.m
//  perspect
//
//  Created by Robert Witoff on 3/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ModelFbGroup.h"
#import "PspctAppDelegate.h"

@implementation ModelFbGroup

+(NSArray*)getAll
{
    return [ModelFbGroup getAllWithPredicate:nil];
}

+(NSArray*)getAllVisible
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"is_visible == %@", [NSNumber numberWithBool:YES]];
    return [ModelFbGroup getAllWithPredicate:pred];
}

+(NSArray*)getAllWithPredicate:(NSPredicate*)predicate
{
    //Get Context
    PspctAppDelegate *delegate = (PspctAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    //Get Entity
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"FbGroup" inManagedObjectContext:context]];
    
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
    PspctAppDelegate *delegate = (PspctAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    //Creating a managed object
    ModelFbGroup *group = [NSEntityDescription insertNewObjectForEntityForName:@"FbGroup" inManagedObjectContext:context];
    
    group.fb_id = [blob objectForKey:@"id"];
    group.name = [blob objectForKey:@"name"];
    group.is_visible = [NSNumber numberWithBool:YES];
    
    return group;
}

@end
