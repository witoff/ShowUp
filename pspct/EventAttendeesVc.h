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

@interface EventAttendeesVc : UITableViewController<MFMessageComposeViewControllerDelegate>
{
    EKEvent *event;
    NSMutableDictionary* attendeeContacts;
    UIImage *imgMissing;
}

-(id)initWithEvent:(EKEvent*)evt;
-(void)parseContacts;

@property(nonatomic, retain) EKEvent *event;
@property(nonatomic, retain) NSMutableDictionary *attendeeContacts;
@property(nonatomic, retain) UIImage *imgMissing;

@end
