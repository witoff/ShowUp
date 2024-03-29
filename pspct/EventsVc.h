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

@interface EventsVc : UITableViewController<MFMessageComposeViewControllerDelegate>
{
    @private
    bool didScroll;
    NSArray *birthdays;
    NSMutableArray *events;
}

@property (nonatomic, retain) NSArray *birthdays; 
@property (nonatomic, retain) NSMutableArray *events; 


-(IBAction)scrollToToday:(id)sender;
-(IBAction)reloadEvents:(id)sender;

@end
