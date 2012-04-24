//
//  EventVc.h
//  pspct
//
//  Created by Robert Witoff on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"
#import <MessageUI/MessageUI.h>

@interface EventsVc : UITableViewController<FBRequestDelegate, MFMessageComposeViewControllerDelegate>
{
    NSArray *birthdays;
    NSMutableArray *events;
}

@property (nonatomic, retain) NSArray *birthdays; 
@property (nonatomic, retain) NSMutableArray *events; 

-(NSArray*)getContactDetails:(NSString*)firstname andLast:(NSString*)lastname;
-(void)sendSms:(NSString*)fullname;

@end
