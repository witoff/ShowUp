//
//  PspctFriendLists.h
//  pspct
//
//  Created by Robert Witoff on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"

#define FILE_FRIENDLISTS @"friendLists"
#define FILE_FRIENDLISTS_HIDDEN @"friendLists_hidden"

@interface FriendListTableVc : UITableViewController<FBRequestDelegate>
{
    NSMutableArray* friendLists;
    NSMutableArray* friendLists_hidden;
}

@property (nonatomic, retain) NSMutableArray *friendLists;
@property (nonatomic, retain) NSMutableArray *friendLists_hidden;

+(void) deleteData;
+(void) showHiddenLists;

-(void) loadData;
-(void) saveData;

-(void) preloadMvc;

@end
