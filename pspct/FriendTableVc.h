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
#import "ModelGroup.h"

@interface FriendTableVc : UITableViewController<FBRequestDelegate, MFMessageComposeViewControllerDelegate>
{
    ModelGroup *group;
    NSMutableArray* friends;
    
    UIBarButtonItem* btnMessage;
    
    UIImage *imgMissing;
}

@property (nonatomic, retain) ModelGroup *group;
@property (nonatomic, retain) NSMutableArray *friends;
@property (nonatomic, retain) UIBarButtonItem *btnMessage;
@property (nonatomic, retain) UIImage *imgMissing;

- (id)initWithGroup:(ModelGroup*)group;
- (void)sendSmsWithMessage:(NSString*)message;
-(void)updateRowOrder;

@end
