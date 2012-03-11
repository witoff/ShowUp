//
//  ModelGroupUserEntry.h
//  perspect
//
//  Created by Robert Witoff on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ModelFbUser, ModelGroup;

@interface ModelGroupUserEntry : NSManagedObject

@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSNumber * is_visible;
@property (nonatomic, retain) NSNumber * is_selected;
@property (nonatomic, retain) ModelGroup *group;
@property (nonatomic, retain) ModelFbUser *user;

+(ModelGroupUserEntry*)insertNewObject;

@end
