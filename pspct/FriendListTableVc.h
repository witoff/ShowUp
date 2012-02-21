//
//  PspctFriendLists.h
//  pspct
//
//  Created by Robert Witoff on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"

@interface FriendListTableVc : UITableViewController<FBRequestDelegate>
{
    NSMutableArray* friendLists;
    NSMutableArray* friendLists_hidden;
}

@property (nonatomic, retain) NSMutableArray *friendLists;
@property (nonatomic, retain) NSMutableArray *friendLists_hidden;

-(IBAction)btnEdit_click:(id)sender;
-(void) preloadMvc;
-(void) loadData;
-(void) saveData;

-(IBAction)editOrder:(id)sender;

@end
