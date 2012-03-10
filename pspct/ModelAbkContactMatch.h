//
//  ModelAbkContactMatch.h
//  perspect
//
//  Created by Robert Witoff on 3/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ModelFbUser;

@interface ModelAbkContactMatch : NSManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) ModelFbUser *fb_match;

@end
