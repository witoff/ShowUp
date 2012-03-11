//
//  ModelAbkContactMatch.h
//  perspect
//
//  Created by Robert Witoff on 3/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AbContact.h"

@class ModelFbUser;

@interface ModelAbkContactMatch : NSManagedObject
{
    AbContact *contact;
    BOOL hasSearchedForContact;
}

@property (nonatomic, retain) AbContact *contact;
@property (nonatomic, retain) NSString * ref_key;
@property (nonatomic, retain) NSSet *fb_match;

+(ModelAbkContactMatch*)insertNewMatch;
-(AbContact*)getAbContact;

@end

@interface ModelAbkContactMatch (CoreDataGeneratedAccessors)

- (void)addFb_matchObject:(ModelFbUser *)value;
- (void)removeFb_matchObject:(ModelFbUser *)value;
- (void)addFb_match:(NSSet *)values;
- (void)removeFb_match:(NSSet *)values;

@end
