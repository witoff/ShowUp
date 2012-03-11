//
//  ModelGroup.h
//  perspect
//
//  Created by Robert Witoff on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ModelGroupUserEntry;

@interface ModelGroup : NSManagedObject

@property (nonatomic, retain) NSString * fb_key;
@property (nonatomic, retain) NSNumber * is_visible;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSSet *users;

+(NSArray*)getAll;
+(NSArray*)getAllWithPredicate:(NSPredicate*)predicate;
+(NSArray*)getAllVisible;

+(ModelGroup*)groupFromFbBlob:(NSDictionary*)blob;

@end

@interface ModelGroup (CoreDataGeneratedAccessors)

- (void)addUsersObject:(ModelGroupUserEntry *)value;
- (void)removeUsersObject:(ModelGroupUserEntry *)value;
- (void)addUsers:(NSSet *)values;
- (void)removeUsers:(NSSet *)values;

@end
