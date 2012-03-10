//
//  ModelFbUser.h
//  perspect
//
//  Created by Robert Witoff on 3/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ModelAbkContactMatch, ModelFbGroup;

@interface ModelFbUser : NSManagedObject

@property (nonatomic, retain) NSNumber * abk_confidence;
@property (nonatomic, retain) NSDate * birthday;
@property (nonatomic, retain) NSString * fb_id;
@property (nonatomic, retain) NSString * firstname;
@property (nonatomic, retain) NSString * lastname;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) ModelAbkContactMatch *adbk_match;
@property (nonatomic, retain) NSSet *groups;
@end

@interface ModelFbUser (CoreDataGeneratedAccessors)

- (void)addGroupsObject:(ModelFbGroup *)value;
- (void)removeGroupsObject:(ModelFbGroup *)value;
- (void)addGroups:(NSSet *)values;
- (void)removeGroups:(NSSet *)values;

@end
