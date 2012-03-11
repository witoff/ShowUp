//
//  ModelFbUser.h
//  perspect
//
//  Created by Robert Witoff on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ModelAbkContactMatch, ModelGroupUserEntry;

@interface ModelFbUser : NSManagedObject

@property (nonatomic, retain) NSNumber * abk_confidence;
@property (nonatomic, retain) NSDate * birthday;
@property (nonatomic, retain) NSString * fb_key;
@property (nonatomic, retain) NSString * firstname;
@property (nonatomic, retain) NSString * lastname;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) ModelAbkContactMatch *adbk_match;
@property (nonatomic, retain) NSSet *groups;

-(void)parseName;

@end

@interface ModelFbUser (CoreDataGeneratedAccessors)

- (void)addGroupsObject:(ModelGroupUserEntry *)value;
- (void)removeGroupsObject:(ModelGroupUserEntry *)value;
- (void)addGroups:(NSSet *)values;
- (void)removeGroups:(NSSet *)values;

+(ModelFbUser*)getUserWithFbKey:(NSString*)key;
+(ModelFbUser*)insertUserFromFbBlob:(NSDictionary*)blob;
+(ModelFbUser*)insertNewObject;
+(NSArray*)getAllUsers;

-(void)addAbkContactMatch;

@end
