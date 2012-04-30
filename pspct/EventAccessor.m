//
//  EventAccessor.m
//  perspect calendar
//
//  Created by Robert Witoff on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventAccessor.h"
#import <EventKit/EventKit.h>
#import "PspctAppDelegate.h"
#import "JSON.h"

@implementation EventAccessor


-(NSArray*)getEventsFromOffset:(int)from to:(int)to{
    
    
    PspctAppDelegate *delegate = (PspctAppDelegate *)[[UIApplication sharedApplication] delegate];
    EKEventStore *store = delegate.store;
    
    // Create the predicate's start and end dates.
    CFGregorianDate gregorianStartDate, gregorianEndDate;
    CFGregorianUnits startUnits = {0, 0, from, 0, 0, 0};
    CFGregorianUnits endUnits = {0, 0, to, 0, 0, 0};
    CFTimeZoneRef timeZone = CFTimeZoneCopySystem();
    
    gregorianStartDate = CFAbsoluteTimeGetGregorianDate(
                                                        CFAbsoluteTimeAddGregorianUnits(CFAbsoluteTimeGetCurrent(), timeZone, startUnits),
                                                        timeZone);
    gregorianStartDate.hour = 0;
    gregorianStartDate.minute = 0;
    gregorianStartDate.second = 0;
    
    gregorianEndDate = CFAbsoluteTimeGetGregorianDate(
                                                      CFAbsoluteTimeAddGregorianUnits(CFAbsoluteTimeGetCurrent(), timeZone, endUnits),
                                                      timeZone);
    gregorianEndDate.hour = 0;
    gregorianEndDate.minute = 0;
    gregorianEndDate.second = 0;
    
    NSDate* startDate =
    [NSDate dateWithTimeIntervalSinceReferenceDate:CFGregorianDateGetAbsoluteTime(gregorianStartDate, timeZone)];
    NSDate* endDate =
    [NSDate dateWithTimeIntervalSinceReferenceDate:CFGregorianDateGetAbsoluteTime(gregorianEndDate, timeZone)];
    
    CFRelease(timeZone);
    
    // Create the predicate.
    NSPredicate *predicate = [store predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil]; // eventStore is an instance variable.
    
    // Fetch all events that match the predicate.
    NSArray *events = [store eventsMatchingPredicate:predicate];
    
    //[self setEvents:events];
    
    if (!events)
        events = [[NSArray alloc] init];
    return events;
}

-(NSArray*)debugGetLocalEvents
{
    //Load from disk
    NSString *path = [[NSBundle mainBundle] pathForResource:@"allevents" ofType:@"json"];  
    NSString *raw = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray *data = [raw JSONValue];

    /*
    NSMutableArray *eventss = [[NSMutableArray alloc] initWithCapacity:data.count];
    EKEventStore *store = [[EKEventStore alloc] init];

    for (NSDictionary *entry in data) {
        
        EKEvent *event = [EKEvent eventWithEventStore:store];
        EKParticipant *test = [[EKParticipant alloc] init];
        test.name = @"arst"
    }
    
     */
    return data;
}

@end
