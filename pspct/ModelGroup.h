//
//  ModelGroup.h
//  perspect
//
//  Created by Robert Witoff on 3/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ModelFbUser;

@interface ModelGroup : NSManagedObject

@property (nonatomic, retain) NSNumber * is_visible;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * fb_id;
@property (nonatomic, retain) NSSet *users;
@end

@interface ModelGroup (CoreDataGeneratedAccessors)

- (void)addUsersObject:(ModelFbUser *)value;
- (void)removeUsersObject:(ModelFbUser *)value;
- (void)addUsers:(NSSet *)values;
- (void)removeUsers:(NSSet *)values;

+(NSArray*)getAll;
+(NSArray*)getAllWithPredicate:(NSPredicate*)predicate;
+(NSArray*)getAllVisible;

+(ModelGroup*)groupFromFbBlob:(NSDictionary*)blob;

@end
