//
//  EventAttendeesVc.h
//  perspect calendar
//
//  Created by Robert Witoff on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import <MessageUI/MessageUI.h>
#import "EventAttendeeSliderCell.h"

@interface EventAttendeesVc : UITableViewController<MFMessageComposeViewControllerDelegate>
{
    EKEvent *event;
    UIImage *imgMissing;

    // All of the event EKParticipants that are displayed
    NSMutableArray* invited;

    
@private
    NSArray *_titleContacts;
    NSMutableDictionary* _attendeeContacts;
    EventAttendeeSliderCell *_sliderCell;
}

-(id)initWithEvent:(EKEvent*)evt;
-(void)parseContacts;

@property(nonatomic, retain) EKEvent *event;
@property(nonatomic, retain) NSMutableArray *invited;

@property(nonatomic, retain) UIImage *imgMissing;

@property(nonatomic, retain) NSMutableDictionary *_attendeeContacts;
@property(nonatomic, retain) NSArray* _titleContacts;
@property(nonatomic, retain) EventAttendeeSliderCell *_sliderCell;

@end
