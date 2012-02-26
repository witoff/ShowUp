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

@interface FriendTableVc : UITableViewController<FBRequestDelegate, MFMessageComposeViewControllerDelegate>
{
    NSString* listId;
    NSString* listName;
    NSString* listType;
    NSMutableArray* friends;
    NSMutableArray* friends_hidden;
    
    NSMutableDictionary *selected;
    
    UIBarButtonItem* btnMessage;
    
    UIImage *imgMissing;
}

@property (nonatomic, retain) NSString *listId;
@property (nonatomic, retain) NSString *listName;
@property (nonatomic, retain) NSString *listType;
@property (nonatomic, retain) NSMutableArray *friends;
@property (nonatomic, retain) NSMutableArray *friends_hidden;
@property (nonatomic, retain) NSMutableDictionary *selected;
@property (nonatomic, retain) UIBarButtonItem *btnMessage;
@property (nonatomic, retain) UIImage *imgMissing;

- (id)initWithListId:(NSString*)identifier andListName:(NSString*)name andListType:(NSString*)type;

- (void)sendSmsWithMessage:(NSString*)message;

@end
