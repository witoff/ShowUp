//
//  ModelFbList.m
//  perspect
//
//  Created by Robert Witoff on 3/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ModelFbList.h"
#import "PspctAppDelegate.h"

@implementation ModelFbList

@dynamic list_type;

+(NSArray*)getAll
{
    return [ModelFbList getAllWithPredicate:nil];
}

+(NSArray*)getAllVisible
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"is_visible == %@", [NSNumber numberWithBool:YES]];
    return [ModelFbList getAllWithPredicate:pred];
}

+(NSArray*)getAllWithPredicate:(NSPredicate*)predicate
{
    //Get Context
    PspctAppDelegate *delegate = (PspctAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    //Get Entity
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"FbList" inManagedObjectContext:context]];
    
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
    NSLog(@"ModelFbList :: groupFromFbBlob");
    PspctAppDelegate *delegate = (PspctAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    //Creating a managed object
    ModelFbList *list = [NSEntityDescription insertNewObjectForEntityForName:@"FbList" inManagedObjectContext:context];

    list.fb_key = [blob objectForKey:@"id"];
    list.name = [blob objectForKey:@"name"];
    list.list_type = [blob objectForKey:@"list_type"];
    list.is_visible = [NSNumber numberWithBool:YES];

    return list;
}

@end
