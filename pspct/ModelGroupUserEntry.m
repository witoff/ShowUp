//
//  ModelGroupUserEntry.m
//  perspect
//
//  Created by Robert Witoff on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ModelGroupUserEntry.h"
#import "ModelFbUser.h"
#import "ModelGroup.h"
#import "PspctAppDelegate.h"

@implementation ModelGroupUserEntry

@dynamic order;
@dynamic is_visible;
@dynamic is_selected;
@dynamic group;
@dynamic user;

+(ModelGroupUserEntry*)insertNewObject
{
    PspctAppDelegate *delegate = (PspctAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    ModelGroupUserEntry *entry = [NSEntityDescription insertNewObjectForEntityForName:@"GroupUserEntry" inManagedObjectContext:context];
    return entry;
}

@end
