//
//  EventAccessor.h
//  perspect calendar
//
//  Created by Robert Witoff on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventAccessor : NSObject

-(NSArray*)getEventsFromOffset:(int)from to:(int)to;


-(NSArray*)debugGetLocalEvents;
-(NSArray*)debugGetUniqueEventAttendees;
-(NSArray*)debugGetUniqueEventTitles;

@end
