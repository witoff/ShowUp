//
//  PspctFriendLists.h
//  pspct
//
//  Created by Robert Witoff on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"

@interface PspctFriendListTableVc : UITableViewController<FBRequestDelegate>
{
    NSArray* friendLists;
}

@property (nonatomic, retain) NSArray *friendLists;



@end
