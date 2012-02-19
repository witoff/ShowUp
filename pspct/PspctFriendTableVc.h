//
//  PspctFriendTableVc.h
//  pspct
//
//  Created by Robert Witoff on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBRequest.h"
#import <MessageUI/MessageUI.h>

@interface PspctFriendTableVc : UITableViewController<FBRequestDelegate, MFMessageComposeViewControllerDelegate>
{
    NSString* listId;
    NSString* listName;
    NSArray* friends;
    NSMutableArray* selected;
}

@property (nonatomic, retain) NSString *listId;
@property (nonatomic, retain) NSString *listName;
@property (nonatomic, retain) NSArray *friends;
@property (nonatomic, retain) NSMutableArray *selected;

- (id)initWithListId:(NSString*)identifier andListName:(NSString*)name;
- (void)delayPresentation:(MFMessageComposeViewController*)mvc;
- (IBAction)sendMessage:(id)sender;

@end
